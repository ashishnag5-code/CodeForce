import { LightningElement, track, api, wire } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import getWizardSettings from '@salesforce/apex/GenericWizardController.getWizardSettings';
import fetchWizardState from '@salesforce/apex/GenericWizardController.fetchWizardState';
import saveDraftStage from '@salesforce/apex/GenericWizardController.saveDraftStage';
import { getRecord } from 'lightning/uiRecordApi';
import STAGE_FIELD from "@salesforce/schema/Loan_Application__c.Stage__c";
import PRODUCT_FIELD from "@salesforce/schema/Loan_Application__c.Product__c";
import RECORD_TYPE from "@salesforce/schema/Loan_Application__c.RecordType.Name";///* Changed by naga for doc Doc Manager should not be at QDE for 4 enchancement */
import Icons from "@salesforce/resourceUrl/SampleIcons";
import AUSF_LOGOS from "@salesforce/resourceUrl/AUSF_LOGOS";
import getRecordtypeName from '@salesforce/apex/GenericWizardController.getRecordtypeName';
import { getSpinnerImage } from 'c/customSpinner';
import userId from "@salesforce/user/Id";
import APPLICABLE_PRODUCTS_FIELD from '@salesforce/schema/User.Applicable_Products__c';

// Tractor TAR Feature
const TRACTOR_RECORD_TYPE_DEVELOPER_NAME = 'Tractor';
const PRODUCT_APPLICABLE = 'Product_Applicable';
import getCollateralRecord from '@salesforce/apex/AusfbTractorTarContainerController.getCollateralRecord';
import getMetadataConfig from '@salesforce/apex/AusfbTractorTarContainerController.getMetadataConfig';
const TAR_MANDATORY_VISIBLE = new Set(['PSD','Ops Maker', 'Ops Author', 'Partially Disbursed','PDD', 'Cancelled', 'Rejected', 'Completed']); 
// Tractor TAR Feature

export default class GenericWizard extends NavigationMixin(LightningElement) {
    nextIcon = Icons + '/svg/next.svg#next';
    nextImage = Icons + '/img/next.jpeg';
    spinner = Icons + '/img/spinner.gif';
    @track
    spinnerImage; //= AUSF_LOGOS + '/AUSF_LOGOS/spinner/Bike.gif';
    disableNext = false;
    nextLogo = AUSF_LOGOS + '/AUSF_LOGOS/logos/SFDC_Icons_Next.png';
    cancelLogo = AUSF_LOGOS + '/AUSF_LOGOS/logos/SFDC_Icons_Cancel.png';
    previousLogo = AUSF_LOGOS + '/AUSF_LOGOS/logos/SFDC_Icons_Previous.png';

    @api recordId;
    @api sObjectName;
    @api isLoaded = false;
    @api insideRecordPage = false;
    @api fromRecordPage = false;
    //passed from record page to wizard to show edit mode in wizard
    @api applicantIdForEdit;
    //@api vehicleIdForEdit;
    @api flowName;
    @api childToFlow;
    @api wizardProductName;
    @api productName;
    productMap = {}
    wizardProductMap = {}
    @api boolReFetchData = false;
    @api aapCount;

    currentPage = 1
    originalPageForMobile;
    recordTypeName;
    totalPage = 25
    //refreshCounter = 0
    @track loanApplicationRecord = {};
    @track applicantRecord = {};
    @track applicantRecordlist = [];
    _loanAppRec;

    startPage = 1;
    offSet = 0;
    isPanMandatory = false;
    sScreenConfigs;
    @api
    stageName;
    currentObject = {}
    @track
    sCurrentFlowConfig = {};
    isLoaded = false;
    strDraftStage = '';
    showButton = true;
    isLoading;
    globalState;
    userId = userId;
    /*
    @wire(getRecord, { recordId: '$recordId', fields: ['Loan_Application__c.RecordType.Name'] })
    getImageRecord({ data, error }) {
        if (data) {
            console.log('%% in spinner');
            let recordTypeDetails = data.fields['RecordType'].displayValue; //this line has record type Id and Name.
            if(recordTypeDetails == 'Four Wheeler'){
                this.spinnerImage = AUSF_LOGOS + '/AUSF_LOGOS/spinner/Car.gif';
            }
            else if(recordTypeDetails == 'Two Wheeler'){
                this.spinnerImage = AUSF_LOGOS + '/AUSF_LOGOS/spinner/Bike.gif';
            }
            else{
                this.spinnerImage = AUSF_LOGOS + '/AUSF_LOGOS/spinner/Car.gif';
            }
        }
    }
    */

