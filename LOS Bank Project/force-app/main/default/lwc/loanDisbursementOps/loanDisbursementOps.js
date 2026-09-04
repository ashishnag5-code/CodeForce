import { api, LightningElement, track, wire } from 'lwc';
import getVisibleFieldsForLoanDetails from '@salesforce/apex/LoanDetailsController.getVisibleFieldsForLoanDetails'
import getPaymentFavourings from '@salesforce/apex/LoanDisbursementOpsController.getPaymentFavourings'
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import LOAN_APPLICATION_OBJECT from '@salesforce/schema/Loan_Application__c'
import getLoanDetails from '@salesforce/apex/LoanDisbursementOpsController.getLoanDetails'
import { updateRecord } from 'lightning/uiRecordApi';
import generateLoanDisbursementDetails from '@salesforce/apex/LoanDisbursementDetailsApiController.generateLoanDisbursementDetails'
import generateDisbursementDeductions from '@salesforce/apex/DisbursementDeductionDetailsController.generateDisbursementDeductions'
import generateDisbursementStage from '@salesforce/apex/DisbursementStageApiController.generateDisbursementStage'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getRepaymentSchedule from '@salesforce/apex/LoanDisbursementOpsController.getRepaymentSchedule'
import getPDFData from '@salesforce/apex/EMIScheduleAPIController.getPDFData'
import getTrancheDetails from '@salesforce/apex/LoanDisbursementOpsController.getTrancheDetails'
import generateDoDisbursement from '@salesforce/apex/DoDisbursementAPIController.generateDoDisbursement'
import getUserDetails from '@salesforce/apex/LoanDisbursementOpsController.getUserDetails'
import generateTrancheDisbursement from '@salesforce/apex/TrancheDisbursementAPIController.generateTrancheDisbursement'
import getLatestEmiSchedule from '@salesforce/apex/EMIScheduleAPIController.getLatestEmiSchedule'
import getRepaymentScheduleForAuthor from '@salesforce/apex/EMIScheduleAPIController.getRepaymentScheduleForAuthor'
import getLoanId from '@salesforce/apex/CIFCreationController.getLoanId'
import getAssignmentRecordDetails from '@salesforce/apex/LoanDisbursementOpsController.getAssignmentRecordDetails'
import getAssignmentRecordDetailsByLoan from '@salesforce/apex/LoanDisbursementOpsController.getAssignmentRecordDetailsByLoan'
import isBSRPSLComplete from '@salesforce/apex/LoanDisbursementOpsController.isBSRPSLComplete'
import doIFTPayment from '@salesforce/apex/PaymentIFTAPIController.doIFTPayment'
import { getSpinnerImage } from 'c/customSpinner';
import createAddendumDocument from '@salesforce/apex/LoanDisbursementOpsController.createAddendumDocument'
import sendNotificationToRO from '@salesforce/apex/LoanDisbursementOpsController.sendNotificationToRO'
import sendDisbursedNotification from '@salesforce/apex/DoDisbursementAPIController.sendDisbursedNotification'
import checkMotorInsurance from '@salesforce/apex/LoanDisbursementOpsController.checkMotorInsurance'
import checkIfDibursePaymentDone from '@salesforce/apex/LoanDisbursementOpsController.checkIfDibursePaymentDone'
import updateDisbursementDateTime from '@salesforce/apex/LoanDisbursementOpsController.updateDisbursementDateTime' 
import updateLoanApplicationRecord from '@salesforce/apex/LoanDisbursementOpsController.updateLoanApplicationRecord' 
import updatePaymentTrancheRecord from '@salesforce/apex/LoanDisbursementOpsController.updatePaymentTrancheRecord'
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
  } from 'lightning/messageService';
  import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c';
  import My_Resource from '@salesforce/resourceUrl/ausfIcons';
  import MyModal from 'c/callEsignFromLoanDisbursement';
  import minFirstEMIDaysOps from '@salesforce/label/c.minFirstEMIDaysOps';
  
export default class LoanDisbursementOps extends NavigationMixin(LightningElement) {

    @track isAddedumStatusPending=false
    @track loanApp = {};
    displayButtonOnPayment=true
    dontDisplayButtonOnPayment=false
    @wire(MessageContext)
    messageContext;
    @api recordId;
    @track generalLedgerOptions = []
    @api spinnerImage;
    @api objectApiName;
    paymentRecId;
    isUserMaker
    isLoading;
    recordTypeId = '';
    disbursementCategoryOptions = [];
    modeOfDisbursementOptions = [];
    scheduleNameOptions = [];
    sessionId;
    netDisbursementAmount = 0
    disbursementAmount = 0
    disableFields = false
    displayPayments = false
    displayValidatePayments=false
    displayReleasePayments=false
    trancheId = ''
    excludeFieldList = ['RecordTypeId', 'Stage__c', 'Application_Id__c', 'Applicants__r', 'Total_Loan_Amount__c','Name'];
    displayLoanDisbursementDetails = false
    loanBalanceResponse = {}
    userType
    currentTranche
    loadComponents = false
    @track loanAppId;
    @track paymentFavouringParentId;
    @track paymentFavouringDisbursementAmount;
    @track paymentFavouringTotalCharges;
    minROI = 0;
    maxROI = 0;
    totalNonChequePoolAmount = 0;
    totalChequePoolAmount = 0;
    ROIUnderFlowError = '';
    ROIOverFlowError = '';
    chequePrintLocationRequired = false
    completedStage = '';
    emiDateOptions=[]
    paymentFavouringsToBeValidated=false
    openEMIModal = false;
    esignType = 'Addendum Document';
    generateEsign      = My_Resource + '/ausfIcons/Generate-E-sign.png';
    @track assignmentRecord
    @track bsrPslCompleted
    
    async connectedCallback() {
        this.subscribeToMessageChannel();
        this.setInitialData()
    }

    async setInitialData(){
        this.userType = await getUserDetails();
        if(this.objectApiName =='Loan_Application__c'){
            this.assignmentRecord = await getAssignmentRecordDetailsByLoan({recordId: this.recordId})
            this.loanAppId = this.recordId;
            this.recordId = this.assignmentRecord.Id
            if(this.assignmentRecord.OwnerId.startsWith('00G')){
                this.userType='Group'
            }
            this.getLoanAppDetails();
        }{
            this.assignmentRecord = await getAssignmentRecordDetails({recordId: this.recordId})
            getLoanId({ recordId: this.recordId }).then((data => {
                this.loanAppId = data
                if(this.assignmentRecord.OwnerId.startsWith('00G')){
                    this.userType='Group'
                }
                this.getLoanAppDetails();
            }))
        }
        
    }

    async checkLatestAddedumStatus(){
        this.assignmentRecord = await getAssignmentRecordDetails({recordId: this.recordId})
        let assignmentRecord = this.assignmentRecord;

        if(assignmentRecord.hasOwnProperty('Addendum_Status__c')){
            if(this.assignmentRecord.Addendum_Status__c=='Pending'){
                this.template.querySelector('[data-id="Addendum_Status__c"]').classList.remove('slds-hide')
                //this.template.querySelector('[data-id="initiateDisbursement"]').disabled = true
                this.isAddedumStatusPending=true
            }
            if(this.assignmentRecord.Addendum_Status__c=='Complete' && !this.loanApp.Completed_Disbursement_Stage__c){
                this.template.querySelector('[data-id="Addendum_Status__c"]').classList.remove('slds-hide')
                this.template.querySelector('[data-id="initiateDisbursement"]').disabled = false
                const notifyRO = sendNotificationToRO({recordId: this.loanAppId})
                this.isAddedumStatusPending=false
            }

        }
        
        // Adding Addendum Status Fix 31August 2023
        //if(!assignmentRecord.hasOwnProperty('Addendum_Status__c') && this.loanApp.Stage__c=='Ops Maker' && !this.loanApp.Completed_Disbursement_Stage__c && this.userType=='Ops Maker'){
            //this.template.querySelector('[data-id="Addendum_Status__c"]').classList.remove('slds-hide')
            //this.template.querySelector('[data-id="initiateDisbursement"]').disabled = false
            //const notifyRO = sendNotificationToRO({recordId: this.loanAppId})
            //this.isAddedumStatusPending=false
        //}
    }

