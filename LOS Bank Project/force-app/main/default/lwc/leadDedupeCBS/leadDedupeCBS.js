// apexWireMethodToProperty.js
import { api, LightningElement, track, wire } from 'lwc';
import getCBSApplicantDetail from '@salesforce/apex/LeadDedupeController.getCBSApplicantDetail';
import getCCResponse from '@salesforce/apex/LeadDedupeController.getCCResponse';
import getCustomerODResponse from '@salesforce/apex/LeadDedupeController.getCustomerODResponse';
import Id from '@salesforce/user/Id';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import UserNameFIELD from '@salesforce/schema/User.Name';
import ProfileNameFIELD from '@salesforce/schema/User.Profile.Name';
import LOAN_APPLICATION_ID from '@salesforce/schema/Applicant__c.Loan__c';
import StageName from '@salesforce/schema/Loan_Application__c.Stage__c';
import LOAN_APP_ID_FIELD from '@salesforce/schema/Loan_Application__c.Id'
import RO_LEAD_DEDUPE_REMARKS from '@salesforce/schema/Loan_Application__c.RO_Lead_Dedupe_Remarks__c';
import CREDIT_LEAD_DEDUPE_REMARKS from '@salesforce/schema/Loan_Application__c.Credit_Lead_Dedupe_Remarks__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class leadDedupeCBS extends LightningElement {
     @api
     inputValues;
     @api
     countFullInd;
     @api
     countFullNonInd;
     @api
     spinnerImage;

     @api
     applicantInput = {};
     @api
     staticRecordId;
     @api
     boolIsNPA;
     boolDPDFound = false;
     /*
     mobile = '1234567890';
     aadhar = '123456789012';
     pan = 'CQEPP0017E';
     */
     inputValuesJson;

     @api
     applicants;
     applicantRecord = {};
     applicantODRecord = [];
     applicantCreditCard = {};
     applicantODDetail = {};
     viewMoreFull = false
     //viewLessFull
     viewMorePartial = false
     //viewLessPartial
     @track norecordsFull = false;
     norecordsPartial = false;

     isLoading = false;
     activeSections = [];

     ROLeadDedupeRemarks;
     CreditLeadDedupeRemarks;
     leadInputParams;
     currentUserProfile;
     hideCreditLead;
     hideROLead;
     isROLeadDisable = false;
     isRequiredCreditLead = false;
     hideRemarksSaveButton;

     _loanAppId;

     get loanAppId(){
     return this._loanAppId;
     }
     @api set loanAppId(value){
     this._loanAppId = value;
     console.log('this._loanAppId: '+this._loanAppId);
     }

     _applicantId;

    // We add a getter and setter
    @api 
    get applicantId() {
        return this._applicantId;
    }

    set applicantId(newValue) {
        // This is going to be executed every time 
        // projects receive a new value
        this._applicantId = newValue;
    }


     @wire(getRecord, { recordId: Id, fields: [UserNameFIELD, ProfileNameFIELD] })
     currentUserInfo({ error, data }) {
          if (data) {
               console.log(JSON.stringify(data.fields));
               console.log(JSON.stringify(this.loanAppId));
               this.currentUserProfile = data.fields.Profile.value.fields.Name.value;
          } else if (error) {
               this.error = error;
          }
     }
     @wire(getRecord, { recordId: '$loanId', fields: [StageName, RO_LEAD_DEDUPE_REMARKS, CREDIT_LEAD_DEDUPE_REMARKS] })
     UserInfo({ error, data }) {
          if (data) {
               console.log('this.isRequiredCreditLead: '+this.isRequiredCreditLead);
               this.stageName = data.fields.Stage__c.value;
               this.ROLeadDedupeRemarks = data.fields.RO_Lead_Dedupe_Remarks__c.value;
               this.CreditLeadDedupeRemarks = data.fields.Credit_Lead_Dedupe_Remarks__c.value;             
               
               if (this.currentUserProfile == 'Sales') {
                    this.isRequiredCreditLead = false;
                    this.isROLeadDisable = false;
                    this.hideCreditLead = 'slds-hide';
               }
               else if (this.currentUserProfile == 'Credit Manager' && this.stageName == 'Credit') {
                    this.isRequiredCreditLead = true;
                    this.isROLeadDisable = true;
                    this.hideCreditLead = '';
                    console.log('this.isRequiredCreditLead: '+this.isRequiredCreditLead);
                    console.log('this.isROLeadDisable: '+this.isROLeadDisable);
                    console.log('this.hideCreditLead: '+this.hideCreditLead);
               }
               else {
                    this.hideCreditLead = 'slds-hide';
                    this.hideROLead = 'slds-hide';
                    this.hideRemarksSaveButton = 'slds-hide';
               }
          } else if (error) {
               this.error = error;
          }
     }

     @wire(getRecord, { recordId: '$_applicantId', fields: [LOAN_APPLICATION_ID] })
     applicantRec;
    
    get loanId() {
        return getFieldValue(this.applicantRec.data, LOAN_APPLICATION_ID);
    }
     handleChangeRoDedupeRemarks(event){
          this.ROLeadDedupeRemarks = event.detail.value
     }
     handleChangeCreditDedupeRemarks(event){
          this.CreditLeadDedupeRemarks = event.detail.value
     }
     handleChangeRoRemarks(event){
          this.RORemarks = event.detail.value
     }
     handleChangeCreditManagerRemarks(event){
          this.CreditManagerRemarks = event.detail.value
     }

     handleSave(){
          console.log('handleSave: '+this.loanId);
          this.isLoading=true;
          if(this.isRequiredCreditLead && !this.CreditLeadDedupeRemarks){
               this.isLoading=false;
               this.template.querySelector('c-common-toast').showToast('Error', '<strong> Please Populate Credit Lead Dedupe Remarks.<strong/>', 'utility:error', 10000);
          }else{
               const fields = {};
               //fields[LOAN_APP_ID_FIELD.fieldApiName] = this.loanId;
               fields[LOAN_APP_ID_FIELD.fieldApiName] = this.loanId;
               fields[RO_LEAD_DEDUPE_REMARKS.fieldApiName] = this.ROLeadDedupeRemarks;
               fields[CREDIT_LEAD_DEDUPE_REMARKS.fieldApiName] = this.CreditLeadDedupeRemarks;
               const recordInput = {
               fields: fields
               };
               console.log('recordInput: '+JSON.stringify(recordInput));
               updateRecord(recordInput).then(() => {
                    this.isLoading=false;
                    this.template.querySelector('c-common-toast').showToast('success', '<strong>' + 'Record Saved Successfully' + '<strong/>', 'utility:success', 10000);
               })
               .catch(error => {
                    this.isLoading=false;
               let errMsg = '';                    
               if (error && error.body && error.body.message) {
                    console.log('error: '+JSON.stringify(error));
                    errMsg = error.body.message;
                    console.log('errMsg: '+errMsg);
                    this.template.querySelector('c-common-toast').showToast('Error', '<strong>' + errMsg+ '<strong/>', 'utility:error', 10000);
               }                    
               
               });
          }
     }

     /*
     @wire(getCBSApplicantList, { objleadInputParams :'$inputValuesJson' })
     wired({ error, data }) {
          //this.isLoading = true;
          if (error) {
               this.error = error;
               console.log('error', error);
               this.isLoading = false;
           }
          else if (data) {
               console.log('%% '+JSON.stringify(data));
               this.isLoading = true;
               let tempData = {};
               tempData.data = data;
               this.applicants = tempData;
               console.log('%% '+this.applicants);
               this.isLoading = false;
          }
     }*/
     /*
     @wire(getApplicantListCBS, { objleadInputParams :'$inputValuesJson' })
     wired({ error, data }) {
          if (error) {
               this.error = error;
               console.log('error', error);
           }
          else if (data) {
               console.log('%% '+JSON.stringify(data));
               let tempData = {};
               tempData.data = data;
               this.applicants = tempData;
               console.log('%% '+this.applicants);
          }
     }
     */
     connectedCallback() {
          if(this.applicants.applicantList_fullMatch == undefined || 
               this.applicants.applicantList_fullMatch.length == 0){
               this.norecordsFull = true;
          }
          if(this.applicants.applicantList_partialMatch == undefined || 
               this.applicants.applicantList_partialMatch.length == 0){
               this.norecordsPartial = true;
          }
          this.activeSections = [...this.activeSections,'A','B'];
          //this.applicants = this.applicantsList;
          //this.inputValuesJson = this.inputValues;
          //console.log('%% '+JSON.stringify(this.applicants));
     }

     @api
     setNoRecordsFullFalse(){
          this.norecordsFull = false;
     }


     @api
     setNoRecordsPartiallFalse(){
          this.norecordsPartial = false;
     }
     

     viewMoreHandler(event){
          console.log('%% '+event);
          //console.log('%% '+event.currentTarget);
          //console.log('%% '+event.currentTarget.dataset);
          console.log('%% '+JSON.stringify(this.inputValuesJson));
          console.log('%% '+this.countFullInd);
          console.log('%% '+this.countFullNonInd);
          
          //this.viewLessFull = false
          var recordId = event.currentTarget.dataset.id;
          var card = event.currentTarget.dataset.card;
          var countFull = this.countFullInd + this.countFullNonInd;
          console.log('%% '+recordId);
          this.isLoading = true;
          //this.dispatchEvent(new CustomEvent('spinnerevent', {detail: true , bubbles :true, composed : true}));
          Promise.all([
               getCBSApplicantDetail({ strCustomerId : recordId ,strApplicantId : this.applicantInput.Id , cardName : card, countFull : countFull}),
               getCCResponse({ strCustomerId : recordId ,strApplicantId : this.applicantInput.Id}),
               getCustomerODResponse({ strCustomerId : recordId ,strApplicantId : this.applicantInput.Id})
          ]).then((values) => {
               if(values[0] != undefined){
                    this.applicantRecord = values[0];
               }
               if(values[1] != undefined){
                    this.applicantCreditCard = values[1];
               }
               if(values[2] != undefined){
                    this.applicantODRecord = values[2];
               }
               console.log(this.applicantODRecord);
               //this.boolDPDFound = this.applicantODRecord.boolIsDPDFound;
               let applicantDPDMatch = this.applicantODRecord.find((item)=>item.boolIsDPDFound === true);
               if(applicantDPDMatch != undefined && applicantDPDMatch != null){
                    this.boolDPDFound = true;
               }
               console.log(this.boolDPDFound);
               console.log(values);
               this.error = undefined;
               this.isLoading = false;
               //this.dispatchEvent(new CustomEvent('spinnerevent', {detail: false , bubbles :true, composed : true}));
               if(this.applicantRecord && this.applicantRecord.strCustomerID){
               if(card == 'full'){
                    this.viewMoreFull = true
               }
               if(card == 'partial'){
                    this.viewMorePartial = true
               }
               }else{
                    this.dispatchEvent(
                         new ShowToastEvent({
                             title: '',
                             message: 'We did not receive any Match from CBS. Please Re-try',
                             variant: 'error',
                             mode: 'sticky'
                         }),
                     );
               }
               
          }).catch(error => {
               if(error[0] != undefined){
                    this.error = error[0];
               }
               if(error[1] != undefined){
                    this.error = error[1];
               }
               console.log('resultCC is '+error)
               //this.error = errorCC;
               this.isLoading = false;
               //this.dispatchEvent(new CustomEvent('spinnerevent', {detail: true , bubbles :true, composed : true}));
               //this.accounts = undefined;
          })
          /*
          
          getCBSApplicantDetail({ strCustomerId : recordId ,strApplicantId : this.applicantInput.Id , cardName : card})
		.then(result => {
               this.applicantRecord = result;
               getCCResponse({ strCustomerId : recordId ,strApplicantId : this.applicantInput.Id})
		     .then(resultCC => {
                    console.log('resultCC is '+JSON.stringify(resultCC));
                    if(resultCC != ''){
                         this.applicantCreditCard = resultCC;
                    }
                    this.error = undefined;
                    this.isLoading = false;
                    if(card == 'full'){
                         this.viewMoreFull = true
                    }
                    if(card == 'partial'){
                         this.viewMorePartial = true
                    }
               })
               .catch(errorCC => {
               console.log('resultCC is '+errorCC)
                    this.error = errorCC;
                    this.isLoading = false;
                    //this.accounts = undefined;
               })
		})
		.catch(error => {
            console.log('result is '+error)
			this.error = error;
               this.isLoading = false;
			//this.accounts = undefined;
		})*/
          console.log('%% '+JSON.stringify(this.applicantRecord));
     }

     viewLessHandler(event){
          this.applicantRecord = {};
          if(this.viewMoreFull){
               this.viewMoreFull = false;
          }
          if(this.viewMorePartial){
               this.viewMorePartial = false;
          }
          //this.viewLessFull = true
     }

     setlistview(event){
          try {
               console.log('%%%'+JSON.stringify(event.detail));
               var entdetail = event.detail;
               //event.stopPropogation();
               if(this.viewMoreFull){
                    this.viewMoreFull = false;
               }
               if(this.viewMorePartial){
                    this.viewMorePartial = false;
               }

               this.dispatchEvent(new CustomEvent('copyrecord',{detail:{value:entdetail,tab:'CBS'}}));
          }
          catch(err) {
               console.log('%% '+err.message);
          }
          //this.dispatchEvent(new CustomEvent('copyapplicantparent',{ detail: entdetail }));
     }
}