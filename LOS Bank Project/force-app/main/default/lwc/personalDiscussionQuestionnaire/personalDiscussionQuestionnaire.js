import { LightningElement, api, track } from 'lwc';
import displayQuestionnaire from '@salesforce/apex/PersonalDiscussionQuestionnaireCntrl.displayQuestionnaire';
import getLatestValues from '@salesforce/apex/PersonalDiscussionQuestionnaireCntrl.getLatestValues';
import insertFileVersion from '@salesforce/apex/PersonalDiscussionQuestionnaireCntrl.insertFileVersion';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';

const RECORD_TAB_CONTEXT = 'RecordTab';
const GENERAL_WIZARD_CONTEXT = 'GeneralWizard';
import { createMessageContext, publish } from 'lightning/messageService';
import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c';

export default class PersonalDiscussionQuestionnaire extends LightningElement {
    @api recordId;
    @api documentId;
    @api isCreatingNewDocument;
    messageContext = createMessageContext();
    @api fiMode = false;
    @api spinnerImage;
    @api containerContext = RECORD_TAB_CONTEXT;
    isDisabled = false;
    versionData = [];
    isLoading = false;
    isEditable = false;
    allowEdit = false;
    dataValue;
    @track displayList = [];
    applicants = [];
    assets = [];
    isInfoMissing = false;
    isMissing = false;
    hasError = false;
    errorOnChild;
    isFirstTimeCreation = false;
    applicantDetails = [];
    cropDetailsList = [];
    isWizard = false;

    connectedCallback() {
        this.getPDData();
    }

    get title() {
        if (this.fiMode) {
            return 'Tractor FI Questionnaire';
        }
        return 'Personal Discussion Questionnaire';
    }

