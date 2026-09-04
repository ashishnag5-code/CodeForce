import { LightningElement, api } from 'lwc';
import { deleteRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";
import getRelatedRecords from '@salesforce/apex/RelatedRecordEditController.getRelatedRecords';

const actions = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }
];

export default class RelatedRecordsView extends NavigationMixin(LightningElement) {
    @api recordId;
    @api childAPIName;
    @api relationshipName;
    @api whereClause;
    @api fields;
    @api sortBy;
    @api numberOfRecords;
    @api sortOrder;
    @api viewAll = false;
    @api sectionLabel;
    @api relatedListLabel;
    @api iconName;

    hideViewAll = false;
    error;
    data;
    columns;
    showEditModal = false;
    currentEditRecordId;
    countOfRecords;

    connectedCallback() {
        this.fields = this.fields.replace(/\s+/g, '');
        let fieldList = this.fields.split(',');
        if (!fieldList.includes('id')) {
            fieldList.push('id');
        }
        this.fields = fieldList.join(',');
        this.getViewData();
    }

    getViewData(){        
        let requestInput = {
            recordId: this.recordId,
            childAPIName : this.childAPIName,
            relationshipName: this.relationshipName,
            whereClause: this.whereClause,
            fields: this.fields,
            sortBy: this.sortBy,
            numberOfRecords: this.numberOfRecords,
            sortOrder: this.sortOrder,
            viewAll: this.viewAll
        };
        getRelatedRecords({ serializedRequest : JSON.stringify(requestInput) })
        .then(result => {
            result.data?.forEach(each => {
                each.RecordLink = '/' + each.Id;
            });
            if (result.data) {
                let tempData = JSON.parse(JSON.stringify(result.data));
                let tempColumns = [];
                this.columns = [];
                for (let each in result.columns) {
                    if (result.columns[each]?.fieldName?.includes('.')) {
                        let keyForEachRow = result.columns[each].fieldName.replaceAll('.', '');
                        let objName = result.columns[each].fieldName.split('.')[0];
                        let fieldName = result.columns[each].fieldName.split('.')[1];
                        for (let eachRow in tempData) {
                            tempData[eachRow][keyForEachRow] = tempData[eachRow][objName][fieldName];
                        }
                    }
                    let updatedColumn = JSON.parse(JSON.stringify(result.columns[each]));
                    updatedColumn.fieldName = updatedColumn.fieldName.replaceAll('.', '');
                    tempColumns.push(updatedColumn);
                }
                this.data = tempData;
                this.columns = tempColumns;
                var rowAction = { type: 'action', typeAttributes: { rowActions: actions } };
                this.columns.push(rowAction);
            }
            this.countOfRecords = this.data ? (this.data?.length === 1 ? '1 item' : this.data?.length + ' items') : '0 items';
        })
        .catch(error=>{
            this.error = error;
            let errMsg = '';                    
            if (error && error.body && error.body.message) {
                errMsg = error.body.message;
            }                  
            this.dispatchEvent(this.showToast('error', errMsg, 'Error!', 'dismissable'));
        })
    }

    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        this.currentEditRecordId = row.Id;
        switch (action.name) {
            case 'edit':
                this.showEditModal = true;
                break;
            case 'delete':
                this.deleteViewRecord(this.currentEditRecordId);
                const rows = this.data;
                const rowIndex = rows.indexOf(row);
                rows.splice(rowIndex, 1);
                this.data = rows;
                break;
        }
    }

    handleSuccess(){
        this.dispatchEvent(this.showToast('success', 'Record updated successfully.', 'Success!', 'dismissable'));
        this.getViewData();
        this.showEditModal = false;
    }

    handleError(event){
        let message = event.detail.detail;
        this.dispatchEvent(this.showToast('error', message, 'Error!', 'dismissable'));
    }

    closeModal() {
        this.showEditModal = false;
    }

    deleteViewRecord(currentRecordId){
        deleteRecord(currentRecordId)
        .then(() => {
            this.dispatchEvent(this.showToast('success', 'Record deleted successfully.', 'Success!', 'dismissable'));
            this.getViewData();
        })
        .catch((error) => {
            this.dispatchEvent(this.showToast('error', error.body.message, 'Error!', 'dismissable'));
        });
    }

    handleViewAll(){
        this.hideViewAll = true;
        this.viewAll = true;
        this.getViewData();
    }

    //Common method to show toast
    showToast(variant, message, title, mode) {
        return new ShowToastEvent({
            "title": title,
            "message": message,
            "variant": variant,
            "mode": mode
        });
    }
}