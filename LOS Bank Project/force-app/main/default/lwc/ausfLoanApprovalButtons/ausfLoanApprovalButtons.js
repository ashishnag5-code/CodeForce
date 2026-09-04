/*
Logs:
@ LastModified Date   -   Last Modified By    -   Comments
@ Sept-12-2023        -   Mohit M.            -   SFAU-5134 - BRE-Rerun should not be available for Pricing
@ Nov-30-2023         -   Mohit M.            -   SFAU-5673
*/
import { LightningElement, api, track, wire } from "lwc";
import getApproverList from "@salesforce/apex/AUSFApproverController.getApproverList";
import rejectLoanApplication from "@salesforce/apex/AUSFApproverController.rejectLoanApplication";
import sendBackToRoLoanApplication from "@salesforce/apex/AUSFApproverController.sendBackToRoLoanApplication";
import getLevelVsApprovers from "@salesforce/apex/AUSFApproverController.getLevelVsApprovers";
import validateAndAssignForRelook from "@salesforce/apex/AUSFApproverController.validateAndAssignForRelook";
import getLoanApp from "@salesforce/apex/AUSFApproverController.getLoanApp";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import validateCreditVerification from '@salesforce/apex/CreditVerification.validateCreditVerification';
import acceptApprovalFromQueue from '@salesforce/apex/AUSFApproverController.acceptApprovalFromQueue';
import revokeDelegatedUserAccess from '@salesforce/apex/AUSFApproverController.revokeDelegatedUserAccess';
//import updateVehicleCostBasedOnValuationRecieved from '@salesforce/apex/AUSFApproverController.updateVehicleCostBasedOnValuationRecieved';
//import valuationVerificationRequired from '@salesforce/label/c.ValuationVerificationRequired';
import FORM_FACTOR from "@salesforce/client/formFactor";
import LOAN_APPROVAL from '@salesforce/resourceUrl/LoanApproval';
import LOAN_APPROVAL_FORWARD from '@salesforce/resourceUrl/LoanApprovalForward';
import LOAN_APPROVAL_SENTBACK from '@salesforce/resourceUrl/LoanApprovalSendBack';
import RunBREBeforeApprovalMsgLabel from '@salesforce/label/c.Run_BRE_Before_Approval_Message';
import isNPAResolvedForTractorApplications from '@salesforce/apex/CreditVerification.isNPAResolvedForTractorApplications';//R2-34
//import LightningConfirm from 'lightning/confirm';
// Financial Template by credit resources
import isFinancialTemplateConditionMatchNDataNotFilled from '@salesforce/apex/AusfbFinancialByCreditController.isFinancialTemplateConditionMatchNDataNotFilled'
import createOrArchiveDeviationFinancialTemplate from '@salesforce/apex/AusfbFinancialByCreditController.createOrArchiveDeviationFinancialTemplate';
import getRevisitScreens from '@salesforce/apex/FinancialViewTemplateR2Controller.getRevisitScreens';
import { showToastMessage } from 'c/lwcutilities';
import FINANCIAL_TEMPLATE_CREDIT_VALIDATION_MESSAGE from '@salesforce/label/c.Financial_Template_for_Credit_Validation';
// Financial Template by credit resources

import {
  subscribe,
  unsubscribe,
  APPLICATION_SCOPE,
  MessageContext,
} from 'lightning/messageService';
import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c';

//import { CloseActionScreenEvent } from 'lightning/actions';

const RELOOK_STATUS = [
  'Credit Rejected',
  'Pricing Rejected',
];
const ACTION_TYPE_ACCEPT = 'Accept';
const ACTION_TYPE_APPROVAL = 'Approve';
const ACTION_TYPE_SEND_BACK_TO_RO = 'Send_To_RO';
const ACTION_TYPE_REJECTION = 'Reject';
const ACTION_TYPE_FORWARD = 'Forward';
const ACTION_TYPE_REASSIGN = 'Reassign';
const APPROVEL_STATUS_REJECTED = 'Rejected';
const ACTION_TYPE_RELOOK = 'relook';
const ACTION_TYPE_BRE_RERUN = 'ReRun_BRE';
const APPROVE_DISABLED_SUB_STAGES = 'Rejected';
const STAGE_PSD = 'PSD';

const APPROVAL_REJECTION = 'Approval_Rejection';

