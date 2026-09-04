import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import opsAccordion from '@salesforce/resourceUrl/opsAccordion';
import getApplicationDetails from '@salesforce/apex/SummaryPageController.getApplicationDetails';
import getVisibleFields from '@salesforce/apex/SummaryPageController.getVisibleFields';
import getPricingDetails from '@salesforce/apex/SummaryPageController.getPricingDetails';
import getApprovalDetails from '@salesforce/apex/SummaryPageController.getApprovalDetails';
import { getRecordNotifyChange } from "lightning/uiRecordApi";
import { registerRefreshContainer, unregisterRefreshContainer } from 'lightning/refresh';
import { getRecord } from 'lightning/uiRecordApi'; //1780,82
const FIELDS = ['Loan_Application__c.Product__c'];//1780,82





export default class Ausf_DDE_PSD_QDESummaryPageNew extends LightningElement {
    @api applicationId ='';
    @api stageName = '';
    @track applicationDealSummaryWrapper = {};
    @track pricingWrapper = {};
    @track approvalWrapper={'creditApproverLevel':'','creditApproverName':'','pricingApproverLevel':'','pricingApproverName':''};
    @track tractorList = ['10501','10502','10503','10104','10105','10106','10101','10102','10103','10204','10205','10206','10401','10402','10403'];//1780,82
    activeSections = ['A', 'B', 'C','D','E', 'F'];
    refreshContainerID;
    product;//1780,82
    isTractorCommercial = false;//1780,82

    loadStyles() {
        loadStyle(this, opsAccordion);
    }
    
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

    // NOTE : Renderedcallback() only works for child components to parent DOM
    renderedCallback(){
        console.log('inside renderCallback');
        this.loadStyles();
    }

    handleSectionToggle(event) {
        console.log('Open Sections**'+event.detail.openSections);
    }

    connectedCallback(){
        // Refresh LDS cache and wires
        let changeIds = [];
        changeIds.push(this.applicationId);
        //this.refreshContainerID = registerRefreshContainer(this, this.refreshContainer);
        getRecordNotifyChange(changeIds);
        this.getVisibleFieldsData('Summary Page');
        this.getVisibleFieldsData('Summary Page Pricing');
        this.getVisibleFieldsData('Summary Page Approval');
    }

    disconnectedCallback() {
        unregisterRefreshContainer(this.refreshContainerID);
    }

    refreshContainer(refreshPromise) {
        console.log('refreshing');
        return refreshPromise.then((status) => {
            if (status === REFRESH_COMPLETE) {
                alert('refresehed')
                console.log('Done!');
            }
            else if (status === REFRESH_COMPLETE_WITH_ERRORS) {
               console.warn('Done, with issues refreshing some components');
            }
            else if (status === REFRESH_ERROR) {
               console.error('Major error with refresh.');
            }
         });
    }

    getVisibleFieldsData(screenName) {
        this.isLoading = true;
        getVisibleFields({
            strScreen :screenName, strStage :this.stageName, strProfile :''
        })
        .then(res=>{
            console.log('result is '+JSON.stringify(res));
            res.forEach(input => {
                if(this.template.querySelector('[data-id="'+input+'"]') != null){
                    //alert('here find '+input)
                    this.template.querySelector('[data-id="'+input+'"]').classList.remove('slds-hide');
                }
            });
            if(screenName == 'Summary Page'){
                this.getApplicationDetails();
            }
            else if(screenName == 'Summary Page Pricing'){
                this.setPricingWrapper();

            }
            else if(screenName == 'Summary Page Approval'){
                this.getApprovalRecords();
            }
            
        })
    }

    getApplicationDetails() {
        getApplicationDetails({
            applicationId : this.applicationId
        })
        .then(res=>{
            this.applicationDealSummaryWrapper = res;
            this.isLoading = false;
        })
        .catch(err=>{
            this.isLoading = false;
            console.log('err '+JSON.stringify(err));
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
        this.approvalWrapper = dataObject;
        
        let objArray = Object.entries(dataObject);
        let objMap = new Map(objArray);
        objMap.forEach((value, key)=>{
            if(key == 'creditApprover') {
                this.approvalWrapper.creditApproverLevel = value.reduce((accumulator, item) => (accumulator + item.approverLevel), '');
                this.approvalWrapper.creditApproverName = value.reduce((accumulator, item) => (accumulator + item.approverName), '');
            }
            else if(key == 'pricingApprover') {
                this.approvalWrapper.pricingApproverLevel = value.reduce((accumulator, item) => (accumulator + item.approverLevel), '');
                this.approvalWrapper.pricingApproverName = value.reduce((accumulator, item) => (accumulator + item.approverName), '');
            }
        })


    }

}