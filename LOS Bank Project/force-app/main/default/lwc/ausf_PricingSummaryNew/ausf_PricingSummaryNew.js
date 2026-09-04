import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import opsAccordion from '@salesforce/resourceUrl/opsAccordion';
import getPricingApplicantDetails from '@salesforce/apex/PricingSummaryPageController.getPricingApplicantDetails';
import getVehicleDetails from '@salesforce/apex/PricingSummaryPageController.getPricingVehicleDetails';
import getPricingLoanDetails from '@salesforce/apex/PricingSummaryPageController.getPricingLoanDetails';
import getPricingSourcingDetails from '@salesforce/apex/PricingSummaryPageController.getPricingSourcingDetails';
import getPricingPerformanceDetails from '@salesforce/apex/PricingSummaryPageController.getPricingPerformanceDetails';
import getApprovalDetails from '@salesforce/apex/SummaryPageController.getApprovalDetails';//1780,82
import { getRecord } from 'lightning/uiRecordApi'; //1780,82
const FIELDS = ['Loan_Application__c.Product__c'];//1780,82






export default class Ausf_PricingSummaryNew extends LightningElement {
    activeSections = ['A', 'B', 'C','D','E','F'];

    @api applicationId='';
    @track applicantWrapper = {};
    @track vehicleWrapper = {};
    @track loanDetailsWrapper = {};
    @track sourceDetailsWrappr = {};
    @track performanceDetailsWrapper = {};
    @track wirrData = {};
    @track pricingWrapper = {};
    @track approvalWrapper={'creditApproverLevel':'','creditApproverName':'','pricingApproverLevel':'','pricingApproverName':''};
    @track tractorList = ['10501','10502','10503','10104','10105','10106','10101','10102','10103','10204','10205','10206','10401','10402','10403'];//1780,82
    product;//1780,82
    isTractorCommercial = false;//1780,82



    loadStyles() {
        loadStyle(this, opsAccordion);
    }
    showCibilReport = false;

    //1780,82
    @wire(getRecord, { recordId: '$applicationId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            this.product = data.fields.Product__c.value;
            console.log('@@product'+this.product);
            if(this.tractorList.includes(this.product)){
                this.isTractorCommercial = true;
            }
        }
    }

    handleBackFromCibil(evt){
        this.showCibilReport = false;
    }

    handleClick(evt){
        evt.preventDefault();
        this.showCibilReport = true;
    }

    // NOTE : Renderedcallback() only works for child components to parent DOM
    renderedCallback(){
        console.log('inside renderCallback');
        this.loadStyles();
    }

    handleSectionToggle(event) {
        console.log('Open Sections**'+event.detail.openSections);
    }

    connectedCallback() {
        this.setApplicantWrapperData();
        this.setVehicleWrapperData();
        this.setPricingDetailsWrapper();
        this.setSourceDetailsWrapper();
        this.setPerformanceWrapper();
        this.getApprovalRecords();
    }

    setApplicantWrapperData(){
        getPricingApplicantDetails({
            applicationId : this.applicationId
        })
        .then(res=>{
            console.log('yash '+JSON.stringify(res));
            this.applicantWrapper = res

        })
        .catch(err=>{
            console.log('err '+JSON.stringify(err));
        })

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

    setPricingDetailsWrapper(){

        getPricingLoanDetails ({
            applicationId : this.applicationId
        })
        .then(res=>{
            console.log('res pricing'+JSON.stringify(res));
            if(res) {
                this.loanDetailsWrapper = res;
            }
        })
        .catch(err=>{
            console.log('err '+JSON.stringify(err));
        })

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

    setPerformanceWrapper(){
        getPricingPerformanceDetails({
            applicationId : this.applicationId
        })
        .then(res=>{
            console.log('yash '+JSON.stringify(res));
            this.pricingWrapper = res
            //this.wirrData = res.performanceObjectDetails;

        })
        .catch(err=>{
            console.log('err '+JSON.stringify(err));
        })

    }

    //1780,82
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

    //1780,82
    setApprobalDetailsWrapper(dataObject) {
        this.approvalWrapper = dataObject;
    }
}