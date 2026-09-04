import { LightningElement,api,wire } from 'lwc';
import getApplicantCibil from '@salesforce/apex/CibilReportPopOverController.getApplicantCibil'
import { NavigationMixin } from 'lightning/navigation';
import { getRecord } from "lightning/uiRecordApi";
const FIELDS = ["ContentVersion.Id", "ContentVersion.Title", "ContentVersion.VersionData"];

export default class CibilReportPopOver extends LightningElement {
    @api recordId;
    @api type;
    @api hideShareButton = false;
    @api renderBackToSummary = false;
    contentDocumentId='';
    contentVersionId;

    connectedCallback(){
        console.log('contentdocId '+this.type);
        console.log('applicant '+this.recordId);
        this.getApplicantCibil();
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
        window.open(this.type);
    }
    closeModal(){
        if(!this.renderBackToSummary){
            window.history.back();
        }
        else{
            this.dispatchEvent(new CustomEvent('back'));
        }
       
        
    }

    getApplicantCibil(){
        getApplicantCibil({
            applcntId : this.recordId
        })
        .then(data=>{
            console.log('data '+JSON.stringify(data));
            if(data){
                this.contentDocumentId = data.contentDocumentId;
                this.contentVersionId = data.contentVersionId;
            }

        })
        .catch(error=>{
            console.log('error '+JSON.stringify(error));
        })
    }

    @wire(getRecord, { recordId: "$contentVersionId", fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            let versionData = data.fields && data.fields.VersionData ? data.fields.VersionData.value : "";
            this.template.querySelector('.elementHoldingHTMLContent').innerHTML = atob(versionData);
        } else if (error) {
            console.log("Error" + error);
        }
    }
}