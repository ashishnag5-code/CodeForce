import { LightningElement, api, track } from 'lwc';
import getVehicleDetails from '@salesforce/apex/PricingSummaryPageController.getPricingVehicleDetails';


export default class Ausf_PricingVehicleDetails extends LightningElement {
    @api applicationId=''
    @track vehicleWrapper = {}
    connectedCallback() {
        this.setVehicleWrapperData();
    }

    setVehicleWrapperData() {
        getVehicleDetails({
            applicationId : this.applicationId
        })
        .then(res=>{
            if(res) {
                this.vehicleWrapper = res;
            }

        })
        .catch(err=>{
            console.log('err');
        })
    }
}