import { LightningElement, track, wire, api } from 'lwc';
import getPickListValues from '@salesforce/apex/AUSFVehicleController.getPickListValues';
import getMmvRecord from '@salesforce/apex/AUSFVehicleController.getMmvRecord';
import getNewCategoryPickListValues from '@salesforce/apex/AUSFVehicleController.getNewCategoryPickListValues';
import getCollateralEnquiryList from '@salesforce/apex/CustomCollateralEnquiryController.getCollateralEnquiryList';
import getLtvMasterRecord from '@salesforce/apex/AUSFVehicleController.getLtvMasterRecord';
import getDLPFMPMasterRecord from '@salesforce/apex/AUSFVehicleController.getDLPFMPMasterRecord';
import getApplicantFinancials from '@salesforce/apex/AUSFVehicleController.getApplicantFinancials';
import getLtvMasterRecordAgainstFMV from '@salesforce/apex/AUSFVehicleController.getLtvMasterRecordAgainstFMV';
import OnRoadPriceCalculationField from '@salesforce/label/c.OnRoadPriceCalculationField';
import deleteCollateral from '@salesforce/apex/AUSFVehicleController.deleteCollateral';
import getSchemeMasterRecord from '@salesforce/apex/AUSFVehicleController.getSchemeMasterRecord';
import getSchemePickListValues from '@salesforce/apex/AUSFVehicleController.getSchemePickListValues';
import fetchBranchMasterRecord from '@salesforce/apex/AUSFVehicleController.fetchBranchMasterRecord';
import getVisibleFields from '@salesforce/apex/AUSFVehicleController.getVisibleFields';
import getVehicleDetails from '@salesforce/apex/AUSFVehicleController.getVehicleDetails';
import upsertCollateral from '@salesforce/apex/AUSFVehicleController.upsertCollateral';
import getCollateralList from '@salesforce/apex/AUSFVehicleController.getCollateralList';
import deleteExistingCollateral from '@salesforce/apex/AUSFVehicleController.deleteExistingCollateral';
import getVahaanDetail from '@salesforce/apex/AUSFVehicleController.getVahaanDetail';
import callBikeDekhoAPI from '@salesforce/apex/AUSFVehicleBikeDekhoInt.callBikeDekhoAPI';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';
import COLLATERAL_RECORD from '@salesforce/schema/Collateral__c';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';
import AUSFAccessoriesLoanAmount from '@salesforce/label/c.AUSFAccessoriesLoanAmount';
import AUSFAccessoriesMaxAmount from '@salesforce/label/c.AUSFAccessoriesMaxAmount';
import createCollateral from '@salesforce/apex/AUSFVehicleController.createCollateral';
import getProductVsPriceTagConfigs from '@salesforce/apex/AUSFVehicleController.getProductVsPriceTagConfigs';
import getVehiclePricing from '@salesforce/apex/AUSFVehicleController.getPriceDetailsViaApiCall';
import getMaterialFields from '@salesforce/apex/Utility.getMaterialFields';
import checkMaterialFields from '@salesforce/apex/Utility.checkMaterialFields';
import { updateDisabledOnFieldTokens } from 'c/ausfVehicleListUsed';
import {RefreshEvent} from 'lightning/refresh'
import { registerRefreshHandler, unregisterRefreshHandler } from 'lightning/refresh';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c';
import Boolean_Use_Original_Vehicle_Usage from '@salesforce/label/c.Boolean_Use_Original_Vehicle_Usage'; // SFAU-5163
import Implement_Collateral_Code from '@salesforce/label/c.Implement_Collateral_Code';
import Self_Propelled_Collateral_Code from '@salesforce/label/c.Self_Propelled_Collateral_Code'; 
import getApplicants from '@salesforce/apex/financeController.getApplicants';
import { IMPLEMENT_COLLATERAL_TYPES, reduceErrors, OTHER_FUNDING_ITEMS_MAPPINGS, validateLoanFunding } from 'c/lwcutilities';
import validateParentLoan from '@salesforce/apex/AUSFCommercialVehicleController.validateParentLoanTractor';
import otherFundingValidationError from '@salesforce/label/c.OtherFundingAmountValidationError';

import {
    subscribe,
    unsubscribe,
    publish,
    APPLICATION_SCOPE,
    createMessageContext
  } from 'lightning/messageService';

const API_RESPONSE_TO_FIELD_MAPPING = {
    price: [ 'Final_Cost__c' ],
    // price: [ 'Ex_Showroom_Price__c', 'Final_Cost__c' ],
    //ex_showroom_price: [ 'Ex_Showroom_Price__c' ], // will remain editable, the value from api is now stamped on Ex_Showroom_Price_API__c
    // insurance: [ 'Insurance__c' ], //SFAU-2536 - Sachin - RTO & Insurance to be free input
    // rto: [ 'RTO_Taxes__c' ],
    on_road_price: [ 'On_Road_Price__c' ]
};
const MATERIAL_SCREEN_VEHICLE_LIST_NEW = 'Vehicle - New';
const LTVMitigates = new Map([
    ["Income Document Mitigate", 'Documented Income Source- Salary/Pension etc. above 1.5 Lac PA OR ITR of 2.5 Lac PA of last 2 yrs. Documented'],
    ["Milk Statement Mitigate", "Milk income if customer is having >3 milk cattles (Can be verified at the time of F.I. or can be submitted if having any documented Income proof)."],
    ["RC Copy Mitigate", "Asset Ownership- Vehicle - 4wheeler/Tractor/CV/CE. RC to be documented. Asset age max 10 years"],
    ["Track Record Mitigate", "Loan Track ETR/GTR of 1.5 Lac - (loan closed max in past 12 Months)- Min period of Track 12 Months (Excluding KCC, GL & CD Loans)"],
    ["Banking Mitigate", "QB (of last 6 months) in Scheduled bank account equal to 1x of annual repayment - documented"],
    ["Agri Income Document Mitigate", "Agri Produce revenue 3 Lac PA with documentary proof. "],
    ["Land Document Mitigate", "Land Holding 6 acres & above in the name of Joint family owned and cultivation is doing by applicant / Co-applicant."]
  ]);



const LTV_OFFERED_ON_FINAL_COST = 'LTV_offered_On_final_cost__c';
const FUEL_TYPE_ELECTRIC = 'electric';
const EX_SHOWROOM_FIELD_API = 'Ex_Showroom_Price__c';
const LOAN_AMOUNT_FIELD_API = 'Apportioned_Loan_Amount__c';

const RTO_TAXES_FIELD_API = 'RTO_Taxes__c';
const ACCESSORIES_FIELD_API = 'Accessories__c';
const INSURANCE_FIELD_API =  'Insurance__c';
const INSURANCE_FUNDING_FIELD_API = 'Insurance_Funding__c';
const ACCESSORIES_FUNDING_FIELD_API = 'Accessories_Funding__c';
const RTO_TAX_FIELD_API = 'RTO_Tax__c';
const MAKE_FIELD_API = 'Make__c';
const VEHICLE_TYPE_VS_ALLOWED_DELETE_STAGES = {
    //'Two Wheeler': [ 'QDE', 'DDE', 'Credit' ],
    //'Four Wheeler': [ 'QDE', 'Credit' ],
    'Tractor': [ 'QDE', 'DDE' ]
};

const LOOKUP_FIELD_TO_COLLATERAL_FIELD = {
    'color_code__c': 'Vehicle_Color__c'
};

const FIELD_FORMATS = {
    [ EX_SHOWROOM_FIELD_API ]: /^[0-9]{5,9}$/,
    [ RTO_TAXES_FIELD_API ]: /^[0-9]{0,8}$/,
    [ ACCESSORIES_FIELD_API ]: /^[0-9]{0,8}$/,
    [ INSURANCE_FIELD_API ]: /^[0-9]{0,8}$/
};

const FIELD_FORMATS_ERROR = {
    [ EX_SHOWROOM_FIELD_API ]: 'Ex-Showroom Price should be b/w 5 to 9 digits only',
    [ RTO_TAXES_FIELD_API ]: 'RTO Tax can\'t exceed 9 digits',
    [ ACCESSORIES_FIELD_API ]: 'Accessories value can\'t exceed 8 digits',
    [ INSURANCE_FIELD_API ]: 'Insurance cost can\'t exceed 8 digits'
};

const TW_RT_NAME = 'Two Wheeler';
const FW_RT_NAME = 'Four Wheeler';

const OTHER_FUNDING_HIDDEN_FIELDS = {
    [ TW_RT_NAME ]: [ ACCESSORIES_FUNDING_FIELD_API ],
    [ FW_RT_NAME ]: [ ACCESSORIES_FUNDING_FIELD_API, RTO_TAXES_FIELD_API, 'RTO_Tax__c', 'Insurance_Funding__c' ]
};

const TODAY = new Date();
const THIS_YEAR = `${TODAY.getFullYear()}`;
const PREVIOUS_YEAR = `${TODAY.getFullYear() - 1}`;

const MANUFACTURE_YEAR_OPTIONS = [
    {
        label: THIS_YEAR,
        value: THIS_YEAR
    },
    {
        label: PREVIOUS_YEAR,
        value: PREVIOUS_YEAR
    }
];
export default class Ausfb_RelatedApplicansComponent extends NavigationMixin(LightningElement) {
    label = {
        AUSFAccessoriesLoanAmount,
        AUSFAccessoriesMaxAmount,
	    Boolean_Use_Original_Vehicle_Usage,
        Implement_Collateral_Code,
        Self_Propelled_Collateral_Code
    };
    @api recordId;
    activeSections = ['A', 'B', 'C', 'D', 'E'];
    isLoaded = false;
    isModalOpen = false;
    showLoanDetails = false;
    isCeAssesmentMethod = false;
    showCancelButton = false;
    showVehicle = true;
    OnRoadPriceCalculationFields = OnRoadPriceCalculationField;
    maximumPrice;
    manufacturerOptions = [];
    manufacturerOptionValue;
    makeOptions = [];
    makeOptionValue;
    variantOptionValue;
    modelOptions = [];
    fuelTypeOptions = [];
    fuelTypeOptionValue;
    modelOptionValue;
    variantOptions = [];
    schemeOptionValue;
    vehicleSchemeOptions = [];
    schemeMasterRecord
    ltvMasterRecord;
    dlpMasterRecord;
    applicantFinancialsRecord;
    productName;
    @track selectedCollList;
    @track deletedCollList;
    isTwoWheeler = false;
    isFourWheeler = false;
    isTractor = false;
    isSingleImplement = false;
    showBackButton = false;
    isCollateralRequired = false;
    @track vehicleUsageOptions;
    vehicleUsageOptionValue;
    @track LTVEnhancerOptions;
    LTVEnhancerValues=[];
    @track LTVdescriptions=[];
     @track concatenatedOptions = '';
    @track options = [
        { label: 'Income Document Mitigate', value: 'Income Document Mitigate' },
        { label: 'Milk Statement Mitigate', value: 'Milk Statement Mitigate' },
        { label: 'RC Copy Mitigate', value: 'RC Copy Mitigate' },
        { label: 'Track Record Mitigate', value: 'Track Record Mitigate' },
        { label: 'Banking Mitigate', value: 'Banking Mitigate' },
        { label: 'Agri Income Document Mitigate', value: 'Agri Income Document Mitigate' },
        { label: 'Land Document Mitigate', value: 'Land Document Mitigate' },
    ];
    @track selectedOptions = [];
    @track LTVMitigates = new Map([
        ["Income Document Mitigate", 'Documented Income Source- Salary/Pension etc. above 1.5 Lac PA OR ITR of 2.5 Lac PA of last 2 yrs. Documented'],
        ["Milk Statement Mitigate", "Milk income if customer is having >3 milk cattles (Can be verified at the time of F.I. or can be submitted if having any documented Income proof)."],
        ["RC Copy Mitigate", "Asset Ownership- Vehicle - 4wheeler/Tractor/CV/CE. RC to be documented. Asset age max 10 years"],
        ["Track Record Mitigate", "Loan Track ETR/GTR of 1.5 Lac - (loan closed max in past 12 Months)- Min period of Track 12 Months (Excluding KCC, GL & CD Loans)"],
        ["Banking Mitigate", "QB (of last 6 months) in Scheduled bank account equal to 1x of annual repayment - documented"],
        ["Agri Income Document Mitigate", "Agri Produce revenue 3 Lac PA with documentary proof. "],
        ["Land Document Mitigate", "Land Holding 6 acres & above in the name of Joint family owned and cultivation is doing by applicant / Co-applicant."]
      ]);
    @track engineCategoryOptions;
    engineCategoryOptionValue;
    showSearchResult = false;
    @track newVehicleRecord = {'Insurance_Funding__c':false,'RTO_Tax__c':false,'Accessories_Funding__c':false,'Body__c':false,'LS__c':false,'Quantity__c':1, [ACCESSORIES_FIELD_API]: '0', Other_Costs__c: 0 };
    _vehicleRecord = {}; // This holds actual db values:: it will always hold values which are there in database
    @track desableField = {'Make__c':true,'Model__c':true,'Variant__c':true,'Fuel_Type__c':true,'Vehicle_Category__c':true,'Scheme__c':true, On_Road_Price__c: true };
    @track inputSearchParamater = {'Vehicle_Number__c':'','Engine_Number__c':'','Chasis_Number__c':''}
    @track searchData =[];
    @track dataFromApi = {'Owner_Serial_number__c':false,'manufactureMonth':false, 'manufactureYear':false,'Current_Owner_Name__c':false,'Registration_City__c':false,'Vehicle_Color__c':false,'Vehicle_Number__c':false,'Engine_Number__c':false,'Chasis_Number__c':false,'HPN_With_Financiers_Name__c':false};
    loanApplicationRecord;
    @track selectedValues = [];
    applicantRecord;
    usedProductOptions;
    mapOfCollateralNameVsId;
    accountCodes ={};
    mdetailsOptions = [];
    loanAmount;
    showAddSection = false;
    state;
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
    error;
    errorOnChild;
    account;
    labelVal ='Choose Applicant from Drop down';
    vehicleIdForEdit;
    selectedApplicantId;
    totalApplicantsFull;
    boolNorecordsFull=false;
    isChecked = false;
    selectedAppVsData = new Map();
    showCollateral = false
    showManualCollDetail = false;
    showCBSCollDetail = false;
    showApplicantSelection = true;
    variantId ;
    cityId;
    onRoadPriceHelpText;
    insuranceValidation = true;
    rtoTaxValidation = true; 
    collateralAllOptions;
    configurations = { };
    currentYear;
    collateralUpdates = {}
    manufactureYearFutureValidation = false;
    currentMonth;
    manufactureYearOptions = MANUFACTURE_YEAR_OPTIONS;
    loanStage;
    isLanCreated;
    parentLoanIdentifier = '';
    parentLoan = {}; // R2-2519 | Used for standalone implement loans
    parentCollateral = {};

