import { api,track,LightningElement } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getAssignmentRecordLoanId from '@salesforce/apex/OpsSummaryPageController.getAssignmentRecordLoanId';




const fields = ['Assignment__c.Loan_Application__c']
export default class Ausf_LoanOPSSummary extends LightningElement {
    @api recordId;
    @track applicationId = '';
    @api objectApiName;
    @track loadCOmponent = false;
    @track isRenderFromAssignment = false;
    @track verificationObject = {};

    connectedCallback() {
        if(this.objectApiName == 'Assignment__c') {
            this.getAssignmentRecordLoanId();
        }
        else{
            this.applicationId = this.recordId;
            this.loadCOmponent = true;
            this.isRenderFromAssignment = false;
        }
          
    }

    

    getAssignmentRecordLoanId() {
        getAssignmentRecordLoanId({
            assignmentId: this.recordId,
        })
        .then(res=>{
            if(res || res!=''){
                this.applicationId = res;
                this.loadCOmponent = true;
                this.isRenderFromAssignment = true;
                
            }
            else{
                //alert('Proceed with a Loan Application Record')
            }
        })
        .catch(err=>{
            console.log('yash err '+JSON.stringify(err));
        })
    }

    
}