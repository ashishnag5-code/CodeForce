import { LightningElement,api, track } from 'lwc';
import karzaLPGBillCallOut from '@salesforce/apex/KarzaLPGBillController.karzaLPGBillCallOut'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkIfAlreadyUploaded from '@salesforce/apex/CPVWaiverDocumentsController.checkIfAlreadyUploaded'
import markVerified from '@salesforce/apex/CPVWaiverDocumentsController.markVerified'
import callValidateAddressMatch from '@salesforce/apex/CPVWaiverDocumentsController.callValidateAddressMatch'
import addressMatch from '@salesforce/apex/CPVWaiverDocumentsController.addressMatch'
import validateNameMatch from '@salesforce/apex/LOSKarzaNameMatchController.validateNameMatch'
import { getSpinnerImage } from 'c/customSpinner';
import getVerifiedRecords from '@salesforce/apex/CPVWaiverDocumentsController.getVerifiedRecords'

export default class GasBillVerification extends LightningElement {
    
    @api loanAppId;
    @api headingValue
    @api applicantId
    @api
    spinnerImage;
    isLoading;
    @track editDetails=false
    isVerified=false
    cpvDocuments=true
    @track matchScore
    fetchDetailsReceived=false
    @track gasBillResponse={}
    received=false
    isLoading=false;
    isUploadFile=false;
    isFetchApi=false;
    hideButtons=false
    lpgId='';
    amount;
    documentType='Gas bill'
    @track label;
    fetchFailed=false;
    @api isEditRestricted

