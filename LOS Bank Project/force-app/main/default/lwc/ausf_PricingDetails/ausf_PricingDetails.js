import {api,LightningElement,track } from 'lwc';
import getVisibleFields from '@salesforce/apex/SummaryPageController.getVisibleFields';
import getPricingDetails from '@salesforce/apex/SummaryPageController.getPricingDetails';



export default class Ausf_PricingDetails extends LightningElement {
    @api applicationId='';
    @api screenName ='';
    @api stageName = '';
    @track pricingWrapper = {};
    connectedCallback() {
        this.getVisibleFieldsData();
        this.setPricingWrapper();
    }

    getVisibleFieldsData() {
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
            
        })
    }

    setPricingWrapper(){
        getPricingDetails({
            applicationId : this.applicationId
        })
        .then(res=>{
            //console.log('pricing wrapper '+JSON.stringify(res));
            this.pricingWrapper = res;
            //t//his.getVisibleFieldsData();
        })
        .catch(err=>{
            console.log('err '+JSON.stringify(err));
        })
    }


}