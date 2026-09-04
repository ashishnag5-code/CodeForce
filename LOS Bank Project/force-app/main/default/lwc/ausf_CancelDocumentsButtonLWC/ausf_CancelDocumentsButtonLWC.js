import {api, LightningElement, track} from 'lwc';
import cancelDocuments from '@salesforce/apex/SystemGenerateDocumentsController.systemGenerateDocumentLWCMethod';
import generateCancelApprovalRecords from '@salesforce/apex/SystemGenerateDocumentsController.generateCancelApprovalRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getSpinnerImage } from 'c/customSpinner';
import My_Resource from '@salesforce/resourceUrl/ausfIcons';
import FORMFACTOR from '@salesforce/client/formFactor'



export default class Ausf_CancelDocumentsButtonLWC extends LightningElement {
    isShowModal = false;
    applicationRecord = {};
    selectedLetterTypes = {'sanctionLetter':false,'doletter':false};
    selectedLetterCount = 0;
    generatedLetterSuccessfully = [];
    isSending = false;
    @track isDisabledSactionLetter = false;
    @track isDisabledDOLetter = false;
    isRefreshRecord = false;
    @api spinnerImage;
    submitToOpsMaker   = My_Resource + '/ausfIcons/Submit-to-Ops-maker.png';
    generateDoSanction = My_Resource + '/ausfIcons/Generate-DO-sanction.png';
    cancelDoSanction   = My_Resource + '/ausfIcons/Cancel-DO-sanction.png';
    generateEsign      = My_Resource + '/ausfIcons/Generate-E-sign.png';

    async spinnerImageMethod() {
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.applicationRecord.Id);
        }
        console.log('%%spinner image '+this.spinnerImage);
    }


    connectedCallback(){
        if(FORMFACTOR == 'Small'){
            this.isSmallDevice = true
            this.isLargeDevice=false
        }else{
            this.isSmallDevice = false
            this.isLargeDevice=true
        }
    }

    @api
    renderComponent(loanApplicationRecord) {
        console.log('application Record '+JSON.stringify(loanApplicationRecord));
        this.isShowModal = true;
        this.applicationRecord = loanApplicationRecord;
        this.isDisabledSactionLetter = !this.applicationRecord.hasOwnProperty('Sanction_Status__c')
        this.isDisabledDOLetter = !this.applicationRecord.hasOwnProperty('DO_Status__c')
        this.spinnerImageMethod();
        // this.selectedLetterTypes.doletter = (this.applicationRecord.fields.DO_Status__c.value == 'Cancelled');
        // this.selectedLetterTypes.sanctionLetter = (this.applicationRecord.fields.Sanction_Status__c.value == 'Cancelled')
    }

    hideModalBox() {
        this.isShowModal = false;
        const refreshEvt = new CustomEvent('refresh',{detail : this.isRefreshRecord});
        this.dispatchEvent(refreshEvt);
    }

    handleCheckBoxSelect(evt) {
       this.selectedLetterTypes[evt.currentTarget.dataset.id]=evt.target.checked;
    }

    handleSanctionLetterCancellation(){
        this.isSending = true;
        this.selectedLetterCount++;
        this.generateCancelApprovalRecords('Sanction Cancelled letter');
        //this.cancelDocumentHelper('Sanction Cancelled letter',this.applicationRecord.Id,'sanctionLetter');

    }
 
    handleDOLetterCancellation(){
        this.isSending = true;
        this.selectedLetterCount++;
        this.generateCancelApprovalRecords('DO Cancelled letter');
        //this.cancelDocumentHelper('DO Cancelled letter', this.applicationRecord.Id,'doletter');
    }

    generateCancelApprovalRecords(letterType){
        generateCancelApprovalRecords({
            loanId : this.applicationRecord.Id,
            letterType : letterType
        })
        .then(res=>{
            this.showToast('Note!!',res,'warning');
            this.isSending = false;
            this.hideModalBox();
            
        })
        .catch(err=>{
            this.showToast('ERROR','Error in raising Approval Records','error');
            this.isSending = false;
            this.hideModalBox();
        })
    }

    // cancelDocuments() {
    //     this.isSending = true;
    //     this.generatedLetterSuccessfully = [];
    //     if(!this.selectedLetterTypes.sanctionLetter && !this.selectedLetterTypes.doletter) {
    //         this.showToast('ERROR','Please select a checkbox to proceed','error');
    //         this.isSending = false;
    //         return;
    //     }
    //     else{
    //         if(this.selectedLetterTypes.sanctionLetter){
    //             this.selectedLetterCount++;
    //             this.cancelDocumentHelper('Sanction Cancelled letter',this.applicationRecord.Id,'sanctionLetter');
    //         }
    //         if(this.selectedLetterTypes.doletter){
    //             this.selectedLetterCount++;
    //             this.cancelDocumentHelper('DO Cancelled letter', this.applicationRecord.Id,'doletter');
    //         }            
    //     }
    // }

    // cancelDocumentHelper(letterType, applicationId, generatedLetterId) {
    //     cancelDocuments({
    //         letterType : letterType,
    //         applicationId : applicationId

    //     })
    //     .then(res=>{
    //         this.isRefreshRecord = true;
    //         this.generatedLetterSuccessfully.push({letterType : generatedLetterId, isSuccessful : true})
    //         this.validateAllLettersSent();
    //     })
    //     .catch(err=>{
    //         this.isRefreshRecord = false;
    //         this.showToast('ERROR','Error in generating letter','error');
    //         this.isSending = false;
    //         this.hideModalBox();

    //     })
    // }

    // validateAllLettersSent() {
    //     if(!this.generatedLetterSuccessfully) {
    //         return
    //     }
    //     if(this.generatedLetterSuccessfully.length == this.selectedLetterCount) {
    //         this.isSending = false;
    //         this.showToast('SUCCESS','Letters Generated Successfully','success');
    //         this.hideModalBox();
    //     }

    // }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }



}