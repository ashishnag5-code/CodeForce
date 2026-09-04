import { LightningElement, api, track } from 'lwc';
import getVisibleFields from '@salesforce/apex/financeController.getVisibleFields';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';//4733

export default class WithoutAuditedEditView extends LightningElement {
    //API Attributes
    @api isDelete;
    @api key;
    @api instance;
    @api applicantId;
    @api loanId
    @track isEditRestricted //4733
    @api isR2;
    //Boolean Attributes
    readonly = true;
    isLoaded = false;

    //Decimal Attributes
    annualNetProfit = 0;
    monthlyNetProfit = 0;

    yearOptions;
    yearValue;
    maxDate;
    filingValue;
    filingEditValue;
    async connectedCallback() {
        //console.log('instance-->' +JSON.stringify(instance));
        this.loadYearOptions();
        this.getVisibleFieldsMetadata();
        this.handleInitialValues();
        this.getToday();
        this.isEditRestricted = await restricAccess({compName: 'financialView' ,loanId: this.loanId})
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

    handleInitialValues() {
        this.monthlyNetProfit = this.instance.Monthly_Net_Profit__c;
        this.yearValue = this.instance.Year__c;
        this.filingValue = this.instance.Filing_Date__c;
    }

    getVisibleFieldsMetadata() {
        this.isLoaded = true;
        getVisibleFields({
                strScreen: 'Documented- Without Audited Financial',
                Stage:'QDE'
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
    handleChange(event) {
        //this.documentedwithoutfinancialRecord[event.target.name] = event.target.value;
        let fieldName = event.target.name;
        let fieldValue = event.target.value;
        if (fieldName == 'Annual_Net_Profit__c') {
            this.annualNetProfit = parseFloat(fieldValue);
            this.monthlyNetProfit = this.handleMonth(this.annualNetProfit);
        }
        if (fieldName == 'Year__c') {
            this.yearValue = fieldValue;
        }
        if(fieldName == 'Filing_Date__c'){
            this.filingEditValue = fieldValue;
        }
    }

    handleMonth(turnoverval) {
        const monthly = turnoverval / 12;
        return monthly;
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
        
        //this.handleFieldMappings();
        const fields = event.detail.fields;
        fields.Monthly_Net_Profit__c = this.monthlyNetProfit;
        fields.Filing_Date__c = this.filingEditValue; //10 Jul
        fields.Year__c = this.yearValue;
        console.log('fields-->' + JSON.stringify(fields));
        const selectedDate = new Date( this.filingEditValue );
        const currentDate = new Date();
       // currentDate.setHours(0, 0, 0, 0);
        if (selectedDate > currentDate) {
            console.log('futureDate');
        }else{
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            console.log('onsubmit event recordEditForm' + JSON.stringify(event.detail.fields));
        }
    }
    handleRowAction(event) {
        this.readonly = false;
    }
    handleEditCancel(event) {
        this.readonly = true;
    }
    handleSuccess(event) {
        //  this.isLoaded = true;
        if(this.isEditRestricted){
            return;
        }//4733
        console.log('onsuccess event recordEditForm', event.detail.id);
        this.showMessage('Record Updated Successfully', 'success');
        //this.redirectHome();
        const selectedEvent = new CustomEvent("otherincome", { 
            detail: { 
                redirect: false,
                template: 'withoutdoc'
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
                template: 'withoutdoc'
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