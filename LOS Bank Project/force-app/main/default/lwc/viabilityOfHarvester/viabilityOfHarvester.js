import { LightningElement, track, api, wire } from 'lwc';
import { getVisibleFields, showToastMessage, setPicklistsValues, validate, getUniqueValue, getApplicantName } from 'c/lwcutilities';
import createFinancialRecords from '@salesforce/apex/financeController.createFinancialRecords'
import FINANCIAL_OBJECT from '@salesforce/schema/Applicant_Financials_Details__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import markRecordsInactive from '@salesforce/apex/AgricultureIncomeDetailsController.deleteFinancialRecords'; // R2 Updated
import renderDeleteAction from '@salesforce/apex/AgricultureIncomeDetailsController.renderDeleteAction'; //R2
export default class ViabilityOfHarvester extends LightningElement {
    isDelete = true; //R2
    activeSections = ['A','B','C'];
    @api applicantData
    @api parentFinancial
    @api isMobile;
    recordTypeId
    isEdit=true
    fieldsToBeDisabled = ['Approx_No_of_hours_run_in_a_year__c','Total_Income__c','Total_Diesel_Exp_per_Year__c','Total_Net_Income__c','Net_Surplus__c','Diesel_cost_per_Hr__c','Total_Expenses__c','Final_expenses__c','Yearly_EMI_of_Proposed_loan__c']
    
    @api childRecords
    @api existingViabilitySheetData
    @track viabilitySheetData={}

    async connectedCallback(){
        const visibleFields = await getVisibleFields('Viability Sheet SPH', this.applicantData.Loan__r.Stage__c, undefined, 'Tractor', undefined)
        visibleFields.forEach(input=>{
            if(this.template.querySelector('[data-id="'+input+'"]')){
                this.template.querySelector('[data-id="'+input+'"]').classList.remove('slds-hide')
            }
            if(this.template.querySelector('[data-name="'+input+'"]')){
                this.template.querySelector('[data-name="'+input+'"]').classList.add('validate')
            }
        })
        if(this.childRecords && this.childRecords.length>0){
            this.childRecords.forEach(input=>{
                if(input.RecordType.DeveloperName == 'Viability_Sheet_Self_Propelled_Harvester'){
                    this.viabilitySheetData = JSON.parse(JSON.stringify(input))
                    this.disableAllFields(true)
                }
            })
        }
        this.viabilitySheetData.Yearly_EMI_of_Proposed_loan__c = this.parentFinancial.Proposed_Installment__c
        //R2
        const isDelete = await renderDeleteAction({ recordId: this.applicantData.Loan__c});
        this.isDelete = isDelete;
        console.log('isDelete-->' +isDelete);
    }

    disableAllFields(isDisable){
        this.isEdit=!isDisable
        this.template.querySelectorAll('lightning-input').forEach(input=>{
            input.disabled=isDisable;
            if(!isDisable && this.fieldsToBeDisabled.includes(input.name)){
                input.disabled=true
            }
        })
    }

    @wire(getObjectInfo, { objectApiName: FINANCIAL_OBJECT })
    objectInfo({data, error}){
        if(data){
            const rtis = data.recordTypeInfos;
            this.recordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Viability Sheet Self Propelled Harvester');
        }
    }

