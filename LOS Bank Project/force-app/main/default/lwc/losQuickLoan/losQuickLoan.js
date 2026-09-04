/*
 * LastModified Date    -   Last Modified By    -   Description
 * Oct-09-2023          -   Mohit M.            -   SFAU-5163 getVehicleUsageList
*/
import { LightningElement, track, wire, api } from 'lwc';
import getProductTypeMetadata from '@salesforce/apex/LosQuickLoanController.getRecordTypeNames';
import getDealerClassMetadata from '@salesforce/apex/LosQuickLoanController.getDealerClassNames';
import getLoanApplicationRecord from '@salesforce/apex/LosQuickLoanController.getLoanApplication';
import createLoanApplication from '@salesforce/apex/LosQuickLoanController.createLoanApplication';
import validateMobile from '@salesforce/apex/LosQuickLoanController.validateMobile';
import fetchMasterRecord from '@salesforce/apex/LosLeadCreateWizardController.fetchBranchMasterRecord';
import mobileOtpVerificationHandler from '@salesforce/apex/LOSMobileOtpController.mobileOtpVerificationHandler';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getFieldDisplayValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LOANAPPLICATION_OBJECT from '@salesforce/schema/Loan_Application__c';
import APPLICABLE_PRODUCTS_FIELD from '@salesforce/schema/User.Applicable_Products__c';
import OtpDurationLabel from '@salesforce/label/c.AUSF_RESEND_OTP_DURATION';
import SourcingChannelDependecyLabel from '@salesforce/label/c.AUSFSourcingChannelDependency';
import SourcingChannelMandatory from '@salesforce/label/c.SourcingChannelMandatory';
import getVehicleUsageOptions from '@salesforce/apex/LosLeadCreateWizardController.getVehicleUsageOptions';
import getCollateralTypeOptions from '@salesforce/apex/LosLeadCreateWizardController.getCollateralTypeOptions';
import { getLoanType, TRACTOR_PRODUCT_CODES, CV_PRODUCT_CODES, CONSTRUCTION_EQUIPMENT_PRODUCT_CODES, reduceErrors, DEBOUNCE_TIMER, delay } from 'c/lwcutilities';
import getVehicleUsageList from '@salesforce/apex/LosQuickLoanController.getVehicleUsageList';
import getDealerDetailsBySourceCode from '@salesforce/apex/LosQuickLoanController.getDealerDetailsBySourceCode';
import Implement_Collateral_Code from '@salesforce/label/c.Implement_Collateral_Code'; // SFAU-5163

const VEHICLE_USAGE_BY_TYPE = {
    'Two Wheeler': '',
    'Four Wheeler' : 'Personal'
};

const COLLATERAL_TYPE_FIELD = 'Collateral_Type__c';
const SOURCE_CODE_IDENTIFIER = 'SourceCode';
const PRODUCT_VALUE_PROPERTY = 'productOptionValue';
const SUB_PRODUCT_VALUE_PROPERTY = 'subProductOptionValue';

const FIELD_VISIBILITY_BY_PRODUCT = {
    [ COLLATERAL_TYPE_FIELD ]: [ ...CONSTRUCTION_EQUIPMENT_PRODUCT_CODES ],
    [ SOURCE_CODE_IDENTIFIER ]: [ ...CV_PRODUCT_CODES, ...CONSTRUCTION_EQUIPMENT_PRODUCT_CODES ],
};

export default class LosLeadCreateWizard extends NavigationMixin(LightningElement) {
    @api recordId;
    @api userInfo = {};
    @track mobileNumber = '';
    SourcingChannelMandatory = SourcingChannelMandatory;
    implementCollateralCode = Implement_Collateral_Code;
    isloading = false;
    selectedCountryCountryCodeLength = 3;
    boolCheckMobileNumber = true;
    enterOTPValue = ''
    currentStep = '1';
    loanAmount;
    //  loanAmountInWords = '';
    sourceNameId;
    indvidualCustomer = false;
    sourcingChannelOptionsValue = '';
    productOptionsValue = '';
    customerTypeOptionsValue = 'Individual';
    pancardForm16OptionsValue = '';
    stageOptionsValue = '';
    categoryValue = '';
    categoryChecks = false;
    isEnterOtp = false;
    loanApplicationRecord = {};
    isEnabledPanCard = false;
    @track sourcingChannelPicklistValues;
    @track sourcingNameDefaultId;
    @track vehicleUsePicklistValues;
    @track productPicklistValues;
    @track customerTypePicklistValues;
    @track stagePicklistValues;
    /* OTP Verification variable */
    @track isVerified = false;
    @track boolResendOtp = false;
    boolRequestOtp = false;
    boolSendOtp = true;
    @track isVerifiedNumber = false;;
    @track boolIsDisableVerifyButton = true;
    @track otpVerified = false;
    @track boolVerify = true;
    @track oldMobileNumberValue;
    isInTimeInterval = false;
    @track isReadOnly = false;
    @track isCustomerReadOnly = false;
    @track isSourceChannelNameReadOnly = false;  //added by Gaurav for sourcing channel should not allow to change on DDE(Bug:SFAU-2833) 
    @track increse1Second;
    errorOnChild = false;
    @api currentApplicantRecord = {};
    applicantId = '';
    productCategory = [];
    productSubCategory = [];
    mapOfProductPicklist = new Map();
    mapOfProductValueVsLabel = new Map()
    productOptionValue = '';
    subProductOptionValue = '';
    productValue = '';
    branchId;
    branchLocation = '';
    purchasingCityVal = '';
    vehicleUseOptionsValue = '';
    isShowcustomLookups = false;
    isShowSourceNameLookup = false;
    isSourcingChannelReadOnly = false;
    isLoanTypeReadOnly = false;
    isValueUpdated = false;
    @track recordSelected = {};
    productValueType = '';
    dealerClassValue = '';
    productTypeMetadataList = [];
    dealerClassMetadataList = [];
    @track isDisableVehicleUse = false;
    productCategoryToSubCatMap = new Map();
    collateralTypes = [];
    dealerSourceCode = '';
    dealerClasses = [];
    _collateralType;

    get isSourcingRequired(){
        return this.sourcingChannelOptionsValue && this.SourcingChannelMandatory.includes(this.sourcingChannelOptionsValue)
    }
    get productCode(){
        return this.mapOfProductPicklist.get( `${this.productOptionValue}(${this.subProductOptionValue})`);
    }

