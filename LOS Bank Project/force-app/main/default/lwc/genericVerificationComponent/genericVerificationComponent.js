import { LightningElement, api, track } from 'lwc';
import adharKychMethod from '@salesforce/apex/LOSAdharKycController.adharKychMethod';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getAadhaarNum from '@salesforce/apex/LOSAdharKycController.getAadhaarNum';

export default class genericVerificationComponent extends NavigationMixin(LightningElement) {
    @api progressValue;
    @api applicant;
    value = 'inProgress';
    @api aadhaarNumber;
    loanApplicationId = '';
    msterRecordName = '';
    boolCheckaadhaarNumber = false;
    enterOTPValue = ''
    isEnterOtp = false;
    @api isVerified;
    boolResendButton = false;
    boolRequestOtp = false;
    boolSendOtp = true;
    boolVerify = false;
    increse1Second = 117;
    @api consent;
    isloading;
    @track aadhaarNumberOnUi;

   async connectedCallback(){
        console.log('verified: ', this.isVerified);
        if(this.isVerified){
            this.boolSendOtp = false;
            this.boolCheckaadhaarNumber = true;
        }else{
            this.boolSendOtp = true;
            this.boolCheckaadhaarNumber = false;
        }
    //    let getAadhaarNumberByToken = await getAadhaarNum({applicationId: this.applicant.Id, aadhaaarToken : this.aadhaarNumber });
        let result = await getAadhaarNum({applicationId: this.applicant.Id, aadhaaarToken : this.aadhaarNumber });
        let responseVal = JSON.parse(result);
        if(responseVal != null && responseVal.additionalResponse != null) {
            this.aadhaarNumber = responseVal.additionalResponse;
            this.maskNumber();
        }else if(responseVal != null){ 
            let checklist = responseVal.checklistRecord;
            this.showToastEvent('Error', 'API Error: ' + checklist.Name + ' Response: ' + responseVal.statusCode + '- ' + responseVal.status , 'error');
            return;
        }
    }

    maskNumber() {
        let aadhaarNumber = this.aadhaarNumber;
        this.aadhaarNumberOnUi = aadhaarNumber.replace(/\d(?=\d{4})/g, '*');
        console.log('this.aadhaarNumberOnUi in mask-- '+this.aadhaarNumberOnUi);
    }

   /* unMaskNumber() {

        let aadhaarNumb = this.aadhaarNumberOnUi;

        if(aadhaarNumb.includes('*')) {      
            this.aadhaarNumberOnUi = this.aadhaarNumber;
        }
        else {
            this.maskNumber();
        }      
        console.log('this.aadhaarNumberOnUi in unmask-- '+ this.aadhaarNumberOnUi);
    }  */

    @api
    addCssTopreviewIcon() {
        let getPreviewIcon = this.template.querySelector(`[data-id="previewAadhaar"]`);
        getPreviewIcon.classList.add("afterSuccess");
        getPreviewIcon.classList.remove("previewIcon");
    }

    handleChange(event) {
        this.value = event.detail.value;
    }

    handleChangeOtpOptions(event) {
        this.value = event.detail.value;

    }

