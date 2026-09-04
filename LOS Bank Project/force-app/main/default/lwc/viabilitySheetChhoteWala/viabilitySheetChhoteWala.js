import { LightningElement,track,wire,api } from 'lwc';
import upsertIncome from '@salesforce/apex/financeController.createFinancialRecords'
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi'
import FINANCIAL_OBJECT from '@salesforce/schema/Applicant_Financials_Details__c'
import { toastWithMessage, validate,getVisibleFields, showToastMessage } from 'c/lwcutilities';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import markRecordsInactive from '@salesforce/apex/AgricultureIncomeDetailsController.deleteFinancialRecords'; // R2 Updated
import renderDeleteAction from '@salesforce/apex/AgricultureIncomeDetailsController.renderDeleteAction'; //R2
export default class ViabilitySheetChhoteWala extends LightningElement {
    @track viFinancialRecord ={};
    @api isMobile 
    isDelete= true;//R2

    viRecordTypeId;

    //Api Attributes
    @api currentApplicant
    @api loanId;
    @api templateName
    @api loanApplication
    @api parentFinancialRecord
    @api childRecords
    @api isTractorTemplate//R2-2849
    @track sheetLabel = 'VIABILITY SMALL COMMERCIAL VEHICLE SHEET'
    
    //Array Attributes
    activeSections = ['A', 'B'];
    activeSubSections = ['B', 'C','D']

    //Boolean Attributes
    isThreeWheeler = false
    isEdit=true
    fieldsToBeDisabled = ['Monthly_revenue__c','Total_Expenses__c','Free_Cash_Flow__c','FCF_EMI__c']

    async connectedCallback(){
        this.setInitialData()
         //R2
         const isDelete = await renderDeleteAction({ recordId:  this.loanApplication.Id});
         this.isDelete = isDelete;
         console.log('isDelete-->' +isDelete);
    }

