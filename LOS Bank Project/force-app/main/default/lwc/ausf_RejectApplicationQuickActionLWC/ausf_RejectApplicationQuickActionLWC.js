import { api, LightningElement, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import handleApplicationReject from '@salesforce/apex/SystemGenerateDocumentsController.rejectApplication';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getSpinnerImage } from 'c/customSpinner';


const FIELDS = ['Loan_Application__c.DO_Status__c', 'Loan_Application__c.Sanction_Status__c','Loan_Application__c.Stage__c'];

export default class Ausf_RejectApplicationQuickActionLWC extends LightningElement {
    @api recordId;
    @track renderComponent = false;
    applicationRecord = {};
    @track picklistValues = {'controllerValue':'','dependentValue':''};
    @track otherReason = '';
    @track isRefreshRecord = false;
    isLoading = true;
    @api spinnerImage;
   
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            this.isLoading = false;
            
        } else if (data) {
            console.log('test '+JSON.stringify(data));
            this.applicationRecord = data;
            this.isLoading = false;
            if(this.applicationRecord.fields.Stage__c.value == 'Rejected') {
                this.showToast('ERROR!','Application Record Rejected cannot be Rejected again','error');
                this.closeAction();
                return;

            }
            if(this.applicationRecord.fields.DO_Status__c.value == 'Issued' || this.applicationRecord.fields.Sanction_Status__c.value == 'Issued') {
                this.showToast('ERROR!','Please cancel DO/ Sanction Letter before proceeding to Reject','error');
                this.closeAction();
                return;
            }
            this.spinnerImageMethod();
        }
    }

    async spinnerImageMethod() {
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.applicationRecord.Id);
        }
        console.log('%% '+this.spinnerImage);
    }

    handlePicklistSelection(evt) {
        console.log('selected '+JSON.stringify(evt.detail));
        this.picklistValues.controllerValue = evt.detail.controllerValue;
        this.picklistValues.dependentValue = evt.detail.dependentValue;
    }

    handleTextAreaChange(evt) {
        console.log('test '+evt.detail.value);
        this.otherReason = evt.detail.value;
    }

    handleReject() {
        this.isLoading = true;
        if(this.picklistValues.controllerValue == ''){
            this.showToast('ERROR!','Please select a Rejection Reason to proceed','error');
            this.isLoading = false;
            return;
        }
        
        if(this.validateOtherValues()) {
            handleApplicationReject({
                reason : this.picklistValues.controllerValue,
                subReason : this.picklistValues.dependentValue,
                otherReason : this.otherReason,
                applicationId : this.applicationRecord.id
            })
            .then(res=>{
                this.isLoading = false;
                this.showToast('SUCCESS!','Record Rejected Successfully','success');
                this.isRefreshRecord = true;
                this.closeAction();
            })
            .catch(err=>{
                this.isLoading = false;
                this.showToast('ERROR!','Error in Saving the application record','error');
                this.isRefreshRecord = true;
                this.closeAction();
            })
        }
        else {
            this.isLoading = false;
        }

    }

    validateOtherValues() {
        let isValid = true;
        let reason = this.template.querySelector("lightning-textarea");
        if(this.picklistValues.controllerValue == 'Other' && !reason.value) {
            isValid = false;
            reason.setCustomValidity("Other Reason required");
        } else {
            isValid = true;
            reason.setCustomValidity(""); // clear previous value
        }
        reason.reportValidity();
        return isValid;

    }

    closeAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
        if(this.isRefreshRecord) {
            //window.location.reload();
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}