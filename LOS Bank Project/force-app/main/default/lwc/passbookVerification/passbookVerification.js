import { api, LightningElement } from 'lwc';
import checkIfAlreadyUploaded from '@salesforce/apex/CPVWaiverDocumentsController.checkIfAlreadyUploaded'
import { getSpinnerImage } from 'c/customSpinner';

export default class PassbookVerification extends LightningElement {
    
    isUploadFile=false;
    loadSpinner=false
    received=false
    hideButtons=false
    label=''
    documentType='Passbook'
    amount
    spinnerImage;

    @api loanAppId
    @api applicantId
    @api headingValue;
    @api isEditRestricted

    async connectedCallback(){
        /**/
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.loanAppId);
        }
        checkIfAlreadyUploaded({recordId: this.applicantId, documentType: this.documentType}).then((data)=>{
            if(data && data.Status__c==='Received'){
                this.received=true
                this.amount=data.Amount__c
                this.label = 'Passbook Uploaded with an Amount of '
                this.hideButtons = true
            }else{
                //this.isUploadFile = true
                this.hideButtons = true
            }
        }).catch((error=>{

        }))
    }

    handleUploadFile(event){
        checkIfAlreadyUploaded({recordId: this.applicantId, documentType: this.documentType}).then((data)=>{
            if(data && data.Status__c==='Received'){
                this.received=true
                this.amount=data.Amount__c
                this.label = 'Passbook Uploaded with an Amount of '
                this.hideButtons = true
            }else{
                if(this.isEditRestricted){//4733
                    this.showToast('Access Restricted','You cannot Upload Document due to Insufficient Access','error')
                    return
                }
                this.isUploadFile = true
                this.hideButtons = true
            }
        })   
    }

    handleClose(event){
        this.hideButtons=false
        this.isUploadFile=false
        this.received=false
    }

    handleEvent(event){
        if(event.detail.isreceived){
            this.received=true
            this.amount = event.detail.amount
            this.label = 'Passbook Uploaded with an Amount of '
        }
    }
}