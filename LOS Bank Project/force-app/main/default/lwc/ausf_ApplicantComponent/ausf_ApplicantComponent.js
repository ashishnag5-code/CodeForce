import { api, LightningElement, track } from 'lwc';
import getApplicantDetails from '@salesforce/apex/SummaryPageController.getApplicantDetails';
import getVisibleFields from '@salesforce/apex/SummaryPageController.getVisibleFields';



export default class Ausf_ApplicantComponent extends LightningElement {

    @api applicationId='';
    @api isTractorCommercial; //1780,82
    @track applicantWrapper = [];
    @api screenName ='';
    @api stageName = '';
    @track renderData = {}
    @track renderedFields = [];

    connectedCallback() {
        this.setApplicantWrapper();
        this.getVisibleFieldsData();
        
    }

    getVisibleFieldsData() {
        getVisibleFields({
            strScreen :this.screenName, strStage :this.stageName, strProfile :''
        })
        .then(res=>{
            this.renderedFields = res;
            res.forEach(input=>{
                this.renderData[input]=true;
            })            
            
        })
        .catch(err=>{
            console.log('Error '+JSON.stringify(err));
        })
    }

    setApplicantWrapper() {
        getApplicantDetails({
            applicationId : this.applicationId
        })
        .then(res=>{
            this.applicantWrapper = res;
            //t//his.getVisibleFieldsData();
        })
        .catch(err=>{
            console.log('err '+JSON.stringify(err));
        })
    }


}