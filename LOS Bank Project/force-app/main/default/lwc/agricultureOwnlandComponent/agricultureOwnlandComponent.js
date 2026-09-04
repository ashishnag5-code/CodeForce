import { LightningElement,api,wire } from 'lwc';
import APPLICANTFINANCIALDETAILS_OBJECT from '@salesforce/schema/Applicant_Financials_Details__c';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import createFinancialRecords from '@salesforce/apex/financeController.createFinancialRecords';


export default class AgricultureOwnlandComponent extends LightningElement {
    @api key;
    @api financialId;
    @api applicantId;
    agricultureRecord={};
    cropOptions;
    irrigationOptions;


    connectedCallback(){
        let irrigationValues=[];
        let cropOptionsVal=[];
         //Assigning Irrigation Values
         irrigationValues.push({label:'Well',value:'Well'});
         irrigationValues.push({label:'Borewell',value:'Borewell'});
         irrigationValues.push({label:'Canal',value:'Canal'});
         irrigationValues.push({label:'River',value:'River'});
         irrigationValues.push({label:'Rainfall',value:'Rainfall'});
         this.irrigationOptions = irrigationValues;

         cropOptionsVal.push({label:'Cotton',value:'Cotton'}); // Afterwards we need to query from master
         cropOptionsVal.push({label:'Chillies',value:'Chillies'});

         this.cropOptions =cropOptionsVal;
         


    }

    @wire(getObjectInfo, { objectApiName: APPLICANTFINANCIALDETAILS_OBJECT })
    objectInfo;

    get recordTypeId() {
        // Returns a map of record type Ids 
        const rtis = this.objectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'Agriculture Own Land');
    }


    handleChange(event){
        this.agricultureRecord[event.target.name] = event.target.value;
        let fieldName = event.target.name;
        let fieldValue = event.target.value;
     /*   
        if(fieldName=='Annual_Turnover__c'){
            this.turnOver = parseFloat(fieldValue);
            this.grossturnoverMonthly = this.handleMonth(this.turnOver);
        }

        if(fieldName=='Annual_Net_Profit__c'){
            this.annualNetProfit = parseFloat(fieldValue);
            this.monthlyNetProfit =this.handleMonth(this.annualNetProfit);
        }

        if(fieldName=='Annual_Depreciation__c'){
            this.annualDepreciation = parseFloat(fieldValue);
            this.monthlyDepreciation =this.handleMonth(this.annualDepreciation);
        }

        if(fieldName=='Annual_Interest_Paid_On_Loans__c'){
            this.annualInterestLoan = parseFloat(fieldValue);
            this.monthlyInterestLoan =this.handleMonth(this.annualInterestLoan);
        }

        if(fieldName=='Annual_Non_Cash_Expenses__c'){
            this.annualnonchash = parseFloat(fieldValue);
            this.monthlynoncash =this.handleMonth(this.annualnonchash);
            
        }

      */
        
    }

     handleMonth(turnoverval){
        const monthly = turnoverval/12;
        return monthly;
    }

    calculateTotalIncome(){
        const annualIncome = this.turnOver + this.annualNetProfit + this.annualDepreciation + this.annualInterestLoan +this.annualnonchash;
        this.annualtotalIncome = annualIncome;
        this.monthlytotalIncome = this.handleMonth(this.annualtotalIncome);
    }

    handleSubmit(){
        console.log('financeParentrecord-->' +this.financialId);
        this.handleFieldMappings();
        
        const fields = this.documentedfinancialRecord;
        console.log('documentedfinancialRecord-->' +JSON.stringify(this.documentedfinancialRecord));
        const recordInput = { apiName: APPLICANTFINANCIALDETAILS_OBJECT.objectApiName, fields };
       // if(this.isInputValid()){
         //  createRecord(recordInput)
         this.isLoaded = true;
         createFinancialRecords({financeRecord : this.documentedfinancialRecord})
            .then(financials => {
                console.log('success-->' +JSON.stringify(financials));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Documented Financials created',
                        variant: 'success',
                    }),
                );
               // this.rendeauditedFinaceTemplate = false;
                this.isLoaded = false;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
      //  }
     }

     handleFieldMappings(){
        console.log('recordType-->' + this.recordTypeId);
        this.documentedfinancialRecord.RecordTypeId =  this.recordTypeId;
        this.documentedfinancialRecord.Applicant_Financials__c = this.financialId;
        this.documentedfinancialRecord.Applicant__c=this.applicantId;
        this.documentedfinancialRecord.Monthly_Turnover__c = this.grossturnoverMonthly;
        this.documentedfinancialRecord.Monthly_Net_Profit__c = this.monthlyNetProfit;
        this.documentedfinancialRecord.Monthly_Depreciation__c = this.monthlyDepreciation;
        this.documentedfinancialRecord.Monthly_Interest_Paid_on_Loans__c = this.monthlyInterestLoan;
        this.documentedfinancialRecord.Monthly_Non_Cash_Expenses__c = this.monthlynoncash;
        this.documentedfinancialRecord.Annual_Total_Income__c = this.annualtotalIncome;
        this.documentedfinancialRecord.Monthly_Total_Income__c = this.monthlytotalIncome;
    }

     isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll(".validate");
        inputFields.forEach(inputField => {
            if (!inputField.value) {
                inputField.setCustomValidity("Complete this field");
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }
}