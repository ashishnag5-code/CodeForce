import { LightningElement,track,api,wire } from 'lwc';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import Loan_Number__c from "@salesforce/schema/Loan_Application__c.Loan_Number__c";
import CreatedDate from "@salesforce/schema/Loan_Application__c.CreatedDate";
import OPS_Action__c from "@salesforce/schema/Loan_Application__c.OPS_KYC_Action__c";
import OPS_Remark__c from "@salesforce/schema/Loan_Application__c.OPS_KYC_Remark__c";
import Application_Id__c from "@salesforce/schema/Loan_Application__c.Application_Id__c";
import RO_KYC_Remarks__c from "@salesforce/schema/Loan_Application__c.RO_KYC_Remarks__c";
import Application_FI_Status__c from "@salesforce/schema/Loan_Application__c.Application_FI_Status__c";
import getApplicantList from '@salesforce/apex/OpsKYCController.getApplicantList';
import getDocumentChecklistRecords from '@salesforce/apex/OpsKYCController.getDocumentChecklistRecords';
import getAddresses from '@salesforce/apex/OpsKYCController.getAddresses';
import getLinkedFiles from '@salesforce/apex/OpsKYCController.getLinkedFiles';
import updateRecords from '@salesforce/apex/OpsKYCController.updateRecords';
import updateAddressRecords from '@salesforce/apex/OpsKYCController.updateAddressRecords';
import updateLoanRecord from '@salesforce/apex/OpsKYCController.updateLoanRecord';
import getRecordInfo from '@salesforce/apex/OpsKYCController.getRecordInfo';
import reSubmitRecord from '@salesforce/apex/OpsKYCController.reSubmitRecord';
import getAddressSourceMetadata from '@salesforce/apex/OpsKYCController.getAddressSourceMetadata';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import Id from '@salesforce/user/Id';
import updateApplicant from '@salesforce/apex/OpsKYCController.updateApplicant';
import { loadStyle } from 'lightning/platformResourceLoader';
import opsAccordion from '@salesforce/resourceUrl/opsAccordion';
import getFIDetailsAssociatedWithApplicant from '@salesforce/apex/OpsKYCController.getFIDetailsAssociatedWithApplicant';
import checkOwnerUser from '@salesforce/apex/OpsKYCController.checkOwnerUser';
import getOpsResponseMetadataRecords from '@salesforce/apex/OpsKYCController.getOpsResponseMetadataRecords';//5599 Method addition
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

const fields = [Loan_Number__c,CreatedDate,OPS_Action__c,OPS_Remark__c,Application_Id__c,RO_KYC_Remarks__c,Application_FI_Status__c];
export default class AusfOPSKYCComponent extends LightningElement {
    @api recordId;
    @wire(MessageContext)
    messageContext
    @track applicationDate;
    @track loanNumber;
    @track opsActionLoan;
    @track remarksLoan;
    @track applicationId;
    @track applicantOptions = [];
    @track documentChecklist = [];
    @track kycList = [];
    @track poiList = [];
    @track poaList = [];
    @track otherList = [];
    @track draftValues = [];
    @track draftValuesPOI = [];
    @track draftValuesPOA = [];
    @track nonIndPoIList = [];
    @track draftValuesPOINonInd = [];
    @track draftValuesPOANonInd = [];
    @track nonIndPOAList = [];
    @track kycListNonInd = [];
    @track opsActionOptions = [{label: 'Rework',value:'Rework'},{label:'Approve',value:'Approve'}];
    @track isInd = false;
    @track userProfileName;
    @track applicant;
    @track customerImg;
    @track aadhaarImg;
    @track relatedFiles;
    @track match;
    @track isNotRO = true;
    @track isRo = false;
    @track assignmentRecordId='';
    @track isComplete = false;
    @track isVerified = false;
    @track isAllVerified = false;
    @track isApplicantSelected = false;
    @track RoRemarksLabel = '';
    @track roRemarks = '';
    @track entityValue = '';
    @track fiStatus = '';
    @track isOwnerQueue = false;
    @track isOwnerView = false;
    addressMetadata = {};
    activeSections = ['KYC','POI','POA','Other'];
    baseUrl = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=';
    applicantList;
    @track columns = [
        {label : 'KYC Name', fieldName : 'Document_Name__c', editable : false},
        {label : 'KYC Document Number', fieldName : 'Document_Number__c', editable : false},
        {label : 'Validity', fieldName : 'Validity',editable : false},
        {label : 'Verified Mode', fieldName : 'Verified_Mode',editable : false},
        {label : 'Match %', fieldName : 'Match',editable : false},
        {label : 'Document (~)', fieldName : 'Document__c',editable : false, type:"url", typeAttributes: { label: { fieldName: 'Document_Name__c' }, target: '_blank' }},
        {label : 'OPS Action Approved?', fieldName : 'OPS_Action__c', type:'boolean', editable : {fieldName: 'controlEditField'}},
        {label : 'Remarks', fieldName : 'OPS_Remark__c', editable : {fieldName: 'controlEditField'}},
        { type: "button", typeAttributes: {  
            label: 'View Response',  
            name: 'View Ind',  
            title: 'View',  
            disabled: { fieldName: 'IsDisabled'},  
            value: 'view',  
            iconPosition: 'left' ,
            cellAttributes: {
                style: 'border: none;'
            } 
        } }, 
    ]
    @track columnsPOI = [
        {label : 'KYC Name', fieldName : 'Document_Name__c', editable : false},
        {label : 'KYC Document Number', fieldName : 'Document_Number__c', editable : false},
        {label : 'Validity', fieldName : 'Validity', editable : false},
        {label : 'Verified Mode', fieldName : 'Verified_Mode',editable : false},
        {label : 'Match %', fieldName : 'Match',editable : false},
        {label : 'Document (~)', fieldName : 'Document__c',editable : false, type:"url", typeAttributes: { label: { fieldName: 'Document_Name__c' }, target: '_blank' }},
        {label : 'OPS Action Approved?', fieldName : 'OPS_Action__c', type:'boolean', editable : {fieldName: 'controlEditField'}},
        {label : 'Remarks', fieldName : 'OPS_Remark__c',editable : {fieldName: 'controlEditField'}},
        { type: "button", typeAttributes: {  
            label: 'View Response',  
            name: 'View Ind',  
            title: 'View',  
            disabled: { fieldName: 'IsDisabled'},  
            value: 'view',  
            iconPosition: 'left' ,
            cellAttributes: {
                style: 'border: none;'
            } 
        } }, 
    ]
    @track columnsPOA = [
        {label : 'Type of Address', fieldName : 'Type_Of_Address', editable : false},
        {label : 'Address', fieldName : 'Address', editable : false, wrapText : true},
        {label : 'POA', fieldName : 'POA', editable : false},
        //{label : 'Verified Status', fieldName : 'Verified_Status',editable : false},
        {label : 'Document (~)', fieldName : 'Document__c',editable : false,  type:"url", typeAttributes: { label: { fieldName: 'Document_Name__c' }, target: '_blank' }},
        {label : 'OPS Action Approved?', fieldName : 'OPS_Action__c', type:'boolean', editable : {fieldName: 'controlEditField'}},
        {label : 'Remarks', fieldName : 'OPS_Remark__c',editable : {fieldName: 'controlEditField'}},
        
    ]
    @track columnsOther = [
        {label : 'Entity', fieldName : 'Entity', editable : false},
        {label : 'Status', fieldName : 'Status',type:'text', editable : false}
    ]

