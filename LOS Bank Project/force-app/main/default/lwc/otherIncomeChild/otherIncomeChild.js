import { LightningElement, track, wire, api } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import APPLICANTFINANCIALDETAILS_OBJECT from '@salesforce/schema/Applicant_Financials_Details__c';
import METHODOFASSESSMENT from '@salesforce/schema/Applicant_Financials_Details__c.Method_Of_Assesment__c';
import OTHERINCOMEPICKLIST from '@salesforce/schema/Applicant_Financials_Details__c.Other_Income_Picklist__c';
import markRecordsInactive from '@salesforce/apex/AgricultureIncomeDetailsController.deleteFinancialRecords'; // R2 Updated
import upsertIncome from '@salesforce/apex/AgricultureIncomeDetailsController.upsertIncome';
import getVisibleFieldsForLoanDetails from '@salesforce/apex/AgricultureIncomeDetailsController.getVisibleFieldsForLoanDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import renderDeleteAction from '@salesforce/apex/AgricultureIncomeDetailsController.renderDeleteAction'; //R2
 
export default class OtherIncomeChild extends LightningElement {
     isDelete = true; //R2
    @api financialId;
    @api applicantId;
    recordTypeId;
    @api loanId

    @track isIncomeTypeOther = false;
    @track methodOfAssessmentOptions ='';
    @track otherIncomeOptions='';
    
    record={}
    
    Other_Income_Picklist__c=''
    Other_If_Any__c=''
    Monthly_Income__c=0
    Method_Of_Assesment__c=''
    Id=''

    @api changedData;

    edit=false;
    loadSpinner = false;
    readOnly = false;
    showRecordViewForm = false;

    displayButtons=true;
    @api isR2 //R2-60
    keyval
    @api 
    get sendKey(){
        return this.keyval
    }
    set sendKey(value){
        this.keyval = value
        if(value){
            this.keyId = value
        }
    }

    connectedCallback(){
        this.getVisibleFields();
        this.handleDeleteVisbility();//R2
    }
    
    getVisibleFields(){
        getVisibleFieldsForLoanDetails({strScreen :'Other Income', strStage :'QDE', strProfile :'' })
        .then(result => {
            result.forEach(input => {
                this.template.querySelectorAll('[data-id="'+input+'"]').forEach(element =>{
                    element.classList.remove('slds-hide');
                })
            });
            if(this.isR2 && this.edit){
                this.template.querySelector('lightning-accordion').activeSectionName=""
            }
        })
        .catch(error => {
            console.log('result is '+error);
        })
    }

    remo;
    @api
    get newRecord(){
        return this.remo;
    }
    set newRecord(value){
        this.remo = value;
        if(value){
            this.record = JSON.parse(JSON.stringify(value));
            this.handleNewMappings();
            if(this.record.Id){
                this.edit=true
            }else{
                this.edit=false
            }
        }
    }
    //R2
    async handleDeleteVisbility(){
    const isDelete = await renderDeleteAction({ recordId: this.loanId});
    this.isDelete = isDelete;
    console.log('isDelete-->' +isDelete);
    }

    handleClose(event){
        if(this.record.Id){
            this.showRecordViewForm = true 
             
        }
        this.readOnly = true;
        this.edit = true; 
    }

    handleEdit(event){
        
        this.readOnly = false;
        this.edit = false; 
        this.showRecordViewForm = false
        this.getVisibleFields();
        if(this.isR2){
            this.template.querySelector('lightning-accordion').activeSectionName="A"
        }
    }

    setStringDefaultValues(data){
        return data?data:''
    }

    setNumericDefaultValues(data){
        if(data){
            data = parseFloat(data)
        }
        return data?parseFloat(data.toFixed(2)):0
    }

    handleMappings(){
        if(this.recordTypeId)
            this.record.RecordTypeId = this.recordTypeId
        if(this.applicantId)
            this.record.Applicant__c = this.applicantId; 
        if(this.financialId){
            this.record.Applicant_Financials__c = this.financialId;
        }
        
        this.record.Other_Income_Picklist__c = this.setStringDefaultValues(this.Other_Income_Picklist__c)
        this.record.Other_If_Any__c = this.setStringDefaultValues(this.Other_If_Any__c)
        this.record.Monthly_Income__c = this.setStringDefaultValues(this.Monthly_Income__c)
        this.record.Method_Of_Assesment__c = this.setStringDefaultValues(this.Method_Of_Assesment__c)
        
        if(this.Id){
            this.record.Id = this.Id;
        }

    }

    handleNewMappings(){
        if(this.record.RecordTypeId)
            this.recordTypeId = this.record.RecordTypeId
        if(this.record.Applicant__c)
        this.applicantId = this.record.Applicant__c
        if(this.record.Applicant_Financials__c)
            this.financialId= this.record.Applicant_Financials__c; 

        this.Other_Income_Picklist__c = this.setStringDefaultValues(this.record.Other_Income_Picklist__c)
        if(this.Other_Income_Picklist__c == 'Other'){
            this.isIncomeTypeOther = true
        }
        else{
            this.isIncomeTypeOther=false
        }
        this.Other_If_Any__c = this.setStringDefaultValues(this.record.Other_If_Any__c)
        this.Monthly_Income__c = this.setStringDefaultValues(this.record.Monthly_Income__c)
        this.Method_Of_Assesment__c = this.setStringDefaultValues(this.record.Method_Of_Assesment__c)

        if(this.record.Id){
            this.Id = this.record.Id;
        }
        this.setModeToReadOnlyInChild();
    }

