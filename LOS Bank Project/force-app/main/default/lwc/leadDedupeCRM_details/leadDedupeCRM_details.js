import { LightningElement, api } from 'lwc';
import copyApplicantfromCRM from '@salesforce/apex/LeadDedupeController.copyApplicantfromCRM';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class LeadDedupeCRM_details extends LightningElement {
    @api applicantRecord = {};
    @api
    applicantInput = {};
    errorOnChild = '';
    isMobile = false;
    @api
    boolIsNPA;
    @api
    spinnerImage;
    @api applicableDedupeActions = [ 'Applicant Copy' ];
    isLoading;

    // R2-28
    get allowCopyToApplication(){
        return this.applicableDedupeActions?.includes('Applicant Copy');
    }

    viewAllRecords(event){
        this.dispatchEvent(new CustomEvent('viewall'));
    }

    markSelected(event){
        var selectedRecordId = event.currentTarget.dataset.id;
        console.log('%% in'+selectedRecordId);
        console.log('%% in'+this.applicantInput);
        if(this.boolIsNPA){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'NPA Detected. Application cannot Proceed',
                    message: 'NPA Detected. Application cannot Proceed',
                    variant: 'error',
                }),
            );
        }
        else {
            copyApplicantfromCRM({ objApplicanttoCopy : this.applicantRecord ,objApplicant : this.applicantInput})
            .then(result => {
                console.log('result is '+JSON.stringify(result));
                this.dispatchEvent(new CustomEvent('copyrecord',{detail:{value:result.applicant,tab:'CRM'}, bubbles:true,composed:true}));
            })
            .catch(error => {
                console.log('result is '+error)
            })
        }
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