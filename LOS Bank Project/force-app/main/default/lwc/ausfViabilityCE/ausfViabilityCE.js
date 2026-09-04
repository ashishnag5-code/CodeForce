import { LightningElement,track,api,wire } from 'lwc';
import upsertIncome from '@salesforce/apex/financeController.createFinancialRecords'
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi'
import FINANCIAL_OBJECT from '@salesforce/schema/Applicant_Financials_Details__c'
import { toastWithMessage, validate,getVisibleFields, showToastMessage } from 'c/lwcutilities';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import markRecordsInactive from '@salesforce/apex/AgricultureIncomeDetailsController.deleteFinancialRecords'; // R2 Updated
import renderDeleteAction from '@salesforce/apex/AgricultureIncomeDetailsController.renderDeleteAction'; //R2

export default class AusfViabilityCE extends LightningElement {
    @track viFinancialRecord = {}
    viRecordTypeId;
    isDelete= true;//R2
    //Api Attributes
    @api currentApplicant
    @api loanApplication
    @api parentFinancialRecord
    @api childRecords;
    isEdit = true;
    @api isMobile;
    fieldsToBeDisabled = ['Monthly_running_in_hours__c','Monthly_charges_for_hire__c','Fuel_Cost__c','Total_Expenses__c','Free_Cash_Flow__c','Monthly_running_in_hours__c','FCF_EMI__c']
   
    //Array Attributes
    activeSections = ['A', 'B', 'C','D'];
    
    connectedCallback(){
        this.setInitialData();
    }

   async setInitialData(){
        if(this.childRecords && this.childRecords.length>0){
            this.childRecords.forEach(input=>{
                if(input.RecordType.DeveloperName == 'Viability_Sheet_Commercial_Equipment'){
                    this.viFinancialRecord = JSON.parse(JSON.stringify(input))
                    this.disableAllFields(true)
                }
            })
            setTimeout(() => {
                this.handleFCFColorCheck()
                }, 100);
        }else{
            // prepopulate EMI 
            this.viFinancialRecord.Emi__c = this.loanApplication.EMI__c;
        }
            //R2
         const isDelete = await renderDeleteAction({ recordId:  this.loanApplication.Id});
         this.isDelete = isDelete;
         console.log('isDelete-->' +isDelete);
    }
    handleOnEditClick(){
        this.isEdit=true
        this.disableAllFields(false)
    }
    disableAllFields(isDisable){
        this.isEdit=!isDisable
        setTimeout(() => {
            this.template.querySelectorAll('lightning-input').forEach(input=>{
                input.disabled=isDisable;
                if(!isDisable && this.fieldsToBeDisabled.includes(input.name)){
                    input.disabled=true
                }
            })
          }, 100);
    }


    //get  viability sheet commercial vehicle financial record type
    @wire(getObjectInfo, { objectApiName: FINANCIAL_OBJECT })
    objectInfo({ data, error }) {
        if (data) {
            console.log('inside farmer financial getObj Info')
            const rtis = data.recordTypeInfos;
            this.viRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Viability Sheet Commercial Equipment');
        }
    }

    handleChange(event){
        let name = event.target.name
        let value = event.target.value
        this.viFinancialRecord[name] = value

        switch (name) {
            case 'No_of_working_days_per_month__c':
            case 'No_of_hours_day__c':
                this.calculateMonthlyRunningHours();
                this.calculateMonthlyCharges();
                break;
    
            case 'Rate_hour__c':
            case 'Monthly_running_in_hours__c':
                this.calculateMonthlyCharges();
                break;
    
            case 'Cost_per_liter_of_fuel__c':
                this.calculateFuelCost();
                break;
    
            case 'Repair_Servicing_Miscellaneous_Charges__c':
                this.calculateTotalExpenseFreeCashFlow();
                break;
    
            case 'Emi__c':
                this.calculateFreeCashFlowEMI();
                break;
    
            default:
                break;

          
        }
        this.calculateFuelCost();
        if(this.viFinancialRecord.Total_Expenses__c ){
            this.calculateTotalExpenseFreeCashFlow();
        }
        if(this.viFinancialRecord.Emi__c && this.viFinancialRecord.Free_Cash_Flow__c ){
            this.calculateFreeCashFlowEMI();
        }
          this.handleFCFColorCheck()
    }

