import { LightningElement, api } from 'lwc';
import copyApplicantfromCRM from '@salesforce/apex/LeadDedupeController.copyApplicantfromCRM';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class AusfCustomerCollateralEnquiryDetails extends LightningElement {
    @api applicantRecord = {};
    @api
    applicantInput = {};
    errorOnChild = '';
    isMobile = false;
    @api collatralDetail;
    @api linkageDetail;
    @api automobileDetail;
    @api valuationDetail;
    @api propertyDetail;
    @api isAutomobileView = false;
    @api isPropertyView = false;

    viewAllRecords(){
        this.dispatchEvent(new CustomEvent('viewall'));
    }

    markSelected(event){
        var selectedRecordId = event.currentTarget.dataset.id;
        console.log('%% in'+selectedRecordId);
        console.log('%% in'+this.applicantInput);

        copyApplicantfromCRM({ objApplicanttoCopy : this.applicantRecord ,objApplicant : this.applicantInput})
		.then(result => {
			console.log('result is '+JSON.stringify(result));
            this.dispatchEvent(new CustomEvent('copyrecord',{detail:{value:result.applicant,tab:'CRM'}, bubbles:true,composed:true}));
		})
		.catch(error => {
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