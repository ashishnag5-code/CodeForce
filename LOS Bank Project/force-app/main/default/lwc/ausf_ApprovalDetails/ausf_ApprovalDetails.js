import { api,LightningElement, track } from 'lwc';
import getVisibleFields from '@salesforce/apex/SummaryPageController.getVisibleFields';
import getApprovalDetails from '@salesforce/apex/SummaryPageController.getApprovalDetails';



export default class Ausf_ApprovalDetails extends LightningElement {
    @api screenName ='';
    @api stageName = '';
    @track approvalWrapper={'creditApproverLevel':'','creditApproverName':'','pricingApproverLevel':'','pricingApproverName':''};
    @api applicationId='';
    connectedCallback() {
        this.getVisibleFieldsData();
        this.getApprovalRecords();
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

    getApprovalRecords() {
        getApprovalDetails({
            applicationId : this.applicationId

        })
        .then(res=>{
            if(res) {
                this.setApprobalDetailsWrapper(res);
            }
        })
        .catch(err=>{
            console.log('err '+JSON.stringify(err));
        })
    }

    setApprobalDetailsWrapper(dataObject) {
        let objArray = Object.entries(dataObject);
        let objMap = new Map(objArray);
        objMap.forEach((value, key)=>{
            if(key == 'creditApprover') {
                this.approvalWrapper.creditApproverLevel = value.approverLevel;
                this.approvalWrapper.creditApproverName = value.approverName;
            }
            else if(key == 'pricingApprover') {
                this.approvalWrapper.pricingApproverLevel = value.approverLevel;
                this.approvalWrapper.pricingApproverName = value.approverName;
            }
        })


    }





}