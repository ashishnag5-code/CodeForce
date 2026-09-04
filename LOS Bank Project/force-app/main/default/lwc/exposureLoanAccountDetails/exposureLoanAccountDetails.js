import { LightningElement,api } from 'lwc';
import getLoanDetails from '@salesforce/apex/exposureDetailsController.getLoanDetails';
import getLoanInquiryDetails from '@salesforce/apex/exposureDetailsController.getLoanInquiryDetails';
import handleExposureUpdation from '@salesforce/apex/exposureDetailsController.handleExposureUpdation';
import getVisibleFields from '@salesforce/apex/exposureDetailsController.getVisibleFields';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ExposureLoanAccountDetails extends LightningElement {
    //Api Attributes
    @api objAccountRecord;

    //Boolean Attributes
    isLoaded = false;

    //String Attributes
    includeExposure = 'Yes';
    selectedIncludeExposure='';

    //Array Attributes
    exposureOptions = [];

    includedExposure=[];

    connectedCallback() {
        console.log('loanaccountid-->' + this.objAccountRecord.Id +'---' +this.objAccountRecord.Applicant__r.Loan__r.Stage__c);
        this.getVisibleFieldsMetadata(this.objAccountRecord.Applicant__r.Loan__r.Stage__c);
        this.assignOptions();
    }

    assignOptions() {
        let elOptions = [];
        elOptions.push({
            label: 'Yes',
            value: 'Yes'
        });
        elOptions.push({
            label: 'No',
            value: 'No'
        });
        this.exposureOptions = elOptions;

        this.includeExposure = (this.objAccountRecord.Include_In_Exposure__c!=null)? (this.objAccountRecord.Include_In_Exposure__c) : 'Yes'	;
    }
    handleLoan() {
        this.getLoanStatement(this.objAccountRecord.Account_Number__c, this.objAccountRecord.Applicant__c);
    }

    getLoanStatement(accountNumber, applicant) {
        console.log('accountNumber' + accountNumber);
        this.isLoaded = true;

        Promise.all([
            getLoanDetails({
                accountNumberInstance: accountNumber,
                applicantId: applicant
            }),
            getLoanInquiryDetails({
                accountNumberInstance: accountNumber,
                applicantId: applicant
            })
        ]).then((result) => {
            //Making it as true to know that they have made a callout
      
            if (result[0]!=null && result[0].length > 0) {
                console.log('loanResponse-->' + JSON.stringify(result[0]));
               
                this.isLoaded = false;
            }else{
                this.showErrorMessage('No Response,Please try again with different AccountNumber ', 'error');
               /* this.dispatchEvent(new CustomEvent('render', {
                    detail: true
                }));*/
            }
            if (result[1]!=null && result[1].length > 0) {
                console.log('inquiryResponse-->' + JSON.stringify(result[1]));
                
               /* this.dispatchEvent(new CustomEvent('render', {
                    detail: true
                }));*/
                this.isLoaded = false;
            }else{
                this.showErrorMessage('No Response,Please try again with different AccountNumber ', 'error');
               /* this.dispatchEvent(new CustomEvent('render', {
                    detail: true
                }));*/
            }

            if(result[1]!=null  && result[0].length > 0 && result[1].length > 0&&  result[0]!=null ){
                this.dispatchEvent(new CustomEvent('loandetails', {
                    detail: result[0]
                }));
                this.dispatchEvent(new CustomEvent('inquirydetails', {
                    detail: result[1]
                }));
            }
            this.isLoaded = false;
        }).catch(error => {
            console.log('error in loan api' + JSON.stringify(error));
            this.isLoaded = false;
        })
    }

    getVisibleFieldsMetadata(stageVal) {
        this.isLoaded = true;

        getVisibleFields({
                strScreen: 'Exposure Loan',
                Stage: stageVal
            })
            .then(result => {
                // console.log('visiblefieldsinloan-->' +JSON.stringify(result));
                result.forEach(input => {
                    this.template.querySelector('[data-id="' + input + '"]').classList.remove('slds-hide');
                });
                this.isLoaded = false;
            })
            .catch(error => {
                this.isLoaded = false;
                console.log('result is ' + JSON.stringify(error));
            })
    }

    handleChange(event){
        let picklistName = event.target.name;
        let picklistValue = event.target.value;

        this.selectedIncludeExposure = picklistValue;
       // this.exposureMap.set(this.objAccountRecord.Id,'No');
       this.includedExposure.push({ accountId:this.objAccountRecord.Id, POS:this.objAccountRecord.POS__c,applicantId:this.objAccountRecord.Applicant__c, accountType: this.objAccountRecord.Account_Type__c,productCode: this.objAccountRecord.Product_Code__c})

        if(picklistName == 'includeExposure'){
                this.updateExposureDetails();
        }
    }

    updateExposureDetails(){
        this.isLoaded = true;
        //console.log('exposureDetailsupdateArray-->' +JSON.stringify(this.objAccountRecord));
        handleExposureUpdation({
          records:this.objAccountRecord, includeExposureVal : this.selectedIncludeExposure
        })
        .then(result => {
            if(result){
                    console.log('calculatedResult-->' +JSON.stringify(result));
                    this.isLoaded = false;
                    var resultVal = result;
                    this.dispatchEvent(new CustomEvent('exposurecalculation', {
                        //detail: this.objAccountRecord
                        detail: resultVal
                    }));
            
                        this.dispatchEvent(new CustomEvent('loancredit', {
                            detail: this.objAccountRecord
                        }));
                }
                this.isLoaded = false;
        })
        .catch(error => {
            this.isLoaded = false;
            console.log('result is ' + JSON.stringify(error));
        })
    }

    showErrorMessage(message, variant) {
        const event = new ShowToastEvent({
            title: '',
            variant: variant,
            mode: 'sticky',
            message: message
        });
        this.dispatchEvent(event);
    }
}