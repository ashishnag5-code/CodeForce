import { LightningElement,api, wire } from 'lwc';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
    createMessageContext
  } from 'lightning/messageService';
  import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c';

export default class DealSummaryAndPSDButtonsParent extends LightningElement {

     subscription = null;
    displayDealSummary=true
    @api recordId
    connectedCallBack(){
        this.subscribeToMessageChannel()
    }

    hideDealSummary(){
        this.displayDealSummary=false
    }

    showDealSummary(){
        this.displayDealSummary=true
    }

    //@wire(MessageContext)
    messageContext = createMessageContext();

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
          this.template.querySelector('c-ausf_-p-s-d-buttons-component').setInitialData()
        }
      }
    
      unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
      }
    
      disconnectedCallback() {
          this.unsubscribeToMessageChannel();
      }

      renderedCallback(){
        console.log('Inside rerender')
      }
}