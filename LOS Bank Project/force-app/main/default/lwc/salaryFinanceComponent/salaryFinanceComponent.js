import { LightningElement,api,wire, track } from 'lwc';
import APPLICANTFINANCIALDETAILS_OBJECT from '@salesforce/schema/Applicant_Financials_Details__c';
import getVisibleFields from '@salesforce/apex/financeController.getVisibleFields';
import { createRecord } from 'lightning/uiRecordApi';
import getActiveFinancialRecord from '@salesforce/apex/FinancialViewTemplateR2Controller.getActiveFinancialRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import opsAccordion from '@salesforce/resourceUrl/opsAccordion';
import FORM_FACTOR from '@salesforce/client/formFactor';
import calculateAverageSalary from '@salesforce/apex/MultipleFileUploadController.calculateAverageSalary'; //june30
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import markRecordsInactive from '@salesforce/apex/AgricultureIncomeDetailsController.deleteFinancialRecords'; // R2 Updated
import renderDeleteAction from '@salesforce/apex/AgricultureIncomeDetailsController.renderDeleteAction'; //R2
export default class SalaryFinanceComponent extends LightningElement {
    isDelete = true; //R2
    //API Attributes
    @api loanAppId
    @api documentType
    @api applicantId;
    @api financialRecord;
    @api existingDetails;
    @api companyDefault;
    @api companyDefaultName
    @api spinnerImage;
    @api isMobile;
    @api cartDataFetched //Neha-3838
    dataUpdatedByUser=false
    dataUpdatedFromCart=false
    @api originalDocVerifiedValue;
    @api isR2;
    parentRecordId
    
    salaryRecord;
    objectInfo;
    finId;
    cartMIData;
    fetchDet;
    companyName;

    //Array Attributes 
    activeSections = ['A', 'B', 'C', 'D'];
    salaryfinancialRecord = {};

    //Boolean Attributes
    renderSalaryFinaceTemplate = true;
    isLoaded = false;
    @track showOtherIncomeSection = false;
    @track showModal = false;
    showViewForm = false;
    readAttribute = false;
    editSave = false;
    showUploadFiles = false;
    @track fetchCartData = false;
    readonly = true;
    showEditView = false;
    isCompanyReadOnly = false;
    salaryView = true;
    isButtonDisabled = false;

    //Decimal Attributes
    otherComponentMonthlyIncome = 0;
    month1Val = 0;
    month2Val = 0;
    month3Val = 0;
    averageMonthlySalary = 0;
    cashVal = 0;
    netVal = 0;
    cartMonth1Val = 0;
    cartMonthlyIncomeData; //june30

    @track isEditRestricted

    @api
    get cartMonthlyIncomeData() {
        return this.cartMIData;
    }
    set cartMonthlyIncomeData(value) {
        this.cartMIData = value;
        if (value) {
            this.handleCartData(value);
        }
    }
    @api
    get fetchDetails() {
        return this.fetchDet;
    }

    set fetchDetails(value) {
        this.fetchDet = value;
        this.fetchCartData = value;
        console.log('this.fetchCartData ' + this.fetchCartData);
    }

    @api
    get financialId() {
        return this.finId;
    }

    set financialId(value) {
        this.finId = value;
        if (this.finId) {
            this.showModal = true;
        }
    }

