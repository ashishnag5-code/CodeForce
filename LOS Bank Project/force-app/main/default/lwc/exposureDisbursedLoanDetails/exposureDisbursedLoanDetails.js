import { LightningElement,api } from 'lwc';
import getVisibleFields from '@salesforce/apex/exposureDetailsController.getVisibleFields';
import handleDisbursedExposureUpdation from '@salesforce/apex/exposureDetailsController.handleDisbursedExposureUpdation';
export default class ExposureDisbursedLoanDetails extends LightningElement {
    @api objAccountRecord;
    @api objApplicantRecord;
    @api loanStage;

    selectedIncludeExposure='';
    
    isLoaded = false;
    creditOverride = false;

    exposureOptions=[];

    loanNumber;
    customerName;
    product;
    sanctiondate;
    loanAmount

    connectedCallback() {
       console.log('objAccountRecord-->' +JSON.stringify(this.objAccountRecord));
       // this.getVisibleFieldsMetadata(this.objAccountRecord.Loan__r.Stage__c);
       this.getVisibleFieldsMetadata(this.loanStage);
        this.assignOptions();
    }
   /* assignOptions() {
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
        this.creditOverride = (this.objApplicantRecord.creditAuthority!=null)? this.objAccountRecord.creditAuthority : false;
        
        let parsedJSON = JSON.parse(this.objAccountRecord.SF_Exposure_JSON__c);
        let includeInExposure = parsedJSON[0].includeInExposure;
        let creditOverride  = parsedJSON[0].creditOverrideAuthority;
        console.log('includeInExposure-->' +includeInExposure);// this.objApplicantRecord.includeExposure
        if(includeInExposure!=null){
            this.includeExposure = includeInExposure;
        }else{
            this.includeExposure = 'Yes';
        }
        this.creditOverride = (creditOverride!=null )? creditOverride : false;
    }*/
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
        this.creditOverride = (this.objApplicantRecord.creditAuthority!=null)? this.objAccountRecord.creditAuthority : false;
       
        let parsedJSON;
        let includeInExposure;
        if(this.objAccountRecord.SF_Exposure_JSON__c!=null){
            parsedJSON = JSON.parse(this.objAccountRecord.SF_Exposure_JSON__c);
            if(parsedJSON!=undefined &&  parsedJSON[0].includeInExposure !=undefined){
                includeInExposure = parsedJSON[0].includeInExposure;
            } 
            console.log('includeInExposure-->' +includeInExposure);// this.objApplicantRecord.includeExposure 
            let creditOverride  = (parsedJSON[0].creditOverrideAuthority!=undefined) ? parsedJSON[0].creditOverrideAuthority : null ;
            this.creditOverride = (creditOverride!=null) ? !creditOverride : '';
           // this.creditOverride = (creditOverride!=null )? creditOverride : false;
           this.loanNumber = (parsedJSON[0].applicationNumber!=undefined) ? parsedJSON[0].applicationNumber : null ;
           this.customerName = (parsedJSON[0].customerName!=undefined) ? parsedJSON[0].customerName : null ;
           this.product = (parsedJSON[0].Product!=undefined) ? parsedJSON[0].Product : null ;
           this.sanctiondate = (parsedJSON[0].SanctionDate!=undefined) ? parsedJSON[0].SanctionDate : null ;
           this.loanAmount = (parsedJSON[0].LoanAmount!=undefined) ? parsedJSON[0].LoanAmount : null ;

        }
        
        
       
        if(includeInExposure!=null){
            this.includeExposure = includeInExposure;
        }else{
            this.includeExposure = 'Yes';
        }
       
    }


    getVisibleFieldsMetadata(stageVal) {
        this.isLoaded = true;
        var screenName='';
        if(stageVal == 'DDE'){
            screenName ='DDE Exposure ExisLoan';
        }else if(stageVal =='Credit'){
            screenName='Credit Exposure ExisLoan';
        }
        getVisibleFields({
                strScreen: screenName,
                Stage: stageVal
            })
            .then(result => {
                console.log('resultinExisLoan=>' +JSON.stringify(result));
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
        handleDisbursedExposureUpdation({
            applicantRecords:this.objAccountRecord ,includeExposureVal: this.selectedIncludeExposure ,strLoanId : this.objApplicantRecord.loanId
        })
        .then(result => {
           if(result){
            console.log('calculatedResult-->' +JSON.stringify(result));
            this.isLoaded = false;
            var resultVal = result;
           this.dispatchEvent(new CustomEvent('disbursedcalculated', {
                //detail: this.objAccountRecord
                detail: resultVal
            }));
         }
            
           
        })
        .catch(error => {
            this.isLoaded = false;
            console.log('result is ' + JSON.stringify(error));
        })
    }
}