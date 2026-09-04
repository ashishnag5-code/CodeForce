import { LightningElement,api,wire, track } from 'lwc';
import APPLICANTFINANCIALDETAILS_OBJECT from '@salesforce/schema/Applicant_Financials_Details__c';
import getVisibleFields from '@salesforce/apex/financeController.getVisibleFields';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import getActiveFinancialRecord from '@salesforce/apex/FinancialViewTemplateR2Controller.getActiveFinancialRecord';
import markRecordsInactive from '@salesforce/apex/AgricultureIncomeDetailsController.deleteFinancialRecords'; // R2 Updated
import renderDeleteAction from '@salesforce/apex/AgricultureIncomeDetailsController.renderDeleteAction'; //R2


export default class DocumentedAuditedChildComponent extends LightningElement {
    isDelete = true; //R2
    //API Attributes
    @api existingDetails;
    @api key;
    @api applicantId;
    @api spinnerImage;
    @api loanAppId;
    @api isMobile;
    @api isR2;
    keyVal;
    finId;
    acc;
    parentRecordId;
   //Array Attributes
    documentedfinancialRecord={};

    //Decimal Attributes
    turnOver=0;
    grossturnoverMonthly=0;
    annualNetProfit=0;
    monthlyNetProfit=0;
    annualDepreciation=0;
    monthlyDepreciation=0;
    annualInterestLoan=0;
    monthlyInterestLoan=0;
    annualnonchash=0;
    monthlynoncash=0;
    annualtotalIncome=0;
    monthlytotalIncome=0;

    //Boolean Attributes
    isLoaded=false;
    rendeauditedFinaceTemplate=true;
    showEditView= false;
    readonly = true;
    @track readAttribute = false;
    @track editSave = false;
    isButtonDisabled = false;
    
    @api 
    get keyValue(){
        return this.keyVal;
    }
    set keyValue(value){
        this.keyVal = value;
    }

    @api 
    get financialId(){
        return this.finId;
    }
    set financialId(value){
        this.finId = value;
        this.documentedfinancialRecord.Applicant_Financials__c = this.finId;
    }

    connectedCallback(){
        this.isButtonDisabled = false;
        this.getVisibleFieldsMetadata();
        if(this.existingDetails!='' && this.existingDetails!=null){
            this.showEditView = true;
         }
         this.handleDeleteVisbility();//R2
    }
    
    getVisibleFieldsMetadata(){
        getVisibleFields({ strScreen : 'Documented- With Audited Financial',Stage: 'QDE'})
		.then(result => {
			console.log('result is '+JSON.stringify(result));
            result.forEach(input => {
                this.template.querySelector('[data-id="'+input+'"]').classList.remove('slds-hide');
            });
		})
		.catch(error => {
            console.log('result is '+JSON.stringify(error));
		})
    }
    

    @wire(getObjectInfo, { objectApiName: APPLICANTFINANCIALDETAILS_OBJECT })
    objectInfo;

