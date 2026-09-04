import { LightningElement,track, api,wire } from 'lwc';
import { getBarcodeScanner } from "lightning/mobileCapabilities";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveRecord from '@salesforce/apex/LOSPDDMakerController.saveData';
import getData from '@salesforce/apex/LOSPDDMakerController.getData';
import saveOpsDetailsOnLoan from '@salesforce/apex/LOSPDDMakerController.saveOpsDetailsOnLoan';
import getCollateralList from '@salesforce/apex/AUSFVehicleController.getCollateralList';
import sendNotification from '@salesforce/apex/NotificationHandler.sendNotification';
import OtpDurationLabel from '@salesforce/label/c.AUSF_RESEND_OTP_DURATION';
import getDealerRCDetails from '@salesforce/apex/LOSPDDMakerController.getDealerRCDetails';
import getRecordInfo from '@salesforce/apex/LOSPDDMakerController.getRecordInfo';
import reSubmitRecord from '@salesforce/apex/LOSPDDMakerController.reSubmitRecord';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import OPS_PDD_Action from "@salesforce/schema/Loan_Application__c.OPS_PDD_Action__c";
import OPS_PDD_Remark from "@salesforce/schema/Loan_Application__c.OPS_PDD_Remark__c";
import FORM_FACTOR from '@salesforce/client/formFactor';
import AUSF_LOGOS from "@salesforce/resourceUrl/AUSF_LOGOS";
import deactivateDocument from '@salesforce/apex/LOSDocumentManagerController.deactivateDocument'
import getDocumentChecklist from '@salesforce/apex/LOSDocumentManagerController.getDocumentChecklist';
import getVahaanDetail from '@salesforce/apex/AUSFVehicleController.getVahaanDetail';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import getAgentInfobyId from '@salesforce/apex/LOSPDDMakerController.getAgentInfobyId';
const fields = [OPS_PDD_Action,OPS_PDD_Remark];
import { loadStyle } from 'lightning/platformResourceLoader';
import opsAccordion from '@salesforce/resourceUrl/opsAccordion';
import { publish, MessageContext } from 'lightning/messageService';
import { NavigationMixin } from "lightning/navigation";
import LightningAlert from 'lightning/alert';
//import getROCChargesData from '@salesforce/apex/LOSPDDMakerController.getROCChargesData';

//import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
//SFAU-5835
import createVahanReport from '@salesforce/apex/AUSFVehicleController.createVahanReport';
import updateReportOnRc from '@salesforce/apex/LOSPDDMakerController.updateReportOnRc';
// Tractor Changes
import IMPLEMENT_PRODUCT_CODE from '@salesforce/label/c.Implement_Collateral_Code';
import TRACTOR_PRODUCT_CODES from '@salesforce/label/c.Tractor_Product_Codes';
import {showToastMessage} from 'c/lwcutilities';
import PDD_MAKER_TRACKER_INVOICE_AMOUNT_VALIDATION from '@salesforce/label/c.PDD_Maker_Invoice_Amount_Validation';
// Tractor Changes

// Commercial Changes
import COMMERCIAL_PRODUCT_CODE from '@salesforce/label/c.Commercial_Product_Codes';
import COMMERCIAL_BODY_FUNDING_CODE from '@salesforce/label/c.Commercial_Body_Funding_Collateral_Codes';
// Commercial Changes

// Construction Equipment changes
import CONSTRUCTION_EQUIPMENT_PRODUCT_CODES from '@salesforce/label/c.Construction_Equipment_Product_Codes';
const REGISTRABLE_LITERAL = 'Yes';
const NON_REGISTRABLE_LITERAL = 'No';
const ATTACHMENT_LITERAL = 'Yes';
// Construction Equipment changes
import callCollateralModificationCallout from '@salesforce/apex/CollateralModificationAPIController.callCollateralModificationCalloutPDD'
import getRegistrationCityPickListValues from '@salesforce/apex/AUSFVehicleController.getRegistrationCityPickListValues';
export default class LosPDDMaker extends NavigationMixin(LightningElement) {
    activeSections = ['pddModule','documentTypeInvoice','documentTypeInsurance','documentTypeTax','documentTypeVehicleRC','deferralRegisterForRTO','originalDocsCollected','rocCharge'];
    isloading = false;
    isloadingTable = false;
    showPage = false;
    picklistValues = {};
    disableDuplicate = false;
    boolSendOtp = true;
    boolRequestOtp = false;
    boolCheckMobileNumber = true;
    isOpsUser;
    isNotOpsUser = false;
    errorOnChild;
    isMobile;
@track loanRecType
    @track increse1Second;
    @track boolResendOtp = false;
    get isNotOpsMaker(){
        return !this.isOpsUser || !this.allowEdit
    }
    //todayDate = (new Date()).toISOString();
    minInsuranceDate;
    @track inputSearchParamater = {'Engine_Number__c':'','Chasis_Number__c':'' }
    @track dataObj = {};
    @track propertyDocListToBeDisplayed = [];
    @track responseWrap;
    @api scannedBarcode;
    @api recordId; //= 'a016s000003eUebAAE';
    @api objectApiName;
    @track deferralRegister = {};
    @track vahanData = {};

    @track statusValues = [ {'label': 'Completed','value': 'Completed'}];
    @track isReadOnlyDeferralCategory = false;
    @track renderDeferralCategory = false;
    @track isAssignmentObject = false;
    opsAssignmentId='';
    submitToOps = false;
    @track opsActionLoan='';
    @track remarksLoan=''
    @track rtoAgentInfo = {};
    nextLogo = AUSF_LOGOS + '/AUSF_LOGOS/logos/SFDC_Icons_Next.png';
    cancelLogo = AUSF_LOGOS + '/AUSF_LOGOS/logos/SFDC_Icons_Cancel.png';
    errorMessage = 'Please check all details before submit';
    // pdd Specific docs start
    @track invoiceDoc = {};
    @track insuranceDoc = {};
    @track taxDoc = {};
    @track rcDoc = {};

    // R2 changes
    @track collateralData = {};


    // Document Status Mandatory conditions
    invoiceStatusMandatory = true;
    insuranceStatusMandatory = true;
    taxStatusMandatory = false;
    rcSectionStatusMandatory = true;
    // Document Status Mandatory conditions

    // tractor changes

    
    
    @track rocChargeData = {};
    @track rocCreationStatusOptions = [];

    //5598 variables
    @track isVahaanRespSuccessful = false;

    get showVahanButton(){
        return this.dataObj.invoiceStatus == 'Completed' && this.dataObj.rCStatus != 'Completed';
    }

    get showSubmit(){
        return this.stage == 'Ops Maker' || this.stage == 'Ops Author' || this.stage == 'PDD';
    }
    // pdd Specific docs end

    get showRCSubStatus(){//R2-879
        if(this.dataObj.rCStatus!='Pending'){
            this.dataObj.subStatus=''
        }
        return ((this.stage == 'Ops Maker' || this.stage == 'Ops Author' || this.stage == 'PDD') && this.isOpsUser && this.dataObj.rCStatus=='Pending' && (this.loanRecType=='Commercial_Vehicle' || this.loanRecType=='Construction_Equipment'));
    }

    get subStatusValues(){//R2-879
        return this.picklistValues.subStatus;
    }

