import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import profileName from '@salesforce/label/c.Profile_Name';
import SOURCING_CHANNEL_FIELD from '@salesforce/schema/Loan_Application__c.Sourcing_channel__c';
import DEALER_CHANNEL_FIELD from '@salesforce/schema/Loan_Application__c.Dealer_Channel__c';
import dealerDetailHandler from '@salesforce/apex/DealerDetailController.dealerDetailHandler';
import genericFetchForDealer from '@salesforce/apex/DealerDetailController.genericFetchForDealer';
import saveDealerAndUpdatLoanAppl from '@salesforce/apex/DealerDetailController.saveDealerAndUpdatLoanAppl';
import getProductTypeMetadata from '@salesforce/apex/LosQuickLoanController.getRecordTypeNames';
import getDealerClassMetadata from '@salesforce/apex/LosQuickLoanController.getDealerClassNames';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import getMaterialFields from '@salesforce/apex/Utility.getMaterialFields';
import checkMaterialFields from '@salesforce/apex/Utility.checkMaterialFields';
import checkBodyFundingRequired from '@salesforce/apex/DealerDetailController.checkBodyFundingRequired';
import dealerSave from '@salesforce/apex/DealerDetailController.dealerSave';
import getBankName from '@salesforce/apex/LoanDetailsController.getBankName';
import CATEGORY_FIELD from '@salesforce/schema/Account.Category__c';
import COW_SUB_PRODUCT_NAMES from '@salesforce/label/c.AUSFCowScreen'
import COW_SUB_PRODUCT_NAMES_R2 from '@salesforce/label/c.AUSFCowScreenR2'

export default class DealerDetail extends LightningElement {

    activeSections = ['DealerDetailSection', 'SourcingAndPayoutSection', 'Trigger/Limits'];
    isLoading;
    @api spinnerImage;
    @api recordId;
    dealerRequired = false;
    error;
    errorOnChild = '';
    mfgValue = "";
    productValue = "";
    productValueType = "";
    @track purchaseState = "";
    purchaseCity = "";
    dealerName = "";
    productName = "";
    dealerClass = "";
    dealerOptionsShow = false;
    dealerOptions = [];
    dealerChannelVal = '';
    dealerClassValue = '';
    dealerClassVal = '';
    dealerClassMetadataList = [];

    @track data;
    @track loanAppRec = {};
    @track recordSelected = {};
    @track mfgOptions = [];
    @track dealerDetail = {};
    @track dseNamePanOptions = [];
    @track dsmNamePanOptions = [];
    @track sourceChannelOptions = [];
    @track paymentObj = { 'sobjectType': 'Payment__c' };
    @track loanApplUpdate = { 'sobjectType': 'Loan_Application__c' };

    isDisablePurchStateFld = false;
    isDisablePurchCityFld = true;
    isDisableDealNameFld = true;
    isDisableOutlNameFld = true;
    isDisableInputFld = false;
    isInputRequied = false;
    isPurchaseCity = false;
    isDealerName = false;
    isOutletName = false;
    isDseNamePan = false;
    isDsmNamePan = false;
    isSourcingAndPayoutSection = false;
    isSourceChannelPayout = false;
    isDealerPayout = false;
    isTwoWheeler = false;
    isFourWheeler = false;
    isOtherSourceAmt = false;
    isOtherDealerAmt = false;
    istriigerSection = true;
    isRCLimit = false;
    @track sourcePayAmountOnUI = '';
    @track isUsedOrNow = false;
    showLookups = false;
    isNew = false;
    outletId;
    isShowOutletLookup = false;
    showDelaerNameLookup = false;
     //R2 Attributes
    isBodyType = false;
    showDealerDisabled = true;
    bodyFundingDealerClass='';
    cowSubProducts = COW_SUB_PRODUCT_NAMES+','+COW_SUB_PRODUCT_NAMES_R2

    get outletRequired(){ //SFAU-3459, SFAU-4876 [Kunal]
        return this.isTwoWheeler == false &&  this.productName && this.productName.includes('New') ? true : false;
    }

    payoutTypeOptions = [{ label: 'Full', value: 'Full' }, { label: 'Half', value: 'Half' }, { label: 'Other amount-%', value: 'Other amount-%' }];
    commonOptions = [{ label: 'Yes', value: 'Yes' }, { label: 'No', value: 'No' }];

    @wire(getRecord, {
        recordId: "$recordId",
        fields: "RecordTypeId"
    })
    record;

    @wire(getPicklistValues, { recordTypeId: '$record.data.recordTypeId', fieldApiName: SOURCING_CHANNEL_FIELD })
    sourceChannelpicklIstOptions({ error, data }) {
        if (data) {
            console.log('data of getPicklistValues--' + JSON.stringify(data));
            let sourceChOpt = data.values.map(opt => ({ 'label': opt.label, 'value': opt.value }));
            this.sourceChannelOptions = sourceChOpt;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            console.log("error inside sourceChannelpicklIstOptions" + error);
        }
    }


    @wire(getPicklistValues, { recordTypeId: '$record.data.recordTypeId', fieldApiName: DEALER_CHANNEL_FIELD })
    dealerChannelOptions({ error, data }) {
        if (data) {
            console.log('data of getPicklistValues--' + JSON.stringify(data));
            let dealerOpt = data.values.map(opt => ({ 'label': opt.label, 'value': opt.value }));
            this.dealerOptions = dealerOpt;
            console.log('dealerOptions', this.dealerOptions);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            console.log("error inside sourceChannelpicklIstOptions" + error);
        }
    }
      // R2-1816 || START
    get categoryOptions(){
      return [
                { label: 'A', value: 'A' },
                { label: 'AA', value: 'AA' },
                { label: 'B', value: 'B' },
                { label: 'NA', value: 'NA' },
                { label: 'C', value: 'C' },
                { label: 'D', value: 'D' },
                { label: 'E', value: 'E' },
                { label: 'F', value: 'F' },
                { label: 'NR', value: 'NR' },
            ];
    }

