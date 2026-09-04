import { LightningElement,api,track,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle } from 'lightning/platformResourceLoader';
import AUBranding from '@salesforce/resourceUrl/AUBranding';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import Loan_Number from "@salesforce/schema/Loan_Application__c.Loan_Number__c";
import Loan_Amount from "@salesforce/schema/Loan_Application__c.Loan_Amount__c";
import E_Mandate_Status__c from "@salesforce/schema/Loan_Application__c.E_Mandate_Status__c";
import EMI_Date from "@salesforce/schema/Loan_Application__c.EMI_Date__c";
import First_EMI_Date from "@salesforce/schema/Loan_Application__c.First_EMI_Date__c";
import EMI_Amount from "@salesforce/schema/Loan_Application__c.EMI__c";
import SPDC_Details__c from "@salesforce/schema/Loan_Application__c.SPDC_Details__c";
import PDC_Details__c from "@salesforce/schema/Loan_Application__c.PDC_Details__c";
import Repayment_Mode__c from "@salesforce/schema/Loan_Application__c.Repayment_Mode__c";
import Count_of_ACH_SI__c from "@salesforce/schema/Loan_Application__c.Count_of_ACH_SI__c";
import RecordTypeId from "@salesforce/schema/Loan_Application__c.RecordTypeId";
import Repayment_Bank_Name__c from "@salesforce/schema/Loan_Application__c.Repayment_Bank_Name__c";
import Repayment_Account_Number__c from "@salesforce/schema/Loan_Application__c.Repayment_Account_Number__c";
import TENURE from "@salesforce/schema/Loan_Application__c.Tenure__c";
import Emandate_Journey__c from "@salesforce/schema/Loan_Application__c.Emandate_Journey__c";
import Emandate_Payment_Type__c from "@salesforce/schema/Loan_Application__c.Emandate_Payment_Type__c";
import Stage__c from "@salesforce/schema/Loan_Application__c.Stage__c";
import LAN__c from "@salesforce/schema/Loan_Application__c.LAN__c";
//import sendEnquiryDetails from '@salesforce/apex/EMandateService.sendEnquiryDetails';
import saveDetails from '@salesforce/apex/EMandateService.saveDetails';
import sendRegistrationDetails from '@salesforce/apex/EMandateService.sendRegistrationDetails';
//import getBankAccountRecords from '@salesforce/apex/RepaymentController.getBankAccountRecords';
//import saveRepaymentDetails from '@salesforce/apex/RepaymentController.saveRepaymentDetails';
import AcceptedFileFormate from '@salesforce/label/c.AcceptedFileFormate';
import mobileOtpVerificationHandler from '@salesforce/apex/LOSMobileOtpController.mobileOtpVerificationHandler';
import OtpDurationLabel from '@salesforce/label/c.AUSF_RESEND_OTP_DURATION';
import getCASADetails from '@salesforce/apex/RepaymentController.getCASADetails';
import getDocumentRecordsData from '@salesforce/apex/RepaymentController.getDocumentRecordsData';
import deactivateDocument from '@salesforce/apex/LOSDocumentManagerController.deactivateDocument'
import { NavigationMixin } from "lightning/navigation";
import uploadSIForm from '@salesforce/apex/RepaymentController.uploadSIForm';
import uploadACHForm from '@salesforce/apex/RepaymentController.uploadACHForm';
import checkIfEsignEnabled from '@salesforce/apex/SignDeskEsignApiController.checkIfEsignEnabled'
import FORMFACTOR from '@salesforce/client/formFactor'
import My_Resource from '@salesforce/resourceUrl/ausfIcons';
import getBankName from '@salesforce/apex/RepaymentController.getBankName';
import uploadFile from '@salesforce/apex/ChecqueOCRController.chequeOcrCallOut';
import getValidBankNameAndIFSC from '@salesforce/apex/RepaymentController.getValidBankNameAndIFSC'
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import getMICRCode from '@salesforce/apex/RepaymentController.getMICRCode';
import getRecordInfo from '@salesforce/apex/RepaymentController.getRecordInfo';
import EmandateTimeout from '@salesforce/label/c.AUSF_Emandate_Timeout';
import sendSIotification from '@salesforce/apex/RepaymentController.sendSIotification'
import { refreshApex } from '@salesforce/apex';
import SPDC_Amount_Limit from '@salesforce/label/c.SPDC_Amount_Limit';

