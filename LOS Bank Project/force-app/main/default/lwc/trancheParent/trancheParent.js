import { LightningElement, track, api, wire } from 'lwc';
import getTrancheDetails from '@salesforce/apex/TrancheController.getTrancheDetails'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import upsertData from '@salesforce/apex/TrancheController.upsertData'
import deleteTranche from '@salesforce/apex/TrancheController.deleteTranche'
import { refreshApex } from '@salesforce/apex';
import getVisibleFieldsForLoanDetails from '@salesforce/apex/TrancheController.getVisibleFieldsForLoanDetails'
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

export default class TrancheParent extends LightningElement {

    @track trancheList = []
    keyIndex = 0;
    @track recordCount = 0
    trancheNumber = 1;
    @api loanApp;
    deleteRecords = []
    readOnly = true
    totalDisbursement = 0
    trancheMap = new Map()
    visibleFields = []
    @track isDelete = false
    @api boolFromCINLANCmp;
    @api fieldsToBeDisabled

    connectedCallback() {
        this.totalDisbursement = 0
        console.log(JSON.stringify(this.loanApp))
        getTrancheDetails({ recordId: this.loanApp.Id }).then((data => {
            if (data && data.length > 0) {
                this.keyIndex = 0
                this.trancheNumber = 1
                data.forEach(input => {
                    input.key = this.keyIndex
                    input.isChecked = false
                    this.trancheMap.set(input.key, input)
                    this.keyIndex++
                    this.trancheNumber++
                });
                this.trancheList = Array.from(this.trancheMap.values())
                this.recordCount = this.trancheList.length
                this.readOnly = true
                this.getVisibleFieldsForTrancheData()
                this.calculateTotals()
            }
        }))
    }

    /*@wire (getVisibleFieldsForLoanDetails, {strScreen :'Tranche Details', strStage :this.loanApp.Stage__c, strProfile :''})
    visibleFieldsForTranche({error, data}){
        if(data){
            this.showFields(data)
        }
    }*/
    getVisibleFieldsForTrancheData() {
        var a = JSON.parse(JSON.stringify(this.loanApp))
        getVisibleFieldsForLoanDetails({ strScreen: 'Tranche Details', strStage: this.loanApp.Stage__c, strProfile: '' })
            .then(result => {
                console.log('result is ' + JSON.stringify(result));
                this.visibleFields = result;
                this.showFields(this.visibleFields)
                if (this.fieldsToBeDisabled && this.fieldsToBeDisabled.length > 0) {
                    this.boolFromCINLANCmp = true
                    this.fieldsToBeDisabled.forEach((input => {
                        if (this.template.querySelectorAll('[data-name="' + input + '"]')) {
                            this.template.querySelectorAll('[data-name="' + input + '"]').forEach((inputToBeDisabled => {
                                inputToBeDisabled.disabled = true
                                inputToBeDisabled.classList.add('slds-p-left_small')
                            }))
                        }

                    }))
                }
            })
            .catch(error => {
                console.log('result is ' + error);
            })
    }

    showFields(result) {
        result.forEach(input => {
            this.template.querySelectorAll('[data-id="' + input + '"]').forEach(element => {
                element.classList.remove('slds-hide');
            })
        });
    }

    handleEdit() {
        this.readOnly = false
    }

    handleReject() {
        this.readOnly = true
    }

