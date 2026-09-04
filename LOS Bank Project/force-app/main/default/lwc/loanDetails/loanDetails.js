import { LightningElement, track, wire, api } from 'lwc';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues, getObjectInfo,getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import LOAN_APPLICATION_OBJECT from '@salesforce/schema/Loan_Application__c'
import getBankMasterRecords from '@salesforce/apex/LoanDetailsController.getBankMasterRecords';
import EMI_FIELD from '@salesforce/schema/Loan_Application__c.EMI__c';
import getVisibleFieldsForLoanDetails from '@salesforce/apex/LoanDetailsController.getVisibleFields';
import ID from '@salesforce/schema/Loan_Application__c.Id'
import getDetails from '@salesforce/apex/LoanDetailsController.getDetails';
import callEMIScheduleAPI from '@salesforce/apex/EMIScheduleAPIController.callEMIScheduleAPI' 
import refetchEMI from '@salesforce/apex/EMIScheduleAPIController.refetchEMI' 
import getLatestEmiSchedule from '@salesforce/apex/EMIScheduleAPIController.getLatestEmiSchedule' 
import getPDFData from '@salesforce/apex/EMIScheduleAPIController.getPDFData' 
import { getSpinnerImage } from 'c/customSpinner';
import {NavigationMixin} from 'lightning/navigation';
import markDataInactive from '@salesforce/apex/LoanDetailsController.markDataInactive';
import getBankRecords from '@salesforce/apex/LoanDetailsController.getBankRecords';
import getBankName from '@salesforce/apex/LoanDetailsController.getBankName';
import getApplicants from '@salesforce/apex/LoanDetailsController.getApplicants';
import getApplicantBankAccountRecords from '@salesforce/apex/LoanDetailsController.getApplicantBankAccountRecords';
import updateLoanApp from '@salesforce/apex/LoanDetailsController.updateLoanApp';
import getMaterialFields from '@salesforce/apex/Utility.getMaterialFields';
import checkMaterialFields from '@salesforce/apex/Utility.checkMaterialFields'
import { notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import { registerRefreshHandler, unregisterRefreshHandler } from 'lightning/refresh';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import getMICRCode from '@salesforce/apex/LoanDetailsController.getMICRCode';
import panVerification from '@salesforce/apex/LoanDetailsController.panVerification';
// Tractor Validation feature
const RANGE_INSERT_ERROR_MESSAGE = '{rangeInsert}';
import COW_SUB_PRODUCT_NAMES from '@salesforce/label/c.COW_Product_Names'

import getTractorValidations from '@salesforce/apex/LoanDetailsController.getTractorValidations';
// Tractor Validation feature

// Tractor Loan Details New Field Features
import getSchemePickListValues from '@salesforce/apex/LoanDetailsController.getSchemePickListValues';
import updateRevisitScreen from '@salesforce/apex/LoanDetailsController.updateRevisitScreen';
// Tractor Loan Details New Field Features

// EMI Calculation for Tractor
const QUARTERLY_EMI_CALCULATION_LITERAL = 'QUARTERLY';
const HALF_YEARLY_EMI_CALCULATION_LITERAL = 'HALF YEARLY';
// EMI Calculation for Tractor

// Tractor Loan Details at QDE Stage
const TRACTOR_RECORD_TYPE_DEVELOPER_NAME = 'Tractor';
// Tractor Loan Details at QDE Stage

// Schedule Name selection
const SCHEDULE_NAME_EQUATED = 'equated';
// Schedule Name selection

// Tractor applicability check scenaior
const RECORD_TYPE_CHECK_SCENARIO = 'RecordType';
const RECORD_TYPE_CHECK_SCENARIO_WITHOUT_STAGE = 'RecordTypeWithoutStage';
const QDE_STAGE_LITERAL = 'QDE';
const NON_MANDATE_FIELD = new Set(['EMI_Date__c', 'First_EMI_Date__c']);
// Tractor applicability check scenaior

// Tractor related error Message
import LOAN_DETAIL_ERROR_MESSAGE_ON_LAND_DETAIL_CHANGE from '@salesforce/label/c.Loan_Details_Error_Message_on_Land_Details_change';

//EMI disclaimer message
import LOAN_DETAILS_EMI_DISCLAIMER from '@salesforce/label/c.Loan_Details_EMI_disclaimer';

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

export default class LoanDetails extends NavigationMixin(LightningElement) {

  //  @wire(MessageContext)
    messageContext = createMessageContext();
    @track displaySaveButton=false
    initialLoanAmount;
    @api
    spinnerImage;
    isLoading;
    breReRunFields = [];
    roiLabel='Applied ROI'
    btCaseType=''
    callEMIAPI=false
    emiAPIVariablesList = ['Tenure__c','Loan_Amount__c','ROI__c','EMI_Date__c','First_EMI_Date__c','Emi_Frequency__c','Repayment_Start_Date__c','Schedule_Name__c'];
    isRequired=true
    @track emiFrequencyOptions=[]
    fileUrl=''
    disbursementCategoryDisabled=false
    requiredAtDDE=false
    @track emiDateOptions=[]
    @api visibleFields=[]
    @track displayBTSection=false
    disableRepaymentStartDate=false
    excludeFieldList = ['Name','Applicants__r','Collaterals__r','Total_Charges__c','Wheels_Exposure__c','Total_Exposure__c','RecordTypeId','Dealer_Master__c','Dealer_Master__r.IRR__c','Scheme__r','Branch_Master__r','Risk_Base_Pricing__c'];
    @track repaymentAccountTypeOptions = [{label:'Current Account' ,value:'CA' },{label:'Savings Bank' ,value:'SB' }];
    applicationFieldsToBeUpdated;
    addNominee=false
    @track bankRecordId
    showTrancheSection=false;
    recordTypeId
    @track loanApp={}
    @track productOptions;
    @track calculatedEMI;
    @track Scheme__c
    @api recordId;
    @api insideRecordPage = false;
    rateChartCodes=[]
    twoWheelerExposure=false
    fourWheelerExposure=false
    totalExposure=''
    readOnly=false
    displayEdit=false
    rangeMap = new Map();
    loanAmountUnderFlowError
    loanAmountOverFlowError
    ROIUnderFlowError
    ROIOverFlowError
    tenureUnderFlowError
    tenureOverFlowError
    minLoanAmount;
    maxLoanAmount;
    minTenure
    maxTenure
    minROI
    maxROI
    visitedCustomerPDOptions;
    isCustomerVisitForPDMandatory = false;
    loan;
    objectInfo;
    errorOnChild;
    sliderChange = false;
    boolHideCalculateEMI = true;
    @track scheduleNameOptions=[]
    scheduleRecords=[]
//SFAU-5343
    isBTTypeRequired = false;
    @api showSave
    @track isIOI=false
    @track isVPI=false
    @track showTable=false
    breReRun=false
    @track productDetails=new Map
    @track isBTInternal=false
    @track isBTExternal=false
    @track promocodeOptions=[]
    @track collateralDetails=[]
    @track bankName='';
    @track applicantList = [];
    @track repaymentByValue;
    @track repaymentByAppl;

    @track bankNameReadOnly=false
    loadIt=false
    bankRecordsList=new Map();
    @track allRepaymentModeOptions=[];
    @track repaymentBankNameOptions=[]
    bankAccountRecordsSI = [];
    fieldsToBeDisabled=[]
    hideSliders=false
    stages = ['PSD','Ops Maker','Ops Author','PDD']
    @track isDisbursementStage
    @track applicantPANVerificationList
    @track showPANVerificationModal
    r2LoanRecordTypes = ['Tractor','Commercial Vehicle','Construction Equipment']
    @track displayExposureFields=false //R2-2468
    // Tractor Validation variables
    metadataConfigTractorValidationList = [];
    isConfigLoaded = false;
    // Tractor Validation variables

    cowSubProducts = COW_SUB_PRODUCT_NAMES
    // Scheme selection variables for Tractor
    schemeOption = [];
    // Scheme selection variables for Tractor

    // Schedule options for Tractor QDE
    scheduleOptions = [];
    // Schedule options for Tractor QDE

    // Tractor QDE Charges Map
    chargeMapTractorQDE = new Map();
    isPreviousSelectedSchemeNotApplicable = false;
    // Tractor QDE Charges Map

    //EMI disclaimer message
    LOAN_DETAILS_EMI_DISCLAIMER = LOAN_DETAILS_EMI_DISCLAIMER;
    //EMI disclaimer message

    //EMI disclaimer message
    get showEMIDisclaimerMsg(){
        return this.loanApp.Stage__c === QDE_STAGE_LITERAL && (
            this.loanApp.Emi_Frequency__c === QUARTERLY_EMI_CALCULATION_LITERAL || this.loanApp.Emi_Frequency__c === HALF_YEARLY_EMI_CALCULATION_LITERAL
        );
    }
    //EMI disclaimer message
    
    // Tractor validation getting metadata config
    @wire(getTractorValidations)
    metadataConfigTractorValidation({error,data}){
        if(error){
            this.showToastMessage('Error','Something went wrong in fetching metadata config for Tractor validation ' + JSON.stringify(error),'error', 'sticky')
        }
        if(data){
            this.metadataConfigTractorValidationList = data;
            this.isConfigLoaded = true;
        }

    }
    // Tractor validation getting metadata config
   

    // Check if this is applicable for tractor scenario
    get applicableTractorQdeUIChange(){
        return this.handleCheckIfApplicableForTractorScenario(RECORD_TYPE_CHECK_SCENARIO);
    }

    handleCheckIfApplicableForTractorScenario(context){
        
        if(context === RECORD_TYPE_CHECK_SCENARIO){
            if(this.loanApp && this.loanApp.RecordType){
                return this.loanApp.RecordType.DeveloperName === TRACTOR_RECORD_TYPE_DEVELOPER_NAME
                && this.loanApp.Stage__c === QDE_STAGE_LITERAL;
            }
            return false;
        }
        if(context === RECORD_TYPE_CHECK_SCENARIO_WITHOUT_STAGE){
            if(this.loanApp && this.loanApp.RecordType){
                return this.loanApp.RecordType.DeveloperName === TRACTOR_RECORD_TYPE_DEVELOPER_NAME;
            }
            return false;
        }
        return false;
    }
    // Check if this is applicable for tractor scenario

    

    // fetching schemes for tractors 
    async handleFetchSchemesForTractorScenario(){
        this.isLoading=true;
        try{
            let schemesResp = await getSchemePickListValues(
                {
                    loanApp : this.loanApp,
                    app : this.loanApp.Applicants__r[0],
                    category : this.loanApp.Collaterals__r[0].Vehicle_Category__c,
                    collCode : this.loanApp.Collaterals__r[0].Collateral_Name__c,
                }
            );
            if(schemesResp && schemesResp.schemeValues && schemesResp.schemeValues.fullChargeRecord && schemesResp.schemeValues.fullChargeRecord[0] && schemesResp.schemeValues.fullChargeRecord[0].value){ // Assigning Map by charges
                this.handleMapChargesForTractors(schemesResp.schemeValues.fullChargeRecord[0].value);
            }
            
            this.schemeOption = schemesResp.schemeValues.Scheme;
        }
        catch(e){
            console.log('Something went wrong in fetching schemes ' + e + ' JSON ' + JSON.stringify(e));
            this.showToastMessage('Error','Something went wrong in fetching schemes ' + e + ' JSON ' + JSON.stringify(e) ,'error', 'sticky');
        }
        this.isLoading=false;
    }
    // fetching schemes for tractors

    // Arrange charges into map for tractors
    handleMapChargesForTractors(fullChargeMaster){
        try{
            const chargeMaster = JSON.parse(fullChargeMaster);
            for(let i in chargeMaster){
                this.chargeMapTractorQDE.set(i, chargeMaster[i]);
            }
            this.isSchemeApplicable();
        }
        catch(e){
            this.showToastMessage('Error','Something went wrong in converting string into JSON ' + e ,'error', 'sticky');
        }
    }
    // Arrange charges into map for tractors

    // Check if land details got changed
    isSchemeApplicable(){
        if(this.loanApp.Scheme__c!=null && !this.chargeMapTractorQDE.has(this.loanApp.Scheme__c)){
            this.loanApp.Scheme__c = null;
            this.Scheme__c = null;
            this.isPreviousSelectedSchemeNotApplicable = true;
            this.showToastMessage('Info',`${LOAN_DETAIL_ERROR_MESSAGE_ON_LAND_DETAIL_CHANGE}` ,'error', 'sticky');
        }
    }
    // Check if land details got changed

    checkIsBT(value){
        this.isBTInternal= value === 'Internal'?true:false
        this.isBTExternal= value === 'External'?true:false
    }

    

    openVFPageForEMI(content){
        if(content && content.ContentDocumentId){
            var docId = content.ContentDocumentId
            this.callEMIAPI = false
            //EMI Amount mismatch - Neha
            const fields= {Id: this.loanApp.Id, ReTrigger_EMI_Schedule__c:false};
            const recordInput = {fields}
            updateRecord(recordInput).then((data)=>{
            }).catch((error)=>{
            })
            // let todaysDate = new Date()
            // if(this.loanApp.EMI_Date__c && todaysDate.getDate()<parseInt(this.loanApp.EMI_Date__c)){
            //     let newDate = todaysDate.getFullYear() + '-' + (todaysDate.getMonth()+1).toString().padStart(2, '0') + '-' + this.loanApp.EMI_Date__c.padStart(2, '0');
            //     this.loanApp.First_EMI_Date__c = newDate
            // }else{
            //     let newDate = todaysDate.getFullYear() + '-' + (todaysDate.getMonth()+2).toString().padStart(2, '0') + '-' + this.loanApp.EMI_Date__c.padStart(2, '0');
            //     this.loanApp.First_EMI_Date__c = newDate
            // }
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state : {
                    recordIds: docId,
                    selectedRecordId: docId
                }
            })
        }else{
            this.showToastMessage('Error','No EMI Schedule Found','error', 'sticky');
        }
    }

    handleContext(event){
        if(this.loanApp.Stage__c=='Ops Author'){
            event.preventDefault(); 
        }
    }

    handlePaste(event){
        if(this.loanApp.Stage__c=='Ops Author'){
            event.preventDefault(); 
        }
    }

    handleEMIApi(){
        this.isLoading=true
        if(this.callEMIAPI){
            callEMIScheduleAPI({loanApp: this.loanApp}).then((data)=>{
                this.isLoading=false
                if(data.includes('API Error')){
                    this.showToastMessage('Error',data,'error','sticky')
                    return
                }
                refetchEMI({loanId: this.loanApp.Id}).then((data=>{
                    this.loanApp.EMI__c = Math.round(data);
                }))
                //this.showToastMessage('Success','EMI Schedule Generated Successfully','success')
                getPDFData({loanApp: this.loanApp, refId:data, masterName:'EMI Schedule'}).then((data=>{
                    this.openVFPageForEMI(data)
                }))
            }).catch((error)=>{
                this.isLoading=false;
                let errMsg = '';                    
                if (error && error.body && error.body.message) {
                    errMsg = error.body.message;
                } 
                console.log('errMsg: '+errMsg);
                this.showToastMessage('Error','We Encountered an Error while Processing Your Request','error','sticky')
            })
        }else{
            getLatestEmiSchedule({loanApp: this.loanApp, masterName:'EMI Schedule'}).then((data)=>{
                this.isLoading=false
                if(!data || !data.ContentDocumentId){
                    this.isLoading=true
                    callEMIScheduleAPI({loanApp: this.loanApp}).then((data)=>{
                        this.isLoading=false
                        if(data.includes('API Error')){
                            this.showToastMessage('Error',data,'error','sticky')
                            return
                        }
                        refetchEMI({loanId: this.loanApp.Id}).then((data=>{
                            this.loanApp.EMI__c = Math.round(data);
                        }))
                        //this.showToastMessage('Success','EMI Schedule Generated Successfully','success')
                        getPDFData({loanApp: this.loanApp, refId:data, masterName:'EMI Schedule'}).then((data=>{
                            this.openVFPageForEMI(data)
                        }))
                    }).catch((error)=>{
                        this.isLoading=false
                        this.showToastMessage('Error','We Encountered an Error while Processing Your Request','error', 'sticky')
                    })
                }else{
                    this.openVFPageForEMI(data)
                }
                //this.showToastMessage('Success','EMI Schedule Generated Successfully','success')
                //this.openVFPageForEMI(data)
            }).catch((error)=>{
                this.isLoading=false
                this.showToastMessage('Error','We Encountered an Error while Processing Your Request','error', 'sticky')
            })
        }
        
    }

    /*get mclrData(){
        return [
            {'mclrTenure': '3 Months', 'mclrPercent':8.6, 'tenure':'1-3 Months', 'irrBelow':'Variable', 'irrAbove':'Fixed','deviationApplicable':'No'},
            {'mclrTenure': '6 Months', 'mclrPercent':9.1, 'tenure':'4-6 Months', 'irrBelow':'Variable', 'irrAbove':'Fixed','deviationApplicable':'No'},
            {'mclrTenure': '1 Year', 'mclrPercent':10.1, 'tenure':'7-12 Months', 'irrBelow':'Variable', 'irrAbove':'Fixed','deviationApplicable':'No'},
            {'mclrTenure': '2 Year', 'mclrPercent':10.45, 'tenure':'13-24 Months', 'irrBelow':'Variable', 'irrAbove':'Fixed','deviationApplicable':'No'},
            {'mclrTenure': '3 Year', 'mclrPercent':10.45, 'tenure':'25-36 Months', 'irrBelow':'Variable', 'irrAbove':'Fixed','deviationApplicable':'No'},
            {'mclrTenure': 'Above 36 Months', 'mclrPercent':10.45, 'tenure':'Above 36 Months', 'irrBelow':'Fixed', 'irrAbove':'Fixed','deviationApplicable':'No'}
        ];
    }

    get columns(){
        return [
            { label: 'MCLR Tenure', fieldName: 'mclrTenure', type:'text', initialWidth:150, 
                cellAttributes:{
                    class:"slds-text-body_small"
                } 
            },
            { label: 'MCLR %', fieldName: 'mclrPercent', type:'decimal',initialWidth:115,
                cellAttributes:{
                    class:"slds-text-body_small"
                } 
            },
            { label: 'IRR <= MCLR%', fieldName: 'irrBelow', type:'text',initialWidth:165,
                cellAttributes:{
                    class:"slds-text-body_small"
                } 
            },
            { label: 'IRR > MCLR%', fieldName: 'irrAbove', type:'text',initialWidth:160,
                cellAttributes:{
                    class:"slds-text-body_small"
                } 
            },
            { label: 'Deviation', fieldName: 'deviationApplicable', type:'text',initialWidth:123,
                cellAttributes:{
                    class:"slds-text-body_small"
                }  
            }
        ]
    }

    handlePreview(){
        if(this.showTable){
            this.showTable=false
        }else{
            this.showTable=true
        }
    }*/

    nomineeNetPercentValidationSuccess=true
    handleEvents(event){
        if(event.detail.template ==='Nominee'){
            if(event.detail.isUnsaved){
                this.showToastMessage('Error','Please Save all the Nominees before Proceeding','error', 'sticky');
                this.nomineeNetPercentValidationSuccess=false
            }else if(event.detail.value!=100){
                this.showToastMessage('Error','Total Share for Nomination for all Nominees should add upto 100%','error', 'sticky');
                this.nomineeNetPercentValidationSuccess=false
            }else{
                this.nomineeNetPercentValidationSuccess=true
            }
        }
        
    }    

    closeLoanDetails(){
        this.readOnly=true;
        this.bankNameReadOnly=true
        this.displayEdit=true
    }

    async connectedCallback(){
        
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.recordId);
        }
        this.isLoading=true;
        if(this.showSave){
            this.displaySaveButton=true
        }
        this.getLoanDetails();
        this.setIsEditRestricted();
    }

    async setIsEditRestricted(){
        this.isEditRestricted = await restricAccess({compName: 'loanDetails' ,loanId: this.recordId})
    }

    /*calculateFlatROI(){
        this.loanApp.Loan_Amount__c = parseInt(this.loanApp.Loan_Amount__c)
        this.loanApp.ROI__c = parseFloat(this.loanApp.ROI__c)
        this.loanApp.Tenure__c = parseFloat(this.loanApp.Tenure__c)
        this.loanApp.Total_Loan_Amount__c = parseFloat(this.loanApp.Total_Loan_Amount__c)
        let receivableAmt = this.loanApp.Loan_Amount__c+(this.loanApp.Loan_Amount__c*(this.loanApp.ROI__c/100)*(this.loanApp.Tenure__c/12))
        this.loanApp.Flat_ROI__c = ((receivableAmt-this.loanApp.Total_Loan_Amount__c)/this.loanApp.Total_Loan_Amount__c);
        this.loanApp.Flat_ROI__c = (this.loanApp.Flat_ROI__c *100).toFixed(2)
    }

    calculateROIForFlatROI(){
        //this.loanApp.Flat_ROI__c = parseFloat(this.loanApp.Flat_ROI__c).toFixed(2)
        this.loanApp.ROI__c = (parseFloat(this.loanApp.Flat_ROI__c*1.81)).toFixed(2)
        this.sliderChange=true
    }*/

    calculateTypeOfRate(){

        var mclrPercent
        if(this.loanApp.Tenure__c>=1 && this.loanApp.Tenure__c<=3){
            mclrPercent=8.6
        }else if(this.loanApp.Tenure__c>=4 && this.loanApp.Tenure__c<=6){
            mclrPercent=9.1
        }else if(this.loanApp.Tenure__c>=7 && this.loanApp.Tenure__c<=12){
            mclrPercent=10.1
        }else if(this.loanApp.Tenure__c>=13 && this.loanApp.Tenure__c<=24){
            mclrPercent=10.45
        }else if(this.loanApp.Tenure__c>=25 && this.loanApp.Tenure__c<=36){
            mclrPercent=10.45
        }
        if(this.loanApp.ROI__c<=mclrPercent){
            this.loanApp.Type_of_Rate__c='Variable'
        }else{
            this.loanApp.Type_of_Rate__c='Fixed'
        }
        if(this.loanApp.Tenure__c>36){
            mclrPercent=10.45
            this.loanApp.Type_of_Rate__c='Fixed'
        }

        this.rateChartCodes.forEach(input=>{
            if((input.Rate_Type__c).toUpperCase() == (this.loanApp.Type_of_Rate__c).toUpperCase()){
                this.loanApp.Rate_Chart_Code__c = input.Id
            }

        })
    }

    getVisibleFields(stage){
        let typeOfWheeler;
        if(stage == 'Credit' && this.isTwoWheeler){
            typeOfWheeler ='Two Wheeler';
        }else if(stage == 'Credit' && this.isFourWheeler){
            typeOfWheeler ='Four Wheeler';
        }
        
        if(this.handleCheckIfApplicableForTractorScenario(RECORD_TYPE_CHECK_SCENARIO)){
            typeOfWheeler = TRACTOR_RECORD_TYPE_DEVELOPER_NAME;
        }
        getVisibleFieldsForLoanDetails({ strScreen :'Loan Details', strStage :stage, strProfile :'',vehicleType : typeOfWheeler  })
        .then(result => {
            console.log('result is '+JSON.stringify(result));
            result.forEach(input => {
                if(input != 'EMI__c' || stage != 'QDE'){
                    this.template.querySelectorAll('[data-id="'+input+'"]').forEach(element =>{
                        element.classList.remove('slds-hide');
                        if(!this.applicableTractorQdeUIChange || (this.applicableTractorQdeUIChange && !NON_MANDATE_FIELD.has(input)))
                            element.classList.add('validate');
                    })
                    this.template.querySelectorAll('[data-name="'+input+'"]').forEach(element =>{
                        if(!this.applicableTractorQdeUIChange || (this.applicableTractorQdeUIChange && !NON_MANDATE_FIELD.has(input)))
                            element.classList.add('validate');
                    })
                }
            });
            this.visibleFields=result
            if(this.visibleFields.includes('EMI_Date__c') && (!this.emiDateOptions || this.emiDateOptions.length==0)){
                this.showToastMessage('Warning','We could not find EMI Date Options','warning', 'sticky')
            }
          //  this.setReadOnlyIfNeeded(stage,typeOfWheeler);
            this.disableFieldsAsPerMetadata()
            
        })
        .catch(error => {
            console.log('result is '+error);
        })

    }

    setReadOnlyIfNeeded(stage,typeOfWheeler){
        getUserScreenEditAccess({ strScreen :'Loan Details', strStage :stage, strProfile :'',vehicleType : typeOfWheeler  })
        .then(result => { 
            if(!result){
                this.visibleFields.forEach(input => {
                    this.template.querySelectorAll('[data-id="'+input+'"]').forEach(element =>{
                        element.readOnly = true;
                    })
                })
            }
        })
        .catch(error => {
            console.log('result is '+error);
        })
    }

    //R2-2045
    setEMIDateOptions(emiDates){
        let list=[]
        if(emiDates){
            emiDates.split(',').forEach(dateValue=>{
                //var newDate = parseInt(dateValue)
                list.push({label:dateValue, value:dateValue})
            })
            this.emiDateOptions=list
            if(this.emiDateOptions && this.emiDateOptions.length==1){
                this.loanApp.EMI_Date__c=this.emiDateOptions[0].value
            }
        }
    }

