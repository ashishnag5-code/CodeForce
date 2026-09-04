import { LightningElement,api } from 'lwc';
import getApplicants from '@salesforce/apex/CibilNIController.getApplicants';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from "lightning/actions";
import cibilNIRequest from '@salesforce/apex/CibilNIController.cibilNIRequest';
import { NavigationMixin } from 'lightning/navigation';


export default class InitiateCibilNI extends NavigationMixin(LightningElement) {
    isNoRecords = false;
    listOfApplicants = [];
    selectedValue;
    isAppSelected = false;
    showLoadingSpinner = false;
    loanId;

    get recordId() {
        return this._recordId;
    } 

    @api set recordId(value) {
        this._recordId = value;
        this.loanId = value;
        //alert('value: '+value);
        getApplicants({loanId : this._recordId})
        .then(result => {
            //alert('value: '+result.length);
            if(result && result.length == 0){
                this.isNoRecords = true;
            }else{  
                for(const list of result){
                    const option = {
                        label: list.Entity_Name__c,
                        value: list.Id
                    };
                    // this.selectOptions.push(option);
                    this.listOfApplicants = [ ...this.listOfApplicants, option ];
                }                
            }                           
        })
        .catch(error => {
            let errMsg = '';                    
            /*if (error && error.body && error.body.message) {
                errMsg = error.body.message;
            }        
            var custEvent = new CustomEvent('closemodal');
            this.dispatchEvent(custEvent);            
            this.dispatchEvent(this.showToast('error', errMsg, 'Error!', 'dismissable'));*/
        });      
    }

    handleClose(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    handlePicklistChange( event ) {
        this.applId = event.detail.value;   
        this.isAppSelected = true;
    }
    initiateCibil(){
        this.showLoadingSpinner = true;
        this.isAppSelected = false;
        cibilNIRequest({appId : this.applId})
        .then(result => {
            this.showLoadingSpinner = false;
            if(result == 'success'){
                this.dispatchEvent(this.showToast('success', 'Cibil NI Executed Successfully', 'Success', 'dismissable'));
            }else if(result == 'error'){
                this.dispatchEvent(this.showToast('error', 'Please check with Administrator', 'Error!', 'dismissable'));
            }else{
                this.dispatchEvent(this.showToast('error', result, 'Pre Requisites are missing', 'dismissable'));
            }
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.loanId,
                    objectApiName: 'Loan_Application__c',
                    actionName: 'view'
                }
            });                     
        })
        .catch(error => {
            let errMsg = '';                    
        });      
    }
    showToast(variant, message, title, mode) {
        return new ShowToastEvent({
            "title": title,
            "message": message,
            "variant": variant,
            "mode": mode
        });
    }
}