    @wire(getRecord, { recordId: '$recordId', fields: [STAGE_FIELD,RECORD_TYPE, PRODUCT_FIELD] })/* Changed by naga for doc Doc Manager should not be at QDE for 4 enchancement */
    wiredLoanAppl(result) {       
        const { data, error } = result;
        this._loanAppRec = result;
        if (data) {
            console.log("data--"+JSON.stringify(data));
        //    this.loanAppRec = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
       //     this.loanAppRec = undefined;
        }
    }

    // R2-9
    @wire( getRecord, { recordId: '$userId', fields: [ APPLICABLE_PRODUCTS_FIELD ] } )
    userInfo;
    
    async setSpinner(recordId){
        let data = await getSpinnerImage(recordId);
        console.log(data);
        this.spinnerImage = data;
    }

    get nextLabel() {
        return 'Next';
    }


    get disablePrevious() {
        return this.currentObject.onPrevious === 0;
    }

    showMessage(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }
    
    async previousHandler() {
        console.log('%%% ' + JSON.stringify(this.applicantRecord));
        if(this.currentObject.onPrevious === 0){
            return;
        }
        /* Changed by naga for doc Doc Manager should not be at QDE for 4 enchancement */
       if((this.currentObject.onPrevious === 16) && this._loanAppRec != null && this._loanAppRec.data.recordTypeInfo.name=='Four Wheeler' && this._loanAppRec.data.fields.Stage__c.value=='QDE'){
            this.updateScreen(this.sCurrentFlowConfig,this.currentObject.onPrevious - 1, false);
            this.isLoaded = false;
        }   /* End od doc Doc Manager should not be at QDE for 4 enchancement */   
        else {

            await this.setOffSet('previous');
            this.updateScreen(this.sCurrentFlowConfig,this.currentObject.onPrevious - this.offSet, false);
            console.log('result is '+JSON.stringify(this.sCurrentFlowConfig));
            this.isLoaded = false;
        }

        //}
    }

    @track isDeDupeToBeSkipped = false;


