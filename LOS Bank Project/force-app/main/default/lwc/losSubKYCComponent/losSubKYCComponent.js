import { LightningElement, api, track } from 'lwc';
import biometric from '@salesforce/resourceUrl/biometricKYC';
import smartphone from '@salesforce/resourceUrl/smartphoneKYC';
import osv from '@salesforce/resourceUrl/osvKYC';
import otp from '@salesforce/resourceUrl/otpKYC';
import ckyc from '@salesforce/resourceUrl/ckyc';
import ckycVerified from '@salesforce/resourceUrl/ckycVerified';

import physicalV from '@salesforce/resourceUrl/phyicalVerified';
import smartV from '@salesforce/resourceUrl/smartV';
import otpVerified from '@salesforce/resourceUrl/otpVerified';
import biometricV from '@salesforce/resourceUrl/biometricV';


import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import fetchDocChkLstId from '@salesforce/apex/LosSubKycController.getDocumentChecklistId';
import validateRecordEdit from '@salesforce/apex/ComponentProfileRestrictionController.validateRecordEdit';


export default class LosSubKYCComponent extends LightningElement {

    biometric = biometric;
    smartphone = smartphone;
    osv = osv;
    otp = otp;
    ckyc = ckyc;
    physicalV = physicalV;
    smartV = smartV;
    otpVerified = otpVerified;
    biometricV = biometricV;
    ckycVerified = ckycVerified;
    // biometricVerified = kycverified + '/biometic.png';
    // otpVerified = kycverified + '/otp.png';
    // smartPhoneKYCVerified = kycverified +'/smartkyc.png';
    // ckycVerified = kycverified + '/ckyc.png';
    // physicalKYCVerified = kycverified + '/physical.png';
    
    showKYCSubType = true;
    validateOTP;
    biometricKYC;
    smartphoneKYC;
    osvKYC;
    isCKYC;

    aadhaarVerificationType;

    @api applicant;
    @api spinnerImage;
    docChkLstId;
    isloading = true;
    isIndividual = true;
    isAadharPresent = false; //Added as a part of Bug-2439
    @track blnRestrictEdit = false;
    @track blnGoNext = false;
    
    connectedCallback() {
        console.log(this.biometric + '-' + this.smartphone + '-' + this.osv + '-'  + this.otp + '-' + this.ckyc);
        console.log(this.biometricVerified + '-' + this.otpVerified + '-' + this.smartPhoneKYCVerified + '-'  + this.ckycVerified + '-' + this.physicalKYCVerified);
        console.log('KYC Subtype component called: ', JSON.stringify(this.applicant));
        //Below code added as a part of Bug-2439		
	    if(this.applicant?.Aadhaar_Number__c){		
    	    this.isAadharPresent = true;		
    	}		
    	else{		
    	    this.isAadharPresent = false;		
    	}
        this.fetchDocChkLst();
        this.setIcons();
        this.checkRestrictRecord ();
        
        
        
    }

    /*
    @description - to check login user have access to edit record
    */
    checkRestrictRecord () {
        validateRecordEdit({
            compName: 'ausfb_customerDetailComponent' ,recordId: this.applicant.Id
            }).then(data => {
                if (data) {
                    this.blnRestrictEdit = data.blnRestrictEdit;
                    this.blnGoNext = data.blnMoveNext;
                }
            }).catch(error => {
                console.log('error is ' + JSON.stringify(error));
            })
    }

