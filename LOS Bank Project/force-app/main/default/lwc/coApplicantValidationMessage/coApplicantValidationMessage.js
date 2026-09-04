import { LightningElement, api, track } from 'lwc';
import coApplicantValidationForTractor from '@salesforce/apex/Ausfb_RelatedApplicantController.coApplicantValidationForTractor';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
    createMessageContext
  } from 'lightning/messageService';
import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c';

export default class CoApplicantValidationMessage extends LightningElement {

    @api recordId
    @track validationMessage
    @track classAttributes
    @track iconName
    @track iconVariant
    @track loadComponent=false
    subscription = null;

    connectedCallback(){
        this.coApplicantValidationForTractor()
    }

    @api
    coApplicantValidationForTractor(){
        coApplicantValidationForTractor({applicantId:this.recordId}).then(data=>{
            if(data){
                this.validationMessage = data.message
                this.loadComponent=true
                if(data.status=='success'){
                    this.iconVariant='success'
                    this.iconName = 'utility:success'
                    this.classAttributes = 'slds-text-color_success slds-text-align_center slds-text-heading_small slds-m-left_small'
                }else if(data.status=='error'){
                    this.iconName = 'utility:adduser'
                    this.iconVariant=''
                    this.classAttributes = 'slds-text-color_error slds-text-align_center slds-text-heading_small slds-m-left_small'

                }
            }else{
                this.loadComponent=false
            }
        }).catch(error=>{
            this.loadComponent=false
        })
    }

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
            this.coApplicantValidationForTractor()
        }
    }  
    
    unsubscribeToMessageChannel(){
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    
    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }
}