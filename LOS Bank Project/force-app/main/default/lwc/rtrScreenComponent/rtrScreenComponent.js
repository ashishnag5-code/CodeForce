import { LightningElement, track, api, wire } from 'lwc';
import getPicklistOptions from '@salesforce/apex/RtrScreenController.getPicklistOptions';
import getBankAccountRecords from '@salesforce/apex/RtrScreenController.getBankAccountRecords';
import upsertBankAccountRecords from '@salesforce/apex/RtrScreenController.upsertBankAccountRecords';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Bank_Account_Records__c from '@salesforce/schema/Bank_Account_Records__c';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import { loadStyle } from "lightning/platformResourceLoader";
import WrappedHeaderTable from "@salesforce/resourceUrl/WrappedHeaderTable";
import LOANTYPE_FIELD from '@salesforce/schema/Bank_Account_Records__c.Type_of_Loan__c';
import STATUS_FIELD from '@salesforce/schema/Bank_Account_Records__c.Status__c';
import EMIOBLIGATION_FIELD from '@salesforce/schema/Bank_Account_Records__c.EMI_Considered_for_Obligation__c';
import getMaterialFields from '@salesforce/apex/Utility.getMaterialFields';
import checkMaterialFields from '@salesforce/apex/Utility.checkMaterialFields';
import reCalculateFoir from '@salesforce/apex/RtrScreenController.reCalculateFoir';
import { deleteRecord } from 'lightning/uiRecordApi';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
// Sachin - SFAU-4273 - FOIR not getting recalculated after RTR manuals are added ( Refresh Issue )
import { createMessageContext, publish, } from 'lightning/messageService';
import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c';


const columns = [
    {
        label: 'Financier Name',
        fieldName: 'Name_of_the_Financier__c',
        wrapText: true
    },
{
        label: 'Ownership Indicator',
        fieldName: 'Owenership_Indicator__c',
        wrapText: true
    },
    {
        label: 'Loan Type',
        fieldName: 'Type_of_Loan__c',
        wrapText: true
    },
    {
        label: 'Loan Amount',
        fieldName: 'Loan_Amount__c'
    },
    {
        label: 'POS',
        fieldName: 'POS__c'
    },
    {
        label: 'ROI',
        fieldName: 'ROI__c',
    },
    {
        label: 'Emi Paid (No.)',
        fieldName: 'No_of_Emi_Paid__c'
    },
    {
        label: 'Tenure',
        fieldName: 'Tenure__c'
    },
    {
        label: 'EMI Start Date',
        fieldName: 'Payment_History_End_Date__c',
        type: 'date-local',
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    },
    {
        label: 'EMI Amount',
        fieldName: 'EMI_Amount__c'
    },
    {
        label: 'Repayment History',
        fieldName: 'Track_Record__c'
    },
    {
        label: 'Average Delay in Last 12 Months',
        fieldName: 'Average_12_Month_DPD__c'
    },
    {
        label: 'Peak Delay Last 12 Months',
        fieldName: 'Highest_12_Month_DPD__c'
    },
    {
        label: 'Average Delay',
        fieldName: 'Average_Delay__c'
    },
    {
        label: 'Peak Delay All',
        fieldName: 'Highest_Overall_DPD__c'
    },
    {
        label: 'Status',
        fieldName: 'RTR_Status__c',
        editable: true,
        type: 'picklistColumn',
        typeAttributes: {
            placeholder: 'Choose Status', options: { fieldName: 'statusPickListOptions' },
            value: { fieldName: 'RTR_Status__c' }, // default value for picklist,
            context: { fieldName: 'Id' } // binding account Id with context variable to be returned back
        }
    },
    {
        label: 'Reported Date',
        fieldName: 'Reported_Date__c',
        type: 'date-local',
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    },
    {
        label: 'EMI Considered for Obligation',
        fieldName: EMIOBLIGATION_FIELD.fieldApiName,
        type: 'picklistColumn',
        editable: true,
        typeAttributes: {
            placeholder: 'Choose Yes/No', options: { fieldName: 'pickListOptions' },
            value: { fieldName: EMIOBLIGATION_FIELD.fieldApiName }, // default value for picklist,
            context: { fieldName: 'Id' } // binding account Id with context variable to be returned back
        }
    },
    {
        label: 'Remarks',
        fieldName: 'Remarks__c',
        editable: true,
        wrapText: true
    }
];

