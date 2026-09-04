/*
Logs:
 * LastModified Date    -   Last Modified By    -   Description
 * Sep-28-2023          -   Mohit M.            -   SFAU-5291 - Commented Blacklist error message
 * Oct-3-2023           -   Mohit M.            -   SFAU-5291 - Save Challan Info - true/false
 */
import { LightningElement, track, wire, api } from 'lwc';
import getPickListValues from '@salesforce/apex/AUSFVehicleController.getPickListValues';
import getCollateralEnquiryList from '@salesforce/apex/CustomCollateralEnquiryController.getCollateralEnquiryList';
import getUsedCategoryPickListValues from '@salesforce/apex/AUSFVehicleController.getUsedCategoryPickListValuesR2';
import getDepreciatedObj from '@salesforce/apex/AUSFVehicleController.getDepreciatedObj';
import getIBBValue from '@salesforce/apex/AUSFVehicleController.getIBBValue';
import deleteCollateral from '@salesforce/apex/AUSFVehicleController.deleteCollateral';
import getDepreciatedValue from '@salesforce/apex/AUSFVehicleController.getDepreciatedValue';
import getSchemeMasterRecord from '@salesforce/apex/AUSFVehicleController.getSchemeMasterRecord';
import getSchemePickListValues from '@salesforce/apex/AUSFVehicleController.getSchemePickListValues';
import fetchBranchMasterRecord from '@salesforce/apex/AUSFVehicleController.fetchBranchMasterRecord'; 
import getVisibleFields from '@salesforce/apex/AUSFVehicleController.getVisibleFields';
import getVehicleDetails from '@salesforce/apex/AUSFVehicleController.getVehicleDetails';
import upsertCollateral from '@salesforce/apex/AUSFVehicleController.upsertCollateral';
import getCollateralList from '@salesforce/apex/AUSFVehicleController.getCollateralList';
import getVahaanDetail from '@salesforce/apex/AUSFVehicleController.getVahaanDetail';
import createVahanReport from '@salesforce/apex/AUSFVehicleController.createVahanReport';
import getValuationDetails from '@salesforce/apex/AUSFValuationController.getValuationDetails';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import COLLATERAL_RECORD from '@salesforce/schema/Collateral__c';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import branchTopup from '@salesforce/label/c.AUSF_Branch_topup';
import isRepoSaleCollateralAllowedToCopy from '@salesforce/label/c.CollateralDedupeAllowRepoSale';
import getLoanSchemeMasterDetails from '@salesforce/apex/AUSFValuationController.getLoanSchemeMasterDetails';
import getMmvRecord from '@salesforce/apex/AUSFVehicleController.getMmvRecord';
import getRegistrationCityPickListValues from '@salesforce/apex/AUSFVehicleController.getRegistrationCityPickListValues';
import validateNameMatch from '@salesforce/apex/LOSKarzaNameMatchController.validateNameMatch';
import createCollateral from '@salesforce/apex/AUSFVehicleController.createCollateral';
import getMaterialFields from '@salesforce/apex/Utility.getMaterialFields';
import checkMaterialFields from '@salesforce/apex/Utility.checkMaterialFields';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import getProductVsPriceTagConfigs from '@salesforce/apex/AUSFVehicleController.getProductVsPriceTagConfigs';
import setValidationOnDocument from '@salesforce/apex/CreditVerification.setValidationOnDocument'
import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c';
import getInternalBTTopupRecord from '@salesforce/apex/BalanceTransferController.getInternalBTTopupRecord';
import vehicleCostMultiplicand from '@salesforce/label/c.VehicleCostMultiplicand';
import vahanReportNAMessage from '@salesforce/label/c.VahanReportNotAvailableMessage';
import Boolean_Use_Original_Vehicle_Usage from '@salesforce/label/c.Boolean_Use_Original_Vehicle_Usage'; // SFAU-5163
import checkForExistingLeadCollateral from '@salesforce/apex/AUSFVehicleController.checkForExistingLeadCollateral';
import AUSFCowScreen from '@salesforce/label/c.AUSFCowScreen'; //SFAU-5584
import canDoMaxLoanAmount from '@salesforce/label/c.MaxCanDoValuationLoanAmount'; //R2-2527
import otherFundingValidationError from '@salesforce/label/c.OtherFundingAmountValidationError';

import { OTHER_FUNDING_ITEMS_MAPPINGS, validateLoanFunding } from 'c/lwcutilities';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    createMessageContext
  } from 'lightning/messageService';


// 25th-Sept - Date format received from Vahan is valid for en-US locale. 
const LOCALE = 'en-US';

const MATERIAL_SCREEN_VEHICLE_LIST_USED = 'Vehicle - Used';
const MAKE_FIELD_API = 'Make__c';
const screenName = 'vehicle';
const TODAY = new Date();

const MAX_CAN_DO_LOAN_AMOUNT = +canDoMaxLoanAmount; //R2-2527

const SVSH_SVOH_OPTIONS = [
    { label: 'None', value: '' },
    { label: 'SVSH', value: 'SVSH' },
    { label: 'SVOH', value: 'SVOH' }
];

const GENERIC_YES_NO_OPTIONS = [
    { label: 'Yes', value: 'Yes' },
    { label: 'No', value: 'No' }
];

const STAGE_WITH_REQUIRED_VALUATION = [ 'PSD' ];
const FUEL_TYPE_ELECTRIC = 'electric';

const USER_DOESNT_HAVE_ACCESS_ERROR = 'INSUFFICIENT_ACCESS_OR_READONLY';
const EDIT_NOT_ALLOWED_ERROR_MESSAGE = 'You\'re not allowed to edit this application';

const VEHICLE_TYPE_VS_ALLOWED_DELETE_STAGES = {
    'Two Wheeler': [ 'QDE', 'Credit' ],
    'Four Wheeler': [ 'QDE', 'DDE', 'Credit' ],
};

const LOOKUP_FIELD_TO_COLLATERAL_FIELD = {
    'color_code__c': 'Vehicle_Color__c'
};

const VEHICLE_NUMBER_FIELD = 'Vehicle_Number__c';
const OWNER_SERIAL_NUMBER = 'Owner_Serial_number__c';

const VAHAN_FIELDS = [
    VEHICLE_NUMBER_FIELD,
    'Chasis_Number__c',
    'Engine_Number__c',
    'HPN_With_Financiers_Name__c',
    OWNER_SERIAL_NUMBER,
    'Current_Owner_Name__c',
    'Blacklist_Details__c',
    'Challan_Info__c',
    'Vahaan_Response__c',
    'IsDetailsFromVahaanApi__c',
    'Challan_Overdue_Amount__c',
    'Registration_Date__c'
];

const FIELD_FORMATS = {
    [ VEHICLE_NUMBER_FIELD ]: /^[A-Za-z0-9]{6,10}$/,
    [ OWNER_SERIAL_NUMBER ]: /^([1-9]|10)$/,
};

const FIELD_FORMATS_ERROR = {
    [ VEHICLE_NUMBER_FIELD ]: 'Please Enter Alphanumeric values',
    [ OWNER_SERIAL_NUMBER ]: 'Owner serial number should be b/w 1 to 9',
};

const BT_STATUS_OPTIONS = [{label:'Top Up',value:'Top Up'},
    {label:'Fore Closure Refinance',value:'Fore Closure Refinance'}];

const MMV_KEYS = [ 'make__c', 'model__c', 'variant__c' ];
export const updateDisabledOnFieldTokens = ( allFields, fieldsToDisable = [], disabledValue ) => {
    allFields.forEach(field => {
        const fieldKey = field.name ?? field.dataset.id ?? field.dataset.name;
        if(fieldsToDisable.includes(fieldKey?.toLowerCase())){
            field.disabled = disabledValue;
        }
    });
}

export default class AusfVehicleListUsed extends NavigationMixin(LightningElement) {
    @api recordId;
    $labels = { vahanReportNAMessage };
    activeSections = ['A','B','C','D'];
    isLoaded = false;   
    actionDisableCheck = false;    
    isModalOpen =false;
    showLoanDetails = false;           
    isCeAssesmentMethod = false;
    showCancelButton = false;
    isIBBValuedesabled = false;
    showBackButton = false;
    showVehicle = true;
    randomCollateralId ;
    showValuationDetail = false;
    isDisabledCertified = true;
    isCertifiedRequired = false;
    vehicleRecord;
    @track selectedCollList;
    valuationDetails;
    owner='5';
    manufacturerOptions =[];                                                    
    manufacturerOptionValue;
    makeOptions =[];
    existingPolicyExpired =[];
    makeOptionValue;
    variantOptionValue;
    modelOptions =[];
    fuelTypeOptions = [];
    fuelTypeOptionValue;
    modelOptionValue;
    variantOptions=[];
    valuerNameCodeOptions=[];
    schemeOptionValue;
    vehicleSchemeOptions =[];
    schemeMasterRecord
    depreciatedObjRecord;
    productName;
    isTwoWheeler = false;
    @track vehicleUsageOptions;
    vehicleUsageOptionValue;
    @track engineCategoryOptions;
    engineCategoryOptionValue;
    showSearchResult = false;
    @track newVehicleRecord = {'Insurance_Funding__c':false,'LS__c':false,'Quantity__c':1};
    _vehicleRecord = {}; // This holds actual db values:: it will always hold values which are there in database
    @track desableField = {'Make__c':false,'Model__c':true,'Variant__c':true,'Fuel_Type__c':true,'Vehicle_Category__c':true,'Scheme__c':false};
    @track inputSearchParamater = {'Vehicle_Number__c':'','Engine_Number__c':'','Chasis_Number__c':''}
    @track searchData =[];
    @track dataFromApi = {'Collateral_Name__c':false,'Owner_Serial_number__c':false,'manufactureMonth':false, 'manufactureYear':false,'Current_Owner_Name__c':false,'Registration_City__c':false,'Vehicle_Color__c':false,'Vehicle_Number__c':false,'Engine_Number__c':false,'Chasis_Number__c':false,'HPN_With_Financiers_Name__c':false};
    //@track dataFromApi;
    loanApplicationRecord;
    applicantRecord;
    usedProductOptions;
    mapOfCollateralNameVsId;
    accountCodes ={};
    loanAmount;
    showAddSection = false;
    // state;
    vehiclusg;
    visibledFields;
    title ='';
    manufactureYear;
    manufactureMonth;
    showMainSection = false;
    showSection = true;
    showSearchScreen = false;
    errorMessage;
    showErrorMessage = false;
    addNewApplicant = false;
    showApplicantInsertion = false;
    viewMorePartial = false;
    editApplicant = false;
    @track applicantLst = [];
    @track existingCollateralListCBS =[];
    @track existingCollateralListManual =[];
    appRecTypes = [];
    recordCount;
    customerNameVal = '';
    bureauScoreVal = '';
    appRecTypeVal = '';
    editRecordId;
    isPanUploaded = true;
    isChecked = false;
    boolNorecordsFull=false;
    error;
    errorOnChild;
    account;
    showCollateral = false;
    showManualCollDetail = false;
    showCBSCollDetail = false;
    showApplicantSelection = true;
    selectedApplicantId;
    vehicleIdForEdit;
    totalApplicantsFull=[];
    labelVal ='Choose Applicant from Drop down';
    disabledFetchVahhan = false;
    schemeName;
    isVahaanCheckIsMendatory = false;
    mapOfRtoCityVsCode;
    collateralRecId;
    vahaanOwnerName;
    collateralOwnerName;
    rtoCodeOptions =[];
    isDisableValuation = false;
    configurations = {};
    svshOptions = SVSH_SVOH_OPTIONS;
    searchLabel = 'Search';
    genericYesNoOptions = GENERIC_YES_NO_OPTIONS;
    btLoanStatusOptions = BT_STATUS_OPTIONS;
    collateralUpdates = {};
    collateralLink = '';
    totalPrincipalOutstanding = 0;
    loanStage;
    isLanCreated;

