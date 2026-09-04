import { LightningElement, wire, api, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';

import Id from '@salesforce/user/Id';
import UserNameFIELD from '@salesforce/schema/User.Name';
import ProfileNameFIELD from '@salesforce/schema/User.Profile.Name';
import LOAN_APPLICATION_ID from '@salesforce/schema/Applicant__c.Loan__c';
import StageName from '@salesforce/schema/Loan_Application__c.Stage__c';
import LOAN_APP_ID_FIELD from '@salesforce/schema/Loan_Application__c.Id'
import RO_LEAD_DEDUPE_REMARKS from '@salesforce/schema/Loan_Application__c.RO_Lead_Dedupe_Remarks__c';
import CREDIT_LEAD_DEDUPE_REMARKS from '@salesforce/schema/Loan_Application__c.Credit_Lead_Dedupe_Remarks__c';

import getCRMApplicantList from '@salesforce/apex/LeadDedupeController.getCRMApplicantList';

export default class leadDedupeCRM extends LightningElement {
     @api recordId;
     @api loanAppId;
     userProfileName = '';
     @api
     applicantInput = {};
     @api 
     boolIsFromWizard;
     @api
     boolIsNPA;
     @api
     spinnerImage;
     viewMoreFull = false
     viewMorePartial = false
     viewLess
     applicantRecord;
     @track
     applicantsFull;
     @track
     applicantsPartial;
     boolNorecordsFull = false;
     boolNorecordsPartial = false;
     isLoading;
     errorOnChild = '';
     @api applicableDedupeActions = [ 'Full', 'Partial', 'Lead - Other Products', 'Dedupe Remarks', 'Applicant Copy' ]; //R2-28 - Matching Leads to be shown on Lead Record page
     @api
     totalApplicants = [];
     totalApplicantsFull = [];
     totalApplicantsPartial = [];
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
     
     // * R2-28
     get isFullMatchApplicable(){
          return this.applicableDedupeActions?.includes('Full');
     }
     get isPartialMatchApplicable(){
          return this.applicableDedupeActions?.includes('Partial');
     }
     get isExistingLeadsApplicable(){
          return this.applicableDedupeActions?.includes('Lead - Other Products');
     }
     get showDedupeRemarksSection(){
          return this.applicableDedupeActions?.includes('Dedupe Remarks');
     }
     // ** R2-28

     @wire(getRecord, { recordId: Id, fields: [UserNameFIELD, ProfileNameFIELD] })
     currentUserInfo({ error, data }) {
          if (data) {
               console.log(JSON.stringify(data.fields));
               console.log('this.loanAppId: '+JSON.stringify(this.loanAppId));
               this.currentUserProfile = data.fields.Profile.value.fields.Name.value;
          } else if (error) {
               this.error = error;
          }
     }
     @wire(getRecord, { recordId: '$loanId', fields: [StageName, RO_LEAD_DEDUPE_REMARKS, CREDIT_LEAD_DEDUPE_REMARKS] })
     UserInfo({ error, data }) {
          if (data) {
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

     @wire(getRecord, { recordId: '$leadInputParams', fields: [LOAN_APPLICATION_ID] })
     applicantRec;
    
    get loanId() {
        return getFieldValue(this.applicantRec.data, LOAN_APPLICATION_ID);
    }

//     @wire(getLoanAppApprovalDetails, { loanId: '$loanId' })
//     getLoanApproval({ error, data }) {
//      console.log('came in');
//         if(data){
//           console.log('data: '+data);
//           if(this.currentUserProfile == 'Credit Manager' && this.stageName == 'Credit'){
//                this.isBaseCredit = true;
//           }else{
//                this.isBaseCredit = false;
//           }
//         }else{
//           this.isBaseCredit = false;
//         }
//      }


     connectedCallback() {
          this.activeSections = [...this.activeSections,'A','B','C'];
          this.leadInputParams = this.applicantInput.Id;
          console.log('%% '+JSON.stringify(this.leadInputParams));
          console.log('%%totalApplicants '+JSON.stringify(this.totalApplicants));
          
          //getCRMApplicantList({ applicantId : this.leadInputParams , boolIsWizard : this.boolIsFromWizard})
		//.then(result => {
          //     this.totalApplicants = result;
               this.totalApplicantsFull = this.totalApplicants.filter((item)=>item.boolIsFullMatch === true);
               this.totalApplicantsPartial = this.totalApplicants.filter((item)=>item.boolIsFullMatch === false);
               console.log('totalApplicantsFull'+JSON.stringify(this.totalApplicantsFull));
               if(this.totalApplicantsFull.length == 0){
                    this.boolNorecordsFull = true;
               }
               if(this.totalApplicantsPartial.length == 0){
                    this.boolNorecordsPartial = true;
               }
               let blockNextFull = this.totalApplicantsFull.find((item)=>item.boolBlockNext === true);
               let blockNextPartial = this.totalApplicantsPartial.find((item)=>item.boolBlockNext === true);
               if((blockNextFull != undefined && blockNextFull.boolBlockNext) || 
                    (blockNextPartial != undefined && blockNextPartial.boolBlockNext)){
                    this.dispatchEvent(new CustomEvent('blocknext'));
               }
               this.isLoading = false;
               
		/*})
		.catch(error => {
               if(this.totalApplicantsFull.length == 0){
                    this.boolNorecordsFull = true;
               }
               if(this.totalApplicantsPartial.length == 0){
                    this.boolNorecordsPartial = true;
               }
               this.isLoading = false;
               console.log('result is '+JSON.stringify(error));
		})*/
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

     viewMoreHandler(event){     
          var recordId = event.currentTarget.dataset.id;
          var card = event.currentTarget.dataset.card;
          console.log('%% '+recordId);
          if(card=='full'){
               this.applicantRecord = this.applicantsFull.find((item)=>item.applicant.Id === recordId);
               this.viewMoreFull = true
          }
          if(card=='partial'){
               this.applicantRecord = this.applicantsPartial.find((item)=>item.applicant.Id === recordId);
               this.viewMorePartial = true
          }
          console.log('%% '+this.applicantRecord);
          this.viewLess = false
     }
     viewLessHandler(){
          this.viewMoreFull = false
          this.viewMorePartial = false
          this.viewLess = true
     }

     updateApplicantsHandler(event){
          console.log('%%%updateApplicantsHandler '+event.detail.records);
          let currentRecords = [...event.detail.records];
          if(currentRecords != undefined){
               let IsfullRecords = currentRecords.find((item)=>item.boolIsFullMatch === true);
               if(IsfullRecords != undefined && IsfullRecords.boolIsFullMatch){
                    this.applicantsFull = currentRecords;
               }
               else{
                    this.applicantsPartial = currentRecords;
               }
          }
          console.log('%%%applicants '+JSON.stringify(currentRecords));
          //console.log('%%%updateApplicantsHandler '+event.detail.section);
          /*if(event.detail.section=='full'){
               this.applicantsFull=[...event.detail.records]
          }
          if(event.detail.section=='partial'){
               this.applicantsPartial=[...event.detail.records]
          }*/
     }
     /*
     selectRecordHandler(event){
          const selectedRecordId = event.detail.selectedRecordId;
          console.log('%%%selectedRecord '+selectedRecordId);
          let data = this.applicants;
          let tempList = [];
          data.forEach(function(app){
               if(app.applicant.Id == selectedRecordId){
                    app.boolIsSelected = true;
               }
               tempList.push(app);
          });
          this.applicants = tempList;
          console.log('Obj'+ JSON.stringify(event.detail.result));
     }*/
}