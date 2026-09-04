import { api,track,LightningElement } from 'lwc';
import getOpsCategoryDetails from '@salesforce/apex/OpsSummaryPageController.getOpsCategoryDetails';


export default class Ausf_OpsCaseCategory extends LightningElement {
    @api  applicationId = '';
    @api renderFromAssignmentRec = false;
    @track renderDataObj={};
    @track opsCategoryWrapper = {};
    connectedCallback() {
        this.setOpscategoryWrapper();
    }

    setOpscategoryWrapper(){
        getOpsCategoryDetails({
            applicationId : this.applicationId
        })
        .then(res=>{
            //console.log('yash '+JSON.stringify(res));
            this.opsCategoryWrapper = res
            for(var obj in res){
                //console.log('yash '+res[obj]);
                if(res[obj]!=' '&& res[obj]!=''){
                    this.renderDataObj[obj]=true;
                }
                else{
                    this.renderDataObj[obj] = false;
                }
            }

        })
        .catch(err=>{
            console.log('err '+JSON.stringify(err));
        })

    }
}