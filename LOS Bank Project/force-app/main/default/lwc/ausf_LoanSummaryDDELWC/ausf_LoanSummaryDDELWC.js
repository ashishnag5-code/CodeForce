import { api, LightningElement } from 'lwc';

export default class Ausf_LoanSummaryDDELWC extends LightningElement {
    @api recordId;
    screenName = 'Summary Page';
    stageName = 'DDE';
    connectedCallback() {
    }

}