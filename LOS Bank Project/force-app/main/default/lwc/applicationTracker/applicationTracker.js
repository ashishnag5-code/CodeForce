import { LightningElement, api } from 'lwc';
import fetchLineItems from '@salesforce/apex/ApplicationTrackerController.fetchLineItems';

export default class ApplicationTracker extends LightningElement {
    @api recordId;
    lineItems = [];

    connectedCallback() {
        fetchLineItems({ recordId: this.recordId })
        .then((result) => {
            this.lineItems = result;
        })
        .catch(error =>{
            console.error('Error - ' + error);
        })
    }
}