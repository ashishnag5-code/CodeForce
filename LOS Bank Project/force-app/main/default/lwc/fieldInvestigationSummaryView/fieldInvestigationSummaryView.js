import { LightningElement,track,api } from 'lwc';
import fiSummaryView from '@salesforce/apex/FISummaryViewController.fiSummaryView';
import fiSummaryViewLabel from '@salesforce/label/c.Fi_Summary_View_Label';


export default class FieldInvestigationSummaryView extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track fiSummaryViewLabel=fiSummaryViewLabel;
    @track showMessage ='No Records available';
    @track columns = [{
        label: 'Applicant Type',
        fieldName: 'entity',
        type: 'text'
    },
    {
        label: 'Applicant Name',
        fieldName: 'partyName',
        type: 'text'    
    },
    {
        label: 'Current Address',
        fieldName: 'currentAddress',
        type: 'text',
        
    },
    {
        label: 'Permanent Address',
        fieldName: 'permanentAddress',
        type: 'text'
    },
    {
        label: 'Office Address',
        fieldName: 'officeAddress',
        type: 'text'
    },
    {
        label: 'Touch Point Address',
        fieldName: 'tpAddress',
        type: 'text'
    },
    {
        label: 'Final Status',
        fieldName: 'finalStatus',
        type: 'text'
    }
];
@track fiList ;
@track checkForNullValues;
connectedCallback(){
    if(this.objectApiName == 'Loan_Application__c'){
        fiSummaryView({loanApplicationId:this.recordId})
        .then(result => {
            if (result != null && result.length>0) {
                this.fiList = result;
                this.checkForNullValues=false;
                console.log('this.result>>>>>++' + JSON.stringify(result));
            }
            else{
                this.checkForNullValues=true;
            }
        })
        .catch(error => {
            console.log('this.error>>>>>' + JSON.stringify(this.error));
    
            this.error = error;
        });
    }
    else{
        fiSummaryView({applicantId:this.recordId})
        .then(result => {
            if (result != null && result.length>0) {
                this.fiList = result;
                this.checkForNullValues=false;
                console.log('this.result>>>>>++' + JSON.stringify(result));
            }
            else{
                this.checkForNullValues=true;
            }
        })
        .catch(error => {
            console.log('this.error>>>>>' + JSON.stringify(this.error));
    
            this.error = error;
        });
    }
    
}
}