    get rcStatusValues(){
        if(this.dataObj && this.dataObj.caseDeferral == 'Yes' && this.dataObj.isUsedOrCOW){
            return [
                {'label': 'Completed','value': 'Completed'},
                {'label': 'Deferral','value': 'Deferral'}
            ]
        }else{
            return [
                {'label': 'Completed','value': 'Completed'},
                {'label': 'Pending','value': 'Pending'}
            ]
        }
    }

    get invoiceRequired(){
        return this.dataObj.invoiceStatus && this.dataObj.invoiceStatus == 'Completed';
    }
    get disableSubmit(){
        return !this.disableDuplicate && !this.dataObj.isUsedOrCOW;
    }

    get disableDuplicateCheckButton(){
        return !this.allowEdit || this.disableDuplicate || this.isOpsUser
    }



    // Tractor changes

    // Checking if it is implement
    get isImplement(){
        if(this.isTractorProduct){
            if(this.collateralData && this.collateralData.Collateral_Name__c && IMPLEMENT_PRODUCT_CODE){
                for(let i of IMPLEMENT_PRODUCT_CODE.split(',')){
                    if(this.collateralData.Collateral_Name__c === i.trim()){
                        return true;
                    }
                }
            }
        }

        return false;
    }
    // Checking if it is implement

    // Check condition for tractor
    get isTractorProduct(){
        if(this.dataObj && this.dataObj.productCode && TRACTOR_PRODUCT_CODES){
            for(let i of TRACTOR_PRODUCT_CODES.split(',')){
                if(this.dataObj.productCode === i.trim()){
                    return true;
                }
            }
        }
        return false;
    }
    // Check condition for tractor

   

    handleFormMandatoryForTractorCommercialConstruction(){
        if(this.isImplement){
            this.invoiceStatusMandatory = true;
            this.insuranceStatusMandatory = false;
            this.taxStatusMandatory = false;
            this.rcSectionStatusMandatory = false;
        }
        if(this.isCommercialBodyFunding){
            this.insuranceStatusMandatory = false;
        }
        if(this.isAttachmentCE){
            this.insuranceStatusMandatory = false;
        }
        
    }

    // Tractor changes

    // Construction equipment changes

     // Check condition for construction equipment
     get isConstructionEquipment(){
        if(this.dataObj && this.dataObj.productCode && CONSTRUCTION_EQUIPMENT_PRODUCT_CODES){
            for(let i of CONSTRUCTION_EQUIPMENT_PRODUCT_CODES.split(',')){
                if(this.dataObj.productCode === i.trim()){
                    return true;
                }
            }
        }
        return false;
    }
    
    // Check condition for construction equipment

    // Registrable of non registrable asset
    get isRegistrableAsset(){
        if(this.isConstructionEquipment){
            return this.collateralData.Registrable__c === REGISTRABLE_LITERAL;
        }
        return false;
    }
    get isNonRegistrableAsset(){
        if(this.isConstructionEquipment){
            return this.collateralData.Registrable__c === NON_REGISTRABLE_LITERAL;
        }
         return false;
    }
    // Registrable of non registrable asset

    // Check if it is attachment
    get isAttachmentCE(){
        if(this.isConstructionEquipment){
            return this.collateralData.Attachment__c === ATTACHMENT_LITERAL;
        }
         return false;
    }
    // Check if it is attachment

    // getter for used or cow
    get isUsedOrCOW(){
        return this.dataObj.isUsedOrCOW;
    }
    // getter for used or cow
    
    // Serial No Check
    get isSerialNoVisible(){
        const implementCondition = this.isImplement;
        const constructionEquipCondition = this.isNonRegistrableAsset && this.isConstructionEquipment;
        
        return (implementCondition || constructionEquipCondition);
    }
    // Serial No Check

    // Engine No check
    get isEngineNoVisible(){
        const implementCondition = this.isImplement;
        const constructionEquipCondition = this.isUsedOrCOW && this.isNonRegistrableAsset && this.isConstructionEquipment;

        return !(implementCondition || constructionEquipCondition);
    }
    // Engine No check

    // Financier Name and Original NOC Status visible
    get isNOCFinanceVisible(){
        return this.isNonRegistrableAsset && this.isUsedOrCOW && this.isConstructionEquipment;
    }

    // Invoice section visible for CE
    get isInvoiceSectionVisible(){
        if(this.isConstructionEquipment && this.isUsedOrCOW && this.isNonRegistrableAsset){
            return true;
        }
        return !this.dataObj.isUsedOrCOW;
    }
    // Invoice section visible for CE

    // Construction equipment changes

    // Commercial Changes
    get isCommercialProduct(){
        if(this.dataObj && this.dataObj.productCode && COMMERCIAL_PRODUCT_CODE){
            for(let i of COMMERCIAL_PRODUCT_CODE.split(',')){
                if(this.dataObj.productCode === i.trim()){
                    return true;
                }
            }
        }
        return false;
    }

    get isCommercialBodyFunding(){
        if(this.isCommercialProduct){
            if(this.collateralData && this.collateralData.Collateral_Name__c && COMMERCIAL_BODY_FUNDING_CODE){
                for(let i of COMMERCIAL_BODY_FUNDING_CODE.split(',')){
                    if(this.collateralData.Collateral_Name__c === i.trim()){
                        return true;
                    }
                }
            }
        }
        return false;
    }
    // Commercial Changes

    get isNotTractorCommercialConstructionEquipment(){
        return !this.isTractorProduct && !this.isCommercialProduct;
    }

    get DocumentInfoOptions(){
        return [
            {'label': 'Received','value': 'Received'},
            {'label': 'Not Received','value': 'Not Received'},
        ]
    }

    get OpsActionOptions(){
        return [
            {'label': 'Ok','value': 'Ok'},
            {'label': 'Not Ok','value': 'Not Ok'},
        ]
    }
    
    get opsPDDActionOptions(){
        return [
            {'label': 'Rework','value': 'Rework'},
            {'label': 'Approve','value': 'Approve'},
        ]
    }

    get documentHandoverToOptions(){
        return [
            {'label': 'BM', 'value': 'BM'},
            {'label': 'COM', 'value': 'Com'},
            {'label': 'Credit', 'value': 'Credit'},
            {'label': 'RTO agent', 'value': 'RTO agent'}
        ]
    }

    get hideInvoiceSection(){
        //return this.isOpsUser && (this.dataObj.invoiceStatus != 'Completed' || !this.invoiceDoc.isUploded)
        return false;
    }

    get hideInsuranceSection(){
        //return this.isOpsUser && (this.dataObj.insuranceStatus != 'Completed' || !this.insuranceDoc.isUploded)
        return false
    }
    get hideTaxSection(){
        //return this.isOpsUser && (this.dataObj.taxReceiptStatus != 'Received' || !this.taxDoc.isUploded)
        if(this.isConstructionEquipment && this.isNonRegistrableAsset){ // Construction equipment non registrable hide tax section
            return true;
        }
        if(this.isCommercialBodyFunding) return true; // Commercial Body funding changes
        return false;
    }
    get hideRCSection(){
    //return this.isOpsUser && (this.dataObj.rCStatus != 'Completed' || !this.rcDoc.isUploded)
if(this.isCommercialBodyFunding) return true; // Commercial Body funding changes
      return false;
    }

    get YesNoOptions(){
        return [
            {'label': 'Yes', 'value': 'Yes'},
            {'label': 'No', 'value': 'No'}
        ]
    }

    get taxRequired(){
        return this.dataObj.taxReceiptStatus == 'Received';
    }