    messageContext = createMessageContext();
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                pageRefreshOnMaterialFieldChange,
                (message) => this.handleRefreshData(message),
                { scope: APPLICATION_SCOPE }
            );
        }
      }

      handleRefreshData(message){
        if(message.refreshPage=='Yes'){
             this.showValuationDetail = false; 
          this.applicantLst =[];
          this.loadInitialData()  // call the method which is fetching all the data for this component. In case of wire calls, use refresh apex
        }
      }

      unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
      }
    
      disconnectedCallback() {
          this.unsubscribeToMessageChannel();
      }


    /*
    @api boolIsWizardMode=false;
    editVehicleRecordPage = false;
    flowName;
    childToFlow;
    boolReFetchData;
    @api vehicleIdForEdit;
    */

    _state;
    get state(){
        return this._state;
    }

    @api set state(value){
        this._state = value;
    }

    get manufactureMonthOptions() {
        return [
            { label: '01', value: '01' },
            { label: '02', value: '02' },
            { label: '03', value: '03' },
            { label: '04', value: '04' },
            { label: '05', value: '05' },
            { label: '06', value: '06' },
            { label: '07', value: '07' },
            { label: '08', value: '08' },
            { label: '09', value: '09' },
            { label: '10', value: '10' },
            { label: '11', value: '11' },
            { label: '12', value: '12' },
        ];
    }

    // SFAU-5715
    get ibbVerified() {
        return (((this.newVehicleRecord.IBB_Value__c) && (this.newVehicleRecord.IBB_API_Value__c) && this.newVehicleRecord.IBB_Value__c == this.newVehicleRecord.IBB_API_Value__c) ? "Verified" : "Not Verified");
    }

    get collateralTypes() {
        return [
            { label: 'Existing', value: 'Existing' },
            { label: 'New', value: 'New' },
        ];
    }

    get vehicleType(){
        return this.loanApplicationRecord?.RecordType.Name ?? 'Four Wheeler';
    }

    get isSameAsVehicleOwner(){

        //SFAU-5228 : Added by Samridhi - this.productName && (this.productName.toUpperCase().includes('CASH ON WHEELS') || this.productName.toUpperCase().includes('USED')) && - Sachin - not required because the comp is used only for used / cow cases
        let isSameOwner = '';
        if(this.newVehicleRecord.Loan__c && this.productName && (this.productName.toUpperCase().includes('CASH ON WHEELS') || AUSFCowScreen.toUpperCase().includes(this.productName.toUpperCase()) || this.productName.toUpperCase().includes('USED')) && this.newVehicleRecord.HPN_With_Financiers_Name__c && this.isContainsAU(this.newVehicleRecord.HPN_With_Financiers_Name__c)){ // SFAU-5856
            isSameOwner = (this.newVehicleRecord.RC_is_on_name_of_Applicant__c == 'Yes') ? 'SVSH' : 'SVOH';
        }else if(this.newVehicleRecord.Loan__c && this.productName && (this.productName.toUpperCase().includes('CASH ON WHEELS') || AUSFCowScreen.toUpperCase().includes(this.productName.toUpperCase()) || this.productName.toUpperCase().includes('USED')) && this.newVehicleRecord.HPN_With_Financiers_Name__c){
            //isSameOwner = (this.newVehicleRecord.RC_is_on_name_of_Applicant__c == 'Yes') ? 'SVOH' : '';
            isSameOwner = ''; //R2-3079 if it is Not an AU then option should be None 
        }


        /*const isSameOwner = (this.loanApplicationRecord?.Name_of_Customer__c && this.newVehicleRecord.Current_Owner_Name__c) ?
            this.newVehicleRecord.Current_Owner_Name__c?.replaceAll(' ', '').toLowerCase() === this.loanApplicationRecord?.Name_of_Customer__c?.replaceAll(' ', '')?.toLowerCase() ?
                'SVSH' : 'SVOH' : ''; */
        if(isSameOwner !== this.newVehicleRecord.SVSH_SVOH__c){
            this.newVehicleRecord.SVSH_SVOH__c = isSameOwner;
        }
        return isSameOwner;
    }

    isContainsAU(value){ //SFAU-5856
        if(value){
            let trimVal = value.replaceAll(' ','');
            return trimVal.toUpperCase().startsWith('AU',0);
        }
        return false;
        
    }

    get isSVSH(){
        return this.newVehicleRecord.SVSH_SVOH__c == 'SVSH';
    }

    // SFAU-5146 - Valuation amount not required if dealer is certified
    get isValuationRequired(){
        return this.isDisabledCertified && STAGE_WITH_REQUIRED_VALUATION.includes(this.loanApplicationRecord?.Stage__c?.toUpperCase());
    }

    get valuationAmountClasses(){
        return this.isValuationRequired ? 'validate' : '';
    }

    get ibbValueClasses(){
        return this.isFourWheeler ? 'validate' : '';
    }

    get canDeleteCollateral(){
        return VEHICLE_TYPE_VS_ALLOWED_DELETE_STAGES[this.loanApplicationRecord?.RecordType.Name]?.includes(this.loanApplicationRecord?.Stage__c);
    }

    label = {
        branchTopup,
        Boolean_Use_Original_Vehicle_Usage
    };
    async connectedCallback() {
        this.subscribeToMessageChannel();
        this.loadInitialData();
        this.getInternalBT()
    }

    @track totalPOS=0
    keyIndex=0;
    @track recordCount=0
    keyId=0
    btMap=new Map()
    addBT=true;
    
    getInternalBT(){
        getInternalBTTopupRecord({recordId: this.recordId,type : 'Internal'}).then( data => { this.totalPrincipalOutstanding = data?.reduce( (posSoFar, item) => (+item.POS__c + posSoFar), 0) });
    }

    async loadInitialData(){
        await this.getMaterialSettings(MATERIAL_SCREEN_VEHICLE_LIST_USED, this.recordId);
        /*if(this.vehicleIdForEdit != undefined){
            this.fetchState(this.recordId);
            this.handleEditAction();
        }
        else{*/
            this.fetchState(this.recordId);
            this.title = 'Vehicle Information';
        //}
        this.getLoanDetails(this.recordId);
        this.getPicklistOptions('','',this.vehicleType,'Make');
        //this.getPicklistOptions(this.recordId);
        //this.getVehicles(this.recordId);
        this.getInternalBT();
        this.currentYear = new Date().getFullYear();
    }

    getLoanDetails(loanId){
        this.isLoaded = true;
        getLoanSchemeMasterDetails({loanId: loanId})
        .then(data => {
            if(data){
                this.schemeName = data;
                this.isLoaded = false;
            }
          })
          .catch(error => {
              console.log('errorin getMaster '+JSON.stringify(error));
              this.isLoaded = false;
          })
    }

    getInternalBT(){
        getInternalBTTopupRecord({recordId: this.recordId,type : 'Internal'}).then( data => { this.totalPrincipalOutstanding = data?.reduce( (posSoFar, item) => (+item.POS__c + posSoFar), 0) });
    }

    fetchState(loanApplRecordId) {
        this.isLoaded = true;
        fetchBranchMasterRecord({loanAppId: loanApplRecordId })
		.then(async data => {
            if (data) {
                // this.state = data.state;
                let loanApplication = data.loanApp.Loan__r;
                this.loanApplicationRecord = loanApplication;
                this.collateralUpdates = data.wasCollateralUpdated;
               /* if(data.loanApp.Loan__r.Dealer_Master__r){
                    if(data.loanApp.Loan__r.Dealer_Master__r.Grading__c){
                        let gradingField = data.loanApp.Loan__r.Dealer_Master__r.Grading__c;
                        if(gradingField.includes('Certified')){
                            this.isDisabledCertified = false;
                            this.isCertifiedRequired = true;
                            //this.template.querySelector('[data-id="'+input+'"]').classList.remove('slds-hide');
                            //this.template.querySelector('.addValidateClass').classList.add('validate');
                        }
                    }
                    
                }*/
                if(data.certifiedVal == 'Yes'){ // START || SFAU-3522 || Ashish
                    this.isDisabledCertified = false;
                    this.isCertifiedRequired = true;
                }// END
                
                this.applicantRecord = data.loanApp;
                let collatList = data.collateralList;
                this.loggedInUserProfile = data.userProfile;
                this.screenType = data.screenName;
                //this.manufacturerOptions = data.picklistValues['Manufacturer__c'];
                //this.collateralNames = data.collateralNames.Collateral_Name__c;
                this.mapOfCollateralNameVsId = data.mapOfCollateralNameVsId;
                this.vehiclusg = loanApplication.Vehicle_use__c;
                let curObj = this.newVehicleRecord;
                curObj.Apportioned_Loan_Amount__c=loanApplication.Loan_Amount__c;
                //curObj.Collateral_ID__c = data.strCollateralIdForNew;
                this.randomCollateralId = data.strCollateralIdForNew;
                this.stageValue = loanApplication.Stage__c;
                this.productName = data.productName;
                this.loanAmount = loanApplication.Loan_Amount__c;
                this.accountCodes =data.loanApp.Loan__r.Branch_Master__r;
                this.getPicklistOptions('','',this.vehicleType,'Make');
                this.isFourWheeler = data.typeOfWheeler.isFourWheeler;
                this.isTwoWheeler = data.typeOfWheeler.isTwoWheeler;
                this.loanStage = data.loanStage;
                if(this.loanStage == 'Credit'){
                    this.isIBBValuedisabled = true;
                }
                this.isLanCreated = data.isLanCreated;
                if(this.isTwoWheeler){
                    const productToPriceMappings = await getProductVsPriceTagConfigs().catch(err => console.error(err));
                    this.configurations = { ...this.configurations, productToPriceMappings: productToPriceMappings ?? [] };
                }
                // SFAU-3648 - Vehicle Usage to be auto selected and disabled
                // if(!this.isTwoWheeler){
                    curObj.Vehicle_Usage__c = loanApplication.Vehicle_use__c;
                // }
		curObj.Original_Vehicle_Usage__c = this.label.Boolean_Use_Original_Vehicle_Usage == 'Yes' && loanApplication.Original_Vehicle_Usage__c != '' ? loanApplication.Original_Vehicle_Usage__c : loanApplication.Vehicle_Usage__c;
                this.newVehicleRecord = curObj;
                // START - SFAU-5163
                this.newVehicleRecord.Original_Vehicle_Usage__c = this.label.Boolean_Use_Original_Vehicle_Usage == 'Yes' && loanApplication.Original_Vehicle_Usage__c != '' ? loanApplication.Original_Vehicle_Usage__c : loanApplication.Vehicle_Usage__c;
                // END - SFAU-5163
                // SFAU-5608
                if (collatList != undefined && collatList.length > 0 && collatList[0].Collateral_From_Lead_Api__c == true) {
                    this.newVehicleRecord.Id = collatList[0].Id;
                    this.newVehicleRecord.Collateral_From_Lead_Api__c = false;
                    this.newVehicleRecord.Collateral_ID__c = collatList[0].Collateral_ID__c;
                }
                if(collatList.length>0 && collatList[0].Collateral_From_Lead_Api__c != true /*&& this.vehicleIdForEdit == undefined*/){
                    //this.applicantLst = data.collateralList;
                    let conts = data.collateralList;
                        for(let key in collatList){
                            
                             if(conts[key].Type_Of_Existing_Collateral__c==='CBS'){
                                this.existingCollateralListCBS.push(conts[key]);
                                
                             }else if(conts[key].Type_Of_Existing_Collateral__c==='Manual'){
                                this.existingCollateralListManual.push(conts[key]);
                             }else{
                                this.applicantLst.push(conts[key]);
                             }
                        }

                        if(this.existingCollateralListCBS.length>0){
                            this.showCBSCollDetail = true;
                        }
                        if(this.existingCollateralListManual.length>0){
                            this.showManualCollDetail = true;
                        }

                        if(this.showManualCollDetail || this.showCBSCollDetail){
                            this.showApplicantSelection = false;
                        }

                        if(this.applicantLst){
                            let constVal = 1000000;
                            let loanApp = this.loanApplicationRecord;
                            let loanAmount =  parseInt(loanApp.Loan_Amount__c);
                            let dataCol = this.applicantLst;
                            for (let i = 0; i < dataCol.length; i++) {
                                dataCol[i].isDisableValuation = true;
                                //if(dataCol[i].Certified_Value__c){
                                    let certifiedVal = parseInt(dataCol[i].Certified_Value__c);
                                    if(certifiedVal>0 && certifiedVal<=constVal){
                                        dataCol[i].isDisableValuation = !this.collateralUpdates[dataCol[i].Id];;
                                        let optionValuer = [{label:'Auto Inspect',value:'Auto Inspect'},{label:'Other valuation',value:'Other valuation'},{label:'Cando',value:'Cando'}];
                                        this.valuerNameCodeOptions = optionValuer;
                                    }else if(certifiedVal>constVal){
                                        dataCol[i].isDisableValuation = !this.collateralUpdates[dataCol[i].Id];;
                                        let optionValuer = [{label:'Auto Inspect',value:'Auto Inspect'},{label:'Other valuation',value:'Other valuation'}];
                                        this.valuerNameCodeOptions = optionValuer;
                                    }else if(certifiedVal===0 || isNaN(certifiedVal)){
                                        dataCol[i].isDisableValuation = !this.collateralUpdates[dataCol[i].Id];;
                                        if( loanAmount <= MAX_CAN_DO_LOAN_AMOUNT ){
                                            this.defaultValue = 'Cando';
                                            let optionValuer = [{label:'Auto Inspect',value:'Auto Inspect'},{label:'Other valuation',value:'Other valuation'},{label:'Cando',value:'Cando'}];
                                            this.valuerNameCodeOptions = optionValuer;
                                        }else if( loanAmount > MAX_CAN_DO_LOAN_AMOUNT ){
                                            let optionValuer = [{label:'Auto Inspect',value:'Auto Inspect'},{label:'Other valuation',value:'Other valuation'}];
                                            this.valuerNameCodeOptions = optionValuer;
                                        }
                                        
                                    }
                                //}
                            }
                            
                            this.applicantLst = dataCol;
                        }
                    

                    this.showMainSection = true;
                    this.showSection = true;
                    this.showCancelButton =true;
                    const Obj = {};
                    Obj.applicantLst = this.applicantLst;
                    this.dispatchEvent(new CustomEvent('save', {
                        detail:Obj
                    }));
                }else{
                    /*if(data.screenName === 'New'){
                        this.newVehicleRecord.Collateral_Type__c ='New';
                        this.addNewApplicant = true
                        const d = new Date();
                        let year = d.getFullYear();
                        this.manufactureYear = year;
                        this.getVisibleFields();
                        this.showSection = false;
                    }*/if (data.screenName === 'Used'){
                        this.showSearchScreen = true;
                        this.newVehicleRecord.Collateral_Type__c ='Existing';

                        if (collatList != undefined && collatList.length > 0 && collatList[0].Collateral_From_Lead_Api__c == true) {
                            this.inputSearchParamater.Vehicle_Number__c = collatList[0].Vehicle_Number__c;
                            this.inputSearchParamater.Engine_Number__c = collatList[0].Engine_Number__c;
                            this.inputSearchParamater.Chasis_Number__c = collatList[0].Chasis_Number__c;
                            this.inputSearchParamater['Apportioned_Loan_Amount__c'] = collatList[0].Apportioned_Loan_Amount__c;
                            this.inputSearchParamater['Approved_LTV__c'] = collatList[0].Approved_LTV__c;
                            this.inputSearchParamater['LTV_offered_On_road__c'] = collatList[0].LTV_offered_On_road__c;
                            this.inputSearchParamater['LTV_offered_On_final_cost__c'] = collatList[0].LTV_offered_On_final_cost__c;
                            this.inputSearchParamater['Final_Cost__c'] = collatList[0].Final_Cost__c;
                            this.inputSearchParamater['Ex_Showroom_Price__c'] = collatList[0].Ex_Showroom_Price__c;
                            this.inputSearchParamater['Valuation_Amount__c'] = collatList[0].Valuation_Amount__c;
                            this.inputSearchParamater['Make__c'] = collatList[0].Make__c;
                            this.inputSearchParamater['Model__c'] = collatList[0].Model__c;
                            this.inputSearchParamater['Current_Owner_Name__c'] = collatList[0].Current_Owner_Name__c;
                            this.inputSearchParamater['Owner_Serial_number__c'] = collatList[0].Owner_Serial_number__c;
                        }
                        // populate cached vahan details
                        if(this.state){
                            this.showApplicantInsertion = true;
                            const { [ screenName ]: { vahanRaw } } = this.state;
                            const { vehicleRecord, disabledFields } = this.populateVahanDetails( vahanRaw );
                            this.newVehicleRecord = await this.populateRegistrationCities(vehicleRecord, disabledFields, vahanRaw);
                            this.dataFromApi = disabledFields;
                        }
                    }
                }
                this.applicantLst = this.getValuationSettingsBasedOnScheme(this.applicantLst, this.schemeName);
                this.isLoaded = false;
            }
		})
		.catch(error => {
            console.log('error is '+JSON.stringify(error));
            this.isLoaded = false;
		})
    }

    handleRowAction(event){
        this.isLoaded = true;
        const recordVehicleId = event.currentTarget.dataset.id;
        this.vehicleIdForEdit = recordVehicleId;
        this.handleEditAction();
    }

    handleEditAction(){
        /*if(this.vehicleIdForEdit != undefined){
            if(this.boolIsWizardMode){*/
                this.isLoaded = true;
                this.showMainSection = false;
                this.addNewApplicant = true;
                this.showCancelButton = true;
                this.showSection = false;
                this.title ='Change Vehicle Information';
                this.getVisibleFields();
                this.applyMaterialSettings();
                /*let newVehicleList = this.applicantLst;
                for (let i = 0; i < newVehicleList.length; i++) {
                    if(recordId === newVehicleList[i].Id){
                        this.newVehicleRecord = newVehicleList[i];
                    }
                }*/
                this.getVehicleDetail(this.vehicleIdForEdit);
                this.dispatchEvent(new CustomEvent('wizardevent', {
                    bubbles: true,
                    composed: true,
                    detail:{value:'',name:'VehicleDetails' ,mode:''}
                }));
            /*}
            else{
                this.editVehicleRecordPage = true;
                this.flowName = 'Parent_Flow_QDE';
                this.childToFlow = 'Parent_Flow_QDE_Edit_Vehicles';
                this.boolReFetchData = true; 
            }
        }*/
    }

    getVehicleDetail(recordVehicleId){
        this.isLoaded = true;
        /*let screen = this.screenType;
        let stage = this.stageValue;
        let profile = this.loggedInUserProfile;
        strScreen :screen, strStage :stage, strProfile :profile */

        getVehicleDetails({collateralId: recordVehicleId,loanAppId:this.recordId})
		.then(async data => {
            if (data) {
                //this.isVahaanCheckIsMendatory = false;
                let customObject = data.coll;
                this._vehicleRecord = { ...data.coll };
                customObject.Insurance_Funding__c = customObject.Insurance_Funding__c==='Yes'?true:false;
                customObject.LS__c = customObject.LS__c==='Yes'?true:false;
                this.newVehicleRecord = customObject;
                this.collateralLink = data.linkForDoc;
	    	this.newVehicleRecord.Vehicle_Usage__c = this.vehiclusg;
                let listOfRecord = this.applicantLst;
                if(listOfRecord.length===0){
                    this.applicantLst.push(customObject);
                }
                /*let cbsResp ={};
                cbsResp = JSON.parse(this.newVehicleRecord.CBS_Response__c);
                this.setReadOnlyField(cbsResp);

                let vahaanResp ={};
                vahaanResp = JSON.parse(this.newVehicleRecord.Vahaan_Response__c);
                this.setReadOnlyField(vahaanResp);*/
                this.dataFromApi = JSON.parse(this.newVehicleRecord.IntegrationReadOnlyData__c || '{}');
                this.disabledFetchVahhan = !!this.newVehicleRecord.IsDetailsFromVahaanApi__c;
                /*
                * MMV options to remain enabled for editing
                if(this.dataFromApi.Make__c){
                    this.desableField.Make__c = true;
                }
                if(this.dataFromApi.Model__c){
                    this.desableField.Model__c = true;
                }
                if(this.dataFromApi.Variant__c){
                    this.desableField.Variant__c = true;
                }*/

                this.makeOptionValue = this.newVehicleRecord.Make__c;
                this.modelOptionValue = this.newVehicleRecord.Model__c;
                this.variantOptionValue = this.newVehicleRecord.MMV_Master__c;
                //this.enableFieldToEdit(this.newVehicleRecord);
                let yearandMonth = data.coll.Manufacture_year_month__c;
                //const myArray = yearandmonth.split("-");
                //let text = "200412";
                let month = yearandMonth?.substr(4, 2);
                let year = yearandMonth?.substr(0, 4);
                //this.applicantLst.push(customObject);
                this.manufactureYear = year;
                this.manufactureMonth = month;
                this.makeOptions = data.picklist.Make;
                this.modelOptions = data.picklist.Model;
                this.variantOptions = data.picklist.Variant;
                this.schemeOptionValue = this.newVehicleRecord.Scheme__c;
                this.vehicleCategoryOptions = data.picklist.Category;
                this.vehicleSchemeOptions = data.picklist.Scheme;
                this.fuelTypeOptions = data.picklist.FuelType;
                this.collateralNames = data.picklist.CollateralName;

                this.setDefaultFieldValue( data.picklist.CollateralName, 'Collateral_Name__c' );;
                this.setDefaultFieldValue( data.picklist.FuelType, 'Fuel_Type__c' );
                /* START - SFAU-5608 */
                this.setDefaultCategoryValue( data.picklist.Category, 'Vehicle_Category__c' );
                /* END - SFAU-5608 */
                this.ragistrationCityOptions = data.picklist.RTOName;
                this.rtoCodeOptions = data.picklist[this.newVehicleRecord.Registration_City__c];
                if(!this.newVehicleRecord.Vahaan_Response__c && this.state){
                    const { [ screenName ]: { vahanRaw } } = this.state || { [screenName ]: { vahanRaw: {} } };
                    const { vehicleRecord, disabledFields } = this.populateVahanDetails( vahanRaw );
                    this.newVehicleRecord = await this.populateRegistrationCities(vehicleRecord, disabledFields, vahanRaw);
                    this.dataFromApi = disabledFields;
                }
                this.isLoaded = false;
            }
		})
		.catch(error => {
            console.log('error is '+JSON.stringify(error));
            this.isLoaded = false;
		})
    }

    handleDeleteAction(event){
        const { id: collateralId } = event.currentTarget.dataset;
        restricAccess({
            compName: 'ausfVehicleListUsed' ,loanId: this.recordId
            })
            .then(data => {
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to delete vechile',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }else{
                    let collList = this.applicantLst;
                    let todoTaskIndex;
                    for(let i=0; i<collList.length; i++) {
                        if(collateralId === collList[i].id) {
                            todoTaskIndex = i;
                        }
                    }

                    collList.splice(todoTaskIndex, 1);
                    if(collList.length===0){

                        this.desableField = {
                            Make__c : false,
                            Model__c : true,
                            Variant__c : true,
                            Fuel_Type__c : true,
                            Vehicle_Category__c : true,
                            Scheme__c : true
                        };
            
                    this.showApplicantInsertion = true;
                    this.showSearchScreen = true;
                    this.resetScreen();
                }
                this.applicantLst = collList;
                const Obj = {};
                Obj.applicantLst = this.applicantLst;
                this.dispatchEvent(new CustomEvent('newsave', {
                    detail:Obj
                }));
                this.deleteCollateral(collateralId);
            }
        })
        .catch(error => {
            console.log('error is ' + JSON.stringify(error));
        })
    }
    deleteCollateral(collateralId){
        this.isloading = true;
        deleteCollateral({collId : collateralId})
                .then(result => {
                    this.isloading = false;
                    this.showToast('Successfully deleted collateral','success');

                })
                .catch(error => {
                    this.isloading = false;
                    this.error =error;
                });

    }

    handleActionOnExistingCollateral(event){
        let objDetail = event.detail;
        if(objDetail.type==='CBS'){
            this.showCBSCollDetail = objDetail.showDetail;
        }
        if(objDetail.type==='Manual'){
            this.showManualCollDetail = objDetail.showDetail;
        }
    }

    

    handleCopyToCollateral(event){
        
        this.isLoaded = true;
        let current = event.detail;
        this.title='Change Vehicle Information';
        this.isLoaded = true;
        this.addNewApplicant = true;
        this.showSearchScreen = false;
        this.showCancelButton = true;
        this.showSection = false;
        const recordVehicleId = current.collateralObj;
        let collObj = current.collateralObj;
        checkForExistingLeadCollateral({loanAppRecId: this.recordId,blnIsLeadCollateral:true})
		.then(async data => {
            if (data) {
                let currentObj = Object.assign({}, collObj);
                if (data.length>0) {
                    this.newVehicleRecord.Id = data[0].Id;
                    this.newVehicleRecord.Make__c = data[0].Make__c;
                    this.newVehicleRecord.Modek__c = data[0].Model__c;
                    this.newVehicleRecord.Valuation_Amount__c = data[0].Valuation_Amount__c;
                    this.newVehicleRecord.Kilometer__c = data[0].Kilometer__c;
                    this.newVehicleRecord.Current_Owner_Name__c = data[0].Current_Owner_Name__c;
                    this.newVehicleRecord.Owner_Serial_number__c = data[0].Owner_Serial_number__c;

                    this.newVehicleRecord.Apportioned_Loan_Amount__c = data[0].Apportioned_Loan_Amount__c;
                    this.newVehicleRecord.Approved_LTV__c = data[0].Approved_LTV__c;
                    this.newVehicleRecord.LTV_offered_On_road__c = data[0].LTV_offered_On_road__c;
                    this.newVehicleRecord.LTV_offered_On_final_cost__c = data[0].LTV_offered_On_final_cost__c;
                    this.newVehicleRecord.Final_Cost__c = data[0].Final_Cost__c;
                    this.newVehicleRecord.Ex_Showroom_Price__c = data[0].Ex_Showroom_Price__c;
                    this.newVehicleRecord.Engine_Category__c = data[0].Engine_Category__c;
                    this.newVehicleRecord.Vehicle_Color__c = data[0].Vehicle_Color__c;
                    this.newVehicleRecord.Registration_City__c = data[0].Registration_City__c;
                }
                this.newVehicleRecord.LS__c = currentObj.LS__c==='Yes'?true:false;
                this.newVehicleRecord.Insurance_Funding__c = currentObj.Insurance_Funding__c==='Yes'?true:false;

                this.newVehicleRecord.Loan__c = this.recordId; // SFAU-5700
                if(currentObj.Current_Owner_Name__c){
                    this.newVehicleRecord.Current_Owner_Name__c = currentObj.Current_Owner_Name__c;
                    this.collateralOwnerName = currentObj.Current_Owner_Name__c;
                }

                if(!this.newVehicleRecord.Collateral_Name__c){
                    this.newVehicleRecord.Collateral_Name__c = currentObj.Collateral_Name__c;
                }
                if(!this.newVehicleRecord.Collateral_ID__c){
                    this.newVehicleRecord.Collateral_ID__c = currentObj.Collateral_ID__c;
                }
                if(!this.newVehicleRecord.Collateral_Type__c){
                    this.newVehicleRecord.Collateral_Type__c = currentObj.Collateral_Type__c;
                }
                if(!this.newVehicleRecord.Cost__c){
                    this.newVehicleRecord.Cost__c = currentObj.Cost__c;
                }
                if(!this.newVehicleRecord.Vehicle_Number__c){
                    this.newVehicleRecord.Vehicle_Number__c = currentObj.Vehicle_Number__c;
                    /*let vehicleNumber =  currentObj.Vehicle_Number__c;
                    let rtoCode = vehicleNumber.substr(0, 2);*/
                    this.getRegistrationCityPickListValues(currentObj.Vehicle_Number__c,true);
                }
                if(!this.newVehicleRecord.POS__c){
                    this.newVehicleRecord.POS__c = currentObj.POS__c;
                    let posValue = parseInt(currentObj.POS__c,10);
                    if(posValue ==0){
                        this.isVahaanCheckIsMendatory = true;
                    }
                }
                if(!this.newVehicleRecord.Total_Collateral_Value__c){
                    this.newVehicleRecord.Total_Collateral_Value__c = currentObj.Total_Collateral_Value__c;
                }
                
                if(!this.newVehicleRecord.Chasis_Number__c){
                    this.newVehicleRecord.Chasis_Number__c = currentObj.Chasis_Number__c;
                }
                if(!this.newVehicleRecord.Engine_Number__c){
                    this.newVehicleRecord.Engine_Number__c = currentObj.Engine_Number__c;
                }
                if(!this.newVehicleRecord.Manufacture_year_month__c){
                    this.newVehicleRecord.Manufacture_year_month__c = currentObj.Manufacture_year_month__c;
                }
                if(!this.newVehicleRecord.Manual_Variant__c){
                    this.newVehicleRecord.Manual_Variant__c = currentObj.Manual_Variant__c;
                }
                if(!this.newVehicleRecord.Manual_Make__c){
                    this.newVehicleRecord.Manual_Make__c = currentObj.Manual_Make__c;
                }
                if(!this.newVehicleRecord.Manual_Model__c){
                    this.newVehicleRecord.Manual_Model__c = currentObj.Manual_Model__c;
                }

                if(this.newVehicleRecord.Manual_Make__c){
                    this.newVehicleRecord.Make__c = currentObj.Manual_Make__c;
                }
                if(this.newVehicleRecord.Manual_Model__c){
                    this.newVehicleRecord.Model__c = currentObj.Manual_Model__c;
                }
                if(this.newVehicleRecord.Manual_Variant__c){
                    this.newVehicleRecord.Variant__c = currentObj.Manual_Variant__c;
                }
                
                this.newVehicleRecord.Collateral_Id_in_CBS__c = currentObj.Collateral_Id_in_CBS__c; // SFAU-5773
                this.newVehicleRecord.Linked_Account_Number__c = currentObj.Linked_Account_Number__c; //CUG-- 9th Sept - AccountNumber not being mapped to Linked_Account__c
                this.newVehicleRecord.Collateral_Code_in_CBS__c = currentObj.Collateral_Code_in_CBS__c;
                this.newVehicleRecord.Repo_Sale_Date__c = currentObj.Repo_Sale_Date__c; //CUG-- 9th Sept - AccountNumber not being mapped to Linked_Account__c

                let arrObj =[];
                for (let i = 0; i < this.searchData.length; i++) {
                    let obj ={};
                    obj.AccountNumber = this.searchData[i].Linked_Account_Number__c;
                    obj.CollateralUnusedValue = this.searchData[i].POS__c;
                    arrObj.push(obj);
                }
                this.newVehicleRecord.Collateral_Search_Results__c =JSON.stringify(arrObj);
                this.newVehicleRecord.CBS_Response__c = JSON.stringify(recordVehicleId);
                this.newVehicleRecord.Collateral_Type__c ='Existing';
                this.newVehicleRecord.Vehicle_Usage__c=this.loanApplicationRecord.Vehicle_use__c;
                // SFAU-5163
                this.newVehicleRecord.Original_Vehicle_Usage__c = this.label.Boolean_Use_Original_Vehicle_Usage == 'Yes' && this.loanApplicationRecord.Original_Vehicle_Usage__c != '' ? this.loanApplicationRecord.Original_Vehicle_Usage__c : this.loanApplicationRecord.Vehicle_Usage__c;
                
                this.newVehicleRecord.Apportioned_Loan_Amount__c=this.loanApplicationRecord.Loan_Amount__c;
                let yearandMonth = this.newVehicleRecord.Manufacture_year_month__c;
                if(yearandMonth){
                    let month = yearandMonth.substr(4, 2);
                    let year = yearandMonth.substr(0, 4);
                    this.manufactureYear = year;
                    this.manufactureMonth = month;
                }
                //"10101-MUV-INR"
                this.setReadOnlyField(this.newVehicleRecord);
                this.getVisibleFields();
                this.applyMaterialSettings();
                
                /*this.newVehicleRecord.POS__c = recordVehicleId.POS__c;
                this.newVehicleRecord.Total_Collateral_Value__c = recordVehicleId.Total_Collateral_Value__c;
                this.newVehicleRecord.Vehicle_Number__c = recordVehicleId.Vehicle_Number__c;
                this.newVehicleRecord.Collateral_Name__c = this.mapOfCollateralNameVsId[recordVehicleId.Collateral_Name__c];
                //this.newVehicleRecord.Collateral_Type__c = recordVehicleId.Collateral_Type__c;
                this.newVehicleRecord.Collateral_ID__c = recordVehicleId.Collateral_ID__c;*/

                this.getMmvRecord(this.newVehicleRecord.Manual_Variant__c)
                this.errorOnChild  = 'Please create vehicle record.';
                const obj = {};
                obj.errorOnChild = this.errorOnChild;
                obj.applicantLst = '';
                this.dispatchEvent(new CustomEvent('save', {
                    detail:obj
                }));
                
                this.isLoaded = false;
            }
		})
		.catch(error => {
            console.log('error is '+JSON.stringify(error));
            this.isLoaded = false;
		})
    }

    getMmvRecord(variantId){
        //this.isLoaded = true;
        getMmvRecord({ variant : variantId})
        .then(result => {
            if(result.Id){
                let colName = this.newVehicleRecord.Collateral_Name__c;
                let collateralName = colName.substr(0, 5);
                this.newVehicleRecord.Collateral_Name__c = collateralName;
                this.makeOptionValue = this.newVehicleRecord.Manual_Make__c;
                this.modelOptionValue = this.newVehicleRecord.Manual_Model__c;
                this.getPicklistOptions(this.newVehicleRecord.Manual_Make__c,'',this.vehicleType,'Make');
                this.getPicklistOptions(this.newVehicleRecord.Manual_Make__c,this.newVehicleRecord.Manual_Model__c,this.vehicleType,'Model');
                this.getPicklistOptions(this.newVehicleRecord.Manual_Make__c,this.newVehicleRecord.Manual_Model__c,this.vehicleType,'Variant');
                this.variantOptionValue = result.Id;
                /*this.desableField.Model__c = true;
                this.desableField.Make__c = true;
                this.desableField.Variant__c = true;
                this.dataFromApi.Model__c = true;
                this.dataFromApi.Make__c = true;
                this.dataFromApi.Variant__c = true;*/
                this.getUsedCategoryPickListValues(result.Id);
                this.getSchemePickListValues();
                
            }else{
                this.showToast('Variant from api is not matching with masters data, please select collateral','failure');
            }
            this.isLoaded = false;
        })
        .catch(error => {
                this.isLoaded = false;
                console.log('result is '+JSON.stringify(error));
        })
    }

    setReadOnlyField(collateralObj){
        let obj = {};
        for (const key in collateralObj) {
            if(!MMV_KEYS.includes(key) && collateralObj[key]){
                obj[key]=true;
            }
        }
        this.dataFromApi = obj;
    }   

    handleClick(){
        let uiParamater = this.inputSearchParamater;
        let chaseNum = uiParamater.Chasis_Number__c;
        let engineNum = uiParamater.Engine_Number__c;
        let vehicleNum = uiParamater.Vehicle_Number__c;
        
        const element = this.template.querySelector(".searchvehicle");
        if(vehicleNum && element && !element.checkValidity()){
            element.reportValidity();
        } else if(chaseNum || engineNum || vehicleNum){
            this.resetScreen();
            this.getCollateralList();
        } else {
            this.setSpinner( false );
            this.errorOnChild  = 'Please enter value in any one of below search paramater to get collateral.';
            const obj = {};
            obj.errorOnChild = this.errorOnChild;
            obj.applicantLst = this.applicantLst;
            this.dispatchEvent(new CustomEvent('save', {
                detail:obj
            }));
            this.showToast('Please enter value in any one of below search paramater to get collateral.','error')
        }
        
    }

    handleChange(event){
        this.showCollateral = true;
        let selected = event.detail;
        this.totalApplicantsFull =[];
        let picklistName = selected.target.name;
        let picklistValue = selected.target.value;
        this.selectedApplicantId = picklistValue;
        
        this.getCollateral(this.selectedApplicantId);
        //this.template.querySelector('c-ausf-customer-collateral-enquiry').getCollateral(this.selectedApplicantId);

    }

    getCollateral(applicantId) {
        if(!applicantId) return; //missing CustomerId / no need to call CBS
        this.isLoaded = true;
        getCollateralEnquiryList({ strApplicantId : applicantId})
        .then(result => {
                this.totalApplicantsFull = result.collateralList;
                let totalCollList = result.collateralList;
                let selectedList = this.selectedCollList || [];
                if(selectedList.length>0){
                    for(let i=0; i<selectedList.length; i++) {
                        for(let j=0; i<totalCollList.length; j++){
                            if(selectedList[i].strCollateralId ===totalCollList[j].strCollateralId){
                                totalCollList[j].isSelected = true;
                            }
                        }   
                    }
                    this.totalApplicantsFull = totalCollList;
                } else if(result.errorMessage){
                    this.showToast(result.errorMessage, 'error');
                }

                if(this.totalApplicantsFull.length === 0){
                    this.boolNorecordsFull = true;
                }else{
                        this.boolNorecordsFull = false;
                }
                this.isLoaded = false;
        })
        .catch(error => {
                if(this.totalApplicantsFull.length === 0){
                    this.boolNorecordsFull = true;
                }else{
                    this.boolNorecordsFull = false;
                }
                this.isLoaded = false;
                console.log('result is '+JSON.stringify(error));
        })
   }

    getCollateralList(){
        this.setSpinner( true );
        this.searchLabel = 'Search';
        getCollateralList({obj: this.inputSearchParamater,loanAppId:this.recordId })
		.then(data => {
                
                if(data.responseCode == 200){
                    if(data.responseMessage ==='Success'){
                        // Sachin - SFAU-4097 -- Collateral with Repo Sale Date to be configurabel whether to allow or not ( CustomLabel - CollateralDedupeAllowRepoSale )
                        this.searchData = data.collaterals.map(collateral => ({ ...collateral, isCopyDisabled: isRepoSaleCollateralAllowedToCopy.toLowerCase() === "false" && !!collateral.Repo_Sale_Date__c }));
    
                        if(data.collaterals.length==0){
                            this.callVahaanApi();
                        } else this.setSpinner( false );
                        if(this.searchData){
                            const obj = {};
                            obj.errorOnChild = 'Please select value in any one of below searched result.';
                            obj.applicantLst = this.applicantLst;
                            this.dispatchEvent(new CustomEvent('save', {
                                detail:obj
                            }));
                        }
                        
                        // this.isLoaded = false;
                        this.showSearchResult = true;
                        this.showApplicantInsertion= false;
                        this.showErrorMessage=false;
                    }else if(data.responseMessage==='Failure'){
                        this.showErrorMessage=true;
                        this.searchData ='';
                        this.errorMessage = data.message;
                        this.isLoaded = false;
                        this.showApplicantInsertion = true;
                        if(data.collaterals.length==0){
                            this.callVahaanApi();
                        } else this.setSpinner( false );
                    }
                }else{
                    if(data.collaterals.length==0){
                        this.callVahaanApi();
                    } else this.setSpinner( false );
                }
                
                // this.isLoaded = false;
		})
		.catch(error => {
            console.log('error is '+JSON.stringify(error));
            this.showApplicantInsertion = true;
            this.errorMessage = 'API Issue - CBS returned invalid data';
            this.isLoaded = false;
            this.searchData='';
		})
    }

    callVahaanApi(){
        if(this.inputSearchParamater.Vehicle_Number__c){
            let vehicleNumber = this.inputSearchParamater.Vehicle_Number__c;
            this.getVahaanDetail(vehicleNumber, this.recordId);
        } else this.setSpinner( false );
    }

    

    enableFieldToEdit(newVehicleRecord){
        if(newVehicleRecord.Make__c){
            this.desableField.Make__c = false;
            //this.getPicklistOptions('','',newVehicleRecord.Collateral_ID__c,'Make');
        }if(newVehicleRecord.Model__c){
            this.desableField.Model__c = false;
            //this.getPicklistOptions(this.makeOptionValue,'',this.newVehicleRecord.Collateral_ID__c,'Model');
        }if(newVehicleRecord.Fuel_Type__c){
            //this.getCategoryPickListValues(this.newVehicleRecord.MMV_Master__c);
            this.desableField.Fuel_Type__c= false;
        }if(newVehicleRecord.Vehicle_Category__c){
            this.desableField.Vehicle_Category__c = false;
        }if(newVehicleRecord.Variant__c){
            //this.getPicklistOptions(this.makeOptionValue,this.modelOptionValue,this.newVehicleRecord.Collateral_ID__c,'Variant');
            this.desableField.Variant__c = false;
        }if(newVehicleRecord.Scheme__c){
            this.desableField.Scheme__c = false;
            //this.getSchemePickListValues();
        }
    }
    /*
    getFieldsAndRecords(loanAppId){
        this.isLoaded = true;
        getFieldsAndRecords({ strObjectApiName:'Collateral__c',strfieldSetName:'NewVehicle',criteriaField:'Loan__c',criteriaFieldValue: loanAppId })
		.then(data => {
            if (data) {
                this.applicantLst = data['RECORD_LIST'];
                this.isLoaded = false;
            }
		})
		.catch(error => {
            console.log('error is '+JSON.stringify(error));
            this.isLoaded = false;
		})
    }*/

    handleCollateralName(event){
        this.updateDataInVariable(event);
        let currentObj = Object.assign({}, this.newVehicleRecord);
        //currentObj.Collateral_ID__c = event.target.value;
        //currentObj.Collateral_ID__c = this.mapOfCollateralNameVsId[event.target.value];
        this.newVehicleRecord = currentObj;

        this.getPicklistOptions('','',currentObj.Collateral_Name__c,'Make');

        const product = this.isEv ? FUEL_TYPE_ELECTRIC : currentObj.Collateral_Name__c;
        this.mapVehicleCategoryFor2W(this.isTwoWheeler, product);
    }

    handleGetDepValue(){
        this.isLoaded = true;
        
        getDepreciatedValue({ coll:this.newVehicleRecord,loanApp:this.loanApplicationRecord,manufactureYear:this.manufactureYear })
		.then(data => {
            if (data) {
                this.newVehicleRecord.Grid_Depreciated_Value__c = data['X'+this.manufactureYear+'__c'] ?? 'NA';
                this.isLoaded = false;
            }
		})
		.catch(error => {
            console.log('error is '+JSON.stringify(error));
            this.newVehicleRecord = { ...this.newVehicleRecord, Grid_Depreciated_Value__c: 'NA'  };
            this.isLoaded = false;
		})
    }

    getVisibleFields(){
        this.isLoaded = true;
        let screen = this.screenType;
        let stage = this.stageValue;
        let profile = this.loggedInUserProfile;
        let typeOfWheeler='Both';


        getVisibleFields({ strScreen :screen, strStage :stage, strProfile :profile, typeOfWheeler: typeOfWheeler })
		.then(result => {
            this.visibledFields = result;
            result.forEach(input => {
                if(this.template.querySelector('[data-id="'+input+'"]') != null){
                    this.template.querySelector('[data-id="'+input+'"]').classList.remove('slds-hide');
                }
            });
            this.isLoaded = false;
		})
		.catch(error => {
            console.log('result is '+error)
            this.isLoaded = false;
		})
    }

    handleVahaanData(){
        let vehicleNumber = this.newVehicleRecord.Vehicle_Number__c;
        // SFAU-5566 - vahhan api issue
        if (vehicleNumber != undefined && vehicleNumber != null && vehicleNumber != 'undefined' && vehicleNumber != ''){
            this.getVahaanDetail(vehicleNumber, this.recordId);
        }
    }
    
    getVahaanDetail(vehicleNumber, loanApplicationId){
        this.setSpinner( true );
        getVahaanDetail({ registrationNumber:vehicleNumber, loanApplicationId })
		.then(async data => {
            if (data) {
                this.isVahaanCheckIsMendatory = false;
                let returndata = data.result;
                // :TODO - utilize local / session storage instead -- refresh proof / more data can be cached
                window.dispatchEvent( new CustomEvent('updatestate', { detail: { sectionName: 'vehicle', vahanRaw: data.result ?? {}, bubbles: true, composed: true } } ) );
                if(data.result && Object.keys(data.result).length){
                    const { vehicleRecord, disabledFields } = this.populateVahanDetails(data.result);
                    this.newVehicleRecord = vehicleRecord;
                    this.dataFromApi = disabledFields;
                    this.errorMessage = 'Match found in Vahaan. Click Search Again for CBS search';
                    // this.disabledFetchVahhan = true;
                    // this.searchLabel = 'Search Again';
                    // let currentObj = Object.assign({}, this.newVehicleRecord);
                    // let readOnlydata = Object.assign({}, this.dataFromApi);
                    // let dataResult = data.result;
                    // const { vehicleDetails, insuranceDetails, financersDetails, nocCcDetails, ownerDetails, pdf, metadata, challanDetails } = data.result || { };
                    // this.newVehicleRecord.Vahaan_Response__c = JSON.stringify(data.result);
                    // currentObj.IsDetailsFromVahaanApi__c =true;
                    // if(!currentObj.Vehicle_Number__c && vehicleDetails.registrationNo){
                    //     currentObj.Vehicle_Number__c = vehicleDetails.registrationNo;
                    //     readOnlydata.Vehicle_Number__c = vehicleDetails.registrationNo?true:false; 
                    //     /*let vehicleNumber =  dataResult.registrationNumber;
                    //     let rtoCode = vehicleNumber.substr(0, 2);*/
                    //     //this.getRegistrationCityPickListValues(vehicleDetails.registrationNo);
                    // }
                    
                    // if(!currentObj.Chasis_Number__c && vehicleDetails.chassisNo){
                    //     currentObj.Chasis_Number__c =vehicleDetails.chassisNo;
                    //     readOnlydata.Chasis_Number__c = vehicleDetails.chassisNo?true:false;
                    //     this.inputSearchParamater.Chasis_Number__c = vehicleDetails.chassisNo;
                    // }
                    // if(!currentObj.Engine_Number__c && vehicleDetails.engineNo){
                    //     currentObj.Engine_Number__c =vehicleDetails.engineNo;
                    //     readOnlydata.Engine_Number__c = vehicleDetails.engineNo?true:false;
                    //     this.inputSearchParamater.Engine_Number__c = vehicleDetails.engineNo;
                    // }
                    // if(financersDetails.financersName){
                    //     currentObj.HPN_With_Financiers_Name__c =financersDetails.financersName;
                    //     let financier = financersDetails.financersName;
                    //     if(financier.includes("AU")){
                    //         currentObj.NOC_Status__c='release/with AU';
                    //         this.showNocStatus = true;
                    //     }
                    //     readOnlydata.HPN_With_Financiers_Name__c = true;
                    // }else{
                    //     currentObj.HPN_With_Financiers_Name__c ='NA';
                    //     readOnlydata.HPN_With_Financiers_Name__c = false;
                    // }
                    
                    // //readOnlydata.HPN_With_Financiers_Name__c = dataResult.financier?true:false;
                    // if(vehicleDetails.ownerSrNo){
                    //     currentObj.Owner_Serial_number__c =vehicleDetails.ownerSrNo;
                    //     readOnlydata.Owner_Serial_number__c = vehicleDetails.ownerSrNo?true:false;
                    // }
                    
                    // if(ownerDetails.ownersName){
                    //     currentObj.Current_Owner_Name__c  =ownerDetails.ownersName;
                    //     readOnlydata.Current_Owner_Name__c = ownerDetails.ownersName?true:false;
                    //     this.vahaanOwnerName = ownerDetails.ownersName;
                    //     // currentObj.SVSH_SVOH__c = this.isSameAsVehicleOwner;
                    // }
                    // currentObj.Blacklist_Details__c = vehicleDetails.blackListDetails ?? currentObj.Blacklist_Details__c;
                    // currentObj.Challan_Info__c = vehicleDetails.challanInfo ?? currentObj.Challan_Info__c;
                    // currentObj.Challan_Overdue_Amount__c = challanDetails?.reduce((overdue, challan) => {
                    //     if(challan.status === 'PENDING'){
                    //         overdue += challan.totalAmount;
                    //     }
                    //     return overdue;
                    // }, 0);
                    this.newVehicleRecord = await this.populateRegistrationCities(vehicleRecord, disabledFields, data.result);
                    // /*if(dataResult.registeredAt){
                    //     currentObj.Registration_City__c = dataResult.registeredAt;
                    //     readOnlydata.Registration_City__c = dataResult.registeredAt?true:false;
                    // }*/
                    

                    // /*currentObj.Vehicle_Color__c = dataResult.color;
                    // readOnlydata.Vehicle_Color__c = dataResult.color?true:false;*/

                    // /*if(!this.manufactureMonth || !this.manufactureYear){
                    //     let yearandmonth = dataResult.manufacturedMonthYear;

                    //     const myArray = yearandmonth.split("-");

                    //     this.manufactureYear = myArray[1];
                    //     readOnlydata.manufactureYear = this.manufactureYear?true:false;

                    //     this.manufactureMonth = myArray[0];
                    //     readOnlydata.manufactureMonth = this.manufactureMonth?true:false;
                    // }*/
                    // // this.newVehicleRecord = currentObj;
                    // this.dataFromApi = readOnlydata;
                    this.getVahanReport();

                }else{
                    this.desableField.Make__c = false;
                    this.showToast( data.errorMessage, 'error' );
                }
                this.isLoaded = false;
            }else{
                this.isVahaanCheckIsMendatory = false;
            }
		})
		.catch(error => {
            console.log('error is '+JSON.stringify(error));
            this.isLoaded = false;
            this.isVahaanCheckIsMendatory = false;
		})
    }
    // SFAU-3486
    getVahanReport(){
        createVahanReport({loanId:this.recordId})
        .then(data=>{
            this.collateralLink = data;
        })
        .catch(error => {
            console.log('error is '+JSON.stringify(error));
           
		})

    }

    validateNameMatch(fullName,strType,strCollateralId){
        this.isLoaded = true;
        validateNameMatch({ strName: fullName, strType: strType, strApplicantId: strCollateralId})
                    .then(resultNameMatch => {
                        this.isLoaded = false;
                    })
                    .catch(error => {
                        console.log('validateNameMatch error'+error);
                        this.isLoaded = false;
                    })
    }
    
    createCollateral(){
        this.isLoaded = true;
        createCollateral({ loanId: this.recordId, collateralType:'Used'})
                    .then(data => {
                        this.isLoaded = false;
                        this.newVehicleRecord = { ...this.newVehicleRecord, ...data, /*...{ Collateral_ID__c: `${this.loanApplicationRecord.Product__c}${data.Name}${Math.floor(Math.random() * 10)}` }*/ };
                    })
                    .catch(error => {
                        console.log('validateNameMatch error'+error);
                        this.isLoaded = false;
                    })
    }

    getRegistrationCityPickListValues(rtoCodeValue, fromLead){
        getRegistrationCityPickListValues({rtoCode:rtoCodeValue})
		.then(data => {
            if (data) { 
                this.ragistrationCityOptions = data.RTOName;
                this.mapOfRtoCityVsCode = data;
                this.newVehicleRecord.Registration_City__c = fromLead == true ? '' : this.newVehicleRecord.Registration_City__c;
                if(data.RTOName && data.RTOName.length==1){
                    this.newVehicleRecord.Registration_City__c = data.RTOName[0].value
                    let rtoCityName = data.RTOName[0].value;
                    if(data[rtoCityName]){
                        this.rtoCodeOptions = data[rtoCityName];
                        if(data[rtoCityName].value.length==1){
                            let rtoCodeOptions = data[rtoCityName];
                            this.newVehicleRecord.Rto_Code__c = rtoCodeOptions[0].value
                        }
                    }
                    /*if(this.newVehicleRecord.Registration_City__c){
                        this.dataFromApi.Registration_City__c = true;
                        if(this.newVehicleRecord.Rto_Code__c){
                            this.dataFromApi.Rto_Code__c = true;
                        }
                    }*/
                    
                }
                
            }
		})
		.catch(error => {
            console.log('error is '+JSON.stringify(error));
            this.isLoaded = false;
		})
    }

    handleToggleChange(event){
        let currentObj = Object.assign({}, this.newVehicleRecord);
        currentObj[event.target.name] = event.target.checked;
        
        if(event.target.name==='Insurance_Funding__c' && event.target.checked ===false){
            currentObj.Insurance_Value__c ='';
        }else if(event.target.name==='LS__c' && event.target.checked ===false){
            currentObj.LS_Value__c=''
        }

        this.newVehicleRecord = currentObj;

        
    }

    handleSchemeChange(event){
        this.updateDataInVariable(event);
        this.getSchemeMasterRecord(event.target.value);
        
    }

    getSchemeMasterRecord(selectedId){
        this.isLoaded = true;
        getSchemeMasterRecord({schemeId:selectedId})
		.then(data => {
            if (data) { 
                this.schemeMasterRecord = data;
                let schemeObj = data;
                let loanObj = this.loanApplicationRecord;
                let isValidRoi = false;
                let isValidLoanAmount = false;
                let isValidTenure= false;
                if(parseFloat(schemeObj.MAXROI__c)>=parseFloat(loanObj.ROI__c) && parseFloat(schemeObj.MINROI__c)<=parseFloat(loanObj.ROI__c)){
                    isValidRoi = true;
                    //this.showToast('Rate of Intrest should Match with scheme','info');
                }
                if(parseInt(schemeObj.MAXLOANAMOUNT__c)>=parseInt(loanObj.Loan_Amount__c) && parseInt(schemeObj.MINLOANAMOUNT__c)<=parseInt(loanObj.Loan_Amount__c)){
                    isValidLoanAmount = true;
                    //this.showToast('Rate of Intrest should Match with scheme','info');
                }
                if(parseInt(schemeObj.MAXTENURE__c)>=parseInt(loanObj.Tenure__c) && parseInt(schemeObj.MINTENURE__c)<=parseInt(loanObj.Tenure__c)){
                    isValidTenure = true;
                    //this.showToast('Rate of Intrest should Match with scheme','info');
                }
                if(isValidLoanAmount && isValidTenure && isValidRoi){
                    this.getDepreciatedObj()
                }else{
                    this.isModalOpen =true;
                }
                this.isLoaded = false;
            }else{
                this.isLoaded = false;
            }
		})
		.catch(error => {
            console.log('error is '+JSON.stringify(error));
            this.isLoaded = false;
		})
    }

    getDepreciatedObj(){
        this.isLoaded = true;
        getDepreciatedObj({coll:this.newVehicleRecord,app:this.applicantRecord})
		.then(data => {
            if (data) { 
                this.depreciatedObjRecord = data;
                this.newVehicleRecord = { ...this.newVehicleRecord, Approved_LTV__c: data.LTV_Approved__c, Assessment_Method__c: 'LTV' };
                this.isLoaded = false;
            }else{
                this.isLoaded = false;
            }
		})
		.catch(error => {
            console.log('error is '+JSON.stringify(error));
            this.isLoaded = false;
		})
    
    }

    showVehicleDetail(event){
        const obj = event.detail;
        if(obj.ROI__c){
            this.loanApplicationRecord.ROI__c =obj.ROI__c;
        }
        if(obj.Loan_Amount__c){
            this.loanApplicationRecord.Loan_Amount__c =obj.Loan_Amount__c;
            this.newVehicleRecord.Apportioned_Loan_Amount__c = obj.Loan_Amount__c;
        }
        if(obj.Tenure__c){
            this.loanApplicationRecord.Tenure__c =obj.Tenure__c;
        }

        let schemeObj = this.schemeMasterRecord;
        let loanObj = this.loanApplicationRecord;
        let isValidRoi = false;
        let isValidLoanAmount = false;
        let isValidTenure= false;
        if(parseFloat(schemeObj.MAXROI__c)>=parseFloat(loanObj.ROI__c) && parseFloat(schemeObj.MINROI__c)<=parseFloat(loanObj.ROI__c)){
            isValidRoi = true;
            //this.showToast('Rate of Intrest should Match with scheme','info');
        }
        if(parseInt(schemeObj.MAXLOANAMOUNT__c)>=parseInt(loanObj.Loan_Amount__c) && parseInt(schemeObj.MINLOANAMOUNT__c)<=parseInt(loanObj.Loan_Amount__c)){
            isValidLoanAmount = true;
            //this.showToast('Rate of Intrest should Match with scheme','info');
        }
        if(parseInt(schemeObj.MAXTENURE__c)>=parseInt(loanObj.Tenure__c) && parseInt(schemeObj.MINTENURE__c)<=parseInt(loanObj.Tenure__c)){
            isValidTenure = true;
            //this.showToast('Rate of Intrest should Match with scheme','info');
        }
        if(isValidLoanAmount && isValidTenure && isValidRoi){
            this.getDepreciatedObj()
            this.dispatchEvent( new CustomEvent('updateloandetail') );
        }else{
            this.isModalOpen =true;
        }

        this.showVehicle = true;
        this.showLoanDetails = false;
        this.getVisibleFields();
    }

    handleIBBValue(){
        this.isLoaded = true;
        let isValid = true;
        let errorMsg ='To get IBB Value These Fields Are Mandatory: ';
        if(!this.makeOptionValue){
            errorMsg =errorMsg +'Make,'
            isValid=false;
        }
        if(!this.modelOptionValue){
            errorMsg =errorMsg +'Model,'
            isValid=false;
        }
        if(!this.variantOptionValue){
            errorMsg =errorMsg +'Variant,'
            isValid=false;
        }
        if(!this.manufactureYear){
            errorMsg =errorMsg +'Manufacture Year,'
            isValid=false;
        }
        if(!this.manufactureMonth){
            errorMsg =errorMsg +'Manufacture Month,'
            isValid=false;
        }
        if(!this.newVehicleRecord.Kilometer__c){
            errorMsg =errorMsg +'Kilometer,'
            isValid=false;
        }
        if(!this.newVehicleRecord.Vehicle_Color__c){
            errorMsg =errorMsg +'Vehicle Color'
            isValid=false;
        }
        if(!this.newVehicleRecord.Owner_Serial_number__c){
            errorMsg =errorMsg +'Owner Serial Number'
            isValid=false;
        }

        if(isValid){
            const detail = {
                make: this.makeOptionValue,
                model: this.modelOptionValue,
                variant:this.variantOptionValue,
                month:this.manufactureMonth,
                location:'delhi',
                year:this.manufactureYear
            };
            getIBBValue({param:detail,coll:this.newVehicleRecord})
            .then(data => {
                if (data) { 
                    if(data.ibbValue){
                        this.newVehicleRecord.IBB_Value__c =data.ibbValue;
                        // SFAU-5715
                        this.newVehicleRecord.IBB_API_Value__c = data.ibbValue;
                        this.isIBBValuedisabled =true;
                    }else{
                        this.showToast(data.errorMsg,'error');
                    }
                    this.isLoaded = false;
                }else{
                    this.isLoaded = false;
                }
            })
            .catch(error => {
                console.error('error is '+JSON.stringify(error));
                this.isLoaded = false;
            })
        }else{
            this.isLoaded = false;
            const event = new ShowToastEvent({
                title: '',
                message: errorMsg,
                variant: 'error',
                mode: 'Sticky'
            });
            this.dispatchEvent(event);
            
        }
    }


    handleAdditionalInformationClick(){
        const vahanResponse = VAHAN_FIELDS.reduce( (collateral, field) => ({...collateral, [field]: this.newVehicleRecord[field] }),
            { Vehicle_Number__c: this.inputSearchParamater.Vehicle_Number__c, Engine_Number__c: this.inputSearchParamater.Engine_Number__c, Chasis_Number__c: this.inputSearchParamater.Chasis_Number__c }
        );
        this.resetScreen();
        this.dataFromApi = VAHAN_FIELDS.reduce( ( disabledFields, field ) => ({ ...disabledFields, [ field ]: !!vahanResponse[field] }), this.dataFromApi );
        this.createCollateral();
        let loanApplication = this.loanApplicationRecord ;
        let curObj = this.newVehicleRecord;
        curObj.Vehicle_Usage__c=loanApplication.Vehicle_use__c;
        curObj.Apportioned_Loan_Amount__c=loanApplication.Loan_Amount__c;
        //curObj.Collateral_ID__c = this.randomCollateralId;
        curObj.Insurance_Funding__c = false;
        curObj.Collateral_Type__c = 'New';
        curObj.LS__c = false;

        this.title = 'Add New Vehicle Information';
        this.addNewApplicant = true;
        this.showMainSection = false;
        this.showSection = false;
        this.showCancelButton = true;
        this.showSearchScreen = false;
        this.newVehicleRecord = { ...curObj, ...vahanResponse };
        this.getPicklistOptions( '', '', this.vehicleType, 'Make' );
        this.getVisibleFields();
    }

    _debounceInputTimer;
    handleInputChange(event){

        const { name: fieldApi, value: fieldValue } = event.target;
        clearTimeout(this._debounceInputTimer);

        this._debounceInputTimer = setTimeout(() => {
            if( this.disabledFetchVahhan && fieldApi === VEHICLE_NUMBER_FIELD && this.inputSearchParamater[fieldApi] !== fieldValue ){
                window.dispatchEvent( new CustomEvent('updatestate', { detail: { sectionName: 'vehicle', vahanRaw: {}, bubbles: true, composed: true } } ) );
            }
    
            this.inputSearchParamater[fieldApi] = fieldValue;
    
            let uiParamater = this.inputSearchParamater;
            let chaseNum = uiParamater.Chasis_Number__c;
            let engineNum = uiParamater.Engine_Number__c;
            let vehicleNum = uiParamater.Vehicle_Number__c;
            
            if(chaseNum || engineNum || vehicleNum){
                this.errorOnChild  = 'Please click on search button to get collateral.';
                const obj = {};
                obj.errorOnChild = this.errorOnChild;
                obj.applicantLst = this.applicantLst;
                this.dispatchEvent(new CustomEvent('save', {
                    detail:obj
                }));
            }else{
                this.errorOnChild  = 'Please enter value in any one of below search paramater to get collateral.';
                const obj = {};
                obj.errorOnChild = this.errorOnChild;
                obj.applicantLst = this.applicantLst;
                this.dispatchEvent(new CustomEvent('save', {
                    detail:obj
                })); 
            }
        }, 1000);

        
    }

    handleMakeValueChange(event){
        //this.updateDataInVariable(event);
        this.makeOptionValue = event.target.value;
        this.desableField.Model__c = false;
        this.fuelTypeOptionValue = '';
        let makeValue = event.target.value;
        this.getPicklistOptions(makeValue,'',this.vehicleType,'Model');
        /*
        const obj = this.usedProductOptions;
        this.modelOptions = obj[event.detail.value];
        this.modelOptions = this.usedProductOptions.find((item)=>item === this.makeOptionValue);
        /*if(this.screenType === 'New'){
            this.getModelPicklistOptions(event.detail.value);
        }

        if(this.screenType === 'Used'){
            this.modelOptions = this.usedProductOptions.find((item)=>item === this.makeOptionValue);
        }*/
        
    }

    handleModelValueChange(event){
        //this.updateDataInVariable(event);
        this.modelOptionValue = event.target.value;
        let makeValue = this.makeOptionValue;
        let modelValue = event.target.value;
        this.getPicklistOptions(makeValue,modelValue,this.vehicleType,'Variant');
    }

    updateDataInVariable(event){
        let currentObj = Object.assign({}, this.newVehicleRecord);
        currentObj[event.target.name] = event.target.value;
        this.newVehicleRecord = currentObj;
    }
    _debounceTimer;
    handleValueChange(event){
        //alert('in value changes ')
        const { name: fieldApi, label: fieldLabel, value: fieldValue } = event.target;
        this.updateDataInVariable(event);

        if(fieldLabel==='manufactureYear'){
            this.manufactureYear = fieldValue;
            if (Number(fieldValue) > Number(this.currentYear)) {
                this.showToast('Manufacture Year can not be future year', 'error');
                this.manufactureYear = TODAY.getFullYear();
            }
        }else if(fieldLabel==='manufactureMonth'){
            if(Number(this.manufactureYear) === TODAY.getFullYear() ){
                if(+event.target.value > TODAY.getMonth() ){
                    this.showToast('Manufacture Month can not be of future month of the current year', 'error');
                    this.manufactureMonth = ('0' + (TODAY.getMonth() + 1)).slice(-2);
                }
            }
            this.manufactureMonth = fieldValue;
        } else if(fieldApi === VEHICLE_NUMBER_FIELD && fieldValue?.length > 1){
            clearTimeout(this._debounceTimer);

            this._debounceTimer = setTimeout(() => {
                if( this.disabledFetchVahhan && fieldApi != VEHICLE_NUMBER_FIELD && this.newVehicleRecord[fieldApi] !== fieldValue ){
                    window.dispatchEvent( new CustomEvent('updatestate', { detail: { sectionName: 'vehicle', vahanRaw: {}, bubbles: true, composed: true } } ) );
                }
                this.populateRegistrationCities(this.newVehicleRecord, this.desableField, {});
            }, 2000);
        }
        else if(fieldApi == 'RC_is_on_name_of_Applicant__c'){ // SFAU-5773
            this.newVehicleRecord['BT_Loan_Status__c'] = undefined;
        }

        
    }

    handleRegCityChange(event){
        this.newVehicleRecord.Registration_City__c = event.target.value;
        let rtoccodeoptions = this.mapOfRtoCityVsCode;
        this.rtoCodeOptions = rtoccodeoptions[event.target.value];
    }

    getSelectedCollateral(event){
        this.selectedCollList = event.detail;
    }

    handleSubmitForm(){
        restricAccess({
            compName: 'ausfVehicleListUsed' ,loanId: this.recordId
            })
            .then(data => {
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save Vehicle',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }else{

                //this.addNewApplicant = false;
                let isValid = this.isInputValid();
                let isYearValid = this.isYearInputValid();
                if(!isValid || !isYearValid){
                    const inputWithError = this.template.querySelector('.slds-has-error');
                    if(inputWithError) this.showToast('Please fill the Mandatory Data','error');
                    inputWithError?.focus();
                    return;
                } else if( !validateLoanFunding( OTHER_FUNDING_ITEMS_MAPPINGS, this.newVehicleRecord ) ){
                    this.showToast( otherFundingValidationError );
                    return;
                } else if(this.loanStage == 'Ops Maker' || this.loanStage == 'Ops Author' || this.loanStage == 'PDD'){
                    this.showToast( 'Cannot update collateral at this stage','error' );
                    return;
                }

                if(this.newVehicleRecord.LS__c === 'No' || this.newVehicleRecord.LS__c  === false ){
                    this.showToast( 'An Approval from NBM will be required if LS is not taken', 'info' );
                }

                let color = this.newVehicleRecord.Vehicle_Color__c; 
                if(!this.isVahaanCheckIsMendatory){
                    if(color || this.isTwoWheeler){
                        if(isValid && isYearValid){
                            this.upsertVehicleInfo();
                        }
                    }else{
                        this.showToast('Please Select Vehicle Color','error');
                    }
                }else{
                    this.showToast('Vahaan Check is Mandatory','error');
                }
            }
        })
        .catch(error => {
            console.log('error is ' + JSON.stringify(error));
        })
    }

    async upsertVehicleInfo() {
        this.isLoaded = true;
        let currentObj = Object.assign({}, this.newVehicleRecord);
        currentObj.Loan__c = this.recordId;
        if(!currentObj.MMV_Master__c){
            currentObj.MMV_Master__c = this.variantOptionValue;
        }
        currentObj.Manufacture_year_month__c = this.manufactureYear+this.manufactureMonth;
        currentObj.Insurance_Funding__c = currentObj.Insurance_Funding__c?'Yes':'No';
        currentObj.Manual_Make__c ='';
        currentObj.Manual_Model__c ='';
        currentObj.Manual_Variant__c ='';
        /*currentObj.Body__c = currentObj.Body__c?'Yes':'No';
        currentObj.RTO_Tax__c = currentObj.RTO_Tax__c?'Yes':'No';
        currentObj.Accessories_Funding__c = currentObj.Accessories_Funding__c?'Yes':'No';*/
        currentObj.LS__c = currentObj.LS__c?'Yes':'No';
        currentObj.Other_Funding_Total__c = this.otherFundingTotal;
        currentObj.IntegrationReadOnlyData__c = JSON.stringify(this.dataFromApi);
        //this.newVehicleRecord = currentObj;

        //this.newVehicleRecord['Loan__c'] = this.recordId;
        
        //this.aplicantRecord['Id'] = applicantIdInput;

        if (currentObj) {
            this.isloading = true;
            await this.validateMaterialFields(MATERIAL_SCREEN_VEHICLE_LIST_USED, this.recordId, [ MAKE_FIELD_API ]);
            upsertCollateral({collateral : currentObj,screen:this.screenType,cbsCollateralList:this.selectedCollList})
                .then(result => {
                    const { collaterals, wasCollateralUpdated } = result;
                    this.isLoaded = false;
                    this.addNewApplicant = false;
                    this.showMainSection = true;
                    this.showSection = true;
                    this.applicantLst=collaterals;
                    let collateralRecId = collaterals[0].Id;
                    this.collateralUpdates = wasCollateralUpdated;
                    this.validateNameMatch(this.vahaanOwnerName,'Vahaan',collateralRecId );
                    this.validateNameMatch(this.collateralOwnerName,'Collateral',collateralRecId);
                    const Obj = {};
                    Obj.applicantLst = this.applicantLst;
                    this.dispatchEvent(new CustomEvent('save', {
                        detail:Obj
                    }));

                    if(this.applicantLst){
                        let constVal = 1000000;
                        let loanApp = this.loanApplicationRecord;
                        let loanAmount =  parseInt(loanApp.Loan_Amount__c);
                        let dataCol = this.applicantLst;
                        for (let i = 0; i < dataCol.length; i++) {
                            dataCol[i].isDisableValuation = true;
                            //if(dataCol[i].Certified_Value__c){
                                let certifiedVal = parseInt(dataCol[i].Certified_Value__c);
                                if(certifiedVal>0 && certifiedVal<=constVal){
                                    dataCol[i].isDisableValuation = !this.collateralUpdates[dataCol[i].Id];;
                                }else if(certifiedVal>constVal){
                                    dataCol[i].isDisableValuation = !this.collateralUpdates[dataCol[i].Id];;
                                    let optionValuer = [{label:'Auto Inspect',value:'Auto Inspect'},{label:'Other valuation',value:'Other valuation'}];
                                    this.valuerNameCodeOptions = optionValuer;
                                }else if(certifiedVal===0 || isNaN(certifiedVal)){
                                    dataCol[i].isDisableValuation = !this.collateralUpdates[dataCol[i].Id];;
                                    if( loanAmount < MAX_CAN_DO_LOAN_AMOUNT ){
                                        this.defaultValue = 'Cando';
                                        let optionValuer = [{label:'Auto Inspect',value:'Auto Inspect'},{label:'Other valuation',value:'Other valuation'},{label:'Cando',value:'Cando'}];
                                        this.valuerNameCodeOptions = optionValuer;
                                    }else if( loanAmount > MAX_CAN_DO_LOAN_AMOUNT){
                                        let optionValuer = [{label:'Auto Inspect',value:'Auto Inspect'},{label:'Other valuation',value:'Other valuation'}];
                                        this.valuerNameCodeOptions = optionValuer;
                                    }
                                    
                                }
                            //}
                        }
                       /* if(dataCol[0].isDisableValuation === false){
                            this.showToast('You needs to upload Certified Valuation mandatorily before sending to credit (Document Name - Certified Valuation)','info');
                        }*/
                        
                        this.applicantLst = dataCol;
                    }

                })
                .catch(error => {
                    this.isLoaded = false;
                    this.showToast( this.getErrors( error ) ?? EDIT_NOT_ALLOWED_ERROR_MESSAGE, 'error');
                    this.error =error;
                });

        }
    }

    getErrors( error ){
        return error?.body?.message ?? error?.body?.pageErrors?.[0].message;
    }

    get ltvOfferedOnVehicleCost(){
        let currentObj = Object.assign({}, this.newVehicleRecord);
        let loanAmount = this.newVehicleRecord.Apportioned_Loan_Amount__c ? this.newVehicleRecord.Apportioned_Loan_Amount__c : 0;
        let vehicleCost = currentObj.Vehicle_Cost__c?currentObj.Vehicle_Cost__c:0;
        let finalValue=0;
        //parseInt Converts a string to an integer.
        if(parseInt(loanAmount,10) && parseInt(vehicleCost,10)>0){

            
                finalValue = (parseInt(loanAmount,10)/ parseInt(vehicleCost,10))*100
                //this.finalDisValue = finalValue;
                currentObj.LTV_offered_On_road__c = finalValue.toFixed(2);
                this.newVehicleRecord = currentObj;
            
        }
        return finalValue.toFixed(2);
    }

    get ltvOfferedStyles(){
        return this.isLTVInvalid ? 'slds-has-error' : '';
    }

    get ltvOfferedLabelStyles(){
        return this.isLTVInvalid ? 'slds-form-element__label slds-text-color_error' : 'slds-form-element__label';
    }

    get isLTVInvalid(){
        return !!(+this.newVehicleRecord?.LTV_offered_On_final_cost__c && +this.newVehicleRecord.Apportioned_Loan_Amount__c && (this.ltvOfferedOnVehicleFinalCost > 100));
    }

    get ltvOfferedOnVehicleFinalCost(){
        let currentObj = Object.assign({}, this.newVehicleRecord);
        // SFAU-4476 - total loan amount to be considered instead of Apportioned
        // let loanAmount = this.newVehicleRecord.Apportioned_Loan_Amount__c ? this.newVehicleRecord.Apportioned_Loan_Amount__c : 0;
        const totalLoanAmount = this.newVehicleRecord.Loan__r?.Total_Loan_Amount__c ?? this.loanApplicationRecord?.Total_Loan_Amount__c;
        if(this.isTwoWheeler){
            return currentObj.LTV_offered_On_final_cost__c;
        }

        let vehicleCost = currentObj.Final_Cost__c ? currentObj.Final_Cost__c : 0;
        let finalValue=0;
        //parseInt Converts a string to an integer.
        if(parseInt(totalLoanAmount,10) && parseInt(vehicleCost,10)>0){

            
                finalValue = (parseInt(totalLoanAmount,10)/ parseInt(vehicleCost,10))*100
                //this.finalDisValue = finalValue;
                currentObj.LTV_offered_On_final_cost__c = finalValue.toFixed(2);
                this.newVehicleRecord = currentObj;
            
        }
        return finalValue.toFixed(2);
    }

    get loanEligibilty(){
        let currentObj = Object.assign({}, this.newVehicleRecord);
        let loanAmount = this.newVehicleRecord.Apportioned_Loan_Amount__c ? this.newVehicleRecord.Apportioned_Loan_Amount__c : 0;
        let approvedLtvAmount = currentObj.Approved_LTV__c?currentObj.Approved_LTV__c:0;
        let finalValue=0;
        //parseInt Converts a string to an integer.

            if(parseInt(approvedLtvAmount,10) && parseInt(loanAmount,10)!==0){
                finalValue = (parseInt(approvedLtvAmount,10)/parseInt(loanAmount,10))*100
                //this.finalDisValue = finalValue;
                currentObj.Loan_Eligibilty__c = finalValue.toFixed(2);
                this.newVehicleRecord = currentObj;
            }
        return finalValue.toFixed(2);
    }

    get calculateCustomerEquity(){
        let currentObj = Object.assign({}, this.newVehicleRecord);
        let loanAmount = this.newVehicleRecord.Apportioned_Loan_Amount__c ? this.newVehicleRecord.Apportioned_Loan_Amount__c : 0;
        let vehicleCost = currentObj.Vehicle_Cost__c?currentObj.Vehicle_Cost__c:0;
        let finalValue=0;
        //parseInt Converts a string to an integer.

            if(parseInt(vehicleCost,10) && parseInt(vehicleCost,10)>parseInt(loanAmount,10)){
                finalValue = (parseInt(vehicleCost,10)-parseInt(loanAmount,10))
                //this.finalDisValue = finalValue;
                currentObj.Customer_equity__c = finalValue.toFixed(2);
                this.newVehicleRecord = currentObj;
            }
        return finalValue.toFixed(2);
    }

    get isEv(){
        return this.newVehicleRecord?.Fuel_Type__c?.toLowerCase() === FUEL_TYPE_ELECTRIC;
    }
    /**
     * SFAU-4476
     * Changes in Final Cost of vehicle / Certified value / Valution amount to be considered instead of vehicle cost
     */
    get finalPrice(){
        let currentObj = Object.assign({}, this.newVehicleRecord);
        let vehicleCost = currentObj.Vehicle_Cost__c?currentObj.Vehicle_Cost__c:0;
        let insuranceAmount = currentObj.Insurance_Value__c?currentObj.Insurance_Value__c:0;
        let lsAmount = currentObj.LS_Value__c?currentObj.LS_Value__c:0;
        let finalValue=0;

        const { Valuation_Amount__c: valuationAmount, Certified_Value__c: certifiedValue, IBB_Value__c: ibbValue } = currentObj || {};
        const certifiedValueNum = +certifiedValue?.replace(/,/g, ''), valuationAmountNum = +valuationAmount?.replace(/,/g, ''), ibbValueNum = +ibbValue?.replace(/,/g, '');

        const applicableCost = this.getApplicableVehicleCostMultiplier( vehicleCost, ibbValueNum, certifiedValueNum || valuationAmountNum ) || 0;
        //parseInt Converts a string to an integer.

        if( applicableCost || insuranceAmount || lsAmount ){
            finalValue = (parseInt( applicableCost, 10 ) + parseInt(insuranceAmount,10) + parseInt(lsAmount,10));
            //this.finalDisValue = finalValue;
            if(finalValue.toFixed(2) !== this.newVehicleRecord.Final_Cost__c){
                //...get Vehicle category
                const product = this.isEv ? FUEL_TYPE_ELECTRIC : this.newVehicleRecord.Collateral_Name__c;
                this.evaluateVehicleCategoryBasedOnRoadPrice(product, finalValue);   
            }
            currentObj.Final_Cost__c = finalValue.toFixed(2);
            this.newVehicleRecord = currentObj;
            }
        return finalValue.toFixed(2);
    }

    get vehicleCost(){

        const { Vehicle_Cost__c: vehicleCost, IBB_Value__c: ibbValue, Valuation_Amount__c: valuationAmount, Certified_Value__c: certifiedValue } = this.newVehicleRecord || {};
        const ibbValueNum = +ibbValue?.replace(/,/g, ''), valuationAmountNum = +valuationAmount?.replace(/,/g, ''), certifiedValueNum = +certifiedValue?.replace(/,/g, '');

        // if(certifiedValue || (isNaN(ibbValueNum) && isNaN(valuationAmountNum) )) return vehicleCost;

        /**
         * SFAU-4476
         * updates on 1st Aug 23
         * Vehicle cost to be 120 ( configured in VehicleCostMultiplicand label )% of least amount ibb / valuation / grid value
         */
        // const vehicleCostMultiplier = this.getApplicableVehicleCostMultiplier( vehicleCost, ibbValueNum, certifiedValueNum || valuationAmountNum );
        const applicableCost = this.getApplicableVehicleCostMultiplier( vehicleCost, ibbValueNum, certifiedValueNum || valuationAmountNum ) || 0;
        if( applicableCost !== vehicleCost ){
            this.newVehicleRecord.Vehicle_Cost__c =  applicableCost.toFixed();
        }
        return this.newVehicleRecord.Vehicle_Cost__c;
    }

    getApplicableVehicleCostMultiplier = ( vehicleCost, ibbValueNum, valuationAmountNum ) => {

        const values = [
            ibbValueNum ? ( +vehicleCostMultiplicand / 100 ) * ibbValueNum : Number.POSITIVE_INFINITY,
            valuationAmountNum ? valuationAmountNum : Number.POSITIVE_INFINITY,
            // depreciatedAmountNum ? depreciatedAmountNum : Number.POSITIVE_INFINITY //SFAU-4476 - Grid will not be considered
        ]
        .filter((num) => !isNaN(num))
        .sort(( a,b ) => (a - b) );

        return values.length && values[0] !== Number.POSITIVE_INFINITY ? values[0] : vehicleCost;
    }

    handleAdditionalClick(){
        this.showBackButton = true;
        this.showCancelButton = false;
        this.title ='Additional Collateral Detail';
    }

    handleBack(){
        this.showBackButton = false;
        this.showCancelButton = true;
        this.title ='Vehicle Information';
        this.getVisibleFields();
    }

    isInputValid() {
        // let visibledFieldList = this.visibledFields;
        // const inputFields = [ ...this.template.querySelectorAll(".validate") ];
        // //&& visibledFieldList.includes(inputField.name)
        // const isValid = inputFields.reduce((isValidSoFar, input) => {
        //     if (visibledFieldList.includes(input.name)) {
        //         let isFieldValid = false;
        //         if(!input.value){
        //             isFieldValid = false;
        //             input.setCustomValidity("Complete this field");
        //         } else {
        //             isFieldValid = true;
        //             input.setCustomValidity("");
        //         }
        //         return isValidSoFar && isFieldValid;
        //     }
        // }, true);

        // return isValid && this.isLTVInvalid;
        // let isValid = true;
        let visibledFieldList = this.visibledFields;
        const inputFields = [ ...this.template.querySelectorAll(".validate") ];
        //&& visibledFieldList.includes(inputField.name)
        let isValid = inputFields.reduce((isValidSoFar, inputField) => {            let isFieldValid = false;
            if (visibledFieldList.includes(inputField.name)) {
                if(!inputField.value){
                    isFieldValid = false;
                    inputField.setCustomValidity("Complete this field");
                } else if(FIELD_FORMATS.hasOwnProperty(inputField.name) && !FIELD_FORMATS[inputField.name]?.test(inputField.value)) {
                    isFieldValid = false;
                    inputField.setCustomValidity(FIELD_FORMATS_ERROR[inputField.name] ?? 'Format is not valid');
                } else {
                    isFieldValid = true;
                    inputField.setCustomValidity("");
                }
                inputField.reportValidity();
            }else if(inputField.name == 'BT_Loan_Status__c'){ // SFAU-5773
                isFieldValid = false;
                if(!inputField.value){
                    isFieldValid = false;
                    inputField.setCustomValidity("Complete this field");
                }else {
                    isFieldValid = true;
                    inputField.setCustomValidity("");
                }
                inputField.reportValidity();
            }
                return isValidSoFar && isFieldValid;
        }, true);
        //     if (!inputField.value && visibledFieldList.includes(inputField.name)) {
        //         inputField.setCustomValidity("Complete this field");
        //         inputField.reportValidity();
        //         isValid = false;
        //     }else if(inputField.name === 'Vehicle_Number__c' && inputField.value){
        //         isValid = inputField.checkValidity();
        //         inputField.reportValidity();
        //     }
        // });

        const { POS__c: posValue, Final_Cost__c: vehicleFinalCost, Apportioned_Loan_Amount__c: loanAmount } = this.newVehicleRecord, posValueNum = +(posValue ?? 0), vehicleFinalCostNum = +vehicleFinalCost;
        if(isValid && ((this.totalPrincipalOutstanding + +loanAmount) > vehicleFinalCostNum)){
            this.showToast( 'POS + Loan Amount can not be greater than Final Cost of the vehicle', 'error' );
            isValid = false;
        } else if(this.isLTVInvalid){
            isValid = false;
        }
        /* Commented as per defect - SFAU-5291
        else if(this.newVehicleRecord.Blacklist_Details__c){
            this.showToast(this.newVehicleRecord.Blacklist_Details__c, 'error');
            isValid = false;
        }
        */
        return isValid;
    }
        
    getPicklistOptions(makeValue,modelValue,collateralNameValue,fieldNameValue){
        
        //vehicleUsage, String state,String scheme,String manufacturer
        getPickListValues({ make:makeValue,model:modelValue ,collateralName:collateralNameValue, fieldName:fieldNameValue})
		.then(data => {
            if (data) {
                if(fieldNameValue==='Make'){
                    this.makeOptions = data[fieldNameValue];
                    if(!this.makeOptionValue){
                        if(this.makeOptions && this.makeOptions.length==1){
                            this.makeOptionValue = this.makeOptions[0].value;
                            this.getPicklistOptions(this.makeOptionValue,'',this.vehicleType,'Model');
                            // this.desableField.Make__c=true;
                        }else{
                            this.desableField.Make__c=false;
                        }
                    }
                    
                    
                }
                if(fieldNameValue==='Model'){
                    this.modelOptions = data[fieldNameValue];
                    if(!this.modelOptionValue){
                        if(this.modelOptions && this.modelOptions.length==1){
                            this.modelOptionValue = this.modelOptions[0].value;
                            this.getPicklistOptions(this.makeOptionValue,this.modelOptionValue,this.vehicleType,'Variant');
                            // this.desableField.Model__c=true;
                        }else{
                            this.desableField.Model__c=false;
                        }
                    }
                    
                }
                if(fieldNameValue==='Variant'){
                    this.variantOptions = data[fieldNameValue];
                    this.desableField.Variant__c = !this.variantOptions.length;
                    if(!this.variantOptionValue){
                        if(this.variantOptionValue && this.variantOptionValue.length==1){
                            this.variantOptionValue = this.variantOptions[0].value;
                            this.getUsedCategoryPickListValues(this.variantOptionValue);
                            // this.desableField.Variant__c=true;
                        }else{
                            this.desableField.Variant__c=false;
                        }
                    }
                    
                }
                this.isLoaded = false;
            }
		})
		.catch(error => {
            console.log('error is '+JSON.stringify(error));
            this.isLoaded = false;
		})
    }

    handleCategoryChange(event){
        this.updateDataInVariable(event)
        this.getSchemePickListValues();

    }

    handleVaiantValueChange(event){
        //this.updateDataInVariable(event)
        this.variantOptionValue =event.target.value;
        // this.schemeOptionValue = event.target.value;
        this.newVehicleRecord.MMV_Master__c=event.target.value;
        this.getUsedCategoryPickListValues(event.target.value);

    }

    getSchemePickListValues(){
        this.isLoaded = true;
        //vehicleUsage, String state,String scheme,String manufacturer
        getSchemePickListValues({loanApp:this.loanApplicationRecord,app:this.applicantRecord, category: this.newVehicleRecord.Vehicle_Category__c, collCode: this.newVehicleRecord.Collateral_Name__c })
		.then(data => {
            if (data) {
                    this.vehicleSchemeOptions = data.schemeValues.Scheme;
                    if(data.schemeValues.Scheme && data.schemeValues.Scheme.length==1){
                        this.newVehicleRecord.Scheme__c = data.schemeValues.Scheme[0].value;
                        this.schemeOptionValue = data.schemeValues.Scheme[0].value;
                        this.getSchemeMasterRecord(this.schemeOptionValue);
                        this.desableField.Scheme__c=true;
                    }else{
                        this.desableField.Scheme__c=false;
                    }
                    this.schemeMasterRecord = data.schemeMaster;
                    //this.desableField.Scheme__c=false;
                this.isLoaded = false;
            }else{
                this.isLoaded = false;
            }
		})
		.catch(error => {
            console.log('error is '+JSON.stringify(error));
            this.isLoaded = false;
		})
    }

    getUsedCategoryPickListValues(variantValue){
        this.isLoaded = true;
        //vehicleUsage, String state,String scheme,String manufacturer
        getUsedCategoryPickListValues({variant:variantValue, loanId : this.recordId})
		.then(data => {
            if (data) {
                    this.vehicleCategoryOptions = data.Category;
                    this.fuelTypeOptions = data.FuelType;
                    this.setDefaultFieldValue( data.FuelType, 'Fuel_Type__c' );

                    if(data.CollateralName.length>0){
                        this.collateralNames = data.CollateralName;
                        if(data.CollateralName.length==1){
                            this.newVehicleRecord.Collateral_Name__c = data.CollateralName[0].value;
                            const product = this.isEv ? FUEL_TYPE_ELECTRIC : this.newVehicleRecord.Collateral_Name__c;
                            this.mapVehicleCategoryFor2W( this.isTwoWheeler, product );
                        }
                    }
                    if(data.Category && data.Category.length==1){
                        this.newVehicleRecord = { ...this.newVehicleRecord, ...{ Vehicle_Category__c: data.Category[0].value }};
                        this.desableField.Vehicle_Category__c=true;
                        this.getSchemePickListValues();
                    }else{
                        this.desableField.Vehicle_Category__c=false;
                    }
                    if(data.FuelType && data.FuelType.length==1){
                        this.newVehicleRecord.Fuel_Type__c = data.FuelType[0].value;
                        this.desableField.Fuel_Type__c=true;
                    }else{
                        this.desableField.Fuel_Type__c=false;
                    }
                    
                    if(data.LuxuryVehicle?.length){
                        const [ luxuryVehicle ] = data.LuxuryVehicle;
                        if(luxuryVehicle){
                            this.newVehicleRecord.Luxury_Non_Luxury__c = luxuryVehicle.value;
                        }
                    }
                    // SFAU-5608 - auto-populate vehicle category
                    this.setDefaultCategoryValue( data.Category, 'Vehicle_Category__c' );
                this.isLoaded = false;
            }else{
                this.isLoaded = false;
            }
		})
		.catch(error => {
            console.log('error is '+JSON.stringify(error));
            this.isLoaded = false;
		})
    }

    isYearInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll(".year");
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
            //this.contact[inputField.name] = inputField.value;
        });
        const TODAY = new Date();
        const selectedMonthLastDay = new Date( this.manufactureYear, (+this.manufactureMonth) - 1, TODAY.getDate());
        return isValid && selectedMonthLastDay < new Date(TODAY.getFullYear(), TODAY.getMonth() + 1, 0);
    }

    @wire(getPicklistValuesByRecordType, {
        objectApiName: COLLATERAL_RECORD,
        recordTypeId: '012000000000000AAA'
    })
    wiredValues({ error, data }) {
        if (data) {
            this.vehicleUsageOptions = data.picklistFieldValues.Vehicle_Usage__c.values;
            this.engineCategoryOptions = data.picklistFieldValues.Engine_Category__c.values;
            this.existingPolicyExpired = data.picklistFieldValues.Exiting_Policy_Expired__c.values;
            this.existingPolicyType = data.picklistFieldValues.Existing_Policy_Type__c.values;
            this.lsOptions = data.picklistFieldValues.LS__c.values;
            this.bodyOptions = data.picklistFieldValues.Body__c.values;
            this.assessoriesOptions = data.picklistFieldValues.Accessories_Funding__c.values;
            this.rtoTaxOptions = data.picklistFieldValues.RTO_Tax__c.values;
            this.insuranceFundingOptions = data.picklistFieldValues.Insurance_Funding__c.values;
            this.assessmentMethodOptions = data.picklistFieldValues.Assessment_Method__c.values;
            //this.fuelTypeOptions = data.picklistFieldValues.Fuel_Type__c.values;
            this.error = undefined;
        } else {
            this.error = error;
            console.log('error is '+error)
        }
    }

    handleValuationClick(event){
        let selectedId = event.currentTarget.dataset.id;
        let newVehicleList = this.applicantLst;
            for (let i = 0; i < newVehicleList.length; i++) {
                if(selectedId === newVehicleList[i].Id){
                    this.vehicleRecord = newVehicleList[i];
                }
            }
        //this.vehiclerecord =collList.find((item)=>item.Id === selectedId);
        this.showValuationDetail = true;
        this.showMainSection = false;
        setValidationOnDocument({documentType:'Valuation', loanApplicationId:this.vehicleRecord.Loan__c})
        //this.getValuationDetails(selectedId);
    }

    navigateHomeView(event){
        this.showValuationDetail = event.detail;
        this.showMainSection = true;
        this.handleCancelForm();
    }

    /*getValuationDetails(collRecId){
        this.isLoaded =true;
        getValuationDetails({collId:collRecId})
		.then(data => {
            if (data) {
                this.valuationDetails =data;
                this.isLoaded = false;
            }else{
                this.isLoaded = false;
            }
		})
		.catch(error => {
            this.isLoaded = false;
		})
    }*/

    handleCancelForm(){
        this.addNewApplicant = false;
        this.showSection = true;
        this.showVehicle = true;
        let appList = this.applicantLst;
            if(appList.length===0){
                this.showSearchScreen = true;
                if(this.searchData){
                    this.errorOnChild  = 'Please select value in any one of below searched result.';
                    const obj = {};
                    obj.errorOnChild = this.errorOnChild;
                    obj.applicantLst = '';
                    this.dispatchEvent(new CustomEvent('save', {
                        detail:obj
                    }));
                }
            }else{
                this.showMainSection = true;
            } 
            this.showValuationDetail = false;
    }
    

    showToast(message,variant) {
        const event = new ShowToastEvent({
            title: '',
            message: message,
            variant: variant,
            mode :'sticky'
        });
        this.dispatchEvent(event);
    }
    
    @api nextHandler() {
        let vehicleRecord = this.applicantLst;
        this.errorOnChild = vehicleRecord.length>0?'':'Please create vehicle record';
        const Obj = {};
        //this.errorOnChild = '';
        //Obj.applicantRecord = this.applicantIdInput;
        Obj.errorOnChild = this.errorOnChild;
        Obj.next = this.errorOnChild === '' ? true : false;
        if(Obj.next===false){
            this.showToast(this.errorOnChild,'error');
        }
        this.dispatchEvent(new CustomEvent('next', {
            detail: Obj
        }));
    }

    closeModal(event){
        const obj = event.detail;
        this.isModalOpen = obj.isModalOpen;
    }

    showDetails(event){
        const obj = event.detail;
        this.showLoanDetails = obj.showLoanDetails;
        this.showVehicle = false;
        this.isModalOpen = obj.isModalOpen;
        this.dispatchEvent( new CustomEvent('updateloandetail') );
    }

    
    handleLookupSelect(event) {
     
        if (event.detail.value != undefined) {
            let selectedValue = event.detail.value;
            let selectedName = event.detail.name;
            let fieldName = event.detail.fieldapi;
            let objectName = event.detail.objApiName;
            if (fieldName !== null && selectedName !== null) {
              // this.companyDefaultId =selectedValue;
               //this.companyOptionsValue = selectedName;
                this.companyName = selectedName;
               this.companyDefault = selectedValue;

            }
            this.newVehicleRecord[(LOOKUP_FIELD_TO_COLLATERAL_FIELD?.[fieldName?.toLowerCase()] ?? fieldName)] = selectedValue;
        }

    }
    async getMaterialSettings(strScreen, strLoanId){
        const fields = await getMaterialFields({ strScreen, strLoanId }).catch(err => this.showToast('Something went wrong! Please contact System Administrator', 'error'));
        this.configurations = { materialSettings: fields.map( field => field.toLowerCase()) || [] };
        // if(fields){
            //..disable these fields on UI
            // this.desableField = this.convertArrayToObjWithDefaultValues(fields, true, this.desableField);
        // }

    }

    // convertArrayToObjWithDefaultValues = ( fields, defaultValue, existingValues = { } ) => fields.reduce(( accumulator, field ) => ( { ...accumulator, [field]: defaultValue } ), existingValues );

    async applyMaterialSettings(){
        await Promise.resolve();
        const fieldTokens = this.template.querySelectorAll('lightning-input, lightning-combobox');
        updateDisabledOnFieldTokens([ ...fieldTokens ], this.configurations.materialSettings, true);
    }

    async setDefaultFieldValue( picklistOptions, fieldApi ){
        if(picklistOptions?.length === 1){
            const [{ value }] = picklistOptions;
            this.desableField = { ...this.desableField, [fieldApi]: true };
            this.handleValueChange({ target: { name: fieldApi, value } });
        }
    }
    getValuationSettingsBasedOnScheme = (applicants, schemeName) => applicants.map(applicant => ({ ...applicant, isDisableValuation: schemeName === branchTopup || !this.collateralUpdates[applicant.Id] }));
    async populateRegistrationCities( vehicleRecord, disabledFields, { registeredAt }){
        const cities = await getRegistrationCityPickListValues({ rtoCode: vehicleRecord.Vehicle_Number__c }).catch(err => console.error(err));
        const { RTOName: registrationCities, ...rtoCodes } = cities ?? {};
        this.ragistrationCityOptions = registrationCities ?? [];
        this.mapOfRtoCityVsCode = rtoCodes;
        if(registrationCities.length === 1){
            const rtoCity = registrationCities[0].value;
            vehicleRecord.Registration_City__c = rtoCity;
            if(rtoCity){
                this.rtoCodeOptions = rtoCodes[rtoCity] ?? [];
                if(this.rtoCodeOptions.length === 1){
                    vehicleRecord.Rto_Code__c = this.rtoCodeOptions[0].value;
                    disabledFields.Rto_Code__c = true;
                } else {
                    vehicleRecord.Rto_Code__c = null;
                }
            }
        } else {
            vehicleRecord.Registration_City__c = null;
        }
        this.desableField.Registration_City__c = !!vehicleRecord.Registration_City__c;

        const { value: registrationCity } = registrationCities?.find( city => city.value === registeredAt ) ?? {};
        if(registrationCity){
            vehicleRecord.Registration_City__c = registrationCity;
        }
        return vehicleRecord;
    }
    async validateMaterialFields(strScreen, strLoanId, lstFieldsAPI){
        if(this.isDirtyField(this._vehicleRecord, { [MAKE_FIELD_API]: this.makeOptionValue }, MAKE_FIELD_API)){
            await checkMaterialFields( { MATERIAL_SCREEN_VEHICLE_LIST_USED, strLoanId, lstFieldsAPI } )
                .catch(err => { console.error(err); this.showToast(err.body?.message ?? '(Material Fields)Something went wrong! Please contact System administrator', 'error'); });
        }
    }

    isDirtyField = (oldRecord, newRecord, fieldApi) => oldRecord?.[fieldApi] != newRecord?.[fieldApi];

    resetScreen(){
        this.disabledFetchVahhan = !!this.newVehicleRecord.IsDetailsFromVahaanApi__c;
        this.manufactureYear = null;
        this.manufactureMonth = null;
        this.makeOptionValue = null;
        this.modelOptionValue = null;
        this.variantOptionValue = null;
        this.dataFromApi = {};
        this.newVehicleRecord = { Insurance_Funding__c: false, LS__c: false, Quantity__c: 1 };
    }

    setSpinner( hasLoaded ){
        this.isLoaded = hasLoaded
    }

    async evaluateVehicleCategoryBasedOnRoadPrice(product, vehicleCost){
        if(product){
            const { productToPriceMappings } = this.configurations;
            const selectedProductToPriceMapping = productToPriceMappings?.find(mapping => mapping.Product__c?.toLowerCase() === product && (vehicleCost >= mapping.Min_On_Road_Price__c && vehicleCost <= mapping.Max_On_Road_Price__c) );
            if(selectedProductToPriceMapping){
                await Promise.resolve();

                this.vehicleCategoryOptions = [ selectedProductToPriceMapping ].map(({ Vehicle_Category__c: label }) => ({ label, value: label }));
                this.handleCategoryChange({ target: { name: 'Vehicle_Category__c', value: selectedProductToPriceMapping.Vehicle_Category__c } } );
            }
        }
    }

    mapVehicleCategoryFor2W(is2W, productName){
        if( is2W && productName ){
            this.vehicleCategoryOptions = this.configurations.productToPriceMappings
                ?.filter( mapping => mapping.Product__c?.toLowerCase() === productName )
                .map(({ Vehicle_Category__c: value }) => ({ label: value?.replaceAll('_', ' '), value }) );
        }
    }

    get otherFundingTotal(){
        const { Insurance_Value__c: insuranceAmount, RTO_Tax_Value__c: rtoTaxes, LS_Value__c: lsAmount, Accessories_Value__c: accessoriesAmount }  = this.newVehicleRecord || {},
            insuranceAmountNum = +insuranceAmount, rtoTaxesNum = +rtoTaxes, lsAmountNum = +lsAmount, accessoriesAmountNum = +accessoriesAmount;

        return (!isNaN(insuranceAmountNum) ? insuranceAmountNum : 0) + (!isNaN(rtoTaxesNum) ? rtoTaxesNum : 0) + (!isNaN(lsAmountNum) ? lsAmountNum : 0) + (!isNaN(accessoriesAmountNum) ? accessoriesAmountNum : 0);
    }

    populateVahanDetails(vahanResponse){
        this.disabledFetchVahhan = true;
        this.searchLabel = 'Search Again';
        const vehicleRecord = { ...this.newVehicleRecord };
        const disabledFields = { ...this.dataFromApi };
        const { vehicleDetails, insuranceDetails, financersDetails, nocCcDetails, ownerDetails, pdf, metadata, challanDetails } = vahanResponse || { };
        this.newVehicleRecord.Vahaan_Response__c = JSON.stringify(vahanResponse);
        vehicleRecord.IsDetailsFromVahaanApi__c =true;

        if(vehicleDetails?.registrationNo){
            vehicleRecord.Vehicle_Number__c = vehicleDetails.registrationNo;
            disabledFields.Vehicle_Number__c = !!vehicleDetails.registrationNo; 
            this.inputSearchParamater.Vehicle_Number__c = vehicleDetails.registrationNo;
            /*let vehicleNumber =  dataResult.registrationNumber;
            let rtoCode = vehicleNumber.substr(0, 2);*/
            //this.getRegistrationCityPickListValues(vehicleDetails.registrationNo);
        }
        
        if(!vehicleRecord.Chasis_Number__c && vehicleDetails?.chassisNo){
            vehicleRecord.Chasis_Number__c = vehicleDetails.chassisNo;
            disabledFields.Chasis_Number__c = !!vehicleDetails.chassisNo;
            this.inputSearchParamater.Chasis_Number__c = vehicleDetails.chassisNo;
        }
        if(!vehicleRecord.Engine_Number__c && vehicleDetails?.engineNo){
            vehicleRecord.Engine_Number__c = vehicleDetails.engineNo;
            disabledFields.Engine_Number__c = !!vehicleDetails.engineNo;
            this.inputSearchParamater.Engine_Number__c = vehicleDetails.engineNo;
        }
        if(financersDetails?.financersName){
            vehicleRecord.HPN_With_Financiers_Name__c = financersDetails.financersName;
            let financier = financersDetails.financersName;
            if(financier.includes("AU")){
                vehicleRecord.NOC_Status__c='release/with AU';
                this.showNocStatus = true;
            }
            disabledFields.HPN_With_Financiers_Name__c = true;
        }else{
            vehicleRecord.HPN_With_Financiers_Name__c ='NA';
            disabledFields.HPN_With_Financiers_Name__c = false;
        }
        
        //disabledFields.HPN_With_Financiers_Name__c = dataResult.financier?true:false;
        if(vehicleDetails?.ownerSrNo){
            vehicleRecord.Owner_Serial_number__c = vehicleDetails.ownerSrNo;
            disabledFields.Owner_Serial_number__c = !!vehicleDetails.ownerSrNo;
        }
        if(vehicleDetails?.registrationDt){
            vehicleRecord.Registration_Date__c = new Intl.DateTimeFormat(LOCALE).format(new Date(vehicleDetails.registrationDt));
        }

        if(ownerDetails?.ownersName){
            vehicleRecord.Current_Owner_Name__c = ownerDetails.ownersName;
            disabledFields.Current_Owner_Name__c = !!ownerDetails.ownersName;
            this.vahaanOwnerName = ownerDetails.ownersName;
            // vehicleRecord.SVSH_SVOH__c = this.isSameAsVehicleOwner;
        }
        vehicleRecord.Blacklist_Details__c = vehicleDetails?.blackListDetails ?? vehicleRecord.Blacklist_Details__c;
        // SFAU-5291 - Save Challan Info - true/false
        vehicleRecord.Challan_Info__c = !!challanDetails?.length ?? vehicleRecord.Challan_Info__c;
        vehicleRecord.Challan_Overdue_Amount__c = challanDetails?.reduce((overdue, challan) => {
            if(challan.status === 'PENDING'){
                overdue += challan.totalAmount;
            }
            return overdue;
        }, 0);
        return { vehicleRecord, disabledFields };
    }

    // SFAU-5608 - auto-populate vehicle category
    async setDefaultCategoryValue( picklistOptions, fieldApi ) {
        if( picklistOptions?.length === 1 ) {
            const [{ value }] = picklistOptions;
            this.handleCategoryChange({ target: { name: fieldApi, value } });
        }
    }
}