    nextHandler(event) {
        let current = event.detail;
        console.log('%%%applicantRecordlist '+JSON.stringify(this.applicantRecordlist));
        //console.log('%% ' + this.template.querySelector(".component").classList.contains("checkSkipKYC"));
        if (current.next) {
            console.log("current.next"+current.next);
            if (current.hasOwnProperty('loanApplicationRecord')) {
                this.loanApplicationRecord = current.loanApplicationRecord;
                this.recordId = this.loanApplicationRecord.Id;
                this.setSpinner(this.recordId);
                console.log('loanApplicationRecord', this.loanApplicationRecord.Id);
            }
            if (current.hasOwnProperty('applicantRecord')) {
                if(current.hasOwnProperty('isAdditionalKYCChanged')){
                    this.isDeDupeToBeSkipped = !current.isAdditionalKYCChanged;
                }
                let applicantRecordfromEvent = current.applicantRecord;
                if(applicantRecordfromEvent.hasOwnProperty('Id')){
                    this.applicantRecord = applicantRecordfromEvent;
                    console.log('applicantRecord', JSON.stringify(this.applicantRecord));
                    this.setOffSet('next');
                    if(this.applicantRecordlist.length === 0){
                        this.applicantRecordlist.push(this.applicantRecord);
                    }
                    else{
                        this.applicantRecordlist[this.applicantRecordlist.findIndex(el => el.id === this.applicantRecord.id)] = this.applicantRecord;
                    }
                }
                else if(this.applicantRecordlist.length > 0){
                    this.setOffSet('next');
                }
                console.log('applicantRecord', this.applicantRecord);
                console.log('%%%applicantRecordlist '+JSON.stringify(this.applicantRecordlist));
                /*if (this.applicantRecord.hasOwnProperty('KYC_Status__c')
                    && this.applicantRecord.KYC_Status__c == 'Complete'
                    && this.applicantRecord.KYC_Type__c == 'CBS'
                    && this.sCurrentFlowConfig.Dedupe && this.sCurrentFlowConfig.Dedupe.currentVal) {
                        //this.currentPage = this.currentPage + 2;
                    //this.skipKYC = true;
                    //this.sCurrentFlowConfig = JSON.parse(this.sScreenConfigs.Skip_KYC.Screen_Config_Json__c);
                    this.updateScreen(this.sCurrentFlowConfig,this.currentObject.onSkipKYCNext, false);
                    return ;
                }*/
            }
            if (current.hasOwnProperty('isPanMandatory')) {
                console.log('current.isPanMandatory', current.isPanMandatory);
                this.isPanMandatory = current.isPanMandatory;
            }
            if (this.currentPage < this.totalPage) {
                //this.oldPage = this.currentPage;
                //this.currentPage = this.currentPage + 1
                //this.getNextScreen(this.sCurrentFlowConfig,'next');
                //this.viewNextScreen(this.sCurrentFlowConfig,this.currentPage,this.oldPage);
                if(this.loanApplicationRecord.Product__c != undefined && this.loanApplicationRecord.Product__c != '' 
                    && this.loanApplicationRecord.Product__c.length == 5){
                    if(this.productMap[this.loanApplicationRecord.Product__c] != this.productName){
                        this.productName = this.productMap[this.loanApplicationRecord.Product__c];
                        this.wizardProductName = this.wizardProductMap[this.loanApplicationRecord.Product__c];
                        this.setUpWizard(false);
                    }
                    else{
                        this.goToNext();
                    }
                }
                else{
                    this.goToNext();
                }
                /*
                console.log('%%%applicantRecordlist '+JSON.stringify(this.applicantRecordlist));
                this.saveDraftStage();
                if(this.currentObject.onNext === 0){
                    //this.navigateToRecordPage(this.recordId);
                    if(this.isMobile && this.fromRecordPage){
                        this.currentPage = this.originalPageForMobile;
                        this.updateScreen(this.sCurrentFlowConfig, this.currentPage, true);
                    }
                    else{
                        this.navigateToRecordPage(this.recordId);
                    }
                }  /* Changed by naga for doc Doc Manager should not be at QDE for 4 enchancement *
                else if((this.currentObject.onNext === 16) && this._loanAppRec != null && this._loanAppRec.data.recordTypeInfo.name=='Four Wheeler' && this._loanAppRec.data.fields.Stage__c.value=='QDE'){
                    this.updateScreen(this.sCurrentFlowConfig,this.currentObject.onNext + 1, false);
                }         
                else{
                    this.updateScreen(this.sCurrentFlowConfig,this.currentObject.onNext + this.offSet, false);
                }
                //  doc Doc Manager should not be at QDE for 4  end 
                console.log('result is '+JSON.stringify(this.sCurrentFlowConfig));*/
                this.isLoaded = false
            }
        }
    }

    async goToNext(){
        console.log('%%%applicantRecordlist '+JSON.stringify(this.applicantRecordlist));
        this.saveDraftStage();
        if(this.currentObject.onNext === 0){
            //this.navigateToRecordPage(this.recordId);
            if(this.isMobile && this.fromRecordPage){
                this.currentPage = this.originalPageForMobile;
                this.updateScreen(this.sCurrentFlowConfig, this.currentPage, true);
            }
            else{
                this.navigateToRecordPage(this.recordId);
            }
        }  /* Changed by naga for doc Doc Manager should not be at QDE for 4 enchancement */
        else if((this.currentObject.onNext === 16) && this._loanAppRec != null && this._loanAppRec.data.recordTypeInfo.name=='Four Wheeler' && this._loanAppRec.data.fields.Stage__c.value=='QDE'){
            this.updateScreen(this.sCurrentFlowConfig,this.currentObject.onNext + 1, false);
        }         
        else{
            await this.setOffSet('next');
            this.updateScreen(this.sCurrentFlowConfig,this.currentObject.onNext + this.offSet, false);
        }
        //  doc Doc Manager should not be at QDE for 4  end 
        console.log('result is '+JSON.stringify(this.sCurrentFlowConfig));
    }

