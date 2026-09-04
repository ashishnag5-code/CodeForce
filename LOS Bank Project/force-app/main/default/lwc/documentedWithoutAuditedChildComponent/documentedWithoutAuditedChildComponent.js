import { LightningElement,api,wire, track } from 'lwc';
import APPLICANTFINANCIALDETAILS_OBJECT from '@salesforce/schema/Applicant_Financials_Details__c';
import getVisibleFields from '@salesforce/apex/financeController.getVisibleFields';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import getActiveFinancialRecord from '@salesforce/apex/FinancialViewTemplateR2Controller.getActiveFinancialRecord';
import markRecordsInactive from '@salesforce/apex/AgricultureIncomeDetailsController.deleteFinancialRecords'; // R2 Updated
import renderDeleteAction from '@salesforce/apex/AgricultureIncomeDetailsController.renderDeleteAction'; //R2

export default class DocumentedWithoutAuditedChildComponent extends LightningElement {
    isDelete = true; //R2
    //API Attributes
    @api key;
    @api existingDetails;
    @api applicantId;
    @api isMobile;
    @api isR2;
    @api loanId;
    parentRecordId;
    //Array Attributes
    documentedwithoutfinancialRecord = {};

    //Decimal Attributes
    annualNetProfit = 0;
    monthlyNetProfit = 0;

    yearOptions;
    yearValue;
    keyVal;
    maxDate;

    //Boolean Attributes
    isLoaded = false;
    showEditView = false;
    readonly = true;
    @track readAttribute = false;
    @track editSave = false;
    isButtonDisabled = false;

    @api
    get financialId() {
        return this.finId;
    }
    set financialId(value) {
        this.finId = value;
        this.documentedwithoutfinancialRecord.Applicant_Financials__c = this.finId;
    }

    @api
    get keyValue() {
        return this.keyVal;
    }
    set keyValue(value) {
        this.keyVal = value;
    }

    connectedCallback() {
        this.isButtonDisabled = false;
        this.loadYearOptions();
        this.getVisibleFieldsMetadata();
        if (this.existingDetails != '' && this.existingDetails != null) {
            this.showEditView = true;
            console.log('existingwithoutauditeddata-->' + JSON.stringify(this.existingDetails));
        }else{
            this.showEditView = false;
        }
        this.handleDeleteVisbility();//R2
    }
     //R2
     async handleDeleteVisbility(){
        const isDelete = await renderDeleteAction({ recordId: this.loanId});
        this.isDelete = isDelete;
        console.log('isDelete-->' +isDelete);
    }

    loadYearOptions() {
        var date = new Date();
        var futureYear = date.getFullYear() +1;
        var currentYear = date.getFullYear();
        var previouYear = date.getFullYear() - 1;
        var previousSecondYear = date.getFullYear() - 2;
        var previousThirdYear = date.getFullYear() - 3;
        let yearValues = [];
        //Assigning Year Values
       
        
        
       
        
        yearValues.push({
            label: previousThirdYear + '-' + previousSecondYear,
            value: previousThirdYear + '-' + previousSecondYear
        });
        yearValues.push({
            label: previousSecondYear + '-' + previouYear,
            value: previousSecondYear + '-' + previouYear
        });
        yearValues.push({
            label: previouYear + '-' + currentYear,
            value: previouYear + '-' + currentYear
        });
        yearValues.push({
            label: currentYear + '-' + futureYear,
            value: currentYear + '-' + futureYear
        });

        this.yearOptions = yearValues;
        this.getToday();
    }

    getToday() {
        const today = new Date();
        const year = today.getFullYear();
        let month = today.getMonth() + 1;
        let day = today.getDate();

        if (month < 10) {
            month = '0' + month;
        }
        if (day < 10) {
            day = '0' + day;
        }

        this.maxDate = `${year}-${month}-${day}`;
    }
    getVisibleFieldsMetadata() {
        this.isLoaded = true;
        getVisibleFields({
                strScreen: 'Documented- Without Audited Financial',Stage: 'QDE'
            })
            .then(result => {
                console.log('result is ' + JSON.stringify(result));
                result.forEach(input => {
                    this.template.querySelector('[data-id="' + input + '"]').classList.remove('slds-hide');
                });
                this.isLoaded = false;
            })
            .catch(error => {
                console.log('result is ' + JSON.stringify(error));
                this.isLoaded = false;
            })
    }


    @wire(getObjectInfo, {
        objectApiName: APPLICANTFINANCIALDETAILS_OBJECT
    })
    objectInfo;

