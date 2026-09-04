import { LightningElement, track, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';
import getWizardSettings from '@salesforce/apex/Utility.getWizardSettings';
import fetchWizardState from '@salesforce/apex/GenericWizardController.fetchWizardState';
import saveDraftStage from '@salesforce/apex/GenericWizardController.saveDraftStage';
import getWizardSettingsWire from '@salesforce/apex/GenericWizardController.getWizardSettingsWire';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';


export default class GenericWizard extends NavigationMixin(LightningElement) {
    @api recordId;
    @api sObjectName;
    @api isLoaded = false;
    @api insideRecordPage = false;
    //passed from record page to wizard to show edit mode in wizard
    @api applicantIdForEdit;
    @api vehicleIdForEdit;
    @api flowName = 'Parent_Flow_QDE';
    @api childToFlow = 'Parent_Flow_QDE_Default';
    @track flowNameInWire;
    @api boolReFetchData = false;
    @api aapCount;

    currentPage = 1
    totalPage = 15
    //refreshCounter = 0
    @track loanApplicationRecord = {};
    @track applicantRecord = {};
    @track applicantRecordlist = [];

    startPage = 1;
    offSet = 0;
    isPanMandatory = false;
    sScreenConfigs;
    stageName;
    currentObject = {}
    @track
    sCurrentFlowConfig = {};
    isLoaded = false;
    strDraftStage = '';

    get nextLabel() {
        return 'Next';
    }


    get disablePrevious() {
        return this.currentObject.onPrevious === 0;
    }
    
    previousHandler() {
        console.log('%%% ' + JSON.stringify(this.applicantRecord));
        //if (this.currentPage > this.startPage) {
            //this.oldPage = this.currentPage;
            //this.currentPage = this.currentPage - 1
            //this.enablePage()
            //this.getNextScreen(this.sCurrentFlowConfig,'previous');
            //this.viewNextScreen(this.sCurrentFlowConfig,this.currentPage,this.oldPage);
            this.setOffSet('previous');
            this.updateScreen(this.sCurrentFlowConfig,this.currentObject.onPrevious - this.offSet);
            console.log('result is '+JSON.stringify(this.sCurrentFlowConfig));
            this.isLoaded = false
        //}
    }

    nextHandler(event) {
        this.isLoaded = false;
        let current = event.detail;
        console.log('%%%applicantRecordlist '+JSON.stringify(this.applicantRecordlist));
        //console.log('%% ' + this.template.querySelector(".component").classList.contains("checkSkipKYC"));
        if (current.next) {
            console.log("current.next"+current.next);
            if (current.hasOwnProperty('loanApplicationRecord')) {
                this.loanApplicationRecord = current.loanApplicationRecord;
                this.recordId = this.loanApplicationRecord.Id;
                console.log('loanApplicationRecord', this.loanApplicationRecord.Id);
            }
            if (current.hasOwnProperty('applicantRecord')) {
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
                    this.updateScreen(this.sCurrentFlowConfig,this.currentObject.onSkipKYCNext);
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
                console.log('%%%applicantRecordlist '+JSON.stringify(this.applicantRecordlist));
                this.saveDraftStage();
                if(this.currentObject.onNext === 0){
                    this.navigateToRecordPage(this.recordId);
                }
                else{
                    this.updateScreen(this.sCurrentFlowConfig,this.currentObject.onNext + this.offSet);
                }
                console.log('result is '+JSON.stringify(this.sCurrentFlowConfig));
                //this.enablePage()
                this.isLoaded = false
            }
        }
    }

    setOffSet(button){
        this.offSet = 0;
        if(this.sCurrentFlowConfig.QuickLoan && this.sCurrentFlowConfig.QuickLoan.currentVal 
            && this.applicantRecordlist.length > 0 && this.strDraftStage != '' && this.strDraftStage != 'QuickLoan'){
                this.offSet = this.sCurrentFlowConfig.QuickLoan.offSet;
        }
        if (this.applicantRecord.hasOwnProperty('KYC_Status__c')
            && this.applicantRecord.KYC_Status__c == 'Complete'
            && this.applicantRecord.KYC_Type__c == 'CBS'
            && this.sCurrentFlowConfig.Dedupe && this.sCurrentFlowConfig.Dedupe.currentVal) {
                this.offSet = this.sCurrentFlowConfig.Dedupe.offSet;
        }
        if (this.applicantRecord.hasOwnProperty('KYC_Status__c')
            && this.applicantRecord.KYC_Status__c == 'Complete'
            && this.applicantRecord.KYC_Type__c == 'CBS'
            && this.sCurrentFlowConfig.CustomerInformation && this.sCurrentFlowConfig.CustomerInformation.currentVal) {
                this.offSet = this.sCurrentFlowConfig.CustomerInformation.offSet;
        }
        if(button == 'previous' && this.sCurrentFlowConfig.RelatedApplicants && this.sCurrentFlowConfig.RelatedApplicants.currentVal) {
            this.offSet = this.sCurrentFlowConfig.RelatedApplicants.offSet;
        }
        //return this.offSet;
    }

    //For Initial Quick Loan
    onWizardEvent(event){
        this.insideRecordPage = false;
        if(event.detail.name == 'RelatedApplicant'){
            if(event.detail.mode == 'add'){
                this.recordId = this.loanApplicationRecord.Id;
                this.applicantRecord = {};
                this.updateScreen(this.sCurrentFlowConfig,this.currentObject.onAddEditApplicants);
                console.log('event add count',event.detail.addcount);
                this.aapCount = event.detail.addcount;
            }
            if(event.detail.mode == 'edit'){
                this.recordId = this.loanApplicationRecord.Id;
                console.log('%% '+JSON.stringify(this.applicantRecordlist));
                console.log('%% '+JSON.stringify(event.detail.value));
                this.applicantRecord = this.applicantRecordlist.find((item)=>item.Id === event.detail.value);
                if(this.applicantRecord != undefined){
                    this.updateScreen(this.sCurrentFlowConfig,this.currentObject.onAddEditApplicants);
                }
            }
        }
    }

    finishHandler() {
        this.closeQuickAction();
    }
    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    
    connectedCallback() {
        this.setFormFactor();
        console.log('in wizard');
        if(this.boolReFetchData){
            this.fetchExistingState();
        }
        else{
            this.flowNameInWire = this.flowName;
        }
        /*
        console.log('Form factor - Mobile : ', this.isMobile);
        console.log('Form factor - Mobile : ', this.currentPage);
        console.log('sObjectName', this.sObjectName);
        

        if(this.flowName == undefined && this.childToFlow == undefined){
            this.flowName = 'Parent_Flow_QDE';
            this.childToFlow = 'Parent_Flow_QDE_Default';
        }
        //if(this.recordId == undefined){
        this.stageName = 'QDE'
        //}
        if(this.boolReFetchData){
            this.fetchExistingState();
        }
        else{
            //this.setUpWizard();
        }*/
    }

    @wire(getWizardSettingsWire, { WizardName: '$flowNameInWire' , StageName: 'QDE' })
    wiredWizardSettings({ error, data }){
        if (data) {
            console.log('getWizardSettingsWire error is ' + JSON.stringify(data));
            this.sScreenConfigs = data;
            const pageConfig = this.sScreenConfigs.Generic_Wizard_Current_Page_Configs__r.find((item)=>item.DeveloperName === this.childToFlow);
            this.startPage = pageConfig.Start_Page__c;
            this.currentPage = pageConfig.Current_Page__c;
            this.sCurrentFlowConfig = JSON.parse(data.Screen_Config_Json_Long__c);
            this.updateScreen(this.sCurrentFlowConfig, this.currentPage);
        }
        else if (error) {
            console.log('getWizardSettingsWire error is ' + JSON.stringify(error));
        }
    }
    
    setUpWizard(){
        getWizardSettings({ WizardName : this.flowName ,StageName : this.stageName})
        .then(result => {
            console.log('result is '+JSON.stringify(result));
            this.sScreenConfigs = result;
            const pageConfig = this.sScreenConfigs.Generic_Wizard_Current_Page_Configs__r.find((item)=>item.DeveloperName === this.childToFlow);
            this.startPage = pageConfig.Start_Page__c;
            this.currentPage = pageConfig.Current_Page__c;
            this.sCurrentFlowConfig = JSON.parse(result.Screen_Config_Json_Long__c);
            this.updateScreen(this.sCurrentFlowConfig, this.currentPage);
        })
        .catch(error => {
            console.log('result is '+error)
            this.error = error;
            this.isLoading = false;
        })
    }

    fetchExistingState(){
        fetchWizardState({ strLoanAppId : this.recordId})
        .then(result => {
            console.log('result is '+JSON.stringify(result));
            console.log('result is '+ this.applicantIdForEdit);
            this.loanApplicationRecord = result;
            this.strDraftStage = result.Draft_Stage__c;
            if(result.Applicants__r != undefined){
                this.applicantRecordlist = result.Applicants__r;
                this.applicantRecord = result.Applicants__r.find((item)=>item.Id === this.applicantIdForEdit);
            }
            if(this.applicantRecord == undefined){
                this.applicantRecord = {};
            }
            console.log('result is '+ this.applicantRecord);
            //this.setUpWizard();
            this.flowNameInWire = this.flowName;
        })
        .catch(error => {
            console.log('result is '+error)
            this.error = error;
            this.isLoading = false;
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

    updateScreen(object, stepCounter) {
        Object.keys(object).forEach((key)=>{
            console.log(key);
            console.log(object[key]);
            if(object[key].stepCounter === stepCounter){
                object[key].currentVal = true;
                this.currentObject = object[key];
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
        this.navigateToRecordPage(this.loanApplicationRecord.Id);
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

    childNextHandler() {
        this.isLoaded = true;
        this.template.querySelector(".component").nextHandler();
    }

    saveDraftStage(){
        if(this.flowName == 'Parent_Flow_QDE'){
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
     
}