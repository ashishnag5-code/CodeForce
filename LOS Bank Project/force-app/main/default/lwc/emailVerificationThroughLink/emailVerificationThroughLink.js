import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import OtpDurationLabel from '@salesforce/label/c.AUSF_RESEND_OTP_DURATION';
import getApplicantAddress from '@salesforce/apex/EmailVerificationThroughLinkControiller.getApplicantAddress';
import emailOtpVerificationHandler from '@salesforce/apex/EmailVerificationThroughLinkControiller.emailOtpVerificationHandler';
import saveVerifiedEmailStatus from '@salesforce/apex/EmailVerificationThroughLinkControiller.saveVerifiedEmailStatus';

export default class EmailVerificationThroughLink extends LightningElement {

    @api   recordId;
    @track addressRec;

    isApplicantEmailId = "";
    isloading        = false;
    isValueUpdated   = false;
    isInTimeInterval = false;
    isVerified       = false;
    isEnterOtp       = false;
    boolResendOtp    = false;
    boolRequestOtp   = false;
    boolSendOtp      = true;
    mobileNumber     = ''; 
    boolCheckMobileNumber = false;
    boolVerify = true;
    oldMobileNumberValue;
    loanApplicationRecord = {};
    increse1Second;
    emailId;
    enterOTPValue;
    requestId;

    @wire(getApplicantAddress, {applcntId : '$recordId', addressType : 'Office' }) 
    wiredApplicant({ error, data }) {
            if (data) {
                this.addressRec = data[0];
                this.emailId      = data[0].Office_Email_address__c;
                let officeEmailVerificationStatus = data[0].Office_Email_Verification_Status__c;
                this.isApplicantEmailId = data[0].Office_Email_address__c;
                if(officeEmailVerificationStatus == "Verified") {
                    this.isVerified = true;
                    this.boolSendOtp = false;
                }
                this.error = undefined;
            } else if (error) {
                this.error = error;
                this.addressRec = undefined;
                console.log('Error inside wiredApplicant  '+ error);
            }
    }

    validatePhoneNumber(input_str) {
        var re = /^[6-9]{1}[0-9]{9}/;
        return re.test(input_str);
    }

    makeParamsforEmailOtp() {
        let generateOtpEmailObj = {};
        generateOtpEmailObj.applcntId        = this.recordId;
        generateOtpEmailObj.emailId          = this.emailId; 
        generateOtpEmailObj.masterRecordName = 'Generate OTP For Email';
        this.emailOtpVerificationHandler(generateOtpEmailObj);
    }

    handleSendOTP() {
        this.boolRequestOtp = true;
        this.boolSendOtp = false;
        this.isEnterOtp = true;
        this.set27SecondTimer();
        this.makeParamsforEmailOtp();
    }

    handleResendOTP() {
        this.isEnterOtp = true;
        this.boolRequestOtp = true;
        this.boolResendOtp = false;
        this.set27SecondTimer();
        this.makeParamsforEmailOtp();
    }

    handleVerify() {
        this.isloading = true;
        this.boolRequestOtp = false;
        this.boolSendOtp = false;
        let paramsObj    = {};
        paramsObj.enterOTPValue    = this.enterOTPValue;
        paramsObj.reqId            = this.requestId;
        paramsObj.applcntId        = this.recordId;
        paramsObj.masterRecordName = "Verify OTP For Email"; 
        this.emailOtpVerificationHandler(paramsObj);
    }

    set27SecondTimer() {
        this.isInTimeInterval = true;
        this.increse1Second = OtpDurationLabel;
        const secondTimeInterval = setInterval(() => {
            this.increse1Second -= 1;
        }, 1000);
        setTimeout(() => {
            if (!this.isVerified && this.isInTimeInterval) {
                this.boolRequestOtp = false;
                this.boolResendOtp = true;
            }
            window.clearInterval(secondTimeInterval);

        }, OtpDurationLabel * 1000);
    }

    emailOtpVerificationHandler(generateOtpEmailObj) {
        
        emailOtpVerificationHandler({ params : generateOtpEmailObj })
            .then(result => {
                if (result != null) {
                    let response = result;
                    if(generateOtpEmailObj.masterRecordName == 'Generate OTP For Email') {
                        this.requestId  = response.requestId;
                    }
                    if (generateOtpEmailObj.masterRecordName == 'Verify OTP For Email') {
                        if (response.statusCode != 101) {
                            this.isVerified = false;
                            this.isEnterOtp = true;
                            this.boolRequestOtp = false;
                            this.boolSendOtp = false;                            
                            this.boolVerify = true;
                            this.showToastMessage("",response.result.message, "error", "sticky");
                        }
                        else if (response.statusCode == 101) {
                            this.isVerified       = true;
                            this.boolResendOtp    = false;
                            this.isEnterOtp       = false;                          
                            this.reportOtpVerficationValidity("");
                            this.saveVerifiedEmail("Verified");
                        }
                    }
                }

                this.isloading = false;
                this.error = undefined;
            })
            .catch(error => {
                this.isloading = false;
                this.error = error;
            })
    }

    saveVerifiedEmail(isVerify) {
        saveVerifiedEmailStatus({ verify : isVerify, addressRec : this.addressRec })
            .then((result) => {
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                console.log("Error inside saveVerifiedEmailStatus" + error);
            });
    }

    reportOtpVerficationValidity(message) {
        let inputField = this.template.querySelector("lightning-input[data-id='emailInput']");
        inputField.setCustomValidity(message);
        inputField.reportValidity();
    }

    handleChangeOtp(event) {
        let isOTPValid = this.isCheckValidity();
        if (event.detail.value.length == 6 && isOTPValid) {
            this.enterOTPValue = event.detail.value;
            this.boolVerify = false;
        }
        else {
            this.boolVerify = true;
        }
    }

    isCheckValidity() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.checkValidity');
        for (let inputField of inputFields) {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            } else {
                inputField.setCustomValidity("");
                inputField.reportValidity();
            }
        };
        return isValid;
    }

    showToastMessage(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            mode: mode,
            message: message,
        });
        this.dispatchEvent(event);
    }
}