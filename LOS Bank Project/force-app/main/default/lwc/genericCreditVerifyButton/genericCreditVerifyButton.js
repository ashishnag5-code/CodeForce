import { LightningElement, api } from 'lwc';
import setValidationOnDocument from '@salesforce/apex/CreditVerification.setValidationOnDocument'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getLoanBREDecision from '@salesforce/apex/CreditVerification.getLoanBREDecision'; //SFAU-4930
import getLoanDetails from '@salesforce/apex/CreditVerification.getLoanDetails'; 

import {
    APPLICATION_SCOPE,
    createMessageContext,
    MessageContext,
    publish,
    releaseMessageContext,
    subscribe,
    unsubscribe,
} from 'lightning/messageService';
import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c';

export default class GenericCreditVerifyButton extends LightningElement {

    @api documentType
    messageContext = createMessageContext();
    @api recordId
    showButton = true;
    
    // START  || SFAU-4930
    async connectedCallback(){ 
        const response = await getLoanDetails({loanId: this.recordId})
        if(response && response.loan && response.loan.Stage__c=='Credit' && 
            response.user && response.user.Profile.Name=='Credit Manager' && response.loan.BRE_Decision__c!='STP'){
                this.showButton = true;
        }
        //this.getBreDecision();
        
    }

    getBreDecision(){
        getLoanBREDecision({loanApplicationId:this.recordId}).then((data=>{
            if(data){
                if(data!='STP'){
                    this.showButton = true;
                }else{
                    this.showButton = false;
                }
            }
           
        })).catch((error=>{
            
        }))
    }
    // END   || SFAU-4930
    handleVerify(){
        setValidationOnDocument({documentType:this.documentType,loanApplicationId:this.recordId}).then((data=>{
            this.showToastMessage('',this.documentType+' Verified','success')
            const payload = { recordIdOfSobject: this.recordId, refreshPage: 'Yes'};
            publish(this.messageContext, pageRefreshOnMaterialFieldChange, payload);
        })).catch((error=>{
            this.showToastMessage('',this.documentType+' Verification Failed','error', 'sticky')
        }))
    }

    showToastMessage(titleValue, messageValue, variantValue, mode){
        const event = new ShowToastEvent({
            title: titleValue,
            message: messageValue,
            variant: variantValue,
            mode: mode
        });
        this.dispatchEvent(event);
    }
}