    async connectedCallback(){
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.loanAppId);
        }

        checkIfAlreadyUploaded({recordId: this.applicantId, documentType: this.documentType}).then((data)=>{
            if(data && data.Document_Verification_Status__c==='Verified'){
                this.received=false
                this.hideButtons = true
                this.isFetchApi=true
                this.isVerified=true
                this.lpgId=data.Document_Number__c
                let billResponse = data.Api_Response__c?JSON.parse(data.Api_Response__c):{}
                this.gasBillResponse = billResponse
                this.matchScore = data.Address_Match_Score__c?data.Address_Match_Score__c:-101
                this.setLabel(data)
	    } else if (data && data.Status__c==='Received') {
                this.received=true
                this.fetchDetailsReceived=false
                this.amount=data.Amount__c
                this.label = 'Gas Bill Uploaded with an Amount of '
                this.hideButtons = false
                this.fetchFailed=false
                this.isFetchApi=false
            }else{
                this.received=false
                this.hideButtons = false
            }
        })
    }

    handleUploadFile(event){
        this.isLoading=true
        this.label=''
        this.editDetails=false
        checkIfAlreadyUploaded({recordId: this.applicantId, documentType: this.documentType}).then((data)=>{
            this.isLoading=false
            if(data && data.Status__c==='Received'){
                this.received=true
                this.fetchDetailsReceived=false
                this.amount=data.Amount__c
                this.label = 'Gas Bill Uploaded with an Amount of '
                this.hideButtons = false
                this.fetchFailed=false
                this.isFetchApi=false
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
    }

    async handleFetchApi(){
        this.isLoading=true
        this.amount=''
        this.isUploadFile=false
        this.isFetchApi=true
        this.hideButtons = true
        this.received=false
        checkIfAlreadyUploaded({recordId: this.applicantId, documentType: this.documentType}).then((data)=>{
            this.isLoading=false
            if(data && data.Document_Verification_Status__c==='Verified'){
                this.received=false
                this.isVerified=true
                this.lpgId=data.Document_Number__c
                this.setLabel(data)
            }else{
                if(this.isEditRestricted){//4733
                    this.showToast('Access Restricted','You cannot Fetch Document Details due to Insufficient Access','error')
                    this.received=false
                    this.hideButtons=false
                    this.isFetchApi=false
                    this.editDetails=false
                    return
                }
                this.received=false
                this.hideButtons=true
                this.isFetchApi=true
                this.editDetails=true
            }
        }).catch((error=>{
            this.isLoading=false
        }))   
    }

    async displayMoreDetails(event){
        let list = ['Gas bill']
        let data = await getVerifiedRecords({recordId: this.applicantId, documentType: list})
        let billResponse = data[0].Api_Response__c?JSON.parse(data[0].Api_Response__c):{}
        this.gasBillResponse = billResponse
        this.matchScore = data[0].Address_Match_Score__c?data[0].Address_Match_Score__c:-101
        this.received = true
        this.cpvDocuments=false
        this.fetchDetailsReceived=true
    }

    handleClose(event){
        this.hideButtons=false
        this.isFetchApi=false
        this.isUploadFile=false
        this.received=false
        this.editDetails=false
    }

    handleEditClose(event){
        if(this.isVerified){
            this.hideButtons=true
            this.isFetchApi=true
        }else{
            this.hideButtons=false
            this.isFetchApi=false
        }
        
        this.isUploadFile=false
        this.received=false
        this.editDetails=false
    }

    handleonBack(){
        this.received=false
        this.hideButtons=true
        this.isFetchApi=true
        this.cpvDocuments=true
    }

    editLPGDetails(){
        if(this.isEditRestricted){//4733
            this.showToast('Access Restricted','You cannot Edit Document Details due to Insufficient Access','error','sticky')
            return
        }
        this.editDetails = true
        this.isFetchApi = false
    }

    handleChange(event){
        if(event.target.name === 'Document_Number__c'){
            this.lpgId = event.target.value;
            this.isVerified=false
        }
        this.handleValidations()
    }

    showToast(title, message, variant,mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    fetchDetails(){
        if(this.isEditRestricted){//4733
            this.showToast('Access Restricted','You cannot Fetch Document Details due to Insufficient Access','error','sticky')
            return
        }
        this.isLoading=true
        if(this.handleValidations()){
            this.label=''
            this.isLoading = true
            karzaLPGBillCallOut({lpgId: this.lpgId, recordId: this.applicantId, loanAppId: this.loanAppId}).then((dataResp)=>{
                if(dataResp.includes('API Error')){
                    this.isLoading = false
                    this.received=true
                    this.hideButtons=false
                    this.isFetchApi=false
                    this.fetchFailed=true
                    this.label=dataResp
                    this.showToast('Error',dataResp,'error','sticky')
                    return
                }
                let data = JSON.parse(dataResp)
                this.received=true
                this.isLoading=false
                if(data.result && Object.keys(data.result).length>0){
                    this.fetchDetailsReceived=true
                    this.gasBillResponse=data.result
                    this.showToast('Success','Gas Bill Details Fetched Successfully','success','dismissible')
                    //this.label='Address Match in progress....'
                    addressMatch({address: data.result.ConsumerAddress, recordId: this.applicantId, loanAppId: this.loanAppId, type:this.documentType}).then((value)=>{
                        console.log(JSON.stringify(value))
                        callValidateAddressMatch({newAddressToString: value, recordId:this.applicantId, type:this.documentType}).then((data=>{
                            if(data){
                                this.matchScore=parseInt(data)
                            }
                            else{
                                this.matchScore=-101
                            }
                            this.fetchFailed=false
                            this.hideButtons=true
                        }))
                    })
                    validateNameMatch({strName: data.result.ConsumerName, strType: this.documentType, strApplicantId: this.applicantId, strRecordId:''}).then((value)=>{
                        this.showToast('Success','Name Match Completed','success','dismissible')
                    }).catch((error=>{
                        this.showToast('Error','Something went Wrong','error','sticky')
                    }))
                }else{
                    this.fetchDetailsReceived=false
                    this.showToast('Error','No Details Found for the Provided Document Number','error','sticky')
                    this.label='No Details Found for the Provided Document Number'
                    this.fetchFailed=true
                    this.hideButtons=false
                    this.isLoading = false
                }
                this.isLoading = false
                this.isFetchApi=false
                console.log(data)
            }).catch((error)=>{
                this.isLoading = false
                this.received=true
                this.hideButtons=false
                this.isFetchApi=false
                this.fetchFailed=true
                this.label='Something Went Wrong while Processing the Request'
                this.showToast('Error',error.message.body,'error','sticky')
                console.log(JSON.stringify(error))
            })
        }else{
            this.showToast('Error','Please Fill the Mandatory Details','error','sticky')
        }
        
    }

    handleValidations() {
        var valid;
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {
            valid = true
        } else {
            valid = false;
        }
        return valid;
    }

    handleEvent(event){
        this.label=''
        if(event.detail.isreceived){
            this.received=true
            this.amount = event.detail.amount
            this.label = 'Gas Bill Uploaded with an Amount of '
            this.fetchFailed=false
            this.hideButtons=false
        }
    }

    handleBack(event){
        this.received=false
        this.hideButtons=true
        this.isFetchApi=true
    }

    handleDocumentVerified(event){
        if(this.isEditRestricted){//4733
            this.showToast('Access Restricted','You cannot Verify Document Details due to Insufficient Access','error','sticky')
            return
        }
        if(event.detail){
            markVerified({recordId: this.applicantId, documentType: this.documentType, DocumentNumber: this.lpgId, response: JSON.stringify(this.gasBillResponse), addressMatchScore: this.matchScore }).then((data)=>{
                this.showToast('Success','Document Verification Successful','success','dismissible')
                this.received=false
                this.hideButtons=true
                this.isFetchApi=true
                this.isVerified=true
                this.editDetails=false
                this.setLabel(data)
            }).catch((error)=>{
                this.showToast('Error','Document Verification Failed','error','sticky')
            })
        }
    }

    setLabel(data){
        if(data.Address_Match_Score__c){
            this.label = 'Gas Bill is Verified '+data.Document_Number__c+' and Address Match Score '+data.Address_Match_Score__c+'%'
        }else{
            this.label = 'Gas Bill is Verified '+data.Document_Number__c+' and Address Match Score : NA'
        }
    }
}