/*
@Name : ausf_SendBackFieldInvestigation
@Description: Send Back Field Investigation record to FI Agent/Agency - SFAU-2999
@ Logs:
Modified By         :       Modified Date           :       Description
Mohit M.            :       14-June-2023            :       SFAU-2999
*/
import { api, LightningElement, track, wire } from 'lwc';
import Stage from "@salesforce/schema/Field_Investigation__c.Stage__c";
import Credit_Manager from "@salesforce/schema/Field_Investigation__c.Credit_Manager__c";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import sendBackFIRecord from '@salesforce/apex/CreateFieldInvestigatiionRecord.sendBackFIRecord';
import { NavigationMixin } from 'lightning/navigation';


export default class Ausf_SendBackFieldInvestigation extends NavigationMixin(LightningElement){
    @api recordId;
    @track renderSendBackButton=false;
    @track disableSendBackButton = false;
    @api fromMobile;
    @track isModalOpen = false;
    
    connectedCallback(){
        this.renderSendBackButton = true;
    }

    openSendBackModal(){
        this.isModalOpen = true;

    }

    closeModal(){
        this.isModalOpen = false;
    }

    handleSendBackComments(evt){
        this.sendBackComments = evt.detail.value;
    }

    
    handleSendback(){

        if(!this.checkSendBackComments()){
            this.disableSendBackButton = true;
            sendBackFIRecord({
                strRecordId : this.recordId,
                sendBackComments : this.sendBackComments
            })
            .then(res=>{
                console.log('res'+JSON.stringify(res));
                if(res.blnSuccess){
                    this.template.querySelector('c-common-toast').showToast('success','<strong>'+res.strMessage+'<strong/>','utility:error',10000);
                    this.updateRecordAndNavigateToHomePage();
                }
                else{
                    this.template.querySelector('c-common-toast').showToast('error','<strong>'+res.strMessage+'<strong/>','utility:success',10000);
                    this.disabledRejectButton = false;
                    
                }   
            })
            .catch(err=>{
                console.log('err'+err);
                this.template.querySelector('c-common-toast').showToast('success','<strong>'+res.strMessage+'<strong/>','utility:success',10000);
            })

        }
        
    }

    updateRecordAndNavigateToHomePage(){
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Field_Investigation_Tab'
            },
        });
    }

    checkSendBackComments(){
        let isError = false;
        let textBox = this.template.querySelector('lightning-textarea');
        if(!textBox.value || textBox.value == ''){
            textBox.setCustomValidity('Please provide comments before sending back');
            isError = true;

        }
        else{
            textBox.setCustomValidity('');
            isError = false;
        }
        textBox.reportValidity();
        return isError;
    }
}