    getPDData(){
        getLatestValues({ loanId: this.recordId, documentId: this.documentId})
        .then(results => {                
            if (results.csvString != '') {
                this.versionData = JSON.parse(results.csvString);
            }
            if (this.versionData){
                displayQuestionnaire({ loanId: this.recordId })
                .then(result => {
                    if(result?.questions?.length > 0) {
                        this.applicants = result.applicants;
                        this.applicantDetails = result.applicantDetails; 
                        this.assets = result.assets;
                        if (!this.fiMode && (this.assets === undefined || this.assets === null || this.assets.length === 0)) {
                            this.isInfoMissing = true;
                            return;
                        }
                        this.displayList = result.questions;
                        let hiddenQuestions = result.hiddenQuestions;
                        this.allowEdit = result.isEditable;
                        this.displayList.forEach(item1 => {
                            item1.pdqs.forEach(item => {
                                if (this.versionData.length > 0) {
                                    this.versionData.forEach(ver => {
                                        if (ver.name == item.QualifiedApiName) {
                                            if (item.Question_Type__c == 'Tabular Input') {
                                                item.value = JSON.parse(ver.value);
                                            } else if ((item.Question_Type__c == 'Per Applicant' || item.Question_Type__c == 'Per Asset') && item.Type__c == 'Table') {
                                                if (ver.values) {
                                                    item.values = JSON.parse(JSON.stringify(ver.values));
                                                }
                                            } else {
                                                item.value = ver.value;
                                            }
                                        }
                                    })
                                } else {
                                    this.isFirstTimeCreation = true;
                                    // logic for pre-populating during creation here
                                    if (item.QualifiedApiName == 'RO_Name_Code') {
                                        item.value = result?.roName;
                                    } else if (item.QualifiedApiName == 'Date_OF_PD') {
                                        let todaysDate = new Date();
                                        const offset = todaysDate.getTimezoneOffset();
                                        todaysDate = new Date(todaysDate.getTime() - (offset*60*1000));
                                        item.value = todaysDate.toISOString().split('T')[0];
                                    }
                                }
                                // always set this to recent modified by user
                                if (item.QualifiedApiName == 'PD_Done_By_Name_Code') {
                                    item.value = results?.pdDoneBy;
                                }
                                item.isTabularInput = false;
                                item.isRichText = false;
                                item.isDropdown = false;
                                item.isDate = false;
                                item.isRadioButtons = false;
                                item.isCheckboxes = false;
                                item.isImageRadio = false;
                                item.isImageCheckBoxes = false;
                                item.isText = false;
                                item.isNumber = false;
                                item.isLongTextArea = false;
                                item.isFileUpload = false;
                                item.isPerApplicant = false;
                                item.isPerAsset = false;
                                item.isPerApplicantText = false;
                                item.isPerApplicantDate = false;
                                item.isPerApplicantDropdown = false;
                                item.isPerApplicantLngTxtArea = false;
                                item.isComplexTable = false;
                                item.isHidden = hiddenQuestions?.includes(item.QualifiedApiName);
                                if (item.Question_Type__c == 'Rich Text Input') {
                                    item.isRichText = true;
                                }
                                if (item.Question_Type__c == 'Number') {
                                    item.isNumber = true;
                                } else if (item.Question_Type__c == 'Tabular Input') {
                                    if (item.value == null || item.value == undefined) {
                                        if (item.QualifiedApiName === 'CROP_DETAILS') {
                                            let updatedTable = JSON.parse(item.Table_Definition_LOVs__c);
                                            if (this.cropDetailsList && this.cropDetailsList?.length > 0) {
                                                updatedTable.value.tableData = [];
                                                for (let each in this.cropDetailsList) {
                                                    updatedTable.value.tableData.push({cropDetailName: this.cropDetailsList[each].cropDetails, cropDetailArea: this.cropDetailsList[each].area});
                                                }
                                            }
                                            item.value = updatedTable;
                                        } else {
                                            item.value = JSON.parse(item.Table_Definition_LOVs__c);
                                        }
                                    }
                                    item.isTabularInput = true;
                                } else if (item.Question_Type__c == 'Dropdown') {
                                    let string = item.Table_Definition_LOVs__c;
                                    item.Table_Definition_LOVs__c = [];
                                    const arr1 = string.split(';');
                                    arr1.forEach(arr => {
                                        let a = {};
                                        a.label = arr;
                                        a.value = arr;
                                        item.Table_Definition_LOVs__c.push(a);
                                    })
                                    item.isDropdown = true;
                                } else if (item.Question_Type__c == 'Date') {
                                    item.isDate = true;
                                } else if (item.Question_Type__c == 'Radio Buttons') {
                                    let string = item.Table_Definition_LOVs__c;
                                    item.Table_Definition_LOVs__c = [];
                                    const arr1 = string.split(';');
                                    arr1.forEach(arr => {
                                        let a = {};
                                        a.label = arr;
                                        a.value = arr;
                                        item.Table_Definition_LOVs__c.push(a);
                                    })
                                    item.isRadioButtons = item.Question_Type__c == 'Radio Buttons' ? true : false;
                                } else if(item.Question_Type__c == 'Checkboxes'){
                                    item.isCheckboxes = true;
                                    let string = item.Table_Definition_LOVs__c;
                                    item.Table_Definition_LOVs__c = [];
                                    if(!item.value){
                                        item.value = [];
                                    }
                                    const arr1 = string.split(';');
                                    arr1.forEach(arr => {
                                        let a = {};
                                        a.label = arr;
                                        a.value = arr;
                                        item.Table_Definition_LOVs__c.push(a);
                                    })
                                } else if(item.Question_Type__c == 'Image Checkboxes'){
                                    item.isImageCheckBoxes = true;
                                } else if(item.Question_Type__c == 'Image Radio Button'){
                                    item.isImageRadio = true;
                                } else if(item.Question_Type__c == 'Text'){
                                    item.isText = true;
                                } else if(item.Question_Type__c == 'Long Text Area'){
                                    item.isLongTextArea = true;
                                } else if(item.Question_Type__c == 'File Upload'){
                                    item.isFileUpload = true;
                                } else if(item.Question_Type__c == 'Per Applicant') {
                                    if (item.Type__c === 'Table') {
                                        // display as table 
                                        item.isComplexTable = true;
                                        if (item.values == null || item.values == undefined) {
                                            item.values = [];
                                            for (let each in this.applicants) {
                                                if (item.QualifiedApiName === 'DETAILS_OF_APPLICANT_S_INCOME_AND_EMPLOY') {
                                                    let tableContentWithData = this.getApplicantsIncomeData(JSON.parse(item.Table_Definition_LOVs__c), this.applicants[each].Id);
                                                    item.values.push({ recordKey: this.applicants[each].Id, recordValue: tableContentWithData, recordLabel: this.applicants[each][item.Header_Field_Name__c] });
                                                } else {
                                                    item.values.push({ recordKey: this.applicants[each].Id, recordValue: JSON.parse(item.Table_Definition_LOVs__c), recordLabel: this.applicants[each][item.Header_Field_Name__c] });
                                                }
                                            }
                                        } else {
                                            let parsedValues = item.values;
                                            for (let each in this.applicants) {
                                                let isInTable = false;
                                                for (let eachRow in parsedValues) {
                                                    if (parsedValues[eachRow].recordKey === this.applicants[each].Id) {
                                                        isInTable = true;
                                                        parsedValues[eachRow].recordLabel = this.applicants[each][item.Header_Field_Name__c];
                                                        parsedValues[eachRow].recordValue = JSON.parse(parsedValues[eachRow].recordValue);
                                                    }
                                                }
                                                if (!isInTable) {
                                                    let tableContentWithData = this.getApplicantsIncomeData(JSON.parse(item.Table_Definition_LOVs__c), this.applicants[each].Id);
                                                    parsedValues.push({ recordKey: this.applicants[each].Id, recordValue: tableContentWithData, recordLabel: this.applicants[each][item.Header_Field_Name__c] });
                                                }
                                            }
                                            item.values = parsedValues;
                                        }
                                    } else {
                                        if (item.value == null || item.value == undefined) {
                                            let perApplicantObj = {};
                                            perApplicantObj.value = {};
                                            perApplicantObj.value.tableDefinition = [
                                                {editable: "false", type: 'text', label: 'Applicant', fieldName: 'applicantLabel'},
                                                {editable: "true", type: item.Type__c.toLowerCase(), label: item.Column_Name__c, fieldName: 'inputField', options: item.Options__c}
                                            ];
                                            perApplicantObj.value.tableData = [];
                                            for (let each in this.applicants) {
                                                perApplicantObj.value.tableData.push({
                                                    id: this.applicants[each].Id, applicantLabel: this.applicants[each][item.Header_Field_Name__c], inputField: item.Type__c.toLowerCase() == 'checkbox' ? false : ''
                                                });
                                            }
                                            item.value = perApplicantObj;
                                        } else {
                                            let parsedValue = JSON.parse(item.value);
                                            let finalValue = JSON.parse(item.value);
                                            if (finalValue && finalValue.value) {
                                                finalValue.value.tableData = [];
                                            }
                                            for (let each in this.applicants) {
                                                let isInTable = false;
                                                if (parsedValue?.value?.tableData !== undefined && parsedValue?.value?.tableData !== null) {
                                                    for (let eachRow in parsedValue.value.tableData) {
                                                        if (parsedValue.value.tableData[eachRow].id === this.applicants[each].Id) {
                                                            isInTable = true;
                                                            parsedValue.value.tableData[eachRow].applicantLabel = this.applicants[each][item.Header_Field_Name__c];
                                                            finalValue.value.tableData.push({
                                                                id: this.applicants[each].Id, applicantLabel: this.applicants[each][item.Header_Field_Name__c], inputField: parsedValue.value.tableData[eachRow].inputField
                                                            });
                                                        }
                                                    }
                                                }
                                                if (!isInTable) {
                                                    finalValue?.value?.tableData.push({
                                                        id: this.applicants[each].Id, applicantLabel: this.applicants[each][item.Header_Field_Name__c], inputField: ''
                                                    });
                                                }
                                            }
                                            item.value = finalValue;
                                        }
                                        item.isTabularInput = true;
                                    }
                                } else if(item.Question_Type__c == 'Per Asset'){
                                    if (item.Type__c === 'Table') {
                                        // display as table 
                                        item.isComplexTable = true;
                                        if (item.values == null || item.values == undefined) {
                                            item.values = [];
                                            for (let each in this.assets) {
                                                item.values.push({ recordKey: this.assets[each].Id, recordValue: JSON.parse(item.Table_Definition_LOVs__c), recordLabel: this.assets[each][item.Header_Field_Name__c] });
                                            }
                                        } else {
                                            let parsedValues = item.values;
                                            for (let each in this.assets) {
                                                let isInTable = false;
                                                for (let eachRow in parsedValues) {
                                                    if (parsedValues[eachRow].recordKey === this.assets[each].Id) {
                                                        isInTable = true;
                                                        parsedValues[eachRow].recordLabel = this.assets[each][item.Header_Field_Name__c];
                                                        parsedValues[eachRow].recordValue = JSON.parse(parsedValues[eachRow].recordValue);
                                                    }
                                                }
                                                if (!isInTable) {
                                                    parsedValues.push({ recordKey: this.assets[each].Id, recordValue: JSON.parse(item.Table_Definition_LOVs__c), recordLabel: this.assets[each][item.Header_Field_Name__c] });
                                                }
                                            }
                                            item.values = parsedValues;
                                        }
                                    } else {
                                        if (item.value == null || item.value == undefined) {
                                            let perAssetObj = {};
                                            perAssetObj.value = {};
                                            perAssetObj.value.tableDefinition = [
                                                {editable: "false", type: 'text', label: 'Asset', fieldName: 'assetLabel'},
                                                {editable: "true", type: item.Type__c.toLowerCase(), label: item.Column_Name__c, fieldName: 'inputField', options: item.Options__c}
                                            ];
                                            perAssetObj.value.tableData = [];
                                            for (let each in this.assets) {
                                                perAssetObj.value.tableData.push({
                                                    id: this.assets[each].Id, assetLabel: this.assets[each][item.Header_Field_Name__c], inputField: ''
                                                });
                                            }
                                            item.value = perAssetObj;
                                        } else {
                                            let parsedValue = JSON.parse(item.value);
                                            let finalValue = JSON.parse(item.value);
                                            if (finalValue && finalValue.value) {
                                                finalValue.value.tableData = [];
                                            }
                                            for (let each in this.assets) {
                                                let isInTable = false;
                                                if (parsedValue?.value?.tableData !== undefined && parsedValue?.value?.tableData !== null) {
                                                    for (let eachRow in parsedValue.value.tableData) {
                                                        if (parsedValue.value.tableData[eachRow].id === this.assets[each].Id) {
                                                            isInTable = true;
                                                            parsedValue.value.tableData[eachRow].assetLabel = this.assets[each][item.Header_Field_Name__c];
                                                            finalValue.value.tableData.push({
                                                                id: this.assets[each].Id, assetLabel: this.assets[each][item.Header_Field_Name__c], inputField: parsedValue.value.tableData[eachRow].inputField
                                                            });
                                                        }
                                                    }
                                                }
                                                if (!isInTable) {
                                                    finalValue?.value?.tableData.push({
                                                        id: this.assets[each].Id, assetLabel: this.assets[each][item.Header_Field_Name__c], inputField: item.Type__c.toLowerCase() == 'checkbox' ? false : ''
                                                    });
                                                }
                                            }
                                            item.value = finalValue;
                                        }
                                        item.isTabularInput = true;
                                    }
                                }
                            })
                        })
                    } else{
                        this.isInfoMissing = true;
                    }
                    if (this.containerContext === GENERAL_WIZARD_CONTEXT && result.isEditableInWizard) {
                        this.isEditable = true;
                    } else {
                        this.isEditable = false;
                    }
                    if (this.containerContext === GENERAL_WIZARD_CONTEXT) {
                        this.isWizard = true;
                    }
                })
                .catch(error => {
                    this.isEditable = false;
                    console.log('error: '+ JSON.stringify(error));
                    let errMsg = '';
                    if (error && error.body && error.body.message) {
                        errMsg = error.body.message;
                    }
                    this.showToast('Error!!', errMsg, 'error', 'dismissable');
                })
            }
        })
        .catch(error => {
            console.log('error 0: '+JSON.stringify(error));
            let errMsg = '';                    
            if (error && error.body && error.body.message) {
                errMsg = error.body.message;
            }                  
            this.showToast('Error!!', errMsg, 'error', 'dismissable');
        })
    }

