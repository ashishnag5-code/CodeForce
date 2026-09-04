import { LightningElement,track,wire,api } from 'lwc';
import upsertIncome from '@salesforce/apex/financeController.createFinancialRecords'
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi'
import FINANCIAL_OBJECT from '@salesforce/schema/Applicant_Financials_Details__c'
import { toastWithMessage, validate,getVisibleFields, showToastMessage } from 'c/lwcutilities';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import getCollateralDetails from '@salesforce/apex/financeController.getCollateralDetails';
import markRecordsInactive from '@salesforce/apex/AgricultureIncomeDetailsController.deleteFinancialRecords'; // R2 Updated
import renderDeleteAction from '@salesforce/apex/AgricultureIncomeDetailsController.renderDeleteAction'; //R2
export default class AusfViabilityCV extends LightningElement {
    isDelete= true;//R2
    @track viFinancialRecord ={};
    viRecordTypeId;
    @api isMobile;

    //Api Attributes
    @api currentApplicant
    @api loanApplication
    @api parentFinancialRecord
    @api loanId;
    @api templateName
    @api childRecords
    isEdit=true

    //Array Attributes
    activeSections = ['A', 'B'];
    activeSubSections = ['B', 'C','D']
    fieldsToBeDisabled = ['Monthly_running_in_Km__c','Total_Round_trip__c','Monthly_revenue__c','Fuel_Cost__c','Tyre_Cost__c','Total_Expenses__c','Free_Cash_Flow__c','FCF_EMI__c','Vehicle_Model__c','Emi__c']

    //get  viability sheet commercial vehicle financial record type
    @wire(getObjectInfo, { objectApiName: FINANCIAL_OBJECT })
    objectInfo({ data, error }) {
        if (data) {
            console.log('inside farmer financial getObj Info')
            const rtis = data.recordTypeInfos;
            this.viRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Viability Sheet Commercial Vehicle');
        }
    }

    connectedCallback(){
        this.setInitialData();
    }

    async setInitialData(){
        let commercialSheetExists=false
        if(this.childRecords && this.childRecords.length>0){
            this.childRecords.forEach(input=>{
                if(input.RecordType.DeveloperName == 'Viability_Sheet_Commercial_Vehicle'){
                    this.viFinancialRecord = JSON.parse(JSON.stringify(input))
                    this.disableAllFields(true)
                    commercialSheetExists=true
                }
            })
            if(!commercialSheetExists){
                await this.setInitialValues()
            }
            setTimeout(() => {
                this.handleFCFColorCheck()
                }, 100);
        }else{
            await this.setInitialValues()
            // prepopulate EMI 
            /*this.viFinancialRecord.Emi__c = this.loanApplication.EMI__c;
            let collateral = await getCollateralDetails({loanId: this.loanApplication.Id})
            if(collateral && collateral.Variant__c){
                this.viFinancialRecord.Vehicle_Model__c = collateral.Variant__c;
            }*/
        }
         //R2
        const isDelete = await renderDeleteAction({ recordId:  this.loanApplication.Id});
        this.isDelete = isDelete;
        console.log('isDelete-->' +isDelete);
       
    }

