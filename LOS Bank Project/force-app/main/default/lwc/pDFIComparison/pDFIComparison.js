import { LightningElement, api } from 'lwc';
import getDetails from '@salesforce/apex/PDFIComparisonController.fetchDetails';

export default class PDFIComparison extends LightningElement {
    @api recordId;
    errorMessage;
    valuesForDisplay = [];

    connectedCallback() {
        getDetails({ loanId: this.recordId })
        .then(result => {
            if (result.errorMessage) {
                this.errorMessage = result.errorMessage;
            } else {
                this.valuesForDisplay = result.tableValuesInst;
            }
        })
        .catch(error => {
            this.errorMessage = 'We cannot load these details right now. Please reach out to your admin - ' + error?.body?.message;
        })
    }
}