    getVisibleFields(stage) {
        getVisibleFieldsForLoanDetails({ strScreen: 'Disbursement Details Ops', strStage: stage, strProfile: '' }).then((result => {
            result.forEach(input => {
                this.template.querySelectorAll('[data-id="' + input + '"]').forEach(element => {
                    element.classList.remove('slds-hide');
                })
            });
            this.checkLatestAddedumStatus()
            this.setLoanApplicationData()
        })).catch((error => {
            this.showToastMessage('Error', error, 'error')
            this.isLoading = false
        }))
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
            this.setInitialData()
        }
      }
    
      unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
      }
    
      disconnectedCallback() {
          this.unsubscribeToMessageChannel();
      }


    async getLoanAppDetails() {
        if (this.spinnerImage == undefined) {
            this.spinnerImage = await getSpinnerImage(this.recordId);
        }
        this.isLoading = true
        getLoanDetails({ loanAppId: this.loanAppId }).then((data => {
            this.loanApp = data.loanApp
            if(this.loanApp.Stage__c=='Ops Author' || this.loanApp.Stage__c=='Ops Maker' || this.loanApp.Stage__c=='PDD'){
                this.loadComponents = true
                /*if(this.loanApp.OwnerId.startsWith('00G')){
                    this.userType='Group'
                }*/
                this.isUserMaker=this.userType=='Ops Maker'?true:false
                this.scheduleNameOptions = data.scheduleNames
                this.minROI = data.ranges.Min_ROI_Value__c;
                this.maxROI = data.ranges.Max_ROI_Value__c;
                this.ROIUnderFlowError = 'Please enter a value above ' + this.minROI
                this.ROIOverFlowError = 'Please enter a value below ' + this.maxROI
                this.loanApp.Total_Charges__c = this.loanApp.Total_Charges__c?this.loanApp.Total_Charges__c:0
                this.bsrPslCompleted = true
                this.bsrPslCompleted = this.loanApp.is_BSR_PSL_API_successful__c;
                if(data.relatedApplicants && data.relatedApplicants.length>0){
                    data.relatedApplicants.forEach(input=>{
                        if(!input.is_BSR_PSL_API_successful__c){
                            this.bsrPslCompleted = false
                        }
                    })
                }
                if(data.stateMappings && data.stateMappings[0]){
                    if(data.loanApp.RecordType.DeveloperName == 'Two_Wheeler'){
                        this.setEMIOptions(data.stateMappings[0].Two_Wheeler_EMI_Date__c)
                    }else if(data.loanApp.RecordType.DeveloperName == 'Four_Wheeler'){
                        this.setEMIOptions(data.stateMappings[0].Four_Wheeler_EMI_Date__c)
                    }else if(data.loanApp.RecordType.DeveloperName === 'Commercial_Vehicle'){
                        let hcvLcvIcv = ['10103','10104','10134','10113']
                        let scvCarTaxi3W = ['10105','10101','10102','10108','10106','10107']
                        if(hcvLcvIcv.includes(this.loanApp.Collateral_Type__c)){
                            this.setEMIOptions(data.stateMappings[0].HCV_LCV_ICV_CE_EMI_Date__c)
                        }else if(scvCarTaxi3W.includes(this.loanApp.Collateral_Type__c)){
                            this.setEMIOptions(data.stateMappings[0].SCV_CarTaxi_3W_EMI_Date__c)
                        }
                    }else if(data.loanApp.RecordType.DeveloperName === 'Construction_Equipment'){
                        this.setEMIOptions(data.stateMappings[0].HCV_LCV_ICV_CE_EMI_Date__c)
                    }else if(data.loanApp.RecordType.DeveloperName === 'Tractor'){
                        this.setEMIOptions(data.stateMappings[0].Tractor__c)
                    }
                }else{
                    this.showToastMessage('Warning','We could not find EMI Date Options','warning', 'sticky')
                }
                if (this.loanApp.Disbursement_Category__c == 'Full' && data.hasOwnProperty('glValues')) {
                    //this.generalLedgerOptions = data.glValues;
                    //SF-5427 - Added by Samridhi
                    this.loanApp.General_Ledger__c = data.glValues[0].value;
                }

                this.getVisibleFields(this.loanApp.Stage__c)
            }else{
                this.isLoading = false
            }
        })).catch((error => {
            this.isLoading = false
            this.showToastMessage('Error', error.message.body, 'error', 'sticky')
        }))
    }

    setEMIOptions(wheels){
        var list=[]
        if(wheels.includes(',')){
            wheels.split(',').forEach(dateValue=>{
                list.push({label:dateValue, value:dateValue})
            })
        }else{
            var newDate = wheels
            list.push({label:newDate, value:newDate})
        }
        this.emiDateOptions = list
    }

    async setLoanApplicationData() {
        //enable/disable buttons for Author
        if(this.userType == 'Group' || this.loanApp.Stage__c == 'PDD' || this.loanApp.Stage__c == 'PSD' || (this.userType!='Ops Maker' && this.userType!='Ops Author') ){
            this.template.querySelectorAll('lightning-input').forEach(input => {
                input.disabled = true
            })
            this.template.querySelectorAll('lightning-combobox').forEach(input => {
                input.disabled = true
            })
            this.template.querySelectorAll('lightning-button').forEach(input => {
                input.disabled = true
            })
            this.template.querySelectorAll('lightning-slider').forEach(input => {
                input.disabled = true
            })
        }
        else if (this.loanApp.Stage__c == 'Ops Author') {
            if (this.loanApp.Disbursement_Category__c == 'Full') {
                this.paymentFavouringParentId = this.loanAppId;
            }
            this.template.querySelectorAll('[data-id="disableAtOpsAuthor"').forEach(input => {
                input.disabled = true
            })
            if(this.userType == 'Ops Author') { //this.userType == 'Admin' - removed check for System Admin - Neha
                this.template.querySelectorAll('lightning-button').forEach(input => {
                    if (input.classList.contains('disableAtOpsAuthor')) {
                        input.disabled = true
                    }
                    if (input.classList.contains('visibleAtOpsAuthor')) {
                        input.classList.remove('slds-hide')
                        //Added - 16 Aug
                        input.disabled = false
                    }
                })
                this.template.querySelectorAll('lightning-slider').forEach(input => {
                    input.classList.add('slds-hide')
                })
                this.template.querySelector('[data-name="ROI__c"]').label='Applied ROI'
                this.template.querySelector('[data-id="repaymentSchedule"]').disabled = false;
                //if (this.loanApp.Completed_Disbursement_Stage__c == 'Repayment Schedule') {
                if (this.loanApp.Completed_Disbursement_Stage__c == 'Repayment Schedule Ops Author') {    
                    //this.template.querySelector('[data-id="disburseLoan"]').disabled = false;
                }
                if (this.loanApp.Completed_Disbursement_Stage__c == 'Do Disbursement') {    
                    this.template.querySelector('[data-id="disburseLoan"]').disabled = true;
                    this.handlePaymentFavouringOnDoDisburse()
                }
                
                //this.handleEnableDoDisburse()
            }
        }

        //enable/disable buttons for maker
        else if (this.loanApp.Stage__c == 'Ops Maker') {
            if (this.userType == 'Admin' || this.userType == 'Ops Maker') {
                if (this.loanApp.LAN__c && this.loanApp.is_Collateral_Creation_Successful__c && this.loanApp.is_Collateral_Linkage_Successful__c && !this.loanApp.Dpd_Found__c) {
                    this.template.querySelector('[data-name="EMI_Date__c"]').disabled = false;
                }if (!this.loanApp.Completed_Disbursement_Stage__c && this.loanApp.LAN__c && this.loanApp.is_Collateral_Creation_Successful__c && this.loanApp.is_Collateral_Linkage_Successful__c && !this.loanApp.Dpd_Found__c && (((this.assignmentRecord.Addendum_Status__c!='Pending' && this.loanApp.Esign_Type__c=='Digital') || (this.loanApp.Esign_Type__c=='Physical')))) {
                    this.template.querySelector('[data-id="initiateDisbursement"]').disabled = false;
                } else if (this.loanApp.Completed_Disbursement_Stage__c == 'Initiate Disbursement') {
                    this.template.querySelector('[data-id="disbursementStage"]').disabled = false;
                } else if (this.loanApp.Completed_Disbursement_Stage__c == 'Disbursement Stage') {
                    this.template.querySelector('[data-id="repaymentSchedule"]').disabled = false;
                } else if(this.loanApp.Completed_Disbursement_Stage__c == 'Do Disbursement' || this.loanApp.Completed_Disbursement_Stage__c == 'Repayment Schedule' || this.loanApp.Completed_Disbursement_Stage__c == 'Repayment Schedule Ops Author'){
                    this.template.querySelector('[data-id="repaymentSchedule"]').disabled = false;
                }
                /*else if (this.loanApp.Repayment_Schedule_Viewed_by_Maker__c){
                    this.template.querySelector('[data-id="repaymentSchedule"]').disabled = true;
                }*/
                //this.template.querySelector('[data-id="fetchEMIDetails"]').disabled = false;
            }
        }


        this.recordTypeId = this.loanApp.RecordTypeId //get RecordId to fetch picklist values

        if (!this.loanApp.Mode_of_Disbursement__c) {
            this.loanApp.Mode_of_Disbursement__c = 'GL'
        }
        if (this.loanApp.Mode_of_Disbursement__c == 'Cheque') {
            this.template.querySelector('[data-id="Disbursement_Cheque_Print_Location__c"]').classList.remove('slds-hide')
            this.chequePrintLocationRequired = true
        } else {
            this.chequePrintLocationRequired = false
        }
        if (!this.loanApp.Schedule_Type__c) {
            this.loanApp.Schedule_Type__c = 'Monthly'
        }

        //get tranches if disbursement category is partial
        if (this.loanApp.Disbursement_Category__c == 'Partial') {
            const trancheDetails = await getTrancheDetails({ recordId: this.loanAppId, trancheNumber: (this.loanApp.Disbursed_Tranche__c + 1) })
            const tranche = trancheDetails.tranche
            //this.generalLedgerOptions = trancheDetails.glValues;

            //SF-5427 - Added by Samridhi
            this.loanApp.General_Ledger__c = trancheDetails.glValues[0].value;
            if (tranche) {
                this.currentTranche = tranche.Tranche_Number__c
                if ((this.loanApp.Disbursed_Tranche__c + 1) == 1) {
                    this.disbursementAmount = tranche.Disbursement_Amount__c
                    this.netDisbursementAmount = tranche.Disbursement_Amount__c - this.loanApp.Total_Charges__c;
                } else {
                    this.disbursementAmount = tranche.Disbursement_Amount__c
                    this.netDisbursementAmount = tranche.Disbursement_Amount__c
                }
                this.trancheId = tranche.Id
            }
            this.template.querySelector('[data-id="Remaining_Sanction_Amount__c"').classList.remove('slds-hide')
            //load payment favouring details for author
            if (this.loanApp.Stage__c == 'Ops Author') {
                this.paymentFavouringParentId = tranche.Id
                this.paymentFavouringDisbursementAmount = this.disbursementAmount
                this.paymentFavouringTotalCharges = this.loanApp.Total_Charges__c
                this.completedStage = this.loanApp.Completed_Disbursement_Stage__c;
                this.displayValidatePayments=true
                this.displayReleasePayments=false
                this.displayPayments = true

            }


        }

        //handling when disbursement category is full
        if (this.loanApp.Disbursement_Category__c == 'Full') {
            this.disbursementAmount = this.loanApp.Total_Loan_Amount__c
            this.netDisbursementAmount = this.loanApp.Total_Loan_Amount__c - this.loanApp.Total_Charges__c;
            //load payment favouring details for author
            if (this.loanApp.Stage__c == 'Ops Author' || this.loanApp.Stage__c == 'PDD' || this.loanApp.Stage__c == 'Ops Maker') {
                this.paymentFavouringParentId = this.loanAppId
                this.paymentFavouringDisbursementAmount = this.loanApp.Total_Loan_Amount__c
                this.paymentFavouringTotalCharges = this.loanApp.Total_Charges__c
                this.completedStage = this.loanApp.Completed_Disbursement_Stage__c;
                this.displayValidatePayments=true
                this.displayReleasePayments=false
                this.displayPayments = true
            }
        }

        //set Narration details
        if (!this.loanApp.Narration__c) {
            if (this.loanApp.Applicants__r && this.loanApp.Applicants__r.length > 0 && this.loanApp.Applicants__r[0].Customer_Name__c) {
                this.loanApp.Narration__c = this.loanApp.Application_Id__c+' '+this.loanApp.Applicants__r[0].Customer_Name__c+' '+this.loanApp.Mode_of_Disbursement__c
            } else {
                this.loanApp.Narration__c = this.loanApp.Application_Id__c+' '+this.loanApp.Mode_of_Disbursement__c
            }
        }

        //set Disbursement Date
        if (!this.loanApp.Disbursement_Date__c || !this.loanApp.Completed_Disbursement_Stage__c) {
            var newDate = new Date()
            var todaysDate = newDate.getFullYear() + '-' + (newDate.getMonth() + 1).toString().padStart(2, '0') + '-' + newDate.getDate().toString().padStart(2, '0');
            this.loanApp.Disbursement_Date__c = todaysDate
        }

        this.handleEnableDoDisburse()
        if (this.loanApp.Completed_Disbursement_Stage__c == 'Do Disbursement' && this.userType != 'Ops Author' && this.loanApp.Stage__c != 'Ops Author') {    
            this.template.querySelector('[data-id="disburseLoan"]').disabled = true;
            this.handlePaymentFavouringOnDoDisburse()
        }
        this.isLoading = false
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: LOAN_APPLICATION_OBJECT, recordTypeId: '$recordTypeId' })
    propertyOrFunction({ error, data }) {
        var picklistMap = new Map()
        if (data) {
            picklistMap = data.picklistFieldValues
            this.disbursementCategoryOptions = picklistMap['Disbursement_Category__c'].values
            this.modeOfDisbursementOptions = picklistMap['Mode_of_Disbursement__c'].values
            this.moratoriumPeriodOptions = picklistMap['Moratorium_Period__c'].values
        }
    }

    async handleChange(event) {
        if(event.target.name == 'Net Disbursement Amount'){
            this.netDisbursementAmount = event.target.value
        }else{
            this.loanApp[event.target.name] = event.target.value;
            if (event.target.name == 'Mode_of_Disbursement__c') {
                if (event.target.value == 'Cheque') {
                    this.template.querySelector('[data-id="Disbursement_Cheque_Print_Location__c"').classList.remove('slds-hide')
                    this.chequePrintLocationRequired = true
                } else {
                    this.template.querySelector('[data-id="Disbursement_Cheque_Print_Location__c"').classList.add('slds-hide')
                    this.chequePrintLocationRequired = false
                }
            }
            if (event.target.name == 'Disbursement_Category__c') {
                if (event.target.value == 'Partial') {
                    this.template.querySelector('[data-id="Remaining_Sanction_Amount__c"').classList.remove('slds-hide')
                } else {
                    this.template.querySelector('[data-id="Remaining_Sanction_Amount__c"').classList.add('slds-hide')
                }
            }
            if(event.target.name == 'EMI_Date__c'){
                //alert('Record ID '+this.recordId);
                //this.openEMIModal = true;
                this.calculateFirstEMIDate()
                /*to be uncommented later*/
                
                // if modal closed with X button, promise returns result = 'undefined'
                // if modal closed with OK button, promise returns result = 'okay'
            }
            /*if(event.target.name == 'First_EMI_Date__c'){
                this.validateFirstEMIDate(this.loanApp.First_EMI_Date__c);
            }*/
            if(event.target.name=='EMI_Date__c' || event.target.name=='First_EMI_Date__c'){
                if(this.validateFirstEMIDate(this.loanApp.First_EMI_Date__c)){
                    if(this.loanApp.Esign_Type__c=='Digital'){
                        this.isLoading=true
                        this.template.querySelector('[data-id="initiateDisbursement"]').disabled = true
                        this.template.querySelector('[data-id="Addendum_Status__c"]').classList.remove('slds-hide')
                        this.isAddedumStatusPending=true
                        this.initiateAddendum()
                    }
                }
            }
            //alert('event.target.name'+event.target.name);
        }
        
    }

    async reinitiateAddendum(){
        const result = await MyModal.open({
            // `label` is not included here in this example.
            // it is set on lightning-modal-header instead
            size: 'large',
            description: 'Accessible description of modal\'s purpose',
            loanid: this.loanAppId,
        });
    }

    async initiateAddendum(){
        const addendumCreationResult = await createAddendumDocument({applicationId: this.loanAppId, firstEMIDate: JSON.stringify(this.loanApp.First_EMI_Date__c), assignmentRecordId: this.recordId})    
        this.isLoading=false
        if(addendumCreationResult == 'Success'){
            var fields = { Id: this.loanAppId, Completed_Disbursement_Stage__c: '', Repayment_Schedule_Viewed_by_Maker__c:false,
                                    First_EMI_Date__c: this.loanApp.First_EMI_Date__c, EMI_Date__c: this.loanApp.EMI_Date__c }
            const recordInput = { fields };
            updateRecord(recordInput).then(() => {
                this.loanApp.Completed_Disbursement_Stage__c='';
                this.loanApp.Repayment_Schedule_Viewed_by_Maker__c=false;
                this.template.querySelectorAll('lightning-button').forEach(buttonInput=>{
                    if(buttonInput.dataId=='reinitiateEsign'){
                        buttonInput.disabled=false
                    }else{
                        buttonInput.disabled=true
                    }
                    
                })
            }).catch((error=>{
        }))           
        const result = await MyModal.open({
                // `label` is not included here in this example.
                // it is set on lightning-modal-header instead
                size: 'large',
                description: 'Accessible description of modal\'s purpose',
                loanid: this.loanAppId,
            });
        }
    }

    handleFirstEMIDateChange(event){
        this.loanApp.First_EMI_Date__c = event.target.value;
        this.validateFirstEMIDate(this.loanApp.First_EMI_Date__c);
    }

    validateFirstEMIDate(firstEMIDate){
        const todaysdate = new Date();
        let addMonths, minDays = minFirstEMIDaysOps, maxDays;
        if(this.loanApp.Emi_Frequency__c && this.loanApp.EMI_Date__c && firstEMIDate){
            if(this.loanApp.Emi_Frequency__c == 'MONTHLY'){
                addMonths = 1;
                maxDays = 60;
            }else if(this.loanApp.Emi_Frequency__c == 'QUARTERLY'){
                addMonths = 3;
                maxDays = 120;
            }else if(this.loanApp.Emi_Frequency__c == 'HALF YEARLY'){
                addMonths = 6;
                maxDays = 210;
            }
            if(new Date(firstEMIDate).getDate() != Number(this.loanApp.EMI_Date__c)){
                this.showToastMessage('Error', 'The First EMI Date should only be '+this.loanApp.EMI_Date__c+ ' of any month.', 'error');
                return false;
            }else if(new Date(firstEMIDate).getDate() == Number(this.loanApp.EMI_Date__c)){
                if(new Date(firstEMIDate) < todaysdate){
                    this.showToastMessage('Error', 'Entered First EMI Date is a past date. Please enter a valid date', 'error');
                    return false;
                }else{
                    let datDiff = (new Date(firstEMIDate).getTime() - new Date(todaysdate).getTime());
                    console.log('datDiff: '+datDiff/(1000 * 3600 * 24));
                    //SFAU-5235 : Updated by Samridhi
                    if((datDiff/(1000 * 3600 * 24))+1 < minDays || (datDiff/(1000 * 3600 * 24))+1 > maxDays){
                        console.log('came into if');
                        this.showToastMessage('Error', 'First EMI Date cannot be less than '+minDays+' days and more than '+maxDays+' days from today. Please enter a valid First EMI Date.', 'error');
                        return false;
                    }else{
                        console.log('came into else');
                        return true;
                    }
                }
            }else{
                return true;
            }
        }
    }

    calculateFirstEMIDate(){
        var addMonths;
        var minDays = minFirstEMIDaysOps;
        var maxDays;
        const todaysdate = new Date();
        const loanEMIFrequency = ((this.loanApp.Emi_Frequency__c).toUpperCase()).replace(/\s/g, "");
        if(loanEMIFrequency && this.loanApp.EMI_Date__c){
            if(loanEMIFrequency == 'MONTHLY'){
                addMonths = 1;
                maxDays = 60;
            }else if(loanEMIFrequency == 'QUARTERLY'){
                addMonths = 3;
                maxDays = 120;
            }else if(loanEMIFrequency == 'HALFYEARLY'){
                addMonths = 6;
                maxDays = 210;
            }
            console.log('date first: '+this.loanApp.First_EMI_Date__c);
            console.log('type first: '+typeof(this.loanApp.First_EMI_Date__c));
            if(this.loanApp.EMI_Date__c == '10' || this.loanApp.EMI_Date__c == '18'){            
                let currentMonthEMIDate = new Date(todaysdate.getFullYear(), todaysdate.getMonth(), Number(this.loanApp.EMI_Date__c));
                console.log('currentMonthEMIDate: '+currentMonthEMIDate);
                if(currentMonthEMIDate < todaysdate){
                    let expectedFirstEMIDate = new Date(todaysdate.getFullYear(), Number(parseInt(todaysdate.getMonth())+parseInt(addMonths)), Number(this.loanApp.EMI_Date__c));
                    console.log('expectedFirstEMIDate: '+expectedFirstEMIDate);
                    
                    let expectedEmiDateDiff = (new Date(expectedFirstEMIDate).getTime() - todaysdate.getTime());
                    let expectedCurrentDateDiff = (new Date(expectedFirstEMIDate).getTime() - currentMonthEMIDate.getTime());
                    console.log('expectedEmiDateDiff: '+expectedEmiDateDiff);
                    console.log('expectedCurrentDateDiff: '+expectedCurrentDateDiff);
                    if((expectedEmiDateDiff /(1000 * 3600 * 24)) > minDays && (expectedCurrentDateDiff/(1000 * 3600 * 24)) < maxDays){
                        console.log('(parseInt(expectedFirstEMIDate.getMonth())+1).length: '+'0'+(parseInt(expectedFirstEMIDate.getMonth())+1).toString());
                        let monthVal = (parseInt(expectedFirstEMIDate.getMonth())+1).toString().length==1?'0'+(parseInt(expectedFirstEMIDate.getMonth())+1).toString():(parseInt(expectedFirstEMIDate.getMonth())+1);
                        // For edge condition Month val Tractor QDE Change
                        if(Number(monthVal) > 12){
                            monthVal = Number(monthVal) % 12 + '';
                            monthVal = monthVal < 10 ? '0' + monthVal : monthVal;
                            todaysdate.setFullYear(todaysdate.getFullYear() + 1);
                        }
                        // For edge condition Month val Tractor QDE Change
                        this.loanApp.First_EMI_Date__c = expectedFirstEMIDate.getFullYear() +'-'+ monthVal +'-'+ expectedFirstEMIDate.getDate();
                        console.log('answer:'+this.loanApp.First_EMI_Date__c);
                    }else{
                        console.log('(parseInt(todaysdate.getMonth())+parseInt(addMonths)+2).length: '+(parseInt(todaysdate.getMonth())+parseInt(addMonths)+2).toString().length);
                        let monthVal = (parseInt(todaysdate.getMonth())+parseInt(addMonths)+2).toString().length==1?'0'+(parseInt(todaysdate.getMonth())+parseInt(addMonths)+2).toString():(parseInt(todaysdate.getMonth())+parseInt(addMonths)+2)
                        if(Number(monthVal) > 12){
                            monthVal = Number(monthVal) % 12 + '';
                            monthVal = monthVal < 10 ? '0' + monthVal : monthVal;
                            todaysdate.setFullYear(todaysdate.getFullYear() + 1);
                        }
                        this.loanApp.First_EMI_Date__c = todaysdate.getFullYear() +'-'+ monthVal +'-'+ Number(this.loanApp.EMI_Date__c);
                    }
                }else{
                    let currentMonthDiff = (currentMonthEMIDate.getTime() - todaysdate.getTime());
                    if((currentMonthDiff/(1000 * 3600 * 24)) > minDays && (currentMonthDiff/(1000 * 3600 * 24)) < maxDays){
                        console.log('currentMonthEMIDate.getMonth().length==1: '+currentMonthEMIDate.getMonth().toString().length);
                        let monthVal = (currentMonthEMIDate.getMonth()+1).toString().length==1?'0'+(currentMonthEMIDate.getMonth()+1).toString():(currentMonthEMIDate.getMonth()+1);
                        // For edge condition Month val Tractor QDE Change
                        if(Number(monthVal) > 12){
                            monthVal = Number(monthVal) % 12 + '';
                            monthVal = monthVal < 10 ? '0' + monthVal : monthVal;
                            todaysdate.setFullYear(todaysdate.getFullYear() + 1);
                        }
                        // For edge condition Month val Tractor QDE Change
                        this.loanApp.First_EMI_Date__c = currentMonthEMIDate.getFullYear() +'-'+ monthVal +'-'+ currentMonthEMIDate.getDate();
                    }else{
                        console.log('(parseInt(todaysdate.getMonth())+parseInt(addMonths)+1).length: '+(parseInt(todaysdate.getMonth())+parseInt(addMonths)+1).toString().length);
                        let monthVal = (parseInt(todaysdate.getMonth())+parseInt(addMonths)+1).toString().length==1?'0'+(parseInt(todaysdate.getMonth())+parseInt(addMonths)+1).toString():(parseInt(todaysdate.getMonth())+parseInt(addMonths)+1);
                        // For edge condition Month val Tractor QDE Change
                        if(Number(monthVal) > 12){
                            monthVal = Number(monthVal) % 12 + '';
                            monthVal = monthVal < 10 ? '0' + monthVal : monthVal;
                            todaysdate.setFullYear(todaysdate.getFullYear() + 1);
                        }
                        // For edge condition Month val Tractor QDE Change
                        this.loanApp.First_EMI_Date__c = todaysdate.getFullYear() +'-'+  monthVal +'-'+ Number(this.loanApp.EMI_Date__c);
                    }
                }
                // this.loanApp.First_EMI_Date__c = new Date(this.loanApp.First_EMI_Date__c);
                // let res = new Date(this.loanApp.First_EMI_Date__c);
                // let dates = new Date(Number(parseInt(res.getMonth())+1)+'/'+res.getDate()+'/'+res.getFullYear());
                 //this.loanApp.First_EMI_Date__c = new Date("08/18/23");
            }
        }
    }

    showToastMessage(titleValue, messageValue, variantValue, mode) {

        const event = new ShowToastEvent({
            title: titleValue,
            message: messageValue,
            variant: variantValue,
            mode: mode
        });
        this.dispatchEvent(event);


    }

    handleValidations() {
        var valid;

        const allValid1 = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        const allValid2 = [
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid1 && allValid2) {
            valid = true
        } else {
            valid = false;
        }
        return valid;
    }

    async handleDisbursementDetails() {
        this.isLoading = true
        /*//SFAU-4473
        let motorInsCheck = await checkMotorInsurance({loanId: this.loanApp.Id})
        if(motorInsCheck == 'Failed'){
            this.isLoading = false
            this.template.querySelector('[data-id="initiateDisbursement"]').disabled = true;
            this.showToastMessage('','Found Discrepency in Motor Insurance Deviation. Application is sent back to PSD Stage','error')
            return;
        }
        //SFAU-4473*/
        if(!this.bsrPslCompleted){
            let checkIfIntComplete = await isBSRPSLComplete({loanId: this.loanApp.Id})
            if(!checkIfIntComplete){
                this.isLoading = false
                this.showToastMessage('','Please Complete BSR-PSL for Loan Application / Applicants before Initiating Disbursement','error')
                return;
            }
            
        }
        if (this.handleValidations() && this.validateFirstEMIDate(this.loanApp.First_EMI_Date__c)) {
            this.updateDateTime('Disbursement Details');
            var stage=this.loanApp.Stage__c
            var name=this.loanApp.Name
            const fields = this.loanApp;
            Object.keys(fields).forEach(element => {
                if (this.excludeFieldList.includes(element)) {
                    delete fields[element]
                }
            })
            const recordInput = { fields };
            updateRecord(recordInput).then(() => {
                this.loanApp.Stage__c=stage
                this.loanApp.Name=name
                if (this.loanApp.Disbursement_Category__c === 'Full' || (this.loanApp.Disbursement_Category__c === 'Partial' && this.trancheNumber === 1)) {
                    Promise.all([
                        generateLoanDisbursementDetails({
                            recordId: this.loanAppId
                        }),
                        generateDisbursementDeductions({
                            recordId: this.loanAppId,
                            netDisbursementAmount: this.netDisbursementAmount
                        })
                    ]).then((values) => {
                        this.isLoading = false
                        if (values[0] != undefined) {
                            if (values[0].TransactionStatus.ResponseMessage == 'Success') {
                                this.template.querySelector('[data-id="initiateDisbursement"]').disabled = true;
                                this.template.querySelector('[data-id="disbursementStage"]').disabled = false;
                                this.loanApp.Completed_Disbursement_Stage__c = 'Initiate Disbursement'
                                var fields = { Id: this.loanAppId, Completed_Disbursement_Stage__c: 'Initiate Disbursement' }
                                const recordInput = { fields };
                                updateRecord(recordInput).then(() => {

                                }).catch((error=>{

                                }))
                                this.showToastMessage('Success', 'Loan Disbursement Details Initiated Successfully', 'success')
                            } else {
                                this.showToastMessage('Error', 'We encountered error while processing the request', 'error', 'sticky')
                            }
                        }
                        if (values[1] != undefined) {
                            if (values[1].TransactionStatus.ResponseMessage == 'Success') {
                                this.showToastMessage('Success', 'Loan Disbursement Deductions Fetched Successfully', 'success')
                            } else {
                                this.showToastMessage('Error', 'We encountered error while processing the request', 'error')
                            }
                        }

                        if (values[0] != undefined && values[1] != undefined) {
                            if (values[0].TransactionStatus.ResponseMessage == 'Success' && values[1].TransactionStatus.ResponseMessage == 'Success') {
                                
                            }

                        }

                    }).catch(error => {
                        if (error[0] != undefined) {
                            this.error = error[0];
                        }
                        if (error[1] != undefined) {
                            this.error = error[1];
                        }
                        this.isLoading = false

                    })
                } else {
                    generateLoanDisbursementDetails({
                        recordId: this.loanAppId
                    }).then((data => {
                        this.isLoading = false
                        if (data.TransactionStatus.ResponseMessage == 'Success') {
                            this.showToastMessage('Success', 'Loan Disbursement Details Initiated Successfully', 'success')
                            this.template.querySelector('[data-id="initiateDisbursement"]').disabled = true;
                            this.template.querySelector('[data-id="disbursementStage"]').disabled = false;
                            this.loanApp.Completed_Disbursement_Stage__c = 'Initiate Disbursement'
                            var fields = { Id: this.loanAppId, Completed_Disbursement_Stage__c: 'Initiate Disbursement' }
                            const recordInput = { fields };
                            updateRecord(recordInput).then(() => {

                            })
                        } else {
                            this.showToastMessage('Error', 'We encountered error while processing the request', 'error', 'sticky')
                        }
                    })).catch((error => {
                        this.isLoading = false
                        this.showToastMessage('Error', error, 'error', 'sticky')
                    }))
                }

            }).catch(error=>{
                this.isLoading=false
            });
        } else {
            this.isLoading = false
            this.showToastMessage('Error', 'Please Fill the Mandatory Fields', 'error', 'sticky')
        }

    }

    handleDisbursementStage() {
        this.isLoading = true
        generateDisbursementStage({ recordId: this.loanAppId, netDisbursementAmount: this.netDisbursementAmount }).then((data => {
            this.isLoading = false
            if (data.TransactionStatus.ResponseMessage == 'Success') {
                this.showToastMessage('Success', 'Disbursement Stage Fetched Successfully', 'success')
                this.template.querySelector('[data-id="disbursementStage"]').disabled = true;

                this.sessionId = data.SessionId;

                if (data.SessionId) {
                    this.loanApp.Completed_Disbursement_Stage__c = 'Disbursement Stage'
                    var fields = { Id: this.loanAppId, Disbursement_Session_Id__c: data.SessionId, Completed_Disbursement_Stage__c: 'Disbursement Stage' }
                    const recordInput = { fields };
                    updateRecord(recordInput).then(() => {
                        this.template.querySelector('[data-id="repaymentSchedule"]').disabled = false;
                    })
                }

            } else {
                this.showToastMessage('Error', 'We encountered error while processing the request', 'error', 'sticky')
            }
        })).catch((error => {
            this.isLoading = false
            this.showToastMessage('Error', 'Something Went Wrong', 'error', 'sticky')
        }))
    }

    handleRepaymentSchedule() {
        this.isLoading = true
        if (this.loanApp.Stage__c == 'Ops Maker') {
            getRepaymentSchedule({ recordId: this.loanAppId, apiName: 'Disbursement Schedule', netDisbursementAmount: this.netDisbursementAmount }).then((data) => {
                if(data.includes('API Error')){
                    this.isLoading = false
                    this.showToastMessage('Error',data,'error','sticky')
                    return
                }
                getPDFData({ loanApp: this.loanApp, refId: data, masterName: 'Disbursement Schedule' }).then((data => {
                    this.isLoading = false
                    this.openVFPageForEMI(data)
                    if (data && data.ContentDocumentId) {
                        //this.template.querySelector('[data-id="repaymentSchedule"]').disabled = true;
                        if(this.loanApp.Completed_Disbursement_Stage__c == 'Disbursement Stage'){
                            this.loanApp.Completed_Disbursement_Stage__c = 'Repayment Schedule'
                            var fields = { Id: this.loanAppId, Repayment_Schedule_Viewed_by_Maker__c: true, Completed_Disbursement_Stage__c: 'Repayment Schedule' }
                            const recordInput = { fields };
                            updateRecord(recordInput).then(() => {
    
                            })
                        }
                        
                    }
                })).catch((error=>{

                }))
            }).catch((error) => {
                this.isLoading = false
                this.showToastMessage('Error', 'Something Went Wrong', 'error', 'sticky')
            })
        }
        if (this.loanApp.Stage__c == 'Ops Author') {
            getRepaymentScheduleForAuthor({loanId: this.loanApp.Id}).then((data=>{
                this.isLoading = false
                /*this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: '/apex/EMISchedule?id='+data
                    }
                })*/
                if(data){
                    this[NavigationMixin.GenerateUrl]({
                        type: "standard__webPage",
                        attributes: {
                            url: '/apex/EMISchedule?id='+data
                        }
                    }).then(url => {
                        window.open(url, "_blank");
                    });
                    if(this.loanApp.Completed_Disbursement_Stage__c == 'Repayment Schedule'){
                        this.loanApp.Completed_Disbursement_Stage__c = 'Repayment Schedule Ops Author'
                        var fields = { Id: this.loanAppId, Completed_Disbursement_Stage__c: 'Repayment Schedule Ops Author' }
                        const recordInput = { fields };
                        updateRecord(recordInput).then(() => {
                            this.handleEnableDoDisburse()//this.template.querySelector('[data-id="disburseLoan"]').disabled = false;
                        }).catch((error=>{
                            this.showToastMessage('Error', 'Something Went Wrong', 'error', 'sticky')
                        }))
                    }
                    
                }
            })).catch((error=>{
                this.isLoading = false
            }))
            /*getLatestEmiSchedule({ loanApp: this.loanApp, masterName: 'Disbursement Schedule' }).then((data) => {
                this.isLoading = false
                this.openVFPageForEMI(data)

            }).catch((error) => {
                this.isLoading = false
                this.showToastMessage('Error', 'Something Went Wrong', 'error')
            })*/
        }

    }

    /*handleFetchEMISchedule(){
        getRepaymentSchedule({recordId: this.loanAppId, apiName: 'EMI Schedule', netDisbursementAmount: this.netDisbursementAmount}).then((data)=>{
            getPDFData({loanApp: this.loanApp, refId:data, masterName:'Disbursement Schedule'}).then((data=>{
                this.openVFPageForEMI(data)
            }))
        }).catch((error)=>{
            this.showToastMessage('Error','We Encountered an Error while Processing Your Request','error')
        })
    }*/

    openVFPageForEMI(content) {
        if (content && content.ContentDocumentId) {
            var docId = content.ContentDocumentId
            /*this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state: {
                    recordIds: docId,
                    selectedRecordId: docId
                }
            })*/
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state: {
                    recordIds: docId,
                    selectedRecordId: docId
                }
            }).then(url => { window.open(url) })
        } else {
            this.showToastMessage('Error', 'No EMI Schedule Found', 'error', 'sticky');
        }
    }

    handlePaymentFavouringOnDoDisburse(){
        let isSuccess=true
        let isSuccessCheque=true
        this.totalNonChequePoolAmount = 0;
        this.totalChequePoolAmount = 0;
        getPaymentFavourings({ recordId: this.paymentFavouringParentId }).then((data=>{
            data.forEach(input => {
                if(!this.paymentRecId){
                    this.paymentRecId = input.Id;
                }
                if((input.Payment_Mode__c == 'Transfer' || input.Payment_Mode__c == 'NEFT' || input.Payment_Mode__c == 'RTGS' || input.Payment_Mode__c == 'IMPS')){
                    this.template.querySelector('[data-id="disbursePayment"]').classList.remove('slds-hide')
                    if(!input.Is_Pool_Disbursement_Successful__c && input.Payment_Favouring_Status__c!='Complete' && !input.Pool_Txn_Reference_Number__c){ // SFAU-5600 - Added Pool_Txn_Reference_Number__c check
                        this.template.querySelector('[data-id="disbursePayment"]').disabled = false
                        isSuccess=false
                    }
                    if(!(input.Payment_Recipient__c == 'CSD' && input.Margin_Money_Action__c == 'Yes')){    
                        this.totalNonChequePoolAmount += input.Net_Amount__c;
                    }
                    
                }else if(input.Payment_Mode__c=='Cheque'){
                    this.template.querySelector('[data-id="disbursePaymentCheque"]').classList.remove('slds-hide')
                    if(!input.Is_Cheque_Pool_Disburse_Successful__c && input.Payment_Favouring_Status__c!='Complete' && !input.Pool_Txn_Cheque_Reference_Number__c){ // SFAU-5600 - Added Pool_Txn_Cheque_Reference_Number__c check
                        this.template.querySelector('[data-id="disbursePaymentCheque"]').disabled = false
                        isSuccessCheque=false
                    }
                    if(!(input.Payment_Recipient__c == 'CSD' && input.Margin_Money_Action__c == 'Yes')){    
                        this.totalChequePoolAmount += input.Net_Amount__c;
                    }

                }
            })
            if(isSuccess){
                this.template.querySelector('[data-id="disbursePayment"]').disabled = true
              /*  this.template.querySelectorAll('c-payment-details-ops-author').forEach(input=>{
                    input.getPaymentFavouringsRecords(false)
                })
              */  
            }else{
                this.template.querySelector('[data-id="disbursePayment"]').disabled = false
            }

            if(isSuccessCheque){
                this.template.querySelector('[data-id="disbursePaymentCheque"]').disabled = true
                /*    this.template.querySelectorAll('c-payment-details-ops-author').forEach(input=>{
                    input.getPaymentFavouringsRecords(true)
                }) */
            }else{
                this.template.querySelector('[data-id="disbursePaymentCheque"]').disabled = false
            }

            if(isSuccess || isSuccessCheque){
                this.template.querySelectorAll('c-payment-details-ops-author').forEach(input=>{
                    input.getPaymentFavouringsRecords(isSuccessCheque)
                })
            }
        }))
        
       
    }

    async handleDisbursePayment(event){
        let disburseBtn = event.target.dataset.id;
        this.template.querySelector('[data-id=' + disburseBtn + ']').disabled = true
       // this.template.querySelector('[data-id="disbursePayment"]').disabled = true
        this.isLoading=true
        const response = await checkIfDibursePaymentDone({loanId: this.loanAppId,disburseBtn: disburseBtn});
        if(response && response.isPaymentAlreadyDone){
            this.isLoading=false
            this.showToastMessage('','Payment is Already Disbursed. Please Refresh the Page to Check Latest Details','warning')
            return
        }

        let disbursementAmount = disburseBtn == 'disbursePaymentCheque' ? this.totalChequePoolAmount : this.totalNonChequePoolAmount;
        //this.isLoading = true
        doIFTPayment({ recordId: this.loanAppId, paymentFavouringId: this.paymentRecId, isPoolDisbursement: 'Yes', disbursementAmount: disbursementAmount.toString(),disburseBtn : disburseBtn }).then((data => {
            let callOutData = JSON.parse(data)
            data = JSON.parse(callOutData.response)
            let request = JSON.parse(callOutData.checklistRecord.Request__c)
            if(callOutData.statusCode!=200){
                this.isLoading = false
                this.template.querySelector('[data-id=' + disburseBtn + ']').disabled = true
                             this.showToastMessage('Error', 'API Error: ' + callOutData.checklistNumber + ' Response: ' + callOutData.statusCode + '- ' + callOutData.status , 'error','sticky');
            }else if(data.TransactionStatus.ResponseMessage == 'Success'){
                this.showToastMessage('','Disbursement to Pool Account Completed', 'success')
                this.template.querySelector('[data-id=' + disburseBtn + ']').disabled = true
                    this.isLoading = false
                    this.template.querySelectorAll('c-payment-details-ops-author').forEach(input=>{
                        input.getPaymentFavouringsRecords( disburseBtn == 'disbursePaymentCheque' )
                    })
                            }else{
                this.isLoading = false
                this.template.querySelector('[data-id=' + disburseBtn + ']').disabled = true
                 this.showToastMessage('Disbursement to Pool Account Failed', data.TransactionStatus.ResponseMessage, 'error', 'sticky') 
                if(data.TransactionStatus.ValidationErrors){
                    this.showToastMessage('', data.TransactionStatus.ValidationErrors.ErrorMessage, 'warning', 'sticky') 

                }                                    
            }
            
        })).catch((error => {
            this.isLoading = false
            this.template.querySelector('[data-id=' + disburseBtn + ']').disabled = true
            this.showToastMessage('', IFT_API+' Failed - '+error.body.message, 'error', 'sticky')
        }))
    }

    handleEnableDoDisburse(){
        let isSuccess = true
        let isChequePresent = false;
        getPaymentFavourings({ recordId: this.paymentFavouringParentId }).then((data => {
            data.forEach(input => {
                if(input.is_Payment_Favouring_Modified__c && !input.is_Validated_By_Author__c){
                    isSuccess=false
                }
                if(input.Payment_Mode__c == 'TA' || (input.Payment_Recipient__c == 'CSD' && input.Margin_Money_Action__c == 'Yes')){
                    isSuccess = true;
                }
                if(input.Payment_Mode__c == 'Cheque' || isChequePresent){
                    isChequePresent = true;
                }
            })
            if(this.template.querySelectorAll('c-payment-details-ops-author') && this.template.querySelectorAll('c-payment-details-ops-author').length>0){
                this.template.querySelectorAll('c-payment-details-ops-author').forEach(input=>{
                    input.getPaymentFavouringsRecords(isChequePresent);
                })
            }
            
            
            if(isSuccess){
                //this.displayValidatePayments=false
                this.displayReleasePayments=true
                if (this.loanApp.Completed_Disbursement_Stage__c == 'Repayment Schedule Ops Author') {    
                    this.template.querySelector('[data-id="disburseLoan"]').disabled = false;   
                }
                
            }
        }))

        
    }

    updateDateTime(apiName){
        updateDisbursementDateTime({currentApi: apiName, loanId: this.loanAppId}).then((data=>{

        })).catch((error=>{

        }))

    }

    handleDoDisbursement() {
        this.template.querySelector('[data-id="disburseLoan"').disabled = true;
        this.isLoading = true
        var newDate = new Date();
        var todaysDate = newDate.getFullYear() + '-' + (newDate.getMonth() + 1).toString().padStart(2, '0') + '-' + newDate.getDate().toString().padStart(2, '0');
        if (this.loanApp.Disbursement_Date__c == todaysDate) {
            this.updateDateTime('Do Disbursement');
            if (this.loanApp.Disbursement_Category__c === 'Full' || (this.loanApp.Disbursement_Category__c === 'Partial' && this.trancheNumber === 1)) {
                generateDoDisbursement({ recordId: this.loanAppId, netDisbursementAmount: this.netDisbursementAmount }).then((data => {
                    this.isLoading = false
                    let callOutData = JSON.parse(data)
                    data = JSON.parse(callOutData.response)
                    if(callOutData && callOutData.statusCode && callOutData.statusCode!=200){
                        this.template.querySelector('[data-id="disburseLoan"').disabled = false;
                        this.showToast('Error', 'API Error: ' + callOutData.checklistNumber + ' Response: ' + callOutData.statusCode + '- ' + callOutData.status , 'error');
                    }else if (data.TransactionStatus && data.TransactionStatus.ResponseMessage === 'Success') {
                        this.showToastMessage('Success', 'Disbursement Successfull', 'success')
                        this.displayLoanDisbursementDetails = true
                        this.loanBalanceResponse = data.LoanBalanceResponse;
                        this.template.querySelector('[data-id="disburseLoan"').disabled = true;
                        //this.handlePaymentFavouringOnDoDisburse() -- moved after update as pool dibursement field was not getting set to true - Neha
                        /*New Update Method added SFAU-5557*/
                        let newLoanAppinstance = {};
                        newLoanAppinstance.Completed_Disbursement_Stage__c = 'Do Disbursement';
                        newLoanAppinstance.Disbursed_Tranche__c = (this.loanApp.Disbursed_Tranche__c + 1);
                        newLoanAppinstance.Is_Loan_Disbursed__c = true;
                        newLoanAppinstance.Id = this.loanApp.Id
                        newLoanAppinstance.Do_Disbursement_Success_Date__c = newDate;
                        updateLoanApplicationRecord({
                            applicationRecord : JSON.stringify(newLoanAppinstance)
                        })
                        .then(res=>{
                            if(res.isSuccess){
                                this.showToastMessage('Success', res.message, 'success', 'sticky');
                                this.handlePaymentFavouringOnDoDisburse();
                                if(this.loanApp.Disbursement_Category__c === 'Partial'){
                                    this.showToastMessage('Success', 'Tranche ' + (this.loanApp.Disbursed_Tranche__c + 1) + ' Disbursed Successfully', 'success')
                                    let paymentTrancheRecord = {};
                                    paymentTrancheRecord.Id = this.trancheId;
                                    paymentTrancheRecord.Disbursed__c = true;
                                    paymentTrancheRecord.Disbursement_Date__c = this.loanApp.Disbursement_Date__c;
                                    updatePaymentTrancheRecord({
                                        paymentRecord : JSON.stringify(paymentTrancheRecord)
                                    })
                                    .then(res=>{
                                        if(res.isSuccess){
                                            this.showToastMessage('Success', 'Tranche ' + (this.loanApp.Disbursed_Tranche__c + 1) + ' Disbursed Successfully', 'success')
                                            this.showToastMessage('Success', res.message, 'success');
                                        }
                                        else{
                                            this.showToastMessage('Error', res.message, 'error');
                                        }
                                        this.isLoading = false;
                                        this.showToastMessage('Success', 'Tranche ' + (this.loanApp.Disbursed_Tranche__c + 1) + ' Disbursed Successfully', 'success')

                                    })
                                    .catch(err=>{
                                        this.isLoading = false
                                        this.showToastMessage('Error', 'Error in updating Tranche!!', 'error', 'sticky')
                                        this.showToastMessage('Error', error.body.message, 'error', 'sticky')
                                    })
                                    
                                    // this.showToastMessage('Success', 'Tranche ' + (this.loanApp.Disbursed_Tranche__c + 1) + ' Disbursed Successfully', 'success')
                                    // var fields = { Id: this.trancheId, Disbursed__c: true, Disbursement_Date__c: this.loanApp.Disbursement_Date__c }
                                    // const recordInput = { fields };
                                    // updateRecord(recordInput).then(() => {
                                    // }).catch((error => {
                                    //     this.isLoading = false
                                    //     this.showToastMessage('Error', 'Error in updating Tranche!!', 'error', 'sticky')
                                    //     this.showToastMessage('Error', error.body.message, 'error', 'sticky')
        
                                    // }))
                                }
                            }
                            else{
                                this.isLoading = false
                                this.template.querySelector('[data-id="disburseLoan"').disabled = true;
                                this.showToastMessage('Error', res.message, 'error', 'sticky');
                            }
                            

                        })
                        .catch(err=>{
                            this.isLoading = false
                            this.template.querySelector('[data-id="disburseLoan"').disabled = true;
                            this.showToastMessage('Error', error.body.message, 'error', 'sticky')
                        })

                        /*New Update Method added end*/

                        
                        // var fields = { Id: this.loanAppId, Is_Loan_Disbursed__c: true, Disbursed_Tranche__c: (this.loanApp.Disbursed_Tranche__c + 1), Completed_Disbursement_Stage__c: 'Do Disbursement' }
                        // const recordInput = { fields };
                        // updateRecord(recordInput).then(() => {
                        //     this.handlePaymentFavouringOnDoDisburse() //moved here - Neha
                        //     if(this.loanApp.Disbursement_Category__c === 'Partial'){
                        //         this.showToastMessage('Success', 'Tranche ' + (this.loanApp.Disbursed_Tranche__c + 1) + ' Disbursed Successfully', 'success')
                        //         var fields = { Id: this.trancheId, Disbursed__c: true, Disbursement_Date__c: this.loanApp.Disbursement_Date__c }
                        //         const recordInput = { fields };
                        //         updateRecord(recordInput).then(() => {
                        //         }).catch((error => {
                        //             this.isLoading = false
                        //             this.showToastMessage('Error', error.body.message, 'error', 'sticky')
    
                        //         }))
                        //     }
                        // }).catch((error => {
                        //     this.isLoading = false
                        //     this.template.querySelector('[data-id="disburseLoan"').disabled = true;
                        //     this.showToastMessage('Error', error.body.message, 'error', 'sticky')

                        // }))
                        this.sendNotification(); //Notification 
                        //this.template.querySelector('[data-id="chevron"').iconName = 'utility:chevrondown';
                    }else if(data.TransactionStatus && (data.TransactionStatus.ResponseCode === '99' || data.TransactionStatus.ResponseCode === '55')){
                        this.template.querySelector('[data-id="disburseLoan"').disabled = false;
                        if(data.TransactionStatus.ExtendedErrorDetails && data.TransactionStatus.ExtendedErrorDetails.messages && data.TransactionStatus.ExtendedErrorDetails.messages.length>0){
                            let errorMessages = 'API Error: ' + callOutData.checklistNumber + ' Response: ';
                            data.TransactionStatus.ExtendedErrorDetails.messages.forEach(errorInput=>{
                                errorMessages = errorMessages+errorInput.message+' ;'
                            })
                            this.showToastMessage('Error',errorMessages,'error', 'sticky')

                        }
                        //this.showToastMessage('Error','We Encountered an Error while Processing Your Request','error', 'sticky')
                    }

                })).catch((error => {
                    this.isLoading = false
                    this.template.querySelector('[data-id="disburseLoan"').disabled = true;
                    this.showToastMessage('Error', error.body.message, 'error', 'sticky')

                }))
            }
            else {
                generateTrancheDisbursement({ recordId: this.loanAppId, netDisbursementAmount: this.netDisbursementAmount }).then((data => {
                    this.isLoading = false
                    if (data.TransactionStatus && data.TransactionStatus.ResponseMessage === 'Success') {
                        this.showToastMessage('Success', 'Disbursement Successfull', 'success')
                        //this.displayLoanDisbursementDetails = true
                        //this.loanBalanceResponse = data.LoanBalanceResponse;
                        this.template.querySelector('[data-id="disburseLoan"').disabled = true;
                        //this.template.querySelector('c-payment-details-ops-author').handleEnablePaymentReleaseButton();
                        this.handlePaymentFavouringOnDoDisburse()
                        this.loanApp.Completed_Disbursement_Stage__c = 'Do Disbursement'
                        var fields = { Id: this.loanAppId, Is_Loan_Disbursed__c: true, Disbursed_Tranche__c: (this.loanApp.Disbursed_Tranche__c + 1), Completed_Disbursement_Stage__c: 'Do Disbursement' }
                        const recordInput = { fields };
                        updateRecord(recordInput).then(() => {
                            this.showToastMessage('Success', 'Tranche ' + (this.loanApp.Disbursed_Tranche__c + 1) + ' Disbursed Successfully', 'success')
                            var fields = { Id: this.trancheId, Disbursed__c: true, Disbursement_Date__c: this.loanApp.Disbursement_Date__c }
                            const recordInput = { fields };
                            updateRecord(recordInput).then(() => {
                            }).catch((error => {
                                this.isLoading = false
                            }))
                        }).catch((error => {
                            this.isLoading = false
                            this.showToastMessage('Error', error.body.message, 'error', 'sticky')

                        }))
                    }else{
                        this.template.querySelector('[data-id="disburseLoan"').disabled = false;
                        this.showToastMessage('Error','We Encountered an Error while Processing Your Request','error', 'sticky')
                    }
                }))
            }
        } else {
            this.isLoading = false
            this.template.querySelector('[data-id="disburseLoan"').disabled = true;
            this.showToastMessage('Error', 'Disbursement was expected to be done on ' + this.loanApp.Disbursement_Date__c + ' .Please Submit the Loan Application to Ops Maker', 'error', 'sticky')
        }


    }
    closeModal(){
        this.openEMIModal = false;
    }
    handleReturnToSummary(){
        this.dispatchEvent(new CustomEvent('returntosummary'));
    }
    handleGenerateEsignClick(){
        this.dispatchEvent(new CustomEvent('generateesignclick'));
    }
    handleSignDeskEsign(){
        this.template.querySelector('c-generate-esign-component').handleGenerateEsign()
    }

      //29 AUG added notification 
      sendNotification(){
        sendDisbursedNotification({ loanId: this.loanAppId }).then((data => {
           console.log('sent notification successfully');
        })).catch((error => {
            this.isLoading = false
            this.showToastMessage('', IFT_API+' Failed - '+error, 'error', 'sticky')
        }))
    }
    //end
}