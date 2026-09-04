import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveCharges from '@salesforce/apex/ChargesController.saveCharges';
import getCustomMetaRecStageProfle from '@salesforce/apex/ChargesController.getCustomMetaRecStageProfle';
import chargesHandler from '@salesforce/apex/ChargesController.chargesHandler';
import FORM_FACTOR from '@salesforce/client/formFactor';
import {updateRecord} from 'lightning/uiRecordApi';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';

// Stamping charges for MP Tractor
import getStampingChargeApplicableRecord from '@salesforce/apex/ChargesController.getStampingChargeApplicableRecord';
import STAMPING_EXPENSE_FEATURE_MP_SPECIFIC from "@salesforce/label/c.Stamping_Expense_Feature_MP_Specific";
// Stamping charges for MP Tractor

// Commercial Udyam Features
import COMMERCIAL_PRODUCT_CODES from '@salesforce/label/c.Commercial_Product_Codes';
// Commercial Udyam Features

// Custom Spinner settings
import { getSpinnerImage } from 'c/customSpinner';
// Custom Spinner settings

import {
    APPLICATION_SCOPE,
    createMessageContext,
    MessageContext,
    publish,
    releaseMessageContext,
    subscribe,
    unsubscribe,
} from 'lightning/messageService';
import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c';

// Stamping Charges functionality for Tractor QDE Specific
const TRACTOR_PRODUCT_CODES = new Set(['10501','10502','10503']);
const STAGES_LITERAL_APPLICABLE = new Set(['QDE', 'DDE', 'PSD']);
const STAMPING_CHARGE_SC_CODE = new Set(['1005']);;
const STAMPING_EXPENSE_SC_CODE = new Set(['1146']);;
const DISABLE_ENABLE_FIELDS = new Set(['Charge_Amount__c', 'Total_Amount__c', 'Actual_rate__c']);;
// Stamping Charges functionality for Tractor QDE Specific

// Commercial Udyam Cert feature
const COMMERCIAL_PRODUCT_CODES_SET = new Set(COMMERCIAL_PRODUCT_CODES.split(','));
// Commercial Udyam Cert feature


export default class Charges extends LightningElement {


    messageContext = createMessageContext();
    isloading;
    error;
    stageProfCustmMetaDataRecs;
    isMobile;
    isActualRateFld;
    isValidate = false;
    disableFldAndBttn = false;
    disableEditBttn   = true;
    @api boolFromWizard   = false;
    @api recordId;
    @track loanApplRec =[];
    @track chargesData = [];
    @track visibledFields = [];
    @track validateFields = {};
    errorOnChild;
    totalCharges = 0;
    @track displayButtons=true
    hideButtonStages = ['PDD','Ops Maker','Ops Author']//4733

    // Stamping Charges functionality for Tractor QDE Specific
    existingStampingExpenseBeforeChange = {
        actualRate : 0,
        chargeAmount : 0,
        taxAmount : 0,
        totalAmount : 0
    };
    existingStampingChargeBeforeChange = {
        actualRate : 0,
        chargeAmount : 0,
        taxAmount : 0,
        totalAmount : 0
    };
    // Stamping Charges functionality for Tractor QDE Specific

    // Stamping charges for MP Tractor
    Stamping_Expense_Feature_MP_Specific = STAMPING_EXPENSE_FEATURE_MP_SPECIFIC;
    showToggleAgriGlobal = false;
    // Stamping charges for MP Tractor


    // Udyam Certificate flags
    isExceptionExistUdyamCertCommercial = false;
    // Udyam Certificate flags

