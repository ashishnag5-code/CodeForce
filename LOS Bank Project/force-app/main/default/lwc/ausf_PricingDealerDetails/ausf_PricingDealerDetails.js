import { api,LightningElement, track } from 'lwc';
import getPricingSourcingDetails from '@salesforce/apex/PricingSummaryPageController.getPricingSourcingDetails';

export default class Ausf_PricingDealerDetails extends LightningElement {
    @api  applicationId = '';
    @track sourceDetailsWrappr = {};
    connectedCallback() {
        this.setSourceDetailsWrapper();
    }

    setSourceDetailsWrapper(){
        getPricingSourcingDetails({
            applicationId : this.applicationId
        })
        .then(res=>{
            console.log('yash '+JSON.stringify(res));
            this.sourceDetailsWrappr = res

        })
        .catch(err=>{
            console.log('err '+JSON.stringify(err));
        })

    }
}