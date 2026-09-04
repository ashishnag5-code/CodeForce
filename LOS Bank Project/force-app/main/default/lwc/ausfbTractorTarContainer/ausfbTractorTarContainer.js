import { LightningElement, api, wire, track } from 'lwc';
// Update TAR
import { updateRecord } from 'lightning/uiRecordApi';
// Getting current picklist value
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

// Current user profile name
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import PROFILE_NAME_FIELD from '@salesforce/schema/User.Profile.Name';

// Toast message display
import {toastWithMessage} from 'c/lwcutilities';

// Error Message custom label
import ERROR_MESSAGE_LABEL from '@salesforce/label/c.TAR_Tractor_New_Error_Message';

// Picklist field collateral 
import TAR_PLACE_OF_VISIT from '@salesforce/schema/Collateral__c.TAR_Place_of_Visit__c';

// Apex Data Service
import getCollateralRecord from '@salesforce/apex/AusfbTractorTarContainerController.getCollateralRecord';
import getDocumentCheckListRelatedToTar from '@salesforce/apex/AusfbTractorTarContainerController.getDocumentCheckListRelatedToTar';
import getMetadataConfig from '@salesforce/apex/AusfbTractorTarContainerController.getMetadataConfig';
import validateDocumentUpload from '@salesforce/apex/AusfbTractorTarContainerController.validateDocumentUpload';
import createApproval from '@salesforce/apex/AusfbTractorTarContainerController.createApproval';
import getApprovals from '@salesforce/apex/AusfbTractorTarContainerController.getApprovals';
import getApprovalRecs from '@salesforce/apex/AusfbTractorTarContainerController.getApprovalRecs';
import validateTARSubmitOrApproval from '@salesforce/apex/AusfbTractorTarContainerController.validateTARSubmitOrApproval'
import resetCreditVerificationOnLoan from '@salesforce/apex/CreditVerification.resetCreditVerificationOnLoan'
import getVersionFiles from '@salesforce/apex/LOSDocumentManagerController.getVersionFiles';
import submitforApprovalOrReject from '@salesforce/apex/AusfbTractorTarContainerController.submitforApprovalOrReject'
// Apex Data Service

// Ready only fields 
const readOnlyFields = new Set(['MMV_Master__c', 'Engine_Number__c', 'Chasis_Number__c', 'TAR_Status__c']);
// Ready only fields 

// Custom Spinner settings
import { getSpinnerImage } from 'c/customSpinner';
// Custom Spinner settings

// Metadata for component visibility literals
const STAGE_EDITABLE = 'Stages_Editable';
const STAGE_READ_ONLY = 'Stages_ReadOnly';
const PROFILE_DEVELOPER_NAME = 'Profile_Editable';
const PRODUCT_APPLICABLE = 'Product_Applicable';
const RECORD_TAB_CONTEXT = 'RecordTab';
const GENERAL_WIZARD_CONTEXT = 'GeneralWizard';
const QUICK_ACTION_CONTEXT = 'QuickAction';
// Metadata for component visibility literals

// Component visibility literals
const READ_ONLY_LITERAL  = 'READ_ONLY';
const NO_VISIBLE  = 'NO_VISIBLE';
const EDITABLE  = 'EDITABLE';
// Component visibility literals

// Error message document merge
const ERROR_MESSAGE_DOCUMENT_MERGE = '{documents}';

const TAR_MANDATORY_VISIBLE = new Set(['PSD','Ops Maker', 'Ops Author', 'Partially Disbursed','PDD', 'Cancelled', 'Rejected', 'Completed']);
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

export default class AusfbTractorTarContainer extends LightningElement {

    // loading spinner
    isLoading = false;
    // loading spinner
    messageContext = createMessageContext();
    // For LOS Generic component setup
    trueValue = true;
    falseValue = false;
    // For LOS Generic component setup
    subscription=null

    // Loan Id from parent component
    @api recordId; //= 'a2cHE000004HbWQ';
    // Loan Id from parent component

