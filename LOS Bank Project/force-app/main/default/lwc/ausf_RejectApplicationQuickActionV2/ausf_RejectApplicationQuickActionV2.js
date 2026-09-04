import { api, LightningElement, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import handleApplicationReject from '@salesforce/apex/SystemGenerateDocumentsController.rejectApplication';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getSpinnerImage } from 'c/customSpinner';
const FIELDS = ['Loan_Application__c.DO_Status__c', 'Loan_Application__c.Sanction_Status__c','Loan_Application__c.Stage__c'];
const APPLICATION_REJECTION = 'Application_Rejection';
const APPROVAL_REJECTION = 'Approval_Rejection';

export default class Ausf_RejectApplicationQuickActionV2 extends LightningElement {
    @api recordId;
    @track renderComponent = false;
    applicationRecord = {};
        @track picklistValues = {'controllerValue':'','dependentValue':''};
    @track otherReason = '';
    @track isRefreshRecord = false;
    isLoading = true;
    @api spinnerImage;
    @api isApprovalScreen;
   
    connectedCallback(){
        //alert(this.recordId);
    }
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
                this.closeAction( this.otherReason, false, this.isApprovalScreen ? APPROVAL_REJECTION : APPLICATION_REJECTION );
                return;

            }
            if(this.applicationRecord.fields.DO_Status__c.value == 'Issued' || this.applicationRecord.fields.Sanction_Status__c.value == 'Issued') {
                this.showToast('ERROR!','Please cancel DO/ Sanction Letter before proceeding to Reject','error');
                this.closeAction( this.otherReason, false, this.isApprovalScreen ? APPROVAL_REJECTION : APPLICATION_REJECTION );
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
        
let validationResult = this.template.querySelector('c-depended-pick-list-l-w-c').handleDependedCheck();
        if(validationResult){
        if(this.validateOtherValues()) {
                        handleApplicationReject({
                reason : this.picklistValues.controllerValue,
                subReason : this.picklistValues.dependentValue,
                otherReason : this.otherReason,
                applicationId : this.applicationRecord.id,
                    isApprovalScreen: !!this.isApprovalScreen
            })
            .then(res=>{
                this.isLoading = false;
this.showToast('SUCCESS!','Application has been rejected successfully','success');
                this.isRefreshRecord = true;
                this.closeAction(this.otherReason, true, this.isApprovalScreen ? APPROVAL_REJECTION : APPLICATION_REJECTION );
            })
            .catch(err=>{
                this.isLoading = false;
                this.showToast('ERROR!', err.body?.message ?? 'Error in Saving the application record','error');
                this.isRefreshRecord = true;
                    this.closeAction( this.otherReason, false, this.isApprovalScreen ? APPROVAL_REJECTION : APPLICATION_REJECTION );
            })
        }
        else {
            this.isLoading = false;
        }
}
        else{
            let testResult = this.validateOtherValues();
            this.isLoading = false
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

closeAction( reason, isSuccess, action = APPLICATION_REJECTION ) {
        // this.dispatchEvent(new CloseActionScreenEvent());
        // if(this.isRefreshRecord) {
        //     //window.location.reload();
        // }
        this.dispatchEvent(new CustomEvent('closequickaction', { detail: { action, reason, isSuccess } } ));
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
                        mode: variant === 'error' ? 'sticky' : 'dismissable'
        });
        this.dispatchEvent(event);
    }
}