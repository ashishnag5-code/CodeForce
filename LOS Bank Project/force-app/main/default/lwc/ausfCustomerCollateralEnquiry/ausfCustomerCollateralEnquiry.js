import { LightningElement, api, track } from 'lwc';
import getCollateralEnquiryList from '@salesforce/apex/CustomCollateralEnquiryController.getCollateralEnquiryList';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class leadDedupeCRM extends LightningElement {
     leadInputParams;
     @api isChecked = false;
     @api recordId;
     @api
     applicantInput = {};
     @api 
     boolIsFromWizard;
     isLoading = false;
     isAutomobileView = false;
     isPropertyView = false;
     viewMoreFull = false
     isDetailView = false;
     viewMorePartial = false
     //viewLess
     applicantRecord;
     selectedCollateralList =[];
     deletedCollateralList =[];
     collatralDetailAutomobile;
     collatralDetailProperty;
     linkageDetailAutomobile;
     linkageDetailProperty;
     automobileDetail;
     propertyDetail;
     valuationDetailProperty;
     valuationDetailAutombile
     
     @track
     applicantsFull;
     @track
     applicantsPartial;
     @api
     boolNorecordsFull = false;
     boolNorecordsPartial = false;
     errorOnChild = '';
     totalApplicants;
     @api totalApplicantsFull = [];
     /*totalApplicantsFullTemp=[]

     @api
     get totalApplicantsFull(){
          return this.totalApplicantsFullTemp
     }
     set totalApplicantsFull(value){
          if(value){
               this.totalApplicantsFullTemp = JSON.parse(JSON.stringify(value))
               this.setSelectedCollateralList()
          }
     }*/


     @api spinnerImage;

     connectedCallback(){
          console.log('ausf customer '+this.isChecked);
          console.log('ausf customer '+JSON.stringify(this.totalApplicantsFull));
          /*this.totalApplicantsFull.forEach(input => {
               if(input.isSelected){
                    this.selectedCollateralList.push(currentObj);
                    if (this.template.querySelector('[data-divid="' + input.strCollateralId + '"]') != null) {
                         this.template.querySelector('[data-divid="' + input.strCollateralId + '"]').classList.remove('slds-hide');
                    }
               }
          });*/
     }

     renderedCallback(){
     //setSelectedCollateralList(){
          //this.selectedCollateralList =[];
          console.log('ausf customer '+this.isChecked);
          console.log('ausf customer renderedCallback'+JSON.stringify(this.totalApplicantsFull));
          this.totalApplicantsFull.forEach(input => {
               if(input.isSelected){
                    this.selectedCollateralList.push(input);
                    if (this.template.querySelector('[data-divid="' + input.strCollateralId + '"]') != null) {
                         this.template.querySelector('[data-divid="' + input.strCollateralId + '"]').classList.remove('slds-hide');
                    }
               }
          });
     }
    /* @api
     getCollateral(applicantId) {
          this.isLoading = true;
          console.log('record id is %% '+JSON.stringify(applicantId));
          getCollateralEnquiryList({ strApplicantId : applicantId})
		.then(result => {
               JSON.stringify('getCollateralEnquiryList '+JSON.stringify(result.collateralList))
               this.totalApplicants = result.collateralList;
               this.totalApplicantsFull = result.collateralList;


               //this.totalApplicantsFull = this.totalApplicants.filter((item)=>item.boolIsFullMatch === true);
               console.log('totalApplicantsFull'+JSON.stringify(this.totalApplicantsFull));
               if(this.totalApplicantsFull.length === 0){
                    this.boolNorecordsFull = true;
               }else{
                    this.boolNorecordsFull = false;
               }
               let blockNextFull = this.totalApplicantsFull.find((item)=>item.boolBlockNext === true);
               if(blockNextFull !== undefined && blockNextFull.boolBlockNext){
                    this.dispatchEvent(new CustomEvent('blocknext'));
               }
               this.isLoading = false;
		})
		.catch(error => {
               if(this.totalApplicantsFull.length === 0){
                    this.boolNorecordsFull = true;
               }else{
                    this.boolNorecordsFull = false;
               }
               this.isLoading = false;
               console.log('result is '+JSON.stringify(error));
		})
     }*/
     handleSelected(event){

          let isChecked = event.target.checked;
          console.log('isChecked '+isChecked)
          let selectedList = JSON.parse(JSON.stringify(this.selectedCollateralList));
          let deletedList = this.deletedCollateralList;
          let recordId = event.currentTarget.dataset.id;
          if (isChecked){
               let selectedCollateral = this.totalApplicantsFull.find((item)=>item.strCollateralId === recordId);
               let currentObj = Object.assign({}, selectedCollateral);
               currentObj.isSelected = true;
               this.selectedCollateralList.push(currentObj);
               console.log('selected list '+JSON.stringify(this.selectedCollateralList))
               if (this.template.querySelector('[data-divid="' + recordId + '"]') != null) {
                    this.template.querySelector('[data-divid="' + recordId + '"]').classList.remove('slds-hide');
               }
               if(deletedList.length>0){
                    let todoTaskIndex;
                    for(let i=0; i<deletedList.length; i++) {
                         if(recordId === deletedList[i]) {
                              todoTaskIndex = i;
                         }
                    }
                    deletedList.splice(todoTaskIndex, 1);
                    this.deletedCollateralList = deletedList;
               }
               /*let totalApplicants = Object.assign([], this.totalApplicantsFull);
               for (let i = 0; i < totalApplicants.length; i++) {
                    if(totalApplicants[i].strCollateralId == recordId){
                         //console.log('%% '+JSON.stringify(totalApplicants[i]));
                         totalApplicants[i].isShowApportioned = true;
                         console.log('%% '+JSON.stringify(totalApplicants[i]));
                    }
               }
               this.totalApplicantsFull = totalApplicants;*/
              
          }
          if (!isChecked && selectedList.length>0){
               //R2-2636
              /* let selectedCollateral = selectedList;
               let currentObj = Object.assign({}, selectedCollateral);
               currentObj.isSelected = false;
               this.selectedCollateralList.push(currentObj);*/
               //END
               let todoTaskIndex;
               for(let i=0; i<selectedList.length; i++) {
                    if(recordId === selectedList[i].strCollateralId) {
                         todoTaskIndex = i;
                         selectedList[i].isSelected = false;
                         this.deletedCollateralList.push(selectedList[i].strCollateralId);
                    }
               }
               selectedList.splice(todoTaskIndex, 1);
               
               this.selectedCollateralList = selectedList;
               console.log('after deselecting list '+JSON.stringify(this.selectedCollateralList))
               if (this.template.querySelector('[data-divid="' + recordId + '"]') != null) {
                    this.template.querySelector('[data-divid="' + recordId + '"]').classList.add('slds-hide');
               }
              
          }
          
           const selectedEvent = new CustomEvent("selectedcoll", {
               detail: this.selectedCollateralList
                });
                this.dispatchEvent(selectedEvent);
          const deletedEvent = new CustomEvent("deletedcoll", {
               detail: this.deletedCollateralList
          });
          this.dispatchEvent(deletedEvent);
          
     }

     viewMoreHandler(event){    
          this.isLoading = true;
          let recordId = event.currentTarget.dataset.id;
          console.log('%% selected customer id'+recordId);
          //if(card==='full'){
               this.applicantRecord = this.totalApplicantsFull.find((item)=>item.strCollateralId === recordId);
               this.isPropertyView =this.applicantRecord.boolIsProprtyView;
               this.isAutomobileView =this.applicantRecord.boolIsAutomobileView;
               this.isDetailView = 
               this.collatralDetailAutomobile = [{label:'Collateral ID',value:this.applicantRecord.strCollateralId},{label:'Collateral Type',value:this.applicantRecord.strCollateralType},{label:'Product Name Code',value:this.applicantRecord.strProductNameCode},{label:'Collateral Value',value:this.applicantRecord.strTotalCollateralValue},{label:'Collateral Unused Value',value:this.applicantRecord.strCollateralUnusedValue},{label:'Total utilized Value',value:this.applicantRecord.strAmountCollValueCollCcy}];
               this.collatralDetailProperty = [{label:'Collateral ID',value:this.applicantRecord.strCollateralId},{label:'Collateral Type',value:this.applicantRecord.strCollateralType},{label:'Product Name Code',value:this.applicantRecord.strProductNameCode},{label:'Collateral Value',value:this.applicantRecord.strTotalCollateralValue},{label:'Collateral Unused Value',value:this.applicantRecord.strCollateralUnusedValue},{label:'Total utilized Value',value:this.applicantRecord.strAmountCollValueCollCcy},{label:'Property Owner Name',value:this.applicantRecord.strPropertyOwnerName},{label:'Property Title & Type',value:this.applicantRecord.strPropertyType},{label:'Occupancy Type',value:this.applicantRecord.strPropertyType}];
               
               this.linkageDetailAutomobile = [{label:'Linkage Type',value:this.applicantRecord.strCollateralType},{label:'Customer ID',value:this.applicantRecord.strCollateralId},{label:'Customer Name',value:this.applicantRecord.strPropertyOwnerName},{label:'Relationship',value:this.applicantRecord.strAccountCustomerRelation},{label:'Linked Account Number',value:this.applicantRecord.strAccountNumber},{label:'Apportioned Amount',value:this.applicantRecord.strAmountCollValueCollCcy},{label:'POS',value:this.applicantRecord.strCollateralUnusedValue}];
               this.linkageDetailProperty = [{label:'Linkage Type',value:this.applicantRecord.strCollateralType},{label:'Customer ID',value:this.applicantRecord.strCollateralId},{label:'Customer Name',value:this.applicantRecord.strPropertyOwnerName},{label:'Relationship',value:this.applicantRecord.strAccountCustomerRelation},{label:'Linked Account Number',value:this.applicantRecord.strAccountNumber},{label:'Apportioned Amount',value:this.applicantRecord.strAmountCollValueCollCcy},{label:'POS',value:this.applicantRecord.strCollateralUnusedValue}];

               this.automobileDetail = [{label:'Make',value:this.applicantRecord.strMake},{label:'Model',value:this.applicantRecord.strModel},{label:'Mfg Year',value:this.applicantRecord.strManufactureYear},{label:'Chassis Number',value:this.applicantRecord.ChassisNumber},{label:'Engine Number',value:this.applicantRecord.strEngineNumber},{label:'Registration Number',value:this.applicantRecord.strRegistrationNumber}];
               this.propertyDetail = [{label:'House No/Plot No',value:this.applicantRecord.strKhasaraPlotNo},{label:'Address',value:this.applicantRecord.strAddress},{label:'Model',value:this.applicantRecord.strModel},{label:'Taluka',value:this.applicantRecord.strTehsilTaluka},{label:'Village',value:this.applicantRecord.strVillage},{label:'Property Description',value:this.applicantRecord.strPropertyDesc1}];
               
               this.valuationDetailAutombile = [{label:'Valuation date',value:this.applicantRecord.strLastValuationDate},{label:'Valuation Amount',value:this.applicantRecord.strLastValue},{label:'Total Pos',value:this.applicantRecord.strTotalPos}];
               this.valuationDetailProperty = [{label:'Valuation date',value:this.applicantRecord.strLastValuationDate},{label:'Area Unit',value:this.applicantRecord.strAreaUnit},{label:'Land Area',value:this.applicantRecord.strTotalArea},{label:'Construction Value',value:this.applicantRecord.strCostPrice}];
               
               if(this.isAutomobileView || this.isPropertyView){
                    this.viewMoreFull = true
               }else{
                    this.showToast();
               }
          //}
          console.log('%% applicantRecord'+JSON.stringify(this.applicantRecord));
          this.isLoading = false;
          //this.viewLess = false;
     }

     handleValueChange(event){

     }

     showToast() {
          const event = new ShowToastEvent({
              title: '',
              message: 'Details section is not available for selected collateral',
          });
          this.dispatchEvent(event);
      }

     viewLessHandler(){
          this.viewMoreFull = false
          this.viewMorePartial = false
          this.viewLess = true
     }

     updateApplicantsHandler(event){
          console.log('%%%updateApplicantsHandler '+event.detail.records);
          let currentRecords = [...event.detail.records];
          if(currentRecords !== undefined){
               let IsfullRecords = currentRecords.find((item)=>item.boolIsFullMatch === true);
               if(IsfullRecords !== undefined && IsfullRecords.boolIsFullMatch){
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