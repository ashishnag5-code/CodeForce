import { LightningElement, track, wire, api } from 'lwc';
import getApplicants from '@salesforce/apex/Ausfb_RelatedApplicantController.getApplicants';
import getApplicant from '@salesforce/apex/Ausfb_RelatedApplicantController.getApplicant';
import deleteApplicantRecord from '@salesforce/apex/Ausfb_RelatedApplicantController.deleteApplicant';
import checkMandatoryDocumentsUpload from '@salesforce/apex/Ausfb_RelatedApplicantController.checkMandatoryDocuments';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import APPLICANT_OBJECT from '@salesforce/schema/Applicant__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getVisibleFieldsForLosAddIndNonInd from '@salesforce/apex/LosQuickLoanController.getVisibleFieldsForLosAddIndNonInd';
import Valid_InactiveUser_Display_Profiles from '@salesforce/label/c.InactiveApplicantsListValidProfileName';
import { getRecord } from 'lightning/uiRecordApi';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import user_Id from '@salesforce/user/Id';
import logged_In_User_Name from '@salesforce/schema/User.Name';
import logged_In_User_ProfileName from '@salesforce/schema/User.Profile.Name';
import LightningConfirm from "lightning/confirm";
import LightningAlert from "lightning/alert";
import coApplicantValidationForTractor from '@salesforce/apex/Ausfb_RelatedApplicantController.coApplicantValidationForTractor';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
    createMessageContext
  } from 'lightning/messageService';
import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c';

export default class Ausfb_RelatedApplicansComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @api currentApplicantRecord;
    @api boolIsWizardMode = false;
    @api spinnerImage;
    @track showInActiveSection = false;
    isLoading = false;
    showMainSection = true;
    addNewApplicant = false;
    showApplicantInsertion = true;
    viewMorePartial = false;
    editApplicant = false;
    applicantLst = [];
    appRecTypes = [];
    recordCount;
    customerNameVal = '';
    bureauScoreVal = '';
    customerTypeVal = '';
    appRecTypeVal = '';
    hasPanVerified = '';
    editRecordId;
    isPanMandatory = false;
    errorOnChild;
    flowName;
    childToFlow;
    boolReFetchData;
    appCount;
    coAppCount;
    grntrCount;
    customerType;
    isShowSwap = true;
    isShowDelete = true;
    visibledFields;
    showCustomerDetail = false;
    applicantIdInput = '';
    isCustomerDetailsSaved;
    @track validUserProfilesForInactiveList = Valid_InactiveUser_Display_Profiles.split(',');
    @track userProfileName = '';
    @track inactiveRecordCount = 0;
    @track inactiveApplicantList = [];
    @track renderInactiveSection = false;
    subscription = null;
