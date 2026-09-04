import { LightningElement, api, track } from 'lwc';
import getFinancialWrapper from '@salesforce/apex/FinancialViewTemplateR2Controller.getFinancialWrapper'
import getVisibleFieldsForFinancials from '@salesforce/apex/FinancialViewTemplateR2Controller.getVisibleFieldsForFinancials'
import updateParentFinancials from '@salesforce/apex/FinancialViewTemplateR2Controller.updateParentFinancials'
import { showToastMessage, setPicklistsValues, validate, getUniqueValue, getApplicantName } from 'c/lwcutilities';
import getTractorFinancialValidations from '@salesforce/apex/FinancialViewTemplateR2Controller.getTractorFinancialValidations'
import getExistingChildFinancialRecords from '@salesforce/apex/FinancialViewTemplateR2Controller.getExistingChildFinancialRecords'
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import { getSpinnerImage } from 'c/customSpinner';
import { updateRecord } from 'lightning/uiRecordApi';
import getFinancialStatus from '@salesforce/apex/financeController.getFinancialStatus';

import {
    APPLICATION_SCOPE,
    createMessageContext,
    MessageContext,
    publish,
    releaseMessageContext,
    subscribe,
    unsubscribe,
} from 'lightning/messageService';
import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c';

export default class TractorFinancialChildTemplates extends LightningElement {

    @api isMobile
    @track currentApplicant
    @track renderSPHViabilitySheet
    @track renderTRSmallViabilitySheet
    @track showViabilityFields
    @track loanStage;
    @track visibleFields;
    @track parentFinancialRecord={}
    @track loanApplication
    @track renderEmpTemplates;
    @track applicantsData=[]
    @track loanId
    @track templateName;
    childRecValues
    @track childRecords 
    @track considerIncome=true
    @track fcfRatioMandatory=false
    @api spinnerImage
    isLoading
    messageContext = createMessageContext();

