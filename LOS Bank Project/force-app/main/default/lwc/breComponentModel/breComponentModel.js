import { LightningElement, api } from 'lwc';
// import { getSpinnerImage } from 'c/customSpinner';

export default class BreComponentModel extends LightningElement {
    // spinnerImage;
    @api loanApplication;

    get stageName(){
        return this.loanApplication.Stage__c;
    }

    handleClose(){
        this.dispatchEvent(
            new CustomEvent('toggle')
        );
    }
}