    get disableInvoice(){
        return (this.invoiceDoc && this.invoiceDoc.opsAction == 'Ok' && this.dataObj.invoiceStatus == 'Completed' && !this.isOpsUser) || !this.allowEdit
    }

    get disableInsurance(){
        return (this.insuranceDoc && this.insuranceDoc.opsAction == 'Ok' &&  this.dataObj.insuranceStatus == 'Completed' && !this.isOpsUser)  || !this.allowEdit
    }

    get disableTax(){ 
        return (this.taxDoc && this.taxDoc.opsAction == 'Ok' &&  this.dataObj.taxReceiptStatus == 'Received' && !this.isOpsUser)  || !this.allowEdit
    }

    get disableRC(){
        return (this.rcDoc && this.rcDoc.opsAction == 'Ok' &&  this.dataObj.rCStatus == 'Completed' &&  !this.isOpsUser)  || !this.allowEdit
    }

    get disableDeferral(){
        return  !this.allowEdit
    }

    get requiredInsuranceRC(){
       // return this.dataObj && this.dataObj.caseDeferral == 'No'
       if(this.dataObj){
        if(this.isImplement){// Tractor Changes
            return this.dataObj.insuranceStatus == 'Completed';
        }
        else if(this.isCommercialBodyFunding){// Commercial Changes
            return this.dataObj.insuranceStatus == 'Completed';
        }
        else if(this.isAttachmentCE){
            return false;
        }
        else{
            return  (this.dataObj.isUsedOrCOW || this.dataObj.insuranceStatus == 'Completed')
        }
   }
   return false;
    }

    get requiredInsuranceFields(){
        return this.dataObj && (this.dataObj.isUsedOrCOW  || this.dataObj.insuranceStatus == 'Completed')
    }

    get requiredRCFields(){
        if(this.dataObj){ 
            if(this.isImplement){ // Tractor Changes
                return  this.dataObj.rCStatus == 'Completed';
            }
            else{
                return  (this.dataObj.isUsedOrCOW || this.dataObj.rCStatus == 'Completed')
            }
       }
       return false;
    }

    get requiredVahaanFields(){
        return this.showModifyCollateral == true || this.taxRequired;
    }

    get requiredVahaanFields2(){
        return this.showModifyCollateral == true || this.requiredRCFields;
    }

    get disableRegisterNumber(){
        return this.disableRC || this.profileName == 'Sales' || this.profileName == 'COM';
    }
   

    get StatusOptions(){
        return [
            {'label': 'LOV - RTO not working', 'value': 'LOV - RTO not working'},
            {'label': 'RTO query', 'value': 'RTO query'},
            {'label': 'Seller not available', 'value': 'Seller not available'},
            {'label': 'Seller KYC', 'value': 'Seller KYC'}
        ]
    }

    get showDeferralSection(){
if(this.isImplement || this.isCommercialBodyFunding || this.isAttachmentCE)  return false;
        return this.dataObj && this.dataObj.caseDeferral == 'Yes' && this.dataObj.isUsedOrCOW
    }

    get showAdditionalDocuments(){
        return this.dataObj.isUsedOrCOW && this.dataObj.caseDeferral == 'Yes';
    }

    get highlightEngine(){
        return this.dataObj.updatedEngine ? 'highlight-field' : '';
    }

    get highlightChasis(){
        return this.dataObj.updatedChasis ? 'highlight-field' : '';
    }

    // SFAU-5548 - Deferral Mandatory
    get isDeferralMandatory(){
        return this.dataObj.rCStatus == 'Deferral'
    }

    //SFAU-5835
    get isManualRC(){
        return this.dataObj.rcType == 'Manual RC';
    }

    //SFAU-5835
    get disableVahaanRC(){
        return this.disableRC || (this.dataObj.rcType == 'Automated FOP' && this.profileName == 'Sales');
    }

    //SFAU-5835
    getVahanReport(){   
       createVahanReport({loanId:this.recordId})
       .then(data=>{
            this.updateReportOnRc(); 
        })
        .catch(error => {
            this.isloading = false;
            console.log('error is '+JSON.stringify(error));
        
        })
    }       

    updateReportOnRc(){
        updateReportOnRc({loanId:this.recordId})
       .then(data=>{
           if(data){
            this.getUpdatedDocChecklist();
           }
           this.isloading = false;
        })
        .catch(error => {
            this.isloading = false;
            console.log('error is '+JSON.stringify(error));
        
        })
    }

    

    @wire(getRecord, {
        recordId: "$recordId",
        fields
    })
    wiredRecord({ error, data }) {
        if (data) {
            this.loanApplicantionRecord = data;
            this.opsActionLoan = getFieldValue(this.loanApplicantionRecord,OPS_PDD_Action);
            this.remarksLoan = getFieldValue(this.loanApplicantionRecord,OPS_PDD_Remark);
        }
        else if(error){
            console.log('error '+JSON.stringify(error));
        }
    }

    isCollateralModified = false;

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

    loadStyles() {
        loadStyle(this, opsAccordion);
    }

    // NOTE : Renderedcallback() only works for child components to parent DOM
    renderedCallback(){
        console.log('inside renderCallback');
        this.loadStyles();
        this.setFormFactor();
    }

    connectedCallback(){
        //this.setFormFactor();
        if(this.objectApiName=='Assignment__c'){
            this.isAssignmentObject = true;
            this.opsAssignmentId = this.recordId;
            getRecordInfo({
                id : this.opsAssignmentId
            })
            .then(data=>{
                this.recordId = data;
                this.getROCChargesData()//New Method added to not break existing functionality
            })
            .catch(error =>{
                console.log('error '+JSON.stringify(error));
            })
        }
        this.getData();
        
    }

    /*ROC Chrges Code STart************/

    getROCChargesData(){
        /*
        getROCChargesData({
            loanId : this.recordId
        })
        .then(res=>{
            if(res.hasOwnProperty('applicationrecord')){
                this.rocChargeData = res.applicationrecord;
            }
            if(res.hasOwnProperty('rocCreationStatusOptions')){
                let creationStatusOptions = [];
                let options = res.rocCreationStatusOptions;
                options.forEach(data=>{
                    creationStatusOptions.push(data);
                })
                this.rocCreationStatusOptions = creationStatusOptions;
            }
            this.isROCEditable = res.isEditable;
        })
        .catch(err=>{
            console.log('error in ROC Charge Data '+JSON.stringify(e));
            this.isloading = false;
        })
        */
    }

    handleROCChange(evt){
       this.rocChargeData[evt.currentTarget.dataset.id] = evt.detail.value;
    }


    /********************************** */

    handleCancel(){
        this.getData();
    }

    handleSendOTP() {
        this.boolRequestOtp = true;
        this.boolSendOtp = false;
        this.isEnterOtp = true;
         this.set27SecondTimer();
         this.mobileNotificationHandler();
    }

    set27SecondTimer() {
        this.isInTimeInterval = true;
        this.increse1Second = OtpDurationLabel;
        const secondTimeInterval = setInterval(() => {
            this.increse1Second -= 1;
        }, 1000);
        setTimeout(() => {
            if (this.isInTimeInterval) {
                this.boolSendOtp = true;
            }
            window.clearInterval(secondTimeInterval);

        }, OtpDurationLabel * 1000);
    }


