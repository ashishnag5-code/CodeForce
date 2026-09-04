import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';
import uploadIcon from '@salesforce/resourceUrl/uploadIcon';
import refreshIcon from '@salesforce/resourceUrl/refreshIcon';
import getDocumentChecklist from '@salesforce/apex/DocumentManagerHandler.getDocumentChecklist';
import getVersionFiles from '@salesforce/apex/DocumentManagerHandler.getVersionFiles';
import {
    publish,
    MessageContext
} from 'lightning/messageService';
import DOCUMENT_ID from '@salesforce/messageChannel/PreviewDocId__c';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    NavigationMixin
} from 'lightning/navigation';



export default class DocManager extends NavigationMixin(LightningElement) {
    @api recordId;
    @track showTable;
    responseWrap;
    @track docList = [];
    @wire(MessageContext)
    messageContext;
    @track contentUrl;
    refresh = refreshIcon;
    upload = uploadIcon;
    get acceptedFormats() {
        return ['.pdf', '.png'];
    }

    connectedCallback() {
        console.log('record id:' + this.recordId);

        getVersionFiles({
                recordId: this.recordId
            })
            .then(result => {
                console.log('data is ' + JSON.stringify(result))
                this.responseWrap = result;
                this.showTable = true;
                console.log(this.responseWrap, 'preview com');
            })
            .catch(error => {
                this.responseWrap = null;
            });

        getDocumentChecklist({
                applicantId: this.recordId
            })
            .then((result) => {
                this.docList = JSON.parse(result);
            })
            .catch(() => {});
    }



    handleUploadFinished(event) {
        console.log('File upload finished...');
    }

    handleUpload(event) {
                this[NavigationMixin.Navigate]({
                    type: "standard__webPage",
                    attributes: {
                        url : "aubridge://biometric/:" + this.recordId
                    },
                });
        }

    handleRefresh(event) {
         getVersionFiles({
                        recordId: this.recordId
                    })
                    .then(result => {
                        console.log('data is ' + JSON.stringify(result))
                        this.responseWrap = result;
                        this.showTable = true;
                        console.log(this.responseWrap, 'preview com');
                    })
                    .catch(error => {
                        this.responseWrap = null;
                    });

                getDocumentChecklist({
                        applicantId: this.recordId
                    })
                    .then((result) => {
                        this.docList = JSON.parse(result);
                    })
                    .catch(() => {});
    }

    handleClick(event) {

        let id = event.currentTarget.name;
        var thisUrl;
        for (let i = 0; i < this.responseWrap.length; i++) {
            console.log('obj url is' + JSON.stringify(this.responseWrap[i].url))
            console.log('id is ' + id)
            if (this.responseWrap[i].recordId == id) {
                thisUrl = this.responseWrap[i].url;
                if (this.responseWrap[i].fileType == 'pdf') {
                    this.isFileTypePDF = true;
                } else {
                    this.isFileTypePDF = false;
                }
            }
        }
        console.log('url is' + thisUrl);
        this.contentUrl = thisUrl;
        const payload = {
            docid: thisUrl,
            fileType: this.isFileTypePDF
        };

       // publish(this.messageContext, DOCUMENT_ID, payload);

    }

}