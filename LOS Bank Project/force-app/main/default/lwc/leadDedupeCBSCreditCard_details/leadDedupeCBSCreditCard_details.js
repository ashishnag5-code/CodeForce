import { LightningElement,api } from 'lwc';

export default class LeadDedupeCBSAccount_details extends LightningElement {
    @api 
    objAccountRecord;
    @api
    spinnerImage;
    isLoading;
}