import { api, LightningElement, track } from 'lwc';
import karzaPNGBillCallOut from '@salesforce/apex/KarzaPNGBillController.karzaPNGBillCallOut'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkIfAlreadyUploaded from '@salesforce/apex/CPVWaiverDocumentsController.checkIfAlreadyUploaded'
import markVerified from '@salesforce/apex/CPVWaiverDocumentsController.markVerified'
import callValidateAddressMatch from '@salesforce/apex/CPVWaiverDocumentsController.callValidateAddressMatch'
import addressMatch from '@salesforce/apex/CPVWaiverDocumentsController.addressMatch'
import getServiceProviderInformation from '@salesforce/apex/CPVWaiverDocumentsController.getServiceProviderInformation'
import validateNameMatch from '@salesforce/apex/LOSKarzaNameMatchController.validateNameMatch'
import { getSpinnerImage } from 'c/customSpinner';
import getVerifiedRecords from '@salesforce/apex/CPVWaiverDocumentsController.getVerifiedRecords'
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';

export default class PngBillVerification extends LightningElement {
    
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
    defaultMatchName='Address Match'
    fetchDetailsReceived=false
    @track pngResponse={}
    received=false
    isLoading=false;
    isUploadFile=false;
    isFetchApi=false;
    hideButtons=false
    consumerId='';
    amount;
    documentType='PNG bill'
    label;
    fetchFailed=false;
    serviceProviders=[];
    selectedServiceProvider='';
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
                this.consumerId=data.Document_Number__c
                let billResponse = data.Api_Response__c?JSON.parse(data.Api_Response__c):{}
                this.pngResponse = billResponse
                this.matchScore = data.Address_Match_Score__c?data.Address_Match_Score__c:-101
                this.setLabel(this.consumerId, data.Address_Match_Score__c)
                this.setInitialData()
            }else if(data && data.Status__c==='Received'){
	    	    this.received=true
                this.fetchDetailsReceived=false
                this.amount=data.Amount__c
                this.label = 'PNG Bill Uploaded with an Amount of '
                this.hideButtons = false
                this.fetchFailed=false
                this.isFetchApi=false
	        }else{
                this.hideButtons=false
                this.received=false
            }
        })
        
        
    }

    setLabel(docNumber, addressMatchScore){
        if(docNumber && addressMatchScore){
            this.label = 'PNG Bill is Verified for Document Number '+docNumber+' and Address Match Score '+addressMatchScore+'%'
        }else{
            this.label = 'PNG Bill is Verified for Document Number '+docNumber+' and Address Match Score : NA'
        }
    }

    /*checkIfDataAlreadyVerified(){
        checkIfAlreadyUploaded({recordId: this.applicantId, documentType: this.documentType}).then((data)=>{
            if(data && data.Document_Verification_Status__c==='Verified'){
                this.received=false
                this.hideButtons = true
                this.isFetchApi=true
                this.isVerified=true
                if(data.Document_Number__c){
                    this.consumerId=data.Document_Number__c
                }
                this.setLabel(this.consumerId, data.Address_Match_Score__c)
            }else{
                this.hideButtons=false
                this.received=false
            }
        })
    }*/

    handleUploadFile(event){
        this.isLoading=true
        this.editDetails=false
        this.label=''
        checkIfAlreadyUploaded({recordId: this.applicantId, documentType: this.documentType}).then((data)=>{
            this.isLoading=false
            if(data && data.Status__c==='Received'){
                this.received=true
                this.fetchDetailsReceived=false
                this.amount=data.Amount__c
                this.label = 'PNG Bill Uploaded with an Amount of '
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
        }).catch((error=>{
            this.isLoading=false
        }))
    }

    async handleFetchApi(){
        this.isLoading=true
        this.amount=''
        this.isFetchApi=true
        this.hideButtons = true
        this.isUploadFile=false
        this.received=false
        this.setInitialData()
        checkIfAlreadyUploaded({recordId: this.applicantId, documentType: this.documentType}).then((data)=>{
            this.isLoading=false
            if(data && data.Document_Verification_Status__c==='Verified'){
                this.received=false
                this.hideButtons = true
                this.isFetchApi=true
                this.isVerified=true
                this.consumerId=data.Document_Number__c
                this.setLabel(this.consumerId, data.Address_Match_Score__c)
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

    async setInitialData(){
        const serviceProviderData = await getServiceProviderInformation({providerType:'PNG_Service_Providers'})
        if(serviceProviderData && serviceProviderData.length>0){
            var options=[];
            serviceProviderData.forEach(element => {
                options.push({label:element.Service_Provider_Name__c, value:element.Service_Provider_Code__c})
            });
            this.serviceProviders=options
        }
    }

    handleClose(event){
        this.hideButtons=false
        this.isFetchApi=false
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

    editPNGDetails(){
        if(this.isEditRestricted){//4733
            this.showToast('Access Restricted','You cannot Edit Document Details due to Insufficient Access','error')
            return
        }
        this.editDetails = true
        this.isFetchApi = false
        /*restricAccess({
            compName: 'pngBillVerification' ,loanId: this.recordId
            })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save PNG Bill',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }else{
                    this.editDetails = true
                    this.isFetchApi = false
                }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
            })*/
    }


    async displayMoreDetails(event){
        let list = ['Png bill']
        let data = await getVerifiedRecords({recordId: this.applicantId, documentType: list})
        let billResponse = data[0].Api_Response__c?JSON.parse(data[0].Api_Response__c):{}
        this.electricityBillResponse = billResponse
        this.matchScore = data[0].Address_Match_Score__c?data[0].Address_Match_Score__c:-101
        this.received = true
        this.cpvDocuments=false
        this.fetchDetailsReceived=true
    }

    


    handleChange(event){
        var name = event.target.name
        var value = event.target.value
        if(name === 'Document_Number__c'){
            this.consumerId = value;
            this.isVerified=false
        }
        if(name === 'Service_Provider'){
            this.selectedServiceProvider=value
            this.consumerId=''
            this.template.querySelector('[data-id="Document_Number__c"]').disabled = false
        }
    }

    showToast(title, message, variant, mode) {
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
            this.showToast('Access Restricted','You cannot Fetch Document Details due to Insufficient Access','error')
            return
        }
        this.isLoading=true
        if(this.handleValidations()){
            this.label=''
            this.isLoading = true
            karzaPNGBillCallOut({consumerId: this.consumerId, recordId: this.applicantId, loanAppId: this.loanAppId, serviceProvider: this.selectedServiceProvider}).then((dataResp)=>{
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
                this.received=true
                this.isLoading=false
                let data = JSON.parse(dataResp)
                if(data.result && Object.keys(data.result).length>0){
                    this.fetchDetailsReceived=true
                    this.pngResponse=data.result
                    this.showToast('Success','PNG Bill Details Fetched Successfully','success')
                    //this.label='Address Match in progress....'
                    addressMatch({address: data.result.Customer_Address, recordId: this.applicantId, loanAppId: this.loanAppId, type:this.documentType}).then((value)=>{
                        console.log(JSON.stringify(value))
                        callValidateAddressMatch({newAddressToString: value, recordId:this.applicantId, type:this.documentType}).then((data1=>{
                            if(data1){
                                this.matchScore=parseInt(data1)
                            }
                            else{
                                this.matchScore=-101
                            }
                            this.fetchFailed=false
                            this.hideButtons=true
                        })).catch(error=>{
                            this.matchScore= -101
                        })
                    })
                    validateNameMatch({strName: data.result.ConsumerName, strType: this.documentType, strApplicantId: this.applicantId, strRecordId:''}).then((value)=>{
                        this.showToast('Success','Name Match Completed','success')
                    }).catch((error=>{
                        this.showToast('Error','Something went Wrong','error', 'sticky')
                    }))
                }else{
                    this.fetchDetailsReceived=false
                    this.showToast('Error','No Details Found for the Provided Document Number','error', 'sticky')
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
                this.showToast('Error','Something Went Wrong while Processing the Request','error', 'sticky')
                console.log(JSON.stringify(error))
            })
        }else{
            this.showToast('Error','Please Fill the Mandatory Details','error', 'sticky')
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
        if(event.detail.isreceived){
            this.received=true
            this.amount = event.detail.amount
            this.label = 'PNG Bill Uploaded with an Amount of '
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
            this.showToast('Access Restricted','You cannot Verify Document Details due to Insufficient Access','error')
            return
        }
        if(event.detail){
            markVerified({recordId: this.applicantId, documentType: this.documentType, DocumentNumber: this.consumerId, response: JSON.stringify(this.pngResponse), addressMatchScore: this.matchScore}).then((data)=>{
                this.showToast('Success','Document Verification Successful','success')
                this.received=false
                this.hideButtons=true
                this.isFetchApi=true
                this.isVerified=true
                this.editDetails=false
                this.consumerId=data.Document_Number__c
                this.setLabel(data.Document_Number__c, data.Address_Match_Score__c)
            }).catch((error)=>{
                this.showToast('Error','Document Verification Failed','error', 'sticky')
            })
        }
    }
}