    handleResetAll() {
        this.template.querySelectorAll('lightning-input').forEach(Element => {
            Element.value = null;
        });

        this.template.querySelectorAll('lightning-combobox').forEach(Element => {
            Element.value = null;
        });

    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll(".validate");
        inputFields.forEach(inputField => {
            if (!inputField.value) {
                console.log('input fiel name ' + inputField.name)
                inputField.setCustomValidity("Complete this field");
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    handleSendOTP() {
        console.log('child comp consent: ',this.consent);
        if(!this.consent){
            this.showError('Warning','Please check consent before proceeding ahead');
            return;
        }

        this.boolRequestOtp = true;
        this.boolSendOtp = false;
        this.isEnterOtp = true;
        this.boolVerify = true;
        this.set27SecondTimer();
        this.adharKychMethod('Adhar - Generate OTP');
       // this.adharKychMethod('1234567890', '', 'Adhar - Generate OTP');
    }

    adharKychMethod(masterRecordName, transactionRefNo, Otp) {
        this.isloading = true;
        adharKychMethod({ adharNumber: this.aadhaarNumber, applicationId: this.applicant.Id, masterRecordName: masterRecordName, transactionRefNo: transactionRefNo, Otp: Otp })
            .then(result => {
                this.isloading = false;
                console.log('result of adharKychMethod is ' + JSON.stringify(result));
                if(masterRecordName == 'Adhar - Generate OTP') {
                    this.getTransactionRefNo(result);
                }
                else if(masterRecordName == 'Adhar - Validate OTP'){
                    this.adharValidate(result);                   
                }
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
                this.isloading = false;
                console.log("Error inside adharKychMethod");
            })
    }

    getTransactionRefNo(result) {
        let responseOfadharGenOtp = result;
        let parseResponse = JSON.parse(responseOfadharGenOtp);
        let data          = parseResponse.response_data.data;

        let decodedStringAtoB = atob(data);  // decoding the string into original format
        const parser = new DOMParser();
        const doc = parser.parseFromString(decodedStringAtoB, "text/xml");
        const errorNode = doc.querySelector("parsererror");
        if (errorNode) {
            console.log("Error while parsing String");
        } else {
            console.log(doc.documentElement.nodeName);
            let rootElement = doc.documentElement;
            this.transactionRefNo = rootElement.getAttribute("txn");
        }
    }

    adharValidate(result) {
        let parseValidateResp = JSON.parse(result);
        let status = parseValidateResp.status;

        if(status == "SUCCESS")  {           
            this.isVerified = true;
            this.boolSendOtp = false;
            let base64ImgData = parseValidateResp.Response.aadhaarimage;
            parseValidateResp.Response.aadhaarimage = "data:image/jpeg;base64," + base64ImgData;
            let objectToPass = {aadhaarNumber: this.aadhaarNumber, isVerified : this.isVerified, identifierDocuments : "true", adharValidateResponse  : parseValidateResp};
            const selectedEvent = new CustomEvent("progressvaluechange", {
                detail: objectToPass
            });
    
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
        }
        else { 
            let message = parseValidateResp.message;
            this.boolSendOtp = true;
            this.isEnterOtp  = true;                  
            this.showToastMessage("", message, "error", "sticky");
        }
    }

    handleResendOTP() {
        if(!this.consent){
            this.showError('Please check consent before proceeding ahead');
            return;
        }

        this.isEnterOtp = true;
        this.boolRequestOtp = true;
        this.boolResendOtp = false;
        this.boolVerify = true;
        this.set27SecondTimer();
        this.adharKychMethod('Adhar - Generate OTP');
       // this.mobileOtpVerificationHandler('Mobile Resend OTP');
    }

    handleVerify(event) {
        if(!this.consent){
            this.showError('Warning','Please check consent before proceeding ahead');
            return;
        }
      
        this.isEnterOtp = false;
        this.boolRequestOtp = false;
        this.boolResendOtp = false;
        this.boolSendOtp = false;
        this.progressValue = 'Approved';
        this.adharKychMethod('Adhar - Validate OTP', this.transactionRefNo, this.enterOTPValue);
        /* this.adharKychMethod('1234567890', '', 'Adhar - Validate OTP');
        // Creates the event with the data.
        console.log('aadhaar: ',this.aadhaarNumber);
        const selectedEvent = new CustomEvent("progressvaluechange", {
            detail: {
                status: 'Approved',
                aadhaarNumber: this.aadhaarNumber,
                isVerified   : this.isVerified,
                adharValidateResponse  : this.adharValidateResponse
            }
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);  */
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

    handleChangeNumber(event) {
        let inputField = this.template.querySelector(".mobilebutton");
        console.log('inputField ' + inputField.name);
        console.log('inputField.checkValidity() ' + inputField.checkValidity());
        if (event.target.name == 'Aadhaar_Number__c' && (event.target.value.length == 12 || event.target.value.length == 16) && inputField.checkValidity()) {
            this.aadhaarNumber = event.target.value;
            this.boolCheckaadhaarNumber = false;
            this.boolSendOtp = true;
        } else {
            this.boolCheckaadhaarNumber = true;
            this.isEnterOtp = false;
            this.boolRequestOtp = false;
            this.boolResendOtp = false;
            this.isVerified = false;
        }
        this.boolVerify = true;
    }

    set27SecondTimer() {
        this.increse1Second = 117;
        const secondTimeInterval = setInterval(() => {
            this.increse1Second -= 1;
        }, 1000);
        setTimeout(() => {
            if (!this.isVerified) {
                this.boolRequestOtp = false;
                this.boolResendOtp = true;
            }
            window.clearInterval(secondTimeInterval);

        }, 117000);
    }

    showError(variant, error){
        console.log('show error', error);
        this.dispatchEvent(
            new ShowToastEvent({
                title: '',
                message: error,
                variant: variant,
            }),
        );
    }

    showToastMessage(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            mode: mode,
            message: message
        });
        this.dispatchEvent(event);
    }

      isCheckValidity() {
        console.log('in isCheckValid method');
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.checkValidity');
        console.log('fields: ', inputFields);
        for (let inputField of inputFields) {
            if (!inputField.checkValidity()) {
                console.log('input fiel name ' + inputField.name)
                inputField.reportValidity();
                isValid = false;
            } else {
                inputField.setCustomValidity("");
                inputField.reportValidity();
            }
        };
        return isValid;
    }
}