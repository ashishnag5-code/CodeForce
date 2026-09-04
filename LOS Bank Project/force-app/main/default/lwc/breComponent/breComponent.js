import { LightningElement, track, api } from 'lwc';
import updateLoanApp from '@salesforce/apex/LosKYCController.updateLoanApp';
import FORM_FACTOR from '@salesforce/client/formFactor';
//import getLoanApplicationStage from '@salesforce/apex/AUSFPreApprovedCheckController.getLoanApplicationStage';
import checkForBRERun from '@salesforce/apex/BREHandler.checkForBRERun';
import createBRERequest from '@salesforce/apex/BREHandler.createBRERequest';
import createBREIntegrationChecklist from '@salesforce/apex/BREHandler.createBREIntegrationChecklistRecord';
import recordTypeVsStageMetadataHandler from '@salesforce/apex/LightningPathLWCController.recordTypeVsStageMetadataHandler';
import getBRECurrentLoanStatus from '@salesforce/apex/BREHandler.getBRECurrentLoanStatus';
import riskScoreCalculation from '@salesforce/apex/RiskCalculationController.riskScoreCalculation';
import BRE_Icons from "@salesforce/resourceUrl/BRE_Icons";
import evaluateAndUpdateApplicantRiskCategory from '@salesforce/apex/BREHandler.evaluateApplicantRiskCategory';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import validateToMoveNext from '@salesforce/apex/BREHandler.validateToMoveNext';
import updateNexStageForPreApproved from '@salesforce/apex/BREHandler.updateNexStageForPreApproved';
import { NavigationMixin } from "lightning/navigation";
import LightningConfirm from "lightning/confirm";
import LightningPrompt from "lightning/prompt";
import LightningAlert from "lightning/alert";
import getRevisitScreens from '@salesforce/apex/FinancialViewTemplateR2Controller.getRevisitScreens';
import { showToastMessage } from 'c/lwcutilities';

export default class BreComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    @api stageName;
    @api spinnerImage;
    breRunIcon = BRE_Icons + '/BRE_Icons/BRE-run-(button).png';
    @track isLoading = false;
    setNext = false;
    showBREDetails = false;
    @track isBre = false;
    integrationCheckListRecId;
    @track showBreOutput = false;
    @track showUCCriteria = false;
    @track strRequestId = '';
    @track isAwaitResponse = false;
    @track loadPage = false;
    @track blnuirunBRE = false;
    @track blnskipstageonnext = false;
    @track blnBRERunAndReceived = false;
    @track disableNext = false;
    @track isMobileView = false;
    @track isDesktopScreen = false;
    @track isMobileScreen = false;
    @track isMobile = false;
    @track error = false;

    async connectedCallback() {
        //this.setFormFactor();
        //code
       // this.getBRECurrentStatus();
        await this.evaluateApplicantRiskCategory(this.recordId); //SFAU-1356 - Sachin
        if(!await this.checkRevisitScreenValidation(this.recordId)){//R2-1673
            return
        }
        this.getRiskCalculation();
        
    }

    async checkRevisitScreenValidation(recId){
        let response = await getRevisitScreens({loanId: recId})
        if(response && new Map(Object.entries(response)).size>0){
            let responseMap = new Map(Object.entries(response));
            let loanDetailsMessage
            responseMap.forEach((values, keys) => {
                let screens =''
                if(values && values.split(';').length>0){
                    values = values.replace(' ','')
                    values.split(';').forEach(input=>{
                        if(input=='LoanDetails'){
                            loanDetailsMessage = 'Re-Visit and Update Loan Details';
                        }else if(input=='Financial'){
                            showToastMessage(this,"","error",'Re-Visit and Update Land/Customer Details'+' for '+keys,"sticky");
                        }
                        //screens = (screens==''?screens:(screens+','))+(input=='Financial'?' ':(input=='LoanDetails'?' Loan Details Screen':''))
                    })
                    //screens = screens.substring(0, screens.length - 1);
                }
                
            });
            if(loanDetailsMessage){
                showToastMessage(this,"","error",loanDetailsMessage,"sticky");
            }
            return false
        }
        return true
    }

    // Check BRE Current Status
    checkToRunBRE(){
        this.loadPage = false;
        this.isLoading = true;
        this.disableNext = true;
        checkForBRERun({ loanAppId: this.recordId})
            .then(result => {
                console.log('======= ' + JSON.stringify(result));
                //alert('Hello 1');
                if (result.blnSuccess == true) {
                    //this.isMobileView = result.isMobileView;
                    //this.isDesktopScreen = !result.isMobileView
                }
                //alert('Hello 1 ' + this.isMobileView);
                if (result.blnSuccess == true && result.blnBRERunRequired == true){
                    this.getBRECurrentStatus();
                }
                else if (result.blnSuccess == true && result.blnBRERunRequired == false) {
                    this.isLoading = false;
                    this.handleConfirmClick (result.strMessage, result.strCurrentStage, result.strNextStage, this.recordId);
                }
                else if (result.blnSuccess == false){
                    this.showError('Error', result.strMessage);
                }
            })
            .catch(error => {
                this.error = error;
                this.isLoading = false;
                console.log('error', error);
            })
    }

    async handleConfirmClick(strmsg, currentstage, nextstage, recordid) {
        const result = await LightningConfirm.open({
            message: strmsg,
            variant: "default", // headerless
            label: "OK"
        });
        
        if (result) {
            this.updateStageForPreApproved(currentstage, nextstage);
        }
    }

    updateStageForPreApproved(currentstage, nextstage) {
        this.loadPage = false;
        this.isLoading = true;
        this.disableNext = true;
        updateNexStageForPreApproved({ loanAppId: this.recordId, currentstage: currentstage, nextstage: nextstage})
            .then(result => {
                console.log('======= ' + JSON.stringify(result));
                if (result.blnSuccess == true){
                    this.navigateToRecordPage();
                }
                else if (result.blnSuccess == false){
                    this.isLoading = false;
                    this.showError('Error', result.strMessage);
                }
            })
            .catch(error => {
                this.error = error;
                this.isLoading = false;
                console.log('error', error);
            })
    }