const DEFAULT_ERROR_MESSAGE = 'There\'s an error while processing your request. Please contact System Administrator';
const APPROVAL_SUBMISSION_NEXT_LEVEL = 'Loan Application has been submitted to next level for approval';
const APPORVAL_SUBMISSION_APPROVED = 'Loan Application has been successfully approved';

// Custom Spinner settings
import { getSpinnerImage } from 'c/customSpinner';
// Custom Spinner settings

export default class AusfLoanApprovalButtons extends LightningElement {
  @api recordId;
  isApprove = false;
  currentApprovalRecord = {};
  @track items = [];
  @track error;
  isloading = false;
  currentApprover;
  rejectedApprover;
  @track relookApprovers = [];
  isSendBackToRo = false;
  isReAssign = false;
  isTwoWheeler = false;
  loanAppRecord;
  isCreditStage = false
  isPricingStage = false
  levelOptions=[];
  levelVsApproverMap;
  isForward =false;
  isLoaded = false;
  isCibilRunAgain = false;
  isRunValuationAgain = false;
  isRunFIAgain = false;
  showComp = false;
  isBeingApproved = false;
  currentAction;
  needPreApprovalAction;
  isBreReRunRequired;
  subscription = null;
  allowRevoke;
  isRelook;
  allowReassignment;
  showDealBackgroundSection;
  loan_ApprovalIconSrc = LOAN_APPROVAL;
  loan_ApprovalForwardIconSrc = LOAN_APPROVAL_FORWARD;
  loan_ApprovalSentBackIconSrc = LOAN_APPROVAL_SENTBACK;

  @track isMobile = false;

  label = {
    RunBREBeforeApprovalMsgLabel
  };

  get hideApprovalActions(){
    return this.isApprove || this.isBeingApproved|| this.needPreApprovalAction || this.allowRelookBySomeone || this.allowReassignment;
  }

  get allowRelookBySomeone(){
    return this.loanAppRecord?.Stage__c === APPROVEL_STATUS_REJECTED;
  }

  get approveActionLabel(){
    return this.isBreReRunRequired ? 'ReRun BRE' : 'Approve';
  }

  get isBreScreen(){
    return this.currentAction === ACTION_TYPE_BRE_RERUN;
  }

  get isBeingRejected(){
    return this.currentAction === ACTION_TYPE_REJECTION;
  }

  get showApprovalSubmissionActions(){
    return !this.isApprove && !this.isForward && !this.isReAssign;
  }

  get isAtPSD(){
    return this.loanAppRecord?.Stage__c === STAGE_PSD;
  }

  get allowReassign(){
    return this.isTwoWheeler && !this.allowRelookBySomeone && !this.isAtPSD;
  }

  get isApproveDisabled(){
    return APPROVE_DISABLED_SUB_STAGES.includes(this.loanApp?.Sub_Stage__c);
  }
  connectedCallback(){
    this.isMobile = (FORM_FACTOR === "Small");
    this.subscribeToMessageChannel();
    this.getLoanApplication();
  }

  // Custom Spinner settings
  async spinnerImageMethod() {
    if(this.spinnerImage == undefined){
        this.spinnerImage = await getSpinnerImage(this.recordId);
    }
  }
  // Custom Spinner settings

  
  async getLoanApplication() {
    await this.spinnerImageMethod();
    this.isLoaded = true
    getLoanApp({ recordId: this.recordId })
      .then((data) => {
        this.isLoaded = false
        if (data) {
          console.log("data is " + JSON.stringify(data));
          this.isTwoWheeler = data.isTwoWheeler;
          this.loanAppRecord = data.loanApp;
          this.isCreditStage =data.isCreditStage;
          this.isPricingStage = data.isPricingStage;
          this.isCibilRunAgain = data.isGenerateCibilAgain;//false;//data.isGenerateCibilAgain;
          this.isRunFIAgain = data.isRunFIAgain;
          this.isRunValuationAgain = data.isRunValuationAgain;
          this.needPreApprovalAction = data.needPreApprovalAction && this.loanAppRecord?.Stage__c !== APPROVEL_STATUS_REJECTED;
          this.showComp = data.showComp || this.needPreApprovalAction;
          this.allowRevoke = data.allowRevoke;
          this.allowReassignment = data.allowReassignment;
          this.isBreReRunRequired = data.isBreReRunRequired;
          /* START SFAU-5134  */
          if (this.isPricingStage == true || this.isPricingStage == 'true') {
            this.isBreReRunRequired = false;
          }
          /* END SFAU-5134 */
        }
      })
      .catch((error) => {
        this.isLoaded = false;
        if (error) {
          this.error = error;
        }
      });
  }

