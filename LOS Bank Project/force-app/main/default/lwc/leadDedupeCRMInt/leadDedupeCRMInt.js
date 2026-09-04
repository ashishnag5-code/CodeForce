import { LightningElement, wire, api, track } from 'lwc';
import getLeadtoLeadAppList from '@salesforce/apex/LeadDedupeController.getLeadtoLeadAppList';

export default class leadDedupeCRM extends LightningElement {
     leadInputParams;
     @api
     applicantInput = {};
     @api
     spinnerImage;
     @api 
     boolIsFromWizard;
     viewMore = false
     //viewMorePartial = false
     viewLess
     applicantRecord;
     //@track
     //applicantsFull;
     @track
     applicants = [];
     boolNorecords = false;
     //boolNorecordsPartial = false;
     isLoading;
     errorOnChild = '';
     totalApplicants = [];
     //totalApplicantsFull = [];
     //totalApplicantsPartial = [];

     connectedCallback() {
        this.isLoading = true;
        //this.leadInputParams = this.applicantInput.Id;
        console.log('%% '+JSON.stringify(this.leadInputParams));
        getLeadtoLeadAppList({ strApplicantId : this.applicantInput.Id , boolIsWizard : this.boolIsFromWizard})
		.then(result => {
            console.log('%%% '+JSON.stringify(result));
            this.totalApplicants = result;
               /*this.totalApplicantsFull = this.totalApplicants.filter((item)=>item.boolIsFullMatch === true);
               this.totalApplicantsPartial = this.totalApplicants.filter((item)=>item.boolIsFullMatch === false);
               console.log('totalApplicantsFull'+JSON.stringify(this.totalApplicantsFull));
               if(this.totalApplicantsFull.length == 0){
                    this.boolNorecordsFull = true;
               }
               if(this.totalApplicantsPartial.length == 0){
                    this.totalApplicantsPartial = true;
               }
               let blockNextFull = this.totalApplicantsFull.find((item)=>item.boolBlockNext === true);
               let blockNextPartial = this.totalApplicantsPartial.find((item)=>item.boolBlockNext === true);
               if((blockNextFull != undefined && blockNextFull.boolBlockNext) || 
                    (blockNextPartial != undefined && blockNextPartial.boolBlockNext)){
                    this.dispatchEvent(new CustomEvent('blocknext'));
               }*/
            this.isLoading = false;
		})
		.catch(error => {
            if(this.totalApplicants.length == 0){
                this.boolNorecords = true;
            }
            this.isLoading = false;
            console.log('result is '+JSON.stringify(error));
		})
     }

     viewMoreHandler(event){     
          var recordId = event.currentTarget.dataset.id;
          /*var card = event.currentTarget.dataset.card;
          console.log('%% '+recordId);
          if(card=='full'){
               this.applicantRecord = this.applicantsFull.find((item)=>item.applicant.Id === recordId);
               this.viewMoreFull = true
          }
          if(card=='partial'){*/
               this.applicantRecord = this.applicants.find((item)=>item.strApplicationNumber === recordId);
               this.viewMore = true
          //}
          console.log('%% '+this.applicantRecord);
          this.viewLess = false
     }
     viewLessHandler(){
          this.viewMore = false
          //this.viewMorePartial = false
          this.viewLess = true
     }

     updateApplicantsHandler(event){
          console.log('%%%updateApplicantsHandler '+event.detail.records);
          let currentRecords = [...event.detail.records];
          if(currentRecords != undefined){
                this.applicants = currentRecords;
               /*let IsfullRecords = currentRecords.find((item)=>item.boolIsFullMatch === true);
               if(IsfullRecords != undefined && IsfullRecords.boolIsFullMatch){
                    this.applicantsFull = currentRecords;
               }
               else{
                    this.applicantsPartial = currentRecords;
               }*/
          }
          console.log('%%%applicants '+JSON.stringify(currentRecords));
     }
}