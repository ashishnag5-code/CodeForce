import { LightningElement, track,wire,api } from 'lwc';
import { getRecord, getFieldValue,createRecord } from 'lightning/uiRecordApi';
import {loadStyle} from 'lightning/platformResourceLoader';
import { getObjectInfo,getPicklistValues,getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LOANAPPLICATION_OBJECT from '@salesforce/schema/Loan_Application__c';
import LOANAMOUNT_FIELD from '@salesforce/schema/Loan_Application__c.Loan_Amount__c';
import PRODUCT_FIELD from '@salesforce/schema/Loan_Application__c.Product__c';
import SOURCENAME_FIELD from '@salesforce/schema/Loan_Application__c.Source_Name__c';
import SOURCINGCHANNEl_FIELD from '@salesforce/schema/Loan_Application__c.Sourcing_channel__c';
import VEHICLEUSE_FIELD from '@salesforce/schema/Loan_Application__c.Vehicle_use__c';
import CUSTOMERTYPE_FIELD from '@salesforce/schema/Loan_Application__c.Customer_Type__c';
import MOBILE_FIELD from '@salesforce/schema/Loan_Application__c.Mobile__c';
import PANCARD_FIELD from '@salesforce/schema/Loan_Application__c.Pan_Card__c';
import ADHARCARD_FIELD from '@salesforce/schema/Loan_Application__c.Adhar_Card__c';
import PANFORM16_FIELD from '@salesforce/schema/Loan_Application__c.Pan_Form16__c';
import CATEGORY_FIELD from '@salesforce/schema/Loan_Application__c.Category__c';

export default class LosLeadCreateWizard extends LightningElement {
    @api recordId;
    @track mobileNumber='+91';
    selectedCountryCountryCodeLength=3;
    boolCheckMobileNumber=true;
    enterOTPValue =''
    currentStep = '1';
    loanAmount ;
    sourceName ;
    indvidualCustomer = false;
    sourcingChannelOptionsValue = '';
    productOptionsValue = '';
    customerTypeOptionsValue = '';
    pancardForm16OptionsValue = '';
    categoryValue = '';
    categoryChecks = false;
    isEnterOtp = false;
    loanApplicationRecord = {};
    isEnabledPanCard = false;
    @track sourcingChannelPicklistValues;
    @track vehicleUsePicklistValues;
    @track productPicklistValues;
    @track customerTypePicklistValues;
    @track categoryTypePicklistValues;
    @track pancardForm16PicklistValues;
    
    /* OTP Verification variable */
    @track isVerified = false;
    @track boolResendOtp = false;
    boolResendButton = false;
    boolRequestOtp = false;
    boolSendOtp = true;
    @track boolIsDisableVerifyButton = true;
    @track increse1Second=27;
    @track otpVerified = false;
    @track boolVerify = true;

    @wire(getObjectInfo, { objectApiName: LOANAPPLICATION_OBJECT })
    objectInfo;

    connectedCallback(){
        
    }
    @wire(getPicklistValuesByRecordType, { objectApiName: LOANAPPLICATION_OBJECT, recordTypeId: '$objectInfo.data.defaultRecordTypeId' })
    allDataPicklistValues({error,data}){
        if(data){
            this.sourcingChannelPicklistValues = data.picklistFieldValues.Sourcing_channel__c.values;
            this.vehicleUsePicklistValues = data.picklistFieldValues.Vehicle_use__c.values;
            this.productPicklistValues = data.picklistFieldValues.Product__c.values;
            this.categoryTypePicklistValues = data.picklistFieldValues.Category__c.values;
            this.customerTypePicklistValues = data.picklistFieldValues.Customer_Type__c.values;
            this.pancardForm16PicklistValues = data.picklistFieldValues.Pan_Form16__c.values;
        }else if(error){
            console.log('error is '+JSON.stringify(error));
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [LOANAMOUNT_FIELD, PRODUCT_FIELD,SOURCENAME_FIELD,SOURCINGCHANNEl_FIELD,VEHICLEUSE_FIELD,CUSTOMERTYPE_FIELD] })
    loanApplicationRecord({error,data}){
        if(data){
            console.log('data is '+JSON.stringify(data));
            this.loanAmount = this.data.fields.Loan_Amount__c.value;
            this.sourceName = this.data.fields.Source_Name__c.value;
        }else if(error){
            console.log('error is '+JSON.stringify(error));
        }
    }

    handleSourcingchannelChange(event) {
        this.sourcingChannelOptionsValue = event.target.value;
        this.loanApplicationRecord[event.target.name] =event.target.value;
    }
    handleValuChange(event){
        this.loanApplicationRecord[event.target.name] =event.target.value;
        
    }

    handlePancardForm16ValueChange(event){
        this.pancardForm16OptionsValue = event.detail.value;
        if(event.target.name ==='Pan_Form16__c'){
            this.isEnabledPanCard = true;
        }else{
            this.isEnabledPanCard = false;
        }
    }

    handleProductChange(event) {
        this.productOptionsValue = event.detail.value;
        this.loanApplicationRecord[event.target.name] =event.target.value;
    }

    handleVehicleUseChange(event){
        this.vehicleUseOptionsValue = event.detail.value;
        this.loanApplicationRecord[event.target.name] =event.target.value;
    }
    handleCustomerTypeChange(event) {
        this.customerTypeOptionsValue = event.detail.value;
        console.log('innncategoryValue---');
        this.loanApplicationRecord[event.target.name] =event.target.value;
        if(event.detail.value ==='Individual'){
            this.indvidualCustomer = true;
        }else {
            this.indvidualCustomer = false;
        }
    }
    handleCategoryTypeChange(event) {
        this.categoryValue = event.detail.value;
        this.loanApplicationRecord[event.target.name] =event.target.value;
        console.log('loanApplicationRecord---');
        if(event.detail.value ==='Applicant'){
            console.log('loan----');
            this.categoryChecks = true;
            //isInputValid();
        }else {
            this.categoryChecks = false;
        }
    }
    handleResetAll(){
        this.template.querySelectorAll('lightning-input').forEach(Element =>{
            Element.value = null;
        });

        this.template.querySelectorAll('lightning-combobox').forEach(Element =>{
            Element.value = null;
        });

    }

    isInputValid(){
        let isValid = true;
        let inputFields = this.template.querySelectorAll(".validate");
        inputFields.forEach(inputField =>{
            if(!inputField.value){
                inputField.setCustomValidity("Complete this field");
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

    handleSendOTP(){
        this.boolRequestOtp = true;
        this.boolSendOtp = false;
        this.isEnterOtp = true;
        //this.boolVerify=true;
        this.set27SecondTimer();
    }

    handleResendOTP(){
        //this.boolIsDisableVerifyButton = false;
        
        this.isEnterOtp = true;
        this.boolRequestOtp = true;
        this.boolResendOtp = false;
        //this.boolVerify=true;
        this.set27SecondTimer();
    }

    handleVerify(event){
        this.isVerified = true;
        this.isEnterOtp = false;
        this.boolRequestOtp = false;
        this.boolResendOtp = false;
        this.boolSendOtp = false;
    }

    handleChangeOtp(event){
        if(event.detail.value.length == 6 ){
            this.enterOTPValue = event.detail.value;
            this.boolVerify=false;
        }
        //this.checkDisableTermCondition();
    }
 
    handleChangePhoneNumber(event){
        if(event.target.name=='Mobile__c' && event.target.value.length == 13){
            this.loanApplicationRecord[event.target.name] =event.target.value;
            this.mobileNumber = event.target.value;
            this.boolCheckMobileNumber = false;
        } else{
            this.boolCheckMobileNumber = true;
        }
        //this.checkDisableTermCondition();
    }

    set27SecondTimer(){
        this.increse1Second=27;
        const secondTimeInterval =   setInterval(() => {
            this.increse1Second -= 1;                            
         }, 1000);
        setTimeout(()=> {
            if(!this.isVerified){
                this.boolRequestOtp = false;
                this.boolResendOtp = true;
                //this.boolVerify = false;
            }
            window.clearInterval(secondTimeInterval);
            
        }, 27000);
    }

    createLead() {

        if (this.isInputValid()) {
        this.isloading = true;
        const fields = this.loanApplicationRecord;
        const recordInput = { apiName: LOANAPPLICATION_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then(account => {
                console.log('account '+JSON.stringify(account));
                this.handleResetAll();
                this.isloading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Lead created',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {

                this.isloading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });

        } else {
            alert('Please update the invalid form entries and try again.');
        }
    }

}