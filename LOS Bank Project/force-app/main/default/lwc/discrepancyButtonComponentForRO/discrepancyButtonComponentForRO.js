import { LightningElement, api, wire } from 'lwc';
import updateLoanApplicationRec from '@salesforce/apex/DiscrepancyButtonController.updateLoanApplicationRec';
import OPS_DISCREPANCY_REMARKS_FIELD from '@salesforce/schema/Loan_Application__c.Remarks__c';
import RO_DISCREPANCY_REMARKS_FIELD from '@salesforce/schema/Loan_Application__c.RO_Discrepancy_Remarks__c';
import DISCREPANCY_COUNT_FIELD from '@salesforce/schema/Loan_Application__c.Discrepancy_Count__c';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

export default class DiscrepancyButtonComponentForRO extends LightningElement {

    @api recordId;
    isLoading = false;
    remarks = '';
    disableSubmit = false;

    @wire(getRecord, { recordId: '$recordId', fields: [ OPS_DISCREPANCY_REMARKS_FIELD, RO_DISCREPANCY_REMARKS_FIELD, DISCREPANCY_COUNT_FIELD ] })
    loanApp;

    // SFAU-4293 - RO remarks not showing for OPS
    get opsRemarks(){
        return getFieldValue( this.loanApp?.data, OPS_DISCREPANCY_REMARKS_FIELD );
    }

    get roRemarks(){
        return this.remarks || getFieldValue( this.loanApp?.data, RO_DISCREPANCY_REMARKS_FIELD );
    }
    get showOpsRemarks(){
        return !!getFieldValue( this.loanApp?.data, DISCREPANCY_COUNT_FIELD );
    }

    handleOnChange(event) {
        this.remarks = event.detail.value;
    }

    handleSubmit() {
        this.disableSubmit = true;
        if(this.remarks) {
            this.isLoading = true;
            updateLoanApplicationRec({ recordId : this.recordId, remarks : this.remarks, opsStatus : '' })
            .then((result) => {
                refreshApex(this.loanApp);  
                this.error = undefined;
                this.closeAction();
            })
            .catch((error) => {
                this.error = error;
                this.isLoading = false;
                this.disableSubmit = false;
                console.log('Error inside updateLoanApplicationRec'+error);
            });
        }
    }

    closeAction() {
        this.disableSubmit = false;
        this.dispatchEvent(new CustomEvent('closequickaction'));
    }
}