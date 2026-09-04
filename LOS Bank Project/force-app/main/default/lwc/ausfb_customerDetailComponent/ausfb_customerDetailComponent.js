import { LightningElement, api, wire, track } from 'lwc';
import emailVerificationHandler from '@salesforce/apex/EmailVerificationHandler.doRestCallout';
import restrictedDomain from '@salesforce/apex/CustDetCompController_AUFSB.getRestrictedDomains';
import getApplicant from '@salesforce/apex/CustDetCompController_AUFSB.getApplicant';
import updateApplicant from '@salesforce/apex/CustDetCompController_AUFSB.updateApplicant';
import callValidateNameMatch from '@salesforce/apex/CustDetCompController_AUFSB.callValidateNameMatch';
import validateMobile from '@salesforce/apex/CustDetCompController_AUFSB.validateMobile';
import getCustomMetaRecStageProfle from '@salesforce/apex/CustDetCompController_AUFSB.getCustomMetaRecStageProfle';
import { getObjectInfo, getPicklistValues, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import APPLICANT_OBJECT from '@salesforce/schema/Applicant__c';
import getVisibleFields from '@salesforce/apex/CustDetCompController_AUFSB.getVisibleFields';
import checkPrimaryApplicant from '@salesforce/apex/CustDetCompController_AUFSB.checkPrimaryApplicant';
import DcumentMasterCustomerImage from '@salesforce/label/c.DcumentMasterCustomerImage';
import cameraicon from '@salesforce/resourceUrl/cameraicon';
import biometricIcon from '@salesforce/resourceUrl/biometricIcon';
import getFaceMatchCall from '@salesforce/apex/CustDetCompController_AUFSB.getFaceMatch';
import getHRPByVehicleType from '@salesforce/apex/CustDetCompController_AUFSB.getHighRiskProfilesByVehicleType';
import LightningAlert from 'lightning/alert';
import getCustomerPhoto from '@salesforce/apex/CustDetCompController_AUFSB.getCustomerPhoto';
import getMaterialFields from '@salesforce/apex/Utility.getMaterialFields';
import checkMaterialFields from '@salesforce/apex/Utility.checkMaterialFields';
import emailVerificationApi from '@salesforce/apex/EmailVerificationHandler.emailVerificationApi';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import checkKartaCondition from '@salesforce/apex/CustDetCompController_AUFSB.checkKartaCondition';
import validateRecordEdit from '@salesforce/apex/ComponentProfileRestrictionController.validateRecordEdit';
import karzaNameMatchCallout from '@salesforce/apex/CustDetCompController_AUFSB.karzaNameMatchCallout';
/*import EXISTINGCUSTOMER_FIELD from '@salesforce/schema/Applicant__c.Existing_Customer__c';
import TITLE_FIELD from '@salesforce/schema/Applicant__c.Title__c';
import FIRSTNAME_FIELD from '@salesforce/schema/Applicant__c.First_Name__c';
import MIDDLENAME_FIELD from '@salesforce/schema/Applicant__c.Middle_Name__c';
import LASTNAME_FIELD from '@salesforce/schema/Applicant__c.Last_Name__c';
import DOB_FIELD from '@salesforce/schema/Applicant__c.Dob__c';
import AGE_FIELD from '@salesforce/schema/Applicant__c.Age__c';
import GENDER_FIELD from '@salesforce/schema/Applicant__c.Gender__c';
import FATHERNAME_FIELD from '@salesforce/schema/Applicant__c.Father_Name__c';
import SPOUSENAME_FIELD from '@salesforce/schema/Applicant__c.Spouse_Name__c';
import HIGHRISKPROFILE_FIELD from '@salesforce/schema/Applicant__c.High_risk_Profile__c';
import EMPLOYEEID_FIELD from '@salesforce/schema/Applicant__c.AU_Employee_ID__c';
import EMPLOYMENTSTATUS_FIELD from '@salesforce/schema/Applicant__c.AU_Employment_status__c';
import MOBILENUMBER_FIELD from '@salesforce/schema/Applicant__c.Mobile_Number__c';
import EMAIL_FIELD from '@salesforce/schema/Applicant__c.Email__c';
import AUEMPLOYEE_FIELD from '@salesforce/schema/Applicant__c.AU_Employee__c';
import NAMEOFEMPLOYEE_FIELD from '@salesforce/schema/Applicant__c.Name_of_Employee_AU__c';
import RESIDENTIALSTATUS_FIELD from '@salesforce/schema/Applicant__c.Residential_Status__c';*/

import aadhaar from '@salesforce/resourceUrl/aadhaar';
import ckyc from '@salesforce/resourceUrl/ckyc';
import maleCoApplicantRelationship from '@salesforce/label/c.CoApplicantMaleRelationshipOptions';
import femaleCoApplicantRelationship from '@salesforce/label/c.CoApplicantFemaleRelationshipOptions';
import { CO_APPLICANT_RECORD_TYPE_LABEL, reduceErrors } from 'c/lwcutilities';
//R2-1673
import {
    APPLICATION_SCOPE,
    createMessageContext,
    MessageContext,
    publish,
    releaseMessageContext,
    subscribe,
    unsubscribe,
} from 'lightning/messageService';
import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c';

export default class Ausfb_customerDetailComponent extends LightningElement {
    isQde = false;
    cameraicon = cameraicon;
    biometricIcon = biometricIcon;
    aadhaarIconDummy = aadhaar;
    @api applicantIdInput
    @api aplicantRecord = {};
    @track applcntRecord = {};
    @api spinnerImage;
    @api boolFromRelated = false;
    loanApplctionId = '';
    oldapplicantRecord = {};
    stageProfCustmMetaDataRecs = [];
    fldForBreRunList = [];
    boolSendOtp = true;
    isVerified = false;
    boolVerify = false;
    isValidDomain = false;
    isEmailValid = false;
    isEmail = false;
    isApiDown = false;
    isDesableVerifyButton = true;
    isAUEmployee = false;
    isPhsicallyChallenged = false;
    isFaceMatchScore = false;
    isExistingCustomerDisabled = true;
    isRiskIdentification = true;
    fldLsttoVisible;
    existingCustomerPicklistValues;
    titlePicklistValues;
    genderPicklistValues;
    highRiskProfilePicklistValues;
    employmentStatusPicklistValues;
    auEmployeePicklistValues;
    residentialStatusPicklistValues;
    maritalStatusPicklistValues;
    educationQualificationPicklistValues;
    noOfDependentsPicklistValues;
    castePicklistValues;
    religionPicklistValues;
    keyPersonPicklistValues;
    politicallyExposedPersonPicklistValues;
    isCustomerHinVipPicklistValues;
    phsicallyChallengedPicklistValues;
    natutreOfPhsicallychallengePicklistValues;
    proofOfDisablityPicklistValues;
    customerImageChanged = false;
    isloading = true;
    activeSections = ['A', 'B'];
    isDisabledMaterialFlds = false;
    strEmail = ''
    isVerify = false;
    showerror = false;
    errorStr = '';
    trueValue = true;
    falseValue = false;
    @track customerImageURL = '';
    customerImageNeeded = true;
    label = {
        DcumentMasterCustomerImage
    };
    isGenderDisabled;

    faceMatch = false;
    todayDate;
    disableTitle = false;
    spousNameRequired = false;
    @track relationshipWithApplOptions = [];
    @track faceMatchScore = 0.00;
    @track defaultTitlePicklistValues = [];
    @track isLastNameRequired = true;
    @track isBO = false;
    isEditAllowed = true;
    @track blnRestrictEdit = false;
    @track blnGoNext = false;
    //17Jul Start
    cbsStatus=''; 
    firstnameDisable =false;
    middleNameDisable =false;
    lastnameDisable =false;
    dobDisable =false;
    mothernameDisable = false;
    fathernameDisable =false;
    spouseDisable =false;
    genderDisable = false;
    @track isApplicantEditRestricted=false
    primaryApplicant = {};
    messageContext = createMessageContext();

    get isFieldUpdateAllowed(){
        return !this.isEditAllowed;
    }

    // R2-17
    get isRelationWithApplicantOther(){
        return this.isTractor && this.applcntRecord?.Relationship_with_applicant__c === 'Others';
    }

    connectedCallback() {
        this.applcntRecord = this.aplicantRecord;
        this.getApplicantData();
        this.todayDate = this.getTodayDate();
        //this.disableFieldsAsPerMetadata();
        /*getApplicant({recordId: this.applicantIdInput})
            .then(result => {
                console.log('result >>'+JSON.stringify(result))

                this.applcntRecord = result;
                console.log('result.Id>>'+result.Id)
                this.oldapplicantRecord = result;
                this.isloading = false;
            })
            .catch(error => {   
                this.error = error;
                this.applcntRecord = undefined;
            }) */
        
    }

    /*
    @description - to check login user have access to edit record
    */
    checkRestrictRecord () {
        validateRecordEdit({
            compName: 'ausfb_customerDetailComponent' ,recordId: this.applicantIdInput
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
            message: 'You do not have access to change Customer Information details',
            variant: 'error',
            mode : 'sticky'
        });
        this.dispatchEvent(evt);
    }

    getTodayDate() {
        const date = new Date();

        let day = date.getDate();
        let month = date.getMonth() + 1;
        let year = date.getFullYear();
        let currentDate = `${year}-${month}-${day}`;
        return currentDate;
    }

    get disableDOB() {
        return this.applcntRecord && this.applcntRecord.KYC_Type__c == 'Aadhaar - Biometric';
    }

    loggedInUserProfile;
    isTwoWheeler = false;
    isFourWheeler = false;
    isTractor = false;
    isCE = false;
    isCV = false;
    maxEstablishmentDate;
    @api getApplicantData() {
        console.log('get applicant method')
        this.isloading = true;
        getApplicant({ recordId: this.applicantIdInput })
            .then(result => {
                console.log('result >>' + JSON.stringify(result))
                console.log('result >>' + JSON.stringify(result.applicant))
                console.log('result >>' + JSON.stringify(result.adharUrl))
                this.customerType = result.applicant.Customer_Type__c;
                this.applcntRecord = result.applicant;
                this.maxEstablishmentDate = (new Date(result.maxEstablishmentDate)).toISOString();
                this.isFourWheeler = result.typeOfWheeler.isFourWheeler;
                this.isTwoWheeler = result.typeOfWheeler.isTwoWheeler;
                this.isTractor = result.typeOfWheeler.isTractor; //R2-17
                if(result.applicant.Loan__r.RecordType.Name == 'Construction Equipment'){
                    this.isCE = true;
                }
                if(result.applicant.Loan__r.RecordType.Name == 'Commercial Vehicle'){
                    this.isCV = true;
                }
                this.loggedInUserProfile = result.userProfile;
                this.loanApplctionId = result.applicant.Loan__c;
                let applicantRecordTypeName = result.applicant.RecordType.Name;
                // R2-17
                this.primaryApplicant = result.applicant.Loan__r?.Primary_Applicant__r ?? {};

                this.genrateRelationshipWithApplOpt(result.relationShipWithApplOptions);
                let isEmailVerified = result.applicant.IsEmailVerified__c;
                this.faceMatch = result.applicant.Document_Checklists__r ? result.applicant.Document_Checklists__r[0].Face_Match__c : this.faceMatch;
                let score = result.applicant.Document_Checklists__r ? result.applicant.Document_Checklists__r[0].Match_Percentage__c : 0.00;
                this.faceMatchScore = score ? parseFloat(score).toFixed(2) : 0.00;
                let gender = result.applicant.Gender__c;
                this.cbsStatus = result.applicant.Cbs_Checked__c; //17 JUL Start
                
                this.isApplicantEditRestricted = result.applicant.Loan__r.OPS_KYC_Action__c=='Approve'?true:false
                this.isQde = result.applicant.Loan__r.Stage__c =='QDE'? true:false;
                if(this.applcntRecord.KYC_Type__c == 'Aadhaar - Biometric'){
                    this.dobDisable = true;
                }
                if(this.cbsStatus !=null){
                    if(this.cbsStatus == true ){ //|| this.cbsStatus =='Pending'
                        if(result.applicant.First_Name__c!=null){
                            this.firstnameDisable = true;
                        }
                        if(result.applicant.Middle_Name__c!=null){
                            this.middleNameDisable = true;
                        }
                        if(result.applicant.Last_Name__c!=null){
                            this.lastnameDisable = true;
                        }
                        if(result.applicant.Dob__c!=null){
                            this.dobDisable = true;
                        }
                        
                        if(result.applicant.Spouse_Name__c!=null){
                            this.spouseDisable = true;
                        }
                        if(result.applicant.Gender__c!=null){
                           this.genderDisable = true;
                        }
                    }
                } //END
              /*  if(this.isFourWheeler) {
                    let getRiskIndentification = this.template
                    this.isRiskIdentification = false;
                }  */
                this.applcntRecord.Residential_Status__c = 'Resident';
                if (gender == 'Male') {
                    this.applcntRecord.Title__c = 'Mr';
                    this.disableTitle = true;
                    this.titlePicklistValues = [];
                    this.titlePicklistValues = this.defaultTitlePicklistValues;
                }
                else if (gender == 'Female') {
                    this.disableTitle = false;
                    this.setTitlePickListValuesForFemale();
                } else {
                    this.titlePicklistValues = [];
                    this.titlePicklistValues = this.defaultTitlePicklistValues;
                    this.disableTitle = false;
                    this.applcntRecord.Title__c = '';
                }

                if (this.customerType == "Individual") {
                    this.isFaceMatchScore = true;
                }
                if (this.customerType == "Non Individual") {
                    this.isEmailRequired = true;
                }

                if (isEmailVerified) {
                    this.isVerified = true;
                    this.boolSendOtp = false;
                }
                if(this.applcntRecord.Email__c == '' || this.applcntRecord.Email__c == null ){ //START 27 JUL
                    this.isVerified = false;
                }//END

                if (applicantRecordTypeName == "Applicant") {
                    this.applcntRecord.Relationship_with_applicant__c = "Self";
                }
                if ((applicantRecordTypeName == "Co-Applicant" || applicantRecordTypeName == "Guarantor") && this.customerType == 'Individual') {
                    this.removeSelfFromRelationshipWithApplOptions( applicantRecordTypeName === CO_APPLICANT_RECORD_TYPE_LABEL && this.applcntRecord.Loan__r.Customer_Type__c === 'Individual' ? this.getRelationshipOptionsByGender( this.primaryApplicant ) : result.relationShipWithApplOptions );
                    //this.checkKartaCondition();
                    
                }
                else if ((applicantRecordTypeName == "Co-Applicant" || applicantRecordTypeName == "Guarantor") && this.customerType == 'Non Individual') {
                    this.removeSelfFromRelationshipWithApplOptions( result.relationShipWithApplOptions );                    
                }

                if(applicantRecordTypeName == "BO"){
                    this.isBO = true;
                }
                this.customerImageURL = result.customerUrl;

                if (result.customerUrl) {
                    this.customerImageNeeded = false;
                } else {
                    this.customerImageNeeded = true;
                }
                this.aadharUrl = result.adharUrl;
                //console.log('result.Id>>'+result.Id)
                let olddata = result;
                console.log('olddata>> ' + JSON.stringify(olddata))
                this.oldapplicantRecord = olddata;
                if (result.Email__c != null) {
                    this.isDesableVerifyButton = false;
                }
                //   this.applcntRecord['Existing_Customer__c'] = 'Yes';
                if (!this.applcntRecord.hasOwnProperty("Existing_Customer__c")) {
                    //this.isExistingCustomerDisabled = false; // R2-2339 fix UAT bug
                    this.applcntRecord['Existing_Customer__c'] = 'No';
                }
                if (result.applicant.AU_Employee__c == 'Yes') {
                    this.isAUEmployee = true;
                }
                else {
                    this.applcntRecord['AU_Employee__c'] = 'No';
                }
                // this.getStageProfileDataConfigRecords(this.applcntRecord);
                if(!this.applcntRecord.Last_Name__c && this.applcntRecord.First_Name__c){
                    this.isLastNameRequired = false;
                }
                if(!this.applcntRecord.High_risk_Profile__c && this.applcntRecord.Loan__c && this.applcntRecord.Loan__r.Stage__c!='QDE'){//High risk profile was getting set to normal (this value is not present in the picklist) at qde and on Land Details Screen, field validation was not working
                    //this.applcntRecord.High_risk_Profile__c = 'Normal';
                    this.applcntRecord.High_risk_Profile__c = 'No';//setting to No as Normal value is not present in the picklist
                }
                this.getVisibleFields();
                setTimeout(() => {
                    if (applicantRecordTypeName == "Applicant") {
                        this.applcntRecord.Relationship_with_applicant__c = "Self";
                        let ele = this.template.querySelector('[data-name="Relationship_with_applicant__c"]');
                        if(ele){
                            ele.disabled = true;
                        }
                    }
                }, 300);
               
                this.isloading = false;
                if (applicantRecordTypeName == "Co-Applicant" || applicantRecordTypeName == "Guarantor") {
                    this.checkKartaCondition();
                }
                // check For Restrict Record
                this.checkRestrictRecord ();
                this.disableFieldsAsPerMetadata();
            })
            .catch(error => {
                console.log('in error >> ' + error)
                this.error = error;
                this.applcntRecord = undefined;
                this.oldapplicantRecord = undefined;
                this.isloading = false;
            })
    }

    // R2-17
    getRelationshipOptionsByGender( primaryApplicant ){
        console.log({primaryApplicant});
        let options = maleCoApplicantRelationship.split(/\s*,\s*/);
        if(primaryApplicant.Gender__c === 'Female' /*&& primaryApplicant.Marital_Status__c === 'Married'*/ ){
            options = femaleCoApplicantRelationship.split(/\s*,\s*/);
        }
        return options.join(',');
    }

    removeSelfFromRelationshipWithApplOptions(relationShipWithApplOptions) {
        let splitString = relationShipWithApplOptions.split(",");
        let result = splitString.filter(Opt => Opt != 'Self');
        let mapOptions = result.map(opt => ({ label: opt, value: opt }));
        this.relationshipWithApplOptions = mapOptions;

    }

    genrateRelationshipWithApplOpt(relationShipWithApplOptions) {
        //this.applcntRecord.Relationship_with_applicant__c = 'Self'; Commenting as part of 3474
        let splitString = relationShipWithApplOptions.split(",");
        let mapOptions = splitString.map(opt => ({ label: opt, value: opt }));
        console.log(mapOptions);
        this.relationshipWithApplOptions = mapOptions;
    }

    getStageProfileDataConfigRecords(applcntRecord) {
        this.applcntRecord['Is_Customer_HIN_VIP__c'] = 'No';
        getCustomMetaRecStageProfle()
            .then(result => {
                console.log('result >>' + JSON.stringify(result))
                this.stageProfCustmMetaDataRecs = result;
                let flterRecByLoanStg = this.filterRecByLoanStage(applcntRecord, this.stageProfCustmMetaDataRecs);
                if (flterRecByLoanStg.length > 0) {
                    this.showFldsByStageOnUI(flterRecByLoanStg);
                }
            })
            .catch(error => {
                console.log('in error >> ' + error)
                this.error = error;
            })
    }



    filterRecByLoanStage(applcntRecord, stageProfCustmMetaDataRecs) {
        let applcntRecords = applcntRecord;
        let loanStage = applcntRecords.Loan__r.Stage__c;
        //let customerType    = applcntRecords.Loan__r.Customer_Type__c;
        let customerType = applcntRecords.Customer_Type__c;
        let applicantRecordType = applcntRecords.RecordType.Name;
        console.log('customerType', customerType);
        console.log('applicantRecordType', applicantRecordType);
        let stageProfCustmMetaRecs = stageProfCustmMetaDataRecs.filter(rec => {
            /*if(applicantRecordType == 'BO'){
                if(rec.Loan_Stage__c === loanStage && rec.Screen__c === (loanStage + " Customer Information") && rec.Customer_Type__c === 'Individual') {
                    return rec;
                }
            }
            else{
                */
            if (rec.Loan_Stage__c === loanStage && rec.Screen__c === (loanStage + " Customer Information") && rec.Customer_Type__c === customerType) {
                return rec;
            }
            // }
        });
        return stageProfCustmMetaRecs;
    }

    getVisibleFields(){
        this.isLoaded = true;
        let loanStage = this.applcntRecord.Loan__r.Stage__c;
        let screen = (loanStage + " Customer Information")
        let profile = 'System Administrator';
        let typeOfWheeler;
        if(loanStage == 'Credit' && this.isTwoWheeler){
            typeOfWheeler ='Two Wheeler';
        }
        else if(loanStage == 'Credit' && this.isFourWheeler){
            typeOfWheeler ='Four Wheeler';
        }
        else if(loanStage == 'Credit' && (this.isTractor || this.isCE || this.isCV)){
            typeOfWheeler ='Tractor';
        }
        /*else if(loanStage == 'Credit' && this.isCE){
            typeOfWheeler ='Tractor';
        }
        else if(loanStage == 'Credit' && this.isTractor){
            typeOfWheeler ='Tractor';
        }*/
        console.log('screen getVisibleFields '+screen)
        console.log('screen getVisibleFields '+loanStage)
        console.log('screen getVisibleFields '+profile)
        console.log('screen getVisibleFields '+typeOfWheeler)

        getVisibleFields({ strScreen : screen, strStage :loanStage, strProfile :profile, typeOfWheeler: typeOfWheeler,customerType : this.customerType})
		.then(result => {
            this.fldLsttoVisible = result;
			console.log('result is visible fields '+JSON.stringify(result));
            result.forEach(input => {
                if(this.template.querySelector('[data-id="'+input+'"]') != null){
                    this.template.querySelector('[data-id="'+input+'"]').classList.remove('slds-hide');
                }
            });
            // SFAU-3707 Start
            if(this.isFourWheeler || this.isTractor || this.isCE || this.isCV) {
                this.isRiskIdentification = false;
            }
            // SFAU-3707 End
            this.isLoaded = false;
		})
		.catch(error => {
            console.log('result is '+error)
            this.isLoaded = false;
		})
    }

    showFldsByStageOnUI(flterRecByLoanStg) {
        let fldLsttoVis = flterRecByLoanStg[0].Fields__c.split(",");
        this.fldLsttoVisible = fldLsttoVis;
        fldLsttoVis.forEach(input => {
            this.template.querySelector('[data-id="' + input + '"]')?.classList.remove('slds-hide');
        });
    }

    @wire(getObjectInfo, { objectApiName: APPLICANT_OBJECT })
    objectInfo;

    @wire(getPicklistValuesByRecordType, { objectApiName: APPLICANT_OBJECT, recordTypeId: '$objectInfo.data.defaultRecordTypeId' })
    allDataPicklistValues({ error, data }) {
        if (data) {
            this.existingCustomerPicklistValues = data.picklistFieldValues.Existing_Customer__c.values;
            this.titlePicklistValues = data.picklistFieldValues.Title__c.values;
            this.defaultTitlePicklistValues = data.picklistFieldValues.Title__c.values;
            this.genderPicklistValues = data.picklistFieldValues.Gender__c.values;
            this.employmentStatusPicklistValues = data.picklistFieldValues.AU_Employment_status__c.values;
            // this.highRiskProfilePicklistValues = data.picklistFieldValues.High_risk_Profile__c.values;
            this.auEmployeePicklistValues = data.picklistFieldValues.AU_Employee__c.values;
            this.residentialStatusPicklistValues = data.picklistFieldValues.Residential_Status__c.values;
            this.maritalStatusPicklistValues = data.picklistFieldValues.Marital_Status__c.values;
            this.educationQualificationPicklistValues = data.picklistFieldValues.Education_qualification__c.values;
            this.noOfDependentsPicklistValues = data.picklistFieldValues.No_of_Dependents__c.values;
            this.castePicklistValues = data.picklistFieldValues.Caste__c.values;
            this.religionPicklistValues = data.picklistFieldValues.Religion__c.values;
            this.keyPersonPicklistValues = data.picklistFieldValues.Key_Person__c.values;
            this.politicallyExposedPersonPicklistValues = data.picklistFieldValues.Politically_Exposed_Person__c.values;
            this.isCustomerHinVipPicklistValues = data.picklistFieldValues.Is_Customer_HIN_VIP__c.values;
            this.phsicallyChallengedPicklistValues = data.picklistFieldValues.Phsically_challenged__c.values;
            this.natutreOfPhsicallychallengePicklistValues = data.picklistFieldValues.Natutre_of_Phsically_challenge__c.values;
            this.proofOfDisablityPicklistValues = data.picklistFieldValues.Proof_of_Disablity__c.values;

        } else if (error) {
            console.log('error is ' + JSON.stringify(error));
        }
    }
    @wire(getHRPByVehicleType, { loanId: '$applcntRecord.Loan__c' })
    wiredHRPResult({ error, data }) {
        console.log({ error, data });
        if (error) {
            console.error(error);
        } else if (data) {
            const { isAccepted, hrpOptions, disableHRP } = data;
            this.highRiskProfilePicklistValues = hrpOptions.map(({ Profile__c: label }) => ({ label, value: label }));
            //SFAU-5166
            if(disableHRP){
                [...this.template.querySelectorAll('[data-name="High_risk_Profile__c"]')].forEach(field => { field.disabled = true });
            }
            //end
            if(!isAccepted){
                this.isEditAllowed = false;
                this.showToastMessage('Error', 'You can\'t make any changes to this application since you\'ve not accepted it', 'error', 'sticky');
                [...this.template.querySelectorAll('lightning-input', 'lightning-combobox')].forEach(field => { field.disabled = true });
                this.isDisabledMaterialFlds = true;
            }
        }
    }

    /*@wire(getRecord, { recordId: '$applicantIdInput', fields: [EMAIL_FIELD,NAMEOFEMPLOYEE_FIELD, RESIDENTIALSTATUS_FIELD,AUEMPLOYEE_FIELD,MOBILENUMBER_FIELD, EMPLOYMENTSTATUS_FIELD, EMPLOYEEID_FIELD, 
                                                       HIGHRISKPROFILE_FIELD,SPOUSENAME_FIELD,FATHERNAME_FIELD,GENDER_FIELD, EXISTINGCUSTOMER_FIELD,
                                                       AGE_FIELD,DOB_FIELD,LASTNAME_FIELD,MIDDLENAME_FIELD,FIRSTNAME_FIELD,TITLE_FIELD,] })
    wiredContacts({ error, data }) {
        if (data) {
            let object  = this.getSObject(data);
            console.log('object',object);
            this.applcntRecord = object;
            this.oldapplicantRecord = object;
            this.isloading = false;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.applcntRecord = undefined;
            this.isloading = false;
        }
    }*/

    getSObject(wiredData) {
        return {
            sobjectType: wiredData.apiName,
            Id: wiredData.id,
            ...Object.keys(wiredData.fields).reduce((a, f) => {
                a[f] = wiredData.fields[f].value;
                return a;
            }, {})
        };
    }

    handleValuChange(event) {
        console.log('name ' + event.target.name + 'value ' + event.target.value)

        console.log('appdata>> ' + JSON.stringify(this.applcntRecord))
        console.log('olddata>> ' + JSON.stringify(this.oldapplicantRecord))

        let fldName = event.target.name;
        let fldValue = event.target.value;

        if (fldName == "AU_Employee__c") {
            this.fldForBreRunList.push(fldName);
        }
        if (fldName == "High_risk_Profile__c" && fldValue != 'Normal') {
            this.fldForBreRunList.push(fldName);
            if(fldValue == 'Politician' || fldValue == 'Politician / Political connection'){ //Jul17
                this.applcntRecord.Politically_Exposed_Person__c = 'Yes';
            }else{
                this.applcntRecord.Politically_Exposed_Person__c = 'No';
            }
        }
        this.applcntRecord[event.target.name] = event.target.value;
        if(fldName == 'Risk_Identification__c'){
            this.applcntRecord['Risk_Identification__c'] = event.target.checked;
        }
        if (event.target.name === 'Email__c') {
            this.strEmail = event.target.value;
            this.boolSendOtp = true; //27 JUL
            this.isVerified = false; //27 JUL
            this.checkBlockedList(this.strEmail);
            let isValid = this.reportOtpVerficationValidity();
            if (isValid) {
                this.isDesableVerifyButton = false;
            } else {
                this.isDesableVerifyButton = true;
            }
        }

        if (event.target.name === 'AU_Employee__c' && event.target.value === 'Yes') {
            this.isAUEmployee = true;
        }
        else if (event.target.name === 'AU_Employee__c' && event.target.value === 'No') {
            this.isAUEmployee = false;
        }
        else if (event.target.name === 'Phsically_challenged__c' && event.target.value === 'Yes') {
            this.isPhsicallyChallenged = true;
        }
        else if (event.target.name === 'Phsically_challenged__c' && event.target.value === 'No') {
            this.isPhsicallyChallenged = false;
        } else if (event.target.name == 'Gender__c') {
            if (event.target.value == 'Male') {
                this.disableTitle = true;
                this.titlePicklistValues = [];
                this.titlePicklistValues = this.defaultTitlePicklistValues;
                this.applcntRecord.Title__c = 'Mr';
            } else if (event.target.value == 'Female') {
                // this.disableTitle = true;
                // this.applcntRecord.Title__c = 'Mrs';
	    	this.applcntRecord.Title__c = ''; // SFAU-5215
                this.disableTitle = false;
                this.setTitlePickListValuesForFemale();
            } else {
                this.titlePicklistValues = [];
                this.titlePicklistValues = this.defaultTitlePicklistValues;
                this.disableTitle = false;
            }
        } else if (event.target.name == 'Marital_Status__c') {
            if (event.target.value == 'Single') {
                this.disableTitle = true;
                this.applcntRecord.Title__c = 'Miss';
                this.spousNameRequired = false;
                // R2-17
                this.applcntRecord.Relationship_with_applicant__c = null;
                this.applcntRecord.Relation_with_Applicant_Other__c = null;
            } else if (event.target.value == 'Married') {
                this.spousNameRequired = true;
            } else {
                this.spousNameRequired = false;
            }

        }
        else if (event.target.name == 'Dob__c') {
            this.applcntRecord.Age__c = this.calculateAge(this.applcntRecord.Dob__c);
        }
        else if (event.target.name == 'Director_Identification_Number__c') {
            this.applcntRecord.Director_Identification_Number__c = event.target.value;
        }
        else if(event.target.name == 'Relationship_with_applicant__c'){
            if(this.isTractor || this.isCV){
                this.fldForBreRunList.push(event.target.name);
            }
            this.applcntRecord.Relationship_with_applicant__c = event.target.value;
            let val = event.target.value;
            console.log('@@val'+val);
            console.log('@@applicantRecordTypeName'+this.appRecordTypeName);
            if(val == 'Director' && (this.appRecordTypeName == "Co-Applicant" || this.appRecordTypeName == "BO")){
                console.log('@@iside');
                this.getDINField();
            }
            else{
                this.isDIN = false;
                this.isDINReq = false;
                this.applcntRecord.Director_Identification_Number__c = '';
            }

            // R2-17
            if( this.applcntRecord.Relationship_with_applicant__c !== 'Others' ){
                this.applcntRecord.Relation_with_Applicant_Other__c = null;
                if( this.applcntRecord.Relationship_with_applicant__c?.toLowerCase().includes('in law') ){
                    this.applcntRecord.Marital_Status__c = 'Married';
                }
            }
        }
        else if(event.target.name == 'Residential_Status__c'){
            if(this.isTractor || this.isCV){
                this.fldForBreRunList.push(event.target.name);
            }
        }
        else if(event.target.name == 'Date_of_Establishment__c'){
            if(this.isTractor){
                this.fldForBreRunList.push(event.target.name);
            }
        }
    }
    emailError=false;
    checkBlockedList(fldValue){
        validateMobile({ emailId: fldValue})
        .then(result => {
            if(result){
                this.isDesableVerifyButton = true;
                this.emailError=true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'This email id is blocked',
                        variant: 'error',
                        mode : 'sticky'
                    }),
                );
            }
            else {
                this.emailError=false;
            this.isDesableVerifyButton=false;
            }
        })
        .catch(error =>{
            this.error = error; 
        })

    }
    setTitlePickListValuesForFemale(){
        this.titlePicklistValues = [];
        this.titlePicklistValues = [{label:'Mrs',value:'Mrs'},
        {label:'Miss',value:'Miss'}]
    }

    async disableFieldsAsPerMetadata() {
        this.fieldsToBeDisabled = await getMaterialFields({ strScreen: 'Customer Details', strLoanId: this.loanApplctionId });
        if (this.fieldsToBeDisabled) {
            this.fieldsToBeDisabled.forEach((input => {
                if (this.template.querySelectorAll('[data-name="' + input + '"]')) {
                    this.template.querySelectorAll('[data-name="' + input + '"]').forEach((inputToBeDisabled => {
                        inputToBeDisabled.disabled = true
                    }))
                }
            }))
        }
    }

    handleSendOTP(event) {
        if(this.isApplicantEditRestricted){
            this.showToastMessage('', 'Email cannot be Changed as KYC is already Approved', 'error', 'sticky');
            return;
        }
        if(this.blnRestrictEdit){
            this.showToastMessage('Access Restricted', 'You do not have access to change Email', 'error', 'sticky');
            return;
        }
        this.isloading = true;
        if(this.emailValidate) {
            this.emailVerificationHandler();
        }
        console.log('email is valid');

    }

    getDINField() {
        console.log('@@iside method'+this.applcntRecord.Id);
        checkPrimaryApplicant({ appId: this.applcntRecord.Id })
            .then(data => {
                console.log('@@data'+data);
                if (data == 'mandatory') {
                    this.isDIN = true;
                    this.isDINReq = true;

                }
                else if (data == 'nonmandatory') {
                    this.isDIN = true;
                    this.isDINReq = false;

                }
                else if (data == 'No') {
                    this.isDIN = false;
                    this.isDINReq = false;

                }
            })
            .catch(error => {
                this.error = error;
            })

    }

    emailValidate() {
        var isValidVal = true;
        var inputFields = this.template.querySelector('.emailValidation');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValidVal = false;
            }
        });
        return isValidVal;
    }

    handleSubmit(event) {
        console.log('onsubmit event recordEditForm' + event.detail.fields);
    }
    onEmailChange(event) {
        this.strEmail = event.target.value;

    }

    emailVerificationHandler() {
        //var isEmailValid = false;
        emailVerificationHandler({ strEmail: this.strEmail, recordId: this.applicantIdInput })
            .then(result => {
                if (JSON.stringify(result.result) != '{}' && JSON.stringify(result) != '{}' && result.result.data.regexp && result.result.data.result) {
                    this.restrictedDomain();
                } else {
                    this.errorStr = 'please input valid email address';
                    this.isloading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: '',
                            message: 'please enter valid email address',
                            variant: 'error',
                            mode : 'sticky'
                        }),
                    );
                }

            })
            .catch(error => {
                console.log('Error inside emailVerificationHandler'+JSON.stringify(error))
                this.errorStr = reduceErrors( error )?.join?.(', ') ?? JSON.stringify( error );
                this.isloading = false;
                this.isApiDown = true;
                this.showToastMessage('', this.errorStr, 'error' );
            })
        /*console.log('this.isEmailValid>>'+this.isEmailValid)
        var isEmailValid = this.isEmailValid;
        console.log('isEmailValid>>'+isEmailValid)
        return isEmailValid;*/
    }

    restrictedDomain() {

        restrictedDomain({ domainAddress: this.strEmail })
            .then(result => {
                console.log('result restrict is ' + result);
                if (result) {
                    console.log('email domain is valid')
                    this.boolSendOtp = false;
                    this.isloading = false;
                 /*   this.isVerified = true;
                    this.applcntRecord['IsEmailVerified__c'] = this.isVerified;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: '',
                            message: 'Email is verified',
                            variant: 'success',
                        }),
                    ); */
                    this.showToastMessage('', 'Verification email has been sent on the email ID. Please verify', 'success', 'dissmissable'); //27 JUL
                    this.callEmailVerificationApi();
                }
                else {
                    this.errorStr = 'please enter valid email domain address';
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: '',
                            message: 'please enter valid email domain address',
                            variant: 'error',
                            mode : 'sticky'
                        }),
                    );
                    this.showerror = true;
                    this.isloading = false;

                }
            })
            .catch(error => {
                console.log('result is error')
                this.isloading = false;
            })
    }

    callEmailVerificationApi() {
        emailVerificationApi({ strEmail: this.strEmail, applcntRecordId: this.applicantIdInput })
            .then((result) => {
                console.log('Result-->' + result);
            })
            .catch((error) => {
                this.error = error;
                console.log('Error inside callEmailVerificationApi--' + error);
            });
    }

    handleSuccess(event) {
        console.log('onsuccess event recordEditForm', event.detail.id);
    }
    /*@api
    nextHandler(){
        console.log('return------');
        //const fields = event.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit();
        let returnObj = {
            'next' : true,
        }

    this.dispatchEvent(new CustomEvent('next', {
        detail: returnObj
    }));
      
    }*/

    updateApplicant() {
        console.log('in update method');
        console.log('applcntRecord>>' + JSON.stringify(this.applcntRecord))
        //this.applcntRecord['Id'] = applicantIdInput;
        let record = this.applcntRecord; //26JUL START
        delete record['IsEmailVerified__c'];
        delete record['Email__c'];
        this.applcntRecord = record; //26JUL END
        if (this.applcntRecord) {
            if (this.blnGoNext == true && this.blnRestrictEdit == true) {
                const Obj = {};
                Obj.applicantRecord = this.applcntRecord;
                Obj.next = true;
                console.log('Obj', Obj);

                this.dispatchEvent(new CustomEvent('next', {
                    detail: Obj
                }));
            }
            else {
                console.log('in update method >2');
                this.isloading = true;
                console.log('this.applcntRecord', this.applcntRecord);
                //4291 start
                setTimeout(() => {
                    karzaNameMatchCallout({documentType: 'AUWheels0001', applicantId: this.applcntRecord.Id})
                }, 1000); 
                setTimeout(() => {
                    karzaNameMatchCallout({documentType: 'AUWheels0002', applicantId: this.applcntRecord.Id})
                }, 2000); 
                setTimeout(() => {
                    karzaNameMatchCallout({documentType: 'AUWheels0004', applicantId: this.applcntRecord.Id})
                }, 3000); 
                setTimeout(() => {
                    karzaNameMatchCallout({documentType: 'AUWheels0005', applicantId: this.applcntRecord.Id})
                }, 4000); 
                //4291 end
                /*Promise.all([
                    karzaNameMatchCallout({documentType: 'AUWheels0001', applicantId: this.applcntRecord.Id}),
                    karzaNameMatchCallout({documentType: 'AUWheels0002', applicantId: this.applcntRecord.Id}),
                    karzaNameMatchCallout({documentType: 'AUWheels0004', applicantId: this.applcntRecord.Id}),
                    karzaNameMatchCallout({documentType: 'AUWheels0005', applicantId: this.applcntRecord.Id})
                ]).then((values) => {
                }).catch(error=>{

                })*/
                /*callValidateNameMatch({applicantRecord: this.applcntRecord}).then((data=>{

                })).catch(error=>{

                })*/
                updateApplicant({ applicant: this.applcntRecord })
                    .then(result => {
                        console.log('result ' + JSON.stringify(result));
                        this.isloading = false;
                        this.applcntRecord = result;
                        const Obj = {};
                        Obj.applicantRecord = result;
                        Obj.next = true;
                        console.log('Obj', Obj);

                        this.dispatchEvent(new CustomEvent('next', {
                            detail: Obj
                        }));
                        const payload = { recordIdOfSobject: this.applcntRecord.Id, refreshPage: 'Yes'};
                        publish(this.messageContext, pageRefreshOnMaterialFieldChange, payload);
                    })
                    .catch(error => {
                        console.log('Error '+JSON.stringify(error));
                        this.isloading = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: '',
                                message: error.body.message,
                                variant: 'error',
                                mode : 'sticky'
                            }),
                        );
                    });
            }
        }
    }

    calculateAge(birthday) {

        // Convert the date of birth string to a Date object
        let dateOfBirth = new Date(birthday);

        // Get the current date
        let currentDate = new Date();

        // Calculate the difference in years between the current date and the date of birth
        let age = currentDate.getFullYear() - dateOfBirth.getFullYear();

        // Check if the current date is before the birthday this year
        let isBeforeBirthday =
            currentDate.getMonth() < dateOfBirth.getMonth() ||
            (currentDate.getMonth() === dateOfBirth.getMonth() &&
                currentDate.getDate() < dateOfBirth.getDate());

        // Subtract 1 from the age if the current date is before the birthday
        if (isBeforeBirthday) {
            age--;
        }
        return age;

    }

    @api nextHandler() {
        //let next = (this.strEmail != '' && this.isVerified) ? true : false;
        // && (this.isVerified || this.isApiDown)
        /*if(this.isApplicantEditRestricted){
            this.showToastMessage('', 'Customer Details cannot be Changed as KYC is already Approved', 'error', 'sticky');
            return;
        }*/
       
        if(this.isApplicantEditRestricted || this.blnRestrictEdit){ //4473
            if(this.blnRestrictEdit){
                this.showToastMessage('Access Restricted', 'Customer Details were not saved due to Insufficient Access Rights', 'warning', 'sticky');
            }else if(this.isApplicantEditRestricted){
                this.showToastMessage('', 'Customer Details were not updated as KYC is already Approved', 'warning', 'sticky');
            }
            const Obj = {};
            Obj.next = true; 
            this.dispatchEvent(new CustomEvent('next', {
                detail: Obj
            }));         
        }else if(this.emailError ==true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'This Email is blocked',
                    variant: 'error',
                    mode : 'sticky'
                }),
            );
        } else {
            if (this.applcntRecord.High_risk_Profile__c == 'No' && this.applcntRecord.Politically_Exposed_Person__c == 'Yes') {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '',
                        message: 'High Risk profile can not be No if the person is politically exposed.',
                        variant: 'warning',
                    }),
                );
            }
            else if (this.applcntRecord.Mother_Name__c == 'NA'||this.applcntRecord.Mother_Name__c == 'na'||this.applcntRecord.Mother_Name__c == 'Na') {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '',
                        message: 'Mother Name can not be NA.',
                        variant: 'warning',
                    }),
                );
            }
            else if (this.applcntRecord.Spouse_Name__c == 'NA'||this.applcntRecord.Spouse_Name__c == 'na'||this.applcntRecord.Spouse_Name__c == 'Na') {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '',
                        message: 'Spouse Name can not be NA.',
                        variant: 'warning',
                    }),
                );
            }
            /* START - SFAU-5215 - Title is mandatory for Ind and Non Ind */
            else if (this.applcntRecord.Title__c == '' && this.applcntRecord.Customer_Type__c == 'Individual') {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '',
                        message: 'Title is mandatory.',
                        variant: 'warning',
                    }),
                );
            }
            /* END - SFAU-5215 - Title is mandatory for Ind and Non Ind */
            // R2-2303
            else if (this.applcntRecord.Email__c && this.boolSendOtp && !this.isDesableVerifyButton) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '',
                        message: 'Please complete email verification to proceed.',
                        variant: 'error',
                        mode: 'sticky'
                    }),
                );
            }
            // End of R2-2303
            else {
                if (this.isInputValid()) {
                    this.checkMaterialFlds();
                    if (this.applcntRecord.KYC_Type__c == 'Aadhaar - Biometric' && !this.faceMatch) {
                        let errorMessage = this.customerImageURL ? 'Face match is mandatory' : 'Live photo is mandatory'
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: '',
                                message: errorMessage,
                                variant: 'error',
                                mode : 'sticky'
                            }),
                        );
                        return
                    } else {
                        if (this.customerType == 'Individual') {
                            if (this.validateAge()) {
                                this.updateApplicant();
                            }
                        }
                        else if (this.customerType == 'Non Individual') {
                            this.updateApplicant();
                        }
                    }
                } else {
                    const Obj = {};
                    Obj.next = false; 
                    // Commented by kunal as it was going next without saving data
                    //  Obj.next = true;// changes by Yash SIT not going Next  
                    Obj.applicantRecord = this.applcntRecord;
                    console.log('Obj', Obj);

                    this.dispatchEvent(new CustomEvent('next', {
                        detail: Obj
                    }));

                    if (this.isInputValid()) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: '',
                                message: 'Email is not Verified, Please verify',
                                variant: 'error',
                                mode : 'sticky'
                            }),
                        );
                    }
                }
            }
        }
    }

    @api checkAgeValidation() {
        if(this.customerType == 'Individual'){
            let checkAge = this.validateAge();
            if (checkAge == false) {
                return false;
            }
        }

        return true;
    }

    validateAge() {
        let getAge = this.template.querySelector(`[data-name="Age__c"]`);
        let ageValue = getAge.value;
        if (ageValue < 18) {
            this.showToastMessage('', 'Age Cannot be less than 18', 'error', 'sticky');
            return false;
        }
        else {
            return true;
        }
    }

    showToastMessage(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            mode: variant === 'error' ? 'sticky' : 'dismissible',
            message: message
        });
        this.dispatchEvent(event);
    }

    /*  isInputValid() {
          let isValid = true;
          let visibledFieldList = this.fldLsttoVisible;
          console.log('visibledFieldList '+JSON.stringify(visibledFieldList))
          let inputFields = this.template.querySelectorAll(".validate");
          //&& visibledFieldList.includes(inputField.name)
          inputFields.forEach(inputField => {
              if (!inputField.value && visibledFieldList.includes(inputField.name)) {
                 // inputField.setCustomValidity("Complete this field");
                  inputField.reportValidity();
                  isValid = false;
                  console.log('field name is >>'+inputField.name);
              }
          });
          return isValid;
      } */

    isInputValid() {
        let emailCheck = true;
        let isValid = true;
        let visibledFieldList = this.fldLsttoVisible;
        console.log('visibledFieldList ' + JSON.stringify(visibledFieldList))
        let inputFields = this.template.querySelectorAll(".validate");
        //&& visibledFieldList.includes(inputField.name)
        inputFields.forEach(inputField => {
            if(inputField.name=='Last_Name__c' && !this.isLastNameRequired){

            }

            else if (!inputField.checkValidity() && (visibledFieldList.includes(inputField.name) || inputField.name=='Director_Identification_Number__c')) {
                // inputField.setCustomValidity("Complete this field");
                inputField.reportValidity();
                isValid = false;
                console.log('field name is >>' + inputField.name);
            }
        });

        if (this.applcntRecord.Mobile_Number__c == this.applcntRecord.Alternate_Mobile_Number__c) {
            this.showToastMessage('', 'Mobile and Alternate Mobile Number should be different', 'error', 'sticky');
            emailCheck = false;
        }
        if (isValid == true && emailCheck == true) {
            isValid = true;
        }
        else {
            isValid = false;
        }
        return isValid;
    }

    reportOtpVerficationValidity() {
        let isValid = true;
        let inputField = this.template.querySelector(".mobilebutton");
        console.log('inputField ' + inputField.name);
        if (!inputField.checkValidity()) {
            isValid = false;
        }
        return isValid;
    }
    handleCustomerImage(event) {
        this.isloading = true;
        if (event.detail.isSuccess) {
            this.customerImageChanged = true;
            setTimeout(() => {
                this.getCustomerImage();
            }, 1000);
        }
    }

    getCustomerImage() {
        this.isloading = true;
        getCustomerPhoto({
            recordId: this.applicantIdInput
        }).then(result => {
            this.customerImageURL = result;
            if (result) {
                this.customerImageNeeded = false;
            } else {
                this.customerImageNeeded = true;
            }
            this.isloading = false;
        })
            .catch(error => {
                //alert(JSON.stringify(error));
                console.log('in error >> ' + error)
                this.isloading = false;
            })
    }
    handleChangeCustomerImage() {
        if(this.isApplicantEditRestricted || this.blnRestrictEdit){ //4473
            if(this.blnRestrictEdit){
                this.showToastMessage('Access Restricted', 'Customer Details were not saved due to Insufficient Access Rights', 'warning', 'sticky');
            }else if(this.isApplicantEditRestricted){
                this.showToastMessage('', 'Customer Details were not updated as KYC is already Approved', 'warning', 'sticky');
            }
            return;
        }
        (this.customerImageNeeded) ? this.customerImageNeeded = false : this.customerImageNeeded = true;
    }
    handleFaceMatch() {
        this.isloading = true;
        const aadharUrl = new URLSearchParams(this.aadharUrl);
        const versionId1 = aadharUrl.get('versionId')
        console.log('aadharUrlVersisionID' + versionId1);

        const customerImageURLNew = new URLSearchParams(this.customerImageURL);
        const versionId2 = customerImageURLNew.get('versionId')
        console.log('customerImageURLVersisionID' + versionId2);
        let response = {};
        getFaceMatchCall({
            versionId1: versionId1,
            versionId2: versionId2,
            applicantId: this.applicantIdInput
        }).then(result => {
            console.log('result' + result);
            response = JSON.parse(result);
            console.log('response: ' + response);

            //let facePercentMatchScore = response.matchScore;
            let facePercentMatchScore = response.hasOwnProperty('matchScore') ? response.matchScore : 0.00;
            this.faceMatchScore = parseFloat(facePercentMatchScore.toFixed(2));
            this.faceMatch = true  // response.isMatch; Discussed on email (Kunal)
            if (response.isMatch) {
                //let faceMathcPercentage = response.matchScore;
                //this.faceMatchScore = parseFloat(faceMathcPercentage.toFixed(2));
                this.showToastMessage('Success', 'Face matched', 'success');
                this.customerImageChanged = false;
            } else {
                // let faceMathcPercentage = response.matchScore;
                // this.faceMatchScore = parseFloat(faceMathcPercentage.toFixed(2));
                this.showToastMessage('Error', 'Face not matched. Score: ' + this.faceMatchScore, 'error', 'sticky');
                const Obj = {};
                Obj.next = false;
                Obj.applicantRecord = this.applcntRecord;
                //this.faceMatchScore = response.matchScore;
                console.log('Obj', Obj);

                this.dispatchEvent(new CustomEvent('next', {
                    detail: Obj
                }));
            }
            this.isloading = false;
        })
            .catch(error => {
                console.log('in error >> ' + error)
                this.isloading = false;
            })
    }

    handleSubmitForm(event) {
        if(this.isApplicantEditRestricted){
            this.showToastMessage('', 'Customer Details cannot be Changed as KYC is already Approved', 'error', 'sticky');
            return;
        }
        if(this.emailError ==true){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'This Email is blocked',
                    variant: 'error',
                    mode : 'sticky'
                }),
            );
            }
            else{
        if(!this.isEditAllowed){
            this.showToastMessage('Error', 'You can\'t make any changes to this application since you\'ve not accepted it', 'error', 'sticky');
            return;
        };
        restricAccess({
            compName: 'ausfb_customerDetailComponent' ,loanId: this.loanApplctionId
            })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save Customer Details',
                        variant: 'error',
                        mode : 'sticky'
                    });
                    this.dispatchEvent(evt);
                }else{
        //this.updateApplicant();
        if (this.applcntRecord.High_risk_Profile__c == 'No' && this.applcntRecord.Politically_Exposed_Person__c == 'Yes') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '',
                    message: 'High Risk profile can not be No if the person is politically exposed.',
                    variant: 'warning',
                }),
            );
        }
        else if (this.applcntRecord.Mother_Name__c == 'NA'||this.applcntRecord.Mother_Name__c == 'na'||this.applcntRecord.Mother_Name__c == 'Na') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '',
                    message: 'Mother Name can not be NA.',
                    variant: 'warning',
                }),
            );
        }
        else if (this.applcntRecord.Spouse_Name__c == 'NA'||this.applcntRecord.Spouse_Name__c == 'na'||this.applcntRecord.Spouse_Name__c == 'Na') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: '',
                    message: 'Spouse Name can not be NA.',
                    variant: 'warning',
                }),
            );
        }
        else {
            if (this.isInputValid()) {
                this.checkMaterialFlds();
                if (this.customerType == 'Individual') {
                    if (this.validateAge()) {
                        this.updateApplicant();
                        this.dispatchEvent(new CustomEvent('save'));
                    }
                }
                else if (this.customerType == 'Non Individual') {
                    this.updateApplicant();
                    this.dispatchEvent(new CustomEvent('save'));
                }
            }
        }
           }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
            })
    }
    }

    checkMaterialFlds() {
        checkMaterialFields({ strScreen: 'Customer Details', strLoanId: this.loanApplctionId, lstFieldsAPI: this.fldForBreRunList })
            .then(result => {
                this.contacts = result;
            })
            .catch(error => {
                this.error = error;
            });
    }

    handleBack(event) {
        this.dispatchEvent(new CustomEvent('save'));
    }

    checkKartaCondition(){
        checkKartaCondition({
            appId: this.loanApplctionId//changed this.applcntRecord.Id to this.loanApplctionId R2-1811
        })
        .then(data=>{
            console.log('checkKartaCondition data '+JSON.stringify(data));
            if(data == true){
                let options=[]
                options=JSON.parse(JSON.stringify(this.relationshipWithApplOptions))
                console.log('here----'+ JSON.stringify(this.relationshipWithApplOptions));
                options.push({
                    label:'Karta',
                    value:'Karta'
                })
                this.relationshipWithApplOptions=options
                console.log('relationshipWithApplOptions '+JSON.stringify(this.relationshipWithApplOptions));
            }
        })
        .catch(error => {
            console.log('checkKartaCondition error '+JSON.stringify(error));
            return false;
        })
    }
}