/*
    getBreResponse(){
        
        getBreResponse({ loanAppId: this.recordId })
            .then(result => {
                console.log('result: ', result);  
                
            })
            .catch(error => {
                this.error = error;
                console.log('error', error);
            })
    }
    */
    getRiskCalculation(){
        riskScoreCalculation({ loanAppId:this.recordId })
        .then(result => {
            this.checkToRunBRE ();
        })
        .catch(error => {
            this.error = error;
            console.log('error', error);
        })
    }

    // Check BRE Current Status
    getBRECurrentStatus(){
        this.loadPage = false;
        this.isLoading = true;
        this.disableNext = true;
        getBRECurrentLoanStatus({ loanAppId: this.recordId, strRequestId : this.strRequestId, isbrescreen : true })
            .then(result => {
                console.log('======= ' + JSON.stringify(result));
                if (result.blnSuccess == true){
                    this.isDesktopScreen = !result.isMobileView;
                    this.isMobileScreen = result.isMobileView;
                    if (result.blnRunBRE == true) {
                        this.showBreOutput = false;
                        this.isLoading = false;
                        this.loadPage = true;
                    }
                    else if (result.blnBREError == true) {
                        this.showError('Error', result.strSuccessMessage);
                        this.showBreOutput = false;
                        this.isLoading = false;
                        this.loadPage = true;
                    }
                    else if (result.blnBREReceived == true) {
                        //this.setFormFactor();
                        this.strRequestId = result.strRequestId;
                        this.showBreOutput = true;
                        this.isLoading = false;
                        this.disableNext = false;
                        this.isDesktopScreen = !result.isMobileView;
                        this.isMobileScreen = result.isMobileView;
                    }
                    /*
                    if (result.strBREStatus != '') {
                        this.showToastMessage("", result.strSuccessMessage , "error", "sticky");
                    }
                    else if (result.)
                        if (result.strBREStatus == 'IN PROGRESS') {
                            this.isAwaitResponse = true;
                        }
                    }
                    if (result.blnBREReceived = true) {
                        this.showBreOutput = true;
                        this.isLoading = false;
                        this.isAwaitResponse = !this.isAwaitResponse;
                    }
                    if (this.strRequestId == '' && result.blnBREReceived == false){
                        this.showBreOutput = false;
                    }
                    */
                }
                else if (result.blnSuccess == false){
                    this.showError('Error', result.strSuccessMessage);
                    this.isLoading = false;
                }
                
            })
            .catch(error => {
                this.error = error;
                this.isLoading = false;
                console.log('error', error);
            })

            /*

            if (result.blnSuccess == true){
                    //this.isLoading = false;
                    this.showToastMessage("", result.strSuccessMessage , "success", "sticky");
                    this.showBreOutput = true;
                    this.isLoading = false;
                }
                else if (result.blnSuccess == true){
                    this.showError('Error', result.strErrorMessage);
                    this.isLoading = false;
                }
            })
            .catch(error => {
                this.isLoading = false;
                this.error = error;
                console.log('error'+error);
            }) 
            */
    }
    
    runBRE(){
        console.log('run bre called');
        this.blnskipstageonnext = true;
        this.blnuirunBRE = true;
        this.isLoading = true;
        this.disableNext = true;
        this.isBre = true;
        this.createBREIntegrationChecklistRecord();
    }

    setFormFactor() {
        switch (FORM_FACTOR) {
            case 'Large': {
                this.isMobile = false;
                console.log('this is desktop');
                break;
            }
            case 'Medium': {
                this.isMobile = true;
                console.log('this is tablet');
                break;
            }
            case 'Small': {
                this.isMobile = true;
                console.log('this is mobile');
                break;
            }
        }
    }

    

    updateStage(){
        const application = {
            id : this.recordId,
            stage__c : this.stageName
        };

        updateLoanApp({ loanApp: JSON.stringify(application) })
        .then(result => {
            this.setNext = true;
            console.log('result: ', result);                
        })
        .catch(error => {
            this.error = error;
            console.log('error', error);
        })
    }

    showDetails(){
        this.showBREDetails = false;
    }

    returnToParent() {
        console.log('returning to parent', JSON.stringify(this.applicant));
        let returnObj = {
            'next': true,
            'error': ''
        }

        console.log('return: ', returnObj);
        this.dispatchEvent(new CustomEvent('next', {
            detail: returnObj
        }));
    }

    showError(variant, error) {
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

    

    getRecordTypeVsStagesMetadata(state) {
        recordTypeVsStageMetadataHandler({ recordId : this.recordId })
            .then(result => {
                console.log('result: ', JSON.stringify(result));
                let parseCallbackReq, amlStatus = "";
                let custmMetadataRecLst = result.custmMetadataRecLst[0].Stage__c;
                let parseStageData      = JSON.parse(custmMetadataRecLst);
    //                let integrationCheck    = result.integrationCheckList[0];
                let callBackReq         = result.callBackRequest;
               
              //  let stage               = result.loanApplcationRec[0].Stage__c;
                if(callBackReq) {
                    parseCallbackReq    = JSON.parse(callBackReq);
                    amlStatus         = parseCallbackReq.AML_ACTION;
                }              
                let nextStage = '';
                let stageData     = parseStageData.stages;
                if(this.stageName == 'DDE') {
                    let currStageIndex = stageData.findIndex(stg => stg.Stage__c == 'DDE');
                    nextStage = stageData[currStageIndex+1].Stage__c;

                }
                if(nextStage == 'Credit' && amlStatus == 'Hold') {
                    this.showToastMessage("", "You cannot proceed to next Stage as Loan Application is Rejected due to Fraud Registry", "error", "sticky");
                    this.setNext = false;
                    
                }
                else {
                   // this.stageName = "Credit";
                    this.setNext = true;
                   // this.updateStage();
                }

                if(state == true) {
                    if (this.setNext) {
                        this.returnToParent();
                    } else if(!this.setNext){
                        this.notreturnToParent();
                    }
                }              
            })
            .catch(error => {
                this.error = error;
                console.log('error'+error);
            })
    }

    breComponentControllerHandler() {
        breComponentControllerHandler({ recordId : this.recordId })
            .then(result => {
                console.log('result: ', JSON.stringify(result));
                let amlVal = result;
                return amlVal;           
            })
            .catch(error => {
                this.error = error;
                console.log('error'+error);
            })
    }

    createBREIntegrationChecklistRecord() {
        console.log('In createBREIntegrationChecklistRecord');
        createBREIntegrationChecklist({ 
            loanAppId : this.recordId ,
            integrationMasterName : 'FICO BRE'
        })
            .then(result => {
                if (result.blnSuccess == true){
                    console.log('result: ', result);
                    //this.isLoading = false;
                    this.integrationCheckListRecId = result.intChecklistId;
                    this.showUCCriteria = result.hasShowCriteriaPermission;
                    this.strRequestId = result.strRequestId;
                    this.createBreRequest();
                }
                else if (result.blnSuccess == false){
                    this.isLoading = false;
                    this.showError('Error', result.strErrorMessage);
                }
            })
            .catch(error => {
                this.isLoading = false;
                this.error = error;
                console.log('error'+error);
            })
    }

    createBreRequest(){
        console.log('In createBRERequest');
        createBRERequest({ 
            loanAppId : this.recordId ,
            integrationMasterName : 'FICO BRE',
            strIntChecklistRequestId : this.strRequestId
        })
            .then(result => {
                console.log('Integration Checklist Id: ', result);
                if (result.blnSuccess == true){
                    //this.isLoading = false;
                  //  this.showToastMessage("", result.strSuccessMessage , "success", "sticky");
                    this.strRequestId = result.strRequestId;
                    this.isDesktopScreen = !result.isMobileView;
                    this.isMobileScreen = result.isMobileView;
                    this.showBreOutput = true;
                    this.isLoading = false;
                }
                else if (result.blnSuccess == false){
                    this.showError('Error', result.strErrorMessage);
                    this.isLoading = false;
                }
            })
            .catch(error => {
                this.isLoading = false;
                this.error = error;
                console.log('error'+error);
            })
    }

     notreturnToParent() {
        console.log('returning to parent', JSON.stringify(this.applicant));
        let returnObj = {
            'next': false,
            'error': ''
        }

        console.log('return: ', returnObj);
        this.dispatchEvent(new CustomEvent('next', {
            detail: returnObj
        }));
    }

    @api
    nextHandler() {
        if (this.isBre == false && this.disableNext == false) {
            this.validateToMoveNext();
        }
        /*
        if(this.isBre) {
            this.validateToMoveNext();
//            this.navigateToRecordPage();
            //this.getRecordTypeVsStagesMetadata(true); 
        }
        */
               
    }
    async evaluateApplicantRiskCategory(loanId){
        await evaluateAndUpdateApplicantRiskCategory({ loanId })
            .catch( err => { this.showError('Error', err.body?.message ?? 'An error occured while updating Risk Category. Please contact System Administrator'); console.error(err); } );
    }

    // navigate to Record Home Page
    navigateToRecordPage() {
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                actionName: "view",
                recordId: this.recordId
            }
        });
    }

    validateToMoveNext(){
        console.log('In validateToMoveNext');
        validateToMoveNext({ 
            strLoanId : this.recordId ,
            strRequestId : this.strRequestId
        })
            .then(result => {
                console.log('validateToMoveNext response ' + JSON.stringify(result));
                if (result.blnSuccess == true && result.blnMoveNext == true){
                    this.navigateToRecordPage();        
                }   
                if (result.blnSuccess == true && result.blnMoveNext == false){
                    this.showError('Error', result.strMessage);
                    this.isLoading = false;
                } 
                else if (result.blnSuccess == false){
                    this.showError('Error', result.strMessage);
                    this.isLoading = false;
                }
            })
            .catch(error => {
                this.isLoading = false;
                //this.error = error;
                //console.log('error'+error);
            })
    }

    
    
}