    async setOffSet(button){
        this.offSet = 0;
        
        //Tractor TAR Skipping conditions
        if(this.sCurrentFlowConfig.CPVWaiver && this.sCurrentFlowConfig.CPVWaiver.currentVal && this._loanAppRec.data.recordTypeInfo.name === TRACTOR_RECORD_TYPE_DEVELOPER_NAME && button === "next"){
            if(await this.shouldTractorTarSkip()){
                this.offSet = 1;
            }
        }
        if(this.sCurrentFlowConfig.PDComponent && this.sCurrentFlowConfig.PDComponent.currentVal && this._loanAppRec.data.recordTypeInfo.name === TRACTOR_RECORD_TYPE_DEVELOPER_NAME &&  button === "previous"){
            if(await this.shouldTractorTarSkip()){
                this.offSet = 1;
            }
        }
        //Tractor TAR Skipping conditions

        if(this.sCurrentFlowConfig.QuickLoan && this.sCurrentFlowConfig.QuickLoan.currentVal 
            && this.applicantRecordlist.length > 0 && this.strDraftStage != '' && this.strDraftStage != 'QuickLoan'){
                this.offSet = this.sCurrentFlowConfig.QuickLoan.offSet;
        }
        // De Dupe Skip Logic
        if(button == "next" && this.isDeDupeToBeSkipped){
            console.log('de dupe to be inside');
            this.offSet = 1;
        }
        if (button == "next" && this.applicantRecord.hasOwnProperty('CBS_Status__c')
            && this.applicantRecord.CBS_Status__c == 'Complete'
            && this.applicantRecord.KYC_Type__c == 'Aadhaar - Physical Document'
            && this.sCurrentFlowConfig.Dedupe && this.sCurrentFlowConfig.Dedupe.currentVal) {
                this.offSet = this.sCurrentFlowConfig.Dedupe.offSet;
        }
        if (button == "previous" && this.applicantRecord.hasOwnProperty('CBS_Status__c')
            && this.applicantRecord.CBS_Status__c == 'Complete'
            && this.applicantRecord.KYC_Type__c == 'Aadhaar - Physical Document'
            && this.sCurrentFlowConfig.CustomerInformation && this.sCurrentFlowConfig.CustomerInformation.currentVal) {
                this.offSet = this.sCurrentFlowConfig.CustomerInformation.offSet;
        }
        if(button == 'previous' && this.sCurrentFlowConfig.RelatedApplicants && this.sCurrentFlowConfig.RelatedApplicants.currentVal) {
            this.offSet = this.sCurrentFlowConfig.RelatedApplicants.offSet;
        }
        if (button == "next" && ( ((this.applicantRecord.hasOwnProperty('Customer_Type__c')
            && this.applicantRecord.Customer_Type__c == 'Non Individual') || (!this.applicantRecord.hasOwnProperty('Aadhaar_Number__c')) ) )
            && this.sCurrentFlowConfig.Dedupe && this.sCurrentFlowConfig.Dedupe.currentVal) {
                this.offSet = this.sCurrentFlowConfig.Dedupe.offSetNI;
        }
        if (button == "previous" && ((this.applicantRecord.hasOwnProperty('Customer_Type__c')
            && (this.applicantRecord.Customer_Type__c == 'Non Individual')) || (!this.applicantRecord.hasOwnProperty('Aadhaar_Number__c')) )
            && this.sCurrentFlowConfig.PANKYC && this.sCurrentFlowConfig.PANKYC.currentVal) {
                this.offSet = this.sCurrentFlowConfig.PANKYC.offSetNI;
        }
        //return this.offSet;
    }

    // Tractor TAR skip handle  
    async shouldTractorTarSkip(){
        const loanId = this._loanAppRec.data.id;
        let collateralData = await getCollateralRecord({loanId : loanId});
        
        if(!collateralData){
            return true;
        }
        if(collateralData.Vehicle_Delivery__c!=='Yes' && !TAR_MANDATORY_VISIBLE.has(this._loanAppRec.data.fields.Stage__c.value) ){
            return true;
        }
        let metadataConfig = await getMetadataConfig();
        if(!this.isProductApplicable(collateralData, metadataConfig)){
            return true;
        }

        return false;
    }

