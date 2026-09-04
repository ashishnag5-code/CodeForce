import { LightningElement,api } from 'lwc';
import getApplicantDetails from '@salesforce/apex/CustomerSummaryController.getApplicantDetails'
import getCCResponse from '@salesforce/apex/LeadDedupeController.getCCResponse';
import getLoanODDetails from '@salesforce/apex/CustomerSummaryController.getLoanODDetails';

// Custom Spinner settings
import { getSpinnerImage } from 'c/customSpinner';
// Custom Spinner settings

export default class AusfCustomerSummary extends LightningElement {

    //API Attributes
    @api recordId;

    //Boolean Attributes
    isLoading = false;
    viewMorePartial = false;

    applicantDetails;

    connectedCallback() {
        this.getApplicantDetails();
    }

     // Custom Spinner settings
     async spinnerImageMethod() {
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.recordId);
        }
    }
    // Custom Spinner settings

    async getApplicantDetails() {
        await this.spinnerImageMethod();
        this.isLoading = true;

        getApplicantDetails({
                loanId: this.recordId,
            }).then(result => {
                if (result) {
                    this.applicantDetails = result;
                    console.log('applicantDetails-->' + JSON.stringify(this.applicantDetails))
                    this.isLoading = false;
                }
            })
            .catch(error => {
                this.isLoading = false;
                console.log('error in getApplicantDetails-->' +error);
            })
    }

    viewMoreHandler(event) {
        if (event != undefined && event.currentTarget.dataset != undefined) {
            if (event.currentTarget.dataset.recordName == 'ViewMoreInformation') {
                var recordId = event.currentTarget.dataset.id;
                //this.viewMorePartial = true;
                console.log('recordId-->' + recordId);

                /* let records = this.addressLst;
                 let addressrecords = [];

                 for (let i = 0; i < this.addressLst.length; i++) {
                     if (this.addressLst[i].Id == recordId) {
                         addressrecords.push(records[i]);
                     }
                 }
                 console.log('addressrecords-->' + JSON.stringify(addressrecords));
                 this.selectedRecords = addressrecords;*/
            }
        }
    }

    /*handleLoanODDetails(event) {
        let applicantId = event.target.dataset.Id;
        let cifNO = event.target.name;
        Promise.all([
            getLoanODDetails({
                strCustomerId: cifNO,
                strApplicantId: applicantId
            }),
            getCCResponse({
                strCustomerId: cifNO,
                strApplicantId: applicantId
            })
        ]).then((values) => {
           

        }).catch(error => {
            
        })
    }*/


}