    // Collateral data
    collateralData ={};
    collateralId;
    collateralRecordTypeId;
    typeOfPlaceVisit = [];
    // Collateral data

    comments = '';
    approvalReq;
    isApprovalExist = false;
    @track approvalStatus;
    @track approvalRemarks;
    @track approvalApprover;
    @track approversList;
    @track isCurrentuserApprover = false;
    @track approverejectMsg ='';
    @track approveOrRejReq = false;
    @track populateAppRejComments='';
    @track submitForAppOrRej ='';
    @track subLoanAppId = '';
    @track disableallButton = false;
    activeSections = ['A', 'B'];
    disableButton = false;
    // Form Data
    tarData ={

    };
    // Form Data

    // Fields to be displayed on the form
    fieldsDisplay = [];
    @track imageFields = [];

    // Documents check
    documentCheckListData = [];

    // Metadata helper variables
    metadataConfig = [];
    profileName = '';

    // Component visibility check 
    isComponentDisabled = false;
    isComponentVisible = true;
    // Component visibility check 

    // Component visibility change based on context
    @api containerContext = RECORD_TAB_CONTEXT;
    // Component visibility change based on context

    // Custom Spinner settings
    spinnerImage
    // Custom Spinner settings
    


    // Metadata config fetch
    @wire(getMetadataConfig)
    metadataConfigFetch({error, data}){
        if(error){
            console.error('Error fetching collateral data' + JSON.stringify(error));
            toastWithMessage(this, 'ERROR!', 'error', 'Error fetching collateral data ' + error);
        }
        if(data){
            this.isLoading = true;
            this.metadataConfig = data; 
            this.handleGetCollateralData();
        }
    }

    get disableSubmitForApprovalButton(){
        return this.disableButton || this.isComponentDisabled;
    }

    // Fetching picklist value
    @wire(getPicklistValues, { recordTypeId: '$collateralRecordTypeId', fieldApiName: TAR_PLACE_OF_VISIT })
    wiredPicklistValues({ error, data }) {
        console.log('===== data =====',data);
        if (data) {
            this.typeOfPlaceVisit = data.values.map(item => ({
                label: item.label,
                value: item.value,
            }));
        } else if (error) {
            toastWithMessage(this, 'ERROR!', 'error', 'Error fetching picklist value' + error);
        }
    }

    connectedCallback(){
        this.subscribeToMessageChannel();
    }
    // Context based boolean conditions
    // get isRecordTab(){
    //     return this.containerContext === RECORD_TAB_CONTEXT && this.isWizardAction;
    // }

    // get isQuickAction(){
    //     return this.containerContext === QUICK_ACTION_CONTEXT && this.isWizardAction;
    // }

    get isWizardAction(){
        return this.containerContext === GENERAL_WIZARD_CONTEXT;
    }
    // Context based boolean conditions

    // Get Field Label
    fieldLabels(fieldAPI){
        if(fieldAPI === 'MMV_Master__c'){
            return 'MMV';
        }
        else if(fieldAPI === 'Engine_Number__c'){
            return 'Engine No.';
        }
        else if(fieldAPI === 'Chasis_Number__c'){
            return 'Chasis No.';
        }
        else if(fieldAPI === 'TAR_Place_of_Visit__c'){
            return 'Place of Visit';
        }
        else if(fieldAPI === 'TAR_if_Other_please_specify__c'){
            return 'if Other please specify';
        }
        else if(fieldAPI === 'TAR_Delivery_Date__c'){
            return 'Delivery Date';
        }
        else if(fieldAPI === 'TAR_Customer_Equity_Amount_MMR_paid__c'){
            return 'Customer Equity Amount (MMR paid)';
        }
        else if(fieldAPI === 'TAR_Tractors_Running_Usage_Hour_Meter_Re__c'){
            return 'Tractors Running / Usage (Hour Meter Reading)';
        }
        else if(fieldAPI === 'TAR_Sr_No__c'){
            return 'Sr no';
        }
        else{
            return 'label not found!';
        }
    }

    // Get Field Label

