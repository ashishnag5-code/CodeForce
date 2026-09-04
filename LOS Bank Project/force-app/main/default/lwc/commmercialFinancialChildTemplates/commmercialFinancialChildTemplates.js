import { LightningElement,wire,api,track } from 'lwc';
import getFinancialWrapper from '@salesforce/apex/FinancialViewTemplateR2Controller.getFinancialWrapper'
import getVisibleFieldsForFinancials from '@salesforce/apex/FinancialViewTemplateR2Controller.getVisibleFieldsForFinancials'
import getViabilityTemplatesMapping from '@salesforce/apex/FinancialViewTemplateR2Controller.getViabilityTemplatesMapping'
import updateParentFinancials from '@salesforce/apex/FinancialViewTemplateR2Controller.updateCommercialParentFinancials'
import upsertIncome from '@salesforce/apex/AgricultureIncomeDetailsController.upsertIncome'
import getExistingChildFinancialRecords from '@salesforce/apex/FinancialViewTemplateR2Controller.getExistingChildFinancialRecords'
import isPanMandatory from '@salesforce/apex/FinancialViewTemplateR2Controller.isPanMandatory';
import { toastWithMessage, showToastMessage } from 'c/lwcutilities';
import { getSpinnerImage } from 'c/customSpinner';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';

export default class CommmercialFinancialChildTemplates extends LightningElement {

    // For financial template by credit to be filled 
    @api loanId;
    selectedApplicantId;
    // For financial template by credit to be filled 
     
    //track attributes
    @track viabilityData;
    @track renderCommercialViabilitySheet = false;
    @track renderCommercialSmallViabilitySheet = false;
    @track renderCommercialConstructionViabilitySheet = false;
    @track renderHireVsBuy = false;
    @track renderEmpTemplates = false;
    @track showViabilitySheets = false;
    @track isMonthlyBreakup = false; // this is to display Documented/Assessed Income only if the values are filled
    @track templatesToShow =[];
    @track profileMasterData;
    @api isMobile;
    @track parentFinancialRecord={}
    @track applicantParentLoanFinancial={};
    @track applicantParentLoanChildFinancial ={}
    @track isBodyFunding = false;
    @track hideFCF = false;
    
    
    @track childRecords