    get recordTypeId() {
        // Returns a map of record type Ids 
        const rtis = this.objectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'Documented Without Audited financial');
    }

    handleChange(event) {
        this.documentedwithoutfinancialRecord[event.target.name] = event.target.value;
        let fieldName = event.target.name;
        let fieldValue = event.target.value;
        if (fieldName == 'Annual_Net_Profit__c') {
            this.annualNetProfit = parseFloat(fieldValue);
            this.monthlyNetProfit = this.handleMonth(this.annualNetProfit);
        }
        if (fieldName == 'Year__c') {
            this.yearValue = fieldValue;
        }
        
    }

    handleMonth(turnoverval) {
        const monthly = turnoverval / 12;
        return monthly;
    }

   async handleSubmit() {
        
        console.log('financeParentrecord-->' + this.financialId);
        if(this.isR2){
            this.documentedwithoutfinancialRecord.Row_Instance__c = this.keyVal;
            this.parentRecordId = await getActiveFinancialRecord({applicantId :this.applicantId, rowIndex : parseInt(this.keyVal)});
            if(this.parentRecordId){
                this.documentedwithoutfinancialRecord.Id = this.parentRecordId; 
            }
        }
        this.handleFieldMappings();
        const fields = this.documentedwithoutfinancialRecord;
        console.log('documentedfinancialRecord-->' + JSON.stringify(this.documentedwithoutfinancialRecord));
        const recordInput = {
            apiName: APPLICANTFINANCIALDETAILS_OBJECT.objectApiName,
            fields
        };
        // Creates the event with the data.
        if (this.isInputValid()) {
            this.isButtonDisabled = true;
            const selectedEvent = new CustomEvent("withoutdocauditedsubmit", {
                // detail: this.salaryfinancialRecord
                detail: {
                    record: this.documentedwithoutfinancialRecord,
                    template: 'withoutaudited',
                    key: this.keyValue
                }
            });

            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
            this.editSave = true;
            this.readAttribute = true;
            if(this.isR2){
                this.readAttribute = true;
                this.editSave = false;
            }
        }

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
            if (inputField.value == 0) {
                inputField.setCustomValidity("Complete this field");
                inputField.reportValidity();
                isValid = false;
            }
        });

        const selectedDate = new Date(this.documentedwithoutfinancialRecord.Filing_Date__c);
        const currentDate = new Date();
       // currentDate.setHours(0, 0, 0, 0);

        if (selectedDate > currentDate) {
            console.log('futureDate');
            isValid = false;
        } 


        return isValid;
    }

    handleFieldMappings() {
        this.documentedwithoutfinancialRecord.Monthly_Net_Profit__c = this.monthlyNetProfit;
        this.documentedwithoutfinancialRecord.RecordTypeId = this.recordTypeId;
        this.documentedwithoutfinancialRecord.Applicant_Financials__c = this.financialId;
        this.documentedwithoutfinancialRecord.Applicant__c = this.applicantId;
    }

    @api
    handledocumentedReadOnly() {
        this.readAttribute = true;
        this.editSave = false;
    }

    handleCancel() {
        this.readAttribute = true;
        this.editSave = false;
    }

    handleEdit() {
        this.readAttribute = false;
        this.editSave = true;
        if(this.isR2){
            this.isButtonDisabled = false;
        }
    }

    redirectHome() {
        this.showEditView = false;
        const selectedEvent = new CustomEvent("home", {
            detail: {
                redirect: false,
                template: 'withoutdoc'
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    handleEnableFetchDetails(event){
        
    }
    

    handleOtherIncome(event){
        const selectedEvent = new CustomEvent("otherincome", { 
            detail: { 
                redirect: false,
                template: 'withoutdoc'
            }
        });
        this.dispatchEvent(selectedEvent);
    }

     // R2 || START
   async handleDeleteRow(event){
    console.log('existingDetails-->' +JSON.stringify(this.existingDetails));
    if(this.existingDetails.length !=0){
        this.handlemarkRecordsInactive( this.existingDetails[0].Id);
    }else{
        this.parentRecordId = await getActiveFinancialRecord({applicantId :this.applicantId, rowIndex : parseInt(this.keyVal)});
        this.handlemarkRecordsInactive( this.parentRecordId);
       
    }
}

handlemarkRecordsInactive(recordId){
    markRecordsInactive({afd :recordId}).then((data)=>{
        this.handleResetValues(); 
    }).catch((error)=>{
    })
}

handleResetValues(){
    this.handleResetAttributes();
    this.getVisibleFieldsMetadata();
    this.dispatchEvent(new CustomEvent('deletedrecord',{
                detail: ''
    }));


}
handleEditDelete(event){
    let recordId = event.detail;
    this.handlemarkRecordsInactive(recordId);
}

handleResetAttributes(){
   
    this.annualNetProfit =undefined;
    this.monthlyNetProfit=undefined;
    this.yearValue=undefined;
    this.filingValue = undefined;
    this.existingDetails=[];
    this.showEditView = false;
    this.showViewForm = false;
    this.salaryView = true;   
    this.readAttribute = false; //
    this.isButtonDisabled = false;
}
//END
}