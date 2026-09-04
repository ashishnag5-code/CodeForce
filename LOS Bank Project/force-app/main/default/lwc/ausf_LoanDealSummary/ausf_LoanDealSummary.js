import { api, LightningElement, track } from 'lwc';
import getApplicationDetails from '@salesforce/apex/SummaryPageController.getApplicationDetails';
import getVisibleFields from '@salesforce/apex/SummaryPageController.getVisibleFields';
import { getSpinnerImage } from 'c/customSpinner';



export default class Ausf_LoanDealSummary extends LightningElement {
    @api applicationId ='';
    @api screenName ='';
    @api stageName = '';
    @track applicationDealSummaryWrapper = {};
    @track isLoading = false;

    async spinnerImageMethod() {
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.applicationId);
        }
        console.log('spinner Image '+this.spinnerImage)
    }

    connectedCallback() {
        this.getVisibleFieldsData();
        this.spinnerImageMethod()
    }

    viewMoreHandler(evt){
       return;
    }

    getVisibleFieldsData() {
        this.isLoading = true;
        getVisibleFields({
            strScreen :this.screenName, strStage :this.stageName, strProfile :''
        })
        .then(res=>{
            console.log('result is '+JSON.stringify(res));
            res.forEach(input => {
                if(this.template.querySelector('[data-id="'+input+'"]') != null){
                    //alert('here find '+input)
                    this.template.querySelector('[data-id="'+input+'"]').classList.remove('slds-hide');
                }
            });
            this.getApplicationDetails();
        })
    }

    getApplicationDetails() {
        getApplicationDetails({
            applicationId : this.applicationId
        })
        .then(res=>{
            this.applicationDealSummaryWrapper = res;
            this.isLoading = false;
        })
        .catch(err=>{
            this.isLoading = false;
            console.log('err '+JSON.stringify(err));
        })
    }



}