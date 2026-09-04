import { api, LightningElement, track } from 'lwc';
import generateDocuments from '@salesforce/apex/SystemGenerateDocumentsController.systemGenerateDocumentLWCMethod';
import generateDOSanctionApprovalRecords from '@salesforce/apex/SystemGenerateDocumentsController.generateDOSanctionApprovalRecords';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getSpinnerImage } from 'c/customSpinner';
import My_Resource from '@salesforce/resourceUrl/ausfIcons';
import FORMFACTOR from '@salesforce/client/formFactor'


export default class Ausf_GenerateDocumentButtonLWC extends LightningElement {

    isShowModal = false;
    isLoaded = false;
    applicationRecord = {};
    selectedLetterTypes = {'sanctionLetter':false,'doletter':false};
    selectedLetterCount = 0;
    generatedLetterSuccessfully = [];
    isSending = false;
    isRefreshRecord = false;
    @track isDisabledSactionLetter = false;
    @track isDisabledDOLetter = false;
    @api spinnerImage;
    submitToOpsMaker   = My_Resource + '/ausfIcons/Submit-to-Ops-maker.png';
    generateDoSanction = My_Resource + '/ausfIcons/Generate-DO-sanction.png';
    cancelDoSanction   = My_Resource + '/ausfIcons/Cancel-DO-sanction.png';
    generateEsign      = My_Resource + '/ausfIcons/Generate-E-sign.png';
    isSmallDevice=false
    isLargeDevice=false
    @track renderRBMTatkalModal = false;
    @track renderFIPendingRBMTatkal = false;
    @track renderESignPendingRBMTatkal = false;
    @track renderGenericPendingRBMTatkal = false;
    modalClass = 'slds-modal slds-fade-in-open'; //R2-2546

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
            this.modalClass = 'slds-modal slds-fade-in-open slds-modal_full'; //R2-2546
        }else{
            this.isSmallDevice = false
            this.isLargeDevice=true
        }
    }

    @api
    renderComponent(loanApplicationRecord) {
        this.isShowModal = true;
        this.applicationRecord = loanApplicationRecord;
        console.log('test '+JSON.stringify(this.applicationRecord))
        this.isDisabledSactionLetter = (this.applicationRecord.hasOwnProperty('Sanction_Status__c') && this.applicationRecord.Sanction_Status__c=='Issued');
        this.isDisabledDOLetter = (this.applicationRecord.hasOwnProperty('DO_Status__c') && this.applicationRecord.DO_Status__c=='Issued');
        this.spinnerImageMethod();
    }

    hideModalBox() {
        this.isShowModal = false;
        const refreshEvt = new CustomEvent('refresh',{detail : this.isRefreshRecord});
        this.dispatchEvent(refreshEvt);
    }

    handleCheckBoxSelect(evt) {
       this.selectedLetterTypes[evt.currentTarget.dataset.id]=evt.target.checked;
    }

    @track nextButtonLabel='Proceed'
    handleSanctionLetterGeneration(){
        if((this.applicationRecord.hasOwnProperty('Application_FI_Status__c') && (this.applicationRecord.Application_FI_Status__c == 'Negative' || this.applicationRecord.Application_FI_Status__c == 'Positive' || this.applicationRecord.Application_FI_Status__c == 'Waived Off'))
            && ((this.applicationRecord.hasOwnProperty('Esign_Status__c') && this.applicationRecord.Esign_Status__c != 'Initiated') || !this.applicationRecord.hasOwnProperty('Esign_Status__c'))
            && ((this.applicationRecord.hasOwnProperty('OPS_KYC_Action__c') && this.applicationRecord.OPS_KYC_Action__c != 'Rework') || !this.applicationRecord.hasOwnProperty('OPS_KYC_Action__c'))
        ){
            this.isLoaded = true;
            this.isSending = true;
            this.selectedLetterCount++;
            this.generateDocumentHelper('Sanction letter',this.applicationRecord.Id, 'sanctionLetter');
        }
        else{
            this.renderFIPendingRBMTatkal = !(this.applicationRecord.hasOwnProperty('Application_FI_Status__c') && (this.applicationRecord.Application_FI_Status__c == 'Negative' || this.applicationRecord.Application_FI_Status__c == 'Positive' || this.applicationRecord.Application_FI_Status__c == 'Waived Off'));
            if(!this.renderFIPendingRBMTatkal){
                this.renderESignPendingRBMTatkal = !((this.applicationRecord.hasOwnProperty('Esign_Status__c') && this.applicationRecord.Esign_Status__c != 'Initiated') || !this.applicationRecord.hasOwnProperty('Esign_Status__c'));
                if(!this.renderESignPendingRBMTatkal){
                    this.renderGenericPendingRBMTatkal = true;
                }
            }
            this.renderRBMTatkalModal = true;
            this.systemLetterRequest = 'Sanction Letter'
        }   
    }

    @track renderRemarksSection = false;
    @track approvalRemarks = '';
    @track systemLetterRequest = '';

    handleRemarkChange(evt){
        this.approvalRemarks = evt.detail.value;
    }

    generateApprovalRequest(evt){
        if(this.nextButtonLabel == 'Proceed'){
            this.nextButtonLabel = 'Request';
            this.renderRemarksSection = true;
        }
        else if(this.nextButtonLabel == 'Request'){
            this.generateSystemLetterRequest();
        }
        
    }

    generateSystemLetterRequest(){
        this.isSending = true;
        generateDOSanctionApprovalRecords({
            loanId : this.applicationRecord.Id,
            letterType : this.systemLetterRequest,
            remarks : this.approvalRemarks,
            isRBMTatkal : true
        })
        .then(res=>{
            this.isSending = false;
            console.log('res '+JSON.stringify(res))
            this.showToast('Note!!',res,'warning');
            this.closeModal();
        })
        .catch(err=>{
            this.isSending = false;
            console.log('err '+JSON.stringify(err))
            this.showToast('Note!!','Error in raising the request','error');
            this.closeModal();
        })
    }

    handleDOLetterGeneration(){
        if((this.applicationRecord.hasOwnProperty('Application_FI_Status__c') && (this.applicationRecord.Application_FI_Status__c == 'Negative' || this.applicationRecord.Application_FI_Status__c == 'Positive' || this.applicationRecord.Application_FI_Status__c == 'Waived Off'))
            && ((this.applicationRecord.hasOwnProperty('Esign_Status__c') && this.applicationRecord.Esign_Status__c != 'Initiated') || !this.applicationRecord.hasOwnProperty('Esign_Status__c')) 
            && ((this.applicationRecord.hasOwnProperty('OPS_KYC_Action__c') && this.applicationRecord.OPS_KYC_Action__c != 'Rework') || !this.applicationRecord.hasOwnProperty('OPS_KYC_Action__c'))
        ){
            this.isSending = true;
            this.selectedLetterCount++;
            this.generateDocumentHelper('Delivery Order', this.applicationRecord.Id, 'doletter');
        }
        else{
            this.renderFIPendingRBMTatkal = !(this.applicationRecord.hasOwnProperty('Application_FI_Status__c') && (this.applicationRecord.Application_FI_Status__c == 'Negative' || this.applicationRecord.Application_FI_Status__c == 'Positive' || this.applicationRecord.Application_FI_Status__c == 'Waived Off'));
            if(!this.renderFIPendingRBMTatkal){
                this.renderESignPendingRBMTatkal = !((this.applicationRecord.hasOwnProperty('Esign_Status__c') && this.applicationRecord.Esign_Status__c != 'Initiated') || !this.applicationRecord.hasOwnProperty('Esign_Status__c'));
                if(!this.renderESignPendingRBMTatkal){
                    this.renderGenericPendingRBMTatkal = true;
                }
            }
            this.renderRBMTatkalModal = true;
            this.systemLetterRequest = 'Delivery Order';
        }
    }

    closeModal(){
        this.renderFIPendingRBMTatkal = false;
        this.renderESignPendingRBMTatkal = false;
        this.renderGenericPendingRBMTatkal = false;
        this.renderRBMTatkalModal = false;
        this.systemLetterRequest= '';
        this.renderRemarksSection = false;
        this.nextButtonLabel = 'Proceed';
        this.approvalRemarks = '';
    }

    // generateDocuments() {
    //     this.isSending = true;
    //     if(!this.selectedLetterTypes.sanctionLetter && !this.selectedLetterTypes.doletter) {
    //         this.showToast('ERROR','Please select a checkbox to proceed','error');
    //         this.isSending = false;
    //         return;
    //     }
    //     else{
    //         if(this.selectedLetterTypes.sanctionLetter){
    //             this.selectedLetterCount++;
    //             this.generateDocumentHelper('Sanction letter',this.applicationRecord.Id, 'sanctionLetter');
    //         }
    //         if(this.selectedLetterTypes.doletter){
    //             this.selectedLetterCount++;
    //             this.generateDocumentHelper('DO letter', this.applicationRecord.Id, 'doletter');
    //         }  
            
    //     }
    // }

    generateDocumentHelper(letterType, applicationId, generatedLetterId) {
        generateDocuments({
            letterType : letterType,
            applicationId : applicationId

        })
        .then(res=>{
            this.isRefreshRecord = true;
            this.generatedLetterSuccessfully.push({letterType : generatedLetterId, isSuccessful : true})
            this.validateAllLettersSent();
        })
        .catch(err=>{
            this.showToast('ERROR','Error in generating Letter','error');
            this.isSending = false;
            this.hideModalBox();


        })
    }

    validateAllLettersSent() {
        if(!this.generatedLetterSuccessfully) {
            return
        }
        if(this.generatedLetterSuccessfully.length == this.selectedLetterCount) {
            this.isSending = false;
            this.showToast('SUCCESS','Letters Generated Successfully','success');
            this.hideModalBox();
        }

    }

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