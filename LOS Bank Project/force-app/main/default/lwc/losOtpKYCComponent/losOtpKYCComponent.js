import { LightningElement, api } from 'lwc';
import updateRecords from '@salesforce/apex/LosKYCController.updateRecords';
import addressMatchForAadhar from '@salesforce/apex/LOSKarzaAddressMatchController.addressMatchForAadhar';

export default class LosOtpKYCComponent extends LightningElement {

    @api applicant = {};
    @api isVerified;
    @api kyc;
    @api spinnerImage;
    identifierDocuments;

    aadhaarNumber;
    adharValidateResponse;
    
    consent;
    address;

    showAadhaarDetails;
    showOTPKYC = true;
    isloading = false;

    connectedCallback(){
        console.log('kyc value is:',this.kyc);
        console.log('applicant', JSON.stringify(this.applicant));
        if(this.applicant.KYC_Status__c == 'Complete'){
            this.consent = true;
            this.isVerified = true;
        }
    }

    showKYCOptions(){
        console.log('Back to KYC Subtype option selection');
        this.dispatchEvent(new CustomEvent('subkycselection'));
    }

    handleProgressValueChange(event) {
        try {
            console.log('innnn' + event.detail.aadhaarNumber);
            console.log('applicant', JSON.stringify(this.applicant));
            this.aadhaarNumber = event.detail.aadhaarNumber;
            this.consent = true;
           // this.applicant['Aadhaar_Number__c'] = event.detail.aadhaarNumber;
           // this.applicant['Aadhaar_Consent_Version__c'] = 'V1';
          //  this.isVerified = true;          
          this.adharValidateResponse = event.detail.adharValidateResponse;
          this.identifierDocuments = event.detail.identifierDocuments;
          console.log("adharValidateResponse-- "+JSON.stringify(this.adharValidateResponse));
          console.log("identifierDocuments-- "+JSON.stringify(this.identifierDocuments));
          this.showDetails();
        } catch (error) {
            console.log('error', error);
        }
    }

    handleDocumentVerify() {
        //bug fix SFAU-1090 start
        this.applicant = JSON.parse(JSON.stringify(this.applicant))
        this.applicant.KYC_Status__c = "Complete";
        //bug fix SFAU-1090 end
        this.updateRecords();
        this.isVerified = true;
       // this.showDetails();
    }

    updateRecords(){
        console.log('applicant id: ', JSON.stringify(this.applicant));
        console.log('response: ', JSON.stringify(this.adharValidateResponse));
        //update record on controller
        this.isloading = true;
        updateRecords({ applicant: JSON.stringify(this.applicant), response: JSON.stringify(this.adharValidateResponse.Response) })
            .then(result => {
                this.isloading = false;
                this.showDetails();
                this.template.querySelector('c-generic-Verification-Component')?.addCssTopreviewIcon();
             /*   this.evt = setInterval(() => {
                    this.template.querySelector('c-generic-verification-component').addCssTopreviewIcon();
                  }, 300);  */

                console.log('result - aadhar update: ', result);
                this.updateParent();
                this.callAddressMatchCallout();
            })
            .catch(error => {
                this.isloading = false;
                this.error = error;
                console.log('error', error);
            })

    }

    
    callAddressMatchCallout(){
        addressMatchForAadhar({response: JSON.stringify(this.adharValidateResponse), recordId: this.applicant.Id}).then((data=>{
            console.log(data)
        }))
    }
    //'Dob__c': '28-02-1995', //Applicant

    updateParent(){
        console.log('Updating Parent');
        this.dispatchEvent(new CustomEvent('updateapplicant', {
            detail: {
                'applicant': this.applicant
            }
        }));
    }

    handleClick() {
        this.dispatchEvent(new CustomEvent('wizardevent', {
            detail: { name: 'EditKYC', mode: 'edit' },bubbles: true, composed: true
        }));
    }

    showDetails() {
        console.log('Show user details');
        this.showOTPKYC = !this.showOTPKYC;
        this.showAadhaarDetails = !this.showAadhaarDetails;
    }

    updateConsent(event){
        this.consent = event.detail.consent;
        document.getElementsByName('aadhaarVerification').consent = this.consent;
    }
}