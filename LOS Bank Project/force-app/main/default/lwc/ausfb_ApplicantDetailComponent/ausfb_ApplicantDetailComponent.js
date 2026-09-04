import { LightningElement, api, wire, track } from 'lwc';
import emailVerificationHandler from '@salesforce/apex/EmailVerificationHandler.doRestCallout';
import restrictedDomain from '@salesforce/apex/CustDetCompController_AUFSB.getRestrictedDomains';
import getApplicant from '@salesforce/apex/CustDetCompController_AUFSB.getApplicant';
import updateApplicant from '@salesforce/apex/CustDetCompController_AUFSB.updateApplicant';
import { getObjectInfo, getPicklistValues, getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import APPLICANT_OBJECT from '@salesforce/schema/Applicant__c';
/*import EXISTINGCUSTOMER_FIELD from '@salesforce/schema/Applicant__c.Existing_Customer__c';
import TITLE_FIELD from '@salesforce/schema/Applicant__c.Title__c';
import FIRSTNAME_FIELD from '@salesforce/schema/Applicant__c.First_Name__c';
import MIDDLENAME_FIELD from '@salesforce/schema/Applicant__c.Middle_Name__c';
import LASTNAME_FIELD from '@salesforce/schema/Applicant__c.Last_Name__c';
import DOB_FIELD from '@salesforce/schema/Applicant__c.Dob__c';
import AGE_FIELD from '@salesforce/schema/Applicant__c.Age__c';
import GENDER_FIELD from '@salesforce/schema/Applicant__c.Gender__c';
import FATHERNAME_FIELD from '@salesforce/schema/Applicant__c.Father_Name__c';
import SPOUSENAME_FIELD from '@salesforce/schema/Applicant__c.Spouse_Name__c';
import HIGHRISKPROFILE_FIELD from '@salesforce/schema/Applicant__c.High_risk_Profile__c';
import EMPLOYEEID_FIELD from '@salesforce/schema/Applicant__c.AU_Employee_ID__c';
import EMPLOYMENTSTATUS_FIELD from '@salesforce/schema/Applicant__c.AU_Employment_status__c';
import MOBILENUMBER_FIELD from '@salesforce/schema/Applicant__c.Mobile_Number__c';
import EMAIL_FIELD from '@salesforce/schema/Applicant__c.Email__c';
import AUEMPLOYEE_FIELD from '@salesforce/schema/Applicant__c.AU_Employee__c';
import NAMEOFEMPLOYEE_FIELD from '@salesforce/schema/Applicant__c.Name_of_Employee_AU__c';
import RESIDENTIALSTATUS_FIELD from '@salesforce/schema/Applicant__c.Residential_Status__c';*/

import aadhaar from '@salesforce/resourceUrl/aadhaar';
import ckyc from '@salesforce/resourceUrl/ckyc';

// Custom Spinner settings
import { getSpinnerImage } from 'c/customSpinner';
// Custom Spinner settings


export default class Ausfb_ApplicantDetailComponent extends NavigationMixin(LightningElement) {
    @api recordId;
    @api aplicantRecord = {};
    oldapplicantRecord = {};
    boolSendOtp = true;
    isVerified = false;
    boolVerify = false;
    isValidDomain = false;
    isEmailValid = false;
    isApiDown = false;

    existingCustomerPicklistValues;
    titlePicklistValues;
    genderPicklistValues;
    highRiskProfilePicklistValues;
    employmentStatusPicklistValues;
    auEmployeePicklistValues;
    residentialStatusPicklistValues;
    isloading = true;
    activeSections = ['A', 'B'];

    strEmail = ''
    isVerify = false;
    showerror = false;
    errorStr = '';

    connectedCallback() {

        /*getApplicant({recordId: this.recordId})
            .then(result => {
                console.log('result >>'+JSON.stringify(result))

                this.aplicantRecord = result;
                console.log('result.Id>>'+result.Id)
                this.oldapplicantRecord = result;
                this.isloading = false;
            })
            .catch(error => {   
                this.error = error;
                this.aplicantRecord = undefined;
            }) */


        this.getApplicantData();
    }

    
     // Custom Spinner settings
     async spinnerImageMethod(loanId) {
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(loanId);
        }
    }
    // Custom Spinner settings

    

    getApplicantData() {
        console.log('get applicant method')
        getApplicant({ recordId: this.recordId })
            .then(result => {
                console.log('result >>' + JSON.stringify(result))
                this.spinnerImageMethod(result.Loan__c);
                this.aplicantRecord = result;
                console.log('result.Id>>' + result.Id)
                this.oldapplicantRecord = result;
                this.isloading = false;
            })
            .catch(error => {
                console.log('in error >> ' + error)
                this.error = error;
                this.aplicantRecord = undefined;
                this.oldapplicantRecord = result;
                this.isloading = false;
            })
    }

    @wire(getObjectInfo, { objectApiName: APPLICANT_OBJECT })
    objectInfo;

    @wire(getPicklistValuesByRecordType, { objectApiName: APPLICANT_OBJECT, recordTypeId: '$objectInfo.data.defaultRecordTypeId' })
    allDataPicklistValues({ error, data }) {
        if (data) {
            this.existingCustomerPicklistValues = data.picklistFieldValues.Existing_Customer__c.values;
            this.titlePicklistValues = data.picklistFieldValues.Title__c.values;
            this.genderPicklistValues = data.picklistFieldValues.Gender__c.values;
            this.employmentStatusPicklistValues = data.picklistFieldValues.AU_Employment_status__c.values;
            this.highRiskProfilePicklistValues = data.picklistFieldValues.High_risk_Profile__c.values;
            this.auEmployeePicklistValues = data.picklistFieldValues.AU_Employee__c.values;
            this.residentialStatusPicklistValues = data.picklistFieldValues.Residential_Status__c.values;

        } else if (error) {
            console.log('error is ' + JSON.stringify(error));
        }
    }

    /*@wire(getRecord, { recordId: '$recordId', fields: [EMAIL_FIELD,NAMEOFEMPLOYEE_FIELD, RESIDENTIALSTATUS_FIELD,AUEMPLOYEE_FIELD,MOBILENUMBER_FIELD, EMPLOYMENTSTATUS_FIELD, EMPLOYEEID_FIELD, 
                                                       HIGHRISKPROFILE_FIELD,SPOUSENAME_FIELD,FATHERNAME_FIELD,GENDER_FIELD, EXISTINGCUSTOMER_FIELD,
                                                       AGE_FIELD,DOB_FIELD,LASTNAME_FIELD,MIDDLENAME_FIELD,FIRSTNAME_FIELD,TITLE_FIELD,] })
    wiredContacts({ error, data }) {
        if (data) {
            let object  = this.getSObject(data);
            console.log('object',object);
            this.aplicantRecord = object;
            this.oldapplicantRecord = object;
            this.isloading = false;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.aplicantRecord = undefined;
            this.isloading = false;
        }
    }*/

    getSObject(wiredData) {
        return {
            sobjectType: wiredData.apiName,
            Id: wiredData.id,
            ...Object.keys(wiredData.fields).reduce((a, f) => {
                a[f] = wiredData.fields[f].value;
                return a;
            }, {})
        };
    }

    handleValuChange(event) {
        console.log('name ' + event.target.name + 'value ' + event.target.value)
        this.aplicantRecord[event.target.name] = event.target.value;
        if (event.target.name === 'Email__c') {
            this.strEmail = event.target.value;
        }
    }

    handleSendOTP(event) {
        this.isloading = true;
        this.emailVerificationHandler();
        console.log('email is valid');

    }


    handleSubmit(event) {
        console.log('onsubmit event recordEditForm' + event.detail.fields);
    }
    onEmailChange(event) {
        this.strEmail = event.target.value;

    }

    emailVerificationHandler() {
        //debugger;
        //var isEmailValid = false;
        emailVerificationHandler({ strEmail: this.strEmail, recordId: this.recordId })
            .then(result => {
                console.log('regex is ' + result.result.data.regexp);
                console.log('res result is ' + result.result.data.result);
                if (result.result.data.regexp && result.result.data.result) {
                    this.restrictedDomain();
                } else {
                    this.errorStr = 'please input valid email address';
                    this.isloading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'please enter valid email address',
                            message: 'please enter valid email address',
                            variant: 'error',
                            mode : 'sticky'
                        }),
                    );
                }

            })
            .catch(error => {
                console.log('is error')
                this.errorStr = 'please enter valid email address';
                this.isloading = false;
                this.isApiDown = true;
            })
        /*console.log('this.isEmailValid>>'+this.isEmailValid)
        var isEmailValid = this.isEmailValid;
        console.log('isEmailValid>>'+isEmailValid)
        return isEmailValid;*/
    }

    restrictedDomain() {

        restrictedDomain({ domainAddress: this.strEmail })
            .then(result => {
                console.log('result restrict is ' + result);
                if (result) {
                    console.log('email domain is valid')
                    this.boolSendOtp = false;
                    this.isloading = false;
                    this.isVerified = true;
                    this.aplicantRecord['IsEmailVerified__c'] = this.isVerified;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Email is verified',
                            message: 'Email is verified',
                            variant: 'success',
                        }),
                    );
                }
                else {
                    this.errorStr = 'please enter valid email domain address';
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'please enter valid email domain address',
                            message: 'please enter valid email domain address',
                            variant: 'error',
                            mode : 'sticky'
                        }),
                    );
                    this.showerror = true;
                    this.isloading = false;

                }
            })
            .catch(error => {
                console.log('result is error')
                this.isloading = false;
            })
    }

    handleSuccess(event) {
        console.log('onsuccess event recordEditForm', event.detail.id);
    }
    /*@api
    nextHandler(){
        console.log('return------');
        //const fields = event.detail.fields;
        this.template.querySelector('lightning-record-edit-form').submit();
        let returnObj = {
            'next' : true,
        }

    this.dispatchEvent(new CustomEvent('next', {
        detail: returnObj
    }));
      
    }*/

    updateApplicant() {
        console.log('in update method');
        console.log('aplicantRecord>>' + JSON.stringify(this.aplicantRecord))
        //this.aplicantRecord['Id'] = recordId;

        if (this.aplicantRecord) {
            console.log('in update method >2');
            this.isloading = true;
            console.log('this.aplicantRecord', this.aplicantRecord);
            updateApplicant({ applicant: this.aplicantRecord })
                .then(result => {
                    console.log('result ' + JSON.stringify(result));
                    this.isloading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Applicant record updated',
                            variant: 'success',
                        }),
                    );
                    this.navigateToRecordPage(this.recordId);
                    /*
                    this.aplicantRecord = result;
                    
                    const Obj = {};
                    Obj.applicantRecord = result;
                    Obj.next = true ;
                    console.log('Obj', Obj);

                    this.dispatchEvent(new CustomEvent('next', {
                        detail: Obj
                    }));
                    */

                })
                .catch(error => {
                    this.isloading = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error upserting record',
                            message: error.body.message,
                            variant: 'error',
                            mode : 'sticky'
                        }),
                    );
                });

        } else {

        }
    }
    /*
       @api nextHandler() {
            //let next = (this.strEmail != '' && this.isVerified) ? true : false;
            if(this.isInputValid() && (this.isVerified || this.isApiDown)){
                if(JSON.stringify(this.oldapplicantRecord) === JSON.stringify(this.aplicantRecord)){
                    const Obj = {};
                    Obj.next = true ;
                    Obj.applicantRecord = this.aplicantRecord;
                    console.log('Obj', Obj);
    
                    this.dispatchEvent(new CustomEvent('next', {
                        detail: Obj
                    }));
                }else{
                    let value = this.updateApplicant();
                }
                
            }else{
                    const Obj = {};
                    Obj.next = false ;
                    Obj.applicantRecord = this.aplicantRecord;
                    console.log('Obj', Obj);
    
                    this.dispatchEvent(new CustomEvent('next', {
                        detail: Obj
                    }));
    
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Email is not Verified, Please verify',
                            message: 'Email is not Verified, Please verify',
                            variant: 'error',
                        }),
                    );
            }
            
        }
        */

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('.validate');
        inputFields.forEach(inputField => {
            if (!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
            //this.contact[inputField.name] = inputField.value;
        });
        return isValid;
    }

    navigateToRecordPage(objectRecordid) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: objectRecordid,
                //objectApiName: 'Account',
                actionName: 'view'
            },
        });
    }

    handleCancel(){
        this.navigateToRecordPage(this.recordId);
    }

    handleSave(){
        if(this.isInputValid() && this.isVerified){
        this.updateApplicant();
        }
        else{
            if(!this.isVerified){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Email is not Verified, Please verify',
                    message: 'Email is not Verified, Please verify',
                    variant: 'error',
                    mode : 'sticky'
                }),
            );
            }
        }
    }
}