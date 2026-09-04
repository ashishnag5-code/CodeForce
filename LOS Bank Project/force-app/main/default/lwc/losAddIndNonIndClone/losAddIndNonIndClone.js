import { LightningElement, track, wire, api } from 'lwc';
import { updateRecord, createRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import APPLICANT_OBJECT from '@salesforce/schema/Applicant__c';
import { loadStyle } from 'lightning/platformResourceLoader';
import maskedCss from '@salesforce/resourceUrl/masked';
import OtpDurationLabel from '@salesforce/label/c.AUSF_RESEND_OTP_DURATION';
import mobileOtpVerificationHandler from '@salesforce/apex/LOSMobileOtpController.mobileOtpVerificationHandler';
import checkMandatoryDocuments from '@salesforce/apex/Ausfb_RelatedApplicantController.checkMandatoryDocuments';
import getApplicantRecord from '@salesforce/apex/LosQuickLoanController.getApplicant';
import FORM_FACTOR from '@salesforce/client/formFactor';
import updateOCRDate from '@salesforce/apex/LOSDocumentUploadController.updateOCRData';
import getVersionFilesRec from '@salesforce/apex/LOSDocumentUploadController.getVersionFiles';

export default class LosAddIndNonIndClone extends NavigationMixin(LightningElement) {
    @api recordId;
    @api applicantId ="a006s000002Ney2AAC";
    @api sObjectName;
    @track pancardForm16PicklistValues;
    @api appCount;
    pancardForm16OptionsValue = '';
    isEnabledPanCard = false;
    isEnabledVoterId = false;
    isEnabledDrivingLicence = false;
    isEnabledPassport = false;
    @track ApplicantRecord = {};
    AdditionalInformationvalue = {};
    errorOnChild = false;
    showPreview = true;
    mask = true;
    addNewApplicant = false;
    appRecTypes = [];
    appRecTypeVal = '';
    @track mobileNumber = '';
    /* OTP Verification variable */
    @track isVerified = false;
    @track boolResendOtp = false;
    boolRequestOtp = false;
    boolSendOtp = true;
    @track isVerifiedNumber = false;
    @track boolIsDisableVerifyButton = true;
    @track otpVerified = false;
    @track boolVerify = true;
    @track oldMobileNumberValue;
    @track isReadOnly = false;
    @track increse1Second;
    boolCheckMobileNumber = true;
    enterOTPValue = '';
    isEnterOtp = false;
    isPanMandatory = false;
    isMobile;
    trueValue =true;
    falseValue =false;
    @track docName;
    eventdocName;
    @track showUploadComponent = false;
    @track showOCRDetails=false;
    @track dataValues = [];
    @track modelNeeded =true;
    applicantRec;
    documentChkRecord;
    isAadhar;
    contentVersionId;
    documentNumber;
    documentIdsMap=[];
    AdditionalInformationoptions = [
        { label: 'VoterId', value: 'VoterId' },
        { label: 'Driving Licence', value: 'Driving Licence' },
        { label: 'Passport', value: 'Passport' },
    ];
    @track allAdditionalInformationvalues = [];
    isShowAdditionalInformationsPicklist = false;


    @track objectInfo;

    @wire(getObjectInfo, { objectApiName: APPLICANT_OBJECT })
    objectInfo;

    GetrecordTypeInfo() {
        // Returns a map of record type Ids 
        const rtis = this.objectInfo.data.recordTypeInfos;
        Object.keys(rtis).forEach(element => {
            console.log('RT Id', rtis[element].recordTypeId);
            console.log('RT Name', rtis[element].name);
            console.log('App Count', this.appCount);
            
            if ((this.appCount == 0 && rtis[element].name == 'Applicant') || rtis[element].name == 'Co-Applicant' || rtis[element].name == 'Guarantor') {
                this.appRecTypes.push({ label: rtis[element].name, value: rtis[element].recordTypeId });
            }
        });
    }


    handleApplicantType(event) {
        this.appRecTypeVal = event.target.value;
        console.log('appRecTypeVal', this.appRecTypeVal);
        this.checkMandatoryDocuments(this.recordId);
    }




    handleSendOTP() {
        this.boolRequestOtp = true;
        this.boolSendOtp = false;
        this.isEnterOtp = true;
        this.set27SecondTimer();

        this.mobileOtpVerificationHandler('Mobile Generate OTP');

    }

    mobileOtpVerificationHandler(masterRecordName) {

        mobileOtpVerificationHandler({ mobileNumber: this.mobileNumber, otp: this.enterOTPValue, loanApplicationId: '', otpValue: masterRecordName })
            .then(result => {
                console.log('result is ' + result);
                if (result != null) {
                    let response = JSON.parse(result);
                    if (masterRecordName == 'Mobile Validate OTP') {
                        console.log('result status is ' + response.RequestStatus);
                        if (response.RequestStatus == 'Failed') {
                            this.isVerified = false;
                            this.isEnterOtp = true;
                            this.boolRequestOtp = false;
                            //this.boolResendOtp = false;
                            this.boolSendOtp = false;
                            this.isVerifiedNumber = false;
                            this.boolVerify = true;
                        }
                        else if (response.RequestStatus == 'Success') {
                            this.isVerified = true;
                            this.boolResendOtp = false;
                            this.isloading = true;
                            this.isEnterOtp = false;
                            this.isVerifiedNumber = true;
                            this.reportOtpVerficationValidity("");

                        }

                    }
                }

                this.isloading = false;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
            })
    }

    handleResendOTP() {
        this.isEnterOtp = true;
        this.boolRequestOtp = true;
        this.boolResendOtp = false;
        this.set27SecondTimer();
        this.mobileOtpVerificationHandler('Mobile Resend OTP');
    }

    handleVerify() {
        this.isloading = true;
        this.isEnterOtp = false;
        this.boolRequestOtp = false;
        this.boolResendOtp = false;
        this.boolSendOtp = false;
        this.oldMobileNumberValue = this.mobileNumber;
        this.mobileOtpVerificationHandler('Mobile Validate OTP');
    }

    handleChangeOtp(event) {
        if (event.detail.value.length == 6) {
            this.enterOTPValue = event.detail.value;
            this.boolVerify = false;
        }
        else {
            this.boolVerify = true;
        }
    }
     // Commenting to avoid duplicate method
    // handleChangePhoneNumber(event) {
    //     this.isInTimeInterval = false;
    //     let inputField = this.template.querySelector(".mobilebutton");
    //     console.log('inputField ' + inputField.name);
    //     console.log('inputField.checkValidity() ' + inputField.checkValidity());
    //     if (this.oldMobileNumberValue === event.target.value && this.isVerifiedNumber) {
    //         this.isVerified = true;
    //         this.isEnterOtp = false;
    //         this.boolRequestOtp = false;
    //         this.boolResendOtp = false;
    //         this.boolSendOtp = false;
    //     } else {
    //         if (event.target.name == 'Mobile__c' && event.target.value.length == 10 && this.validatePhoneNumber(event.target.value)) {
    //             this.loanApplicationRecord[event.target.name] = event.target.value;
    //             this.mobileNumber = event.target.value;
    //             this.boolCheckMobileNumber = false;
    //             this.boolSendOtp = true;
    //         } else {
    //             this.boolCheckMobileNumber = true;
    //             this.isEnterOtp = false;
    //             this.boolRequestOtp = false;
    //             this.boolResendOtp = false;
    //             this.isVerified = false;
    //         }
    //     }
    //     this.boolVerify = true;
    // }

    set27SecondTimer() {
        this.isInTimeInterval = true;
        this.increse1Second = OtpDurationLabel;
        const secondTimeInterval = setInterval(() => {
            this.increse1Second -= 1;
        }, 1000);
        setTimeout(() => {
            if (!this.isVerified && this.isInTimeInterval) {
                this.boolRequestOtp = false;
                this.boolResendOtp =  true;
            }
            window.clearInterval(secondTimeInterval);

        }, OtpDurationLabel * 1000);
    }



    validatePhoneNumber(input_str) {
        var re = /^[6-9]{1}[0-9]{9}/;
        console.log('Valid Phone Number', re.test(input_str));
        return re.test(input_str);
    }

    handleChangePhoneNumber(event) {
        let inputField = this.template.querySelector(".mobilebutton");
        console.log('inputField ' + inputField.name);
        console.log('inputField.checkValidity() ' + inputField.checkValidity());
        
        // R2-2403 Start 	
        if(this.recordTypeName == 'Guarantor' && this.applicantLst){//SFAU-4038
            for(let element of this.applicantLst){
                if(element.Mobile_Number__c == event.target.value){ 
                    this.showToastEvent("", "Mobile can not be same under the current Application.", "error");	
                    return;
                }
            }
       }
       // R2-2403 End 	
        if (this.oldMobileNumberValue === event.target.value && this.isVerifiedNumber) {
            this.isVerified = true;
            this.isEnterOtp = false;
            this.boolRequestOtp = false;
            this.boolResendOtp = false;
            this.boolSendOtp = false;
        } else {
            console.log('event.target.name', event.target.name);
            if (event.target.name == 'Mobile_Number__c' && event.target.value.length == 10) {
                this.ApplicantRecord[event.target.name] = event.target.value;
                this.mobileNumber = event.target.value;
                this.boolCheckMobileNumber = false;
                this.boolSendOtp = true;
            } else {
                this.boolCheckMobileNumber = true;
                this.isEnterOtp = false;
                this.boolRequestOtp = false;
                this.boolResendOtp = false;
                this.isVerified = false;
            }
        }
        this.boolVerify = true;
    }

    

    @api nextHandler() {

        this.updateApplicant();
    }

    connectedCallback() {
        if(FORM_FACTOR=='Small'){
            this.isMobile = true;
            this.modelNeeded = false;
        }else{
            this.isMobile = false;
        }
        console.log('App Count', this.appCount);
        loadStyle(this, maskedCss);
        console.log('Connected Callback Add Ind SObj----->', this.sObjectName);
        if (this.sObjectName == 'Applicant__c') {
            this.applicantId = this.recordId;
        }
        if (!this.applicantId) {
            this.addNewApplicant = true;
            console.log('In Add New Applicant');
            console.log('Loan App Id In Add New Applicant', this.recordId);
            //this.GetrecordTypeInfo();
            this.checkMandatoryDocuments(this.recordId);
        }
        else {
            this.getApplicant();
            this.getVersionFiles();
        }
    }
    getApplicant() {
        console.log('this.applicantId', this.applicantId);
        console.log('this.recordId', this.recordId);
        getApplicantRecord({
            recId: this.applicantId
        })
            .then((object) => {
                if (object != null) {
                    console.log('object', object);
                    this.ApplicantRecord = object;
                }
            })
            .catch((error) => {
                this.error = error;
            });
    }
    getVersionFiles(){
        getVersionFilesRec({
            recordId: this.applicantId
        })
            .then((result) => {
                if (result != null) {
                    console.log('resultFile'+result);
                    console.log('resultJSON'+JSON.stringify(result));
                    for (var key in result) {
                        this.documentIdsMap.push({ key: key, value: result[key] });
                        let dataVlaue = '[data-id=\"'+key+'preview'+'\"]';
                        if(this.template.querySelector(dataVlaue)){
                            this.template.querySelector(dataVlaue).classList.remove('slds-hide');
                        }
                    }
                    console.log('this.documentIdsMap'+this.documentIdsMap);
                }
            })
            .catch((error) => {
                this.error = error;
            });
    }
    handlePreviewClick(event){
        console.log('PreviewCLick'+event.currentTarget.dataset.id);
        let dataValue = event.currentTarget.dataset.id.replace('preview', '');
        let contentDocumentId;
        this.documentIdsMap.forEach(function(value, key) {
            console.log(value['key'] + " = " +  value['value']);
            if(dataValue==value['key']){
                console.log('clickedValue'+value['value']);
                contentDocumentId = value['value'];
            }
        })
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                // assigning ContentDocumentId to show the preview of file
                selectedRecordId: contentDocumentId
            }
        })
    }
    handleMasking() {
        console.log('mask', this.mask);
        if (this.mask) {
            this.removeMasking();
        }
        else {
            this.addMasking();
        }
        this.mask = this.mask ? false : true;
    }

    removeMasking() {
        this.template.querySelector('.aadhaar').classList.remove('masked');
    }

    addMasking() {
        this.template.querySelector('.aadhaar').classList.add('masked');
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: APPLICANT_OBJECT, recordTypeId: '$objectInfo.data.defaultRecordTypeId' })
    allDataPicklistValues({ error, data }) {
        if (data) {
            console.log('data picklist' + JSON.stringify(data));
            this.pancardForm16PicklistValues = data.picklistFieldValues.Pan_Form60__c.values;
        } else if (error) {
            console.log('error is ' + JSON.stringify(error));
        }
    }

    handleValuChange(event) {
        const inputValue = event.target.value;
        /*
        if (event.target.name == 'Aadhaar_Number__c') {
            //this.ApplicantRecord[event.target.name] = event.target.value.toUpperCase();
            console.log('aadhaar value-->', inputValue);
            if (inputValue == '' || inputValue == null) {
                this.showPreview = false;
            }
            else {
                this.showPreview = true;
            }
            console.log('this.showPreview', this.showPreview);

        }
        */
        this.ApplicantRecord[event.target.name] = inputValue;
        this.isInputValid(event.target.name);
        this.isCheckValidity();


    }


    handlePancardForm16ValueChange(event) {
        console.log('event.detail.value', event.detail.value);
        console.log('event.target.value', event.target.value);
        this.pancardForm16OptionsValue = event.detail.value;
        this.ApplicantRecord[event.target.name] = event.target.value;
        if (event.target.value === 'Pan Card') {
            this.isEnabledPanCard = true;
        } else {
            this.isEnabledPanCard = false;
        }
        this.isInputValid(event.target.name);
    }

    handleAdditionalInformationClick() {
        console.log('this.isShowAdditionalInformationsPicklist', this.isShowAdditionalInformationsPicklist);
        this.isShowAdditionalInformationsPicklist = true;

    }
    handleAdditionalInformationChange(event) {


        if (!this.allAdditionalInformationvalues.includes(event.target.value)) {
            this.allAdditionalInformationvalues.push(event.target.value);
        }
        console.log('this.allAdditionalInformationvalues', this.allAdditionalInformationvalues);
        if (event.target.value === 'VoterId') {
            this.isEnabledVoterId = true;
        }
        else if (event.target.value === 'Driving Licence') {
            this.isEnabledDrivingLicence = true;
        }
        else if (event.target.value === 'Passport') {
            this.isEnabledPassport = true;
        }
        this.getVersionFiles();

    }

    handleRemove(event) {
        const valueRemoved = event.target.name;
        console.log('valueRemoved', valueRemoved);
        this.allAdditionalInformationvalues.splice(this.allAdditionalInformationvalues.indexOf(valueRemoved), 1);
        console.log('this.allAdditionalInformationvalues', this.allAdditionalInformationvalues);
        if (valueRemoved === 'VoterId') {
            this.isEnabledVoterId = false;
        }
        else if (valueRemoved === 'Driving Licence') {
            this.isEnabledDrivingLicence = false;
        }
        else if (valueRemoved === 'Passport') {
            this.isEnabledPassport = false;
        }

    }

    handleResetAll() {
        this.template.querySelectorAll('lightning-input').forEach(Element => {
            Element.value = null;
        });

        this.template.querySelectorAll('lightning-combobox').forEach(Element => {
            Element.value = null;
        });

    }


    isInputValid(inputFieldName) {
        let isValid = true;
        let inputFields = this.template.querySelectorAll(".validate");
        inputFields.forEach(inputField => {

            if (inputFieldName == '') {
                if (!inputField.value) {
                    console.log('input fiel name ' + inputField.name)
                    inputField.setCustomValidity("Complete this field");
                    inputField.reportValidity();
                    isValid = false;

                }
                else {
                    inputField.setCustomValidity("");
                    inputField.reportValidity();

                }
            }
            else {
                if (inputFieldName == inputField.name) {
                    if (!inputField.value) {
                        console.log('input fiel name ' + inputField.name)
                        inputField.setCustomValidity("Complete this field");
                        inputField.reportValidity();
                        isValid = false;

                    }
                    else {
                        inputField.setCustomValidity("");
                        inputField.reportValidity();

                    }

                }

            }
        });
        return isValid;
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

    updateApplicant() {

        console.log('in update method');
        if (this.isInputValid('') && this.isCheckValidity() ) {
            console.log('in update method');
            console.log('this.applicantId', this.applicantId);
            
            if (this.applicantId) {
                this.isloading = true;
                this.ApplicantRecord['Id'] = this.applicantId;
                const fields = this.ApplicantRecord;
                console.log('fields', fields);
                const recordInput = { fields };
                updateRecord(recordInput)
                    .then(applicant => {
                        console.log('applicant ' + JSON.stringify(applicant));
                        this.isloading = false;
                        //this.errorOnChild = (this.isInputValid('') && this.isCheckValid()) ? false : true;
                        const Obj = {};
                        Obj.applicantRecord = this.ApplicantRecord;
                        Obj.errorOnChild = this.errorOnChild;
                        Obj.next = this.errorOnChild ? false : true;
                        Obj.isPanMandatory = this.isPanMandatory;
                        console.log('Obj', Obj);

                        this.dispatchEvent(new CustomEvent('next', {
                            detail: Obj
                        }));
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
            }
            else {
                if(this.isVerified){
                    this.isloading = true;
                this.ApplicantRecord['RecordTypeId'] = this.appRecTypeVal;
                this.ApplicantRecord['Loan__c'] = this.recordId;
                const fields = this.ApplicantRecord;
                console.log('fields', fields);
                const recordInput = {
                    apiName: APPLICANT_OBJECT.objectApiName,
                    fields: fields
                };
                createRecord(recordInput)
                    .then(applicant => {
                        console.log('applicant ' + JSON.stringify(applicant));
                        this.isloading = false;
                       // this.errorOnChild = (this.isInputValid('') && this.isCheckValid()) ? false : true;
                        console.log('Id', applicant.id);
                        this.ApplicantRecord['Id'] = applicant.id;
                        const Obj = {};
                        Obj.applicantRecord = this.ApplicantRecord;
                        Obj.errorOnChild = this.errorOnChild;
                        Obj.next = this.errorOnChild ? false : true;
                        Obj.isPanMandatory = this.isPanMandatory;
                        console.log('Obj', Obj);

                        this.dispatchEvent(new CustomEvent('next', {
                            detail: Obj
                        }));
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

            }
            else{
            if (!this.isVerified) {
                console.log('Not verified');

                this.reportOtpVerficationValidity("Please generate and verify OTP");
            }
            }

        }

        

        }


    }


    checkMandatoryDocuments(RecId) {
        this.isPanMandatory = false;
        checkMandatoryDocuments({
            //recId: RecId
            recId: this.applicantId
        })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    data.forEach(rec => {
                        console.log('rec', rec);
                        console.log('this.appRecTypeVal', this.appRecTypeVal);
                        this.appRecTypes.forEach(recType => {
                            if (recType.label == rec.customerType) {
                                if (recType.value == this.appRecTypeVal) {
                                    this.isPanMandatory = rec.isPanRequired;
                                }
                            }
                        });
                    });

                }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
            })


    }


    reportOtpVerficationValidity(message) {
        let inputField = this.template.querySelector(".mobilebutton");
        console.log('inputField ' + inputField.name);
        inputField.setCustomValidity(message);
        inputField.reportValidity();
    }
    hanldeOcrClick(event){
        console.log('clickButton'+event.currentTarget.dataset.name);
        //alert('OCRBUTTONCLICK'+event.currentTarget.dataset.name);
        this.template.querySelector("c-los-generic-document-upload").handleOCRClickParent();
    }
    hanldeUploadClick(event){
        this.docName = event.currentTarget.dataset.name;
        this.showUploadComponent = false;
        console.log('uploadValue'+event.currentTarget.dataset.name);
        setTimeout(() => {
            this.showUploadComponent = true;
       }, 500);
    }
    handleSuccess(event){
        if(event.detail.isSuccess && event.detail.showOCRInParent){
            console.log('Inside Final Success!!!!');
            this.dataValues = event.detail.ocrData;
            this.applicantRec = event.detail.applicantRec;
            this.documentChkRecord = event.detail.documentChkRecord;
            this.documentNumber = event.detail.documentNumber;
            this.isAadhar = event.detail.isAadhar;
            this.contentVersionId = event.detail.contentVersionId;
            this.eventdocName = event.detail.docName;
            this.showOCRDetails = true;
        }else if(event.detail.isSuccess && event.detail.showGreenTick){
            let dataVlaue = '[data-id=\"'+event.detail.docName+'green'+'\"]';
            if(this.template.querySelector(dataVlaue)){
                this.template.querySelector(dataVlaue).classList.remove('slds-hide');
            }
            this.getVersionFiles();
            this.showUploadComponent = false;
        }else if(event.detail.isSuccess){
            console.log('losAddIndNonIndClone NO OCR & Success');
            this.getVersionFiles();
            this.showUploadComponent = false;
        }else{
            this.showToastEvent('Error', event.detail.errorMessage, 'error');
            this.showUploadComponent = false;
        }
    
    }
    okClick(){
        this.updateRecords(true);
    }
    notOkClick(){
        //this.updateRecords(false);
        console.log('');
        //this.showUploadComponent = false;
        this.showOCRDetails = false;
        this.showUploadComponent = false;

    }
    updateRecords(isOkBoolean){
        this.isloading= true;
        updateOCRDate({ applicantRec: this.applicantRec, documentChkRecord: this.documentChkRecord,isAadhar: this.isAadhar,isOk :isOkBoolean,contentVersionId :this.contentVersionId })
        .then(result => {
            this.isloading= false;
            let parseResult=JSON.parse(result);
            if(parseResult.isSuccess){
                this.showToastEvent('Success', 'Details Updated Succesfully!!', 'success');
                this.showUploadComponent = false;
                const resultEvent = {isSuccess:true};
                const documentHandlerEvent = new CustomEvent('documentsuccess', {
                detail : resultEvent
                });
                this.dispatchEvent(documentHandlerEvent);
                if(this.eventdocName =='AUWheels0001'){
                    this.ApplicantRecord.PAN__c = this.documentNumber;
                }else if(this.eventdocName =='AUWheels0002'){
                    this.ApplicantRecord.Voter_Id__c = this.documentNumber;  
                }else if(this.eventdocName =='AUWheels0003'){
                    this.ApplicantRecord.Aadhaar_Number__c = this.documentNumber;  
                }else if(this.eventdocName =='AUWheels0004'){
                    this.ApplicantRecord.Driving_License_Id__c = this.documentNumber;  
                }else if(this.eventdocName =='AUWheels0005'){
                    this.ApplicantRecord.Passport_Number__c = this.documentNumber;  
                }
                this.showOCRDetails = false;
                this.showUploadComponent = false;
                setTimeout(() => {
                    let dataVlaue = '[data-id=\"'+this.eventdocName+'green'+'\"]';
                    if(!this.showOCRDetails && this.template.querySelector(dataVlaue)){
                        this.template.querySelector(dataVlaue).classList.remove('slds-hide');
                    }
                    this.getVersionFiles();
               }, 1000); 


            }else{
                this.showToastEvent('Error', 'We Encountered an Error while updating details!!', 'error');
                this.showUploadComponent = false;
                const resultEvent = {isSuccess:false};
                const documentHandlerEvent = new CustomEvent('documentsuccess', {
                detail : resultEvent
                });
                this.dispatchEvent(documentHandlerEvent);
                this.showOCRDetails = false;
                this.showUploadComponent = false;
            }
        })
        .catch(error => {
            this.isloading= false;
            this.error = error;
            console.log('error', error);
            this.showUploadComponent = false;
        })
    }
    showToastEvent(titleValue, messageValue, variantValue){
        const event = new ShowToastEvent({
            title: titleValue, 
            message: messageValue,
            variant: variantValue
        });
        this.dispatchEvent(event);
    }
    hanleCancel(){
        this.showUploadComponent=false;
        this.docName ='';

    }
    handleOCRButton(event){
        if(event.detail.isSuccess){
            console.log('OCR 1'+event.detail.docName);
            //alert('DOCNAME'+ event.detail.docName)
            //alert('applicantIdLOCAL'+ this.applicantId);
            console.log('OCR 2'+event.detail.documentId);
            //alert('documentId'+ event.detail.documentId)
            console.log('OCR 3'+event.detail.documentType);
            //alert('documentType'+ event.detail.documentType)
            console.log('OCR 4'+event.detail.applicantId);
            //alert('applicantIdEvent'+ event.detail.applicantId)
            //alert('applicantIdLOCAL'+ this.applicantId);
            let dataVlaue = '[data-id=\"'+event.detail.docName+'\"]';
            //alert('dataVlaue'+dataVlaue);
            if(this.isMobile){
                this.template.querySelector(dataVlaue).classList.remove('slds-hide');
            }

        }
    }
}