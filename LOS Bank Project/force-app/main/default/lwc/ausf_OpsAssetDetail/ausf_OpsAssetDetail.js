import { api,track,LightningElement } from 'lwc';
import getOpsAssetDetails from '@salesforce/apex/OpsSummaryPageController.getOpsAssetDetails';

export default class Ausf_OpsAssetDetail extends LightningElement {
    @api  applicationId = '';
    @track opsAssetWrapper = {};
    connectedCallback() {
        this.setOpsCategoryWrapper();
    }

    setOpsCategoryWrapper(){
        getOpsAssetDetails({
            applicationId : this.applicationId
        })
        .then(res=>{
            console.log('yash '+JSON.stringify(res));
            this.opsAssetWrapper = res

        })
        .catch(err=>{
            console.log('err '+JSON.stringify(err));
        })

    }
}