    // Check if product is applicable or not for Tractor TAR
    isProductApplicable(collateralData, metadataConfigVal){
        let productApplicable = new Set(metadataConfigVal.find(ele => ele.DeveloperName === PRODUCT_APPLICABLE).MetaData_Value__c.split(','));
        return productApplicable.has(collateralData.Loan__r.Product__c);
    }

    // Tractor TAR skip handle  

    //For Initial Quick Loan
    onWizardEvent(event){
        this.insideRecordPage = false;
        if(event.detail.name == 'RelatedApplicant'){
            if(event.detail.mode == 'add'){
                this.recordId = this.loanApplicationRecord.Id;
                this.applicantRecord = {};
                this.updateScreen(this.sCurrentFlowConfig,this.currentObject.onAddEditApplicants,false);
                console.log('event add count',event.detail.addcount);
                this.aapCount = event.detail.addcount;
            }
            if(event.detail.mode == 'edit'){
                this.recordId = this.loanApplicationRecord.Id;
                console.log('%% '+JSON.stringify(this.applicantRecordlist));
                console.log('%% '+JSON.stringify(event.detail.value));
                this.applicantRecord = this.applicantRecordlist.find((item)=>item.Id === event.detail.value);
                if(this.applicantRecord != undefined){
                    this.updateScreen(this.sCurrentFlowConfig,this.currentObject.onAddEditApplicants,false);
                }
            }
        }
        if(event.detail.name == 'EditKYC'){
            this.updateScreen(this.sCurrentFlowConfig,this.currentObject.onEditKYC,false);
        }
    }

    toggleButtons(event){
        this.showButton = event.detail;
    }

    finishHandler() {
        this.closeQuickAction();
    }
    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    connectedCallback() {
        console.log('aapCount in wizard',this.aapCount);
        window.addEventListener('updatestate', (event) => this.handleGlobalState(event));
        this.setFormFactor();
        console.log('Form factor - Mobile : ', this.isMobile);
        console.log('Form factor - Mobile : ', this.currentPage);
        console.log('sObjectName', this.sObjectName);
        
        /*if (this.sObjectName == 'Applicant__c') {
            this.flowName = 'Edit_KYC';
            this.childToFlow = 'Edit_KYC_Default';
        }*/
        if(this.flowName == undefined && this.childToFlow == undefined && this.productName == undefined){
            this.flowName = 'Parent_Flow';
            this.childToFlow = 'Default';
            this.productName = 'Auto Loan';
            this.wizardProductName = 'Auto Loan';
        }
        if(this.stageName == undefined){
            this.stageName = 'QDE'
        }
        if(this.boolReFetchData){
            this.fetchExistingState();
        }
        else{
            this.setUpWizard(true);
        }
    }

    
    async setUpWizard(isFirstCall){
        await getWizardSettings({ strWizardName : this.flowName ,strStageName : this.stageName ,strProductName : this.wizardProductName})
        .then(result => {
            console.log('result is 123 '+JSON.stringify(result));
            this.sScreenConfigs = result.objGenericWizard;
            this.productMap = result.mapProdCodevsProduct;
            this.wizardProductMap = result.mapProdCodevsWizardProdName;
            const pageConfig = this.sScreenConfigs.Generic_Wizard_Current_Page_Configs__r.find((item)=>item.Flow_Name__c === this.childToFlow);
            this.startPage = pageConfig.Start_Page__c;
            this.currentPage = pageConfig.Current_Page__c;
            if(this.isMobile && this.insideRecordPage){
                this.originalPageForMobile = pageConfig.Current_Page__c;
            }
            this.sCurrentFlowConfig = JSON.parse(result.objGenericWizard.Screen_Config_Json_Long__c);
            if(isFirstCall){
                this.updateScreen(this.sCurrentFlowConfig, this.currentPage,false);
            }
            else{
                this.goToNext();
            }
        })
        .catch(error => {
            console.log('result is '+error)
            this.error = error;
            //this.isLoading = false;
        })
    }