    get isLoanCreated(){
        console.log((JSON.stringify(this.userInfo)));
        return !!this.loanApplicationRecord?.Id;
    }

    get isCollateralTypeApplicable(){
        return !FIELD_VISIBILITY_BY_PRODUCT[COLLATERAL_TYPE_FIELD]?.includes( this.productCode ) && this.productOptionValue?.trim() !== 'Other' && this.productOptionValue?.trim() !== 'Auto Loan' && this.productOptionValue?.trim() !== 'Two Wheeler';
    }

    get isVehicleUsageApplicable(){
        return this.productOptionValue?.trim() !== 'Other';
    }

    get isSourceCodeVisible(){
        return FIELD_VISIBILITY_BY_PRODUCT[SOURCE_CODE_IDENTIFIER]?.includes( this.productCode );
    }

    // R2-1738 - Populating sourcing channel name should auto populate City of Source
    get _isShowSourceNameLookup(){
        return true;//this.isSourceCodeVisible || this.isShowSourceNameLookup;
    }

    @api nextHandler() {
        this.createLoanApplication();
    }

    @wire(getObjectInfo, { objectApiName: LOANAPPLICATION_OBJECT })
    objectInfo;


    @wire(getPicklistValuesByRecordType, { objectApiName: LOANAPPLICATION_OBJECT, recordTypeId: '$objectInfo.data.defaultRecordTypeId' })
    allDataPicklistValues({ error, data }) {
        if (data) {
            const productPicklistMap = new Map();
            const productPicklistValueVsLabelMap = new Map();
            const productCategorytMap = new Map();
            const productSubCategorytMap = new Map();

            const productPicklist = data.picklistFieldValues.Product__c.values,
                allowedProducts = this.accessibleProducts;
            productPicklist.forEach(element => {
                if( !allowedProducts.length || allowedProducts.includes( element.label ) ){
                    productPicklistMap.set(element.label, element.value);
                    productPicklistValueVsLabelMap.set(element.value, element.label);   

                    const [ product, loanType ] = getLoanType( element.label );
                    productCategorytMap.set( product, element.value );
                    productSubCategorytMap.set( loanType, element.value );
                    console.log(element.label.split('('), ' Has Entry ==', this.productCategoryToSubCatMap.has( product ));
                    if(!this.productCategoryToSubCatMap.has( product )){
                        this.productCategoryToSubCatMap.set( product, [ ] );
                    }
                    this.productCategoryToSubCatMap.get( product ).push( loanType );
                }
            });
            let productCategoryValues = Array.from(productCategorytMap.keys()).map(element => {
                return {
                    label: element,
                    value: element
                }
            });
            this.productCategory = [];
            for (let each in productCategoryValues) {
                if (productCategoryValues[each].label !== 'Other ') {
                    this.productCategory.push({label: productCategoryValues[each].label, value: productCategoryValues[each].label});
                }
            }
            this.productSubCategory = [];
            this.mapOfProductPicklist = productPicklistMap;
            this.mapOfProductValueVsLabel = productPicklistValueVsLabelMap;
            this.sourcingChannelPicklistValues = data.picklistFieldValues.Sourcing_channel__c.values;
            //this.vehicleUsePicklistValues = data.picklistFieldValues.Vehicle_use__c.values; // SFAU-5163
            this.customerTypePicklistValues = data.picklistFieldValues.Customer_Type__c.values;
            this._collateralType = ''; //triggers wire

            if (this.recordId) {
                this.getLoanApplication();
            }
            this.fetchBranchName();
            this.setDefaultValue( this.productCategory, PRODUCT_VALUE_PROPERTY );
            this.setDefaultValue( this.productSubCategory, SUB_PRODUCT_VALUE_PROPERTY );

        } else if (error) {
            console.log('error is ' + JSON.stringify(error));
        }
    }

    @wire(getCollateralTypeOptions, { product: '$productCode' })
    wireCollateralTypeOptions({ error, data }){
        console.log({ error, data });
        if(error){
            console.error( error );
        } else if(data){
            const { Collateral_Name__c: collateralTypes } = data;
            this.collateralTypes = collateralTypes;//.filter( item => item.label !== 'Body Funding' ); //R2-22 - Body can not be funded standalone | 21st Nov - Standalone Body loan for Drop one
            this.setDefaultFieldValue( collateralTypes, 'Collateral_Type__c' );
        }
    }

    @wire(getVehicleUsageOptions, { product: '$productCode', collateralType: '$_collateralType' } )
    wiredUsageOptions({ error, data }){
        console.log({ error, data });
        if(error){
            console.error( error );
        } else if(data){
            const { Vehicle_use__c: usageOptions } = data;
            this.vehicleUsePicklistValues = usageOptions;
            // this.collateralTypes = collateralTypes;//.filter( item => item.label !== 'Body Funding' ); //R2-22 - Body can not be funded standalone | 21st Nov - Standalone Body loan for Drop one
            this.setDefaultFieldValue( usageOptions, 'Original_Vehicle_Usage__c' );
            // this.setDefaultFieldValue( collateralTypes, 'Collateral_Type__c' );
        }
    }

    get accessibleProducts(){
        const applicableProducts = getFieldDisplayValue( this.userInfo ?? {}, APPLICABLE_PRODUCTS_FIELD );
        console.log(applicableProducts);
        return applicableProducts?.split?.(';') ?? [];
    }

    connectedCallback() {
        /* if (this.recordId) {
             this.getLoanApplication();
         }
         
         this.fetchBranchName();
         if (this.sourceNameId) {
             this.isShowcustomLookups = true;
         }
         */
        this.loanApplicationRecord['Customer_Type__c'] = this.customerTypeOptionsValue;
        this.getProductType();
        this.getDealerClass();


    }

    getDealerClass() {
        getDealerClassMetadata()
            .then((result) => {
                if (result != null) {
                    this.dealerClassMetadataList = result;
                }
            })
            .catch((error) => {
                this.error = error;
            });
    }

    getProductType() {
        getProductTypeMetadata()
            .then((result) => {
                if (result != null) {
                    this.productTypeMetadataList = result;
                }
            })
            .catch((error) => {
                this.error = error;
            });
    }



