import { LightningElement, api } from 'lwc';
import fetchHistory from '@salesforce/apex/DecisionHistoryController.fetchHistory';

export default class DecisionHistory extends LightningElement {
    decisionHistoryList;
    @api recordId;
    errorMessage;

    connectedCallback() {
        fetchHistory({ loanId: this.recordId })
        .then(result => {
            this.decisionHistoryList = result;
        }).catch( error => {
            this.errorMessage = 'Error Loading Decision History. Please contact your admin';
        });
    }
}