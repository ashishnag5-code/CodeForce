import { LightningElement, api, track } from 'lwc';
import APPLICANTFINANCIALDETAILS_OBJECT from '@salesforce/schema/Applicant_Financials_Details__c';
import getVisibleFields from '@salesforce/apex/financeController.getVisibleFields';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';//4733

export default class AssessedEditView extends LightningElement {
    @api isDelete;
    @api key;
    @api instance;
    @api loanId;
    @api applicantId;
    @api isMobile;
    readonly = true;
    @track isEditRestricted //4733
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
    annualNetProfit=0;

    //Boolean Attributes
    isLoaded = false;
    showViewForm = false;
    assessedRecord;
    readAttributee = false;
    editSave = false;
    showEditView = false;
    readonly = true;
    @api
    financialId;

    async connectedCallback() {
        this.getVisibleFieldsMetadata();
        this.handleInitialValues();
        this.isEditRestricted = await restricAccess({compName: 'financialView' ,loanId: this.loanId})
    }
    handleChange(event) {
        this.assesedfinancialRecord[event.target.name] = event.target.value;
        let fieldName = event.target.name;
        let fieldValue = event.target.value;
        
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

    handleInitialValues() {
       // let data = this.existingDetails;
       // for (var key in data) {
            this.annualTurnover = this.instance.Annual_Turnover__c;
            this.annualExpense =this.instance.Annual_Expense__c;
            this.monthlyNetProfit = this.instance.Monthly_Net_Profit__c;
            this.annualNetProfit = this.instance.Annual_Net_Profit__c;
            this.turnOver = this.instance.Monthly_Turnover__c;
            this.expense =  this.instance.Monthly_Expense__c;
      //  }
    }

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
    handleSuccess(event) {
        if(this.isEditRestricted){
            return;
        }//4733
        this.isLoaded = true;
        console.log('onsuccess event recordEditForm', event.detail.id);
        this.showMessage('Record Updated Successfully', 'success');
       // this.redirectHome(); jul8
       const selectedEvent = new CustomEvent("otherincome", { 
            detail: { 
            redirect: false,
            template: 'assessed'
             }
         });
         this.dispatchEvent(selectedEvent);
         if(this.isR2){
           this.readonly = true;
         }
         
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
    handleRowAction(event) {
        this.readonly = false;
    }
    handleEditCancel(event) {
        this.readonly = true;

    }

    handleEditSubmit(event) {
        event.preventDefault();
        //4733 start
        if(this.isEditRestricted){
            const evt = new ShowToastEvent({
                title: 'Access Restricted',
                message: 'You do not have access to edit Financial Details',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            return
        }
        //4733 end
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

    redirectHome() {
        this.isLoaded = true;
        this.showEditView = false;
        const selectedEvent = new CustomEvent("home", {
            detail: {
                redirect: false,
                template: 'assessed'
            }
        });
        this.dispatchEvent(selectedEvent);
        this.isLoaded = false;
    }

    handleDeleteRow(event){
        console.log('event-->' +event.currentTarget.dataset.id);
        this.dispatchEvent(new CustomEvent('deletedrecord',{
            detail: event.currentTarget.dataset.id
        }));
    }

}