    @track columnsPOINonInd = [
        {label : 'KYC Name', fieldName : 'Document_Name__c', editable : false},
        {label : 'KYC Document Number', fieldName : 'Document_Number__c', editable : false},
        {label : 'Validity', fieldName : 'Validity', editable : false},
        {label : 'Match %', fieldName : 'Match',editable : false},
        {label : 'Document (~)', fieldName : 'Document__c',editable : false, type:"url", typeAttributes: { label: { fieldName: 'Document_Name__c' }, target: '_blank' }},
        {label : 'OPS Action Approved?', fieldName : 'OPS_Action__c', type:'boolean', editable : {fieldName: 'controlEditField'}},
        {label : 'Remarks', fieldName : 'OPS_Remark__c',editable : {fieldName: 'controlEditField'}},
        { type: "button", typeAttributes: {  
            label: 'View Response',  
            name: 'View NonInd',  
            title: 'View',  
            disabled: { fieldName: 'IsDisabled'},  
            value: 'view',  
            iconPosition: 'left',
            cellAttributes: {
                style: 'border: none;'
            }   
        }}
    ]

    @wire(getRecord, {
        recordId: "$recordId",
        fields
    })
    wiredRecord({ error, data }) {
        if (data) {
            this.loanApplicantionRecord = data;
            console.log('loan app data '+JSON.stringify(this.loanApplicantionRecord));
            this.applicationDate = getFieldValue(this.loanApplicantionRecord, CreatedDate);
            this.loanNumber = getFieldValue(this.loanApplicantionRecord, Loan_Number__c);
            this.remarksLoan = getFieldValue(this.loanApplicantionRecord, OPS_Remark__c);
            this.opsActionLoan = getFieldValue(this.loanApplicantionRecord, OPS_Action__c);
            this.applicationId = getFieldValue(this.loanApplicantionRecord,Application_Id__c);
            this.roRemarks = getFieldValue(this.loanApplicantionRecord,RO_KYC_Remarks__c);
            //this.fiStatus = getFieldValue(this.loanApplicantionRecord,Application_FI_Status__c);
            if(this.opsActionLoan=='Approve'){
                this.isComplete = true;
            }
        }
        else if(error){
            console.log('error '+JSON.stringify(error));
        }
    }

    @wire(getRecord, { recordId: Id, fields: [ProfileName] })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (data.fields.Profile.value != null) {
                this.userProfileName = data.fields.Profile.value.fields.Name.value;
                console.log('profile name '+this.userProfileName);
                if(this.userProfileName=='Sales'){
                    this.isNotRO = false;
                    this.isRo = true;
                    console.log('isRo '+this.isRo);
                }  
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
    }

    connectedCallback(){
        this.activeSections = ['KYC','POI','POA','Other'];
        getRecordInfo({
            id : this.recordId
        })
        .then(data=>{
            console.log('data '+JSON.stringify(data));
            this.assignmentRecordId = this.recordId;
            if(data!=null){
                this.recordId =data['Loan_Application__c'];
                //this.isComplete = data['Status__c']=='Complete'?true:false;  
            }
            this.checkOwnerUser();
            //this.getApplicantDetails();
            this.getApplicantsFISummary();
        })
        .catch(error=>{
            console.log('error '+JSON.stringify(error));
        })
        this.getAddressSourceMetadata();
    }

