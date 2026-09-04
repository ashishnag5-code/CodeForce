import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import My_Resource from '@salesforce/resourceUrl/ausfIcons';
import checkIfEsignEnabled from '@salesforce/apex/SignDeskEsignApiController.checkIfEsignEnabled'
const FIELDS = ['Loan_Application__c.DO_Status__c', 'Loan_Application__c.Sanction_Status__c', 'Loan_Application__c.Stage__c'];

export default class Ausf_SystemGenerateDocuments extends LightningElement {

    submitToOpsMaker   = My_Resource + '/ausfIcons/Submit-to-Ops-maker.png';
    generateDoSanction = My_Resource + '/ausfIcons/Generate-DO-sanction.png';
    cancelDoSanction   = My_Resource + '/ausfIcons/Cancel-DO-sanction.png';

    @api recordId;
    @track renderButtons ={'generateButton':false,'cancelButton':false,'rejectButton':false, 
                            'generateEsignButton':false, 'submitToMaker': false}
    loanApplicationRecord = {};

    connectedCallback(){
        
    }

    checkifEsignFeatureEnabled(){
        checkIfEsignEnabled().then((data=>{
            this.renderButtons.generateEsignButton = data;
        }))
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            
        } else if (data) {
            this.loanApplicationRecord = data;
            if(this.loanApplicationRecord.fields.Stage__c.value == 'PSD'){
                if(this.loanApplicationRecord.fields.DO_Status__c.value == 'Cancelled' && this.loanApplicationRecord.fields.Sanction_Status__c.value == 'Cancelled') {
                    this.renderButtons.rejectButton = true;
                }
                else {
                    this.renderButtons.rejectButton = false;
                }
                this.renderButtons.generateButton = true
                this.renderButtons.submitToMaker = true
                this.renderButtons.cancelButton = true
                this.checkifEsignFeatureEnabled()
            }
            
        }
    }

    handleDocumentGenerate(evt) {
        this.template.querySelector('c-ausf_-generate-document-button-l-w-c').renderComponent(this.loanApplicationRecord);

    }

    handleCancelDocument(evt) {
        this.template.querySelector('c-ausf_-cancel-documents-button-l-w-c').renderComponent(this.loanApplicationRecord);

    }

    handleReturnToMaker(){

    }

    
    /*
    handleRejectDocument(evt) {
        this.template.querySelector('c-ausf_reject-document-button-l-w-c').renderComponent(this.loanApplicationRecord);
    }*/

    handleRefresh(evt) {
        if(evt.detail) {
            window.location.reload();
        }
    }


    
}