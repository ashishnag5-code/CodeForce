import { api, LightningElement, track, wire } from 'lwc';
import Stage from "@salesforce/schema/Field_Investigation__c.Stage__c";
import Credit_Manager from "@salesforce/schema/Field_Investigation__c.Credit_Manager__c";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import handleFIRecordReject from '@salesforce/apex/CreateFieldInvestigatiionRecord.handleFIRecordReject';
import rejectButtonLabel from '@salesforce/label/c.FI_Reject_Button_Label';

import { NavigationMixin } from 'lightning/navigation';


const fields = [Stage,Credit_Manager];


export default class Ausf_Reject_CancelFI extends NavigationMixin(LightningElement){
    @api recordId;
    @track renderRejectButton=false;
    @track fiCreditManager = '';
    @track disabledRejectButton = false;
    @track rejectButtonLabel = rejectButtonLabel
    @api applicationStage = '';
    @track restrictedApplicationStages = ['Ops Maker','Ops Author','PDD','Rejected'];


    
    connectedCallback(){
        //alert('recordId '+this.recordId);
    }

    @wire(getRecord, {
        recordId: "$recordId",
        fields
    })
    //   fieldInvestigation;
    wiredRecord({ error, data }) {

        if (data) {
            console.log('Data>>>'+JSON.stringify(data));
            if(data.fields.hasOwnProperty('Stage__c')){
                this.stageValue = data.fields.Stage__c.value;
                this.renderRejectButton = this.stageValue == 'Assigned';
            }
            if(data.fields.hasOwnProperty('Credit_Manager__c')){
                this.fiCreditManager = data.fields.Credit_Manager__c.value;
            }
            else{
                this.fiCreditManager = '';
            }
        }
        if(error){
            this.template.querySelector('c-common-toast').showToast('error','<strong>'+JSON.stringify(error.message)+'<strong/>','utility:error',10000);            
        }
    }

    handleFiReject(evt){
        if(this.restrictedApplicationStages.includes(this.applicationStage)){
            this.template.querySelector('c-common-toast').showToast('Error', '<strong>' + 'You cannot Reject the FI when Application is in '+this.applicationStage + 'stage. <strong/>', 'utility:Error', 10000);
            return;
        }
        handleFIRecordReject({
            fiRecordId : this.recordId,
            fiCreditManager : this.fiCreditManager
        })
        .then(res=>{
            console.log('res'+JSON.stringify(res));
            if(res.isError){
                this.template.querySelector('c-common-toast').showToast('error','<strong>'+res.errorMessage+'<strong/>','utility:error',10000);
            }
            else{
                this.template.querySelector('c-common-toast').showToast('success','<strong>Record Cancelled Successfully<strong/>','utility:success',10000);
                this.disabledRejectButton = true;
                this.updateRecordAndNavigateToHomePage();
            }   
        })
        .catch(err=>{
            console.log('err'+err);
            this.template.querySelector('c-common-toast').showToast('success','<strong>'+err.body.message+'<strong/>','utility:success',10000);
        })
    }

    updateRecordAndNavigateToHomePage(){
        // alert('called');    
        // const fields = {};
        // fields['Id'] = this.recordId;
        // const recordInput = {
        //     fields: fields
        //   };
        // updateRecord(recordInput)
        // .then((record) => {
        //     alert('here');
        //     console.log(record);
        // })
        // .catch(err=>{
        //     alert('here error'+JSON.stringify(err));
        // })

        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Field_Investigation_Tab'
            },
        });
    }
}