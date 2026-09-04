import { LightningElement, api } from 'lwc';
import LightningModal from 'lightning/modal';
import postFeed from "@salesforce/apex/cibilScoreViwerUsingLinkController.postFeed";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class CibilReportMobileView extends LightningModal {
    @api domString;
    @api contentDocumentId;
    isShowModal = false;
    iconname = 'custom:custom33';
    userid ='';

    connectedCallback() {
        if (this.template.querySelector('.elementHoldingHTMLContent') !== null && this.template.querySelector('.elementHoldingHTMLContent') !== undefined) {
            this.template.querySelector('.elementHoldingHTMLContent').innerHTML = this.domString;
        }
    }

    renderedCallback() {
        if (this.template.querySelector('.elementHoldingHTMLContent') !== null && this.template.querySelector('.elementHoldingHTMLContent') !== undefined) {
            this.template.querySelector('.elementHoldingHTMLContent').innerHTML = this.domString;
        }
    }

    shareOrDownloadFile() {
        /*this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: this.contentDocumentId
            }
        });*/
        this.isShowModal = true;
    }

    closeModal() {
        this.close('Success');
    }

    hideModalBox(){
        this.isShowModal = false;
    }

    handleChange(event){
        this.userid = event.detail.value;
        console.log('****j', this.userid);
         /*alert('Selected value '+ event.detail.value);
         alert('Selected name '+ event.detail.name);
         alert('Selected label '+ event.detail.label);*/
    }
    shareReportToUser(){
        if(this.userid == ''){
            alert('Please select User');
        }else{
            postFeed({ contentId: this.contentDocumentId, userId: this.userid})
            .then((result) => {
                this.isShowModal = false;
                this.close('Success');
            })
            .catch((error) => {
                this.isShowModal = false;
                this.close('Success');
            });
        }
    }
}