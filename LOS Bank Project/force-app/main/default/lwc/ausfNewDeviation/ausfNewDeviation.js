import { LightningElement, api, wire, track} from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import manual_Deviation_Master_OBJ from '@salesforce/schema/Manual_Deviation_Master__c';
import Deviation_Master_Department_FIELD from '@salesforce/schema/Manual_Deviation_Master__c.Department__c';
import DEVIATION_OBJECT from '@salesforce/schema/Deviation__c';
import DEVIATION_ACTUAL_FIELD from '@salesforce/schema/Deviation__c.Actual_Value__c';
import DEVIATION_POLICY_FIELD from '@salesforce/schema/Deviation__c.Policy_Value__c';
import DEVIATION_VARIENCE_FIELD from '@salesforce/schema/Deviation__c.Variance__c';
import DEVIATION_LOANAPPLICATION_FIELD from '@salesforce/schema/Deviation__c.Loan_Application__c';
import DEVIATION_LEVEL_FIELD from '@salesforce/schema/Deviation__c.Level__c';
import DEVIATION_SOURCE_FIELD from '@salesforce/schema/Deviation__c.Source__c';
import DEVIATION_TYPE_FIELD from '@salesforce/schema/Deviation__c.Deviation_Type__c';
import DEVIATION_DETAILS_FIELD from '@salesforce/schema/Deviation__c.Details__c';
import DEVIATION_DEPARTMENT_FIELD from '@salesforce/schema/Deviation__c.Department__c';
import DEVIATION_ACTIVE from '@salesforce/schema/Deviation__c.Active__c';
import DEVIATION_MITIGATE from '@salesforce/schema/Deviation__c.Mitigates__c';
import DEVIATION_ID from '@salesforce/schema/Deviation__c.Id';
import getRecords from '@salesforce/apex/AUSFNewDeviation.getRecords';
import getDeviationRecords from '@salesforce/apex/AUSFNewDeviation.getDeviationRecords';
import {createRecord,updateRecord} from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getUserDetails from '@salesforce/apex/AUSFNewDeviation.getUserDetails';
import My_Resource from '@salesforce/resourceUrl/ausfIcons';
import { getSpinnerImage } from 'c/customSpinner';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';//4733

export default class AusfNewDeviation extends LightningElement {

    deviationDetails   = My_Resource + '/ausfIcons/Deviation-Details.png';
    isSourceBRE=false
    @api spinnerImage;
    isLoading;
    @api recordId;
    isDisabled=false
    departmentVal = '';
    ruleTypeVal = '';
    deviationDescriptionVal = '';
    deviationLevelVal = '';
    isDeviationLevelRequired = false;
    isDeviationDescRequired = false;
    isRuleTypeRequired = false;
    @track isEditRestricted//4733

    policyValue = '';
    actualValue = '';
    variance = '';
    mitigates = '';

    deviationMasterData;
    deviationData;

    ruleTypePicklist = [];
    descriptionPicklist = [];
    deviationLevel = [];

    loanApplicationId; 
    deviationId;  
    
    isEditLoad = false;

    buttonLabel;