  handleForward(event){
    //alert('clicked')
    const { name: action } = event.target;
    
    this.currentAction = action;
    if(this.isMobile){
      this.currentAction = 'Forward';
    }
   //alert('current action '+this.currentAction)
      this.isLoaded = true;
      this.levelOptions = [];
      getLevelVsApprovers({ loanAppId: this.recordId})
        .then((result) => {
          this.isLoaded = false;
          //alert('inside result')
          console.log("result " + JSON.stringify(result));  
          if (result) {
            this.isBeingApproved = true;
            this.isForward = (this.isMobile)?true:action === ACTION_TYPE_FORWARD;
            //alert('this.isFor '+this.isForward)
            this.isReAssign = action === ACTION_TYPE_REASSIGN;
            //this.approverOptions = result.levels;
            this.levelVsApproverMap = result.mapOfApproverLevelVsAccountTeam;
            result.levels?.sort();
            if (result.levels.length > 0) {
              for (let i = 0; i < result.levels.length; i++) {
                console.log('')
                this.levelOptions = [
                  ...this.levelOptions,
                  {
                    value: result.levels[i],
                    label: result.levels[i]
                  }
                ];
              }
              //this.isApprove = true;
            }
          }
          
        })
        .catch((error) => {
          this.isLoaded = false;
          this.error = error;
        });
  }

  getApprovers(approvalRecord) {
    this.isLoaded = true;
    this.items = [];
    console.log({approvalRecord});
    getApproverList({ loanAppId: this.recordId, approvalRecord })
      .then((data) => {
        if (data) {
          this.currentApprover = data.currentId;
          if(data.loanApprovals){
            console.log("data is " + JSON.stringify(data.loanApprovals));
            if (data.loanApprovals.length > 1) {
              console.log("currentId " + this.currentApprover);
              for (let i = 0; i < data.loanApprovals.length; i++) {
                this.items = [
                  ...this.items,
                  {
                    value: data.loanApprovals[i].Id,
                    label: data.loanApprovals[i].Approver__r.Name
                  }
                ];
              }
              this.showToast('Please select next approver.')
              this.isApprove = true;

            }else{
              this.showComp = false;
              this.isBeingApproved = false;
              this.showToast(data.isFinalApproval ?  APPORVAL_SUBMISSION_APPROVED : APPROVAL_SUBMISSION_NEXT_LEVEL);
            }
          }else{
            this.showComp = false;
            this.isBeingApproved = false;
            this.showToast(data.isFinalApproval ?  APPORVAL_SUBMISSION_APPROVED : APPROVAL_SUBMISSION_NEXT_LEVEL);
          }
          this.isLoaded = false;
        }
      })
      .catch((error) => {
        this.isLoaded =false;
        this.showToast( error.body?.message ?? DEFAULT_ERROR_MESSAGE, 'error' );
        if (error) {
          this.error = error;
        }
      });
  }

  async acceptApproval(){
    this.isLoaded = true;
    this.currentAction = ACTION_TYPE_ACCEPT;
    const response = await acceptApprovalFromQueue( { loanId: this.recordId } )
      .catch(err => { this.isLoaded = false; this.showToast( err.body?.message ?? DEFAULT_ERROR_MESSAGE, 'error' ); console.error( err ); });
    
    if(response){
      const { showComp, needPreApprovalAction } = response;
      if(!needPreApprovalAction && showComp){
        this.showToast( 'You\'ve successfully picked this loan approval from queue' );
      }

      this.showComp = showComp;
      this.needPreApprovalAction = needPreApprovalAction;
      this.isLoaded = false;
    }
  }

