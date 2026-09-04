import { LightningElement, track, wire, api } from 'lwc';
import { updateRecord, createRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import APPLICANT_OBJECT from '@salesforce/schema/Applicant__c';
import OtpDurationLabel from '@salesforce/label/c.AUSF_RESEND_OTP_DURATION';
import Generic_API_Error from '@salesforce/label/c.Generic_API_Error';
import mobileOtpVerificationHandler from '@salesforce/apex/LOSMobileOtpController.mobileOtpVerificationHandler';
import validateMobile from '@salesforce/apex/LosQuickLoanController.validateMobile';
import checkMandatoryDocuments from '@salesforce/apex/Ausfb_RelatedApplicantController.checkMandatoryDocuments';
import getApplicantRecord from '@salesforce/apex/LosQuickLoanController.getApplicant';
import getApplicants from '@salesforce/apex/Ausfb_RelatedApplicantController.getApplicants';
import getLoanApplication from '@salesforce/apex/LosQuickLoanController.getLoanApplicationData';
import FORM_FACTOR from '@salesforce/client/formFactor';
import updateOCRDate from '@salesforce/apex/LOSDocumentUploadController.updateOCRData';
import getVersionFilesRec from '@salesforce/apex/LOSDocumentUploadController.getVersionFiles';
import getVisibleFieldsForLosAddIndNonInd from '@salesforce/apex/LosQuickLoanController.getVisibleFieldsForLosAddIndNonInd';
import getTokenViaAddharNumber from '@salesforce/apex/AadharTokenUtil.getTokenViaAddharNumber';
import updateDocChecklistRec from '@salesforce/apex/LosQuickLoanController.updateDocChecklistRec';
import updateDocVerification from '@salesforce/apex/LosQuickLoanController.updateDocVerification';
import DocumentAadhaar from '@salesforce/label/c.DocumentAadhaar';
import DocumentDL from '@salesforce/label/c.DocumentDL';
import DocumentPan from '@salesforce/label/c.DocumentPan';
import DocumentUdyam from '@salesforce/label/c.DocumentUdyam';
import maskedCss from '@salesforce/resourceUrl/masked';
import { loadStyle } from 'lightning/platformResourceLoader';
import DocumentPassport from '@salesforce/label/c.DocumentPassport';
import DocumentVoter from '@salesforce/label/c.DocumentVoter';
import DocumentGST from '@salesforce/label/c.DocumentGST';
import DocumentElectricity from '@salesforce/label/c.DocumentElectricity';
import DocumentTIN from '@salesforce/label/c.DocumentTIN';
import DocumentWATER from '@salesforce/label/c.DocumentWATER';
import DocumentLandline from '@salesforce/label/c.DocumentLandline';
import DocumentITR from '@salesforce/label/c.DocumentITR';
import validateRecordEdit from '@salesforce/apex/ComponentProfileRestrictionController.validateRecordEdit';
import { getSpinnerImage } from 'c/customSpinner';
import coApplicantInfoMessage from '@salesforce/label/c.CoApplicantInfoMessage';
import { COMMERCIAL_RECORD_TYPE_NAMES, TRACTOR_RT_NAME, CO_APPLICANT_RECORD_TYPE_LABEL } from 'c/lwcutilities';//R2-17

const FIELDS_TO_UPPER_CASE = ['pan__c', 'passport_number__c', 'voter_id__c', 'driving_license_id__c'];
export default class LosAddIndNonInd extends NavigationMixin(LightningElement) {
    label = {
        DocumentAadhaar,
        DocumentDL,
        DocumentPan,
        DocumentPassport,
        DocumentVoter,
        DocumentUdyam,
        DocumentGST,
        DocumentTIN,
        DocumentElectricity,
        DocumentWATER,
        DocumentITR,
        DocumentLandline
    };
    Generic_API_Error = Generic_API_Error;
    DocumentITRPreview = DocumentITR + 'preview';
    DocumentLandlinePreview = DocumentLandline + 'preview';
    DocumentWATERPreview = DocumentWATER + 'preview';
    DocumentUdyamPreview = DocumentUdyam + 'preview';
    DocumentElectricityPreview = DocumentElectricity + 'preview';
    DocumentTINPreview = DocumentTIN + 'preview';
    DocumentGSTPreview = DocumentGST + 'preview';
    DocumentAadhaarPreview = DocumentAadhaar + 'preview';
    DocumentPanPreview = DocumentPan + 'preview';
    DocumentDLPreview = DocumentDL + 'preview';
    DocumentPassportPreview = DocumentPassport + 'preview';
    DocumentVoterPreview = DocumentVoter + 'preview';
    @api recordId;
    @api applicantId;
    @api currentApplicantRecord = {};
    @api sObjectName;
    @track pancardForm16PicklistValues;
    @api appCount;
    @track isLoading
    @api spinnerImage;
    pancardForm16OptionsValue = '';
    isEnabledPanCard = false;
    isCommercial = false;
    isEnabledVoterId = false;
    isEnabledDrivingLicence = false;
    isEnabledPassport = false;
    isDisabledAadhaar = false;
    isDisabledPanCard = false;
    isDisabledVoterId = false;
    isDisabledDrivingLicence = false;
    isDisabledPassport = false;
    @track ApplicantRecord = {};
    oldAadhaarValue;
    oldPanValue;
    AdditionalInformationvalue = {};
    errorOnChild = false;
    showPreview = false;
    mask = true;
    addNewApplicant = false;
    appRecTypes = [];
    customerTypes = [];
    appRecTypeVal = '';
    customerTypeVal = '';
    showAppRecType = false;
    @track mobileNumber = '';
    /* OTP Verification variable */
    @track isVerified = false;
    @track boolResendOtp = false;
    boolRequestOtp = false;
    boolSendOtp = true;
    mobileError=false;
    @track isVerifiedNumber = false;
    @track boolIsDisableVerifyButton = true;
    @track otpVerified = false;
    @track boolVerify = true;
    @track oldMobileNumberValue;
    @track isReadOnly = false;
    @track increse1Second;
    @track oldDocVerifObj = {};
    boolCheckMobileNumber = true;
    enterOTPValue = '';
    isEnterOtp = false;
    isPanMandatory = false;
    customerType;
    constitutionTypeOptions;
    visibledFields;
    isHtmlPanMandatorty = false;
    isEnabledNpr;
    isEnabledNrega;
    isEnabledCkyc;
    /* Document Upload Related START*/
    isMobile;
    trueValue = true;
    falseValue = false;
    @track docName;
    eventdocName;
    @track showUploadComponent = false;
    @track showOCRDetails = false;
    @track dataValues = [];
    @track modelNeeded = true;
    applicantRec;
    documentChkRecord;
    isAadhar;
    contentVersionId;
    documentNumber;
    documentIdsMap = [];
    @track documentChecklists = [];
    isloading = false;
    aadhaarNumberOnUi;
    applicantLst = [];
    isKYCValid = true;
    @track isRegNoVisible = false;
    @track isGSTNoVisible = false;
    @track isUdyamNoVisible = false;
    @track isTINVisible = false;
    @track isCINVisible = false;
    @track isTrustDeedVisible = false;
    @track isHUFDeedVisible = false;
    @track isLLPVisible = false;
    @track isSoleProp = false;
    docImage = '';
    @track blnRestrictEdit = false;
    @track blnGoNext = false;
    @track showBO = false;
    recordTypeName;
    loanAppStage;
    loanRecType;
    opsKycActionApproved=false

    get showMobile() {
        return this.customerTypeVal && this.appRecTypeVal
    }
    /* Document Upload Related END*/
    AdditionalInformationoptions = [
        { label: 'VoterId', value: 'VoterId' },
        { label: 'Driving Licence', value: 'Driving Licence' },
        { label: 'Passport', value: 'Passport' },
        { label: 'NPR', value: 'NPR' },
        { label: 'NREGA', value: 'NREGA' },
        { label: 'CKYC', value: 'CKYC' },
    ];

    AdditionalComInformationoptions = [
        { label: 'VoterId', value: 'VoterId' },
        { label: 'Passport', value: 'Passport' },
        { label: 'NPR', value: 'NPR' },
        { label: 'NREGA', value: 'NREGA' },
        { label: 'CKYC', value: 'CKYC' },
    ];

    
    @track allAdditionalInformationvalues = [];
    isShowAdditionalInformationsPicklist = false;
    @track allAdditionalInformationvaluesInit = {'initAadharData':'','initPanData':'','initAdditionalDocList':[]};
    
    @track isStageNotQDE = false;
    @track objectInfo;

    @wire(getObjectInfo, { objectApiName: APPLICANT_OBJECT })
    objectInfo;


    get hidekycFields() {
        
        return this.addNewApplicant && !this.applicantId;
    }

    /* START - SFAU-5538 */
    get disableCIF () {
        return (this.isStageNotQDE || this.ApplicantRecord.KYC_Status__c == 'Complete' || this.ApplicantRecord.CIBIL_Status__c == 'Completed');
    }
    /* END - SFAU-5538 */


    GetrecordTypeInfo() {
        this.appRecTypes = [];
        // Returns a map of record type Ids 
        const rtis = this.objectInfo.data.recordTypeInfos;
        Object.keys(rtis).forEach(element => {
            console.log('RT Id', rtis[element].recordTypeId);
            console.log('RT Name', rtis[element].name);
            console.log('App Count', this.appCount);
            console.log('this.customerTypeVal', this.customerTypeVal);
            console.log('this.customerType', this.customerType);
            if (this.customerTypeVal == 'Individual') {
                if ((this.appCount == 0 && rtis[element].name == 'Applicant') || rtis[element].name == 'Co-Applicant' || rtis[element].name == 'Guarantor' || rtis[element].name == 'BO') {
                    this.appRecTypes.push({ label: rtis[element].name, value: rtis[element].recordTypeId });
                }
            }
            else if (this.customerTypeVal == 'Non Individual') {
                //  if (rtis[element].name == 'Non Individual' || rtis[element].name == 'BO') {
                if ((this.appCount == 0 && rtis[element].name == 'Applicant') || rtis[element].name == 'Co-Applicant' || rtis[element].name == 'Guarantor') {
                    this.appRecTypes.push({ label: rtis[element].name, value: rtis[element].recordTypeId });
                }
            }
        });
        console.log('this.appRecTypes', this.appRecTypes);

    }


    handleApplicantType(event) {
        this.appRecTypeVal = event.target.value;
        console.log('appRecTypeVal', this.appRecTypeVal);
        //Below lines added as a part of Bug-2851
        let label = event.target.options.find(opt => opt.value === event.target.value).label;
        if ((label == 'Guarantor' || label == 'Co-Applicant') ) {
            this.isStageNotQDE = false;
            if(this.ApplicantRecord.Customer_Type__c=='Individual'){
                this.showBO = true;
            }
            else{
                this.showBO = false;
            }
        }else  if(label == 'BO'){//R2-2637
            this.isStageNotQDE = false;
        }
        else{
            this.showBO = false;
        }
        this.checkMandatoryDocuments(this.recordId);
        this.recordTypeName= label;// SFAU-4038
        // R2-17 - Co-Applicant can only be a relative message.
        if( this.loanRecType === TRACTOR_RT_NAME && label === CO_APPLICANT_RECORD_TYPE_LABEL ){
            this.showToastEvent('', coApplicantInfoMessage, 'info');
        }
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
            /*    if (result != null) {
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
                            if (!this.applicantId) {
                                this.createApplicant();
                            }
                        }

                    }
                } */

                if (result != null) {            
                    if (masterRecordName == 'Mobile Validate OTP') {
                        let responseVal = JSON.parse(result);
                        let checklist = responseVal.checklistRecord;
                        let response = JSON.parse(responseVal.response);
                        if(responseVal.statusCode != 200){
                            this.isVerified = false;
                                this.isEnterOtp = true;
                                this.boolRequestOtp = false;
                                this.boolSendOtp = false;
                                this.isVerifiedNumber = false;
                                this.boolVerify = true;
                                this.showToastEvent('Error', 'API Error: ' + checklist.Name + ' Response: ' + responseVal.statusCode + '- ' + responseVal.status , 'error');
                        }else if (response.RequestStatus == 'Failed') {
                                this.isVerified = false;
                                this.isEnterOtp = true;
                                this.boolRequestOtp = false;
                                this.boolSendOtp = false;
                                this.isVerifiedNumber = false;
                                this.boolVerify = true;
                                this.showToastEvent('Error', response.StatusCode + '- ' + response.StatusDesc , 'error');
                            }
                            else if (response.RequestStatus == 'Success') {
                                this.isVerified = true;
                                this.boolResendOtp = false;
                                this.isloading = true;
                                this.isEnterOtp = false;
                                this.isVerifiedNumber = true;
                                this.reportOtpVerficationValidity("");
                                if (!this.applicantId) {
                                    this.createApplicant();
                                }
    
                            } 

                    }else if (masterRecordName == 'Mobile Generate OTP') {
                        let responseVal = JSON.parse(result);
                        let checklist = responseVal.checklistRecord;
                        let response = JSON.parse(responseVal.response);

                        if(responseVal.statusCode != 200){
                             this.boolRequestOtp = false;
                             this.boolSendOtp = true;
                             this.isEnterOtp = false;
                            this.showToastEvent('Error', 'API Error: ' + checklist.Name + ' Response: ' + responseVal.statusCode + '- ' + responseVal.status , 'error');
                        }else if (response.RequestStatus == 'Failed') {
                                this.showToastEvent('Error', response.StatusCode + '- ' + response.StatusDesc , 'error');
                            }
                            else if (response.RequestStatus == 'Success') {
    
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

    createApplicant() {
        this.isloading = true;
        // createApplicantRecord({ loanId: this.recordId, customerType: this.customerTypeVal, recordType: this.appRecTypeVal, mobileNumber: this.mobileNumber })
        // .then(result => {
        //     if(result){
        //         this.applicantId = result.Id;
        //         this.ApplicantRecord = result;
        //         this.isloading = false;
        //     }else{
        //         this.isloading = false;
        //     }
        // })
        // .catch(error => {
        //     this.isloading = false;
        //     this.error = error;
        // })

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
                this.showToastEvent('Success', 'Applicant Created Successfully', 'success');
                console.log('applicant ' + JSON.stringify(applicant));
                this.isloading = false;
                // this.errorOnChild = (this.isInputValid('') && this.isCheckValid()) ? false : true;
                console.log('Id', applicant.id);
                this.applicantId = applicant.id;
                this.ApplicantRecord['Id'] = applicant.id;
                if (this.ApplicantRecord.hasOwnProperty('Loan__c')) {
                    delete this.ApplicantRecord['Loan__c'];
                }
                if (this.ApplicantRecord.hasOwnProperty('RecordTypeId')) {
                    delete this.ApplicantRecord['RecordTypeId'];
                }
            })
            .catch(error => {
                this.isloading = false;
                if(error?.body?.output?.errors !=undefined){
                    this.mobileError=error?.body?.output?.errors[0]?.message;
                    this.showToastEvent('Error creating record', error?.body?.output?.errors[0]?.message, 'error');
                }
                else
                    this.showToastEvent('Error creating record', error.body.message, 'error');
                console.log("error inside createRecord--", error);

            });

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
        let isOTPValid = this.isCheckValidity();
        if (event.detail.value.length == 4 && isOTPValid) {
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
    checkBlockedList(fldValue){
        validateMobile({ mobileNo: fldValue})
        .then(result => {
            if(result){
                this.mobileError=true;
                this.boolSendOtp = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'This mobile number is blocked',
                        variant: 'error',
                    }),
                );
            }
            else {
                this.mobileError=false;
                this.boolSendOtp=true;

            }
        })
        .catch(error =>{
            this.error = error; 
        })

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
                this.checkBlockedList(this.mobileNumber)
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

    async connectedCallback() {

        if (this.spinnerImage == undefined) {
            this.spinnerImage = await getSpinnerImage(this.recordId);
        }
        this.isLoading=true
        if (FORM_FACTOR == 'Small') {
            this.isMobile = true;
            this.modelNeeded = false;
        } else {
            this.isMobile = false;
        }
        loadStyle(this, maskedCss);
        console.log('App Count', this.appCount);
        console.log('Connected Callback Add Ind SObj----->', this.sObjectName);
        console.log('Connected Callback Add Ind SObj----->', JSON.stringify(this.currentApplicantRecord));
        if (this.sObjectName == 'Applicant__c') {
            this.applicantId = this.recordId;
        }

        if (this.applicantId) {
            this.getCustomerType(this.applicantId, '');
            this.checkMandatoryDocuments(this.recordId);
        }
        else {
            this.getCustomerType(this.recordId, '');
        }

        if (!this.applicantId) {
            this.addNewApplicant = true;
            console.log('In Add New Applicant');
            console.log('Loan App Id In Add New Applicant', this.recordId);
            let componentFields = this.template.querySelectorAll(".component");
            componentFields.forEach(inputField => {
                console.log('inputField data id', inputField.dataset.id);
                this.template.querySelector('[data-id="' + inputField.dataset.id + '"]')?.classList.add('slds-hide');
            });
            this.checkMandatoryDocuments(this.recordId);
        }
        else {
            this.getApplicant();
            this.getVersionFiles();
        }
        this.getLoanApplication();
        this.getApplicants();
        this.checkRestrictRecord ();
        
        
        
    }

    /*
    @description - to check login user have access to edit record
    */
    checkRestrictRecord () {
        validateRecordEdit({
            compName: 'losAddIndNonInd' ,recordId: this.recordId
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

    getApplicants() {	
        console.log('Loan App Id-->' + JSON.stringify(this.recordId));	
        getApplicants({	
            loanAppRecId: this.recordId	
        })	
            .then(data => {	
                this.isLoading=false;
                console.log('data is----->' + JSON.stringify(data));	
                if (data) {	
                    this.applicantLst = data;	
                }	
            })	
            .catch(error => {	
                this.isLoading=false;
                console.log('error is ' + JSON.stringify(error));	
                this.applicantLst = undefined;	
                //this.accounts = undefined;	
            })	
    }

    getCustomerType(recordId, strCustomerType) {
        this.isloading = true;;
        console.log('Inside getVisibleFields');

        getVisibleFieldsForLosAddIndNonInd({ strScreen: 'losAddIndNonInd', recordId: recordId, strCustomerType: strCustomerType })
            .then(result => {
                this.isloading = false;
                if (strCustomerType) {
                    this.customerType = strCustomerType;
                }
                else {
                    this.customerType = result.customerType;
                }
                if (this.customerType == 'Non Individual') {
                    this.isHtmlPanMandatorty = true;
                }
                else {
                    this.isHtmlPanMandatorty = false;
                }
                this.visibledFields = result.visibleFields;
                console.log('visible field result is ' + JSON.stringify(result));

                let componentFields = this.template.querySelectorAll(".component");
                componentFields.forEach(inputField => {
                    console.log('inputField data id', inputField.dataset.id);
                    this.template.querySelector('[data-id="' + inputField.dataset.id + '"]').classList.add('slds-hide');
                });

                result.visibleFields.forEach(input => {
                    if (this.template.querySelector('[data-id="' + input + '"]') != null) {
                        this.template.querySelector('[data-id="' + input + '"]').classList.remove('slds-hide');
                    }
                });
            })
            .catch(error => {
                this.isloading = false;
                console.log('result is ' + error)
            })

    }





    getApplicant() {
        console.log('this.applicantId', this.applicantId);
        console.log('this.recordId', this.recordId);
        getApplicantRecord({
            recId: this.applicantId
        })
            .then((result) => {
                if (result != null) {
                    console.log('result', result);
                    /*New change added by Yash*/
                    this.allAdditionalInformationvaluesInit.initAadharData = ( result.applcnt.Aadhaar_Number__c!=undefined)? result.applcnt.Aadhaar_Number__c:'';
                    this.allAdditionalInformationvaluesInit.initPanData = ( result.applcnt.PAN__c!=undefined)? result.applcnt.PAN__c:'';
                    this.ApplicantRecord = result.applcnt;
                    this.oldAadhaarValue = result.applcnt.Aadhaar_Number__c;
                    this.oldPanValue = result.applcnt.PAN__c;
                    this.oldDocVerifObj.oldGstNo = result.applcnt.GST_NO__c;
                    this.oldDocVerifObj.oldUdyamNo = result.applcnt.UDYAM_Registration_Number__c;
                    this.oldDocVerifObj.oldGstCinNo = result.applcnt.CIN__c;
                    this.recordTypeName = this.ApplicantRecord.RecordType.Name
                    console.log('this.ApplicantRecord.CIBIL_Status__c', this.ApplicantRecord.CIBIL_Status__c);
                
                    this.documentChecklists = result.docCheckList;
                    this.showAdditionalFlds(this.documentChecklists);

                    if (this.oldAadhaarValue) {
                        this.maskNumber();
                    }
                    if (( this.ApplicantRecord.RecordType.Name == 'Guarantor' || this.ApplicantRecord.RecordType.Name == 'Co-Applicant') && this.ApplicantRecord.Customer_Type__c=='Individual') {
                        this.showBO = true;
                    }
                    else{
                        this.showBO = false;
                    }
                    if (this.ApplicantRecord.CIBIL_Status__c != '' && this.ApplicantRecord.CIBIL_Status__c != null) {
                        /*
                        if(this.ApplicantRecord.Aadhaar_Number__c != '' && this.ApplicantRecord.Aadhaar_Number__c != null){
                            this.isDisabledAadhaar = true;
                        }
                        if(this.ApplicantRecord.PAN__c != '' && this.ApplicantRecord.PAN__c != null){
                            this.isDisabledPanCard = true;
                        }
                        if(this.ApplicantRecord.Voter_Id__c != '' && this.ApplicantRecord.Voter_Id__c != null){
                            this.isDisabledVoterId = true;
                        }
                        if(this.ApplicantRecord.Driving_License_Id__c != '' && this.ApplicantRecord.Driving_License_Id__c != null){
                            this.isDisabledDrivingLicence = true;
                        }
                        if(this.ApplicantRecord.Passport_Number__c != '' && this.ApplicantRecord.Passport_Number__c != null){
                            this.isDisabledPassport = true;
                        }
                        */
                        let inputFields = this.template.querySelectorAll(".kyc");
                        inputFields.forEach(inputField => {
                            if (!inputField.value) {
                                console.log('input fiel name ' + inputField.name);
                                inputField.disabled = true;
                            }
                        })

                    }
                    if(result.applcnt.Customer_Type__c && result.applcnt.Customer_Type__c=='Non Individual'){
                        this.isCommercial=false;
                        if(result.applcnt.Constitution_Type__c){
                            if(result.applcnt.Constitution_Type__c.includes('Sole Proprietary')){
                                this.isRegNoVisible = true;
                                this.isGSTNoVisible = true;
                                this.isUdyamNoVisible = true;
                                this.isSoleProp = true;
                
                                this.isCINVisible = false;
                                this.isLLPVisible = false;
                                this.isHUFDeedVisible = false;
                                this.isTrustDeedVisible = false;
                            }
                            else if(result.applcnt.Constitution_Type__c.includes('Trust')){
                                this.isRegNoVisible = true;
                                this.isTrustDeedVisible = true;
                
                                this.isGSTNoVisible = false;
                                this.isUdyamNoVisible = false;
                                this.isCINVisible = false;
                                this.isLLPVisible = false;
                                this.isHUFDeedVisible = false;
                                this.isSoleProp = false;
                            }
                            else if(result.applcnt.Constitution_Type__c.includes('HUF')){
                                this.isHUFDeedVisible = true;
                
                                this.isRegNoVisible = false;
                                this.isGSTNoVisible = false;
                                this.isUdyamNoVisible = false;
                                this.isCINVisible = false;
                                this.isLLPVisible = false;
                                this.isTrustDeedVisible = false;
                                this.isSoleProp = false;
                            }
                            else if(result.applcnt.Constitution_Type__c.includes('Firm')){
                                this.isRegNoVisible = true;
                                this.isUdyamNoVisible = true;
                
                                this.isGSTNoVisible = false;
                                this.isCINVisible = false;
                                this.isLLPVisible = false;
                                this.isHUFDeedVisible = false;
                                this.isTrustDeedVisible = false;
                                this.isSoleProp = false;
                            }
                            else if(result.applcnt.Constitution_Type__c.includes('Public Limited') || result.applcnt.Constitution_Type__c.includes('Private Limited')){
                                this.isRegNoVisible = true;
                                this.isCINVisible = true;
                
                                this.isGSTNoVisible = false;
                                this.isUdyamNoVisible = false;
                                this.isLLPVisible = false;
                                this.isHUFDeedVisible = false;
                                this.isTrustDeedVisible = false;
                                this.isSoleProp = false;
                            }
                            else if(result.applcnt.Constitution_Type__c.includes('Society') || result.applcnt.Constitution_Type__c.includes('AOP')){
                                this.isRegNoVisible = true;
                
                                this.isGSTNoVisible = false;
                                this.isUdyamNoVisible = false;
                                this.isCINVisible = false;
                                this.isLLPVisible = false;
                                this.isHUFDeedVisible = false;
                                this.isTrustDeedVisible = false;
                                this.isSoleProp = false;
                            }
                            else if(result.applcnt.Constitution_Type__c.includes('Limited Liability Partnership')){
                                this.isLLPVisible = true;
                                this.isCINVisible = true;
                
                                this.isRegNoVisible = false;
                                this.isGSTNoVisible = false;
                                this.isUdyamNoVisible = false;
                                this.isHUFDeedVisible = false;
                                this.isTrustDeedVisible = false;
                                this.isSoleProp = false;
                            }
                        }
                    }
                }
                this.checkMandatoryDocuments(this.recordId);
            })
            .catch((error) => {
                this.error = error;
            });
    }

    maskNumber() {
        let aadhaarNumber = this.ApplicantRecord.Aadhaar_Number__c;
        this.aadhaarNumberOnUi = aadhaarNumber?.replace(/\d(?=\d{4})/g, '*');
        console.log('this.aadhaarNumberOnUi in mask-- ' + this.aadhaarNumberOnUi);
    }

    unMaskNumber() {

        let aadhaarNumb = this.aadhaarNumberOnUi;

        if (aadhaarNumb && aadhaarNumb.includes('*')) {
            this.aadhaarNumberOnUi = this.ApplicantRecord.Aadhaar_Number__c;
        }
        else {
            this.maskNumber();
        }
        console.log('this.aadhaarNumberOnUi in unmask-- ' + this.aadhaarNumberOnUi);
    }

    showAdditionalFlds(documentChecklists) {

        const isCommercial = this.isCommercial || (COMMERCIAL_RECORD_TYPE_NAMES.includes( this.ApplicantRecord?.Loan__r.RecordType.Name )&& this.customerType != 'Non Individual')
        for (let val of documentChecklists) {
            if (val.Document_Master__r.Document_Name__c == 'Voter ID Card') {
                this.isEnabledVoterId = true;
                this.allAdditionalInformationvalues.push('VoterId');
                if (this.ApplicantRecord.Voter_Id__c) {
                    this.isShowAdditionalInformationsPicklist = true;
                }
            }
            else if (val.Document_Master__r.Document_Name__c == 'Driving Licence' && !isCommercial) {
                this.isEnabledDrivingLicence = true;
                this.allAdditionalInformationvalues.push('Driving Licence');
                if (this.ApplicantRecord.Driving_License_Id__c) {
                    this.isShowAdditionalInformationsPicklist = true;
                }
            }
            else if (val.Document_Master__r.Document_Name__c == 'Passport') {
                this.isEnabledPassport = true;
                this.allAdditionalInformationvalues.push('Passport');
                if (this.ApplicantRecord.Passport_Number__c) {
                    this.isShowAdditionalInformationsPicklist = true;
                }
            }
            else if (val.Document_Master__r.Document_Name__c == 'NPR document') {
                this.isEnabledNpr = true;
                this.allAdditionalInformationvalues.push('NPR');
                if (this.ApplicantRecord.NPR__c) {
                    this.isShowAdditionalInformationsPicklist = true;
                }
            }
            else if (val.Document_Master__r.Document_Name__c == 'NREGA document') {
                this.isEnabledNrega = true;
                this.allAdditionalInformationvalues.push('NREGA');
                if (this.ApplicantRecord.NREGA__c) {
                    this.isShowAdditionalInformationsPicklist = true;
                }
            }
        }
        let initAdditionalData = [];
        initAdditionalData = JSON.parse(JSON.stringify(this.allAdditionalInformationvalues));
        this.allAdditionalInformationvaluesInit.initAdditionalDocList = initAdditionalData;
    }

    handleOnFocusOut() {
        this.unMaskNumber();
    }

    getVersionFiles() {
        getVersionFilesRec({
            recordId: this.applicantId
        })
            .then((result) => {
                if (result != null) {
                    console.log('resultFile' + result);
                    console.log('resultJSON' + JSON.stringify(result));
                    for (var key in result) {
                        this.documentIdsMap.push({ key: key, value: result[key] });
                        let dataVlaue = '[data-id=\"' + key + 'preview' + '\"]';
                        if (this.template.querySelector(dataVlaue)) {
                            this.template.querySelector(dataVlaue).classList.remove('slds-hide');
                        }
                    }
                    console.log('this.documentIdsMap' + this.documentIdsMap);
                }
            })
            .catch((error) => {
                this.error = error;
            });
    }
    handlePreviewClick(event) {
        console.log('PreviewCLick' + event.currentTarget.dataset.id);
        let dataValue = event.currentTarget.dataset.id?.replace('preview', '');
        let contentDocumentId;
        this.documentIdsMap.forEach(function (value, key) {
            console.log(value['key'] + " = " + value['value']);
            if (dataValue == value['key']) {
                console.log('clickedValue' + value['value']);
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
            this.constitutionTypeOptions = data.picklistFieldValues.Constitution_Type__c.values;
            this.customerTypes = data.picklistFieldValues.Customer_Type__c.values;
        } else if (error) {
            console.log('error is ' + JSON.stringify(error));
        }
    }

    handleValuChange(event) {
        let inputValue = event.target.value;
        let fldName = event.target.name;
        
        if (this.blnRestrictEdit == true) {
            this.restrictAccessMessage ();
        }
        else {   

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

            if (FIELDS_TO_UPPER_CASE.includes(fldName?.toLowerCase())) {
                if (inputValue)
                    inputValue = inputValue.toUpperCase();
            }

            this.ApplicantRecord[fldName] = inputValue;

            if(fldName=='Is_BO__c'){
                this.ApplicantRecord.Is_BO__c = event.target.checked;
            }

            if (fldName == 'Aadhaar_Number__c') {
                this.aadhaarNumberOnUi = inputValue;
                /*    let combineDigits= '';
                    if(this.oldAadhaarValue && ((this.oldAadhaarValue.length == 12 && inputValue.length > 8) || (this.oldAadhaarValue.length == 16 && inputValue.length > 12))) {
                        let lastFOurCharOfInpValue = inputValue.substr(inputValue.length - 4, inputValue.length);
                        let allValuesExceptlastFouCharac = this.ApplicantRecord.Aadhaar_Number__c.substr(0, this.ApplicantRecord.Aadhaar_Number__c.length - 4);
                        combineDigits = allValuesExceptlastFouCharac + lastFOurCharOfInpValue;
                    
                    }
                    else {
                        this.ApplicantRecord[fldName] = inputValue;
                    }  
                    if(combineDigits.length == 12) {
                        this.ApplicantRecord.Aadhaar_Number__c = combineDigits;
                    } */
            }
            /* else {
                this.ApplicantRecord[fldName] = inputValue;
            }  */

            if (fldName == 'Customer_Type__c') {
                this.customerTypeVal = inputValue;
                this.GetrecordTypeInfo();
                this.hideShowAppRecType();
                if(inputValue=='Non Individual'){
                    this.showBO = false;
                }
                else{
                    this.showBO = true;
                }
                this.getCustomerType(this.recordId, event.target.value);
            }
            if (fldName == 'CIN__c') {
                this.ApplicantRecord.CIN__c = inputValue.toUpperCase();
            }
            else if (fldName == 'GST_NO__c') {
                this.ApplicantRecord.GST_NO__c = inputValue.toUpperCase();
            }
            else if (fldName == 'TIN__c') {
                this.ApplicantRecord.TIN__c = inputValue.toUpperCase();
            }
            else if (fldName == 'UDYAM_Registration_Number__c') {
                this.ApplicantRecord.UDYAM_Registration_Number__c = inputValue.toUpperCase();
            }
            else if(fldName == 'Constitution_Type__c'){
                if(inputValue.includes('Sole Proprietary')){
                    this.isRegNoVisible = true;
                    this.isGSTNoVisible = true;
                    this.isUdyamNoVisible = true;
                    this.isSoleProp = true;

                    this.isCINVisible = false;
                    this.isLLPVisible = false;
                    this.isHUFDeedVisible = false;
                    this.isTrustDeedVisible = false;
                }
                else if(inputValue.includes('Trust')){
                    this.isRegNoVisible = true;
                    this.isTrustDeedVisible = true;

                    this.isGSTNoVisible = false;
                    this.isUdyamNoVisible = false;
                    this.isCINVisible = false;
                    this.isLLPVisible = false;
                    this.isHUFDeedVisible = false;
                    this.isSoleProp = false;
                }
                else if(inputValue.includes('HUF')){
                    this.isHUFDeedVisible = true;

                    this.isRegNoVisible = false;
                    this.isGSTNoVisible = false;
                    this.isUdyamNoVisible = false;
                    this.isCINVisible = false;
                    this.isLLPVisible = false;
                    this.isTrustDeedVisible = false;
                    this.isSoleProp = false;
                }
                else if(inputValue.includes('Firm')){
                    this.isRegNoVisible = true;
                    this.isUdyamNoVisible = true;

                    this.isGSTNoVisible = false;
                    this.isCINVisible = false;
                    this.isLLPVisible = false;
                    this.isHUFDeedVisible = false;
                    this.isTrustDeedVisible = false;
                    this.isSoleProp = false;
                }
                else if(inputValue.includes('Public Limited') || inputValue.includes('Private Limited')){
                    this.isRegNoVisible = true;
                    this.isCINVisible = true;

                    this.isGSTNoVisible = false;
                    this.isUdyamNoVisible = false;
                    this.isLLPVisible = false;
                    this.isHUFDeedVisible = false;
                    this.isTrustDeedVisible = false;
                    this.isSoleProp = false;
                }
                else if(inputValue.includes('Society') || inputValue.includes('AOP')){
                    this.isRegNoVisible = true;

                    this.isGSTNoVisible = false;
                    this.isUdyamNoVisible = false;
                    this.isCINVisible = false;
                    this.isLLPVisible = false;
                    this.isHUFDeedVisible = false;
                    this.isTrustDeedVisible = false;
                    this.isSoleProp = false;
                }
                else if(inputValue.includes('Limited Liability Partnership')){
                    this.isLLPVisible = true;
                    this.isCINVisible = true;

                    this.isRegNoVisible = false;
                    this.isGSTNoVisible = false;
                    this.isUdyamNoVisible = false;
                    this.isHUFDeedVisible = false;
                    this.isTrustDeedVisible = false;
                    this.isSoleProp = false;
                }
                /*else{
                    this.isRegNoVisible = false;
                    this.isGSTNoVisible = false;
                    this.isUdyamNoVisible = false;
                    this.isCINVisible = false;
                    this.isLLPVisible = false;
                    this.isHUFDeedVisible = false;
                    this.isTrustDeedVisible = false;
                }*/
            }

            this.isInputValid(fldName);
            this.isCheckValidity();
        }
    }

    handleOnBlur(event) {
        let inputValue = event.target.value;
        let fldName = event.target.name;
        //  console.log('this.ApplicantRecord[fldName]',this.ApplicantRecord[fldName]);
        console.log('inputValue ' + inputValue);
        console.log('fldName ' + fldName);
        if (fldName == 'Aadhaar_Number__c' || fldName == 'PAN__c' || fldName == 'Voter_Id__c') {
            if (this.ApplicantRecord.CIBIL_Status__c != '' && this.ApplicantRecord.CIBIL_Status__c != null) {
                if (this.ApplicantRecord[fldName] == null && inputValue != null) {
                    this.showToastEvent('Info', 'Please fetch CIBIL again as KYC is added.', 'Info');
                }
            }
        }
    }

    hideShowAppRecType() {
        this.showAppRecType = false;
        setInterval(() => {
            this.showAppRecType = true;;
        }, 200);
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

    	
    checkKYCSame(kycName , kycValue) {	
        console.log('kycName',kycName);	
        console.log('kycValue',kycValue);	
        let isKycSame = false;	
        this.applicantLst.forEach(element => {	
            if( (this.addNewApplicant || this.applicantId != element.Id) && !element.IsInactive__c && element.Customer_Type__c == 'Individual' ){	
            	
            console.log('element.Aadhaar_Number__c',element.Aadhaar_Number__c);	
            if (kycName =='Aadhaar_Number__c' && element.Aadhaar_Number__c == kycValue) {	
                isKycSame = true;	
            }	
            else if (kycName =='PAN__c' && element.PAN__c == kycValue) {	
                isKycSame = true;	
            }	
            else if (kycName =='Voter_Id__c' && element.Voter_Id__c == kycValue) {	
                isKycSame = true;	
            }	
            else if (kycName =='Driving_License_Id__c' && element.Driving_License_Id__c == kycValue) {	
                isKycSame = true;	
            }	
            else if (kycName =='Passport_Number__c' && element.Passport_Number__c == kycValue) {	
                isKycSame = true;	
            }	
            else if (kycName =='NPR__c' && element.NPR__c == kycValue) {	
                isKycSame = true;	
            }	
            else if (kycName =='NREGA__c' && element.NREGA__c == kycValue) {	
                isKycSame = true;	
            }
            if(this.recordTypeName == 'Guarantor'){//SFAU-4038
                if(kycName == 'Mobile_Number__c' && element.Mobile_Number__c == kycValue){ 
                isKycSame = true;	
            }
              }//END
            }	
        });	
        return isKycSame;	
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
        else if (event.target.value === 'NPR') {
            this.isEnabledNpr = true;
        }
        else if (event.target.value === 'NREGA') {
            this.isEnabledNrega = true;
        }
        else if (event.target.value === 'CKYC') {
            this.isEnabledCkyc = true;
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
            this.ApplicantRecord.Voter_Id__c = '';
        }
        else if (valueRemoved === 'Driving Licence') {
            this.isEnabledDrivingLicence = false;
            this.ApplicantRecord.Driving_License_Id__c = '';
        }
        else if (valueRemoved === 'Passport') {
            this.isEnabledPassport = false;
            this.ApplicantRecord.Passport_Number__c = '';
        }
        else if (valueRemoved === 'NPR') {
            this.isEnabledNpr = false;
            this.ApplicantRecord.NPR__c = '';
        }
        else if (valueRemoved === 'NREGA') {
            this.isEnabledNrega = false;
            this.ApplicantRecord.NREGA__c = '';
        }
        else if (valueRemoved === 'CKYC') {
            this.isEnabledCkyc = false;
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
        let visibledFieldList = this.visibledFields;
        let inputFields = this.template.querySelectorAll(".validate");
        console.log("inputFields--> ", inputFields);
        inputFields.forEach(inputField => {

            if (inputFieldName == '') {
                if (!inputField.checkValidity() && visibledFieldList.includes(inputField.name)) {
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

    checkIfAnyKYCDocumentChanged(){
        let applicantRecord = this.ApplicantRecord;
        let booleanResult = false;
        if(applicantRecord.Aadhaar_Number__c != this.allAdditionalInformationvaluesInit.initAadharData){
            booleanResult = true;
        }
        if((applicantRecord.PAN__c!=undefined) && (applicantRecord.PAN__c != this.allAdditionalInformationvaluesInit.initPanData)){
            booleanResult = true;
        }
        if(!this.checkAdditionalKYCDocChange(this.allAdditionalInformationvalues, this.allAdditionalInformationvaluesInit.initAdditionalDocList)){
            booleanResult = true;
        }
        return booleanResult;
    }

    checkAdditionalKYCDocChange(additionalDocArray, additionalDocArrayInit){
        return Array.isArray(additionalDocArray) &&
               Array.isArray(additionalDocArrayInit) &&
               additionalDocArray.length === additionalDocArrayInit.length &&
               additionalDocArray.every((val, index) => val === additionalDocArrayInit[index]);
    }

    updateApplicant() {

        console.log('in update method');
        if (this.isInputValid('') && this.isCheckValidity()) {
            console.log('in update method');
            console.log('this.applicantId', this.applicantId);

            if (this.applicantId) {
                this.isloading = true;
                this.ApplicantRecord['Id'] = this.applicantId;
                this.ApplicantRecord['Customer_Type__c'] = this.customerType;

                if (this.oldAadhaarValue != this.ApplicantRecord['Aadhaar_Number__c']) {
                    this.ApplicantRecord['KYC_Status__c'] = '';
                }
                if (this.oldPanValue != this.ApplicantRecord['PAN__c']) {
                    this.ApplicantRecord['PAN_verification_Status__c'] = 'Not Verified';
                }
                if(this.ApplicantRecord.hasOwnProperty('Loan__c')){
                    delete this.ApplicantRecord['Loan__c']
                }
                if(this.ApplicantRecord.hasOwnProperty('RecordTypeId')){
                    delete this.ApplicantRecord['RecordTypeId']
                }

                this.updateRec();
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
                        //Obj.isAdditionalKYCChanged = this.checkIfAnyKYCDocumentChanged();
                        console.log('Obj', Obj);

                        this.dispatchEvent(new CustomEvent('next', {
                            detail: Obj
                        }));
                        console.log('this.customerType ' + this.customerType);
                        if (this.customerType == 'Non Individual') {
                            console.log('this.ApplicantRecord const ' + this.ApplicantRecord['Constitution_Type__c']);
                            if (this.ApplicantRecord['Constitution_Type__c'] != 'Sole Proprietary' && this.ApplicantRecord['Constitution_Type__c'] != 'HUF') {
                                this.showToastEvent('Info', 'Please add a BO under the same Loan Application', 'Info');
                            }
                        }
                    })
                    .catch(error => {

                        this.isloading = false;
                        this.showToastEvent('Error creating record', error.body.message, 'error');
                        console.log("error inside updateRecord-- ", error);

                    });
            }
            else {
                if (this.isVerified) {
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
                            Obj.isAdditionalKYCChanged = this.checkIfAnyKYCDocumentChanged();
                            console.log('Obj', Obj);
                            this.updateRec();
                            this.dispatchEvent(new CustomEvent('next', {
                                detail: Obj
                            }));
                            console.log('this.customerType ' + this.customerType);

                            if (this.customerType == 'Non Individual') {
                                console.log('this.ApplicantRecord const ' + this.ApplicantRecord['Constitution_Type__c']);
                                if (this.ApplicantRecord['Constitution_Type__c'] != 'Sole Proprietary' && this.ApplicantRecord['Constitution_Type__c'] != 'HUF') {
                                    //this.showToastEvent('Info', 'Please add a BO under the same Loan Application', 'Info');
                                    const event = new ShowToastEvent({
                                        title: 'Info',
                                        message: 'Please add a BO under the same Loan Application',
                                        variant: 'Info',
                                        mode: 'dismissible'

                                    });
                                    this.dispatchEvent(event);
                                }
                            }
                        })
                        .catch(error => {
                            this.isloading = false;
                            this.showToastEvent('Error creating record', error.message || error.body.message, 'error');
                            console.log("error inside createRecord--", error);

                        });

                }
                else {
                    if (!this.isVerified) {
                        console.log('Not verified');

                        this.reportOtpVerficationValidity("Please generate and verify OTP");
                    }
                }

            }



        }
        else {
            const Obj = {};
            Obj.applicantRecord = this.ApplicantRecord;
            Obj.errorOnChild = this.errorOnChild;
            Obj.next = this.errorOnChild ? false : true;
            Obj.isPanMandatory = this.isPanMandatory;
            console.log('Obj', Obj);

            this.dispatchEvent(new CustomEvent('next', {
                detail: Obj
            }));
        }


    }

    updateRec() {
        updateDocChecklistRec({ applicntRecord: this.ApplicantRecord })
            .then((result) => {
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                console.log("Error inside updateDocChecklistRec " + error);
            });
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
                        if (!this.appRecTypeVal) {
                            if ((this.currentApplicantRecord && this.currentApplicantRecord.RecordType && this.currentApplicantRecord.RecordType.Name == rec.customerType) ||
                            (this.ApplicantRecord && this.ApplicantRecord.RecordType && this.ApplicantRecord.RecordType.Name == rec.customerType)) {
                                console.log('isPanMandate ' + rec.isPanRequired);
                                this.isPanMandatory = rec.isPanRequired;
                            }
                        }
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
    hanldeOcrClick(event) {
        console.log('clickButton' + event.currentTarget.dataset.name);
        //alert('OCRBUTTONCLICK'+event.currentTarget.dataset.name);
        this.template.querySelector("c-los-generic-document-upload").handleOCRClickParent();
    }
    hanldeUploadClick(event) {
        if(this.blnRestrictEdit){
            this.showToastEvent('Access Restricted', 'You cannot upload document due to Insufficient Access', 'error');
        }
        this.docName = event.currentTarget.dataset.name;
        this.showUploadComponent = false;
        console.log('uploadValue' + event.currentTarget.dataset.name);
        setTimeout(() => {
            this.showUploadComponent = true;
        }, 500);
    }
    docImageBase64='';
    handleSuccess(event) {
        if (event.detail.isSuccess && event.detail.showOCRInParent) {
            console.log('Inside Final Success!!!!');
            this.dataValues = [];
            event.detail.ocrData.forEach(element => {
                if( element.key == 'documentBase64'){
                    if (element.value !== undefined && element.value !== null) {
                        this.docImage = 'data:image/png;base64,' +  element.value;
                    }
                    this.docImageBase64 = element.value;
                    delete this.dataValues['documentBase64'];
                } else if (element.key == 'Aadhar Number') {
                    let maskedValue = element.value;
                    maskedValue = maskedValue === undefined || maskedValue === null ? '' : ('********' + maskedValue.substring(maskedValue.length - 4));
                    this.dataValues.push({key: element.key, value: maskedValue});
                } else {
                    this.dataValues.push(element);
                }

            });
            this.applicantRec = event.detail.applicantRec;
            this.documentChkRecord = event.detail.documentChkRecord;
            this.documentNumber = event.detail.documentNumber;
            this.isAadhar = event.detail.isAadhar;
            this.contentVersionId = event.detail.contentVersionId;
            this.eventdocName = event.detail.docName;
            this.showOCRDetails = true;
        } else if (event.detail.isSuccess && event.detail.showGreenTick) {
            this.getVersionFiles();
            this.showUploadComponent = false;
        } else if (event.detail.isSuccess) {
            console.log('losAddIndNonIndClone NO OCR & Success');
            this.getVersionFiles();
            this.showUploadComponent = false;
        } else {
            this.showToastEvent('Error', event.detail.errorMessage, 'error');
            //this.showUploadComponent = false;
        }

    }
    okClick() {
        this.updateRecords(true);
    }
    notOkClick() {
        //this.updateRecords(false);
        console.log('');
        //this.showUploadComponent = false;
        this.showOCRDetails = false;
        this.showUploadComponent = false;

    }
    updateRecords(isOkBoolean) {
        this.isloading = true;
        let obj = JSON.parse(this.applicantRec);
        obj['documentBase64'] = this.docImageBase64;
        this.applicantRec = JSON.stringify(obj);
        
        updateOCRDate({ applicantRec: this.applicantRec, documentChkRecord: this.documentChkRecord, isAadhar: this.isAadhar, isOk: isOkBoolean, contentVersionId: this.contentVersionId })
            .then(result => {
                this.isloading = false;
                let parseResult = JSON.parse(result);
                if (parseResult.isSuccess) {
                    this.showToastEvent('Success', 'Details Updated Succesfully!!', 'success');
                    this.showUploadComponent = false;
                    const resultEvent = { isSuccess: true };
                    const documentHandlerEvent = new CustomEvent('documentsuccess', {
                        detail: resultEvent
                    });
                    this.dispatchEvent(documentHandlerEvent);
                    if (this.eventdocName == DocumentPan) {
                        this.ApplicantRecord.PAN__c = this.documentNumber;
                    } else if (this.eventdocName == DocumentVoter) {
                        this.ApplicantRecord.Voter_Id__c = this.documentNumber;
                    } else if (this.eventdocName == DocumentAadhaar) {
                        this.ApplicantRecord.Aadhaar_Number__c = this.documentNumber;
                        this.aadhaarNumberOnUi = this.documentNumber;
                        this.maskNumber();
                        if (this.documentNumber != this.oldAadhaarValue && this.oldAadhaarValue) {
                            this.generateAadhaarToken(this.documentNumber);
                        }

                    } else if (this.eventdocName == DocumentDL) {
                        this.ApplicantRecord.Driving_License_Id__c = this.documentNumber;
                    } else if (this.eventdocName == DocumentPassport) {
                        this.ApplicantRecord.Passport_Number__c = this.documentNumber;
                    }
                    this.showOCRDetails = false;
                    this.showUploadComponent = false;
                    this.isloading = false;
                    setTimeout(() => {
                        this.getVersionFiles();
                    }, 1000);


                } else {
                    let errorMsge = parseResult.message ? parseResult.message : 'We Encountered an Error while updating details!!';
                    this.showToastEvent('Error', errorMsge, 'error');
                    this.showUploadComponent = false;
                    const resultEvent = { isSuccess: false };
                    const documentHandlerEvent = new CustomEvent('documentsuccess', {
                        detail: resultEvent
                    });
                    this.dispatchEvent(documentHandlerEvent);
                    this.showOCRDetails = false;
                    this.showUploadComponent = false;
                    this.isloading = false;
                }
            })
            .catch(error => {
                this.isloading = false;
                this.error = error;
                console.log('error', error);
                this.showUploadComponent = false;
            })
    }
    showToastEvent(titleValue, messageValue, variantValue) {
        const event = new ShowToastEvent({
            title: titleValue,
            message: messageValue,
            variant: variantValue
        });
        this.dispatchEvent(event);
    }
    hanleCancel() {
        this.showUploadComponent = false;
        this.docName = '';

    }
    handleOCRButton(event) {
        if (event.detail.isSuccess) {
            let dataVlaue = '[data-id=\"' + event.detail.docName + '\"]';
            if (this.isMobile) {
                this.template.querySelector(dataVlaue).classList.remove('slds-hide');
            }
        }
    }

    renderedCallback() {
        if (this.visibledFields) {
            this.visibledFields.forEach(input => {
                if (this.template.querySelector('[data-id="' + input + '"]') != null && this.template.querySelector('[data-id="' + input + '"]').classList.contains('slds-hide')) {
                    this.template.querySelector('[data-id="' + input + '"]').classList.remove('slds-hide');
                }
            });
        }
    }


    oneDocumentMandatory() {

        if (this.customerType == 'Individual') {
            return this.mandatoryForInd();
        }
        else if (this.customerType == 'Non Individual') {
            return this.mandatoryForNonInd();
        }
    }

    mandatoryForInd() {
        let aadhaarNumber = this.ApplicantRecord.Aadhaar_Number__c;
        let pan = this.ApplicantRecord.PAN__c;
        let cifNo = this.ApplicantRecord.CIF_No__c;
        let voterId = this.ApplicantRecord.Voter_Id__c;
        let drivingLicenseId = this.ApplicantRecord.Driving_License_Id__c;
        let passportNumber = this.ApplicantRecord.Passport_Number__c;
        let npr = this.ApplicantRecord.NPR__c;
        let nrega = this.ApplicantRecord.NREGA__c;
        let ckyc = this.ApplicantRecord.CKYC__c;
        let phone = this.ApplicantRecord.Mobile_Number__c;
        //Removed pan from below line - Bug 2439
        if (!aadhaarNumber && !cifNo && !voterId && !drivingLicenseId && !passportNumber && !npr && !nrega && !ckyc) {
            this.showToastEvent("", "Please fill atleast any one document details below", "error");
            return true;
        }

          if(aadhaarNumber){	
            if(this.checkKYCSame('Aadhaar_Number__c', aadhaarNumber) == true){	
                this.showToastEvent("", "Aadhaar Number can not be same under the current Application.", "error");	
                return true;	
            }	
        }	
        if(pan){	
           if(this.checkKYCSame('PAN__c', pan) == true && this.customerType == 'Individual'){	
                this.showToastEvent("", "PAN can not be same under the current Application.", "error");	
                return true;	
            }
        }	
        if(cifNo){	
            if(this.checkKYCSame('CIF_No__c', cifNo) == true){	
                this.showToastEvent("", "CIF No can not be same under the current Application.", "error");	
                return true;	
            }	
        }	
        if(voterId){	
            if(this.checkKYCSame('Voter_Id__c', voterId) == true){	
                this.showToastEvent("", "VoterId can not be same under the current Application.", "error");	
                return true;	
            }	
        }	
        if(drivingLicenseId){	
            if(this.checkKYCSame('Driving_License_Id__c', drivingLicenseId) == true){	
                this.showToastEvent("", "Driving Licence can not be same under the current Application.", "error");	
                return true;	
            }	
        }	
        if(passportNumber){	
            if(this.checkKYCSame('Passport_Number__c', passportNumber) == true){	
                this.showToastEvent("", "Passport can not be same under the current Application.", "error");	
                return true;	
            }	
        }	
        if(npr){	
            if(this.checkKYCSame('NPR__c', npr) == true){	
                this.showToastEvent("", "NPR can not be same under the current Application.", "error");	
                return true;	
            }	
        }	
        if(nrega){	
            if(this.checkKYCSame('NREGA__c', nrega) == true){	
                this.showToastEvent("", "NREGA can not be same under the current Application.", "error");	
                return true;	
            }	
        }	
        if(ckyc){	
            if(this.checkKYCSame('CKYC__c', ckyc) == true){	
                this.showToastEvent("", "CKYC can not be same under the current Application.", "error");	
                return true;	
            }	
        }
        if(this.recordTypeName == 'Guarantor'){ // Added for SFAU-4038
            if(phone){
             if(this.checkKYCSame('Mobile_Number__c', phone) == true){	
                this.showToastEvent("", "Mobile can not be same under the current Application.", "error");	
                this.enterOTPValue = '';
                this.isVerifiedNumber = false;
                return true;	
            }	
             }
        }//END
        
        return false;
    }

    mandatoryForNonInd() {

        if(!this.ApplicantRecord.Constitution_Type__c){
            this.showToastEvent("", "Please select Constitution Type", "error");
            return true;
        }//handling done if user has not selected Constitution Type and clicked on next R2-31
        let constituteType = this.ApplicantRecord.Constitution_Type__c;
        let fldsToCheck = ["CIF_No__c", "GST_NO__c", "TIN__c", "CIN__c", "Reg_No__c", "UDYAM_Registration_Number__c", "CKYC__c",
        "Trust_Deed__c","HUF_Deed__c","LLP_Agreement__c","Utility_Bills_Electricity__c","Utility_Bills_Landline_Phone__c",
        "Utility_Bills_Water__c","Importer_Exporter_Code_IEC_Certificate__c","Income_Tax_Return__c","PAN__c"];
        let counterCheck = 0;

        if (constituteType == "Sole Proprietary") {
            for (let i = 0; i < fldsToCheck.length; i++) {
                if(fldsToCheck[i]=='Utility_Bills_Electricity__c' || fldsToCheck[i]=='Utility_Bills_Landline_Phone__c' || fldsToCheck[i]=='Utility_Bills_Water__c' || 
                fldsToCheck[i]=='Importer_Exporter_Code_IEC_Certificate__c' || fldsToCheck[i]=='Income_Tax_Return__c' || fldsToCheck[i]=='Reg_No__c' || fldsToCheck[i]=='GST_NO__c' || fldsToCheck[i]=='UDYAM_Registration_Number__c' || fldsToCheck[i]=='CIF_No__c'){
                    let value = this.ApplicantRecord[fldsToCheck[i]];
                    if (value) {
                        counterCheck++;
                    }
                }
            }
            if (counterCheck < 2) {
                this.showToastEvent("", "Please fill atleast any two KYC details below", "error");
                return true;
            }
        }
        else{
            for (let i = 0; i < fldsToCheck.length; i++) {
                let value = this.ApplicantRecord[fldsToCheck[i]];
                if(constituteType.includes('Limited Liability Partnership')){
                    if(fldsToCheck[i]=='LLP_Agreement__c' || fldsToCheck[i]=='CIN__c' || fldsToCheck[i]=='CIF_No__c' || fldsToCheck[i]=='PAN__c'){
                        if (value) {
                            counterCheck++;
                        }
                    }
                }
                else if(constituteType.includes('Public Limited') || constituteType.includes('Private Limited')){
                    if(fldsToCheck[i]=='Reg_No__c' || fldsToCheck[i]=='CIN__c' || fldsToCheck[i]=='CIF_No__c' || fldsToCheck[i]=='PAN__c'){
                        if (value) {
                            counterCheck++;
                        }
                    }
                }
                else if (constituteType.includes('Society') || constituteType.includes('AOP')) {
                    if(fldsToCheck[i]=='Reg_No__c' || fldsToCheck[i]=='CIF_No__c' || fldsToCheck[i]=='PAN__c'){
                        if (value) {
                            counterCheck++;
                        }
                    }
                }
                else if (constituteType.includes('Firm')) {
                    if(fldsToCheck[i]=='Reg_No__c' || fldsToCheck[i]=='UDYAM_Registration_Number__c' || fldsToCheck[i]=='CIF_No__c' || fldsToCheck[i]=='PAN__c'){
                        if (value) {
                            counterCheck++;
                        }
                    }
                }
                else if (constituteType.includes('HUF')) {
                    if(fldsToCheck[i]=='HUF_Deed__c' || fldsToCheck[i]=='CIF_No__c' || fldsToCheck[i]=='PAN__c'){
                        if (value) {
                            counterCheck++;
                        }
                    }
                }
                else if (constituteType.includes('Trust')) {
                    if(fldsToCheck[i]=='Reg_No__c' || fldsToCheck[i]=='Trust_Deed__c' || fldsToCheck[i]=='CIF_No__c' || fldsToCheck[i]=='PAN__c'){
                        if (value) {
                            counterCheck++;
                        }
                    }
                }

            }
            if (counterCheck < 1) {
                this.showToastEvent("", "Please fill atleast any one KYC details below", "error");
                return true;
            }
        }
        return false;
    }

    updateDocVerifictn(applicantRecord, docVerStatus) {
        updateDocVerification({ applicntRecord: applicantRecord, status: docVerStatus })
            .then((result) => {
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                console.log("Error inside updateDocVerification-- " + error.body.message);
            });
    }

    @api async nextHandler() {
        if (!this.checkPANValidation()) {
            this.dispatchEvent(new CustomEvent('addharupdate'));
            return;
        }
        let result;
        if(this.mobileError ==true){
            this.showToastEvent("", "This mobile number is blocked", "error");	
            this.dispatchEvent(new CustomEvent('addharupdate'));
        }
        else
        {
            if(this.isPanMandatory && !this.ApplicantRecord["PAN__c"] ){
                this.showToastEvent("", "Pan is mandatory for this application.", "error");	
                this.dispatchEvent(new CustomEvent('addharupdate'));
                return;
            }

        if ((this.ApplicantRecord["Aadhaar_Number__c"] != null && this.ApplicantRecord["Aadhaar_Number__c"] != undefined) && (this.ApplicantRecord["Aadhaar_Number__c"].length == 12 || this.ApplicantRecord["Aadhaar_Number__c"].length == 16) && this.ApplicantRecord["Aadhaar_Number__c"] != this.oldAadhaarValue) {
            console.log('Aadhaar_Number__c%%%%' + this.ApplicantRecord["Aadhaar_Number__c"]);

            if (this.ApplicantRecord["Aadhaar_Number__c"].includes('*')) {
                let aadhaarField = this.template.querySelector(".aadhaar");
                aadhaarField.setCustomValidity("Invalid Aadhar Number. Please Re-Enter.");
                aadhaarField.reportValidity();
                this.dispatchEvent(new CustomEvent('addharupdate'));
                return;
            }
            result = await getTokenViaAddharNumber({ applicantId: this.applicantId, strAadhaarNumber: this.ApplicantRecord["Aadhaar_Number__c"] });

            let responseVal = JSON.parse(result);
            if(responseVal != null && responseVal.additionalResponse != null){
                console.log('inside -->',responseVal.additionalResponse);
                this.ApplicantRecord['Aadhaar_Number__c'] = responseVal.additionalResponse;
                this.ApplicantRecord['KYC_Status__c'] = '';
            }else if(responseVal != null){
                let checklist = responseVal.checklistRecord;
                this.showToastEvent('Error', 'API Error: ' + checklist.Name + ' Response: ' + responseVal.statusCode + '- ' + responseVal.status , 'error');
                this.dispatchEvent(new CustomEvent('addharupdate'));
                return;
            }            
        }
        let oneDocMand = this.oneDocumentMandatory();
        console.log('oneDocMandatory '+oneDocMand);
        if (!oneDocMand && this.isInputValid2() && this.aadhaarValidation() && this.validationForAdditionalFlds()) {
            this.updateApplicant();
            this.dispatchEvent(new CustomEvent('addharupdate'));
            if ((this.oldDocVerifObj.oldGstNo != this.ApplicantRecord["GST_NO__c"]) || (this.oldDocVerifObj.oldUdyamNo != this.ApplicantRecord["UDYAM_Registration_Number__c"])
                || (this.oldDocVerifObj.oldCinNo != this.ApplicantRecord["CIN__c"])) {
                this.updateDocVerifictn(this.ApplicantRecord, "Not Verified");
            }
        }
        else{
            this.dispatchEvent(new CustomEvent('addharupdate'));
        }
    }
    }

    validationForAdditionalFlds() {
        const allValid = [
            ...this.template.querySelectorAll('.validate'),
        ].reduce((validSoFar, inputCmp) => {
            console.log('inout valid '+inputCmp.name+' value '+inputCmp.value);
            if(inputCmp.name=='CIF_No__c' && !inputCmp.value){
                inputCmp.setCustomValidity("");
            }
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {
            return true;
        } else {
            return false;
        }
    }

    aadhaarValidation() {

        if (this.aadhaarNumberOnUi) {
            let aadhaarNumberLenght = this.aadhaarNumberOnUi.length;
            let aadhaarField = this.template.querySelector(".aadhaar");
            if (aadhaarNumberLenght != 12 && aadhaarNumberLenght != 16) {
                this.showToastEvent("", "Please Enter 12 digits or 16 digits number in Aadhar Number", "error");
                aadhaarField.setCustomValidity("Please Enter 12 digits or 16 digits number");
                aadhaarField.reportValidity();
                return false;
            }
            else {
                aadhaarField.setCustomValidity("");
                aadhaarField.reportValidity();
                return aadhaarField.checkValidity();
            }
        }
        else {
            return true;
        }
    }

    isInputValid2() {
        let allValid = true;
        let inputFields = this.template.querySelectorAll(".validationForMix");
        let getPan = this.template.querySelector('[data-id="PAN"]');

        for (let inputField of inputFields) {
            if (inputField.value && !(inputField.checkValidity())) {
                inputField.reportValidity();
                allValid = false;
            }
            else {
                inputField.setCustomValidity("");
            }
        }
        if (!getPan.checkValidity()) {
            this.showToastEvent("", "PAN is Mandatory for NI Customer", "error");//R2-31
            getPan.reportValidity();
            allValid = false;
        }
        else {
            getPan.setCustomValidity("");
        }

        return allValid;
    }

    generateAadhaarToken(strAadhaar) {
        console.log('strAadhaar' + strAadhaar);
        getTokenViaAddharNumber({
            applicantId: this.applicantId,
            strAadhaarNumber: strAadhaar
        })
            .then((result) => {
                result = JSON.parse(result);
                console.log('Aadhaar Result' + result);
                if (result != null && result.additionalResponse != null) {
                    this.ApplicantRecord['Aadhaar_Number__c'] = result.additionalResponse;
                    this.ApplicantRecord['KYC_Status__c'] = '';
                    console.log('this.ApplicantRecordAadhhar' + this.ApplicantRecord['Aadhaar_Number__c']);
                    return result;
                }else if(result != null){
                    let responseVal = JSON.parse(result);
                    let checklist = responseVal.checklistRecord;
                        this.showToastEvent('Error', 'API Error: ' + checklist.Name + ' Response: ' + responseVal.statusCode + '- ' + responseVal.status , 'error');
                }
            })
            .catch((error) => {
                console.log('Aadhaar Error' + error);
                this.error = error;
                return null;
            });
    }

    checkPANValidation() {
        let isValid = true;
        let inputField = this.template.querySelector('[data-id="PAN"]');
        let pan = this.ApplicantRecord.PAN__c;
        console.log('pan ' + inputField?.value);
        if (inputField?.value != null && inputField?.value.length > 4) {
            let digit = inputField.value.charAt(3);
            console.log('digit ' + digit);
            if (this.ApplicantRecord?.Customer_Type__c == 'Individual' && digit != 'P') {
                isValid = false;
            }
            else if (this.ApplicantRecord?.Customer_Type__c == 'Non Individual') {
                if (this.ApplicantRecord?.Constitution_Type__c?.includes('Trust') && digit != 'T') {
                    isValid = false;
                }
                else if (this.ApplicantRecord?.Constitution_Type__c?.includes('Firm') && digit != 'F') {
                    isValid = false;
                }
                else if (this.ApplicantRecord?.Constitution_Type__c?.includes('HUF') && digit != 'H') {
                    isValid = false;
                }
                else if ((this.ApplicantRecord?.Constitution_Type__c?.includes('Public Limited') || this.ApplicantRecord?.Constitution_Type__c?.includes('Private Limited')) && digit != 'C') {
                    isValid = false;
                }
                else if (this.ApplicantRecord?.Constitution_Type__c?.includes('Sole Proprietary') && digit != 'P') {
                    isValid = false;
                }
                else {
                    isValid = true;
                }
                console.log('isvalid ' + isValid);
            }
            if (!isValid) {
                this.showToastEvent('Error', 'PAN Number is not valid for this Constitution Type', 'error');
                inputField.setCustomValidity("PAN Number is not valid for this Constitution Type");
                inputField.reportValidity();
            }
            else {
                inputField.setCustomValidity("")
            }
        }
        return isValid;
    }

    isFourWheelerApp = false;

    getLoanApplication() {
        getLoanApplication({
            recId: this.recordId
        }).then(result => {
            let data = result.loanApplication;
            this.opsKycActionApproved = result.loanApplication.OPS_KYC_Action__c=='Approve'?true:false
            let product = result.product;
            const rtis = this.objectInfo.data.recordTypeInfos;
            console.log('recordtypes ' + JSON.stringify(rtis));
            let guarantorId = '';
            let coApplicantId = '';
            let boId = '';
            Object.keys(rtis).forEach(element => {
                if (rtis[element].name == 'Guarantor') {
                    guarantorId = rtis[element].recordTypeId;
                }
                if (rtis[element].name == 'Co-Applicant') {
                    coApplicantId = rtis[element].recordTypeId;
                }
                if (rtis[element].name == 'BO') {
                    boId = rtis[element].recordTypeId;
                }
            })
            console.log('ids ' + guarantorId + ' ' + coApplicantId);
            this.loanAppStage = data?.Stage__c;
            this.loanRecType = data?.RecordType.Name;
            this.isFourWheelerApp = product.isFourWheeler;
            if (data?.Stage__c == 'QDE' || (data?.Stage__c == 'DDE' && product.isFourWheeler)) {
                this.isStageNotQDE = false;
            }
            else if ((this.currentApplicantRecord && this.currentApplicantRecord.RecordType && this.currentApplicantRecord?.RecordType?.Name != 'Guarantor' && this.currentApplicantRecord?.RecordType?.Name != 'Co-Applicant' && this.currentApplicantRecord?.RecordType?.Name != 'BO') ||
                (this.currentApplicantRecord?.RecordTypeId != guarantorId && this.currentApplicantRecord?.RecordTypeId != coApplicantId && this.currentApplicantRecord?.RecordTypeId != boId)) {
                this.isStageNotQDE = true;
            }//added check for BO R2-2637
            
            if((data.RecordType.Name == 'Commercial Vehicle' || data.RecordType.Name == 'Construction Equipment' ) && this.ApplicantRecord.Customer_Type__c != 'Non Individual'){ //R2-1865 fix added == instead of =
                this.AdditionalInformationoptions = this.AdditionalComInformationoptions;
                this.isCommercial =true;
            }
            
            
            setTimeout(() => {
                if(this.opsKycActionApproved){
                    this.template.querySelectorAll('lightning-input').forEach(input=>{
                        input.disabled=true
                    })
                    this.template.querySelectorAll('lightning-combobox').forEach(input=>{
                        input.disabled=true
                    })
                }
                this.isLoading=false
            }, 3000);

            
        })
            .catch(error => {
                console.log('error ' + JSON.stringify(error));
            })
    }

    get isBoDisabled(){
        return !(this.loanAppStage == 'QDE' || (this.isFourWheelerApp && this.loanAppStage == 'DDE') );
    }
}