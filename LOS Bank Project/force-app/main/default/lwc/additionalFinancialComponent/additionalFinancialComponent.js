import { api, LightningElement, track, wire } from 'lwc';
import updateApplicant from '@salesforce/apex/financeController.updateApplicant';
import getApplicant from '@salesforce/apex/financeController.getApplicant';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import APPLICANT_OBJECT from '@salesforce/schema/Applicant__c';
import MARITAL_FIELD from '@salesforce/schema/Applicant__c.Marital_Status__c';
import RESIDENCE_FIELD from '@salesforce/schema/Applicant__c.Residential_Status__c';
import PHYSICAL_FIELD from '@salesforce/schema/Applicant__c.Phsically_challenged__c';
import HIGHRISK_FIELD from '@salesforce/schema/Applicant__c.High_risk_Profile__c';
import AUEMP_FIELD from '@salesforce/schema/Applicant__c.AU_Employee__c';
import AUEMPSTATUS_FIELD from '@salesforce/schema/Applicant__c.AU_Employment_status__c';
import NATUREPHCH_FIELD from '@salesforce/schema/Applicant__c.Natutre_of_Phsically_challenge__c';
import PROOFD_FIELD from '@salesforce/schema/Applicant__c.Proof_of_Disablity__c';
import getApplicants from '@salesforce/apex/financeController.getApplicants'; //26 JUL
import getMaterialFields from '@salesforce/apex/Utility.getMaterialFields';
import checkMaterialFields from '@salesforce/apex/Utility.checkMaterialFields';
import { showToastMessage } from 'c/lwcutilities';
import singleWithEmploymentHouseWife from '@salesforce/label/c.SingleWithEmploymentHouseWife';

export default class AdditionalFinancialComponent extends LightningElement {
    @api screen;
    @api applicantId;
    @api isMobile;
    @api spouseName;
    @api recordId;
    maritalValue = '';
    phValue = '';
    resValue = '';
    hrValue = '';
    auValue = '';
    aeValue = '';
    empNameValue = '';
    empIdValue = '';
    npcValue = '';
    pdValue = '';
    spouseValue = '';
    maritalOptions = [];
    resOptions = [];
    phOptions = [];
    hrOptions = [];
    auOptions = [];
    aeOptions = [];
    npcOptions = [];
    pdOptions = [];
    isAUEmployee = false;
    isPhysicalChg = false;
    spousNameRequired = false;
    isMaritalStatus = false;//26 JUL
    customerType;//26JUL
    breReRunFields = [];