    calculateMonthlyRunningHours(){
        if( this.viFinancialRecord.No_of_hours_day__c && this.viFinancialRecord.No_of_working_days_per_month__c){
            this.viFinancialRecord.Monthly_running_in_hours__c = this.viFinancialRecord.No_of_hours_day__c * this.viFinancialRecord.No_of_working_days_per_month__c;
        }
        
    }
    calculateMonthlyCharges(){
        if( this.viFinancialRecord.Rate_hour__c && this.viFinancialRecord.Monthly_running_in_hours__c){
            this.viFinancialRecord.Monthly_charges_for_hire__c = this.viFinancialRecord.Rate_hour__c * this.viFinancialRecord.Monthly_running_in_hours__c;
        }
        
    }
    calculateFuelCost(){
        if( this.viFinancialRecord.Monthly_running_in_hours__c  && this.viFinancialRecord.Cost_per_liter_of_fuel__c && this.viFinancialRecord.Fuel_average_in_liter_per_hour__c){
            this.viFinancialRecord.Fuel_Cost__c =  this.viFinancialRecord.Monthly_running_in_hours__c * this.viFinancialRecord.Cost_per_liter_of_fuel__c * this.viFinancialRecord.Fuel_average_in_liter_per_hour__c;
        }
        
    }
    calculateTotalExpenseFreeCashFlow(){
        if(this.viFinancialRecord.Fuel_Cost__c && this.viFinancialRecord.Repair_Servicing_Miscellaneous_Charges__c &&this.viFinancialRecord.Drivers_Salary_Allowances__c && this.viFinancialRecord.Insurance_taxes__c ){
            let expenses =  this.viFinancialRecord.Fuel_Cost__c + parseFloat(this.viFinancialRecord.Drivers_Salary_Allowances__c) +  parseFloat(this.viFinancialRecord.Insurance_taxes__c)  +  parseFloat(this.viFinancialRecord.Repair_Servicing_Miscellaneous_Charges__c);
             if(expenses && expenses!=null){
                expenses = parseFloat(expenses);
                this.viFinancialRecord.Total_Expenses__c  = expenses.toFixed(2);
              } 
        }
        if(this.viFinancialRecord.Monthly_charges_for_hire__c && this.viFinancialRecord.Total_Expenses__c){
            let fcf = this.viFinancialRecord.Monthly_charges_for_hire__c - this.viFinancialRecord.Total_Expenses__c;
            if(fcf && fcf!=null){
                fcf = parseFloat(fcf);
                this.viFinancialRecord.Free_Cash_Flow__c = fcf.toFixed(2);
             }
        }
        
    }
    calculateFreeCashFlowEMI(){
        if( this.viFinancialRecord.Free_Cash_Flow__c && this.viFinancialRecord.Emi__c){
            let fcfEMI = this.viFinancialRecord.Free_Cash_Flow__c / this.viFinancialRecord.Emi__c;
            if(fcfEMI && fcfEMI!=null){
                fcfEMI = parseFloat(fcfEMI);
                this.viFinancialRecord.FCF_EMI__c = fcfEMI.toFixed(2);
            }
        }
        
        this.handleFCFColorCheck()
    }
    handleFCFColorCheck(){
        if(this.viFinancialRecord.FCF_EMI__c){
            if(this.viFinancialRecord.FCF_EMI__c  <1.3){
                this.template.querySelector('[data-name="FCF_EMI__c"]').classList.add('redColor')
             }else{
                // if(this.template.querySelector('[[data-name="FCF_EMI__c"]').classList.contains('redColor')){
                     this.template.querySelector('[data-name="FCF_EMI__c"]').classList.remove('redColor')
               //  }
             }
        }
        
    }

    handleSave(){
        restricAccess({
            compName: 'ausfViabilityCE' ,loanId: this.loanApplication.Id
            })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    showToastMessage(this, "", "error", "You do not have access to save/edit Viability", "dismissable");
                    /*const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save/edit Payment Favourings',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);*/
                }
                else{
                    this.viFinancialRecord.RecordTypeId = this.viRecordTypeId
                    this.viFinancialRecord.Applicant__c = this.currentApplicant.Id
                    this.viFinancialRecord.Applicant_Financials__c = this.parentFinancialRecord.Id
                    let inputFields = this.template.querySelectorAll(".validate");
                    if (validate(inputFields)) {
                        upsertIncome({ financeRecord: this.viFinancialRecord }).then(data => {
                            this.viFinancialRecord.Id = data
                            this.isEdit = false;
                            this.disableAllFields(true)
                            toastWithMessage(this, "", "success", "Construction Equipment Viability Updated Successfully");
                            this.dispatchEvent(new CustomEvent('childfinancialsubmit', {
                                detail: {
                                    templateName: 'Viability_Sheet_Commercial_Equipment'
                                }
                            }));
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
    handleDeleteRow(event){
        if(this.viFinancialRecord.Id){
            markRecordsInactive({afd :this.viFinancialRecord.Id}).then((data)=>{
                this.viFinancialRecord={};
                this.handleOnEditClick();
                this.dispatchEvent(new CustomEvent('childfinancialsubmit',{
                    detail: ''
                }));
                this.viFinancialRecord.Emi__c = this.loanApplication.EMI__c;
            }).catch((error)=>{
                console.log('error-->' +error);
            })
        }
    }
}