const actions = [
    { label: 'Delete', name: 'delete' }
];

const columns1 = [
    {
        label: 'Financier Name',
        fieldName: 'Name_of_the_Financier__c',
        type: 'text',
        editable: true,
        wrapText: true
    },
{
        label: 'Owenership Indicator',
        fieldName: 'Owenership_Indicator__c',
        type: 'text',
        editable: true,
        wrapText: true
    },
    
    {
        label: 'Loan Type',
        fieldName: LOANTYPE_FIELD.fieldApiName,
        type: 'picklistColumn',
        editable: true,
        typeAttributes: {
            placeholder: 'Choose Loan Type', options: { fieldName: 'loanTypePickListOptions' },
            value: { fieldName: LOANTYPE_FIELD.fieldApiName }, // default value for picklist,
            context: { fieldName: 'Id' } // binding account Id with context variable to be returned back
        }
    },
    {
        label: 'Loan Amount',
        type: 'number',
        fieldName: 'Loan_Amount__c',
        editable: true
    },
    {
        label: 'POS',
        fieldName: 'POS__c',
        type: 'number',
        editable: true
    },
    {
        label: 'ROI',
        fieldName: 'ROI__c',
        editable: true
    },
    {
        label: 'Emi Paid (No.)',
        fieldName: 'No_of_Emi_Paid__c',
        type: 'number',
        editable: true
    },
    {
        label: 'Tenure',
        fieldName: 'Tenure__c',
        type: 'number',
        editable: true
    },
    {
        label: 'EMI Start Date',
        fieldName: 'Payment_History_End_Date__c',
        type: 'date-local',
        editable: true,
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    },
    {
        label: 'EMI Amount',
        fieldName: 'EMI_Amount__c',
        type: 'number',
        editable: true
    },
    {
        label: 'Average Delay in Last 12 Months',
        fieldName: 'Average_12_Month_DPD__c'
    },
    {
        label: 'Peak Delay Last 12 Months',
        fieldName: 'Highest_12_Month_DPD__c'
    },
    {
        label: 'Average Delay',
        fieldName: 'Average_Delay__c'
    },
    {
        label: 'Peak Delay All',
        fieldName: 'Highest_Overall_DPD__c'
    },
    
    {
        label: 'Status',
        fieldName: 'RTR_Status__c',
        type: 'picklistColumn',
        editable: true,
        typeAttributes: {
            placeholder: 'Choose Status', options: { fieldName: 'statusPickListOptions' },
            value: { fieldName: 'RTR_Status__c' }, // default value for picklist,
            context: { fieldName: 'Id' } // binding account Id with context variable to be returned back
        }

    },
    {
        label: 'Loan Track Verified From',
        fieldName: 'Loan_Track_Verified_From__c',
        type: 'text',
        value: 'Manual',
        editable: false
    },
    {
        label: 'Reported Date',
        fieldName: 'Reported_Date__c',
        type: 'date-local',
        editable: true,
        typeAttributes: {
            day: "numeric",
            month: "numeric",
            year: "numeric"
        }
    },
    {
        label: 'EMI Considered for Obligation',
        fieldName: EMIOBLIGATION_FIELD.fieldApiName,
        type: 'picklistColumn',
        editable: true,
        typeAttributes: {
            placeholder: 'Choose Yes/No', options: { fieldName: 'pickListOptions' },
            value: { fieldName: EMIOBLIGATION_FIELD.fieldApiName }, // default value for picklist,
            context: { fieldName: 'Id' } // binding account Id with context variable to be returned back
        }
    },
    {
        label: 'Remarks',
        fieldName: 'Remarks__c',
        type: 'text',
        editable: true,
        wrapText: true
    },
    {
        type: 'action',
        typeAttributes: { rowActions: actions, menuAlignment: 'left' },
        context: { fieldName: 'Id' }
    }
];