  async handleApprove() {
    try{
      this.currentAction = this.isBreReRunRequired ? ACTION_TYPE_BRE_RERUN : ACTION_TYPE_APPROVAL;

      if(this.isBreReRunRequired || this.currentAction !== ACTION_TYPE_APPROVAL){
        return;
      }
      //SFAU-5147 || START
      let result = await  getLoanApp({ recordId: this.recordId });
      let loanApp = result.loanApp;
      let isTwoWheelerApp = result.isTwoWheeler;
      if(loanApp.ReTrigger_EMI_Schedule__c==true && !isTwoWheelerApp && loanApp.Stage__c=='Credit'){//Pricing users cannot make changes - added stage check
        showToastMessage(this,"","error",'Re-initiate EMI Schedule',"sticky");
        return
      }
      let r2RecordTypes = ['Tractor','Commercial_Equipment','Commercial_Vehicle']
      //END 
      //R2-34 start
      if(loanApp.RecordType.DeveloperName=='Tractor'){
        const resp = await isNPAResolvedForTractorApplications({loanId : this.recordId})
        if(resp.status=='Fail'){
          this.showToastMessage(resp.errorMessage,'error');
          return        
        }
      }//R2-34 end

      // Finance template by credit validation check
      const isFinancialTemplateError = await isFinancialTemplateConditionMatchNDataNotFilled({loanId : this.recordId});
      // Finance template by credit validation check

      //R2-1757
      if(r2RecordTypes.includes(loanApp.RecordType.DeveloperName)){
        let response = await getRevisitScreens({loanId: this.recordId})
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
      }//R2-1757 end
      if(this.isCibilRunAgain){
        this.showToast('Please generate cibil again because it is 30 days old')
      }
      //SFAU-5673 AND SFAU-5795 - START
      else if(result.isBreReRunRequired && result.isPricingStage == false){
        this.isBreReRunRequired = true;
        this.currentAction = ACTION_TYPE_BRE_RERUN;
        this.showToast(this.label.RunBREBeforeApprovalMsgLabel, 'error' );
      }
      //SFAU-5673 - END
      else if(loanApp.isLoanAmtChanged__c){  //SFAU-5147 
        this.showToast( 'Loan amount modified please refresh the charges', 'error' );////SFAU-5147 
      }else if(this.isRunFIAgain){
        this.showToast('Please generate FI again because it is 30 days old')
      }else if(this.isRunValuationAgain){
        this.showToast('Please generate Valuation again because it is 30 days old')
      }
      else if(isFinancialTemplateError != 'no-error'){ // Finance template by credit validation check
        const errorMsg = FINANCIAL_TEMPLATE_CREDIT_VALIDATION_MESSAGE.replace('{applicant_name}', isFinancialTemplateError);
        const event = new ShowToastEvent({
          title: 'ERROR',
          message: errorMsg,
          variant: 'error',
          mode: 'sticky'
        });
        this.dispatchEvent(event);
        
    } // Finance template by credit validation check
        /*
    else if(this.loanAppRecord?.Is_Valuation_Verification_Required__c ){ // SFAU-4091 * Valuation have received, Credit has to verify the updated vehicle details
      // this.showToast( valuationVerificationRequired, 'info' );
      this.updateVehicleDetailsBasedOnValuationReceived( this.recordId );
    } */ 
    else{
      const creditVerified = await validateCreditVerification({documentType:'',loanApplicationId:this.recordId})
      // START - SFAU-5663
      if(creditVerified.blnSuccess == true && creditVerified.blnSanctionCompleted == false){
        const event = new ShowToastEvent({
          title: 'Complete',
          message: 'Please complete Sanctioned Conditions',
          variant: 'error',
          mode: 'sticky'
        });
        this.dispatchEvent(event);
      }
      else if (creditVerified.blnSuccess == true && creditVerified.lstDocument != undefined && creditVerified.lstDocument.length == 0) {
        this.isBeingApproved = true;
      }else if (creditVerified.blnSuccess == true && creditVerified.lstDocument != undefined && creditVerified.lstDocument.length > 0) {
        this.isBeingApproved = false;
        var pendingDocuments = '';
        creditVerified.lstDocument.forEach(input=>{
          pendingDocuments = pendingDocuments+input+'; '
        })
        const event = new ShowToastEvent({
          title: '',
          message: 'Please complete Document Verification for '+pendingDocuments,
          variant: 'error',
          mode: 'sticky'
        });
        this.dispatchEvent(event);
      }
      else if (creditVerified.blnSuccess == false) {
        this.isBeingApproved = false;
        const event = new ShowToastEvent({
          title: '',
          message: 'There is some error!!',
          variant: 'error',
          mode: 'sticky'
        });
        this.dispatchEvent(event);
      }
      /* SFAU-5663 - Commented
      if(creditVerified && creditVerified.length==0){
        this.isBeingApproved = true;
      }else{
        this.isBeingApproved = false;
        var pendingDocuments = '';
        creditVerified.forEach(input=>{
          pendingDocuments = pendingDocuments+input+'; '
        })
        const event = new ShowToastEvent({
          title: '',
          message: 'Please complete Document Verification for '+pendingDocuments,
          variant: 'error',
          mode: 'sticky'
        });
        this.dispatchEvent(event);
      }
      */
      
      // this.getApprovers();
    }
    }
    catch(e){
      this.showToast('Something went wrong while approving ' + JSON.stringify(e), 'error' );
    }
    
    
  }