    setModeToReadOnlyInChild(){
        
        this.displayButtons=false
        if(this.record.Id){
            this.edit=true
            this.readOnly=true
            this.showRecordViewForm=true
        }else{
            this.edit=false
            this.readOnly=false
            this.showRecordViewForm=false
        }
        
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title, 
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    async saveIncome(event){
        //4733 start
        const isEditRestricted = await restricAccess({compName: 'financialView' ,loanId: this.loanId})
        if(isEditRestricted){
            const evt = new ShowToastEvent({
                title: 'Access Restricted',
                message: 'You do not have access to edit Financial Details',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            return
        }
        //4733 end
        this.handleMappings();

        if(this.handleValidations()){
            upsertIncome({record: this.record}).then((data)=>{
                this.record.Id = data.Id;
                this.readOnly = true;
                this.edit = true;
                this.showRecordViewForm=true;
    
                const selectedEvent = new CustomEvent("calculatemonthlyincome", {
                    detail:{
                            template: 'other',
                        }                
                    });
                    this.dispatchEvent(selectedEvent);
            })
        }
        
    }

    

    @wire(getObjectInfo, { objectApiName: APPLICANTFINANCIALDETAILS_OBJECT })
    objectInfo({data, error}){
        if (data){
            const rtis = data.recordTypeInfos;
            this.recordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Other Income');
        }
    };

    @wire (getPicklistValues, {recordTypeId: '$recordTypeId', fieldApiName: METHODOFASSESSMENT})
    retrieveMethodOfAssessment({error, data}){
        if(data){
            this.methodOfAssessmentOptions = data.values;
        }
    }

    @wire (getPicklistValues, {recordTypeId: '$recordTypeId', fieldApiName: OTHERINCOMEPICKLIST})
    retrieveOtherIncome({error, data}){
        if(data){
            this.otherIncomeOptions = data.values;
        }
    }

    handleChange(event){
        var key = event.target.accessKey;
        var value = event.target.value;
        var name = event.target.name;

        if(name == 'Other_Income_Picklist__c'){
            this.Other_Income_Picklist__c = value;
            if(value == 'Other'){
                this.isIncomeTypeOther = true;
            }
            else{
                this.isIncomeTypeOther = false;
                this.Other_If_Any__c = '';
            }
        }
        else if(name == 'Other_If_Any__c'){
            this.Other_If_Any__c = value;
        }
        else if(name == 'Monthly_Income__c'){
            this.Monthly_Income__c = value;
        }
        else if(name == 'Method_Of_Assesment__c'){
            this.Method_Of_Assesment__c = value;
        }

    }

    handleValidations() {
        var valid;        
        const allValid1 = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
            
        }, true);
        const allValid2 = [
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
            
        }, true);

        if (allValid1 && allValid2) {
            valid = true
        } else {
            valid = false;
        }
        return valid;
    }

    /*addAdditionalOtherIncome(){
        this.keyIndex = this.keyIndex+1;
        this.activeSections.push(this.otherIncomeList.length+1);
        this.otherIncomeList.push({idVal: this.keyIndex, Name: this.otherIncomeList.length+1, readOnly: false, Monthly_Income__c:0});
        this.getFields();
        
    }*/
   
    handleDeleteRow(event){

        let list=[];
        list = this.otherIncomeList;
        console.log('list-->' +JSON.stringify(this.record));
       /* var record = list.filter(function (element) {
            return parseInt(element.idVal) == parseInt(event.target.accessKey);
        
        })*/
        let record = this.record;
        console.log('record-->' +JSON.stringify(record));
        if(record.Id){
            this.showRecordViewForm = false;
            markRecordsInactive({afd :record.Id}).then((data)=>{
                console.log('Success');
                const selectedEvent = new CustomEvent("calculatemonthlyincome", {
                    detail:{ 
                        template: 'other',
                    }                
                });
                this.dispatchEvent(selectedEvent);
                this.dispatchEvent(new CustomEvent('deletedrecord',{
                    detail: this.keyId
                }));
                this.dispatchEvent(new CustomEvent('calculatetotal',{
                    detail:{
                        amount: this.Monthly_Income__c,
                        key: this.keyId,
                        isDeleted: true
                    }
                }));
               // this.showToast('','Other Income Details Deleted Successfully','Success');
            }).catch((error)=>{
                console.log('Error')

            })
        }
       /* list = list.filter(function (element) {
            return parseInt(element.idVal) != parseInt(event.target.accessKey);
        
        })
        var sections=[]
        var Name = 1;
        list.forEach(element => {
            element.Name = Name;
            sections.push(Name);
            Name++; 
        });
        this.otherIncomeList = list;
        this.activeSections=sections;*/
    }

}