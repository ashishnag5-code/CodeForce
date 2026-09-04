import { LightningElement, track, api, wire } from 'lwc';
import getAssignmentRelatedRecords from '@salesforce/apex/AUSF_AssignmentRelatedRecordsCntlr.getAssignmentRelatedRecords';
import sendBackSanctionData from '@salesforce/apex/AUSF_AssignmentRelatedRecordsCntlr.sendBackSanctionData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class Ausf_SentBackROSanctions extends LightningElement {
    @track isSanctionRelatedList=false;
    @api relatedObject = 'Sanction_Condition__c';
    @api recordId='';
    @track tableData=[];
    @track columns = [];
    @track selectedSendBackData = [];

    connectedCallback(){
        this.setColumns();
        
    }

    sendBackToCredit(evt){
        if(!this.selectedSendBackData || !this.selectedSendBackData.length || this.selectedSendBackData==[]){
            this.showNotification('Error','Please select a record to proceed','error');
            return;
        }
        let sanctionConditionId = [];
        this.selectedSendBackData.forEach(rec=>{
            sanctionConditionId.push(rec.id)
        })
        this.sendBackSanctionData(sanctionConditionId, this.recordId, false);
       



    }

    sendBackSanctionData(sanctionConditionIds, applicationId, isComplianceSentBack){
        sendBackSanctionData({
            sanctionIds : sanctionConditionIds,
            loanId : applicationId,
            isComplianceSentBack : isComplianceSentBack
        })
        .then(res=>{
            this.showNotification('Success','Success in sending back the record','success');
            console.log('test '+res);
        })
        .catch(err=>{
            this.showNotification('Error','Error in sending back the record','error');
            console.log('err '+err);
        })
    }

    onRowSelection(evt){
        const selectedRows = evt.detail.selectedRows;
        console.log('test '+selectedRows)
        this.selectedSendBackData = selectedRows;

    }

    setColumns(){
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

        }
        
        ]
        this.getRelatedRecords();

    }

    getRelatedRecords(){
        getAssignmentRelatedRecords({
            loanId : this.recordId,
            objectName : this.relatedObject
        })
        .then(res=>{
            console.log('res=>'+JSON.stringify(res));
            if(this.relatedObject == 'Sanction_Condition__c'){
                this.setSanctionConditionData(res);
            }
            
        })
        .catch(err=>{
            console.log('err=>'+JSON.stringify(err));
        })
    }

    setSanctionConditionData(dataLocal){
        //console.log('from here'+JSON.stringify(dataLocal))
        this.tableData = [];
        if(dataLocal){
            let dataTableValue = [];
            for(let data of dataLocal){
                if(data.Status__c == 'Not Compliant'){
                    dataTableValue.push({
                        conditionName : data.Name,
                        raisedBy : data.Raised_By__r.Name,
                        remarks : data.Remarks__c,
                        type : data.Sanction_Type__c,
                        id : data.Id,
                        recordLink : '/'+data.Id
                    })
                }
            }
            this.tableData = JSON.parse(JSON.stringify(dataTableValue));
        }
        console.log('complete data here'+JSON.stringify(this.tableData))
    }

    showNotification(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: variant === 'error' ? 'sticky' : 'dismissible'
        });
        this.dispatchEvent(evt);
    }



}