export default class RtrScreenComponent extends LightningElement {
    //fields = [LOANTYPE_FIELD,STATUS_FIELD,EMIOBLIGATION_FIELD,FINANCIER_FIELD,LOAN_AMOUNT_FIELD,POS_FIELD,ROI_FIELD,NO_EMI_PAID_FIELD,TENURE_FIELD,PAYMENT_HISTORY_FIELD,EMI_AMOUNT_FIELD,REPORTED_DATE_FIELD,REMARKS_FIELD,APPLICANT_FIELD,Bureau_Results__c];
    messageContext = createMessageContext();
    isLoaded = false;
    showBureauTable = false;
    showButton = false;
    showManualTable = false;
    @api recordId;
    @track showCreateForm=false;
    applicantId;
    burResId;
    initialOption = 'Please select the applicant';
    labelVal = 'Choose Applicant from Drop down';
    /*
    applicantType;
    repaymentHistory;
    applicantTypeOptions = [
        { label: 'Applicant', value: 'Applicant' },
        { label: 'Co-Applicant', value: 'Co-Applicant' }
    ];
    
    repaymentHistoryOptions = [
        { label: 'ETR', value: 'ETR' },
        { label: 'GTR', value: 'GTR' },
        { label: 'PTR', value: 'PTR' },
        { label: 'NA', value: 'NA' }
    ];
    */

    loanTypeOptions = [
        { label: 'Business Loan', value: 'Business Loan' },
        { label: 'Personal Loan', value: 'Personal Loan' },
        { label: 'Vehicle Loan', value: 'Vehicle Loan' },
        { label: 'Housing Loan & Other', value: 'Housing Loan & Other' }
    ];

    /*variables for RTR Bureau Inline DataTable*/
    columns = columns;
    showSpinner = false;
    @track data = [];
    @track barData;
    @track draftValues = [];
    lastSavedData = [];
    @track pickListOptions;
    @track statusPickListOptions;
    @track loanTypePickListOptions;

    /*variables for RTR Manual Inline DataTable*/
    columns1 = columns1;
    showSpinner1 = false;
    @track data1 = [];
    @track barData1;
    @track draftValues1 = [];
    lastSavedData1 = [];
    index = 0;

    renderedCallback() {
        if (!this.stylesLoaded) {
            Promise.all([loadStyle(this, WrappedHeaderTable)])
                .then(() => {
                    console.log("Custom styles loaded");
                    this.stylesLoaded = true;
                })
                .catch((error) => {
                    console.error("Error loading custom styles");
                });
        }


    }

    connectedCallback() {
        getPicklistOptions()
            .then(data => {
                if (data) {
                    console.log('data---->', JSON.stringify(data));
                    this.pickListOptions = [];
                    this.statusPickListOptions = [];
                    this.loanTypePickListOptions = [];
                    data.forEach(ele => {
                        var options = [];
                        if (ele.Picklist_Values__c.includes(',')) {
                            options = ele.Picklist_Values__c.split(',');
                        }
                        else {
                            options = ele.Picklist_Values__c;
                        }
                        console.log('options---->', JSON.stringify(options));
                        options.forEach(element => {
                            if (ele.MasterLabel == 'EMI_Considered_for_Obligation') {
                                this.pickListOptions.push({ label: element, value: element });
                            }
                            else if (ele.MasterLabel == 'Status') {
                                this.statusPickListOptions.push({ label: element, value: element });
                            }
                            else if (ele.MasterLabel == 'Loan_Type') {
                                this.loanTypePickListOptions.push({ label: element, value: element });
                            }

                        })
                        console.log('this.loanTypePickListOptions---->', JSON.stringify(this.loanTypePickListOptions));
                        console.log('this.statusPickListOptions---->', JSON.stringify(this.statusPickListOptions));
                        console.log('this.pickListOptions---->', JSON.stringify(this.pickListOptions));
                    })
                }
            })
            .catch(error => {
                console.log(error);
                this.showToast('Error', 'An Error Occured!!', 'error', 'dismissable');

            })
        this.disableFieldsAsPerMetadata();

    }

    @wire(getObjectInfo, { objectApiName: Bank_Account_Records__c })
    objectInfo;

    get manualRecordTypeId() {
        if ( this.objectInfo.data ) {
            const recTyps = this.objectInfo.data.recordTypeInfos;
            console.log('rec type'+JSON.stringify(recTyps));
            console.log('rec type id'+ Object.keys( recTyps ).find( recTyp => recTyps[ recTyp ].name === 'Manual' ));
            return Object.keys( recTyps ).find( recTyp => recTyps[ recTyp ].name === 'Manual' );
        } else {
            return null;
        }
    }

