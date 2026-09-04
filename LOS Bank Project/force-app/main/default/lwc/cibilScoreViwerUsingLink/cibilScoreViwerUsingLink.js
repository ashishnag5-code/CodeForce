import { LightningElement, wire, track } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import contentData from "@salesforce/apex/cibilScoreViwerUsingLinkController.contentData";
import { getRecord } from "lightning/uiRecordApi";
const FIELDS = ["ContentVersion.Id", "ContentVersion.Title", "ContentVersion.VersionData"];

export default class CibilScoreViwerUsingLink extends LightningElement {
    @track conDocId;
    domString;
    cibilHTMLString;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            const urlValue = currentPageReference.state.c__conDocumentId;
            //alert(urlValue);
            if (urlValue) {
                this.conDocId = urlValue;
                //alert(this.conDocId);
                contentData({ value: urlValue })
                .then((result) => {
                    //alert(result);
                    if (this.template.querySelector('.elementHoldingHTMLContent') !== null && this.template.querySelector('.elementHoldingHTMLContent') !== undefined) {
                        this.template.querySelector('.elementHoldingHTMLContent').innerHTML = result;
                    }
                })
                .catch((error) => {
                this.domString = `Error during processing: ${error}`;
                });
            } else {
                this.conDocId = `URL Value was not set`;
            }
        }
    }

    /*renderedCallback() {
        if (this.template.querySelector('.elementHoldingHTMLContent') !== null && this.template.querySelector('.elementHoldingHTMLContent') !== undefined) {
            this.template.querySelector('.elementHoldingHTMLContent').innerHTML = this.domString;
        }
    }*/
}