import { api,LightningElement, track } from 'lwc';
import getPricingApplicantDetails from '@salesforce/apex/PricingSummaryPageController.getPricingApplicantDetails';


export default class Ausf_PricingApplicantDetails extends LightningElement {
    @api  applicationId = '';
    @track applicantWrapper = {};
    connectedCallback() {
        this.setApplicantWrapperData();
    }

    setApplicantWrapperData(){
        getPricingApplicantDetails({
            applicationId : this.applicationId
        })
        .then(res=>{
            console.log('yash '+JSON.stringify(res));
            this.applicantWrapper = res

        })
        .catch(err=>{
            console.log('err '+JSON.stringify(err));
        })

    }


}