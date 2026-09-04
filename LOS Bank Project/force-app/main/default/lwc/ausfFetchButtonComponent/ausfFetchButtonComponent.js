import { LightningElement,api } from 'lwc';
import getCCResponse from '@salesforce/apex/LeadDedupeController.getCCResponse';
import getLoanODDetails from '@salesforce/apex/CustomerSummaryController.getLoanODDetails';
import handleCCExposure from '@salesforce/apex/CustomerSummaryController.handleCCExposure';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Custom Spinner settings
import { getSpinnerImage } from 'c/customSpinner';
// Custom Spinner settings

export default class AusfFetchButtonComponent extends LightningElement {
    @api loanId;
    @api applicantId;
    @api customerId;
    @api stage;
    @api isDisabled;
    @api isCreditPopOver = false;

    //Boolean Attributes
    isloading = false;
    showBRE = false;

    creditDetails;

    connectedCallback(){
        if(this.isCreditPopOver){
            this.handleLoanODDetails();
        }
    }

     // Custom Spinner settings
     async spinnerImageMethod() {
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.recordId);
        }
    }
    // Custom Spinner settings

    async handleLoanODDetails() {
        await this.spinnerImageMethod();
        this.isloading = true;
        let applicantId = this.applicantId;
        let cifNO = this.customerId;
        this.error = '';
        console.log('cifNO-->' +cifNO);
        Promise.all([
            getLoanODDetails({
                strCustomerId: cifNO,
                strApplicantId: applicantId,
                loanId : this.loanId
            }),
            getCCResponse({
                strCustomerId: cifNO,
                strApplicantId: applicantId
            })
        ]).then((values) => {
            this.isloading = false;
              if(values[0] != undefined && !values[0].error){
                if(values[0].dpdFound == false){
                    this.showMessage('Exposure is Fetched - No DPD Found', 'Success');
                    if(this.isCreditPopOver){
                        this.dispatchEvent(new CustomEvent('dpdfetched',{
                            detail:{
                                message : 'Exposure is Fetched - No DPD Found'
                            } 
                        }));
                    }
                }else if(values[0].dpdFound == true){
                    this.showMessage('Exposure is Fetched - DPD Found', 'Error');
                    if(this.isCreditPopOver){
                        this.dispatchEvent(new CustomEvent('dpdfetched',{
                            detail:{
                                message : 'Exposure is Fetched - DPD Found'
                            } 
                        }));
                    }
                }
                else{
                    this.error = 'API Error : Please try again in sometime.'
                }
              }else{
                this.error = values[0].error;
              }
              if(values[1] != undefined){
                console.log('CCDetails-->' +JSON.stringify(values[1],null,2));
                this.creditDetails = values[1];
                this.handleCCDetails(this.creditDetails );
                   //this.applicantCreditCard = values[1];
              }
              if(!this.error && this.creditDetails){
                this.handleCCDetails(this.creditDetails );
              }else if(this.error){
                this.showMessage(this.error, 'Error');
              }

        }).catch(error => {
             if(error[0] != undefined){
                  this.error = error[0];
             }
             if(error[1] != undefined){
                  this.error = error[1];
             }
             this.showMessage(this.error, 'Error');
             this.isloading = false;

        })
    }

    handleCCDetails(creditDetails) {
        this.isloading = true;
        this.showBRE = false;
        handleCCExposure({
            strCustomerId: this.customerId,
            strApplicantId:this.applicantId,
            creditBankRecords: JSON.stringify(creditDetails)
        }).then(response => {
            this.isloading = false;
            let responseVal = response;
            console.log('responseVal-->' +responseVal);
            //event dispatch for CIF LAN Creation start
            this.dispatchEvent(new CustomEvent('exposurefetched',{
                detail:{
                    applicantRecordId : this.applicantId
                } 
            }));
            //event dispatch for CIF LAN Creation end
            if(responseVal == true && !this.isCreditPopOver){
                //Show the BRE Component
                this.showBRE = true;
                this.showMessage('Your Exposure has been increased from the previous', 'Success');
            }

        }).catch(error => {

            this.isloading = false;

        })
    }

     closeModal(){
       this.showBRE= false;
    }

    showMessage(message, variant) {
        const event = new ShowToastEvent({
            title: '',
            variant: variant,
            mode: variant === 'error' ? 'sticky' : 'dismissible',
            message: message
        });
        this.dispatchEvent(event);
    }

}