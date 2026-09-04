import { LightningElement,api,track,wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import DOCUMENT_ID from '@salesforce/messageChannel/PreviewDocId__c';

export default class LosPreviewDoc extends LightningElement {

    @api recordId;
    @track showTable;
    showSpinner = false;
    url = '';
    isFileTypePDF = false;
    responseWrap;
    @api heightInRem;
    documentId;

    @wire(MessageContext)
    messageContext;
    subscribeToMessageChannel() {
        console.log('in subscribe model')
        this.showSpinner = true;
        this.subscription = subscribe(
          this.messageContext,
          DOCUMENT_ID,
          (message) => this.handleMessage(message)
        );
    }

    handleMessage(message) {
        
        this.url = message.docid;
        this.isFileTypePDF = message.fileType;
        this.showSpinner = false;
    }

    get pdfHeight() {
        return 'height: ' + this.heightInRem + 'rem';
    }

    connectedCallback(){
        this.subscribeToMessageChannel();
    }  

}