    getLoanApplication() {
        getLoanApplicationRecord({
            recId: this.recordId
        })
            .then((object) => {
                if (object != null) {
                    this.loanApplicationRecord = object;
                    this.loanAmount = this.loanApplicationRecord.Loan_Amount__c;
                    //  this.loanAmountInWords = this.loanApplicationRecord.Loan_Amount_In_Words__c;
                    this.purchasingCityVal = this.loanApplicationRecord.Purchase_City__c;
                    this.sourceNameId = this.loanApplicationRecord.Sourcing_Channel_Name__c;
                    this.mobileNumber = this.loanApplicationRecord.Mobile__c;
                    this._collateralType = this.loanApplicationRecord.Collateral_Type__c ?? '';
                    this.vehicleUseOptionsValue = this.loanApplicationRecord.Original_Vehicle_Usage__c;
                    this.isVerified = this.loanApplicationRecord.Is_Verified_Number__c;
                    if (this.isVerified) {
                        this.isVerifiedNumber = true;
                    }
                    const productPicklistLabel = this.mapOfProductValueVsLabel.get(this.loanApplicationRecord.Product__c);
                    // R2-21
                    const [ product, loanType ] = getLoanType( productPicklistLabel );
                    const subProductPicklistLabel = loanType;
                    this.productOptionValue = product;
                    this.productSubCategory = this.productCategoryToSubCatMap.get(this.productOptionValue)?.map( item => ({ label: item, value: item }));
                    this.subProductOptionValue = subProductPicklistLabel;
                    this.sourcingChannelOptionsValue = this.loanApplicationRecord.Sourcing_channel__c;
                    this.dealerSourceCode = this.loanApplicationRecord.Sourcing_Channel_Name__r?.Account_Code__c;
                    // SFAU-5163
                    // this.getVehicleUse(true,this.loanApplicationRecord.Original_Vehicle_Usage__c);
                    // this.vehicleUseOptionsValue = this.loanApplicationRecord.Vehicle_use__c ?? (VEHICLE_USAGE_BY_TYPE[this.loanApplicationRecord.RecordType.Name]);
                    this.customerTypeOptionsValue = this.loanApplicationRecord.Customer_Type__c;
                    if(this.loanApplicationRecord.Customer_Type__c){
                        this.isCustomerReadOnly = true;
                    }
                    this.productValue = this.loanApplicationRecord.Product__c;
                    this.getProductTypeValue(this.productValue);
                    this.getDealerClassValue(this.sourcingChannelOptionsValue);
                    this.stageOptionsValue = this.loanApplicationRecord.Stage__c;
                    if (this.stageOptionsValue === 'QDE') {
                        if (this.loanApplicationRecord.Is_Converted_From_Lead__c == false) {
                            this.isReadOnly = true;
                        }
                        if (!this.isVerified && this.mobileNumber && (this.mobileNumber.length == 10 || this.mobileNumber.length == 11 || this.mobileNumber.length == 12)) {
                            this.boolSendOtp = true;
                            this.boolCheckMobileNumber = false;
                        }
                        // SFAU-5608
                        /* Commenting for SFAU-5911
                        if (this.loanApplicationRecord.Lead_Id__c != '' && this.loanApplicationRecord.Lead_Id__c != undefined){
                            this.isSourceChannelNameReadOnly = true;
                        }
                        */
                    }
                    else if(this.stageOptionsValue != 'QDE') {
                        this.isSourceChannelNameReadOnly = true; //added by Gaurav for sourcing channel should not allow to change on DDE(Bug:SFAU-2833) 
                        this.isLoanTypeReadOnly = true;
                        this.isReadOnly = true;
                    }
                    else{
                        this.isLoanTypeReadOnly = true;
                        this.isReadOnly = true;
                    }
                    this.isDisableVehicleUse = true;
                    if (this.productOptionValue.trim() == 'Auto Loan' && (this.stageOptionsValue == 'QDE' || this.stageOptionsValue == 'DDE')) {
                        this.isDisableVehicleUse = false;
                    }
                    else if (this.productOptionValue.trim() == 'Two Wheeler' && (this.stageOptionsValue == 'QDE')) {
                        this.isDisableVehicleUse = false;
                    }

                    if (this.purchasingCityVal && this.sourceNameId) {
                        this.isShowcustomLookups = true;
                        this.isShowSourceNameLookup = true;
                        setTimeout(() => {
                            this.prePopulateLookupFld();
                            this.prePopulateLookupFld1();

                        }, 200);
                    }
                }
            })
            .catch((error) => {
                this.error = error;
            });
    }

    fetchBranchName() {
        fetchMasterRecord({
            recordTypeName: 'Branch'
        })
            .then((result) => {
                if (result != null) {
                    this.branchId = result.Id;
                    this.branchLocation = result.Account_Name__c;
                    this.loanApplicationRecord.Branch_Master__c = this.branchId;
                    if (this.branchLocation != null) {
                        this.loanApplicationRecord.Branch__c = this.branchLocation;
                    }
                }

            })
            .catch((error) => {
                this.error = error;
            });
    }

    getProductTypeValue(productVal) {
        this.productTypeMetadataList.forEach(Element => {
            if (Element.Product__c == productVal) {
                this.productValueType = Element.Product_Type__c;
                // this.productValueType = Element.Product_Type__c === 'Commercial' ? `(\'CV\', \'Car Taxi\', \'4W\')` : `(\'${Element.Product_Type__c}\')`;
            }
        });

    }

    getDealerClassValue(sourcingChannelVal) {
        this.dealerClassMetadataList.forEach(Element => {
            if (Element.SF_Value__c == sourcingChannelVal) {
                this.dealerClassValue = Element.Dealer_Class__c;
            }
        });
        this.dealerClasses = this.dealerClassValue.split(',').map( item => item.slice(1, -1));
    }

    /*
    async handleSourcingchannelChange(event) {
        const value = event.detail.value ?? event.target.value;
        this.isValueUpdated = true;
        this.recordSelected = {};
        this.sourceNameId = null;
        this.loanApplicationRecord.Purchase_City__c = null;
        this.loanApplicationRecord.Source_Name__c = null;
        delete this.loanApplicationRecord.Sourcing_Channel_Name__r;
        this.resetDependentLookups();
        await Promise.resolve();
        if (this.isShowcustomLookups) {
            this.template.querySelector("c-generic-custom-lookup").callHandleRemove();
        }
        this.sourcingChannelOptionsValue = value;
        this.getDealerClassValue(this.sourcingChannelOptionsValue);
        this.loanApplicationRecord['Sourcing_channel__c'] = value;
        this.isInputValid('Sourcing_channel__c');
        if (this.productValue && this.vehicleUseOptionsValue && this.isShowCustomLookupOnSourceChannel(this.sourcingChannelOptionsValue)) {
            this.isShowcustomLookups = true;
        }
        else {
            this.isShowcustomLookups = false;
        }



    }*/