    get recordTypeId() {
        // Returns a map of record type Ids 
        const rtis = this.objectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'Documented With Audited financial');
    }
    //R2
    async handleDeleteVisbility(){
        const isDelete = await renderDeleteAction({ recordId: this.loanAppId});
        this.isDelete = isDelete;
        console.log('isDelete-->' +isDelete);
    }


    handleChange(event){
        this.documentedfinancialRecord[event.target.name] = event.target.value;
        let fieldName = event.target.name;
        let fieldValue = event.target.value;
        
        if(fieldName=='Annual_Turnover__c'){
            this.turnOver = parseFloat(fieldValue);
            this.grossturnoverMonthly = this.handleMonth(this.turnOver);
        }

        if(fieldName=='Annual_Net_Profit__c'){
            this.annualNetProfit = parseFloat(fieldValue);
            this.monthlyNetProfit =this.handleMonth(this.annualNetProfit);
        }

        if(fieldName=='Annual_Depreciation__c'){
            this.annualDepreciation = parseFloat(fieldValue);
            this.monthlyDepreciation =this.handleMonth(this.annualDepreciation);
        }

        if(fieldName=='Annual_Interest_Paid_On_Loans__c'){
            this.annualInterestLoan = parseFloat(fieldValue);
            this.monthlyInterestLoan =this.handleMonth(this.annualInterestLoan);
        }

        if(fieldName=='Annual_Non_Cash_Expenses__c'){
            this.annualnonchash = parseFloat(fieldValue);
            this.monthlynoncash =this.handleMonth(this.annualnonchash);
            
        }
       /* if(fieldName=='Annual_Total_Income__c'){
            this.annualtotalIncome = parseFloat(fieldValue);
            this.monthlytotalIncome =this.handleMonth(this.annualtotalIncome);
        }*/
    }

     handleMonth(turnoverval){
        const monthly = turnoverval/12;
        return monthly;
    }

    calculateTotalIncome(){
        const annualIncome = this.annualNetProfit + this.annualDepreciation + this.annualInterestLoan +this.annualnonchash;
        this.annualtotalIncome = annualIncome;
        this.monthlytotalIncome = this.handleMonth(this.annualtotalIncome);
        // this.turnOver
    }

    async handleSubmit(){
       
       console.log('this.keyVal-->' +this.keyVal);
       this.handleFieldMappings();
       if(this.isR2){
            this.documentedfinancialRecord.Row_Instance__c = this.keyVal;
            this.parentRecordId = await getActiveFinancialRecord({applicantId :this.applicantId, rowIndex : parseInt(this.keyVal)});
            if(this.parentRecordId){
                this.documentedfinancialRecord.Id = this.parentRecordId; 
            }
        }
        const fields = this.documentedfinancialRecord;
        console.log('documentedfinancialRecord-->' +JSON.stringify(this.documentedfinancialRecord));
        const recordInput = { apiName: APPLICANTFINANCIALDETAILS_OBJECT.objectApiName, fields };
         // Creates the event with the data.
         if(this.isInputValid()){
            this.isButtonDisabled = true;
             const selectedEvent = new CustomEvent("docauditedsubmit", {
                // detail: this.salaryfinancialRecord
                 detail:{
                    record:this.documentedfinancialRecord,
                    template:'audited',
                    key: this.keyValue
                }
             });

             // Dispatches the event.
             this.dispatchEvent(selectedEvent);
             this.editSave = true;
          this.readAttribute=true;
             if(this.isR2){
                this.readAttribute = true;
                this.editSave = false;
              }
         }
     }

    handleFieldMappings(){
        console.log('recordType-->' + this.recordTypeId);
        this.documentedfinancialRecord.RecordTypeId =  this.recordTypeId;
        //this.documentedfinancialRecord.Applicant_Financials__c = this.financialId;
        this.documentedfinancialRecord.Applicant__c=this.applicantId;
        this.documentedfinancialRecord.Monthly_Turnover__c = this.grossturnoverMonthly;
        this.documentedfinancialRecord.Monthly_Net_Profit__c = this.monthlyNetProfit;
        this.documentedfinancialRecord.Monthly_Depreciation__c = this.monthlyDepreciation;
        this.documentedfinancialRecord.Monthly_Interest_Paid_on_Loans__c = this.monthlyInterestLoan;
        this.documentedfinancialRecord.Monthly_Non_Cash_Expenses__c = this.monthlynoncash;
        this.documentedfinancialRecord.Annual_Total_Income__c = this.annualtotalIncome;
        this.documentedfinancialRecord.Monthly_Total_Income__c = this.monthlytotalIncome;
       
    }

    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll(".validate");
        inputFields.forEach(inputField => {
            console.log('inputField-->' +inputField.value);
            if (!inputField.value) {
                inputField.setCustomValidity("Complete this field");
                inputField.reportValidity();
                isValid = false;
            }
            if (inputField.value ==0) {
                inputField.setCustomValidity("Complete this field");
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }
    @api
    handledocumentedReadOnly(){
        console.log('inside set '+this.readAttribute+' '+this.editSave);

        this.readAttribute = true;
        this.editSave = false;
        console.log('inside set '+this.readAttribute+' '+this.editSave);

        
    }
    handleCancel(){
        this.readAttribute = true;
        this.editSave = false;
    }
    handleEdit(){
        this.readAttribute = false;
        this.editSave = true;
        if(this.isR2){
            this.isButtonDisabled = false;
        }
    }

    handleUpdate(){
        this.handleFieldMappings();
          // Creates the event with the data.
          const selectedEvent = new CustomEvent("auditedupdate", {
            detail:{
                record:this.documentedfinancialRecord,
                template:'audited',
                key: this.keyValue
            }            
            /*detail: this.documentedfinancialRecord,
            key: this.keyValue,
            template :'audited'*/
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
    handleEditSubmit(event) {
        event.preventDefault();
       //this.handleFieldMappings();
        const fields = event.detail.fields;
        fields.Monthly_Turnover__c = this.grossturnoverMonthly;
        fields.Monthly_Net_Profit__c = this.monthlyNetProfit;
        fields.Monthly_Depreciation__c = this.monthlyDepreciation;
        fields.Monthly_Interest_Paid_on_Loans__c = this.monthlyInterestLoan;
        fields.Monthly_Non_Cash_Expenses__c = this.monthlynoncash;
        fields.Annual_Total_Income__c = this.annualtotalIncome;
        fields.Monthly_Total_Income__c = this.monthlytotalIncome;
        
        console.log('fields-->' +JSON.stringify(fields));
         this.template.querySelector('lightning-record-edit-form').submit(fields);
             console.log('onsubmit event recordEditForm' + JSON.stringify(event.detail.fields));
    }
    handleRowAction(event){
        this.readonly = false;
    }
    handleEditCancel(event){
        this.readonly = true;
        
    }
    handleSuccess(event) {
        //  this.isLoaded = true;
        console.log('onsuccess event recordEditForm', event.detail.id);
        this.showMessage('Record Updated Successfully', 'success');
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

    redirectHome(){
        this.showEditView = false;
        const selectedEvent = new CustomEvent("home", {
            detail:{
                redirect:false,
                template:'documentaudited'
            }
        });
         this.dispatchEvent(selectedEvent);
    }

    handleEnableFetchDetails(event){
        
    }
    handleOtherIncome(event){ //jul8
        const selectedEvent = new CustomEvent("otherincome", { 
            detail: { 
                redirect: false,
                template: 'documentaudited'
            }
        });
        this.dispatchEvent(selectedEvent);
    }

      // R2 || START
   async handleDeleteRow(event){
    console.log('existingDetails-->' +JSON.stringify(this.existingDetails));
    if(this.existingDetails.length !=0){
        this.handlemarkRecordsInactive( this.existingDetails[0].Id);
    }else{
        this.parentRecordId = await getActiveFinancialRecord({applicantId :this.applicantId, rowIndex : parseInt(this.keyVal)});
        this.handlemarkRecordsInactive( this.parentRecordId);
       
    }
}

handlemarkRecordsInactive(recordId){
    markRecordsInactive({afd :recordId}).then((data)=>{
        this.handleResetValues(); 
    }).catch((error)=>{
    })
}

handleResetValues(){
    this.handleResetAttributes();
    this.getVisibleFieldsMetadata();
    this.dispatchEvent(new CustomEvent('deletedrecord',{
                detail: ''
    }));


}
handleEditDelete(event){
    let recordId = event.detail;
    this.handlemarkRecordsInactive(recordId);
}

handleResetAttributes(){
    this.yearVal ='';
    this.turnOver =undefined;
    this.grossturnoverMonthly =undefined;
    this.annualNetProfit =undefined;
    this.bnameVal ='';
    this.monthlyNetProfit=undefined;
    this.annualDepreciation=undefined;
    this.monthlyDepreciation = undefined;
    this.annualInterestLoan = undefined;
    this.monthlyInterestLoan = undefined;
    this.annualnonchash = undefined;
    this.monthlynoncash = undefined;
    this.annualtotalIncome = undefined;
    this.monthlytotalIncome = undefined;
    this.existingDetails=[];
    this.showEditView = false;
    this.showViewForm = false;
    this.salaryView = true;   
    this.readAttribute = false; //
    this.isButtonDisabled = false;
}
//END
}