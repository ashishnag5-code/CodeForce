import { LightningElement, api, track } from 'lwc';
import karzaElectricityBillCallOut from '@salesforce/apex/KarzaElectricityBillController.karzaElectricityBillCallOut'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkIfAlreadyUploaded from '@salesforce/apex/CPVWaiverDocumentsController.checkIfAlreadyUploaded'
import markVerified from '@salesforce/apex/CPVWaiverDocumentsController.markVerified'
import callValidateAddressMatch from '@salesforce/apex/CPVWaiverDocumentsController.callValidateAddressMatch'
import addressMatch from '@salesforce/apex/CPVWaiverDocumentsController.addressMatch'
import getServiceProviderInformation from '@salesforce/apex/CPVWaiverDocumentsController.getServiceProviderInformation'
import validateNameMatch from '@salesforce/apex/LOSKarzaNameMatchController.validateNameMatch'
import { getSpinnerImage } from 'c/customSpinner';
import getVerifiedRecords from '@salesforce/apex/CPVWaiverDocumentsController.getVerifiedRecords'

export default class ElectricityBillVerification extends LightningElement {

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
    @track electricityBillResponse={}
    received=false
    isLoading=false;
    isUploadFile=false;
    isFetchApi=false;
    hideButtons=false
    consumerId='';
    amount;
    documentType = 'Electricity bill'
    serviceProvider=''
    states=[];
    selectedState='';
    serviceProviders=[];
    selectedServiceProvider='';
    stateVsServiceProviders=new Map();
    serviceProviderVsCode=new Map();
    verificationStatus=''
    @track label;
    fetchFailed=false;
    @api isEditRestricted
    

