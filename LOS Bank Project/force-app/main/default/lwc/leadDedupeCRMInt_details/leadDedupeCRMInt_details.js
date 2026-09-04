import { LightningElement, api } from 'lwc';
import copyApplicantfromLeadtoLead from '@salesforce/apex/LeadDedupeController.copyApplicantfromLeadtoLead';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class LeadDedupeCRM_details extends LightningElement {
    @api applicantRecord = {};
    @api
    applicantInput = {};
    @api
     spinnerImage;
    errorOnChild = '';
    isMobile = false;
    isLoading;

    viewAllRecords(event){
        this.dispatchEvent(new CustomEvent('viewall'));
    }

    markSelected(event){
        this.isLoading = true;
        var selectedRecordId = event.currentTarget.dataset.id;
        console.log('%% in'+selectedRecordId);
        console.log('%% in'+this.applicantInput);

        copyApplicantfromLeadtoLead({ objLeadtoLeadWrapper : this.applicantRecord ,objApplicant : this.applicantInput})
		.then(result => {
            this.isLoading = false;
			console.log('result is '+JSON.stringify(result));
            this.dispatchEvent(new CustomEvent('copyrecord',{detail:{value:result,tab:'CRM'}, bubbles:true,composed:true}));
		})
		.catch(error => {
            this.isLoading = false;
            console.log('result is '+error)
		})
    }

    setFormFactor() {
        switch (FORM_FACTOR) {
            case 'Large': {
                this.isMobile = false;
                break;
            }
            case 'Medium': {
                this.isMobile = true;
                break;
            }
            case 'Small': {
                this.isMobile = true;
                break;
            }
        }
    }

    connectedCallback() {
        this.setFormFactor();
        console.log('Form factor - Mobile : ', this.isMobile);
    }
}