    mobileNotificationHandler(){
        sendNotification({notificationName : 'RTO Agent Trigger',loanApplicationId: this.recordId , phoneNo: this.deferralRegister.rtoAgentNumber})
        .then((result) => {
           console.log('sms send');
           this.boolResendOtp = false;
        })
        .catch((error) => {
            console.log('error-->' + JSON.stringify(error));
            this.isloading = false;
        })
        .finally(() => {                
           
        })
    }

    get hideVahaanCheck(){
        return this.isOpsUser && this.dataObj.invoiceStatus == 'Completed' && this.dataObj.rCStatus == 'Completed'
    }

    get showCancel(){
        return this.isOpsUser;
    }

    accountRoleData={};
    applicant={};
    profileName='';
    allowEdit;
    stage='';
    getData(){
        this.isloading = true;
        getData({loanAppId : this.recordId})
            .then((result) => {
                this.collateralData = result.collateralData;
                this.picklistValues = result.picklistValues;
                this.dataObj = JSON.parse(result.wrapper);
                this.checkErrorOnInvoice();
                this.accountRoleData = JSON.parse(JSON.stringify(result.AccountTeamMember));
                this.deferralRegister =this.dataObj.deferralRegister;
                this.vahanData = this.dataObj.vahanData;
                this.stage = result.stage;
                this.isOpsUser = result.isOpsUser;
                this.allowEdit = result.allowEdit || this.objectApiName=='Assignment__c';
                this.isNotOpsUser = !this.isOpsUser;
                this.profileName = result.profileName;
                this.rtoAgentInfo = result.rtoAgentInfo;
                this.minInsuranceDate = (new Date(result.minInsuranceEndDate)).toISOString();
                this.applicant = result.applicant;
                this.loanRecType = result.loanRecordType
                if(this.rtoAgentInfo && this.deferralRegister.documentHandoverto == 'RTO agent'){
                    this.deferralRegister.rtoAgentName = this.rtoAgentInfo.Name;
                    this.deferralRegister.rtoAgentNumber = this.rtoAgentInfo.MobilePhone;
                    this.deferralRegister.rtoAgentID = this.rtoAgentInfo.Agent_Code__c;
                }
               /* this.deferralRegister.rtoAgentName = this.deferralRegister.documentHandoverto == 'RTO agent' ?  this.rtoAgentInfo.Name : this.deferralRegister.rtoAgentName;
                this.deferralRegister.rtoAgentNumber = this.deferralRegister.documentHandoverto == 'RTO agent' ? this.rtoAgentInfo.MobilePhone: this.deferralRegister.rtoAgentName;
                this.deferralRegister.rtoAgentID = this.deferralRegister.documentHandoverto == 'RTO agent' ? this.rtoAgentInfo.Agent_Code__c: this.deferralRegister.rtoAgentName; */
                let obj = {};
                if(this.dataObj.isUsedOrCOW){
                    obj.label = 'Deferral';
                    obj.value = 'Deferral';
                    this.statusValues.push(obj);
                }else{
                    obj.label = 'Pending';
                    obj.value = 'Pending';
                    this.statusValues.push(obj);
                }
                //  console.log('this.accountRoleData -- > ' + this.accountRoleData.Com.TeamMemberRole);
                // let parseResult=JSON.parse(result.documentChecklist);
                // if(parseResult.isSuccess && parseResult.docChkRecords){
                //     this.propertyDocListToBeDisplayed = [];
                //     setTimeout(() => {
                //         this.propertyDocListToBeDisplayed = parseResult.docChkRecords;
                //         this.responseWrap = parseResult.reponseWrapper;
                //         console.log('this.responseWrap&&'+JSON.stringify(this.responseWrap));
                //    }, 100); 
                // }else{
                //     console.log('No result found.');
                //     console.log('Error message'+parseResult.message);
                // }
                this.setDocWrapper(result.documentChecklist);
                this.setDealerCategoryPicklist();
                // Tractor Changes
                this.handleFormMandatoryForTractorCommercialConstruction();
                // Tractor Changes
                this.isloading = false;
            })
            .catch((error) => {
                console.log('error-->' + JSON.stringify(error));
                this.isloading = false;
            })
            .finally(() => {                
               
            })
    }


    checkErrorOnInvoice(){
        if(this.dataObj && this.dataObj.invoiceAmount && this.dataObj.exShowRoomPrice){
            let difference = Math.abs( parseInt(this.dataObj.invoiceAmount) - this.dataObj.exShowRoomPrice);
            let twoPercentOfExShowroom = (this.dataObj.exShowRoomPrice * 2) / 100;
            let maxDifference = Math.min(twoPercentOfExShowroom,10000);
            if(difference > maxDifference){
                this.dataObj['deviationNeeded'] = true;
                this.dataObj['deviationAmount'] = difference;
            }else{
                this.dataObj['deviationNeeded'] = false;
            }
        }else{
            this.dataObj['deviationNeeded'] = false;
        }
    }

    setDocWrapper(documentChecklist){
        let parseResult=JSON.parse(documentChecklist);
        if(parseResult.isSuccess){
            this.propertyDocListToBeDisplayed = [];
            setTimeout(() => {
                this.propertyDocListToBeDisplayed = parseResult.docChkRecords ?  parseResult.docChkRecords : this.propertyDocListToBeDisplayed;
                this.invoiceDoc = parseResult.invoiceChecklistRecord;
                this.insuranceDoc = parseResult.insuranceChecklistRecord;
                this.taxDoc = parseResult.taxChecklistRecord;
                this.rcDoc = parseResult.rcChecklistRecord;
                this.responseWrap = parseResult.reponseWrapper;
                this.showPage = true;
           }, 100); 
        }else{
            this.showPage = true;
            console.log('No result found.');
            console.log('Error message'+parseResult.message);
        }
    }

    setDealerCategoryPicklist() {
        getDealerRCDetails({
            loanId : this.recordId
        })
        .then(res=>{
            if(this.dataObj.caseDeferral == 'Yes' && this.dataObj.isUsedOrCOW){
                this.renderDeferralCategory = true;
                if(!res){
                    this.picklistValues.deferralCategory = [];
                    this.picklistValues.deferralCategory.push({
                        label:'Branch Deferral',
                        value:'Branch Deferral'
                    })
                    this.isReadOnlyDeferralCategory = true;
                    this.dataObj.deferralCategory = 'Branch Deferral';
                }
            }
            
        })
        .catch(err=>{
            console.log('err '+JSON.stringify(err))
            this.showToastMessage('error',err.message || err.body.message)
        })
    }

