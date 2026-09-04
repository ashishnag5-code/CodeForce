import { api, LightningElement, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
const FIELDS = ['Loan_Application__c.Stage__c'];



export default class Ausf_LoanSummaryDDELWC extends LightningElement {
    @api recordId;
    screenName = 'Summary Page';
    @track stageName = '';
    @track renderChildComponents = false;
    connectedCallback() {
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            
        } else if (data) {
            console.log('loading data'+JSON.stringify(data.fields))
            this.stageName = data.fields.Stage__c.value;
            this.renderChildComponents = true;

        }
    }

}