import { LightningElement,api } from 'lwc';
import getVisibleFields from '@salesforce/apex/exposureDetailsController.getVisibleFields';
import getCCDetails from '@salesforce/apex/exposureDetailsController.getCCDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ExposureCCAccountDetails extends LightningElement {
    @api objAccountRecord;
    
    //Boolean Attributes
    isLoaded = false;
    showODReponseSection = false;

    responseStatement;

    connectedCallback() {
        console.log('loanStage-->' +this.objAccountRecord.Applicant__r.Loan__r.Stage__c);
        this.getVisibleFieldsMetadata(this.objAccountRecord.Applicant__r.Loan__r.Stage__c);
    }

    getVisibleFieldsMetadata(stageVal) {
        this.isLoaded = true;
        getVisibleFields({
                strScreen: 'DDE Exposure CC  Details',
                Stage: stageVal
            })
            .then(result => {
                result.forEach(input => {
                    this.template.querySelector('[data-id="' + input + '"]').classList.remove('slds-hide');
                });
                this.isLoaded = false;
            })
            .catch(error => {
                this.isLoaded = false;
                console.log('result is ' + JSON.stringify(error));
            })
    }

    handleCC(){
        console.log('CASA Account Number-->' +this.objAccountRecord.Account_Number__c);
        console.log('appplicant-->' +this.objAccountRecord.Applicant__c);
        this.getCCStatement(this.objAccountRecord.Account_Number__c,this.objAccountRecord.Applicant__c,this.objAccountRecord.Id);
    }

    getCCStatement(accountNumber,applicant,accountId){
        this.isLoaded =true;
        getCCDetails({
            accountNumberInstance: accountNumber,
            applicantId: applicant,
            accountId: accountId
        }).then(result => {
            if (result!=null) {
             this.responseStatement = result;
              this.isLoaded = false;
              this.showODReponseSection = true;
            }else{
                this.showErrorMessage("For account number " + accountNumber + ", there are no existing credit card details.", 'error');
                this.isLoaded =false;
            }
        })
        .catch(error => {
            this.isLoaded = false;
            console.log('error in getCasaDetails-->' + JSON.stringify(error));
        })
    }
    showErrorMessage(message, variant) {
        const event = new ShowToastEvent({
            title: '',
            variant: variant,
            mode: 'sticky',
            message: message
        });
        this.dispatchEvent(event);
    }

}