//    getUserScreenEditAccess

    bankAccountRecords;
    workWithLoanDetails(data){
        if(this.stages.includes(this.loanApp.Stage__c)){
            this.isDisbursementStage = true //SFAU-3086
        }
        if(this.loanApp.Stage__c === 'Credit' || this.loanApp.Stage__c === 'Pricing'){
            //this.showSave=true
            this.displaySaveButton=true
        }
        if(this.loanApp.Stage__c === 'Ops Author' || this.loanApp.Stage__c==='Ops Maker'){
            this.hideSliders=true
        }
        //EMI Amount mismatch - Neha
        if(this.loanApp.ReTrigger_EMI_Schedule__c){
            this.callEMIAPI=true
        }
        //this.sliderChange = true;
        this.loanApp.Loan_Amount__c = parseInt(this.loanApp.Loan_Amount__c).toFixed(0)
        this.initialLoanAmount = this.loanApp.Loan_Amount__c 
        //this.loanApp.Loan_Amount__c = this.loanApp.Loan_Amount__c?this.loanApp.Loan_Amount__c.toFixed(0):0;
        this.loanApp.Tenure__c = this.loanApp.Tenure__c?this.loanApp.Tenure__c:0;
        this.loanApp.EMI__c = this.loanApp.EMI__c?this.loanApp.EMI__c:0
        if(this.loanApp.Stage__c=='QDE'){
            this.recordTypeId = this.loanApp.RecordTypeId
        }
        if(this.loanApp.Stage__c=='QDE' && !this.loanApp.Total_Loan_Amount__c){
            this.loanApp.Total_Loan_Amount__c=parseFloat(this.loanApp.Loan_Amount__c)
        }
        if(this.loanApp.EMI__c && this.loanApp.EMI__c >= 0){
            if(this.insideRecordPage){
                this.readOnly=true
                this.bankNameReadOnly=true
                this.displayEdit=true
            }
            this.loanApp.ROI__c = this.loanApp.ROI__c?this.loanApp.ROI__c:0;
        }else{
            this.readOnly=false
            this.bankNameReadOnly=false
            this.displayEdit=false
            
        }
        if(this.loanApp.RecordType.DeveloperName=='Two_Wheeler'){
            this.roiLabel = 'Final ROI'
            /*this.template.querySelector('[data-id="Flat_ROI__c"]').classList.remove('slds-hide')
            this.template.querySelectorAll('[data-name="Flat_ROI__c"]').forEach(input=>{
                input.classList.add('validate')
            })
            if(!this.loanApp.Flat_ROI__c){
                this.calculateFlatROI()
            }*/
            //this.calculateROIForFlatROI()        
        }
        //if(this.loanApp.Stage__c=='QDE'){ // By Kunal - SFAU-5578 
            let promoCodeMaster= data.promocodes;
            let promolist=[]
            if(promoCodeMaster && promoCodeMaster.length>0){
                promoCodeMaster.forEach(promo=>{
                    promolist.push({label:promo.Promo_Name__c,value:promo.Id})
                })
            }
            this.promocodeOptions = promolist
        //}    
        
        
        data.productDetails.forEach(prod=>{
            if(prod.Product__c == this.loanApp.Product__c){
                if(!this.loanApp.ROI__c && prod.RecordType__c === 'Two Wheeler' && this.loanApp.Dealer_Master__c && this.loanApp.Dealer_Master__r.IRR__c){
                    this.loanApp.ROI__c = this.loanApp.Dealer_Master__r.IRR__c
                }else{
                    this.loanApp.ROI__c = this.loanApp.ROI__c?this.loanApp.ROI__c:0;
                }
                if(this.r2LoanRecordTypes.includes(prod.RecordType__c)){
                    this.displayExposureFields = true
                }
                
                if(prod.RecordType__c === 'Four Wheeler'){
                    this.fourWheelerExposure = true;

                    //if(this.loanApp.Stage__c=='DDE' || this.loanApp.Stage__c=='Credit'){
                    if(this.loanApp.Stage__c!='QDE'){
                        if(data.stateMappings && data.stateMappings[0]){
                            var list=[]
                            data.stateMappings[0].Four_Wheeler_EMI_Date__c.split(',').forEach(dateValue=>{
                                //var newDate = parseInt(dateValue)
                                list.push({label:dateValue, value:dateValue})
                            })
                            this.emiDateOptions=list
                        }else{
                            this.showToastMessage('Warning','We could not find EMI Date Options','warning', 'sticky')
                        }
                    } 
                }
                else if(prod.RecordType__c === 'Two Wheeler'){
                    this.twoWheelerExposure = true;

                    //if(this.loanApp.Stage__c=='DDE' || this.loanApp.Stage__c=='Credit'){
                    if(this.loanApp.Stage__c!='QDE'){
                        if(data.stateMappings && data.stateMappings[0]){
                            var list=[]
                            if(data.stateMappings[0].Two_Wheeler_EMI_Date__c.includes(',')){
                                data.stateMappings[0].Two_Wheeler_EMI_Date__c.includes(',').split(',').forEach(dateValue=>{
                                    //var newDate = parseInt(dateValue)
                                    list.push({label:dateValue, value:dateValue})
                                })
                            }
                            else{
                                var newDate = data.stateMappings[0].Two_Wheeler_EMI_Date__c
                                list.push({label:newDate, value:newDate})
                            }
                            this.emiDateOptions=list
                            if(this.emiDateOptions.length==1 && !this.loanApp.EMI_Date__c){
                                this.loanApp.EMI_Date__c=this.emiDateOptions[0].value
                            }
                        }else{
                            this.showToastMessage('Warning','We could not fine EMI Date Options','warning', 'sticky')
                        }
                        
                    }
                }else if(prod.RecordType__c === 'Commercial Vehicle'){//R2-2045
                    let hcvLcvIcv = ['10103','10104','10134','10113']
                    let scvCarTaxi3W = ['10105','10101','10102','10108','10106','10107']
                    if(hcvLcvIcv.includes(this.loanApp.Collateral_Type__c)){
                        this.setEMIDateOptions(data.stateMappings && data.stateMappings[0]?data.stateMappings[0].HCV_LCV_ICV_CE_EMI_Date__c:undefined)
                    }else if(scvCarTaxi3W.includes(this.loanApp.Collateral_Type__c)){
                        this.setEMIDateOptions(data.stateMappings && data.stateMappings[0]?data.stateMappings[0].SCV_CarTaxi_3W_EMI_Date__c:undefined)
                    }
                }else if(prod.RecordType__c === 'Construction Equipment'){//R2-2045
                    this.setEMIDateOptions(data.stateMappings && data.stateMappings[0]?data.stateMappings[0].HCV_LCV_ICV_CE_EMI_Date__c:undefined)
                }
            }
            this.productDetails.set(prod.Product__c, prod)
            
        })


        data.rangeDetails.forEach(element => {
            this.rangeMap.set(element.Product_Id__c,element);
        });
       
        if(this.rangeMap.get(this.loanApp.Product__c) && !this.handleCheckIfApplicableForTractorScenario(RECORD_TYPE_CHECK_SCENARIO)){
            this.minLoanAmount = this.rangeMap.get(this.loanApp.Product__c).Min_Loan_Value__c;
            this.maxLoanAmount = this.rangeMap.get(this.loanApp.Product__c).Max_Loan_Value__c;
            this.loanAmountUnderFlowError = 'Please enter a value above '+this.minLoanAmount
            this.loanAmountOverFlowError = 'Please enter a value below '+this.maxLoanAmount
            this.minROI = this.rangeMap.get(this.loanApp.Product__c).Min_ROI_Value__c;
            this.maxROI = this.rangeMap.get(this.loanApp.Product__c).Max_ROI_Value__c;
            this.ROIUnderFlowError = 'Please enter a value above '+this.minROI
            this.ROIOverFlowError = 'Please enter a value below '+this.maxROI
            this.minTenure = this.rangeMap.get(this.loanApp.Product__c).Min_Tenure__c;
            this.maxTenure = this.rangeMap.get(this.loanApp.Product__c).Max_Tenure__c;
            this.tenureUnderFlowError = 'Please enter a value above '+this.minTenure
            this.tenureOverFlowError = 'Please enter a value below '+this.maxTenure
        }
        

        //if(this.loanApp.Stage__c=='DDE' || this.loanApp.Stage__c=='Credit'){
        if(this.loanApp.Stage__c!='QDE'){
            console.log('master bank '+JSON.stringify(data.masterBank));
            this.requiredAtDDE=true
            this.rateChartCodes = data.rateChartCodeRecords;
            if(!this.loanApp.Nature_of_Loan__c){
                this.loanApp.Nature_of_Loan__c='Secured'
            }
            /*if(this.loanApp.Collaterals__r && this.loanApp.Collaterals__r[0].Apportioned_Loan_Amount__c){
                this.loanApp.Total_Loan_Amount__c=parseFloat(this.loanApp.Collaterals__r[0].Apportioned_Loan_Amount__c)
            }else{
                this.loanApp.Total_Loan_Amount__c=parseFloat(this.loanApp.Loan_Amount__c)
            }*/
            this.bankRecordId=data.masterBank
            if(this.loanApp.Scheme__r)
                this.Scheme__c=this.loanApp.Scheme__r?this.loanApp.Scheme__r.Scheme_Name__c:''

            this.bankAccountRecords=data.bankAccountRecords

            if(this.loanApp.Repayment_Bank_Name__c){
                this.bankAccountRecords.forEach(element => {
                    if(element.Bank_Name__c === this.loanApp.Repayment_Bank_Name__c){
                        this.repaymentAccountNumberOptions.push({label:element.Account_Number__c, value:element.Account_Number__c})
                    }
                    
                });
            }
            this.manualEntryForAccNo = this.repaymentAccountNumberOptions.length == 0?true:false
            if(!this.manualEntryForAccNo && !this.loanApp.Repayment_Account_Number__c){
                this.loanApp.Repayment_Account_Number__c = this.repaymentAccountNumberOptions.length == 1?this.repaymentAccountNumberOptions[0].value:'';
            }
            
            var applicant = this.loanApp.Applicants__r[0];
            //applicant.First_Name__c = applicant.First_Name__c?applicant.First_Name__c+' ':''
            //applicant.Middle_Name__c = applicant.Middle_Name__c?applicant.Middle_Name__c+' ':''
            //applicant.Last_Name__c = applicant.Last_Name__c?applicant.Last_Name__c:''
            //var applicantName = (applicant.First_Name__c+applicant.Middle_Name__c+applicant.Last_Name__c).toUpperCase();
            var subProduct = this.productDetails.get(this.loanApp.Product__c).Sub_Product__c
            var parentProd = this.productDetails.get(this.loanApp.Product__c).RecordType__c
            if(parentProd=='Two Wheeler' || subProduct=='New'){
                this.showTrancheSection = false;
                this.loanApp.Disbursement_Category__c = 'Full';
                this.disbursementCategoryDisabled = true;
            }else{
                this.showTrancheSection = this.loanApp.Disbursement_Category__c=='Partial'?true:false;
                this.disbursementCategoryDisabled = false;
            }
            if(((parentProd=='Four Wheeler' || this.r2LoanRecordTypes.includes(parentProd)) && subProduct && (subProduct==='Used'|| this.cowSubProducts.toUpperCase().includes(subProduct.toUpperCase()))) && this.loanApp.Collaterals__r && this.loanApp.Collaterals__r[0]){//R2-2634
            //if(this.loanApp.Collaterals__r && this.loanApp.Collaterals__r[0]){
                this.displayBTSection=true
                        
                if(this.loanApp.Collaterals__r && this.loanApp.Collaterals__r.length>0 && this.loanApp.Collaterals__r[0].HPN_With_Financiers_Name__c){
                    this.collateralDetails = this.loanApp.Collaterals__r[0]
                    /*var subProduct = this.productDetails.get(this.collateralDetails.Product__c).Sub_Product__c
                    if(subProduct==='Used'||subProduct==='Cash on Wheels'){
                        this.displayBTSection=true
                    }else{
                        this.displayBTSection=false
                    }*/
                    //var isVehicleOnOwnerName = this.loanApp.Collaterals__r[0].Current_Owner_Name__c.toUpperCase() === applicantName?true:false
                    
                 /*   if(this.collateralDetails.RC_is_on_name_of_Applicant__c === 'Yes'){
                        this.btCaseType = 'Cash on Wheels'
                        if(!this.loanApp.Collaterals__r[0].HPN_With_Financiers_Name__c || this.loanApp.Collaterals__r[0].HPN_With_Financiers_Name__c==='NA'){
                            this.loanApp.BT_Type__c = 'NA'
                        }else if(this.loanApp.Collaterals__r[0].HPN_With_Financiers_Name__c.toUpperCase().startsWith('AU',0)){
                            this.loanApp.BT_Type__c = 'Internal'
                        }else{
                            this.loanApp.BT_Type__c = 'External'
                        }
                    }
                    if(this.collateralDetails.RC_is_on_name_of_Applicant__c === 'No'){
                        this.btCaseType = 'Used'
                        if(!this.loanApp.Collaterals__r[0].HPN_With_Financiers_Name__c || this.loanApp.Collaterals__r[0].HPN_With_Financiers_Name__c==='NA'){
                            this.loanApp.BT_Type__c = 'External'
                        }else if((this.loanApp.Collaterals__r[0].HPN_With_Financiers_Name__c).toUpperCase().startsWith('AU',0)){
                            this.loanApp.BT_Type__c = 'Internal'
                        }else{
                            this.loanApp.BT_Type__c = 'External'
                        }
                    }*/

                     //SFAU-5318 : Added by Samridhi
                     if(this.collateralDetails.RC_is_on_name_of_Applicant__c === 'Yes'){
                        this.btCaseType = 'Cash on Wheels';
                     }else{
                        this.btCaseType = 'Used';
                     }

                     if((this.loanApp.Collaterals__r[0].HPN_With_Financiers_Name__c && this.loanApp.Collaterals__r[0].HPN_With_Financiers_Name__c).toUpperCase().startsWith('AU',0)){
                        // Added by Kunal - SFAU-5343 Start
                        this.isBTTypeRequired = this.loanApp.Collaterals__r[0].SVSH_SVOH__c == 'SVOH' && this.loanApp.Collaterals__r[0].Linked_Account_Number__c;
                        this.btOptions =  this.isBTTypeRequired ? [{label:'Internal', value:'Internal'}] : [{label:'Internal', value:'Internal'}, {label:'NA', value:'NA'}];
// Added by Kunal - SFAU-5343 End
                     } else if((this.loanApp.Collaterals__r[0].HPN_With_Financiers_Name__c == 'NA' || this.loanApp.Collaterals__r[0].HPN_With_Financiers_Name__c == 'None') && (this.loanApp.Collaterals__r[0].RC_is_on_name_of_Applicant__c == 'No')){
                        this.btOptions = [{label:'NA', value:'NA'}];
                     } else{
                        this.btOptions = [{label:'External', value:'External'},{label:'NA', value:'NA'}];
                     }
                    /*if(this.loanApp.Collaterals__r[0].HPN_With_Financiers_Name__c==='' || !this.loanApp.Collaterals__r[0].HPN_With_Financiers_Name__c){
                        if(isVehicleOnOwnerName){
                            this.loanApp.BT_Type__c = 'NA'
                        }else{
                            this.loanApp.BT_Type__c = 'External'
                        }
                    }else if(this.loanApp.Collaterals__r[0].HPN_With_Financiers_Name__c){
                        if(this.loanApp.Collaterals__r[0].HPN_With_Financiers_Name__c.toUpperCase() == 'AU SMALL FINANCE BANK'){
                            if(isVehicleOnOwnerName){
                                this.loanApp.BT_Type__c = 'Internal'
                            }else{
                                this.loanApp.BT_Type__c = 'Internal'
                            }
                        }else{
                            if(isVehicleOnOwnerName){
                                this.loanApp.BT_Type__c = 'External'
                            }
                        }
                    
                    }*/
                }
            }else{
                this.displayBTSection=false
            }   

            
            
            
            

            var options=new Map()
            data.scheduleRecords.forEach(input1=>{
                options.set(input1.Name__c,{label:input1.Name__c,value:input1.Name__c})
                //this.emiFrequencyOptions.push({label:input1.Interest_Frequency__c,value:input1.Interest_Frequency__c})
            })
            this.scheduleNameOptions=Array.from(options.values())
            this.scheduleRecords=data.scheduleRecords

            options=new Map()
            this.scheduleRecords.forEach(input=>{
                if(input.Name__c===this.loanApp.Schedule_Name__c){
                    options.set(input.Interest_Frequency__c,{label:input.Interest_Frequency__c,value:input.Interest_Frequency__c})
                }
            })
            this.emiFrequencyOptions=Array.from(options.values())
            
            this.calculateTypeOfRate()
            getBankMasterRecords().then((data1)=>{
                data1.forEach(element => {
                    this.bankRecordsList.set(element.Bank_Name__c, element)
                });
                this.recordTypeId = this.loanApp.RecordTypeId
                //this.setRepaymentModeOption()
                
                //&& this.bankRecordsList.get(this.loanApp.Repayment_Bank_Name__c).Net_Banking__c==='Live'
                /*if(this.bankRecordsList.get(this.loanApp.Repayment_Bank_Name__c)){
                    this.eligibleForEmandate = 'Bank is Eligible for Emandate'
                    this.template.querySelector('.emandateText').classList.remove('slds-text-color_destructive')
                    this.template.querySelector('.emandateText').classList.add('slds-text-color_success')
                }else{
                    if(!this.loanApp.Repayment_Bank_Name__c)
                        this.eligibleForEmandate = ''
                    else
                        this.eligibleForEmandate = 'Bank is not Eligible for Emandate'
                    this.template.querySelector('.emandateText').classList.add('slds-text-color_destructive')
                    this.template.querySelector('.emandateText').classList.remove('slds-text-color_success')
                }*/
                
            })

            this.showRepaymentStartDateMethod()
            
            if(this.readOnly==false){
                this.isIOI = this.loanApp.Schedule_Type__c === 'IOI'?true:false
                this.isVPI = this.loanApp.Schedule_Type__c === 'VPI'?true:false
                this.showTrancheSection = this.loanApp.Disbursement_Category__c === 'Partial'?true:false
                this.addNominee=true
                this.checkIsBT(this.loanApp.BT_Type__c)

            }
            if(!this.loanApp.First_EMI_Date__c){
                this.calculateFirstEMIDate();
            }
        }
        // Tractor QDE UI Updates for EMI Date
        if(this.handleCheckIfApplicableForTractorScenario(RECORD_TYPE_CHECK_SCENARIO)){
            this.Scheme__c=this.loanApp.Scheme__r?this.loanApp.Scheme__r.Id:'';
            this.scheduleOptions = data.scheduleRecords;
        }
        // Tractor QDE UI Updates for EMI Date
        
        // Tractor  UI Updates for EMI Date
        if(this.handleCheckIfApplicableForTractorScenario(RECORD_TYPE_CHECK_SCENARIO_WITHOUT_STAGE)){
            if(data.stateMappings && data.stateMappings[0] && data.stateMappings[0].Tractor__c){
                let list=[];
                this.emiDateOptions = [];
                data.stateMappings[0].Tractor__c.split(',').forEach(dateValue=>{
                    //var newDate = parseInt(dateValue)
                    list.push({label:dateValue, value:dateValue})
                })
                this.emiDateOptions=list
            }else{
                this.showToastMessage('Warning','We could not find EMI Date Options','warning', 'sticky');
            }
        }
        // Tractor  UI Updates for EMI Date
        this.getVisibleFields(this.loanApp.Stage__c);
        if(this.loanApp.Stage__c=='QDE'){
            this.handleEMICalculations()
        }
        
    }

    async disableFieldsAsPerMetadata(){
        this.fieldsToBeDisabled = await getMaterialFields({strScreen:'Loan Detail',strLoanId:this.loanApp.Id});
        if(this.fieldsToBeDisabled){
            this.fieldsToBeDisabled.forEach((input=>{
                if(input == 'Repayment_Bank_Name__c'){
                    this.bankNameReadOnly = true
                }else{
                    if(this.template.querySelectorAll('[data-name="'+input+'"]')){
                        this.template.querySelectorAll('[data-name="'+input+'"]').forEach((inputToBeDisabled=>{
                            inputToBeDisabled.disabled = true
                        }))
                    }
                    
                }
                
                
            }))
        }
        this.isLoading=false
    }

    isFourWheeler = false;
    isTwoWheeler = false;

    getLoanDetails(){
        getDetails({recordId: this.recordId}).then((data)=>{
            this.loadIt=true
            this.loanApp = data.loanApp;
            this.isCustomerVisitForPDMandatory = data.isPDMandatory;
            this.isFourWheeler = data.typeOfWheeler.isFourWheeler;
                this.isTwoWheeler = data.typeOfWheeler.isTwoWheeler;
            this.getApplicants();
            console.log('record data '+JSON.stringify(data.bankAccountRecords));
            this.workWithLoanDetails(data);

            // Fetching Tractor related data for QDE
            if(this.handleCheckIfApplicableForTractorScenario(RECORD_TYPE_CHECK_SCENARIO)){
                this.handleFetchSchemesForTractorScenario();
            }
            // Fetching Tractor related data for QDE
            if(this.loanApp.Stage__c == 'QDE' && !this.isTwoWheeler){
                if(this.loanApp.Emi_Frequency__c != undefined && this.loanApp.Emi_Frequency__c != '' && this.loanApp.Emi_Frequency__c != null){
                    if(this.loanApp.Emi_Frequency__c.toUpperCase().includes('MONTHLY')){
                        this.boolHideCalculateEMI = false;
                        this.template.querySelectorAll('[data-id="EMI__c"]').forEach(element =>{
                            element.classList.remove('slds-hide');
                        });
                    }
                    else{
                        this.template.querySelectorAll('[data-id="EMI__c"]').forEach(element =>{
                            element.classList.add('slds-hide');
                        });
                        this.boolHideCalculateEMI = true;
                    }
                }
            }
            else{
                this.boolHideCalculateEMI = false;
                if(this.isTwoWheeler){
                    this.template.querySelectorAll('[data-id="EMI__c"]').forEach(element =>{
                        element.classList.remove('slds-hide');
                    });
                }
            }
        })
            
    }

    @wire (getObjectInfo, {objectApiName: LOAN_APPLICATION_OBJECT}) objectInfo;

    @track purposeOfLoanOptions
    @track natureOfLoanOptions
    
    @track scheduleTypeOptions
    @track disbursementCategoryOptions
    
    @track repaymentModeOptions
    @track moratoriumPeriodOptions
    @track repaymentAccountNumberOptions=[]
    @track btOptions=[]
    manualEntryForAccNo=false
    eligibleForEmandate='';

    handleLookupSelect(event){
        console.log('inside');
        this.loanApp.Repayment_Bank_Name__c = event.detail.name
        this.setRepaymentModeOption()
        this.setRepaymentMode()
        this.repaymentAccountNumberOptions=[];
        if(this.loanApp.Repayment_Bank_Name__c){
            this.bankAccountRecords.forEach(element => {
                if(element.Bank_Name__c === this.loanApp.Repayment_Bank_Name__c){
                    this.repaymentAccountNumberOptions.push({label:element.Account_Number__c, value:element.Account_Number__c})
                }
                
            });
        }

        this.manualEntryForAccNo = this.repaymentAccountNumberOptions.length == 0?true:false
        //this.loanApp.Repayment_Account_Number__c = this.repaymentAccountNumberOptions.length == 1?this.repaymentAccountNumberOptions[0].value:''
        if(!this.manualEntryForAccNo){
            this.loanApp.Repayment_Account_Number__c = this.repaymentAccountNumberOptions.length == 1?this.repaymentAccountNumberOptions[0].value:'';
        }
        if(this.manualEntryForAccNo){
           // this.loanApp.Repayment_Account_Number__c = ''
        }
    }

    setRepaymentMode(){
        if((this.loanApp.Repayment_Bank_Name__c)?.toUpperCase().startsWith('AU',0)){
            if(!this.loanApp.Repayment_Mode__c || this.loanApp.Repayment_Mode__c==''){
                this.loanApp.Repayment_Mode__c = 'Standing Instructions'
            }
        }else{
            this.loanApp.Repayment_Mode__c = ''
        }
    }

    setRepaymentModeOption(){
        if((this.loanApp.Repayment_Bank_Name__c)?.toUpperCase().startsWith('AU',0)){
            //this.loanApp.Repayment_Mode__c = 'Standing Instructions'
            //this.repaymentModeOptions = this.allRepaymentModeOptions
            this.repaymentModeOptions = this.allRepaymentModeOptions.filter(function (element) {
                return (element.label!='E mandate without PDC' && element.label!='E mandate with PDC');
            });
            this.eligibleForEmandate = ''
            this.template.querySelector('.emandateText').classList.remove('slds-text-color_destructive')
            this.template.querySelector('.emandateText').classList.remove('slds-text-color_success')
        }else if(!this.loanApp.Repayment_Bank_Name__c){
            //this.loanApp.Repayment_Mode__c = ''
            this.eligibleForEmandate = ''
            this.repaymentModeOptions = this.allRepaymentModeOptions
            this.template.querySelector('.emandateText').classList.remove('slds-text-color_destructive')
            this.template.querySelector('.emandateText').classList.remove('slds-text-color_success')
        }else{
            if(this.bankRecordsList.get(this.loanApp.Repayment_Bank_Name__c)){
                if(!this.bankRecordsList.get(this.loanApp.Repayment_Bank_Name__c).is_Eligible_for_Emandate__c){
                    this.eligibleForEmandate = 'Bank is not Eligible for Emandate'
                    this.template.querySelector('.emandateText').classList.add('slds-text-color_destructive')
                    this.template.querySelector('.emandateText').classList.remove('slds-text-color_success')
                    this.repaymentModeOptions = this.allRepaymentModeOptions.filter(function (element) {
                        return (element.label!='E mandate without PDC' && element.label!='E mandate with PDC' && element.label!='Standing Instructions');
                    });
                }
                if(this.bankRecordsList.get(this.loanApp.Repayment_Bank_Name__c).is_Eligible_for_Emandate__c){
                 //   this.loanApp.Repayment_Mode__c = 'E mandate without PDC'
                    this.eligibleForEmandate = 'Bank is Eligible for Emandate'
                    this.template.querySelector('.emandateText').classList.remove('slds-text-color_destructive')
                    this.template.querySelector('.emandateText').classList.add('slds-text-color_success')
                    this.repaymentModeOptions = this.allRepaymentModeOptions.filter(function (element) {
                        return element.label!='Standing Instructions';
                    });
                }
                
            }
        }
        //Modified for SFAU-5341
        if(this.repaymentByAppl &&  !this.repaymentByAppl['CIF_No__c']){
            this.repaymentModeOptions = this.allRepaymentModeOptions.filter(function (element) {
                return element.label!='Standing Instructions';
            });
        }
    }
    /*openVFPage(data){
       
        if(FORM_FACTOR === 'Small'){
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                   url: '/apex/EMISchedule?id='+data
               }
            });
        }
        if(FORM_FACTOR === 'Large'){
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__webPage',
                attributes: {
                    url: '/apex/EMISchedule?id='+data
                }
            }).then(generatedUrl => {
                window.open(generatedUrl);
            });
        }
    }*/

    @wire(getPicklistValuesByRecordType, { objectApiName: LOAN_APPLICATION_OBJECT, recordTypeId: '$recordTypeId' })
    propertyOrFunction({error, data}){
        var picklistMap = new Map()
        if(data){
            //console.log('Picklist  ' + JSON.stringify(data));
            picklistMap = data.picklistFieldValues
            this.natureOfLoanOptions = picklistMap['Nature_of_Loan__c'].values
            this.disbursementCategoryOptions = picklistMap['Disbursement_Category__c'].values
            this.allRepaymentModeOptions = picklistMap['Repayment_Mode__c'].values
            this.setRepaymentModeOption();
            this.productOptions = picklistMap['Product__c'].values
            this.moratoriumPeriodOptions = picklistMap['Moratorium_Period__c'].values
            this.visitedCustomerPDOptions = picklistMap['Visited_Customer_for_PD__c'].values
           // this.btOptions=picklistMap['BT_Type__c'].values

           // For Tractor QDE adding EMI Frequency option without any dependencies
            if(this.applicableTractorQdeUIChange){
                this.emiFrequencyOptions = [];
                for(let i of picklistMap['Emi_Frequency__c'].values){
                    this.emiFrequencyOptions.push({label:i.label,value:i.value})
                }
            }
            // For Tractor QDE adding EMI Frequency option without any dependencies

            var options=[];
            picklistMap['Purpose_of_Loan__c'].values.forEach(input => {
                if(input.validFor.includes(picklistMap['Purpose_of_Loan__c'].controllerValues[this.loanApp.Product__c])){
                    options.push({label:input.label, value:input.value})
                }

            });
            this.purposeOfLoanOptions = options
            if(this.purposeOfLoanOptions.length==1 && !this.loanApp.Purpose_of_Loan__c){
                this.loanApp.Purpose_of_Loan__c=this.purposeOfLoanOptions[0].value
                
            }
        }
    }

    handleEdit(){
        this.readOnly = false;
        this.bankNameReadOnly=false
        this.displayEdit=false;
        //if(this.readOnly==false && (this.loanApp.Stage__c=='DDE' || this.loanApp.Stage__c=='Credit')){
        if(this.readOnly==false && (this.loanApp.Stage__c!='QDE')){
            this.isIOI = this.loanApp.Schedule_Type__c === 'IOI'?true:false
            this.isVPI = this.loanApp.Schedule_Type__c === 'VPI'?true:false
            this.showTrancheSection = this.loanApp.Disbursement_Category__c === 'Partial'?true:false
            this.addNominee=true
            this.checkIsBT(this.loanApp.BT_Type__c)
        }
        this.disableFieldsAsPerMetadata()
        this.dispatchEvent(new CustomEvent('wizardevent', {
            detail:{value:'',name:'LoanDetails' ,mode:''}
        }));
    /*restricAccess({
            compName: 'loanDetails' ,loanId: this.recordId
            })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save Loan',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }else{
        this.readOnly = false;
        this.bankNameReadOnly=false
        this.displayEdit=false;
        //if(this.readOnly==false && (this.loanApp.Stage__c=='DDE' || this.loanApp.Stage__c=='Credit')){
        if(this.readOnly==false && (this.loanApp.Stage__c!='QDE')){
            this.isIOI = this.loanApp.Schedule_Type__c === 'IOI'?true:false
            this.isVPI = this.loanApp.Schedule_Type__c === 'VPI'?true:false
            this.showTrancheSection = this.loanApp.Disbursement_Category__c === 'Partial'?true:false
            this.addNominee=true
            this.checkIsBT(this.loanApp.BT_Type__c)
        }
        this.disableFieldsAsPerMetadata()
        this.dispatchEvent(new CustomEvent('wizardevent', {
            detail:{value:'',name:'LoanDetails' ,mode:''}
        }));
         }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
            })*/
    }

    handleValidations() {
        this.handleResetCustomValidationForTractor();
        var valid;
        let name = this.template.querySelectorAll('lightning-input');
        console.log(name)
        const allValid1 = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            let classlist = Array.from(inputCmp.classList)
            if(classlist && classlist.includes('validate')){
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }else{
                return validSoFar
            }
        }, true);

        /*const allValid3 = [
            ...this.template.querySelectorAll('lightning-slider'),
        ].reduce((validSoFar, inputCmp) => {
            let classlist = Array.from(inputCmp.classList)
            if(classlist && classlist.includes('validate')){
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }else{
                return validSoFar
            }
        }, true);*/

        const allValid2 = [
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            let classlist = Array.from(inputCmp.classList)
            if(classlist && classlist.includes('validate')){
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }else{
                return validSoFar
            }
            
        }, true);

        if (allValid1 && allValid2) {
            valid = true
        } else {
            valid = false;
        }
        return valid;
    }

    /*handleIndividualValidation(inputName) {
        var valid;
        
        const allValid1 = [
            ...this.template.querySelectorAll('[name="'+inputName+'"]'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid1) {
            valid = true
        } else {
            valid = false;
        }
        return valid;
    }*/

    showRepaymentStartDateMethod(){
        if(this.loanApp.EMI_Frequency==='IOI' && this.loanApp.Disbursement_Category__c==='Partial'){
            this.disableRepaymentStartDate=false
        }else{
            this.disableRepaymentStartDate=true
        }
    }

    handleChange(event){
        //this.sliderChange = true;
        var name = event.target.name
        var value = event.target.value;
        //this.handleValidations()
        this.loanApp[event.target.name]=event.target.value;
       

        if(this.emiAPIVariablesList.includes(name)){
            this.callEMIAPI = true
            this.sliderChange = true;
        }

        if(name==='Schedule_Name__c'){
            var options=new Map()
            this.scheduleRecords.forEach(input=>{
                if(input.Name__c===value){
                    this.loanApp.Schedule_Code__c = input.Schedule_Code__c
                    options.set(input.Interest_Frequency__c,{label:input.Interest_Frequency__c,value:input.Interest_Frequency__c})
                }
            })
            this.emiFrequencyOptions=Array.from(options.values())
            if(this.loanApp.Schedule_Name__c.toUpperCase().includes('MONTHLY')){
                this.loanApp.Emi_Frequency__c='MONTHLY'
                this.scheduleRecords.forEach(input=>{
                    if(input.Interest_Frequency__c===this.loanApp.Emi_Frequency__c && input.Name__c===this.loanApp.Schedule_Name__c){
                        this.isIOI = input.VPI_or_EPI__c=== 'IOI'?true:false
                        this.isVPI = input.VPI_or_EPI__c === 'VPI'?true:false
                        this.loanApp.Schedule_Type__c=input.VPI_or_EPI__c
                        this.callEMIAPI = true
                    }
                })
                this.showRepaymentStartDateMethod()

            }else{
                if(this.emiFrequencyOptions && this.emiFrequencyOptions.length==1){
                    this.loanApp.Emi_Frequency__c=this.emiFrequencyOptions[0].value
                    this.scheduleRecords.forEach(input=>{
                        if(input.Interest_Frequency__c===this.loanApp.Emi_Frequency__c && input.Name__c===this.loanApp.Schedule_Name__c){
                            this.isIOI = input.VPI_or_EPI__c=== 'IOI'?true:false
                            this.isVPI = input.VPI_or_EPI__c === 'VPI'?true:false
                            this.loanApp.Schedule_Type__c=input.VPI_or_EPI__c
                            this.callEMIAPI = true
                        }
                    })
                    this.showRepaymentStartDateMethod()
                }else{
                    this.isIOI=false
                    this.isVPI=false
                    this.loanApp.Schedule_Type__c=''
                    this.callEMIAPI = true
                }

            }
            this.calculateFirstEMIDate();
        }

        if(name==='Emi_Frequency__c'){
            this.breReRunFields.push('Emi_Frequency__c')
            if(this.scheduleRecords && this.scheduleRecords.length>0){
                this.scheduleRecords.forEach(input=>{
                    if(input.Interest_Frequency__c===value && input.Name__c===this.loanApp.Schedule_Name__c){
                        this.isIOI = input.VPI_or_EPI__c=== 'IOI'?true:false
                        this.isVPI = input.VPI_or_EPI__c === 'VPI'?true:false
                        this.loanApp.Schedule_Type__c=input.VPI_or_EPI__c
                        this.callEMIAPI = true
                    }
                })
                this.showRepaymentStartDateMethod();
                this.loanApp.Emi_Frequency__c = value;
            }
            if(this.loanApp.Stage__c == 'QDE'){
                if(this.loanApp.Emi_Frequency__c.toUpperCase().includes('MONTHLY')){
                    this.boolHideCalculateEMI = false;
                    this.template.querySelectorAll('[data-id="EMI__c"]').forEach(element =>{
                        element.classList.remove('slds-hide');
                    });
                }
                else{
                    this.template.querySelectorAll('[data-id="EMI__c"]').forEach(element =>{
                        element.classList.add('slds-hide');
                    });
                    this.boolHideCalculateEMI = true;
                }
            }
            else{
                this.boolHideCalculateEMI = false;
            }
            this.calculateFirstEMIDate();    
            
        }

        if(name==='Loan_Amount__c'){
            this.breReRun = false
            let difference =  parseFloat(this.loanApp.Loan_Amount__c) - this.initialLoanAmount
            // SFAU-5677 - Add check Greater, LESSER THAN and EQUAL TO
            if(Math.abs(difference) >= 5000){
                this.breReRun=true
                if(this.loanApp.Stage__c=='PSD' && this.loanApp.Pre_Approved_Flag__c){
                    this.loanApp.BRE_Run_for_PreApproved_Offer__c=true
                }
                this.breReRunFields.push('Loan_Amount__c')
            }
            if(this.loanApp.Collaterals__r && this.loanApp.Collaterals__r[0].Other_Funding_Total__c){
                this.loanApp.Total_Loan_Amount__c=parseFloat(this.loanApp.Loan_Amount__c)+parseFloat(this.loanApp.Collaterals__r[0].Other_Funding_Total__c)
            }else{
                this.loanApp.Total_Loan_Amount__c=parseFloat(this.loanApp.Loan_Amount__c)
            }
            /*if(this.loanApp.RecordType.DeveloperName == 'Two_Wheeler'){
                this.calculateFlatROI()
                //this.calculateROIForFlatROI()
            }*/
        }

        if(name==='Disbursement_Category__c'){
            this.showTrancheSection = value === 'Partial'?true:false
            this.showRepaymentStartDateMethod()
        }

        if(name==='BT_Type__c'){
            this.checkIsBT(value)
        }
        //if(this.loanApp.Stage__c==='DDE' || this.loanApp.Stage__c=='Credit'){
        if(this.loanApp.Stage__c!='QDE'){
            this.calculateTypeOfRate()
        }
        if(name=='Repayment_Mode__c'){
            this.getBankAccountRecords(value);
        }
        //Below condition block added as a part of Bug-2964
        if(name=='IFSC_Code__c' ){
            this.loanApp['IFSC_Code__c'] = value.toUpperCase(); 
            console.log('ifsc '+this.loanApp['IFSC_Code__c']);
        }
        if(name=='IFSC_Code__c' && value.length==11){
            console.log('in ifsc '+value);
            this.getBankName(value);
            this.getMICRCode(value);
        }
        if(name=='Repayment_Account_Number__c'){
            this.bankAccountRecords.forEach(element => {
                if(element.Bank_Name__c === this.loanApp.Repayment_Bank_Name__c && element.Account_Number__c == this.loanApp.Repayment_Account_Number__c){
                    if(element.Account_Type__c.includes('Saving')){
                        this.loanApp.Repayment_Account_Type__c = 'SB';
                    }
                    else if(element.Account_Type__c.includes('Current')){
                        this.loanApp.Repayment_Account_Type__c = 'CA';
                    }
                }
                
            });
        }

        if(name=='Tenure__c'){
            this.breReRun=true
            if(this.loanApp.Stage__c=='PSD'  && this.loanApp.Pre_Approved_Flag__c){
                this.loanApp.BRE_Run_for_PreApproved_Offer__c=true
            }
            this.breReRunFields.push('Tenure__c')
            /*if(this.loanApp.RecordType.DeveloperName == 'Two_Wheeler'){
                this.calculateFlatROI()
                //this.calculateROIForFlatROI()
            }*/
        }

        if(name=='ROI__c'){
            if(this.loanApp.Stage__c=='PSD'  && this.loanApp.Pre_Approved_Flag__c){
                this.loanApp.BRE_Run_for_PreApproved_Offer__c=true
            }
        }

        /*if(this.loanApp.RecordType.DeveloperName == 'Two_Wheeler'){
            if(name=='Flat_ROI__c'){
                this.calculateROIForFlatROI()
                //this.calculateFlatROI()
            }
            if(name=='ROI__c'){
                this.calculateFlatROI()
            }
        }*/
        if(name=='EMI_Date__c'){
            this.loanApp.EMI_Date__c = value;
            this.calculateFirstEMIDate();
        }
        //this.handleIndividualValidation(name)
        console.log(JSON.stringify(this.loanApp));
        
    }   

    showToastMessage(titleValue, messageValue, variantValue, mode){

        const event = new ShowToastEvent({
            title: titleValue,
            message: messageValue,
            variant: variantValue,
            mode: mode
        });
        this.dispatchEvent(event);
    

    }

    async handleEMICalculations(){
        // Quarterly and Monthly EMI calculation check
        let roiDivideConstant = 12;
        // Quarterly and Monthly EMI calculation check

        var appliedROIPerMonth = (this.loanApp.ROI__c/roiDivideConstant)/100;
        var numerator = this.loanApp.Total_Loan_Amount__c * appliedROIPerMonth * Math.pow((1+appliedROIPerMonth), this.loanApp.Tenure__c);
        var denominator = Math.pow((1+appliedROIPerMonth), this.loanApp.Tenure__c)-1;
        if(numerator == 0 || (denominator <= 0)){
            this.loanApp.EMI__c = 0;
        }
        else{
            //this.loanApp.EMI__c = (numerator/denominator).toFixed(2);
            this.loanApp.EMI__c = (numerator/denominator); // Removed toFixed(2) as it is rounding decimal values ex: converting 0.495423 to 0.50;
            this.loanApp.EMI__c = this.loanApp.EMI__c ? Math.round(this.loanApp.EMI__c) : this.loanApp.EMI__c;
        }

        // Quarterly and Monthly EMI calculation check
        if(this.loanApp.Emi_Frequency__c === QUARTERLY_EMI_CALCULATION_LITERAL){
            this.loanApp.EMI__c = this.loanApp.EMI__c * 3;
        }
        else if(this.loanApp.Emi_Frequency__c === HALF_YEARLY_EMI_CALCULATION_LITERAL){
            this.loanApp.EMI__c = this.loanApp.EMI__c * 6;
        }
        // Quarterly and Monthly EMI calculation check

        this.loanApp[EMI_FIELD.fieldApiName] = this.loanApp.EMI__c;
    }
    handleFirstEMIDateChange(event){
        this.loanApp.First_EMI_Date__c = event.target.value;
        this.sliderChange = true;
        this.callEMIAPI = true;
        this.validateFirstEMIDate(this.loanApp.First_EMI_Date__c);
    }
    validateFirstEMIDate(firstEMIDate){
        const todaysdate = new Date();
        let addMonths, minDays = 20, maxDays;
        if(this.loanApp.Emi_Frequency__c && this.loanApp.EMI_Date__c && firstEMIDate){
            const loanEMIFrequency = ((this.loanApp.Emi_Frequency__c).toLowerCase()).replace(/\s/g, "");
            if(loanEMIFrequency == 'monthly'){
                addMonths = 1;
                maxDays = 60;
            }else if(loanEMIFrequency == 'quarterly'){
                addMonths = 3;
                maxDays = 120;
            }else if(loanEMIFrequency == 'halfyearly'){
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

        if(this.applicableTractorQdeUIChange){
            return true;
        }
    }
    calculateFirstEMIDate(){
        console.log('called calculateFirstEMIDate');
        var addMonths;
        var minDays = 20;
        var maxDays;
        const todaysdate = new Date();
        if(this.loanApp.Emi_Frequency__c && this.loanApp.EMI_Date__c){
            // Adjust for multiple types of literals eg. Half yearly and HALFYEARLY
            const loanEMIFrequency = ((this.loanApp.Emi_Frequency__c).toLowerCase()).replace(/\s/g, "");

            if(loanEMIFrequency == 'monthly'){
                addMonths = 1;
                maxDays = 60;
            }else if(loanEMIFrequency == 'quarterly'){
                addMonths = 3;
                maxDays = 120;
            }else if(loanEMIFrequency == 'halfyearly'){
                addMonths = 6;
                maxDays = 210;
            }
            // Adjust for multiple types of literals eg. Half yearly and HALFYEARLY
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
                        // For edge condition Month val Tractor QDE Change
                        if(Number(monthVal) > 12){
                            monthVal = Number(monthVal) % 12 + '';
                            monthVal = monthVal < 10 ? '0' + monthVal : monthVal;
                            todaysdate.setFullYear(todaysdate.getFullYear() + 1);
                        }
                        // For edge condition Month val Tractor QDE Change
                        this.loanApp.First_EMI_Date__c = todaysdate.getFullYear() +'-'+ monthVal +'-'+ Number(this.loanApp.EMI_Date__c);
                    }
                }else{
                    let currentMonthDiff = (currentMonthEMIDate.getTime() - todaysdate.getTime());
                    if((currentMonthDiff/(1000 * 3600 * 24)) > minDays && (currentMonthDiff/(1000 * 3600 * 24)) < maxDays){
                        console.log('currentMonthEMIDate.getMonth().length==1: '+currentMonthEMIDate.getMonth().toString().length);
                        let monthVal = currentMonthEMIDate.getMonth().toString().length==1?'0'+currentMonthEMIDate.getMonth().toString():currentMonthEMIDate.getMonth();
                        // For edge condition Month val Tractor QDE Change
                        if(Number(monthVal) > 12){
                            monthVal = Number(monthVal) % 12 + '';
                            monthVal = monthVal < 10 ? '0' + monthVal : monthVal;
                            todaysdate.setFullYear(todaysdate.getFullYear() + 1);
                        }
                        // For edge condition Month val Tractor QDE Change
                        this.loanApp.First_EMI_Date__c = currentMonthEMIDate.getFullYear() +'-'+ monthVal +'-'+ currentMonthEMIDate.getDate();
                    }else{
                        //console.log('(parseInt(todaysdate.getMonth())+parseInt(addMonths)+1).length: '+(parseInt(todaysdate.getMonth())+parseInt(addMonths)+1).toString().length);
                        console.log(' parseInt(todaysdate.getMonth())' + parseInt(todaysdate.getMonth()));
                        console.log(' parseInt(addMonths)' + parseInt(addMonths));
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
                 console.log('date: '+this.loanApp.First_EMI_Date__c);
                 console.log('type: '+typeof(this.loanApp.First_EMI_Date__c));
                // console.log('type: '+typeof(dates));
                 //this.loanApp.First_EMI_Date__c = new Date("08/18/23");
            }
        }
    }

    calculateEMI(){
    restricAccess({
            compName: 'loanDetails' ,loanId: this.recordId
            })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to calculate EMI for the Loan',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }else{
        this.sliderChange = false;
        //if(this.handleValidations() && this.handleValidationCheckTractor(this.loanApp) && this.handleSchemeValidation(this.loanApp)){commented for testing purpose as scheme validation was giving error - Neha
        if(this.handleValidations() && this.handleValidationCheckTractor(this.loanApp)){
            if(!this.vpiRecordCountValidation()){
                return;
            }else{
                if(this.loanApp.First_EMI_Date__c){
                    console.log('this.validateFirstEMIDate(this.loanApp.First_EMI_Date__c): '+this.validateFirstEMIDate(this.loanApp.First_EMI_Date__c));
                    if(this.validateFirstEMIDate(this.loanApp.First_EMI_Date__c)){
                        if(this.loanApp.Stage__c=='QDE'){
                            this.handleEMICalculations()
                        }
                        //if(this.loanApp.Stage__c=='DDE' || this.loanApp.Stage__c=='Credit'){
                        if(this.loanApp.Stage__c!='QDE'){
                            this.handleEMIApi()
                        }
                    }
                }else{
                    if(this.loanApp.Stage__c=='QDE'){
                        this.handleEMICalculations()
                    }
                    //if(this.loanApp.Stage__c=='DDE' || this.loanApp.Stage__c=='Credit'){
                    if(this.loanApp.Stage__c!='QDE'){
                        this.handleEMIApi()
                    }
                }
            }
            
        }else{
            this.showToastMessage('Error','Your Input seems to be Invalid. Kindly fill the Details Correctly','error', 'sticky')
        }
          }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
            })

    }

    handleClose(){
        this.template.querySelector('.loanDetailsCmp').classList.remove('slds-hide')
        this.showPANVerificationModal=false
    }

    async saveLoanDetails(){
        if(this.isEditRestricted){
            this.showToastMessage('Access Restricted', 'You cannot edit Loan Details due to Insufficient Access Rights', 'warning', 'sticky');
            return       
        }else{
        
            if(this.loanApp.Stage__c=='QDE' && this.boolHideCalculateEMI){
                await this.handleEMICalculations()
            }
            let isValidFieldValidation = true;
            let isValidFirstEMIDateValidation = true;

            if(this.applicableTractorQdeUIChange){ // For Tractor QDE scenarios
                isValidFirstEMIDateValidation = this.validateFirstEMIDate(this.loanApp.First_EMI_Date__c);
            }
            
            if(!isValidFirstEMIDateValidation) return; // For tractor changes check mandatory conditions for EMI Date options too

            isValidFieldValidation = this.handleValidations();

            if(isValidFieldValidation && isValidFirstEMIDateValidation){

                let btParent = this.template.querySelector('c-balance-transfer-parent');
                let isAllAdded = true;
                if(btParent && this.isBTInternal){ //SFAU-5700
                    isAllAdded = btParent.checkIfAllLoanSelected();
                }   
                //let applicantsPANVerificationRequired = false;
                                const applicantsPANVerificationRequired = await panVerification({loanApp: JSON.parse(JSON.stringify(this.loanApp))})
                if(applicantsPANVerificationRequired && applicantsPANVerificationRequired.length>0){
                    this.applicantPANVerificationList = JSON.parse(JSON.stringify(applicantsPANVerificationRequired))
                    this.showPANVerificationModal=true
                    this.template.querySelector('.loanDetailsCmp').style.height='30 rem'
                    return
                }else{
                    this.handleClose()
                }

                // Update revisit screen info
                if(this.handleCheckIfApplicableForTractorScenario(RECORD_TYPE_CHECK_SCENARIO_WITHOUT_STAGE)){
                    try{
                        await updateRevisitScreen({loanId : this.loanApp.Id});
                    }
                    catch(err){
                        this.showToastMessage('Error','Something went wrong in updating Revisit screen ' + err + ' ' + JSON.stringify(err),'error', 'sticky');
                    }
                }
                // Update revisit screen info
                if(this.sliderChange && !this.boolHideCalculateEMI){
                    this.showToastMessage('Error','Please calculate EMI','error', 'sticky') 
}else if(!isAllAdded){
                    const evt = new ShowToastEvent({
                        title: 'Error',
                        message: 'Please add all Interal BT Transfers',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                    return;
                }
                else if(this.showSave){
                    //this.appFields[ID.fieldApiName] = this.recordId;
                    //const fields= this.appFields;

                    this.loanApp[ID.fieldApiName] = this.recordId;

                    //if(!Number.isInteger(parseInt(this.loanApp.Loan_Amount__c,10))){
                        this.loanApp.Loan_Amount__c = parseInt(this.loanApp.Loan_Amount__c).toFixed(0);
                    //}
                    //if(!Number.isInteger(this.loanApp.EMI__c)){
                        this.loanApp.EMI__c = parseInt(this.loanApp.EMI__c).toFixed(0);
                    //}
                    //if(!Number.isInteger(this.loanApp.ROI__c)){
                        this.loanApp.ROI__c = parseInt(this.loanApp.ROI__c).toFixed(2);
                    //}
                    
                    this.applicationFieldsToBeUpdated = this.loanApp
                    Object.keys(this.applicationFieldsToBeUpdated).forEach(element =>{
                        if(this.excludeFieldList.includes(element)){
                            delete this.applicationFieldsToBeUpdated[element]
                        }
                    })
                    
                    const fields= this.applicationFieldsToBeUpdated;
                    const recordInput = {fields}
                    updateRecord(recordInput).then((data)=>{
                        
                        this.dispatchEvent(new CustomEvent('showvehicle',{
                            detail: fields
                        }));
                        const payload = { recordIdOfSobject: this.loanApp.Id, refreshPage: 'Yes', componentNames: 'ausf-vehicle-list'};
                        publish(this.messageContext, pageRefreshOnMaterialFieldChange, payload);
                    }).catch((error)=>{
                        console.error('error is '+JSON.stringify(error))
                    })
                }
                else {
                    var trancheAmountValidationSuccess=false
                    //var nomineeNetPercentValidationSuccess=false
                    var vpiStageValidationSuccess=false
                    let vpiRecordMandatorySuccess = this.vpiRecordCountValidation();
                    var isUnsavedDataValue=true
                    var matchBankWithIFSC=true
                    const Obj = {};
                    this.errorOnChild = '';
                
                    
                    //if(this.loanApp.Stage__c==='DDE' || this.loanApp.Stage__c=='Credit'){
                    if(this.loanApp.Stage__c!='QDE'){
                            
                            if(this.loanApp.Disbursement_Category__c=='Full' || (this.loanApp.Disbursement_Category__c=='Partial' && this.template.querySelector('c-tranche-parent').getNetDisbursementvalue())){
                                trancheAmountValidationSuccess=true
                            }else{
                                //this.showToastMessage('Error','Net Tranche Disbursement Amount should be equal to Loan Amount (excluding sum of charges) '+(this.loanApp.Loan_Amount__c-this.loanApp.Total_Charges__c),'error');
                                this.showToastMessage('Error','Net Tranche Disbursement Amount should be equal to Total Loan Amount '+(this.loanApp.Total_Loan_Amount__c),'error', 'sticky');

                            }
                            if(this.template.querySelector('c-nominee-parent')){
                                if(this.loanApp.RecordType.DeveloperName=='Two_Wheeler' && this.loanApp.Stage__c=='Credit'){
                                    this.nomineeNetPercentValidationSuccess=true
                                }else{
                                this.template.querySelector('c-nominee-parent').getTotalPercent()
                            }
                                //this.template.querySelector('c-nominee-parent').getTotalPercent()
                            }
                            /*if(this.template.querySelector('c-nominee-parent').getTotalPercent()){
                                nomineeNetPercentValidationSuccess=true
                            }else{
                                nomineeNetPercentValidationSuccess=false
                                this.showToastMessage('Error','Total Share for Nomination for all Nominees should add upto 100%','error');
                            }*/
                            if(this.loanApp.Schedule_Type__c!='VPI' || (this.loanApp.Schedule_Type__c=='VPI' && this.template.querySelector('c-vpi-parent').vpiValidation())){
                                vpiStageValidationSuccess=true
                            }else{
                                vpiStageValidationSuccess=false
                                let noOfInst = this.template.querySelector('c-vpi-parent').calculateNoOfInstallments()
                                this.showToastMessage('Error','Please check the Upto Installment Sequence. Maximum Installments can be upto '+noOfInst,'error', 'sticky')
                            }

                            if((this.loanApp.Schedule_Type__c=='VPI' && this.template.querySelector('c-vpi-parent').getUnsavedData()) || (this.loanApp.Disbursement_Category__c=='Partial' && this.template.querySelector('c-tranche-parent').getUnsavedData())){
                                this.showToastMessage('Error','Please save Tranche/VPI Schedule Data before proceeding','error', 'sticky')
                                isUnsavedDataValue=true
                            }else{
                                isUnsavedDataValue=false
                            }
                            
                            if(this.visibleFields.includes('Repayment_Bank_Name__c') || this.visibleFields.includes('IFSC_Code__c')){
                            var bankMappedWithIFSC = await getBankName({ifsc: this.loanApp.IFSC_Code__c});
                            if(bankMappedWithIFSC && bankMappedWithIFSC.Bank_Name__c == this.loanApp.Repayment_Bank_Name__c){
                                matchBankWithIFSC=true
                            }else{
                                matchBankWithIFSC=false
                                this.showToastMessage('Error','Mismatch in IFSC Code and Repayment Bank Name. Please verify.','error', 'sticky')
                            }
                            }
                            
                            if(trancheAmountValidationSuccess && this.nomineeNetPercentValidationSuccess && vpiStageValidationSuccess && vpiRecordMandatorySuccess && !isUnsavedDataValue && matchBankWithIFSC){
                                markDataInactive({loanApp:this.loanApp}).then((data)=>{
                                    this.saveAllDetails()
                                }).catch((error)=>{
                                    this.showToastMessage('Error','There was some Error in processing the record','error', 'sticky')
                                })
                                
                            }
                        }
                        
                    
                    
                    else{
                        if(this.applicableTractorQdeUIChange)
                            this.handleSetEMIFrequency();
                        

                        this.saveAllDetails()
                    
                    }
                }
                
            }else{
                this.showToastMessage('Error','Mandatory Details seem to be Missing.','error', 'sticky')
            } 
        }   
    }

    // Set Schedule name based on EMI frequency
    handleSetEMIFrequency(){
        if(this.scheduleOptions){
            for(let i of this.scheduleOptions){
                if(i.Name__c && (i.Name__c.toLowerCase()).includes(SCHEDULE_NAME_EQUATED) ){
                    const emiFrequency = ((this.loanApp.Emi_Frequency__c).toLowerCase()).replace(/\s/g, "");
                    const masterFrequency = (i.Interest_Frequency__c).toLowerCase().replace(/\s/g, "");
                    if(emiFrequency === masterFrequency){
                        this.loanApp.Schedule_Name__c = i.Name__c;
                        this.loanApp.Schedule_Code__c = i.Schedule_Code__c;
                        this.loanApp.Schedule_Type__c = i.VPI_or_EPI__c;//R2-2572
                        break;
                    }
                }
            }
        }
    }
    // Set Schedule name based on EMI frequency

    saveAllDetails(){
       
        this.errorOnChild = '';
        this.loanApp[ID.fieldApiName] = this.recordId;
        this.applicationFieldsToBeUpdated = this.loanApp
        Object.keys(this.applicationFieldsToBeUpdated).forEach(element =>{
            if(this.excludeFieldList.includes(element)){
                delete this.applicationFieldsToBeUpdated[element]
            }
        })
        this.updateLoanAppRecord();
        
        //if(this.trancheAmountValidationSuccess && this.nomineeNetPercentValidationSuccess){
            
    
            // Object.keys(this.applicationFieldsToBeUpdated).forEach(element =>{
            //     if(this.excludeFieldList.includes(element)){
            //         delete this.applicationFieldsToBeUpdated[element]
            //     }
            // })
            
            // const fields= this.applicationFieldsToBeUpdated;
            // const recordInput = {fields}
         /*   updateRecord(recordInput).then((data)=>{
                //this.showToastMessage('Record Updated', 'Record was Updated Successfully', 'success')  
               
            }).catch((error)=>{
                this.showToastMessage('Record Update Failed', 'Record was not Updated '+error.body.message, 'error') 
            }) */
        //}
        
    }
    updateLoanAppRecord(){

        this.isLoading = true;
        updateLoanApp({
            jsonString : JSON.stringify(this.applicationFieldsToBeUpdated)
        }).then( (data) => {
            if(data == 'success'){
                // Tractor QDE scenario
                if(this.handleCheckIfApplicableForTractorScenario(RECORD_TYPE_CHECK_SCENARIO)){
                    this.handleTractorValidationChecks();
                }
                else{
                    this.handleUpdateLoanAppRecordSuccess();
                }
                
            /*    setTimeout(function(){
                    window.location.reload(1);
                 }, 1000); */
            }
            else {
                //SFAU-5178
                this.showToastMessage('Error',data,'error', 'sticky'); 
                this.isLoading = false;
            }

        }).catch(error => {
            console.log('error ..... '+JSON.stringify(error));
            console.log('error in getBankAccount '+JSON.stringify(error));
            //SFAU-5178
            this.showToastMessage('Error',error.body.message,'error', 'sticky') ; 
            this.isLoading = false;
        })

       
    }

    // Handle Tractor validation checks
    
    //handling save sequence
    async handleTractorValidationChecks(){
        try{
            if(!this.isConfigLoaded){
                this.showToastMessage('Info','Metadata config not loaded successfully please try to save again','info', 'dismissible');
                return;
            }
            if(this.handleValidationCheckTractor(this.loanApp) && this.handleSchemeValidation(this.loanApp)){
                this.handleUpdateLoanAppRecordSuccess(); // Calling previous saving code here
            }
            else{
                this.showToastMessage('ERROR!','Please review the errors on the form','error', 'dismissible');
            }
            this.isLoading = false;
            
        }
        catch(error){
            console.log('Something went wrong' + (error));
            this.showToastMessage('ERROR!','Something went wrong! ' + JSON.stringify(error),'error', 'sticky');
        }
    }
    //handling save sequence

    // Handing scheme validation
    handleSchemeValidation(loanAppRecord){
        if(!loanAppRecord.Scheme__c){
            return true;
        }
        const schemeId = loanAppRecord.Scheme__c;
        const currentScheme = this.chargeMapTractorQDE.get(schemeId);
        return this.handleCheckSchemeTenureValidation(currentScheme, loanAppRecord)
        && this.handleCheckSchemeRoiValidation(currentScheme, loanAppRecord)
        && this.handleCheckSchemeAmountValidation(currentScheme, loanAppRecord);
    }

    // Handing scheme validation Tenure
    handleCheckSchemeTenureValidation(currentScheme, loanAppRecord){
        const loanTenure = loanAppRecord.Tenure__c;
        const minTenure = currentScheme.MINTENURE__c;
        const maxTenure = currentScheme.MAXTENURE__c;
        if(this.handleLoanValueSchemeComparison(loanTenure,minTenure, maxTenure)){
            this.handleErrorMessageDisplayRemove('Tenure__c');
            return true;
        }
        else{
            this.handleErrorMessageDisplay(minTenure, maxTenure, 'Tenure__c', currentScheme);
            return false;
        }
       
    }

    // Handing scheme validation ROI
    handleCheckSchemeRoiValidation(currentScheme, loanAppRecord){
        const loanRoi = loanAppRecord.ROI__c;
        const minRoi = currentScheme.MINROI__c;
        const maxRoi = currentScheme.MAXROI__c;
        if(this.handleLoanValueSchemeComparison(loanRoi,minRoi, maxRoi)){
            this.handleErrorMessageDisplayRemove('ROI__c');
            return true;
        }
        else{
            this.handleErrorMessageDisplay(minRoi, maxRoi, 'ROI__c', currentScheme);
            return false;
        }
    }

    handleLoanValueSchemeComparison(loanValue, min, max){
        if(loanValue >= 0){
            if(min <= loanValue && max >= loanValue){
                return true;
            }
            else{
                return false;
            }
        }
        return true;
    }

    // Handing scheme validation Loan Amount
    handleCheckSchemeAmountValidation(currentScheme, loanAppRecord){
        const loanAmount = loanAppRecord.Total_Loan_Amount__c;
        const minAmount = currentScheme.MINLOANAMOUNT__c;
        const maxAmount = currentScheme.MAXLOANAMOUNT__c;
        if(this.handleLoanValueSchemeComparison(loanAmount,minAmount, maxAmount)){
            this.handleErrorMessageDisplayRemove('Loan_Amount__c');
            return true;
        }
        else{
            this.handleErrorMessageDisplay(minAmount, maxAmount, 'Loan_Amount__c', currentScheme);
            return false;
        }
    }

    handleErrorMessageDisplayRemove(loanAppField){
        const inputOnUI = this.template.querySelector('lightning-input[data-name="' + loanAppField + '"]');
        inputOnUI.setCustomValidity('');
        inputOnUI.reportValidity();
    }

    handleErrorMessageDisplay(min, max, loanAppField, currentScheme){
        const inputOnUI = this.template.querySelector('lightning-input[data-name="' + loanAppField + '"]');

        let errorMessage = '';
        
        if(loanAppField === 'ROI__c'){
            errorMessage = `${currentScheme.Scheme_Name__c} scheme allows ROI between ${min} and ${max}. Change the ROI or select a different scheme`;
        }
        else if(loanAppField === 'Tenure__c'){
            errorMessage = `${currentScheme.Scheme_Name__c} scheme allows ROI between ${min} and ${max}. Change the tenure or select a different scheme`;
        }
        else{
            errorMessage = `${currentScheme.Scheme_Name__c} scheme allows Loan amount between ${min} and ${max}. Change the loan amount or select a different scheme`;
        }
        inputOnUI.setCustomValidity(errorMessage);
        inputOnUI.reportValidity();

    }
    // Handing scheme validation

    // Checking for validation conditions for current loan application
    handleValidationCheckTractor(loanDetailsTractorValidation){
        if(!this.handleCheckIfApplicableForTractorScenario(RECORD_TYPE_CHECK_SCENARIO_WITHOUT_STAGE)){
            return true;
        }
        let isValid = true;
        
        for(let i of this.metadataConfigTractorValidationList){
            if(this.isApplicableCheck(i, loanDetailsTractorValidation)){
                if(!this.isWithinRange(i, loanDetailsTractorValidation)){
                    isValid = false;
                }
            }
        }

        return isValid;
    }
    // Checking for validation conditions for current loan application

    // Range check for tenure, amount etc
    isWithinRange(metadataRecordTractor, loanDetailsTractorValidation){
        
        let iRRRangeBool = this.isIRRWithinRange(metadataRecordTractor, loanDetailsTractorValidation);
        let isTenureRangeBool = this.isTenureWithinRange(metadataRecordTractor, loanDetailsTractorValidation);
        let isLoanAmountRange = this.isLoanAmountWithinRange(metadataRecordTractor, loanDetailsTractorValidation);

        if(iRRRangeBool
        && isTenureRangeBool
        && isLoanAmountRange
        ){
            return true;
        }
        return false;
    }
    // Range check for tenure, amount etc

    // IIR Range check metadata
    isIRRWithinRange(metadataRecordTractor, loanDetailsTractorValidation){
        if(!metadataRecordTractor.IRR_Range__c || (!loanDetailsTractorValidation.ROI__c && loanDetailsTractorValidation.ROI__c!==0)){
            return true;
        }
        const irrRange = metadataRecordTractor.IRR_Range__c;

        const to = parseFloat(irrRange.split('-')[0]);
        const from = parseFloat(irrRange.split('-')[1]);

        if(loanDetailsTractorValidation.ROI__c >= to && loanDetailsTractorValidation.ROI__c <= from){
            return true;
        }
        else{
            this.displayErrorMessageTractor(to, from, 'IRR_Range__c', metadataRecordTractor, 'ROI__c');
            return false;
        }
    }
    // IIR Range check metadata

    // Tenure Range check metadata
    isTenureWithinRange(metadataRecordTractor, loanDetailsTractorValidation){
        if(!metadataRecordTractor.Tenure_Range__c || (!loanDetailsTractorValidation.Tenure__c && loanDetailsTractorValidation.Tenure__c!==0)){
            return true;
        }
        const irrRange = metadataRecordTractor.Tenure_Range__c;

        const to = parseFloat(irrRange.split('-')[0]);
        const from = parseFloat(irrRange.split('-')[1]);

        if(loanDetailsTractorValidation.Tenure__c >= to && loanDetailsTractorValidation.Tenure__c <= from){
            return true;
        }
        else{
            this.displayErrorMessageTractor(to, from, 'Tenure_Range__c', metadataRecordTractor, 'Tenure__c');
            return false;
        }
    }
    // Tenure Range check metadata

    // Loan Amount Range check metadata
    isLoanAmountWithinRange(metadataRecordTractor, loanDetailsTractorValidation){
        if(!metadataRecordTractor.Loan_Amount_Range__c || (!loanDetailsTractorValidation.Loan_Amount__c && loanDetailsTractorValidation.Loan_Amount__c !== 0)){
            return true;
        }
        const irrRange = metadataRecordTractor.Loan_Amount_Range__c;

        const to = parseFloat(irrRange.split('-')[0]);
        const from = parseFloat(irrRange.split('-')[1]);

        if(loanDetailsTractorValidation.Loan_Amount__c >= to && loanDetailsTractorValidation.Loan_Amount__c <= from){
            return true;
        }
        else{
            this.displayErrorMessageTractor(to, from, 'Loan_Amount_Range__c', metadataRecordTractor, 'Loan_Amount__c');
            return false;
        }
    }
    // Loan Amount Range check metadata


    // Resetting validation incase of tractors
    handleResetCustomValidationForTractor(){
        if(this.handleCheckIfApplicableForTractorScenario(RECORD_TYPE_CHECK_SCENARIO)){
            const fields = ['Loan_Amount__c', 'Tenure__c', 'ROI__c'];
            for(let field of fields){
                const inputOnUI = this.template.querySelector('lightning-input[data-name="' + field + '"]');
                inputOnUI.setCustomValidity('');
                inputOnUI.reportValidity();
            }
        }
    }
    // Resetting validation incase of tractors

    // Display error message based on invalid condition
    displayErrorMessageTractor(to, from, key, metadataRecordTractor, loanAppField){
        const errorMessage = JSON.parse(metadataRecordTractor.Error_Message__c);
        
        let errorMessageKey =  errorMessage[key];
        errorMessageKey = errorMessageKey.replace(RANGE_INSERT_ERROR_MESSAGE, to + '-' + from );
        const inputOnUI = this.template.querySelector('lightning-input[data-name="' + loanAppField + '"]');
        inputOnUI.setCustomValidity(errorMessageKey);
        inputOnUI.reportValidity();
    }
    // Display error message based on invalid condition

  

    // Check if current loan is applicable for tractor validations
    isApplicableCheck(metadataRecordTractor, loanDetailsTractorValidation){
        if(this.isProductApplicable(metadataRecordTractor, loanDetailsTractorValidation)
        && this.isStageApplicable(metadataRecordTractor, loanDetailsTractorValidation)
        && this.isCollateralApplicable(metadataRecordTractor, loanDetailsTractorValidation)
        ){
            return true;
        }

        return false;
    }
    // Check if current loan is applicable for tractor validations

    // Product applicability check
    isProductApplicable(metadataRecordTractor, loanDetailsTractorValidation){
        if(!metadataRecordTractor.Product_Code_Applicable__c || !loanDetailsTractorValidation.Product__c){
            return true;
        }
        else{
           for(let i of metadataRecordTractor.Product_Code_Applicable__c.split(',')){
                if(loanDetailsTractorValidation.Product__c === i.trim()){
                    return true;
                }
           }
        }
        return false;
    }
    // Product applicability check

    // Stage applicability check
    isStageApplicable(metadataRecordTractor, loanDetailsTractorValidation){
        if(!metadataRecordTractor.Stage_Applicable__c || !loanDetailsTractorValidation.Stage__c){
            return true;
        }
        else{
           for(let i of metadataRecordTractor.Stage_Applicable__c.split(',')){
                if(loanDetailsTractorValidation.Stage__c === i.trim()){
                    return true;
                }
           }
        }
        return false;
    }
    // Stage applicability check

    // Collateral applicability check
    isCollateralApplicable(metadataRecordTractor, loanDetailsTractorValidation){
        if(!metadataRecordTractor.Collateral_Type__c || !metadataRecordTractor.Collateral_Type__c){
            return true;
        }
        else{
           for(let i of metadataRecordTractor.Collateral_Type__c.split(',')){
                if(loanDetailsTractorValidation.Collateral_Type__c === i.trim()){
                    return true;
                }
           }
        }
        return false;
    }
    // Collateral applicability check

    // Handle Tractor validation checks

    // Previous updateLoanApp success code added below function to check tractor validation sequentially
    handleUpdateLoanAppRecordSuccess(){
        const Obj = {};
        Obj.errorOnChild = this.errorOnChild;
        Obj.next = this.errorOnChild == '' ? true : false;
        console.log('Obj', Obj);
        this.readOnly=true
        this.bankNameReadOnly=true
        //SFAU-4992 -- Loan amount updates will trigger Exposure change -- gets the updated values here incase the record is saved again
        this.getLoanDetails();

        this.dispatchEvent(new CustomEvent('next', {
            detail: Obj
        }));
        console.log('breReRun'+this.breReRun)
        const payload = { recordIdOfSobject: this.loanApp.Id, refreshPage: 'Yes', componentNames: 'ausf-vehicle-list'};
        publish(this.messageContext, pageRefreshOnMaterialFieldChange, payload);
        if(this.breReRun){
            console.log('checkMFields')
            checkMaterialFields({strScreen:'Loan Detail',strLoanId: this.loanApp.Id,lstFieldsAPI: this.breReRunFields}).then((data=>{
                console.log('sendPayload')
                const payload = { recordIdOfSobject: this.loanApp.Id, refreshPage: 'Yes' };
                publish(this.messageContext, pageRefreshOnMaterialFieldChange, payload);
            })).catch((error=>{

            }))

        }
    }
    // Previous updateLoanApp success code added below function to check tractor validation sequentially

 
    async resolveAllPromises(){
        await Promise.resolve();
        const payload = { recordIdOfSobject: this.loanApp.Id, refreshPage: 'Yes' };
        publish(this.messageContext, pageRefreshOnMaterialFieldChange, payload);
    }

    @api nextHandler() {
        if(this.isEditRestricted){
            this.showToastMessage('Access Restricted', 'Loan Details were not saved due to Insufficient Access Rights', 'warning', 'sticky');
            const Obj = {};
            Obj.next = true; 
            this.dispatchEvent(new CustomEvent('next', {
                detail: Obj
            }));         
        }else{
            this.saveLoanDetails();
        }
        
    }

    getBankAccountRecords(repaymentMode){
        console.log('repayment mode '+repaymentMode);
        console.log('bankAccountList '+this.bankAccountRecordsSI);
        /*if(this.bankAccountRecordsSI!=null){
            let casaDetails;
            let isCBS = false;
            for(var i=0;i<this.bankAccountRecordsSI.length;i++){
                if(this.bankAccountRecordsSI[i].RecordType.DeveloperName=='CBS'){
                    isCBS = true;
                    if(repaymentMode.includes('Standing Instructions')){
                        casaDetails = this.bankAccountRecordsSI[i].CASARelationDetails__c;
                        if(casaDetails!=null){
                            this.loanApp['SI_Mobile_Number__c'] = casaDetails[0].MobileNo;
                        }
                    }
                    else{
                        this.loanApp['SI_Mobile_Number__c'] = '';
                        this.showToastMessage('Note', 'You already have CASA account with AU, do you wish to change Repayment mode', 'warning');
                    }
                    
                }
            }
        }
        else{*/
            getBankRecords({
                recordId : this.recordId
            })
            .then(data => {
                console.log('data in getBankAccount '+JSON.stringify(data));
                this.bankAccountRecordsSI = data;
                let casaDetails;
                let isCBS = false;
                for(var i=0;i<data.length;i++){
                    console.log('data[] '+JSON.stringify(data[i]));
                    if(data[i].RecordType.DeveloperName=='CBS'){
                        console.log('step 2');
                        isCBS = true;
                        if(repaymentMode.includes('Standing Instructions')){
                            if(data[i].CASARelationshipDetails__c!=null){
                                casaDetails = data[i].CASARelationshipDetails__c;
                                console.log('casaDetails '+casaDetails);
                                console.log('mob no '+JSON.parse(JSON.parse(JSON.stringify(casaDetails)))[0].MobileNo);
                                this.loanApp.SI_Mobile_Number__c= JSON.parse(JSON.parse(JSON.stringify(casaDetails)))[0].MobileNo;
                                console.log('SIMobileNumber '+this.loanApp.SI_Mobile_Number__c);
                            }
                        }
                        else{
                            this.loanApp['SI_Mobile_Number__c'] = '';
                            this.showToastMessage('Note', 'You already have CASA account with AU, do you wish to change Repayment mode', 'warning', 'sticky');
                        }
                        
                    }
                }
                console.log('SIMobileNumber '+this.loanApp.SI_Mobile_Number__c);
            })
            .catch(error => {
                console.log('error in getBankAccount '+JSON.stringify(error));
            })
        //}
        
    }
    getBankName(ifsc){
        getBankName({
            ifsc:ifsc
        })
        .then(data=>{
            console.log('data '+JSON.stringify(data));
            if(data!=null){
                this.bankRecordId = data?.Id;
                console.log(this.bankRecordId);
                this.loanApp.Repayment_Bank_Name__c = data?.Bank_Name__c;
                if(this.template.querySelector('c-generic-custom-lookup')){
                    this.template.querySelector('c-generic-custom-lookup').setBankName();
                }
                var detail = {name: this.loanApp.Repayment_Bank_Name__c}
                var event={detail}
                this.handleLookupSelect(event)
            }
            //this.loanApp.Repayment_Bank_Name__c = data;
            //console.log('value '+this.loanApp.Repayment_Bank_Name__c);
            //this.bankName = data;
        })
        .catch(error=>{
            console.log('error '+JSON.stringify(error));
        })
    }

    getApplicants(){
        getApplicants({
            loanId: this.recordId
        })
        .then(data=>{
            console.log('data '+JSON.stringify(data));
            this.applicantList = data; 
            let options = [];
            for(var i=0;i<data.length;i++){
                
                options.push({
                    label : ( data[i].First_Name__c ?? '' ) + ' ' +( data[i].Last_Name__c ?? '' ) + '-' + data[i].RecordType.Name ,
                    value: JSON.stringify(data[i])
                })
                if(this.loanApp.Repayment_By__c!=null && this.loanApp.Repayment_By__c==data[i].Id){
                    console.log('repayment by '+this.loanApp.Repayment_By__c);
                    this.repaymentByValue = JSON.stringify(data[i]);
                    this.repaymentByAppl = data[i];
                    this.loanApp.Repayment_By_User__c = this.repaymentByAppl.Id;
                    this.loanApp.Repayment_By__c = (data[i].First_Name__c ? data[i].First_Name__c+ ' ' : '')+(data[i].Last_Name__c?data[i].Last_Name__c:'');
                    this.loanApp.Repayment_By_User__c = this.repaymentByAppl.Id;
                }else if(!this.loanApp.Repayment_By__c && data[i].RecordType.Name=='Applicant' && this.loanApp.Stage__c != 'QDE'){
                    this.repaymentByValue = JSON.stringify(data[i]);
                    this.repaymentByAppl = data[i];
                    this.loanApp.Repayment_By_User__c = this.repaymentByAppl.Id;
                    this.loanApp.Repayment_By__c = (data[i].First_Name__c ? data[i].First_Name__c+ ' ' : '')+(data[i].Last_Name__c?data[i].Last_Name__c:'');
                    this.loanApp.Repayment_By_User__c = this.repaymentByAppl.Id;
                }
                
            }
            this.applicantOptions = options;
            this.setRepaymentModeOption();
            
        })
        .catch(error=>{
            console.log('error '+JSON.stringify(error));
        })
    }

    handleRepaymentByChange(event){
        let applicant = JSON.parse(event.detail.value);
        this.repaymentByAppl = applicant;
        this.loanApp.Repayment_By_User__c = this.repaymentByAppl.Id;
        getApplicantBankAccountRecords({
            applId : applicant.Id
        })
        .then(data=>{
            console.log('applicant bankaccountrecords '+JSON.stringify(data));
            this.bankAccountRecords = data;
            console.log('bankaccountrecords '+JSON.stringify(this.bankAccountRecords));
            this.loanApp.Repayment_By__c = (applicant.First_Name__c?applicant.First_Name__c+' ':'') +(applicant.Last_Name__c?applicant.Last_Name__c:'');
            console.log('repayment by '+this.loanApp.Repayment_By__c);
            this.repaymentAccountNumberOptions=[];
            if(this.loanApp.Repayment_Bank_Name__c){
                this.bankAccountRecords.forEach(element => {
                    if(element.Bank_Name__c === this.loanApp.Repayment_Bank_Name__c){
                        this.repaymentAccountNumberOptions.push({label:element.Account_Number__c, value:element.Account_Number__c})
                    }
                    
                });
            }
            this.setRepaymentModeOption();

        this.manualEntryForAccNo = this.repaymentAccountNumberOptions.length == 0?true:false
        //this.loanApp.Repayment_Account_Number__c = this.repaymentAccountNumberOptions.length == 1?this.repaymentAccountNumberOptions[0].value:'';
        if(!this.manualEntryForAccNo && !this.loanApp.Repayment_Account_Number__c){
            this.loanApp.Repayment_Account_Number__c = this.repaymentAccountNumberOptions.length == 1?this.repaymentAccountNumberOptions[0].value:'';
        }
    })
        .catch(error=>{
            console.log('error in applicant bankaccountrecords '+JSON.stringify(error));
        })

    }

    getMICRCode(ifsc){
        getMICRCode({
            ifsc:ifsc
        })
        .then(data=>{
            console.log('data '+JSON.stringify(data));
            if(data){
                this.loanApp.MICR_Code__c = data;
            }
            else{
                this.loanApp.MICR_Code__c = '';
            }
        })
        .catch(error=>{
            console.log('error '+JSON.stringify(error));
        })
    }

    //SFAU-5067 - Samridhi
    vpiRecordCountValidation(){
        let vpiRecordMandatorySuccess=true;
        if(this.loanApp.Schedule_Type__c=='VPI'){
            if(this.template.querySelector('c-vpi-parent').getRecordCount() > 0){
                vpiRecordMandatorySuccess=true
            }else{
                vpiRecordMandatorySuccess=false
                this.showToastMessage('Error','Please fill VPI details in order to proceed ahead' ,'error', 'sticky');
            }
        }
        return vpiRecordMandatorySuccess;
    }

    handleOnVPIModify(event){
        if(event.detail.modified){
            this.callEMIAPI=true
            this.sliderChange = true;
        }
    }
}