@track isApplicantEditRestricted;


    @track objectInfo;
    @wire(getRecord, { recordId: user_Id, fields: [logged_In_User_Name,logged_In_User_ProfileName]}) 
    currentUserInfo({error, data}) {
        if (data) {
            this.userProfileName = data.fields.Profile.displayValue;
            this.showInActiveSection = (this.validUserProfilesForInactiveList.includes(this.userProfileName));
        
        } else if (error) {
            this.error = error ;
        }
    }

    @wire(getObjectInfo, { objectApiName: APPLICANT_OBJECT })
    objectInfo;
    /*
        GetrecordTypeInfo() {
            // Returns a map of record type Ids 
            const rtis = this.objectInfo.data.recordTypeInfos;
            Object.keys(rtis).forEach(element => {
                console.log('RT Id', rtis[element].recordTypeId);
                console.log('RT Name', rtis[element].name);
                if (rtis[element].name == 'Applicant' || rtis[element].name == 'Co-Applicant' || rtis[element].name == 'Guarantor') {
                    this.appRecTypes.push({ label: rtis[element].name, value: rtis[element].recordTypeId });
                }
            });
        }
        */


        get isIndividual(){
            return this.customerTypeVal == 'Individual';
        }

    GetrecordTypeInfo() {
        // Returns a map of record type Ids 

        const rtis = this.objectInfo.data.recordTypeInfos;
        Object.keys(rtis).forEach(element => {
            console.log('RT Id', rtis[element].recordTypeId);
            console.log('RT Name', rtis[element].name);
            console.log('this.customerTypeVal', this.customerTypeVal);
            console.log('this.customerType', this.customerType);
            if (this.customerTypeVal == 'Individual') {
                if ((rtis[element].name == 'Applicant') || rtis[element].name == 'Co-Applicant' || rtis[element].name == 'Guarantor' || rtis[element].name == 'BO') {
                    this.appRecTypes.push({ label: rtis[element].name, value: rtis[element].recordTypeId });
                }
            }
            else if (this.customerTypeVal == 'Non Individual') {
                if ((this.appCount == 0 && rtis[element].name == 'Applicant') || rtis[element].name == 'Co-Applicant' || rtis[element].name == 'Guarantor') {
                    this.appRecTypes.push({ label: rtis[element].name, value: rtis[element].recordTypeId });
                }
            }
        });
        console.log('this.appRecTypes', this.appRecTypes);

    }

    connectedCallback() {
        console.log('In Related Applicant Component');
        console.log('objectApiName' + this.objectApiName);
        this.getApplicants();
        this.subscribeToMessageChannel()
    }

    getCustomerType(recordId, actionType) {
        console.log('Inside getVisibleFields');
        getVisibleFieldsForLosAddIndNonInd({ strScreen: 'losAddIndNonInd', recordId: recordId, strCustomerTypeId: '' })
            .then(result => {
                this.customerType = result.customerType;
                this.visibledFields = result.visibleFields;
                console.log('visible field result is ' + JSON.stringify(result));
                result.visibleFields.forEach(input => {
                    if (this.template.querySelector('[data-id="' + input + '"]') != null) {
                        this.template.querySelector('[data-id="' + input + '"]').classList.remove('slds-hide');
                    }
                });
                if (actionType == "swap") {

                    this.editApplicant = true;
                    getApplicant({
                        recId: this.editRecordId
                    })
                        .then(data => {
                            console.log('data is ' + JSON.stringify(data));
                            if (data) {
                                this.customerNameVal = data.Customer_Name__c;
                                this.bureauScoreVal = data.Bureau_Score__c;
                                this.customerTypeVal = data.Customer_Type__c;
                                this.appRecTypeVal = data.RecordTypeId;
                                this.hasPanVerified = data.PAN_verification_Status__c;
                                this.appRec = data;
                                this.isLoading = false;
                                this.GetrecordTypeInfo();
                            }
                        })
                        .catch(error => {
                            console.log('error is ' + JSON.stringify(error));
                            this.isLoading = false;
                            this.appRec = undefined;
                        })
                }
                if (actionType == "edit") {
                    //inside record page

                    if (this.objectApiName == 'Loan_Application__c' && !this.boolIsWizardMode) {
                        this.addNewApplicant = true;
                        this.flowName = 'Edit_Applicant_QDE';
                        this.childToFlow = 'Edit_Applicant_QDE_Default';
                        this.boolReFetchData = true;
                    }
                    else {
                        this.dispatchEvent(new CustomEvent('wizardevent', {
                            detail: { value: this.editRecordId, name: 'RelatedApplicant', mode: 'edit' }
                        }));
                    }
                    this.isLoading = false;
                }

            })
            .catch(error => {
                console.log('result is ' + error)
            })


    }

    getApplicants() {
        console.log('Loan App Id-->' + JSON.stringify(this.recordId));

        getApplicants({
            loanAppRecId: this.recordId
        })
            .then(data => {
                if (data && data.length > 0) {
                    // Profile check added to display inactive user also to certin profile member->3548
                    let updatedDataList = [];
                    this.inactiveApplicantList=[] //R2-38
                    data.forEach(rec=>{
                        if(!rec.IsInactive__c){
                            updatedDataList.push(rec);
                        }
                        if(rec.IsInactive__c){
                            this.inactiveApplicantList.push(rec);
                        }
                        
                    })
                    data = updatedDataList;
                    this.inactiveRecordCount = this.inactiveApplicantList.length;
                    this.renderInactiveSection = this.inactiveRecordCount>0;
                    console.log('inactive '+JSON.stringify(this.inactiveApplicantList));
                
                    this.applicantLst = data;
                    this.recordCount = data.length;
                    this.appCount = 0;
                    this.coAppCount = 0;
                    this.grntrCount = 0;
//SFAU-4295
                      this.isApplicantEditRestricted = this.applicantLst[0].Loan__r.OPS_KYC_Action__c=='Approve'?true:false
                    //For 2W show delete,add till QDE Stage, for 4W show delete,add till DDE stage
                    if(this.applicantLst[0].Loan__r.RecordType.Name=='Two Wheeler'){
                        this.isShowDelete = this.applicantLst[0].Loan__r.Stage__c == 'QDE' ? true : false;
                        this.showApplicantInsertion = this.applicantLst[0].Loan__r.Stage__c == 'QDE' ? true : false;
                    }
                    else if(this.applicantLst[0].Loan__r.RecordType.Name=='Four Wheeler'){
                        this.isShowDelete = this.applicantLst[0].Loan__r.Stage__c == 'DDE' ? true : (this.applicantLst[0].Loan__r.Stage__c == 'QDE');
                        this.showApplicantInsertion = this.applicantLst[0].Loan__r.Stage__c == 'DDE' ? true : (this.applicantLst[0].Loan__r.Stage__c == 'QDE');
                    }
                    //this.isShowDelete = this.applicantLst[0].Loan__r.Stage__c == 'QDE' ? true : false;  //added by Gaurav to show delete icon only on QDE stage (Bug:SFAU-3357)
                    this.applicantLst.forEach(recType => {
                        recType.isApplicant = recType.RecordType.Name == 'Applicant';
                        recType.isIndividual = recType.Customer_Type__c == 'Individual';
                        if (recType.RecordType.Name == 'Applicant') {
                            this.appCount = this.appCount + 1;
                            if(!recType.IsInactive__c && recType.Loan__r.RecordType.Name=='Tractor'){
                                this.coApplicantValidationForTractor(recType.Id)
                            }
                        }
                        else if (recType.RecordType.Name == 'Co-Applicant') {
                            this.coAppCount = this.coAppCount + 1;
                        }
                        else if (recType.RecordType.Name == 'Guarantor') {
                            this.grntrCount = this.grntrCount + 1;
                        }
                        /*
                        this.isCustomerDetailsSaved = false;
                        if (recType.Is_Customer_Details_Saved__c == true){
                            this.isCustomerDetailsSaved = true;
                        }
                        */
                    });

                }
                else {
                    console.log('Here');
                    this.recordCount = 0;
                    this.appCount = 0;
                    this.coAppCount = 0;
                    this.grntrCount = 0;
                    this.applicantLst = [];
                }
                this.isShowSwap = this.recordCount > 1 ? true : false;  //added by Gaurav to show swap icon only on QDE stage (Bug:SFAU-2682) {NOTE by Vinoth-Note - Swap is applicable (Button should be visible only when there are more than one party in a deal)}
                //console.log('appCount', this.appCount);
                //console.log('coAppCount', this.coAppCount);
                //console.log('grntrCount', this.grntrCount);
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
                this.applicantLst = [];
                //this.accounts = undefined;
            })

    }

    //R2-36
    coApplicantValidationForTractor(appl){
        /*coApplicantValidationForTractor({applicantId:appl}).then(data=>{
            if(data){
                this.showMessage(data.message, data.status);
            }
        })*/
        this.template.querySelector('c-co-applicant-validation-message').coApplicantValidationForTractor()
    }


    handleRowAction(event) {
const actionType = event.currentTarget.dataset.button;
         //4295 start
         if(this.isApplicantEditRestricted && actionType != "edit"){
            this.showMessage('Customer Details cannot be Changed as KYC is already Approved', 'error');
            return
        }
        //4295 end
        this.isLoading = true;
        const recordId = event.currentTarget.dataset.id;
        
        this.showMainSection = false;
        this.editRecordId = recordId;
        console.log('editRecordId is ' + this.editRecordId);
        //this.getCustomerType(recordId, actionType);
        if (actionType == "swap") {
            // R2-2387
            //this.GetrecordTypeInfo();
            // R2-2387
            getApplicant({
                recId: this.editRecordId
            })
                .then(data => {
                    
                    if (data) {
                        console.log('data is ' + JSON.stringify(data));
                        if(data.RecordType.Name=='Applicant'){
                        this.editApplicant = false;
                        this.showMainSection = true;
                        this.showMessage('Applicant can not be swapped.', 'warning');
                        }
                        else{
                        this.editApplicant = true;
                        }
                        this.customerNameVal = data.Customer_Name__c;
                        this.bureauScoreVal = data.Bureau_Score__c;
                        this.customerTypeVal = data.Customer_Type__c;
                        this.appRecTypeVal = data.RecordTypeId;
                        this.hasPanVerified = data.PAN_verification_Status__c;
                        this.appRec = data;
                        this.isLoading = false;
                        // R2-2387
                        this.GetrecordTypeInfo();
                        // R2-2387
                    }
                })
                .catch(error => {
                    console.log('error is ' + JSON.stringify(error));
                    this.isLoading = false;
                    this.appRec = undefined;
                })
        }
        if (actionType == "delete") {
            this.handleConfirmClick(recordId);
            this.showMainSection = true;
            this.isLoading = false;
        }

        if (actionType == "edit") {
            //inside record page

            if (this.objectApiName == 'Loan_Application__c' && !this.boolIsWizardMode) {
                this.addNewApplicant = true;
                this.flowName = 'Edit_Applicant_QDE';
                this.childToFlow = 'Edit_Applicant_QDE_Default';
                this.boolReFetchData = true;
            }
            else {
                this.dispatchEvent(new CustomEvent('wizardevent', {
                    detail: { value: this.editRecordId, name: 'RelatedApplicant', mode: 'edit' }
                }));
            }
            this.isLoading = false;
        }

    }

    async handleConfirmClick(recordId) {
        const result = await LightningConfirm.open({
            message: "Are you sure you want to delete ?",
            variant: "default", // headerless
            label: "Confirmation"
        });
        //Confirm has been closed
        //result is true if OK was clicked
        if (result) {
            this.deleteApplicant(recordId);
        } else {
            //and false if cancel was clicked
        }
    }

    deleteApplicant(recordId) {
        deleteApplicantRecord({
            applicantRecId: recordId,
        })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    this.getApplicants();
                    this.showMessage('Applicant deleted successfully.', 'success');
                }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
            })
    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll(".validate");
        inputFields.forEach(inputField => {
            if (!inputField.value && visibledFieldList.includes(inputField.name)) {
                inputField.setCustomValidity("Complete this field");
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }


    handleApplicantType(event) {
        this.appRecTypeVal = event.target.value;
        console.log('appRecTypeVal', this.appRecTypeVal);
        this.checkMandatoryDocumentsUploaded();
        console.log('isPanMandatory', this.isPanMandatory);

    }



    handleReset() {
        this.appRecTypeVal = '';
        this.appRecTypes = [];

    }

    handleSubmit(event) {


        console.log('isPanMandatory', this.isPanMandatory);
        event.preventDefault();
        console.log('event.detail.fields', event.detail.fields);
        const fields = event.detail.fields;
        fields.RecordTypeId = this.appRecTypeVal;

        let recordTypeName;
        this.appRecTypes.forEach(recType => {
            if (recType.value == this.appRecTypeVal) {
                recordTypeName = recType.label;
            }
        });

        if (this.isInputValid()) {
            console.log('this.hasPanVerified', this.hasPanVerified);
            if ((this.isPanMandatory && this.hasPanVerified == 'Verified') || !this.isPanMandatory) {
                if ((this.appCount == 0 && recordTypeName == 'Applicant') || recordTypeName != 'Applicant')
                    this.template.querySelector('lightning-record-edit-form').submit(fields);
                else
                    this.showMessage('There is already an Applicant exists.', 'warning');
            }
            else {
                this.showMessage('Please Upload and Verify the Pan Card.', 'warning');

            }
        }

        console.log('onsubmit event recordEditForm' + JSON.stringify(event.detail.fields));
    }

    checkMandatoryDocumentsUploaded() {
        this.isPanMandatory = false;
        checkMandatoryDocumentsUpload({
            //recId: this.recordId,
            recId: this.editRecordId //R2-38
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
        // return isUploaded;


    }



    handleSuccess(event) {
        this.isLoading = true;
        console.log('onsuccess event recordEditForm', event.detail.id);
        this.showMessage('Record Updated Successfully', 'success');
        this.editApplicant = false;
        this.showMainSection = true;
        this.handleReset();
        this.getApplicants();
        this.isLoading = false;
    }


    handleRecordUpdateCancel() {
        this.editApplicant = false;
        this.showMainSection = true;
        this.handleReset();
    }

    showMessage(message, variant) {
        const event = new ShowToastEvent({
            title: '',
            variant: variant,
            mode: variant === 'error' ? 'sticky' : 'dismissible',
            message: message
        });
        this.dispatchEvent(event);
    }

    navigateToAppRecordPage(event) {
        console.log('App Id', event.currentTarget.dataset.id);
        this.navigateToRecordPage(event.currentTarget.dataset.id);

    }

    navigateToRecordPage(objectRecordid) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: objectRecordid,
                objectApiName: 'Applicant__c',
                actionName: 'view'
            },
        });
    }

    handleGotoRelatedList() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Loan_Application__c',
                relationshipApiName: 'Applicants__r',
                actionName: 'view'
            },
        });
    }


    handleAdditionalInformationClick(event) {
        restricAccess({
            compName: 'ausfb_RelatedApplicansComponent' ,loanId: this.recordId
        })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to add Applicant',
                        variant: 'error',
                        mode : 'sticky'
                    });
                    this.dispatchEvent(evt);
                }else{
        if(this.applicantLst){
        console.log('this.applicantLst.length', this.applicantLst.length);
        if (this.applicantLst.length > 10) {
            this.showMessage('Maximum 11 customer types can be added under a loan application', 'warning');
        }
        else if (!this.boolIsWizardMode) {
            this.addNewApplicant = true;
            this.flowName = 'Edit_Applicant_QDE';
            this.childToFlow = 'Edit_Applicant_QDE_Default';
            this.boolReFetchData = false;
        }
        else {
            console.log('appCount', this.appCount);
            this.dispatchEvent(new CustomEvent('wizardevent', {
                detail: { value: '', name: 'RelatedApplicant', mode: 'add', addcount: this.appCount }
            }));
        }
        }
                }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
            })
        
    }

    getIsCustomerDetailSaved(applicantData){
        let activeApplicantData = [];
        for(let d in applicantData){
            if(!applicantData[d].IsInactive__c){
                activeApplicantData.push(applicantData[d]);
            }
        }
        activeApplicantData.forEach(app=>{
            if(!app.IsInactive__c){
            app.IsCustomerDetailSaved = ((app.Is_Customer_Details_Saved__c == true) ||(app.Customer_Type__c == 'Non Individual'))?true:false;
            }
            //app.IsCustomerDetailSaved = ((app.Is_Customer_Details_Saved__c == true) ||(app.Customer_Type__c == 'Non Individual'))?true:false;
        })
        for(let val of activeApplicantData){
            if(!val.IsCustomerDetailSaved){
                return false;
            }
        }
        return true;
    }

    @api async nextHandler() {
        const result = await getApplicants({ loanAppRecId: this.recordId });
        if (result) {
            console.log('result------>',JSON.stringify(result));
            this.isCustomerDetailsSaved = false;
            let data = result;
            this.isCustomerDetailsSaved = this.getIsCustomerDetailSaved(data);
            // data.forEach(app => {
            //     if(!app.IsInactive__c){
            //         this.isCustomerDetailsSaved = false;
            //         if ((app.Is_Customer_Details_Saved__c == true) ||(app.Customer_Type__c == 'Non Individual')) {
            //             this.isCustomerDetailsSaved = true;
            //         }
            //         else if((app.Customer_Type__c == 'Individual') && (app.Is_Customer_Details_Saved__c == false)){
            //             this.isCustomerDetailsSaved = false;
            //             return;
            //         }

                    
            //         // else if(!app.Is_Customer_Details_Saved__c){
            //         //     if(app.Loar__r.hasOwnProperty('Customer_Type__c')){
            //         //         if(app.Loar__r.Customer_Type__c == 'Non Individual'){
            //         //             this.isCustomerDetailsSaved = true;
            //         //         }
            //         //     }
            //         // }
            //     }
            // });

        }
        // /R2-2806
        if(((this.applicantLst[0].Loan__r.Stage__c=='QDE' && this.applicantLst[0].Loan__r.RecordType.Name=='Two Wheeler') || (this.applicantLst[0].Loan__r.Stage__c!='QDE' && (this.applicantLst[0].Loan__r.RecordType.Name=='Four Wheeler' || this.applicantLst[0].Loan__r.RecordType.Name=='Construction Equipment' || this.applicantLst[0].Loan__r.RecordType.Name=='Commercial Vehicle' || this.applicantLst[0].Loan__r.RecordType.Name=='Tractor' ))) && !this.checkBOPresent()){
        // /R2-2806
            this.showMessage('Please add a BO under the same Loan Application', 'error');
            return;
        }
        if(((this.applicantLst[0].Loan__r.Stage__c=='QDE' && this.applicantLst[0].Loan__r.RecordType.Name=='Two Wheeler') || (this.applicantLst[0].Loan__r.Stage__c!='QDE' && this.applicantLst[0].Loan__r.RecordType.Name=='Four Wheeler')) && !this.checkIndMandatory()){
            this.showMessage('Please add Individual before proceeding', 'error');
            return;
        }
        console.log('in related component next handler'+this.isCustomerDetailsSaved);
        if (this.appCount == 0) {
            this.showMessage('There must be an Applicant record to proceed further.', 'warning');
        }
        if (this.isCustomerDetailsSaved == false && this.applicantLst[0].Loan__r.Stage__c == 'DDE' && this.showCustomerDetail == false) {
            this.showMessage('Please fill all the mandatory customer details to proceed further.', 'warning');
        }
        let checkValidationForAge = '';
        if (this.template.querySelector('c-ausfb_customer-detail-component') == null) {
            checkValidationForAge = true;
        }
        else {
            checkValidationForAge = this.template.querySelector('c-ausfb_customer-detail-component').checkAgeValidation();
        }
        const Obj = {};
        if (this.appCount == 0 || checkValidationForAge == false || (this.isCustomerDetailsSaved == false && this.applicantLst[0].Loan__r.Stage__c == 'DDE' && this.showCustomerDetail == false)) {
            Obj.next = false;
        }
        else {
            Obj.next = true;
        }
        //  Obj.next = true;
        Obj.applicantRecord = this.applicantIdInput;
        this.errorOnChild = this.appCount == 0 ? 'There must be an Applicant in order to proceed further.' : '';
        Obj.applicantRecord = this.currentApplicantRecord;
        Obj.errorOnChild = this.errorOnChild;
        //  Obj.next = this.errorOnChild == '' ? true : false;
        console.log('Obj', Obj);
        this.dispatchEvent(new CustomEvent('next', {
            detail: Obj
        }));
    }

    handleCustomerDetail(event) {
        this.showCustomerDetail = true;
        this.showMainSection = false;
        this.applicantIdInput = event.currentTarget.dataset.id;
    }

    saveCustomerDetailHandler(event) {
        this.showCustomerDetail = false;
        this.showMainSection = true;
    }

    checkIndMandatory(){
        console.log('appl list '+JSON.stringify(this.applicantLst));
        let flag = false;
        let primaryApp = {};
        for(var i in this.applicantLst){
            if(this.applicantLst[i].RecordType.Name=='Applicant'){
                primaryApp = this.applicantLst[i];
            }
            if(this.applicantLst[i].RecordType.Name=='Applicant' && this.applicantLst[i].Customer_Type__c=='Non Individual' && (this.applicantLst[i].Constitution_Type__c=='HUF' || this.applicantLst[i].Constitution_Type__c=='Sole Proprietary')){
                flag = true;
                break;
            }
        }
        if(flag){
            for(var i in this.applicantLst){
                if(this.applicantLst[i].Customer_Type__c=='Individual'){
                    return true;
                }
            }
        }
        else{
            return true;
        }
        return false;
    }

    checkBOPresent(){
        console.log('appl list '+JSON.stringify(this.applicantLst));
        let flag = false;
        let primaryApp = {};
        for(var i in this.applicantLst){
            if(this.applicantLst[i].RecordType.Name=='Applicant'){
                primaryApp = this.applicantLst[i];
            }
            if(this.applicantLst[i].Customer_Type__c=='Non Individual' && this.applicantLst[i].Constitution_Type__c!='HUF' && this.applicantLst[i].Constitution_Type__c!='Sole Proprietary'){
                flag = true;
                break;
            }
        }
        if(flag){
            for(var i in this.applicantLst){
                if(this.applicantLst[i].RecordType.Name=='BO'){
                    return true;
                }
                if(this.applicantLst[i].Is_BO__c==true){
                    return true;
                }
            }
        }
        else{
            return true;
        }
        return false;
    }
    checkIndMandatory(){
        console.log('appl list '+JSON.stringify(this.applicantLst));
        let flag = false;
        let primaryApp = {};
        for(var i in this.applicantLst){
            if(this.applicantLst[i].RecordType.Name=='Applicant'){
                primaryApp = this.applicantLst[i];
            }
            if(this.applicantLst[i].RecordType.Name=='Applicant' && this.applicantLst[i].Customer_Type__c=='Non Individual' && (this.applicantLst[i].Constitution_Type__c=='HUF' || this.applicantLst[i].Constitution_Type__c=='Sole Proprietary')){
                flag = true;
                break;
            }
        }
        if(flag){
            for(var i in this.applicantLst){
                if(this.applicantLst[i].Customer_Type__c=='Individual'){
                    return true;
                }
            }
        }
        else{
            return true;
        }
        return false;
    }

    messageContext = createMessageContext();
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                pageRefreshOnMaterialFieldChange,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }
    
    handleMessage(message){
        if(message.refreshPage=='Yes'){
            this.template.querySelector('c-co-applicant-validation-message').coApplicantValidationForTractor()
        }
    }  
    
    unsubscribeToMessageChannel(){
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    
    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

}