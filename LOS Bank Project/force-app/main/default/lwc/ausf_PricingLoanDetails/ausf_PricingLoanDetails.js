import { api,LightningElement, track } from 'lwc';
import getPricingLoanDetails from '@salesforce/apex/PricingSummaryPageController.getPricingLoanDetails';


export default class Ausf_PricingLoanDetails extends LightningElement {
    @api applicationId = '';
    @track loanDetailsWrapper = {};
    connectedCallback() {
        this.setPricingDetailsWrapper();
    }

    setPricingDetailsWrapper(){

        getPricingLoanDetails ({
            applicationId : this.applicationId
        })
        .then(res=>{
            console.log('res '+JSON.stringify(res));
            if(res) {
                this.loanDetailsWrapper = res;
            }
        })
        .catch(err=>{
            console.log('err '+JSON.stringify(err));
        })

    }
    

    
}