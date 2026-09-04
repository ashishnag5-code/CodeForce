import { LightningElement, wire, track, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import PRODUCT_FIELD from '@salesforce/schema/Loan_Application__c.Product__c';
import LOAN_AMOUNT_FIELD from '@salesforce/schema/Loan_Application__c.Loan_Amount__c';
import TENURE_FIELD from '@salesforce/schema/Loan_Application__c.Tenure__c';
import ROI_FIELD from '@salesforce/schema/Loan_Application__c.ROI__c';
import EMI_FIELD from '@salesforce/schema/Loan_Application__c.EMI__c';
import NAME_FIELD from '@salesforce/schema/Loan_Application__c.Name';
import ID_FIELD from '@salesforce/schema/Loan_Application__c.Id';

export default class LoanDetailsLightningCard extends LightningElement {

    @track loanApp;
    @track Loan_Amount__c;
    @track Product__c;
    @track Tenure__c;
    @track Id;
    @track Name;
    @track ROI__c;
    @track EMI__c;
    @track Promo_Code__c;
    @api recordId;
    editLoan = false;
    flowName;
    childToFlow;
    boolReFetchData;

    /*connectedCallback(){
        this.getDetails();
    }

    getDetails(){
        getLoanDetails({recordId: this.recordId}).then((data)=>{
            this.loanApp = data;
            this.Loan_Amount__c = this.loanApp.Loan_Amount__c;
            this.Tenure__c = this.loanApp.Tenure__c;
            this.Product__c = this.loanApp.Product__c;
            this.Name = this.loanApp.Name;
            this.Id = this.loanApp.Id;
            this.EMI__c = this.loanApp.EMI__c;
            this.ROI__c = this.loanApp.ROI__c;
            this.Promo_Code__c = this.loanApp.Promo_Code__c;

            if(this.EMI__c){
                this.editLoan = false;
            }
            else{
                this.editLoan = true;
            }

        }).catch((error)=>{
            console.log(error);
        })
    }

    handleDetailSavedEvent(event){
        if(event.detail){
            this.editLoan = false;
        }
        this.getDetails();
    }*/
    
    handleRowAction(event) {
        this.editLoan = true;
        this.dispatchEvent(new CustomEvent('wizardevent', {
            detail:{value:'',name:'LoanDetails' ,mode:''}
        }));
        //this.flowName = 'Parent_Flow_QDE';
        //this.childToFlow = 'Parent_Flow_QDE_Edit_LoanDetails';
        //this.boolReFetchData = true;

    }

    @api nextHandler() {
        const Obj = {};
        this.errorOnChild = '';
        //Obj.applicantRecord = this.applicantIdInput;
        Obj.errorOnChild = this.errorOnChild;
        Obj.next = this.errorOnChild == '' ? true : false;
        console.log('Obj', Obj);
        this.dispatchEvent(new CustomEvent('next', {
            detail: Obj
        }));
    }
}