    handleBeginClickNew(event) {
        const instanceBarcodeScanner = getBarcodeScanner();
        if (instanceBarcodeScanner.isAvailable()) {
            instanceBarcodeScanner.beginCapture({
                    barcodeTypes: [instanceBarcodeScanner.barcodeTypes.CODE_128,
                        instanceBarcodeScanner.barcodeTypes.CODE_39,
                        instanceBarcodeScanner.barcodeTypes.CODE_93,
                        instanceBarcodeScanner.barcodeTypes.DATA_MATRIX,
                        instanceBarcodeScanner.barcodeTypes.EAN_13,
                        instanceBarcodeScanner.barcodeTypes.EAN_8,
                        instanceBarcodeScanner.barcodeTypes.ITF,
                        instanceBarcodeScanner.barcodeTypes.UPC_E,
                        instanceBarcodeScanner.barcodeTypes.PDF_417,
                        instanceBarcodeScanner.barcodeTypes.UPC_A,
                        instanceBarcodeScanner.barcodeTypes.QR
                    ]
            }).then((result) => {
            
                 this.scannedBarcode =  result.value ;
                 let obj = this.scannedBarcode.split(',');
                 let obj2 = {};
                 obj.forEach(element => {
                     let ele =element.split(':');
                         obj2[ele[0].trim()] = ele[1].trim();
                 });

                this.dataObj.originalRCValue =  JSON.stringify(obj2);
                this.dataObj.registrationNumber = obj2['Registration No'];
                this.dataObj.registrationDate = obj2['Registration Date'];
                this.dataObj.engineNo = obj2['Engine No'];
if(this.isImplement){ // For Tractor Implement
                    const chassisNoLabel = obj2['Chassis No'];
                    const serialNoLabel = obj2['Serial No'];
                    if(chassisNoLabel){
                        this.dataObj.serialNoImplement = chassisNoLabel;
                    }
                    if(serialNoLabel){
                        this.dataObj.serialNoImplement = serialNoLabel;
                    }
                }
                else{
                this.dataObj.chasisNumber = obj2['Chassis No'];
                }
                

                this.template.querySelector(".registrationNumber").value = this.dataObj.registrationNumber;
                this.template.querySelector(".registrationDate").value = this.dataObj.registrationDate;
                this.template.querySelector(".engineNo").value = this.dataObj.engineNo;
if(this.isImplement){// For Tractor Implement
                    this.template.querySelector(".serialNoImplement").value = this.dataObj.serialNoImplement;
                }
                else{
                    this.template.querySelector(".chasisNumber").value = this.dataObj.chasisNumber;
                }

                instanceBarcodeScanner.endCapture();
            }).catch(error => {
                this.showToastMessage('error',error.message || error.body.message);
            });
        }
    }

    validatePhoneNumber(input_str) {
        var re = /^[6-9]{1}[0-9]{9}/;
        console.log('Valid Phone Number', re.test(input_str));
        return re.test(input_str);
    }

    handleInputVahaan(event){
        this.vahanData[event.target.name] = event.target.value;
    }


    handleInput(event){

                    if(!this.dataObj.isUsedOrCOW && event.target.name == 'rCStatus' && event.target.value == 'Completed'){
                        if(this.dataObj.invoiceStatus == 'Completed'){
                            this.dataObj.rCStatus = event.target.value;
                        }else{
                            this.dataObj.rCStatus = this.dataObj.rCStatus;
                            let element = this.template.querySelector('.rcStatus');
                            if(element){
                                element.value = this.dataObj.rCStatus;
                            }
                            this.showToastMessage('error', 'Please update invoice status to complete first.');
                        }
                    }else if(event.target.name == 'rCStatus'){
                        this.dataObj[event.target.name] = event.target.value.trim();
                    }else if(event.target.name == 'invoiceAmount'){ 
                        this.dataObj.invoiceAmount = event.target.value;
                        this.checkErrorOnInvoice();
                    }else if(event.target.name == 'insuranceStartDate'){
                        this.dataObj[event.target.name] = event.target.value.trim();
                        let endDate = new Date(event.target.value)
                        this.dataObj.insuranceEndDate = (new Date(endDate.setMonth(endDate.getMonth() + 12))).toISOString();
                    }else{
                        this.dataObj[event.target.name] = event.target.value.trim();
                        if(this.inputSearchParamater[event.target.dataset.api] !== undefined){
                            this.inputSearchParamater[event.target.dataset.api] = event.target.value;
                            this.disableDuplicate = false;
                        }
                        if(event.target.name == 'vehicleDelivery' && event.target.value == 'Yes'){
                            this.showToastMessage('info', 'Update Engine and Chassis Number (Not mandatory)');
                        }
                    }
    }

    handleDeferralRegister(event){
        this.deferralRegister[event.target.name] = event.target.value;
        if (event.target.name == 'rtoAgentNumber' && event.target.value.length == 10 && this.validatePhoneNumber(event.target.value) && this.deferralRegister.recordId) {
            this.boolCheckMobileNumber = false;
        }else if(event.target.name == 'documentHandoverto' && event.target.value != 'RTO agent'){
            this.deferralRegister.rtoAgentName = this.accountRoleData[event.target.value] != undefined ? this.accountRoleData[event.target.value].User.Name : '';
            this.deferralRegister.rtoAgentNumber = this.accountRoleData[event.target.value] != undefined ? this.accountRoleData[event.target.value].User.MobilePhone : '';
            this.deferralRegister.rtoAgentID = this.accountRoleData[event.target.value] != undefined ? this.accountRoleData[event.target.value].Employee_Code__c : '';
            
        }else if(event.target.name == 'documentHandoverto' && event.target.value === 'RTO agent'){
            this.deferralRegister.rtoAgentName = this.rtoAgentInfo != undefined ? this.rtoAgentInfo.Name : "";
            this.deferralRegister.rtoAgentNumber = this.rtoAgentInfo != undefined ? this.rtoAgentInfo.MobilePhone : "";
            this.deferralRegister.rtoAgentID =  this.rtoAgentInfo != undefined ?  this.rtoAgentInfo.Agent_Code__c : "";
            if(this.deferralRegister.rtoAgentNumber && this.deferralRegister.rtoAgentNumber.length == 10 && this.validatePhoneNumber(this.deferralRegister.rtoAgentNumber) && this.deferralRegister.recordId){
                this.boolCheckMobileNumber = false;
            }else{
                this.boolCheckMobileNumber = true;
            }
            
        }else if(event.target.name === 'confirmationRecieved'){
            this.dataObj.confirmationRecievedDate = event.target.value == 'Yes' ? new Date().toISOString().substring(0, 10) : undefined;
        }
        else if(event.target.name == 'rtoAgentID' && event.target.value && event.target.value.length > 2){
            this.fetchAgentId(event.target.value);
        }
    }

    fetchAgentId(agenId){
        this.isloading = true;
        getAgentInfobyId({
            loanId : this.recordId, agentId: agenId
        }).then(data => {
            if(data){
                this.deferralRegister.rtoAgentName = data != undefined ? data.Name : this.deferralRegister.rtoAgentName;
                this.deferralRegister.rtoAgentNumber =  data != undefined ? data.MobilePhone : this.deferralRegister.rtoAgentNumber;

            }
            this.isloading = false;
        }).catch(error => {
            console.log('error is '+JSON.stringify(error));
            this.isloading = false;
            this.searchData='';
		})
    }

    validateEngineChasis(){
        if(this.isImplement){ // For Tractor Implement
            if( this.dataObj.serialNoImplement == null || this.dataObj.serialNoImplement.length < 0){
                return false;
            }else{
                return true;
            }
        }
        else{
            if( this.dataObj.engineNo == null || this.dataObj.engineNo.length < 13  || this.dataObj.chasisNumber == null || this.dataObj.chasisNumber.length < 13){
                return false;
            }else{
                return true;
            }
        }
        
    }

   

