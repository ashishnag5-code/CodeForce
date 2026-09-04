import { LightningElement,api } from 'lwc';
import getVisibleFields from '@salesforce/apex/exposureDetailsController.getVisibleFields';
import handleExposureUpdation from '@salesforce/apex/exposureDetailsController.handleExposureUpdation';

export default class ExposureCreditLoanAccountDetails extends LightningElement {
    @api objAccountRecord;

    //Boolean Attributes
    isLoaded = false;
    creditOverride = false;

    //String Attributes
    includeExposure = 'Yes';
    selectedIncludeExposure ='';

    //Array Attributes
    exposureOptions = [];

    connectedCallback() {
        console.log('creditRecordId-->' +this.objAccountRecord.Id);
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
         this.creditOverride = (this.objAccountRecord.Credit_Override_authority__c!=null)? this.objAccountRecord.Credit_Override_authority__c : false;
      
        //console.log('Credit_Override_authority__c-->' +this.objAccountRecord.Credit_Override_authority__c);
        if(this.objAccountRecord.Include_In_Exposure__c!=null){
            this.includeExposure = this.objAccountRecord.Include_In_Exposure__c	;
        }else{
            this.includeExposure = 'Yes';
        }
       
    }

    getVisibleFieldsMetadata(stageVal) {
        this.isLoaded = true;
        getVisibleFields({
                strScreen: 'Exposure Credit',
                Stage: stageVal
            })
            .then(result => {
               // console.log('creditloanfields-->' +JSON.stringify(result));
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
        if(picklistName == 'includeExposure'){
                this.updateExposureDetails();
        }
    }

    updateExposureDetails(){
        this.isLoaded = true;
        handleExposureUpdation({
          records:this.objAccountRecord, includeExposureVal :this.selectedIncludeExposure
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
    
                this.dispatchEvent(new CustomEvent('exposurecredit', {
                    detail: this.objAccountRecord
                }));
               }
            
           
        })
        .catch(error => {
            this.isLoaded = false;
            console.log('result is ' + JSON.stringify(error));
        })
    }
}