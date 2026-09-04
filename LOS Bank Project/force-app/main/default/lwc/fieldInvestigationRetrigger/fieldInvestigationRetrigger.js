import { LightningElement, api, wire, track } from 'lwc';
import fetchRelatedApplicantAddress from '@salesforce/apex/CreateFieldInvestigatiionRecord.fetchRelatedApplicantAddress';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import Loan_Application from "@salesforce/schema/Field_Investigation__c.Loan_Application__c";
import Proposed_Vehicle from "@salesforce/schema/Field_Investigation__c.Proposed_vehicle__c";
import getUserAssignedPermissions from '@salesforce/apex/CreateFieldInvestigatiionRecord.getUserAssignedPermissions';
import { NavigationMixin } from 'lightning/navigation';


const fields = [Loan_Application,Proposed_Vehicle];

export default class FieldInvestigationRetrigger extends NavigationMixin(LightningElement) {
    @api recordId;
    @api objectApiName;
    @api isRetriggerPermission
    @api isReassignPermission
    @track isRenderPermissionSetCOmplete = false;
    loanApplication;
    @track openModal = false;
    @api applicationStage = '';
    @track restrictedApplicationStages = ['Ops Maker','Ops Author','PDD','Rejected'];

    connectedCallback(){
        this.getUserAssignedPermissions()
    }
    getUserAssignedPermissions(){
        getUserAssignedPermissions({})
        .then(res=>{ 
            this.isRetriggerPermission = res.isRetriggerPermission;
            this.isReassignPermission = res.isReassignPermission;
            this.isRenderPermissionSetCOmplete = true;    
        })
        .catch(err=>{
            console.log('err'+JSON.stringify(err));
    
        })
    }

    
    @wire(getRecord, {
        recordId: "$recordId",
        fields
    })
    wiredRecord({ error, data }) {
        if (data) {
            console.log('Data>>>' + JSON.stringify(data));
            this.loanApplication = data.fields.Loan_Application__c.value;
            
        }
    }

    get isFi(){
        return this.objectApiName == 'Field_Investigation__c'?true:false;
    }

    openRetriggerModal(){
        this.openModal = true;
    }

    closeRetriggerModal(){
        this.openModal = false;
    }

    handleReTrigger() {
        if(this.restrictedApplicationStages.includes(this.applicationStage)){
            this.template.querySelector('c-common-toast').showToast('Error', '<strong>' + 'You cannot retrigger the FI when Application is in '+this.applicationStage + 'stage. <strong/>', 'utility:Error', 10000);
            return;
        }
        if (this.objectApiName == 'Field_Investigation__c')
            fetchRelatedApplicantAddress({ recordId: this.loanApplication, blnRetriggerFI: true, lstFiIds: this.recordId })
                .then(result => {
                    console.log('result$$' + JSON.stringify(result));
                    this.template.querySelector('c-common-toast').showToast('success', '<strong>Success<strong/>', 'utility:success', 10000);
                    this.navigateToActionPage();
                })
                .catch(error => {
                    console.log('this.error>>>>>' + JSON.stringify(error));
                    this.template.querySelector('c-common-toast').showToast('Error', '<strong>' + error + '<strong/>', 'utility:Error', 10000);

                });
    }

    navigateToActionPage(){
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'My_Actions'
            },
        });

    }
    
}