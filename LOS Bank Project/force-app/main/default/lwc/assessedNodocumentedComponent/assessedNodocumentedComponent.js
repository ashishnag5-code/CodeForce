import { LightningElement,api,wire, track } from 'lwc';
import APPLICANTFINANCIALDETAILS_OBJECT from '@salesforce/schema/Applicant_Financials_Details__c';
import getVisibleFields from '@salesforce/apex/financeController.getVisibleFields';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import getActiveFinancialRecord from '@salesforce/apex/FinancialViewTemplateR2Controller.getActiveFinancialRecord';
import markRecordsInactive from '@salesforce/apex/AgricultureIncomeDetailsController.deleteFinancialRecords'; // R2 Updated
import renderDeleteAction from '@salesforce/apex/AgricultureIncomeDetailsController.renderDeleteAction'; //R2
export default class AssessedNodocumentedComponent extends LightningElement {
    isDelete = true; //R2
    //API Attributes
    @api existingDetails;
    @api applicantId;
    @api saveDetails = false;
    @api spinnerImage;
    @api loanAppId;
    @api isMobile;
    @api isR2;

    //Array Attributes
    activeSections = ['A', 'B', 'C', 'D'];
    assesedfinancialRecord = {};

    //Decimal Attributes
    turnOver = 0;
    expense = 0;
    annualExpense = 0;
    annualTurnover = 0;
    monthlyNetProfit;
    annualNetProfit;

    //Boolean Attributes
    isLoaded = false;
    showViewForm = false;
    assessedRecord;
    readAttributee = false;
    editSave = false;
    showEditView = false;
    isButtonDisabled
    readonly = true;
    parentRecordId;
    @api
    financialId;
    keyVal;

    connectedCallback() {
        this.isButtonDisabled = false;
        this.getVisibleFieldsMetadata();
        this.handleInitialValues();
        if (this.existingDetails != '' && this.existingDetails != null) {
            console.log('this.existingDetails-->' +JSON.stringify(this.existingDetails));
            this.showEditView = true;
        }else{
            this.showEditView = false;
        }
        this.handleDeleteVisbility();//R2
    }

    @api
    get keyValue() {
        return this.keyVal;
    }
    set keyValue(value) {
        this.keyVal = value;
    }
  /*  @api
    get financialId() {
        return this.finId;
    }

    set financialId(value) {
        this.finId = value;
       
    }*/

    getVisibleFieldsMetadata() {
        getVisibleFields({
                strScreen: 'Assessed No Documented',
                Stage: 'DDE'
            })
            .then(result => {
                console.log('result is ' + JSON.stringify(result));
                result.forEach(input => {
                    this.template.querySelector('[data-id="' + input + '"]').classList.remove('slds-hide');
                });
            })
            .catch(error => {
                console.log('result is ' + JSON.stringify(error));
            })
    }
     //R2
     async handleDeleteVisbility(){
        const isDelete = await renderDeleteAction({ recordId: this.loanAppId});
        this.isDelete = isDelete;
        console.log('isDelete-->' +isDelete);
        }

    @wire(getObjectInfo, {
        objectApiName: APPLICANTFINANCIALDETAILS_OBJECT
    })
    objectInfo;

