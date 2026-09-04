import { api,track,LightningElement, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import opsAccordion from '@salesforce/resourceUrl/opsAccordion';
import getOpsCategoryDetails from '@salesforce/apex/OpsSummaryPageController.getOpsCategoryDetails';
import getOpsAssetDetails from '@salesforce/apex/OpsSummaryPageController.getOpsAssetDetails';
import getOpsSourcingDetails from '@salesforce/apex/OpsSummaryPageController.getOpsSourcingDetails';
import { NavigationMixin } from 'lightning/navigation';
import verifyRecordSection from '@salesforce/apex/OpsSummaryPageController.verifyRecordSection';
import setVerificationWrapper from '@salesforce/apex/OpsSummaryPageController.setVerificationWrapper';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi'; //1780,82
const FIELDS = ['Loan_Application__c.Product__c'];//1780,82



export default class Ausf_OpsCaseCategory extends NavigationMixin(LightningElement) {
    activeSections = ['A', 'B', 'C'];
    @api applicationId = '';
    @api renderFromAssignmentRec = false;
    @track renderDataObj={};
    @track renderOpsSourDetObj={};
    @track opsCategoryWrapper = {};
    @track opsAssetWrapper = {};
    @track opsSourcingWrapper = {};
    @track tractorList = ['10501','10502','10503','10104','10105','10106','10101','10102','10103','10204','10205','10206','10401','10402','10403']; //1780,82
    @api objectApiName;
    @api verificationobject = {}
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

    setVerificationButtonWrapper(){
        setVerificationWrapper({
            recId : this.applicationId
        })
        .then(res=>{
            this.verificationObject = JSON.parse(res);
            //alert(this.verificationObject.isCaseSummaryVerified)

        })
        .catch(err=>{
            this.showErrorMessage(err.body.message,'error');
            console.log('err '+JSON.stringify(err));

        })
    }

    handleVerifyClick(evt){
        console.log('sectionName'+evt.currentTarget.dataset.id)
        if(this.verificationObject[evt.currentTarget.dataset.id]){
            this.showErrorMessage('Ops Section already verified','error');
            return;
        }
        this.verificationObject[evt.currentTarget.dataset.id]=true;
        verifyRecordSection({
            sectionName : evt.currentTarget.dataset.id,
            recordId : this.applicationId
        })
        .then(res=>{
        })
        .catch(err=>{
            this.showErrorMessage(err.body.message,'error');
        })
    }

    connectedCallback() {
        this.setOpscategoryWrapper();
        this.setVerificationButtonWrapper()
    }

    handleRedirectToLoanApplication(evt){   
        evt.preventDefault()

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.applicationId,
                actionName: 'view'
            },
        });

    }

    handleSectionToggle(event) {
        console.log('Open Sections**'+event.detail.openSections);
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

        getOpsSourcingDetails({
            applicationId : this.applicationId
        })
        .then(res=>{
            console.log('tt '+JSON.stringify(res));
            this.opsSourcingWrapper = res
            for(var obj in res){
                //console.log('yash '+res[obj]);
                if(res[obj]!=' '&& res[obj]!=''){
                    this.renderOpsSourDetObj[obj]=true;
                }
                else{
                    this.renderOpsSourDetObj[obj] = false;
                }
            }
            //console.log('render data '+JSON.stringify(this.renderDataObj));

        })
        .catch(err=>{
            console.log('err '+JSON.stringify(err));
        })

    }

    showErrorMessage(message, variant) {
        const event = new ShowToastEvent({
            title: '',
            variant: variant,
            mode: 'dismissible',
            message: message
        });
        this.dispatchEvent(event);
    }
}