    get vehicleDeliveryOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
        ];
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

    get vehicleDeliveryLabel() {
        return this.isSingleImplement? 'Implement Delivery Status': 'Vehicle Delivery Status';
    }


    get collateralTypes() {
        return [
            { label: 'Existing', value: 'Existing' },
            { label: 'New', value: 'New' },
        ];
    }

    get disableGetPriceDetails() {
        return !(this.isTwoWheeler || this.isFourWheeler);
    }

    get vehicleType() {
        return this.loanApplicationRecord?.RecordType.Name ?? 'Four Wheeler';
    }

    get isEv() {
        return this.newVehicleRecord?.Fuel_Type__c?.toLowerCase() === FUEL_TYPE_ELECTRIC;
    }
    get canDeleteCollateral() {
        return VEHICLE_TYPE_VS_ALLOWED_DELETE_STAGES[this.loanApplicationRecord?.RecordType.Name]?.includes(this.loanApplicationRecord?.Stage__c);
    }
    get isInsuranceAvailable(){
        return !OTHER_FUNDING_HIDDEN_FIELDS[ this.vehicleType ]?.includes(INSURANCE_FUNDING_FIELD_API);
    }
    get isAccessoriesAvailable(){
        return !OTHER_FUNDING_HIDDEN_FIELDS[ this.vehicleType ]?.includes(ACCESSORIES_FUNDING_FIELD_API);
    }
    get isRtoTaxAvailable(){
        return !OTHER_FUNDING_HIDDEN_FIELDS[ this.vehicleType ]?.includes(RTO_TAX_FIELD_API);
    }
    get isOtherFundingLeftPortionVisible(){
        return [ this.isInsuranceAvailable, this.isAccessoriesAvailable, this.isRtoTaxAvailable ].filter( isFieldVisible => isFieldVisible ).length;
    }

    // SFAU-2719 - Month not required if manufacture year is current year
    get allowMonthSelection(){
        const isMonthRequired = this.manufactureYear != THIS_YEAR; //loose equality since year is in number
        if( !isMonthRequired ) this.manufactureMonth = null;
        return isMonthRequired;
    }

    get isImplementLoan(){
        return IMPLEMENT_COLLATERAL_TYPES.includes( this.loanApplicationRecord.Collateral_Type__c );
    }

    get allowParentLoanValidate(){
        return this.isCollateralUpdatedPostCreation || (!!this.parentLoanIdentifier && !!this.parentLoan.Name && this.parentLoanIdentifier === this.parentLoan.Name);
    }

    get parentLoanValiationButtonLabel(){
        return `Validate${this.allowParentLoanValidate ? 'd' : ''}`;
    }

    get isCollateralUpdatedPostCreation(){
        return this.newVehicleRecord.Is_Collateral_Updated_Post_Creation__c;//this.collateralUpdates?.[ this.newVehicleRecord.Id ];
    }


    connectedCallback() {
        this.subscribeToMessageChannel()
        this.loadInitialData();
    }

    async loadInitialData(){
        console.log('OnRoadPriceCalculationFields '+JSON.stringify(this.OnRoadPriceCalculationFields))
        console.log('desabled fields are  '+this.desableField)
        await this.getMaterialSettings(MATERIAL_SCREEN_VEHICLE_LIST_NEW, this.recordId);
        this.fetchState(this.recordId);
        this.title = 'Vehicle Information';
        this.getApplicantsData();
        this.currentYear = new Date().getFullYear();
        this.currentMonth = new Date().getMonth();
    }

    getApplicantsData() {
        getApplicants({
            applicantId: this.recordId
        })
        .then(data => {
            if (data) {
                let options = [];
                for (var key in data) {
                    options.push({
                        label: data[key].Customer_Name__c,
                        value: data[key].Id,
                    });    
                }
                this.mdetailsOptions = options;
            }
        })
        .catch(error => {
            console.log('error in getApplicantsData' + error);
        })
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
          this.loadInitialData()
        }
      }

      unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
      }
    
      disconnectedCallback() {
          this.unsubscribeToMessageChannel();
      }

    handleRowAction(event) {
        const recordVehicleId = event.currentTarget.dataset.id;
        this.vehicleIdForEdit = recordVehicleId;
        this.handleEditAction();
    }
    handleCheckboxChange(event) {
        this.selectedValues = event.detail.value;
    }


    handleChange(event) {
        this.showCollateral = true;
        let selected = event.detail;
        this.totalApplicantsFull = [];
        let picklistName = selected.target.name;
        let picklistValue = selected.target.value;
        this.selectedApplicantId = picklistValue;
        console.log('selected applicant id is ' + JSON.stringify(this.selectedApplicantId));
        this.getCollateral(this.selectedApplicantId);
    }

    getCollateral(applicantId) {
        this.isLoaded = true;
        console.log('record id is %% ' + JSON.stringify(applicantId));
        getCollateralEnquiryList({ strApplicantId: applicantId })
            .then(result => {
                console.log('getCollateralEnquiryList ' + JSON.stringify(result.collateralList))
                this.totalApplicantsFull = result.collateralList;
                let totalCollList = result.collateralList;
                let selectedList = this.selectedCollList ?? [];
                if (selectedList?.length > 0) {
                    for (let i = 0; i < selectedList.length; i++) {
                        for (let j = 0; i < totalCollList.length; j++) {
                            if (selectedList[i].strCollateralId === totalCollList[j].strCollateralId) {
                                totalCollList[j].isSelected = true;
                            }
                        }
                    }
                    this.totalApplicantsFull = totalCollList;
                }

                if (this.totalApplicantsFull.length === 0) {
                    this.boolNorecordsFull = true;
                } else {
                    this.boolNorecordsFull = false;
                }
                this.isLoaded = false;
            })
            .catch(error => {
                if (this.totalApplicantsFull.length === 0) {
                    this.boolNorecordsFull = true;
                } else {
                    this.boolNorecordsFull = false;
                }
                this.isLoaded = false;
                console.log('result is ' + JSON.stringify(error));
            })
    }

    handleEditAction() {
        this.isLoaded = true;
        this.showMainSection = false;
        this.showCancelButton = true;
        this.addNewApplicant = true;
        this.showSection = false;
        this.title = 'Change Vehicle Information';
        this.getVisibleFields();
        this.applyMaterialSettings();
        console.log('get list is >>' + JSON.stringify(this.applicantLst))
        console.log('before get new vehicle record is >>' + JSON.stringify(this.newVehicleRecord))
        this.getVehicleDetail(this.vehicleIdForEdit);
        console.log(' after get new vehicle record is >>' + JSON.stringify(this.newVehicleRecord))
        this.dispatchEvent(new CustomEvent('wizardevent', {
            bubbles: true,
            composed: true,
            detail: { value: '', name: 'VehicleDetails', mode: '' }
        }));
    }

    handleEdit(event) {
        let current = event.detail;
        this.title = 'Change Vehicle Information';
        this.isLoaded = true;
        this.addNewApplicant = true;
        this.showSearchScreen = false;
        this.showSection = false;
        const recordVehicleId = current.collateralObj;
        this.getVisibleFields();
        console.log('recordVehicleId>> ' + JSON.stringify(recordVehicleId));
        this.newVehicleRecord = recordVehicleId;

        if (this.screenType === 'New') {
            this.getMakePicklistOptions(recordVehicleId.Collateral_ID__c);
        }

        if (this.screenType === 'Used') {
            this.getUsedScreenTypePickListValues(recordVehicleId.Manufacturer__c);
        }
    }

    handleClick() {
        //let uiParamater = this.inputSearchParamater;
        let chaseNum = this.newVehicleRecord.Chasis_Number__c;
        let engineNum = this.newVehicleRecord.Engine_Number__c;
        this.inputSearchParamater = {'Engine_Number__c':this.newVehicleRecord.Engine_Number__c,'Chasis_Number__c':this.newVehicleRecord.Chasis_Number__c};
        if (chaseNum || engineNum) {
            this.getCollateralList();
        }

    }

    getCollateralList() {
        this.isLoaded = true;
        getCollateralList({ obj: this.inputSearchParamater, loanAppId: this.recordId })
            .then(data => {
                console.log('searched data is>>' + JSON.stringify(data))
                if (data.responseMessage === 'Success') {
                    console.log('in callout >' + JSON.stringify(data.collaterals))
                    let currentObj = Object.assign({}, this.newVehicleRecord);
                    currentObj.CBS_Response__c = JSON.stringify(data.collaterals);
                    this.newVehicleRecord = currentObj;
                    this.searchData = data.collaterals;
                    this.isLoaded = false;
                    this.showSearchResult = true;
                    this.showApplicantInsertion = false;
                    this.showErrorMessage = false;
                } else if (data.responseMessage === 'Failure') {
                    this.showErrorMessage = true;
                    this.searchData = '';
                    this.errorMessage = data.message;
                    this.isLoaded = false;
                    this.showApplicantInsertion = true;
                }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
                this.isLoaded = false;
                this.searchData = '';
            })
    }

    getVehicleDetail(recordVehicleId) {
        getVehicleDetails({ collateralId: recordVehicleId, loanAppId: this.recordId })
            .then(data => {
                if (data) {
                    console.log('data is>>' + JSON.stringify(data))
                    let customObject = data.coll;
                    this._vehicleRecord = { ...data.coll };
                    customObject.Insurance_Funding__c = customObject.Insurance_Funding__c === 'Yes' ? true : false;
                    customObject.Body__c = customObject.Body__c === 'Yes' ? true : false;
                    customObject.RTO_Tax__c = customObject.RTO_Tax__c === 'Yes' ? true : false;
                    customObject.Accessories_Funding__c = customObject.Accessories_Funding__c === 'Yes' ? true : false;
                    customObject.LS__c = customObject.LS__c === 'Yes' ? true : false;
                    this.isCollateralRequired = customObject.Vehicle_Delivery__c === 'Yes' ? true : false;
                    // Applicable only in case of Standalone Implement loans
                    this.parentLoan = customObject.Loan__r.Parent_Loan__r ?? {};
                    this.parentCollateral = customObject.Parent_Collateral__r ?? {};
                    this.parentLoanIdentifier = this.parentLoan.Name ?? customObject.Loan__r.Parent_Loan__c;
        
                    if(customObject.CBS_Response__c != undefined && customObject.CBS_Response__c != ''){
                        this.showSearchResult = true;
                        this.searchData = JSON.parse(customObject.CBS_Response__c);
                    }
                    let ltvValues = customObject.LTV_Enhancer__c?.split(';').map(value => value.trim()) || [];
                    this.LTVEnhancerValues = ltvValues;
                    let matchingDescriptions = ltvValues.map(value => {
                        if(!this.LTVdescriptions.includes(this.LTVMitigates.get(value)))
                             this.LTVdescriptions.push(this.LTVMitigates.get(value))
                    });
                    this.newVehicleRecord = customObject;
                    this.newVehicleRecord.Vehicle_Usage__c = this.vehiclusg;
                    this.newVehicleRecord.Collateral_Name__c = customObject.Collateral_Name__c ? customObject.Collateral_Name__c : customObject.Loan__r.Collateral_Type__c;
                    this.newVehicleRecord.Apportioned_Loan_Amount__c = customObject.Apportioned_Loan_Amount__c ?  customObject.Apportioned_Loan_Amount__c: customObject.Loan__r.Loan_Amount__c;
                    this.newVehicleRecord.Other_Funding_Total__c= customObject.Other_Funding_Total__c ? customObject.Other_Funding_Total__c : 0;
                    this.loanAmount = this.newVehicleRecord.Apportioned_Loan_Amount__c - this.newVehicleRecord.Other_Funding_Total__c;
                    if(this.newVehicleRecord.Collateral_Name__c == this.label.Implement_Collateral_Code){ //Check for Implement
                        this.isSingleImplement = true;
                        this.implementNames = data.picklist.Implement;
                    }
                    else{
                        this.isSingleImplement = false;
                    }
                    let listOfRecord = this.applicantLst;
                    if (listOfRecord.length === 0) {
                        this.applicantLst.push(customObject);
                    }

                    console.log('newVehicleRecord is ' + JSON.stringify(this.newVehicleRecord))
                    console.log('customObject is ' + JSON.stringify(customObject))
                    this.makeOptionValue = this.newVehicleRecord.Make__c;
                    this.modelOptionValue = this.newVehicleRecord.Model__c;
                    this.variantOptionValue = this.newVehicleRecord.MMV_Master__c;
                    this.enableFieldToEdit(this.newVehicleRecord);
                    let yearandMonth = data.coll.Manufacture_year_month__c;
                    let month = yearandMonth?.substr(4, 2);
                    let year = yearandMonth?.substr(0, 4);
                    this.manufactureYear = year ?? THIS_YEAR; //SFAU-2719
                    this.manufactureMonth = month;
                    this.makeOptions = data.picklist.Make;
                    this.modelOptions = data.picklist.Model;
                    this.variantOptions = data.picklist.Variant;
                    if ((data.picklist.VariantId != null || data.picklist.VariantId != undefined) && data.picklist.VariantId.length > 0) {
                        this.variantId = data.picklist.VariantId[0].label;
                        console.log('variantId is ' + this.variantId)
                    }
                    if ((data.picklist.MaxAmount != null || data.picklist.MaxAmount != undefined) && data.picklist.MaxAmount.length > 0) {
                        console.log('maximumPrice is ' + this.maximumPrice)
                        this.maximumPrice = data.picklist.MaxAmount[0].label;
                    }
                    this.schemeOptionValue = this.newVehicleRecord.Scheme__c;
                    this.vehicleCategoryOptions = data.picklist.Category;
                    this.vehicleSchemeOptions = data.picklist.Scheme;
                    this.fuelTypeOptions = data.picklist.FuelType;
		            this.setDefaultFieldValue(data.picklist.FuelType, 'Fuel_Type__c');
                    /* START - SFAU-5417 */
                    this.setDefaultCategoryValue( data.picklist.Category, 'Vehicle_Category__c' );
                    /* END - SFAU-5417 */
		            this.isLoaded = false;
                }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
                this.isLoaded = false;
            })
    }

    enableFieldToEdit(newVehicleRecord) {
        const { materialSettings } = this.configurations || [];
        if (!materialSettings.includes(MAKE_FIELD_API) && newVehicleRecord.Make__c) {
            this.desableField.Make__c = false;
            //this.getPicklistOptions('','',newVehicleRecord.Collateral_ID__c,'Make');
        } if (!materialSettings.includes('model__c') && newVehicleRecord.Model__c) {
            this.desableField.Model__c = false;
            //this.getPicklistOptions(this.makeOptionValue,'',this.newVehicleRecord.Collateral_ID__c,'Model');
        } if (!materialSettings.includes('fuel_type__c') && newVehicleRecord.Fuel_Type__c) {
            //this.getCategoryPickListValues(this.newVehicleRecord.MMV_Master__c);
            this.desableField.Fuel_Type__c = false;
        } if (!materialSettings.includes('vehicle_category__c') && newVehicleRecord.Vehicle_Category__c) {
            this.desableField.Vehicle_Category__c = false;
        } if (!materialSettings.includes('variant__c') && newVehicleRecord.Variant__c) {
            //this.getPicklistOptions(this.makeOptionValue,this.modelOptionValue,this.newVehicleRecord.Collateral_ID__c,'Variant');
            this.desableField.Variant__c = false;
        } if (!materialSettings.includes('scheme__c') && newVehicleRecord.Scheme__c) {
            this.desableField.Scheme__c = false;
            //this.getSchemePickListValues();
        }
    }

    resetMMVData(isImplementRemove){
        let currentObj = Object.assign({}, this.newVehicleRecord);
        currentObj.Make__c = '';
        currentObj.Model__c = '';
        currentObj.Variant__c = '';
        this.makeOptionValue = '';
        this.modelOptionValue = '';
        this.variantOptions = '';
        if(isImplementRemove){
            currentObj.Implement_Type__c = '';
        }
        this.newVehicleRecord = currentObj;
    }

    handleCollateralName(event) {
        this.updateDataInVariable(event);
        if(event.target.name == 'Collateral_Name__c' && event.target.value == this.label.Implement_Collateral_Code){ //Check for Implement
            this.getPicklistOptions('','',this.vehicleType,'Implement');
            this.resetMMVData(true);
        }
        else{
            this.isSingleImplement = false;
            this.getVisibleFields();
            this.getPicklistOptions('','',this.vehicleType,'Make');
            this.resetMMVData(false);
            //const product = this.isEv ? FUEL_TYPE_ELECTRIC : currentObj.Collateral_Name__c;
            //this.mapVehicleCategoryFor2W(this.isTwoWheeler, product);
        }
    }

    handleImplementName(event) {
        this.updateDataInVariable(event);
        this.resetMMVData(false);
        this.getPicklistOptions('','',this.vehicleType,'Make');
    }

    getOnRoadPriceHelpText() {
        let result = this.onRoadPriceFields;
        let helpText;     
        for (let key in result){
            if(result[key].Active__c && (!result[key]?.Vehicle_Type__c || [ 'Both', this.vehicleType ].includes(result[key]?.Vehicle_Type__c))){
                if(helpText){
                    helpText = helpText +' + ' +result[key].Label;
                }else{
                    helpText = result[key].Label;
                }
            }
        }
        this.onRoadPriceHelpText = helpText;
        console.log('this.onRoadPriceHelpText ' + this.onRoadPriceHelpText)
    }

    fetchState(loanApplRecordId) {
        this.isLoaded = true;
        console.log('record 222>>' + loanApplRecordId)
        fetchBranchMasterRecord({ loanAppId: loanApplRecordId })
            .then(async data => {
                if (data) {
                    console.log('fetchState data is>>' + JSON.stringify(data))
                    this.state = data.state;
                    let loanApplication = data.loanApp.Loan__r;
                    this.loanApplicationRecord = loanApplication;
                    this.cityId = data.cityId;
                    this.applicantRecord = data.loanApp;
                    console.log('applicant is ' + data.loanApp)
                    let collatList = data.collateralList;
                    this.loggedInUserProfile = data.userProfile;
                    this.screenType = data.screenName;
                    this.loanStage = data.loanStage;
                    this.isLanCreated = data.isLanCreated;
                    this.onRoadPriceFields = data.onRoadPrice;
                    if (this.onRoadPriceFields) {
                        this.getOnRoadPriceHelpText();
                    }
                    //this.manufacturerOptions = data.picklistValues['Manufacturer__c'];
                    this.collateralNames = data.collateralNames.Collateral_Name__c;
                    console.log('Collateral_Name__c ' + data.collateralNames.Collateral_Name__c)
                    console.log('Collateral_Name__c ' + data.collateralNames.Collateral_Name__c)
                    this.mapOfCollateralNameVsId = data.mapOfCollateralNameVsId;
                    this.vehiclusg = loanApplication.Vehicle_use__c;
                    let curObj = this.newVehicleRecord;
                    curObj.Apportioned_Loan_Amount__c = loanApplication.Loan_Amount__c;
                    //curObj.Apportioned_Loan_Amount__c = loanApplication.Loan_Amount__c;
                    //curObj.Collateral_ID__c=data.strCollateralIdForNew;
                    curObj.Engine_Category__c = curObj.Engine_Category__c ?? 'BS4';
                    curObj.Vehicle_Usage__c = loanApplication.Vehicle_use__c; //SFAU-3648 - vehicle Usage to be disabled / auto populates from loan application
                    curObj.Collateral_Name__c = loanApplication.Collateral_Type__c;
                    curObj.Original_Vehicle_Usage__c = this.label.Boolean_Use_Original_Vehicle_Usage == 'Yes' && loanApplication.Original_Vehicle_Usage__c != '' ? loanApplication.Original_Vehicle_Usage__c : loanApplication.Vehicle_Usage__c;
                    this.newVehicleRecord = curObj;
                    // START - SFAU-5163
                    this.newVehicleRecord.Original_Vehicle_Usage__c = this.label.Boolean_Use_Original_Vehicle_Usage == 'Yes' && loanApplication.Original_Vehicle_Usage__c != '' ? loanApplication.Original_Vehicle_Usage__c : loanApplication.Vehicle_Usage__c;
                    // END - SFAU-5163

                   

                    curObj.Product__c = loanApplication.Product__c;
                    this.stageValue = loanApplication.Stage__c;
                    this.productName = data.productName;
                    this.loanAmount = loanApplication.Loan_Amount__c;
                    this.newVehicleRecord.Apportioned_Loan_Amount__c = loanApplication.Loan_Amount__c;
                    this.newVehicleRecord.Apportioned_Loan_Amount__c = loanApplication.Loan_Amount__c;
                    this.accountCodes = data.loanApp.Loan__r.Branch_Master__r;
                    if(curObj.Collateral_Name__c == this.label.Implement_Collateral_Code){ //Check for Implement
                        this.isSingleImplement = true;
                        this.getPicklistOptions('', '', this.vehicleType, 'Implement');
                    }
                    else{
                        this.getPicklistOptions('', '', this.vehicleType, 'Make');
                    }
                    console.log('accountCodes is ' + JSON.stringify(this.accountCodes))
                    this.isFourWheeler = data.typeOfWheeler.isFourWheeler;
                    this.isTwoWheeler = data.typeOfWheeler.isTwoWheeler;
                    this.isTractor = data.typeOfWheeler.isTractor;
                    if (this.isTwoWheeler) {
                        const productToPriceMappings = await getProductVsPriceTagConfigs().catch(err => console.error(err));
                        console.log(productToPriceMappings);
                        this.configurations = { ...this.configurations, productToPriceMappings: productToPriceMappings ?? [] };
                        console.log({ ...this.configurations });
                    }
                 if (collatList.length > 0) {
                        if (data.collateralList[0].Collateral_ID__c) {
                            this.applicantLst = data.collateralList;
                            this.showCancelButton = true;
                            this.showMainSection = true;
                            this.showSection = true;
                            const Obj = {};
                            Obj.applicantLst = this.applicantLst;
                            this.dispatchEvent(new CustomEvent('newsave', {
                                detail: Obj
                            }));

                        } else {
                            this.newVehicleRecord.Collateral_ID__c = `${this.loanApplicationRecord.Product__c}${data.collateralList?.[0]?.Name}${Math.floor(Math.random() * 10)}`;
                            this.newVehicleRecord.Id = data.collateralList[0].Id;
                            if (data.screenName === 'New') {
                                this.newVehicleRecord.Collateral_Type__c = 'New';
                                this.addNewApplicant = true;
                                this.manufactureYear = THIS_YEAR;
                                this.getVisibleFields();
                                this.showSection = false;
                            }
                        }

                        /*for(let key in collatList){
                            
                             if(conts[key].Type_Of_Existing_Collateral__c==='CBS'){
                                console.log('CBS key is '+key);
                                console.log('CBS key is '+JSON.stringify(conts[key]));
                                this.existingCollateralListCBS.push(conts[key]);
                                
                             }else if(conts[key].Type_Of_Existing_Collateral__c==='Manual'){
                                console.log('Manual key is '+key);
                                console.log('Manual key is '+JSON.stringify(conts[key]));
                                this.existingCollateralListManual.push(conts[key]);
                             }else{
                                console.log('key is '+key);
                                console.log('key is '+JSON.stringify(conts[key]));
                                this.applicantLst.push(conts[key]);
                             }
                        }
                        if(this.existingCollateralListCBS.length>0){
                            this.showCBSCollDetail = true;
                        }
                        if(this.existingCollateralListManual.length>0){
                            //this.showManualCollDetail = true;
                        }

                        if(this.showManualCollDetail || this.showCBSCollDetail){
                            this.showApplicantSelection = false;
                        }*/

                    } else {
                        this.createCollateral();
                        if (data.screenName === 'New') {
                            this.newVehicleRecord.Collateral_Type__c = 'New';
                            this.addNewApplicant = true
                            this.manufactureYear = THIS_YEAR; //SFAU-2719
                             // Start - R2-2383
                            this.newVehicleRecord.Vehicle_Delivery__c ='Yes';
                            // End - R2-2383
                            this.getVisibleFields();
                            this.showSection = false;
                        }
                    }

                    this.isLoaded = false;
                }
                // if(collatList.length>0 /*&& this.vehicleIdForEdit == undefined*/){
                //     let conts = data.collateralList;
                //         for(let key in collatList){

                //              if(conts[key].Type_Of_Existing_Collateral__c==='CBS'){
                //                 console.log('CBS key is '+key);
                //                 console.log('CBS key is '+JSON.stringify(conts[key]));
                //                 this.existingCollateralListCBS.push(conts[key]);

                //              }else if(conts[key].Type_Of_Existing_Collateral__c==='Manual'){
                //                 console.log('Manual key is '+key);
                //                 console.log('Manual key is '+JSON.stringify(conts[key]));
                //                 this.existingCollateralListManual.push(conts[key]);
                //              }else{
                //                 console.log('key is '+key);
                //                 console.log('key is '+JSON.stringify(conts[key]));
                //                 this.applicantLst.push(conts[key]);
                //              }
                //         }
                //         if(this.existingCollateralListCBS.length>0){
                //             this.showCBSCollDetail = true;
                //         }
                //         if(this.existingCollateralListManual.length>0){
                //             //this.showManualCollDetail = true;
                //         }

                //         if(this.showManualCollDetail || this.showCBSCollDetail){
                //             this.showApplicantSelection = false;
                //         }
                //     this.showCancelButton =true;
                //     this.showMainSection = true;
                //     this.showSection = true;
                //     const Obj = {};
                //     Obj.applicantLst = this.applicantLst;
                //     this.dispatchEvent(new CustomEvent('newsave', {
                //         detail:Obj
                //     }));
                // }else{
                //     if(data.screenName === 'New'){
                //         this.newVehicleRecord.Collateral_Type__c ='New';
                //         this.addNewApplicant = true
                //         const d = new Date();
                //         let year = d.getFullYear();
                //         this.manufactureYear = year;
                //         this.getVisibleFields();
                //         this.showSection = false;
                //     }
                // }
                // this.createCollateral();
                //this.isLoaded = false;
                // }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
                this.isLoaded = false;
            })
    }

    createCollateral() {
        this.isLoaded = true;
        createCollateral({ loanId: this.recordId, collateralType: 'New' })
            .then(data => {
                console.log('collateral data result ' + JSON.stringify(data));
                console.log('Loan App data result ' + JSON.stringify(this.loanApplicationRecord));
                this.isLoaded = false;
                this.newVehicleRecord = { ...this.newVehicleRecord, ...data, /*...{ Collateral_ID__c: `${this.loanApplicationRecord.Product__c}${data.Name}${Math.floor(Math.random() * 10)}` }*/ };
            })
            .catch(error => {
                console.log('validateNameMatch error' + error);
                this.isLoaded = false;
            })
    }

    handleActionOnExistingCollateral(event) {
        let objDetail = event.detail;
        if (objDetail.type === 'CBS') {
            this.showCBSCollDetail = objDetail.showDetail;
        }
        if (objDetail.type === 'Manual') {
            this.showManualCollDetail = objDetail.showDetail;
        }
    }
    handleAdditionalClick() {
        restricAccess({
            compName: 'ausfVehicleParent' ,loanId: this.recordId
            })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to add Additional Collateral Data',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }else{
                    this.showBackButton = true;
                    this.showCancelButton = false;
                    this.showManualCollDetail = true;
                    this.title = 'Additional Collateral Detail';
                
                }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
            })
	    
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
            console.log('selectedValue', selectedValue);
            console.log('selectedName', selectedName);
            console.log('fieldName', fieldName);
            console.log('objectName', objectName);
        }

    }

    handleBack() {
        this.showBackButton = false;
        this.showCancelButton = true;
        this.showManualCollDetail = false;
        this.title = 'Vehicle Information';
        this.getVisibleFields();
    }

    getVisibleFields() {
        this.isLoaded = true;
        let screen = this.screenType;
        let stage = this.stageValue;
        let profile = this.loggedInUserProfile;
        let typeOfWheeler;
        if (this.isTwoWheeler) {
            typeOfWheeler = 'Two Wheeler';
        }
        if (this.isFourWheeler) {
            typeOfWheeler = 'Four Wheeler';
        }
        if (this.isTractor) {
            typeOfWheeler = 'Tractor';
        }
        console.log('screen getVisibleFields ' + screen)
        console.log('screen getVisibleFields ' + stage)
        console.log('screen getVisibleFields ' + profile)
        console.log('screen getVisibleFields ' + typeOfWheeler)

        getVisibleFields({ strScreen: screen, strStage: stage, strProfile: profile, typeOfWheeler: typeOfWheeler })
            .then(result => {
                this.visibledFields = result;
                console.log('result is ' + JSON.stringify(result));
                result.forEach(input => {
                    if (this.template.querySelector('[data-id="' + input + '"]') != null) {
                        this.template.querySelector('[data-id="' + input + '"]').classList.remove('slds-hide');
                    }
                });
                this.isLoaded = false;
            })
            .catch(error => {
                console.log('result is ' + error)
                this.isLoaded = false;
            })
    }

    handleVahaanData() {
        this.isLoaded = true;
        let customObject = this.newVehicleRecord;
        getVahaanDetail({ registrationNumber: customObject.Vehicle_Number__c, loanApplicationId: this.recordId })
            .then(data => {
                if (data) {
                    console.log('data is>>' + JSON.stringify(data))
                    let returndata = data.result;
                    if (returndata) {
                        let currentObj = Object.assign({}, this.newVehicleRecord);
                        let readOnlydata = Object.assign({}, this.dataFromApi);
                        let dataResult = data.result;

                        currentObj.IsDetailsFromVahaanApi__c = true;

                        currentObj.Vehicle_Number__c = dataResult.registrationNumber;
                        readOnlydata.Vehicle_Number__c = dataResult.registrationNumber ? true : false;

                        currentObj.Chasis_Number__c = dataResult.chassisNumber;
                        readOnlydata.Chasis_Number__c = dataResult.chassisNumber ? true : false;

                        currentObj.Engine_Number__c = dataResult.engineNumber;
                        readOnlydata.Engine_Number__c = dataResult.engineNumber ? true : false;

                        currentObj.HPN_With_Financiers_Name__c = dataResult.financier;
                        readOnlydata.HPN_With_Financiers_Name__c = dataResult.financier ? true : false;

                        currentObj.Owner_Serial_number__c = dataResult.ownerSerialNumber;
                        readOnlydata.Owner_Serial_number__c = dataResult.ownerSerialNumber ? true : false;

                        currentObj.Current_Owner_Name__c = dataResult.ownerName;
                        readOnlydata.Current_Owner_Name__c = dataResult.ownerName ? true : false;

                        currentObj.Registration_City__c = dataResult.registeredAt;
                        readOnlydata.Registration_City__c = dataResult.registeredAt ? true : false;

                        currentObj.Vehicle_Color__c = dataResult.color;
                        readOnlydata.Vehicle_Color__c = dataResult.color ? true : false;

                        let yearandmonth = dataResult.manufacturedMonthYear;
                        console.log('yearandmonth>> ' + yearandmonth)

                        const myArray = yearandmonth.split("-");
                        console.log('myArray>> ' + JSON.stringify(myArray))

                        this.manufactureYear = myArray[1];
                        console.log('manufactureYear>> ' + this.manufactureYear)
                        readOnlydata.manufactureYear = this.manufactureYear ? true : false;

                        this.manufactureMonth = myArray[0];
                        console.log('manufactureMonth>> ' + this.manufactureMonth)
                        readOnlydata.manufactureMonth = this.manufactureMonth ? true : false;

                        this.newVehicleRecord = currentObj;
                        this.dataFromApi = readOnlydata;

                    } else {
                        this.showToast('No Data Found for given ragistration number', 'info');
                    }
                    this.isLoaded = false;
                }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
                this.isLoaded = false;
            })
    }
    handleToggleChange(event) {
        console.log('checked value is ' + event.target.checked);
        let currentObj = Object.assign({}, this.newVehicleRecord);
        currentObj[event.target.name] = event.target.checked;

        if (event.target.name === 'Insurance_Funding__c' && event.target.checked === false) {
            currentObj.Insurance_Value__c = '';
        } else if (event.target.name === 'Accessories_Funding__c' && event.target.checked === false) {
            currentObj.Accessories_Value__c = '';
        } else if (event.target.name === 'Body__c' && event.target.checked === false) {
            currentObj.Body_Value__c = ''
        } else if (event.target.name === 'LS__c' && event.target.checked === false) {
            currentObj.LS_Value__c = ''
        } else if (event.target.name === 'RTO_Tax__c' && event.target.checked === false) {
            currentObj.RTO_Tax_Value__c = ''
        }

        this.newVehicleRecord = currentObj;


    }

    handleSchemeChange(event) {
        this.updateDataInVariable(event);
        this.getSchemeMasterRecord(event.target.value);
        /*let schemeObj = this.schemeMasterRecord;
        let loanObj = this.loanApplicationRecord;
        console.log('lona obj'+ JSON.stringify(loanObj))
        let isValidRoi = false;
        let isValidLoanAmount = false;
        let isValidTenure= false;

        if(schemeObj.MAXROI__c>loanObj.ROI__c && schemeObj.MINROI__c<loanObj.ROI__c){
            isValidRoi = true;
            //this.showToast('Rate of Intrest should Match with scheme','info');
        }
        if(schemeObj.MAXLOANAMOUNT__c>loanObj.Loan_Amount__c && schemeObj.MINLOANAMOUNT__c<loanObj.Loan_Amount__c){
            isValidLoanAmount = true;
            //this.showToast('Rate of Intrest should Match with scheme','info');
        }
        if(schemeObj.MAXTENURE__c>loanObj.Tenure__c && schemeObj.MINTENURE__c<loanObj.Tenure__c){
            isValidTenure = true;
            //this.showToast('Rate of Intrest should Match with scheme','info');
        }
        if(!isValidRoi){
            this.showToast('Rate Of Instrest should lie between Max Value '+ schemeObj.MAXROI__c+'Min Value '+schemeObj.MINROI__c);
        }
        if(!isValidLoanAmount){
            this.showToast('Rate Of Instrest should lie between Max Value '+ schemeObj.MAXLOANAMOUNT__c+'Min Value '+schemeObj.MINLOANAMOUNT__c);
        }
        if(!isValidTenure){
            this.showToast('Rate Of Instrest should lie between Max Value '+ schemeObj.MAXTENURE__c+'Min Value '+schemeObj.MINTENURE__c);
        }

        if(isValidLoanAmount && isValidTenure && isValidRoi){
            this.getLtvRecord()
        }*/
    }

    getSchemeMasterRecord(selectedId) {
        this.isLoaded = true;
        getSchemeMasterRecord({ schemeId: selectedId })
            .then(data => {
                if (data) {
                    console.log('data is Category>>' + JSON.stringify(data))
                    this.schemeMasterRecord = data;
                    let schemeObj = data;
                    let loanObj = this.loanApplicationRecord;
                    let isValidRoi = false;
                    let isValidLoanAmount = false;
                    let isValidTenure = false;
                    if (schemeObj.MAXROI__c >= loanObj.ROI__c && schemeObj.MINROI__c <= loanObj.ROI__c) {
                        isValidRoi = true;
                        //this.showToast('Rate of Intrest should Match with scheme','info');
                    }
                    if (schemeObj.MAXLOANAMOUNT__c >= loanObj.Loan_Amount__c && schemeObj.MINLOANAMOUNT__c <= loanObj.Loan_Amount__c) {
                        isValidLoanAmount = true;
                        //this.showToast('Rate of Intrest should Match with scheme','info');
                    }
                    if (schemeObj.MAXTENURE__c >= loanObj.Tenure__c && schemeObj.MINTENURE__c <= loanObj.Tenure__c) {
                        isValidTenure = true;
                        //this.showToast('Rate of Intrest should Match with scheme','info');
                    }
                    /*if(!isValidRoi){
                        this.showToast('Rate Of Instrest should lie between Max Value '+ schemeObj.MAXROI__c+'Min Value '+schemeObj.MINROI__c);
                    }
                    if(!isValidLoanAmount){
                        this.showToast('Rate Of Instrest should lie between Max Value '+ schemeObj.MAXLOANAMOUNT__c+'Min Value '+schemeObj.MINLOANAMOUNT__c);
                    }
                    if(!isValidTenure){
                        this.showToast('Rate Of Instrest should lie between Max Value '+ schemeObj.MAXTENURE__c+'Min Value '+schemeObj.MINTENURE__c);
                    }*/

                    if (isValidLoanAmount && isValidTenure && isValidRoi) {
                        this.getLtvRecord()
                    } else {
                        this.isModalOpen = true;
                    }

                    this.isLoaded = false;
                } else {
                    this.isLoaded = false;
                }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
                this.isLoaded = false;
            })
    }

    getLtvRecord() {
        this.isLoaded = true;
        getLtvMasterRecord({ loanApp: this.loanApplicationRecord, mapOfColl: JSON.stringify(this.newVehicleRecord) })
            .then(data => {
                if (data) {
                    console.log('data is Category>>' + JSON.stringify(data))
                    this.ltvMasterRecord = data;
                    this.newVehicleRecord.Assessment_Method__c = this.ltvMasterRecord.Assessment_Method__c;
                    if (this.ltvMasterRecord) {
                        if (this.ltvMasterRecord.Assessment_Method__c === 'CE') {
                            this.isCeAssesmentMethod = true;
                        }
                        if (this.ltvMasterRecord.Assessment_Method__c === 'LTVInPercent') {
                            let ltvObj = this.ltvMasterRecord;
                            this.newVehicleRecord.Assessment_Method__c = 'LTV';
                            if (this.applicantRecord.Customer_Grade__c === 'IB') {
                                this.newVehicleRecord.Approved_LTV__c = ltvObj.IB__c;
                            }
                            if (this.applicantRecord.Customer_Grade__c === 'NIB') {
                                this.newVehicleRecord.Approved_LTV__c = ltvObj.NIB__c;
                            }
                            if (this.applicantRecord.Customer_Grade__c === 'Premium') {
                                this.newVehicleRecord.Approved_LTV__c = ltvObj.Premium__c;
                            }
                            console.log('loan obj ' + this.loanApplicationRecord)
                            console.log('collateral data obj ' + JSON.stringify(this.newVehicleRecord))
                        } else if (this.ltvMasterRecord.Assessment_Method__c === 'Absolute') {
                            this.newVehicleRecord.Approved_LTV__c = this.newVehicleRecord.Loan_Eligibilty__c / this.newVehicleRecord.Net_of_Discount_Price__c;
                        }
                    }
                    this.newVehicleRecord = {...this.newVehicleRecord};
                    this.isLoaded = false;
                } else {
                    this.isLoaded = false;
                }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
                this.isLoaded = false;
            })
    }


    handleAdditionalInformationClick() {
        let loanApplication = this.loanApplicationRecord;
        let curObj = this.newVehicleRecord;
        curObj.Vehicle_Usage__c = loanApplication.Vehicle_use__c;
        // SFAU-5163
        curObj.Original_Vehicle_Usage__c = this.label.Boolean_Use_Original_Vehicle_Usage == 'Yes' && loanApplication.Original_Vehicle_Usage__c != '' ? loanApplication.Original_Vehicle_Usage__c : loanApplication.Vehicle_Usage__c;
        curObj.Apportioned_Loan_Amount__c = loanApplication.Loan_Amount__c;
        //curObj.Collateral_ID__c = this.randomCollateralId;
        curObj.Insurance_Funding__c = false;
        curObj.Engine_Category__c = 'BS4';
        curObj.Collateral_Type__c = 'Existing';
        curObj.LS__c = false;
        this.title = 'Add New Vehicle Information';
        this.addNewApplicant = true;
        this.showMainSection = false;
        this.showSection = false;
        this.newVehicleRecord = curObj;
        this.getPicklistOptions('', '', this.vehicleType, 'Make');
        this.getVisibleFields();
    }

    handleInputChange(event) {
        this.inputSearchParamater[event.target.name] = event.target.value;
    }
   handleLTVEnhancerValueChange(event){
        this.LTVdescriptions = [];
       this.LTVEnhancerValues = event.target.value;
       let selectecLTVValues = this.LTVEnhancerValues.join('; ');
       this.newVehicleRecord.LTV_Enhancer__c = selectecLTVValues;
       let matchingDescriptions = this.LTVEnhancerValues.map(value => {
        if(!this.LTVdescriptions.includes(this.LTVMitigates.get(value)))
             this.LTVdescriptions.push(this.LTVMitigates.get(value))
    });

    }

    handleMakeValueChange(event) {
        //this.updateDataInVariable(event);
        this.makeOptionValue = event.target.value;
        this.desableField.Model__c = false;
        this.desableField.Variant__c = true;
        this.desableField.Fuel_Type__c = true;
        this.desableField.Vehicle_Category__c = true;
        this.fuelTypeOptionValue = '';
        this.fuelTypeOptions = '';
        this.variantOptionValue = '';
        this.variantOptions = '';
        this.vehicleCategoryOptions = '';
        this.newVehicleRecord.Vehicle_Category__c = '';
        let makeValue = event.target.value;
        this.getPicklistOptions(makeValue, '', this.vehicleType, 'Model');
        /*console.log('values are '+JSON.stringify(this.usedProductOptions))
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

    handleModelValueChange(event) {
        //this.updateDataInVariable(event);
        this.modelOptionValue = event.target.value;
        let makeValue = this.makeOptionValue;
        let modelValue = event.target.value;
        this.desableField.Fuel_Type__c = true;
        this.desableField.Vehicle_Category__c = true;
        this.fuelTypeOptionValue = '';
        this.fuelTypeOptions = '';
        this.vehicleCategoryOptions = '';
        this.newVehicleRecord.Vehicle_Category__c = '';
        this.getPicklistOptions(makeValue, modelValue, this.vehicleType, 'Variant');
    }

    updateDataInVariable(event) {
        let currentObj = Object.assign({}, this.newVehicleRecord);
        currentObj[event.target.name] = event.target.value;
        this.newVehicleRecord = currentObj;
    }

    handleDeleteAction(event){
        const { id: collateralId } = event.currentTarget.dataset;
        restricAccess({
            compName: 'ausfVehicleParent' ,loanId: this.recordId
            })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to delete Vehicle',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }else{
                let collList = this.applicantLst;
                console.log('before slice list is '+JSON.stringify(collList))
                let todoTaskIndex;
                for(let i=0; i<collList.length; i++) {
                    console.log('current ls is '+JSON.stringify(collList[i]));
                    if(collateralId === collList[i].id) {
                        todoTaskIndex = i;
                    }
                }

                collList.splice(todoTaskIndex, 1);
                console.log('after list is '+JSON.stringify(collList))
                if(collList.length===0){
                    this.newVehicleRecord = {
                        Insurance_Funding__c: false,
                        RTO_Tax__c: false,
                        Accessories_Funding__c: false,
                        Body__c: false,
                        LS__c: false,
                        Quantity__c: 1,
                        [ACCESSORIES_FIELD_API]: '0',
                        Other_Costs__c: 0
                    };

                    this.desableField = {
                        Make__c : false,
                        Model__c : true,
                        Variant__c : true,
                        Fuel_Type__c : true,
                        Vehicle_Category__c : true,
                        Scheme__c : true
                    };
                    this.dataFromApi = {
                        Collateral_Name__c :false,
                        Owner_Serial_number__c : false,
                        manufactureMonth : false,
                        manufactureYear : false,
                        Current_Owner_Name__c : false,
                        Registration_City__c : false,
                        Vehicle_Color__c : false,
                        Vehicle_Number__c : false,
                        Engine_Number__c : false,
                        Chasis_Number__c : false,
                        HPN_With_Financiers_Name__c : false
                    };
                    // this.showApplicantInsertion = true;
                    this.makeOptionValue = null;
                    this.modelOptionValue = null;
                    this.variantOptionValue = null;
                    // this.createCollateral();
                    // this.addNewApplicant = true;
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
        deleteCollateral({ collId: collateralId })
            .then(result => {
                console.log('result ' + JSON.stringify(result));
                this.isloading = false;
                this.showToast('Successfully deleted collateral', 'success');

            })
            .catch(error => {
                this.isloading = false;
                this.error = error;
            });

    }


    handleValueChange(event) {
        //alert('in value changes ')
        console.log('name ' + event.target.name + ' value ' + event.target.value)
        console.log('name ' + event.target.label + ' value ' + event.target.label)

        this.updateDataInVariable(event);

        if (event.target.label === 'manufactureYear') {
            this.manufactureYear = event.target.value;
            if (Number(event.target.value) > Number(this.currentYear)) {
                this.showToast('Manufacture Year can not be future year', 'error');
                event.target.value = '';
            }
        } else if (event.target.label === 'manufactureMonth') {
            this.manufactureMonth = event.target.value;
            // if(Number(this.manufactureYear ) == this.currentYear){
            //     if(Number(event.target.value) > Number(this.currentMonth)){
            //         this.showToast('Manufacture Month can not be of future month of the current year', 'error');
            //         this.manufactureMonth = this.currentMonth;
            //     }
            // }
        }else if(event.target.name==='Insurance_Value__c'){
            this.isInsuranceAmountValid();
        } else if (event.target.name === 'RTO_Tax_Value__c') {
            this.isInsuranceAmountValid();
        } else if (event.target.name === 'Assessment_Method__c' && event.target.value === 'CE') {
            this.isCeAssesmentMethod = true;
        } else if (event.target.name === 'Accessories_Value__c') {
            this.isInsuranceAmountValid();
        } else if (event.target.name === 'Discount__c') {
            if (parseInt(event.target.value, 10) >= parseInt(this.newVehicleRecord.Ex_Showroom_Price__c, 10)) {
                this.showToast('Discount price can not be equal to or greater than ex-showroom price', 'error');
                this.newVehicleRecord.Discount__c = '';
            }
        } else if (event.target.name === 'Engine_Number__c' || event.target.name === 'Chasis_Number__c') {
            this.handleInputChange(event);
        } else if (event.target.name === 'LTV_offered__c') {
            //this.handleInputChange(event);
            let currentObj = Object.assign({}, this.newVehicleRecord);
            //let loanAmtonProposedAsset = currentObj.Apportioned_Loan_Amount__c ? currentObj.Apportioned_Loan_Amount__c : 0;
            let costToConsider = currentObj.Cost_to_be_Consider__c ? currentObj.Cost_to_be_Consider__c : 0;
            let netOfDiscountPrice = currentObj.Net_of_Discount_Price__c ? currentObj.Net_of_Discount_Price__c : 0;
            let ltvOffered = currentObj.LTV_offered__c ? currentObj.LTV_offered__c : 0;
            let loanAmtonProposedAsset = 0;
            if (!this.isSingleImplement && ltvOffered && costToConsider !== 0) {
                loanAmtonProposedAsset = (parseFloat(ltvOffered) / 100) * parseInt(costToConsider);
                //finalValue = finalValue * 100;
            }
            else if (this.isSingleImplement && ltvOffered && netOfDiscountPrice !== 0) {
                loanAmtonProposedAsset = (parseFloat(ltvOffered) / 100) * parseInt(netOfDiscountPrice);
                //finalValue = finalValue * 100;
            }
            this.loanAmount = loanAmtonProposedAsset.toFixed(2) - currentObj.Other_Funding_Total__c;
        }else if (event.target.name === 'Date_of_Delivery__c') {
            if (new Date() < new Date(event.target.value)) {
                this.showToast( 'Date of Delivery cannot be in more than todays date', 'error' );    
                this.newVehicleRecord.Date_of_Delivery__c = new Date();   
            }
        }

        console.log('in handle changes')

    }

    handleBodyValueChange(event) {
        this.updateDataInVariable(event);
        if (event.target.value === 'Yes') {
            this.isBody = true;
        } else {
            this.isBody = false;
            this.isLs = false;
            let currentObj = Object.assign({}, this.newVehicleRecord);
            currentObj.Body__c = '';
            this.newVehicleRecord = currentObj;
        }
    }

    handleAssessoriesValueChange(event) {
        this.updateDataInVariable(event);
        if (event.target.value === 'Yes') {
            this.isAsssessories = true;
        } else {
            this.isAsssessories = false;
            this.isLs = false;
            let currentObj = Object.assign({}, this.newVehicleRecord);
            currentObj.Accessories_Value__c = '';
            this.newVehicleRecord = currentObj;
        }
    }


    async upsertVehicleInfo() {
        console.log('in update method');
        let currentObj = Object.assign({}, this.newVehicleRecord);
        currentObj.Loan__c = this.recordId;
        //currentObj.MMV_Master__c = this.recordId;
        // SFAU-2719 - Month not required if manufacture year is current year
        currentObj.Manufacture_year_month__c = this.manufactureYear + (this.manufactureMonth ?? '');
        currentObj.Insurance_Funding__c = currentObj.Insurance_Funding__c?'Yes':'No';
        currentObj.Body__c = currentObj.Body__c?'Yes':'No';
        currentObj.RTO_Tax__c = currentObj.RTO_Tax__c?'Yes':'No';
        currentObj.Accessories_Funding__c = currentObj.Accessories_Funding__c?'Yes':'No';
        currentObj.LS__c = currentObj.LS__c?'Yes':'No';
        currentObj.Accessories__c = currentObj.Accessories__c ? currentObj.Accessories__c : '0';
        currentObj.Other_Costs__c = currentObj.Other_Costs__c ? currentObj.Other_Costs__c : 0;

        delete currentObj.Product__c;
        delete currentObj.Make__c;
        delete currentObj.Model__c;
        delete currentObj.Variant__c;


        if (currentObj.Assessment_Method__c === 'LTV') {
            let variance = parseInt(currentObj.Approved_LTV__c, 10) - parseInt(currentObj.LTV_offered_On_final_cost__c, 10);
            currentObj.Variance__c = variance;
        }
        /*if(currentObj.Assessment_Method__c==='Absolute'){
            variance = currentObj.Approved_LTV__c - currentObj.LTV_offered_On_final_cost__c
        }
        if(currentObj.Assessment_Method__c==='CE'){
            variance = currentObj.Approved_LTV__c - currentObj.LTV_offered_On_final_cost__c
        }*/

        //this.newVehicleRecord = currentObj;

        //this.newVehicleRecord['Loan__c'] = this.recordId;

        console.log('aplicantRecord>>' + JSON.stringify(currentObj))
        //this.aplicantRecord['Id'] = applicantIdInput;

        if (currentObj) {
            console.log('in update method >2');
            this.isloading = true;
            console.log('this.aplicantRecord', currentObj);
            const { Id: parentLoanId } = this.parentLoan,
                { Id: parentCollateralId } = this.parentCollateral,
                additionalParams = { parentLoanId, parentCollateralId };
            await this.validateMaterialFields(MATERIAL_SCREEN_VEHICLE_LIST_NEW, this.recordId, [MAKE_FIELD_API]);

            upsertCollateral({ collateral: currentObj, screen: this.screenType, cbsCollateralList: this.selectedCollList, additionalParams })
                .then(result => {
                    console.log('result ' + JSON.stringify(result));
                    const { collaterals } = result;
                    this.isloading = false;
                    this.addNewApplicant = false;
                    this.showMainSection = true;
                    this.showSection = true;
                    this.applicantLst = collaterals;
                    console.log('applis is '+this.applicantLst)
                    if(this.deletedCollList != undefined && this.deletedCollList.length > 0){
                        deleteExistingCollateral({ collateralId: this.deletedCollList })
                        .then(result => {
                            console.log('result ' + JSON.stringify(result));
                        })
                        .catch(error => {

                        });
                    }

                    const Obj = {};
                    Obj.applicantLst = this.applicantLst;
                    this.dispatchEvent(new CustomEvent('newsave', {
                        detail: Obj
                    }));
                    const payload = { recordIdOfSobject: this.recordId, refreshPage: 'Yes'};
                    publish(this.messageContext, pageRefreshOnMaterialFieldChange, payload);

                })
                .catch(error => {
                    this.isloading = false;
                    this.error = error;
                    this.showToast( error?.body?.message ?? 'There\'s some issue while save Collateral details. Please contact System Administrator.', 'error' );
                });

               /* setTimeout(function(){
                    window.location.reload(1);
                 }, 1000); */

        }
    }

    // Apportioned Loan Amount = Loan Amount + other funding
    get calculateApportionedLoanAmount(){
        let currentObj = Object.assign({}, this.newVehicleRecord);
        let insuranceFundingPrice = currentObj.Insurance_Value__c ? currentObj.Insurance_Value__c : 0;
        let rtoTaxprice = currentObj.RTO_Tax_Value__c ? currentObj.RTO_Tax_Value__c : 0;
        let lsPrice = currentObj.LS_Value__c ? currentObj.LS_Value__c : 0;
        //let accessoriesPrice = currentObj.Accessories_Value__c ? currentObj.Accessories_Value__c : 0;
        let loanAmount = this.loanAmount ? this.loanAmount : 0;
        let finalValue = 0;
        //parseInt Converts a string to an integer.
        if (loanAmount || insuranceFundingPrice || rtoTaxprice || lsPrice) {
            finalValue = parseInt(loanAmount) + parseInt(insuranceFundingPrice) + parseInt(rtoTaxprice) + parseInt(lsPrice)
            //this.finalDisValue = finalValue;
            let otherFundingTotal = parseInt(insuranceFundingPrice) + parseInt(rtoTaxprice) + parseInt(lsPrice);
            currentObj.Other_Funding_Total__c = otherFundingTotal.toFixed(2);
            currentObj.Apportioned_Loan_Amount__c = finalValue.toFixed(2);
            this.newVehicleRecord = currentObj;

        }
        return finalValue.toFixed(2);
    }

    // Total Loan Amount = Loan Amount + other funding
    get calculateTotalLoanAmount(){
        let currentObj = Object.assign({}, this.newVehicleRecord);
        let insuranceFundingPrice = currentObj.Insurance_Value__c ? currentObj.Insurance_Value__c : 0;
        let rtoTaxprice = currentObj.RTO_Tax_Value__c ? currentObj.RTO_Tax_Value__c : 0;
        let lsPrice = currentObj.LS_Value__c ? currentObj.LS_Value__c : 0;
        //let accessoriesPrice = currentObj.Accessories_Value__c ? currentObj.Accessories_Value__c : 0;
        let loanAmount = currentObj.Apportioned_Loan_Amount__c ? currentObj.Apportioned_Loan_Amount__c : 0;
        let finalValue = 0;
        //parseInt Converts a string to an integer.
        if (loanAmount || insuranceFundingPrice || rtoTaxprice || lsPrice ) {
            finalValue = parseInt(loanAmount) + parseInt(insuranceFundingPrice) + parseInt(rtoTaxprice) + parseInt(lsPrice)
            //this.finalDisValue = finalValue;
            let otherFundingTotal = parseInt(insuranceFundingPrice) + parseInt(rtoTaxprice) + parseInt(lsPrice);
            currentObj.Other_Funding_Total__c = otherFundingTotal.toFixed(2);
            currentObj.Total_Loan_Amount__c = finalValue.toFixed(2);
            this.newVehicleRecord = currentObj;

        }
        return finalValue.toFixed(2);
    }

    // SFAU-3836
    get finalCostCalculationLabel(){
        return `Cost to be consider + Insurance + RTO + LS`;
    }

    get vehicleCost() {
        let currentObj = Object.assign({}, this.newVehicleRecord);
        let costToConsider = currentObj.Cost_to_be_Consider__c?currentObj.Cost_to_be_Consider__c:0;
        let finalValue = 0;
        if (costToConsider) {
            finalValue = parseInt(costToConsider)
            //this.finalDisValue = finalValue;
            currentObj.Vehicle_Cost__c = finalValue.toFixed(2);
            this.newVehicleRecord = currentObj;

        }
        return finalValue.toFixed(2);
    }

    get finalVehicleCost() {
        let currentObj = Object.assign({}, this.newVehicleRecord);
        let vehicleCost = currentObj.Vehicle_Cost__c?currentObj.Vehicle_Cost__c:0;
        let insuranceFundingPrice = currentObj.Insurance_Value__c ? currentObj.Insurance_Value__c : 0;
        let rtoTaxprice = currentObj.RTO_Tax_Value__c ? currentObj.RTO_Tax_Value__c : 0;
        let lsPrice = currentObj.LS_Value__c ? currentObj.LS_Value__c : 0;
        let finalValue = 0;
        if (vehicleCost || insuranceFundingPrice || rtoTaxprice || lsPrice ) {
            finalValue = parseInt(vehicleCost) + parseInt(insuranceFundingPrice) + parseInt(rtoTaxprice) + parseInt(lsPrice)
            //this.finalDisValue = finalValue;
            let otherFundingTotal = parseInt(insuranceFundingPrice) + parseInt(rtoTaxprice) + parseInt(lsPrice);
            //currentObj.Other_Funding_Total__c = otherFundingTotal.toFixed(2);
            currentObj.Final_Vehicle_Cost__c = finalValue.toFixed(2);
            this.newVehicleRecord = currentObj;

        }
        return finalValue.toFixed(2);
    }

    get finalPrice() {
        let currentObj = Object.assign({}, this.newVehicleRecord);
        //let onRoadPrice = currentObj.On_Road_Price__c ? currentObj.On_Road_Price__c : 0;
        //let accessoriesPrice = !this.isTwoWheeler && currentObj.Accessories__c ? currentObj.Accessories__c : 0; //SFAU-3836 - Exclude accessories from Final Vehicle cost since they're already added in Vehicle Cost(On Road price)
        //let otherCost = currentObj.Other_Costs__c ? currentObj.Other_Costs__c : 0;
        let lsPrice = currentObj.LS_API__c ? currentObj.LS_API__c : 0;
        let costToConsider = currentObj.Cost_to_be_Consider__c?currentObj.Cost_to_be_Consider__c:0;
        let insuranceAmount = currentObj.Insurance__c?currentObj.Insurance__c:0;
        let rtoTaxAmount = currentObj.RTO_Taxes__c?currentObj.RTO_Taxes__c:0;
        /*let accessoriesAmount = currentObj.Accessories_Value__c?currentObj.Accessories_Value__c:0;*/
        //parseInt Converts a string to an integer.
        let finalValue = 0;
        if (insuranceAmount || lsPrice || rtoTaxAmount || costToConsider) {
            finalValue = parseInt(insuranceAmount) + parseInt(lsPrice) + parseInt(rtoTaxAmount) + parseInt(costToConsider)
            //this.finalDisValue = finalValue;
            currentObj.Final_Cost__c = finalValue.toFixed(2);
            this.newVehicleRecord = currentObj;

        }
        return finalValue.toFixed(2);
    }

    get calculateOnRoadPrice() {
        let currentObj = Object.assign({}, this.newVehicleRecord);
        let insurancePrice = currentObj.Insurance__c?currentObj.Insurance__c:0;
        let rtoTaxes = currentObj.RTO_Taxes__c?currentObj.RTO_Taxes__c:0;
        let finalDisValue = currentObj.Net_of_Discount_Price__c?currentObj.Net_of_Discount_Price__c:0;
        var finalValue = 0;
        let loanAmount = parseInt(this.loanApplicationRecord.Loan_Amount__c);
        if(insurancePrice || rtoTaxes || finalDisValue){
            finalValue = parseInt(insurancePrice)+parseInt(rtoTaxes) +parseInt(finalDisValue);
            //this.onRoadPrice = finalValue;
            currentObj.On_Road_Price__c = finalValue.toFixed(2);
            currentObj.Customer_equity__c= currentObj.On_Road_Price__c-loanAmount;
            this.newVehicleRecord = currentObj;
        }
        return finalValue.toFixed(2);
        /*let currentObj = Object.assign({}, this.newVehicleRecord);
        //let insurancePrice = currentObj.Insurance__c?currentObj.Insurance__c:0;
        //let rtoTaxes = currentObj.RTO_Taxes__c?currentObj.RTO_Taxes__c:0;
        //let finalDisValue = currentObj.Net_of_Discount_Price__c?currentObj.Net_of_Discount_Price__c:0;
        var finalValue = 0;
        //let helpText;
        let result = this.onRoadPriceFields;
        console.log('result are '+result)
        for (let key in result){
            if(result[key].Active__c && (!result[key]?.Vehicle_Type__c || [ 'Both', this.vehicleType ].includes(result[key]?.Vehicle_Type__c))){
                let obj = result[key].Name__c;
                let currentVal = this.newVehicleRecord[obj] ? parseInt(this.newVehicleRecord[obj]) : 0;
                finalValue = parseInt(finalValue) + currentVal;
                /*if(helpText){
                    helpText = helpText +' + ' +result[key].Label;
                }else{
                    helpText = result[key].Label;
                }*
            }
        }
        //this.onRoadPriceHelpText = helpText;
        //console.log('this.onRoadPriceHelpText '+this.onRoadPriceHelpText)
        //parseInt Converts a string to an integer.
        /*if(insurancePrice || rtoTaxes || finalDisValue){
            finalValue = parseInt(insurancePrice)+parseInt(rtoTaxes) +parseInt(finalDisValue);
            //this.onRoadPrice = finalValue;
            currentObj.On_Road_Price__c = finalValue.toFixed(2);
            currentObj.Customer_equity__c= currentObj.On_Road_Price__c-this.loanApplicationRecord.Loan_Amount__c;
            this.newVehicleRecord = currentObj;
            
        }*
        if (this.onRoadPrice !== finalValue) {
            //...get Vehicle category
            const product = this.isEv ? FUEL_TYPE_ELECTRIC : this.newVehicleRecord.Collateral_Name__c;
            this.evaluateVehicleCategoryBasedOnRoadPrice(product, finalValue);
        }
        this.onRoadPrice = finalValue;
        currentObj.On_Road_Price__c = finalValue.toFixed(2);
        let loanAmount = parseInt(this.loanApplicationRecord.Loan_Amount__c);
        currentObj.Customer_equity__c = currentObj.On_Road_Price__c - loanAmount;
        this.newVehicleRecord = currentObj;
        return finalValue.toFixed(2);
        */
    }

    get ltvofferedExshowroomPrice() {
        let currentObj = Object.assign({}, this.newVehicleRecord);
        let apportionedLoanAmount = currentObj.Apportioned_Loan_Amount__c ? currentObj.Apportioned_Loan_Amount__c : 0;
        let lsValue = currentObj.LS_Value__c ? currentObj.LS_Value__c : 0;
        let nodprice = currentObj.Net_of_Discount_Price__c ? currentObj.Net_of_Discount_Price__c : 0;
        let finalValue = 0;
        //parseInt Converts a string to an integer.
        if (parseInt(apportionedLoanAmount) >= parseInt(lsValue)) {

            if (apportionedLoanAmount && nodprice !== 0) {
                finalValue = ((parseInt(apportionedLoanAmount) - parseInt(lsValue)) / parseInt(nodprice)) * 100
                //this.finalDisValue = finalValue;
                currentObj.LTV_offered_Ex_showroom__c = finalValue.toFixed(2);
                this.newVehicleRecord = currentObj;
            }
            if (apportionedLoanAmount && nodprice == 0) {
                finalValue = (parseInt(apportionedLoanAmount) - parseInt(lsValue)) * 100
                //this.finalDisValue = finalValue;
                currentObj.LTV_offered_Ex_showroom__c = finalValue.toFixed(2);
                this.newVehicleRecord = currentObj;
            }
        }
        return finalValue.toFixed(2);
    }

    get ltvOfferedOnroadPrice() {
        let currentObj = Object.assign({}, this.newVehicleRecord);
        let apportionedLoanAmount = currentObj.Apportioned_Loan_Amount__c ? currentObj.Apportioned_Loan_Amount__c : 0;
        let lsValue = currentObj.LS_Value__c ? currentObj.LS_Value__c : 0;
        let onRoadPrice = currentObj.On_Road_Price__c ? currentObj.On_Road_Price__c : 0;
        let finalValue = 0;
        //parseInt Converts a string to an integer.
        if (parseInt(apportionedLoanAmount) >= parseInt(lsValue)) {

            if (apportionedLoanAmount && onRoadPrice !== 0) {
                finalValue = ((parseInt(apportionedLoanAmount) - parseInt(lsValue)) / parseInt(onRoadPrice)) * 100
                //this.finalDisValue = finalValue;
                currentObj.LTV_offered_On_road__c = finalValue.toFixed(2);
                this.newVehicleRecord = currentObj;
            }
            if (apportionedLoanAmount && onRoadPrice == 0) {
                finalValue = (parseInt(apportionedLoanAmount) - parseInt(lsValue)) * 100
                //this.finalDisValue = finalValue;
                currentObj.LTV_offered_On_road__c = finalValue.toFixed(2);
                this.newVehicleRecord = currentObj;
            }
        }
        return finalValue.toFixed(2);
    }

    get ltvOfferedStyles() {
        return this.isLTVInvalid ? 'slds-has-error' : '';
    }

    get ltvOfferedLabelStyles() {
        return this.isLTVInvalid ? 'slds-form-element__label slds-text-color_error' : 'slds-form-element__label';
    }

    get isLTVInvalid() {
        return !!(+this.newVehicleRecord?.Apportioned_Loan_Amount__c && +this.newVehicleRecord?.Final_Cost__c && (this.ltvOffered > 100));
    }

    get loanEligibilty() {
        let currentObj = Object.assign({}, this.newVehicleRecord);
        let approvedLtvAmount = currentObj.Approved_LTV__c ? currentObj.Approved_LTV__c : 0;
        let costToConsider = currentObj.Cost_to_be_Consider__c ? currentObj.Cost_to_be_Consider__c : 0;
        let netOfDiscountPrice = currentObj.Net_of_Discount_Price__c ? currentObj.Net_of_Discount_Price__c : 0;
        let maxFunding = currentObj.Max_Funding_Cap__c ? currentObj.Max_Funding_Cap__c : 0;
        let finalValue = 0;
        if (!this.isSingleImplement && approvedLtvAmount && costToConsider !== 0) {
            finalValue = (parseInt(approvedLtvAmount) / 100) * parseInt(costToConsider);
        }
        else if (this.isSingleImplement && approvedLtvAmount && netOfDiscountPrice !== 0) {
            finalValue = (parseInt(approvedLtvAmount) / 100) * parseInt(netOfDiscountPrice);
            if(maxFunding !== 0 && maxFunding < finalValue){
                finalValue = parseInt(maxFunding);
            }
        }
        currentObj.Loan_Eligibilty__c = finalValue.toFixed(2);
        this.newVehicleRecord = currentObj;
        return finalValue.toFixed(2);
    }

    get ltvOffered() {
        let currentObj = Object.assign({}, this.newVehicleRecord);
        let loanAmtonProposedAsset = currentObj.Apportioned_Loan_Amount__c ? currentObj.Apportioned_Loan_Amount__c : 0;
        let costToConsider = currentObj.Cost_to_be_Consider__c ? currentObj.Cost_to_be_Consider__c : 0;
        let netOfDiscountPrice = currentObj.Net_of_Discount_Price__c ? currentObj.Net_of_Discount_Price__c : 0;
        let finalValue = 0;
        if (!this.isSingleImplement && loanAmtonProposedAsset && costToConsider !== 0) {
            finalValue = parseInt(loanAmtonProposedAsset) / parseInt(costToConsider);
            finalValue = finalValue * 100;
        }
        else if (this.isSingleImplement && loanAmtonProposedAsset && netOfDiscountPrice !== 0) {
            finalValue = parseInt(loanAmtonProposedAsset) / parseInt(netOfDiscountPrice);
            finalValue = finalValue * 100;
        }
        currentObj.LTV_offered__c = finalValue.toFixed(2);
        currentObj.LTV_offered_On_final_cost__c = finalValue.toFixed(2);
        this.newVehicleRecord = currentObj;
        return finalValue.toFixed(2);
    }

    get ltvOfferedOnFinalCost() {
        let currentObj = Object.assign({}, this.newVehicleRecord);
        let apportionedLoanAmount = currentObj.Apportioned_Loan_Amount__c ? currentObj.Apportioned_Loan_Amount__c : 0;
        let finalCost = currentObj.Final_Cost__c ? currentObj.Final_Cost__c : 0;
        let finalValue = 0;
        //parseInt Converts a string to an integer.

        if (apportionedLoanAmount && finalCost !== 0) {
            finalValue = (parseInt(apportionedLoanAmount) / parseInt(finalCost)) * 100;
            //this.finalDisValue = finalValue;
            //commenting for Drop 1
            //currentObj.LTV_offered_On_final_cost__c = finalValue.toFixed(2);
            this.newVehicleRecord = currentObj;
        }
        if (apportionedLoanAmount && finalCost == 0) {
            finalValue = parseInt(apportionedLoanAmount) * 100;
            //commenting for Drop 1
            //currentObj.LTV_offered_On_final_cost__c = finalValue.toFixed(2);
            this.newVehicleRecord = currentObj;
        }
        return finalValue.toFixed(2);
    }


    get netOfDiscountPrice() {
        let currentObj = Object.assign({}, this.newVehicleRecord);
        let exShowroomPrice = currentObj.Ex_Showroom_Price__c ? currentObj.Ex_Showroom_Price__c : 0;
        let discountValue = currentObj.Discount__c ? currentObj.Discount__c : 0;
        let finalValue = 0;
        //parseInt Converts a string to an integer.
        if (parseInt(exShowroomPrice) >= parseInt(discountValue)) {

            if (exShowroomPrice || discountValue) {
                finalValue = parseInt(exShowroomPrice) - parseInt(discountValue)
                //this.finalDisValue = finalValue;
                currentObj.Net_of_Discount_Price__c = finalValue.toFixed(2);
                this.newVehicleRecord = currentObj;
            }
        }
        return finalValue.toFixed(2);
    }

    get costToConsider() {
        let currentObj = Object.assign({}, this.newVehicleRecord);
        let netOfDiscountPrice = this.netOfDiscountPrice ? this.netOfDiscountPrice : 0;
        let FMP = currentObj.FMP__c ? currentObj.FMP__c : 0;
        let finalValue = 0;
        //parseInt Converts a string to an integer.
        if (parseInt(netOfDiscountPrice) >= parseInt(FMP)) {
            finalValue = parseInt(FMP);
        }
        else{
            finalValue = parseInt(netOfDiscountPrice);
        }
        currentObj.Cost_to_be_Consider__c = finalValue.toFixed(2);
        this.newVehicleRecord = currentObj;
        return finalValue.toFixed(2);
    }


    isInsuranceAmountValid() {
        let isValid = true;
        let insurance = parseInt(this.newVehicleRecord.Insurance__c, 10);
        let rtoTaxesValue = parseInt(this.newVehicleRecord.RTO_Taxes__c, 10);
        let maximumAssPrice = parseInt(this.maximumPrice, 10);
        let loanAmount = parseInt(this.loanAmount, 10)
        let accessLoanAmount = parseInt(this.label.AUSFAccessoriesLoanAmount, 10);
        let maxAccessAmount = parseInt(this.label.AUSFAccessoriesMaxAmount, 10);
        if (loanAmount > accessLoanAmount) {
            maximumAssPrice = maxAccessAmount;
        }
        console.log('insurance 123 ' + insurance)
        console.log('rtoTaxesValue 123 ' + insurance)
        console.log('max price 123 ' + maximumAssPrice)
        //let visibledFieldList = this.visibledFields;
        //console.log('visibledFieldList '+JSON.stringify(visibledFieldList))
        let inputFields = this.template.querySelectorAll(".insurance");
        //&& visibledFieldList.includes(inputField.name) && visibledFieldList.includes(inputField.name)
        inputFields.forEach(inputField => {
            if (inputField.value) {
                let currentVal = parseInt(inputField.value, 10)
                if (inputField.name === 'Insurance_Value__c') {
                    console.log('inputField.value 123 ' + inputField.value)
                    if (insurance < currentVal) {
                        inputField.setCustomValidity("Insurance Amount can not be greater than Insurance");
                        inputField.reportValidity();
                    } else {
                        inputField.setCustomValidity("")
                        inputField.reportValidity();
                    }
                }
                if (inputField.name === 'RTO_Tax_Value__c') {
                    if (rtoTaxesValue < currentVal) {
                        inputField.setCustomValidity("RTO Amount can not be greater than RTO Taxes");
                        inputField.reportValidity();
                    } else {
                        inputField.setCustomValidity("")
                        inputField.reportValidity();
                    }
                }
                if (inputField.name === 'Accessories_Value__c') {

                    if (maximumAssPrice < currentVal) {
                        inputField.setCustomValidity("Accessories Amount can not be greater than " + maximumAssPrice);
                        inputField.reportValidity();
                    } else {
                        inputField.setCustomValidity("")
                        inputField.reportValidity();
                    }
                }

                console.log('field name is >>' + inputField.name);
            }
        });
    }

    isYearInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.year');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
            //this.contact[inputField.name] = inputField.value;
        });
        return isValid;
    }

    isInputValid() {
        let isValid = true, areFormatsValid = true;;
        let insurance = parseInt(this.newVehicleRecord.Insurance__c, 10);
        let rtoTaxes = parseInt(this.newVehicleRecord.RTO_Taxes__c, 10);
        let isAuInsurance = parseInt(this.newVehicleRecord.Insurance_Value__c, 10);
        let isAccessVal = parseInt(this.newVehicleRecord.Accessories_Value__c, 10);
        let isAuLs = parseInt(this.newVehicleRecord.RTO_Tax_Value__c, 10);
        let visibledFieldList = this.visibledFields;
        console.log('visibledFieldList ' + JSON.stringify(visibledFieldList))
        let inputFields = this.template.querySelectorAll(".validate");
        //&& visibledFieldList.includes(inputField.name)
        inputFields.forEach(inputField => {
            // R2-2372
            if(inputField.name === 'Hours_Meter_Reading__c'){
                isValid = inputField.reportValidity();
            }
            // R2-2372
            if (!inputField.value && visibledFieldList.includes(inputField.name)) {
                //inputField.setCustomValidity("Complete this field");
                inputField.reportValidity();
                isValid = false;
                console.log('field name is >>' + inputField.name);
            } else {
                if (isAuInsurance || isAuLs || isAccessVal) {
                    let currentVal = parseInt(inputField.value, 10);

                    if (inputField.name === 'Insurance_Value__c' && currentVal > insurance && visibledFieldList.includes(inputField.name)) {
                        inputField.setCustomValidity("Insurance Amount can not be greater than insurance");
                        inputField.reportValidity();
                        isValid = false;
                        console.log('field name is >>' + inputField.name);
                    }
                    if (inputField.name === 'RTO_Tax_Value__c' && currentVal > rtoTaxes && visibledFieldList.includes(inputField.name)) {
                        inputField.setCustomValidity("RTO Amount can not be greater than RTO Taxes");
                        inputField.reportValidity();
                        isValid = false;
                        console.log('field name is >>' + inputField.name);
                    }

                    let maximumAssPrice = parseInt(this.maximumPrice, 10);
                    let loanAmount = parseInt(this.loanAmount, 10)
                    let accessLoanAmount = parseInt(this.label.AUSFAccessoriesLoanAmount, 10);
                    let maxAccessAmount = parseInt(this.label.AUSFAccessoriesMaxAmount, 10);
                    if (loanAmount > accessLoanAmount) {
                        maximumAssPrice = maxAccessAmount;
                    }

                    if (inputField.name === 'Accessories_Value__c' && currentVal > maximumAssPrice && visibledFieldList.includes(inputField.name)) {
                        inputField.setCustomValidity("Accessories Amount can not be greater than " + maximumAssPrice);
                        inputField.reportValidity();
                        isValid = false;
                        console.log('field name is >>' + inputField.name);
                    }

                }
                console.log(inputField.name, inputField.value, FIELD_FORMATS[inputField.name]);
                if ((FIELD_FORMATS.hasOwnProperty(inputField.name)) && !FIELD_FORMATS[inputField.name]?.test(inputField.value)) {
                    console.log('===== Validating format ==', inputField.name);
                    areFormatsValid = false;
                    inputField.setCustomValidity(FIELD_FORMATS_ERROR[inputField.name] ?? 'Format is not valid');
                    inputField.reportValidity();
                    console.log(' === populating errors ===', inputField.name, FIELD_FORMATS_ERROR[inputField.name]);
                } else if (FIELD_FORMATS.hasOwnProperty(inputField.name)) {
                    console.log(' === clearing errors ===', inputField.name);
                    inputField.setCustomValidity('');
                    inputField.reportValidity();
                }
            }

        });

        // const { [ EX_SHOWROOM_FIELD_API ]: exShowRoomPrice } = this.newVehicleRecord;
        const { POS__c: posValue, Final_Cost__c: vehicleFinalCost, Apportioned_Loan_Amount__c: loanAmount } = this.newVehicleRecord, posValueNum = +(posValue ?? 0), vehicleFinalCostNum = +vehicleFinalCost;
        console.log(posValue, loanAmount, vehicleFinalCost);
        if(isValid && ((+posValueNum + +loanAmount) > vehicleFinalCostNum)){
            this.showToast( 'Loan Amount can not be greater than Final Cost of the vehicle', 'error' );
            isValid = false;
        } else if(this.isLTVInvalid){
            isValid = false;
        } /*:: NOT needed SFAU - 2426 / 3007 - else if(isValid && exShowRoomPrice && exShowRoomPrice <= +this.newVehicleRecord[LOAN_AMOUNT_FIELD_API]){
            isValid = false;
            // this.updateDataInVariable({ target: { name: EX_SHOWROOM_FIELD_API, value: null }});
            this.showToast('Ex-Showroom price can not be equal or less than Loan Amount','error');
        }*/

        console.log('isValid>> ' + isValid)
        return { isValid, areFormatsValid };
    }

    async handleGetPriceDetails() {
        if (this.disableGetPriceDetails) return;

        this.isLoaded = true;
        const variantId = this.variantId;
        const cityId = this.cityId;
        const loanApplicationId = this.recordId;

        let callapi = false;
        if (variantId && cityId) {
            callapi = true;
            this.isLoaded = false;
        } else {
            if (!variantId) {
                this.showToast('Variant Id is not present', 'error')
            }
            if (!cityId) {
                this.showToast('City is required', 'error')
            }
            this.isLoaded = false;
        }
        if (callapi) {
            const pricingDetails = await getVehiclePricing({ loanApplicationId, variantId, cityId }).catch(() => { this.showToast('Something Went Wrong,Please try again.', 'error') });
            console.log({ pricingDetails });
            if (pricingDetails?.statusCode !== 200 || pricingDetails?.errorMessage) {
                this.isLoaded = false;
                this.showToast(pricingDetails.errorMessage ?? 'Something Went Wrong,Please try again.', 'error');
                return;
            }
            this.newVehicleRecord = this.populatePricingProperties(this.newVehicleRecord, pricingDetails);
            this.isLoaded = false;
        }
    }


    getPicklistOptions(makeValue, modelValue, collateralNameValue, fieldNameValue) {
        console.log(' === Loan Application ==> ', JSON.parse(JSON.stringify(this.loanApplicationRecord || {})));
        //vehicleUsage, String state,String scheme,String manufacturer
        getPickListValues({ make: makeValue, model: modelValue, collateralName: collateralNameValue, fieldName: fieldNameValue, collateralType: this.newVehicleRecord.Collateral_Name__c, screenType:this.screenType, implementType:'' })
            .then(data => {
                if (data) {
                    console.log('data is>>' + JSON.stringify(data))
                    console.log('PicklistValues-->' + JSON.stringify(data[fieldNameValue]));
                    if (fieldNameValue === 'Make') {
                        this.makeOptions = data[fieldNameValue];
                        this.desableField.Make__c = false;
                    }
                    if (fieldNameValue === 'Model') {
                        this.modelOptions = data[fieldNameValue];
                        this.desableField.Model__c = false;
                    }
                    if (fieldNameValue === 'Variant') {
                        this.variantOptions = data[fieldNameValue];
                        this.desableField.Variant__c = false;
                    }
                    if (fieldNameValue === 'Implement') {
                        this.implementNames = data[fieldNameValue];
                        this.isSingleImplement = true;
                        //this.desableField.Variant__c = false;
                    }
                    this.isLoaded = false;
                }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
                this.isLoaded = false;
            })
    }

    handleCategoryChange(event) {
        this.updateDataInVariable(event)
        //this.getSchemePickListValues();
        this.getDLPFMPMaster();
    }

    getDLPFMPMaster(){
        this.isLoaded = true;
        Promise.all([
            getApplicantFinancials({ loanApp: this.loanApplicationRecord}),
            getDLPFMPMasterRecord({ loanApp: this.loanApplicationRecord, mapOfColl: JSON.stringify(this.newVehicleRecord)}),
            getLtvMasterRecordAgainstFMV({ loanApp: this.loanApplicationRecord, mapOfColl: JSON.stringify(this.newVehicleRecord)})
        ]).then((values) => {
            if(values[0] != undefined){
                console.log('error is ' + JSON.stringify(values[0]));
                this.applicantFinancialsRecord = values[0];
            }
            if(values[1] != undefined){
                console.log('error is ' + JSON.stringify(values[1]));
                this.dlpMasterRecord = values[1];
                this.newVehicleRecord.FMP__c = this.dlpMasterRecord.FMV_Price_AU_Grid_Price__c;
                this.newVehicleRecord.Max_Funding_Cap__c = this.dlpMasterRecord.Max_Caping__c;
            }
            if(values[2] != undefined){
                console.log('error is ' + JSON.stringify(values[2]));
                this.ltvMasterRecord = values[2];
                this.newVehicleRecord.LTV_Record__c = JSON.stringify(values[2]);
                if(this.applicantFinancialsRecord && this.newVehicleRecord.Original_Vehicle_Usage__c == 'Agri'){
                    if(this.applicantFinancialsRecord.Applicant__r.Loan__r.Net_Land_Holding_in_Acre__c == 0){
                        this.newVehicleRecord.Approved_LTV__c = this.ltvMasterRecord.Agri_0_Land__c;
                    }
                    if(this.applicantFinancialsRecord.Applicant__r.Loan__r.Net_Land_Holding_in_Acre__c < 3){
                        this.newVehicleRecord.Approved_LTV__c = this.ltvMasterRecord.Agri_Less_than_3_Land__c;
                    }
                    if(this.applicantFinancialsRecord.Applicant__r.Loan__r.Net_Land_Holding_in_Acre__c >= 3){
                        this.newVehicleRecord.Approved_LTV__c = this.ltvMasterRecord.Agri_More_than_3_Land__c;
                    }
                }
                if(this.applicantFinancialsRecord && this.newVehicleRecord.Original_Vehicle_Usage__c == 'Commercial'){
                    if(this.applicantFinancialsRecord.Applicant__r.Loan__r.Customer_Grade__c == 'FTU'){
                        this.newVehicleRecord.Approved_LTV__c = this.ltvMasterRecord.Commercial_FTU__c;
                    }
                    if(this.applicantFinancialsRecord.Applicant__r.Loan__r.Customer_Grade__c == 'FTB'){
                        this.newVehicleRecord.Approved_LTV__c = this.ltvMasterRecord.Commercial_FTB__c;
                    }
                    if(this.applicantFinancialsRecord.Applicant__r.Loan__r.Customer_Grade__c == 'Transporter'){
                        this.newVehicleRecord.Approved_LTV__c = this.ltvMasterRecord.Commercial_Transporter__c;
                    }
                    if(this.applicantFinancialsRecord.Applicant__r.Loan__r.Customer_Grade__c == 'Captive'){
                        this.newVehicleRecord.Approved_LTV__c = this.ltvMasterRecord.Commercial_Captive__c;
                    }
                }
            }
            this.newVehicleRecord = {...this.newVehicleRecord};
            this.isLoaded = false;
        })
        .catch(error => {
            console.log('error is ' + JSON.stringify(error));
            this.isLoaded = false;
        })
    }

    handleVehicleDeliveryChange(event) {
        //this.newVehicleRecord.Vehicle_Delivery__c = event.target.value;
        let currentObj = Object.assign({}, this.newVehicleRecord);
        currentObj[event.target.name] = event.target.value;
        this.newVehicleRecord = currentObj;
        if(event.target.value == 'Yes'){
            this.isCollateralRequired = true;
        }
        else{
            this.isCollateralRequired = false;
        }
    }

    handleVaiantValueChange(event) {
        //this.updateDataInVariable(event)
        this.variantOptionValue = event.target.value;
        console.log('master id is  ' + this.variantOptionValue)
        // this.schemeOptionValue = event.target.value;
        this.newVehicleRecord.MMV_Master__c = event.target.value;
        this.getNewCategoryPickListValues(event.target.value);
        this.getMMVRecord(this.newVehicleRecord.MMV_Master__c);
    }

    getMMVRecord(mmvMasterId){
        getMmvRecord({ variant: mmvMasterId })
        .then(data => {
            if (data) {
                console.log('data is>>' + JSON.stringify(data))
                this.newVehicleRecord.HP__c = data.HP__c;
                this.newVehicleRecord = {...this.newVehicleRecord};
            }
        })
        .catch(error => {
            console.log('error is ' + JSON.stringify(error));
            this.isLoaded = false;
        })
    }
    
    /*
    getSchemePickListValues() {
        this.isLoaded = true;
        //vehicleUsage, String state,String scheme,String manufacturer
        getSchemePickListValues({ loanApp: this.loanApplicationRecord, app: this.applicantRecord, category: this.newVehicleRecord.Vehicle_Category__c, collCode: this.newVehicleRecord.Collateral_Name__c })
            .then(data => {
                if (data) {
                    console.log('data is getSchemePickListValues>>' + JSON.stringify(data))
                    console.log('PicklistValues getSchemePickListValues-->' + JSON.stringify(data.schemeValues.Scheme));
                    this.vehicleSchemeOptions = data.schemeValues.Scheme;
                    this.schemeMasterRecord = data.schemeMaster;
                    this.desableField.Scheme__c = false;
                    this.isLoaded = false;
                } else {
                    this.isLoaded = false;
                }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
                this.isLoaded = false;
            })
    }
    */

    getNewCategoryPickListValues(variantValue) {
        this.isLoaded = true;
        //vehicleUsage, String state,String scheme,String manufacturer
        getNewCategoryPickListValues({ coll: JSON.stringify(this.newVehicleRecord) })
            .then(data => {
                if (data) {
                    console.log('data is Category>>' + JSON.stringify(data))
                    console.log('PicklistValues Category-->' + JSON.stringify(data.Category));
                    console.log('PicklistValues VariantId-->' + JSON.stringify(data.VariantId));
                    this.desableField.Vehicle_Category__c=false;
                    this.desableField.Fuel_Type__c=false;
                    this.vehicleCategoryOptions = data.Category;
                    this.fuelTypeOptions = data.FuelType;
                    this.setDefaultFieldValue(data.FuelType, 'Fuel_Type__c');

                    if ((data.VariantId != null || data.VariantId != undefined) && data.VariantId.length > 0) {
                        this.variantId = data.VariantId[0].label;
                        console.log('variantId is ' + this.variantId)
                    }
                    if ((data.MaxAmount != null || data.MaxAmount != undefined) && data.MaxAmount.length > 0) {
                        this.maximumPrice = data.MaxAmount[0].label;
                    }
                    if (data.CollateralName.length > 0) {
                        this.collateralNames = data.CollateralName;
                        if (data.CollateralName.length == 1) {
                            this.newVehicleRecord.Collateral_Name__c = data.CollateralName[0].value;

                            const product = this.isEv ? FUEL_TYPE_ELECTRIC : this.newVehicleRecord.Collateral_Name__c;
                            this.mapVehicleCategoryFor2W(this.isTwoWheeler, product);
                        }
                    }
                    if(data.LuxuryVehicle?.length){
                        const [ luxuryVehicle ] = data.LuxuryVehicle;
                        if(luxuryVehicle){
                            this.newVehicleRecord.Luxury_Non_Luxury__c = luxuryVehicle.value;
                        }
                    }
                    // SFAU-4545 - auto-populate vehicle category
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

    handleSubmitForm(){
        restricAccess({
            compName: 'ausfVehicleParent' ,loanId: this.recordId
            })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
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
                let { isValid, areFormatsValid } = this.isInputValid();
                let isYearValid = this.isYearInputValid();
                let isHMRValid = true;
                if(Number(this.newVehicleRecord.Hours_Meter_Reading__c) < 0 || Number(this.newVehicleRecord.Hours_Meter_Reading__c) > 100000){
                    isHMRValid = false;
                }

                if(!isValid || !isYearValid){
                    this.showToast('Please fill the Mandatory Data','error');
                    return;
                } else if(!areFormatsValid){
                    this.showToast( 'Please correct field errros','error' );
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
                if(Number(this.newVehicleRecord.Apportioned_Loan_Amount__c) - Number(this.newVehicleRecord.Other_Funding_Total__c) > Number(this.newVehicleRecord.Loan_Eligibilty__c)
                    && this.newVehicleRecord.Collateral_Name__c == this.label.Self_Propelled_Collateral_Code){
                    this.showToast( 'The Permisible amount is '+ this.newVehicleRecord.Loan_Eligibilty__c+' and it will go for deviation', 'info' );
                }
                console.log('isValid '+isValid +'isYearValid '+isYearValid)
                // let color = this.newVehicleRecord.Vehicle_Color__c; 
                // if(color){
                    if(isValid && isYearValid && isHMRValid){
                        this.upsertVehicleInfo();
                    }
                // }else{
                    // this.showToast('Please Select Vehicle Color','error');
                // }
                }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
            })
    }

    @wire(getObjectInfo, { objectApiName: COLLATERAL_RECORD })
    objectInfo;

    @wire(getPicklistValuesByRecordType, {
        objectApiName: COLLATERAL_RECORD,
        recordTypeId: "$objectInfo.data.defaultRecordTypeId"
    })
    wiredValues({ error, data }) {
        if (data) {
            this.vehicleUsageOptions = data.picklistFieldValues.Vehicle_Usage__c.values;
            this.LTVEnhancerOptions = data.picklistFieldValues.LTV_Enhancer__c.values
            this.engineCategoryOptions = data.picklistFieldValues.Engine_Category__c.values;
            this.lsOptions = data.picklistFieldValues.LS__c.values;
            this.bodyOptions = data.picklistFieldValues.Body__c.values;
            this.assessoriesOptions = data.picklistFieldValues.Accessories_Funding__c.values;
            this.rtoTaxOptions = data.picklistFieldValues.RTO_Tax__c.values;
            this.insuranceFundingOptions = data.picklistFieldValues.Insurance_Funding__c.values;
            this.assessmentMethodOptions = data.picklistFieldValues.Assessment_Method__c.values;
            this.collateralAllOptions = data.picklistFieldValues.Collateral_Name__c.values;
            this.companyofLoanSurakshaOptions = data.picklistFieldValues.Company_of_Loan_suraksha__c.values;
            this.productofLoanSurakshaOptions = data.picklistFieldValues.Product_of_Loan_suraksha__c.values;
            console.log('optios ' + JSON.stringify(this.collateralAllOptions))
            //this.fuelTypeOptions = data.picklistFieldValues.Fuel_Type__c.values;
            this.error = undefined;
        } else {
            this.error = error;
            console.log('error is ' + error)
        }
    }

    handleCancelForm() {
        this.addNewApplicant = false;
        //this.editVehicleRecordPage = false;
        this.showSection = true;
        this.showMainSection = true;
        console.log('data is ' + JSON.stringify(this.applicantLst))
        if (this.screenType === 'Used') {
            if (!(this.applicantLst || this.searchData)) {
                this.showSearchScreen = true;
            }

        }
    }

    showToast(message, variant) {
        const event = new ShowToastEvent({
            title: '',
            message: message,
            variant: variant,
            mode: 'sticky'
        });
        this.dispatchEvent(event);
    }

    @api nextHandler() {
        let vehicleRecord = this.applicantLst;
        this.errorOnChild = vehicleRecord.length > 0 ? '' : 'Please create vehicle record';
        const Obj = {};
        //this.errorOnChild = '';
        //Obj.applicantRecord = this.applicantIdInput;
        Obj.errorOnChild = this.errorOnChild;
        Obj.next = this.errorOnChild === '' ? true : false;
        if (Obj.next === false) {
            this.showToast(this.errorOnChild, 'error');
        }
        console.log('Obj', Obj);
        this.dispatchEvent(new CustomEvent('next', {
            detail: Obj
        }));
    }

    closeModal(event) {
        const obj = event.detail;
        console.log('obj is ' + obj)
        this.isModalOpen = obj.isModalOpen;
    }

    showDetails(event) {
        console.log('in show details')
        const obj = event.detail;
        console.log('obj is ' + obj)
        this.showLoanDetails = obj.showLoanDetails;
        this.showVehicle = false;
        this.isModalOpen = obj.isModalOpen;
        this.dispatchEvent(new CustomEvent('updateloandetail'));
    }

    showVehicleDetail(event) {
        const obj = event.detail;
        console.log('show>> is ' + JSON.stringify(obj))
        if (obj.ROI__c) {
            this.loanApplicationRecord.ROI__c = obj.ROI__c;
        }
        if (obj.Loan_Amount__c) {
            this.loanApplicationRecord.Loan_Amount__c = obj.Loan_Amount__c;
        }
        if (obj.Tenure__c) {
            this.loanApplicationRecord.Tenure__c = obj.Tenure__c;
        }
        this.showVehicle = true;
        this.showLoanDetails = false;
        this.getVisibleFields();
        this.dispatchEvent(new CustomEvent('updateloandetail'));
    }

    getSelectedCollateral(event) {
        this.selectedCollList = event.detail;
        console.log('selected Coll is 123 ' + JSON.stringify(this.selectedCollList))
    }

    getDeletedCollateral(event) {
        this.deletedCollList = event.detail;
        console.log('selected Coll is 123 ' + JSON.stringify(this.deletedCollList))
    }

    populatePricingProperties = (vehicleRecord, { pricing }) => {
        this.desableField = this.disableFieldsRecievedFromApi(this.desableField, pricing);
        const vehicleExShowroomPrice = pricing?.price ?? pricing?.ex_showroom_price;
        return ({
            ...vehicleRecord,
            Ex_Showroom_Price__c: vehicleExShowroomPrice,
            Ex_Showroom_Price_API__c: vehicleExShowroomPrice,
            Final_Cost__c: pricing?.price,
            Insurance__c: pricing?.insurance,
            RTO_Taxes__c: pricing?.rto,
            On_Road_Price__c: pricing?.on_road_price
        });
    }
    disableFieldsRecievedFromApi(disabledFields, pricing) {
        for (const key in API_RESPONSE_TO_FIELD_MAPPING) {
            if (key in pricing) {
                API_RESPONSE_TO_FIELD_MAPPING[key].forEach(item => { disabledFields[item] = true; });
            }
        }
        return disabledFields;
    }
    async getMaterialSettings(strScreen, strLoanId) {
        const fields = await getMaterialFields({ strScreen, strLoanId }).catch(err => this.showToast('Something went wrong! Please contact System Administrator', 'error'));
        console.log(fields);
        this.configurations = { materialSettings: fields.map(field => field.toLowerCase()) || [] };
    }

    async applyMaterialSettings() {
        await Promise.resolve();
        const fieldTokens = this.template.querySelectorAll('lightning-input, lightning-combobox');
        updateDisabledOnFieldTokens([...fieldTokens], this.configurations.materialSettings, true);
    }

    async evaluateVehicleCategoryBasedOnRoadPrice(product, onRoadPrice) {
        console.log(' === evaluateVehicleCategoryBasedOnRoadPrice ===> ~', { product, onRoadPrice });
        if (product) {
            const { productToPriceMappings } = this.configurations;
            const selectedProductToPriceMapping = productToPriceMappings?.find(mapping => mapping.Product__c?.toLowerCase() === product && (onRoadPrice >= mapping.Min_On_Road_Price__c && onRoadPrice <= mapping.Max_On_Road_Price__c));
            if (selectedProductToPriceMapping) {
                await Promise.resolve();

                this.vehicleCategoryOptions = [selectedProductToPriceMapping].map(({ Vehicle_Category__c: label }) => ({ label, value: label }));
                this.handleCategoryChange({ target: { name: 'Vehicle_Category__c', value: selectedProductToPriceMapping.Vehicle_Category__c } });
            }
        }
    }

    mapVehicleCategoryFor2W(is2W, productName) {
        if (is2W && productName) {
            this.vehicleCategoryOptions = this.configurations.productToPriceMappings
                ?.filter(mapping => mapping.Product__c?.toLowerCase() === productName)
                .map(({ Vehicle_Category__c: value }) => ({ label: value?.replaceAll('_', ' '), value }));
        }
    }

    async setDefaultFieldValue(picklistOptions, fieldApi) {
        if (picklistOptions?.length === 1) {
            const [{ value }] = picklistOptions;
            this.desableField = { ...this.desableField, [fieldApi]: true };
            this.handleValueChange({ target: { name: fieldApi, value } });
        }
    }
    // SFAU-4545 - auto-populate vehicle category
    async setDefaultCategoryValue( picklistOptions, fieldApi ) {
        if( picklistOptions?.length === 1 ) {
            const [{ value }] = picklistOptions;
            this.handleCategoryChange({ target: { name: fieldApi, value } });
        }
    }
    async validateMaterialFields(strScreen, strLoanId, lstFieldsAPI) {
        console.log(' == Make Field ==> ', this.isDirtyField(this._vehicleRecord, { [MAKE_FIELD_API]: this.makeOptionValue }, MAKE_FIELD_API));
        if (this.isDirtyField(this._vehicleRecord, { [MAKE_FIELD_API]: this.makeOptionValue }, MAKE_FIELD_API)) {
            await checkMaterialFields({ strScreen, strLoanId, lstFieldsAPI })
                .catch(err => { console.error(err); this.showToast(err.body?.message ?? '(Material Fields)Something went wrong! Please contact System administrator', 'error'); });
        }
    }
    isDirtyField = (oldRecord, newRecord, fieldApi) => oldRecord?.[fieldApi] != newRecord?.[fieldApi];

    setSpinner(hasLoaded) {
        this.isLoaded = hasLoaded
    }

    handleParentLoanChange( event ){
        if( !this.newVehicleRecord.Id ){
            this.parentLoanIdentifier = event.target.value;
        }
    }

    async validateParentLoan(){

        const loanIdentifier = this.refs.parentLoan.value;
        console.log({loanIdentifier});
        this.isLoaded = true;
        const result = await validateParentLoan( { parentLoan: { Name: loanIdentifier } } )
            .catch(err => {
                console.error(err);
                const errorMessage = reduceErrors(err);
                this.showToast( errorMessage?.join(','), 'error');
            });

        this.isLoaded = false;
        console.log(result);
        if( result ){
            const { parentLoan } = result;
            console.log(parentLoan);
            const { Name: loanNumber, Collaterals__r: [ parentCollateral ] } = parentLoan;
            console.log(loanNumber, parentCollateral);
            this.parentLoan = parentLoan;
            this.parentLoanIdentifier = loanNumber;
            this.parentCollateral = parentCollateral;
        }
    }

}