    getApplicantsIncomeData(defaultTable, appId) {
        let agricultureIncome = 0;
        let salaryIncome = 0;
        let dairyIncome = 0;
        let businessIncome = 0;
        let selfAgriIncome = 0;
        let contractAgriIncome = 0;
        let shopIncome = 0;
        let totalIncome = 0;
        let rentalIncome = 0;
        for(let i in this.applicantDetails) {
            let app = this.applicantDetails[i];
            if(appId === app.Id){
                if(app['Applicant_Financials__r'] && app.Applicant_Financials__r.length>0){
                    for(let j in app.Applicant_Financials__r){
                        let appFin = app.Applicant_Financials__r[j];
                        let cropArea = 0;
                        if(appFin.RecordType.DeveloperName == 'Farmer_Agriculture_Own_Land'){
                            agricultureIncome = agricultureIncome + (appFin.Net_Revenue__c != null ? appFin.Net_Revenue__c : 0);
                            selfAgriIncome = selfAgriIncome + (appFin.Net_Revenue__c != null ? appFin.Net_Revenue__c : 0);
                            cropArea = this.calculateCropArea(appFin.Area_under_crop__c,appFin.Area_under_Crop_Unit__c);
                            this.cropDetailsList.push({reecordType:appFin.RecordType.DeveloperName,cropDetails:appFin.Crop_Details__c,area:cropArea});
                        } else if(appFin.RecordType.DeveloperName == 'Farmer_Agriculture_Rented_Land'){
                            agricultureIncome = agricultureIncome + (appFin.Net_Revenue__c != null ? appFin.Net_Revenue__c : 0);
                            cropArea = this.calculateCropArea(appFin.Area_under_crop__c,appFin.Area_under_Crop_Unit__c);
                            this.cropDetailsList.push({reecordType:appFin.RecordType.DeveloperName,cropDetails:appFin.Crop_Details__c,area:cropArea});
                        } else if(appFin.RecordType.DeveloperName == 'Farmer_Commercial'){
                            agricultureIncome = agricultureIncome + (appFin.Net_Annual_Income__c != null ? appFin.Net_Annual_Income__c : 0);
                            contractAgriIncome = contractAgriIncome + (appFin.Net_Annual_Income__c != null ? appFin.Net_Annual_Income__c : 0);
                        } else if(appFin.RecordType.DeveloperName == 'Farmer_Dairy_Business'){
                            agricultureIncome = agricultureIncome + (appFin.Total_Net_Income__c != null ? (appFin.Total_Net_Income__c * 12) : 0);
                            dairyIncome = dairyIncome + (appFin.Total_Net_Income__c != null ? (appFin.Total_Net_Income__c * 12) : 0);
                        } else if(appFin.RecordType.DeveloperName == 'Salaried_Document'){
                            salaryIncome = salaryIncome + (appFin.Salary_Received_in_Bank__c != null ? (appFin.Salary_Received_in_Bank__c * 12) : 0) +(appFin.Salary_Received_in_Cash__c != null ? (appFin.Salary_Received_in_Cash__c * 12) : 0) ;
                        } else if(appFin.RecordType.DeveloperName == 'Assessed_No_Document'){
                            businessIncome = businessIncome + (appFin.Monthly_Turnover__c != null ? appFin.Monthly_Turnover__c : 0) ;
                        } else if(appFin.RecordType.DeveloperName == 'Documented_With_Audited_financial'){
                            businessIncome = businessIncome + (appFin.Monthly_Total_Income__c != null ? appFin.Monthly_Total_Income__c : 0) ;
                        } else if(appFin.RecordType.DeveloperName == 'Other_Income'){
                            shopIncome = shopIncome + (appFin.Monthly_Income__c != null ? appFin.Monthly_Income__c : 0) ;
                            if(appFin.Other_Income_Picklist__c == 'Rental'){
                                rentalIncome = rentalIncome + (appFin.Monthly_Income__c != null ? appFin.Monthly_Income__c :0) ;
                            }
                        } else if (appFin.RecordType.DeveloperName == 'Financial_Parent') {
                            totalIncome = totalIncome + (appFin.Total_Income__c != null ? appFin.Total_Income__c : 0);
                        }
                    }
                }
                break;
            }
        }
        defaultTable.value.tableData[0].income1 = agricultureIncome;
        defaultTable.value.tableData[0].income2 = salaryIncome;
        defaultTable.value.tableData[1].income2 = businessIncome;
        defaultTable.value.tableData[2].income1 = dairyIncome;
        defaultTable.value.tableData[2].income2 = rentalIncome;
        defaultTable.value.tableData[3].income1 = selfAgriIncome;
        defaultTable.value.tableData[3].income2 = contractAgriIncome;
        defaultTable.value.tableData[4].income1 = shopIncome;
        defaultTable.value.tableData[4].income2 = totalIncome;
        return defaultTable;
    }

