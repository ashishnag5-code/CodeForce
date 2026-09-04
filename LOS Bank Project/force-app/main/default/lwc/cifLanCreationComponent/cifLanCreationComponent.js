import { api, LightningElement, track, wire } from 'lwc';
import getLoanApplicationDetails from '@salesforce/apex/LANCreationController.getLoanApplicationDetails'
import getApplicants from '@salesforce/apex/CIFCreationController.getApplicants'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import getLoanId from '@salesforce/apex/CIFCreationController.getLoanId'
//import DPD_ByPass from '@salesforce/label/c.DPD_ByPass';


import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
    createMessageContext
  } from 'lightning/messageService';
  import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c';

export default class CifLanCreationComponent extends LightningElement {
    //DPD_ByPass = DPD_ByPass;
    @api recordId
    @track loanAppId;
    loanApp={};
    loanAppRecordType='';
    boolFromCINLANCmp=true
    stateMappings
    @track showLanCreation=false
    @track showTranche=false
    @track displayCardView = true
    @track showExposureButton = false
    @track loadComponents=false
    subscription = null;

    @wire(MessageContext)
    messageContext;

    connectedCallback(){
        this.subscribeToMessageChannel()
        this.setInitialData()
        /*getLoanApplicationDetails({loanAppId: this.recordId}).then((data=>{
            this.loanApp = data
        })).catch((error=>{
            this.showToast('Error',error.message.body,'error')
        }))*/
    }

    @wire(MessageContext)
    messageContext;

    setInitialData(){
        getLoanId({recordId: this.recordId}).then((data=>{
            this.loanAppId = data
            this.loadComponents=true
            //this.recordId = data
        }))
    }

    handleCIFCreationEvent(){
        getApplicants({loanId: this.loanAppId}).then((data=>{
            if(data.Credit_Approved_Exposure__c <= data.Total_Exposure__c){
                this.showToast('Warning','Exposure Increased. Returning to DDE','warning', 'sticky')
                const fields = { Id: this.loanAppId, Stage__c: 'DDE' };
                const recordInput = { fields };
                updateRecord(recordInput).then(() => {
                    this.isLoading = false
                    this.showToast('Success', 'Stage Changed to DDE', 'success')
                });
            }else{
                getLoanApplicationDetails({loanAppId: this.loanAppId}).then((data=>{
                    //if(!data.loan.Dpd_Found__c || this.DPD_ByPass == "true"){
                    if(!data.loan.Dpd_Found__c){
                        this.loanApp = data.loan;
                        this.stateMappings = data.stateMappings;
                        this.loanAppRecordType = data.wheels
                        this.showLanCreation = true
                    }   
                })).catch((error=>{
                    this.showToast('Error',error.message.body,'error', 'sticky')
                }))
                
            }
        })).catch((error=>{
            this.showToast('Error',error.message.body,'error', 'sticky')
        }))
        
    }

    showLoanDetailsCmp(){
        this.displayCardView=false
        if(this.loanApp.Disbursement_Category__c==='Partial'){
            this.showTranche = true;
        }
    }

    returnToPreviousPage(){
        this.displayCardView=true
    }

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                pageRefreshOnMaterialFieldChange,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
      }
    
      handleMessage(message){
        if(message.refreshPage=='Yes'){
            this.loanAppId = undefined;
            this.loadComponents = false;
          this.setInitialData();
        }
      }
    
      unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
      }
    
      disconnectedCallback() {
          this.unsubscribeToMessageChannel();
      }
}