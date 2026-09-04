import { LightningElement,api,wire } from 'lwc';
import getAccountDetails from '@salesforce/apex/exposureDetailsController.getAccountDetails';
import updateAccountDetails from '@salesforce/apex/exposureDetailsController.updateAccountDetails';
import getCBSApplicantDetail from '@salesforce/apex/LeadDedupeController.getCBSApplicantDetail';
import getCCResponse from '@salesforce/apex/LeadDedupeController.getCCResponse';
import getCustomerODResponse from '@salesforce/apex/LeadDedupeController.getCustomerODResponse';
import copyApplicantfromCBS from '@salesforce/apex/LeadDedupeController.copyApplicantfromCBSExposure'; //22 AUG
//import copyApplicantfromCBS from '@salesforce/apex/LeadDedupeController.copyApplicantfromCBS'; //22 AUG
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from '@salesforce/user/Id';

import getUserProfileDetails from '@salesforce/apex/exposureDetailsController.getUserProfileDetails';

export default class ExposureComponent extends LightningElement {

    // API Attributes
    @api recordId;


    //Boolean Attributes
    isLoading = false;
    @api spinnerImage;
    isDisbursedLoan = false;
    isShowDetailsSection = false;
    isShowCasaSection = false;
    isShowLoanApiSection = false;
    showMainSection = false;

    //Array Attributes
    lstODCCAccountDetails;
    lstLoanAccountDetails;
    lstCASAAccountDetails;
    lstCreditAccountDetails;
    lstAccountDetails;
    casaApiDetails;
    loanApiDetails;

    //Decimal Attributes
    decWheelsExposure = 0;
    decTotalExposure = 0;
    emiPaid = 0;
    overDue = 0;

    //String Attributes
    accountNumber = '';
    applicantId ='';
    bankAccountNumber ='';
    vehicleType ='';
    loanStage='';
    userId = Id;
    profileName = '';

    wrapperLst={};
    applicantInput = {};
    refinedRecordsList;
    calculatedList={};
    applicantRecord = {};
    applicantODRecord = [];
    applicantCreditCard = {};


    connectedCallback() {
      
        this.getBankDetails();
        this.getUserDetails();
        this.isShowDetailsSection = true;
    }

    getUserDetails(){

        getUserProfileDetails({
            userId : this.userId
        }).then(result => {
            if (result) {
                this.profileName = result;
                
            }
        })
        .catch(error => {
            this.isLoading = false;
            console.log('error in getAccountDetails-->' + JSON.stringify(error));
        })
    }

    getBankDetails() {
        this.isLoading = true;
    
        getAccountDetails({
                laonApplicantId: this.recordId,
            }).then(result => {
                if (result) {

                    if (result.wheelsExposure != 0) {
                        this.decWheelsExposure = result.wheelsExposure;
                    }
                    if (result.totalExposure != 0) {
                        this.decTotalExposure = result.totalExposure;
                    }

                    this.vehicleType = result.typeOfVehicle;
                    this.loanStage = result.loanStage
                    this.lstAccountDetails = result.recordWrapperList;
                    this.showMainSection =  result.showMainSection;
                    console.log('exposureresult-->' + JSON.stringify(result));

                    /* this.lstAccountDetails = result;
                     if(result[0].applicantRecords!=null){
                         this.isDisbursedLoan = true;
                     }
                     if(result[0].bankAccountRecords!=null){
                         this.isBankRecords = true;
                     }*/
                     
                    this.isLoading = false;
                }
            })
            .catch(error => {
                this.isLoading = false;
                console.log('error in getAccountDetails-->' + JSON.stringify(error));
            })
    }


    handleCasa(event) {
        this.casaApiDetails = event.detail;
        this.isShowDetailsSection = false;
        this.isShowCasaSection = true;
        console.log('parenetCasaDetails-->' + JSON.stringify(event.detail));
    }

    handleLoan(event) {
        this.loanApiDetails = event.detail;
        this.isShowDetailsSection = false;
        this.isShowCasaSection = false;
        this.isShowLoanApiSection = true;
    }
    handleInquiryLoan(event) {
        let details = event.detail;
        if (details != null) {
            this.emiPaid = details[0].No_of_Emi_Paid__c;
            this.overDue = details[0].Loan_Overdue_EMI__c;
            this.accountNumber = details[0].Account_Number__c;
        }
        this.isLoading = true;
        this.getBankDetails();
        this.isLoading = false;
        this.isShowDetailsSection = false;
        this.isShowCasaSection = false;
    }

    handleRowAction() {
        this.isLoading = true;
        this.isShowCasaSection = false;
        this.isShowLoanApiSection = false;
        this.isShowDetailsSection = true;
        this.isLoading = false;
    }

    showMessage(message, variant) {
        const event = new ShowToastEvent({
            title: '',
            variant: variant,
            mode: 'dismissable',
            message: message
        });
        this.dispatchEvent(event);
    }

    handleExposure(event) {
       // console.log('event-->' +event.detail.value);
         this.isLoading = true;
        this.refinedRecordsList = event.detail;
        
       //here i need to hold the static list of all the accountnumbers and pass that to the bank updation method
        this.getBankDetails();
       
        //this.handleBankUpdation();
        this.isLoading = false;

        console.log('mapdetail' + JSON.stringify( this.refinedRecordsList));
        //this.isShowDetailsSection = false;
        // this.isShowCasaSection = false;*/
    }
    handleCalculation(event){
        console.log('event1-->' +event.detail);
        this.calculatedList = event.detail;

    }