    handleSourcingchannelCustomChange(selectedVal, selectedField, event) {
        this.isValueUpdated = true;
        if (this.isShowcustomLookups && event) {
            this.template.querySelector("c-generic-custom-lookup").callHandleRemove();
        }
        this.sourcingChannelOptionsValue = event != '' ? event.detail.value : selectedVal;
        this.getDealerClassValue(this.sourcingChannelOptionsValue);
        if (event != '') {
            this.loanApplicationRecord[event.target.name] = event.target.value;
            this.isInputValid(event.target.name);
        }
        else {
            this.loanApplicationRecord[selectedField] = selectedVal;
            this.isInputValid(selectedField);
        }
        if (this.productValue && this.vehicleUseOptionsValue && this.isShowCustomLookupOnSourceChannel(this.sourcingChannelOptionsValue)) {
            this.isShowcustomLookups = true;
        }
        else {
            this.isShowcustomLookups = false;
        }
    }

    handleSourcingchannelChange(event) {
        /*
        this.isValueUpdated = true;
        if (this.isShowcustomLookups) {
            this.template.querySelector("c-generic-custom-lookup").callHandleRemove();
        }
        this.sourcingChannelOptionsValue = event.detail.value;
        this.getDealerClassValue(this.sourcingChannelOptionsValue);
        this.loanApplicationRecord[event.target.name] = event.target.value;
        this.isInputValid(event.target.name);
        if (this.productValue && this.vehicleUseOptionsValue && this.isShowCustomLookupOnSourceChannel(this.sourcingChannelOptionsValue)) {
            this.isShowcustomLookups = true;
        }
        else {
            this.isShowcustomLookups = false;
        }
        */
        this.handleSourcingchannelCustomChange ('','',event);
    }

    isShowCustomLookupOnSourceChannel(sourceChannelVal) {
        let isShowCustomLookupReturn = false;
        if (sourceChannelVal) {
            if (!SourcingChannelDependecyLabel.includes(this.sourcingChannelOptionsValue)) {
                isShowCustomLookupReturn = true;
            }
        }
        return isShowCustomLookupReturn;

    }

    handleValueChange(event) {
        this.isValueUpdated = true;

        if( this.isCollateralTypeApplicable && event.target.name == 'Collateral_Type__c' && this.loanApplicationRecord[event.target.name] !== event.target.value ){
            this._collateralType = event.target.value;
        }

        this.loanApplicationRecord[event.target.name] = event.target.value;
        this.isInputValid(event.target.name);
         //  R2-598
        if(this.isCollateralTypeApplicable){
            if(event.target.name == 'Collateral_Type__c' && event.target.value == '10133' && this.subProductOptionValue == 'New'){
                this.vehicleUseOptionsValue = 'Agri';
                this.isDisableVehicleUse = true;
                this.loanApplicationRecord['Original_Vehicle_Usage__c'] = 'Agri';
            }else{
                 this.isDisableVehicleUse = false;
            }
        }
    }

    handleAmountChange(event) {
        this.isValueUpdated = true;
        //   this.loanAmountInWords = this.getTextFromNumber(event.target.value);
        //   this.loanApplicationRecord['Loan_Amount_In_Words__c'] = this.loanAmountInWords;
        this.loanApplicationRecord[event.target.name] = event.target.value;
        this.isInputValid(event.target.name);
    }


    async handleProductChange(event) {
        this.isValueUpdated = true;
        this.vehicleUseOptionsValue = '';
        this.vehicleUsePicklistValues = [];
        if (this.isShowcustomLookups) {
            this.template.querySelector("c-generic-custom-lookup").callHandleRemove();
        }
        this.productOptionValue = event.detail.value;
        this.productSubCategory = this.productCategoryToSubCatMap.get(this.productOptionValue)?.map( item => ({ label: item, value: item }));
        if (event.detail.value == 'Two Wheeler ') {
            //this.isSourcingChannelReadOnly = true;
            //this.isLoanTypeReadOnly = true;
            this.sourcingChannelOptionsValue = 'Dealer New Vehicle';
            this.subProductOptionValue = 'New';
            this.loanApplicationRecord['Sourcing_channel__c'] = this.sourcingChannelOptionsValue;
            this.getDealerClassValue(this.sourcingChannelOptionsValue);
            // this.fetchSourceId();
            //SFAU-5163
            // this.getVehicleUse (false,'');
            this.vehicleUseOptionsValue = '';
            this.loanApplicationRecord['Vehicle_use__c'] = ''; //:SFAU-3648 - Manual selection for 2W
        }
        else {
            //this.isSourcingChannelReadOnly = false;
            this.isLoanTypeReadOnly = false;
            this.sourceNameId = '';
            this.sourcingChannelOptionsValue = '';
            this.subProductOptionValue = '';
            this.loanApplicationRecord['Sourcing_channel__c'] = this.sourcingChannelOptionsValue;
            this.getDealerClassValue(this.sourcingChannelOptionsValue);
            //SFAU-5163
            // this.getVehicleUse (false,'');
            this.vehicleUseOptionsValue = 'Personal';
            this.loanApplicationRecord['Vehicle_use__c'] = 'Personal'; //:SFAU-3648 - Auto populate Personal for 4W

        }
        this.loanApplicationRecord['Product__c'] = this.mapOfProductPicklist.get(this.productOptionValue + '(' + this.subProductOptionValue + ')');
        this.productValue = this.loanApplicationRecord['Product__c'];
        this.getProductTypeValue(this.productValue);
        this.isInputValid(event.target.name);
        if (this.productValue && this.vehicleUseOptionsValue && this.isShowCustomLookupOnSourceChannel(this.sourcingChannelOptionsValue)) {
            this.isShowcustomLookups = true;
        }
        else {
            this.isShowcustomLookups = false;
        }
        this.setDefaultValue( this.productSubCategory, SUB_PRODUCT_VALUE_PROPERTY );
    }

