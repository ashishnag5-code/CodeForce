import { LightningElement,api,track,wire } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { NavigationMixin } from "lightning/navigation";
import searchLeadRecord from '@salesforce/apex/LeadAssignmentController.searchLeadRecord';
import changeLeadOwner from '@salesforce/apex/LeadAssignmentController.changeLeadOwner';
import getLeadNumber from '@salesforce/apex/LeadAssignmentController.getLeadNumber';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import LOAN_NUMBER_FIELD from '@salesforce/schema/Loan_Application__c.Loan_Number__c';
import getLeadDetails from '@salesforce/apex/LeadAssignmentController.getLeadDetails';
import { loadStyle } from 'lightning/platformResourceLoader';
import AUBranding from '@salesforce/resourceUrl/AUBranding';
import loggedInUserId from '@salesforce/user/Id';
import { reduceErrors, TRACTOR_PRODUCT_CODES, CV_PRODUCT_CODES, CONSTRUCTION_EQUIPMENT_PRODUCT_CODES } from 'c/lwcutilities';
import panIndiaTcuQueueName from '@salesforce/label/c.PANIndiaTCUQueueName';
import assignLeadsToTcu from '@salesforce/apex/LeadAssignmentController.assignLeadsToTcu';

const fields = [LOAN_NUMBER_FIELD];
export default class LeadAssignmentComponent extends NavigationMixin(LightningElement) {
    @api recordId;

    @api objectApiName;
    @track disableNextButton = true;
    @track disableLeadInput = false;
    @track leadNumber;
    @track branchNameNumber;
    isloading = false;
    showSearchResult =false;
    disableOwnerButton =true;
    @track wrapperResult;
    leadRecordIdsSelected;
    selectedUserId;
    @track selectedRecord = {};
    @api ids;
    @api isListView =false;
    @track listViewSelectedIds;
    @track leadRecordListView;
    currentLoggedInUserId = loggedInUserId
    assignType = false; // R2-9 - by default keep assigne as Branch
    tcuQueueName = panIndiaTcuQueueName;
    tcuQueueId;
    leadDetails = {};

    get isSubmitToTCUAllowed(){
        return ![ ...TRACTOR_PRODUCT_CODES, ...CV_PRODUCT_CODES, ...CONSTRUCTION_EQUIPMENT_PRODUCT_CODES ].includes( this.leadDetails?.Product__c );
    }

    @api renderAssignMeButton = false;
    @track disableAssignMeButton = true;
    connectedCallback(){
        if (this.isListView && this.ids) {
            this.ids = this.ids.split(',').filter(function (e) {
                return e != null && e != '';
            });
        }else if(this.isListView){
            window.history.back();
        }
        if(this.isListView){
            this.isloading= true;
            getLeadDetails({
                leadRecordIds: this.ids,
            }).then((result) => {
            if (result != null) {
                let parseResult=JSON.parse(result);
                console.log('parseResult'+JSON.stringify(parseResult));
                if(parseResult.isSuccess){
                    this.leadRecordListView = parseResult.leadRecordList;
                }else{
                    this.showToastEvent('Error', parseResult.message, 'error');
                }
                this.isloading= false;
            }
            })
            .catch((error) => {
                this.error = error;
                this.isloading= false;
            });
        }
        if(this.objectApiName =='Loan_Application__c'){
            this.disableLeadInput = true;   
            this.isloading= true;
            getLeadNumber({
                recordId: this.recordId
            }).then((result) => {
            if (result != null) {
                const { lead : [ _lead ], tcuQueueId } = result;
                this.leadDetails = _lead;
                this.leadNumber = _lead.Application_Id__c;
                this.tcuQueueId = tcuQueueId;
                this.isloading= false;
        
                if( !this.tcuQueueId ){
                    this.showToastEvent('Error', 'TCU Queue is not present. Please contact System administrator', 'error');
                }
            }
            })
            .catch((error) => {
                this.error = error;
                this.isloading= false;
            }); 
        }
    }
    renderedCallback(){
        Promise.all([
            loadStyle( this, AUBranding )
            ]).then(() => {
                console.log( 'Branding Loaded Success!!' );
            })
            .catch(error => {
                console.log( error.body.message );
        });
        if(this.selectedUserId){
            this.setBoxesValue();
        }
        this.prePopulateLookupFld();
    }
    handleInputChange(event) {
        if (event.target.name == 'leadNumber') {
            this.leadNumber = event.target.value;
        }
        if((this.leadNumber || this.isListViewMethod()) && this.branchNameNumber && this.isCheckValidity()){
            this.disableNextButton= false;
            this.disableAssignMeButton = false;
        }else{
            this.disableNextButton= true;
            this.disableAssignMeButton = true;
        }
    }
    nextClick(event){
        let leadSelected = [];
        if(this.leadNumber){
            leadSelected.push(this.leadNumber);
        }
        if(this.isListViewMethod()){
            this.ids.forEach(idRecord => {
                leadSelected.push(idRecord);
            });
        }
        this.isloading= true;
        this.searchAndAssignLeadRecords(leadSelected, true);
        /*
        searchLeadRecord({
            leadNumbers: leadSelected,
            branchRecordId : this.branchNameNumber
        }).then((result) => {
        if (result != null) {
            let parseResult=JSON.parse(result);
            console.log('parseResult'+JSON.stringify(parseResult));
            if(parseResult.isSuccess){
                this.wrapperResult = parseResult.loadWrapper;
                this.leadRecordIdsSelected = parseResult.leadRecordIds;
                this.showSearchResult =true;
            }else{
                this.showToastEvent('Error', parseResult.message, 'error');
            }
            this.isloading= false;
        }
        })
        .catch((error) => {
            this.error = error;
            this.isloading= false;
        });*/
    }

