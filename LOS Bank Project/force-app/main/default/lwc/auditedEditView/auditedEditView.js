import { LightningElement, api, track } from 'lwc';
import getVisibleFields from '@salesforce/apex/financeController.getVisibleFields';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';//4733

export default class AuditedEditView extends LightningElement {
    //API Attributes
    @api isDelete;
    @api key;
    @api instance;
    @api applicantId;
    @api loanId
    @api isR2;
    @track isEditRestricted //4733
    //Array Attributes
    documentedfinancialRecord = {};

    //Decimal Attributes
    turnOver = 0;
    grossturnoverMonthly = 0;
    annualNetProfit = 0;
    monthlyNetProfit = 0;
    annualDepreciation = 0;
    monthlyDepreciation = 0;
    annualInterestLoan = 0;
    monthlyInterestLoan = 0;
    annualnonchash = 0;
    monthlynoncash = 0;
    annualtotalIncome = 0;
    monthlytotalIncome = 0;
    yearVal = 0;

    //Boolean Attributes
    isLoaded = false;
    rendeauditedFinaceTemplate = true;
    showEditView = false;
    readonly = true;
    readAttribute = false;

    async connectedCallback() {
        this.getVisibleFieldsMetadata();
        this.handleInitialValues();
        this.isEditRestricted = await restricAccess({compName: 'financialView' ,loanId: this.loanId})
    }

    getVisibleFieldsMetadata() {
        getVisibleFields({
                strScreen: 'Documented- With Audited Financial',
                Stage:'QDE'
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

    handleInitialValues() {
        this.grossturnoverMonthly = this.instance.Monthly_Turnover__c;
        this.monthlyNetProfit = this.instance.Monthly_Net_Profit__c;
        this.monthlyDepreciation = this.instance.Monthly_Depreciation__c;
        this.monthlyInterestLoan = this.instance.Monthly_Interest_Paid_on_Loans__c;
        this.monthlynoncash = this.instance.Monthly_Non_Cash_Expenses__c;
        this.annualtotalIncome = this.instance.Annual_Total_Income__c;
        this.monthlytotalIncome = this.instance.Monthly_Total_Income__c;
        // R2-2611 Start
        this.yearVal = this.instance.Year__c;
        // R2-2611 end
    }

    handleChange(event) {
        this.documentedfinancialRecord[event.target.name] = event.target.value;
        let fieldName = event.target.name;
        let fieldValue = event.target.value;

        // R2-2611 Start
        if (fieldName == 'Year__c') {
            this.yearVal = fieldValue;
        }
        // R2-2611 End

        if (fieldName == 'Annual_Turnover__c') {
            this.turnOver = parseFloat(fieldValue);
            this.grossturnoverMonthly = this.handleMonth(this.turnOver);
        }

        if (fieldName == 'Annual_Net_Profit__c') {
            this.annualNetProfit = parseFloat(fieldValue);
            this.monthlyNetProfit = this.handleMonth(this.annualNetProfit);
        }

        if (fieldName == 'Annual_Depreciation__c') {
            this.annualDepreciation = parseFloat(fieldValue);
            this.monthlyDepreciation = this.handleMonth(this.annualDepreciation);
        }

        if (fieldName == 'Annual_Interest_Paid_On_Loans__c') {
            this.annualInterestLoan = parseFloat(fieldValue);
            this.monthlyInterestLoan = this.handleMonth(this.annualInterestLoan);
        }

        if (fieldName == 'Annual_Non_Cash_Expenses__c') {
            this.annualnonchash = parseFloat(fieldValue);
            this.monthlynoncash = this.handleMonth(this.annualnonchash);

        }
    }

     // R2-2611 Start
     isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll(".validate");
        inputFields.forEach(inputField => {
            if(!inputField.reportValidity()){
                isValid = false;
            }
        });
        return isValid;
    }
    // R2-2611 end


    handleMonth(turnoverval) {
        const monthly = turnoverval / 12;
        return monthly;
    }

    calculateTotalIncome() {
        const annualIncome = this.turnOver + this.annualNetProfit + this.annualDepreciation + this.annualInterestLoan + this.annualnonchash;
        this.annualtotalIncome = annualIncome;
        this.monthlytotalIncome = this.handleMonth(this.annualtotalIncome);
    }

    handleCancel() {
        this.readAttribute = true;
        this.editSave = false;
    }
    handleEdit() {
        this.readAttribute = false;
        this.editSave = true;
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

        // R2-2611 Start
        if(!this.isInputValid()){
            return;
        }
        // R2-2611 End

        //this.handleFieldMappings();
        const fields = event.detail.fields;
        fields.Monthly_Turnover__c = this.grossturnoverMonthly;
        fields.Monthly_Net_Profit__c = this.monthlyNetProfit;
        fields.Monthly_Depreciation__c = this.monthlyDepreciation;
        fields.Monthly_Interest_Paid_on_Loans__c = this.monthlyInterestLoan;
        fields.Monthly_Non_Cash_Expenses__c = this.monthlynoncash;
        fields.Annual_Total_Income__c = this.annualtotalIncome;
        fields.Monthly_Total_Income__c = this.monthlytotalIncome;

        // R2-2611 Start
        fields.Year__c = this.yearVal;
        // R2-2611 end

        console.log('fields-->' + JSON.stringify(fields));
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        console.log('onsubmit event recordEditForm' + JSON.stringify(event.detail.fields));
    }
    handleRowAction(event) {
        this.readonly = false;
    }
    handleEditCancel(event) {
        this.readonly = true;
    }
    handleSuccess(event) {
        if(this.isEditRestricted){
            return;
        }//4733
        console.log('onsuccess event recordEditForm', event.detail.id);
        this.showMessage('Record Updated Successfully', 'success');
        //this.redirectHome(); jul8
        const selectedEvent = new CustomEvent("otherincome", { 
            detail: { 
                redirect: false,
                template: 'documentaudited'
            }
        });
        this.dispatchEvent(selectedEvent);
        if(this.isR2){
            this.readonly = true;
        }
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
                template: 'documentaudited'
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    handleEnableFetchDetails(event){
        
    }
    // R2
    handleDeleteRow(event){
        console.log('event-->' +event.currentTarget.dataset.id);
        this.dispatchEvent(new CustomEvent('deletedrecord',{
            detail: event.currentTarget.dataset.id
        }));
    }

}