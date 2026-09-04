import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';

export default class EditDatatableUtility extends LightningElement {
    @api recordId;
    @api fieldName;
    @api fieldLabel;
    @api fieldValue;
    @api isEdited;
    @api fieldType;
    @api fieldKey;
    @api hideIcons;
    @api item;
    allowDeleteRows = false;
    showAddRow = false;
    @track data = [];
    columns = [];
    selectedRows = [];
    tableColumns = [];
    dataForDisplay = [];
    blankRow = [];

    connectedCallback() {
        if (this.item.Add_New_Row_Option__c && this.isEdited){
            this.showAddRow = true;
            this.allowDeleteRows = true;
        }
        this.handleUpdate();
    }

    @api handleUpdate(){
        this.dataForDisplay = [];
        if (this.fieldValue !== undefined) {
            this.columns = this.fieldValue.tableDefinition;
            this.columns.forEach(col=>{
                this.tableColumns = [...this.tableColumns, col.fieldName];
            })
            this.data = this.fieldValue.tableData;
            for (let each in this.data) {
                let tableRow = [];

                for (let eachCol in this.columns) {
                    let dataObj = {};
                    let fieldName = this.columns[eachCol].fieldName;
                    let fieldType = this.columns[eachCol].type;
                    let isEditable = this.columns[eachCol].editable;
                    let options = this.columns[eachCol].options?.split(';');
                    dataObj.label = this.columns[eachCol].label;
                    dataObj.dataVal = this.data[each][fieldName];
                    dataObj.datatype = fieldType;
                    dataObj.isDisabled = (isEditable == 'true' ? false : true);
                    dataObj.isText = false;
                    dataObj.isDate = false;
                    dataObj.isEmail = false;
                    dataObj.isNumber = false;
                    dataObj.isInteger = false;
                    dataObj.isUrl = false;
                    dataObj.isCurrency = false;
                    dataObj.isPicklist = false;
                    dataObj.isCheckbox = false;
                    dataObj.options = [];
                    if(fieldType=='text'){
                        dataObj.isText = true;
                        let tempRow = {
                            "dataVal": "",
                            "datatype": "text",
                            "isDisabled": false,
                            "isText": true,
                            "isDate": false,
                            "isEmail": false,
                            "isNumber": false,
                            "isInteger": false,
                            "isUrl": false,
                            "isCurrency": false,
                            "isPicklist": false,
                            "isCheckbox": false,
                            "options": []
                        }
                        if(this.blankRow.length != this.columns.length){
                            this.blankRow.push(tempRow);
                        }
                    } else if(fieldType=='checkbox') {
                        dataObj.isCheckbox = true;
                        let tempRow = {
                            "datatype": "date",
                            "isDisabled": false,
                            "isText": false,
                            "isDate": false,
                            "isEmail": false,
                            "isNumber": false,
                            "isInteger": false,
                            "isUrl": false,
                            "isCurrency": false,
                            "isPicklist": false,
                            "isCheckbox": true,
                            "options": []
                        }
                        if(this.blankRow.length != this.columns.length){
                            this.blankRow.push(tempRow);
                        }
                    } else if(fieldType=='date') {
                        dataObj.isDate = true;
                        let tempRow = {
                            "datatype": "date",
                            "isDisabled": false,
                            "isText": false,
                            "isDate": true,
                            "isEmail": false,
                            "isNumber": false,
                            "isInteger": false,
                            "isUrl": false,
                            "isCurrency": false,
                            "isPicklist": false,
                            "isCheckbox": false,
                            "options": []
                        }
                        if(this.blankRow.length != this.columns.length){
                            this.blankRow.push(tempRow);
                        }
                    } else if(fieldType=='email') {
                        dataObj.isEmail = true;
                        let tempRow = {
                            "datatype": "email",
                            "isDisabled": false,
                            "isText": false,
                            "isDate": false,
                            "isEmail": true,
                            "isNumber": false,
                            "isInteger": false,
                            "isUrl": false,
                            "isCurrency": false,
                            "isPicklist": false,
                            "isCheckbox": false,
                            "options": []
                        }
                        if(this.blankRow.length != this.columns.length){
                            this.blankRow.push(tempRow);
                        }
                    } else if(fieldType=='number') {
                        dataObj.isNumber = true;
                        let tempRow = {
                            "datatype": "number",
                            "isDisabled": false,
                            "isText": false,
                            "isDate": false,
                            "isEmail": false,
                            "isNumber": true,
                            "isInteger": false,
                            "isUrl": false,
                            "isCurrency": false,
                            "isPicklist": false,
                            "isCheckbox": false,
                            "options": []
                        }
                        if(this.blankRow.length != this.columns.length){
                            this.blankRow.push(tempRow);
                        }
                    } else if(fieldType=='integer') {
                        dataObj.isInteger = true;
                        let tempRow = {
                            "datatype": "number",
                            "isDisabled": false,
                            "isText": false,
                            "isDate": false,
                            "isEmail": false,
                            "isNumber": false,
                            "isInteger": true,
                            "isUrl": false,
                            "isCurrency": false,
                            "isPicklist": false,
                            "isCheckbox": false,
                            "options": []
                        }
                        if(this.blankRow.length != this.columns.length){
                            this.blankRow.push(tempRow);
                        }
                    } else if(fieldType=='url'){
                        dataObj.isUrl = true;
                        let tempRow = {
                            "datatype": "url",
                            "isDisabled": false,
                            "isText": false,
                            "isDate": false,
                            "isEmail": false,
                            "isNumber": false,
                            "isInteger": false,
                            "isUrl": true,
                            "isCurrency": false,
                            "isPicklist": false,
                            "isCheckbox": false,
                            "options": []
                        }
                        if(this.blankRow.length != this.columns.length){
                            this.blankRow.push(tempRow);
                        }
                    } else if(fieldType == 'currency'){
                        dataObj.isCurrency = true;
                        let tempRow = {
                            "datatype": "currency",
                            "isDisabled": false,
                            "isText": false,
                            "isDate": false,
                            "isEmail": false,
                            "isNumber": false,
                            "isInteger": false,
                            "isUrl": false,
                            "isCurrency": true,
                            "isPicklist": false,
                            "isCheckbox": false,
                            "options": []
                        }
                        if(this.blankRow.length != this.columns.length){
                            this.blankRow.push(tempRow);
                        }
                    } else if (fieldType == 'picklist') {
                        dataObj.isPicklist = true;
                        for (let eachOption in options) {
                            if(options[eachOption] == dataObj.dataVal){
                                dataObj.options.push({ label : options[eachOption], value : options[eachOption], selected : dataObj.dataVal});
                            } else{
                                dataObj.options.push({ label : options[eachOption], value : options[eachOption]});
                            }
                        }
                        let tempRow = {
                            "dataVal": dataObj.dataVal,
                            "datatype": "picklist",
                            "isDisabled": false,
                            "isText": false,
                            "isDate": false,
                            "isEmail": false,
                            "isNumber": false,
                            "isInteger": false,
                            "isUrl": false,
                            "isCurrency": false,
                            "isPicklist": true,
                            "isCheckbox": false,
                            "options": dataObj.options
                        }
                        if(this.blankRow.length != this.columns.length){
                            this.blankRow.push(tempRow);
                        }
                    }
                    tableRow.push(dataObj);
                }
                tableRow.id = this.data[each].id;
                this.dataForDisplay.push(tableRow);
            }
        }
    }