    getAddressSourceMetadata(){
        getAddressSourceMetadata()
        .then(data=>{
            console.log('metadata '+JSON.stringify(data));
            this.addressMetadata = data;
        })
        .catch(error=>{
            console.log('error '+JSON.stringify(error));
        })
    }
    /*renderedCallback(){
        console.log('rendered '+this.isRO);
        if(this.isRo==true){
            console.log('isRo in rendered '+this.isRO);
            this.template.querySelector('[data-id="action"]').disabled = true;
            this.template.querySelector('[data-id="remark"]').disabled = true;
        }
    }*/

    /*  5599 CHanges*/
    @track responseComponentWrapper = {};
    @track renderResponseComponent = false;
    @track identifierDocuments = false;
    @track DEFAULT_TRUE = true;

    callRowAction(evt){
        const recId =  evt.detail.row.Id;  
        const actionName = evt.detail.action.name;  
        let checkListData = [];
        checkListData = (actionName == 'View Ind')?this.kycList : this.kycListNonInd;
        let selectedRecord = {};
        checkListData.forEach(rec=>{
            if(rec.Id == recId){
                selectedRecord = rec;
            }
        });
        this.responseComponentWrapper = JSON.parse(selectedRecord.Api_Response__c);
        this.responseComponentWrapper.Response.pan = selectedRecord.Document_Number__c;
        this.renderResponseComponent = true;    
        this.genericDisplayType = selectedRecord.Document_Name__c;
    }

