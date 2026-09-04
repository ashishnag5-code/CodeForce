import { api, LightningElement, track ,wire} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { getSpinnerImage } from 'c/customSpinner';
import getActivePrimaryApplicants from '@salesforce/apex/CAMReportLWCController.getActivePrimaryApplicants'
import CAM_No_APPLICANT_ERROR from '@salesforce/label/c.CAM_No_APPLICANT_ERROR';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi'; //R2-1170,1769
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
    createMessageContext
  } from 'lightning/messageService';
import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c';
const FIELDS = ['Loan_Application__c.Product__c']; //R2-1170,1769
//added LMS event - SFAU-5280

export default class CreditSummaryPage extends NavigationMixin(LightningElement) {

    @api recordId
    @track fileUrl
    @track fileExists=false
    @track showBack=false
    @track loadSpinner=false
    subscription = null;
    @api
    spinnerImage;
    height;
    product; //R2-1170,1769
    @track tractorList = ['10501','10502','10503','10104','10105','10106','10101','10102','10103','10204','10205','10206','10401','10402','10403']; //R2-1170,1769
    @api 
    get heightInRem(){
        return this.height+'rem'
    }
    set heightInRem(value){
        this.height=value
    }

    loadData(){
        this.loadSpinner=false
    }

    //R2-1170,1769
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            this.product = data.fields.Product__c.value;
        }
    }

    async connectedCallback(){
        this.showBack=false
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.recordId);
        }
        this.subscribeToMessageChannel()
        this.setInitialData()
        /*const activePrimaryApplicants = await getActivePrimaryApplicants({loanId: this.recordId})
        if(!activePrimaryApplicants || activePrimaryApplicants.length<=0){
            this.showToastMessage('',CAM_No_APPLICANT_ERROR,'error','sticky')
            return;
        }
        this.generateLatestCamReport()*/
    }

    async setInitialData(){
        const activePrimaryApplicants = await getActivePrimaryApplicants({loanId: this.recordId})
        if(!activePrimaryApplicants || activePrimaryApplicants.length<=0){
            this.showToastMessage('',CAM_No_APPLICANT_ERROR,'error','sticky')
            return;
        }
        this.generateLatestCamReport()
    }

    generateLatestCamReport(){
        this.loadSpinner=true
        this.showBack=false
        this.fileExists=true
        var factor = FORM_FACTOR=='Small'?"1":"3"
        //R2-1170,1769
        if(this.tractorList.includes(this.product)){
            this.fileUrl='/apex/CreditSummaryTractor?id='+this.recordId+'&factor='+factor
        }
        else{
            this.fileUrl='/apex/CreditSummary4W?id='+this.recordId+'&factor='+factor
        }
        
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
            this.fileExists=false
            this.setInitialData()
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