import { api, LightningElement, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import handleApplicationReject from '@salesforce/apex/SystemGenerateDocumentsController.rejectApplication';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Custom Spinner settings
import { getSpinnerImage } from 'c/customSpinner';
// Custom Spinner settings


export default class Ausf_rejectDocumentButtonLWC extends LightningElement {
    @api recordId;
    @track applicationRecord = {};
    @track showPickListComponent = false;
    @track picklistValues = {'controllerValue':'','dependentValue':''};
    isShowModal = false;
    isLoading = true;
    isRefreshRecord = false;
    @api
    renderComponent(loanApplicationRecord) {
        this.isShowModal = true;
        console.log('test '+JSON.stringify(loanApplicationRecord));
        this.applicationRecord = loanApplicationRecord;
        this.showPickListComponent = (loanApplicationRecord!=undefined)?true:false;
        this.isLoading = false;
    }


    // Custom Spinner settings
    async spinnerImageMethod() {
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.recordId);
        }
    }
    

    async connectedCallback(){
        this.handleSpinnerAssignment();
    }

    async handleSpinnerAssignment(){
        await this.spinnerImageMethod();
    }
    // Custom Spinner settings


    hideModalBox() {
        this.isShowModal = false;
        const refreshEvt = new CustomEvent('refresh',{detail : this.isRefreshRecord});
        this.dispatchEvent(refreshEvt);
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

    handleReject(evt) {
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
                this.isRefreshRecord = true;
                this.showToast('SUCCESS!','Record Rejected Successfully','success');
                this.hideModalBox();
            })
            .catch(err=>{
                this.isLoading = false;
                this.showToast('ERROR!','Error in Saving the application record','error');
                this.hideModalBox();
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
            reason.setCustomValidity("Name value is required");
        } else {
            isValid = true;
            reason.setCustomValidity(""); // clear previous value
        }
        reason.reportValidity();
        return isValid;

    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            // mode: 'dismissable'
            mode: variant === 'error' ? 'sticky' : 'dismissable'
        });
        this.dispatchEvent(event);
    }
}