    callRowActionPOI(evt){
        const recId =  evt.detail.row.Id;  
        const actionName = evt.detail.action.name;  
        let checkListData = [];
        checkListData = (actionName == 'View Ind')?this.poiList : this.nonIndPoIList;
        let selectedRecord = {};
        checkListData.forEach(rec=>{
            if(rec.Id == recId){
                selectedRecord = rec;
            }
        });
        getOpsResponseMetadataRecords({
            documentName : selectedRecord.Document_Name__c
        })
        .then(res=>{
            let metadata = [];
            if(res){
                for(var d in res){
                    metadata.push({
                        DeveloperName : res[d].DeveloperName__c,
                        MasterLabel :  res[d].MasterLabel__c,
                        Display_on_UI__c : res[d].Display_On_UI__c,
                        JSON_Key__c : res[d].JSON_Key__c,
                        Order__c : res[d].Order__c
                    })
                }
                this.responseComponentWrapper.Response = JSON.parse(selectedRecord.Api_Response__c);;
                this.responseComponentWrapper.metadata = metadata;
                this.responseComponentWrapper.Response.pan = selectedRecord.Document_Number__c;
                this.renderResponseComponent = true; 
                this.genericDisplayType = selectedRecord.Document_Name__c;
            }
        })
        .catch(err=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: 'Error In Getting Response!! Please contact System Admin.',
                    variant: 'error'
                })
            );  

        })
           
    }

    hideModalBox(){
        this.renderResponseComponent = false;
    }

    /********************** */

    checkOwnerUser(){
        checkOwnerUser({
            recordId : this.assignmentRecordId 
        })
        .then(data =>{
            console.log('user-owner '+data);
            if(data=='User'){
                this.isOwnerQueue = false;
                this.isComplete = true;
            }
            else if(data=='Owner'){
                this.isOwnerQueue = false;
                this.isOwnerView = true;
            }
            else{
                this.isOwnerQueue = true;
            }
            console.log('data '+JSON.stringify(data));
        })
        .catch(error =>{
            console.log('error '+JSON.stringify(error));
        })
    }

    @track applicantSummaryMap = [];

    getApplicantsFISummary(){
        getFIDetailsAssociatedWithApplicant({
            loanApplicationId : this.recordId
        })
        .then(res=>{
            if(res){
                this.applicantSummaryMap = res;
                this.getApplicantDetails();
                console.log('applicant fi map '+JSON.stringify(this.applicantSummaryMap))
            }
            
        })
        .catch(err=>{
            alert('error '+JSON.stringify(err));
        })

    }

    getApplicantDetails(){
        getApplicantList({
            loanId : this.recordId
        })
        .then(data =>{
            console.log('applicants '+JSON.stringify(data));
            this.applicantList = data; 
            
            let options = [];
            let verify = true;
            for(var i=0;i<data.length;i++){
                if(data[i].Ops_KYC_Verified__c==false){
                    verify = false;
                }
                let fName = data[i].First_Name__c ? data[i].First_Name__c : '';
                let lName = data[i].Last_Name__c ? data[i].Last_Name__c : '';
                let existingCustomer = data[i].Existing_Customer__c=='Yes'?'ETB':'NTB';
                options.push({
                    label : fName + ' ' +lName + '-' + data[i].RecordType.Name + '-' + existingCustomer,/*data[i].Customer_Type__c,*/
                    value: JSON.stringify(data[i])
                })
            }
            this.isAllVerified = verify;
            this.applicantOptions = options;
            //console.log('customer type '+JSON.stringify(data[i].Customer_Type__c));
            if(this.applicantOptions && this.applicantOptions.length==1){
                this.applicant = this.applicantOptions[0].value; 

                console.log('applicant id '+JSON.stringify(JSON.parse(this.applicant).Id))
                for(var d in this.applicantSummaryMap){

                    if(d == JSON.parse(this.applicant).Id){
                        this.fiStatus = this.applicantSummaryMap[d].finalStatus;
                    }
                }
                let value = JSON.parse(this.applicant);
                console.log('customer type '+value['Customer_Type__c']);
                if(value['Customer_Type__c']=='Individual'){
                    this.isInd = true;
                }
                else{
                    this.isInd = false;
                }
                this.isApplicantSelected = true;
                this.isVerified = JSON.parse(this.applicant)['Ops_KYC_Verified__c'];
                this.entityValue = value['Customer_Type__c'];
                console.log('verified '+this.isVerified);
                console.log('value '+JSON.stringify(value));
                console.log('id '+value['Id']);
                this.kycList = [];
                this.poiList = [];
                this.aadhaarImg = '';
                this.customerImg = '';
                this.getLinkedFiles(value['Id']);
                this.setOtherDetails();
            }
        })
        .catch(error =>{
            console.log('error '+JSON.stringify(error));
        })
    }
    
    getDocumentChecklistDetails(applId){
        getDocumentChecklistRecords({
            applId : applId
        })
        .then(data =>{
            console.log('relatedfiles '+JSON.stringify(this.relatedFiles));
            if(this.relatedFiles!=null){
                console.log('customerimg '+this.relatedFiles['Live Photo']);
                this.customerImg = this.baseUrl+this.relatedFiles['Live Photo'];
                this.aadhaarImg = this.baseUrl+this.relatedFiles['Application Aadhaar Picture'];
            }
            
            console.log('checklist '+JSON.stringify(data));
            this.documentChecklist = data;
            let optionsKyc=[];
            let optionsPOI = [];
            let optionsPOINonInd = [];
            let optionsKycNonInd = [];
            let appl = JSON.parse(this.applicant);
            let verifyName;
            let verifyAadhaar='';
            
            for(var i=0;i<data.length;i++){
                if(data[i].Document_Master__r?.Document_Name__c=='Live Photo'){
                    let score = data[i].Match_Percentage__c ? data[i].Match_Percentage__c : 0.00;
                    this.match = score ? parseFloat(score).toFixed(2) : '0.00';
                }
                if(data[i].Match_Percentage__c){
                    data[i].Match_Percentage__c = data[i].Match_Percentage__c*100;
                }
                if(this.isInd==true && appl['KYC_Type__c']!=null && appl['KYC_Type__c'].includes('Aadhaar')){
                    verifyName = 'Aadhaar';
                    verifyAadhaar = appl['KYC_Type__c'].substring(appl['KYC_Type__c'].indexOf('-')+1,);
                    console.log('verify '+verifyName+' '+verifyAadhaar);
                }
                else if(this.isInd==true){
                    verifyName = appl['KYC_Type__c'];
                }
                let opsAction = false;
                if(data[i].Ops_Action__c == 'Not Ok'){
                    opsAction = false;
                }
                else if(data[i].Ops_Action__c =='Ok'){
                    opsAction = true;
                }
                //R2-1990
                if(data[i].Document_Master__r.Name=='AUWheels0093' || data[i].Document_Master__r.Name=='AUWheels0091'){
                    let fileUrl='';
                    let verify='';
                    let documentNameTemp
                    if(data[i].Document_Master__r.Name=='AUWheels0093'){
                        documentNameTemp='Electricity bill'
                    }else if(data[i].Document_Master__r.Name=='AUWheels0091'){
                        documentNameTemp='PNG bill'
                    }
                    if(this.relatedFiles!=null && this.relatedFiles[documentNameTemp]!=null){
                        fileUrl = this.baseUrl+this.relatedFiles[documentNameTemp];
                    }
                    if(data[i].Document_Number__c!=null){
                        verify = 'API';
                    }
                    if(this.relatedFiles[documentNameTemp] || data[i].Document_Number__c){
                        let docName=data[i].Document_Master__r.Document_Name__c;
                        /*if(data[i].Document_Number__c !=null && data[i].Document_Number__c !=undefined){
                            docName = 'PAN Card';
                        }else{
                            docName = 'Form 60';
                        }*/
                        if(this.isInd==true){
                            optionsKyc.push({
                                'Document_Name__c' : docName,//data[i].Document_Master__r.Document_Name__c,
                                'Document_Number__c': data[i].Document_Number__c,
                                'Validity' : data[i].Document_Expiry_Date__c,
                                'Verified_Mode' : verify,
                                'Match' : data[i].Match_Percentage__c,
                                'Document__c' : fileUrl,
                                'OPS_Action__c' : opsAction,
                                'OPS_Remark__c' : data[i].Ops_Remark__c,
                                'controlEditField' : this.isNotRO,
                                'Id' : data[i].Id
                            })
                        }else{
                            optionsKycNonInd.push({
                                'Document_Name__c' : data[i].Document_Master__r.Document_Name__c,
                                'Document_Number__c': data[i].Document_Number__c,
                                'Validity' : data[i].Document_Expiry_Date__c,
                                'Match' : data[i].Match_Percentage__c,
                                'Document__c' : fileUrl,
                                'OPS_Action__c' : opsAction,
                                'OPS_Remark__c' : data[i].Ops_Remark__c,
                                'controlEditField' : this.isNotRO,
                                'Id' : data[i].Id
                            })
                        }
                        
                    }
                }
                if(this.isInd==true && data[i].Document_Master__r.Document_Name__c=='Pan Card/Form 60'){
                    
                    let fileUrl='';
                    let verify='';
                    if(this.relatedFiles!=null && this.relatedFiles['Pan Card/Form 60']!=null){
                        fileUrl = this.baseUrl+this.relatedFiles['Pan Card/Form 60'];
                    }
                    if(data[i].Document_Number__c!=null){
                        verify = 'API';
                    }
                    if(this.relatedFiles['Pan Card/Form 60'] || data[i].Document_Number__c){
                        let docName=data[i].Document_Master__r.Document_Name__c;
                        /*if(data[i].Document_Number__c !=null && data[i].Document_Number__c !=undefined){
                            docName = 'PAN Card';
                        }else{
                            docName = 'Form 60';
                        }*/
                        optionsKyc.push({
                            'Document_Name__c' : docName,//data[i].Document_Master__r.Document_Name__c,
                            'Document_Number__c': data[i].Document_Number__c,
                            'Validity' : data[i].Document_Expiry_Date__c,
                            'Verified_Mode' : verify,
                            'Match' : data[i].Match_Percentage__c,
                            'Document__c' : fileUrl,
                            'OPS_Action__c' : opsAction,
                            'OPS_Remark__c' : data[i].Ops_Remark__c,
                            'controlEditField' : this.isNotRO,
                            'Id' : data[i].Id,
                            'Api_Response__c' : data[i].Api_Response__c,
                            'IsDisabled' : (data[i].Api_Response__c==null || data[i].Api_Response__c==undefined)
                        })
                    }
                }
                else if(data[i].Document_Master__r.Document_Name__c.includes('Pan Card')){
                    let fileUrl='';
                    if(this.relatedFiles!=null && (this.relatedFiles['Pan Card/Form 60']!=null || this.relatedFiles['Pan Card']!=null)){
                        if(this.relatedFiles['Pan Card/Form 60']!=null){
                            fileUrl = this.baseUrl+this.relatedFiles['Pan Card/Form 60'];
                        }
                        else if(this.relatedFiles['Pan Card']!=null){
                            fileUrl = this.baseUrl+this.relatedFiles['Pan Card'];
                        }
                    }
                    if(data[i].Document_Number__c!=null){
                        optionsKycNonInd.push({
                            'Document_Name__c' : data[i].Document_Master__r.Document_Name__c,
                            'Document_Number__c': data[i].Document_Number__c,
                            'Validity' : data[i].Document_Expiry_Date__c,
                            'Match' : data[i].Match_Percentage__c,
                            'Document__c' : fileUrl,
                            'OPS_Action__c' : opsAction,
                            'OPS_Remark__c' : data[i].Ops_Remark__c,
                            'controlEditField' : this.isNotRO,
                            'Id' : data[i].Id,
                            'Api_Response__c' : data[i].Api_Response__c,
                            'IsDisabled' : (data[i].Api_Response__c==null || data[i].Api_Response__c==undefined)
                        })
                    }
                }
                if(this.isInd==true && (data[i].Document_Master__r.Document_Name__c=='Aadhaar Card' || data[i].Document_Master__r.Document_Name__c=='Voter ID Card' || data[i].Document_Master__r.Document_Name__c== 'Driving Licence' || data[i].Document_Master__r.Document_Name__c=='Passport' || 
                    data[i].Document_Master__r.Document_Name__c== 'NREGA document' || data[i].Document_Master__r.Document_Name__c== 'NPR document' 
                )){
                    let matchScore='';
                    if(data[i].Document_Master__r.Document_Name__c!='Aadhaar Card'){
                        verifyAadhaar='';
                    }
                    if(data[i].Document_Master__r.Document_Name__c == 'Voter ID Card' || data[i].Document_Master__r.Document_Name__c== 'Driving Licence' || data[i].Document_Master__r.Document_Name__c== 'Passport'){
                        matchScore = data[i].Match_Percentage__c;
                        if(data[i].Document_Number__c!=null){
                            verifyAadhaar = 'API';
                        }
                        /*if(!this.match){
                            this.match = data[i].Match_Percentage__c;
                        }*/
                    }
                    /*if(!this.match && (data[i].Document_Master__r.Document_Name__c == 'NREGA document' || data[i].Document_Master__r.Document_Name__c== 'NPR document') ){
                        this.match = data[i].Match_Percentage__c;
                    }*/
                    let fileUrl='';
                    if(this.relatedFiles!=null && this.relatedFiles[data[i].Document_Master__r.Document_Name__c]!=null){
                        fileUrl = this.baseUrl+this.relatedFiles[data[i].Document_Master__r.Document_Name__c];
                    }
                    if(data[i].Document_Number__c!=null){
                        optionsPOI.push({
                            'Document_Name__c' : data[i].Document_Master__r.Document_Name__c,
                            'Document_Number__c': data[i].Document_Number__c,
                            'Validity' : data[i].Document_Expiry_Date__c,
                            'Verified_Mode' : verifyAadhaar,
                            'Match' : matchScore,
                            'Document__c' : fileUrl,
                            'OPS_Action__c' : opsAction,
                            'OPS_Remark__c' : data[i].Ops_Remark__c,
                            'controlEditField' : this.isNotRO,
                            'Id' : data[i].Id,
                            'Api_Response__c' : data[i].Api_Response__c,
                            'IsDisabled' : (data[i].Api_Response__c==null || data[i].Api_Response__c==undefined)
                        })
                    }
                }
                else if(this.isInd==false && (data[i].Document_Master__r.Document_Name__c=='Udyam Document' || data[i].Document_Master__r.Document_Name__c=='TIN Document' || 
                            data[i].Document_Master__r.Document_Name__c=='CIN Document' || data[i].Document_Master__r.Document_Name__c=='GST' || data[i].Document_Master__r.Document_Name__c=='Water bill' || 
                            data[i].Document_Master__r.Document_Name__c=='telephone bill' || data[i].Document_Master__r.Document_Name__c=='Electricity bill' || 
                            data[i].Document_Master__r.Document_Name__c=='ITR' || data[i].Document_Master__r.Document_Name__c=='registration certificate')){
                    let fileUrl='';
                    if(this.relatedFiles!=null && this.relatedFiles[data[i].Document_Master__r.Document_Name__c]!=null){
                        fileUrl = this.baseUrl+this.relatedFiles[data[i].Document_Master__r.Document_Name__c];
                    }
                    if(data[i].Document_Number__c!=null){
                        optionsPOINonInd.push({
                            'Document_Name__c' : data[i].Document_Master__r.Document_Name__c,
                            'Document_Number__c': data[i].Document_Number__c,
                            'Validity' : data[i].Document_Expiry_Date__c,
                            'Match' : data[i].Match_Percentage__c,
                            'Document__c' : fileUrl,
                            'OPS_Action__c' : opsAction,
                            'OPS_Remark__c' : data[i].Ops_Remark__c,
                            'controlEditField' : this.isNotRO,
                            'Id' : data[i].Id,
                            'Api_Response__c' : data[i].Api_Response__c,
                            'IsDisabled': (data[i].Api_Response__c==null || data[i].Api_Response__c==undefined)
                        })
                    }
                }
            }

            this.kycList = optionsKyc;
            this.kycListNonInd = optionsKycNonInd;
            this.nonIndPoIList = optionsPOINonInd;
            let name = appl['First_Name__c'] +' '+ (appl['Middle_Name__c']?(appl['Middle_Name__c']+' '):'') + (appl['Last_Name__c']?(appl['Last_Name__c']+' '):'');
            optionsPOI.push({
                'Document_Name__c' : 'Name',
                'Document_Number__c': name,
                'Validity' : '',
                'Verified_Mode' : verifyName,
                'Match' : '',
                'Document__c' : '',
                'OPS_Action__c' : '',
                'OPS_Remark__c' : '',
                'controlEditField' : false,
                'IsDisabled': true
            })
            optionsPOI.push({
                'Document_Name__c' : 'DoB',
                'Document_Number__c': ''+appl['Dob__c'],
                'Validity' : '',
                'Verified_Mode' : verifyName,
                'Match' : '',
                'Document__c' : '',
                'OPS_Action__c' : '',
                'OPS_Remark__c' : '',
                'controlEditField' : false,   
                'IsDisabled': true   
            })
            this.poiList = optionsPOI;
        })
        .catch(error =>{
            console.log('error '+JSON.stringify(error));
        })
    }
    getAddressDetails(applId){
        getAddresses({
            applId : applId
        })
        .then(data =>{
            let addressOptions = [];
            let addressOptionsNonInd = [];
            for(var i=0;i<data.length;i++){
                let fileurl = '';
                if(data[i].Address_Source__c?.includes('Voter')){
                    data[i].Address_Source__c = 'Voter ID Card';
                }
                /*if(this.relatedFiles[data[i].Address_Source__c]===undefined){
                    fileurl = '';
                    
                }else{
                    fileurl = this.baseUrl+this.relatedFiles[data[i].Address_Source__c];
                }*/
                let opsAction = false;
                if(data[i].OPS_Action__c == 'Not Ok'){
                    opsAction = false;
                }
                else if(data[i].OPS_Action__c =='Ok'){
                    opsAction = true;
                }

                let src = this.addressMetadata[data[i].Address_Source__c];
                if(src){
                    if(this.relatedFiles[src]){
                    fileurl = this.baseUrl+this.relatedFiles[src];
                }
                }

                if(this.isInd==true){
                    if(data[i].Address_Line_1__c){
                        addressOptions.push({
                            'Document_Name__c' : data[i].Address_Source__c,
                            'Type_Of_Address' : data[i].Address_Type__c,
                            'Address': data[i].Address_Line_1__c+','+data[i].Address_Line_2__c+''+(data[i].Address_Line_3__c===undefined?'':(', '+data[i].Address_Line_3__c))+','+data[i].District__c+', '+data[i].State__c+', '+data[i].City__c+', '+data[i].Pincode__c,
                            'POA' : data[i].Address_Source__c,
                            //'Verified_Status' : data[i].Source_Type__c,
                            'Document__c' : fileurl,
                            'OPS_Action__c' : opsAction,
                            'OPS_Remark__c' : data[i].OPS_Remark__c,
                            'controlEditField' : this.isNotRO,
                            'Id' : data[i].Id
                        })
                    }
                }
                else if(data[i].Address_Type__c=='Current' || data[i].Address_Type__c=='Office'){
                    if(data[i].Address_Line_1__c){
                        addressOptionsNonInd.push({
                            'Document_Name__c' : data[i].Address_Source__c,
                            'Type_Of_Address' : data[i].Address_Type__c,
                            'Address': data[i].Address_Line_1__c+', '+data[i].Address_Line_2__c+''+(data[i].Address_Line_3__c===undefined?'':(', '+data[i].Address_Line_3__c))+','+data[i].District__c+', '+data[i].State__c+', '+data[i].City__c+', '+data[i].Pincode__c,
                            'POA' : data[i].Address_Source__c,
                            //'Verified_Status' : data[i].Source_Type__c,
                            'Document__c' : fileurl,
                            'OPS_Action__c' : opsAction,
                            'OPS_Remark__c' : data[i].OPS_Remark__c,
                            'controlEditField' : this.isNotRO,
                            'Id' : data[i].Id
                        }) 
                    }
                }
            }
            this.poaList = addressOptions;
            this.nonIndPOAList = addressOptionsNonInd;
        })
        .catch(error =>{
            console.log('address error '+JSON.stringify(error));
        })
    }

    setOtherDetails(){
        let data = JSON.parse(this.applicant);
        let options = [];
        options.push({
            'Entity' : 'AML',
            'Status' : data.AML_Status__c
        })
        options.push({
            'Entity' : 'CFR',
            'Status' : data.CFR_Status__c
        })
        options.push({
            'Entity' : 'Email ID',
            'Status' : data.IsEmailVerified__c
        })
        options.push({
            'Entity' : 'Negative',
            'Status' : data.Negative_Check_Status__c
        })
        options.push({
            'Entity' : 'FI Status',
            'Status' : this.fiStatus
        })
        this.otherList = options;
    }

    handleChange(event){
        let name = event.target.name;
        let value = JSON.parse(event.detail.value);
        this.applicant = event.detail.value;
        console.log('applicant id '+JSON.stringify(JSON.parse(this.applicant).Id))
        for(var d in this.applicantSummaryMap){

            if(d == JSON.parse(this.applicant).Id){
                this.fiStatus = this.applicantSummaryMap[d].finalStatus;
            }
        }
        //console.log('test fi '+this.applicantSummaryMap[this.applicant.Id]);
        console.log('customer type '+value['Customer_Type__c']);
        if(value['Customer_Type__c']=='Individual'){
            this.isInd = true;
        }
        else{
            this.isInd = false;
        }
        if(name=='Applicant'){
            this.isApplicantSelected = true;
            this.isVerified = JSON.parse(this.applicant)['Ops_KYC_Verified__c'];
            this.entityValue = value['Customer_Type__c'];
            //this.template.querySelector('[data-id="Ops_KYC_Verified__c"]').checked = JSON.parse(this.applicant)['Ops_KYC_Verified__c'];
        }
        // console.log('verified '+this.isVerified);
        // console.log('value '+JSON.stringify(value));
        // console.log('id '+value['Id']);
        //this.getDocumentChecklistDetails(value['Id']);
        this.kycList = [];
        this.poiList = [];
        this.aadhaarImg = '';
        this.customerImg = '';
        this.getLinkedFiles(value['Id']);
        //this.getAddressDetails(value['Id']);
        this.setOtherDetails();
    }

    async saveRecord(event){
         /*if(this.isComplete){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Record cannot be edited',
                    variant: 'error'
                })
            ); 
            return;
        }*/
        if(!this.isOwnerView){
             this.dispatchEvent(
                 new ShowToastEvent({
                     title: 'Error',
                     message: 'You do not have permission to edit the record',
                     variant: 'error',
                     mode : 'sticky'
                 })
             ); 
             return;
         }
        this.isVerified = false;
        this.isComplete = false;
        const updatedFields = event.detail.draftValues;
        for(var i=0;i<updatedFields.length;i++){
            var obj = updatedFields[i];
            for(var key in obj){
                if(key=='OPS_Action__c'){
                    obj[key] = obj[key]==true?'Ok':'Not Ok';
                }
                console.log('key '+key);
                console.log('value '+obj[key]);
            }
        }
        console.log('updatedFields '+JSON.stringify(updatedFields));
        await updateRecords( { data: updatedFields } )
        .then( result => {

            console.log( JSON.stringify( "Apex update result: " + result ) );
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record(s) updated',
                    variant: 'success'
                })
            );  
            console.log('draft values '+JSON.stringify(event.detail.draftValues));
            this.draftValues = [];   
            this.draftValuesPOI = [];
            this.draftValuesPOINonInd = [];
            console.log('appl id '+JSON.parse(this.applicant)['Id']);
            this.getDocumentChecklistDetails(JSON.parse(this.applicant)['Id']);
        }).catch( error => {

            console.log( 'Error is ' + JSON.stringify( error ) );
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating or refreshing records',
                    message: error,
                    variant: 'error',
                    mode : 'sticky'
                })
            );

        });

    }
    async saveAddressRecord(event){
        /*if(this.isComplete){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Record cannot be edited',
                    variant: 'error'
                })
            ); 
            return;
        }*/
         if(!this.isOwnerView){
             this.dispatchEvent(
                 new ShowToastEvent({
                     title: 'Error',
                     message: 'You do not have permission to edit the record',
                     variant: 'error',
                     mode : 'sticky'
                 })
             ); 
             return;
         }
        this.isVerified = false;
        this.isComplete = false;
        const updatedFields = event.detail.draftValues;
        for(var i=0;i<updatedFields.length;i++){
            var obj = updatedFields[i];
            for(var key in obj){
                if(key=='OPS_Action__c'){
                    obj[key] = obj[key]==true?'Ok':'Not Ok';
                }
                console.log('key '+key);
                console.log('value '+obj[key]);
            }
        }
        console.log('updatedFields '+JSON.stringify(updatedFields));
        await updateAddressRecords( { data: updatedFields } )
        .then( result => {

            console.log( JSON.stringify( "Apex update result: " + result ) );
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record(s) updated',
                    variant: 'success'
                })
            );  
            console.log('draft values '+JSON.stringify(event.detail.draftValues));   
            this.draftValuesPOA = [];
            this.draftValuesPOANonInd = [];
            console.log('appl id '+JSON.parse(this.applicant)['Id']);
            this.getAddressDetails(JSON.parse(this.applicant)['Id']);
        }).catch( error => {

            console.log( 'Error is ' + JSON.stringify( error ) );
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating or refreshing records',
                    message: error,
                    variant: 'error',
                    mode : 'sticky'
                })
            );

        });
    }
    handleSave(){
        let action = this.template.querySelector('[data-id="action"]').value;
        let remark = this.template.querySelector('[data-id="remark"]').value;
        console.log('action '+action+' remark '+remark);
        if(this.isNotRO && (action==null || action=='') ){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Action cannot be empty!',
                    variant: 'error',
                    mode : 'sticky'
                })
            );
            return;
        }
        if(action=='Approve'){
            for(var obj in this.applicantList){
                if(!this.applicantList[obj].Ops_KYC_Verified__c){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Please approve all the documents of applicants and save first',
                            variant: 'error',
                            mode : 'sticky'
                        })
                    );
                    return;
                }
            }
        }
        updateLoanRecord({
            opsAction : action,
            opsRemark : remark,
            loanId : this.recordId,
            assignmentId : this.assignmentRecordId
        })
        .then(data =>{
            console.log(JSON.stringify(data));
            if(data!=null && data.includes('Success')){
                if(action=='Approve'){
                    this.isComplete = true;
                    //LMS Event for CIF Creation Component
                    const payload = { recordIdOfSobject: this.loanApplicantionRecord.id, refreshPage: 'Yes' };
                    publish(this.messageContext, pageRefreshOnMaterialFieldChange, payload);
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record updated',
                        variant: 'success'
                    })
                ); 
            }
            else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Something went wrong',
                        variant: 'error',
                        mode : 'sticky'
                    })
                ); 
            }
        })
        .catch(error =>{
            console.log( 'Error is ' + JSON.stringify( error ) );
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating or refreshing records',
                    message: error,
                    variant: 'error',
                    mode : 'sticky'
                })
            );
        })
    }
    getLinkedFiles(applId){
        getLinkedFiles({
            applId:applId
        })
        .then(data =>{
            console.log('file doc ckecklist '+JSON.stringify(data));
            this.relatedFiles = data;
            this.getDocumentChecklistDetails(applId);
            this.getAddressDetails(applId);
        })
        .catch(error =>{
            console.log('error in checklist '+JSON.stringify(error));
            
        })
    }

    handleReSubmit(){
        let remark = this.template.querySelector('[data-id="RoRemarks"]').value;		
        console.log('remarks '+remark);
        reSubmitRecord({
            loanId: this.recordId,
            assignmentId: this.assignmentRecordId,
            remarks : remark
        })
        .then(data =>{
            console.log('data '+JSON.stringify(data));
            if(data!=null && data.includes('successfully')){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record submited successfully',
                        variant: 'success'
                    })
                ); 
            }
        })
        .catch(error =>{
            console.log('error '+JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Something went wrong',
                    variant: 'error',
                    mode : 'sticky'
                })
            );
        })
    }
    handleSaveApplicant(){
        let verified = true;
        for(var key in this.kycList){
            if(!this.kycList[key].OPS_Action__c && this.kycList[key].Document_Number__c){
                verified = false;
            }

        }
        for(var key in this.kycListNonInd){
            if(!this.kycListNonInd[key].OPS_Action__c && this.kycListNonInd[key].Document_Number__c ){
                verified = false;
            }
        }
        for(var key in this.poiList){
            if(this.poiList[key].Document_Name__c!='Name' && this.poiList[key].Document_Name__c!='DoB' && !this.poiList[key].OPS_Action__c && this.poiList[key].Document_Number__c){
                verified = false
            }
        }
        for(var key in this.nonIndPoIList){
            if(!this.nonIndPoIList[key].OPS_Action__c && this.nonIndPoIList[key].Document_Number__c){
                verified = false
            }
        }
        for(var key in this.poaList){
            if(!this.poaList[key].OPS_Action__c){
                verified = false
            }
        }
        for(var key in this.nonIndPOAList){
            if(!this.nonIndPOAList[key].OPS_Action__c){
                verified = false
            }
        }
        this.isVerified = verified;
        let obj = this.applicantList.find(o=>o.Id==JSON.parse(this.applicant)['Id']);
        obj['Ops_KYC_Verified__c']=verified;

        
        updateApplicant({
            applId : JSON.parse(this.applicant)['Id'],
            loanId : this.recordId,
            verified : verified
        })
        .then(data=>{
            console.log('data in handlesaveapplicant '+JSON.stringify(data));
            /*if(data?.includes('Verified')){
                this.isAllVerified = true;
            }*/
            if(data?.includes('Success')){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Data updated successfully',
                        variant: 'success'
                    })
                ); 
            }
            else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Something went wrong',
                        variant: 'error',
                        mode : 'sticky'
                    })
                );
            }
            
        })
        .catch(error=>{
            console.log('error '+JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Something went wrong',
                    variant: 'error',
                    mode : 'sticky'
                })
            );
        })
    }
}