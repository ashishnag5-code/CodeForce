import { LightningElement, api, wire } from 'lwc';
import { reduceErrors, showToastMessage } from 'c/lwcutilities';
import { getRecord, getFieldValue, updateRecord } from 'lightning/uiRecordApi';
import DEAL_BACKGROUND_FIELD from '@salesforce/schema/Loan_Application__c.Deal_Background__c';

export default class LoanDealBackground extends LightningElement {

    @api recordId;
    @api isReadOnly;

    get dealSummary(){
        return getFieldValue( this.loanApplication.data, DEAL_BACKGROUND_FIELD ) ?? '';
    }

    @wire(getRecord, { recordId: '$recordId', fields: [ DEAL_BACKGROUND_FIELD ] })
    loanApplication;

    async saveDealBackground(){
        const dealBackground = this.refs.dealBackground.value;
        const fields = { Id: this.recordId, [ DEAL_BACKGROUND_FIELD.fieldApiName ]: dealBackground };
        const result = await updateRecord( { fields } )
            .catch(err => {
                console.error(err);
                const errorMessage = reduceErrors( err )?.join?.( ',' );
                showToastMessage( this, '', 'error', errorMessage );
            });

        if( result ){
            showToastMessage( this, '', 'success', 'Deal background has been updated successfully' );
            this.dispatchEvent( new CustomEvent( 'dealsummaryupdate' ) );
        }
    }
    closeDealBackground(){
        this.dispatchEvent( new CustomEvent( 'dealsummaryupdate' ) );
    }
}