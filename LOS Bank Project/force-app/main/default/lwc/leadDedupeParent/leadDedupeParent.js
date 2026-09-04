import { api, LightningElement, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getCBSApplicantList from '@salesforce/apex/LeadDedupeController.getCBSApplicantList';
import updateKYCPending from '@salesforce/apex/LeadDedupeController.updateKYCPending';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import AUSF_LOGOS from "@salesforce/resourceUrl/AUSF_LOGOS";
import { getSpinnerImage } from 'c/customSpinner';
import getCRMApplicantList from '@salesforce/apex/LeadDedupeController.getCRMApplicantList';
import updateNPAFieldOnApplicant from '@salesforce/apex/LeadDedupeController.updateNPAFieldOnApplicant';//R2-34

export default class LeadDedupeTabs extends LightningElement {
    @api recordId;
    @api loanApplicationId;

    @api 
    boolFromCamReport = false;
    @api 
    boolCamReportTypeCBS = false;
    error;
    @api applicants={};

    @api
    applicantIdInput={};
    @api
    spinnerImage;// = AUSF_LOGOS + '/AUSF_LOGOS/spinner/Bike.gif';
    errorOnChild='';
    boolIsCBSCopyDone = false;
    boolIsAbortApplication = false;
    boolIsNPA = false;
    boolIsSkipFullCopy = true;
    countFullInd;
    countFullNonInd;
    isLoading;
    boolIsFromWizard;
    @track totalApplicantsCRM;
    rerunDedupe;
    boolIsCopyDisabled = false;
    hasApplicants = false;
    

    async connectedCallback(){
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.loanApplicationId);
        }
        this.boolIsFromWizard = true;
        if(this.recordId != undefined && this.recordId != ''){
            this.rerunDedupe = true;
            this.boolIsFromWizard = false;
            this.applicantIdInput.Id = this.recordId ;
            this.boolIsCopyDisabled = true;
            //this.isLoading = false;
        } 
        this.runDedupe();
        console.log('%% '+this.spinnerImage);
        console.log('%% '+this.recordId);
        console.log('in connected parent'+this.applicantIdInput.Id);
        /*this.boolIsFromWizard = true;
        this.isLoading = true;
        if(this.recordId != undefined && this.recordId != ''){
            this.rerunDedupe = true;
            this.boolIsFromWizard = false;
            this.applicantIdInput.Id = this.recordId ;
            this.isLoading = false;
        } 

        Promise.all([
            getCBSApplicantList({ strApplicantId :this.applicantIdInput.Id , boolIsWizard : this.boolIsFromWizard}),
            getCRMApplicantList({ applicantId : this.applicantIdInput.Id , boolIsWizard : this.boolIsFromWizard})
        ]).then((values) => {
            if(values[0] != undefined){
                this.applicants = values[0];
                this.setCBSData();
            }
            if(values[1] != undefined){
                this.totalApplicantsCRM = values[1];
            }
        }).catch(error => {
            if(error[0] != undefined){
                 this.error = error[0];
            }
            if(error[1] != undefined){
                 this.error = error[1];
            }
            this.isLoading = false;
        })
        /*
        getCBSApplicantList({ strApplicantId :this.applicantIdInput.Id , boolIsWizard : this.boolIsFromWizard})
        .then(result => {
            console.log('result is '+JSON.stringify(result));
            this.applicants = result;
            let applicantNPA = [];
            this.countFullInd = 0;
            this.countFullNonInd = 0;
            if(this.applicants.applicantList_fullMatch.length > 0){
                applicantNPA = this.applicants.applicantList_fullMatch.filter((item)=>item.strNPAStatus === 'NPA');
                let applicantCustomerMatch = this.applicants.applicantList_fullMatch.find((item)=>item.strInputCustomerType === item.strCustomerType);
                if(applicantCustomerMatch != undefined && applicantCustomerMatch.strCustomerID != undefined){
                    this.boolIsSkipFullCopy = false;
                }
                this.countFullInd = this.applicants.applicantList_fullMatch.reduce((n, e) => e.strCustomerType === 'Individual' ? n+1 : n, 0);
                this.countFullNonInd = this.applicants.applicantList_fullMatch.reduce((n, e) => e.strCustomerType === 'Non Individual' ? n+1 : n, 0);
            }
            console.log('%%'+ this.boolIsNPA);
            if(this.applicants.applicantList_partialMatch.length > 0){
                applicantNPA = this.applicants.applicantList_partialMatch.filter((item)=>item.strNPAStatus === 'NPA');
            }
            console.log('%%'+ this.boolIsNPA);
            if(applicantNPA.length > 0){
                this.boolIsNPA = true;
            }
            console.log('%%'+ this.boolIsNPA);
            this.error = undefined;
            this.isLoading = false;
        })
        .catch(error => {
            console.log('result is '+error)
            this.error = error;
            this.isLoading = false;
        })*/
    }

    handleDedupeRun(event){
        this.boolIsFromWizard = true;
        this.runDedupe();
    }

    runDedupe(){
        //this.boolIsFromWizard = true;
        this.isLoading = true;
        /*if(this.recordId != undefined && this.recordId != ''){
            this.rerunDedupe = true;
            this.boolIsFromWizard = false;
            this.applicantIdInput.Id = this.recordId ;
            this.isLoading = false;
        }*/

        Promise.all([
            getCBSApplicantList({ strApplicantId :this.applicantIdInput.Id , boolIsWizard : this.boolIsFromWizard}),
            getCRMApplicantList({ applicantId : this.applicantIdInput.Id , boolIsWizard : this.boolIsFromWizard})
        ]).then((values) => {
            if(values[0] != undefined){
                this.applicants = values[0];
                console.log('this.applicants: '+JSON.stringify(this.applicants));
                if(this.applicants){
                    this.hasApplicants = true;
                }
                console.log('this.hasApplicants: '+this.hasApplicants);
                this.setCBSData();
            }
            if(values[1] != undefined){
                this.totalApplicantsCRM = values[1];
            }
        }).catch(error => {
            if(error[0] != undefined){
                 this.error = error[0];
            }
            if(error[1] != undefined){
                 this.error = error[1];
            }
            this.isLoading = false;
        })
    }

    setCBSData(){
        let applicantNPA = [];
        this.countFullInd = 0;
        this.countFullNonInd = 0;
        if(this.applicants.applicantList_fullMatch.length > 0){
            applicantNPA = this.applicants.applicantList_fullMatch.filter((item)=>item.strNPAStatus === 'NPA');
            let applicantCustomerMatch = this.applicants.applicantList_fullMatch.find((item)=>item.strInputCustomerType === item.strCustomerType);
            if(applicantCustomerMatch != undefined && applicantCustomerMatch.strCustomerID != undefined){
                this.boolIsSkipFullCopy = false;
            }
            this.countFullInd = this.applicants.applicantList_fullMatch.reduce((n, e) => e.strCustomerType === 'Individual' ? n+1 : n, 0);
            this.countFullNonInd = this.applicants.applicantList_fullMatch.reduce((n, e) => e.strCustomerType === 'Non Individual' ? n+1 : n, 0);
            if(this.template.querySelector('c-lead-Dedupe-C-B-S') != null){
                this.template.querySelector('c-lead-Dedupe-C-B-S').setNoRecordsFullFalse();
            }
        }
        console.log('%%'+ this.boolIsNPA);
        if(this.applicants.applicantList_partialMatch.length > 0){
            applicantNPA = this.applicants.applicantList_partialMatch.filter((item)=>item.strNPAStatus === 'NPA');
            if(this.template.querySelector('c-lead-Dedupe-C-B-S') != null){
                this.template.querySelector('c-lead-Dedupe-C-B-S').setNoRecordsPartiallFalse();
            }
        }
        console.log('%%'+ this.boolIsNPA);
        if(applicantNPA.length > 0){
            this.boolIsNPA = true;
        }
        this.setNPAOnApplicant()//R2-34
        console.log('%%'+ this.boolIsNPA);
        this.error = undefined;
        this.isLoading = false;
    }

    //R2-34
    setNPAOnApplicant(){
        updateNPAFieldOnApplicant({applicantId:this.applicantIdInput.Id, isNPA: this.boolIsNPA}).then((data=>{

        })).catch(error=>{

        })
    }

    onspinnerevent(event) {
        console.log('%% '+this.spinnerImage);
        let showspinner = event.detail;
        if(showspinner){
            this.isLoading = true;
        }
        else{
            this.isLoading = false;
        }
    }

    abortApplication(event){
        console.log('in block application');
        this.boolIsAbortApplication = true;
    }

    setapplicant(event){
        const Obj = {};
        if(this.boolIsAbortApplication){
            Obj.errorOnChild = 'You already have an In-Progress Application for the same Product';
            Obj.next = false;
            console.log('Obj', Obj);

            this.dispatchEvent(new CustomEvent('next', {
                detail: Obj
            }));

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'You already have an In-Progress Application for the same Product',
                    message: 'You already have an In-Progress Application for the same Product',
                    variant: 'error',
                    mode: 'sticky'
                }),
            );
        }
        /*else if(this.boolIsNPA){
            Obj.errorOnChild = 'NPA Detected. Application cannot Proceed';
            Obj.next = false;
            console.log('Obj', Obj);

            this.dispatchEvent(new CustomEvent('next', {
                detail: Obj
            }));

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'NPA Detected. Application cannot Proceed',
                    message: 'NPA Detected. Application cannot Proceed',
                    variant: 'error',
                    mode: 'sticky'
                }),
            );
        }*/
        else if(event.detail.tab == 'CBS'){
            var applicantRecord = event.detail.value;
            event.stopPropagation();
            console.log('%%%selectedRecord '+applicantRecord);
            Obj.applicantRecord = applicantRecord;
            Obj.errorOnChild = this.errorOnChild;
            Obj.next = this.errorOnChild == '' ? true : false;
            console.log('Obj', Obj);
            this.dispatchEvent(new CustomEvent('next', {
                detail: Obj
            }));
        }
        else if(event.detail.tab == 'CRM'){
            var applicantRecord = event.detail.value;
            event.stopPropagation();
            Obj.applicantRecord = applicantRecord;
            Obj.errorOnChild = this.errorOnChild;
            Obj.next = this.errorOnChild == '' ? true : false;
            console.log('Obj', Obj);
            this.dispatchEvent(new CustomEvent('next', {
                detail: Obj
            }));
        }
    }

    @api nextHandler() {
        const Obj = {};
        //this.errorOnChild = '';
        console.log('%%'+JSON.stringify(this.applicantIdInput));
        console.log('%%'+JSON.stringify(this.boolIsCBSCopyDone));
        console.log('%%'+JSON.stringify(this.applicants.applicantList_fullMatch.length));
        console.log('%%'+JSON.stringify(this.applicantIdInput.hasOwnProperty('KYC_Status__c')));
        let boolISKYCComplete = this.applicantIdInput.hasOwnProperty('KYC_Status__c') && this.applicantIdInput.KYC_Status__c == 'Complete' ? true : false;

        if(this.applicants.applicantList_fullMatch.length > 0 
            && !this.boolIsCBSCopyDone && !this.boolIsSkipFullCopy && !boolISKYCComplete){ /* &&this.applicants.applicantList_partialMatch.length == 0*/ 
            Obj.errorOnChild = 'Please select Full Match';
            Obj.next = false;
            console.log('Obj', Obj);

            this.dispatchEvent(new CustomEvent('next', {
                detail: Obj
            }));

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Please select Full Match',
                    message: 'Please select Full Match',
                    variant: 'error',
                    mode: 'sticky'
                }),
            );
        }
        else if(this.boolIsAbortApplication && !boolISKYCComplete){
            Obj.errorOnChild = 'The customer already has an existing application which is in progress. Please close the same to continue.';
            Obj.next = false;
            console.log('Obj', Obj);

            this.dispatchEvent(new CustomEvent('next', {
                detail: Obj
            }));

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'The customer already has an existing application which is in progress. Please close the same to continue.',
                    message: 'The customer already has an existing application which is in progress. Please close the same to continue.',
                    variant: 'error',
                    mode: 'sticky'
                }),
            );
        }
        else if(this.boolIsNPA && !boolISKYCComplete && this.applicantIdInput.Loan__r.RecordType.Name!='Tractor'){//added Tractor check - R2-34
            Obj.errorOnChild = 'NPA Detected. Application cannot Proceed';
            Obj.next = false;
            console.log('Obj', Obj);

            this.dispatchEvent(new CustomEvent('next', {
                detail: Obj
            }));

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'NPA Detected. Application cannot Proceed',
                    message: 'NPA Detected. Application cannot Proceed',
                    variant: 'error',
                    mode: 'sticky'
                }),
            );
        }
        else{
            if(this.applicantIdInput != undefined && this.applicantIdInput.Loan__r != undefined
                && this.applicantIdInput.Loan__r.RecordType != undefined 
                && this.applicantIdInput.Loan__r.RecordType.Name != undefined 
                && this.applicantIdInput.Loan__r.RecordType.Name=='Tractor' && this.boolIsNPA){//R2-34 added toast message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'NPA Detected.',
                        message: 'You will not be able to get Approval / Disbursement until NPA is Resolved',
                        variant: 'error',
                        mode: 'sticky'
                    }),
                );
            }
            if((!this.applicantIdInput.hasOwnProperty('KYC_Status__c') || (this.applicantIdInput.hasOwnProperty('KYC_Status__c') 
                    && this.applicantIdInput.KYC_Status__c == '')) && !boolISKYCComplete){

                let obj = JSON.parse(JSON.stringify(this.applicantIdInput));         
                if(obj.hasOwnProperty('CreatedDate')){
                    delete obj['CreatedDate'];
                }
                this.applicantIdInput = JSON.parse(JSON.stringify(obj));        
                updateKYCPending({ applicantStr : JSON.stringify(this.applicantIdInput)})
                .then(result => {
                    Obj.applicantRecord = result;
                    Obj.errorOnChild = this.errorOnChild;
                    Obj.next = this.errorOnChild == '' ? true : false;
                    console.log('Obj', Obj);

                    this.dispatchEvent(new CustomEvent('next', {
                        detail: Obj
                    }));
                })
                .catch(error => {
                    console.log('result is '+error)
                })
            }
            else{
                Obj.applicantRecord = this.applicantIdInput;
                Obj.errorOnChild = this.errorOnChild;
                Obj.next = this.errorOnChild == '' ? true : false;
                console.log('Obj', Obj);
                this.dispatchEvent(new CustomEvent('next', {
                    detail: Obj
                }));
                
            }
        }
        
    }
}