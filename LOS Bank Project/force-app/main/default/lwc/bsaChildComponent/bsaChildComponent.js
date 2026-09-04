import { LightningElement,api, track } from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createBSARecord from '@salesforce/apex/BSACreditController.createBSARecord';
import removeBSARecord from '@salesforce/apex/BSACreditController.removeBSARecord';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';

export default class BsaChildComponent extends NavigationMixin(LightningElement) {
    //API Attributes
    @api applicantId;
    @api accessKey;
    @api key;
    @api bankAccountRecords;
    @api loanId
    //Decimal Attributes
    ambTotal=0;

    //Boolean Attributes
    showParent = true;
    isLoaded = false;
    showView = false;
    showNewFormView = false;
    showEditForm = false;
    showModal = false;
    inputsDisabled = false;
    isButtonDisabled=false;

    //String Attributes
    fileId = '';
    bankRecordId = '';

    //Decimal Attributes
    keyIndex = 0;

    //Array Attributes
    bsaRecord = {};
    bankRecords = [];

    @track isEditRestricted

    async connectedCallback() {
        console.log('bankAccountRecords-->' + JSON.stringify(this.bankAccountRecords));
        if (this.bankAccountRecords != '' && this.bankAccountRecords != null) {
            this.showView = true;
            this.handleTotalAMB(this.bankAccountRecords);
            this.showNewFormView = false; //2 Aug || SFAU-4456
        } else {
            this.showNewFormView = true;
            this.showView = true; //2 Aug || SFAU-4456
            this.handleNew();//2 Aug || SFAU-4456
        }
        this.isButtonDisabled = false;
        this.isEditRestricted = await restricAccess({compName: 'bsaChildComponent' ,loanId: this.loanId})
    }

    handleTotalAMB(bankRecords){
        //for(let i=0;i<bankRecords.length;i++)
        let ambTotal =0;
        bankRecords.forEach(bankInstance => {
            if(bankInstance.AverageMonthlyBalance!=undefined){
                ambTotal = ambTotal + (bankInstance.AverageMonthlyBalance);
                console.log('AverageMonthlyBalance-->' +bankInstance.AverageMonthlyBalance);
            }
          
        });
        this.ambTotal = ambTotal.toFixed(2);
        console.log('ambTotal-->' +ambTotal);
    }
    showAMBSection(event) {
        console.log('insideAMB');
        this.showParent = false;
        this.dispatchEvent(new CustomEvent('showamb', {
            detail: event.currentTarget.dataset.id,
        }));
    }

    showAMCSection(event) {
        this.showParent = false;
        this.dispatchEvent(new CustomEvent('showamc', {
            detail: event.currentTarget.dataset.id,
        }));
    }