    handlePurchasingCityChange() {
        this.sourceNameId = '';
        this.isValueUpdated = true;
        if (this.purchasingCityVal) {
            this.fetchSourceId();
            setTimeout(() => {
                this.isShowSourceNameLookup = true;
            }, 200);


        }
        else {
            this.isShowSourceNameLookup = false;
        }

    }

    handleSubProductChange(event) {
        this.isValueUpdated = true;
        if (this.isShowcustomLookups) {
            this.template.querySelector("c-generic-custom-lookup").callHandleRemove();
        }
        this.subProductOptionValue = event.detail.value;
        this.loanApplicationRecord['Product__c'] = this.mapOfProductPicklist.get(this.productOptionValue + '(' + this.subProductOptionValue + ')');
        this.productValue = this.loanApplicationRecord['Product__c'];
        this.getProductTypeValue(this.productValue);
        this.isInputValid(event.target.name);
        /* START - SFAU-5163 */
        // this.getVehicleUse (false,'');
        /* END - SFAU-5163 */
        if (this.productValue && this.vehicleUseOptionsValue && this.isShowCustomLookupOnSourceChannel(this.sourcingChannelOptionsValue)) {
            this.isShowcustomLookups = true;
        }
        else {
            this.isShowcustomLookups = false;
        }
        
    }

    handleVehicleUseChange(event) {
        this.isValueUpdated = true;
        if (this.isShowcustomLookups) {
            // this.template.querySelector("c-generic-custom-lookup").callHandleRemove();
            this.resetDependentLookups();
        }
        this.vehicleUseOptionsValue = event.detail.value;
        // SFAU-5163
        this.loanApplicationRecord['Original_Vehicle_Usage__c'] = event.target.value;
        //this.loanApplicationRecord[event.target.name] = event.target.value;
        this.loanApplicationRecord[event.target.name] = 'Personal';
        this.isInputValid(event.target.name);
        if (this.productValue && this.vehicleUseOptionsValue && this.isShowCustomLookupOnSourceChannel(this.sourcingChannelOptionsValue)) {
            this.isShowcustomLookups = true;
        }
        else {
            this.isShowcustomLookups = false;
        }
    }
    handleCustomerTypeChange(event) {
        this.isValueUpdated = true;
        this.customerTypeOptionsValue = event.detail.value;
        this.loanApplicationRecord[event.target.name] = event.target.value;
        if (event.detail.value === 'Individual') {
            this.indvidualCustomer = true;
        } else {
            this.indvidualCustomer = false;
        }
        this.isInputValid(event.target.name);
    }
    handleCategoryTypeChange(event) {
        this.isValueUpdated = true;
        this.categoryValue = event.detail.value;
        this.loanApplicationRecord[event.target.name] = event.target.value;
        this.isInputValid(event.target.name);
    }
    handleResetAll() {
        this.template.querySelectorAll('lightning-input').forEach(Element => {
            Element.value = null;
        });

        this.template.querySelectorAll('lightning-combobox').forEach(Element => {
            Element.value = null;
        });


    }

    isInputValid(inputFieldName) {
        let isValid = true;
        let inputFields = this.template.querySelectorAll(".validate");
        inputFields.forEach(inputField => {

            if (inputFieldName == '') {
                if (!inputField.value) {
                    inputField.setCustomValidity("Complete this field");

                    inputField.reportValidity();
                    isValid = false;

                }
                else {
                    inputField.setCustomValidity("");
                    inputField.reportValidity();

                }
            }
            else {
                if (inputFieldName == inputField.name) {
                    if (!inputField.value) {
                        inputField.setCustomValidity("Complete this field");
                        inputField.reportValidity();
                        isValid = false;

                    }
                    else {
                        inputField.setCustomValidity("");
                        inputField.reportValidity();

                    }

                }

            }
        });
        return isValid;
    }




    handleSendOTP() {
        this.boolRequestOtp = true;
        this.boolSendOtp = false;
        this.isEnterOtp = true;
        this.set27SecondTimer();

        this.mobileOtpVerificationHandler('Mobile Generate OTP');

    }

    mobileOtpVerificationHandler(masterRecordName) {

        mobileOtpVerificationHandler({ mobileNumber: this.mobileNumber, otp: this.enterOTPValue, loanApplicationId: '', otpValue: masterRecordName })
            .then(result => {
                if (result != null) {            
                    if (masterRecordName == 'Mobile Validate OTP') {
                        let responseVal = JSON.parse(result);
                        let response = JSON.parse(responseVal.response);
                        if(responseVal.statusCode != 200){
                            let checklist = responseVal.checklistRecord;
                            this.isVerified = false;
                                this.isEnterOtp = true;
                                this.boolRequestOtp = false;
                                this.boolSendOtp = false;
                                this.isVerifiedNumber = false;
                                this.boolVerify = true;
                                this.showToastEvent('Error', 'API Error: ' + checklist.Name + ' Response: ' + responseVal.statusCode + '- ' + responseVal.status , 'error');
                        }else if (response.RequestStatus == 'Failed') {
                                this.isVerified = false;
                                this.isEnterOtp = true;
                                this.boolRequestOtp = false;
                                this.boolSendOtp = false;
                                this.isVerifiedNumber = false;
                                this.boolVerify = true;
                                this.showToastEvent('Error', response.StatusCode + '- ' + response.StatusDesc , 'error');
                            }
                            else if (response.RequestStatus == 'Success') {
                                this.isVerified = true;
                                this.boolResendOtp = false;
                                this.isloading = true;
                                this.isEnterOtp = false;
                                this.isVerifiedNumber = true;
                                this.reportOtpVerficationValidity("");
    
                            } 

                    }else if (masterRecordName == 'Mobile Generate OTP') {
                        let responseVal = JSON.parse(result);
                        let response = JSON.parse(responseVal.response);
                        if(responseVal.statusCode != 200){
                            let checklist = responseVal.checklistRecord;
                            this.boolRequestOtp = false;
                            this.boolSendOtp = true;
                            this.isEnterOtp = false;
                            this.showToastEvent('Error', 'API Error: ' + checklist.Name + ' Response: ' + responseVal.statusCode + '- ' + responseVal.status , 'error');
                        }else if (response.RequestStatus == 'Failed') {
                                this.showToastEvent('Error', response.StatusCode + '- ' + response.StatusDesc , 'error');
                        }
                        else if (response.RequestStatus == 'Success') {
                            
                        } 

                    }
                }

                this.isloading = false;
                this.error = undefined;
            })
            .catch(error => {
                this.error = error;
            })
    }

