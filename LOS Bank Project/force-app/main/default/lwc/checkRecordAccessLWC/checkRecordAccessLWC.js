import { LightningElement,wire,api,track } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import IsVisibleToLoggedInUser__c from "@salesforce/schema/Loan_Application__c.IsVisibleToLoggedInUser__c";
import EnableCustomRoleHierarchyFeature from '@salesforce/label/c.EnableCustomRoleHierarchyFeature'
const fields = [IsVisibleToLoggedInUser__c];
import { getSpinnerImage } from 'c/customSpinner';
import FORM_FACTOR from "@salesforce/client/formFactor";

export default class CheckRecordAccessLWC extends LightningElement {
    message = 'You Don\'t have necessary permissions to view this record detail';
    @api recordId;
    loanApplicantionRecord;
    boolIsVisible = true;
    spinnerImage;
    @track isLoading=true
    @track isMobile

    @wire(getRecord, {
        recordId: "$recordId",
        fields
    })
    wiredRecord({ error, data }) {
        if (data) {
            this.loanApplicantionRecord = data;
            if(EnableCustomRoleHierarchyFeature.toLowerCase()=='true'){
                this.boolIsVisible = getFieldValue(this.loanApplicantionRecord, IsVisibleToLoggedInUser__c);
            }
            this.isLoading = false
        }
        else if(error){
            this.isLoading = false
            console.log('error '+JSON.stringify(error));
        }
    }

    async connectedCallback(){
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.recordId);
        }
        if(FORM_FACTOR=='Small'){
            this.isMobile=true
        }
    }

    closeModal(){
        window.history.back();
    }
}