    async connectedCallback(){
        /**/
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
                this.electricityBillResponse = billResponse
                this.matchScore = data.Address_Match_Score__c?data.Address_Match_Score__c:-101
                this.setLabel(data)
                this.setInitialData()
            } else if (data && data.Status__c==='Received') {
                this.received=true
                this.fetchDetailsReceived=false
                this.amount=data.Amount__c
                this.label = 'Electricity Bill Uploaded with an Amount of '
                this.hideButtons = false
                this.isFetchApi=false
                this.fetchFailed=false
            } else{
                this.hideButtons=false
                this.received=false
            }
        }).catch((error=>{

        }))
    }
    
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
                this.label = 'Electricity Bill Uploaded with an Amount of '
                this.hideButtons = false
                this.isFetchApi=false
                this.fetchFailed=false
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
        this.isUploadFile=false
        this.hideButtons = true
        this.received=false
        this.setInitialData()
        checkIfAlreadyUploaded({recordId: this.applicantId, documentType: this.documentType}).then((data)=>{
            this.isLoading=false
            if(data && data.Document_Verification_Status__c==='Verified'){
                this.received=false
                this.isVerified=true
                this.consumerId=data.Document_Number__c
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

    async setInitialData()
    {
        const serviceProviderData = await getServiceProviderInformation({providerType:'Electricity_Bill_Service_Providers'})
        if(serviceProviderData && serviceProviderData.length>0){
            var stateOptions=[]
            this.stateVsServiceProviders=new Map();
            this.states=[]
            serviceProviderData.forEach(element => {
                if(this.stateVsServiceProviders.has(element.State__c)){
                    this.stateVsServiceProviders.get(element.State__c).push({label:element.Service_Provider_Name__c, value:element.Service_Provider_Code__c})
                }
                else{
                    stateOptions.push({label:element.State__c, value:element.State__c})
                    this.stateVsServiceProviders.set(element.State__c, new Array())
                    this.stateVsServiceProviders.get(element.State__c).push({label:element.Service_Provider_Name__c, value:element.Service_Provider_Code__c})
                }
                
            });
            this.states=stateOptions
        }
    }

    async displayMoreDetails(event){
        let list = ['Electricity bill']
        let data = await getVerifiedRecords({recordId: this.applicantId, documentType: list})
        let billResponse = data[0].Api_Response__c?JSON.parse(data[0].Api_Response__c):{}
        this.electricityBillResponse = billResponse
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

    editElectricityDetails(){
        if(this.isEditRestricted){//4733
            this.showToast('Access Restricted','You cannot Edit Document Details due to Insufficient Access','error')
            return
        }
        this.editDetails = true
        this.isFetchApi = false
    }

    handleChange(event){
        var name = event.target.name
        var value = event.target.value
        if(name === 'Document_Number__c'){
            this.consumerId = value;
            this.isVerified=false
        }
        if(name === 'State'){
            this.selectedState=value
            this.selectedServiceProvider = ''
            this.consumerId=''
            this.serviceProviders = this.stateVsServiceProviders.get(value)
            this.template.querySelector('[data-id="Service_Provider"]').disabled = false
            this.template.querySelector('[data-id="Document_Number__c"]').disabled = true
        }
        if(name === 'Service_Provider'){
            this.selectedServiceProvider=value
            this.consumerId=''
            this.template.querySelector('[data-id="Document_Number__c"]').disabled = false
        }
        //this.handleValidations()
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    /*handleLookupSelect(event){
        this.serviceProvider = event.detail.name
    }*/

    fetchDetails(){
        if(this.isEditRestricted){//4733
            this.showToast('Access Restricted','You cannot Fetch Document Details due to Insufficient Access','error')
            return
        }
        this.isLoading=true
        if(this.handleValidations()){
            this.label=''
            this.isLoading = true
            karzaElectricityBillCallOut({consumerId: this.consumerId, recordId: this.applicantId, loanAppId: this.loanAppId, serviceProvider: this.selectedServiceProvider}).then((dataResp)=>{
                if(dataResp.includes('API Error')){
                    this.isLoading = false
                    this.received=true
                    this.hideButtons=false
                    this.isFetchApi=false
                    this.fetchFailed=true
                    this.label=dataResp
                    this.fetchDetailsReceived=false
                    this.showToast('Error',dataResp,'error','sticky')
                    return
                }
                this.received=true
                this.isLoading=false
                let data = JSON.parse(dataResp)
                if(data.result && Object.keys(data.result).length>0){
                    this.electricityBillResponse=data.result;
                    this.fetchDetailsReceived=true
                    console.log('data '+data)
                    this.showToast('Success','Electricity Details Fetched Successfully','success')
                    //this.label='Address Match in progress....'
                    addressMatch({address: data.result.address, recordId: this.applicantId, loanAppId:this.loanAppId, type:this.documentType}).then((value)=>{
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
                    validateNameMatch({strName: data.result.consumer_name, strType: this.documentType, strApplicantId: this.applicantId, strRecordId:''}).then((value)=>{
                        this.showToast('Success','Name Match Completed','success')
                    }).catch((error=>{
                        this.showToast('Error','Something went Wrong','error')
                    }))
                }
                else{
                    this.fetchDetailsReceived=false
                    this.showToast('Error','No Details Found for the Provided Document Number','error')
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
                this.showToast('Error','Something Went Wrong while Processing the Request','error')
                console.log(JSON.stringify(error))
            })
        }else{
            this.showToast('Error','Please Fill the Mandatory Details','error')
        }
        
    }

    handleValidations() {
        var valid;
        const allValid = [
            ...this.template.querySelectorAll('.validate'),
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
            this.label = 'Electricity Bill Uploaded with an Amount of '
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
            markVerified({recordId: this.applicantId, documentType: this.documentType, DocumentNumber: this.consumerId, response: JSON.stringify(this.electricityBillResponse), addressMatchScore: this.matchScore}).then((data)=>{
                this.showToast('Success','Document Verification Successful','success')
                this.received=false
                this.hideButtons=true
                this.isFetchApi=true
                this.isVerified=true
                this.editDetails=false
                this.setLabel(data)
            }).catch((error)=>{
                this.showToast('Error','Document Verification Failed','error')
            })
        }
    }

    setLabel(data){
        if(data.Address_Match_Score__c){
            this.label = 'Electricity Bill is Verified '+data.Document_Number__c+' and Address Match Score '+data.Address_Match_Score__c+'%'
        }else{
            this.label = 'Electricity Bill is Verified '+data.Document_Number__c+' and Address Match Score : NA'
        }
    }

}