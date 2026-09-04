import { LightningElement,api,wire} from 'lwc';
// import apex method from salesforce module 
import retrieveRecords from '@salesforce/apex/LOSDocumentManagerController.retrieveRecords';
//import fetchDefaultRecord from '@salesforce/apex/CustomLookupLwcController.fetchDefaultRecord';
import {CurrentPageReference} from 'lightning/navigation';

const DELAY = 300; // dealy apex callout timing in miliseconds  

export default class DisplayOptionalDocs extends LightningElement {
    // public properties with initial default values 
    @api label = 'custom lookup label';
    @api placeholder = 'search...'; 
    @api iconName = 'standard:account';
    @api ObjectApiName ='Loan_Application__c';
    @api defaultRecordId = '';
    @api recordIdfromParent;
    @api selectedApplicantRecord;
    @api MandatoryDocList;

    // private properties 
    lstResult = []; // to store list of returned records   
    hasRecords = true; 
    searchKey=''; // to store input field value    
    isSearchLoading = false; // to control loading spinner  
    delayTimeout;
    selectedRecord = {}; // to store selected lookup record in object formate 

   // initial function to populate default selected lookup record if defaultRecordId provided  
    connectedCallback(){
         console.log('recordId::'+this.recordIdfromParent);
         //load the application optional records on startup
         this.getLoanOptionalDocs();
    }
    

    // wire function property to fetch search record based on user input
    @wire(retrieveRecords, { searchKey: '$searchKey' , sObjectApiName : '$ObjectApiName' ,recorIdStr : '$recordIdfromParent', applicantRecord:'$selectedApplicantRecord'})
     searchResult(value) {
        const { data, error } = value; // destructure the provisioned value
        this.isSearchLoading = false;
        if (data) {
             this.hasRecords = data.length == 0 ? false : true; 
             this.lstResult = JSON.parse(JSON.stringify(data)); 
             console.log('MandatoryDocList:::'+this.MandatoryDocList)
         }
        else if (error) {
            console.log('(error---> ' + JSON.stringify(error));
         }
    };
       
  // update searchKey property on input field change  
    handleKeyChange(event) {
        // Debouncing this method: Do not update the reactive property as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        this.isSearchLoading = true;
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.searchKey = searchKey;
       /* this.delayTimeout = setTimeout(() => {
        this.searchKey = searchKey;
        }, DELAY);*/
    }

//get the application optional docs
    getLoanOptionalDocs(){

        retrieveRecords({searchKey: this.searchKey, sObjectApiName:this.ObjectApiName,recorIdStr: this.recordIdfromParent,applicantRecord:this.applicantRecord}).then((result)=>{
            this.lstResult = result;   
         }).catch(error => {
             this.error = error;
           
         });
       

    }

    //Get the optional records list according to passed object name
   @api doSearch(searchkey,objectName,applicant) {
    this.lstResult=[];
   // this.searchKey = searchkey;
    this.ObjectApiName=objectName;
    this.applicantRecord=applicant;
    this.isSearchLoading = true;
    

    this.searchKey = searchkey;
    this.getLoanOptionalDocs();
    }

   

    // method to toggle lookup result section on UI 
    toggleResult(event){
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer.classList;
        const whichEvent = event.target.getAttribute('data-source');
        switch(whichEvent) {
            case 'searchInputField':
                clsList.add('slds-is-open');
               break;
            case 'lookupContainer':
                clsList.remove('slds-is-open');    
            break;                    
           }
    }

   // method to clear selected lookup record  
   handleRemove(){
    this.searchKey = '';    
    this.selectedRecord = {};
    //this.lookupUpdatehandler(undefined); // update value on parent component as well from helper function 
    // remove selected pill and display input field again 
    const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
     searchBoxWrapper.classList.remove('slds-hide');
     searchBoxWrapper.classList.add('slds-show');
     const pillDiv = this.template.querySelector('.pillDiv');
     pillDiv.classList.remove('slds-show');
     pillDiv.classList.add('slds-hide');

     const oEvent = new CustomEvent('clearlist');
   
      this.dispatchEvent(oEvent);

      //oEvent.preventDefault();
    //return false;
  }



    // method to update selected record from search result 
handelSelectedRecord(event){   
    var objId = event.target.getAttribute('data-recid'); // get selected record Id 
    this.selectedRecord = this.lstResult.find(data => data.Id === objId); // find selected record from list 
    this.handelSelectRecordHelper();
    const oEvent = new CustomEvent('lookupupdate',
    {
        'detail': {selectedRecord: this.selectedRecord}
    }
        );
     this.dispatchEvent(oEvent);
}

//method to add pilldiv on the search box
handelSelectRecordHelper(){

    this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
     const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
     searchBoxWrapper.classList.remove('slds-show');
     searchBoxWrapper.classList.add('slds-hide');
     const pillDiv = this.template.querySelector('.pillDiv');
     pillDiv.classList.remove('slds-hide');
     pillDiv.classList.add('slds-show');    

}

  


}