    async connectedCallback() {
        this.isButtonDisabled = false;
        this.getVisibleFieldsMetadata();
        console.log('insidesalary');
        this.loadMonthlyData(); //june30
        if (this.existingDetails != '' && this.existingDetails != null) {
            console.log('existingDetails-->' +JSON.stringify(this.existingDetails));
            this.month1Val = this.existingDetails[0].First_Month__c;
            this.month2Val = this.existingDetails[0].Second_Month__c;
            this.month3Val = this.existingDetails[0].Third_Month__c;
            this.cashVal = this.existingDetails[0].Salary_Received_in_Cash__c;
            this.netVal = this.existingDetails[0].Monthly_Net_Salary__c;
            this.companyDefault = this.existingDetails[0].Company_Master__c;
            this.showEditView = true;
            this.handleInitialValues();
        }
        this.isEditRestricted = await restricAccess({compName: 'financialView' ,loanId: this.loanAppId})
         //R2 START
         const isDelete = await renderDeleteAction({ recordId: this.loanAppId});
         this.isDelete = isDelete;
         console.log('isDelete-->' +isDelete);
         //END
    }
    getVisibleFieldsMetadata() {
        this.isLoaded = true;
        getVisibleFields({
                strScreen: 'Salary',
                Stage: 'QDE'
            })
            .then(result => {
                console.log('result is ' + JSON.stringify(result));
                result.forEach(input => {
                    this.template.querySelector('[data-id="' + input + '"]').classList.remove('slds-hide');
                });
                this.isLoaded = false;
            })
            .catch(error => {
                this.isLoaded = false;
                console.log('result is ' + JSON.stringify(error));
            })
    }

    loadMonthlyData(){  //june30
        calculateAverageSalary({recordId: this.applicantId}).then((data)=>{
            if(data && data.length>0){
                console.log('salaryData ==>' +JSON.stringify(data));
                if (!this.month1Val && data[0] && data[0].salaryAmount) {
                    this.month1Val = parseFloat(data[0].salaryAmount);
                }
                if (!this.month2Val && data[1] && data[1].salaryAmount) {
                    this.month2Val = parseFloat(data[1].salaryAmount);
                }
                if (!this.month3Val && data[2] && data[2].salaryAmount) {
                    this.month3Val = parseFloat(data[2].salaryAmount);
                }
                this.salaryfinancialRecord.First_Month__c = this.month1Val;
                this.salaryfinancialRecord.Second_Month__c = this.month2Val;
                this.salaryfinancialRecord.Third_Month__c = this.month3Val;
                 
                this.handleAverage();
                this.handleNetSalary();
            }else{
                this.showToastEvent('', 'No Salary Details Found', 'warning');
            }
            
        }).catch((error)=>{
            console.log(error);
        })
    } //end

    handleInitialValues() {
        let data = this.existingDetails;
        for (var key in data) {
            this.averageMonthlySalary = data[key].Average_Monthly_Salary__c;
        }

    }

    @wire(getObjectInfo, {
        objectApiName: APPLICANTFINANCIALDETAILS_OBJECT
    })
    objectInfo;

