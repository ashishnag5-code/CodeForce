import { LightningElement, wire, api, track } from 'lwc';
import PAYMENT_OBJECT from '@salesforce/schema/Payment__c';
import getPaymentFavourings from '@salesforce/apex/RelatedPaymentFavouringsController.getPaymentFavourings';
import getPaymentFavouring from '@salesforce/apex/RelatedPaymentFavouringsController.getPaymentFavouring';
import updatePaymentFavouring from '@salesforce/apex/RelatedPaymentFavouringsController.updatePaymentFavouring';
import savePaymentFavouring from '@salesforce/apex/RelatedPaymentFavouringsController.savePaymentFavouring';
import checkDeviationRules from '@salesforce/apex/RelatedPaymentFavouringsController.checkDeviationRules';
import uploadFile from '@salesforce/apex/ChecqueOCRController.chequeOcrCallOut';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import karzaPennyCallout from '@salesforce/apex/KarzaPennyDropController.karzaPennyDropCallOut';
import getCasaDetails from '@salesforce/apex/RelatedPaymentFavouringsController.getCasaDetails';
import FORM_FACTOR from "@salesforce/client/formFactor";
import getBankName from '@salesforce/apex/LoanDetailsController.getBankName'; //SFAU-3506
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import getCurrentUserDetails from '@salesforce/apex/RelatedPaymentFavouringsController.getCurrentUserDetails'
import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c';
import COW_NEW_PRODUCTS from "@salesforce/label/c.COW_Product_Names";
import getMaterialFields from '@salesforce/apex/Utility.getMaterialFields';
import checkMaterialFields from '@salesforce/apex/Utility.checkMaterialFields';
import internalBTValidation from '@salesforce/apex/RelatedPaymentFavouringsController.internalBTValidation'
import {
    APPLICATION_SCOPE,
    createMessageContext,
    MessageContext,
    publish,
    releaseMessageContext,
    subscribe,
    unsubscribe,
} from 'lightning/messageService';
export default class RelatedPaymentFavouringsComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    isLoading = false;
    trueValue = true;
    falseValue = false;
    @api spinnerImage;
    showMainSection = true;
    showPaymentFavouringInsertion = true;
    addPaymentFavouring = false; 
    paymentFavouringsLst = [];
    externalBtLst = [];
    internalBtLst = [];
    @track acccountTypeOptions = [];
    marginMoneyOptions = [];
    accountTypeValue;
    marginMoneyValue;
    paymentFavouring = {};
    paymentRecipientOptions;
    paymentRecipientDependentOptions;
    paymentRecipientValue = '';
    oldPaymentRecipientValue = '';
    paymentModeOptions=[];
    originalPaymentModeOptions=[];
    paymentModeValue = '';
    oldPaymentModeValue = '';
    recordCount;
    payFavRecordTypeId;
    loanType;
    nameValue = '';
    bankValue = '';
    ifscValue = '';
    accountNoValue = '';
    netAmountValue = '';
    lastNetAmountValue = '';
    dealerName;
    dealerBank;
    dealerIfsc;
    dealerAccountNo;
    csdName;
    csdBank;
    csdIfsc;
    csdAccountNo;
    isAccDetailsReadOnly = false;
    accountNumberOptions = [];
    mapOfAcNoVsInternalBT=new Map()//R2-642
    bankOptions = [];
    isBankLookup = false;
    isBankPicklist = false;
    isAccountNumberPicklist = false;
    displayHelpTextForNetAmt=false
    @track loanAccountNumberLabel = 'Account Number'
    dealerClass;
    loanAmount;
    repaymentBankName;
    repaymentAccNo;
    totalNetAmount = 0;
    editPayment = false;
    editRecordId;
    errorOnChild;
    netLoanAmount;
    showButton = true;
    fileData;
    isUploadDisabled = false;
    boolShowVerify = false;
    boolShowError = false;
    isVerified = false;
    boolCheckAccNumber = true;
    isTranche = false;
    loanStage = '';
    loanLAN = ''; //SFAU-4066
    @track tranchePaymentArr = [];
    @track trancheOptions = [];
    @track paymentList = [];
    trancheValue;
    actionTypeGlobal;
    totalCharges = 0;
    netAmountValueForVal = 0;
    deviceType = '';
    disbursementCategory = '';
    loanApp
    @track bankRecordId
    @track repaymentBankIFSC='';
    ifscMatchedBankName = ''; //SFAU-3506
    @track hideIcons=false
    @track currentUserProfile
    @track opsUserType;
    @track displayFieldIfNotTA = true
    @track isEditRestricted//4733
    @track btPaymentList
    @api isRenderedFromRepayment = false;
    benificiaryResponseName='';
    showBenificiary = false;
    messageContext = createMessageContext();
    @track lasVerifyAccountNoValue = ''; // SFAU-5478 - Mohit
    @track lastBlnVerified = false;
    
    // SFAU-5478 - Penny drop API Validation Required - Mohit
    get blnIsVerified () {
        return this.isVerified && this.accountNoValue == this.lasVerifyAccountNoValue ? true : false;
    }

    // SFAU-5478 - Penny drop API Validation Required - Mohit
    get blnShowVerifyBtn () {
        return this.boolShowVerify && this.accountNoValue != this.lasVerifyAccountNoValue ? true : false;
    }    

    // SFAU-5307
  /*  get disablePaymentMode(){
        return this.bankValue && this.bankValue.toUpperCase().startsWith('AU') ? true : this.false;
    }
    */
    get docName() {
        return this.paymentRecipientValue == 'Customer' ? 'AUWheels0114' : 'AUWheels0133';
    }
    get docTypeName() {
        return this.docName == 'AUWheels0114' ? 'Payment favouring Cheque (Customer)' : 'Payment favouring Cheque (Dealer)';
    }

    // SFAU-5219
    get showMarginMoneyFld(){
        return (this.loanStage == 'Ops Maker' || this.loanStage == 'Ops Author') && this.paymentRecipientValue == 'CSD';
    }

    // SFAU-5219
    get disableMarginMoneyFld(){
        return !(this.opsUserType = 'Ops Maker' || this.loanStage == 'Ops Maker');
    }
    @wire(getObjectInfo, { objectApiName: PAYMENT_OBJECT })
    wiredObjectInfo({ error, data }) {
        if (data) {
            const rtis = data.recordTypeInfos;
            this.payFavRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Payment Favouring');
        }
        else if (error) {
            console.log('error is ' + JSON.stringify(error));
        }
    };

    @wire(getPicklistValuesByRecordType, { objectApiName: PAYMENT_OBJECT, recordTypeId: '$payFavRecordTypeId' })
    allDataPicklistValues({ error, data }) {
        if (data) {
            this.paymentRecipientOptions = data.picklistFieldValues.Payment_Recipient__c.values;
            this.paymentRecipientDependentOptions = data.picklistFieldValues.Payment_Recipient__c.values;
            this.originalPaymentModeOptions = data.picklistFieldValues.Payment_Mode__c.values;
            this.updatePaymentModeOptions();
            this.acccountTypeOptions = data.picklistFieldValues.Account_Type__c.values;
            this.marginMoneyOptions = data.picklistFieldValues.Margin_Money_Action__c.values;
        } else if (error) {
            console.log('error is ' + JSON.stringify(error));
        }
    }

    updatePaymentModeOptions(){
        this.paymentModeOptions = [];
        let setDefaultTranfer = false;
        //SFAU-5577: Updated by Samridhi to not consider TA cases
        if(this.bankValue && this.bankValue.toUpperCase().startsWith('AU') && this.paymentModeValue != 'TA'){
            this.paymentModeOptions.push({label: 'Transfer',value: 'Transfer'})
            this.paymentModeOptions.push({label: 'Cheque',value: 'Cheque'})
            setDefaultTranfer = true;
        }else{
            this.originalPaymentModeOptions.forEach(element => {
                if(element.value != 'Transfer'){
                    this.paymentModeOptions.push(element);
                }
            });
        }


        let paymentMode = this.template.querySelector("[data-name='Payment_Mode__c']")

        if(paymentMode){
            paymentMode.options = this.paymentModeOptions;
        }
        if(setDefaultTranfer && this.paymentModeValue != 'Cheque'){
            this.paymentModeValue = 'Transfer';
        }
    }


    async connectedCallback() {
        const currentUserDetails = await getCurrentUserDetails()
        if(currentUserDetails && currentUserDetails.Profile){
            this.currentUserProfile = currentUserDetails.Profile.Name
            this.opsUserType = currentUserDetails.Ops_User_Type__c;
        }
        this.handleFormFactor();
        this.getPaymentFavouringRecords();
        this.isEditRestricted = await restricAccess({compName: 'relatedPaymentFavouringsComponent' ,loanId: this.recordId})
    }

    handleFormFactor() {
        if (FORM_FACTOR === "Large") {
            this.deviceType = "Desktop/Laptop";
        } else if (FORM_FACTOR === "Medium") {
            this.deviceType = "Tablet";
        } else if (FORM_FACTOR === "Small") {
            this.deviceType = "Mobile";
        }
    }

    getPaymentFavouringRecords() {
        getPaymentFavourings({
            loanAppRecId: this.recordId
        })
            .then(data => {
                if (data) {
                    this.loanApp = data.loanApp
                    this.recordId = data.loanApp.Id
                    this.loanAmount = data.loanApp.Loan_Amount__c;
                    this.repaymentBankName = data.loanApp.Repayment_Bank_Name__c;
                    this.repaymentBankIFSC = data.loanApp.IFSC_Code__c;
                    this.repaymentAccNo = data.loanApp.Repayment_Account_Number__c;
                    this.loanStage = data.loanApp.Stage__c;
                    this.loanLAN =  data.loanApp.LAN__c != null ? data.loanApp.LAN__c :''; //SFAU-4066
                    this.disbursementCategory = data.loanApp.Disbursement_Category__c;
                    if (this.disbursementCategory == 'Partial') {
                        this.isTranche = true;
                    }
                    if (data.loanApp.hasOwnProperty("Total_Charges__c")) {
                        this.totalCharges = data.loanApp.Total_Charges__c;
                    }
                    this.tranchePaymentArr = data.tranchePymntLst;
                    this.paymentList = data.loanApp.Payments__r;
                    if (this.tranchePaymentArr) {
                        this.generateTrancheOptions();
                    }

                    if (data.loanType) {
                        this.loanType = data.loanType;
                    }
                    if (data.netLoanAmount) {
                        this.netLoanAmount = data.netLoanAmount;
                    }
                    if (data.loanApp.hasOwnProperty('Dealer_Master__r')) {
                        this.dealerName = data.loanApp.Dealer_Master__r.Account_Name__c;
                        this.dealerBank = data.loanApp.Dealer_Master__r.Bank_Name__c;
                        this.dealerIfsc = data.loanApp.Dealer_Master__r.IFSC_Code__c;
                        this.dealerAccountNo = data.loanApp.Dealer_Master__r.Benificiary_Account_Number__c;
                        this.dealerClass = data.loanApp.Dealer_Master__r.Dealer_Type__c//data.loanApp.Dealer_Master__r.Dealer_Class__c;
                    }else if (data.loanApp.hasOwnProperty('Sourcing_Channel_Name__r')) {
                        this.dealerName = data.loanApp.Sourcing_Channel_Name__r.Account_Name__c;
                        this.dealerBank = data.loanApp.Sourcing_Channel_Name__r.Bank_Name__c;
                        this.dealerIfsc = data.loanApp.Sourcing_Channel_Name__r.IFSC_Code__c;
                        this.dealerAccountNo = data.loanApp.Sourcing_Channel_Name__r.Benificiary_Account_Number__c;
                        this.dealerClass = data.loanApp.Sourcing_Channel_Name__r.Dealer_Type__c//data.loanApp.Dealer_Master__r.Dealer_Class__c;
                    } 
                    if (data.pmntFvrngMstr) {
                        this.csdName = data.pmntFvrngMstr.Name_of_benificiary__c;
                        this.csdBank = data.pmntFvrngMstr.Bank_Name__c;
                        this.csdIfsc = data.pmntFvrngMstr.IFSC__c;
                        this.csdAccountNo = data.pmntFvrngMstr.Account_number__c;
                    }
                    if (data.loanApp.hasOwnProperty('Payments__r')) {
                        this.paymentFavouringsLst = data.loanApp.Payments__r;
                        this.recordCount = data.loanApp.Payments__r.length;
                        let totalNetAMount = 0;
                        this.paymentFavouringsLst.forEach(element => {
                            if (element.Net_Amount__c) {
                                totalNetAMount = Number(totalNetAMount) + Number(element.Net_Amount__c);
                            }
                            this.totalNetAmount = totalNetAMount;
                        });
                    }
                    else {
                        this.recordCount = 0;
                        this.paymentFavouringsLst = undefined;
                    }
                    if (data.balanceTransferPymntLst) {
                        console.log('data.balanceTransferPymntLst' + JSON.stringify(data.balanceTransferPymntLst));
                        this.btPaymentList=data.balanceTransferPymntLst
                        this.bankOptions = [];
                        this.accountNumberOptions = [];
                        data.balanceTransferPymntLst.forEach(element => {
                            if (element.BT_Type__c && element.BT_Type__c == 'External') {
                                if(element.Payment_Recipient__c == 'Financer'){
                                    this.loanAccountNumberLabel = 'Loan Account Number'
                                }

                                this.externalBtLst.push(element);
                                this.bankOptions.push({ label: element.Financial_Institute_Name__c, value: element.Financial_Institute_Name__c });
                            }
                            else if (element.BT_Type__c && element.BT_Type__c == 'Internal' && element.Payment_Recipient__c == 'Financer') {
                                this.internalBtLst.push(element);
                                this.loanAccountNumberLabel = 'Loan Account Number'
                                //this.accountNumberOptions.push({ label: element.Account_Number__c, value: element.Account_Number__c });
                                this.accountNumberOptions.push({ label: element.Loan_Number__c, value: element.Loan_Number__c });

                            }

                        });
                    
                    }
                    if (this.internalBtLst.length == 1) {
                        //this.accountNoValue = this.internalBtLst[0].Account_Number__c;
                        this.accountNoValue = this.internalBtLst[0].Loan_Number__c;
                    }
                    if (this.internalBtLst.length >= 1) {
                        this.isAccountNumberPicklist = true;
                        //R2-642
                        if(this.loanApp.RecordType.DeveloperName=='Tractor'){
                            this.displayHelpTextForNetAmt=true
                        }
                    }else{
                        this.isAccountNumberPicklist=false
                    }
                   /* if(this.loanApp.Collaterals__r && this.loanApp.Collaterals__r.length>0){
                        if(this.loanApp.Collaterals__r[0].SVSH_SVOH__c=='SVOH'){
                            this.loanAccountNumberLabel = 'Loan Account Number'
                        }
                    }*/
                }
                
                this.hideActionsOnAuthorStage()
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
                this.paymentFavouringsLst = undefined;
            })
    }

    
    // START || R2 Changes Added Null check for Dealer in else condition
    setDealerDetails(paymentRecipient){
        if(paymentRecipient == 'CA'){
            //Sourcing channel check added as in case of Self Sourcing, Sourcing Channel lookup will be blank
            if(this.loanApp.Sourcing_Channel_Name__c){
                this.dealerName = this.loanApp.Sourcing_Channel_Name__r.Account_Name__c?this.loanApp.Sourcing_Channel_Name__r.Account_Name__c:'';
                this.dealerBank = this.loanApp.Sourcing_Channel_Name__r.Bank_Name__c?this.loanApp.Sourcing_Channel_Name__r.Bank_Name__c:'';
                this.dealerIfsc = this.loanApp.Sourcing_Channel_Name__r.IFSC_Code__c?this.loanApp.Sourcing_Channel_Name__r.IFSC_Code__c:'';
                this.dealerAccountNo = this.loanApp.Sourcing_Channel_Name__r.Benificiary_Account_Number__c?this.loanApp.Sourcing_Channel_Name__r.Benificiary_Account_Number__c:'';
                this.dealerClass = this.loanApp.Sourcing_Channel_Name__r.Dealer_Type__c?this.loanApp.Sourcing_Channel_Name__r.Dealer_Type__c:''//data.loanApp.Dealer_Master__r.Dealer_Class__c;
            }else{
                this.dealerName = '';
                this.dealerBank = '';
                this.dealerIfsc = '';
                this.dealerAccountNo = '';
                this.dealerClass = ''
            }
            
        }else{
            this.dealerName = this.loanApp.Dealer_Master__c ? this.loanApp.Dealer_Master__r.Account_Name__c : '';
            this.dealerBank =  this.loanApp.Dealer_Master__c ? this.loanApp.Dealer_Master__r.Bank_Name__c : '';
            this.dealerIfsc =  this.loanApp.Dealer_Master__c ? this.loanApp.Dealer_Master__r.IFSC_Code__c : '';
            this.dealerAccountNo =  this.loanApp.Dealer_Master__c ? this.loanApp.Dealer_Master__r.Benificiary_Account_Number__c : '';
            this.dealerClass =  this.loanApp.Dealer_Master__c ? this.loanApp.Dealer_Master__r.Dealer_Type__c : '';  //data.loanApp.Dealer_Master__r.Dealer_Class__c;
        }
    }

    hideActionsOnAuthorStage(){
        if(this.loanApp.Stage__c=='Ops Author' || this.loanApp.Stage__c=='PDD'){
            this.hideIcons=true
        }
        
    }

    setBTDetails(recipient, onChange){
        if (this.btPaymentList) {
            this.bankOptions = [];
            this.accountNumberOptions = [];
            this.externalBtLst=[]
            this.internalBtLst=[]
            this.mapOfAcNoVsInternalBT=new Map()
            this.btPaymentList.forEach(element => {
                if (element.BT_Type__c && element.BT_Type__c == 'External') {
                    if(recipient == 'Financer'){
                        this.loanAccountNumberLabel = 'Loan Account Number'
                    }

                    this.externalBtLst.push(element);
                    this.bankOptions.push({ label: element.Financial_Institute_Name__c, value: element.Financial_Institute_Name__c });
                }
                else if (element.BT_Type__c && element.BT_Type__c == 'Internal' && recipient == 'Financer') {
                    this.internalBtLst.push(element);
                    this.loanAccountNumberLabel = 'Loan Account Number'
                    //this.accountNumberOptions.push({ label: element.Account_Number__c, value: element.Account_Number__c });
                    this.accountNumberOptions.push({ label: element.Loan_Number__c, value: element.Loan_Number__c });
                    this.mapOfAcNoVsInternalBT.set(element.Loan_Number__c,element)//R2-642
                    if(onChange){
                        this.bankValue = element.Financial_Institute_Name__c
                    }
                }

            });
            console.log('externalBtLst' + JSON.stringify(this.externalBtLst));
            console.log('internalBtLst' + JSON.stringify(this.internalBtLst));
        }
        if (this.internalBtLst.length == 1) {
            this.accountNoValue = this.internalBtLst[0].Loan_Number__c;
            if(onChange &&  this.mapOfAcNoVsInternalBT.get(this.accountNoValue)!=undefined){//R2-3060
                this.netAmountValue = this.mapOfAcNoVsInternalBT.get(this.accountNoValue).POS__c//R2-642
            }
        }
        if (this.internalBtLst.length >= 1) {
            this.isAccountNumberPicklist = true;
            //R2-642
            if(this.loanApp.RecordType.DeveloperName=='Tractor'){
                this.displayHelpTextForNetAmt=true
            }
        }else{
            this.isAccountNumberPicklist=false
        }
    }

    generateTrancheOptions() {

        this.trancheOptions = this.tranchePaymentArr.map(opt => {
            return { label: opt.Tranche_Number__c, value: opt.Id, trancheNumber: opt.Tranche_Number__c, disbursementAmount: opt.Disbursement_Amount__c }
        });
        this.trancheValue = this.trancheOptions[0].value;
        this.currentTrancheNumber = this.trancheOptions[0].trancheNumber;
        this.setDefaultNetAmountValuePartial()
    }

    handlePaymentFavouringInformationClick(event) {
        //this.netAmountValue = "";
        //14 SEP
        this.boolShowVerify = false;
        this.showBenificiary = false;
        this.isVerified = false;
        this.benificiaryResponseName ='';
        //END

        this.displayFieldIfNotTA = true
        var tempNetAmount = 0
        if (this.paymentFavouringsLst && this.paymentFavouringsLst.length > 0) {
            this.paymentFavouringsLst.forEach(input => {
                tempNetAmount = tempNetAmount + input.Net_Amount__c;
            })
        }
        if (this.loanApp.Disbursement_Category__c == 'Full') {
            this.netAmountValue = (this.loanApp.Total_Loan_Amount__c - this.loanApp.Total_Charges__c) - tempNetAmount
        }
        if (this.loanApp.Disbursement_Category__c == 'Partial') {
            this.setDefaultNetAmountValuePartial()
        }
        this.addPaymentFavouring = true;
        if (this.loanType == 'New') {
            let r2RecordTypes = ['Commercial_Vehicle','Construction_Equipment','Tractor'];
            if(r2RecordTypes.includes(this.loanApp.RecordType.DeveloperName)){//R2-862
                this.paymentRecipientDependentOptions = this.paymentRecipientOptions.filter(option => (option.value == 'Dealer' || option.value == 'OEM'));
            }else{
                this.paymentRecipientDependentOptions = this.paymentRecipientOptions.filter(option => (option.value == 'Dealer' || option.value == 'CSD'));
            }
            this.paymentRecipientValue = 'Dealer';
            //if (this.dealerClass == 'TA Dealer') {
            if (this.dealerClass == 'TA') {
                this.paymentModeValue = 'TA';
                if(this.currentUserProfile == 'Sales' || this.currentUserProfile=='COM'){
                    this.displayFieldIfNotTA = false
                }
            }
            this.setDealerDetails(this.paymentRecipientValue);
            this.nameValue = this.dealerName;
            this.bankValue = this.dealerBank;
            this.updatePaymentModeOptions();
            this.ifscValue = this.dealerIfsc;
            this.accountNoValue = this.dealerAccountNo;
            this.isAccDetailsReadOnly = true;
        }
        else if (this.loanType == 'Used') {
            this.paymentRecipientDependentOptions = this.paymentRecipientOptions.filter(option => (option.value == 'UCD' || option.value == 'CA' || option.value == 'Customer' || option.value == 'Other' || option.value == 'Financer'));
        }
        //else if (this.loanType == 'Cash on Wheels') {
        else if(COW_NEW_PRODUCTS.toUpperCase().includes(this.loanType.toUpperCase())){//R2-862
            this.paymentRecipientDependentOptions = this.paymentRecipientOptions.filter(option => (option.value == 'UCD' || option.value == 'CA' || option.value == 'Customer' || option.value == 'Financer'));
        }
        else {
            this.paymentRecipientDependentOptions = this.paymentRecipientOptions;
        }
        //  this.applyCsstoBeneficiaryName("Desktop/Laptop");
    }

    applyCsstoBeneficiaryName(deviceType) {
        let event1 = setTimeout(() => {
            if (this.deviceType == deviceType) {
                let getBeneficiaryName = this.template.querySelector(`div[data-id="beneficiaryNameDiv"]`);
                getBeneficiaryName.classList.add("slds-m-top_x-small");
            }
        }, 500);
    }

    handleTranche(event) {
        this.trancheValue = event.detail.value;
        let getCurrentTranche = this.trancheOptions.filter(tranchOpt => tranchOpt.value == this.trancheValue);
        this.currentTrancheNumber = getCurrentTranche[0].trancheNumber;
        this.setDefaultNetAmountValuePartial()
    }

    setDefaultNetAmountValuePartial() {
        let getCurrentTranche = this.trancheOptions.filter(tranchOpt => tranchOpt.value == this.trancheValue);
        this.currentTrancheNumber = getCurrentTranche[0].trancheNumber;
        if (this.paymentFavouringsLst && this.paymentFavouringsLst.length > 0) {
            let payfavs = this.paymentFavouringsLst.filter(payOpt => payOpt.Tranche__c == this.trancheValue);
            var payFavNetAmount = 0
            if (payfavs && payfavs.length > 0) {
                payfavs.forEach(input => {
                    payFavNetAmount = payFavNetAmount + input.Net_Amount__c
                })
            }
            if (this.currentTrancheNumber == 1) {
                this.netAmountValue = getCurrentTranche[0].disbursementAmount - this.loanApp.Total_Charges__c - payFavNetAmount;
            } else if (this.currentTrancheNumber == 2 || this.currentTrancheNumber == 3) {
                this.netAmountValue = getCurrentTranche[0].disbursementAmount - payFavNetAmount;
            }
        } else {
            if (this.currentTrancheNumber == 1) {
                this.netAmountValue = getCurrentTranche[0].disbursementAmount - this.loanApp.Total_Charges__c;
            } else if (this.currentTrancheNumber == 2 || this.currentTrancheNumber == 3) {
                this.netAmountValue = getCurrentTranche[0].disbursementAmount;
            }
        }
    }

    handleAccountType(evt) {
        this.accountTypeValue = evt.detail.value;
    }

    handleMarginMoneyChange(evt){
        this.marginMoneyValue = evt.detail.value;
    }

    handleRowAction(event) {
        const recordId = event.currentTarget.dataset.id;
        const actionType = event.currentTarget.dataset.button;
        this.actionTypeGlobal = actionType;
        this.editRecordId = recordId;
        if (actionType == 'delete') {
            this.updatePaymentRecord(recordId, actionType);
        }
        else if (actionType == 'edit') {
            /*if( this.loanLAN!='' && (this.loanStage== 'Ops Maker' || this.loanStage == 'Ops Author' || this.loanStage == 'PDD')){ //SFAU - 4066
               // this.showErrorMessage('Payment Favouring Details cannot be edited', 'error'); 
                const evt = new ShowToastEvent({
                    title: 'Access Restricted',
                    message: 'Payment Favouring Details cannot be edited',
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);*/
             //}else{
                this.showMainSection = false;
                this.editPayment = true;
                this.getpaymentFavouringRecord();
           //  }
           
        }


    }

    getpaymentFavouringRecord() {
        getPaymentFavouring({
            paymentId: this.editRecordId
        })
            .then(data => {
                this.dispatchEvent(new CustomEvent('wizardevent', {
                    detail: { value: this.editRecordId, name: 'PaymentFavouring', mode: '' }
                }));
                if (data) {
                    this.displayFieldIfNotTA = true
                    this.paymentRecipientValue = data.Payment_Recipient__c;
                    this.paymentModeValue = data.Payment_Mode__c;
                    if (this.paymentRecipientValue == 'Dealer' && this.paymentModeValue == 'TA' && this.dealerClass == 'TA') {
                        if(this.currentUserProfile == 'Sales' || this.currentUserProfile=='COM'){
                            this.displayFieldIfNotTA = false
                        }
                    }
                    if (this.paymentRecipientValue == 'Dealer' || this.paymentRecipientValue == 'UCD' || this.paymentRecipientValue == 'CA' || this.paymentRecipientValue == 'CSD'){ // SFAU-5849 - Kunal
                        this.isAccDetailsReadOnly = true;
                    }
                    this.nameValue = data.Name__c;
                    this.bankValue = data.Bank_Name_PMT__c;
                    this.updatePaymentModeOptions();
                    this.ifscValue = data.IFSC_Code__c;
                    this.accountNoValue = data.Account_Number__c;
                    this.netAmountValue = data.Net_Amount__c;
                    this.netAmountValueForVal = data.Net_Amount__c;
                    this.isVerified = data.isVerified__c;
                    /* Start - SFAU-5478 - Penny drop API Validation Required - Mohit */
                    this.lasVerifyAccountNoValue = '';
                    if (this.isVerified == true) {
                        this.lasVerifyAccountNoValue = this.accountNoValue;
                        this.lastBlnVerified = true;
                    }
                    /* END - SFAU-5478 - Penny drop API Validation Required - Mohit */
                    this.showBenificiary = this.isVerified == true ? true : false 
                    this.benificiaryResponseName = data.Beneficiary_Name_Response__c;////14 SEP
                    this.trancheValue = data.Tranche__c;
                    if (data.Tranche__r) {
                        this.currentTrancheNumber = data.Tranche__r.Tranche_Number__c;
                    }
                    this.accountTypeValue = data.Account_Type__c;
                    this.marginMoneyValue = data.Margin_Money_Action__c;
                    if(this.paymentRecipientValue=='Financer'){
                        this.setBTDetails(this.paymentRecipientValue, false);
                    }
                    let valuesForEditableAccDetails = ['Financer','Customer','Other','OEM']//R2-2615
                    if(!valuesForEditableAccDetails.includes(this.paymentRecipientValue)){
                        this.isAccDetailsReadOnly = true;
                    }else{
                        this.isAccDetailsReadOnly = false;
                        this.handleVerifyButtonCheck();
                    }
                    
                    
                    this.disableFieldsAsPerMetadata();
                }

            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
            })

    }

    async disableFieldsAsPerMetadata(){
        this.fieldsToBeDisabled = await getMaterialFields({strScreen:'Payment Favouring',strLoanId:this.recordId});
        if(this.fieldsToBeDisabled){
            this.fieldsToBeDisabled.forEach((input=>{
                if(this.template.querySelectorAll('[data-name="'+input+'"]')){
                    this.template.querySelectorAll('[data-name="'+input+'"]').forEach((inputToBeDisabled=>{
                        inputToBeDisabled.disabled = true
                    }))
                }
            }))
        }
        this.isLoading=false
    }

    updatePaymentRecord(paymentRecId, context) {
        restricAccess({
            compName: 'relatedPaymentFavouringsComponent' ,loanId: this.recordId
            })
            .then(data => {
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save/edit Payment Favourings',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
                else{
      
        updatePaymentFavouring({
            paymentRecId: paymentRecId,
            context: context
        })
            .then(data => {
                if (data) {
                    this.getPaymentFavouringRecords();
                    if (context == 'delete') {
                        this.showToastMsg('Success', 'Payment Favouring deleted successfully.', 'success');
                        this.handleResetVerifyButton();
                    }
                }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
            })
            this.setDealerDetails(this.paymentRecipientValue);
                }
            })
            .catch(error=>{
                console.log('error is ' + JSON.stringify(error));

            })
        

    }

    navigateToAppRecordPage(event) {
        this.navigateToRecordPage(event.currentTarget.dataset.id);

    }

    navigateToRecordPage(objectRecordid) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: objectRecordid,
                objectApiName: 'Payment_Favouring__c',
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
                relationshipApiName: 'Payments__r',
                actionName: 'view'
            },
        });
    }

    handlePaymentRecipientChange(event) {
        this.paymentRecipientValue = event.target.value;
        this.isAccountNumberPicklist=false
        this.loanAccountNumberLabel = 'Account Number'; //CUG -- 8thSept23
        if (this.paymentRecipientValue == 'Dealer' || this.paymentRecipientValue == 'UCD' || this.paymentRecipientValue == 'CA') {
            this.isUploadDisabled = true;
            //if (this.paymentRecipientValue == 'Dealer' && this.paymentModeValue != 'TA' && this.dealerClass == 'TA Dealer') {
            if (this.paymentRecipientValue == 'Dealer' && this.paymentModeValue != 'TA' && this.dealerClass == 'TA') {
                this.paymentModeValue = 'TA';
            }
            if (this.paymentModeValue == 'Cheque') {
                this.paymentModeValue = '';
            }
            this.setDealerDetails(this.paymentRecipientValue);

            this.nameValue = this.dealerName;
            this.bankValue = this.dealerBank;
            this.ifscValue = this.dealerIfsc;
            this.accountNoValue = this.dealerAccountNo;
            this.isAccDetailsReadOnly = true;
            this.isBankLookup = false;
            this.boolShowVerify = false;
            this.boolCheckAccNumber = true;
        }
        else if (this.paymentRecipientValue == 'CSD') {
            this.isUploadDisabled = true;
            if (this.paymentModeValue == 'TA' || this.paymentModeValue == 'Cheque') {
                this.paymentModeValue = '';
            }
            this.nameValue = this.csdName;
            this.bankValue = this.csdBank;
            this.ifscValue = this.csdIfsc;
            this.accountNoValue = this.csdAccountNo;
            this.isAccDetailsReadOnly = true;
            this.isBankLookup = false;
            this.boolShowVerify = false;
            this.boolCheckAccNumber = true;
        }
        else if (this.paymentRecipientValue == 'Financer') {
            this.isUploadDisabled = false;
            
            if (this.paymentModeValue == 'TA') {
                this.paymentModeValue = '';
            }
            this.paymentModeValue = 'Cheque';
            this.isAccDetailsReadOnly = false;
            this.resetBankDetails();
            console.log('this.externalBtLst.length', this.externalBtLst.length);
            this.setBTDetails(this.paymentRecipientValue, true)
            if (this.externalBtLst.length == 1) {
                this.bankValue = this.externalBtLst[0].Financial_Institute_Name__c;
            }
            else if (this.externalBtLst.length > 1) {
                this.isBankPicklist = true;
            }
            else {
                if(this.loanApp.BT_Type__c=='Internal'){
                    this.isBankLookup = false;
                }else{
                    this.isBankLookup = true;
                }
                
            }

            //if(this.externalBtLst.length > 0 || this.internalBtLst.length > 0)
            this.loanAccountNumberLabel = 'Loan Account Number'

            this.handleVerifyButtonCheck();

        }
        else if (this.paymentRecipientValue == 'Other') {
            this.isUploadDisabled = false;
            if (this.paymentModeValue == 'TA' || this.paymentModeValue == 'Cheque') {
                this.paymentModeValue = '';
            }
            this.isAccDetailsReadOnly = false;
            this.resetBankDetails();
            this.isBankLookup = false;
            this.handleVerifyButtonCheck();

        }
        else if (this.paymentRecipientValue == 'Customer') {
            this.isUploadDisabled = false;
            if (this.paymentModeValue == 'TA' || this.paymentModeValue == 'Cheque') {
                this.paymentModeValue = '';
            }
            this.bankValue = this.repaymentBankName;
            this.ifscValue = this.repaymentBankIFSC
            this.accountNoValue = this.repaymentAccNo;
            this.isAccDetailsReadOnly = false;
            this.loanAccountNumberLabel = 'Account Number'; //CUG -- 8thSept Account Number to be shown if Payment Recipient is Customer
            this.isBankLookup = false;
            if (this.paymentModeValue == 'NEFT') {
                this.isAccDetailsReadOnly = false;
            }
            this.handleVerifyButtonCheck();
            this.handleCasa();
        }
        else {
            this.isUploadDisabled = false;
            if (this.paymentModeValue == 'TA' || this.paymentModeValue == 'Cheque') {
                this.paymentModeValue = '';
            }
            this.isAccDetailsReadOnly = false;
            this.resetBankDetails();
            this.isBankLookup = false;
        }
        if((this.paymentRecipientValue == 'Dealer' || this.paymentRecipientValue == 'UCD') && (this.currentUserProfile == 'Sales' || this.currentUserProfile=='COM')){
            if(this.paymentModeValue == 'TA'){
                this.displayFieldIfNotTA = false
            }
            if(this.paymentModeValue != 'TA'){
                this.displayFieldIfNotTA = true
            }
        }else{
            this.displayFieldIfNotTA = true
        }
        this.oldPaymentRecipientValue = event.target.value;
        this.updatePaymentModeOptions();
    }

    handleCasa() {
        this.isLoading = true;
        getCasaDetails({
            loanId: this.recordId
        }).then(data => {
            this.isLoading = false;
            this.isLoading = false;
            if (data) {
                this.ifscValue = data.IFSC_Code__c;
                this.bankValue = data.Bank_Name__c;
                this.updatePaymentModeOptions();
                this.accountNoValue = data.Account_Number__c;
                this.nameValue = data.Applicant__r.Customer_Name__c;
            }

        })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
                this.isLoading = false;
            })
    }

    handleVerifyButtonCheck() {
        if (this.loanStage == 'PSD' || this.loanStage == 'Ops Maker' || this.loanStage == 'Ops Author' || this.loanStage == 'Partially Disbursed' || this.loanStage == 'PDD') {  //PSD
            // START - SFAU-5478
            this.boolShowVerify = this.accountNoValue == this.lasVerifyAccountNoValue && this.lastBlnVerified ? false : true;
            this.isVerified = this.accountNoValue == this.lasVerifyAccountNoValue && this.lastBlnVerified ? true : false;
            // END - SFAU-5478
            this.boolCheckAccNumber = false;
        }
        /*else if(this.loanStage == 'Opps' ||  this.loanStage =='PDD' ){ //Opps
            this.boolShowVerify = true;
            this.boolCheckAccNumber = true;
        }*/

    }

    resetBankDetails() {
        this.nameValue = '';
        this.bankValue = '';
        this.updatePaymentModeOptions();
        this.ifscValue = '';
        this.accountNoValue = '';
    }

    handlePaymentModeChange(event) {
        this.paymentModeValue = event.target.value;
        if (this.paymentRecipientValue == 'Customer') {
            /*if (this.paymentModeValue == 'NEFT') {
                this.isAccDetailsReadOnly = false;
            }
            else {
                this.isAccDetailsReadOnly = true;
            }*/
            this.isAccDetailsReadOnly = false; //R2-2147
        }
        
        if((this.paymentRecipientValue == 'Dealer' || this.paymentRecipientValue == 'UCD') && (this.currentUserProfile == 'Sales' || this.currentUserProfile=='COM')){
            if(event.target.value == 'TA'){
                this.displayFieldIfNotTA = false
            }
            if(event.target.value != 'TA'){
                this.displayFieldIfNotTA = true
            }
        }else{
            this.displayFieldIfNotTA = true
        }
        
        this.oldPaymentModeValue = event.target.value;
    }

    handleNameChange(event) {
        this.nameValue = event.target.value;
    }

    handleBankChange(event) {
        this.bankValue = event.target.value;
        //SFAU-5307
        if(this.bankValue && this.bankValue.toUpperCase().startsWith('AU') && this.paymentModeValue != 'TA'){
            this.paymentModeValue = 'Transfer';
        }
        this.updatePaymentModeOptions();
    }
    

    handleIfscChange(event) {
        let value = event.target.value;
        this.ifscValue = value.toUpperCase();
        // this.handleResetVerifyButton();
        this.isVerified = false;
        this.boolShowError = false;
        this.handleBankName(); //SFAU-3506
        this.handleVerifyButtonCheck();
    }

    handleAccountNoChange(event) {
        this.accountNoValue = event.target.value;
        // this.handleResetVerifyButton();
        this.isVerified = false;
        this.boolShowError = false;
        if(this.paymentRecipientValue=='Financer' && this.loanApp.BT_Type__c=='Internal' && this.mapOfAcNoVsInternalBT.get(this.accountNoValue)!=undefined){ //R2-3060
            this.netAmountValue = this.mapOfAcNoVsInternalBT.get(this.accountNoValue).POS__c
        }//R2-642
        this.handleVerifyButtonCheck();
    }

    handleNetAmountChange(event) {

        let totalNetAmtByTrancheNumber = 0;
        let netAmount = event.target.value;
        this.netAmountValue = netAmount;
    }

    handleRecordInsertionCancel() {
        this.addPaymentFavouring = false;
        this.resetBankDetails();
        this.paymentRecipientValue = '';
        this.paymentModeValue = '';
        this.netAmountValue = '';
        this.actionTypeGlobal = '';
        //14 SEP
        this.boolShowVerify = false;
        this.showBenificiary = false;
        this.isVerified = false;
        this.benificiaryResponseName ='';
        //END

    }

    handleRecordInsertionSave() {
        this.savePaymentFavouringRecord('insert');
    }

    savePaymentFavouringRecord(context) {

        //SFAU-5307
        if(this.netAmountValue < 200000 && this.paymentModeValue == 'RTGS'){
            this.showToastMessage("", "RTGS is not applicable under 2 Lacs", 'error', 'sticky');
            return;
        }

        //  let validateSequenceOfTranche = this.validateTrancheInsequence();
        restricAccess({
            compName: 'relatedPaymentFavouringsComponent' ,loanId: this.recordId
            })
            .then(data => {
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save/edit Payment Favourings',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
                else{
        if (this.isInputValid()) {
            if (context == 'update') {
                this.paymentFavouring['Id'] = this.editRecordId;
            }
            this.paymentFavouring['Loan_Application__c'] = this.recordId;
            this.paymentFavouring['Payment_Recipient__c'] = this.paymentRecipientValue;
            this.paymentFavouring['Payment_Mode__c'] = this.paymentModeValue;
            this.paymentFavouring['Name__c'] = this.nameValue;
            this.paymentFavouring['Bank_Name_PMT__c'] = this.bankValue;
            this.paymentFavouring['IFSC_Code__c'] = this.ifscValue;
            this.paymentFavouring['Account_Number__c'] = this.accountNoValue;
            this.paymentFavouring['Net_Amount__c'] = Math.trunc(this.netAmountValue);
            this.paymentFavouring['isVerified__c'] = this.isVerified;
            this.paymentFavouring['Tranche__c'] = this.trancheValue;
            this.paymentFavouring['Account_Type__c'] = this.accountTypeValue;
            this.paymentFavouring['Margin_Money_Action__c'] = this.paymentRecipientValue == 'CSD' ?  this.marginMoneyValue : '';

            this.paymentFavouring['Beneficiary_Name_Response__c'] = this.benificiaryResponseName; //25 AUG
            savePaymentFavouring({
                paymentRec: this.paymentFavouring,
                loanType: this.loanType,
                tranchOptions: this.trancheOptions,
                loanApplId: this.recordId,
                context: context,
                currentTranchNum: this.currentTrancheNumber
            })
                .then(data => {
                    if (data) {
                        this.getPaymentFavouringRecords();
                        if (context == 'insert') {
                            this.addPaymentFavouring = false;
                            this.showMessage('Payment Favouring created succesfully.', 'success');
                        }
                        else if (context == 'update') {
                            this.showMainSection = true;
                            this.editPayment = false;
                            this.showMessage('Payment Favouring updated succesfully.', 'success');
                        }
                        this.resetBankDetails();
                        this.paymentRecipientValue = '';
                        this.paymentModeValue = '';
                        this.netAmountValue = '';
                        this.totalNetAmount = 0;
                        this.actionTypeGlobal = '';
                        this.paymentFavouring = {};
                        
                        // SFAU-5427 - Refresh disburement screen on payment favouring change - (Samridhi)
                        const payload = { recordIdOfSobject: this.recordId, refreshPage: 'Yes', componentNames: 'loan-disbursement-ops'};
                        publish(this.messageContext, pageRefreshOnMaterialFieldChange, payload);
                    }
                })
                .catch(error => {
                    console.log('error is ' + JSON.stringify(error));
                    this.showToastMessage("", error.body.message, 'error', 'sticky');

                })
        }

    }
            })
            .catch(err=>{

            })
        
    }

    calculateTotalNetAmount() {

        let bigObj = new Map();

        if (this.paymentList && this.paymentList.length > 0) {
            for (let val of this.paymentList) {
                let obj = {};
                let trancheNum = val.Tranche__r.Tranche_Number__c;
                if (bigObj.has(trancheNum)) {

                    bigObj.get(trancheNum).totalAmount += val.Net_Amount__c;
                    bigObj.get(trancheNum).count++;

                }
                else {
                    obj['totalAmount'] = val.Net_Amount__c;
                    obj['count'] = 1;
                    bigObj.set(trancheNum, obj);
                }
            }
        }
        return bigObj;
    }

    sortArrayInAscOrder(tranchNumberArr) {
        const sorted = [...tranchNumberArr].sort((a, b) => a - b);
        return sorted;
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


    isInputValid() {
        let isValid = true;
        if (this.paymentRecipientValue == 'Customer') {
            if (this.loanStage == 'PSD') { //PSD
                if (this.isVerified == true) {
                    isValid = true;
                } else {
                    isValid = false;
                    this.showMessage('Please Verify the Account Number', 'error');
                }
            }
        }


        let inputFields = this.template.querySelectorAll(".validate");
        inputFields.forEach(inputField => {
            if (!inputField.value) {
                inputField.setCustomValidity("Complete this field");
                inputField.reportValidity();
                isValid = false;
            } else {
                inputField.setCustomValidity('');
                inputField.reportValidity();
            }
        });
        return isValid;
    }


    handleLookupSelect(event) {
        let selectedValue = event.detail.value;
        let selectedName = event.detail.name;
        let fieldName = event.detail.fieldapi;
        let objectName = event.detail.objApiName;
        if (fieldName !== null && selectedName !== null) {

            //this.loanApplicationRecord['Dealer_Master__c'] = selectedValue;
            this.paymentFavouring[fieldName] = selectedName;

        }
        this.bankValue = selectedName;
        this.updatePaymentModeOptions();
    }

    handleRecordUpdateCancel() {
        this.editPayment = false;
        this.showMainSection = true;
        this.resetBankDetails();
        this.paymentRecipientValue = '';
        this.paymentModeValue = '';
        this.netAmountValue = '';
        this.actionTypeGlobal = '';
    }

    showMessage(message, variant) {
        const event = new ShowToastEvent({
            title: '',
            variant: variant,
            mode: variant === 'error' ? 'sticky' : 'dismissable',
            message: message
        });
        this.dispatchEvent(event);
    }

    handleRecordUpdateCancel() {
        this.editPayment = false;
        this.showMainSection = true;
    }

    handleRecordUpdateSave() {
        this.savePaymentFavouringRecord('update');
    }

    checktotalAmountForPartial() {

        let getAllpaymentFav = this.calculateTotalNetAmount();

        let tranchcNumArr = [];
        let checkCompleteTranches = [];

        if (getAllpaymentFav && getAllpaymentFav.size > 0) {
            for (let [key, value] of getAllpaymentFav) {
                let totAmt = value.totalAmount;
                let getTranchNum = this.trancheOptions.filter(opt => opt.trancheNumber == key);
                let disbursementAmt = 0
                if (getTranchNum[0].trancheNumber == 1) {
                    disbursementAmt = getTranchNum[0].disbursementAmount - this.loanApp.Total_Charges__c;
                } else {
                    disbursementAmt = getTranchNum[0].disbursementAmount;
                }
                if (totAmt != disbursementAmt) {
                    tranchcNumArr.push(key);
                }
                else if (totAmt == disbursementAmt) {
                    checkCompleteTranches.push('true');
                }
            }

            if (tranchcNumArr.length > 0) {
                //this.showToastMessage("",`Please complete the Net amount of Tranche ${tranchcNumArr.toString()}`, "error", "sticky");
                this.showToastMessage("", `Net Amount (Payment Favourings for Tranche ${tranchcNumArr.toString()}) does not match with Tranche Disbursement Amount`, "error", "sticky");
                return true;
            }

            if (checkCompleteTranches.includes('false')) {
                return true;
            }
        } else {
            this.showToastMessage("", 'Adding Payment Favouring is Mandatory', "error", "sticky");
            return true;

        }

    }

    checktotalAmountForFull() {
        //let totalLoanAmt = this.loanAmount - this.totalCharges;
        let totalLoanAmt = this.loanApp.Total_Loan_Amount__c - this.loanApp.Total_Charges__c;
        let totalPaymentAMt = 0;
        if (this.paymentList && this.paymentList.length > 0) {
            for (let payment of this.paymentList) {
                totalPaymentAMt += payment.Net_Amount__c;
            }

            if (totalLoanAmt < totalPaymentAMt) {
                this.showToastMessage("", 'Net Amount cannot exceed ' + totalLoanAmt, "error", "sticky");
                return true;
            } else if (totalLoanAmt != totalPaymentAMt) {
                this.showToastMessage("", 'Net Amount should be equal to ' + totalLoanAmt, "error", "sticky");
                return true;
            }
        } else {
            this.showToastMessage("", 'Adding Payment Favouring is Mandatory', "error", "sticky");
            return true;

        }

    }
    
    async checkInternalBTValidations(){
        let validations = await internalBTValidation({recordId: this.loanApp.Id})
        if(validations && validations.length>0){
            let accounts=''
            validations.forEach(input=>{
                accounts = accounts+input+'; '
            })
            this.showToastMessage("", 'Payment Favourings are mandatory for Foreclosure Accounts - '+accounts, "error", "sticky");
            return false
        }
        return true;
    }

    @api 
    async nextHandler() {
        if (!this.paymentList && this.loanStage == 'DDE') {
            this.showToastMessage("", 'Adding Payment Favouring is Mandatory at DDE stage', "error", "dismissable");
        }
        else {
            if(this.loanApp.RecordType.DeveloperName=='Tractor'){
                let btValidationSuccess = await this.checkInternalBTValidations()
                if(!btValidationSuccess){
                    return;
                }
            }
            
            if (this.disbursementCategory == "Partial") {
                let checkForPartial = this.checktotalAmountForPartial();
                if (checkForPartial) {
                    this.nextButtonToBeEnabled(true)
                    return;
                }
            }
            else if (this.disbursementCategory == "Full") {
                let checkForFull = this.checktotalAmountForFull();
                if (checkForFull) {
                    this.nextButtonToBeEnabled(true)
                    return;
                }
            }
            this.checkDeviationRules();
            const Obj = {};
            //Obj.applicantRecord = this.applicantIdInput;
            this.errorOnChild = '';
            Obj.errorOnChild = this.errorOnChild;
            Obj.next = this.errorOnChild == '' ? true : false;
            if(Obj.next && this.isRenderedFromRepayment){
                this.dispatchEvent(new CustomEvent('navigateback'));
            }
            this.dispatchEvent(new CustomEvent('next', {
                detail: Obj
            }));
        }
    }

    nextButtonToBeEnabled(isError) {
        const Obj = {};
        //Obj.applicantRecord = this.applicantIdInput;
        this.errorOnChild = isError ? 'Yes' : '';
        Obj.errorOnChild = this.errorOnChild;
        Obj.next = this.errorOnChild == '' ? true : false;
        if(Obj.next && this.isRenderedFromRepayment){
            //alert('navigate back');
            this.dispatchEvent(new CustomEvent('navigateback'));
        }
        this.dispatchEvent(new CustomEvent('next', {
            detail: Obj
        }));
    }

    checkDeviationRules() {
        checkDeviationRules({
            loanAppRecId: this.recordId
        })
            .then(data => {

            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
            })

    }


    openfileUpload(event) {
        this.isLoading = true;
        const file = event.target.files[0];
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1];
            this.fileData = {
                'loanAppId': this.recordId,
                'filename': file.name,
                'file64': base64,
            }
        }
        reader.readAsDataURL(file);

        var intervalID = setInterval(() => {
            this.handleClick();
            clearInterval(intervalID);
        }, 10);

    }

    //api call for Cheque OCR
    handleClick() {
        const { loanAppId, file64 } = this.fileData;
        uploadFile({ loanAppId, file64 })
            .then(result => {
                this.isLoading = false;
                if (result) {
                    var resultObj = JSON.parse(result);
                    if (resultObj.statusCode == 101) {
                        this.paymentModeValue = 'Cheque';
                        this.ifscValue = resultObj.result.ifsc;
                        this.accountNoValue = resultObj.result.accNo;
                        this.nameValue = resultObj.result.name[0];
                        this.bankValue = resultObj.result.bank;
                        this.updatePaymentModeOptions();
                        let msg = `Payment Favouring Cheque has been uploaded successfully!!`;
                        this.showMessage(msg, 'success');
                    } else {
                        // R2-2389 - changed the error message
                        let msg = 'The API returned an error with status code ' + resultObj.statusCode + '. Please reach out to your admin for help.';
                        this.showMessage(msg, 'error');
                    }
                }
            })
            .catch(error => {
                this.isLoading = false;
                console.log('error is ', JSON.stringify(error));
            })

    }
    // START || SFAU-3506
    handleBankName() {
        getBankName({
            ifsc: this.ifscValue
        })
            .then(data => {
                this.ifscMatchedBankName = data.Bank_Name__c;
                console.log('this.ifscMatchedBankName-->' + this.ifscMatchedBankName);
                /*if(data.Bank_Name__c ==  this.bankValue){
                     console.log('matched');
                     //this.bannk
                }else{
                 console.log('not matched');
                }*/

            })
            .catch(error => {
                console.log('error ' + JSON.stringify(error));
            })
    }
    //END

    //api to call karza penny drop api
    async  handleVerify() {
        this.boolShowError = false;
        const bankData = await getBankName({ifsc: this.ifscValue})
        this.ifscMatchedBankName = bankData.Bank_Name__c;
        if (this.ifscMatchedBankName == this.bankValue) { // SFAU-3506
            if (this.ifscValue != '' && this.accountNoValue != '' && this.accountNoValue != undefined) {
                this.isLoading = true;
                karzaPennyCallout({
                    strIFSCCode: this.ifscValue,
                    strAccNumber: this.accountNoValue,
                    loanAppId: this.recordId
                })
                    .then(result => {
                        this.isLoading = false;
                        if (result) {
                            this.benificiaryResponseName = result // 14 SEP
                            //this.showBenificiary = this.loanStage == 'PSD' ? true : false;
                            this.showBenificiary = true;
                            this.boolCheckAccNumber = true;
                            this.isVerified = true;
                            // - SFAU-5478 - Penny drop API Validation Required - Mohit
                            this.lasVerifyAccountNoValue = this.accountNoValue;
                            this.lastBlnVerified = true;
                            this.boolShowVerify = false;
                            this.showToastMessage("", ' Account Number ' + this.accountNoValue + '  Verified Successfully', "Success", "dismissable");
                        } else {
                            this.boolShowError = true;
                            this.boolShowVerify = false;
                            this.showToastMessage("", 'The Karza API Failed', "error", "dismissable");
                        }

                    })
                    .catch(error => {
                        this.isLoading = false;
                        this.boolShowError = true;
                        this.boolShowVerify = false;
                        console.log('error in karzaPennyCallout ', JSON.stringify(error));
                    })
            } else {
                this.showToastMessage("", 'Please fill the Account Number and IFSC Code to verify', "error", "dismissable");
            }
        } else {
            this.showToastMessage("", 'The entered IFSC Code does not match the corresponding Bank Name. Please update it accordingly in order to proceed.', "error", "dismissable");
        }

    }
    // END

    handleResetVerifyButton() {
        this.isVerified = false;
        //this.boolShowVerify = true;
        // this.boolCheckAccNumber = false;
    }

    handleSuccess(event) {
        this.isLoading = true;
        if (event.detail.isSuccess) {
            this.fileData = {
                'loanAppId': this.recordId,
                'filename': event.detail.fileName,
                'file64': event.detail.base64,
            }
            this.handleClick();
        } else {
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                mode: 'error',
                message: event.detail.errorMessage
            });
            this.dispatchEvent(event);
        }
    }

    navigateBackToRepayment(evt){
        this.nextHandler();
        
    }


}