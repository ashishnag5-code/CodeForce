import { LightningElement, api } from 'lwc';
import checkIfAlreadyUploaded from '@salesforce/apex/CPVWaiverDocumentsController.checkIfAlreadyUploaded'
import { getSpinnerImage } from 'c/customSpinner';

export default class MobileBillVerification extends LightningElement {
    
    isUploadFile=false;
    loadSpinner=false
    received=false
    hideButtons=false
    label=''
    documentType='Mobile Bill'
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
                this.label = 'Mobile Bill Receipt Uploaded with an Amount of '
                this.hideButtons = true
                this.isUploadFile = false
            }else{
                //this.isUploadFile = true
                this.hideButtons = false
            }
        }).catch((error=>{

        }))
    }

    handleUploadFile(event){
        checkIfAlreadyUploaded({recordId: this.applicantId, documentType: this.documentType}).then((data)=>{
            if(data && data.Status__c==='Received'){
                this.received=true
                this.amount=data.Amount__c
                this.label = 'Mobile Bill Receipt Uploaded with an Amount of '
                this.hideButtons = true
                this.isUploadFile = false
            }else{
                if(this.isEditRestricted){//4733
                    this.showToast('Access Restricted','You cannot Upload Document due to Insufficient Access','error')
                    return
                }
                this.isUploadFile = true
                this.hideButtons = true
                this.received=false
            }
        })    
        //this.isUploadFile = true
    }
    
    handleFetchApi(event){
        
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
            this.label = 'Mobile Bill Uploaded with an Amount of '
        }
    }
}