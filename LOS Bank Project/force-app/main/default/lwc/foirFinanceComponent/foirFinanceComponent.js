import { LightningElement,api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getVisibleFields from '@salesforce/apex/financeController.getVisibleFields';
import getAllApplicantsFoir from '@salesforce/apex/foirController.getAllApplicantsFoir';
import saveDetails from '@salesforce/apex/foirController.saveDetails';
// Sachin - SFAU-4273 - FOIR not getting recalculated after RTR manuals are added ( Refresh Issue )
import { APPLICATION_SCOPE, MessageContext, subscribe, unsubscribe, } from 'lightning/messageService';
import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';

export default class FoirFinanceComponent extends LightningElement {
    //API Attributes
    @api recordVal;

    //Decimal Attributes
    totalMonthlyIncome = 0;
    freemonthcash = 0;
    currentObj = 0;
    proposed = 0;
    consolidationObj = 0;
    totalLoanAmt = 0;
    foirperc = 0;
    activeSubSections = ['B'];
    custGrade = '';
    isCustGradeEditable = false;
    showCustGrade = false;
    gradeOptions = [];
    isTwoWheeler = false;
    isFourWheeler = false;
    totalVerifiedIncome=0
    @track customerGradeChanged=false
    @track isEditRestricted;

    // START -- Sachin - SFAU-4273 - FOIR not getting recalculated after RTR manuals are added ( Refresh Issue )
    subscription;

    @wire(MessageContext)
    messageContext;

    async connectedCallback() {
        this.subscribeToMessageChannel();
        this.initialize();
        this.isEditRestricted = await restricAccess({compName: 'financialView' ,loanId: this.recordVal}) //4733
    }
    disconnectedCallback(){
        this.unsubscribeToMessageChannel();
    }

    initialize(){
        this.getVisibleFieldsMetadata();
        this.getApplicantDetails();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                pageRefreshOnMaterialFieldChange,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    handleMessage(message){
        console.log(' === lightning message ==', message);
        if(message.refreshPage === 'Yes'){
          this.getApplicantDetails();
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    // END -- Sachin - SFAU-4273 - FOIR not getting recalculated after RTR manuals are added ( Refresh Issue )


    getVisibleFieldsMetadata() {
        getVisibleFields({
                strScreen: 'FOIR',
                Stage: 'QDE'
        })
        .then(result => {
            console.log('result is ' + JSON.stringify(result));
            let timeout = setTimeout(() => { 
                result.forEach(input => {
                    if(this.template.querySelector('[data-id="' + input + '"]')){
                        this.template.querySelector('[data-id="' + input + '"]').classList.remove('slds-hide');
                    }
                });
            },50);
            
        })
        .catch(error => {
            console.error(JSON.stringify(error));
        })
    }

    getApplicantDetails() {
        let loanRecordId = this.recordVal;
        this.handleApplicantsFoir(loanRecordId);
    }

    handleApplicantsFoir(loanRecordId){
        console.log('loanRecordId - '+loanRecordId);
        getAllApplicantsFoir({
            loanId: loanRecordId
        })
        .then(data => {
            if (data) {
                console.log('foirData-->' + JSON.stringify(data));
                this.totalMonthlyIncome = data.totalMonthlyIncome;
                this.currentObj = data.currentObligation;
                this.freemonthcash = data.freeMonthlyCashflow;
                this.consolidationObj = data.consolidationObligation;
                this.proposed = data.proposedEMI;
                this.totalLoanAmt = data.totalLoanAmount;
                this.foirperc = data.foirPercentage;
                this.custGrade = data.custGrade;
                this.isCustGradeEditable = data.isCustGradeEditable;
                this.showCustGrade = data.showCustGrade;
                this.isTwoWheeler = data.isTwoWheeler;
                this.isFourWheeler = data.isFourWheeler;
                this.totalVerifiedIncome = data.totalVerifiedIncome;
                this.handleCustomerGradeOptions();
            }
        })
        .catch(error => {
            console.error(JSON.stringify(error));
        })
    }

    @api
    getDetails(loanRecordId){
        this.handleApplicantsFoir(loanRecordId);
    }

    handleCustomerGradeOptions() {
        let cusGradeOptions = [];
        //Assigning Customer Grade Options
        cusGradeOptions.push({
            label: 'IB',
            value: 'IB'
        });
        cusGradeOptions.push({
            label: 'NIB',
            value: 'NIB'
        });

        if(this.isTwoWheeler == true){
            cusGradeOptions.push({
                label: 'CIBIL Surrogate',
                value: 'CIBIL Surrogate'
            });
            cusGradeOptions.push({
                label: 'Banking Surrogate',
                value: 'Banking Surrogate'
            });
        }
        else if(this.isFourWheeler == true){
            cusGradeOptions.push({
                label: 'Premium',
                value: 'Premium'
            });
        }
        this.gradeOptions = cusGradeOptions;
    }

    handleCustGradeChange(event){
        this.custGrade = event.target.value;
        if(!this.isEditRestricted){
            this.customerGradeChanged=true
        }
    }

    handleSave(event){
        if(this.isEditRestricted){
            const evt = new ShowToastEvent({
                title: 'Access Restricted',
                message: 'You do not have access to edit Financial Details',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            return
        }
        saveDetails({
            loanId: this.recordVal,
            custGrade: this.custGrade
        })
        .then(data => {
            //if(data){
                this.handleApplicantsFoir(this.recordVal);
                this.customerGradeChanged=false
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Record was saved.',
                    variant: 'success',
                    mode: 'dismissible'
                });
                this.dispatchEvent(evt);
            //}
        })
        .catch(error => {
            console.error(JSON.stringify(error));
        })
    }

    @api
    checkCustomerGrade(){
        if((this.custGrade && this.customerGradeChanged) || (!this.custGrade)){
            const evt = new ShowToastEvent({
                title: '',
                message: 'Please Save Customer Grade',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            return false
        }else{
            return true
        }
    }

}