    handleAddNewTranche() {
        if (this.trancheList.length == 3) {
            this.showToastMessage('Error', 'Maximum 3 Tranches can be added', 'error')
        } else {
            //this.showFields(this.visibleFields)
            this.trancheMap.set(this.keyIndex, { key: this.keyIndex, Tranche_Number__c: this.trancheNumber, isChecked: false })
            this.trancheList = Array.from(this.trancheMap.values())
            this.getVisibleFieldsForTrancheData()
            this.trancheNumber++
            this.keyIndex++
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

        if (allValid1) {
            valid = true
        } else {
            valid = false;
        }


        return valid;
    }

    checkedCount = 0
    handleChange(event) {

        var record = this.trancheMap.get(event.target.accessKey)
        if (event.target.name === 'isChecked') {
            record[event.target.name] = event.target.checked
            this.checkedCount = event.target.checked == true ? this.checkedCount + 1 : this.checkedCount - 1
            this.isDelete = this.checkedCount == 0 ? false : true
        } else {
            record[event.target.name] = event.target.value
        }
        this.trancheMap.set(event.target.accessKey, record)
        this.trancheList = Array.from(this.trancheMap.values())

    }

    handleSave() {
        if (this.handleValidations()) {
            this.calculateTotals()
            //var charges = this.loanApp.Total_Charges__c?this.loanApp.Total_Charges__c:0
            //if(this.totalDisbursement!=(this.loanApp.Loan_Amount__c-charges)){
            if (this.totalDisbursement != (this.loanApp.Total_Loan_Amount__c)) {
                //this.showToastMessage('Error','Net Tranche Disbursement Amount should be equal to Loan Amount (excluding sum of charges) '+(this.loanApp.Loan_Amount__c-charges),'error');
                this.showToastMessage('Error', 'Net Tranche Disbursement Amount should be equal to Total Loan Amount ' + (this.loanApp.Total_Loan_Amount__c), 'error');
            } else {
                upsertData({ tranche: this.trancheList, loanId: this.loanApp.Id }).then((data) => {
                    this.updateModifiedData(data)
                })
            }
        } else {
            this.showToastMessage('Error', 'Please fill the Mandatory Details', 'error')
        }
    }

    handleDeleteAction() {
        this.checkedCount = 0
        this.isDelete = false
        var updateDeletedRecordsWithId = []
        var updateNonDeletedRecordsWithIds = []
        var updateNonDeletedRecordsWithoutIds = []

        this.trancheList.forEach(element => {
            if (element.isChecked) {
                if (element.Id) {
                    updateDeletedRecordsWithId.push(element.Id)
                }
                this.trancheMap.delete(element.key)
            } else {
                if (element.Id)
                    updateNonDeletedRecordsWithIds.push(element)
                else {
                    updateNonDeletedRecordsWithoutIds.push(element)
                }
            }
        })

        this.trancheList = Array.from(this.trancheMap.values())

        if (updateDeletedRecordsWithId.length > 0) {
            deleteTranche({ recordIds: updateDeletedRecordsWithId, loanId: this.loanApp.Id }).then((data) => {
                this.updateModifiedData(data)
                updateNonDeletedRecordsWithoutIds.forEach(input => {
                    //if(!input.Id)
                    input.Tranche_Number__c = this.trancheNumber
                    this.trancheNumber++
                    this.trancheMap.set(input.key, input)

                })
                this.trancheList = Array.from(this.trancheMap.values())
                this.getVisibleFieldsForTrancheData()
                //this.refreshApex(visibleFieldsForTranche)
            })
        } else {
            this.trancheMap = new Map()
            this.trancheNumber = 1
            this.keyIndex = 0
            updateNonDeletedRecordsWithIds.forEach(input => {
                input.Tranche_Number__c = this.trancheNumber
                input.key = this.keyIndex
                this.trancheNumber++
                this.keyIndex++
                this.trancheMap.set(input.key, input)
            })
            updateNonDeletedRecordsWithoutIds.forEach(input => {
                input.Tranche_Number__c = this.trancheNumber
                input.key = this.keyIndex
                this.trancheNumber++
                this.keyIndex++
                this.trancheMap.set(input.key, input)
            })
            this.trancheList = Array.from(this.trancheMap.values())
            this.getVisibleFieldsForTrancheData()
            //this.refreshApex(visibleFieldsForTranche)
        }
        this.recordCount = this.trancheList.length
        this.calculateTotals()
    }

    /*connectedCallback(){
        this.totalDisbursement=0
        getTrancheDetails({recordId: this.loanApp.Id}).then((data=>{
            if(data && data.length>0){
                this.keyIndex=0
                data.forEach(input => {
                    input.isSaved=true
                    this.trancheMap.set(input.Tranche_Number__c, input)
                    this.tranches.push(input.Tranche_Number__c)
                });
                this.trancheList = Array.from(this.trancheMap.values())  
                this.addTranche=false
                this.recordCount = this.trancheList.length
                this.calculateTotals()
            }else{
                this.trancheMap.set(1, {})
                this.trancheList = Array.from(this.trancheMap.values()) 
            }
        }))
           

    }*/

    updateModifiedData(data) {
        this.keyIndex = 0
        this.trancheNumber = 1
        this.showToastMessage('Success', 'Tranche Records Updated Successfully', 'success')
        this.trancheMap = new Map();
        this.trancheList = []
        if (data && data.length > 0) {
            this.keyIndex = 0
            data.forEach(input => {
                input.key = this.keyIndex
                input.isChecked = false
                this.trancheMap.set(this.keyIndex, input)
                this.keyIndex++
                this.trancheNumber++
            });
            this.readOnly = true
            this.trancheList = Array.from(this.trancheMap.values())
            this.recordCount = this.trancheList.length
            //refreshApex(this.trancheList);
        }
    }

    calculateTotals() {
        this.totalDisbursement = 0
        this.trancheList.forEach(element => {
            if (element.Disbursement_Amount__c)
                this.totalDisbursement = parseFloat(element.Disbursement_Amount__c) + this.totalDisbursement
        })
    }

    showToastMessage(titleValue, messageValue, variantValue) {

        const event = new ShowToastEvent({
            title: titleValue,
            message: messageValue,
            variant: variantValue
        });
        this.dispatchEvent(event);

    }

    /*setTrancheNumber(){
        if(!this.tranches.includes(1)){
            this.trancheNumber=1
        }else if(!this.tranches.includes(2)){
            this.trancheNumber=2
        }else if(!this.tranches.includes(3)){
            this.trancheNumber=3
        }
        
    }*/

    /*handleAddNewTranche(){

        if(this.trancheList.length == 3){
            this.showToastMessage('Error','Maximum 3 Tranches can be added','error')
        }else{
            this.setTrancheNumber();
            this.addTranche=true
            this.trancheMap.set(this.trancheNumber, {})
            this.trancheList = Array.from(this.trancheMap.values())
            console.log('Tranche list '+JSON.stringify(this.trancheList))
            this.trancheRecord={}
        }
        
    }*/

    /*handleSave(event){
        console.log('event.data '+JSON.parse(JSON.stringify(event.detail.data)))
        event.detail.data.isSaved=event.detail.isSaved
        this.trancheMap.set(event.detail.key, JSON.parse(JSON.stringify(event.detail.data)))
        this.tranches.push(event.detail.key)
        this.trancheList = Array.from(this.trancheMap.values())
        this.recordCount = this.trancheList.length
        this.addTranche=false
        this.calculateTotals()
    }*/

    /*handleRowAction(event){
        this.addTranche=event.detail.isAdd
        event.detail.data.isSaved=event.detail.isSaved
        this.trancheMap.set(event.detail.key, JSON.parse(JSON.stringify(event.detail.data)))
        this.trancheNumber=event.detail.key;
        this.trancheList = Array.from(this.trancheMap.values())
        if(this.addTranche){
            this.trancheRecord =this.trancheMap.get(event.detail.key)
        }
        
    }*/

    @api getNetDisbursementvalue() {
        this.calculateTotals()
        var charges = this.loanApp.Total_Charges__c ? this.loanApp.Total_Charges__c : 0
        //if(this.totalDisbursement!=(this.loanApp.Loan_Amount__c-charges)){
        if (this.totalDisbursement != (this.loanApp.Total_Loan_Amount__c)) {
            return false
        } else {
            return true
        }

    }

    @api getUnsavedData() {
        if (!this.readOnly) {
            return true
        } else {
            return false
        }
    }

    /*handleDeleteAction(event){

        this.trancheMap.delete(event.detail.key)
        this.tranches = this.tranches.filter(function (element) {
            return parseInt(element) != parseInt(event.detail.key)
        })
        this.trancheNumber=event.detail.key
        this.trancheList = Array.from(this.trancheMap.values())
        this.recordCount = this.trancheList.length
        this.addTranche=false
        this.calculateTotals()
    }*/
}