    get recordTypeId() {
        // Returns a map of record type Ids 
        const rtis = this.objectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === 'Salaried Document');
    }



    handleChange(event) {
        console.log('event-->' + event.target.name);
        this.isButtonDisabled = false;
        this.salaryfinancialRecord[event.target.name] = event.target.value;
        let fieldName = event.target.name;
        let fieldValue = event.target.value;

        if (fieldName == 'First_Month__c') {
            this.cartDataFetched=false
            this.dataUpdatedByUser=true
            this.month1Val = parseFloat(fieldValue);
        }
        if (fieldName == 'Second_Month__c') {
            this.cartDataFetched=false
            this.dataUpdatedByUser=true
            this.month2Val = parseFloat(fieldValue);
        }
        if (fieldName == 'Third_Month__c') {
            this.cartDataFetched=false
            this.dataUpdatedByUser=true
            this.month3Val = parseFloat(fieldValue);
            //this.handleAverage();
        }
        this.handleAverage();
        this.handleNetSalary();
        if (fieldName == 'Salary_Received_in_Cash__c') {
            this.cashVal = parseFloat(fieldValue);
            this.handleNetSalary();
        }
    }

    handleAverage() {
        var mnt1 = 0;
        var mnt2 = 0;
        var mnt3 = 0;
        if (this.month1Val) {
            mnt1 = this.month1Val;
        }
        if (this.month2Val) {
            mnt2 = this.month2Val;
        }
        if (this.month3Val) {
            mnt3 = this.month3Val;
        }

        //const mnt1=  this.month1Val;
        //const mnt2=  this.month2Val;
        //const mnt3=  this.month3Val;

        console.log('mnt1 ' + mnt1 + 'mnt2 ' + mnt2 + 'mnt3 ' + mnt3);
        let cash = this.cashVal;
        const total = (mnt1 + mnt2 + mnt3);
        const average = total / 3;
        
        this.averageMonthlySalary = average;
        this.dispatchEvent(new CustomEvent('averagemonthlysalary', {
            detail: this.averageMonthlySalary
        }));
    }
    handleNetSalary() {
        var cash = 0;
        if(this.cashVal!=undefined){
            cash = this.cashVal;
        }
        const bank = this.averageMonthlySalary;
        if(cash!=null && cash!=NaN && bank!=null && bank!=NaN ){
            const total = cash + bank;
       
            if(total!=NaN && total !=null){
                console.log('total-->' +total);
                this.netVal = total.toFixed(2);
            }
        }
       
       
    }

    handleCartDetailsChange(event) {
            var name = event.target.name;
            var fieldValue = event.target.value;
            if (name == 'First_Month__c') {
                this.cartDataFetched=false
                this.dataUpdatedByUser=true
                this.month1Val = parseFloat(fieldValue);
            }
            if (name == 'Second_Month__c') {
                this.cartDataFetched=false
                this.dataUpdatedByUser=true
                this.month2Val = parseFloat(fieldValue);
            }
            if (name == 'Third_Month__c') {
                this.cartDataFetched=false
                this.dataUpdatedByUser=true
                this.month3Val = parseFloat(fieldValue);
            }
          
    }

   async handleSubmit() {
     if(this.isR2){
        this.parentRecordId = await getActiveFinancialRecord({applicantId :this.applicantId});
        if(this.parentRecordId){
            this.salaryfinancialRecord.Id = this.parentRecordId; 
        }
        }
       
        this.handleFieldMappings();
        this.checkIfDataIsUpdated()
        const fields = this.salaryfinancialRecord;
        this.salaryMI = this.month1Val + this.month2Val + this.month3Val
        console.log('financialRecord-->' + JSON.stringify(this.salaryfinancialRecord));
        const recordInput = {
            apiName: APPLICANTFINANCIALDETAILS_OBJECT.objectApiName,
            fields
        };
        console.log('this.isInputValid()-->' + this.isInputValid());
        
        if (this.isInputValid()) {
            this.isButtonDisabled = true;
            // Creates the event with the data.
            const selectedEvent = new CustomEvent("salarysubmit", {
                // detail: this.salaryfinancialRecord
                detail: {
                    record: this.salaryfinancialRecord,
                    template: 'salary',
                    salaryMonthVal:this.salaryMI,
                    documentedIncome : this.averageMonthlySalary, 
                    docVerified: this.cartDataFetched,
                    assessedIncome:this.cashVal
                }
            });

            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
            this.editSave = true;
            this.readAttribute = true;
            if(this.isR2){
                this.readonly = true;
             }
        }
    }

    handleFieldMappings() {
        console.log('recordType-->' + this.recordTypeId);
        this.salaryfinancialRecord.RecordTypeId = this.recordTypeId;
        //  this.salaryfinancialRecord.Applicant_Financials__c = this.financialId;
        this.salaryfinancialRecord.Monthly_Net_Salary__c = this.netVal;
        this.salaryfinancialRecord.Salary_Received_in_Bank__c = this.averageMonthlySalary;
        this.salaryfinancialRecord.Average_Monthly_Salary__c = this.averageMonthlySalary;
        this.salaryfinancialRecord.Applicant__c = this.applicantId;
        this.salaryfinancialRecord.Company_Master__c = this.companyDefault;
        //this.salaryfinancialRecord.Company_Name__c =  this.companyName;
        this.salaryfinancialRecord.Company_Name__c =this.companyDefaultName;

    }
    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll(".validate");
        inputFields.forEach(inputField => {
            console.log('inputField-->' + inputField.value);
            if(inputField.value != 0){
                if (!inputField.value) {
                    inputField.setCustomValidity("Complete this field");
                    inputField.reportValidity();
                    isValid = false;
                }
            }
           
           /* if (inputField.value == 0) {
                inputField.setCustomValidity("Complete this field");
                inputField.reportValidity();
                isValid = false;
            }*/
        });
        return isValid;
    }

    @api
    handleReadOnly() {
        this.readAttribute = true;
        this.editSave = false;
    }
    handleCancel() {
        this.readAttribute = true;
        this.editSave = false;
        
    }
    handleEdit() {
        this.readAttribute = false;
        this.editSave = true;
        if(this.isR2){
            this.isButtonDisabled = false;
        }
    }

    handleUpdate() {
        this.handleFieldMappings();
        this.checkIfDataIsUpdated()
        // Creates the event with the data.
        const selectedEvent = new CustomEvent("salaryupdate", {
            detail: {
                record: this.salaryfinancialRecord,
                template: 'salary',
                docVerified: this.cartDataFetched,
                otherComponentMonthlyIncome: this.otherComponentMonthlyIncome
            }
        });

        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }



    handleEditSubmit(event) {
        //4733 start
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
        //4733 end

        event.preventDefault();
        //this.handleFieldMappings();

        const fields = event.detail.fields;
        fields.Average_Monthly_Salary__c = this.averageMonthlySalary;
       // fields.Monthly_Income__c = this.averageMonthlySalary;
        fields.Salary_Received_in_Bank__c = this.averageMonthlySalary;
        fields.Company_Master__c = this.companyDefault;
        fields.Company_Name__c = this.companyName;
        if(this.netVal!=null &&   this.netVal!== "NaN" &&this.netVal!== NaN ){
            fields.Monthly_Net_Salary__c = this.netVal;
        }
        if(this.cashVal!=null && this.cashVal!== "NaN" &&this.cashVal!== NaN){
        fields.Salary_Received_in_Cash__c = this.cashVal;
        }
        if (this.fetchCartData) {
            fields.First_Month__c = this.month1Val;
            fields.Second_Month__c = this.month2Val;
            fields.Third_Month__c = this.month3Val;
        }

        console.log('fields-->' + JSON.stringify(fields));

        if (this.isInputValid()) {
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
        
        console.log('onsubmit event recordEditForm' + JSON.stringify(event.detail.fields));
        /*this.dispatchEvent(new CustomEvent('showeditview', { //jul8
            detail: false
        }));*/
       
    }
    handleSuccess(event) {
        if(this.isEditRestricted){
            return;
        }
        console.log('onsuccess event recordEditForm', event.detail.id);
        /*const selectedEvent = new CustomEvent("home", { //jul8
            detail: { 
                redirect: false,
                template: 'assessed'
            }
        });
        this.dispatchEvent(selectedEvent);*/
        this.checkIfDataIsUpdated();
        const selectedEvent = new CustomEvent("otherincome", { 
            detail: { 
                redirect: false,
                template: 'salary',
                docVerified: this.cartDataFetched
            }
        });
        this.dispatchEvent(selectedEvent);
        if(this.isR2){
            this.readonly = true;
        }
    }

    checkIfDataIsUpdated(){
        if(!this.dataUpdatedByUser && !this.dataUpdatedFromCart){
            this.cartDataFetched=this.originalDocVerifiedValue
        }
    }

    handleRowAction(event) {
        this.readonly = false;
        this.showUploadFiles = true;

    }
    handleEditCancel(event) {
        this.readonly = true;
        this.showUploadFiles = false;

    }
    redirectHome() {
        this.showEditView = false;
        this.salaryView = false;
        this.redirectBack();
    }
    redirectBack(){
        this.checkIfDataIsUpdated()
        const selectedEvent = new CustomEvent("home", {
            detail: {
                redirect: false,
                //template: 'assessed'
                template: 'salary',
                docVerified: this.cartDataFetched
            }
        });
        this.dispatchEvent(selectedEvent);
    }

    handleBack(){
        this.salaryView = false;
        this.showEditView = false;
        this.redirectBack();
    }

    handleCartMonthlyIncome(event) {
        this.handleCartData(event.detail);
    }

    handleCartData(value) {
        //Neha-3838
        let salaryReceivedFromCart=[]
        //if (!this.month1Val && value[0] && value[0].salaryAmount) {
        if((this.cartDataFetched || !this.month1Val) && value[0] && value[0].salaryAmount){
            salaryReceivedFromCart.push('true')
            this.month1Val = parseFloat(value[0].salaryAmount);
        }
        //if (!this.month2Val && value[1] && value[1].salaryAmount) {
        if ((this.cartDataFetched || !this.month2Val) && value[1] && value[1].salaryAmount) {
            salaryReceivedFromCart.push('true')
            this.month2Val = parseFloat(value[1].salaryAmount);
        }
        //if (!this.month3Val && value[2] && value[2].salaryAmount) {
        if ((this.cartDataFetched || !this.month3Val) && value[2] && value[2].salaryAmount) {
            salaryReceivedFromCart.push('true')
            this.month3Val = parseFloat(value[2].salaryAmount);
        }
        if(salaryReceivedFromCart && salaryReceivedFromCart.length==3){
            this.dataUpdatedFromCart=true
        }
        this.salaryfinancialRecord.First_Month__c = this.month1Val;
        this.salaryfinancialRecord.Second_Month__c = this.month2Val;
        this.salaryfinancialRecord.Third_Month__c = this.month3Val;
        this.handleAverage();
    }
    handleEnableFetchDetails(event) {
        if (event.detail)
            this.fetchDetails = true;
        else
            this.fetchDetails = false;
    }
    handleFetchDetails() {
        this.template.querySelector("c-upload-multiple-files").handleFetchDetails();
    }
    handleLookupSelect(event) {
     
        if (event.detail.value != undefined) {
            let selectedValue = event.detail.value;
            let selectedName = event.detail.name;
            let fieldName = event.detail.fieldapi;
            let objectName = event.detail.objApiName;
            if (fieldName !== null && selectedName !== null) {
              // this.companyDefaultId =selectedValue;
               //this.companyOptionsValue = selectedName;
                this.companyName = selectedName;
               this.companyDefault = selectedValue;

            }

            console.log('selectedValue', selectedValue);
            console.log('selectedName', selectedName);
            console.log('fieldName', fieldName);
            console.log('objectName', objectName);
        }

    }

    deleteContentDocument(event){
        if(this.cartDataFetched){
            this.month1Val=''
            this.month2Val=''
            this.month3Val=''
            this.handleAverage();
            this.handleNetSalary();
        }
    }

    // R2 || START
   async handleDeleteRow(event){
        console.log('existingDetails-->' +JSON.stringify(this.existingDetails));
        if(this.existingDetails.length !=0){
            markRecordsInactive({afd :this.existingDetails[0].Id}).then((data)=>{
                this.handleResetValues(); 
            }).catch((error)=>{
            })
        }else{
            this.parentRecordId = await getActiveFinancialRecord({applicantId :this.applicantId});
            markRecordsInactive({afd :this.parentRecordId}).then((data)=>{
                this.handleResetValues(); 
            }).catch((error)=>{
            })
            //this.handleResetValues(); 
        }
    }

    handleResetValues(){
        this.handleResetAttributes();
        this.getVisibleFieldsMetadata();
        this.dispatchEvent(new CustomEvent('deletedrecord',{
                    detail: ''
        }));


    }

    handleResetAttributes(){
        this.month1Val =undefined;
        this.month2Val =undefined;
        this.month3Val =undefined;
        this.averageMonthlySalary =undefined;
        this.companyOptionsValue =undefined;
        this.grossVal=undefined;
        this.averageMonthlySalary=undefined;
        this.cashVal =undefined;
        this.netVal=undefined;
        this.existingDetails=[];
        this.showEditView = false;
        this.showViewForm = false;
        this.salaryView = true;   
        this.readAttribute = false; //
    }
    //END
}