    get dealerTypeOptions(){
        return [
            { label: 'GL', value: 'GL' },
            { label: 'TA', value: 'TA' },
            { label: 'Non TA', value: 'Non TA' }
        ];
    }
    //END

    handleDecimalPlaces(evt) {
        let regex = /^(?:\d*\.\d{1,2}|\d+)$/;
        let checkField = this.template.querySelector('lightning-input[data-name="' + evt.currentTarget.dataset.name + '"]');
        if (!regex.test(checkField.value)) {
            checkField.setCustomValidity("Please provide a valid increment");
            this.isErrorResponse = true;
        }
        else {
            checkField.setCustomValidity("");
            this.isErrorResponse = false;
        }

        checkField.reportValidity();
        console.log('test ' + regex.test(checkField.value))


    }

    connectedCallback() {
        this.isInputRequied = true;
        this.getProductType();
        this.getDealerClass();
        this.fetchDetails();
        this.setIsEditRestricted()
    }

    async setIsEditRestricted(){
        this.isEditRestricted = await restricAccess({compName: 'dealerDetail' ,loanId: this.recordId})
    }

    getDealerClass() {
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

    getDealerClassValue() {
        this.dealerClassMetadataList.forEach(Element => {
            console.log('this.dealerChannelVal', this.dealerChannelVal);
            if (Element.SF_Value__c == this.dealerChannelVal) {
                let dealerClass = Element.Dealer_Class__c;
                this.dealerClassValue = dealerClass;
                console.log('dealerClassValue-->' + dealerClass)
                this.dealerClassVal = dealerClass.replaceAll("'", "");
                this.bodyFundingDealerClass = this.dealerClassVal;
                console.log('this.dealerClassValue', this.dealerClassValue);
            }
        });

    }

    getProductTypeValue(productVal) {
        this.productTypeMetadataList.forEach(Element => {
            if (Element.Product__c == productVal) {
                this.productValueType = Element.Product_Type__c;
                console.log('this.productValueType', this.productValueType);
            }
        });
        return this.productValueType//R2-865
    }

    get disableDealerAmount(){
        return this.isDisableInputFld || this.paymentObj['Dealer_Payout_Type__c'] == 'Full' || this.paymentObj['Dealer_Payout_Type__c'] == 'Half' || this.paymentObj['dealerPayoutType'] == 'Full' || this.paymentObj['dealerPayoutType'] == 'Half';
    }

    get disableSourceAmount(){
        return this.isDisableInputFld || this.paymentObj['Source_Channel_Payout_Type__c'] == 'Full' || this.paymentObj['Source_Channel_Payout_Type__c'] == 'Half' || this.paymentObj['sourceChannelPayoutType'] == 'Full' || this.paymentObj['sourceChannelPayoutType'] == 'Half';
    }





    purchaseOptions = [];
    fetchDetails() {
        this.isLoading = true;
        dealerDetailHandler({ loanApplId: this.recordId })
            .then((result) => {
                console.log("result-- " + JSON.stringify(result));
                this.data = result;
                let sourcingChannel = result.loanApp.Sourcing_channel__c;
                if (result.loanApp) {
                    this.loanAppRec = result.loanApp;
                    
                     //R2-1816 || START
                    this.isBodyType = this.loanAppRec.Collateral_Type__c == '10113' ? true : false; //R2-1816 || Added Collateral Type Check
                    this.outletId = this.loanAppRec.Outlet_Name__c;
                    //R2-1816 || END
                    this.dealerChannelVal = result.loanApp.Dealer_Channel__c;
                    this.purchaseOptions = result.purchaseStateOptions;

                    this.purchaseState = result.loanApp.Purchase_State__c != null ? result.loanApp.Purchase_State__c : '';
                    if (this.dealerChannelVal) {
                        this.getDealerClassValue();
                    }
                    this.productName = result.loanApp.prod;
                    this.getProductTypeValue(result.loanApp.Product__c);
                    this.mfgValue = result.dealerValues.mfg;
                    console.log('productName', this.productName);
                    if (this.productName.includes('New')) {
                        this.dealerRequired = true;
                        this.dealerOptionsShow = true;
                        this.dealerOptions = [
                            { label: 'Dealer New Vehicle', value: 'Dealer New Vehicle' }
                        ];

                    }
                    else if (this.productName.includes('Used')) {
                        this.dealerOptionsShow = true;
                        this.dealerRequired =  (this.loanAppRec.Sourcing_channel__c == "Used Car Dealer With Rc Limit" || this.loanAppRec.Sourcing_channel__c == "Used Car Dealer Without Rc Limit") ? true : false;
                        this.dealerOptions = [
                            { label: 'Used Car Dealer With Rc Limit', value: 'Used Car Dealer With Rc Limit' },
                            { label: 'Used Car Dealer Without Rc Limit', value: 'Used Car Dealer Without Rc Limit' }
                        ];
                        if((this.productName =='CV Loading (Used)' || this.productName =='CV Passenger (Used)') && this.loanAppRec.Sourcing_channel__c == "Used Car Dealer With Rc Limit" ){
                            this.dealerOptions = [
                          { label: 'Used Car Dealer With Rc Limit', value: 'Used Car Dealer With Rc Limit' }
                      ];
                      }
                      else if(this.loanAppRec.Sourcing_channel__c == "Used Car Dealer Without Rc Limit"){
                          this.dealerOptions = [
                          { label: 'Used Car Dealer Without Rc Limit', value: 'Used Car Dealer Without Rc Limit' }
                      ];
                      }
                      if((this.productName =='CV Loading (Used)' || this.productName =='CV Passenger (Used)') && this.loanAppRec.Sourcing_channel__c == "Commercial Associate With Rc Limit" ){
                        this.dealerOptions = [
                      { label: 'Commercial Associate With Rc Limit', value: 'Commercial Associate With Rc Limit' }
                  ];
                  }
                  else if(this.loanAppRec.Sourcing_channel__c == "Commercial Associate Without Rc Limit"){
                      this.dealerOptions = [
                      { label: 'Commercial Associate Without Rc Limit', value: 'Commercial Associate Without Rc Limit' }
                  ];
                  }


                        this.isUsedOrNow = true;
                    }
                    //else if (this.productName.includes('Cow')) {
                    else if (this.productName && this.cowSubProducts.toUpperCase().includes(this.productName.toUpperCase())) {//R2-2634
                        this.dealerOptionsShow = false;
                        this.isUsedOrNow = true;
                    }
                    this.showLookups = true;
                    if (result.loanApp != null && result.loanApp.Purchase_State__c) {
                        this.isDisablePurchCityFld = false;
                    }
                    this.isLoading = false;

                    if (result.loanApp.Dealer_Master__c != null) {

                        this.recordSelected.Purchase_State__c = result.loanApp.Dealer_Master__c != null ? result.loanApp.Dealer_Master__r.Purchase_State__c : '';
                        this.purchaseState = result.loanApp.Dealer_Master__c != null ? result.loanApp.Dealer_Master__r.Purchase_State__c : '';
                        this.recordSelected.Purchase_City__c = result && result.loanApp && result.loanApp.Purchase_City__c ? result.loanApp.Purchase_City__c : '';
                        this.purchaseCity = result && result.loanApp && result.loanApp.Purchase_City__c ? result.loanApp.Purchase_City__c : '';
                        this.recordSelected.Name = result && result.loanApp && result.loanApp.Dealer_Master__r.Name ? result.loanApp.Dealer_Master__r.Name : '';
                        this.dealerName = result && result.loanApp && result.loanApp.Dealer_Master__r.Name ? result.loanApp.Dealer_Master__r.Name : '';
                        
                        this.recordSelected.Outlet_Name__c = result && result.loanApp && result.loanApp.Outlet_Name__c && result.loanApp.Outlet_Name__r.Outlet_Name__c ? result.loanApp.Outlet_Name__r.Outlet_Name__c : '';
                        
                        let params = {};
                        params.Name = result.loanApp.Dealer_Master__r.Name;
                        // this.prePopulateOneLookupFld();
                        setTimeout(() => this.prePopulateOneLookupFld(), 0);
                        this.fetchValueForDealerDetails(params);

                    }

                    // if (result.loanApp.hasOwnProperty("Dealer_Master__r")) {
                    //     this.dealerClass = result.loanApp.Dealer_Master__r.Dealer_Class__c;
                    // }
                    if (result.loanApp.hasOwnProperty("Sourcing_Channel_Name__r")) {
                            this.dealerClass = result.loanApp.Sourcing_Channel_Name__r.Dealer_Class__c;
                            console.log('testyash123 '+result.loanApp.Sourcing_Channel_Name__r.Dealer_Class__c)
                        }

                    // if (this.productName.includes('New')) {
                    //     this.istriigerSection = true;
                    // }
                    //Adding comment as not required condition for Rendering RC limit fields
                    
                    if (this.dealerClass.toLowerCase().includes("with rc limit")) {
                        console.log('test shukls '+this.dealerClass.toLowerCase().includes("with rc limit"))
                        this.isRCLimit = true;
                    }
                }
                if (this.productName) {
                    if (this.productName.includes("Two Wheeler")) {
                        this.isTwoWheeler = true;
                    }
                    else {
                        this.isFourWheeler = true;
                    }
                }
                if ((sourcingChannel == "Marketing Activity" || sourcingChannel == "Self-Sourcing" || sourcingChannel == "TCU - Compaign" || sourcingChannel == "EBRP")) {
                    this.isSourcingAndPayoutSection = true;
                }
                this.showOrHideFLds();
                this.showAllFieldsToCentralTeam();
                this.generateMfgOptions(result.productVsMfg);


                if (result.isFetchFromLoanAppl == false) {
                    this.prePopulateLookupFromLoan(result);
                    this.productVsMfg = result.productVsMfg;
                    if (!(this.data.hasOwnProperty('populateVal'))) {
                        this.paymentObj = {};
                        this.paymentObj.dsePayout = 'No';
                        this.paymentObj.dsmPayout = 'No';
                        this.paymentObj.sourceChannelPayoutType = 'Full';
                        this.paymentObj.Source_Channel_Payout_Type__c = 'Full';
                        this.paymentObj.Dealer_Payout_Type__c = 'Full';
                        this.paymentObj.dealerPayoutType = 'Full';
                        this.paymentObj.sourcePayoutAmt = 100;
                        this.paymentObj.dealerPayoutAmt = 100;
                    }
                }
                else {
                    this.prePopulateLookupFromLoan(result);
                    this.paymentObj = result.populateVal;
                    this.paymentObj.dsePayout = this.paymentObj.dsePayout ? this.paymentObj.dsePayout : 'No';
                    this.paymentObj.dsmPayout = this.paymentObj.dsmPayout ? this.paymentObj.dsmPayout : 'No';
                    this.paymentObj['Source_Channel_Payout_Type__c'] = this.paymentObj.sourceChannelPayoutType;
                    this.paymentObj['Dealer_Payout_Type__c'] = this.paymentObj.dealerPayoutType;
                    this.showOrHidePayoutSectionFLds('DSE_Payout__c', this.paymentObj.dsePayout);
                    this.showOrHidePayoutSectionFLds('DSM_Payout__c', this.paymentObj.dsmPayout);
                    this.showOrHidePayoutSectionFLds('Source_Channel_Payout_Type__c', this.paymentObj.sourceChannelPayoutType);
                    this.showOrHidePayoutSectionFLds('Dealer_Payout_Type__c', this.paymentObj.dealerPayoutType);

                    this.defaultDseOrDSMOptions();
                    this.dealerDetail = result.dealerValues;
                    //this.prePopulateLookupFld();
                    setTimeout(() => this.prePopulateLookupFld(), 0);
                    this.calculateBalanceFld();
                }
                this.error = undefined;
                this.disableFieldsAsPerMetadata();
            })
            .catch((error) => {
                this.error = error;
                this.data = undefined;
                this.isLoading = false;
                console.log("Error inside dealerDetailHandler  " + JSON.stringify(error));
            });
    }

    async disableFieldsAsPerMetadata() {
        this.fieldsToBeDisabled = await getMaterialFields({ strScreen: 'Dealer Details', strLoanId: this.recordId });
        if (this.fieldsToBeDisabled) {
            this.fieldsToBeDisabled.forEach((input => {
                if (this.template.querySelectorAll('[data-name="' + input + '"]')) {
                    this.template.querySelectorAll('[data-name="' + input + '"]').forEach((inputToBeDisabled => {
                        inputToBeDisabled.disabled = true;
                    }));
                }
            }));
        }
        this.isLoading = false;
    }

    showOrHideFLds() {
        let sourceChannelVal = this.loanAppRec.Sourcing_channel__c;

        if (sourceChannelVal == "Au Samridhi/Referral" || sourceChannelVal == "Commercial Associate With Rc Limit" ||
            sourceChannelVal == "Commercial Associate Without Rc Limit" || sourceChannelVal == "Dsa New Vehicle") {
            this.isSourceChannelPayout = true;
        }
        else {
            this.isSourceChannelPayout = false;
        }
        if (sourceChannelVal == "Dealer New Vehicle" || sourceChannelVal == "Used Car Dealer With Rc Limit" || sourceChannelVal == "Used Car Dealer Without Rc Limit") {
            this.isDealerPayout = true;
        }
        else {
            this.isDealerPayout = false;
        }
    }

    setSelectedRecord() {
        this.isDealerName = true;
      //  this.recordSelected.Purchase_State__c = this.dealerDetail && this.dealerDetail.purchaseState ? this.dealerDetail.purchaseState : '';
        this.recordSelected.Purchase_City__c = this.dealerDetail && this.dealerDetail.purchaseCity ? this.dealerDetail.purchaseCity : '';
        this.recordSelected.Account_Name__c = this.dealerDetail && this.dealerDetail.dealerName ? this.dealerDetail.dealerName : '';
        //this.recordSelected.Outlet_Name__c = this.dealerDetail.outletName;
         //R2- 1816 || START
         if(this.isBodyType){
             //this.recordSelected.Outlet_Name__c =  this.outletId;
         }
        //R2- 1816 || END
    }

    prePopulateLookupFld() {
        this.setSelectedRecord();
        const objChild = this.template.querySelectorAll('c-generic-custom-lookup');
        for (let val of objChild) {
            if(val.fieldapi == 'Outlet_Name__c' && !this.recordSelected.Outlet_Name__c){
                val.isDisabled = this.dealerName ? false : true;
            }else{
                val.reflectSelectedRecordValues(this.recordSelected);
            }
        }
    }

    prePopulateOneLookupFld() {
        const objChild = this.template.querySelectorAll('c-generic-custom-lookup');
        for (let val of objChild) {
            if(val.fieldapi == 'Outlet_Name__c' && !this.recordSelected.Outlet_Name__c){
                val.isDisabled = this.dealerName ? false : true;
            }else{
                val.reflectSelectedRecordValues(this.recordSelected);
            }
        }
    }



    prePopulateLookupFromLoan(result) {
        this.mfgValue = result.dealerValues.mfg;
        if (this.mfgValue) {
            //commented as of now as breaking
            /*
            for (let i = 2; i < 6; i++) {
                let getGenericLookup = this.template.querySelector(`[data-sequence='${i}']`);
                getGenericLookup.classList.remove("slds-hide");
            }
            */
        }
        this.productValue = this.loanAppRec.Product__c;
        this.getProductTypeValue(this.productValue);
    }

    defaultDseOrDSMOptions() {
        let dseNamePanOptions = [];
        let dsmNamePanOptions = [];

        //dseNamePanList to dseNamePanLst
        if (JSON.stringify(this.paymentObj.dseNamePanLst) != "[{}]") {
            for (let obj1 of this.paymentObj.dseNamePanLst) {
                let dseId = obj1.id;
                let dse = obj1.name + '_' + obj1.pan;
                dseNamePanOptions.push({ label: dse, value: dseId });
                this.paymentObj.DSE__c = dseId;
                this.dseNamePanOptions = dseNamePanOptions;
            }
        }

        //dsmNamePanList to dsmNamePanLst
        if (JSON.stringify(this.paymentObj.dsmNamePanLst) != "[{}]") {
            for (let obj2 of this.paymentObj.dsmNamePanLst) {
                let dsmId = obj2.id;
                let dsm = obj2.name + '_' + obj2.pan;
                dsmNamePanOptions.push({ label: dsm, value: dsmId });
                this.paymentObj.DSM__c = dsmId;
                this.dsmNamePanOptions = dsmNamePanOptions;
            }
        }
    }


    showAllFieldsToCentralTeam() {
        if (profileName == "System Administrator") {
            this.isSourcingAndPayoutSection = false;
            this.isTwoWheeler = true;
            this.isDseNamePan = true;
            this.isDsmNamePan = true;
        }
    }

    generateMfgOptions(productVsMfg) {
        let productVsMfgObj = productVsMfg;
        let obj = [];
        for (let key in productVsMfgObj) {
            for (let prodCode in productVsMfgObj[key]) {
                let labelAndVal = productVsMfgObj[key][prodCode];
                obj.push({ label: labelAndVal, value: labelAndVal });
            }
        }
        this.mfgOptions = obj;
    }

    handleChange(event) {
        let context =event.detail.context;
        let targetSequence = event.target.dataset.sequence;
        let targetName = event.target.name;
        let val = event.detail.value;
        //let purchaseStateVal = event.detail.name;
        let purchaseCityVal = event.detail.purchasingCityName;
        let dealerNameVal = event.detail.name;
        let outletNameVal = event.detail.value;
        let dealerRecId = event.detail.value;
        let outletRecId = event.detail.value;
        console.log("targetName--" + targetName);
        console.log("val--" + val);
        console.log("event.detail--" + JSON.stringify(event.detail));
        let params = {};
        /*
        if (targetName == "MFG") {
            this.productValue = this.loanAppRec.Product__c;
            this.getProductTypeValue(this.productValue);
            this.mfgValue = val;
            if (val) {
                this.showOrHideGenericLookup(targetSequence);
            }
        }
        */
        if (targetName == "Dealer_channel__c") {
            this.loanAppRec.Dealer_Channel__c = val;
            this.loanApplUpdate.Dealer_Channel__c = val;
            this.dealerChannelVal = val;
            // R2-2708
            const objChild = this.template.querySelectorAll('c-generic-custom-lookup');
            for (let val of objChild) {
                if(val.fieldapi == 'Account_Name__c' || val.fieldapi == 'Purchase_City__c'){
                        val.resetData();
                }
            }
            this.resetDealerDetails();
            // R2-2708
            this.getDealerClassValue();

        }
        else if (targetName == "Purchase_State__c") {
            this.purchaseState = val;
            this.loanAppRec['Purchase_State__c'] = val;
            this.loanApplUpdate.Purchase_State__c = this.purchaseState ? this.purchaseState : ''; 
             // R2 || START
            if(this.isBodyType){
                this.checkBodyFunding();
            }
             this.dealerDetail['Purchase_State__c']= val;
             //END

             this.handlePurchaseRegionChange(targetSequence); // Added to remove value from dependent field
            this.showOrHideGenericLookup(targetSequence);
        }
        else if (targetName == "Purchase_City__c") {
            this.purchaseCity = purchaseCityVal;
            this.loanApplUpdate['Purchase_City__c'] = this.purchaseCity ? this.purchaseCity : '';
            if( this.isBodyType){
                this.checkBodyFunding();// R2 || Change
                this.resetDealerDetails();
            }
            this.handlePurchaseRegionChange(targetSequence); // Added to remove value from dependent field
            this.showOrHideGenericLookup(targetSequence);
            
        }
        else if (targetName == "Account_Name__c") {
            console.log(" inside account name event.detail--" + JSON.stringify(event.detail));
            this.isShowOutletLookup = true;
            this.isDisableOutlNameFld = false;
            this.dealerName = dealerNameVal;
            this.loanApplUpdate['Dealer_Master__c'] = dealerRecId ? dealerRecId : ''; 
            this.loanApplUpdate['Purchase_City__c'] = this.purchaseCity ? this.purchaseCity : '';
            this.loanApplUpdate['Purchase_State__c'] = this.purchaseState ? this.purchaseState : ''; 
            this.loanApplUpdate.Id = this.loanAppRec.Id;
            this.handlePurchaseRegionChange(targetSequence); // Added to remove value from dependent field
            this.showOrHideGenericLookup(targetSequence);
            if(!this.isUsedOrNow)
            params['MFG__r.Name'] = this.mfgValue;
            params.Product__c = this.getProductTypeValue(this.productValue);
            params.Purchase_State__c = this.purchaseState;
            params.Purchase_City__c = this.purchaseCity;
            params.Account_Name__c = this.dealerName;
            if (dealerNameVal) {
                this.fetchValueForDealerDetails(params);
            }
            if(context == 'deselect'){
                this.resetDealerDetails();
            }
        }
        else if (targetName == "Outlet_Name__c") {
            console.log("this.Outlet_Name__c--" + outletNameVal);
            this.loanApplUpdate.Outlet_Name__c = outletRecId;

        }

    }


    // Purchase Region related values re-fetch when editing form
    async handlePurchaseRegionChange(targetSequence){
        const genericLookupArr = this.template.querySelectorAll('c-generic-custom-lookup');
        for(let i = targetSequence - 1; i < genericLookupArr.length; i++){
            genericLookupArr[i].callHandleRemove();
        }
    }
    // Purchase Region related values re-fetch when editing form

     //R2 || START
    handleValChange(event){
        let fieldApiName = event.target.name;
        this.dealerDetail[event.target.name]= event.target.value;
        if(fieldApiName == 'IFSC_Code__c' ){ //&& this.isBodyType
            this.getBankName(event.target.value);
        }
        
    }

    async getBankName(ifscVal){
        var bankMappedWithIFSC = await getBankName({ifsc: ifscVal});
        console.log('bankMappedWithIFSC-->' +JSON.stringify(bankMappedWithIFSC));
        if(bankMappedWithIFSC && bankMappedWithIFSC.Bank_Name__c){
            this.dealerDetail.bankName = bankMappedWithIFSC.Bank_Name__c;
            this.dealerDetail['Bank_Name__c'] = bankMappedWithIFSC.Bank_Name__c;
        }
        
    }
    checkBodyFunding(){
        this.selectedRecord = {};
        this.resetDealerDetails();
        checkBodyFundingRequired({ manufacture : this.mfgValue ,
                                   purchaseCity: this.purchaseCity,
                                   purchaseState : this.purchaseState,
                                   dealerChannel : this.bodyFundingDealerClass,
                                   product: this.productValueType })
        .then((result) => {
            console.log('BodyFunding-->' +result);
            if (result == false) {
               this.showDealerDisabled = false;
            }else{
                this.showDealerDisabled = true;
            }
        })
        .catch((error) => {
            this.error = error;
        });
    }
    handleDealerSave(){
        
        this.dealerDetail['Dealer_Class__c'] = this.bodyFundingDealerClass;
        this.dealerDetail['Product__c'] = 'ALL';//this.productValueType;
        dealerSave({dealerRecord :this.dealerDetail,Mfg : this.mfgValue, strLoanId: this.recordId,
                    channel :this.dealerChannelVal})
        .then((result) => {
          
        })
        .catch((error) => {
            this.error = error;
        });
    }
    // R2 || END

    resetDealerDetails(){
        this.dealerDetail.dealerCode = undefined;
        this.dealerDetail.category = undefined;
        //this.dealerClassVal = undefined;
        this.dealerDetail.dealerType = undefined;
        this.dealerDetail.phoneNumber = undefined;
        this.dealerDetail.email = undefined;
        this.dealerDetail.bankName = undefined;
        this.dealerDetail.benificiaryAccountNumber = undefined;
        this.dealerDetail.ifscCode = undefined;
        const objChild = this.template.querySelectorAll('c-generic-custom-lookup');
        for (let val of objChild) {
           if(val.fieldapi == 'Outlet_Name__c'){
                val.resetData();
           }
        }
    }

    showOrHideGenericLookup(targetSequence) {
       
        if (targetSequence == "1") {
            this.isDisablePurchCityFld = false;

        }
        else if (targetSequence == "2") {
            this.isDisableDealNameFld = false;
        }
        else if (targetSequence == "3") {
            this.isDisableOutlNameFld = false;
        }
    }

    fetchValueForDealerDetails(params) {
        genericFetchForDealer({ params: params, loanApplId: this.recordId })
            .then((result) => {
                console.log('result of genericFetchForDealer--' + JSON.stringify(result));
                this.dealerDetail = result.dealerValues;
                this.calculateBalanceFld();
                if (result.relatedContactsOfAccount.length > 0) {
                    this.genDseOrDSMOptions(result.relatedContactsOfAccount);
                }
                 //R2 || Change || START
               /* if(this.isBodyType){
                    this.checkBodyFunding(); 
                }*/
                //END
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.contacts = undefined;
            });
    }

    calculateBalanceFld() {
        let rcLimitCount = (this.dealerDetail.rcLimitCount) ? Number(this.dealerDetail.rcLimitCount) : "";
        let rcLimitUsedCoun = (this.dealerDetail.rcLimitUsedCount) ? Number(this.dealerDetail.rcLimitUsedCount) : "";
        if (rcLimitCount && rcLimitUsedCoun) {
            this.dealerDetail.balRcLimitCount = rcLimitCount - rcLimitUsedCoun;
        }
        else {
            this.dealerDetail.balRcLimitCount = "";
        }

        let rcLimitAmt = (this.dealerDetail.rcLimitAmount) ? Number(this.dealerDetail.rcLimitAmount) : "";
        let rcLimitUsedAmt = (this.dealerDetail.rcLimitUsedAmount) ? Number(this.dealerDetail.rcLimitUsedAmount) : "";
        if (rcLimitAmt && rcLimitUsedAmt) {
            this.dealerDetail.balRcLimitAmt = rcLimitAmt - rcLimitUsedAmt;
        }
        else {
            this.dealerDetail.balRcLimitAmt = "";
        }

    }

    genDseOrDSMOptions(relatedContactsOfAccount) {
        let dseNamePanOptions = [];
        let dsmNamePanOptions = [];

        for (let val of relatedContactsOfAccount) {
            let type = (val.Type__c) ? val.Type__c : "";
            let name = (val.Name) ? val.Name : "";
            let pan = (val.PAN__c) ? val.PAN__c : "";
            let namePan = name + '_' + pan;

            if (type == "DSE") {
                dseNamePanOptions.push({ label: namePan, value: val.Id });
            }
            else if (type == "DSM") {
                dsmNamePanOptions.push({ label: namePan, value: val.Id });
            }
        }
        this.dseNamePanOptions = dseNamePanOptions;
        this.dsmNamePanOptions = dsmNamePanOptions;
    }

    handleValueChange(evt) {
        let fldApiName = evt.target.name;
        let fldValue = evt.detail.value;
        this.paymentObj[fldApiName] = fldValue;
        if(fldApiName == 'Source_Channel_Payout_Type__c'){
            this.paymentObj['sourceChannelPayoutType'] = fldValue
        }
        if(fldApiName == 'Dealer_Payout_Type__c'){
            this.paymentObj['dealerPayoutType'] = fldValue
        }
        if (fldApiName == 'Source_Payout_amt__c') {
            this.paymentObj['sourcePayoutAmt'] = fldValue;
        }
        if (fldApiName == 'Dealer_Payout_amt__c') {
            this.paymentObj['dealerPayoutAmt'] = fldValue;
        }
        // SFAU-5290 - Start 27 Sept -- Kunal
        if (fldApiName == 'DSE_Payout__c') {
            this.paymentObj['dsePayout'] = fldValue;
            this.paymentObj['dse'] = '';
            this.paymentObj['DSE__c'] = '';
        }
        if (fldApiName == 'DSM_Payout__c') {
            this.paymentObj['dsmPayout'] = fldValue;
            this.paymentObj['DSM__c'] = '';
            this.paymentObj['dsm'] = '';
        }
        // SFAU-5290 - End 27 Sept -- Kunal

        this.showOrHidePayoutSectionFLds(fldApiName, fldValue,true);
    }



    showOrHidePayoutSectionFLds(fldName, fldValue,fromOnChange) {
        if (fldName == "DSE_Payout__c") {
            if (fldValue == 'Yes') {
                this.isDseNamePan = true;
            }
            else {
                if (this.isDseNamePan == true) {
                    let getDseNamePan = this.template.querySelector(`[data-name='DSE__c']`);
                    if(getDseNamePan){
                        getDseNamePan.value = "";
                    }
                } 
                this.isDseNamePan = false; 
            }
        }
        if (fldName == "DSM_Payout__c") {
            if (fldValue == 'Yes') {
                this.isDsmNamePan = true;
            }
            else {
                   if (this.isDsmNamePan == true) {
                    let getDsmNamePan = this.template.querySelector(`[data-name='DSM__c']`);
                    if(getDsmNamePan){
                        getDsmNamePan.value = "";
                    }
                } 


                this.isDsmNamePan = false;
            }
        }
        if (fldName == "Source_Channel_Payout_Type__c") {
            /* if(fldValue == 'Other amount-%') {
                 this.isOtherSourceAmt = true;
             }
             else {
                 this.isOtherSourceAmt = false;
             }        
             if(fldName == "Dealer_Payout_Type__c") {
                 if(fldValue == 'Other amount-%') {
                     this.isOtherDealerAmt = true;
                 }
                 else {
                     this.isOtherDealerAmt = false;
                 }        
             } */

            if (fldValue == 'Full') {
                this.paymentObj['sourcePayoutAmt'] = 100;
                this.paymentObj['Source_Payout_amt__c'] = '100';
            }
            else if (fldValue == 'Half') {
                this.paymentObj['sourcePayoutAmt'] = 50;
                this.paymentObj['Source_Payout_amt__c'] = '50';
            }
            else {
                this.paymentObj['sourcePayoutAmt'] = fromOnChange ?  "" : this.paymentObj['sourcePayoutAmt'] ;
            }
        }

        if (fldName == "Dealer_Payout_Type__c") {
            if (fldValue == 'Full') {
                this.paymentObj['dealerPayoutAmt'] = 100;
                this.paymentObj['Dealer_Payout_amt__c'] = '100';
            }
            else if (fldValue == 'Half') {
                this.paymentObj['dealerPayoutAmt'] = 50;
                this.paymentObj['Dealer_Payout_amt__c'] = '50';
            }
            else {
                this.paymentObj['dealerPayoutAmt'] = fromOnChange ?  "" : this.paymentObj['dealerPayoutAmt'] ;
            }
        }

    }
    



    handleOnBlur() {
        if (this.paymentObj['Source_Channel_Payout_Type__c'] && this.paymentObj['Source_Channel_Payout_Type__c'] != 'Full' && this.paymentObj['Source_Channel_Payout_Type__c'] != 'Half') {
            if (!this.paymentObj['sourcePayoutAmt']) {
                this.paymentObj['sourcePayoutAmt'] = '';
            }
            else if (this.paymentObj['sourcePayoutAmt'] > 100) {
                this.paymentObj['sourcePayoutAmt'] = `Rs ${this.paymentObj['sourcePayoutAmt']}`;
            }
            else if (this.paymentObj['sourcePayoutAmt'] <= 100) {
                this.paymentObj['sourcePayoutAmt'] = `${this.paymentObj['sourcePayoutAmt']} %`;
            }
        }
         if (this.paymentObj['Dealer_Payout_Type__c'] && this.paymentObj['Dealer_Payout_Type__c'] != 'Full' && this.paymentObj['Dealer_Payout_Type__c'] != 'Half') {
            if (!this.paymentObj['dealerPayoutAmt']) {
                this.paymentObj['dealerPayoutAmt'] = '';
            }
            else if (this.paymentObj['dealerPayoutAmt'] > 100) {
                this.paymentObj['dealerPayoutAmt'] = `Rs ${this.paymentObj['dealerPayoutAmt']}`;
            }
            else if (this.paymentObj['dealerPayoutAmt'] <= 100) {
                this.paymentObj['dealerPayoutAmt'] = `${this.paymentObj['dealerPayoutAmt']} %`;
            }
        }
    }


    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll(".validate");
        for (let inputField of inputFields) {
            if (inputField.required && !inputField.value && !inputField.className.includes("slds-hide")) {
                console.log("inputField.name-- " + inputField.name);
                inputField.setCustomValidity("Complete this field");
                inputField.reportValidity();
                isValid = false;
                console.log('field name is >>' + inputField.name);
            }
            else if (inputField.value) {
                if (inputField.name == "Purchase_City__c" || inputField.name == "Account_Name__c") {
                    this.isInputRequied = false;
                }
                inputField.setCustomValidity("");
                inputField.reportValidity();
            }
        }
        return isValid;
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

    async handleSave() {

        let keysToreplace = { 'dsePayout': 'DSE_Payout__c', 'dsmPayout': 'DSM_Payout__c' };



        this.paymentObj.Loan_Application__c = this.loanAppRec.Id;
        if (this.paymentObj.hasOwnProperty('sourcePayoutAmt') && this.paymentObj['sourcePayoutAmt']) {
            if (this.paymentObj['Source_Channel_Payout_Type__c'] && this.paymentObj['Source_Channel_Payout_Type__c'] != 'Full' && this.paymentObj['Source_Channel_Payout_Type__c'] != 'Half') {
                if (this.paymentObj['sourcePayoutAmt'].includes('Rs ')) {
                    this.paymentObj['sourcePayoutAmt'] = Number((this.paymentObj['sourcePayoutAmt']).replace('Rs ', ''));
                }
                else if (this.paymentObj['sourcePayoutAmt'].includes(' %')) {
                    this.paymentObj['sourcePayoutAmt'] = Number((this.paymentObj['sourcePayoutAmt']).replace(' %', ''));
                }
            }
        }
        if (this.paymentObj.hasOwnProperty('dealerPayoutAmt') && this.paymentObj['dealerPayoutAmt']) {
            if (this.paymentObj['Dealer_Payout_Type__c'] && this.paymentObj['Dealer_Payout_Type__c'] != 'Full' && this.paymentObj['Dealer_Payout_Type__c'] != 'Half') {
                if (this.paymentObj['dealerPayoutAmt'].includes('Rs ')) {
                    this.paymentObj['dealerPayoutAmt'] = Number((this.paymentObj['dealerPayoutAmt']).replace('Rs ', ''));
                }
                else if (this.paymentObj['dealerPayoutAmt'].includes(' %')) {
                    this.paymentObj['dealerPayoutAmt'] = Number((this.paymentObj['dealerPayoutAmt']).replace(' %', ''));
                }
            }
        }

        for (let key in keysToreplace) {
            let newKey = keysToreplace[key];
            this.paymentObj[newKey] = this.paymentObj[key]; // Assign new key
            //delete this.paymentObj[key]; // Delete old key
        }

        //this.replaceKeysFromPaymment(keysToreplace);


        let action;
        if (!this.paymentObj.hasOwnProperty('Id') && !this.paymentObj.Id) {
            // this.saveRecord("save");
            action = 'save';
        }
        else {
            this.loanApplUpdate.Id = this.loanAppRec.Id;
            // this.saveRecord("edit");
            action = 'edit';
        }
        this.saveRecord(action);
           //R2-1816 START || 
        if(!this.showDealerDisabled){
            this.handleDealerSave();
        }
         //R2 END
    }

    replaceKeysFromPaymment(keyList) {
        for (let key in keyList) {
            this.replaceKeyFromObj(key, keyList[key]);
        }
    }


    replaceKeyFromObj(oldKey, newKey) {
        this.paymentObj[newKey] = this.paymentObj[oldKey]; // Assign new key
        delete this.paymentObj[oldKey]; // Delete old key
    }

    handleEdit() {
        this.isDisableInputFld = false;
        this.enableOrDisableGenericLookUpFLds(false);
    }

    

    saveRecord(scenario) {
        saveDealerAndUpdatLoanAppl({ loanApplctn: this.loanApplUpdate, paymentRec: this.paymentObj, scenario: scenario })
            .then((result) => {
                console.log('result of saveDealerAndUpdatLoanAppl--' + JSON.stringify(result));
                if (result == "success") {
                    if (scenario == "save") {
                        this.showToastMessage('Success', 'Saved Successfully', 'success', 'dismissible');
                    }
                    else if (scenario == "edit") {
                        this.showToastMessage('Success', 'Updated Successfully', 'success', 'dismissible');
                    }
                    this.isDisableInputFld = true;
                    this.enableOrDisableGenericLookUpFLds(true);
                    const Obj = {};
                    //Obj.applicantRecord = this.applicantIdInput;
                    this.errorOnChild = '';
                    Obj.errorOnChild = this.errorOnChild;
                    Obj.next = this.errorOnChild == '' ? true : false;
                    console.log('Obj', Obj);
                    this.dispatchEvent(new CustomEvent('next', {
                        detail: Obj
                    }));
                } else {
                    this.showToastMessage('Error', 'Something went wrong. Please try again', 'error', 'dismissible');
                }
                this.error = undefined;
            })
            .catch((error) => {
                return null;
                this.error = error;
                console.log("Error inside saveDealerAndUpdatLoanAppl");
            });
    }

    enableOrDisableGenericLookUpFLds(stateOfFld) {
        const objChild = this.template.querySelectorAll('c-generic-custom-lookup');
        for (let lookupFld of objChild) {
            lookupFld.enableOrDisableLookupFLd(lookupFld, stateOfFld);
        }
    }

    showToastMessage(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    @api nextHandler() {
        if(this.isEditRestricted){
            this.showToastMessage('Access Restricted', 'Dealer Details were not saved due to Insufficient Access Rights', 'warning', 'sticky');
            const Obj = {};
            Obj.next = true; 
            this.dispatchEvent(new CustomEvent('next', {
                detail: Obj
            })); 
        }else{
            let inputValid = this.isInputValid();
            let validGenericLookup = this.isValidateGenericLookup();
            // R2-2708
            if (!inputValid || !validGenericLookup) {
            // R2-2708
                this.showToastMessage('Error', 'Please check all the details again', 'error', 'dismissible');
                return;
            }

            this.handleSave();

        }


    }

}