const fields = [Loan_Number,Loan_Amount, EMI_Date, EMI_Amount, SPDC_Details__c,Repayment_Mode__c,PDC_Details__c,Count_of_ACH_SI__c,TENURE,E_Mandate_Status__c,RecordTypeId,Repayment_Bank_Name__c, Emandate_Payment_Type__c, Emandate_Journey__c, Repayment_Account_Number__c,First_EMI_Date,Stage__c,LAN__c];
export default class LosRepaymentComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @track displayGenerateEsign=false
    esignFeatureEnabled=false
    esignType='SI'
    isloading = false;
    trueValue =true;
    falseValue =false;
    loanApplicantionRecord;
    referenceId;
    type;
    acceptedFormat = AcceptedFileFormate;
    errorOnChild;
    @track casaMobileNumber;
    @track isSINACH = false;
    @track showForm = false;
    @track showSubmitForm = false;
    @track bankAccountValue;
    @track bankAccountOptions = [];
    @track bankAccountObj;
    @track repaymentMode;
    @track countACHSI;
    @track listOfPDC;
    @track listOfSPDC;
    @track isfullpdc;
    @track message;
    @track htmlContentLoaded = false;
    @track isEMandate = false;
    @track paymentType;
    @track userValue;
    @track isWithoutpdc;
    @track isCountVisible;
    @track isSI = false;
    @track showPDF = false;
    @track showBankAccount = false;
    @track iframeSrc;
    @track mobileNumber;
    @track isVerifiedNumber = false;
    @track isReadOnly = false;
    @track boolSendOtp = true;
    @track boolCheckMobileNumber = true;
    @track boolResendOtp = false;
    @track isVerified = false;
    @track isEnterOtp = false;
    @track enterOTPValue;
    @track boolRequestOtp = false;
    @track showMobile = false;
    @track boolVerify = true;
    @track showSubmit = false;
    @track disableRegisterButton = false;
    @track disableFetchButton = true;
    @track increse1Second;
    @track callbackStatus = '';
    @track docDataReceived=false
    @track disableEsign=true
    @track isSmallDevice=false
    @track isLargeDevice=false
    @track displayEsignButton=false
    @track isGenerateDisabled=true;
    @track bankRecordId;
    @track assignmentRecordId;
    @track isEditRestricted
    displayRepaymentSection=true
    generateFormIcon      = My_Resource + '/ausfIcons/Generate-E-sign.png';
    generateEsignIcon      = My_Resource + '/ausfIcons/Generate-E-sign.png';
    loanTenure;
    loanAmount;
    repaymentAccountNumber;
    repaymentBankAccount;
    onLoad = false;
    trueValue = true;
    falseValue = false;
    fileData;
    pdcNegative=false;
    spdcNegative=false;
    timeoutEvent;
    timeSpan = 60000;
    @track docName = '';
    @track showGenericUpload = false;
    @track showGenericUploadPdc = false;
    @track uploadChequeRowIndex;
    @track userOption = [{label: 'By Customer', value: 'Yes'},{label: 'By RO', value: 'No'}];
    @track paymentTypeOption = [{label: 'Debit Card', value: 'DebitCard'},{label: 'Net Banking', value: 'NetBanking'},{label: 'Aadhaar', value: 'Aadhaar'}]; 
    @track boolAccessRestrict = false; // SFAU-4066
    @track loanStage='';
    @track loanLAN ='';
    @wire(getRecord, {
        recordId: "$recordId",
        fields
    })
    wiredRecord({ error, data }) {
        if (data) {
            this.loanApplicantionRecord = data;
            this.countACHSI = getFieldValue(this.loanApplicantionRecord, Count_of_ACH_SI__c);
            this.repaymentMode = getFieldValue(this.loanApplicantionRecord, Repayment_Mode__c);
            this.loanAmount = getFieldValue(this.loanApplicantionRecord, Loan_Amount);
            this.loanTenure = getFieldValue(this.loanApplicantionRecord, TENURE);
            this.callbackStatus = getFieldValue(this.loanApplicantionRecord,E_Mandate_Status__c);
            this.repaymentAccountNumber = getFieldValue(this.loanApplicantionRecord,Repayment_Account_Number__c);
            this.repaymentBankAccount = getFieldValue(this.loanApplicantionRecord,Repayment_Bank_Name__c);
            let val = getFieldValue(this.loanApplicantionRecord,Emandate_Journey__c);
            this.loanStage = getFieldValue(this.loanApplicantionRecord,Stage__c);
            this.loanLAN = getFieldValue(this.loanApplicantionRecord,LAN__c);

            if( this.loanLAN!=null && (this.loanStage== 'Ops Maker' || this.loanStage == 'Ops Author' || this.loanStage == 'PDD')){ //SFAU - 4066
                this.boolAccessRestrict = true;
            }else{
                this.boolAccessRestrict = false;
            }

            if (this.listOfPDC?.length == 1 && (this.listOfPDC[0].bankName === undefined || this.listOfPDC[0].bankName == null)) {
                this.listOfPDC[0].bankName = this.repaymentBankAccount;
                this.listOfPDC[0].bankNumber = this.repaymentAccountNumber;
            }
            if (this.listOfSPDC?.length == 1 && (this.listOfSPDC[0].bankName === undefined || this.listOfSPDC[0].bankName == null)) {
                this.listOfSPDC[0].bankName = this.repaymentBankAccount;
                this.listOfSPDC[0].bankNumber = this.repaymentAccountNumber;
            }
            this.htmlContentLoaded = true;
            if(val=='By Customer'){
                this.userValue = 'Yes';
            }
            else if(val=='By RO'){
                this.userValue = 'No';
            }
            this.paymentType = getFieldValue(this.loanApplicantionRecord,Emandate_Payment_Type__c);
            if(this.callbackStatus=='Accepted'){
                this.disableRegisterButton = true;
                this.disableFetchButton = false;
            }
            else if(this.callbackStatus=='Rejected'){
                this.disableRegisterButton = false;
                this.disableFetchButton = true;
            }
            //this.getBankAccountData();
            console.log('Data>>>'+JSON.stringify(data));
            if(this.repaymentMode && (this.repaymentMode.includes('NACH') || this.repaymentMode.includes('Standing Instructions'))){
                this.isCountVisible = true;
                this.isSINACH = true;
                //this.showBankAccount = true;
            if(this.repaymentMode && (this.repaymentMode.includes('E mandate') || this.repaymentMode.includes('Standing Instructions'))){
                    this.iframeSrc = '/apex/RepaymentSIVFPage?recordid='+this.recordId;
                    this.showMobile = true;
                    this.isSI = true;
                    this.getCASADetails();
                    this.isGenerateDisabled = false;
                    this.isReadOnly = false;
                }
                else{
                    this.iframeSrc = '/apex/RepaymentACHVFPage?recordid='+this.recordId;
                    this.isGenerateDisabled = false;
                }
            }
            if(this.repaymentMode && this.repaymentMode.includes('E mandate')){
                this.isEMandate = true;
                //this.showBankAccount = true;
            }
            let recordTypeInfo = this.loanApplicantionRecord.recordTypeInfo.name
            let emandateLimitForCommercial = this.repaymentMode.includes('E mandate') && recordTypeInfo=='Commercial Vehicle' && recordTypeInfo=='Construction_Equipment' && this.loanAmount > parseInt(SPDC_Amount_Limit)
            if(this.repaymentMode && (this.repaymentMode.includes('NACH') || ((this.repaymentMode.includes('E mandate') && this.loanAmount > 1000000) || emandateLimitForCommercial))){
                this.type = 'SPDC';
                this.docName = 'AUWheels0079';
                this.docTypeName = 'SPDC';
                this.isWithoutpdc = true;
                this.showSubmit = true;
            }
            if(getFieldValue(this.loanApplicantionRecord, SPDC_Details__c)!=null){
                let temp = JSON.parse(getFieldValue(this.loanApplicantionRecord, SPDC_Details__c).replaceAll("\\",''));
                console.log('temp '+temp);
                console.log('list of spdc '+JSON.stringify(this.listOfSPDC));
                let listOfData = [];
                for (var i = 0; i < temp.length; i++){
                    if(i>0){
                        this.createRow(this.listOfSPDC,'SPDC');
                    }
                    var obj = temp[i];
                    let spdcObject = {};
                    if(listOfData.length > 0) {
                        spdcObject.index = listOfData[listOfData.length - 1].index + 1;
                        spdcObject['key'] = 'spdc'+(listOfData[listOfData.length - 1].index + 1);
                    } else {
                        spdcObject.index = 1;
                        spdcObject['key'] = 'spdc'+1;
                    }
                    console.log('Object '+JSON.stringify(obj));
                    for (var key in obj){
                        var value = obj[key];
                        spdcObject[key] = value;
                    }
                    listOfData.push(spdcObject);
                    console.log('obj '+JSON.stringify(spdcObject));
                }
                this.docName = 'AUWheels0079';
                this.docTypeName = 'SPDC';
                this.listOfSPDC = listOfData;
                this.htmlContentLoaded = true;
                console.log('list of spdc '+JSON.stringify(this.listOfSPDC));
            }
            
            if(this.repaymentMode=='Full PDC'){
                this.type = 'PDC';
                this.isfullpdc = true;
                //this.isWithoutpdc = true;
                this.showSubmit = true;
                this.docName = 'AUWheels0080';
                this.docTypeName = 'PDC';
            }
            if(getFieldValue(this.loanApplicantionRecord, PDC_Details__c)!=null){
                let temp = JSON.parse(getFieldValue(this.loanApplicantionRecord, PDC_Details__c).replaceAll("\\",''));
                console.log('temp '+temp);
                console.log('list of spdc '+JSON.stringify(this.listOfPDC));
                let listOfData = [];
                for (var i = 0; i < temp.length; i++){
                    if(i>0){
                        this.createRow(this.listOfPDC,'PDC');
                    }
                    var obj = temp[i];
                    let pdcObject = {};
                    if(listOfData.length > 0) {
                        pdcObject.index = listOfData[listOfData.length - 1].index + 1;
                        pdcObject['key'] = 'pdc'+(listOfData[listOfData.length - 1].index + 1);
                    } else {
                        pdcObject.index = 1;
                        pdcObject['key'] = 'pdc'+1;
                    }
                    console.log('Object '+JSON.stringify(obj));
                    for (var key in obj){
                        var value = obj[key];
                        pdcObject[key] = value;
                    }
                    listOfData.push(pdcObject);
                    console.log('obj '+JSON.stringify(pdcObject));
                }
                this.listOfPDC = listOfData;
                this.htmlContentLoaded = true;
                console.log('list of spdc '+JSON.stringify(this.listOfPDC));
            }
            /* this.applicantType = data.fields.Loan_Number__c.value;
            this.proposedVehicle = data.fields.Loan_Amount__c.value;
            this.typeOfAddress = data.fields.EMI_Date__c.value;
            this.applicantId=data.fields.EMI__c.value;  */
        }
        if(error){
            console.log('error '+JSON.stringify(error));
        }

    }
    get loanNumber() {
        return getFieldValue(this.loanApplicantionRecord, Loan_Number);
    }
    get emiAmount(){
        return getFieldValue(this.loanApplicantionRecord, EMI_Amount);
    }
    get emiDate(){
        return getFieldValue(this.loanApplicantionRecord, First_EMI_Date);
    }
    get repaymentModeOption() {
        return [
            { label: 'NACH without PDC', value: 'NACH without PDC' },
            { label: 'NACH with PDC', value: 'NACH with PDC' },
            { label: 'E mandate without PDC', value: 'E mandate without PDC' },
            { label: 'E mandate with PDC', value: 'E mandate with PDC' },
            { label: 'Standing Instructions', value: 'Standing Instructions' },
            { label: 'Full PDC', value: 'Full PDC' }
        ];
    }
    
    connectedCallback(){
        this.initData('PDC');
        this.initData('SPDC');
        console.log('losRepaymentComponent recordId'+this.recordId);
        console.log('losRepaymentComponent objectApiName'+this.objectApiName);
        if(FORMFACTOR == 'Small'){
            this.isSmallDevice = true
            this.isLargeDevice=false
        }else{
            this.isSmallDevice = false
            this.isLargeDevice=true
        }
        if(this.objectApiName == 'Assignment__c'){
            getRecordInfo({
                id : this.recordId
            })
            .then(data=>{
                console.log('data '+JSON.stringify(data));
                this.assignmentRecordId = this.recordId;
                if(data!=null){
                    this.recordId =data;
                    refreshApex(this.loanApplicantionRecord);
                    //this.isComplete = data['Status__c']=='Complete'?true:false;
                    this.getData();
                }
            })
            .catch(error=>{
                console.log('error '+JSON.stringify(error));
            })
        }else{
            this.getData();
        }
       
        
    }

    //4733
    setIsEditRestricted(){
        restricAccess({
            compName: 'losRepaymentComponent' ,loanId: this.recordId}).then(data => {
                this.isEditRestricted=data
            }).catch((error=>{

            }))
        
    }

    getData(){
        this.getDocRecords();
        this.checkIfEsignFeatureEnabled();
        this.setIsEditRestricted()
    }

    checkIfEsignFeatureEnabled(){
        checkIfEsignEnabled().then((data=>{
            this.esignFeatureEnabled = data;
        }))
    }

    @track propertyDocListToBeDisplayed = [];
    @track doc = {};
    @track spdc = {};
    @track pdc = {};

    handleSuccess(event){
        if(event.detail.isSuccess){
            this.getDocRecords();
        }
    }
    getDocRecords(){
        this.isloading = true;
        getDocumentRecordsData({loanId : this.recordId})
        .then((result) => {
            this.isloading = false;
            let parseResult=JSON.parse(result);
            if(parseResult.isSuccess && parseResult.docChkRecords){
                this.propertyDocListToBeDisplayed = [];
                setTimeout(() => {
                    this.propertyDocListToBeDisplayed = parseResult.docChkRecords;
                    parseResult.docChkRecords.forEach(element => {
                        if(element.docName.Document_Master__r.Document_Name__c == 'NACH'){
                            this.doc = element;
                            this.docDataReceived=true
                            if(this.repaymentMode && this.repaymentMode.includes('Standing Instructions')){
                                this.displayEsignButton=true
                                //this.template.querySelector('[data-id="signDeskEsignButton"]').classList.remove('slds-hide')
                            }
                        }else if(element.docName.Document_Master__r.Document_Name__c == 'PDC'){
                            this.pdc = element;
                            this.docDataReceived=true
                        }else if(element.docName.Document_Master__r.Document_Name__c == 'SPDC'){
                            this.spdc = element;
                            this.docDataReceived=true
                            console.log('test 1234'+JSON.stringify(this.spdc.filesList))
                        }
                    });
               //     this.doc = this.propertyDocListToBeDisplayed[0];
               }, 100); 
            }else{
                console.log('No result found.');
                console.log('Error message'+parseResult.message);
            }
            this.isloading = false;
        })
        .catch((error) => {

            console.log('error-->' + JSON.stringify(error));
            this.isloading = false;
        })
        .finally(() => {                
           
        })
    }
    renderedCallback(){
        Promise.all([
            loadStyle( this, AUBranding )
            ]).then(() => {
                console.log( 'Branding Loaded Success!!' );
            })
            .catch(error => {
                console.log( error?.body?.message );
        });
        /*if(!this.htmlContentLoaded && this.template.querySelector('[data-id="htmlContent"]')){
            this.template.querySelector('[data-id="htmlContent"]').innerHTML = this.message;
            this.htmlContentLoaded = true;
        }*/
        if(this.htmlContentLoaded && (this.onLoad==false)){
            if(this.repaymentMode && this.repaymentMode=='Full PDC'){
                for(let i = 0; i < this.listOfPDC.length; i++) {
                    //console.log('index'+this.listOfSPDC[i].index);
                    if(this.listOfPDC[i].bankName!=null){
                        let elements = this.template.querySelector('c-generic-custom-lookup[data-id="'+this.listOfPDC[i].key+'"]');
                        console.log('lookup '+JSON.stringify(elements)+' key '+this.listOfPDC[i].key);
                        this.template.querySelector('c-generic-custom-lookup[data-id="'+this.listOfPDC[i].key+'"]')?.setDefaultBankName(this.listOfPDC[i].bankName);
                    }
                }
            }
            else{
                for(let i = 0; i < this.listOfSPDC.length; i++) {
                    //console.log('index'+this.listOfSPDC[i].index);
                    if(this.listOfSPDC[i].bankName!=null){
                        let elements = this.template.querySelector('c-generic-custom-lookup[data-id="'+this.listOfSPDC[i].key+'"]');
                        console.log('lookup '+JSON.stringify(elements)+' key '+this.listOfSPDC[i].key);
                        this.template.querySelector('c-generic-custom-lookup[data-id="'+this.listOfSPDC[i].key+'"]')?.setDefaultBankName(this.listOfSPDC[i].bankName);
                    }
                }
            }
            this.onLoad = true;
        }
        if(this.template.querySelector('c-generic-custom-lookup[data-id="'+this.listOfPDC[this.listOfPDC.length-1].key+'"]')){
            this.template.querySelector('c-generic-custom-lookup[data-id="'+this.listOfPDC[this.listOfPDC.length-1].key+'"]')?.setDefaultBankName(this.listOfPDC[this.listOfPDC.length-1].bankName);
        }
        if(this.template.querySelector('c-generic-custom-lookup[data-id="'+this.listOfSPDC[this.listOfSPDC.length-1].key+'"]')){
            this.template.querySelector('c-generic-custom-lookup[data-id="'+this.listOfSPDC[this.listOfSPDC.length-1].key+'"]')?.setDefaultBankName(this.listOfSPDC[this.listOfSPDC.length-1].bankName);
        }
    }
    initData(type){
        if(type =='PDC'){
            let listOfPDC = [];
            this.createRow(listOfPDC,type);
            this.listOfPDC = listOfPDC;
        }
        if(type =='SPDC'){
            let listOfSPDC = [];
            this.createRow(listOfSPDC,type);
            this.listOfSPDC = listOfSPDC;
        }

    }
    createRow(listOfData,type) {
        if(type =='PDC'){
            let pdcObject = {};
            if(listOfData.length > 0) {
                pdcObject.index = listOfData[listOfData.length - 1].index + 1;
                pdcObject.key = 'pdc'+pdcObject.index;
            } else {
                pdcObject.index = 1;
                pdcObject.key = 'pdc1';
            }
            pdcObject.countPDC = null;
            //pdcObject.pdcChequeNumber = null;
            pdcObject.bankNumber = this.repaymentAccountNumber;
            pdcObject.ifsc = null;
            pdcObject.pdcChequeNumberFrom = null;
            pdcObject.pdcChequeNumberTo = null;
            pdcObject.bankName = this.repaymentBankAccount;
            pdcObject.micr = null;
            if(this.listOfPDC?.length>=1){
                pdcObject.bankName = pdcObject.bankName === null ? this.listOfPDC[this.listOfPDC?.length-1].bankName : pdcObject.bankName;
                pdcObject.bankNumber = pdcObject.bankNumber === null ? this.listOfPDC[this.listOfPDC?.length-1].bankNumber : pdcObject.bankNumber;
                pdcObject.ifsc = this.listOfPDC[this.listOfPDC?.length-1].ifsc;
                pdcObject.micr = this.listOfPDC[this.listOfPDC?.length-1].micr;
            }
            listOfData.push(pdcObject);
        }
        if(type =='SPDC'){
            let spdcObject = {};
            if(listOfData.length > 0) {
                spdcObject.index = listOfData[listOfData.length - 1].index + 1;
                spdcObject.key = 'spdc'+spdcObject.index;
            } else {
                spdcObject.index = 1;
                spdcObject.key = 'spdc1';
            }
            spdcObject.countSPDC = null;
            //spdcObject.spdcChequeNumber = null;
            spdcObject.spdcChequeNumberFrom = null;
            spdcObject.spdcChequeNumberTo = null;
            spdcObject.bankName = this.repaymentBankAccount;
            spdcObject.bankNumber = this.repaymentAccountNumber;
            spdcObject.ifsc = null;
            spdcObject.micr = null;
            //spdcObject.defaultRecordId = null;
            if(this.listOfSPDC?.length>=1){
                spdcObject.bankName = spdcObject.bankName === null ? this.listOfSPDC[this.listOfSPDC?.length-1]?.bankName : spdcObject.bankName;
                spdcObject.bankNumber = spdcObject.bankNumber === null ? this.listOfSPDC[this.listOfSPDC?.length-1]?.bankNumber : spdcObject.bankNumber;
                spdcObject.ifsc = this.listOfSPDC[this.listOfSPDC?.length-1]?.ifsc;
                spdcObject.micr = this.listOfSPDC[this.listOfSPDC?.length-1]?.micr;
            }
            listOfData.push(spdcObject);
        }
    }
    addNewRow(event) {
        if(this.isEditRestricted){
            this.showToastEvent('Access Restricted','You do not have access to add Repayment details','error');
            return
        }//4733
        let tableName = event.target.dataset.id;
        console.log('tableName'+tableName);
        if(tableName=='PDC'){
            this.createRow(this.listOfPDC,tableName);
        }
        if(tableName=='SPDC'){
            this.createRow(this.listOfSPDC,tableName);
        }
    }
    removeRow(event) {
        if(this.isEditRestricted){
            this.showToastEvent('Access Restricted','You do not have access to remove Repayment details','error');
            return
        }//4733
        let tableName = event.target.dataset.id;
        console.log('tableName'+tableName);
        let toBeDeletedRowIndex = event.target.name;
        if(tableName=='PDC'){
            if(this.listOfPDC.length==1){
                this.showToastEvent('Error','All rows cannot be deleted','error');
                return;
            }
            let listOfPDC = [];
            for(let i = 0; i < this.listOfPDC.length; i++) {
                let tempRecord = Object.assign({}, this.listOfPDC[i]); //cloning object
                if(tempRecord.index !== toBeDeletedRowIndex) {
                    listOfPDC.push(tempRecord);
                }
            }
    
            for(let i = 0; i < listOfPDC.length; i++) {
                listOfPDC[i].index = i + 1;
            }
            this.listOfPDC = listOfPDC;
        }
        if(tableName=='SPDC'){
            if(this.listOfSPDC.length==1){
                this.showToastEvent('Error','All rows cannot be deleted','error');
                return;
            }
            let listOfSPDC = [];
            for(let i = 0; i < this.listOfSPDC.length; i++) {
                let tempRecord = Object.assign({}, this.listOfSPDC[i]); //cloning object
                if(tempRecord.index !== toBeDeletedRowIndex) {
                    listOfSPDC.push(tempRecord);
                }
            }
    
            for(let i = 0; i < listOfSPDC.length; i++) {
                listOfSPDC[i].index = i + 1;
            }
            this.listOfSPDC = listOfSPDC;
        }

    }
    handleInputChange(event) {
        let tableName = event.target.dataset.title;
        console.log('tableName'+tableName);
        let index = event.target.dataset.id;
        let fieldName = event.target.name;
        let value = event.target.value;
        if(fieldName=='bankName'){
            value = event.detail.name;
            index = event.target.dataset.index;
            console.log('bank value '+value);
            //this.getDefaultBankRecord(value,index);
        }
        
        if(fieldName=='ifsc' && value.length==11){
            console.log('in ifsc '+value);
            this.getBankName(value,index,tableName);
            this.getMICRCode(value,index,tableName);
        }
        if(tableName=='PDC'){
            for(let i = 0; i < this.listOfPDC.length; i++) {
                if(this.listOfPDC[i].index === parseInt(index)) {
                    this.listOfPDC[i][fieldName] = value;
                    console.log('list of pdc '+JSON.stringify(this.listOfPDC));
                    if(this.listOfPDC[i]['pdcChequeNumberFrom']!=null && this.listOfPDC[i]['pdcChequeNumberTo']!=null){
                        console.log(' from '+this.listOfPDC[i]['pdcChequeNumberFrom']+' to '+this.listOfPDC[i]['pdcChequeNumberTo']);
                        this.listOfPDC[i]['countPDC'] = this.listOfPDC[i]['pdcChequeNumberTo'] - this.listOfPDC[i]['pdcChequeNumberFrom'] + 1;
                        console.log('count '+this.listOfPDC[i]['countPDC']);
                    }
                }
            }
        }
        if(tableName=='SPDC'){
            for(let i = 0; i < this.listOfSPDC.length; i++) {
                if(this.listOfSPDC[i].index === parseInt(index)) {
                    this.listOfSPDC[i][fieldName] = value;
                    console.log('list of spdc '+JSON.stringify(this.listOfSPDC));
                    if(this.listOfSPDC[i]['spdcChequeNumberFrom']!=null && this.listOfSPDC[i]['spdcChequeNumberTo']!=null){
                        console.log(' from '+this.listOfSPDC[i]['spdcChequeNumberFrom']+' to '+this.listOfSPDC[i]['spdcChequeNumberTo']);
                        this.listOfSPDC[i]['countSPDC'] = this.listOfSPDC[i]['spdcChequeNumberTo'] - this.listOfSPDC[i]['spdcChequeNumberFrom'] + 1;
                        console.log('count '+this.listOfSPDC[i]['countSPDC']);
                    }
                }
            }
        }
        //Below condition block added as a part of Bug-2964
        if(fieldName=='ifsc'){
            console.log('listOfSPDC '+JSON.stringify(this.listOfSPDC));
            console.log('listOfPDC '+JSON.stringify(this.listOfPDC));
            
            if(this.type=='SPDC'){
                let obj = this.listOfSPDC.find(o=>o.index === parseInt(index));
                obj.ifsc = value.toUpperCase();
                console.log('uppercase '+value.toUpperCase());
                
            }
            if(this.type=='PDC'){
                let obj = this.listOfPDC.find(o=>o.index === parseInt(index));
                obj.ifsc = value.toUpperCase();
                console.log('uppercase '+value.toUpperCase());
                
            }
        }
        console.log('this.listOfPDC'+this.listOfPDC);
        console.log('this.listOfPDCJSON'+JSON.stringify(this.listOfPDC));
        console.log('this.listOfSPDC'+this.listOfSPDC);
        console.log('this.listOfSPDCJSON'+JSON.stringify(this.listOfSPDC));
    }

    showToastEvent(titleValue, messageValue, variantValue) {
        const event = new ShowToastEvent({
            title: titleValue,
            message: messageValue,
            variant: variantValue
        });
        this.dispatchEvent(event);
    }

    async submitClickHelper(){
        let isSaved=false
        this.pdcNegative = false;
        this.spdcNegative = false;
        let countOfSPDC=0
        console.log('list '+JSON.stringify(this.listOfSPDC));
        console.log('list '+JSON.stringify(this.listOfPDC));
        const elements = this.template.querySelectorAll('lightning-combobox');
        elements.forEach(input=>{
            if(input.name=='Repayment Mode'){
                this.repaymentMode = input.value;
            }
        })
        let selectedIfscCodes = [];
        let selectedIfscVsBank = []
        console.log('repayment mode '+this.repaymentMode);
        let countOfChecks = 0;
        if(this.type=='PDC'){
            for (var i = 0; i < this.listOfPDC.length; i++) { 
                console.log('count '+this.listOfPDC[i].countPDC);
                countOfChecks = countOfChecks +  parseInt(this.listOfPDC[i].countPDC);
                if(this.listOfPDC[i].countPDC<0){
                    this.pdcNegative = true;
                }
                selectedIfscCodes.push(this.listOfPDC[i].ifsc)
                selectedIfscVsBank.push({label: this.listOfPDC[i].ifsc, value: this.listOfPDC[i].bankName })
            }
            console.log('countofchecks '+countOfChecks+' tenure '+this.loanTenure);
        }
        else if(this.type=='SPDC'){
            for (var i = 0; i < this.listOfSPDC.length; i++) {
                countOfSPDC = countOfSPDC +  parseInt(this.listOfSPDC[i].countSPDC);
                console.log('count '+this.listOfSPDC[i].countSPDC);
                if(this.listOfSPDC[i].countSPDC<0){
                    this.spdcNegative = true;
                }
                selectedIfscCodes.push(this.listOfSPDC[i].ifsc)
                selectedIfscVsBank.push({label: this.listOfSPDC[i].ifsc, value: this.listOfSPDC[i].bankName })
            }
        }
        
        let validIFSCs = await getValidBankNameAndIFSC({selectedPdcIfscCodes: selectedIfscCodes});//await getValidBankNameAndIFSC({selectedPdcIfscCodes: selectedIfscCodes})
        let isincorrect
        let incorrectIFSCmessage
        if(validIFSCs && validIFSCs.length>0){
            
            let ifscVsBank = new Map()
            validIFSCs.forEach(input1=>{
                ifscVsBank.set(input1.IFSC__c, input1.Bank_Name__c)
            })
            
            selectedIfscVsBank.forEach((input=>{
                if(!ifscVsBank.has(input.label) || input.value != ifscVsBank.get(input.label)){
                    isincorrect=true
                    incorrectIFSCmessage = 'Mismatch in IFSC Code and Bank Name : '+input.label+' - '+input.value
                }
            }))
        }

        countOfSPDC = (isNaN(countOfSPDC))?0:countOfSPDC
        countOfChecks = (isNaN(countOfChecks))?0:countOfChecks
        if((this.type=='PDC' && countOfChecks<=0 && !this.pdcNegative) || (this.type=='SPDC' && countOfSPDC<=0 && !this.spdcNegative)){//R2-2643
            this.showToastEvent('Error','Atlease one SPDC is mandatory','error');
        }
        else if(isincorrect){
            this.showToastEvent('Error',incorrectIFSCmessage,'error');
        }
        else if(this.type=='PDC' && this.pdcNegative){
            this.showToastEvent('Error','Cheque Number To cannot be less than Cheque Number From','error');
        }
        else if(this.type=='SPDC' && this.spdcNegative){
            this.showToastEvent('Error','Cheque Number To cannot be less than Cheque Number From','error');
        }
        else if(this.repaymentMode=='Full PDC' && countOfChecks!=this.loanTenure){
            this.showToastEvent('Error','Count of cheque should be equal to Tenure','error');
        }
        else{
            /*elements = this.template.querySelectorAll('lightning-input');
            
            let countOfACH='';
            elements.forEach(input=>{
                if(input.name=='Count of ACH / SI'){
                    countOfACH = input.value;
                }
            })*/
            console.log('count '+this.countACHSI);
            let count = this.countACHSI;
            if(this.countACHSI==='undefined'){
                count = -1;
            }
            let resp = await saveDetails({
                pdcList : JSON.stringify(this.listOfPDC),
                spdcList : JSON.stringify(this.listOfSPDC),
                loanId: this.recordId,
                type : this.type,
                repaymentMode : this.repaymentMode,
                countOfAchSi : count
            })
            if(resp){
                console.log('data in save '+JSON.stringify(resp));
                this.showToastEvent('Success','Record saved successfully','success');
                return true
            }
            /*.then(data =>{
                isSaved=true
                console.log('data in save '+JSON.stringify(data));
                this.showToastEvent('Success','Record saved successfully','success');
                //return isSaved
            })
            .catch(error=>{
                console.log('error in save '+JSON.stringify(error));
            })*/
        }
        
    }

    checkChequeValidity(){
        let isValidAll = [
            ...this.template.querySelectorAll(".cheque")
        ].reduce((validSoFar, input) => {
            input.reportValidity();
            return validSoFar && input.checkValidity();
        }, true);
        return isValidAll;
     }

    async submitClick(){
        if(!this.checkChequeValidity()){
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Please enter valid cheque number',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(evt);
            return;
        }
        let recordTypeInfo = this.loanApplicantionRecord.recordTypeInfo.name
        let emandateLimitForCommercial = this.repaymentMode.includes('E mandate') && recordTypeInfo=='Commercial_Vehicle' && recordTypeInfo=='Construction_Equipment' && this.loanAmount > parseInt(SPDC_Amount_Limit)
        if((this.repaymentMode.includes('NACH') || ((this.repaymentMode.includes('E mandate') && this.loanAmount > 1000000)) || emandateLimitForCommercial) && (!this.isReturnedFromPaymentFavouring) && (!this.listOfSPDC.length)){
            // this.type = 'SPDC';
            // this.docName = 'AUWheels0079';
            // this.docTypeName = 'SPDC';
            // this.isWithoutpdc = true;
            // this.showSubmit = true;
            this.renderChargesInstructionModal = true;
            return;
        }
        restricAccess({
            compName: 'losRepaymentComponent' ,loanId: this.recordId
            }).then(data => {
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save Repayment details',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
                else{
                    this.submitClickHelper();
                }

            }).catch(error=>{
                console.log('error is ' + JSON.stringify(error));

            })
        
    }

    /*enquireStatus(){
        sendEnquiryDetails({
            loanId: this.recordId
        })
        .then(data => {
            console.log('data in enquiry '+JSON.stringify(data));
        })
        .catch(error => {
            console.log('error in enquiry '+JSON.stringify(error));
        })
    }*/

    handleChange(event) {
        console.log('name '+event.detail.name);
        console.log('value '+event.detail.value);
        let value = event.detail.value;

        if(event.target.name=='Repayment Mode' && value.includes('E mandate')){
            this.repaymentMode = value;
            this.isEMandate = true;
            
            //this.showBankAccount = true;
            //this.getBankAccountData();
        }
        else if(event.target.name=='Repayment Mode'){
            this.repaymentMode = value;
            this.isEMandate = false;
        }
        if(event.target.name=='With_User' ){
            this.userValue = event.detail.value;
        }
        let recordTypeInfo = this.loanApplicantionRecord.recordTypeInfo.name
        let emandateLimitForCommercial = this.repaymentMode.includes('E mandate') && recordTypeInfo=='Commercial_Vehicle' && recordTypeInfo=='Construction_Equipment' && this.loanAmount > parseInt(SPDC_Amount_Limit)
        if(event.target.name=='Repayment Mode' && !(value.includes('NACH') || ((this.repaymentMode.includes('E mandate') && this.loanAmount > 1000000) || emandateLimitForCommercial))){
            this.isWithoutpdc = false;
            this.isfullpdc = false;
            this.type = '';
            if(value.includes('Full PDC')){
                this.type = 'PDC';
                this.isfullpdc = true;
            }
        }
        else if(event.target.name=='Repayment Mode'){
            this.type = 'SPDC';
            this.isWithoutpdc = true;
            this.isfullpdc = false;
            
        }
        if(event.target.name=='Repayment Mode' &&(value.includes('NACH') || value.includes('Standing Instructions'))){
            this.isCountVisible = true;
            this.isSINACH = true;
            //this.showBankAccount = true;
            //this.getBankAccountData();
            if(value.includes('Standing Instructions')){
                this.iframeSrc = '/apex/RepaymentSIVFPage?recordid='+this.recordId;
                this.showMobile = true;
                this.isSI = true;
                if(this.isVerified == false){
                    this.isSINACH = false;
                }
                this.getCASADetails();
            }
            else{
                this.isSI = false;
                this.iframeSrc = '/apex/RepaymentACHVFPage?recordid='+this.recordId;
                this.showMobile = false;
            }
        }
        else if(event.target.name=='Repayment Mode'){
            this.isCountVisible = false;
            this.isSI = false;
            this.showMobile = false;
            this.isSI = false;
            this.isSINACH = false;
        }
        /*if(event.target.name=='BankAccount'){
            console.log('BA '+JSON.stringify(event.detail.value));
            this.bankAccountObj = event.detail.value;
            this.bankAccountValue = event.detail.value.Bank_Name__c;
        }*/
        /*if(event.target.name=='Repayment Mode' && value.includes('Standing Instructions')){
            this.isSI = true;
        }*/
    }
    getCASADetails(){
        getCASADetails({
            loanId : this.recordId
        })
        .then(data =>{
            console.log(data);
            let obj = JSON.parse(JSON.parse(JSON.stringify(data)));
            if(data!=null){
                console.log('data.casa '+JSON.stringify(obj[0]));
                this.casaMobileNumber = obj[0].MobileNo;
                console.log('mob '+this.casaMobileNumber);
                this.boolCheckMobileNumber = false;
                this.boolSendOtp = true;
                this.isVerifiedNumber = true;
            }
            
        })
        .catch(error =>{
            console.log(JSON.stringify(error));
        })
    }
    achSIChange(event){
        this.countACHSI = event.detail.value;
    }
    registerAPI(){
        const elements = this.template.querySelectorAll('lightning-combobox');
        elements.forEach(input=>{
            if(input.name=='With_User'){
                this.userValue = input.value;
            }
            if(input.name=='Payment Type'){
                this.paymentType = input.value;
            }
        })
        if(this.userValue=='No'){
            this.showSubmitForm = true;
        }
        this.disableRegisterButton = true;
        this.event1 = setTimeout(() => {
            this.disableRegisterButton = false;
          }, EmandateTimeout);

        this.isloading = true;
        sendRegistrationDetails({
            loanId: this.recordId,
            userConfirmation: this.userValue,
            paymentType: this.paymentType
        })
        .then(data => {
            console.log('E mandate registration data '+JSON.stringify(data));
            if(this.userValue=='No'){
                if(data==null){
                    this.showToastEvent('Error','Something went wrong','error');
                }
                else if(data['Status']!=null && data['Status'].includes('Rejected')){
                    this.isloading = false;
                    this.showSubmitForm = false;
                    this.showToastEvent('Error',data['Description'],'error');
                }
                else if(data['Messgae']==null){
                    this.showToastEvent('Error','Internal Server Error','error');
                    this.isloading = false;
                }
                else{
                    // commented this for SFAU-3766
                    //this.disableRegisterButton = true;
                    console.log('disable register button '+this.disableRegisterButton);
                    this.message = data['Messgae'];
                    this.isloading = false;
                    //this.template.querySelector('[data-id="htmlContent"]').innerHTML = this.message;
                    const node = document.createElement("input");
                    const att = document.createAttribute("type");
                    att.value = "submit";
                    const att2 = document.createAttribute("hidden");
                    att2.value = "true";
                    node.setAttributeNode(att);
                    node.setAttributeNode(att2);
                    //document.getElementById("eMandateForm").innerHTML = event.data;
                    console.log('Message before replacing  '+JSON.stringify(this.message));
                    //this.message = this.message.replaceAll('&lt;','<').replaceAll('&gt;','>').replaceAll('&amp;','&').replaceAll('&quot;','\"');
                    //console.log('Message after replacing  '+JSON.stringify(this.message));
                    let msg = this.message.substring(this.message.lastIndexOf('MandateReqDoc'));
                    //msg = this.message.substring(msg.indexOf('value'));
                    console.log('index '+msg);
                    let mandateValue = msg.substring(msg.indexOf('value')+7,msg.indexOf("\'/><input"));
                    console.log('value '+mandateValue);
                    var txt = document.createElement("textarea");
                    txt.innerHTML = mandateValue;
                    mandateValue =  txt.value;
                    
                    this.template.querySelector('[data-id="htmlContent"]').innerHTML = this.message;
                    document.getElementById("TheForm").appendChild(node);
                    const attr = document.createAttribute("value");
                    attr.value = mandateValue;
                    const node1 = document.getElementById("MandateReqDoc");
                    node1.setAttributeNode(attr);
                    console.log(document.getElementById("MandateReqDoc").value);
                    const formNode = document.getElementById("TheForm");
                    const formAttr = document.createAttribute("target");
                    formAttr.value = '_blank';
                    formNode.setAttributeNode(formAttr);
                    document.getElementById("TheForm").submit();
                    this.disableFetchButton = false;
                }
            }
            else{
                this.isloading = false;
                if(data['Description'].includes('Successfully')){
                    this.disableRegisterButton = true;
                    console.log('disable register button '+this.disableRegisterButton);
                    this.showToastEvent('Success','Link generated successfully','success');
                    this.disableFetchButton = false;
                }
                else{
                    this.showToastEvent('Error',data['Description'],'error');
                }
                //this.showToastEvent('Success','Link generated successfully','success');
                
            }
            this.referenceId = data['referenceId'];
            console.log('reference Id '+this.referenceId);
        })
        .catch(error => {
            this.isloading = false;
            console.log('E mandate registration error '+JSON.stringify(error));
        })
        /*saveRepaymentDetails({
            obj : this.bankAccountObj,
            loanId : this.recordId
        })
        .then(data => {
            console.log(JSON.stringify(data));
            
        })
        .catch(error => {
            console.log(JSON.stringify(error));
        })*/
        
    }
    generatePDF(){
        restricAccess({
            compName: 'losRepaymentComponent' ,loanId: this.recordId
            }).then(data => {
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save Repayment details',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
                else{
                    this.isloading = true;
                    if(this.repaymentMode=='Standing Instructions'){
                        uploadSIForm({loanId: this.recordId}).then((result=>{
                            this.isloading = false;
                            let data;
                            if(result!=null){
                                data = result.split(';');
                                console.log('data '+JSON.stringify(data));
                            }
                            if(data[1] == 'Success'){
                                this.showToastEvent('Success','Repayment SI Form Generated Successfully','success');
                                if(this.esignFeatureEnabled){
                                    this.disableEsign = false;
                                }
                                this.showPDF = true;
                                this[NavigationMixin.Navigate]({
                                    type: 'standard__namedPage',
                                    attributes: {
                                        pageName: 'filePreview',
                                    },
                                    state : {
                                        recordIds: data[0],
                                        selectedRecordId: data[0]
                                    }
                                });
                                this.sendNotification(); //Notification 
                            }else{
                                this.showToastEvent('Error',result,'error');
                            }
                            
                        })).catch((error=>{
                            this.isloading = false;
                            console.log('error '+JSON.stringify(error));
                            this.showToastEvent('Error','Something went Wrong','error');
                        }))
                    }
                    else{
                        uploadACHForm({loanId: this.recordId}).then((result=>{
                            this.isloading = false;
                            let data;
                            if(result!=null){
                                data = result.split(';');
                                console.log('data '+JSON.stringify(data));
                            }
                            if(data[1] == 'Success'){
                                this.showToastEvent('Success','Repayment ACH Form Generated Successfully','success');
                                this.showPDF = true;
                                this[NavigationMixin.Navigate]({
                                    type: 'standard__namedPage',
                                    attributes: {
                                        pageName: 'filePreview',
                                    },
                                    state : {
                                        recordIds: data[0],
                                        selectedRecordId: data[0]
                                    }
                                });
                            }else{
                                this.showToastEvent('Error','Something went Wrong','error');
                            }
                            
                        })).catch((error=>{
                            this.isloading = false;
                            console.log('error '+JSON.stringify(error));
                            this.showToastEvent('Error','Something went Wrong','error');
                        }))
                    }
                    /*saveRepaymentDetails({
                        obj : this.bankAccountObj,
                        loanId : this.recordId
                    })
                    .then(data => {
                        console.log(JSON.stringify(data));
                        
                    })
                    .catch(error => {
                        console.log(JSON.stringify(error));
                    })*/
                    
                }

            }).catch(error=>{
                console.log('error is ' + JSON.stringify(error));

            })



       
        
    }

    generateEsign(){
        if(this.isEditRestricted){
            this.showToastEvent('Access Restricted','You do not have access to Initiate Esign','error');
            return
        }//4733
        if(!this.disableEsign){
            this.displayGenerateEsign=true
            const evt = setTimeout(() => {
                this.template.querySelector('c-generate-esign-component').handleGenerateEsign()
            }, 300);
        }else{
            if(this.esignFeatureEnabled){
                this.showToastEvent('','Please click on Generate to Generate SI Form', 'error');
            }else{
                this.showToastEvent('','Esign Not Applicable', 'error');
            }
            
        }
        
        
    }

    hideRepaymentSection(){
        this.displayRepaymentSection=false
    }

    showRepaymentSection(){
        this.displayRepaymentSection=true
        this.displayGenerateEsign=false
    }

    closeModal(){
        this.showPDF = false;
        this.showSubmitForm = false;
    }
    /*getBankAccountData(){
        console.log('repayment mode '+this.repaymentMode);
        getBankAccountRecords({
            loanId: this.recordId,
            repaymentMode : this.repaymentMode
        })
        .then(data => {
            console.log('data '+JSON.stringify(data));
            let options = []; 
            for(var key in data){
                console.log('key '+key+' data '+data[key]);
                if(data[key].Bank_Name__c!=null){
                    options.push({
                        label: data[key].Bank_Name__c,
                        value : JSON.stringify(data[key])
                    })
                }
                console.log('options '+JSON.stringify(options));
            }
            this.bankAccountOptions = options;
        })
        .catch(error =>{
            console.log('error '+JSON.stringify(error));
        })
    }*/

    handleChangePhoneNumber(event) {
        this.isInTimeInterval = false;
        let inputField = this.template.querySelector(".mobilebutton");
        console.log('inputField ' + inputField.name);
        console.log('inputField.checkValidity() ' + inputField.checkValidity());
        /*if (this.oldMobileNumberValue === event.target.value && this.isVerifiedNumber) {
            this.isVerified = true;
            this.isEnterOtp = false;
            this.boolRequestOtp = false;
            this.boolResendOtp = false;
            this.boolSendOtp = false;
        } else {*/
            if (event.target.name == 'Mobile_Number__c' && event.target.value.length == 10 && this.validatePhoneNumber(event.target.value)) {
                //this.loanApplicationRecord[event.target.name] = event.target.value;
                //this.mobileNumber = event.target.value;
                this.casaMobileNumber = event.target.value;
                this.boolCheckMobileNumber = false;
                this.boolSendOtp = true;
            } else {
                this.boolCheckMobileNumber = true;
                this.isEnterOtp = false;
                this.boolRequestOtp = false;
                this.boolResendOtp = false;
                this.isVerified = false;
            }
        //}
        this.boolVerify = true;
    }
    validatePhoneNumber(input_str) {
        var re = /^[6-9]{1}[0-9]{9}/;
        console.log('Valid Phone Number', re.test(input_str));
        return re.test(input_str);
    }

    handleSendOTP() {
        this.boolRequestOtp = true;
        this.boolSendOtp = false;
        this.isEnterOtp = true;
        this.set27SecondTimer();

        this.mobileOtpVerificationHandler('Mobile Generate OTP');

    }

    mobileOtpVerificationHandler(masterRecordName) {

        mobileOtpVerificationHandler({ mobileNumber: this.casaMobileNumber/*this.mobileNumber*/, otp: this.enterOTPValue, loanApplicationId: '', otpValue: masterRecordName })
            .then(result => {
                console.log('result is ' + result);
                if (result != null) {
                    if (masterRecordName == 'Mobile Validate OTP') {
                        let responseVal = JSON.parse(result);
                        let checklist = responseVal.checklistRecord;
                        let response = JSON.parse(responseVal.response);
                        if(responseVal.statusCode != 200){
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
                                this.isloading = false;
                                this.isEnterOtp = false;
                                this.isVerifiedNumber = true;
                                this.isGenerateDisabled = false;
                                this.reportOtpVerficationValidity("");
    
                            } 

                    }else if (masterRecordName == 'Mobile Generate OTP') {
                        let responseVal = JSON.parse(result);
                        let checklist = responseVal.checklistRecord;
                        let response = JSON.parse(responseVal.response);
                        if(responseVal.statusCode != 200){
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
        //this.oldMobileNumberValue = this.mobileNumber;
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

    handleUploadFinished(){
        const event = new ShowToastEvent({
            title: 'Success',
            message: 'File uploaded successfully',
            variant: 'success'
        });
        this.dispatchEvent(event);
    }

    handlePreviewClick(event){

        restricAccess({
            compName: 'losRepaymentComponent' ,loanId: this.recordId
            }).then(data => {
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save Repayment details',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
                else{
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
                }

            }).catch(error=>{
                console.log('error is ' + JSON.stringify(error));

            })
        
        
    }

    handleClickDelete(event){
        restricAccess({
            compName: 'losRepaymentComponent' ,loanId: this.recordId
            }).then(data => {
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save Repayment Details',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
                else{
                    let id = event.currentTarget.name;
                    console.log('ContentVersionid'+id);
                    deactivateDocument({ recordId : id})
                    .then((result) => {
                        let parseResult=JSON.parse(result);
                        if(parseResult.isSuccess ){
                            this.getDocRecords();
                            this.showToastEvent('Success', 'File Deleted Successfully', 'success');
                        }else{
                            this.showToastEvent('Error','Something went wrong!', 'error');
                            console.log('No result found.');
                            console.log('Error message'+parseResult.message);
                        }
                    }
                    )
                    .catch(error => {
                        this.error = error;
                        this.isloading = false;
                    });
                }

            }).catch(error=>{
                console.log('error is ' + JSON.stringify(error));

            })
        
    }

    @api 
    async nextHandler() {  
        
        const resp = await this.submitClickHelper()//R2-2643
        if(!resp){
            return
        }
         let Obj = {};
            Obj.next = true;
         this.errorOnChild = '';
         Obj.errorOnChild = this.errorOnChild;
         console.log('Obj', Obj);
         this.dispatchEvent(new CustomEvent('next', {
             detail: Obj
         }));
     }

     fetchCallbackDetails(){
        restricAccess({
            compName: 'losRepaymentComponent' ,loanId: this.recordId
            }).then(data => {
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save Repayment Details',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
                else{
                    console.log('callback status '+this.callbackStatus);
                    this.isloading = true;
                    if(this.callbackStatus!=null && this.callbackStatus=='Accepted'){
                        this.isloading = false;
                        this.showToastEvent('Success', 'Mandate Registration is successful', 'success');
                        //this.disableFetchButton = true;
                    }
                    else if(this.callbackStatus!=null && this.callbackStatus=='Rejected'){
                        this.isloading = false;
                        this.showToastEvent('Error', 'Mandate Registration Failed', 'error');
                    }
                    else{
                        this.isloading = false;
                        this.showToastEvent('Error', 'No details found', 'error');
                    }
                }

            }).catch(error=>{
                console.log('error is ' + JSON.stringify(error));

            })

        
     }

     getBankName(ifsc,index,tableName){
        restricAccess({
            compName: 'losRepaymentComponent' ,loanId: this.recordId
            }).then(data => {
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save Repayment Details',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
                else{
                    getBankName({
                        ifsc:ifsc
                    })
                    .then(data=>{
                        console.log('data '+JSON.stringify(data));
                        if(data!=null){
                            if(tableName == 'SPDC'){
                                let key = 'spdc'+index;
                                this.template.querySelector('c-generic-custom-lookup[data-id="'+key+'"]')?.setDefaultBankName(data);
                                this.listOfSPDC[index-1].bankName = data;
                            }
                            else if(tableName == 'PDC'){
                                let key = 'pdc'+index;
                                this.template.querySelector('c-generic-custom-lookup[data-id="'+key+'"]')?.setDefaultBankName(data);
                                this.listOfPDC[index-1].bankName = data;
                            } 
                        }
                    })
                    .catch(error=>{
                        console.log('error '+JSON.stringify(error));
                    })
                }

            }).catch(error=>{
                console.log('error is ' + JSON.stringify(error));

            })
            
    }

    /*getDefaultBankRecord(name,index){
        getDefaultBankRecord({
            bankName : name
        })
        .then(data =>{
            console.log('data '+JSON.stringify(data));
            this.listOfSPDC[index-1]['defaultRecordId'] = data;
            console.log('list '+JSON.stringify(this.listOfSPDC));
        })
    }*/

    /*handleLookupSelect(event){
        console.log('inside');
        let index = event.target.dataset.id;
        this.listOfSPDC[index-1].bankName = event.detail.name;
    }*/

    handleChequeSuccess(event){
        if(event.detail.isSuccess){
            this.fileData = {
                'loanAppId': this.recordId,
                'filename': event.detail.fileName,
                'file64': event.detail.base64,
            }
            this.handleClick();            
        }else{
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                mode: 'error',
                message: event.detail.errorMessage
            });
            this.dispatchEvent(event);
        }
    }

    //api call for Cheque OCR
    handleClick() {
        restricAccess({
            compName: 'losRepaymentComponent' ,loanId: this.recordId
            }).then(data => {
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save Repayment Details',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
                else{
                    const { loanAppId, file64 } = this.fileData;
                    uploadFile({ loanAppId, file64 })
                        .then(result => {
                            console.log('Cheque OCR response-->', JSON.parse(result));
                            if (result) {
                                var resultObj = JSON.parse(result);
                                if(resultObj.statusCode == 101){
                                let msg = `${this.fileData.filename} uploaded successfully!!`;
                                console.log('success message '+msg);
                                if(this.type=='SPDC'){
                                    let listOfSPDCEntry = this.listOfSPDC.find(o=>o.index === this.uploadChequeRowIndex);
                                    listOfSPDCEntry.bankNumber = resultObj.result.accNo;
                                    listOfSPDCEntry.ifsc = resultObj.result.ifsc;
                                    listOfSPDCEntry.bankName = resultObj.result.bank;
                                    console.log(this.template.querySelector('c-generic-custom-lookup[data-id="'+listOfSPDCEntry.key+'"]'));
                                    this.template.querySelector('c-generic-custom-lookup[data-id="'+listOfSPDCEntry.key+'"]')?.setDefaultBankName(resultObj.result.bank);
                                    this.showGenericUpload = false;
                                    this.isLoading = false;
                                }
                                else{
                                    let listOfPDCEntry = this.listOfPDC.find(o=>o.index === this.uploadChequeRowIndex);
                                    listOfPDCEntry.bankNumber = resultObj.result.accNo;
                                    listOfPDCEntry.ifsc = resultObj.result.ifsc;
                                    listOfPDCEntry.bankName = resultObj.result.bank;
                                    console.log(this.template.querySelector('c-generic-custom-lookup[data-id="'+listOfPDCEntry.key+'"]'));
                                    this.template.querySelector('c-generic-custom-lookup[data-id="'+listOfPDCEntry.key+'"]')?.setDefaultBankName(resultObj.result.bank);
                                    this.showGenericUploadPdc = false;
                                    this.isLoading = false;
                                }
                                
                                }
                                else{
                                let msg = 'Some error has occured. Please contact System Administrator';
                                console.log('error message '+msg);
                                this.isLoading = false;
                                }
                            }
                            else{
                                this.showGenericUpload = false;
                                this.showGenericUploadPdc = false;
                                this.isLoading = false;
                            }
                            
                        })
                        .catch(error => {
                            this.isLoading = false;
                            console.log('error is ', JSON.stringify(error));
                        })
                    
                }

            }).catch(error=>{
                console.log('error is ' + JSON.stringify(error));

            })
        
            
    }
    hanldeUploadClick(event){
        if(this.isEditRestricted){
            this.showToastEvent('Access Restricted','You do not have access to add Upload Files','error');
            return
        }//4733
        console.log('file uploaded '+event.target.name);
        this.uploadChequeRowIndex = event.target.name;
        
        console.log(JSON.stringify(event.target));
        console.log(JSON.stringify(this.listOfSPDC,null,2));
        this.showGenericUpload = true;
    }

    handleCloseModal(){
        this.showGenericUpload = false;
        this.showGenericUploadPdc = false;
    }

    hanldeUploadClickPDC(event){
        if(this.isEditRestricted){
            this.showToastEvent('Access Restricted','You do not have access to add Upload Files','error');
            return
        }//4733
        console.log('file uploaded '+event.target.name);
        this.uploadChequeRowIndex = event.target.name;
        
        console.log(JSON.stringify(event.target));
        console.log(JSON.stringify(this.listOfPDC,null,2));
        this.showGenericUploadPdc = true;
    }

    @track renderChargesInstructionModal = false
    @track isChargeComponentLoaded = false;
    @track renderInitialRepaymentForm = true;
    @track isReturnedFromPaymentFavouring = false;

    closeSPDCModal(){
        this.renderChargesInstructionModal = false;
        this.submitClickHelper();
    }

    renderChargesComponent(){
        this.isChargeComponentLoaded = true;    
        this.renderInitialRepaymentForm = false;
        this.closeSPDCModal();
    }

    handleNavigateToPaymentFavouring(evt){
        this.isChargeComponentLoaded = false;
        this.renderInitialRepaymentForm = false;
        this.isPaymentfavouringComponentLoaded = true;
        
    }

    handleBackToRepayment(evt){
        this.isChargeComponentLoaded = false;
        this.renderInitialRepaymentForm = true;
        this.isPaymentfavouringComponentLoaded = false;
        this.isReturnedFromPaymentFavouring = true;
    }

    getMICRCode(value,index, tableName){
        console.log(value+' '+index+' '+tableName);
        getMICRCode({
            ifsc: value
        })
        .then(data =>{
            console.log('data '+JSON.stringify(data));
            if(data){
                if(tableName=='PDC'){
                    this.listOfPDC[index-1].micr = data;
                }
                else if(tableName=='SPDC'){
                    this.listOfSPDC[index-1].micr = data;
                }
            }
            else{
                if(tableName=='PDC'){
                    this.listOfPDC[index-1].micr = '';
                }
                else if(tableName=='SPDC'){
                    this.listOfSPDC[index-1].micr = '';
                }
            }
        })
    }

     //29 AUG added notification 
     sendNotification(){
        sendSIotification({ loanId:  this.recordId }).then((data => {
           console.log('sent si intitaion notification successfully');
        })).catch((error => {
            this.isLoading = false
            this.showToastMessage('', IFT_API+' Failed - '+error, 'error', 'sticky')
        }))
    }
    //end

}