    @api
    async renderValuesPredefined(selectedId, applicantData){
        this.loanId = applicantData[0].Loan__c;
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.loanId);
        }
        this.isLoading=true
        this.applicantsData = applicantData
        applicantData.forEach(input=>{
            if(input.Id == selectedId){
                this.currentApplicant = input
            }
        })
        
        this.loanStage  =  applicantData[0].Loan__r.Stage__c;

        this.visibleFields = await getVisibleFieldsForFinancials({strScreen: 'Financials Tractor',strStage: this.loanStage, typeOfWheeler: 'Tractor'})
        if(this.visibleFields && this.visibleFields.length>0){
            this.visibleFields.forEach(input=>{
                this.template.querySelector('[data-id="'+input+'"]').classList.remove('slds-hide')
                this.template.querySelector('[data-name="'+input+'"]').classList.add('validate')
            })
        }
        
        this.setInitialData(true)
    }

    async getChildRecords(){
        this.childRecords=[]
        this.childRecords = await getExistingChildFinancialRecords({applicantId: this.currentApplicant.Id})
        if(this.childRecords && this.childRecords.length>0){
            this.template.querySelector('[data-name="Total_Income__c"]').disabled=true
        }else{
            this.template.querySelector('[data-name="Total_Income__c"]').disabled=false
        }
    }

    async setInitialData(fromInit){
        this.renderEmpTemplates=false
        this.renderSPHViabilitySheet=false
        this.renderTRSmallViabilitySheet=false
        this.showViabilityFields=false
        let applicableCustomerGrades = ['FTU','FTB','Transporter']
        const response = await getFinancialWrapper({applicantId: this.currentApplicant.Id, applicants: this.applicantsData})
        this.parentFinancialRecord = response && response.parentFinancial?response.parentFinancial:{}
        this.loanApplication = response && response.relatedLoan?response.relatedLoan:{}
        this.calculateAnnualEMI()
        //this.parentFinancialRecord.Proposed_Installment__c = this.loanApplication.EMI__c
        await this.getChildRecords()
        this.handleChildSubmit()
        this.considerIncome = this.parentFinancialRecord.Consider_Income_for_Eligibility__c=='Yes'?true:false
        if(this.considerIncome){
            if(this.loanApplication.Collateral_Type__c=='10133' && (this.loanApplication.Original_Vehicle_Usage__c=='Agri' || this.loanApplication.Original_Vehicle_Usage__c=='Commercial')){
                this.fcfRatioMandatory=this.loanApplication.Original_Vehicle_Usage__c=='Commercial'?true:false//R2-2358
                setTimeout(() => {
                    this.renderSPHViabilitySheet=true
                    this.showViabilityFields=true
                }, 100);   
                
            }else if(this.loanApplication.Collateral_Type__c=='10109' && this.loanApplication.Original_Vehicle_Usage__c=='Commercial' && this.currentApplicant.RecordType.DeveloperName=='Primary_Applicant' && applicableCustomerGrades.includes(this.loanApplication.Customer_Grade__c)){
                //this.fcfRatioMandatory=this.loanApplication.Original_Vehicle_Usage__c=='Commercial'?true:false//R2-2358
                setTimeout(() => {
                    this.renderTRSmallViabilitySheet=true
                    this.showViabilityFields=true
                }, 100);   
                //R2-2849
            }
    
            let incomeProfileMaster = Array.from(response.profileMasterList)
            const matchingRecord = incomeProfileMaster.find((item) =>
                item.Type_of_Employment__c === this.parentFinancialRecord.Type_Of_Employment__c && item.Method_Assesment__c === this.parentFinancialRecord.Method_Of_Assesment__c
            );
            if (matchingRecord) {
                this.templateName = matchingRecord.Financial_Template__c;
                this.setTemplateName(this.templateName);
            }
        }
        this.isLoading=false
        
    }

    calculateAnnualEMI(){
        if(this.loanApplication.Emi_Frequency__c){
            if(this.loanApplication.Emi_Frequency__c.includes('HALF')){
                this.parentFinancialRecord.Proposed_Installment__c=this.loanApplication.EMI__c*2
            }else if(this.loanApplication.Emi_Frequency__c.includes('QUARTERLY')){
                this.parentFinancialRecord.Proposed_Installment__c=this.loanApplication.EMI__c*4
            }else if(this.loanApplication.Emi_Frequency__c.includes('MONTHLY')){
                this.parentFinancialRecord.Proposed_Installment__c=this.loanApplication.EMI__c*12
            }
        }
    }

    setTemplateName(template){
        this.renderEmpTemplates=true;
        setTimeout(() => {
            this.template.querySelector('c-templates-based-on-emp-type').setTemplates(template, this.childRecords)
          }, 300);
    }

    handleChildSubmit(event){
        if(event && event.detail && event.detail.templateName){
            this.template.querySelector('[data-name="Total_Income__c"]').disabled=true
        }
        updateParentFinancials({parentFinancialId: this.parentFinancialRecord.Id}).then(data=>{
            if(data=='Success'){
                this.getParentDetail()   
                const payload = { recordIdOfSobject: this.loanApplication.Id, refreshPage: 'Yes'};
                publish(this.messageContext, pageRefreshOnMaterialFieldChange, payload);
                //this.setInitialData(false)
            }else if(data=='Failure'){

            }
        })
    }

    async getParentDetail(){
        const response = await getFinancialWrapper({applicantId: this.currentApplicant.Id, applicants: this.applicantsData})
        this.parentFinancialRecord = response && response.parentFinancial?response.parentFinancial:{}
        this.loanApplication = response && response.relatedLoan?response.relatedLoan:{}
        this.calculateAnnualEMI()
        //this.parentFinancialRecord.Proposed_Installment__c = this.loanApplication.EMI__c                
    }

    handleChange(event){
        var name = event.target.name
        var value = event.target.value
        this.parentFinancialRecord[name]=value
    }

    handleSaveIncome(event){
restricAccess({
            compName: 'tractorFinancial' ,loanId: this.loanApplication.Id
            })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    showToastMessage(this, "", "error", "You do not have access to save/edit Financial Details", "dismissable");
                    /*const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save/edit Payment Favourings',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);*/
                }
                else{
                        let inputFields = this.template.querySelectorAll(".validate");
                        /*if(!this.parentFinancialRecord.Company_Name__c){
                            showToastMessage(this, "", "error", "Please enter Company/Business Name", "sticky");
                            return;
                        }*/
                        if (validate(inputFields)) {
                            const fields= {Id: this.parentFinancialRecord.Id, Total_Income__c: this.parentFinancialRecord.Total_Income__c, 
                                Proposed_Installment__c: this.parentFinancialRecord.Proposed_Installment__c}//this.loanApplication.EMI__c};
                            const recordInput = {fields}
                            updateRecord(recordInput).then((data)=>{
                                showToastMessage(this, "", "success", "Financial Details Updated Successfully", "dismissable");
                            }).catch((error)=>{
                                console.error('error is '+JSON.stringify(error))
                            })
                        }
                }
            })
            .catch(error=>{
                console.log('error is ' + JSON.stringify(error));
        
        })
    }

    @api
    async nextChildHandler(){
        this.isLoading=true
        let validations = await getTractorFinancialValidations({loan: this.loanApplication}) 
        if(validations && validations.length>0){
            validations.forEach(input=>{
                showToastMessage(this, "", "error", input, "sticky");
            })   
            this.isLoading=false
        }else{
            const Obj = {};
            /*let data = await getFinancialStatus({loanId : this.loanApplication.Id});
            console.log('mandatoryDDEParameter-->' +data.mandatoryDDEParameter);
            if(data.resultCheck == true){
                if(data.mandatoryDDEParameter == true){
                    this.isLoading=false
                    showToastMessage(this,'','error','Some of the Required fields are missing please edit to proceed', 'sticky');
                    return;
                }else{
                    this.isLoading=false
                    this.errorOnChild = '';
                    Obj.errorOnChild = this.errorOnChild;
                    Obj.next = this.errorOnChild == '' ? true : false;
                    console.log('Obj', Obj);    
                }
            }else{
                this.isLoading=false
                showToastMessage(this,'','error','Details are missing for '+data.validationNames, 'sticky');
                this.errorOnChild = 'Please fill the Details for the Applicant';
                Obj.errorOnChild = '';
                Obj.next = this.errorOnChild == '' ? true : false;
                console.log('Obj', Obj);
            }*/
            this.errorOnChild = '';
            Obj.errorOnChild = this.errorOnChild;
            Obj.next = this.errorOnChild == '' ? true : false;
            console.log('Obj', Obj);
            this.dispatchEvent(new CustomEvent('next', {
                detail: {
                    Obj: Obj
                }
            }));    
            this.isLoading=false
        }
    }
    
}