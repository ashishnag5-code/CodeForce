import { LightningElement, track, wire, api } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';

import {toastWithMessage} from 'c/lwcutilities';

import viewAndEditRight from '@salesforce/apex/AusfbWorkOrderByCreditController.viewAndEditRight';
import getInitialData from '@salesforce/apex/AusfbWorkOrderByCreditController.getInitialData';
import upsertWorkOrders from '@salesforce/apex/AusfbWorkOrderByCreditController.upsertWorkOrders';

// Custom Spinner settings
import { getSpinnerImage } from 'c/customSpinner';
// Custom Spinner settings


export default class AusfbWorkOrderByCredit extends LightningElement {
    
    @api loanId = 'a2cHE000004Aa01YAC';

    isLoading = false;

    // Setup Component flags
    isComponentNotEditable = true;
    isComponentVisible = false; // Bug
    // Setup Component flags

    // Work order data
    @track workOrderList = [];


    // Check if work order exist or not
    get isWorkOrderExist(){
        return this.workOrderList.length > 0
    }

    @wire(viewAndEditRight, {loanId : '$loanId'})
    setupConfig({error,data}){
        this.isLoading = true;
        if(data){
            if(data.visible){
                this.isComponentVisible = true;
                if(data.editable){
                    this.isComponentNotEditable = false;
                }
                this.handleGetInitialData();
            }
            else{
                this.isComponentVisible = false;
            }
        }

        if(error){
            toastWithMessage(this, 'ERROR!', 'error', 'Error fetching configuration data in work order' + error);
        }
        this.isLoading = false;
    }

     // Custom Spinner settings
     async spinnerImageMethod() {
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.loanId);
        }
    }
    // Custom Spinner settings

    // Fetching initial data
    handleGetInitialData = async () => {
        try{
            await this.spinnerImageMethod();
            this.workOrderList = await getInitialData({loanId : this.loanId});
        }
        catch(error){
            toastWithMessage(this, 'ERROR!', 'error', 'Error fetching initial data in work order' + error);
        }
        
    }

    // Saving Work Order data
    handleSavingWorkOrderData = async () => {
        if(this.handleCheckValidations()){
            this.isLoading = true;
            try{

                this.workOrderList = await upsertWorkOrders({
                    workOrders : this.workOrderList,
                    loanId : this.loanId,
                });
                toastWithMessage(this, 'SUCCESS!', 'success', 'Work order saved successfully');
            }
            catch(error){
                toastWithMessage(this, 'ERROR!', 'error', 'Error fetching saving data in work order' + error);
            }
            this.isLoading = false;
        }
        else{
            toastWithMessage(this, 'ERROR!', 'error', 'Fill mandatory fields in work order');
        }
        this.isLoading = false;
    }


    // Adding more work order lines
    handleAddWorkOrder = () => {
        this.workOrderList.push({
            S_No__c : this.workOrderList.length + 1,
            Name_of_the_Principal__c : null,
            Nature_of_Work__c : null,
            Contract_start_date__c : null,
            Completion_date__c : null,
            age_work_completed__c : null,
            Value_of_contract_Rs_in_lacs__c : null,
            Unexecuted_CIH_Rs_in_Lacs__c : null,
            Loan_Application__c : this.loanId,
        });
    }

    // Handle input work order changes
    handleInputWorkOrderChange = (event) => {
        const index = event.target.dataset.index;
        const fieldId = event.target.dataset.field;
        const fieldType = event.target.dataset.type;

        if(fieldType === 'number') {
            this.workOrderList[index][fieldId] = parseFloat(event.target.value);
        }
        else{
            this.workOrderList[index][fieldId] = (event.target.value);
        }

    }

    // handle remove rows
    handleDeleteRow = async (event) => {
        const index = event.target.dataset.index;
        if(this.workOrderList[index].Id){
            await this.handleDeleteRowServerSide(this.workOrderList[index].Id);
        }
        this.workOrderList.splice(index, 1);
    }

    // Delete Server side row
    handleDeleteRowServerSide = async (recordId) => {
        this.isLoading = true;
        try{
            await deleteRecord(recordId);
        }
        catch(error){
            toastWithMessage(this, 'ERROR!', 'error', 'Failed deleting server side row ' + error);
        }
        this.isLoading = false;
    }
    

    // Check JS validations
    handleCheckValidations = () => {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('lightning-input');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });
        return isValid;
    }

}