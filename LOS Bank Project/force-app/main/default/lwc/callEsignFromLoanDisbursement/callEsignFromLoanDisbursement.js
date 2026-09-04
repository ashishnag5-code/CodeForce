import { LightningElement,api } from 'lwc';
import LightningModal from 'lightning/modal';
import My_Resource from '@salesforce/resourceUrl/ausfIcons';

export default class CallEsignFromLoanDisbursement extends LightningModal {

    @api loanid;
    generateEsign      = My_Resource + '/ausfIcons/Generate-E-sign.png';
    handleCancel() {
        this.close('okay');
    }

    handleReturnToSummary(){
        this.template.querySelector('[data-id="EsignButton"]').classList.remove('slds-hide')
        //this.dispatchEvent(new CustomEvent('returntosummary'));
    }
    handleGenerateEsignClick(){
        this.template.querySelector('[data-id="EsignButton"]').classList.add('slds-hide')
        //this.dispatchEvent(new CustomEvent('generateesignclick'));
    }
    handleSignDeskEsign(){
        this.template.querySelector('c-generate-esign-component').handleGenerateEsign()
    }
}