    /*
    @description - show restrict message
    */
    restrictAccessMessage () {
        const evt = new ShowToastEvent({
            title: 'Access Restricted',
            message: 'You do not have access to change KYC details',
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }

    setIcons(){
        let kycType = this.applicant.KYC_Type__c;
        switch(kycType){
            case 'Aadhaar - Biometric':
                this.biometric = this.biometricV;
                break;
            case 'Aadhaar - OTP':
                this.otp = this.otpVerified;
                break;
            case 'Aadhaar - Physical Document':
                this.osv = this.physicalV;
                break;
            case 'Aadhaar - Smartphone KYC':
                this.smartphone = this.smartV;
                break;
            case 'CBS':
                console.log("CBS");
                break;
            case 'CKYC':
                this.ckyc = this.ckycVerified;
                break;                    
            default:
                console.log("kycType is --" + kycType);
        }
    }

    validationCheck(evt) {
        const selectedEvent = new CustomEvent("fireupagain", {
            detail: {
                 kycUpdate : true,
             }
           }); 
         this.dispatchEvent(selectedEvent);
    }

    fetchDocChkLst() {
        fetchDocChkLstId({
            applicantId: this.applicant.Id
        })
            .then(result => {
                console.log('docChkLstId is ' + result);
                if (result != null) {
                    this.docChkLstId = result;
                }
                this.isloading = false;
            })
            .catch(error => {
                this.error = error;
                this.isloading = false;
            });
    }

    showKYCOptions(event) {
        console.log('back to main menu');
        this.dispatchEvent(new CustomEvent('kycselection'));
    }

    handleChangeKYCOptions(event) {

        if (this.blnRestrictEdit == true) {
            this.restrictAccessMessage ();
        }
        else {

            this.isloading = true;
            this.aadhaarVerificationType = event.target.dataset.id;
            console.log('Type:' + this.aadhaarVerificationType);

            if (this.aadhaarVerificationType == 'Aadhaar - Biometric') {
                console.log('biometric');
                //this.showError('Info', 'Biometric is currently unavailable, Please proceed with other options');
                //return;
                this.validateOTP = false;
                this.smartPhoneKYC = false;
                this.osvKYC = false;
                this.biometricKYC = true;
            }

            if (this.applicant.KYC_Type__c && this.applicant.KYC_Type__c != this.aadhaarVerificationType && this.applicant.KYC_Status__c == 'Complete') {
                console.log('already done');
                this.showError('Info', 'Aadhaar verification is already completed');
                this.isloading = false;
                return;
            }

            this.showKYCSubType = false;
            if (this.aadhaarVerificationType == 'Aadhaar - OTP') {
                this.validateOTP = true;
                this.smartPhoneKYC = false;
                this.osvKYC = false;
                this.biometricKYC = false;
            } else if (this.aadhaarVerificationType == 'Aadhaar - Physical Document') {
                this.osvKYC = true;
                this.validateOTP = false;
                this.smartPhoneKYC = false;
                this.biometricKYC = false;
            } else if (this.aadhaarVerificationType == 'Aadhaar - Smartphone KYC') {
                this.smartPhoneKYC = true;
                this.validateOTP = false;
                this.biometricKYC = false;
                this.osvKYC = false;
            } 
            else if (this.aadhaarVerificationType == 'CKYC') {
                this.isCKYC = true;
            } 
            this.getApplicantTypeName();
            this.isloading = false;
            /*else if (this.aadhaarVerificationType == 'Biometric') {
            this.biometric = true;
        }*/
        }
    }

    /*
    restrictAadhaarOptionSwitch(value){
        if(this.applicant.KYC_Type__c && this.applicant.KYC_Type__c != value && this.applicant.KYC_Status__c == 'Complete'){
            this.showError('Info', 'Aadhaar verification is already completed using '+this.aadhaarVerificationType+' KYC');
            return;
        }
    }*/

    resetOptions() {
        this.validateOTP = false;
        this.smartPhoneKYC = false;
        this.osvKYC = false;
        this.biometricKYC = false;
        this.isCKYC = false;
    }

    showSubTypeKYC() {
        this.resetOptions();
        this.showKYCSubType = true;
    }

    updateApplicantRecord(event) {
        this.applicant = event.detail.applicant;
        this.dispatchEvent(new CustomEvent('updateapplicant', {
            detail: {
                'applicant': this.applicant
            }
        }));
    }

    getApplicantTypeName(event) {
        console.log('Applicant Type in child',this.aadhaarVerificationType);
        this.dispatchEvent(new CustomEvent('getapplicanttype', {
            detail: {
                'applicantType': this.aadhaarVerificationType
            }
        }));
    }

    @api
    returnApplicant() {
        return this.applicant;
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

    handleconsentchange(event){
        const consentEvent = new CustomEvent('consentchange', {
            detail: {
                'consent': event.detail.consent,
                'apiIssue': event.detail.apiIssue

            }
        });
        this.dispatchEvent(consentEvent);
    }
    


}