  handleReject() {
    // this.isLoaded = true;
    this.currentAction = ACTION_TYPE_REJECTION;
    // this.isBeingApproved = true;
  }

  handleReassign(){
    this.isReAssign = true;
  }

  @wire(MessageContext)
    messageContext;

  handleSendBackToRo() {
    //  this.isLoaded = true;
    this.isBeingApproved = true;
    this.currentAction = ACTION_TYPE_SEND_BACK_TO_RO;

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
      this.getLoanApplication();
    }
  }

  unsubscribeToMessageChannel() {
    unsubscribe(this.subscription);
    this.subscription = null;
  }

  disconnectedCallback() {
      this.unsubscribeToMessageChannel();
  }


  async handleRelook(){
    this.isLoaded = true;
    this.relookApprovers = [];
    this.rejectedApprover = null;
    /*getRelookApprovers({ loanAppId: this.recordId })
      .then((data) => {
        if (data) {
          this.isLoaded = false;
          console.log("data is " + JSON.stringify(data));
          if (data.length) {
            for (let i = 0; i < data.length; i++) { 
              if(!this.rejectedApprover && data[i].Approval_Status__c === APPROVEL_STATUS_REJECTED){
                this.rejectedApprover = data[i].Approver__c;
              }
              this.relookApprovers = [
                ...this.relookApprovers,
                {
                  value: data[i].Approver__c,
                  label: data[i].Approver__r.Name
                }
              ];
            }
            this.isRelook = true;
          }
        }
      })
      .catch((error) => {
        this.isLoaded = false;
        if (error) {
          this.error = error;
        }
      });*/
      await this.getBranchApproverHierarchy();
      // this.isRelook = true;
  }

  showToast(message, variant = 'success' ) {
    const event = new ShowToastEvent({
        title: '',
        message: message,
        variant,
        mode: 'sticky'
    });
    this.dispatchEvent(event);
}

  showToastMessage(message, variant) {
    const event = new ShowToastEvent({
        title: '',
        message: message,
        variant,
        mode: 'sticky'
    });
    this.dispatchEvent(event);
  }