    handleApplicantSelect(event) {
        if (!this.isFirstTimeCreation) {
            return;
        }
        let appId = event.detail;
        let khataNo;
        for (let i in this.applicantDetails) {
            let app = this.applicantDetails[i];
            if(appId === app.Id){
                if(app['Addresses__r'] && app.Addresses__r.length>0){
                    khataNo = app.Addresses__r[0].Khata_Khasara_Survey_Number__c;
                }
                break;
            }
        }
        let displayListCopy = this.displayList;
        displayListCopy[3].pdqs[0].value.value.tableData[3].landAnotherOneRow = khataNo;
        this.displayList = displayListCopy;

        this.template.querySelectorAll('c-edit-datatable-utility').forEach(element => {
            if (element.fieldName === 'LAND_HOLDING_DETAILS_ACRE') {
                element.handleUpdate();
            }
        })
    }

    calculateCropArea(area, unit){
        if (unit != null && unit !== undefined){
            if (unit == 'Acres' || unit == 'Killa') {
                return (area != null ? area : 0);
            } else if (unit == 'Bigha') {
                return (area != null ? (area * 0.62) : 0);
            } else if (unit == 'Hectare') {
                return (area != null ? (area * 2.471051565) : 0);
            } else if (unit == 'Canal') {
                return (area != null ? (area * 0.125) : 0);
            }
        }
        return (area != null?area:0);
    }