    /*
    
        @wire(getObjectInfo, { objectApiName: BAR_OBJECT })
        objectInfo;
    
        //fetch picklist options
        @wire(getPicklistValues, {
            recordTypeId: "$objectInfo.data.defaultRecordTypeId",
            fieldApiName: EMIOBLIGATION_FIELD
        })
    
        wirePickList({ error, data }) {
            if (data) {
                this.pickListOptions = data.values;
                console.log('this.pickListOptions',JSON.stringify(this.pickListOptions));
            } else if (error) {
                console.log(error);
            }
        }
        */

    //here I pass picklist option so that this wire method call after above method
    @wire(getBankAccountRecords, { appId: '$applicantId', pickList: '$pickListOptions' })
    barData(result) {
        this.barData = result;
        this.data = [];
        this.data1 = [];
        if (result.data) {
            console.log('result.data', JSON.stringify(result.data));
            this.burResId = result.data.burResId;
            if(result.data.barList){
            result.data.barList.forEach(obj => {
                if ((obj.Name_of_the_Financier__c === undefined || obj.Name_of_the_Financier__c === null || !obj.Name_of_the_Financier__c.startsWith('AU'))) {
                if (obj.RecordType.Name == 'CIBIL') {
                    this.data.push(JSON.parse(JSON.stringify(obj)));
                }
                else if (obj.RecordType.Name == 'Manual') {
                    this.data1.push(JSON.parse(JSON.stringify(obj)));
                }
            }
            })
            if (this.data.length > 0) {
                this.showBureauTable = true;
                //this.data = JSON.parse(JSON.stringify(result.data));
                this.data.forEach(ele => {
                    ele.pickListOptions = this.pickListOptions;
                        ele.statusPickListOptions = this.statusPickListOptions;
                        if(ele.EMI_Amount__c){
                            ele.EMI_Amount__c = parseInt(ele.EMI_Amount__c).toString();
                        }
                })
                this.lastSavedData = JSON.parse(JSON.stringify(this.data));
            }
            else {
                this.showBureauTable = false;
            }
            if (this.data1.length > 0) {
                this.showManualTable = true;
                //this.data = JSON.parse(JSON.stringify(result.data));
                this.data1.forEach(ele => {
                    ele.pickListOptions = this.pickListOptions;
                    ele.statusPickListOptions = this.statusPickListOptions;
                    ele.loanTypePickListOptions = this.loanTypePickListOptions;
                })
                console.log('this.data1', this.data1);
                this.lastSavedData1 = JSON.parse(JSON.stringify(this.data1));
            }
            else {
                this.showManualTable = false;
            }
        }
        } else if (result.error) {
            console.log('barData error--->', result.error);
            this.data = undefined;
            this.data1 = undefined;
        }
    };

