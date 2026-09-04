import { LightningElement, api } from 'lwc';
import aadhaar from '@salesforce/resourceUrl/aadhaar';
import ckyc from '@salesforce/resourceUrl/ckyc';
import { NavigationMixin } from 'lightning/navigation';
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getApplicant from '@salesforce/apex/LosKYCController.getApplicantData';
import verifyKYC from '@salesforce/apex/LosKYCController.verifyKYC';
import Generic_API_Error from '@salesforce/label/c.Generic_API_Error';
import kycNotVerifiedErrorMessage from '@salesforce/label/c.KYCNotVerifiedError';

export default class Los_KYCComponent extends NavigationMixin(LightningElement) {
    aadhaarIcon = aadhaar;
    ckycIcon = ckyc;
    KYCSelection = true;
    Generic_API_Error = Generic_API_Error;

    aadhaarVerificationType;
    validateOTP = false;
    selectedKYC;
    consent = false;
    showAadhaarDetails = false;
    aadhaarNumber = '';
    isVerified = false;
    @api spinnerImage;
    
    @api applicantId;
    applicant = {};
    applicantType;
    consent = false;
    selectedValue;

    title = 'KYC';
    connectedCallback() {
        console.log('test update 1');
        console.log('applicant details in KYC1:', this.applicantId);
        this.getApplicantData();
    }
    loadCmp = false;

    getApplicantData() {
        getApplicant({ applicantId: this.applicantId })
            .then(result => {
                console.log('result is ' + result)
                this.applicant = JSON.parse(result);
                console.log('result is ' + JSON.stringify(this.applicant));   
                console.log('aadhaar number: ' + this.applicant.Aadhaar_Number__c);  
                this.loadCmp = true;             
            })
            .catch(error => {
                this.error = error;
            });
    }

    showKYCOptions() {
        this.KYCSelection = true;
        this.selectedKYC = false;
    }

    handleOnPlay() {
        console.log('play song');
    }

    selectKYCType(event) {
        console.log('KYC Type selected');
        //this.KYCSelection = false;
        this.selectedValue = event.target.dataset.id;
        if (event.target.dataset.id == 'Aadhaar') {
            this.selectedKYC = true;
            this.KYCSelection = false;
            
        }

        console.log('test update 2');
        console.log('applicant details in KYC2:', JSON.stringify(this.applicant));
        console.log('show options' + event.target.dataset.id);

    }

    resetKYC() {
        this.KYCSelection = true;
        this.KYCScreen = false;
    }

    updateApplicantRecord(event){
        console.log('updating applicant');
        this.applicant = event.detail.applicant;
        console.log('updated: ', JSON.stringify(this.applicant));
    }

    getApplicantTypeName(event){
        console.log('getting applicantType');
        this.applicantType = event.detail.applicantType;
        console.log('applicantType: ', JSON.stringify(this.applicantType));
    }

    @api 
    nextHandler() {
        console.log('checking status: ', this.applicant.KYC_Status__c);
        if(this.apiIssue){
            this.showError("", 'Aadhaar Vault Service ' + this.Generic_API_Error, "error");
        }else if(this.applicant.KYC_Status__c == 'Complete' || (this.applicantType == 'Aadhaar - Physical Document' || this.applicantType == 'Aadhaar - Smartphone KYC')){
            if(this.applicant.KYC_Status__c == 'Complete'){
                this.returnToParent();
            }else if(this.consent){
                this.verifyKYC();
            }else{
                this.showError('Info', 'Please select consent');
            }
        }
        else if(this.applicant.Aadhaar_Number__c){ // added as a part of Bug-2439
            this.showError('Info', kycNotVerifiedErrorMessage); //SFAU-1979
        }
        else{
            this.returnToParent(); // added as a part of Bug-2439
        }

        console.log('otp method');
    }

    verifyKYC(){
        verifyKYC({ applicantId: this.applicantId })
            .then(result => {
                this.applicant.KYC_Status__c = 'Complete';
                this.applicant.KYC_Type__c = this.applicantType;

                this.returnToParent();
            })
            .catch(error => {
                this.error = error;
            });
    }

     validationCheck() {
        this.getApplicantData();
    }

    returnToParent() {
        console.log('returning to parent', JSON.stringify(this.applicant));
        //'next': this.KYCScreen && this.consent,
        let returnObj = {
            'next': true,
            'applicantRecord': this.applicant,
            'error': ''
        }

        console.log('return: ', returnObj);
        this.dispatchEvent(new CustomEvent('next', {
            detail: returnObj
        }));

    }

    showError(variant, error) {
        console.log('show error', error);
        this.dispatchEvent(
            new ShowToastEvent({
                title: '',
                message: error,
                variant: variant,
            }),
        );
    }

    apiIssue = false;
    handleconsent(event){
        this.consent = event.detail.consent;
        this.apiIssue = event.detail.apiIssue;
    }
}