    handleEdit(){
        this.isEdited = true;
    }

    handleChange(event){
        let isCheckbox = event.target.dataset.type === 'checkbox';
        let colId = event.target.name;
        let rowId = event.target.dataset.id;
        this.dataForDisplay[rowId][colId].dataVal = isCheckbox ? event.target.checked : event.target.value;
        if (this.fieldName == 'PD_Done_with' && event.target.checked) {
            const applicantSelectEvent = new CustomEvent('applicantselect', {
                detail: this.dataForDisplay[rowId].id
            });
            this.dispatchEvent(applicantSelectEvent);
        }
    }

    @api getConsolidatedDataFromParent() {
        let consolidatedData = {tableDefinition: this.columns, tableData: this.data};
        return consolidatedData;
    }

    addRow() {
        let newDataList = this.dataForDisplay;
        newDataList.push(this.blankRow);
        this.dataForDisplay = JSON.parse(JSON.stringify(newDataList));
    }

    deleteRow(event) {
        let rowId = event.target.dataset.id;
        let updatedDataTable = [];
        for (let each in this.dataForDisplay) {
            if (each != rowId) {
                updatedDataTable.push(this.dataForDisplay[each]);
            }
        }
        this.dataForDisplay = updatedDataTable;
    }

    @api saveUpdates() {
        let draftValues = this.template.querySelector('lightning-datatable').draftValues;
        let newDataList = [];
        let newElemsById = new Map();
        for (let each in this.data) {
            newElemsById.set(this.data[each].id + '', this.data[each]);
        }
        for (let each in draftValues) {
            let existingRow = newElemsById.get(draftValues[each].id);
            let draftRow = draftValues[each];
            for (let eachColumn in this.columns) {
                let columnName = this.columns[eachColumn].fieldName;
                if (draftRow.hasOwnProperty(columnName)) {
                    existingRow[columnName] = draftRow[columnName];
                }
            }
            newElemsById.set(draftValues[each].id + '', existingRow);
        }
        for (let value of newElemsById.values()){
            newDataList.push(value);
        }
        this.data = JSON.parse(JSON.stringify(newDataList));
        this.draftValues = [];
    }

    submitUpdates() {
        const fields = {};
        fields['Id'] = this.recordId;
        let consolidatedData = {tableDefinition: this.columns, tableData: this.data};
        fields[this.fieldName] = JSON.stringify(consolidatedData);
        const recordInput = {fields}
        updateRecord(recordInput)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Updated data",
                        variant: "success"
                    })
                );
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error updating data",
                        message: error.body.message,
                        variant: "error"
                    })
                );
            });
    } 
   
    @api handleSave(){
        let a= {};
        this.isEdited = false;
        a.tableDefinition = this.columns;
        let finalData = [];
        this.dataForDisplay.forEach(row=>{
            let obj = {id: row.id};
            for(let i=0;i<row.length;i++){
                for(let j=0;j<this.columns.length;j++){
                    if(i==j){
                        obj[this.columns[j].fieldName] = row[i].dataVal;
                    }
                }
            }
            finalData.push(obj);
        })
        a.tableData = finalData;
        let finalJSON = {};
        finalJSON.value = a;
        return finalJSON;
    }
}