    setInitialData(){
        if(this.isTractorTemplate){
            this.sheetLabel='VIABILITY SHEET'
        }
        this.isThreeWheeler =  (this.loanApplication.Collateral_Type__c == '10106' || this.loanApplication.Collateral_Type__c == '10107' || this.loanApplication.Collateral_Type__c == '10105' || this.isTractorTemplate)? true : false;//R2-2849
        if(this.childRecords && this.childRecords.length>0){
            this.childRecords.forEach(input=>{
                if(input.RecordType.DeveloperName == 'Viability_Sheet_Small_Commercial_Vehicle'){
                    this.viFinancialRecord = JSON.parse(JSON.stringify(input))
                    this.disableAllFields(true)
                }
            })
        }else{
            // prepopulate EMI 
            this.viFinancialRecord.Emi__c = this.loanApplication.EMI__c;
        }

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
             this.viRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Viability Sheet Small Commercial Vehicle');
         }
     }

    handleChange(event){
        let name = event.target.name
        let value = event.target.value
        this.viFinancialRecord[name] = value

        if(this.isThreeWheeler){
            switch (name) {
                case 'Rate_per_trip__c':
                case 'No_of_Trips_per_month__c':
                    this.calculateMonthlyRevenue();
                    break;
        
                case 'Expense_per_trip__c':
                    this.calculateFreeCashFlow();
                    break;
        
                case 'Emi__c':
                    this.calculateFreeCashFlowEMi();
                    break;
        
                default:
                    break;
            }
        }else{
            switch (name) {
                case 'No_of_working_days_per_month__c':
                case 'Daily_Billing__c':
                    this.calculateMonthlyRevenueCar();
                    break;
        
                case 'Daily_Expense__c':
                    this.calculateTotalExpenseCar();
                    break;
        
                case 'Emi__c':
                    this.calculateFreeCashFlowEMi();
                    break;
        
                default:
                    break;
            }
        }
        if(this.viFinancialRecord.Total_Expenses__c){
            if(this.isThreeWheeler){
            this.calculateFreeCashFlow();
            }else{  
            this.calculateTotalExpenseCar();
            }
           
        }
      
        if(this.viFinancialRecord.Emi__c && this.viFinancialRecord.Free_Cash_Flow__c){
            this.calculateFreeCashFlowEMi();
        }
        
    }

    calculateMonthlyRevenue(){
        if( this.viFinancialRecord.No_of_Trips_per_month__c && this.viFinancialRecord.Rate_per_trip__c){
            let revenue = this.viFinancialRecord.No_of_Trips_per_month__c *  this.viFinancialRecord.Rate_per_trip__c;           
            this.viFinancialRecord.Monthly_revenue__c = revenue/ 100000;
        }
    }
    
    calculateFreeCashFlow(){
        if(this.viFinancialRecord.Expense_per_trip__c && this.viFinancialRecord.No_of_Trips_per_month__c){
            this.viFinancialRecord.Total_Expenses__c = this.viFinancialRecord.Expense_per_trip__c * this.viFinancialRecord.No_of_Trips_per_month__c;
        }
        if(this.viFinancialRecord.Monthly_revenue__c  && this.viFinancialRecord.Total_Expenses__c){
            let revenueAmt = this.viFinancialRecord.Monthly_revenue__c * 100000;
            this.viFinancialRecord.Free_Cash_Flow__c = revenueAmt - this.viFinancialRecord.Total_Expenses__c;
        }
        
    }

    calculateFreeCashFlowEMi(){
        if(this.viFinancialRecord.Free_Cash_Flow__c && this.viFinancialRecord.Emi__c){
            let fcfEMI = this.viFinancialRecord.Free_Cash_Flow__c / this.viFinancialRecord.Emi__c;
            if(fcfEMI && fcfEMI!=null){
                fcfEMI = parseFloat(fcfEMI);
                this.viFinancialRecord.FCF_EMI__c = fcfEMI.toFixed(2);
            }
        }
        
    }

    calculateMonthlyRevenueCar(){
        if(this.viFinancialRecord.No_of_working_days_per_month__c && this.viFinancialRecord.Daily_Billing__c){
            let revenue = this.viFinancialRecord.Daily_Billing__c *  this.viFinancialRecord.No_of_working_days_per_month__c;
        this.viFinancialRecord.Monthly_revenue__c = revenue/100000;
        }
    }
    calculateTotalExpenseCar(){
        if(this.viFinancialRecord.No_of_working_days_per_month__c && this.viFinancialRecord.Daily_Expense__c){
            this.viFinancialRecord.Total_Expenses__c  =this.viFinancialRecord.No_of_working_days_per_month__c * this.viFinancialRecord.Daily_Expense__c ;
        }
        if(this.viFinancialRecord.Monthly_revenue__c && this.viFinancialRecord.Total_Expenses__c){
             let revenueAmt = this.viFinancialRecord.Monthly_revenue__c * 100000;
            this.viFinancialRecord.Free_Cash_Flow__c = revenueAmt - this.viFinancialRecord.Total_Expenses__c ;
        }   
    }
   


    handleSave(){
        restricAccess({
            compName: 'viabilityChhoteWala' ,loanId: this.loanApplication.Id
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
                    this.viFinancialRecord.Applicant__c = this.currentApplicant.Id;
                    this.viFinancialRecord.Applicant_Financials__c = this.parentFinancialRecord.Id;
                    let inputFields = this.template.querySelectorAll(".validate");
                    if(this.viFinancialRecord.No_of_working_days_per_month__c > 31 ){ // R2-2556 - changed to 31
                        toastWithMessage(this, "", "error", "Working Days cannot be more than 31 days");
                        return;
                    }
                    console.log('this.viFinancialRecord-->' +JSON.stringify(this.viFinancialRecord));
                    if (validate(inputFields)) {
                        upsertIncome({ financeRecord: this.viFinancialRecord }).then(data => {
                            this.viFinancialRecord.Id = data
                            console.log('data-->' +JSON.stringify(data));
                            this.isEdit = false;
                            this.disableAllFields(true)
                            toastWithMessage(this, "", "success", "Commercial Vehicle Small Viability Updated Successfully");
                            this.dispatchEvent(new CustomEvent('childfinancialsubmit', {
                                detail: {
                                    templateName: 'Viability_Sheet_Small_Commercial_Vehicle'
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