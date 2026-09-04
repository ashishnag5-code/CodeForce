import { LightningElement,api } from 'lwc';
import getCasaDetails from '@salesforce/apex/exposureDetailsController.getCasaDetails';
import getVisibleFields from '@salesforce/apex/exposureDetailsController.getVisibleFields';
export default class ExposureCasaLoanAccountDetails extends LightningElement {

    @api objAccountRecord;

    //Boolean Attributes
    isLoaded = false;

    connectedCallback() {
        console.log('loanStage-->' +this.objAccountRecord.Applicant__r.Loan__r.Stage__c);
        this.getVisibleFieldsMetadata(this.objAccountRecord.Applicant__r.Loan__r.Stage__c);
    }
    
    handleCasa(){
        console.log('CASA Account Number-->' +this.objAccountRecord.Account_Number__c);
        console.log('appplicant-->' +this.objAccountRecord.Applicant__c);
        this.getCasaStatement(this.objAccountRecord.Account_Number__c,this.objAccountRecord.Applicant__c);
    }

    getCasaStatement(accountNumber,applicant){
        this.isLoaded =true;
        getCasaDetails({
            accountNumberInstance: accountNumber,
            applicantId: applicant
        }).then(result => {
            if (result) {
               console.log('descreiption-->' +result[0].Description);
               console.log('casaResponse==>' +JSON.stringify(result));
                this.isLoaded = false;
                this.dispatchEvent(new CustomEvent('casadetails', {
                    detail: result
                }));
            }
        })
        .catch(error => {
            this.isLoaded = false;
            console.log('error in getCasaDetails-->' + JSON.stringify(error));
        })
    }

    getVisibleFieldsMetadata(stageVal) {
        this.isLoaded = true;
        getVisibleFields({
                strScreen: 'Exposure CASA Details',
                Stage: stageVal
            })
            .then(result => {
                console.log('casaFields-->' +JSON.stringify(result));
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
}