    handleResendOTP() {
        this.isEnterOtp = true;
        this.boolRequestOtp = true;
        this.boolResendOtp = false;
        this.set27SecondTimer();
        this.mobileOtpVerificationHandler('Mobile Resend OTP');
    }

    handleVerify() {
        this.isloading = true;
        this.isEnterOtp = false;
        this.boolRequestOtp = false;
        this.boolResendOtp = false;
        this.boolSendOtp = false;
        this.oldMobileNumberValue = this.mobileNumber;
        this.mobileOtpVerificationHandler('Mobile Validate OTP');
    }

    handleChangeOtp(event) {
        let isOTPValid = this.isCheckValidity();
        if (event.detail.value.length == 4 && isOTPValid) {
            this.enterOTPValue = event.detail.value;
            this.boolVerify = false;
        }
        else {
            this.boolVerify = true;
        }
    }

    handleChangePhoneNumber(event) {
        let fldValue = event.target.value;
        this.isValueUpdated = true;
        this.isInTimeInterval = false;
        let lenOfMobNo = event.target.value.length;
        let inputField = this.template.querySelector(".mobilebutton");
        if (this.oldMobileNumberValue === event.target.value && this.isVerifiedNumber) {
            this.isVerified = true;
            this.isEnterOtp = false;
            this.boolRequestOtp = false;
            this.boolResendOtp = false;
            this.boolSendOtp = false;
        } else {
            if (event.target.name == 'Mobile__c' && lenOfMobNo == 10 || lenOfMobNo == 11 || lenOfMobNo == 12) {
                this.loanApplicationRecord[event.target.name] = event.target.value;
                this.mobileNumber = event.target.value;
                this.boolCheckMobileNumber = false;
                this.checkBlockedList(fldValue)
                this.checkValidationForIndianMobNo(fldValue);
            } else {
                this.boolCheckMobileNumber = true;
                this.isEnterOtp = false;
                this.boolRequestOtp = false;
                this.boolResendOtp = false;
                this.isVerified = false;
            }
        }
        this.boolVerify = true;
    }
    checkBlockedList(fldValue){
        validateMobile({ mobileNo: fldValue})
        .then(result => {
            if(result){
                this.boolSendOtp = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'This mobile no is blocked',
                        variant: 'error',
                    }),
                );
            }
            else 
            this.boolSendOtp=true;
        })
        .catch(error =>{
            this.error = error; 
        })

    }
    checkValidationForIndianMobNo(fldValue) {

        let getMobNoFLd = this.template.querySelector("lightning-input[data-id='mobileinput']")
        let phoneRegex = /^(\+91[\-\s]?)?[0]?(91)?[6-9]\d{9}$/;

        if (!phoneRegex.test(fldValue)) {
            getMobNoFLd.setCustomValidity('Enter Valid Mobile Number');
        }
        else {
            getMobNoFLd.setCustomValidity('');
        }
        getMobNoFLd.reportValidity();
    }

    set27SecondTimer() {
        this.isInTimeInterval = true;
        this.increse1Second = OtpDurationLabel;
        const secondTimeInterval = setInterval(() => {
            this.increse1Second -= 1;
        }, 1000);
        setTimeout(() => {
            if (!this.isVerified && this.isInTimeInterval) {
                this.boolRequestOtp = false;
                this.boolResendOtp = true;
            }
            window.clearInterval(secondTimeInterval);

        }, OtpDurationLabel * 1000);
    }



    validatePhoneNumber(input_str) {
        var re = /^[6-9]{1}[0-9]{9}/;
        console.log('Valid Phone Number', re.test(input_str));
        return re.test(input_str);
    }


    handleLookupSelect(event) {
        let selectedValue = event.detail.value;
        let selectedName = event.detail.name;
        let selectedCityName = event.detail.purchasingCityName;
        let fieldName = event.detail.fieldapi;
        let objectName = event.detail.objApiName;
        if (fieldName !== null && selectedName !== null) {

            if( fieldName === 'Source_Name__c'){
                this.loanApplicationRecord['Sourcing_Channel_Name__c'] = selectedValue;
            }
            if (fieldName == 'Purchase_City__c') {
                this.purchasingCityVal = selectedCityName;
                this.loanApplicationRecord[fieldName] = selectedCityName;
                this.handlePurchasingCityChange(event);
            }
            else {
                const { sourceCode } = event.detail;
                this.loanApplicationRecord[fieldName] = selectedName;
                if(/*this.isSourceCodeVisible &&*/ sourceCode !== this.refs.dealerSourceCode.value){
                    this.dealerSourceCode = sourceCode;
                }
                if( !selectedCityName /*&& this.isSourceCodeVisible*/ ){
                    this.template.querySelector('c-generic-custom-lookup')?.callHandleRemove();
                }
                // R2-1738 - Populating sourcing channel name should auto populate City of Source
                if( this.purchasingCityVal !== selectedCityName ){
                    this.purchasingCityVal = selectedCityName;
                    this.loanApplicationRecord.Purchase_City__c = selectedCityName;
                    this.prePopulateLookupFld();
                }
            }
        }
    }

    getSObject(wiredData) {
        return {
            sobjectType: wiredData.apiName,
            Id: wiredData.id,
            ...Object.keys(wiredData.fields).reduce((a, f) => {
                a[f] = wiredData.fields[f].value;
                return a;
            }, {})
        };
    }

    getTextFromNumber(inputValue) {
        let single_digits = ["Zero", "One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine"];
        let two_digits = ["Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen"];
        let tens_multiple = ["", "", "Twenty", "Thirty", "Forty", "Fifty", "Sixty", "Seventy", "Eighty", "Ninety"];
        let textValue = '';
        let inputArray = [];
        if (inputValue < 10) {
            textValue = single_digits[inputValue];
        } else {
            inputArray = [];
            while (inputValue > 0) {
                inputArray.push(inputValue % 10);
                inputValue = Math.floor(inputValue / 10);
            }
            if (inputArray.length > 1) {
                if (inputArray[0]) {
                    textValue = single_digits[inputArray[0]];
                }
                if (inputArray[1]) {
                    if (inputArray[1] == 1) {
                        textValue = two_digits[inputArray[0]];
                    } else {
                        textValue = tens_multiple[inputArray[1]] + ' ' + textValue;
                    }
                }
                if (inputArray[2]) {
                    if (inputArray[2] != 0) {
                        textValue = single_digits[inputArray[2]] + ' Hundred ' + textValue;
                    }
                }
                if (inputArray[3]) {
                    if (inputArray[4]) {
                        if (inputArray[4] != 1) {
                            if (inputArray[3] != 0) {
                                textValue = single_digits[inputArray[3]] + ' Thousand ' + textValue;
                            }
                        }
                    } else {
                        if (inputArray[3] != 0) {
                            textValue = single_digits[inputArray[3]] + ' Thousand ' + textValue;
                        }
                    }
                }
                if (inputArray[4]) {
                    if (inputArray[4] == 1) {
                        textValue = two_digits[inputArray[3]] + ' Thousand ' + textValue;
                    } else {
                        if (inputArray[3] == 0) {
                            textValue = tens_multiple[inputArray[4]] + ' Thousand ' + textValue;
                        } else {
                            textValue = tens_multiple[inputArray[4]] + ' ' + textValue;
                        }
                    }
                }
                if (inputArray[5]) {
                    if (inputArray[6]) {
                        if (inputArray[6] != 1) {
                            if (inputArray[5] != 0) {
                                textValue = single_digits[inputArray[5]] + ' Lakh ' + textValue;
                            }
                        }
                    } else {
                        if (inputArray[5] != 0) {
                            textValue = single_digits[inputArray[5]] + ' Lakh ' + textValue;
                        }
                    }
                }
                if (inputArray[6]) {
                    if (inputArray[6] == 1) {
                        textValue = two_digits[inputArray[5]] + ' Lakh ' + textValue;
                    } else {
                        if (inputArray[5] == 0) {
                            textValue = tens_multiple[inputArray[6]] + ' Lakh ' + textValue;
                        } else {
                            textValue = tens_multiple[inputArray[6]] + ' ' + textValue;
                        }
                    }
                }
                if (inputArray[7]) {
                    if (inputArray[8]) {
                        if (inputArray[8] != 1) {
                            if (inputArray[7] != 0) {
                                textValue = single_digits[inputArray[7]] + ' Crore ' + textValue;
                            }
                        }
                    } else {
                        if (inputArray[7] != 0) {
                            textValue = single_digits[inputArray[7]] + ' Crore ' + textValue;
                        }
                    }
                }
                if (inputArray[8]) {
                    if (inputArray[8] == 1) {
                        textValue = two_digits[inputArray[7]] + ' Crore ' + textValue;
                    } else {
                        if (inputArray[7] == 0) {
                            textValue = tens_multiple[inputArray[8]] + ' Crore ' + textValue;
                        } else {
                            textValue = tens_multiple[inputArray[8]] + ' ' + textValue;
                        }
                    }
                }
                if (inputArray[9]) {
                    if (inputArray[9] != 0) {
                        textValue = single_digits[inputArray[9]] + ' Hundred and ' + textValue;
                    }
                }
            }
        }
        if (textValue) {
            textValue = 'INR ' + textValue;
        }

        return textValue;

    }

    checkTractorFunding(){
        let isValid = true;
        if(this.subProductOptionValue.trim() != 'New' && this.productOptionValue.trim() == 'Tractor'
            && this.loanApplicationRecord.Collateral_Type__c == this.implementCollateralCode){
            isValid = false;
        }
        return isValid;
    }

    createLoanApplication() {
        if (this.isInputValid('') && this.isVerified && this.isCheckValidity() && this.isValidateGenericLookup()) {
            this.isloading = true;
            //this.loanApplicationRecord['Stage__c'] = 'QDE';
            if (this.isVerified) {
                this.loanApplicationRecord['Is_Verified_Number__c'] = true;
            }
            const loanApplication = { ...this.loanApplicationRecord };
            delete loanApplication.Sourcing_Channel_Name__r;

            createLoanApplication({ loanApplication, applicantId: this.applicantId, customerType: this.customerTypeOptionsValue })
                .then(result => {
                    this.isloading = false;
                    this.loanApplicationRecord['Id'] = result.la.Id;
                    if (result.app != undefined) {
                        this.applicantId = result.app.Id;
                    }

                    const Obj = {};
                    this.errorOnChild = this.isInputValid('') ? false : true;
                    Obj.loanApplicationRecord = result.la;
                    if (result.app != undefined) {
                        Obj.applicantRecord = result.app;
                    }
                    else {
                        //in Edit mode
                        Obj.applicantRecord = this.currentApplicantRecord;
                    }
                    Obj.errorOnChild = this.errorOnChild;
                    Obj.next = (!this.errorOnChild && this.isVerified) ? true : false;

                    this.dispatchEvent(new CustomEvent('next', {
                        detail: Obj
                    }));

                    if (this.isValueUpdated) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Loan Application created',
                                variant: 'success',
                            }),
                        );

                    }



                })
                .catch(error => {
                    this.isloading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error upserting record',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });



        } else {
            if (!this.checkTractorFunding()) {
                this.isloading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Used stand alone implement cannot be funded',
                        variant: 'error'
                    }),
                );
            }
            if (!this.isVerified) {
                this.reportOtpVerficationValidity("Please generate and verify OTP");
            }

        }
    }



    reportOtpVerficationValidity(message) {
        let inputField = this.template.querySelector(".mobilebutton");
        inputField.setCustomValidity(message);
        inputField.reportValidity();
    }

    fetchSourceId() {
        fetchMasterRecord({
            recordTypeName: 'Dealer',
            sourcingChannel: this.sourcingChannelOptionsValue,
            product: this.productValue,
            vehicleUse: this.vehicleUseOptionsValue,
            purchasingCity: this.purchasingCityVal

        })
            .then((result) => {
                if (result != null) {
                    this.sourceNameId = result.Id;
                    this.prePopulateLookupFld2(result.Name);
                }


            })
            .catch((error) => {
                this.error = error;
            });
    }

    isValidateGenericLookup() {
        let isValid = true;
        let checkStateOfValid = [];
        this.setSelectedRecord();
        const objChild = this.template.querySelectorAll('c-generic-custom-lookup');
        for (let val of objChild) {
            let storeVal = val.validateChildFlds(val, this.recordSelected);
            checkStateOfValid.push(storeVal);
        }
        let staeOfValid = checkStateOfValid.includes("false");
        if (staeOfValid) {
            isValid = false;
        }
        return isValid;
    }


    isCheckValidity() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.checkValidity');
        for (let inputField of inputFields) {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            } else {
                inputField.setCustomValidity("");
                inputField.reportValidity();
            }
        };
        return isValid;
    }

    setSelectedRecord() {
        this.recordSelected.Purchase_City__c = this.loanApplicationRecord.Purchase_City__c;

    }

    prePopulateLookupFld() {
        this.setSelectedRecord();
        const objChild = this.template.querySelector("[data-id='Purchase_City__c']");
        objChild.reflectSelectedRecordValues(this.recordSelected);
    }

    setSelectedRecord1() {
        this.recordSelected.Name = this.loanApplicationRecord.Sourcing_Channel_Name__r.Name;
    }

    prePopulateLookupFld1() {
        this.setSelectedRecord1();
        const objChild = this.template.querySelector("[data-id='Source_Name__c']");
        objChild.reflectSelectedRecordValues(this.recordSelected);
    }


    prePopulateLookupFld2(sourceName) {
        const objChild = this.template.querySelector("[data-id='Source_Name__c']");
        this.recordSelected.Name = sourceName;
        objChild.reflectSelectedRecordValues(this.recordSelected);
    }

    showToastEvent(titleValue, messageValue, variantValue){
        const event = new ShowToastEvent({
            title: titleValue, 
            message: messageValue,
            variant: variantValue,
            mode: 'sticky'
        });
        this.dispatchEvent(event);
    }
    setDefaultFieldValue( picklistOptions, fieldApi ){
        if(picklistOptions?.length === 1){
            const [{ value }] = picklistOptions;
            this.loanApplicationRecord = { ...this.loanApplicationRecord, [ fieldApi ]: value };
            if( fieldApi === 'Original_Vehicle_Usage__c' ){
                this.vehicleUseOptionsValue = value;
            }
        }
    }


    /* START - SFAU-5163 */
    getVehicleUse (blnonloadrecord, varValue) {
        var varProducttype = this.productOptionValue;
        var varLoanType = this.subProductOptionValue;
        this.vehicleUseOptionsValue = '';
        this.vehicleUsePicklistValues = [];
        getVehicleUsageList({
            strProduct: varProducttype, strLoantype: varLoanType, loanAppId: this.recordId
        })
        .then((object) => {
            if (object != null && object.blnSuccess == true) {
                object.lstVehicleUsage.forEach(element => {
                    this.vehicleUsePicklistValues.push({label:element,value:element});
                });
                let vehicleUse = this.template.querySelector("[data-name='Vehicle_use__c']");
                if(vehicleUse){
                    vehicleUse.options = this.vehicleUsePicklistValues;
                }
                if (blnonloadrecord != undefined && blnonloadrecord == true && varValue != undefined && varValue != '' && varValue != 'undefined') {
                    this.vehicleUseOptionsValue = varValue;
                }
            }
        })
        .catch((error) => {
            this.error = error;
        });
    }
    /* END - SFAU-5163 */

    // R2-30 - Dealer Source Code 
    sourceCodeDebounceTimer;
    handleSourceCodeChange(event){
        const { value: sourceCode } = event.target;
        if( !sourceCode ){
            this.recordSelected = {};
            this.populateDependentLookupFields( );
            return;
        } else {
            this.isShowcustomLookups = this.productValue && this.vehicleUseOptionsValue && this.isShowCustomLookupOnSourceChannel(this.sourcingChannelOptionsValue);
        }

        clearTimeout( this.sourceCodeDebounceTimer );
        
        const dealerClasses = this.dealerClasses, productType = this.productValueType, vehicleUsage = this.vehicleUseOptionsValue;
        this.sourceCodeDebounceTimer = setTimeout(async () => {
            console.log(' === get dealer details by source code ===');
            
            const response = await getDealerDetailsBySourceCode({ sourceCode, dealerClasses, productType, vehicleUsage })
                .catch(err => {
                    const errorMessage = reduceErrors( err );
                    this.showToastMessage( this, null, 'error', errorMessage?.[0] ?? 'An error has occured while fetching Dealer details.', 'sticky' );
                });

            console.log({response});
            if( !response ){
                this.recordSelected = {};
            }

            this.populateDependentLookupFields( response || {}, !!response );
            console.log( 'Selected record ==> ', JSON.parse(JSON.stringify( this.recordSelected )));
        }, DEBOUNCE_TIMER );
    }

    async populateDependentLookupFields( response, hideFieldFirst ){
        this.purchasingCityVal = response.Purchase_City__c;
        console.log('Purchase cit ==', this.purchasingCityVal);
        if( hideFieldFirst ){
            this.handlePurchasingCityChange();
        }
        this.sourceNameId = response.Id;

        await delay(200);
        this.recordSelected = { ...this.recordSelected, ...response };
        this.loanApplicationRecord.Sourcing_Channel_Name__r = response;
        this.loanApplicationRecord.Purchase_City__c = this.purchasingCityVal;
        this.loanApplicationRecord.Source_Name__c = response.Account_Name__c;

        await Promise.resolve(); // let track changes reflect DOM
        this.prePopulateLookupFld();
        
        if( this.purchasingCityVal ){
            await Promise.resolve(); // let track changes reflect DOM
            this.prePopulateLookupFld1();
        }

        if( !hideFieldFirst ){
            this.template.querySelector("c-generic-custom-lookup")?.callHandleRemove();
            this.handlePurchasingCityChange();
        }
    }

    setDefaultValue( options, property ){
        if( options?.length === 1 ){
            const [ option ] = options;
            this[property] = option.value;
            if( property === PRODUCT_VALUE_PROPERTY ){
                this.handleProductChange({ detail: { name: option.label, value: option.value }, target: { name: option.label, value: option.value } } );
            } else if( property === SUB_PRODUCT_VALUE_PROPERTY ){
                this.handleSubProductChange({ detail: { name: option.label, value: option.value }, target: { name: option.label, value: option.value } } );
            }
        }
    }
    resetDependentLookups(){
        [...this.template.querySelectorAll('c-generic-custom-lookup')].forEach(item => item.callHandleRemove?.());
    }
}