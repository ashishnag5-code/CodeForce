import { api,LightningElement } from 'lwc';

export default class Ausf_LoanSummaryCreditLWC extends LightningElement {
    @api recordId;
    screenName = 'Summary Page';
    stageName = 'Credit';
    connectedCallback() {
    }
}