    // this executes when your LWC is loaded
    async connectedCallback() {
        const params = new Proxy(new URLSearchParams(window.location.search), {
            get: (searchParams, prop) => searchParams.get(prop)
        });
        let inContextOfRef = params.inContextOfRef;
        if (inContextOfRef.startsWith("1\.")) { inContextOfRef = inContextOfRef.substring(2); }
        var addressableContext = JSON.parse(window.atob(inContextOfRef));
        this.loanApplicationId = addressableContext.attributes.recordId;
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.loanApplicationId);
        }
        //console.log('recordId :' + this.loanApplicationId);
        //this.makeFieldsEditableForUsers();
        if(this.recordId){
            this.buttonLabel = 'Update Deviation';
            this.isEditLoad = true;
            this.showDeviationValue();
        }
        else{
            this.isSourceBRE=false
            this.buttonLabel = 'Create Deviation';
        }
        this.setIsEditRestricted();
        //this.isEditRestricted = await restricAccess({compName: 'ausfNewDeviation' ,loanId: this.loanApplicationId})
    }

    async setIsEditRestricted(){
        this.isEditRestricted = await restricAccess({compName: 'ausfNewDeviation' ,loanId: this.loanApplicationId})
    }


    makeFieldsEditableForUsers(){
        getUserDetails().then((data=>{
            this.isDisabled = (data.Profile && data.Profile.Name == 'Credit Manager')?true:false;
        }))
    }

    @wire(getObjectInfo, { objectApiName: manual_Deviation_Master_OBJ })
    manualDeviationMetadata;

    // now retriving the StageName picklist values of Opportunity
 
    @wire(getPicklistValues,{recordTypeId: '$manualDeviationMetadata.data.defaultRecordTypeId', fieldApiName: Deviation_Master_Department_FIELD})
    manualDeviationDepartmentPicklist;

    handleDepartmentChange(event){
        this.ruleTypeVal = '';
        this.deviationDescriptionVal = '';
        this.deviationLevelVal = '';
        this.departmentVal = event.detail.value;

        //reset all the picklist value
        this.descriptionPicklist = [];
        this.deviationLevel = [];
        
        
            getRecords({ loanId:this.loanApplicationId, department:this.departmentVal})
            .then(data => {
                if (data) {
                    this.deviationMasterData = JSON.parse(JSON.stringify(data));
                    this.generateRuleType();
                }
            }).catch(error => {
                console.log('error is '+JSON.stringify(error));
                console.error(error)
            })
    }


    showDeviationValue(){
        getDeviationRecords({ deviationId:this.recordId})
            .then(data => {
                if (data) {
                    this.deviationData = JSON.parse(JSON.stringify(data));
                    if(this.deviationData.Source__c=='BRE'){
                        this.isSourceBRE=true
                        this.setFields()
                    }else{
                        let deptValueToSend = {detail:{value:this.deviationData.Department__c ? this.deviationData.Department__c : ''}};
                        this.handleDepartmentChange(deptValueToSend);
                        if(this.deviationData.Department__c){
                            this.setFields();
                        }
                    }
                    
                    
                }
            }).catch(error => {
                console.log('error is '+JSON.stringify(error));
                console.error(error)
            })
    }



    generateRuleType(){
        this.ruleTypePicklist = [];
        this.deviationMasterData.forEach(element => {
            let ruleType = {label : element.Rule_Type__c, value:element.Rule_Type__c}
            //let index = this.ruleTypePicklist.indexOf(ruleType);
            if(this.ruleTypePicklist.map(e => e.value).indexOf(element.Rule_Type__c) == -1){
                this.ruleTypePicklist.push(ruleType);
            }
            if(this.isEditLoad){
                this.setDeviationForm();
                this.isEditLoad = false;
            }
        });
        this.isRuleTypeRequired = this.ruleTypePicklist !== undefined && this.ruleTypePicklist !== null && this.ruleTypePicklist.length > 0;
    }

    setDeviationForm(){

        let typeValueToSend = {detail:{value:this.deviationData.Deviation_Type__c ? this.deviationData.Deviation_Type__c : ''}};
        this.handleRoleTypeChange(typeValueToSend);

        let descValueToSend = {detail:{value:this.deviationData.Details__c ? this.deviationData.Details__c : ''}};
        this.handleDescriptionChange(descValueToSend);
        this.setFields()
        
    }

    setFields(){
        this.policyValue = String.valueOf(this.deviationData.Policy_Value__c) ? this.deviationData.Policy_Value__c : null;
        this.actualValue = String.valueOf(this.deviationData.Actual_Value__c) ? this.deviationData.Actual_Value__c : null;
        this.variance = String.valueOf(this.deviationData.Variance__c) ? this.deviationData.Variance__c : null;
        this.loanApplicationId = this.deviationData.Loan_Application__c ? this.deviationData.Loan_Application__c : null;
        this.mitigates = this.deviationData.Mitigates__c ? this.deviationData.Mitigates__c : null;
        this.deviationLevelVal = this.deviationData.Level__c ? this.deviationData.Level__c : null;
        this.ruleTypeVal = this.deviationData.Deviation_Type__c ? this.deviationData.Deviation_Type__c : null;
        this.departmentVal = this.deviationData.Department__c ? this.deviationData.Department__c : null;
        this.deviationDescriptionVal = this.deviationData.Details__c ? this.deviationData.Details__c : null;
        this.mitigates = this.deviationData.Mitigates__c ? this.deviationData.Mitigates__c : null;
    }






    handleRoleTypeChange(event){
        this.descriptionPicklist = [];
        this.deviationLevel = [];
        this.deviationDescriptionVal = '';
        this.deviationLevelVal = '';
        this.ruleTypeVal = event.detail.value;
        let filterData = this.deviationMasterData.filter(element => {
            return (element.Rule_Type__c == this.ruleTypeVal && element.Department__c == this.departmentVal)
        });
        filterData.forEach(filterElement => {
            let description = {label : filterElement.Deviation_Description__c, value : filterElement.Deviation_Description__c}
            if(this.descriptionPicklist.map(e => e.value).indexOf(filterElement.Deviation_Description__c) == -1){
                this.descriptionPicklist.push(description);
            }
        })
        this.isDeviationDescRequired = this.descriptionPicklist !== undefined && this.descriptionPicklist !== null && this.descriptionPicklist.length > 0;
    }



    handleDescriptionChange(event){
        this.deviationLevel = [];
        this.deviationLevelVal = '';
        this.deviationDescriptionVal = event.detail.value;
        let filterData = this.deviationMasterData.filter(element => {
            return (element.Rule_Type__c == this.ruleTypeVal && element.Department__c == this.departmentVal && element.Deviation_Description__c == this.deviationDescriptionVal)
        });
        filterData.forEach(filterElement => {
            let description = {label : filterElement.Deviation_Level__c, value : filterElement.Deviation_Level__c}
            if(this.deviationLevel.map(e => e.value).indexOf(filterElement.Deviation_Level__c) == -1){
                this.deviationLevel.push(description);
                this.deviationLevelVal = filterElement.Deviation_Level__c;
            }
        })
        this.isDeviationLevelRequired = this.deviationLevel !== null && this.deviationLevel !== undefined && this.deviationLevel.length > 0;
    }

    handleLevelChange(event){
        this.deviationLevelVal = event.detail.value;
    }
    handleVarianceChange(event){
        this.variance = event.detail.value;
    }
    handleMitigatesChange(event){
        this.mitigates = event.detail.value;
    }
    
    handleActualValueChange(event){
        this.actualValue = event.detail.value;
        this.calculateVariance();
    }
    handlePolicyChange(event){
        this.policyValue = event.detail.value;
        this.calculateVariance();
    }

    calculateVariance(){
        this.variance = this.policyValue - this.actualValue;
    }

    showToastMessage(title, message, variant, mode){
        const event = new ShowToastEvent({
            title: title,
            variant: variant,
            mode: variant === 'error' ? 'sticky' : 'dismissible',
            message: message
        });
        this.dispatchEvent(event);
    }

    updateBREDeviation(event){
        //4733 start
        if(this.isEditRestricted){
            this.showToastMessage('Access Restricted','You do not have access to edit Deviation Details','error','sticky')
            return
        }
        //4733 end
        this.isLoading=true
        const FIELDS = {};
        FIELDS[DEVIATION_ID.fieldApiName] = this.recordId;
        FIELDS[DEVIATION_MITIGATE.fieldApiName] = this.mitigates;
        const recordInputForUpdate ={fields: FIELDS};
        updateRecord(recordInputForUpdate).then(result => {
            this.isLoading=false
            this.deviationId = result.id;   
            this.navigateToViewDeviationPage(result.id) 
        })
        .catch(error => {
            this.isLoading=false
            console.log(JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: error.body.message,//error.body.output.fieldErrors,
                    variant: 'error',
                    mode : 'sticky'
                }),
            );
        });
                
    }

    createDeviation(){
        //4733 start
        if(this.isEditRestricted){
            this.showToastMessage('Access Restricted','You do not have access to create new Deviation Details','error','sticky')
            return
        }
        //4733 end
        var flag = true;
        const elements1 = this.template.querySelectorAll('lightning-combobox');
        elements1.forEach( input => {
            if((input.options !== null && input.options !== undefined && input.options.length > 0) && 
                (input.value=='' || input.value==null || input.value==='undefined')) {
                input.setCustomValidity("Please add a value");
                flag = false;
            }
            else{
                input.setCustomValidity('');
            }
            input.reportValidity();
        });
        const elements2 = this.template.querySelectorAll('lightning-input');
        elements2.forEach( input => {
            if((input.value=='' || input.value==null || input.value==='undefined')) {
                input.setCustomValidity("Please add a value");
                flag = false;
            }
            else{
                input.setCustomValidity('');
            }
            input.reportValidity();
        });
        const elements3 = this.template.querySelectorAll('lightning-textarea');
        elements3.forEach( input => {
            if((input.value=='' || input.value==null || input.value==='undefined')) {
                input.setCustomValidity("Please add a value");
                flag = false;
            }
            else{
                input.setCustomValidity('');
            }
            input.reportValidity();
        });

        if (flag) {
            this.isLoading=true
            const FIELDS = {};
            FIELDS[DEVIATION_ACTUAL_FIELD.fieldApiName] = this.actualValue;
            FIELDS[DEVIATION_POLICY_FIELD.fieldApiName] = this.policyValue;
            FIELDS[DEVIATION_VARIENCE_FIELD.fieldApiName] = this.variance;
            FIELDS[DEVIATION_LOANAPPLICATION_FIELD.fieldApiName] = this.loanApplicationId;
            FIELDS[DEVIATION_LEVEL_FIELD.fieldApiName] = this.deviationLevelVal;
            FIELDS[DEVIATION_SOURCE_FIELD.fieldApiName] = 'Manual';
            FIELDS[DEVIATION_TYPE_FIELD.fieldApiName] = this.ruleTypeVal;
            FIELDS[DEVIATION_DEPARTMENT_FIELD.fieldApiName] = this.departmentVal;
            FIELDS[DEVIATION_ACTIVE.fieldApiName] = true;
            FIELDS[DEVIATION_DETAILS_FIELD.fieldApiName] = this.deviationDescriptionVal;
            FIELDS[DEVIATION_MITIGATE.fieldApiName] = this.mitigates;
            
            if(this.recordId){
                FIELDS[DEVIATION_ID.fieldApiName] = this.recordId;
                const recordInputForUpdate ={fields: FIELDS};
                updateRecord(recordInputForUpdate)
                    .then(result => {
                        this.isLoading=false
                        console.log('inside update...');
                        this.deviationId = result.id;   
                        this.navigateToViewDeviationPage(result.id) 
                    })
                    .catch(error => {
                        this.isLoading=false
                        console.log(JSON.stringify(error));
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error creating record',
                                message: error.body.message,//error.body.output.fieldErrors,
                                variant: 'error',
                                mode : 'sticky'
                            }),
                        );
                    });
            }else{
                const recordInputForInsert  = {apiName:DEVIATION_OBJECT.objectApiName, fields: FIELDS};
                createRecord(recordInputForInsert)
                    .then(result => {
                        this.isLoading=false
                        this.deviationId = result.id;   
                        this.navigateToViewDeviationPage(this.deviationId)             

                    })
                    .catch(error => {
                        this.isLoading=false
                        console.log(JSON.stringify(error));
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error creating record',
                                message: error.body.message,//error.body.output.fieldErrors,
                                variant: 'error',
                                mode : 'sticky'
                            }),
                        );
                    });
            }
        }
    }


    navigateToViewDeviationPage(pageId) {
            const customEvent = new CustomEvent("getapplicationid", {
              detail: { deviationId : pageId }
            });
            // Fire the custom event
            this.dispatchEvent(customEvent);
    }

}