    handleChange(event){
        let name = event.target.name;
        let value = event.detail.value;
        this.viabilitySheetData[name] = parseFloat(value)

        if(name=='No_of_Acres_land_harvest_in_a_year__c' || name=='Hours_taken_form_01_acre_land__c'){
            this.viabilitySheetData.Approx_No_of_hours_run_in_a_year__c = this.changeDataType(this.viabilitySheetData.No_of_Acres_land_harvest_in_a_year__c * this.viabilitySheetData.Hours_taken_form_01_acre_land__c);
            this.viabilitySheetData.Total_Income__c = this.changeDataType(this.viabilitySheetData.Rate_hour__c * this.viabilitySheetData.Approx_No_of_hours_run_in_a_year__c);
            this.viabilitySheetData.Total_Diesel_Exp_per_Year__c = this.changeDataType(this.viabilitySheetData.Diesel_cost_per_Hr__c * this.viabilitySheetData.Approx_No_of_hours_run_in_a_year__c);
        }

        if(name=='Rate_hour__c'){
            this.viabilitySheetData.Total_Income__c = this.changeDataType(this.viabilitySheetData.Rate_hour__c * this.viabilitySheetData.Approx_No_of_hours_run_in_a_year__c);
        }

        if(name=='Per_Hr_Diesel_consumption_in_ltr__c' || name=='Diesel_cost_per_Ltr__c'){
            this.viabilitySheetData.Diesel_cost_per_Hr__c = this.changeDataType(this.viabilitySheetData.Per_Hr_Diesel_consumption_in_ltr__c * this.viabilitySheetData.Diesel_cost_per_Ltr__c);
            this.viabilitySheetData.Total_Diesel_Exp_per_Year__c = this.changeDataType(this.viabilitySheetData.Diesel_cost_per_Hr__c * this.viabilitySheetData.Approx_No_of_hours_run_in_a_year__c);
        }

        if(name=='Driver_Helper_salary__c' || name=='Insurance_cost_per_yr__c' || name=='Yearly_Maintenance_Cost__c' || name=='Broker_Commission__c' || name=='Any_Other_Expense__c'){
            this.viabilitySheetData.Total_Expenses__c = this.changeDataType(this.viabilitySheetData.Driver_Helper_salary__c + this.viabilitySheetData.Insurance_cost_per_yr__c + this.viabilitySheetData.Yearly_Maintenance_Cost__c + this.viabilitySheetData.Broker_Commission__c + this.viabilitySheetData.Any_Other_Expense__c);
            this.viabilitySheetData.Final_expenses__c = this.changeDataType(this.viabilitySheetData.Total_Expenses__c + this.viabilitySheetData.Total_Diesel_Exp_per_Year__c);
        }

        this.viabilitySheetData.Total_Net_Income__c = this.changeDataType(this.viabilitySheetData.Total_Income__c - this.viabilitySheetData.Final_expenses__c);
        this.viabilitySheetData.Net_Surplus__c = this.changeDataType(this.viabilitySheetData.Total_Net_Income__c - this.viabilitySheetData.Yearly_EMI_of_Proposed_loan__c); 
    }

    changeDataType(value){
        if(value){
            return (parseFloat(value))
        }else{
            return value
        }
    }

    handleOnEditClick(){
        this.isEdit=true
        this.disableAllFields(false)
    }

    handleSubmit(event){
        restricAccess({
            compName: 'viabilityHarvester' ,loanId: this.applicantData.Loan__c
            })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    showToastMessage(this, "", "error", "You do not have access to save/edit Viablity Sheet", "dismissable");
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
                    if (validate(inputFields)) {
                        this.viabilitySheetData.RecordTypeId=this.recordTypeId
                        this.viabilitySheetData.Applicant__c=this.applicantData.Id
                        this.viabilitySheetData.Applicant_Financials__c=this.parentFinancial.Id
                        createFinancialRecords({financeRecord: this.viabilitySheetData}).then(data=>{
                            this.viabilitySheetData.Id=data
                            this.isEdit = false;
                            this.disableAllFields(true)
                            showToastMessage(this, "", "success", "Viability Sheet (Self Propelled Harvester) Updated Successfully", "dismissable");
                            this.dispatchEvent(new CustomEvent('childfinancialsubmit', {
                                detail: {
                                    templateName: 'Viability_Sheet_Self_Propelled_Harvester'
                                }
                            }));
                        }).catch((error=>{
                            showToastMessage(this, "", "error", "Failed to updated Viability Sheet", "sticky");
                        }))
                    }
                }
            })
            .catch(error=>{
                console.log('error is ' + JSON.stringify(error));

            })
        
    }
    handleDeleteRow(event){
        if(this.viabilitySheetData.Id){
            markRecordsInactive({afd :this.viabilitySheetData.Id}).then((data)=>{
                this.viabilitySheetData={};
                this.disableAllFields(false)
               
                 this.dispatchEvent(new CustomEvent('childfinancialsubmit',{
                    detail: this.keyId
                }));
                this.viabilitySheetData.Yearly_EMI_of_Proposed_loan__c = this.parentFinancial.Proposed_Installment__c
            }).catch((error)=>{
            })
        }
    
    }

}