    getCollateralList(){
        if(!this.validateEngineChasis()){
            this.showToastMessage('error','Please enter valid Engine & Chassis Number.');
            return;
        }
        this.isloading = true;
        if(this.isImplement){
            this.inputSearchParamater['Chasis_Number__c'] = this.dataObj.serialNoImplement;
        }
        
        getCollateralList({obj: this.inputSearchParamater,loanAppId:this.recordId })
		.then(data => {
                if(data.responseMessage ==='Success'){
                    this.isloading = false; 
                     if(data.collaterals.length == 0){
                        this.disableDuplicate = true;
                     }else{
                        this.showToastMessage('error','This record already exists in system. please add new record.');
                     }
                }else if(data.responseMessage==='Failure'){

                    // this.showErrorMessage=true;
                    // this.searchData ='';
                    // this.errorMessage = data.message;
                     this.isloading = false;
                     this.disableDuplicate = true;
                     this.showToastMessage('Success','No Duplicate Record exist');
                    }
                
            
		})
		.catch(error => {
            console.log('error is '+JSON.stringify(error));
            this.isloading = false;
            this.searchData='';
		})
    }

    

    isValid(){ 
        this.errorMessage = 'Please check all details before submit';
        let isValidAll = [
            ...this.template.querySelectorAll("lightning-combobox"),
            ...this.template.querySelectorAll("lightning-input"),
            ...this.template.querySelectorAll("lightning-textarea")
        ].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);

        if(this.dataObj.invoiceStatus == 'Completed' && !this.invoiceDoc.isUploded){
            isValidAll = false;
            this.errorMessage = 'Invoice Document is Mandatory if invoice status is completed';
            return isValidAll;
        }
        if(this.dataObj.insuranceStatus == 'Completed' && !this.insuranceDoc.isUploded){
            this.errorMessage = 'Insurance Document is Mandatory if insurance status is completed';
            isValidAll = false;
            return isValidAll;
        }

        if(this.dataObj.rCStatus == 'Completed' && this.dataObj.invoiceStatus != 'Completed' && !this.dataObj.isUsedOrCOW){
            this.errorMessage = 'Please update invoice status to complete first.';
            isValidAll = false;
            return isValidAll;
        }
        
        if(this.dataObj.rCStatus == 'Completed'  &&  !this.rcDoc.isUploded && !this.isVahaanRespSuccessful){// If vahaan Response is successful to By Pass the Document Upload 5598
            this.errorMessage = 'RC Document is Mandatory if rc status is completed';
            isValidAll = false;
            return isValidAll;
        }
        
        //SFAU-5548
        if(this.isDeferralMandatory && this.propertyDocListToBeDisplayed && this.propertyDocListToBeDisplayed.length > 0){
            this.propertyDocListToBeDisplayed.forEach(element => {
              if(!element.isUploded){
                this.errorMessage = 'Please upload all deferral documents.';
                isValidAll = false;
                return isValidAll;
              }
          });
        }



