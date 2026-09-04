import { LightningElement,api,wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import STAGE_FIELD from '@salesforce/schema/Loan_Application__c.Stage__c';

const fields = [STAGE_FIELD];

export default class GenericWizardRecordPage extends LightningElement {
    @api flowName;
    @api childToFlow;
    //@api childToFlow1;
    @api boolReFetchData;
    @api recordId;

    @wire(getRecord, { recordId: '$recordId', fields })
    loanApp;

    get stage() {
        return getFieldValue(this.loanApp.data, STAGE_FIELD);
    }
}