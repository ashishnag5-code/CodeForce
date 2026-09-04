import { LightningElement, api, track } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { NavigationMixin } from 'lightning/navigation';

export default class Ausfb_GenericWizard extends NavigationMixin(LightningElement) {
    @api recordId;
    currentPage = 0;
    totalPage = 7;
    components;
    aadhaarVerified = true;
    //c/leadDedupeCBSotpVerified = false;
    @track loanApplicationRecord = {};
    @track applicantRecord = {};
    skipKYC = false;
    fetchDedupe = false;
    showAddress = false;
    isMobile = false;
    fetchCustomerInfo = false;
    @api wizardActionType;

    connectedCallback() {
        this.setFormFactor();
        console.log('Form factor - Mobile : ', this.isMobile);
        console.log('wizardActionType: ', this.wizardActionType);
        if(this.wizardActionType == 'AddNewApplicant'){
            console.log('In Add New Applicant component');

        }
    }


    setFormFactor() {
        switch (FORM_FACTOR) {
            case 'Large': {
                this.isMobile = false;
                break;
            }
            case 'Medium': {
                this.isMobile = true;
                break;
            }
            case 'Small': {
                this.isMobile = true;
                break;
            }
        }
    }

    get nextLabel() {
        return 'Next';
        // this.currentPage == 0 ? 'Add Additional Documents': ;
    }

    get disablePrevious() {
        return this.currentPage <= 0;
    }

    get disableNext() {
        //if(this.currentPage == 0 && this.aadhaarVerified)
        // return this.currentPage >= this.totalPage - 1;
        //return this.otpVerified;
    }

    previousHandler() {
        if (this.currentPage > 0) {
            //disconnect dedupe screen
            if (this.currentPage == 2) {
                this.fetchDedupe = false;
                this.skipKYC = false;
            }

            if(this.currentPage == 3) {
                this.fetchDedupe = true;
            }
            this.currentPage = this.currentPage - 1;
            this.updateRecords('previous');
        }
    }

    cancelHandler() {
        console.log('cancel');
        this.navigateToRecordPage(this.loanApplicationRecord.Id);
    }
    
    navigateToRecordPage(objectRecordid) {
        console.log('objectRecordid',objectRecordid);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: objectRecordid,
                //objectApiName: 'Loan_Application_c',
                actionName: 'view'
            },
        });
    }

    childNextHandler() {
        if (this.currentPage < this.totalPage) {
            if (!this.components && !this.skipKYC) {
                this.components = this.template.querySelectorAll('div.component');
            }
            if (!this.components && this.skipKYC) {
                this.components = this.template.querySelectorAll('div.skipKYC');
            }
            console.log('%%% '+this.currentPage);

            if( this.showAddress == false){
                this.showAddress = this.components[this.currentPage].classList.contains("fetchAddress");
            }
            if( this.fetchCustomerInfo == false){
                this.fetchCustomerInfo = this.components[this.currentPage].classList.contains("fetchCustomerInfo");
            }
            
            /*if( this.showAddress == false){
                this.showAddress = this.components[this.currentPage].classList.contains("fetchAddress");
            }*/
            
            console.log('components-->' + JSON.stringify(this.components));
            console.log('has-->' + this.components[this.currentPage].classList.contains("fetchAddress"));
            let page = this.components[this.currentPage].children[0];
            console.log('calling child: ', page);

            
            if(this.currentPage == 4 && !this.skipKYC){
                let page2 = this.components[this.currentPage+1].children[0];
                console.log('calling getApplicant: ', page2);
                page2.getApplicantData();
            }
            if(this.currentPage == 5 && !this.skipKYC){
                let page2 = this.components[this.currentPage+1].children[0];
                console.log('calling add: ', page2);
                page2.getApplicants();
            }
           
            page.nextHandler();

            
        }
    }

    nextHandler(event) {
        let current = event.detail;
        console.log('current: ', current);
        console.log('current: ', current.next);
        console.log('current: ', current.applicantRecord);
        console.log('kyc status: ', this.applicantRecord.KYC_Status__c);
        if (current.next) {
            if( this.showAddress == false){
                this.showAddress = this.components[this.currentPage].classList.contains("fetchAddress");
            }
            if( this.fetchCustomerInfo == false){
                this.fetchCustomerInfo = this.components[this.currentPage].classList.contains("fetchCustomerInfo");
            }
            this.currentPage = this.currentPage + 1;
            console.log('hasOwnProperty', current.hasOwnProperty('loanApplicationRecord'));
            if (current.hasOwnProperty('loanApplicationRecord')) {

                this.loanApplicationRecord = current.loanApplicationRecord;
                console.log('loanApplicationRecord', this.loanApplicationRecord.Id);
            }
            if (current.hasOwnProperty('applicantRecord')) {
                this.applicantRecord = current.applicantRecord;
                console.log('%% ' + this.currentPage);
                //connect dedupe screen
                
                console.log('applicantRecord', JSON.stringify(this.applicantRecord));
                console.log('applicantRecord', this.applicantRecord.Id);
                console.log('applicantRecord', this.applicantRecord.KYC_Status__c);
                console.log('fetch dedupe: ',this.fetchDedupe);
                if (this.applicantRecord.hasOwnProperty('KYC_Status__c') && this.applicantRecord.KYC_Status__c == 'Complete' && this.fetchDedupe) {
                    this.skipKYC = true;
                    //this.updateRecords('update');
                    //return;
                    var comp = this.template.querySelectorAll('div.fetchAddress');
                    console.log('comp is '+comp)
                    console.log('comp is '+comp[0])
                    console.log('comp is '+comp[0].children[0])
                    //this.template.querySelector('.fetchAddress').getApplicantData();
                    //if(this.currentPage == 3){

                        let page2 = comp[0].children[0];
                        console.log('calling getApplicant: ', page2);
                        page2.getApplicantData();

                        let page3 = comp[1].children[0];
                        console.log('calling getApplicant: ', page3);
                        page3.getApplicants();
                    //}
                    /*if(this.currentPage == 3){
                        let page2 = this.components[this.currentPage+1].children[0];
                        console.log('calling add: ', page2);
                        page2.getApplicants();
                    }*/
                }
                if (this.currentPage == 2) {
                    this.fetchDedupe = true;
                }else{
                    this.fetchDedupe = false;
                }
                
            }

            this.updateRecords('next');

        } else {
            console.log('failed');
        }



        //}
    }

    updateRecords(handlerName) {
        console.log('updating record: ');
        //if (!this.components || handlerName == 'update') {
        if (this.skipKYC) {
            this.components = this.template.querySelectorAll('div.skipKYC');
        }
        console.log('%% ' + this.skipKYC);
        this.components[this.currentPage].classList.remove('slds-hide');
        console.log('this.components', this.components);
        handlerName == 'previous' ? this.components[this.currentPage + 1].classList.add('slds-hide') : this.components[this.currentPage - 1].classList.add('slds-hide');
        // this.disablePrevious();
        // this.disableNext();
    }


}