    onspinnerevent(event) {
        console.log('%% '+this.spinnerImage);
        let showspinner = event.detail;
        if(showspinner){
            this.isLoading = true;
        }
        else{
            this.isLoading = false;
        }
    }

    fetchExistingState(){
        fetchWizardState({ strLoanAppId : this.recordId})
        .then(result => {
            console.log('result is '+JSON.stringify(result));
            console.log('result is '+ this.applicantIdForEdit);
            this.loanApplicationRecord = result.objLoanApp;
            this.strDraftStage = result.objLoanApp.Draft_Stage__c;
            this.productName = result.objProdRTMap.Product_Name__c;
            this.wizardProductName = result.objProdRTMap.Product_Name_for_Wizard__c;
            if(result.objLoanApp.Applicants__r != undefined){
                this.applicantRecordlist = result.objLoanApp.Applicants__r;
                this.applicantRecord = result.objLoanApp.Applicants__r.find((item)=>item.Id === this.applicantIdForEdit);
            }
            if(this.applicantRecord == undefined){
                this.applicantRecord = {};
            }
            console.log('result is '+ this.applicantRecord);
            this.setUpWizard(true);
        })
        .catch(error => {
            console.log('result is '+error)
            this.error = error;
            //this.isLoading = false;
        })
    }
    /*
    getNextScreen(object, stepCalled) {
        Object.keys(object).forEach((key)=>{
            console.log(key);
            console.log(object[key]);
            if(object[key].prevStep === "0" && stepCalled === 'init'){
                //object[key].currentVal = true;
                this.nextScreen = key;
            }
            if(object[key].currentVal){
                object[key].currentVal = false;
                if(stepCalled === 'next'){
                    this.nextScreen = object[key].nextStep;
                }
                if(stepCalled === 'previous'){
                    this.nextScreen = object[key].prevStep;
                }               
            }
        });
    }
    */

    updateScreen(object, stepCounter, boolIsNavigate) {
        Object.keys(object).forEach((key)=>{
            console.log(key);
            console.log(object[key]);
            if(object[key].stepCounter === stepCounter){
                object[key].currentVal = true;
                this.currentObject = object[key];
                if(boolIsNavigate){
                    this.navigateToRecordPage(this.loanApplicationRecord.Id);
                }
            }
            else{
                object[key].currentVal = false;
            }
        });
    }
    /*
    viewNextScreen(object, nextScreen, prevScreen) {
        Object.keys(object).forEach((key)=>{
            if(object[key].stepCounter === nextScreen){
                object[key].currentVal = true;
            }
            if(object[key].stepCounter === prevScreen){
                object[key].currentVal = false;
            }
        });
    }
    */

    cancelHandler() {
        console.log('cancel');
        if(this.isMobile && this.fromRecordPage){
            this.currentPage = this.originalPageForMobile;
            this.updateScreen(this.sCurrentFlowConfig, this.currentPage, true);
        }
        else{
            this.navigateToRecordPage(this.loanApplicationRecord.Id);
        }
    }

