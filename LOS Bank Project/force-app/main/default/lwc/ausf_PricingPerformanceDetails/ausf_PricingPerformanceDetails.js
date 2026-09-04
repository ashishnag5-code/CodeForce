import { api,LightningElement, track } from 'lwc';
import getPricingPerformanceDetails from '@salesforce/apex/PricingSummaryPageController.getPricingPerformanceDetails';


export default class Ausf_PricingPerformanceDetails extends LightningElement {
    @api  applicationId = '';
    @track performanceDetailsWrapper = {};
    @track wirrData = {};
    connectedCallback() {
        this.setPerformanceWrapper();
    }

    setPerformanceWrapper(){
        getPricingPerformanceDetails({
            applicationId : this.applicationId
        })
        .then(res=>{
            console.log('yash '+JSON.stringify(res));
            this.performanceDetailsWrapper = res
            this.wirrData = res.performanceObjectDetails;

        })
        .catch(err=>{
            console.log('err '+JSON.stringify(err));
        })

    }
}