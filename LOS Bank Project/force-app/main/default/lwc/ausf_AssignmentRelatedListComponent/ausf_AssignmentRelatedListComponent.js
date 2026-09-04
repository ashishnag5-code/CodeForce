import { LightningElement, track, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';sendBackSanctionData
import getAssignmentRelatedRecords from '@salesforce/apex/AUSF_AssignmentRelatedRecordsCntlr.getAssignmentRelatedRecords';
import sendBackSanctionData from '@salesforce/apex/AUSF_AssignmentRelatedRecordsCntlr.sendBackSanctionData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



const FIELDS = ['Assignment__c.Loan_Application__c'];



export default class Ausf_AssignmentRelatedListComponent extends LightningElement {
    @api recordId;
    @api objectApiName;
    applicationId = '';
    @api relatedObject = '';
    //headerLabel = 'Test Header';
    @track columns = [];
    @track tableData = [];
    @track isSanctionRelatedList = false;
    @track selectedSendBackData = [];

    @track approvalRemarks = '';
    @track openRemarksModal = false;
    @track isCreditSendBack = false;

    handleRemarkChange(evt){
        this.approvalRemarks = evt.detail.value;
    }

    closeModal(){
        this.openRemarksModal = false;
    }

    connectedCallback(){

        this.isSanctionRelatedList = (this.relatedObject == 'Sanction_Condition__c');
        //console.log('test '+this.isSanctionRelatedList)
    }
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            let message = 'Unknown error';

        } else if (data) {
            this.applicationId = data.fields.Loan_Application__c.value;
            console.log('application Id '+this.applicationId)
            this.setColumns();
            this.getRelatedRecords();
        }
    }

    sendBackToRO(){
        this.approvalRemarks = '';
        this.openRemarksModal = true;
        this.isCreditSendBack = false;
    }

    sendBackToROSubmit(){
        if(!this.selectedSendBackData || !this.selectedSendBackData.length){
            this.showNotification('Error','Please select a record to proceed','error');
            return;
        }
        let sanctionConditionId = [];
        this.selectedSendBackData.forEach(rec=>{
            sanctionConditionId.push(rec.id)
        })
        this.sendBackSanctionData(sanctionConditionId, this.applicationId, true);

    }

    sendBack(){
        if(this.isCreditSendBack){
            this.sendBackToCreditSubmit();
        }
        else{
            this.sendBackToROSubmit();
        }

    }


    sendBackToCredit(evt){
        this.approvalRemarks = '';
        this.openRemarksModal = true;
        this.isCreditSendBack = true;
    }

    sendBackToCreditSubmit(){
        if(!this.selectedSendBackData || !this.selectedSendBackData.length){
            this.showNotification('Error','Please select a record to proceed','error');
            return;
        }
        let sanctionConditionId = [];
        this.selectedSendBackData.forEach(rec=>{
            sanctionConditionId.push(rec.id)
        })
        this.sendBackSanctionData(sanctionConditionId, this.applicationId, false);

    }

    sendBackSanctionData(sanctionConditionIds, applicationId, isComplianceSentBack){
        sendBackSanctionData({
            sanctionIds : sanctionConditionIds,
            loanId : applicationId,
            isComplianceSentBack : isComplianceSentBack,
            remarks : this.approvalRemarks
        })
        .then(res=>{
            this.showNotification('Success','Success in sending back the record','success');
            console.log('test '+res);
            this.openRemarksModal = false;
            window.location.reload();
        })
        .catch(err=>{
            this.showNotification('Error','Error in sending back the record','error');
            console.log('err '+JSON.stringify(err));
        })
    }

    onRowSelection(evt){
        const selectedRows = evt.detail.selectedRows;
        console.log('test '+selectedRows)
        this.selectedSendBackData = selectedRows;

    }

    setColumns(){
        if(this.relatedObject == 'Sanction_Condition__c'){
            this.columns = [{
                label: 'Sanction Condition',
                fieldName: 'recordLink',
                type: 'url',
                typeAttributes: { label: { fieldName: 'conditionName' }, target: '_blank' }
            },
            {
                label: 'Raised By',
                fieldName: 'raisedBy',
                type: 'text'

            },
            {
                label: 'Remarks',
                fieldName: 'remarks',
                type: 'text'

            },
            {
                label: 'Sanction Type',
                fieldName: 'type',
                type: 'text'

            },
            {
                label: 'Status',
                fieldName: 'status',
                type: 'text'

            },
            {
                label: 'Is Waived',
                fieldName: 'isWaived',
                type: 'boolean'

            }

            ]

        }
        else if(this.relatedObject == 'Query__c'){
            this.columns = [{
                label: 'Query Name',
                fieldName: 'queryName',
                type: 'text'
            },
            {
                label: 'Remarks',
                fieldName: 'remarks',
                type: 'text'

            },
            {
                label: 'Type',
                fieldName: 'type',
                type: 'text'

            },
            {
                label: 'Sub Type',
                fieldName: 'subType',
                type: 'text'

            }

            ]

        }
        else if(this.relatedObject == 'Deviation__c'){
            this.columns = [{
                label: 'Deviation Name',
                fieldName: 'deviationName',
                type: 'text'
            },
            {
                label: 'Level',
                fieldName: 'deviationLevel',
                type: 'text'
            },
            {
                label: 'Type',
                fieldName: 'deviationType',
                type: 'text'
            }
            ]
        }
    }



    getRelatedRecords(){
        getAssignmentRelatedRecords({
            loanId : this.applicationId,
            objectName : this.relatedObject
        })
        .then(res=>{
            console.log('res=>'+JSON.stringify(res));
            if(this.relatedObject == 'Sanction_Condition__c'){
                this.setSanctionConditionData(res);
            }
            else if(this.relatedObject == 'Query__c'){
                this.setQueryData(res);
            }
            else if(this.relatedObject == 'Deviation__c'){
                this.setDeviationData(res);
            }
        })
        .catch(err=>{
            console.log('err=>'+JSON.stringify(err));
        })
    }

    setDeviationData(dataLocal){
        if(dataLocal){

            this.tableData = dataLocal.map(rec=> ({
                deviationName : rec.Name,
                deviationLevel : rec.Level__c,
                deviationType : rec.Deviation_Type__c,
                id : rec.Id
            }));
        }
    }

    setQueryData(dataLocal){
        if(dataLocal){
            this.tableData = dataLocal.map(rec=> ({
                queryName : rec.Name,
                remarks : rec.Remarks__c,
                type : rec.Type__c,
                subType : rec.Sub_Type__c,
                id : rec.Id
            }));
        }

    }


    setSanctionConditionData(dataLocal){
        //console.log('from here'+JSON.stringify(dataLocal))
        if(dataLocal){
            let dataTableValue = [];
            for(let data of dataLocal){
                dataTableValue.push({
                    conditionName : data.Name,
                    raisedBy : data.Raised_By__r.Name,
                    remarks : data.Remarks__c,
                    type : data.Sanction_Type__c,
                    id : data.Id,
                    isWaived : data.Is_Waived__c,
                    status : data.Status__c,
                    recordLink : '/'+data.Id
                })
            }
            this.tableData = dataTableValue;
            /*
            this.tableData = dataLocal.map(rec=> ({
                    conditionName : rec.Name,
                    raisedBy : rec.Raised_By__r.Name,
                    remarks : rec.Remarks__c,
                    type : rec.Sanction_Type__c,
                    id : rec.Id
            }));*/
        }
        console.log('complete data here'+JSON.stringify(this.tableData))
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }

}