    async setInitialValues(){
        this.viFinancialRecord.Emi__c = this.loanApplication.EMI__c;
        let collateral = await getCollateralDetails({loanId: this.loanApplication.Id})
        if(collateral && collateral.Variant__c){
            this.viFinancialRecord.Vehicle_Model__c = collateral.Variant__c;
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

    handleChange(event){
        let name = event.target.name
        let value = event.target.value
        this.viFinancialRecord[name] = value

        switch (name) {
            case 'No_of_Trips_per_month__c':
            case 'Distance_in_Km__c':
                this.handleCalculateMonthlyRunning();
                this.handleTotalTrip();
                break;
    
            case 'Rate_Downtrip__c':
            case 'Rate_uptrip__c':    
                this.handleTotalTrip();
                break;
    
            case 'Life_of_new_tyres_in_Km__c':
                this.handleFuelTyreCost();
                break;
    
            case 'Insurance_Expenses__c':
                this.handleExpenseFreeCashFlow();
                break;
    
            case 'Emi__c':
                this.handleEmiFreeCashFlow();
                break;
    
            default:
                
                break;
        }
        this.handleFuelTyreCost();
        //if(this.viFinancialRecord.Free_Cash_Flow__c && this.viFinancialRecord.Emi__c){ //removed this check
            this.handleEmiFreeCashFlow();
       // }
        if(this.viFinancialRecord.Total_Expenses__c){
            this.handleExpenseFreeCashFlow();
        }
        this.handleFCFColorCheck()
    }


    handleCalculateMonthlyRunning(){
        if(this.viFinancialRecord.Distance_in_Km__c && this.viFinancialRecord.No_of_Trips_per_month__c){
            this.viFinancialRecord.Monthly_running_in_Km__c = this.viFinancialRecord.Distance_in_Km__c * this.viFinancialRecord.No_of_Trips_per_month__c;
        }
        
    }

    handleTotalTrip(){
        if(this.viFinancialRecord.Rate_uptrip__c && this.viFinancialRecord.Rate_Downtrip__c){
            this.viFinancialRecord.Total_Round_trip__c = parseFloat(this.viFinancialRecord.Rate_uptrip__c) + parseFloat(this.viFinancialRecord.Rate_Downtrip__c);
        }
        if(this.viFinancialRecord.Total_Round_trip__c && this.viFinancialRecord.No_of_Trips_per_month__c){
            this.viFinancialRecord.Monthly_revenue__c =  this.viFinancialRecord.Total_Round_trip__c * this.viFinancialRecord.No_of_Trips_per_month__c;
        }
        
    }
    handleFuelTyreCost(){
        if(this.viFinancialRecord.Monthly_running_in_Km__c && this.viFinancialRecord.Cost_per_liter_of_fuel__c && this.viFinancialRecord.Fuel_average_in_KM_per_litre__c){
            this.viFinancialRecord.Fuel_Cost__c =  (this.viFinancialRecord.Monthly_running_in_Km__c * this.viFinancialRecord.Cost_per_liter_of_fuel__c)/this.viFinancialRecord.Fuel_average_in_KM_per_litre__c;
        }
        if(this.viFinancialRecord.No_of_tyres__c &&  this.viFinancialRecord.Cost_of_1_tyre__c && this.viFinancialRecord.Monthly_running_in_Km__c && this.viFinancialRecord.Life_of_new_tyres_in_Km__c){
            this.viFinancialRecord.Tyre_Cost__c = (this.viFinancialRecord.No_of_tyres__c *  this.viFinancialRecord.Cost_of_1_tyre__c * this.viFinancialRecord.Monthly_running_in_Km__c)/ this.viFinancialRecord.Life_of_new_tyres_in_Km__c;
        }
        
    }
    handleExpenseFreeCashFlow(){
        if( this.viFinancialRecord.Fuel_Cost__c && this.viFinancialRecord.Insurance_Expenses__c && this.viFinancialRecord.Tyre_Cost__c &&  this.viFinancialRecord.Drivers_Salary_Allowances__c && this.viFinancialRecord.Cleaners_Salary_Allowances__c && this.viFinancialRecord.RTO_Permit_fitness_charges__c && this.viFinancialRecord.Toll_Tax_paid__c && this.viFinancialRecord.Other_Taxes_Misc_Expenses__c && this.viFinancialRecord.Maintenance_expenses__c){
            let expenses = this.viFinancialRecord.Fuel_Cost__c + this.viFinancialRecord.Tyre_Cost__c +  parseFloat(this.viFinancialRecord.Drivers_Salary_Allowances__c) + parseFloat(this.viFinancialRecord.Cleaners_Salary_Allowances__c) + parseFloat(this.viFinancialRecord.RTO_Permit_fitness_charges__c) + parseFloat(this.viFinancialRecord.Toll_Tax_paid__c) + parseFloat(this.viFinancialRecord.Other_Taxes_Misc_Expenses__c)+ parseFloat(this.viFinancialRecord.Maintenance_expenses__c) +   parseFloat(this.viFinancialRecord.Insurance_Expenses__c)
            if(expenses && expenses!=null){
            expenses = parseFloat(expenses);
            this.viFinancialRecord.Total_Expenses__c  = expenses.toFixed(2);
          } 
        }
        if(this.viFinancialRecord.Monthly_revenue__c && this.viFinancialRecord.Total_Expenses__c){
            let fcf = this.viFinancialRecord.Monthly_revenue__c - this.viFinancialRecord.Total_Expenses__c
            if(fcf && fcf!=null){
                fcf = parseFloat(fcf);
                this.viFinancialRecord.Free_Cash_Flow__c = fcf.toFixed(2);
                this.handleEmiFreeCashFlow(); //added
             }
        }
       
    }
    handleEmiFreeCashFlow(){
        if( this.viFinancialRecord.Free_Cash_Flow__c && this.viFinancialRecord.Emi__c){
            let fcfEMI =  this.viFinancialRecord.Free_Cash_Flow__c / this.viFinancialRecord.Emi__c;
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
                 this.template.querySelector('[data-name="FCF_EMI__c"]').classList.remove('redColor')
             }
        }
        
    }

    handleSave(){
        restricAccess({
            compName: 'ausfViabilityCV' ,loanId: this.loanApplication.Id
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
                            toastWithMessage(this, "", "success", "Commercial Viability Updated Successfully");
                            this.dispatchEvent(new CustomEvent('childfinancialsubmit', {
                                detail: {
                                    templateName: 'Viability_Sheet_Commercial_Vehicle'
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
                this.disableAllFields(false)
                this.dispatchEvent(new CustomEvent('childfinancialsubmit',{
                    detail: this.keyId
                }));
                this.template.querySelector('[data-name="FCF_EMI__c"]').classList.remove('redColor');
                this.setInitialValues();
            }).catch((error)=>{
            })
        }
    }
}