        return isValidAll;
    }

    get showModifyCollateral(){
        return this.isOpsUser && this.opsActionLoan == 'Approve' && this.dataObj.isUsedOrCOW && this.dataObj.assignmentCase == 'Yes';
    }

     // Tractor Changes
     IsDocumentUploadedCheckedByOps(){
        if(this.dataObj.insuranceStatus == 'Completed'){
            if(this.insuranceDoc.opsAction !== 'Ok'){
                return false;
            }
        }
        if(this.dataObj.rCStatus == 'Completed'){
            if(this.rcDoc.opsAction !== 'Ok'){
                return false;
            }
        }
        if(this.dataObj.taxReceiptStatus == 'Completed'){
            if(this.taxDoc.opsAction !== 'Ok'){
                return false;
            }
        }
        if(this.dataObj.invoiceStatus == 'Completed'){
            if(this.invoiceDoc.opsAction !== 'Ok'){
                return false;
            }
        }

        return true;
    }
    // Tractor Changes

    get canApprovePDD(){
        if(this.dataObj.isUsedOrCOW){
        if(this.isImplement || this.isCommercialBodyFunding){// Tractor Implement and commercial body changes, only invoice is mandatory
                return this.IsDocumentUploadedCheckedByOps();
                
            }
            if(this.isTractorProduct || this.isCommercialProduct){// Tractor and Commercial product changes to check if any document is uploaded then Ops to check
                if(!this.IsDocumentUploadedCheckedByOps()){
                    return false;
                }
            }
            return (this.insuranceDoc.opsAction == 'Ok' && this.dataObj.insuranceStatus == 'Completed') && (this.rcDoc.opsAction == 'Ok' && this.dataObj.rCStatus == 'Completed') 
        }else{
            if(this.isImplement || this.isCommercialBodyFunding){// Tractor Implement and commercial body changes, only invoice is mandatory
                if(!this.IsDocumentUploadedCheckedByOps()){
                    return false;
                }
                return (this.invoiceDoc.opsAction == 'Ok' && this.dataObj.invoiceStatus == 'Completed');
            }
            if(this.isTractorProduct || this.isCommercialProduct){// Tractor and Commercial product changes to check if any document is uploaded then Ops to check
                if(!this.IsDocumentUploadedCheckedByOps()){
                    return false;
                }
            }
            return (this.invoiceDoc.opsAction == 'Ok' && this.dataObj.invoiceStatus == 'Completed') && (this.insuranceDoc.opsAction == 'Ok' && this.dataObj.insuranceStatus == 'Completed') && (this.rcDoc.opsAction == 'Ok' && this.dataObj.rCStatus == 'Completed');
        }
    }

    get disableButtons(){
        return !this.allowEdit
    }


    handleSubmit(doSubmit){
        this.showPopup = false;
        restricAccess({
            compName: 'losPDDMaker' ,loanId: this.recordId
            }).then(data => {
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save PDD Makers',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }else{
                    this.dataObj.loanAppId = this.recordId;
                    let opsPDDAction='';
                    let opsPDDRemark = '';
                    if(this.isValid()){
                        if(this.disableSubmit && !this.hideInvoiceSection && !this.disableDuplicateCheckButton && this.dataObj.invoiceStatus == 'Completed'){
                            this.showToastMessage('Warning', 'Please check duplicate records in invoice section.');
                            return;
                        }
                
                        if(this.isOpsUser && !this.canApprovePDD && this.opsActionLoan == 'Approve' && doSubmit){
                            this.showToastMessage('Warning', 'Please verify all documents before approving');
                            return;
                        }

                        // Invoice amt vs Loan Amount validity check
                        if(this.isTractorProduct && this.isInvoiceSectionVisible && this.dataObj.invoiceAmount && this.collateralData.Loan__r.Total_Loan_Amount__c){

                            if(parseFloat(this.dataObj.invoiceAmount) < parseFloat(this.collateralData.Loan__r.Total_Loan_Amount__c)){
                                showToastMessage(this, 'Error!', 'error', PDD_MAKER_TRACKER_INVOICE_AMOUNT_VALIDATION, 'sticky');
                                return;
                            }
                        }
                        // Invoice amt vs Loan Amount validity check
                
                        if(this.isAssignmentObject && this.isOpsUser && doSubmit){
                            console.log('in true');
                            opsPDDAction = this.template.querySelector('[data-id="action"]').value;
                            opsPDDRemark = this.template.querySelector('[data-id="remark"]').value;
                            this.saveOpsDetailsOnLoan(opsPDDAction,opsPDDRemark);
            
                        }else{
                            this.saveData(doSubmit);
                        }
                    }else{
                        this.showToastMessage('Error', this.errorMessage);
                    }
                }
            }).catch(error => {
                console.log('error is ' + JSON.stringify(error));
            })
    }

    handleOpsAction(event){
        if(event.target.name == 'OPS_PDD_Remark__c'){
            this.remarksLoan = event.target.value;
        }else if(event.target.name == 'OPS_PDD_Action__c'){
            this.opsActionLoan = event.target.value;
        }
    }

    saveData(doSubmit){
        this.isloading = true;
        if(this.invoiceDoc){
            this.propertyDocListToBeDisplayed.push(this.invoiceDoc);
        }
        if(this.insuranceDoc){
            this.propertyDocListToBeDisplayed.push(this.insuranceDoc);
        }
        if(this.taxDoc){
            this.propertyDocListToBeDisplayed.push(this.taxDoc);
        }
        if(this.rcDoc){
            this.propertyDocListToBeDisplayed.push(this.rcDoc);
        }
        let opsPDDAction;
        if(this.template.querySelector('[data-id="action"]')){
            let opsPDDAction = this.template.querySelector('[data-id="action"]').value;
            if(opsPDDAction == 'Rework'){
                this.propertyDocListToBeDisplayed.forEach(element => {
                    element.opsAction = element.opsAction == 'Not Ok' ? undefined : element.opsAction;
                });
            }
            
        }
        this.dataObj.docChkRecords = this.propertyDocListToBeDisplayed;
        this.dataObj.deferralRegister = this.deferralRegister;
        this.dataObj.vahanData = this.vahanData;
            saveRecord({jsonString:JSON.stringify(this.dataObj),objectName:this.objectApiName})
            .then((result) => {
                if(result && result.status == 'success'){
                    if(doSubmit){
                        this.resubmitToOps();
                    }else{
                        this.submitToOps = true;
                        this.showToastMessage('Success','Date Saved Successfully');
                        this.getData();
                    }
                }else{
                    this.isloading = false;
                }
            })
            .catch((error) => {
                this.showToastEvent('Error',error.message || error.body.message,'error', 'sticky')
                this.isloading = false;

            })
            .finally(() => {                

            })
    }

    showToastMessage(variantVal,messageVal){
        const event = new ShowToastEvent({
            title: variantVal,
            message: messageVal,
            variant: variantVal
        });
        this.dispatchEvent(event);
    }

    handleInputDoc(event){
        let index = event.target.dataset.index;
        this.propertyDocListToBeDisplayed[index][event.target.name] = event.target.value;
    }

    handleOpsDetails(event){
        if(event.target.name == 'opsActionInvoice'){
            this.invoiceDoc.opsAction = event.target.value;
        }else if(event.target.name == 'opsRemarkInvoice'){
            this.invoiceDoc.opsRemark = event.target.value;
        }else if(event.target.name == 'opsActionInsurance'){
            this.insuranceDoc.opsAction = event.target.value;
        }else if(event.target.name == 'opsRemarkInsurance'){
            this.insuranceDoc.opsRemark = event.target.value;
        }else if(event.target.name == 'opsActionTax'){
            this.taxDoc.opsAction = event.target.value;
        }else if(event.target.name == 'opsRemarkTax'){
            this.taxDoc.opsRemark = event.target.value;
        }else if(event.target.name == 'opsActionRC'){
            this.rcDoc.opsAction = event.target.value;
        }else if(event.target.name == 'opsRemarkRC'){
            this.rcDoc.opsRemark = event.target.value;
        }
    }

    @api 
    nextHandler() {       
         let Obj = {};
             Obj.next = true;
         this.errorOnChild = '';
         Obj.errorOnChild = this.errorOnChild;
         this.dispatchEvent(new CustomEvent('next', {
             detail: Obj
         }));
     }

     saveOpsDetailsOnLoan(opsAction,opsRemark){
            saveOpsDetailsOnLoan({
                loanId: this.recordId,
                opsAction: opsAction,
                opsRemark: opsRemark,
                opsAssignmentId : this.opsAssignmentId
            })
            .then(data=>{
                this.saveData();
    
            })
            .catch(error=> {
                console.log('error '+JSON.stringify(error));
            }) 
     }

     resubmitToOps(){
        reSubmitRecord({
            loanId: this.recordId,
            assignmentId: this.opsAssignmentId
        })
        .then(data =>{
            if(data!=null && data.includes('successfully')){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Data Submitted to Ops Successfully.',
                        variant: 'success'
                    })
                ); 
                this.getData();
            }
        })
        .catch(error =>{
            console.log('error '+JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Something went wrong',
                    variant: 'error'
                })
            );
        })
     }

     handleReSubmit(){
       if(this.isValid()){
        this.handleSubmit(true);
     }else{
        this.showToastMessage('Error', this.errorMessage);
    }
    }

    handleSuccess(event){
        //this.showUploadComponent = false;
        if(event.detail.isSuccess && event.detail.showOCRInParent){
            this.dataValues = event.detail.ocrData;
            this.applicantRec = event.detail.applicantRec;
            this.documentChkRecord = event.detail.documentChkRecord;
            this.documentNumber = event.detail.documentNumber;
            this.isAadhar = event.detail.isAadhar;
            this.contentVersionId = event.detail.contentVersionId;
            this.eventdocName = event.detail.docName;
            this.showOCRDetails = true;
        }else if(event.detail.isSuccess){
           this.getUpdatedDocChecklist();
            
        }else{
            this.showToastEvent('Error', event.detail.errorMessage, 'error');
        }
    
    }

    getUpdatedDocChecklist(){
        this.isloadingTable = true;
        this.isloading = true;
        getDocumentChecklist({ recorIdStr : this.recordId,
            objectApiName: 'pddMaker'})
        .then((result) => {
            this.setDocWrapper(result);
            this.isloadingTable = false;
            this.isloading = false;
        }
        )
        .catch(error => {
            this.error = error;
            this.isloading = false;
            this.isloadingTable = false;
        });
    }

    handleClickDelete(event){
        let id = event.currentTarget.name;
        this.isloadingTable = true;
        deactivateDocument({ recordId : id})
        .then((result) => {
            let parseResult=JSON.parse(result);
            if(parseResult.isSuccess ){
                this.getUpdatedDocChecklist();
                this.showToastEvent('Success', 'File Deleted Successfully', 'success');
            }else{
                this.showToastEvent('Error','Something went wrong!', 'error');
                this.isloadingTable = false;
                console.log('No result found.');
                console.log('Error message'+parseResult.message);
            }
        }
        )
        .catch(error => {
            this.error = error;
            this.isloadingTable = false;
        });
    }

    showToastEvent(titleValue, messageValue, variantValue){
        const event = new ShowToastEvent({
            title: titleValue, 
            message: messageValue,
            variant: variantValue
        });
        this.dispatchEvent(event);
    }

    handlePreviewClick(event) {

        if(FORM_FACTOR=='Small'){
            let contentDocId = event.currentTarget.dataset.id;
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state: {
                    // assigning ContentDocumentId to show the preview of file
                    selectedRecordId: contentDocId
                }
            })
        }else{
            let contentDocId = event.currentTarget.dataset.id;
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state: {
                    // assigning ContentDocumentId to show the preview of file
                    selectedRecordId: contentDocId
                }
            })
            let isFileTypePDF =false;
            if(event.currentTarget.dataset.filetpe=='pdf'){
                isFileTypePDF= true;
            }
            const payload = { docid: event.currentTarget.dataset.url, fileType:isFileTypePDF};
            publish(this.messageContext, DOCUMENT_ID, payload);
        }


        
}

