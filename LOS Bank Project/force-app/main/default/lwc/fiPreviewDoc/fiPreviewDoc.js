import { LightningElement, api, track, wire } from 'lwc';
//import { subscribe, MessageContext } from 'lightning/messageService';
//import DOCUMENT_ID from '@salesforce/messageChannel/PreviewDocId__c';
import getVersionFiles from '@salesforce/apex/FieldInvestigationDocumentManager.getVersionFiles';
import deactivateDocument from '@salesforce/apex/FieldInvestigationDocumentManager.deactivateDocument';


export default class FiPreviewDoc extends LightningElement {

    @track showSpinner = false;
    url = '';
    @api heightInRem;
    @api imagesList;
    @api imagesList2;
    @api recordId;
    @api objectApiName; 
    isUploadImages;

    getUploadedFiles() {
        getVersionFiles({ recordId: this.recordId, objectApiName: this.objectApiName })
            .then(result => {
                if (result != null) {
                    this.showSpinner=false;
                    console.log('result**>>>>' + JSON.stringify(result));
                    result.length >=6 ?this.isUploadImages=false:this.isUploadImages=true;

                   // result.length >3?this.imagesList2= result.slice(3, 6): this.imagesList = result.slice(0, 3);
                   this.imagesList2= result.slice(3, 6);
                   this.imagesList = result.slice(0, 3);
                   
                    
                }
            })
            .catch(error => {
                this.showSpinner=false;
                console.log('this.error>>>>>' + JSON.stringify(this.error));

                this.error = error;
            });
    }

    connectedCallback() {
        this.getUploadedFiles();
    }

    handleClickDelete(event) {
        this.showSpinner=true;
      //  let id = event.currentTarget.name;
      let id =event.detail.value;
        console.log('ContentVersionid' + id);
        deactivateDocument({ recordId: id })
            .then((result) => {
                let parseResult = JSON.parse(result);
                if (parseResult.isSuccess) {
                   this.getUploadedFiles();
                   this.template.querySelector('c-common-toast').showToast('success','<strong>Successfully Deleted<strong/>','utility:success',10000);
                } else {
                    this.template.querySelector('c-common-toast').showToast('Error','<strong>Error<strong/>','utility:error',10000);
                    console.log('No result found.');
                    console.log('Error message' + parseResult.message);
                }
            }
            )
            .catch(error => {
                this.error = error;
                this.isloading = false;
            });
    }

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

    renderedCallback() {
        console.log('imagesList>>>' + JSON.stringify(this.imagesList));
        const storeEvent = new CustomEvent('isuploadcomponentvisible', {
            detail: {
                showUploadComponent: this.isUploadImages
            }
          }
          );
          this.dispatchEvent(storeEvent);
    }


}