    searchAndAssignLeadRecords(selectedRecords, renderSearchResultPage) {
        searchLeadRecord({
            leadNumbers: selectedRecords,
            branchRecordId : this.branchNameNumber
        }).then((result) => {
        if (result != null) {
            let parseResult=JSON.parse(result);
            console.log('parseResult'+JSON.stringify(parseResult));
            if(parseResult.isSuccess){
                this.wrapperResult = parseResult.loadWrapper;
                this.leadRecordIdsSelected = parseResult.leadRecordIds;
                this.showSearchResult = renderSearchResultPage;
                if(!renderSearchResultPage) {
                    this.changeOwner();// For Assign me functionality
                }
            }else{
                this.showToastEvent('Error', parseResult.message, 'error');
            }
            this.isloading= false;
        }
        })
        .catch((error) => {
            this.error = error;
            this.isloading= false;
        });
        
    }

    isCheckValidity() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.checkValidity');
        for (let inputField of inputFields) {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            } else {
                inputField.setCustomValidity("");
                inputField.reportValidity();
            }
        };
        return isValid;
    }
    showToastEvent(titleValue, messageValue, variantValue){
        const event = new ShowToastEvent({
            title: titleValue, 
            message: messageValue,
            variant: variantValue
        });
        this.dispatchEvent(event);
    }
    setBoxes(event){
        console.log('Current Value'+event.target.checked);
        if(event.target.checked){
            let boxes = this.template.querySelectorAll('lightning-input');
            let currentBox = event.target.name;
            console.log(currentBox);
            console.log(Array.from(boxes));
            for (let i = 0; i < boxes.length; i++) {
                let box = boxes[i];
                console.log(box.name);
                console.log(box.checked);
                if (box.name !== currentBox && box.checked){
                    box.checked = false;
                    console.log(box.checked);
                }
            }
            this.selectedUserId = event.target.name;
            this.disableOwnerButton = false;
        }else{
            this.selectedUserId = '';
            this.disableOwnerButton = true;
        }

    }
    setBoxesValue(){
        let boxes = this.template.querySelectorAll('lightning-input');
        for (let i = 0; i < boxes.length; i++) {
            let box = boxes[i];
            if (box.name == this.selectedUserId && !box.checked){
                box.checked = true;
                this.disableOwnerButton = false;
            }
        }

    }
    previousClick(){
        this.showSearchResult =false;
    }
    changeOwner(){
        this.isloading= true;
        changeLeadOwner({
            leadRecordIds: this.leadRecordIdsSelected,
            newOwnerId : this.selectedUserId,
            branchRecId : this.branchNameNumber


        }).then((result) => {
        if (result != null) {
            let parseResult=JSON.parse(result);
            console.log('parseResult'+JSON.stringify(parseResult));
            if(parseResult.isSuccess && this.isListViewMethod()){
                window.history.back();
                eval("$A.get('e.force:refreshView').fire();");
            }else if(parseResult.isSuccess){
                this.showToastEvent('Success', 'Lead assignment Success!!', 'success');
                eval("$A.get('e.force:refreshView').fire();");
                this.cancelRecord();
            }else{
                this.showToastEvent('Error', parseResult.message, 'error');
                this.cancelRecord();
            }
            this.isloading= false;
        }
        })
        .catch((error) => {
            this.error = error;
            this.isloading= false;
            this.cancelRecord();
        });
    }

    cancelRecord (){
        console.log('Cancel .... ');
        try{
            const cancelevent = new CustomEvent('customclose', {
            });
            this.dispatchEvent(cancelevent);
        }
        catch(error){

        }
        
    }
    handleChange(event){
        this.selectedRecord = {Id:event.detail.value, Name: event.detail.name};
        this.branchNameNumber = event.detail.value;
        if((this.leadNumber || this.isListViewMethod()) && this.branchNameNumber && this.isCheckValidity()){
            this.disableNextButton= false;
            this.disableAssignMeButton = false;
        }else{
            this.disableNextButton= true;
            this.disableAssignMeButton = true;
        }
    }
    prePopulateLookupFld() {
        if(this.selectedRecord && this.selectedRecord.Id != undefined){
            const objChild = this.template.querySelectorAll('c-generic-custom-lookup');
            for(let val of objChild) {
                val.reflectSelectedRecordValues(this.selectedRecord);
            }
        }
    }
    isListViewMethod(){
        if(this.isListView && this.ids)
            return true;
        else    
            return false;
    }
    get isListViewReturn(){
        if(this.isListView && this.ids)
            return true;
        else    
            return false;
    }

    async handleAssignMe(evt) {
        let leadSelected = [];
        if(this.leadNumber){
            leadSelected.push(this.leadNumber);
        }
        if(this.isListViewMethod()){
            this.ids.forEach(idRecord => {
                leadSelected.push(idRecord);
            });
        }
        this.isloading= true;
        // R2-9 | Leads can also be submitted to TCU Queue
        if( !this.assignType ){
            this.selectedUserId = this.currentLoggedInUserId;
            this.searchAndAssignLeadRecords(leadSelected, false);
        } else {
            // Assign to TCU Queue
            console.log(this.ids);
            const leads = (this.ids || [ this.recordId ]) .map( id => ({ Id: id, OwnerId: this.tcuQueueId }));
            console.log({leads});
            if( !this.tcuQueueId ){
                this.showToastEvent('Error', 'TCU Queue is not configured. Please contact System Administrator', 'error');
                this.isloading = false;
                return;
            }

            const response = await assignLeadsToTcu( { leads } )
                .catch(err => {
                    const errorMessage = reduceErrors(err);
                    this.showToastEvent('Error', errorMessage?.join?.(','), 'error');
                    this.isloading= false;
                });
        
            const { isSuccess, errors } = response ?? {};
            this.isloading= false;
            if( isSuccess ){
                window.history.back();
                eval("$A.get('e.force:refreshView').fire();");
                this.showToastEvent('Success', `Lead(s) has/have been assigned to ${this.tcuQueueName}`);
            } else {
                this.showToastEvent('Error', errors.map( err => err.error ).join(',') , 'error');
            }
        }


    }

    // R2-9 | Leads can also be submitted to TCU Queue
    handleAssignTypeChange( event ){
        const isAssignedToTCU = event.target.checked;
        console.log({isAssignedToTCU});
        this.assignType = isAssignedToTCU;
        if( this.assignType ){
            this.disableAssignMeButton = false;
            this.disableNextButton = true;
            this.selectedRecord = {};
            this.template.querySelector('c-custom-generic-lookup')?.callHandleRemove();
        } else{
            this.disableAssignMeButton = true;
        }

    }
    get assignButtonLabel(){
        return this.assignType ? 'Assign to TCU' : 'Assign Me';
    }

}