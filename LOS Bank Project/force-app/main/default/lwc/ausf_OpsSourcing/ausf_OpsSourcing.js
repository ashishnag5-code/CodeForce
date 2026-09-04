import { LightningElement,api,track } from 'lwc';
import getOpsSourcingDetails from '@salesforce/apex/OpsSummaryPageController.getOpsSourcingDetails';


export default class Ausf_OpsSourcing extends LightningElement {
    @api  applicationId = '';
    @track opsSourcingWrapper = {};
    @track renderDataObj={};
    connectedCallback() {
        this.setOpsCategoryWrapper();
    }

    setOpsCategoryWrapper(){
        getOpsSourcingDetails({
            applicationId : this.applicationId
        })
        .then(res=>{
            //console.log('tt '+JSON.stringify(res));
            this.opsSourcingWrapper = res
            for(var obj in res){
                //console.log('yash '+res[obj]);
                if(res[obj]!=' '&& res[obj]!=''){
                    this.renderDataObj[obj]=true;
                }
                else{
                    this.renderDataObj[obj] = false;
                }
            }
            //console.log('render data '+JSON.stringify(this.renderDataObj));

        })
        .catch(err=>{
            console.log('err '+JSON.stringify(err));
        })

    }
}