get showVahanFields(){
    return this.dataObj.assignmentCase == 'Yes';
}

    handleLookupSelect(event){
const fieldapi = event.target.dataset.fieldapi;
        if(fieldapi === 'financierName'){
            let selectedValue = event.detail.value;
            let fieldName = fieldapi;
            if (selectedValue == undefined || selectedValue == '' || selectedValue == null) {
                this.dataObj[fieldName] = null;
            }
            else {
                this.dataObj[fieldName] = selectedValue;
            }
        }
        else{
        const { value: insuranceCompanyName } = event.detail;
        this.dataObj = { ...this.dataObj, insuranceCompanyName };
}
    }

    callToVahaan(){
        this.isVahaanRespSuccessful = false;// 5598 Change
        let element = this.template.querySelector(".registrationNumber");
        if(element && !element.checkValidity()){
            element.reportValidity();
            return;
        }else if(element && !element.value){
            this.showToastEvent('Registration Number is required to fetch vahaan details','error');
            return;
        }
        //callout to vahaan 
            this.isloading = true;
            getVahaanDetail({ registrationNumber:this.dataObj.registrationNumber, loanApplicationId: this.recordId})
            .then(async data => {
                if (data) {
                    this.isVahaanCheckIsMendatory = false;
                    let returndata = data.result;
                    if(returndata && Object.keys(returndata).length){
                        this.isVahaanRespSuccessful = true;
                        this.errorMessage = 'Match found in Vahaan. Click Search Again for CBS search';
                        const { vehicleDetails, insuranceDetails, financersDetails, nocCcDetails, ownerDetails, pdf, metadata } = data.result || { };
                        if(vehicleDetails){
                            this.vahanData.engineNo = vehicleDetails.engineNo ? vehicleDetails.engineNo : this.dataObj.engineNo;
if(this.isImplement){
                                this.vahanData.chasisNumber = vehicleDetails.chassisNo ? vehicleDetails.chassisNo : this.dataObj.serialNoImplement;
                            }
                            else{
                            this.vahanData.chasisNumber = vehicleDetails.chassisNo ? vehicleDetails.chassisNo : this.dataObj.chasisNumber;
}
                            
                            this.vahanData.registrationNumber = vehicleDetails.registrationNo;
                            if( vehicleDetails.registrationDt){
                                let registrationDate = new Date(vehicleDetails.registrationDt);
                                let month = registrationDate.getMonth() + 1;
                                let year = registrationDate.getFullYear();
                                let day =  registrationDate.getDate();

                                this.dataObj.registrationDate = year + '/' + month + '/' + day;
                            }
                            this.vahanData.ownerSerialNumber = vehicleDetails.ownerSrNo ;
                            this.vahanData.currentOwnerName = ownerDetails.ownersName ;
                            this.vahanData.hpnFinancer = financersDetails.financersName ;
                            this.template.querySelector(".registrationDate").value = this.dataObj.registrationDate;
                            this.template.querySelector(".engineNo").value = this.dataObj.engineNo;
if(this.isImplement){
                            this.template.querySelector(".chasisNumber").value = this.dataObj.chasisNumber;
}
                            else{
                                this.template.querySelector(".chasisNumber").value = this.dataObj.chasisNumber;
                            }
                            

                            let ownerSerialNumber =  this.template.querySelector(".ownerSerialNumber");
                            let currentOwnerName = this.template.querySelector(".currentOwnerName");
                            let hpnFinanceName = this.template.querySelector(".hpnFinancer");

                            if(ownerSerialNumber){
                                ownerSerialNumber.value =  this.vahanData.ownerSerialNumber;
                            }
                            if(currentOwnerName){
                                currentOwnerName.value =  this.vahanData.currentOwnerName;
                            }
                            if(hpnFinanceName){
                                hpnFinanceName.value =  this.vahanData.hpnFinancer;
                            }
                        }  
                        if(ownerDetails){
                            this.dataObj.fatherNameVahaan = (ownerDetails.hasOwnProperty('fathersName'))?ownerDetails.fathersName:this.dataObj.fatherNameVahaan;
                        }
                        this.populateRegistrationCity();
                        this.getVahanReport(); //SFAU-5835
                    }else{
                        this.showToastEvent('No Data Found for given Registration number','info');
                        this.isloading = false;
                    }
                }
            })
            .catch(error => {
                this.isVahaanRespSuccessful = false;
                console.log('error is '+JSON.stringify(error));
                this.isloading = false;
                this.isVahaanCheckIsMendatory = false;
            })
    }

    async populateRegistrationCity(){
        const cities = await getRegistrationCityPickListValues({ rtoCode: this.dataObj.registrationNumber }).catch(err => console.error(err));
        const { RTOName: registrationCities, ...rtoCodes } = cities ?? {};
        if(registrationCities.length === 1){
            const rtoCity = registrationCities[0].value;
            this.dataObj.registrationCityVahaan = rtoCity;
        } else {
            this.dataObj.registrationCityVahaan = null;
        }
    }

    get isEngineOrChassicDiffer(){
        if(this.isImplement){
            return this.isOpsUser && ( !this.vahanData.chasisNumber || (this.dataObj.serialNoImplement != this.vahanData.chasisNumber) );
        }
        else{
            return this.isOpsUser && ( !this.vahanData.engineNo || !this.vahanData.chasisNumber || (this.dataObj.engineNo != this.vahanData.engineNo) || (this.dataObj.chasisNumber != this.vahanData.chasisNumber) );
        }

    }

    showPopup = false;

    checkRCNotification(){
        if(!this.dataObj.isUsedOrCOW && this.dataObj.rCStatus == 'Completed' && this.rcDoc.opsAction == 'Ok' && this.isEngineOrChassicDiffer ){
            this.showPopup = true;
        }else{
            this.handleSubmit();
        } 
    }

    closeModal(){
        this.showPopup = false;
    }

    handleModifyCollateral(){
        if(this.isOpsUser && !this.canApprovePDD){
            this.showToastMessage('Warning', 'Please verify all documents before approving');
            return;
        } else if(!this.template.querySelector('.registrationNumber')?.value){ // - SFAU-4082 - api getting called with blank registration number
            this.showToastMessage('Warning', 'Please enter Vehicle Registration number');
            return;
        }
        this.isloading = true;
        callCollateralModificationCallout({recordId: this.recordId, vahanData : JSON.stringify(this.vahanData) }).then((data=>{
            let callOutData = JSON.parse(data)
            data = JSON.parse(callOutData.response)
            if(callOutData && callOutData.statusCode!=200){
                this.isLoading = false
                this.showToast('Error', 'API Error: ' + callOutData.checklistNumber + ' Response: ' + callOutData.statusCode + '- ' + callOutData.status , 'error');
                return;
            }
            if(data.TransactionStatus.ResponseMessage === 'Success'){
                this.showToastEvent('Success','Collateral Modification Successful','success')
                this.template.querySelector('[data-id="modifyCollateral"]').disabled = true
                this.isCollateralModified = true;
                this.isloading = false;
            }else{
                if(data.TransactionStatus.ExtendedErrorDetails && data.TransactionStatus.ExtendedErrorDetails.messages.length>0){
                    var validations;
                    data.TransactionStatus.ExtendedErrorDetails.messages.forEach(element => {
                        validations = element.message;
                    });
                    this.showToastEvent('Error','Request to check :'+callOutData.checklistNumber+'. '+validations,'error', 'sticky')
                }
                this.isCollateralModified = false;
                this.isloading = false;
            }
        })).catch((error=>{
            this.isloading = false;
            this.showToastEvent('Error',error.message || error.body.message,'error', 'sticky')
        }))
    }

    

}