handleNextApprover(event){
  let obj = event.detail;
  console.log('obj '+obj)
  this.isApprove = obj;
  this.isBeingApproved = false;
  this.showComp = false;
}
handleFowardApprover(event){
  const { action, isDissmissal } = event.detail;
  if(action === ACTION_TYPE_FORWARD){
    this.isForward = false;
    this.isBeingApproved = false;
    this.getLoanApplication();
  } else if(action === ACTION_TYPE_REASSIGN){
    this.isReAssign = false;
    this.getLoanApplication();
    this.isBeingApproved = false;
  } else if( action === ACTION_TYPE_RELOOK ){
    this.isRelook = false;
    this.isBeingApproved = false;
    this.getLoanApplication();
  }
  this.showComp = !!isDissmissal;
}

  async handleSubmit(){
    const remarksFieldToken = this.template.querySelector('lightning-textarea');
    if(remarksFieldToken.checkValidity()){
      const { value: creditManagerRemarks } = remarksFieldToken;
      console.log(creditManagerRemarks);
      this.currentApprovalRecord = { Remarks__c: creditManagerRemarks };
      this.isLoaded = true;
      if(this.currentAction === ACTION_TYPE_APPROVAL){
        this.getApprovers(this.currentApprovalRecord);
        // Create deviation or archive deviation based on values in financial template by credit
        await createOrArchiveDeviationFinancialTemplate({loanId : this.recordId});
      } else if(this.currentAction === ACTION_TYPE_REJECTION){
        this.rejectLoanApplication( this.recordId, this.currentApprovalRecord );
      } else if(this.currentAction === ACTION_TYPE_SEND_BACK_TO_RO) {
        this.sendApplicationToRo( this.recordId, creditManagerRemarks );
      }
    } else {
      remarksFieldToken.reportValidity();
    }
  }
  handleCancel(){
    this.isBeingApproved = false;
    this.currentApprovalRecord = { ...this.currentApprovalRecord, Remarks__c: null };   
    this.currentAction = null;
  }
  handleRelookSucces(){
    this.isRelook = false;
    
    this.connectedCallback();
  }
  sendApplicationToRo(loanAppId, creditManagerRemarks){
    sendBackToRoLoanApplication({ loanAppId, creditManagerRemarks })
      .then(() => this.showToast('Loan Application successfully sent back to RO'))
      .catch(err => { console.error(err); this.error = err.body?.message ?? DEFAULT_ERROR_MESSAGE; })
      .finally(() => {
        this.isLoaded = false; 
        this.isBeingApproved = false;
        this.showComp = false;
      });
  }
  rejectLoanApplication( loanAppId, currentApprovalRecord ){
    rejectLoanApplication({ loanAppId, currentApprovalRecord })
      .then(() => { this.showToast('Loan Application successfully rejected'); this.showComp = false; })
      .catch((error) => { this.error = error.body?.message; })
      .finally(() => { this.isLoaded = false; });
  }

  async handleModelActions(event){
    // console.log(event.detail);
    // const { action, reason, isSuccess } = event?.detail ?? {};
    // console.log({action, reason, isSuccess});
    // if(action === APPROVAL_REJECTION && isSuccess){
    //   // await rejectLoanApplication({ loanAppId: this.recordId, currentApprovalRecord: { Remarks__c: reason }});
    // }
    this.currentAction = null;
    this.connectedCallback();
  }
  populateCreditUserRemarks(event){
    const { value: remarks } = event.detail;
    
    clearTimeout(this._debounceTimer);

    this._debounceTimer = setTimeout(() => { this.currentApprovalRecord = { Remarks__c: remarks }; }, 2000);
    
  }
  handleDelegatedUserRevoke(){
    this.isLoaded = true;

    const loanId = this.recordId;
    revokeDelegatedUserAccess({ loanId })
      .then(resp => {
        this.isLoaded = false;
        this.getLoanApplication();
        this.showToast(`${resp.Approver__r?.Name ?? 'Delegated User'} access has been revoked. The user can no longer approve / reject this application`);
      }).catch( err => this.showToast(err?.body?.message ?? 'An error occred while revoking access of the delegated user.', 'error'));
  }
  async getBranchApproverHierarchy(){
    const result = await validateAndAssignForRelook({ loanId: this.recordId }).catch(err => console.log(err.body?.message));
    console.log({result});
    this.isLoaded = false;
    if( result.hasActiveApproval ){
      const { mapOfApproverLevelVsAccountTeam } = result;
      const [ assigneeApprovals ] = Object.values(mapOfApproverLevelVsAccountTeam);
      this.showToast( `Successfully assigned to ${assigneeApprovals?.[0].Approver__r?.Name ?? 'the Credit User'}` );
      this.getLoanApplication();
      return;
    }
    this.isRelook = true;
    /*const result = await getLevelVsApprovers({ loanAppId: this.recordId})
      .catch((error) => { this.isLoaded = false; this.error = error; });
    
    this.isLoaded = false;
    console.log("result " + JSON.stringify(result));  
    if (result) {*/
      //this.approverOptions = result.levels;
      // this.isRelook = true;
      this.levelVsApproverMap = result.mapOfApproverLevelVsAccountTeam;

      result.levels?.sort();

      if (result.levels.length > 0) {
        for (let i = 0; i < result.levels.length; i++) {
          console.log('')
          this.levelOptions = [
            ...this.levelOptions,
            {
              value: result.levels[i],
              label: result.levels[i]
            }
          ];
        }
      }
    // }
  }
  
  addDealBackground(){
    this.showDealBackgroundSection = true;
  }

  closeDealBackgroundModal(){
    this.showDealBackgroundSection = false;
  }

/*
  // SFAU-4091
  async updateVehicleDetailsBasedOnValuationReceived( loanId ){
    // const collateral = await getCollateralDetails({ loanId }).catch( err => console.error(err));
    const result = await LightningConfirm.open({
      message: valuationVerificationRequired,
      variant: 'headerless',
      label: valuationVerificationRequired,
    });
    console.log({result});
    if(result){
      const resp = await updateVehicleCostBasedOnValuationRecieved({ loanId })
        .catch(err => {
          this.showToast( err.body?.message ?? err.body.pageErrors?.[0]?.message, 'error' );
          console.error(err);
        });
      
      this.getLoanApplication();
    }
  }
  */
}