    @api
    async renderValuesPredefined(selectedId, applicantData){
        this.selectedApplicantId = selectedId;
         if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.loanId);
        }
        this.isLoading=true
        this.handleResetAttributes() //default will be false
        this.applicantsData = applicantData
        applicantData.forEach(input=>{
            if(input.Id == selectedId){
                this.currentApplicant = input
            }
        })
        this.loanId = applicantData[0].Loan__c;
        this.loanStage  =  applicantData[0].Loan__r.Stage__c;
       /* this.visibleFields = await getVisibleFieldsForFinancials({strScreen: 'Financials Tractor',strStage: this.loanStage, typeOfWheeler: 'Tractor'})
        this.visibleFields.forEach(input=>{
            this.template.querySelector('[data-id="'+input+'"]').classList.remove('slds-hide')
            this.template.querySelector('[data-name="'+input+'"]').classList.add('validate')
        })*/
        this.setInitialData(true)
    }

    async getChildRecords(){
        this.childRecords = await getExistingChildFinancialRecords({applicantId: this.currentApplicant.Id})
    }

    async setInitialData(fromInit){
        const response = await getFinancialWrapper({applicantId: this.currentApplicant.Id, applicants: this.applicantsData})
        console.log('response-->' +JSON.stringify(response));
        this.parentFinancialRecord = response && response.parentFinancial?response.parentFinancial:{}
        this.applicantParentLoanFinancial = response && response.parentLoanFinancial?response.parentLoanFinancial:{}
        this.applicantParentLoanChildFinancial = response && response.parentLoanChildFinancial?response.parentLoanChildFinancial:{}
        this.getChildRecords()
        //Only if Consider Income is Yes then only Templates are applicable
        if(this.parentFinancialRecord.Consider_Income_for_Eligibility__c=='Yes'){
        this.loanApplication = response && response.relatedLoan?response.relatedLoan:{}
        setTimeout(() => {
            console.log('this.currentApplican-->' +this.currentApplicant.RecordType.Name);
            this.showViabilitySheets = (this.loanApplication.Stage__c !=  'QDE' && this.currentApplicant.RecordType.Name=='Applicant')  ? true : false //R2-2668
            this.isMonthlyBreakup = (this.parentFinancialRecord.Monthly_Income__c!=0 || this.parentFinancialRecord.Other_Income__c!=0) ? true : false
            if(fromInit){
                this.handleTemplates()
                this.handleParentalUpdation()
            }
        }, 300);   
      
        this.profileMasterData  = response.profileMasterList     
        //Handle Body Funding Collateral Type pick from parent loan fcf/emi , fcf and emi , hirevsbuy decsion and then on change i need to recalcualte the fcf/emi nd decision logic 
        if(this.loanApplication.Collateral_Type__c == '10113' ){
            this.isBodyFunding = true;
            if(response.parentLoanChildFinancial){
                 if( (this.parentFinancialRecord.FCF_EMI__c==0 || this.parentFinancialRecord.FCF_EMI__c == undefined) && response.parentLoanChildFinancial.RecordType.DeveloperName!= 'Hire_VS_Buy'){
                this.parentFinancialRecord.Free_Cash_Flow__c = this.applicantParentLoanFinancial? this.applicantParentLoanFinancial.Free_Cash_Flow__c? this.applicantParentLoanFinancial.Free_Cash_Flow__c:0:0;
                this.parentFinancialRecord.Emi__c = this.applicantParentLoanFinancial? this.applicantParentLoanFinancial.Emi__c? this.applicantParentLoanFinancial.Emi__c:0:0;
                this.parentFinancialRecord.FCF_EMI__c = this.applicantParentLoanFinancial ? this.applicantParentLoanFinancial.FCF_EMI__c ? this.applicantParentLoanFinancial.FCF_EMI__c :0:0 ;
            }else if( (!this.parentFinancialRecord.HireVsBuy_Decision__c || this.parentFinancialRecord.HireVsBuy_Decision__c == undefined) &&  response.parentLoanChildFinancial.RecordType.DeveloperName == 'Hire_VS_Buy'){
                this.hideFCF = true;
                this.parentFinancialRecord.HireVsBuy_Decision__c = this.applicantParentLoanFinancial? this.applicantParentLoanFinancial.HireVsBuy_Decision__c? this.applicantParentLoanFinancial.HireVsBuy_Decision__c:'':'';
                this.parentFinancialRecord.Emi__c = this.applicantParentLoanFinancial? this.applicantParentLoanFinancial.Emi__c? this.applicantParentLoanFinancial.Emi__c:0:0;
                //this.parentFinancialRecord.FCF_EMI__c = this.applicantParentLoanFinancial ? this.applicantParentLoanFinancial.FCF_EMI__c ? this.applicantParentLoanFinancial.FCF_EMI__c :0:0 ;
             }
            }
        }    
        
        }else{
           this.handleResetAttributes()
            
        }
        this.isLoading = false;   
    }



    //Method to get the Viability Sheet Custom Metadata and get the template name 
    async handleTemplates() {
        //let data = this.viabilityData;
        let data = await getViabilityTemplatesMapping()
        // Filtering the data for CE if amt is less than 35lacs
        if (
            this.loanApplication.RecordType.DeveloperName == 'Construction_Equipment' &&
            this.loanApplication.Loan_Amount__c <= 3500000 &&  this.loanApplication.Collateral_Type__c =='10112'
          ) {
            data = data.filter(dataInstance => {
              return dataInstance.isLesserLoanAmt__c == true;
            });
          }
       // END
        console.log('filtereddata-->'+JSON.stringify(data));
       
          // updating R2-2668 [ instead of Customer Grade from Individual wise we need to refer Loan application Customer Grade as Co applicant and Gaurantor Customer Grade will not be there]  
        /*data.forEach(dataInstance => {
            if(this.parentFinancialRecord.Sub_Grade__c != undefined){
                if(this.parentFinancialRecord.Sub_Grade__c ){
                if (
                    dataInstance.Product__c.includes(this.loanApplication.Product__c) &&
                    dataInstance.Collateral_Type__c.includes(this.loanApplication.Collateral_Type__c) &&
                    dataInstance.Customer_Grade__c.includes(this.parentFinancialRecord.Customer_Grade__c) &&
                    dataInstance.Sub_Grade__c.includes(this.parentFinancialRecord.Sub_Grade__c)
                ) {
                    this.handleTemplate(dataInstance.Template_Name__c);
                }
              }else{
                if (
                    dataInstance.Product__c.includes(this.loanApplication.Product__c) &&
                    dataInstance.Collateral_Type__c.includes(this.loanApplication.Collateral_Type__c) &&
                    dataInstance.Customer_Grade__c.includes(this.parentFinancialRecord.Customer_Grade__c)
                ) {
                    this.handleTemplate(dataInstance.Template_Name__c);
                }
             }
            }else{
                if (
                    dataInstance.Product__c.includes(this.loanApplication.Product__c) &&
                    dataInstance.Collateral_Type__c.includes(this.loanApplication.Collateral_Type__c) &&
                    dataInstance.Customer_Grade__c.includes(this.parentFinancialRecord.Customer_Grade__c)
                ) {
                    this.handleTemplate(dataInstance.Template_Name__c);
                }
            }
           
        });*/
        data.forEach(dataInstance => {
            if(this.loanApplication.Sub_Grade__c != undefined){
                if(this.loanApplication.Sub_Grade__c ){
                if (
                    dataInstance.Product__c.includes(this.loanApplication.Product__c) &&
                    dataInstance.Collateral_Type__c.includes(this.loanApplication.Collateral_Type__c) &&
                    dataInstance.Customer_Grade__c.includes(this.loanApplication.Customer_Grade__c) &&
                    dataInstance.Sub_Grade__c.includes(this.loanApplication.Sub_Grade__c)
                ) {
                    this.handleTemplate(dataInstance.Template_Name__c);
                }
              }else{
                if (
                    dataInstance.Product__c.includes(this.loanApplication.Product__c) &&
                    dataInstance.Collateral_Type__c.includes(this.loanApplication.Collateral_Type__c) &&
                    dataInstance.Customer_Grade__c.includes(this.loanApplication.Customer_Grade__c)
                ) {
                    this.handleTemplate(dataInstance.Template_Name__c);
                }
             }
            }else{
                if (
                    dataInstance.Product__c.includes(this.loanApplication.Product__c) &&
                    dataInstance.Collateral_Type__c.includes(this.loanApplication.Collateral_Type__c) &&
                    dataInstance.Customer_Grade__c.includes(this.loanApplication.Customer_Grade__c)
                ) {
                    this.handleTemplate(dataInstance.Template_Name__c);
                }
            }
           
        });
    
    }
    
    handleResetAttributes(){
        this.showViabilitySheets = false
        this.renderCommercialViabilitySheet = false
        this.renderCommercialSmallViabilitySheet = false;
        this.renderCommercialConstructionViabilitySheet = false;
        this.renderHireVsBuy = false;
        this.renderEmpTemplates = false;
        this.isMonthlyBreakup = false
        this.parentFinancialRecord.HireVsBuy_Decision__c ='';
    }

    //Method to set the template to show
    handleTemplate(templateName) {
        if (templateName && templateName.includes(',')) {
            this.templatesToShow = templateName.split(',');
        } else {
            this.templatesToShow = [templateName];
        }
        console.log('this.templatesToShow-->' +this.templatesToShow);
        this.templatesToShow.forEach(template => {
            if(template == 'EmploymentType'){
                this.setMatchingRecord();
            }  
            if(template == 'Documented_With_Audited_financial' || template == 'Assessed_No_Document' ){
                this.renderEmpTemplates = true;
                setTimeout(() => {
                    this.template.querySelector('c-templates-based-on-emp-type').setTemplates(template,this.childRecords)
                  }, 300);
            }
            else{
                this.setTemplates(template);
            }
        });

      
    }
    // Method to set the template based on Type of Employment and Method of Assessment this is used when the value is Employment Type
    setMatchingRecord() {
        const matchingRecord = this.profileMasterData.find(item => (
            item.Type_of_Employment__c === this.parentFinancialRecord.Type_Of_Employment__c &&
            item.Method_Assesment__c === this.parentFinancialRecord.Method_Of_Assesment__c
        ));
    
        console.log('matchingRecord-->' + JSON.stringify(matchingRecord));
    
        if (matchingRecord) {
            let templateName = matchingRecord.Financial_Template__c;
            this.renderEmpTemplates = true;
            setTimeout(() => {
                this.template.querySelector('c-templates-based-on-emp-type').setTemplates(templateName,this.childRecords)
              }, 300);
            
            // this.setTemplates(this.templateName );
        }
    }
    
    //Common Method to set the templates boolean based on the record type
    setTemplates(templateName) {
        const templateMap = {
            'Viability_Sheet_Commercial_Vehicle': 'renderCommercialViabilitySheet',
            'Viability_Sheet_Small_Commercial_Vehicle': 'renderCommercialSmallViabilitySheet',
            'Viability_Sheet_Commercial_Equipment': 'renderCommercialConstructionViabilitySheet',
            'Hire_VS_Buy': 'renderHireVsBuy',
        };
        
        const templateProp = templateMap[templateName];
    
        if (templateProp !== null) {
            this[templateProp] = true;
        }
        console.log('this.renderCommercialSmallViabilitySheet' +this.renderCommercialSmallViabilitySheet);
    }

    handleChildSubmit(){
        this.handleParentalUpdation()
        
    }
    
    handleChange(event){
        let name = event.target.name
        let value = event.target.value

        if( name == 'Emi__c'){
            this.parentFinancialRecord.Emi__c = value;
            if(!this.hideFCF){
                this.parentFinancialRecord.FCF_EMI__c = this.parentFinancialRecord.Free_Cash_Flow__c/ value;
                this.parentFinancialRecord.Free_Cash_Flow__c = this.parentFinancialRecord.Free_Cash_Flow__c;
            }else{
                let totalexpense = this.applicantParentLoanChildFinancial.Total_Expenses__c ;
                if(value > this.applicantParentLoanFinancial.Emi__c){
                    totalexpense = parseFloat(totalexpense) + parseFloat(value);
                }else{
                    totalexpense = parseFloat(totalexpense) - parseFloat(value);
                }
                let favourableType = this.applicantParentLoanChildFinancial.Monthly_charges_for_hire__c >totalexpense ? 'FAVOURABLE' : 'NON FAVOURABLE';
                this.parentFinancialRecord.HireVsBuy_Decision__c = favourableType;
            }
           
        }

        
    }



    handleParentalUpdation(){
       
        if(this.parentFinancialRecord){
              this.isLoading = true;
            updateParentFinancials({parentFinancialId: this.parentFinancialRecord.Id}).then(data=>{
                if(data=='Success'){
                    this.setInitialData(false)
                }else if(data=='Failure'){
    
                }
            })
             this.isLoading = false;
        }   
    }
    
    handleUpdateBodyFundingFinancials(){
        restricAccess({
            compName: 'commFinanChild' ,loanId: this.loanId
            })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    showToastMessage(this, "", "error", "You do not have access to save/edit financial Information", "dismissable");
                    /*const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save/edit Payment Favourings',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);*/
                }
                else{
                    if(this.parentFinancialRecord){
                        upsertIncome({record : this.parentFinancialRecord}).then(data=>{
                            this.isLoading=false
                            toastWithMessage(this, "", "success", "Details Updated Successfully");
                        }).catch(error => {
                            console.log('Error-> ' +JSON.stringify(error))
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
        const Obj = {};
        this.errorOnChild = '';
        Obj.errorOnChild = this.errorOnChild;
        Obj.next = this.errorOnChild == '' ? true : false;
        console.log('Obj', Obj);
        this.dispatchEvent(new CustomEvent('next', {
            detail: Obj
        }));      
    }
}