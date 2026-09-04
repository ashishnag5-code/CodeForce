import { api, LightningElement, track } from 'lwc';

export default class CbsCheckDPDPopOver extends LightningElement {
    @api loanId;
    @api applicantId;
    @api customerId;
    @api stage;
    @api isDisabled;
    @api isAutoFetch = false;
    isCreditPopOver = true;
    message;

    closeModal(){
        window.history.back();
    }

    handleDPDFetched(event) {
        this.message = event.detail.message;
    }
}