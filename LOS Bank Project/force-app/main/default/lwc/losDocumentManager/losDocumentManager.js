import { LightningElement, api, track,wire } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import getDocumentChecklist from '@salesforce/apex/LOSDocumentManagerController.getDocumentChecklist';
import getDocumentChecklistOptional from '@salesforce/apex/LOSDocumentManagerController.getDocumentChecklistOptional';
import saveDocList from '@salesforce/apex/LOSDocumentManagerController.saveDocList';
 import getVersionFiles from '@salesforce/apex/LOSDocumentManagerController.getVersionFiles'; 
import { publish, MessageContext } from 'lightning/messageService';
import { getRecord,updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex' 

import DOCUMENT_ID from '@salesforce/messageChannel/PreviewDocId__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getApplicants from '@salesforce/apex/LOSDocumentManagerController.getApplicants';
import deactivateDocument from '@salesforce/apex/LOSDocumentManagerController.deactivateDocument'
import LoanApplicationStage from "@salesforce/schema/Loan_Application__c.Stage__c";
import Loan_ID_FIELD from '@salesforce/schema/Loan_Application__c.Id';
import EmandateStatus from "@salesforce/schema/Loan_Application__c.E_Mandate_Status__c";
import LightningAlert from 'lightning/alert';


import ESignStatus from "@salesforce/schema/Loan_Application__c.Esign_Status__c";
import ApplicationFIStatus from "@salesforce/schema/Loan_Application__c.Application_FI_Status__c";
import OPSKYCAction from "@salesforce/schema/Loan_Application__c.OPS_KYC_Action__c";

import { NavigationMixin } from "lightning/navigation";
import updateOCRDate from '@salesforce/apex/LOSDocumentUploadController.updateOCRData';
import getAssignmentRecord from '@salesforce/apex/LOSDocumentManagerController.getAssignmentRecord';
import generateDocument from '@salesforce/apex/SystemGenerateDocumentsController.systemGenerateDocumentLWCMethod'
import checkFTRStatus from '@salesforce/apex/LOSDocumentManagerController.checkFTRStatus';
import getLoanDetails from '@salesforce/apex/LOSDocumentManagerController.getLoanDetails';

import getMandatoryDocsInOptionals from '@salesforce/apex/Utility.getMandatoryDocsInOptionals';
import checkUploadedDocs from '@salesforce/apex/Utility.checkUploadedDocs' 
import generateDOSanctionApprovalRecords from '@salesforce/apex/SystemGenerateDocumentsController.generateDOSanctionApprovalRecords' 
import updateEMandateStatusOnApp from '@salesforce/apex/LOSDocumentManagerController.updateEMandateStatus' 
import isValidStageCheckProfileCheck from '@salesforce/apex/LOSDocumentManagerController.isValidStageCheckProfileCheck'


const fields = [LoanApplicationStage, EmandateStatus, ESignStatus, ApplicationFIStatus, OPSKYCAction];

export default class LosDocumentManager extends NavigationMixin(LightningElement) {

    get YesNoOptions(){
        return [
            {'label': 'Yes', 'value': 'Yes'},
            {'label': 'No', 'value': 'No'}
        ]
    }

    get DocumentStatusOptions(){
        return [
            {'label': 'Received','value': 'Received'},
            {'label': 'Pending','value': 'Pending'},
            {'label': 'Deferral','value': 'Deferral'}
        ]
    }

    get docCategoryOptions(){
        return [
            {'label': 'Applicant Document','value': 'Applicant__c'},
            {'label': 'Application Document','value': 'Loan_Application__c'},
            {'label': 'Vehicle Document','value': 'Vehicle Document'},
            {'label': 'System Generated Document','value': 'System Generated'}
        ]
    }

    @api fromWizard;
    imageUrl;
isPreviewImage=false;   
 @api recordId;
    @api objectApiName;
    @api fetchOptinaldocs
    applicantRec;
    @api applicantRecord;
    @track showTable;
    @track responseWrap;
    @track propertyDocListToBeDisplayed = [];
    optionalPropertyDocListToBeDisplayed = [];
   @track displayPropertyDocListToBeDisplayed = [];
    MdatoryDocsNames= [];
    @track showOCRDetails=false;
    @track renderApprovalRequestRemarkModal = false;
    @track optionalObjectName;
    isLoanPage =false;
    isMobile;
    stage;
    @wire(MessageContext)
    systemDocName;
    messageContext;
    @track applicantOptions=[];
    selectedApplicant=''
    documentCaterogy = '';
    doCategoryOpt = [];
    isloading=false;
    trueValue =true;
    falseValue =false;
 @track isModalOpen = false;    
get acceptedFormats() {
        return ['.pdf', '.png'];
    }
    applicantRec;
    documentChkRecord;
    isAadhar;
    contentVersionId;
    documentNumber;
    disableSubmit = false;
    applicantDropDownPredefinedValue = '';
    @track approvalRemarks = '';
    isMandatory=false;
    isOptional=false;
    optionalDocsMap = new Map();//map to store optional docs to doc name mapping
    mandatoryDocsMap = new Map();//map to store mandatory docs to doc name mapping
    StageName;
    uploadedDocList=[];
    firstIteration=false;
    @track setRBMApprovalModal = false;
    @track renderFIPendingRBMTatkal = false;
    @track renderESignPendingRBMTatkal = false;
    @track renderGenericPendingRBMTatkal = false;
    @track isValidUploadDeleteGenerate = false;
    //On click remove the selected document 
    handleClearlist(event){
       
        if(this.displayPropertyDocListToBeDisplayed.length > 0)
        this.displayPropertyDocListToBeDisplayed= [];

        if((this.optionalPropertyDocListToBeDisplayed == null) || (this.optionalPropertyDocListToBeDisplayed.length==0))
        return;

            this.optionalPropertyDocListToBeDisplayed.forEach(obj=>{
            if(obj.filesList!=null && obj.filesList.length>0){

            }
            else {
                    this.optionalPropertyDocListToBeDisplayed = [];
                  
            }
        })
        }
      
    
    handleRemarkChange(evt){
        this.approvalRemarks = evt.detail.value;
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

    @track applicationStage = ''
    @track emandateStatus = '';
    @track fiStatus = ''
    @track esignStatus = '';
    @track opsKYCAction = '';
    @track requestDocumentName = '';
    @track rbmApprovalRemarks = '';

    @wire(getRecord, { recordId: '$recordId', fields: fields })
    userDetails({data }) {
        if (data) {
            
            if(data.fields.hasOwnProperty('Stage__c')){
                this.applicationStage = data.fields.Stage__c.value
            }
            if(data.fields.hasOwnProperty('E_Mandate_Status__c')){
                this.emandateStatus = data.fields.E_Mandate_Status__c.value;
            }
            if(data.fields.hasOwnProperty('Application_FI_Status__c')){
                this.fiStatus = data.fields.Application_FI_Status__c.value;
            }
            if(data.fields.hasOwnProperty('Esign_Status__c')){
                this.esignStatus = data.fields.Esign_Status__c.value;
            }
            if(data.fields.hasOwnProperty('OPS_KYC_Action__c')){
                this.opsKYCAction = data.fields.OPS_KYC_Action__c.value;
            }
            console.log('test '+JSON.stringify(this.applicationStage)+' '+this.emandateStatus);

        }
    }
    

    connectedCallback(){
        console.log('record id:'+this.recordId);
        console.log('objectApiName'+this.objectApiName);
        this.setFormFactor();

        if(this.objectApiName =='Loan_Application__c'){
            this.documentCaterogy =this.objectApiName;
            this.getApplicantRecords();
            this.getInitprofileStageCheck(this.recordId);
        }else if(this.objectApiName =='Assignment__c'){
            this.isloading = true;
            getAssignmentRecord({recordId: this.recordId}).then((result)=>{
               this.recordId = result ? result[0].Loan_Application__c : '' ;
               this.objectApiName = 'Loan_Application__c'
               this.getApplicantRecords();
               this.getInitprofileStageCheck(this.recordId);
            }).catch(error => {
                this.error = error;
                this.isloading = false;
            });
        }        
    }

    getInitprofileStageCheck(applicationId){
        isValidStageCheckProfileCheck({loanId : applicationId})
        .then(res=>{
            
            this.isValidUploadDeleteGenerate = res;
        })
        .catch(err=>{
            this.error = err;
            this.isloading = false;
        })
    }

    //get all the mandatory docs list according to the stages
    addMandatoryDocs(){

        getLoanDetails({recordId: this.recordId})
        .then((result)=>{
            this.recordId = result[0].Id;
            this.stageName = result[0].Stage__c;
            if(this.recordId !=null && this.stageName!=null){

                getMandatoryDocsInOptionals({loanId: this.recordId,stage: this.stageName}).then((result)=>{
                    this.MdatoryDocsNames = result ;
                 }).catch(error => {
                     this.error = error;
                     this.isloading = false;
                 });
             }
 
         });

       

    }


    getApplicantRecords(){
        this.isloading = true;
        getApplicants({recordId: this.recordId}).then((data)=>{
            var options=[];
            var none = {label: '--NONE--', value: ""};
            options.push(none);
            data.forEach(element => {
                let fName = element.First_Name__c ? element.First_Name__c : '';
                let lName = element.Last_Name__c ? element.Last_Name__c : '';

                var app = {label: fName + ' '+ lName, value: element.Id}
                options.push(app)
            });
            this.setPredefinedApplicantValue(data);
            this.applicantOptions = options
            this.isLoanPage = true;
            //this.getDocumentCheckListWrapper(recordIdString, objName);
            this.getDocumentCheckListWrapper(this.recordId,this.objectApiName,true);
            this.getDocumentCheckListWrapper(this.recordId,this.objectApiName,false);
            this.isloading = false;
        }).catch(error => {
            this.error = error;
            this.isloading = false;
        });
    }
    setPredefinedApplicantValue(applicantData){
        console.log('test data '+JSON.stringify(applicantData));
        if(applicantData){
            applicantData.forEach(applicant=>{
                if(applicant.RecordType.Name == 'Applicant'){
                    this.applicantDropDownPredefinedValue = applicant.Id;
                }
            })
        }
    }

    //Remove any duplicate which got added to the final list
    removeDuplicates(arr) {
        let unique = [];
        let docs= [];
        arr.forEach(element => {
            if (!docs.includes(element.docName.Document_Master__r.Document_Name__c)) {
                unique.push(element);
                docs.push(element.docName.Document_Master__r.Document_Name__c);
            }
        });
        return unique;
    }

//Add the selected document to the display list
    lookupRecord(event){
        this.isloading = true;
    let optionalDoc = event.detail.selectedRecord;
       if(this.optionalDocsMap.has(optionalDoc.Document_Master__r.Document_Name__c)){
            let doucmentRecord = this.optionalDocsMap.get(optionalDoc.Document_Master__r.Document_Name__c);
          let doumentAlreadyExists = this.containsObject(this.propertyDocListToBeDisplayed,doucmentRecord);
          let documentAlreadyExistsInOptional = this.containsObject(this.optionalPropertyDocListToBeDisplayed,doucmentRecord);
          if(doumentAlreadyExists || documentAlreadyExistsInOptional){
            this.showToastEvent('Error', 'Document already exists', 'error');
          }
          else{
            this.displayPropertyDocListToBeDisplayed.unshift(doucmentRecord);
          }
         
             this.isloading= false;
          
      }
        this.isOptional=true;
        this.isloading= false;

    }

 openModal() {
        this.isModalOpen = true;
      }
    
      closepreviewModal() {
        this.isPreviewImage = false;
      }

     containsObject(arr, obj) {
        for (const item of arr) {
          if (JSON.stringify(item) === JSON.stringify(obj)) {
            return true; // Found the object in the array
          }
        }
        return false; // Object not found in the array
      }

    showVerification = false;
    showDocStatus = false;
    noRecordsFound = false;
    getDocumentCheckListWrapper(recordIdString, objName){
        this.noRecordsFound = false;
        return new Promise(async (resolve) =>{
            getDocumentChecklist({ recorIdStr : recordIdString,
                objectApiName: objName})
            .then((result) => {
                console.log('result&&'+JSON.stringify(result));
                let parseResult=JSON.parse(result);
                this.showVerification = parseResult.showVerification;
                if(!this.stage){
                    this.stage = parseResult.stage;
                }
                this.emandateStatus = parseResult.eMandateStatus;
                this.showDocStatus = parseResult.showDocStatus && this.documentCaterogy != 'System Generated';
                if(parseResult.isSuccess && parseResult.docChkRecords){
                    this.propertyDocListToBeDisplayed = [];
                    setTimeout(() => {
                        this.propertyDocListToBeDisplayed = parseResult.docChkRecords;
                        this.responseWrap = parseResult.reponseWrapper;
                        console.log('this.responseWrap 205'+JSON.stringify(this.propertyDocListToBeDisplayed));
                        this.isloading = false;
                        this.isMandatory=true;
                        this.propertyDocListToBeDisplayed.forEach(obj=>{
                            this.mandatoryDocsMap.set(obj.docName.Document_Master__r.Document_Name__c , obj);
                           });
                           
                        resolve('refresh resolve');
                   }, 100); 
                }else{
                   // this.noRecordsFound = true;
                   // this.isloading = false;
                   // console.log('No result found.');
                    console.log('Error message'+parseResult.message);
                }
                if(parseResult.isSuccess && parseResult.docChkRecords){
                    //console.log(this.optionalPropertyDocListToBeDisplayed);
                   // this.optionalPropertyDocListToBeDisplayed = [];
                    setTimeout(() => {
                        this.optionalPropertyDocListToBeDisplayed = parseResult.docChkRecords;
                      //  this.responseWrap = parseResult.reponseWrapper;
                        console.log('this.responseWrap 205'+JSON.stringify(this.optionalPropertyDocListToBeDisplayed));
                        this.isloading = false;
                        //this.isOptional=true
                       this.optionalPropertyDocListToBeDisplayed.forEach(obj=>{
                        this.optionalDocsMap.set(obj.docName.Document_Master__r.Document_Name__c , obj);
                       });
                     
                        resolve('refresh resolve');
                   }, 100); 
                }else{
                   // this.noRecordsFound = true;
                  //  this.isloading = false;
                    console.log('No result found.');
                    console.log('Error message'+parseResult.message);
                }
            }
            )
            .catch(error => {
                this.error = error;
                this.isloading = false;
            });
        })
    }

    //Method to fetch the optional documents.
    getDocumentCheckListWrapper(recordIdString, objName, fetchOptinaldocs){
        console.log('recordIdString::',recordIdString)
        console.log('objName::',objName)
        console.log('fetchOptinaldocs::',fetchOptinaldocs)
            this.noRecordsFound = false;
            return new Promise(async (resolve) =>{
                getDocumentChecklistOptional({ recorIdStr : recordIdString,
                    objectApiName: objName,dofetchOptionalDocs : fetchOptinaldocs})
                .then((result) => {
                    console.log('result&&'+JSON.stringify(result));
                    let parseResult=JSON.parse(result);
                    this.showVerification = parseResult.showVerification;
                    if(!this.stage){
                        this.stage = parseResult.stage;
                    }
                    this.showDocStatus = parseResult.showDocStatus && this.documentCaterogy != 'System Generated';
                    if(parseResult.isSuccess && parseResult.docChkRecords && fetchOptinaldocs){
                        this.propertyDocListToBeDisplayed = [];
                        setTimeout(() => {
                            let docCheckList = this.removeDuplicates(parseResult.docChkRecords);
                            this.propertyDocListToBeDisplayed = docCheckList;//parseResult.docChkRecords;
                            this.responseWrap = parseResult.reponseWrapper;
                            console.log('this.responseWrap 205'+JSON.stringify(this.propertyDocListToBeDisplayed));
                            this.isloading = false;
                            this.isMandatory=true;
                            this.propertyDocListToBeDisplayed.forEach(obj=>{
                                this.mandatoryDocsMap.set(obj.docName.Document_Master__r.Document_Name__c , obj);
                               });
                               this.addMandatoryDocs();
                               //this.displayPropertyDocListToBeDisplayed = [];
                            resolve('refresh resolve');
                       }, 100); 
                    }else{
                       // this.noRecordsFound = true;
                       // this.isloading = false;
                       // console.log('No result found.');
                        console.log('Error message'+parseResult.message);
                    }
                    if(parseResult.isSuccess && parseResult.docChkRecords && !fetchOptinaldocs){
                        //console.log(this.optionalPropertyDocListToBeDisplayed);
                       // this.optionalPropertyDocListToBeDisplayed = [];
                       setTimeout(() => {
                        this.optionalPropertyDocListToBeDisplayed = parseResult.docChkRecords;
                      //  this.responseWrap = parseResult.reponseWrapper;
                     //   console.log('this.responseWrap 999'+JSON.stringify(this.optionalPropertyDocListToBeDisplayed));
                 
                      this.optionalPropertyDocListToBeDisplayed.forEach(obj=>{
                        this.optionalDocsMap.set(obj.docName.Document_Master__r.Document_Name__c , obj);
                       });
                       this.isOptional=true
                      let filterDocList = []
                       this.optionalPropertyDocListToBeDisplayed.forEach(obj=>{
                        if(obj.filesList!=null && obj.filesList.length>0){
                        filterDocList = [...filterDocList, obj];
                        }
                       });
                          this.optionalPropertyDocListToBeDisplayed = filterDocList;
                      // this.addMandatoryDocs();
                      this.isloading = false;
                        resolve('refresh resolve');
                    }, 100); 
                       
                    }else{
                       // this.noRecordsFound = true;
                      //  this.isloading = false;
                        console.log('No result found.');
                        console.log('Error message'+parseResult.message);
                    }
                }
                )
                .catch(error => {
                    this.error = error;
                    this.isloading = false;
                });
                if(this.documentCaterogy=='System Generated' && this.systemDocName!=null && this.systemDocName!=undefined && this.systemDocName!=''){
                    this.displayPropertyDocListToBeDisplayed  = [];
                }
            })
        }
    handlePreviewClick(event) {
         console.log('File upload finished...');
        console.log('event.currentTarget.dataset.fileType'+event.currentTarget.dataset.filetpe)
        console.log('event.currentTarget.dataset.url'+event.currentTarget.dataset.url)
        console.log('event.currentTarget.dataset.id'+event.currentTarget.dataset.id)

        if(event.currentTarget.dataset.filetpe== 'png' || event.currentTarget.dataset.filetpe== 'jpg' || event.currentTarget.dataset.filetpe== 'jpeg' ){
            this.imageUrl = event.currentTarget.dataset.url;
            this.isModalOpen = true;
            this.isPreviewImage=true;
        }
       else{ 

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
            console.log('in else>>');
            const payload = { docid: event.currentTarget.dataset.url, fileType:isFileTypePDF};
            console.log('in else>>'+JSON.stringify(payload));
            publish(this.messageContext, DOCUMENT_ID, payload);
            /* var thisUrl;
            let id = event.currentTarget.name;
            for(let i=0; i<this.responseWrap.length;i++) {
                console.log('obj url is'+JSON.stringify(this.responseWrap[i].url))
                console.log('id is '+id)
                if(this.responseWrap[i].recordId == id) {
                    thisUrl = this.responseWrap[i].url;
                    if(this.responseWrap[i].fileType == 'pdf'){
                        this.isFileTypePDF = true;
                    }else{
                        this.isFileTypePDF = false;
                    }
                }
            }
            console.log('url is'+thisUrl); */
            

        }
    }
        
    }

    get showApplicantSelect(){
        return this.documentCaterogy == 'Applicant__c'
    }

    handleInputDoc(event){
        let index = event.target.dataset.index;
        if(this.propertyDocListToBeDisplayed[index].filesList!=null)
        this.propertyDocListToBeDisplayed[index][event.target.name] = event.target.checked;  
        else
        this.showToastEvent('Error', 'Please upload the document before verifying', 'error');
        this.disableSubmit = false;
    }

    handleInputDocOptional(event){
        let index = event.target.dataset.index;
        if(this.optionalPropertyDocListToBeDisplayed[index].filesList!=null)
        this.optionalPropertyDocListToBeDisplayed[index][event.target.name] = event.target.checked;  
        else
        this.showToastEvent('Error', 'Please upload the document before verifying', 'error');
        this.disableSubmit = false;
    }

    
    handleChange(event){
        if(event.target.name == 'Applicant__c'){
            this.selectedApplicant = event.target.value;
           // this.getDocumentCheckListWrapper(event.target.value, 'Applicant__c');
            this.getDocumentCheckListWrapper(event.target.value,'Applicant__c',true);
            this.getDocumentCheckListWrapper(event.target.value,'Applicant__c',false);
            this.optionalObjectName=event.target.name;
            this.template.querySelector("c-display-optional-docs").doSearch('','Applicant__c',this.selectedApplicant);
            console.log('event.target.name::',event.target.name);
        }else if(event.target.name == 'docCategory' && event.target.value != 'Applicant__c'){
            this.documentCaterogy = event.target.value;
            this.selectedApplicant = '';
           // this.getDocumentCheckListWrapper(this.recordId, event.target.value);
            this.getDocumentCheckListWrapper(this.recordId,event.target.value,true);
            this.getDocumentCheckListWrapper(this.recordId,event.target.value,false);
            this.optionalObjectName=event.target.value;
            this.template.querySelector("c-display-optional-docs").doSearch('',this.optionalObjectName,'');
            console.log('event.target.value::',event.target.value);
        }else{
            this.documentCaterogy = event.target.value;
            this.selectedApplicant = this.applicantDropDownPredefinedValue;
          //  this.getDocumentCheckListWrapper(this.selectedApplicant, 'Applicant__c');
            this.getDocumentCheckListWrapper(this.selectedApplicant,'Applicant__c',true);
            this.getDocumentCheckListWrapper(this.selectedApplicant,'Applicant__c',false);
            this.optionalObjectName='Applicant__c';
            this.applicantRecord=this.selectedApplicant;
            this.template.querySelector("c-display-optional-docs").doSearch('',this.optionalObjectName,this.applicantRecord);
            console.log('event.target.value;::',event.target.value);
           // this.template.querySelector("c-display-optional-docs").doSearch();
        }

        
        // if(event.target.value){
        //     console.log('event.target.value'+event.target.value);
            
        // }else{
        //     this.getDocumentCheckListWrapper(this.recordId,'Loan_Application__c');
        // }

    }
    handleSuccess(event){
        //this.showUploadComponent = false;
        let eventdocName = event.detail.docName;
        ;
        this.displayPropertyDocListToBeDisplayed = [];
        if(event.detail.isSuccess && event.detail.showOCRInParent){
            console.log('Inside Final Success OCR!!!!');
            this.dataValues = event.detail.ocrData;
            this.applicantRec = event.detail.applicantRec;
            this.documentChkRecord = event.detail.documentChkRecord;
            this.documentNumber = event.detail.documentNumber;
            this.isAadhar = event.detail.isAadhar;
            this.contentVersionId = event.detail.contentVersionId;
            this.showOCRDetails = true;
            if(event.detail.isSuccess){
                console.log('docchecklist ----- '+this.documentChkRecord?.Id);
                checkFTRStatus({
                    docCheckRecord: this.documentChkRecord?.Id,
                    loanId: this.recordId
                })
                .then(data=>{
                    console.log('data '+JSON.stringify(data));
                })
                .catch(error=>{
                    console.log('error '+JSON.stringify(error));
                })
            }
        }else if(event.detail.isSuccess){
            console.log('Inside Final Success NO OCR!!!!');
            if(this.selectedApplicant){
                this.getDocumentCheckListWrapper(this.selectedApplicant,'Applicant__c',true);
                this.getDocumentCheckListWrapper(this.selectedApplicant,'Applicant__c',false);
            }else if(this.documentCaterogy){
                this.getDocumentCheckListWrapper(this.recordId,this.documentCaterogy,true);
                this.getDocumentCheckListWrapper(this.recordId,this.documentCaterogy,false);
        
                if((eventdocName == 'AUWheels0136' || (this.responseWrap && this.responseWrap[0] && this.responseWrap[0].docName == 'E Mandate'))){
                    this.updateEMandateStatus();
                }
            }else{
                this.getDocumentCheckListWrapper(this.recordId,this.objectApiName,true);
                this.getDocumentCheckListWrapper(this.recordId,this.objectApiName,false);
            }
            if(event.detail.isSuccess){
                console.log('docchecklist ----- '+this.responseWrap[0]?.recordId);
                checkFTRStatus({
                    docCheckRecord: this.responseWrap[0]?.recordId,
                    loanId: this.recordId
                })
                .then(data=>{
                    console.log('data '+JSON.stringify(data));
                })
                .catch(error=>{
                    console.log('error '+JSON.stringify(error));
                })
            }
            
        }else{
            this.showToastEvent('Error', event.detail.errorMessage, 'error');
        }
    
    }
    updateEMandateStatus(){
     /*   const FIELDS = {};
        FIELDS[EmandateStatus.fieldApiName] = 'Accepted';
        FIELDS[Loan_ID_FIELD.fieldApiName] =  this.recordId;
        const recordInputForUpdate ={fields: FIELDS};
        updateRecord(recordInputForUpdate).then(() => {
    
        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Updating record',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        }) */
        updateEMandateStatusOnApp({
            loanId : this.recordId
        }).then((result) => {

        }).catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error Updating record',
                    message: error.body.message,
                    variant: 'error',
                }),
            );
        })
    }
    showToastEvent(titleValue, messageValue, variantValue){
        const event = new ShowToastEvent({
            title: titleValue, 
            message: messageValue,
            variant: variantValue
        });
        this.dispatchEvent(event);
    }
    handleClickDelete(event){
        if(!this.isValidUploadDeleteGenerate){
            this.showToastEvent('The user is not authorised to delete document '+' at '+this.applicationStage+' stage.','error');
            return;

        }
        let id = event.currentTarget.name;
        console.log('ContentVersionid'+id);
        deactivateDocument({ recordId : id})
        .then((result) => {
            let parseResult=JSON.parse(result);
            if(parseResult.isSuccess ){
                if(this.selectedApplicant){
                    this.getDocumentCheckListWrapper(this.selectedApplicant,'Applicant__c',true);
                    this.getDocumentCheckListWrapper(this.selectedApplicant,'Applicant__c',false);
                }else if(this.documentCaterogy){
                    console.log('came into this.documentCaterogy: '+this.documentCaterogy,true);
                    this.getDocumentCheckListWrapper(this.recordId,this.documentCaterogy,true);
                    this.getDocumentCheckListWrapper(this.recordId,this.documentCaterogy,false);
                }else{
                    this.getDocumentCheckListWrapper(this.recordId,this.objectApiName,true);
                    this.getDocumentCheckListWrapper(this.recordId,this.objectApiName,false);
                }
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
    okClick(){
        this.updateRecords(true);
    }
    notOkClick(){
        //this.updateRecords(false);
        console.log('');
        //this.showUploadComponent = false;
        this.showOCRDetails = false;

    }
    updateRecords(isOkBoolean){
        this.isloading= true;
        updateOCRDate({ applicantRec: this.applicantRec, documentChkRecord: this.documentChkRecord,isAadhar: this.isAadhar,isOk :isOkBoolean,contentVersionId :this.contentVersionId })
        .then(result => {
            this.isloading= false;
            let parseResult=JSON.parse(result);
            if(parseResult.isSuccess){
                this.showToastEvent('Success', 'Details Updated Succesfully!!', 'success');
                this.showOCRDetails = false;
                                if(this.selectedApplicant){
                    this.getDocumentCheckListWrapper(this.selectedApplicant,'Applicant__c',true);
                }else if(this.documentCaterogy){
                    this.getDocumentCheckListWrapper(this.recordId,this.documentCaterogy,true);
                }else{
                    this.getDocumentCheckListWrapper(this.recordId,this.objectApiName,true);
                }
            }else{
                this.showToastEvent('Error', 'We Encountered an Error while updating details!!', 'error');
                const resultEvent = {isSuccess:false};
                const documentHandlerEvent = new CustomEvent('documentsuccess', {
                detail : resultEvent
                });
                this.dispatchEvent(documentHandlerEvent);
                this.showOCRDetails = false;
            }
        })
        .catch(error => {
            this.isloading= false;
            this.error = error;
            console.log('error', error);
        })
    }


        

    handleSubmit(event){
            this.isloading = true;
            let obj = {};
            this.propertyDocListToBeDisplayed.push.apply(this.propertyDocListToBeDisplayed,this.optionalPropertyDocListToBeDisplayed);
            obj.wrapper = this.propertyDocListToBeDisplayed;
            obj.loanId = this.recordId;
            saveDocList({jsonStr:JSON.stringify(obj)})
                .then((result) => {
                    console.log('result-->' + JSON.stringify(result));
                    if(result == 'success'){
                        this.showToastMessage('success','Data Updated Successfully');
                        if(this.selectedApplicant){
                            this.getDocumentCheckListWrapper(this.selectedApplicant,'Applicant__c',true);
                        }else if(this.documentCaterogy){
                            this.getDocumentCheckListWrapper(this.recordId,this.documentCaterogy,true);
                        }else{
                            this.getDocumentCheckListWrapper(this.recordId,this.objectApiName),true;
                        }
                    }else{
                        this.isloading = false;
                    }
                })
                .catch((error) => {
                    console.log('error-->' + JSON.stringify(error));
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

        closeRBMModal(){
            this.renderFIPendingRBMTatkal = false;
            this.renderESignPendingRBMTatkal = false;
            this.renderGenericPendingRBMTatkal = false;
            this.setRBMApprovalModal = false;
            this.rbmApprovalRemarks = '';
            this.requestDocumentName = '';
        }

        handleRBMApprovalRemarks(evt){
            this.rbmApprovalRemarks = evt.detail.value;
        }

        generateSanction_DOApproval(letterName){
            this.isloading = true;
            generateDOSanctionApprovalRecords({
                loanId : this.recordId,
                letterType : letterName,
                remarks : this.approvalRemarks,
                isRBMTatkal : false
            })
            .then(res=>{

                this.showToastEvent(res,'success');
                this.isloading = false;
                this.approvalRemarks='';
                this.closeModal();
            })
            .catch(err=>{
                this.showToastEvent(err.body.message,'error');
                this.isloading = false;
                this.approvalRemarks='';
                this.closeModal();
            })

        }

        closeModal(){
            this.renderApprovalRequestRemarkModal = false;
        }

        generateApprovalRequest(){
            if(this.handleRemarkValidation()){
                this.generateSanction_DOApproval('Sanction Letter');
            }
            else{
                return;
            }

        }

        handleRemarkValidation(){
            let isValid = true;
            let reason = this.template.querySelector("lightning-textarea");
            if(!reason.value) {
                isValid = false;
                reason.setCustomValidity("Please provide valid remarks to proceed");
            } else {
                isValid = true;
                reason.setCustomValidity(""); // clear previous value
            }
            reason.reportValidity();
            return isValid;
        }

        generateRBMApprovalRequest(){
            this.generateRBMSystemLetterRequest();
        }

        generateRBMSystemLetterRequest(){
            this.isloading = true;
            generateDOSanctionApprovalRecords({
                loanId : this.recordId,
                letterType : this.requestDocumentName,
                remarks : this.rbmApprovalRemarks,
                isRBMTatkal : true
            })
            .then(res=>{
                this.showToastEvent(res,'success');
                this.isloading = false;
                this.approvalRemarks='';
                this.closeRBMModal();
            })
            .catch(err=>{
                this.showToastEvent(err.body.message,'success');
                this.isloading = false;
                this.approvalRemarks='';
                this.closeRBMModal();
            })
        }

        handleDocGenerate(event){
            if(this.applicationStage == 'QDE' || this.applicationStage == 'DDE'){
                if(event.currentTarget.dataset.docname == 'Sanction Letter' || event.currentTarget.dataset.docname == 'Delivery Order'){
                    this.showToastEvent('Sanction and DO Letter cannot be generated at QDE/DDE Stage','error');
                    return;
                }
            }

            if(this.applicationStage == 'Credit'){
                if(event.currentTarget.dataset.docname == 'Delivery Order'){
                    this.showToastEvent('DO Letter cannot be generated at Credit Stage','error');
                    return;
                }
            }
            


            if(this.applicationStage == 'Credit'){
                if(event.currentTarget.dataset.docname == 'Sanction Letter'){
                    this.renderApprovalRequestRemarkModal = true;
                    //this.generateSanction_DOApproval(event.currentTarget.dataset.docname);
                    //this.isloading = false;
                    return;
                }
                
            }

            if(this.applicationStage == 'PSD' && (event.currentTarget.dataset.docname=='Sanction Letter' || event.currentTarget.dataset.docname == 'Delivery Order')){
                if((this.fiStatus == 'Waived Off' || this.fiStatus == 'Negative' || this.fiStatus == 'Positive') && this.esignStatus !='Initiated' && this.opsKYCAction !='Rework'){
                    this.setRBMApprovalModal = false;
                    this.requestDocumentName = event.currentTarget.dataset.docname
                    this.systemDocName = event.target.dataset.docname;
                    //return;
                }
                else{
                    this.renderFIPendingRBMTatkal = !(this.fiStatus == 'Waived Off' || this.fiStatus == 'Negative' || this.fiStatus == 'Positive');
                    if(!this.renderFIPendingRBMTatkal){
                        this.renderESignPendingRBMTatkal = !(this.esignStatus !='Initiated');
                        if(!this.renderESignPendingRBMTatkal){
                            this.renderGenericPendingRBMTatkal = true;
                        }
                    }
                    this.setRBMApprovalModal = true;
                    this.requestDocumentName = event.currentTarget.dataset.docname
                    this.systemDocName = event.target.dataset.docname;
                    return;
                }
                
            }
            if(!this.isValidUploadDeleteGenerate){
                this.showToastEvent('The user is not authorised to Generate document '+event.currentTarget.dataset.docname+' at '+this.applicationStage+' stage.','error');
                return;

            }
            this.isloading = true;
            generateDocument({
                letterType : event.target.dataset.docname,
                applicationId : this.recordId
            }).then((result) => {
                this.isloading = false;
                if(this.documentCaterogy){
                    this.getDocumentCheckListWrapper(this.recordId,this.documentCaterogy,true);
                    this.getDocumentCheckListWrapper(this.recordId,this.documentCaterogy,false);
                }else{
                    this.getDocumentCheckListWrapper(this.recordId,this.objectApiName,true);
                    this.getDocumentCheckListWrapper(this.recordId,this.objectApiName,false);
                }
            })
            .catch((error) => {
                console.log('error-->' + JSON.stringify(error));
                this.isloading = false;

            })
            .finally(() => {                
                this.isloading = false;
            })
        }

        errorOnChild;

        @api async nextHandler() {
            
            const Obj = {};
            let response =  await this.validateSubmit();
            console.log('responseinsub-->' +response);
            if(response == true){
                this.errorOnChild = '';
                Obj.errorOnChild = this.errorOnChild;
                Obj.next = this.errorOnChild == '' ? true : false;
                console.log('Obj', Obj);
                this.dispatchEvent(new CustomEvent('next', {
                    detail: Obj
                }));
            }
        }

        validateSubmit(){
            return new Promise((resolve, reject) => {
                let response = false;
                checkUploadedDocs({  loanId: this.recordId, stage: this.stage })
                .then(data => {
                   console.log('data-->' +JSON.stringify(data));
                    if (data && data.status == 'Success') {
                  //      this.showToastMessage('success',data.messages[0]);
                        response = true;
                        resolve(response);
                    }else{
                        let messaage = data.messages;
                        this.showErrorMessage(JSON.stringify(messaage), 'error');
                        response = false;
                        reject('');
                    }
                })
                .catch(error => {
                    reject('');
                });
            })
        }

        showErrorMessage(message, variant) {
            const event = new ShowToastEvent({
                title: '',
                variant: variant,
                mode: 'sticky',
                message: message
            });
            this.dispatchEvent(event);
        }
}