    // Custom Spinner settings
    async spinnerImageMethod() {
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.recordId);
        }
    }
    // Custom Spinner settings

    connectedCallback() {
        this.setFormFactor();
        this.setIsEditRestricted();
    }

    async setIsEditRestricted(){
        this.isEditRestricted = await restricAccess({compName: 'charges' ,loanId: this.recordId});
        await this.spinnerImageMethod();
        this.generateData();
    }

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

    // Stamping Charges functionality for Tractor QDE Specific

    // Check if it is Udyam Certificate feature for Commercial
    get isCommercialUdyamCertificateFeatureApplicable(){
        if(this.loanApplRec && this.loanApplRec[0] && this.loanApplRec[0].Product__c ){
            return COMMERCIAL_PRODUCT_CODES_SET.has(this.loanApplRec[0].Product__c);
        }
        return false;
    }

    get isCommercialUdyamCertificateFeatureApplicableWithException(){
        if(this.loanApplRec && this.loanApplRec[0] && this.loanApplRec[0].Product__c ){
            return COMMERCIAL_PRODUCT_CODES_SET.has(this.loanApplRec[0].Product__c) && this.isExceptionExistUdyamCertCommercial;
        }
        return false;
    }
    // Check if it is Udyam Certificate feature for Commercial

    
    // Checking if stamping charge feature is applicable
    isTractorStampingFeatureApplicable(){
        if(this.loanApplRec && this.loanApplRec[0] && this.loanApplRec[0].Product__c && this.loanApplRec[0].Stage__c){
            return TRACTOR_PRODUCT_CODES.has(this.loanApplRec[0].Product__c) && STAGES_LITERAL_APPLICABLE.has(this.loanApplRec[0].Stage__c);
        }
        return false;
    }
    // Checking if stamping charge feature is applicable

    // Handle Wrapper key to API name mapping
    handleWrapperKeyToApiMapping(key){
        if(key === 'actualRate'){
            return 'Actual_rate__c';
        }
        else if(key === 'chargeAmount'){
            return 'Charge_Amount__c';
        }
        else if(key === 'taxAmount'){
            return 'Tax_Amount__c';
        }

        // Reverse mapping
        else if(key === 'Actual_rate__c'){
            return 'actualRate';
        }
        else if(key === 'Charge_Amount__c'){
            return 'chargeAmount';
        }
        else if(key === 'Tax_Amount__c'){
            return 'taxAmount';
        }
    }
    // Handle Wrapper key to API name mapping

    // Make Stamp Charges exception value (780 initially) for commercial 
    handleStampChangeChangesAsPerCommercial(val){
        this.handleDisableStampChargeField(val);
        if(val){
            for(const [key, value]  of this.chargesData.entries()){
                if(STAMPING_CHARGE_SC_CODE.has(value.scCode)){
                    this.calculateCharges({
                        target : {
                            dataset : {
                                key : value.scCode,
                            },
                            name : this.handleWrapperKeyToApiMapping('chargeAmount')
                        },
                        detail : {
                            value : (JSON.parse(value.sourceStampExpenseSave)).exceptionData
                        },

                    }, true);
                }
            }
        }
        else{
            for(const [key, value]  of this.chargesData.entries()){
                if(STAMPING_CHARGE_SC_CODE.has(value.scCode)){
                    const saveSourcingStamp =  JSON.parse(value.sourceStampExpenseSave);
                    for(let i in saveSourcingStamp.masterData){
                        this.calculateCharges({
                            target : {
                                dataset : {
                                    key : value.scCode,
                                },
                                name : this.handleWrapperKeyToApiMapping(i)
                            },
                            detail : {
                                value : saveSourcingStamp.masterData[i]
                            },
        
                        }, true);
                    }
                    
                }
            }
        }
    }
    // Make Stamp Charges exception value (780 initially) for commercial 

    // Make Stamp charge fields disabled to cater for exceptions
    handleDisableStampChargeField(val){
        for(let i of STAMPING_CHARGE_SC_CODE){
            for(let input of this.template.querySelectorAll(`[data-key="${i}"]`)){
                if(DISABLE_ENABLE_FIELDS.has(input.name)){
                    input.disabled = val;
                }
                
            }
        }
    }
    // Make Stamp charge fields disabled to cater for exceptions

    // Make Stamp Charge 0 and also pushing it to stamping expense tractor
    handleStampingChargeChangesAsPerAgri(val){
        this.handleDisableStampChargeField(val);
        if(val){
            for(const [key, value]  of this.chargesData.entries()){
                if(STAMPING_CHARGE_SC_CODE.has(value.scCode)){
                    for(let i in this.existingStampingChargeBeforeChange){
                        this.calculateCharges({
                            target : {
                                dataset : {
                                    key : value.scCode,
                                },
                                name : this.handleWrapperKeyToApiMapping(i)
                            },
                            detail : {
                                value : 0
                            },

                        }, true);
                    }
                    
                }
                
            }
        }
        else{
            for(const [key, value]  of this.chargesData.entries()){
                if(STAMPING_CHARGE_SC_CODE.has(value.scCode)){
                    for(let i in this.existingStampingChargeBeforeChange){
                        this.calculateCharges({
                            target : {
                                dataset : {
                                    key : value.scCode,
                                },
                                name : this.handleWrapperKeyToApiMapping(i)
                            },
                            detail : {
                                value : Number(this.existingStampingChargeBeforeChange[i])
                            },

                        }, true);
                    }
                    
                }
                
            }
            
        }
    }
    // Make Stamp Charge 0 and also pushing it to stamping expense

    // Make stamping expense 0 if no stamping charge exist
    handleMakingStampingExpense(index){
        try{
            if(STAMPING_CHARGE_SC_CODE.has(this.chargesData[index].scCode) && this.isTractorStampingFeatureApplicable()){
                if(this.chargesData[index].totalAmount === 0 || !this.chargesData[index].totalAmount){ 
                    for(const [key, value]  of this.chargesData.entries()){
                        if(STAMPING_EXPENSE_SC_CODE.has(value.scCode)){
                            for(let i in this.existingStampingExpenseBeforeChange){
                                this.calculateCharges({
                                    target : {
                                        dataset : {
                                            key : value.scCode,
                                        },
                                        name : this.handleWrapperKeyToApiMapping(i)
                                    },
                                    detail : {
                                        value : 0
                                    },

                                }, false);
                            }
                            
                        }
                        
                    }
                }
                else{
                    for(const [key, value]  of this.chargesData.entries()){
                        if(STAMPING_EXPENSE_SC_CODE.has(value.scCode)){
                            for(let i in this.existingStampingExpenseBeforeChange){
                                this.calculateCharges({
                                    target : {
                                        dataset : {
                                            key : value.scCode,
                                        },
                                        name : this.handleWrapperKeyToApiMapping(i)
                                    },
                                    detail : {
                                        value : Number(this.existingStampingExpenseBeforeChange[i])
                                    },

                                }, false);
                            }
                            
                        }
                        
                    }
                }
                this.calculateTotalAmtOnConnectedCallb();
            }
        }
        catch(e){
            console.log('handleMakingStampingExpense ->>> ' + e);
        }
    }
    // Make stamping expense 0 if no stamping charge exist

    // Stamping Charges functionality for Tractor QDE Specific

    generateData() {
        this.isloading = true;
        chargesHandler({ loanApplId: this.recordId })
            .then(async (result) => {
                console.log("result of chargesHandler-- "+JSON.stringify(result));
                this.loanApplRec = result.loanApplList;   
                if(this.loanApplRec && this.loanApplRec.length>0){
                    if(this.hideButtonStages.includes(this.loanApplRec[0].Stage__c)){//4733
                        this.displayButtons=false
                    }  
                } 
                        
                this.error = undefined;
                //this.customMetadataRec();  // R1 Code placed it before tractor computation              
                this.chargesData = result.chargesList;
                this.addDenomination(); 
                this.calculateTotalAmtOnConnectedCallb();         
                this.error = undefined;

                // Initial setup for Udyam certificate for Commercial
                if(this.isCommercialUdyamCertificateFeatureApplicable){
                    let stampingCharge = await this.handleFetchTractorExceptionStampingCase(); // Fetch stamping charge metadata
                    if(stampingCharge && stampingCharge.IsException__c && stampingCharge.Exception_Stamp_Charge__c){
                        this.isExceptionExistUdyamCertCommercial = true;
                    }
                    if(this.isCommercialUdyamCertificateFeatureApplicableWithException){
                        for(let [index,i] of this.chargesData.entries()){
                            if(STAMPING_CHARGE_SC_CODE.has(i.scCode)){
                                i.showToggleUdyam = true;
                                if(!i.sourceStampExpenseSave){
                                    i.sourceStampExpenseSave = JSON.stringify({
                                        exceptionData : stampingCharge.Exception_Stamp_Charge__c,
                                        currentData : {
                                            actualRate : i.actualRate,
                                            chargeAmount : i.chargeAmount,
                                            taxAmount : i.taxAmount,
                                            totalAmount : i.totalAmount
                                        },
                                        masterData : {
                                            actualRate : i.actualRate,
                                            chargeAmount : i.chargeAmount,
                                            taxAmount : i.taxAmount,
                                            totalAmount : i.totalAmount
                                        }
                                    });
                                }
                                if(i.isUdyamCertificateAvailable){
                                    setTimeout(() => this.handleDisableStampChargeField(true));
                                }
                            }
                        }
                        
                    }
                    
                }
                // Initial setup for Udyam certificate for Commercial

                // Initial setup for tractor stamping charges
                if(this.isTractorStampingFeatureApplicable()){
                    
                    let isExceptionExist = false; // Flag variable to make stamp charges and expenses subtract from total
                    let stampingCharge = await this.handleFetchTractorExceptionStampingCase(); // Fetch stamping charge metadata

                    for(let [index,i] of this.chargesData.entries()){

                        // Making toggle inactive if not already set in DB
                        if(!this.chargesData[index].agriEndUseOfProduct){
                            this.chargesData[index].agriEndUseOfProduct = false;
                        }
                        // Making toggle inactive if not already set in DB

                        // Stamping charges for MP Tractor
                        const mpStateSet = new Set(this.Stamping_Expense_Feature_MP_Specific.split(","));
                        if(STAMPING_CHARGE_SC_CODE.has(i.scCode) && mpStateSet.has(this.loanApplRec[0].Branch_Master__r.State__r.Account_Name__c)){
                            this.chargesData[index].showToggleAgri = true;
                        }
                        else{
                            this.chargesData[index].showToggleAgri = false;
                        }
                        // Stamping charges for MP Tractor
                        

                        // Saving Stamping charge for Tractor MP
                        if(STAMPING_CHARGE_SC_CODE.has(i.scCode) && !i.sourceStampExpenseSave){
                            this.existingStampingChargeBeforeChange.actualRate = i.actualRate;
                            this.existingStampingChargeBeforeChange.chargeAmount = i.chargeAmount;
                            this.existingStampingChargeBeforeChange.taxAmount = i.taxAmount;
                            this.existingStampingChargeBeforeChange.totalAmount = i.totalAmount;
                            i.sourceStampExpenseSave = JSON.stringify(this.existingStampingChargeBeforeChange);
                        }
                        else if(STAMPING_CHARGE_SC_CODE.has(i.scCode) && i.sourceStampExpenseSave){
                            this.existingStampingChargeBeforeChange = JSON.parse(i.sourceStampExpenseSave);
                        }
                        // Saving Stamping charge for Tractor MP

                        

                        // Saving Stamping expense for Tractor
                        if(STAMPING_EXPENSE_SC_CODE.has(i.scCode) && !i.sourceStampExpenseSave){
                            this.existingStampingExpenseBeforeChange.actualRate = i.actualRate;
                            this.existingStampingExpenseBeforeChange.chargeAmount = i.chargeAmount;
                            this.existingStampingExpenseBeforeChange.taxAmount = i.taxAmount;
                            this.existingStampingExpenseBeforeChange.totalAmount = i.totalAmount;
                            i.sourceStampExpenseSave = JSON.stringify(this.existingStampingExpenseBeforeChange);
                        }
                        else if(STAMPING_EXPENSE_SC_CODE.has(i.scCode) && i.sourceStampExpenseSave){
                            this.existingStampingExpenseBeforeChange = JSON.parse(i.sourceStampExpenseSave);
                        }
                        // Saving Stamping expense for Tractor

                        // Check exception and conditionally hide stamp charge and expense
                        if(stampingCharge.IsException__c && (STAMPING_CHARGE_SC_CODE.has(i.scCode) || STAMPING_EXPENSE_SC_CODE.has(i.scCode))){
                            if(stampingCharge.Vehicle_Usage__c){
                                let vehicleUsageSet = new Set(stampingCharge.Vehicle_Usage__c.split(','));
                                if(this.loanApplRec[0].Total_Loan_Amount__c <= stampingCharge.Loan_Amount_Not_Applicable_Upto__c && vehicleUsageSet.has(this.loanApplRec[0].Collaterals__r[0].Vehicle_Usage__c)){
                                    i.isStampingChargeNotApplicable = true;
                                    isExceptionExist = true;
                                }
                                else{
                                    i.isStampingChargeNotApplicable = false;
                                    isExceptionExist = false;
                                }
                            }
                        }
                        // Check exception and conditionally hide stamp charge and expense



                    }
                    if(isExceptionExist){  // Exception to exist making charge and expense zero
                        this.handleStampingChargeChangesAsPerAgri(true);
                    }
                    
                    setTimeout(() => {
                        // Making stamping expense disabled
                        for(let i of STAMPING_EXPENSE_SC_CODE){
                            for(let input of this.template.querySelectorAll(`[data-key="${i}"]`)){
                                if(DISABLE_ENABLE_FIELDS.has(input.name)){
                                    input.disabled = true;
                                }
                                
                            }
                        }

                        // Making stamping charge disabled on condition
                        for(let [index,i] of this.chargesData.entries()){
                            if(STAMPING_CHARGE_SC_CODE.has(i.scCode) && i.agriEndUseOfProduct){
                                for(let i of STAMPING_CHARGE_SC_CODE){
                                    for(let input of this.template.querySelectorAll(`[data-key="${i}"]`)){
                                        if(DISABLE_ENABLE_FIELDS.has(input.name)){
                                            input.disabled = true;
                                        }
                                        
                                    }
                                }
                            }
                        }
                        
                    });
                    
                }

                // Initial setup for tractor stamping charges
                console.log("result of -- existingStampingExpenseBeforeChange"+JSON.stringify(this.existingStampingExpenseBeforeChange));
                console.log("result of -- existingStampingChargeBeforeChange"+JSON.stringify(this.existingStampingChargeBeforeChange));
                this.customMetadataRec();  // R1 Code placed it before tractor computation          
            })
            .catch((error) => {
                this.isloading = false;
                this.loanApplRec = undefined;
                this.error = error;
                this.data = undefined;
                console.log("Error in chargesHandler-- "+this.error);
            });
    }


    // Fetch & Check exception for Tractor Stamping Charges
    async handleFetchTractorExceptionStampingCase(){
        try{
            let stampCharge = await getStampingChargeApplicableRecord({
                loanAppId : this.recordId
            });
            return stampCharge;
        }
        catch(e){
            const evt = new ShowToastEvent({
                title: 'ERROR',
                message: 'Something went wrong in fetching Stamping Charge for exception in tractor ' + e + ' ' + JSON.stringify(e),
                variant: 'error',
                mode: 'dismissible'
            });
            this.dispatchEvent(evt);
        }
    }


    // Fetch & Check exception for Tractor Stamping Charges
    
    calculateTotalAmtOnConnectedCallb() {
        let sumOfCharges = 0;
        for(let chrgeData of this.chargesData) {
            sumOfCharges += isNaN(chrgeData.totalAmount) ? 0 : chrgeData.totalAmount; //R2-2790
        }
        this.totalCharges = Math.round(sumOfCharges);
    }

        /*
    renderedCallback() {
        let getStampingCharge = this.template.querySelectorAll(`[data-key='1005'`);
        for(let val of getStampingCharge) {
            val.disabled = true;
        }
    }  
    */

    customMetadataRec() {
        getCustomMetaRecStageProfle()
            .then((result) => {
                this.isloading = false;
                this.stageProfCustmMetaDataRecs = result;
                this.error = undefined;
                let flterRecByLoanStg = this.filterRecByLoanStage(this.stageProfCustmMetaDataRecs);
                if(flterRecByLoanStg.length > 0) {
                    this.showFldsByStageOnUI(flterRecByLoanStg);                  
                }
            })
            .catch((error) => {
                this.isloading = false;
                this.error = error;
                this.stageProfCustmMetaDataRecs = undefined;
                console.log("Error in getLoanAppl-- "+error);
            });
    }
    
    filterRecByLoanStage(stageProfCustmMetaDataRecs) {
        let stageProfCustmMetaRecs = stageProfCustmMetaDataRecs.filter(rec => {
            let loanStage = this.loanApplRec[0].Stage__c;
            if(rec.Loan_Stage__c ===  loanStage && rec.Screen__c === `${loanStage} Charges`) {
                let fields = rec.Fields__c;
                return fields;
            }
        });
        console.log("stageProfCustmMetaRecs--> "+JSON.stringify(stageProfCustmMetaRecs));
        return stageProfCustmMetaRecs;
    }

    showFldsByStageOnUI(flterRecByLoanStg) {
        let fldsArr = flterRecByLoanStg[0].Fields__c.split(",");
        this.visibledFields = fldsArr;
        let getAllLightInp = this.template.querySelectorAll(`[data-id]`);
        for(let lightInp of getAllLightInp) {
            if(fldsArr.includes(lightInp.dataset.id)) {
                let getAllFlds = this.template.querySelectorAll('[data-id="'+lightInp.dataset.id+'"]');
                for(let allFlds of getAllFlds) {
                    allFlds.classList.remove('slds-hide');
                }
            }
        }      
    }

    addDenomination() {
        for(let [index, val] of Object.entries(this.chargesData)) {
            if(val.valueType == "Fixed") {
                this.chargesData[index].rateValueAsPerPolicy = `Rs ${val.rateValueAsPerPolicy}`;
                this.chargesData[index].isActualRateFld = false; 
               // this.showOrHideFld(val.scCode);
            }
            else if(val.valueType == "Percent") {
                this.chargesData[index].rateValueAsPerPolicy = `${val.rateValueAsPerPolicy} %`; 
                this.chargesData[index].isActualRateFld = true;           
            }
        }
    }

  /*  showOrHideFld(scCode) {
       // let getAllLightInp  = this.template.querySelectorAll(`lightning-input[data-key=${scCode}]`);
       let getAllLightInp = this.template.querySelectorAll('[data-key="'+scCode+'"]');
        for(let lightInp of getAllLightInp) {
            if(lightInp.name == "Actual_rate__c") {
                lightInp.classList.add('slds-hide');
            }
        }
    }  */

    handleValuChange(evt) {
       this.calculateCharges(evt);
    }


    calculateCharges(evt, isCalledFirstTime = true) {
        try{
            let fldkey = evt.target.dataset.key;
            let fldVal = Number(evt.detail.value);
            let fldName = evt.target.name;
            let loanAmount = this.loanApplRec[0].Loan_Amount__c;
            for(let [index, val] of Object.entries(this.chargesData)) {
                if(val.scCode === fldkey) {
                    if(val.valueType == "Fixed" && fldName == "Charge_Amount__c") {
                        this.chargesData[index].chargeAmount = fldVal;
                        if(this.chargesData[index].taxApplicable == 'Yes' ){
                            this.chargesData[index].taxAmount = fldVal * val.taxPercentage;
                            this.chargesData[index].totalAmount  = fldVal + this.chargesData[index].taxAmount;
                        }
                        else{
                            this.chargesData[index].totalAmount  = fldVal
                        }
                        this.checkValidation(val, evt);                    
                    }
                    else if(val.valueType == "Fixed" && fldName == "Total_Amount__c"){
                        this.calculateTotalAmount(index, fldVal, val);
                        this.checkValidation(this.chargesData[index], evt);
                    }
                    else if(val.valueType == "Percent" && fldName == "Charge_Amount__c") { 
                        this.chargesData[index].chargeAmount = fldVal;
                        this.chargesData[index].actualRate = this.roundOffTwoDecimalPlace((fldVal/loanAmount) * 100);
                        if(this.chargesData[index].taxApplicable == 'Yes' ){
                            this.chargesData[index].taxAmount = fldVal * val.taxPercentage;
                            this.chargesData[index].totalAmount  = fldVal + this.chargesData[index].taxAmount;
                        }
                        else{
                            this.chargesData[index].totalAmount  = fldVal
                        }
                        //this.chargesData[index].totalAmount = fldVal + ((val.taxAmount/100) * fldVal);
                        this.checkValidation(this.chargesData[index], evt);
                    }
                    else if(val.valueType == "Percent" && fldName == "Total_Amount__c") { 
                        this.calculateTotalAmount(index, fldVal, val);
                        let calculateActualRate = ((this.chargesData[index].chargeAmount)/loanAmount) * 100;
                        this.chargesData[index].actualRate = this.roundOffTwoDecimalPlace(calculateActualRate);
                        this.checkValidation(this.chargesData[index], evt);
                    }
                    else if(val.valueType == "Percent" && fldName == "Actual_rate__c") {
                        this.chargesData[index].actualRate = fldVal;
                        this.chargesData[index].chargeAmount = fldVal/100 * loanAmount;
                        if(this.chargesData[index].taxApplicable == 'Yes' ){
                            this.chargesData[index].taxAmount = this.chargesData[index].chargeAmount * val.taxPercentage;
                            this.chargesData[index].totalAmount  = this.chargesData[index].chargeAmount + this.chargesData[index].taxAmount;
                        }
                        else{
                            this.chargesData[index].totalAmount  = this.chargesData[index].chargeAmount;
                        }
                        this.chargesData[index].chargeAmount = this.roundOffTwoDecimalPlace(this.chargesData[index].chargeAmount);
                        //this.chargesData[index].totalAmount = this.chargesData[index].chargeAmount + ((val.taxAmount/100) * this.chargesData[index].chargeAmount);
                        this.checkValidation(this.chargesData[index], evt);
                    }
                    else if(fldName === 'Agri_and_End_use_of_product_AGRI__c'){ // Tractor Agri Stamping scenario for Tractor
                        this.chargesData[index].agriEndUseOfProduct = evt.target.checked;
                        this.handleStampingChargeChangesAsPerAgri(evt.target.checked);
                    }
                    else if(fldName === 'Udyam_Certificate_Available__c'){ // Commercial Udyam Certificate check 
                        this.chargesData[index].isUdyamCertificateAvailable = evt.target.checked;
                        this.handleStampChangeChangesAsPerCommercial(evt.target.checked);
                    }
                    this.chargesData[index].totalAmount  = this.roundOffTwoDecimalPlace(this.chargesData[index].totalAmount);
                    this.calculateTotalAmtOnConnectedCallb();
                    if(isCalledFirstTime)
                        this.handleMakingStampingExpense(index); // feature for Stamping expense for tractor QDE 
                }
            }
        }
        catch(e){
            console.log('calculateCharges --> ' + e);
        }
    }

    calculateTotalAmount(index, fldVal, val) {
        this.chargesData[index].totalAmount = fldVal;
        if(this.chargesData[index].taxApplicable == 'Yes' ){
            let num = (fldVal)/(1 + val.taxPercentage);  // Formula used- x + 18% of x =  fldVal
            this.chargesData[index].taxAmount = this.roundOffTwoDecimalPlace(num * val.taxPercentage);
            this.chargesData[index].chargeAmount = this.roundOffTwoDecimalPlace(num);  
        }
        else{
            this.chargesData[index].chargeAmount = this.roundOffTwoDecimalPlace(fldVal);  
        }
    }

    roundOffTwoDecimalPlace(numb) {
        let rounded = Math.round((numb + Number.EPSILON) * 100) / 100; // round off two decimal places
        return rounded;
    }

    checkValidation(chargeObj, evt) {
        // For Tractor QDE stamping expense doesn't require any validation
        if(this.isTractorStampingFeatureApplicable() && STAMPING_EXPENSE_SC_CODE.has(evt.target.dataset.key)){
            return;
        }
        let amount, rateValAsperPol;
        let isRaiseDev   = chargeObj.isRaiseDeviation;
        let allowMinValue   = chargeObj.allowMinValue;
        let maxChargeSoc = chargeObj.maxChargesSOC;

        if(chargeObj.valueType == "Fixed") {
            rateValAsperPol = Number(chargeObj.rateValueAsPerPolicy.replace('Rs ', ''));
            amount = chargeObj.chargeAmount;
        }
        else if(chargeObj.valueType == "Percent") {
            rateValAsperPol = Number(chargeObj.rateValueAsPerPolicy.replace(' %', ''));
            amount = chargeObj.actualRate;
            //maxChargeSoc = chargeObj
        }

        if(amount < rateValAsperPol && !isRaiseDev && !allowMinValue) {
            this.throwErrorMessage(chargeObj, `Charge Amount cannot be less than Rate per charge (${rateValAsperPol})`, evt);
            this.storeErrMsgConsoliddted(chargeObj, true);
        }
        else if(amount < rateValAsperPol) {
            chargeObj.isRaiseDeviation = isRaiseDev;
            this.clearErrorMessage(chargeObj, evt);
        }
        else if(amount > maxChargeSoc) {
            this.throwErrorMessage(chargeObj, `Charge Amount cannot be greater than Max Charge SOC (${maxChargeSoc})`, evt);
            this.storeErrMsgConsoliddted(chargeObj, true);
        }

        if(amount <= maxChargeSoc && amount >= rateValAsperPol) {
            this.clearErrorMessage(chargeObj, evt);
            this.storeErrMsgConsoliddted(chargeObj, false);
        }
        else if(maxChargeSoc == undefined && amount >= rateValAsperPol){
            this.clearErrorMessage(chargeObj, evt);
            this.storeErrMsgConsoliddted(chargeObj, false);
        }
        
    }

    throwErrorMessage(chargeObj, errorMessage, evt) {
            let lighInpFld  = this.template.querySelectorAll(`lightning-input[data-key='${chargeObj.scCode}']`);
            for(let input of lighInpFld) {
                if(input.name == 'Charge_Amount__c') { //evt.target.name
                    input.setCustomValidity(errorMessage);
                    input.reportValidity();              
                }
            }                    
    }

    storeErrMsgConsoliddted(chargeObj, isValid) {
        if(this.validateFields.hasOwnProperty(chargeObj.scCode)) {
            this.validateFields[chargeObj.scCode] = isValid;
        }
        else {
            this.validateFields[chargeObj.scCode] = isValid;
        }
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

    clearErrorMessage(chargeObj, evt) {
        let lighInpFld  = this.template.querySelectorAll(`lightning-input[data-key='${chargeObj.scCode}']`);
            for(let input of lighInpFld) {
                if(input.name == 'Charge_Amount__c') { // evt.target.name
                    input.setCustomValidity("");
                    input.reportValidity();
                    this.validateFields.scCode = chargeObj.scCode;
                    this.validateFields.isValid = false;
                }
            } 
    }

    handleSave() {
        restricAccess({
            compName: 'charges' ,loanId: this.recordId
            })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save Charges',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }else{
        if(this.customValidation() && this.inputValidation() && this.isCheckValidity()) {
            console.log("inside handleSave");
            this.submitCharges();              
        }
                }
            })
            .catch(error => {
                console.log('error is ' + error + ' error ' + JSON.stringify(error));
            })
    }

    submitCharges() {
        if(this.chargesData.length > 0) {
            let saveChargesDataArr = [];
            for(let [index, val] of Object.entries(this.chargesData)) {
                saveChargesDataArr[index] = {};
                if(val.hasOwnProperty('Id')) {
                    //saveChargesDataArr[index].Id = val.Id;
                }
                saveChargesDataArr[index].Loan_Application__c          = this.loanApplRec[0].Id;
                if(val.scName.startsWith("Processing Fees")){
                    saveChargesDataArr[index].Charges_Name__c          = "Processing Fees";
                }
                else{
                    saveChargesDataArr[index].Charges_Name__c          =val.scName;
                }
                saveChargesDataArr[index].Master_Name__c               =val.scName;
                saveChargesDataArr[index].SC_Code__c                   =val.scCode;
                saveChargesDataArr[index].External_Id_For_Upsert__c    =val.scCode + this.loanApplRec[0].Id;
                saveChargesDataArr[index].Value_Type__c                =val.valueType;
                saveChargesDataArr[index].Sequence_NO__c               =val.sequenceNO;
                saveChargesDataArr[index].Dedn_Cod__c                  =val.dednCod;
                if(val.valueType == "Fixed") {
                    saveChargesDataArr[index].Rate_value_As_per_Policy__c  = Number((val.rateValueAsPerPolicy).replace('Rs ', ''));
                }
                else {
                    saveChargesDataArr[index].Rate_value_As_per_Policy__c  = Number((val.rateValueAsPerPolicy).replace(' %', ''));
                }               
                saveChargesDataArr[index].Tax_Applicable__c            =val.taxApplicable;
                saveChargesDataArr[index].Tax_Percentage__c            =val.taxPercentage;
                saveChargesDataArr[index].Min_charges__c               =val.minCharges;
                saveChargesDataArr[index].Max_Charges_SOC__c           =val.maxChargesSOC;
                saveChargesDataArr[index].Customer_category            =val.customerCategory;
                saveChargesDataArr[index].Model_Age__c                 =val.modelAge;
                saveChargesDataArr[index].Deviation_Applicable__c      =val.deviationApplicable;
                saveChargesDataArr[index].Shown_to_UI__c               =val.shownToUI;
                saveChargesDataArr[index].Actual_rate__c               =val.actualRate;
                saveChargesDataArr[index].Charge_Amount__c             =val.chargeAmount;
                saveChargesDataArr[index].Tax_Amount__c                =val.taxAmount;
                saveChargesDataArr[index].Total_Amount__c              =Math.round(val.totalAmount);

                if(this.isTractorStampingFeatureApplicable()){ // For saving Stamping expense furture use Tractor QDE
                    saveChargesDataArr[index].Is_Stamping_Charge_Not_Applicable__c  =(!val.isStampingChargeNotApplicable ? false : true);
                    if(saveChargesDataArr[index].Is_Stamping_Charge_Not_Applicable__c){ // For exception case to save previous charges from DB
                        if(STAMPING_CHARGE_SC_CODE.has(val.scCode)){
                            saveChargesDataArr[index].Source_Stamping_Charge_Save__c = JSON.stringify(this.existingStampingChargeBeforeChange);
                        }
                        if(STAMPING_EXPENSE_SC_CODE.has(val.scCode)){
                            saveChargesDataArr[index].Source_Stamping_Charge_Save__c = val.sourceStampExpenseSave;
                        }
                    }
                    else if(STAMPING_CHARGE_SC_CODE.has(val.scCode) && !val.agriEndUseOfProduct){
                        this.existingStampingChargeBeforeChange.actualRate = val.actualRate;
                        this.existingStampingChargeBeforeChange.chargeAmount = val.chargeAmount;
                        this.existingStampingChargeBeforeChange.taxAmount = val.taxAmount;
                        this.existingStampingChargeBeforeChange.totalAmount = val.totalAmount;
                        saveChargesDataArr[index].Source_Stamping_Charge_Save__c = JSON.stringify(this.existingStampingChargeBeforeChange);
                    }
                    else if(STAMPING_CHARGE_SC_CODE.has(val.scCode) && val.agriEndUseOfProduct){
                        saveChargesDataArr[index].Source_Stamping_Charge_Save__c = JSON.stringify(this.existingStampingChargeBeforeChange);
                    }
                    else if(STAMPING_EXPENSE_SC_CODE.has(val.scCode)){
                        saveChargesDataArr[index].Source_Stamping_Charge_Save__c = val.sourceStampExpenseSave;
                    }
                    saveChargesDataArr[index].Agri_and_End_use_of_product_AGRI__c  =(val.agriEndUseOfProduct);
                }

                if(this.isCommercialUdyamCertificateFeatureApplicableWithException){ // For saving stamp charges for future use Commercial
                    if(STAMPING_CHARGE_SC_CODE.has(val.scCode)){
                        saveChargesDataArr[index].Udyam_Certificate_Available__c  =(!val.isUdyamCertificateAvailable ? false : true);
                        const sourceStampChargeObj = JSON.parse(val.sourceStampExpenseSave);
                        sourceStampChargeObj.currentData = {
                            actualRate : val.actualRate,
                            chargeAmount : val.chargeAmount,
                            taxAmount : val.taxAmount,
                            totalAmount : val.totalAmount
                        }
                        if(!saveChargesDataArr[index].Udyam_Certificate_Available__c){
                            sourceStampChargeObj.masterData = {
                                actualRate : val.actualRate,
                                chargeAmount : val.chargeAmount,
                                taxAmount : val.taxAmount,
                                totalAmount : val.totalAmount
                            }
                        }
                        saveChargesDataArr[index].Source_Stamping_Charge_Save__c = JSON.stringify(sourceStampChargeObj);
                    }
                    
                }

            }
            saveCharges({ chargeList: saveChargesDataArr })
            .then((result) => {
                 let status = result.message;
                 if(status == 'success') {
                    const payload = { recordIdOfSobject: this.loanApplRec[0].Id, refreshPage: 'Yes' };
                    publish(this.messageContext, pageRefreshOnMaterialFieldChange, payload);
                    this.showToastMessage('Success', '', 'success', 'dismissible');
                    this.disableFldAndBttn = true;
                    this.disableEditBttn   = false;
                    const Obj = {};
                    this.errorOnChild = '';
                    Obj.errorOnChild = this.errorOnChild;
                    Obj.next = this.errorOnChild == '' ? true : false;
                    console.log('Obj', Obj);
                    this.dispatchEvent(new CustomEvent('next', {
                        detail: Obj
                    }));
                 }
                 else {
                    this.showToastMessage('Error', status, 'error', 'sticky');
                 }
                this.error = undefined;
            })
            .catch((error) => {
                this.error = error;
                this.showToastMessage('', error.body?.message ?? 'Unable to save charges', 'error', 'sticky');
                console.log("Error inside saveCharges  "+error);
            });
        } else{
            let loanObj = {Id: this.recordId, Total_Charges__c:0}
            const fields = loanObj;
            const recordInput = {fields}
              const Obj = {};
                    this.errorOnChild = '';
                    Obj.errorOnChild = this.errorOnChild;
                    Obj.next = this.errorOnChild == '' ? true : false;
                    console.log('Obj', Obj);
                    this.dispatchEvent(new CustomEvent('next', {
                        detail: Obj
                    }));
            updateRecord(recordInput).then((data)=>{
                const payload = { recordIdOfSobject: this.loanApplRec[0].Id, refreshPage: 'Yes' };
                publish(this.messageContext, pageRefreshOnMaterialFieldChange, payload);
                this.showToastMessage('Success', '', 'success', 'dismissible'); 
              
            }).catch((error)=>{
                this.showToastMessage('Error','Error updating record', 'error', 'sticky');
            })
        } 
    }

    handleEdit() {
        this.disableEditBttn = true;
        this.disableFldAndBttn = false;

        // Handle Tractor scenarios
        if(this.isTractorStampingFeatureApplicable()) {
            setTimeout(() => {
                // Making stamping expense disabled
                for(let i of STAMPING_EXPENSE_SC_CODE){
                    for(let input of this.template.querySelectorAll(`[data-key="${i}"]`)){
                        if(input && input.name && DISABLE_ENABLE_FIELDS.has(input.name)){
                            input.disabled = true;
                        }
                        
                    }
                }

                // Making stamping charge disabled depending on agriUsage
                if(this.chargesData){
                    for(let [index,i] of this.chargesData.entries()){
                        if(STAMPING_CHARGE_SC_CODE.has(i.scCode)){
                            if(i.agriEndUseOfProduct){
                                for(let i of STAMPING_CHARGE_SC_CODE){
                                    for(let input of this.template.querySelectorAll(`[data-key="${i}"]`)){
                                        if(DISABLE_ENABLE_FIELDS.has(input.name)){
                                            input.disabled = true;
                                        }
                                        
                                    }
                                }
                                break;
                            }
                        }
                    }
                }
                
            });
        }
        
        // Handle Tractor scenarios
    }

    customValidation() {
        for(let key in this.validateFields) {
            if(this.validateFields[key] == true) {
                return false;
            }
        }
        return true;
    }

    inputValidation() {
        let isValid = true;
        let visibledFieldList = this.visibledFields;
        console.log('visibledFieldList '+JSON.stringify(visibledFieldList));
        let inputFields = this.template.querySelectorAll(".validate");
        inputFields.forEach(inputField => {
            if (!inputField.value && visibledFieldList.includes(inputField.name)) {
                inputField.setCustomValidity("Complete this field");
                inputField.reportValidity();
                isValid = false;
            }
        });

        console.log('isValid>> '+isValid)
        return isValid;
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

    @api async nextHandler() {
     
        if(this.isEditRestricted){
            this.showToastMessage('Access Restricted', 'Charges were not saved due to Insufficient Access Rights', 'warning', 'sticky');
            const Obj = {};
            Obj.next = true; 
            this.dispatchEvent(new CustomEvent('next', {
                detail: Obj
            })); 
        }
        else{
            const Obj = {};
            //SFAU-5147 || START 
            let proceedNext = true;
            let result = await chargesHandler({ loanApplId: this.recordId });
            let loanRecord = result.loanApplList;
            if(loanRecord && loanRecord.length>0 && result.chargesList.length > 0 && result.chargesList[0].Id){
                if( loanRecord[0].isLoanAmtChanged__c == true){
                    this.showToastMessage('Error','Loan amount modified please refresh the charges', 'Error', 'dismissible');
                    proceedNext = false;
                }
            }

            if(proceedNext){
               this.handleSave()
            }
            // END
            //Obj.applicantRecord = this.applicantIdInput;
            /*this.errorOnChild = '';
            Obj.errorOnChild = this.errorOnChild;
            Obj.next = this.errorOnChild == '' ? true : false;
            console.log('Obj', Obj);
            this.dispatchEvent(new CustomEvent('next', {
                detail: Obj
            }));*/

        }
    }

    refreshData(){
        this.generateData();
        this.setAmtBoolean();
    }
    setAmtBoolean(){
        let loanObj = {Id: this.recordId, isLoanAmtChanged__c:false}
        const fields = loanObj;
        const recordInput = {fields}
        updateRecord(recordInput).then((data)=>{
          console.log('loanAmountBoolean set to default');
        }).catch((error)=>{
            console.log('error in update');
            //this.showToastMessage('Error','Error updating record', 'error', 'sticky');
        })
    }

}