    handleBankUpdation(){
      
        console.log('insideBankUpdation__' +JSON.stringify(this.refinedRecordsList));
        console.log('this.calculatedList' +JSON.stringify(this.calculatedList));
        if( this.refinedRecordsList!=undefined){
            this.isLoading = true;
            updateAccountDetails({
                laonApplicantId: this.recordId,
                toUpdateLoan:   this.refinedRecordsList,
                calculatedList: this.calculatedList
                
            }).then(result => {
                console.log('completed');
                this.getBankDetails(); //but still should we need to give a timeout or not testing is pending if we comment down working fine
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                console.log('error in updateAccountDetails-->' + JSON.stringify(error));
            })
            this.isLoading = false;
        }
       
    }

    handleAfterDisbursedCalculation(event){
        this.calculatedList = event.detail;
        this.getBankDetails(); 
        
    }
   
    /*dummyHandler() {
        let booleanCheck = false;
        let accountDetails = this.lstAccountDetails;
        this.lstAccountDetails.forEach(recordWrapper => {
            if (recordWrapper.isLOAN == true) {
                recordWrapper.loanBankAccountRecords.forEach(loanRecord => {
                    if (loanRecord.View_Check__c == false) {
                        booleanCheck = true;
                    }
                });
            }

        });


        if (booleanCheck == true) {
            this.showMessage('Please Click the View button on Loan Account Details to proceed', 'Error');
        }
    }*/
    handleRender(event){
        //this.getBankDetails(); 
    }

    refreshHandler(event){
        const recordId = event.currentTarget.dataset.id;
        this.applicantId =  event.currentTarget.dataset.id;
        let cifNo = event.currentTarget.title;
        console.log('applId-->' +recordId +'---' +'cifNo-->'+cifNo);
        this.isLoading = true;
        Promise.all([
            getCBSApplicantDetail({ strCustomerId : cifNo ,strApplicantId : recordId , cardName : 'full', countFull : 0}),
            getCCResponse({ strCustomerId : cifNo ,strApplicantId : recordId}),
            getCustomerODResponse({ strCustomerId : cifNo ,strApplicantId :recordId})
       ]).then((values) => {
            if(values[0] != undefined){
             this.applicantRecord = values[0];
             }
            if(values[1] != undefined){
             this.applicantCreditCard = values[1];
             }    
            if(values[2] != undefined){
                console.log('values[2]->' +JSON.stringify(values[2]));
             this.applicantODRecord = values[2];
            }
            /* Added by Kunal - SFAU-5667 Start*/
            if(this.applicantRecord && this.applicantRecord.strCustomerID){ // Skip Copy to Applicant if not received any response from API.
                this.copyApplicant();
           }else{
                this.dispatchEvent(
                     new ShowToastEvent({
                         title: '',
                         message: 'We did not receive any Match from CBS. Please Re-try',
                         variant: 'error',
                         mode: 'sticky'
                     }),
                 );
           }
            //this.copyApplicant(); 
           /* Added by Kunal - SFAU-5667 End*/
            this.isLoading = false;
           
       }).catch(error => {
            if(error[0] != undefined){
                 this.error = error[0];
            }
            if(error[1] != undefined){
                 this.error = error[1];
            }
            console.log('resultCC is '+error)
            this.isLoading = false;
       })
    }


    copyApplicant(){
        this.applicantInput.Id = this.applicantId;
        console.log('values[0]==>' +JSON.stringify(this.applicantODRecord));
        copyApplicantfromCBS({ objCustomerDetailWrapper : this.applicantRecord ,objCustomerODResponseWrapper:  this.applicantODRecord , objCreditCardWrapper :  this.applicantCreditCard ,objApplicant : this.applicantInput,boolAddressChange :false})
        .then(result => {
            console.log('copyApplicant'+JSON.stringify(result));
            this.handleBankUpdation();
            this.isLoading = false;
           
        })
        .catch(error => {
            console.log('result is '+error)
            this.isLoading = false;
        })
    }
    @api async nextHandler() {
        let booleanCheck = false;
        //let accountDetails = this.lstAccountDetail;
        if(this.profileName != 'Sales'){
            const bankData = await getAccountDetails({ laonApplicantId: this.recordId,})
            this.lstAccountDetails = bankData.recordWrapperList;
            if(  (this.lstAccountDetails!=undefined) && (this.lstAccountDetails!=null) && (this.lstAccountDetails.length>0)){
            this.lstAccountDetails.forEach(recordWrapper => {
                if (recordWrapper.isLOAN == true) {
                    recordWrapper.loanBankAccountRecords.forEach(loanRecord => {
                        if (loanRecord.View_Check__c == false) {
                            booleanCheck = true;
                        }
                    });
                }
            });
          }
        }
       


        if (booleanCheck == true) {
            this.showMessage('Please Click the View button on Loan Account Details to proceed', 'Error');
        } else {
            const Obj = {};
            //Obj.applicantRecord = this.applicantIdInput;e
            this.errorOnChild = '';
            Obj.errorOnChild = this.errorOnChild;
            Obj.next = this.errorOnChild == '' ? true : false;
            console.log('Obj', Obj);
            this.dispatchEvent(new CustomEvent('next', {
                detail: Obj
            }));
        }
    }
}