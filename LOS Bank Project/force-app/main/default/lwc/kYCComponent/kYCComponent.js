import { LightningElement, track,api } from 'lwc';
import mobileOtpVerificationHandler from '@salesforce/apex/LOSMobileOtpController.mobileOtpVerificationHandler';
import { getRecord, getFieldValue,createRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import {loadStyle} from 'lightning/platformResourceLoader';
import { getObjectInfo,getPicklistValues,getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LOANAPPLICATION_OBJECT from '@salesforce/schema/Applicant__c';
//import ADHARCARD_FIELD from '@salesforce/schema/Applicant__c.Aadhaar_Number__c';

export default class genericVerificationComponent extends NavigationMixin(LightningElement) {
    @api progressValue;
    @api inputLabel ='Mobile Nunber';
    @track value = 'inProgress';
    @track mobileNumber='';
    selectedCountryCountryCodeLength=3;
    boolCheckMobileNumber=true;
    enterOTPValue =''
    currentStep = '1';
   @api kyctype ='';
    isEnterOtp = false;
    loanApplicationRecord = {};
     typeOfVerification = false;
     typeOfMobileotp = false;
    @track isVerified = false;
    @track boolResendOtp = false;
    boolResendButton = false;
    boolRequestOtp = false;
    boolSendOtp = true;
    @track isVerifiedNumber=false;;
    @track boolIsDisableVerifyButton = true;
    @track increse1Second=27;
    @track otpVerified = false;
    @track boolVerify = true;
    @track oldMobileNumberValue
    @track isReadOnly = false;

connectedCallback() {
    if(this.kyctype = 'Mobile'){
    this.typeOfVerification = true;
    }else if(this.kyctype = 'test'){
        this.typeOfMobileotp = true;
    }
}

handleChange(event) {
        this.value = event.detail.value;
        console.log('valuee----'+this.value);
     }
     handleChangeOtpOptions(event) {
        this.value = event.detail.value;
        console.log('valuee----'+this.value);
       
     }
    
    
        handleResetAll(){
            this.template.querySelectorAll('lightning-input').forEach(Element =>{
                Element.value = null;
            });
    
            this.template.querySelectorAll('lightning-combobox').forEach(Element =>{
                Element.value = null;
            });
    
        }
    
        isInputValid(){
            let isValid = true;
            let inputFields = this.template.querySelectorAll(".validate");
            inputFields.forEach(inputField =>{
                if(!inputField.value){
                    console.log('input fiel name '+inputField.name)
                    inputField.setCustomValidity("Complete this field");
                    inputField.reportValidity();
                    isValid = false;
                }
            });
            return isValid;
        }
    
        handleSendOTP(){
            this.boolRequestOtp = true;
            this.boolSendOtp = false;
            this.isEnterOtp = true;
            //this.boolVerify=true;
            this.set27SecondTimer();
            this.mobileOtpVerificationHandler('Mobile Generate OTP');
        }
        mobileOtpVerificationHandler(masterRecordName){

        mobileOtpVerificationHandler({ mobileNumber: this.mobileNumber, otp: this.enterOTPValue, loanApplicationId: '',otpValue: masterRecordName})
		.then(result => {
			console.log('result is '+result)
			this.error = undefined;
		})
		.catch(error => {
			this.error = error;
			//this.accounts = undefined;
		})
    }
        handleResendOTP(){
            //this.boolIsDisableVerifyButton = false;
            
            this.isEnterOtp = true;
            this.boolRequestOtp = true;
            this.boolResendOtp = false;
            //this.boolVerify=true;
            this.set27SecondTimer();
            this.mobileOtpVerificationHandler('Mobile Resend OTP');
        }
    
        handleVerify(event){
            this.isVerified = true;
            this.isEnterOtp = false;
            this.boolRequestOtp = false;
            this.boolResendOtp = false;
            this.boolSendOtp = false;
            this.isVerifiedNumber = true;
            this.oldMobileNumberValue =this.mobileNumber;
            this.progressValue = 'Approved';
            this.inputLabel ='Adhar Number';
            this.mobileOtpVerificationHandler('Mobile Validate OTP');
        // Creates the event with the data.
        const selectedEvent = new CustomEvent("progressvaluechange", {
          detail: this.progressValue
        });
    
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        }
    
        handleChangeOtp(event){
            if(event.detail.value.length == 6 ){
                this.enterOTPValue = event.detail.value;
                this.boolVerify=false;
            }
            else{
                this.boolVerify=true;
            }
            //this.checkDisableTermCondition();
        }
     
        handleChangePhoneNumber(event){
            let inputField = this.template.querySelector(".mobilebutton");
            console.log('inputField '+inputField.name);
            console.log('inputField.checkValidity() '+inputField.checkValidity());
            if(this.oldMobileNumberValue ===event.target.value && this.isVerifiedNumber){
                this.isVerified = true;
                this.isEnterOtp = false;
                this.boolRequestOtp = false;
                this.boolResendOtp = false;
                this.boolSendOtp = false;
            }else{
                if(event.target.name=='Aadhaar_Number__c' && event.target.value.length == 10 && inputField.checkValidity()){
                    this.loanApplicationRecord[event.target.name] =event.target.value;
                    this.mobileNumber = event.target.value;
                    this.boolCheckMobileNumber = false;
                    this.boolSendOtp = true;
                } else{
                    this.boolCheckMobileNumber = true;
                    this.isEnterOtp = false;
                    this.boolRequestOtp = false;
                    this.boolResendOtp = false;
                    this.isVerified=false;
                }
            }
            this.boolVerify=true;
            //this.checkDisableTermCondition();
        }
    
        set27SecondTimer(){
            this.increse1Second=27;
            const secondTimeInterval =   setInterval(() => {
                this.increse1Second -= 1;                            
             }, 1000);
            setTimeout(()=> {
                if(!this.isVerified){
                    this.boolRequestOtp = false;
                    this.boolResendOtp = true;
                    //this.boolVerify = false;
                }
                window.clearInterval(secondTimeInterval);
                
            }, 27000);
        }
    
       
    
        createLead() {
    
            if (this.isInputValid() && this.isVerified) {
                console.log('in create method');
            this.isloading = true;
            //if(!this.stageOptionsValue){
                this.loanApplicationRecord['Stage__c'] ='QDE';
            //}
            
            const fields = this.loanApplicationRecord;
            const recordInput = { apiName: LOANAPPLICATION_OBJECT.objectApiName, fields };
            createRecord(recordInput)
                .then(account => {
                    console.log('account '+JSON.stringify(account));
                    this.handleResetAll();
                    this.isloading = false;
                    this.isVerified = false;
                    this.isVerifiedNumber = false;
                    this.oldMobileNumberValue = '';
                    //Navigate to record page

    
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Lead created',
                            variant: 'success',
                        }),
                    );
                })
                .catch(error => {
    
                    this.isloading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });
    
            } else {
                if(!this.isVerified){
                    if(this.boolCheckMobileNumber){
                        let inputField = this.template.querySelector(".mobileButton");
                        inputField.checkValidity();
                    }
                }
            }
        }
    
    }