    get recordTypeId() {
        // Returns a map of record type Ids 
        const rtis = this.objectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'Assessed No Document');
    }


    handleInitialValues() {
        let data = this.existingDetails;
        for (var key in data) {
            this.annualTurnover = data[key].Annual_Turnover__c;
            this.annualExpense = data[key].Annual_Expense__c;
            this.monthlyNetProfit = data[key].Monthly_Net_Profit__c;
            this.annualNetProfit = data[key].Annual_Net_Profit__c;
            this.turnOver = data[key].Monthly_Turnover__c;
            this.expense =  data[key].Monthly_Expense__c;
        }
    }

    handleChange(event) {
        this.assesedfinancialRecord[event.target.name] = event.target.value;
        let fieldName = event.target.name;
        let fieldValue = event.target.value;
        let turnoverindicatior = false;
        if (fieldName == 'Monthly_Turnover__c') {
            this.turnOver = parseFloat(fieldValue);
            this.handleAnnual(this.turnOver, true);
        }
        if (fieldName == 'Monthly_Expense__c') {
            this.expense = parseFloat(fieldValue);
            this.handleAnnual(this.expense, false);
        }
    }


    handleAnnual(turnoverval, indicator) {
        const annual = turnoverval * 12;
        if (indicator == true) {
            this.annualTurnover = annual;
        }
        if (indicator == false) {
            this.annualExpense = annual;
        }

        if (this.annualTurnover != 0 && this.annualExpense != 0) {
            this.annualNetProfit = this.annualTurnover - this.annualExpense;
            this.monthlyNetProfit = this.turnOver - this.expense;
        }
    }

    async handleSubmit() {
        console.log('financeParentrecord-->' + this.financialId);
        if(this.isR2){
            this.assesedfinancialRecord.Row_Instance__c = this.keyVal;
            this.parentRecordId = await getActiveFinancialRecord({applicantId :this.applicantId, rowIndex : parseInt(this.keyVal)});
            if(this.parentRecordId){
                this.assesedfinancialRecord.Id = this.parentRecordId; 
            }
        }

        this.handleFieldMappings();
        this.saveDetails = true;
        const fields = this.assesedfinancialRecord;
        console.log('assessedNodocfinancialRecord-->' + JSON.stringify(this.assesedfinancialRecord));
        const recordInput = {
            apiName: APPLICANTFINANCIALDETAILS_OBJECT.objectApiName,
            fields
        };
        if (this.isInputValid()) {
            this.isButtonDisabled = true;
            // Creates the event with the data.
            const selectedEvent = new CustomEvent("assesesnodocsubmit", {
                //  detail: this.assesedfinancialRecord
                detail: {
                    record: this.assesedfinancialRecord,
                    template: 'assessed'
                    
                }

            });

            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
            this.editSave = true;
            this.readAttribute = true;
            
            if(this.isR2){
                this.readonly = true;
             }
        }
    }

    handleFieldMappings() {
        console.log('recordType-->' + this.recordTypeId);
        this.assesedfinancialRecord.RecordTypeId = this.recordTypeId;
        this.assesedfinancialRecord.Annual_Turnover__c = this.annualTurnover;
        this.assesedfinancialRecord.Monthly_Expense__c = this.expense;
        this.assesedfinancialRecord.Annual_Expense__c = this.annualExpense;
        this.assesedfinancialRecord.Monthly_Net_Profit__c = this.monthlyNetProfit;
        this.assesedfinancialRecord.Annual_Net_Profit__c = this.annualNetProfit;
        this.assesedfinancialRecord.Applicant__c = this.applicantId;
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
        return isValid;
    }

    @api
    handleassessedReadOnly() {
        this.readAttributee = true;
        this.editSave = false;
    }

    handleCancel() {
        this.readAttributee = true;
        this.editSave = false;
    }
    handleEdit(){
        this.readAttribute = false;
        this.editSave = true;
        if(this.isR2){
            this.isButtonDisabled = false;
        }
    }

    handleEditSubmit(event) {
        event.preventDefault();
        console.log('financialId-->'+this.financialId);
        console.log('onsubmit event recordEditForm' + JSON.stringify(event.detail.fields));
        //this.handleFieldMappings();
        const fields = event.detail.fields;
        fields.Annual_Turnover__c = this.annualTurnover;
        fields.Monthly_Expense__c = this.expense;
        fields.Annual_Expense__c = this.annualExpense;
        fields.Monthly_Net_Profit__c = this.monthlyNetProfit;
        fields.Annual_Net_Profit__c = this.annualNetProfit;
        //this.assesedfinancialRecord.Applicant__c=this.applicantId;
        console.log('fields-->' + JSON.stringify(fields));

        if (this.isInputValid()) {
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
    
    }

    handleUpdate() {
        this.handleFieldMappings();
        // Creates the event with the data.
        const selectedEvent = new CustomEvent("assessedupdate", {
            detail: {
                record: this.assesedfinancialRecord,
                template: 'assessed',
                bubbles: true,
                composed: true
            }

        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
    handleRowAction(event) {
        this.readonly = false;
    }
    handleEditCancel(event) {
        this.readonly = true;

    }
    handleSuccess(event) {
        this.isLoaded = true;
        console.log('onsuccess event recordEditForm', event.detail.id);
        this.showMessage('Record Updated Successfully', 'success');
        this.showEditView = false;
        this.redirectHome();
        this.isLoaded = false;
    }

    showMessage(message, variant) {
        const event = new ShowToastEvent({
            title: '',
            variant: variant,
            mode: 'dismissable',
            message: message
        });
        this.dispatchEvent(event);
    }

    redirectHome() {
        this.showEditView = false;
        const selectedEvent = new CustomEvent("home", {
            detail: {
                redirect: false,
                template: 'assessed'
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
            template: 'assessed'
             }
         });
         this.dispatchEvent(selectedEvent);
    }


     // R2 || START
   async handleDeleteRow(event){
    console.log('existingDetails-->' +JSON.stringify(this.existingDetails));
    if(this.existingDetails.length !=0){
        /*markRecordsInactive({afd :this.existingDetails[0].Id}).then((data)=>{
            this.handleResetValues(); 
        }).catch((error)=>{
        })*/
        this.handlemarkRecordsInactive( this.existingDetails[0].Id);
    }else{
        this.parentRecordId = await getActiveFinancialRecord({applicantId :this.applicantId, rowIndex : parseInt(this.keyVal)});
       /* markRecordsInactive({afd :this.parentRecordId}).then((data)=>{
            this.handleResetValues(); 
        }).catch((error)=>{
        })*/
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
    this.turnOver =undefined;
    this.annualTurnover =undefined;
    this.expense =undefined;
    this.annualExpense =undefined;
    this.bnameVal ='';
    this.monthlyNetProfit=undefined;
    this.annualNetProfit=undefined;
    this.existingDetails=[];
    this.showEditView = false;
    this.showViewForm = false;
    this.salaryView = true;   
    this.readAttribute = false; //
    this.isButtonDisabled = false;
}
//END
}