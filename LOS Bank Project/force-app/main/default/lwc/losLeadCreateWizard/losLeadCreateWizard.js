import { LightningElement, api, track, wire } from 'lwc';
import getProductTypeMetadata from '@salesforce/apex/LosQuickLoanController.getRecordTypeNames';
import getDealerClassMetadata from '@salesforce/apex/LosQuickLoanController.getDealerClassNames';
import getLoanApplicationRecord from '@salesforce/apex/LosQuickLoanController.getLoanApplication';
import { getObjectInfo, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import fetchMasterRecord from '@salesforce/apex/LosLeadCreateWizardController.fetchBranchMasterRecord';
import createLeadRecord from '@salesforce/apex/LosLeadCreateWizardController.createLeadRecord';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LOANAPPLICATION_OBJECT from '@salesforce/schema/Loan_Application__c';
import SourcingChannelDependecyLabel from '@salesforce/label/c.AUSFSourcingChannelDependency';
import getCampaigns from '@salesforce/apex/LosLeadCreateWizardController.getCampaigns'
import getVehicleUsageOptions from '@salesforce/apex/LosLeadCreateWizardController.getVehicleUsageOptions';
import getCollateralTypeOptions from '@salesforce/apex/LosLeadCreateWizardController.getCollateralTypeOptions';
//import firsttemplate from './losLeadCreateWizard.html';
import dealerSourcingChannels from '@salesforce/label/c.DealerSourcingChannels';// R2-27
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import userId from "@salesforce/user/Id";
import EMPLOYEE_ID_FIELD from '@salesforce/schema/User.Employee_Id__c';
import { getLoanType, TRACTOR_PRODUCT_CODES, CV_PRODUCT_CODES, CONSTRUCTION_EQUIPMENT_PRODUCT_CODES, showToastMessage, DEBOUNCE_TIMER } from 'c/lwcutilities';
import getDealerDetailsBySourceCode from '@salesforce/apex/LosQuickLoanController.getDealerDetailsBySourceCode';

const PRODUCT_TYPE_TRACTOR = 'tractor';
const PRODUCT_TYPE_CV = 'commercial';
const COLLATERAL_TYPE_FIELD = 'Collateral_Type__c';
const SOURCE_CODE_IDENTIFIER = 'SourceCode';
const PRODUCT_VALUE_PROPERTY = 'productOptionValue';
const SUB_PRODUCT_VALUE_PROPERTY = 'subProductOptionValue';

const DEALER_SOURCING_CHANNELS = dealerSourcingChannels.split(';');

const FIELD_VISIBILITY_BY_PRODUCT = {
    [ COLLATERAL_TYPE_FIELD ]: [ ...CONSTRUCTION_EQUIPMENT_PRODUCT_CODES ],
    [ SOURCE_CODE_IDENTIFIER ]: [ ...TRACTOR_PRODUCT_CODES, ...CV_PRODUCT_CODES, ...CONSTRUCTION_EQUIPMENT_PRODUCT_CODES ],
};

const LG_CODE_VISIBILITY_BY_SOURCING = [ 'EBRP', 'Self-Sourcing' ];
const LG_CODE_DISABLED_PRODCUT_VALUES = [ 'Other ' ]; //:TODO - This has to be replaced once updated master is given

export default class LosLeadCreateWizard extends NavigationMixin(LightningElement) {
    @api recordId;
    @track mobileNumber = '';
    sourcingChannelOptionsValue = '';
    productOptionsValue = '';
    customerTypeOptionsValue = 'Individual';
    vehicleUseOptionsValue = '';

    @track sourcingChannelPicklistValues;
    @track vehicleUsePicklistValues;
    @track productPicklistValues;
    @track customerTypePicklistValues;
    isRequired = false;
    sourceName = '';
    loanApplicationRecord = {};
    isloading = false;
    branchId;
    branchLocation = '';
    LoanApplicationId = '';
    loanAmount;
  //  loanAmountInWords = '';
    sourceNameId;
    productCategory = [];
    productSubCategory = [];
    mapOfProductPicklist = new Map();
    mapOfProductValueVsLabel = new Map();
    productOptionValue = '';
    subProductOptionValue = '';
    purchasingCityVal = '';
    isShowcustomLookups = false;
    isShowSourceNameLookup = false;
    isSourcingChannelReadOnly = false;
    isLoanTypeReadOnly = false;
    productValueType = '';
    dealerClassValue = '';
    productTypeMetadataList = [];
    dealerClassMetadataList = [];
    today;
    currentTime;
    selectedCampaign='';
    @track campaignOptions=[];
    campaignOptionsMap = new Map()
    campaignNameVsId = new Map()
    productCategoryToSubCatMap = new Map();
    productDetails=new Map();
    @track displayCampaign=false;
    followUpTime;
    @track recordSelected = {};
    @track customerInterestedValues = [{label:'',value:''}];
    @track button_headLabel = 'Create Lead'
    @track isEditCase = false;
    leadStatusOptions = [];
    leadPriorityOptions = [];
    collateralTypes = [];
    userId = userId;
    dealerClasses = [];
    dealerSourceCode = '';
    _collateralType;

    get isTractor(){
        return this.productOptionValue?.toLowerCase().includes( PRODUCT_TYPE_TRACTOR );
    }

    get letterOfXCodeLabel(){
        return 'LG Code';//`${this.isTractor ? 'LG' : 'LC'} Code`;
    }

    // R2-27
    get isCampaignSelectionDisabled(){
        return DEALER_SOURCING_CHANNELS.includes( this.sourcingChannelOptionsValue );
    }

    get productCode(){
        return this.mapOfProductPicklist.get( `${this.productOptionValue}(${this.subProductOptionValue})`);
    }

    get isLGCodeAvailable(){
        return LG_CODE_VISIBILITY_BY_SOURCING.includes( this.sourcingChannelOptionsValue );
    }
    
    get isLGCodeDisabled(){
        return LG_CODE_DISABLED_PRODCUT_VALUES.includes( this.productOptionValue );
    }

    get isCollateralTypeApplicable(){
        return !FIELD_VISIBILITY_BY_PRODUCT[COLLATERAL_TYPE_FIELD]?.includes( this.productCode ) && this.productOptionValue?.trim() !== 'Other';
    }

    // For Other Products - Vehicle Usage is not applicable
    get isVehicleUsageApplicable(){
        return this.productOptionValue?.trim() !== 'Other';
    }

    get isSourceCodeVisible(){
        return true;//FIELD_VISIBILITY_BY_PRODUCT[SOURCE_CODE_IDENTIFIER]?.includes( this.productCode );
    }

    // R2-1738 - Populating sourcing channel name should auto populate City of Source
    get _isShowSourceNameLookup(){
        return this.isShowSourceNameLookup;
    }

    async connectedCallback() {
        console.log('in connected');
        this.fetchBranchName();
        this.getProductType();
        this.getDealerClass();
        this.today = new Date().toISOString().slice(0,10);
        this.setCurrentTime();
        this.loanApplicationRecord['Customer_Type__c'] = this.customerTypeOptionsValue;
        this.loanApplicationRecord.Lead_Status__c = 'In Progress'; //Feedback - default lead status to be In Progress
        const data = await getCampaigns();
        if(data){
            this.productDetails = new Map(Object.entries(data.productDetails));
            data.campaigns.forEach(input=>{
                this.campaignNameVsId.set(input.Campaign_Name__c,input.Campaign_ID__c)
                let key = input.Linked_with__c+'_'+input.Applicable_Products_for_Campaign__c;
                if(this.campaignOptionsMap.has(key)){
                    this.campaignOptionsMap.get(key).push({label:input.Campaign_Name__c, value:input.Campaign_Name__c});
                }else{
                    this.campaignOptionsMap.set(key, new Array);
                    this.campaignOptionsMap.get(key).push({label:input.Campaign_Name__c, value:input.Campaign_Name__c})
                }
                
            })
        }
    }
    /*
    render() {
        console.log('in render');
        return firsttemplate;
    }
    */

     setCurrentTime() {	
        const now = new Date();	
        let hours = now.getHours();	
        let minutes = now.getMinutes();	
        let seconds = now.getSeconds();	
        // Formatting the time to a two-digit format if needed	
        hours = ('0' + hours).slice(-2);	
        minutes = ('0' + minutes).slice(-2);	
        seconds = ('0' + seconds).slice(-2);	
        this.currentTime = `${hours}:${minutes}:${seconds}`;	
        	
    }

    getDealerClass(){
        getDealerClassMetadata()
            .then((result) => {
                if (result != null) {
                    console.log('dealer class result', JSON.stringify(result));
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
                    console.log('product type result', JSON.stringify(result));
                    this.productTypeMetadataList = result;
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
                console.log('this.productValueType',this.productValueType);
            }
        });

    }

     getDealerClassValue(sourcingChannelVal) {
        this.dealerClassMetadataList.forEach(Element => {
            if (Element.SF_Value__c == sourcingChannelVal) {
                this.dealerClassValue = Element.Dealer_Class__c;
                console.log('this.dealerClassValue',this.dealerClassValue);
            }
        });
        this.dealerClasses = this.dealerClassValue.split(',').map( item => item.slice(1, -1));

    }
    

    
    fetchBranchName() {
       fetchMasterRecord({
            recordTypeName : 'Branch'
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



    @wire(getObjectInfo, { objectApiName: LOANAPPLICATION_OBJECT })
    objectInfo;

    @wire(getPicklistValuesByRecordType, { objectApiName: LOANAPPLICATION_OBJECT, recordTypeId: '$objectInfo.data.defaultRecordTypeId' })
    allDataPicklistValues({ error, data }) {
        if (data) {
            const productPicklistMap = new Map();
            const productPicklistValueVsLabelMap = new Map();
            const productCategorytMap = new Map();
            const productSubCategorytMap = new Map();

            const productPicklist = data.picklistFieldValues.Product__c.values;

            productPicklist.forEach(element => {
                productPicklistMap.set(element.label, element.value);
                productPicklistValueVsLabelMap.set(element.value, element.label);
                const [ product, loanType ] = getLoanType( element.label );
                console.log([product, loanType]);
                // productCategorytMap.set(element.label.split('(')[0], element.value);
                // productSubCategorytMap.set(element.label.split('(')[1], element.value);
                productCategorytMap.set(product, element.value);
                productSubCategorytMap.set(loanType, element.value);
                
                // R2-21
                // const [ category, subCategory ] = element.label.split('(');
                console.log(element.label.split('('), ' Has Entry ==', this.productCategoryToSubCatMap.has( product ));
                if(!this.productCategoryToSubCatMap.has( product )){
                    this.productCategoryToSubCatMap.set( product, [ ] );
                }
                //this.productCategoryToSubCatMap.get( product ).push( loanType );
                //duplicate values were getting populated in Loan Type picklist
                if(this.productCategoryToSubCatMap.get( product )){
                    if(this.productCategoryToSubCatMap.get( product ).lenght>0 && !this.productCategoryToSubCatMap.get( product ).contains(loanType)){
                        this.productCategoryToSubCatMap.get( product ).push( loanType );
                    }else{
                        this.productCategoryToSubCatMap.get( product ).push( loanType );
                    }
                }
            });
            this.productCategory = Array.from(productCategorytMap.keys()).map(element => {
                return {
                    label: element,
                    value: element

                }
            });
            this.productSubCategory = [];
            /*Array.from(productSubCategorytMap.keys()).map(element => {
                return {
                    label: element.slice(0, element.length - 1),
                    value: element.slice(0, element.length - 1)

                }
            });*/
            this.mapOfProductPicklist = productPicklistMap;
            this.mapOfProductValueVsLabel = productPicklistValueVsLabelMap;
            this.sourcingChannelPicklistValues = data.picklistFieldValues.Sourcing_channel__c.values;
            // this.vehicleUsePicklistValues = data.picklistFieldValues.Vehicle_use__c.values;
            this.productPicklistValues = data.picklistFieldValues.Product__c.values;
            this.customerTypePicklistValues = data.picklistFieldValues.Customer_Type__c.values;
            this.loanApplicationRecord['Customer_Interested__c'] = true;
            //this.setCustomerInterestDropDown(data.picklistFieldValues.Customer_Interested__c.values);
            this.leadStatusOptions = data.picklistFieldValues.Lead_Status__c.values; //R2-15
            this.leadPriorityOptions = data.picklistFieldValues.Lead_Priority__c.values; //R2-29
            this._collateralType = ''; //triggers wire

            if (this.recordId) {
                this.getLoanApplication();
                this.button_headLabel = 'Update Lead';
                this.isEditCase = true;
            }
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
            this.setDefaultFieldValue( usageOptions, 'Vehicle_use__c' );
        }
    }

    // R2-25 - 
    @wire( getRecord, { recordId: '$userId', fields: [ EMPLOYEE_ID_FIELD ] } )
    userInfo;


    /**SFAU-5568 Changes */
    setCustomerInterestDropDown(dropDownMap){
        let val = [{label:'None',value:''}];
        dropDownMap.forEach(element=>{
            val.push({
                label : element.value,
                value : element.value
            })
        })
        this.customerInterestedValues = [];
        this.customerInterestedValues = JSON.parse(JSON.stringify(val));
        this.loanApplicationRecord['Customer_Interested__c'] = true;

    }

    handleToggleChange(evt){
        this.loanApplicationRecord[evt.currentTarget.dataset.id] = evt.detail.checked;
    }

    /**************** */


     getLoanApplication() {
        getLoanApplicationRecord({
            recId: this.recordId
        })
            .then((object) => {
                if (object != null) {
                    console.log('object', object);
                    this.button_headLabel = 'Update Lead';
                    this.loanApplicationRecord = object;
                    this.loanAmount = this.loanApplicationRecord.Loan_Amount__c;
                    //  this.loanAmountInWords = this.loanApplicationRecord.Loan_Amount_In_Words__c;
                    this.purchasingCityVal = this.loanApplicationRecord.Purchase_City__c;
                    this.sourceNameId = this.loanApplicationRecord.Sourcing_Channel_Name__c;
                    this.mobileNumber = this.loanApplicationRecord.Mobile__c;
                    //this.isVerified = this.loanApplicationRecord.Is_Verified_Number__c;
                    console.log('this.mapOfProductValueVsLabel', this.mapOfProductValueVsLabel);
                    console.log('this.loanApplicationRecord.Product__c', this.loanApplicationRecord.Product__c);
                    const productPicklistLabel = this.mapOfProductValueVsLabel.get(this.loanApplicationRecord.Product__c);
                    const subProductPicklistLabel = productPicklistLabel.split('(')[1]
                    this.productOptionValue = productPicklistLabel.split('(')[0];
                    const [ _product, loanType ] = getLoanType( productPicklistLabel );
                    this.subProductOptionValue = subProductPicklistLabel.slice(0, subProductPicklistLabel.length - 1);
                    this.sourcingChannelOptionsValue = this.loanApplicationRecord.Sourcing_channel__c;
                    this._collateralType = this.loanApplicationRecord.Collateral_Type__c ?? '';
                    this.vehicleUseOptionsValue = this.loanApplicationRecord.Original_Vehicle_Usage__c;
                    this.customerTypeOptionsValue = this.loanApplicationRecord.Customer_Type__c;
                    this.productValue = this.loanApplicationRecord.Product__c;
                    this.getProductTypeValue(this.productValue);
                    this.getDealerClassValue(this.sourcingChannelOptionsValue);
                    if(this.loanApplicationRecord.Follow_Up_Time__c){
                    this.followUpTime = this.msToTime(this.loanApplicationRecord.Follow_Up_Time__c);
                    }
                    //this.stageOptionsValue = this.loanApplicationRecord.Stage__c;
                    /*
                    if (this.stageOptionsValue === 'QDE') {
                        this.isReadOnly = true;
                        if(this.mobileNumber && (this.mobileNumber.length  == 10 || this.mobileNumber.length == 11 || this.mobileNumber.length == 12)){
                        this.boolSendOtp = true;
                        this.boolCheckMobileNumber = false;
                        }
                        else{
                        this.boolSendOtp = false;
                        }
                    }
                    */

                    this.setDefaultValue( [ { label: _product, value: _product } ], PRODUCT_VALUE_PROPERTY );
                    this.setDefaultValue( [ { label: loanType, value: loanType } ], SUB_PRODUCT_VALUE_PROPERTY );

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


    async handleSourcingchannelChange(event) {
        const value = event.target.value ?? event.detail.value;
        if (this.isShowcustomLookups) {
            // this.template.querySelector("c-generic-custom-lookup").callHandleRemove();
            this.recordSelected = {};
            this.sourceNameId = null;
            this.loanApplicationRecord.Purchase_City__c = null;
            this.loanApplicationRecord.Source_Name__c = null;
            delete this.loanApplicationRecord.Sourcing_Channel_Name__r;
            this.resetDependentLookups();
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
        this.setCampaignOptions()
        await Promise.resolve();
        this.populateLetterOfGuaranteeCode();
    }

    setCampaignOptions(){
        if(this.productValue && this.productDetails.get('A_'+this.productValue).RecordType__c){
            var newList=[];
            var commonForAll;
            if(this.sourcingChannelOptionsValue.includes('TCU')){
                newList = this.campaignOptionsMap.get('TCU_'+this.productDetails.get('A_'+this.productValue).RecordType__c)
                commonForAll='TCU_All' 
            }
            if(this.sourcingChannelOptionsValue.includes('Marketing')){
                newList = this.campaignOptionsMap.get('Marketing Activity_'+this.productDetails.get('A_'+this.productValue).RecordType__c)
                commonForAll='Marketing Activity_All'
            } 
            if(newList){
                newList.concat(this.campaignOptionsMap.get(commonForAll))
            }else{
                newList = this.campaignOptionsMap.get(commonForAll)
            }
            this.campaignOptions = newList
            this.displayCampaign = (this.campaignOptions && this.campaignOptions.length>0)?true:false
            this.loanApplicationRecord.Campaign__c = ''
            this.loanApplicationRecord.Campaign_ID__c = '';
        }
        
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

    handleValuChange(event) {
        if( event.target.name == 'Collateral_Type__c' && this.loanApplicationRecord[event.target.name] !== event.target.value ){
            this._collateralType = event.target.value;
        }

        this.loanApplicationRecord[event.target.name] = event.target.value;
        if(event.target.name == 'Campaign__c'){
            this.loanApplicationRecord.Campaign_ID__c = this.campaignNameVsId.get(event.target.value)
        }
        if (event.target.name == 'Follow_Up_Date__c') {	
            const today = new Date().toISOString().slice(0, 10);	
            if (event.target.value == today || event.target.value < today) {	
                this.setCurrentTime();	
            }	
            else {	
                this.currentTime = 0;	
            }	
        }
        this.isInputValid(event.target.name);
    }


    // Convert milliseconds into 'h:mm a' time format
    msToTime(s){
        let ms = s % 1000;
        s = (s - ms) / 1000;
        let secs = s % 60;
        s = (s - secs) / 60;
        let mins = s % 60;
        let hrs = (s - mins) / 60;
        hrs = hrs < 10 ? '0' + hrs : hrs;
        mins = mins < 10 ? '0' + mins : mins;
        console.log(hrs + '  ' + mins);
        return hrs+':' + mins + ':00.000Z';
    }


    handleAmountChange(event) {
       // this.loanAmountInWords = this.getTextFromNumber(event.target.value);
       // this.loanApplicationRecord['Loan_Amount_In_Words__c'] = this.loanAmountInWords;
        this.loanApplicationRecord[event.target.name] = event.target.value;
        this.isInputValid(event.target.name);
    }

    handlePurchasingCityChange() {
        if (this.purchasingCityVal) {
            this.isShowSourceNameLookup = true;
        }
        else {
            this.isShowSourceNameLookup = false;
        }

    }

    handleLookupSelect(event) {
        let selectedValue = event.detail.value;
        let selectedName = event.detail.name;
        let selectedCityName = event.detail.purchasingCityName;
        let fieldName = event.detail.fieldapi;
        let objectName = event.detail.objApiName;
        if (fieldName !== null && selectedName !== null) {

            this.loanApplicationRecord['Sourcing_Channel_Name__c'] = selectedValue;
            if (fieldName == 'Purchase_City__c') {
                this.purchasingCityVal = selectedCityName;
                this.loanApplicationRecord[fieldName] = selectedCityName;
                this.handlePurchasingCityChange(event);
            }
            else {
                this.loanApplicationRecord[fieldName] = selectedName;

                const { sourceCode } = event.detail;
                if( this.isSourceCodeVisible && sourceCode !== this.refs.dealerSourceCode.value){
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
        console.log('selectedValue', selectedValue);
        console.log('selectedName', selectedName);
        console.log('fieldName', fieldName);
        console.log('objectName', objectName);
        console.log('selectedCityName', selectedCityName);
        console.log('this.loanApplicationRecord', this.loanApplicationRecord);



    
    }



    handleProductChange(event) {
        if (this.isShowcustomLookups) {
            this.template.querySelector("c-generic-custom-lookup").callHandleRemove();
        }
        this.productOptionValue = event.detail.value;
        // R2-21 | Home Loan / Credit Card options to only appear when Other is selected
        this.productSubCategory = this.productCategoryToSubCatMap.get(this.productOptionValue)?.map( item => ({ label: item, value: item }));
        if (event.detail.value == 'Two Wheeler ') {
            //this.isSourcingChannelReadOnly = true;
            //this.isLoanTypeReadOnly = true;
            this.sourcingChannelOptionsValue = 'Dealer New Vehicle';
            this.subProductOptionValue = 'New';
            this.loanApplicationRecord['Sourcing_channel__c'] = this.sourcingChannelOptionsValue;
            this.getDealerClassValue(this.sourcingChannelOptionsValue);
            this.fetchSourceId();
            this.vehicleUseOptionsValue = 'Personal';
            this.loanApplicationRecord['Vehicle_use__c'] = 'Personal';
        }
        else {
            //this.isSourcingChannelReadOnly = false;
            this.isLoanTypeReadOnly = false;
            this.sourceNameId ='';
            this.sourcingChannelOptionsValue = '';
            this.subProductOptionValue = '';
            this.loanApplicationRecord['Sourcing_channel__c'] = this.sourcingChannelOptionsValue;
            this.getDealerClassValue(this.sourcingChannelOptionsValue);
            this.vehicleUseOptionsValue = '';
            this.loanApplicationRecord['Vehicle_use__c'] = '';

        }
        this.loanApplicationRecord['Product__c'] = this.mapOfProductPicklist.get(this.productOptionValue + '(' + this.subProductOptionValue + ')');
        this.productValue = this.loanApplicationRecord['Product__c'];
        this.getProductTypeValue(this.productValue);
        if (this.productValue && this.vehicleUseOptionsValue && this.isShowCustomLookupOnSourceChannel(this.sourcingChannelOptionsValue)) {
            this.isShowcustomLookups = true;
        }
        else {
            this.isShowcustomLookups = false;
        }
        this.populateLetterOfGuaranteeCode();
        this.setCampaignOptions()
        this.isInputValid(event.target.name);
        this.setDefaultValue( this.productSubCategory, SUB_PRODUCT_VALUE_PROPERTY );
    }

    handleSubProductChange(event) {
        if (this.isShowcustomLookups) {
            this.template.querySelector("c-generic-custom-lookup").callHandleRemove();
        }
        this.subProductOptionValue = event.detail.value;
        this.loanApplicationRecord['Product__c'] = this.mapOfProductPicklist.get(this.productOptionValue + '(' + this.subProductOptionValue + ')');
        this.productValue = this.loanApplicationRecord['Product__c'];
        this.getProductTypeValue(this.productValue);
        if (this.productValue && this.vehicleUseOptionsValue && this.isShowCustomLookupOnSourceChannel(this.sourcingChannelOptionsValue)) {
            this.isShowcustomLookups = true;
        }
        else {
            this.isShowcustomLookups = false;
        }
        this.isInputValid(event.target.name);
    }


    handleCustomerTypeChange(event) {
        this.customerTypeOptionsValue = event.detail.value;
        this.loanApplicationRecord[event.target.name] = event.target.value;
        this.isInputValid(event.target.name);
        
    }

    handleVehicleUseChange(event) {
        if (this.isShowcustomLookups) {
            this.recordSelected = {};
            this.sourceNameId = null;
            this.loanApplicationRecord.Purchase_City__c = null;
            this.loanApplicationRecord.Source_Name__c = null;
            delete this.loanApplicationRecord.Sourcing_Channel_Name__r;

            // this.template.querySelector("c-generic-custom-lookup").callHandleRemove();
            this.resetDependentLookups();
        }
        this.vehicleUseOptionsValue = event.detail.value;
        this.loanApplicationRecord[event.target.name] = event.target.value;
        if (this.productValue && this.vehicleUseOptionsValue && this.isShowCustomLookupOnSourceChannel(this.sourcingChannelOptionsValue)) {
            this.isShowcustomLookups = true;
        }
        else {
            this.isShowcustomLookups = false;
        }
        this.isInputValid(event.target.name);

    }

    handleResetAll() {
        this.template.querySelectorAll('lightning-input').forEach(Element => {
            if (Element.name != 'Branch__c') {
                Element.value = null;
            }
        });

        this.template.querySelectorAll('lightning-combobox').forEach(Element => {
            // R2-1696
            if( Element.name === 'Customer_Type__c' ){
                Element.value = 'Individual';
            } else{
                Element.value = null;
            }
        });
        // R2-1696
        this.resetForm();
    }

    isInputValid(inputFieldName) {
        let isValid = true;
        let inputFields = this.template.querySelectorAll(".validate");
        inputFields.forEach(inputField => {

            if (inputFieldName == '') {
                if (!inputField.value) {
                    console.log('input fiel name ' + inputField.name)
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
                        console.log('input fiel name ' + inputField.name);
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


    createLead() {

        if (this.isInputValid('') && this.isCheckValidity()) {
            console.log('LC Code value',!this.loanApplicationRecord['LC_Code__c']);
            console.log('Sourcing Channel',this.loanApplicationRecord['Sourcing_channel__c']);
            if (this.loanApplicationRecord['Sourcing_channel__c'] == 'EBRP' && (!this.loanApplicationRecord['LC_Code__c'] || this.validateViaRegex(/^[0-9]{6}$/, +this.loanApplicationRecord['LC_Code__c']))){
                console.log('In LC Code Mandatory Warning.');
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Warning',
                        message: `Please ${this.loanApplicationRecord['LC_Code__c'] ? 'correct' : 'enter'} the ${this.letterOfXCodeLabel}.`,
                        variant: 'Warning',
                    }),
                );
            }
            else {
                this.isloading = true;
                console.log('this.loanApplicationRecord', this.loanApplicationRecord);
    
                const loanApplication = { ...this.loanApplicationRecord };
                delete loanApplication.Sourcing_Channel_Name__r;

                createLeadRecord({ loanApplication: this.loanApplicationRecord })
                    .then(result => {
                        console.log('result ' + JSON.stringify(result));
                        this.handleResetAll();
                        //this.template.querySelector("c-generic-custom-lookup").callHandleRemove();
                        this.isloading = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Lead created',
                                variant: 'success',
                            }),
                        );
                        if(!this.isEditCase){
                            this.navigateToRecordPage(result);
                        }
                        else{
                            window.location.reload();
                        }

                        

                    })
                    .catch(error => {
                        console.log('error',error.body.message);
                        this.isloading = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error creating record',
                                message: error.body.message,
                                variant: 'error',
                            }),
                        );
                    });



            }

        }

    }

    navigateToRecordPage(objectRecordid) {
        console.log('recordid', objectRecordid);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: objectRecordid,
                //objectApiName: 'Loan_application__c',
                actionName: 'view'
            },
        });
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

      fetchSourceId() {
        fetchMasterRecord({
            recordTypeName : 'Dealer'
        })
            .then((result) => {
                console.log('Fetch Source Name Result',result.Id);
                    if (result != null) {
                        this.sourceNameId = result.Id;
                    }

            })
            .catch((error) => {
                this.error = error;
            });
    }

    isCheckValidity() {
        console.log('in isCheckValid method');
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.checkValidity');
        console.log('fields: ', inputFields);
        for (let inputField of inputFields) {
            if (!inputField.checkValidity()) {
                console.log('input fiel name ' + inputField.name)
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
        console.log('In selected Record');
        this.recordSelected.Purchase_City__c = this.loanApplicationRecord.Purchase_City__c;

    }

    prePopulateLookupFld() {
        this.setSelectedRecord();
        const objChild = this.template.querySelector(`[data-id='Purchase_City__c']`);

        console.log('this.recordSelected', JSON.stringify(this.recordSelected));
        objChild.reflectSelectedRecordValues(this.recordSelected);
    }

    	
    setSelectedRecord1() {	
        console.log('In selected Record');	
        this.recordSelected.Name = this.loanApplicationRecord.Sourcing_Channel_Name__r.Name;	
    }

    prePopulateLookupFld1() {
        this.setSelectedRecord1();
        const objChild = this.template.querySelector(`[data-id='Source_Name__c']`);

        console.log('this.recordSelected', JSON.stringify(this.recordSelected));
        objChild.reflectSelectedRecordValues(this.recordSelected);
    }


    prePopulateLookupFld2(sourceName) {
        const objChild = this.template.querySelector(`[data-id='Source_Name__c']`);
        this.recordSelected.Name = sourceName;
        console.log('this.recordSelected', JSON.stringify(this.recordSelected));
        objChild.reflectSelectedRecordValues(this.recordSelected);
    }

    validateViaRegex( regex, fieldValue ){
        return !regex.test(fieldValue);
    }

    setDefaultFieldValue( picklistOptions, fieldApi ){
        if(picklistOptions?.length === 1){
            const [{ value }] = picklistOptions;
            this.loanApplicationRecord = { ...this.loanApplicationRecord, [ fieldApi ]: value };
            if( fieldApi === 'Vehicle_use__c' ){
                this.vehicleUseOptionsValue = value;
            }
        }
    }
    
    populateLetterOfGuaranteeCode(){
        if( this.isLGCodeDisabled && this.isLGCodeAvailable ){
            const roEmployeId = getFieldValue( this.userInfo?.data, EMPLOYEE_ID_FIELD );
            this.loanApplicationRecord = { ...this.loanApplicationRecord, LC_Code__c: roEmployeId };
        } else {
            this.loanApplicationRecord = { ...this.loanApplicationRecord, LC_Code__c: null };
        }
    }

    // R2-1696
    resetForm(){
        this.sourcingChannelOptionsValue = '';
        this.productOptionsValue = '';
        this.customerTypeOptionsValue = 'Individual';
        this.vehicleUseOptionsValue = '';
        this.recordSelected = {};
        this.displayCampaign = false;
        this.selectedCampaign = '';
        this.sourceNameId = '';
        this.loanApplicationRecord = {};
    }

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
        console.log({ sourceCode, dealerClasses, productType, vehicleUsage });
        this.sourceCodeDebounceTimer = setTimeout(async () => {
            console.log(' === get dealer details by source code ===');
            
            const response = await getDealerDetailsBySourceCode({ sourceCode, dealerClasses, productType, vehicleUsage })
                .catch(err => {
                    const errorMessage = reduceErrors( err );
                    showToastMessage( this, null, 'error', errorMessage?.[0] ?? 'An error has occured while fetching Dealer details.', 'sticky' );
                });
            console.log({response});
            if( !response ){
                this.recordSelected = {};
            }
            this.populateDependentLookupFields( response || {}, !!response );
        }, DEBOUNCE_TIMER );
    }

    async populateDependentLookupFields( response, hideFieldFirst ){
        this.purchasingCityVal = response.Purchase_City__c;
        console.log('Purchase cit ==', this.purchasingCityVal);
        if( hideFieldFirst ){
            this.handlePurchasingCityChange();
        }
        this.sourceNameId = response.Id;

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