    @wire(getObjectInfo, { objectApiName: APPLICANT_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: MARITAL_FIELD })
    getPicklistValuesForMarital({ data, error }) {
        if (error) {
            // TODO: Error handling
            console.error(error)
        } else if (data) {
            this.maritalOptions = [...data.values]
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: RESIDENCE_FIELD })
    getPicklistValuesForRes({ data, error }) {
        if (error) {
            // TODO: Error handling
            console.error(error)
        } else if (data) {
            this.resOptions = [...data.values]
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: PHYSICAL_FIELD })
    getPicklistValuesForPhChg({ data, error }) {
        if (error) {
            // TODO: Error handling
            console.error(error)
        } else if (data) {
            this.phOptions = [...data.values]
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: HIGHRISK_FIELD })
    getPicklistValuesForHighRisk({ data, error }) {
        if (error) {
            // TODO: Error handling
            console.error(error)
        } else if (data) {
            this.hrOptions = [...data.values]
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: AUEMP_FIELD })
    getPicklistValuesForAUEMP({ data, error }) {
        if (error) {
            // TODO: Error handling
            console.error(error)
        } else if (data) {
            this.auOptions = [...data.values]
        }
    }


    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: AUEMPSTATUS_FIELD })
    getPicklistValuesForAUEMPStatus({ data, error }) {
        if (error) {
            // TODO: Error handling
            console.error(error)
        } else if (data) {
            this.aeOptions = [...data.values]
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: NATUREPHCH_FIELD })
    getPicklistValuesForNature({ data, error }) {
        if (error) {
            // TODO: Error handling
            console.error(error)
        } else if (data) {
            this.npcOptions = [...data.values]
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: PROOFD_FIELD })
    getPicklistValuesForProof({ data, error }) {
        if (error) {
            // TODO: Error handling
            console.error(error)
        } else if (data) {
            this.pdOptions = [...data.values]
        }
    }

    connectedCallback() {
        if (this.screen == 'Edit') {
            if (this.applicantId) {
                getApplicant({ applicantId: this.applicantId })
                    .then(data => {
                        if (data != null) {
                            this.maritalValue = data.Marital_Status__c;
                            this.resValue = data.Residential_Status__c;
                            this.phValue = data.Phsically_challenged__c;
                            this.hrValue = data.High_risk_Profile__c;
                            this.auValue = data.AU_Employee__c;
                            this.aeValue = data.AU_Employment_status__c;
                            this.empNameValue = data.Name_of_Employee_AU__c;
                            this.empIdValue = data.AU_Employee_ID__c;
                            this.npcValue = data.Natutre_of_Phsically_challenge__c;
                            this.pdValue = data.Proof_of_Disablity__c;
                            this.spouseValue = data.Spouse_Name__c;
                            if(this.phValue == 'Yes'){
                                this.isPhysicalChg = true;
                            }
                            else{
                                this.isPhysicalChg = false;
                            }
                            if(this.auValue == 'Yes'){
                                this.isAUEmployee = true;
                            }
                            else{
                                this.isAUEmployee = false;
                            }
                            if(this.maritalValue == 'Married'){
                                this.spousNameRequired = true;
                            }
                            else{
                                this.spousNameRequired = false;
                            }
                        }

                    })
                    .catch(error => {
                        console.log('error in getApplicant' + JSON.stringify(error));

                    })

            }


        }
        else if (this.screen == 'New') {
            this.maritalValue = '';
            this.resValue = '';
            this.phValue = '';
            this.hrValue = '';
            this.auValue = '';
            this.aeValue = '';
            this.empNameValue = '';
            this.empIdValue = '';
            this.npcValue = '';
            this.pdValue = '';
            this.isPhysicalChg = false;
            this.isAUEmployee = false;
            this.spouseValue = this.spouseName;
            this.spousNameRequired = false;
        }
        this.getApplicantsData(); // 26 JUL
    }


    handleChange(event) {
        let picklistName = event.target.name;
        let picklistValue = event.target.value;
        if (picklistName == 'Marital_Status__c') {
            this.maritalValue = picklistValue;
            if(this.maritalValue == 'Married'){
                this.spousNameRequired = true;
            }
            else{
                this.spousNameRequired = false;
                this.spouseValue = '';
            }
            //custom event for R2
            const selectedEvent = new CustomEvent("changeddetails", { detail: {
                fieldName: picklistName,
                fieldValue: picklistValue
               
            }});
            this.dispatchEvent(selectedEvent);
        }
        if (picklistName == 'Residential_Status__c') {
            this.breReRunFields.push('Residential_Status__c');
            this.resValue = picklistValue;
        }
        if (picklistName == 'Phsically_challenged__c') {
            this.phValue = picklistValue;
            if (this.phValue == 'Yes') {
                this.isPhysicalChg = true;
                
            }
            else if (this.phValue == 'No') {
                this.isPhysicalChg = false;
                this.npcValue = '';
                this.pdValue = '';
            }

        }
        if (picklistName == 'AU_Employee__c') {
            this.breReRunFields.push('AU_Employee__c');
            this.auValue = picklistValue;
            if (this.auValue == 'Yes') {
                this.isAUEmployee = true;
                const selectedEvent = new CustomEvent("auemployee", { detail: {
                    fieldName: picklistName,
                    fieldValue: picklistValue, //added new attributes in detail for R2
                    screen: this.screen,
                    auval: this.auValue
                   
                }});
                this.dispatchEvent(selectedEvent);
            }
            else if (this.auValue == 'No') {
                const selectedEvent = new CustomEvent("auemployee", {detail: {
                    fieldName: picklistName,
                    fieldValue: picklistValue, //added new attributes in detail for R2
                    screen: this.screen,
                    auval: this.auValue
                }});
                
                this.dispatchEvent(selectedEvent);

                this.isAUEmployee = false;
                this.aeValue = '';
                this.empNameValue = '';
                this.empIdValue = '';
            }

        }
        if (picklistName == 'High_risk_Profile__c') {
            this.breReRunFields.push('High_risk_Profile__c');
            this.hrValue = picklistValue;
        }
        if (picklistName == 'Name_of_Employee_AU__c') {
            this.empNameValue = picklistValue;
        }
        if (picklistName == 'AU_Employee_ID__c') {
            this.empIdValue = picklistValue;
        }
        if (picklistName == 'AU_Employment_status__c') {
            this.aeValue = picklistValue;
        }
        if (picklistName == 'Natutre_of_Phsically_challenge__c') {
            this.npcValue = picklistValue;
        }
        if (picklistName == 'Proof_of_Disablity__c') {
            this.pdValue = picklistValue;
        }
        if (picklistName == 'Spouse_Name__c') {
            this.spouseValue = picklistValue;
        }
    }

    sendEvent(){
        const selectedEvent = new CustomEvent("auemployee", { detail: this.screen});
        this.dispatchEvent(selectedEvent);
    }

    @api
    updateApplicantData( typeOfEmploymentValue ) {
        
        if(this.isInputValid()){
            if (this.applicantId != null && this.applicantId != '' && this.applicantId != undefined) {
                if( typeOfEmploymentValue?.toLowerCase() === 'housewife' && this.maritalValue?.toLowerCase() === 'single' ){
                    showToastMessage( this, '', 'error', singleWithEmploymentHouseWife );
                    return false;
                }
                var applicant = { 'marital': this.maritalValue, 'residential': this.resValue, 'physical': this.phValue, 'highrisk': this.hrValue, 'auemp': this.auValue, 'auname': this.empNameValue, 'auid': this.empIdValue, 'austatus': this.aeValue, 'nature': this.npcValue, 'proof': this.pdValue,'spouse':this.spouseValue };
                updateApplicant({ applicantId: this.applicantId, wrapper:JSON.stringify(applicant) })
                    .then(data => {
                        /*checkMaterialFields({
                            strScreen: 'Land Details',
                            strLoanId: this.recordId,
                            lstFieldsAPI : this.breReRunFields
                
                        }).then(data => {
                
                        })
                        .catch(error => {
                            console.log('error in material' + JSON.stringify(error));
                        })*/
                        console.log('Success');
    
                    })
                    .catch(error => {
                        console.log('error in updateApplicant' + JSON.stringify(error));
    
                    })
            }
            return true;

        }
        else{
            return false;
        }
        

    }

    
    isInputValid() {
        let isValid = true;
       

        let inputFields = this.template.querySelectorAll(".validate");
        inputFields.forEach(inputField => {
            if (!inputField.value) {
                inputField.setCustomValidity("Complete this field");
                inputField.reportValidity();
                isValid = false;
            } else {
                inputField.setCustomValidity('');
                inputField.reportValidity();
            }
        });
        return isValid;
    }
    // R2 1971 Modified this Method
    getApplicantsData(){ //26 JUL
    console.log('this.applicantIdinAddtional-->' +this.applicantId);
        getApplicant({ applicantId :this.applicantId})
        .then(data => {
            if(data){
                this.customerType = data.Customer_Type__c;
                console.log('this.customerType--> ' + this.customerType);
                if(this.customerType == 'Individual'){
                    this.isMaritalStatus = true;
                }else{
                    this.isMaritalStatus = false;
                }
                // R2 1971
                 if (data != undefined) {
                            console.log('@@in edit' + JSON.stringify(data));
                            this.maritalValue = data.Marital_Status__c;
                            this.resValue = data.Residential_Status__c;
                            this.phValue = data.Phsically_challenged__c;
                            this.hrValue = data.High_risk_Profile__c;
                            this.auValue = data.AU_Employee__c;
                            this.aeValue = data.AU_Employment_status__c;
                            this.empNameValue = data.Name_of_Employee_AU__c;
                            this.empIdValue = data.AU_Employee_ID__c;
                            this.npcValue = data.Natutre_of_Phsically_challenge__c;
                            this.pdValue = data.Proof_of_Disablity__c;
                            this.spouseValue = data.Spouse_Name__c;
                            if(this.phValue == 'Yes'){
                                this.isPhysicalChg = true;
                            }
                            else{
                                this.isPhysicalChg = false;
                            }
                            /* START - SFAU-5608 */
                            if (this.auValue == 'Yes') {
                                this.isAUEmployee = true;
                                const selectedEvent = new CustomEvent("auemployee", { detail: {
                                    screen: this.screen,
                                    auval: this.auValue
                                
                                }});
                                this.dispatchEvent(selectedEvent);
                            }
                            else if (this.auValue == 'No') {
                                const selectedEvent = new CustomEvent("auemployee", {detail: {
                                    screen: this.screen,
                                    auval: this.auValue
                                }});
                                
                                this.dispatchEvent(selectedEvent);
                
                                this.isAUEmployee = false;
                                this.aeValue = '';
                                this.empNameValue = '';
                                this.empIdValue = '';
                            }
                            /* END SFAU-5608 */
                            if(this.maritalValue == 'Married'){
                                this.spousNameRequired = true;
                            }
                            else{
                                this.spousNameRequired = false;
                            }


                            console.log('@@in edit' + this.maritalValue);
                        }
                this.disableFieldsAsPerMetadata();
            }
           
        })
        .catch(error => {
            console.log('error in getApplicantsData' +error);
            
        })
    }//END

    async disableFieldsAsPerMetadata(){
        this.fieldsToBeDisabled = await getMaterialFields({strScreen:'Land Details',strLoanId:this.recordId});
        if(this.fieldsToBeDisabled){
            this.fieldsToBeDisabled.forEach((input=>{
                if(this.template.querySelectorAll('[data-name="'+input+'"]')){
                    this.template.querySelectorAll('[data-name="'+input+'"]').forEach((inputToBeDisabled=>{
                        inputToBeDisabled.disabled = true
                    }))
                }
            }))
        }
        this.isLoading=false
    }
}