    handlePreview(event) {
        console.log('recId-->' +event.currentTarget.dataset.id);
        let recId = event.currentTarget.dataset.id;
        if(recId!=undefined && recId!=''){
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state: {
                    selectedRecordId: recId
                }
            })
        }else{
            this.showErrorMessage('File is not present for this record','error');
        }
        
    }

    addNewRow(event) {
        if(this.isEditRestricted){
            this.showErrorMessage('You do not have access to add BSA','error');
            return
        }
        ++this.keyIndex;
        var newItem = [{
            index: this.keyIndex
        }];
        this.bankRecords = this.bankRecords.concat(newItem);
        this.isButtonDisabled = false;
    }

    removeRow(event) {
        console.log('key-->' + event.target.accessKey);
        if (this.bankRecords.length >= 2) {
            this.bankRecords = this.bankRecords.filter(function (element) {
                return parseInt(element.index) !== parseInt(event.target.accessKey);
            });
        }
    }

    handleChange(event) {
        this.bsaRecord[event.target.name] = event.target.value;
        let fieldName = event.target.name;
        let fieldValue = event.target.value;
    }
    handleOkay() {
        this.showModal = false;
        this.handleNew();
    }

    handleReject() {
        this.showModal = false;
        this.showNewFormView = false;
        this.showView = true;
        this.bankRecords =[];
        this.handeRefreshEvent();
    }

    handeRefreshEvent() {
        this.dispatchEvent(new CustomEvent('refresh', {
            detail: this.applicantId
        }));
    }

    handleSubmit() {
        restricAccess({
            compName: 'bsaChildComponent' ,loanId: this.loanId
            })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save BSA',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }else{
        this.bsaRecord.Applicant__c = this.applicantId;
        console.log('bsaRecord-->' + JSON.stringify(this.bsaRecord));
        if (this.isInputValid()) {
            this.isButtonDisabled = true;
            this.isLoaded = true;
        createBSARecord({
                bsaRecord: this.bsaRecord
            })
            .then(result => {
                this.bankRecords =[];
                this.isLoaded = false;
                console.log('result-->' + JSON.stringify(result));
                this.inputsDisabled = true;
                this.showModal = true;
                this.showMessage('BSA Record Created Successfully', 'success');
                //this.keyIndex =0;
                if(this.bsaRecord.Average_Monthly_Balance__c!=undefined){
                    this.ambTotal = this.ambTotal  +  parseFloat(this.bsaRecord.Average_Monthly_Balance__c);
                }else{
                    this.ambTotal = this.ambTotal;
                }
                
                this.showNewFormView = false;
                this.handeRefreshEvent();
               
            }).catch(error => {
                console.log('error-->' + error);
                this.isLoaded = false;
            });
        }
    }
        })
        .catch(error => {
            console.log('error is ' + JSON.stringify(error));
        })

    }

    handleNew() {
        if(this.isEditRestricted){
            this.showErrorMessage('You do not have access to add BSA','error');
            return
        }
        this.showNewFormView = true;
       // this.showView = false;
        this.addNewRow();
    }
    handleNewFormBack(){
        this.showNewFormView = false;
        this.bankRecords =[];
    }

    handleRowAction(event) {
        const recordId = event.currentTarget.dataset.id;
        console.log('recordId-->' + recordId);
        this.bankRecordId = recordId;
        this.showEditForm = true;
        this.showNewFormView = false;
        this.showView = false;
    }
    handleRowDeleteAction(event) {
        if(this.isEditRestricted){
            this.showErrorMessage('You do not have access to delete BSA','error');
            return
        }
        this.isLoaded = true;
        const recordId = event.currentTarget.dataset.id;

        removeBSARecord({
                bankAccountRecordId: recordId
            })
            .then(result => {
                this.isLoaded = false;
                console.log('result-->' + JSON.stringify(result));
                this.showModal = false;
                this.showMessage('BSA Record Deleted Successfully', 'success');
                this.handeRefreshEvent();
            }).catch(error => {
                console.log('error-->' + error);
                this.isLoaded = false;
            });


    }
    handleEditSubmit(event) {
        this.isLoaded = true;
        event.preventDefault();
        if(this.isEditRestricted){
            this.showErrorMessage('You do not have access to modify BSA','error');
            return
        }
        const fields = event.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
        this.showEditForm = false;
        this.showNewFormView = false;
        this.showView = true;
        this.isLoaded = false;
    }
    handleSuccess(event) {
        if(this.isEditRestricted){
            return
        }
        this.isLoaded = true;
        console.log('onsuccess event recordEditForm', event.detail.id);
        this.handeRefreshEvent();
        this.showMessage('Record Updated Successfully', 'success');
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
    showErrorMessage(message, variant) {
        const event = new ShowToastEvent({
            title: '',
            variant: variant,
            mode: 'sticky',
            message: message
        });
        this.dispatchEvent(event);
    }
    handleBack() {
        this.showEditForm = false;
        this.showNewFormView = false;
        this.showView = true;
    }

    isInputValid() {
        let isValid = true;

        let inputFields = this.template.querySelectorAll(".validate");
        inputFields.forEach(inputField => {
            if (!inputField.value) {
                inputField.setCustomValidity("Complete this field");
                inputField.reportValidity();
                isValid = false;
            } else {
                inputField.setCustomValidity('');
                inputField.reportValidity();
            }
        });
        return isValid;
    }

}