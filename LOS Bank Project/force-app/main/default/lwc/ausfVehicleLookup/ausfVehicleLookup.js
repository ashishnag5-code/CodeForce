import { LightningElement, api, track, wire } from 'lwc';
// import lookUp from '@salesforce/apex/AUSFVehicleLookupController.search';
//import fetchIconName from '@salesforce/apex/GenericCustomLookupController.getIconName';
// import fetchLookupData from '@salesforce/apex/AUSFVehicleLookupController.fetchLookupData';
// import fetchDefaultRecord from '@salesforce/apex/AUSFVehicleLookupController.fetchDefaultRecord';
const DELAY = 120;
export default class GenericCustomLookup extends LightningElement {
    @api recordId;
    @api defaultRecordId = '';
    @api sObjectApiName;
    @api label;
    @api placeholder = 'search...';
    @api objectName;
    @api required;
    @api stepid;
    @api searchFields;
    @api fieldapi;
    @api recordTypeName = '';
    @api dependentFieldApi = '';
    @api dependentPicklistValue = '';

   @api callHandleRemove(){
    // this.handleRemove();
   }



    // private properties 
    lstResult = []; // to store list of returned records   
    hasRecords = true;
    searchKey; // to store input field value    
    isSearchLoading = false; // to control loading spinner  
    delayTimeout;
    selectedRecord = {}; // to store selected lookup record in object formate 
    iconName;
    // initial function to populate default selected lookup record if defaultRecordId provided
    connectedCallback() {
       /* console.log('this.defaultRecordId ', this.defaultRecordId);
        if (this.recordId != '') {
            fetchDefaultRecord({ recordId: this.recordId, 'sObjectApiName': this.sObjectApiName })
                .then((result) => {
                    if (result != null) {
                        if (result && result.sObjectList.length > 0) {
                            this.selectedRecord = result.sObjectList[0];
                            this.handelSelectRecordHelper();
                        }
                        this.iconName = result.iconName;
                    }
                })
                .catch((error) => {
                    this.error = error;
                    this.selectedRecord = {};
                });
        }
        */
    }

    fetchData() {
/*        lookUp({ searchTerm: this.searchKey, fieldapi:this.fieldapi, myObject: this.sObjectApiName, loanAppId:this.recordId })
            .then(result => {
                this.hasRecords = result.sObjectList.length == 0 ? false : true;
                this.lstResult = JSON.parse(JSON.stringify(result.sObjectList));
                console.log('master data is >'+JSON.stringify(result.sObjectList))
                this.isSearchLoading = false;
                console.log('result.iconName', result.iconName);
                console.log('this.selectedRecord ', this.selectedRecord);
                this.iconName = result.iconName;
            }).catch(error => {
                this.message = error.message;
                this.showSpinner = false;
            })
            */
    }

    // update searchKey property on input field change  
    handleKeyChange(event) {
        // Debouncing this method: Do not update the reactive property as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
/*        this.isSearchLoading = true;
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;

        this.delayTimeout = setTimeout(() => {
            this.searchKey = searchKey;
            this.fetchData();
        }, DELAY);
        */
    }

    // method to toggle lookup result section on UI 
    toggleResult(event) {
/*        this.isSearchLoading = true;
        this.lstResult = null;
        this.fetchData();
        const lookupInputContainer = this.template.querySelector('.lookupInputContainer');
        const clsList = lookupInputContainer.classList;
        const whichEvent = event.target.getAttribute('data-source');
        switch (whichEvent) {
            case 'searchInputField':
                clsList.add('slds-is-open');
                break;
            case 'lookupContainer':
                clsList.remove('slds-is-open');
                break;
        } */
    }

    // method to clear selected lookup record  
    handleRemove() {
/*        this.searchKey = '';
        this.selectedRecord = {};
        this.lookupUpdatehandler('deselect'); // update value on parent component as well from helper function 

        // remove selected pill and display input field again 
        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        searchBoxWrapper.classList.remove('slds-hide');
        searchBoxWrapper.classList.add('slds-show');
        const pillDiv = this.template.querySelector('.pillDiv');
        pillDiv.classList.remove('slds-show');
        pillDiv.classList.add('slds-hide');
        */
    }

    // method to update selected record from search result 
    handelSelectedRecord(event) {
        /*
        var objId = event.target.getAttribute('data-recid'); // get selected record Id 
        this.selectedRecord = this.lstResult.find(data => data.Id === objId); // find selected record from list
        this.lookupUpdatehandler('select'); // update value on parent component as well from helper function 
        this.handelSelectRecordHelper(); // helper function to show/hide lookup result container on UI
        */

    }
    /*COMMON HELPER METHOD STARTED*/
    handelSelectRecordHelper() {
/*        this.template.querySelector('.lookupInputContainer').classList.remove('slds-is-open');
        const searchBoxWrapper = this.template.querySelector('.searchBoxWrapper');
        searchBoxWrapper.classList.remove('slds-show');
        searchBoxWrapper.classList.add('slds-hide');
        const pillDiv = this.template.querySelector('.pillDiv');
        pillDiv.classList.remove('slds-hide');
        pillDiv.classList.add('slds-show');
        */
    }
    // send selected lookup record to parent component using custom event
    lookupUpdatehandler(context) {
        /*if (context === 'deselect') {
            var lookupValue = { value: undefined, name: undefined, stepid: this.stepid, fieldapi: this.fieldapi, objApiName: this.objectName };
        } else {
            var lookupValue = { value: this.selectedRecord.Id, name: this.selectedRecord.Name, stepid: this.stepid, fieldapi: this.fieldapi, objApiName: this.objectName };
        }
        this.dispatchEvent(new CustomEvent('lookupselect', {
            detail: lookupValue
        }));
        */
    }
}