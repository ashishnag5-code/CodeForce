import { LightningElement, wire, api } from 'lwc';
import LOAN_RECORD_TYPE_NAME from '@salesforce/schema/Loan_Application__c.RecordType.Name';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { reduceErrors } from 'c/lwcutilities';
export default class AusfVehicleListCommercial extends LightningElement {
    @api recordId;
    loanApplication = {};

    @wire( getRecord, { recordId: '$recordId', fields: [ LOAN_RECORD_TYPE_NAME ] } )
    wiredLoanApplication({ data, error }) {
        if (data) {
            this.loanApplication = data;
        } else {
            this.error = reduceErrors(error)?.join(',');
        }
    }

    get isCommercialVehicle(){
        return getFieldValue( this.loanApplication, LOAN_RECORD_TYPE_NAME ) === 'Commercial Vehicle';
    }

    get isConstructionEquipment(){
        return getFieldValue( this.loanApplication, LOAN_RECORD_TYPE_NAME ) === 'Construction Equipment';
    }

    @api nextHandler() {
        let vehicleRecord = this.applicantLst;
        this.errorOnChild = vehicleRecord.length > 0 ? '' : 'Please create vehicle record';
        const Obj = {};
        //this.errorOnChild = '';
        //Obj.applicantRecord = this.applicantIdInput;
        Obj.errorOnChild = this.errorOnChild;
        Obj.next = this.errorOnChild === '' ? true : false;
        if (Obj.next === false) {
            this.showToast(this.errorOnChild, 'error');
        }
        console.log('Obj', Obj);
        this.dispatchEvent(new CustomEvent('next', {
            detail: Obj
        }));
    }
     handleSave(event){
        console.log('incommercial');
        const Obj = {};
        this.dispatchEvent(new CustomEvent('newsave', {
            detail: event.detail
        }));
    }
}