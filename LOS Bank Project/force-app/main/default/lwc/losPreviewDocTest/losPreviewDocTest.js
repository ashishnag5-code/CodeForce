import { LightningElement,api,track,wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import DOCUMENT_ID from '@salesforce/messageChannel/PreviewDocId__c';

export default class LosPreviewDocTest extends LightningElement {

    showSpinner = false;
    url = '';
    isFileTypePDF = false;
    @api heightInRem;
    @api imagesList;

   /* @wire(MessageContext)
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
*/
    get pdfHeight() {
        return 'height: ' + this.heightInRem + 'rem';
    }

    renderedCallback(){
        console.log('imagesList>>>'+JSON.stringify(this.imagesList));

    }
    connectedCallback(){
      //  this.subscribeToMessageChannel();
     /* this.url = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=0686s0000014cTrAAI';
        this.isFileTypePDF = false;
        this.showSpinner = false;
        console.log('url>>>>'+this.url);*/
    }  

}