    navigateToRecordPage(objectRecordid) {
        //this.updateRecordView();
        //getRecordNotifyChange([{recordId: this.recordId}]);
        console.log('objectRecordid', objectRecordid);
        //if(!this.isMobile){
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: objectRecordid,
                    actionName: 'view'
                },
            });
        //}
        /*else{
            /*
            var url = window.location.href;
            var value = url.substring(0,url.lastIndexOf('/') + 1);
            window.history.back();
            return false;
            *
            
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'Loan_Application__c',
                    actionName: 'list'
                },
                state: {
                    // 'filterName' is a property on 'state'
                    // and identifies the target list view.
                    // It may also be an 18 character list view id.
                    // or by 18 char '00BT0000002TONQMA4'
                    filterName: 'My_Loan_Applications' 
                }
            });
        }*/
        //this.updateRecordView();
        
    }


    setFormFactor() {
        switch (FORM_FACTOR) {
            case 'Large': {
                this.isMobile = false;
                break;
            }
            case 'Medium': {
                this.isMobile = true;
                break;
            }
            case 'Small': {
                this.isMobile = true;
                break;
            }
        }
    }

   /* fetchloanApplcation() {
        fetchWizardState({ strLoanAppId : this.recordId})
        .then(result => {
            this.loanApplicationRecord = result;
            let loanApplStage = this.loanApplicationRecord.Stage__c;
            if(loanApplStage == 'Rejected') {
                this.showMessage("","You Cannot Proceed to Next Screen as your loan application is rejected","error", "sticky");
            }
        })
        .catch(error => {
            console.log('Error inside fetchWizardState '+error)
            this.error = error;
            this.isLoading = false;
        })
    }  */

    enableNext(event) {
        this.disableNext = false;
    }

    childNextHandler() {
        this.disableNext = true;
        this.isLoaded = true;
        if(!this.sCurrentFlowConfig.AddIndividual.currentVal){
        setTimeout(() => {
            this.disableNext = false;
        }, 2000);
        }
        console.log('%% '+this.spinnerImage);
        if(this.recordId != undefined && this.recordId != null){
            console.log("inside childnexthandler before"+JSON.stringify(this._loanAppRec));
            refreshApex(this._loanAppRec);
            console.log("inside childnexthandler after"+JSON.stringify(this._loanAppRec));
            let stage = this._loanAppRec.data.fields.Stage__c.value;
            if(stage == "Rejected") {
                this.showMessage("","You Cannot Proceed to Next Screen as your loan application is rejected","error", "sticky");
            }
            else {
                //this.isLoading = true;
                this.isLoaded = true;
                if(this.sCurrentFlowConfig.AddIndividual.currentVal){
                    setTimeout(() => {
                        this.template.querySelector(".component").nextHandler();
                    }, 100);
                }
                else{
                    this.template.querySelector(".component").nextHandler();
                }          
            }
            this.isLoaded = false;   
        }
        else {
            //this.isLoading = true;
            this.isLoaded = true;
            if(this.sCurrentFlowConfig.AddIndividual.currentVal){
                setTimeout(() => {
                    this.template.querySelector(".component").nextHandler();
                }, 100);
            }
            else{
                this.template.querySelector(".component").nextHandler();
            }   
        }      
    }

    saveDraftStage(){
        if(this.flowName == 'Parent_Flow'){
            //var strDraftStage;
            if(this.sCurrentFlowConfig.QuickLoan && this.sCurrentFlowConfig.QuickLoan.currentVal && (this.strDraftStage == '' || this.strDraftStage == 'QuickLoan')){
                this.strDraftStage = 'QuickLoan';
            }
            if(this.sCurrentFlowConfig.AMLCIBIL && this.sCurrentFlowConfig.AMLCIBIL.currentVal){
                this.strDraftStage = 'RelatedApplicants';
            }
            if(this.sCurrentFlowConfig.LoanDetails && this.sCurrentFlowConfig.LoanDetails.currentVal){
                this.strDraftStage = 'LoanDetails';
            }
            if(this.sCurrentFlowConfig.VehicleDetails && this.sCurrentFlowConfig.VehicleDetails.currentVal){
                this.strDraftStage = 'VehicleDetails';
            }
            if(this.sCurrentFlowConfig.Financial && this.sCurrentFlowConfig.Financial.currentVal){
                this.strDraftStage = 'FinancialDetails';
            }
            if(this.sCurrentFlowConfig.References && this.sCurrentFlowConfig.References.currentVal){
                this.strDraftStage = '';
            }

            saveDraftStage({ strLoanAppId : this.recordId, currentStage : this.strDraftStage})
            .then(result => {
                console.log('result is '+JSON.stringify(result));
            })
            .catch(error => {
                console.log('result is '+error)
            })
        }
    }

    
    updateRecordView() {
        setTimeout(() => {
             eval("$A.get('e.force:refreshView').fire();");
        }, 1000); 
    }
    handleGlobalState(event){
        console.log(' === Global state === ');
        const { vahanRaw, sectionName } = event.detail;
        console.log({vahanRaw});
        this.globalState = { ...this.globalState, [sectionName]: { vahanRaw }};
        console.log('State ==> ', JSON.parse(JSON.stringify(this.globalState)));
    }    
}