    // Getting current user records
    @wire(getRecord, { recordId: USER_ID, fields: [PROFILE_NAME_FIELD]}) 
    userDetails({error, data}) {
        if (data) {
            this.profileName = data.fields.Profile.value.fields.Name.value; 
            this.handleGetCollateralData();
        } else if (error) {
            console.error('Error fetching profile data' + JSON.stringify(error));
            toastWithMessage(this, 'ERROR!', 'error', 'Error fetching profile data ' + error);
        }
    }

    // Custom Spinner settings
    async spinnerImageMethod() {
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.recordId);
        }
    }
    // Custom Spinner settings

    // Fetching collateral data
    async handleGetCollateralData(){
        try{
            await this.spinnerImageMethod();
            // Making sure both variables have value before proceeding
            if(this.metadataConfig.length === 0 || !this.profileName) return;
            
            this.collateralData = await getCollateralRecord({loanId : this.recordId});
            
            if(!this.collateralData){ // Stop execution if collateral does not exist
                if(!this.isWizardAction)
                    toastWithMessage(this, 'ERROR!', 'info', 'Please fill vehicle details before accessing TAR');
                this.isLoading = false;
                this.isComponentVisible = false;
                return;
            }

            this.handleVisibilityAndRightsCheck(this.collateralData, this.metadataConfig);
            

            if(!this.isComponentVisible){// If NO VISIBLE then no need to proceed further
                return; 
            } 
            
            if(this.collateralData.Vehicle_Delivery__c!=='Yes' && !TAR_MANDATORY_VISIBLE.has(this.collateralData.Loan__r.Stage__c)){
                if(!this.isWizardAction)
                    toastWithMessage(this, 'ERROR!', 'info', 'TAR will be visible only when Vehicle status delivered is yes');
                this.isLoading = false;
                this.isComponentVisible = false;
                return;
            }
            this.collateralRecordTypeId = this.collateralData.RecordTypeId;
            this.collateralId = this.collateralData.Id;
            this.handleFormGeneration(this.collateralData, this.metadataConfig);
        }
        catch(e){
            console.error('Error fetching collateral data' + JSON.stringify(e));
            toastWithMessage(this, 'ERROR!', 'error', 'Error fetching collateral data ' + e);
        }
        this.isLoading = false;
    }


    // Handle display of fields based on metadata
    handleFormGeneration(collateralData, metadataConfigVal){
        let metadataByCollateral = metadataConfigVal.find(ele => collateralData.Loan__r.Collateral_Type__c === ele.Collateral_Type__c);
        this.handleInputFieldFormation(metadataByCollateral);
        this.handleImageFormGeneration(metadataByCollateral, true);
    }

    // handle visibility and rights check
    handleVisibilityAndRightsCheck(collateralData, metadataConfigVal) {
        
        if(this.isProductApplicable(collateralData, metadataConfigVal)){
            if(this.isStageEditable(collateralData, metadataConfigVal)){
                if(this.isProfileEditable(metadataConfigVal)){
                    this.handleComponentViewEditRender(EDITABLE);
                }
                else{
                    this.handleComponentViewEditRender(READ_ONLY_LITERAL);
                }
            }
            else if(this.isStageReadOnly(collateralData, metadataConfigVal)){
                this.handleComponentViewEditRender(READ_ONLY_LITERAL);
            }
            else{
                this.handleComponentViewEditRender(NO_VISIBLE);
            }
        }
        else{
            this.handleComponentViewEditRender(NO_VISIBLE);
        }

    }

    // Check if product is applicable or not
    isProductApplicable(collateralData, metadataConfigVal){
        let productApplicable = new Set(metadataConfigVal.find(ele => ele.DeveloperName === PRODUCT_APPLICABLE).MetaData_Value__c.split(','));
        return productApplicable.has(collateralData.Loan__r.Product__c);
    }

    // Is profile editable as per metadata
    isProfileEditable(metadataConfigVal){
        let profileEditable = new Set(metadataConfigVal.find(ele => ele.DeveloperName === PROFILE_DEVELOPER_NAME).MetaData_Value__c.split(','));
        return profileEditable.has(this.profileName);
    }


    // Is stage editable as per metadata
    isStageEditable(collateralData, metadataConfigVal){
        let editStages = new Set(metadataConfigVal.find(ele => ele.DeveloperName === STAGE_EDITABLE).MetaData_Value__c.split(','));
        return editStages.has(collateralData.Loan__r.Stage__c);
    }

    isStageReadOnly(collateralData, metadataConfigVal){
        let readOnlyStages = new Set(metadataConfigVal.find(ele => ele.DeveloperName === STAGE_READ_ONLY).MetaData_Value__c.split(','));
        return readOnlyStages.has(collateralData.Loan__r.Stage__c);
    }

    // Form field input/disabled based on custom metadata
    handleInputFieldFormation(metadataByCollateral){
        this.fieldsDisplay = [];
        for(let fieldApi of metadataByCollateral.Form_Field_To_Display__c.split(',')){
            fieldApi = fieldApi.trim();
            let obj = {
                fieldApi : fieldApi
            };
            if(readOnlyFields.has(fieldApi)){
                obj.isDisabled = true;
            }
            else{
                obj.isDisabled = this.isComponentDisabled;
            }
            if(fieldApi === 'TAR_Tractors_Running_Usage_Hour_Meter_Re__c' || fieldApi === 'TAR_Customer_Equity_Amount_MMR_paid__c'){
                obj.type='number';
            }
            else if(fieldApi === 'TAR_Delivery_Date__c'){
                obj.type='date';
            }
            else{
                obj.type='text';
            }
            if(fieldApi === 'TAR_Place_of_Visit__c'){
                obj.isPickList = true;
            }
            else{
                obj.isPickList = false;
            }
            obj.fieldLabel = this.fieldLabels(fieldApi);
            obj.fieldValue = this.handleKeyValue(fieldApi);
            this.fieldsDisplay.push(obj);

        }
        
    }

    // Populate value as per keys
    handleKeyValue(fieldApi){
        if(fieldApi === 'MMV_Master__c'){
            return this.collateralData.MMV_Master__r ? this.collateralData.MMV_Master__r.Name : '';
        }
        else {
            return this.collateralData[fieldApi];
        }
    }

    // Populate value as per keys
    
    // Fetch uploaded documents
    async handleFetchUploadedDocuments(){
        const result = await getVersionFiles({
            recordId : this.collateralId,
            objectApiName : 'TAR'
        });
        return result;
    }
    // Fetch uploaded documents

    // handle Image capture form generation
    async handleImageFormGeneration(metadataByCollateral, makeServerCall){
        this.isLoading = true;
        if(makeServerCall){ // Skip if it is just a refresh page request
            this.documentCheckListData = await getDocumentCheckListRelatedToTar({
                documentIds : metadataByCollateral.Image_Field_To_Display__c.split(','),
                collateralId : this.collateralId
            });
        }
        
        const uploadedDocuments = await this.handleFetchUploadedDocuments();
        this.imageFields = [];
        for(let documentId of metadataByCollateral.Image_Field_To_Display__c.split(',')){
            documentId = documentId.trim();
            let documentCheckList = this.documentCheckListData.find(ele => documentId === ele.Document_Master__r.Document_ID__c);
            let obj = {
                documentId : documentId,
                documentName : documentCheckList.Document_Master__r.Document_Name__c,
                uploadedDocuments : uploadedDocuments.filter(ele => ele.docName === documentCheckList.Document_Master__r.Document_Name__c)
            };
            this.imageFields.push(obj);
        }
        this.isLoading = false;
    }

    // Handle change in input field
    handleFieldChange(event){
        const fieldApi = event.target.dataset.apiname;
        const value = event.target.value;
        this.tarData[fieldApi] = value;
       
    }

    // UI Level validations
    handleUILevelValidations(){
        let isValid = true;
        
        if(this.tarData.TAR_Customer_Equity_Amount_MMR_paid__c){
            let inputElement = this.template.querySelector('.TAR_Customer_Equity_Amount_MMR_paid__c');
            const customerEquityAmtCheck = this.tarData.TAR_Customer_Equity_Amount_MMR_paid__c + '';
            if(customerEquityAmtCheck && customerEquityAmtCheck.length > 7){
                inputElement.setCustomValidity('Upto 7 digits only allowed!');
                //toastWithMessage(this, 'ERROR!', 'error', `${this.fieldLabels('TAR_Customer_Equity_Amount_MMR_paid__c')} only 7 digits allowed!`);
                isValid = false;
            }
            else{
                inputElement.setCustomValidity('');
            }
            inputElement.reportValidity();
        }
        if(this.tarData.TAR_Tractors_Running_Usage_Hour_Meter_Re__c){
            let inputElement = this.template.querySelector('.TAR_Tractors_Running_Usage_Hour_Meter_Re__c');
            const customerEquityAmtCheck = this.tarData.TAR_Tractors_Running_Usage_Hour_Meter_Re__c + '';
            if(customerEquityAmtCheck && customerEquityAmtCheck.length > 6){
                inputElement.setCustomValidity('Upto 6 digits only allowed!');
                //toastWithMessage(this, 'ERROR!', 'error', `${this.fieldLabels('TAR_Tractors_Running_Usage_Hour_Meter_Re__c')} only 6 digits allowed!`);
                isValid = false;
            }
            else{
                inputElement.setCustomValidity('');
            }
            inputElement.reportValidity();
        }
        if(this.tarData.TAR_Place_of_Visit__c){
            let inputElement = this.template.querySelector('.TAR_if_Other_please_specify__c');
            if(!this.tarData.TAR_if_Other_please_specify__c && this.tarData.TAR_Place_of_Visit__c==='Other'){
                inputElement.setCustomValidity(`If ${this.fieldLabels('TAR_Place_of_Visit__c')} is specified as Other, this field is mandatory!`);
                //toastWithMessage(this, 'ERROR!', 'error', `If ${this.fieldLabels('TAR_Place_of_Visit__c')} is specified as Other, ${this.fieldLabels('TAR_if_Other_please_specify__c')} is mandatory!`);
                isValid = false;
            }
            else{
                inputElement.setCustomValidity('');
            }
            inputElement.reportValidity();
        }

        if(this.tarData.TAR_Delivery_Date__c){
            let inputElement = this.template.querySelector('.TAR_Delivery_Date__c');
            const selectedDate = inputElement.value;
            const currentDate = new Date().toISOString().split('T')[0];
            if(selectedDate >  currentDate){
                inputElement.setCustomValidity(`Delivery date cannot be future date`);
                //toastWithMessage(this, 'ERROR!', 'error', `If ${this.fieldLabels('TAR_Place_of_Visit__c')} is specified as Other, ${this.fieldLabels('TAR_if_Other_please_specify__c')} is mandatory!`);
                isValid = false;
            }
            else{
                inputElement.setCustomValidity('');
            }
            inputElement.reportValidity();
        }
        return isValid;
    }
    // UI Level validations


    // Update DB will values
    async handleSaveTARData(){
        this.isLoading = true;
        try{
            if(!this.handleUILevelValidations()){
                this.isLoading = false;
                return;
            }
            // if(TAR_MANDATORY_VISIBLE.has(this.collateralData.Loan__r.Stage__c) && !await this.handleValidateDocumentExist()){
            //     return;
            // }
           this.tarData.Id = this.collateralId;
           this.tarData.TAR_Status__c = 'Saved';
            await updateRecord({fields : this.tarData});
            await resetCreditVerificationOnLoan({loanId:this.recordId, documentType: 'TAR', value: false})
            const payload = { recordIdOfSobject: this.recordId, refreshPage: 'Yes'};
            publish(this.messageContext, pageRefreshOnMaterialFieldChange, payload);
            toastWithMessage(this, 'SUCCESS!', 'success', 'TAR data saved successfully');

            this.handleWizardAction();

        }
        catch(e){
            console.error('Error saving collateral data' + JSON.stringify(e));
            toastWithMessage(this, 'ERROR!', 'error', 'Error saving collateral data ' + e);
        }
        this.isLoading = false;
    }

    async handleSubmitTARData(){
        this.isLoading = true;
        try{
            if(!this.handleUILevelValidations()){
                this.isLoading = false;
                return;
            }

            if(await this.handleValidateDocumentExist()){
                if(!this.collateralId){
                    this.isLoading = false;
                   return; 
                }
                
                this.tarData.Id = this.collateralId;
                this.tarData.TAR_Status__c = 'Submitted';
                //alert('this.tarData'+JSON.stringify(this.tarData));
                await updateRecord({fields : this.tarData});
                await resetCreditVerificationOnLoan({loanId:this.recordId, documentType: 'TAR', value: false})
                const payload = { recordIdOfSobject: this.recordId, refreshPage: 'Yes'};
                publish(this.messageContext, pageRefreshOnMaterialFieldChange, payload);
                toastWithMessage(this, 'SUCCESS!', 'success', 'TAR data saved successfully');

                this.handleWizardAction();
            }
            this.isLoading = false;
        }
        catch(e){
            console.error('Error saving collateral data' + JSON.stringify(e));
            toastWithMessage(this, 'ERROR!', 'error', 'Error saving collateral data ' + e);
        }
    }



    // Handle wizard movement based on context
    handleWizardAction(){
        if(this.isWizardAction){
            const Obj = {};
            Obj.next = true;
            this.dispatchEvent(new CustomEvent('next', {
                detail: Obj
            }));
        }
    }

    // handle document upload success refresh the page
    handleDocumentUploadSuccess(){
        this.imageFields = [];
        setTimeout (() => {
            let metadataByCollateral = this.metadataConfig.find(ele => this.collateralData.Loan__r.Collateral_Type__c === ele.Collateral_Type__c);
            this.handleImageFormGeneration(metadataByCollateral, false);
        })
    }

    // Handle based on value is component visible and editable
    handleComponentViewEditRender(visibilityLiteral){
        switch(visibilityLiteral){
            case READ_ONLY_LITERAL : 
                this.isComponentDisabled = true;
                this.isComponentVisible = true;
                break;
            case EDITABLE : 
                this.isComponentDisabled = false;
                this.isComponentVisible = true;
                break;
            case NO_VISIBLE : 
                this.isComponentDisabled = true;
                this.isComponentVisible = false;
                break;

        }
    }

    // Wizard next button handler
    @api nextHandler() {
        if(this.isComponentDisabled){
            this.handleWizardAction();
        }
        else{
            if(!TAR_MANDATORY_VISIBLE.has(this.collateralData.Loan__r.Stage__c)){ // NON PSD Stage just save
                this.handleSaveTARData();
            }
            else{
                validateTARSubmitOrApproval({ recId: this.recordId}) //  PSD Stage just save and submit
                .then(result => {
                    if(result == 'submitted'){
                        this.handleSubmitTARData();
                    }
                    else if(result == 'approved'){
                        this.handleSaveTARData();
                    }else if(result === 'throwerror'){
                        toastWithMessage(this, 'Error!', 'error', 'Please submit TAR report or Take approval for the same');
                    }else {
                        this.handleSaveTARData();
                    }
                })
                .catch(error => {
                    console.error('Error while creating Approval record', error);
                });
            }
        }
        
        
    }

    // Handle document validation
    async handleValidateDocumentExist(){
        try{
            let errorMessage = await validateDocumentUpload({documentCheckListData : this.documentCheckListData});
            if(errorMessage){
                errorMessage = ERROR_MESSAGE_LABEL.replace(ERROR_MESSAGE_DOCUMENT_MERGE, errorMessage);
                toastWithMessage(this, 'ERROR!', 'error', errorMessage);
                return false;
            }
            else{
                return true;
            }
        }   
        catch(e){
            console.error('Error validating document uploaded' + JSON.stringify(e));
            toastWithMessage(this, 'ERROR!', 'error', 'Error validating document uploaded ' + e);
        }
        
    }

    populateComments(event){
        //alert(event.target.value);
        this.comments = event.target.value;
    }

    submitForApproval(){
        this.isLoading = true;
        try{
            if(this.comments == ''){
                toastWithMessage(this, 'ERROR!', 'error', 'Please enter Remarks');
            }
            else{
                this.disableButton = true;
                createApproval({ recId: this.recordId, remarks: this.comments })
                .then(result => {
                    toastWithMessage(this, 'Success!', 'success', 'Submitted for approval successfully');
                    this.refreshApprovalData();
                    //this.handleWizardAction();
                })
                .catch(error => {
                    console.error('Error while creating Approval record', error);
                });
            }
        }
        catch(e){
            console.error('Error saving collateral data' + JSON.stringify(e));
            toastWithMessage(this, 'ERROR!', 'error', 'Error saving collateral data ' + e);
        }
        this.isLoading = false;
    }

    approveRecord(){
        this.approverejectMsg = 'Approve request';
        this.approveOrRejReq = true;
        this.submitForAppOrRej = 'approve';
    }
    rejectRecord(){
        this.approverejectMsg = 'Reject request';
        this.approveOrRejReq = true;
        this.submitForAppOrRej = 'reject';
    }

    populateAppRejComment(event){
        this.populateAppRejComments = event.target.value;
    }

    approverecandSubmit(){
        if(this.populateAppRejComments == ''){
            alert('Enter comments before submitting')
        }else{
            this.disableallButton = true;
            submitforApprovalOrReject({ comments: this.populateAppRejComments, approveOrReject: this.submitForAppOrRej, subLoanApprovalId: this.subLoanAppId })
                .then(result => {
                    toastWithMessage(this, 'Success!', 'success', 'Success');
                    this.isCurrentuserApprover = false;
                    this.refreshApprovalData();
                })
                .catch(error => {
                    console.error('Error while Approving/Rejecting record', error);
                });
        }
        
    }
    cancelrecord(){
        this.approverejectMsg = '';
        this.approveOrRejReq = false;
        this.submitForAppOrRej = '';
    }

    @wire(getApprovals,{recId:'$recordId'})
    wiredApprovals({ error, data }) {
        if (data) {
            //alert(JSON.stringify(data));
            if(data.length>0){
                //this.approvalReq = data;
                if(data[0].remarks != undefined){
                    this.approvalRemarks = data[0].remarks;
                }
                if(data[0].approvalStatus != undefined){
                    this.approvalStatus = data[0].approvalStatus;
                }
                if(data[0].approvedBY != undefined){
                    this.approvalApprover = data[0].approvedBY;
                }
                this.isCurrentuserApprover = data[0].isCurrentuserApprover;
                this.approversList = data[0].approverNames;

                this.subLoanAppId = data[0].loanAppRecId;
                this.isApprovalExist = true;
            }
            else{
                this.isApprovalExist = false;
            }
        } else if (error) {
            this.approvalReq = undefined;
        }
    }

    refreshApprovalData(){
        getApprovalRecs({ recId: this.recordId})
                .then(result => {
                    //alert(JSON.stringify(result));
                    if(result.length>0){
                        //this.approvalReq = data;
                        if(result[0].remarks != undefined){
                            this.approvalRemarks = result[0].remarks;
                        }
                        if(result[0].approvalStatus != undefined){
                            this.approvalStatus = result[0].approvalStatus;
                        }
                        //if(data[0].approvedBY != undefined){
                        if(result[0].approvedBY != undefined){//changed data to result - Neha
                            //this.approvalApprover = data[0].approvedBY;//changed data to result - Neha
                            this.approvalApprover = result[0].approvedBY;
                        }
                        this.isApprovalExist = true;
                        this.isCurrentuserApprover = result[0].isCurrentuserApprover;
                        this.subLoanAppId = result[0].loanAppRecId;
                    }
                    else{
                        this.isApprovalExist = false;
                    }
                })
                .catch(error => {
                    console.error('Error while creating Approval record', error);
                });
    }

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
            this.handleGetCollateralData()
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