    updateDataValues(updateItem) {
        let copyData = JSON.parse(JSON.stringify(this.data));

        copyData.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });

        //write changes back to original data
        this.data = [...copyData];
    }



    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [...this.draftValues];
        //store changed value to do operations
        //on save. This will enable inline editing &
        //show standard cancel & save button
        copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });

        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
    }

    //handler to handle cell changes & update values in draft values
    handleCellChange(event) {
        //this.updateDraftValues(event.detail.draftValues[0]);
        let draftValues = event.detail.draftValues;
        draftValues.forEach(ele => {
            this.updateDraftValues(ele);
        })
    }

    handleSave(event) {
        this.showSpinner = true;
        this.saveDraftValues = this.draftValues;

        const recordInputs = this.saveDraftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
        console.log('recordInputs-->' + JSON.stringify(recordInputs));
        // Updateing the records using the UiRecordAPi
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(res => {
            this.showToast('Success', 'Records Updated Successfully!', 'success', 'dismissable');
            this.draftValues = [];
            return this.refresh();
        }).catch(error => {
            console.log(error);
            this.showToast('Error', 'An Error Occured!!', 'error', 'dismissable');
        }).finally(() => {
            //this.data = [];
            this.draftValues = [];
            // Added By Ashish || FOIR Changes || START
            const draftValues = this.saveDraftValues;
            const filteredList = [];
 
            for (let i = 0; i < draftValues.length; i++) {
             const item = draftValues[i];
            filteredList.push(item.Id);
            
            }
            console.log('filteredList-->' + JSON.stringify(filteredList));
            if (filteredList.length > 0) {
             reCalculateFoir({
                 bankIds: filteredList
             })
                 .then(data => {
                     console.log('foirUpdated');
                     // Sachin - SFAU-4273 - FOIR not getting recalculated after RTR manuals are added ( Refresh Issue )
                    const payload = { recordIdOfSobject: this.recordId, refreshPage: 'Yes' };
                    console.log({payload});
                    publish( this.messageContext, pageRefreshOnMaterialFieldChange, payload );
                 })
            }
            //END
            this.showSpinner = false;
        });

         
    }

    handleCancel(event) {
        //remove draftValues & revert data changes
        this.data = JSON.parse(JSON.stringify(this.lastSavedData));
        this.draftValues = [];
    }

    //handle manual add

    updateDraftValues1(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [...this.draftValues1];
        //store changed value to do operations
        //on save. This will enable inline editing &
        //show standard cancel & save button
        copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });

        if (draftValueChanged) {
            this.draftValues1 = [...copyDraftValues];
        } else {
            this.draftValues1 = [...copyDraftValues, updateItem];
        }
    }

   //handler to handle cell changes & update values in draft values
    handleCellChange1(event) {
        //this.updateDraftValues(event.detail.draftValues[0]);
        let draftValues = event.detail.draftValues;
        
        draftValues.forEach(ele => {
            // R2-2443
            if(ele.Loan_Amount__c && parseFloat(ele.Loan_Amount__c) > 999999999){
                this.showToast('Waring', 'Loan Amount can not accept more than 9 Digit!', 'error', 'sticky');
            }
            else if(ele.POS__c && parseFloat(ele.POS__c) > 999999999){
                this.showToast('Waring', 'POS can not accept more than 9 Digit!', 'error', 'sticky');
            } 
            else if(ele.ROI__c &&  parseFloat(ele.ROI__c) > 99){
                this.showToast('Waring', 'ROI can not accept more than 2 Digit!', 'error', 'sticky');
            }
            else if(ele.ROI__c &&  parseFloat(ele.ROI__c) > 99){
                this.showToast('Waring', 'ROI can not accept more than 2 Digit!', 'error', 'sticky');
            }
            else if(!ele.Name_of_the_Financier__c){
                this.showToast('Waring', 'Name of Financier is mandatory!', 'error', 'sticky');
            }
            else if(ele.Name_of_the_Financier__c && ele.Name_of_the_Financier__c.toUpperCase().startsWith('AU')){
                this.showToast('Waring', 'Name of Financier cannot be AU bank', 'error', 'sticky');
            }
            else if(ele.No_of_Emi_Paid__c && parseFloat(ele.No_of_Emi_Paid__c) > 999){
                this.showToast('Waring', 'No of Emi Paid can not accept more than 3 Digit!', 'error', 'sticky');
            }
            else if(ele.Tenure__c && parseFloat(ele.Tenure__c) > 999){
                this.showToast('Waring', 'Tenure can not accept more than 3 Digit!', 'error', 'sticky');
            }
            else if(ele.EMI_Amount__c && parseFloat(ele.EMI_Amount__c) > 999999){
                 this.showToast('Waring', 'EMI Amount Field can not accept more than 6 Digit!', 'error', 'sticky');
            }
            // R2-2443
            else {
                this.updateDraftValues1(ele);
            }
        
        })
        
    }

    handleSave1(event) {
        this.showSpinner1 = true;
        this.saveDraftValues1 = this.draftValues1;
        console.log('this.draftValues1', JSON.stringify(this.draftValues1));
        let values = this.draftValues1.forEach(ele => {
            if (ele.Id.includes('row-')) {
                delete ele.Id;
                return ele;
            }
        })
        // Upserting the records

        upsertBankAccountRecords({
            bars: this.draftValues1,
            appId: this.applicantId,
            burResId: this.burResId

        })
            .then(data => {
                this.showToast('Success', 'Records Upserted Successfully!', 'success', 'dismissable');
                this.draftValues1 = [];
                 // Added By Ashish || FOIR Changes || START
                 console.log('this.saveDraftValues1 -->' + JSON.stringify(this.saveDraftValues1));
                 let val = this.saveDraftValues1;
                 const filteredList = [];
                 for (let i = 0; i < val.length; i++) {
                     const item = val[i];
                     filteredList.push(item.Id);
                 }
                 reCalculateFoir({
                     bankIds: filteredList
                 })
                     .then(data => {
                         console.log('foirUpdated');
                         // Sachin - SFAU-4273 - FOIR not getting recalculated after RTR manuals are added ( Refresh Issue )
                        const payload = { recordIdOfSobject: this.recordId, refreshPage: 'Yes' };
                        console.log({payload});
                        publish( this.messageContext, pageRefreshOnMaterialFieldChange, payload );
                     })
                 //END
                return this.refresh();
            })
            .catch(error => {
                console.log(error);
                this.showToast('Error', 'An Error Occured!!', 'error', 'dismissable');

            }).finally(() => {
                this.draftValues1 = [];
                this.showSpinner1 = false;
            });

    }

    handleCancel1(event) {
        //remove draftValues & revert data changes
        this.data1 = JSON.parse(JSON.stringify(this.lastSavedData1));
        this.draftValues1 = [];
    }

    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    // This function is used to refresh the table once data updated
    async refresh() {
        await refreshApex(this.barData);
    }


    handleApplicantChange(event) {
        let selected = event.detail;
        let picklistName = selected.target.name;
        let picklistValue = selected.target.value;
        let picklistLabel = selected.target.label;
        console.log('picklistName', picklistName);
        console.log('picklistValue', picklistValue);
        console.log('picklistLabel', picklistLabel);
        if (picklistValue != this.initialOption) {
            this.applicantId = picklistValue;
            this.showButton = true;
        }
    }

    bar = {
        Name_of_the_Financier__c: '',
        Owenership_Indicator__c :'',
        Type_of_Loan__c: '',
        Loan_Amount__c: '',
        POS__c: '',
        No_of_Emi_Paid__c: '',
        Tenure__c: '',
        Payment_History_End_Date__c: '',
        EMI_Amount__c: '',
        RTR_Status__c: '',
        Reported_Date__c: '',
        EMI_Considered_for_Obligation__c: '',
        Remarks__c: '',
        key: ''
    }

    handleAddRtrManualClick() {
        restricAccess({
            compName: 'rtrScreenComponent' ,loanId: this.recordId
            })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save RTR Screen',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }else{
                    this.showCreateForm = true;
                }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
            })
        
        /*this.index++;
        var i = this.index;
        this.bar.key = i;
        this.data1.push(JSON.parse(JSON.stringify(this.bar)));
        this.lastSavedData1.push(JSON.parse(JSON.stringify(this.bar)));
        console.log('data1 ', JSON.stringify(this.data1));
        this.data1.forEach(ele => {
            ele.pickListOptions = this.pickListOptions;
            ele.statusPickListOptions = this.statusPickListOptions;
            ele.loanTypePickListOptions = this.loanTypePickListOptions;
        });
        this.hideShowManualTable();*/
    }

    handleRowAction(event) {
        if (event.detail.action.name == 'delete') {
            console.log(event.detail.row.Id);
            this.handleInactiveRow(event.detail.row.Id);
        }
        this.showSpinner1 = true;
        const action = event.detail.action;
        console.log('action', action);
        const row = event.detail.row;
        const rows = this.data1;
        const rowIndex = rows.indexOf(row);
        console.log('row', row);
        console.log('rowIndex', rowIndex);
        if (this.data1.length > 1) {
            this.data1.splice(rowIndex, 1);
            this.lastSavedData1.splice(rowIndex, 1);
            this.index--;
            this.showSpinner1 = false;
        } else if (this.data1.length == 1) {
            this.data1 = [];
            this.lastSavedData1 = [];
            this.index = 0;
            this.showSpinner1 = false;
        }

        /*
                const action = event.detail.action;
                const row = event.detail.row;
                switch (action.name) {
                    case 'show_details':
                        alert('Showing Details: ' + JSON.stringify(row));
                        break;
                    case 'delete':
                        const rows = this.data1;
                        const rowIndex = rows.indexOf(row);
                        rows.splice(rowIndex, 1);
                        this.data1 = rows;
                        break;
                }
                */
        this.hideShowManualTable();
    }

    hideShowManualTable() {
        this.showManualTable = false;
        setInterval(() => {
            this.showManualTable = true;
        }, 200);
    }

    handleOnChange(event){
        this.typeOfLoan = event.detail.value;
    }

    handleSubmit(event){
        event.preventDefault();
        console.log('event.detail.fields', event.detail.fields);
        const fields = event.detail.fields;
        fields.Type_of_Loan__c = this.typeOfLoan;
        console.log('onsubmit event recordEditForm' + JSON.stringify(fields));
        // R2-2443
        if(fields.Loan_Amount__c && parseFloat(fields.Loan_Amount__c)>999999999){
            this.showToast('Waring', 'Loan Amount can not accept more than 9 Digit!', 'error', 'sticky');
        }
         else if(fields.POS__c && parseFloat(fields.POS__c) > 999999999){
            this.showToast('Waring', 'POS can not accept more than 9 Digit!', 'error', 'sticky');
        } 
        else if(fields.ROI__c &&  parseFloat(fields.ROI__c) > 99){
            this.showToast('Waring', 'ROI can not accept more than 2 Digit!', 'error', 'sticky');
        }
        else if(fields.ROI__c &&  parseFloat(fields.ROI__c) > 99){
            this.showToast('Waring', 'ROI can not accept more than 2 Digit!', 'error', 'sticky');
        }
        else if(!fields.Name_of_the_Financier__c){
            this.showToast('Waring', 'Name of Financier is mandatory!', 'error', 'sticky');
        }
        else if(fields.Name_of_the_Financier__c && fields.Name_of_the_Financier__c.toUpperCase().startsWith('AU')){
            this.showToast('Waring', 'Name of Financier cannot be AU bank', 'error', 'sticky');
        }
        // else if(fields.ROI__c && fields.ROI__c.includes('.') && fields.ROI__c.length>5){
        //     this.showToast('Waring', 'ROI can not accept more than 2.2 Digit!', 'warning', 'dismissable');
        // }
        else if(fields.No_of_Emi_Paid__c && parseFloat(fields.No_of_Emi_Paid__c) > 999){
            this.showToast('Waring', 'No of Emi Paid can not accept more than 3 Digit!', 'error', 'sticky');
        }
        else if(fields.Tenure__c && parseFloat(fields.Tenure__c) > 999){
            this.showToast('Waring', 'Tenure can not accept more than 3 Digit!', 'error', 'sticky');
        }
        else if(fields.EMI_Amount__c && parseFloat(fields.EMI_Amount__c) > 999999){
             this.showToast('Waring', 'EMI Amount Field can not accept more than 6 Digit!', 'error', 'sticky');
        }
        // R2-2443
        
        
        else{
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            this.showCreateForm = false;
        }
    }


    handleSuccess(event) {
        console.log('record id '+event.detail.id);
        const filteredList = [];
        filteredList.push(event.detail.id);
        reCalculateFoir({
            bankIds: filteredList
        })
            .then(data => {
                console.log('foirUpdated');
                // Sachin - SFAU-4273 - FOIR not getting recalculated after RTR manuals are added ( Refresh Issue )
                const payload = { recordIdOfSobject: this.recordId, refreshPage: 'Yes' };
                console.log({payload});
                publish( this.messageContext, pageRefreshOnMaterialFieldChange, payload );
            })
        this.showCreateForm = false;
        const evt = new ShowToastEvent({
            title: '',
            message: 'Record Saved Successfully',
            variant: 'success',
        });
        this.dispatchEvent(evt);
        this.refresh();
    }

    handleFormCancel(){
        this.showCreateForm = false;
    }

    async disableFieldsAsPerMetadata() {
        this.fieldsToBeDisabled = await getMaterialFields({ strScreen: 'RTR Manual', strLoanId: this.recordId });
        if (this.fieldsToBeDisabled) {
            this.fieldsToBeDisabled.forEach((input => {
                console.log(' input field name ', input);
                if (input == 'Applicant__c' || input == 'Bureau_Results__c') {
                    // this.bankNameReadOnly = true
                } else {
                    if (this.template.querySelectorAll('[data-name="' + input + '"]')) {
                        this.template.querySelectorAll('[data-name="' + input + '"]').forEach((inputToBeDisabled => {
                            console.log(' input field name disabled', input);
                            inputToBeDisabled.disabled = true
                        }))
                    }
                }
            }))
        }
    }
    /*
        checkMaterialFlds() {
            checkMaterialFields({strScreen:'RTR Bureau', strLoanId: this.recordId, lstFieldsAPI: this.fldForBreRunList})
                .then(result => {
                    this.contacts = result;
                })
                .catch(error => {
                    this.error = error;
                });
        }
    */


    /*
        handleChange(event) {
            console.log('onchange value', event.target.value);
        }
    
    */

    handleInactiveRow(recId) {
        deleteRecord(recId)
            .then(() => {
                this.refresh();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record deleted',
                        variant: 'success'
                    })
                );

            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }


}