    @api handleEdit(){
        this.isEditable = true;
    }

    handleCancel(){
        this.isEditable = false;
    }

    @api nextHandler() {       
        this.handleSave();
        let Obj = {};
        Obj.next = true;
        this.errorOnChild = '';
        Obj.errorOnChild = this.errorOnChild;
        this.dispatchEvent(new CustomEvent('next', {
            detail: Obj
        }));
    }
    
    handleSave() {
        restricAccess({
            compName: 'personalDiscussionQuestionnaire' ,loanId: this.recordId
            })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save/edit Personal Discussion',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }
                else{
                this.isLoading = true;
                var listData = [];
                this.isMissing = false; 
                this.hasError = false;
                var complexDataMap = new Map();
                this.template.querySelectorAll('lightning-checkbox-group').forEach(element => {
                    if (this.isMissing){
                        return;
                    }
                    if (element.value && element.value.length == 0) {
                        this.isMissing = true;
                    } else if(element.required && !element.value) {
                        this.isMissing = true;
                    } else {
                        this.isMissing = false;
                    }
                })
                this.template.querySelectorAll('.as').forEach(element => {
                    if (this.isMissing){
                        return;
                    }
                    if((element.type == 'radio') && element.value && element.value.length == 0) {
                        this.isMissing = true;
                    } else if(element.required && !element.value) {
                        this.isMissing = true;
                    } else {
                        this.isMissing = false;
                    }

                    if (element.type == 'date' && element.name == 'Date_OF_PD') {
                        let currentDate = new Date().toJSON().slice(0, 10);
                        if (element.value > currentDate) {
                            this.showToast('Error!!', 'Date of PD can\'t be a future date.', 'error', 'dismissable');
                            this.isLoading = false;
                            this.hasError = true;
                            return;
                        }
                    }
                })
                if (!this.isMissing && !this.hasError) {
                    this.template.querySelectorAll('.as').forEach(element => {
                        let a = {};
                        a.name = element.name;
                        a.value = element.value;
                        listData.push(a);
                    })

                    this.template.querySelectorAll('c-edit-datatable-utility').forEach(element => {
                        let saveDetail = element.handleSave();
                        let d = {};
                        d.name = element.fieldName;
                        d.value = JSON.stringify(saveDetail);
                        if (element.fieldType === null || element.fieldType === undefined) {
                            listData.push(d);
                        } else {
                            let listToPush = [];
                            if (complexDataMap.has(element.fieldName)) {
                                listToPush = complexDataMap.get(element.fieldName);
                            }
                            listToPush.push({recordKey: element.fieldKey, recordValue: d.value});
                            complexDataMap.set(element.fieldName, listToPush);
                        }
                    })

                    for (let [key, value] of complexDataMap.entries()) {
                        let complexElem = {};
                        complexElem.name = key;
                        complexElem.values = value;
                        listData.push(complexElem);
                    }

                    this.template.querySelectorAll('c-image-based-checkbox-or-radio-options').forEach(element => {
                        let saveDetail = element.finalResult;
                        let d = {};
                        d.name = saveDetail.name;
                        d.value = saveDetail.value;
                        listData.push(d);
                    })

                    this.template.querySelectorAll('c-file-upload-p-d-q').forEach(element => {
                        let saveDetail = element.finalResult;
                        let d = {};
                        d.name = saveDetail.name;
                        d.value = saveDetail.value;
                        listData.push(d);
                    })

                    var arrString = btoa(JSON.stringify(listData));
                    insertFileVersion({ versionData: arrString, loanId: this.recordId })
                    .then(() => {
                        this.isLoading = false;
                        this.getPDData();
                        this.showToast('Success!!', 'Record created successfully!!', 'success', 'dismissable');
                        const payload = { recordIdOfSobject: this.recordId, refreshPage: 'Yes'};
                        publish(this.messageContext, pageRefreshOnMaterialFieldChange, payload);
                    }).catch(error => {
                        this.isLoading = false;
                        this.isEditable = false;
                        let errMsg = '';                    
                            if (error && error.body && error.body.message) {
                                errMsg = error.body.message;
                            }       
                        this.showToast('Error!!', errMsg, 'error', 'dismissable');
                    });
                } else if(this.isMissing && !this.hasError){
                    this.showToast('Error!!', 'Required fields are missing', 'error', 'dismissable');
                    this.isLoading = false;
                }
            }
        })
    }

    showToast(titleText, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: titleText,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
}