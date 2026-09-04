import { api, LightningElement, track, wire } from 'lwc';
import callCIFCreationCallout from '@salesforce/apex/CIFCreationController.callCIFCreationCallout'
import callCIFModifyCallout from '@salesforce/apex/CIFCreationController.callCIFModifyCallout'
import ckycInsertApiHandler from '@salesforce/apex/CkycInsertApi.ckycInsertApiHandler'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { getSpinnerImage } from 'c/customSpinner';
// Joshna - START OF CBS API Change Tracker updates
import isComplete from '@salesforce/apex/CBSBSRPSLAPIController.isComplete';
import submitCIFDetails from '@salesforce/apex/CBSBSRPSLAPIController.submitCIFDetails';
// Joshna - END OF CBS API Change Tracker updates
// SFAU-5602 - Mohit M. - Save CIF Creation and Modification Date
import updateRecordServer from '@salesforce/apex/CIFCreationController.updateRecordServer';
import {
    APPLICATION_SCOPE,
    createMessageContext,
    MessageContext,
    publish,
    releaseMessageContext,
    subscribe,
    unsubscribe,
} from 'lightning/messageService';
import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c';

export default class CifCardView extends LightningElement {

    @wire(MessageContext)
    messageContext;
    @track ckycInsertDisabled=true
    @api applicantRecord;
    @api insCheck
    //@api enableExposureButton
    applicantName='';
    customerType='';
    kycApprovalStatus='';
    cifButtonDisabled=true
    buttonLabel=''
    showCarousel=false
    @api userType
    @track customerList=[]
    @track customer={}
    @track counter=0
    @api disableExposureButton
    @api spinnerImage;
    @track isLoading=false
    @track errorInCIFCreation = false
    @track errorInCIFModification = false

    // Joshna - START OF CBS API Change Tracker updates
    disableCBSBSRPSL = false;
    hasCIF = false;
    applicantId;
    disableCKYCInsert=true
    // Joshna - END OF CBS API Change Tracker updates

    connectedCallback(){
        this.setInitialData()
    }

    get ifExposureFetch(){
        if(this.customerType == 'NTB' && this.applicantRecord.CIF_No__c){
            return true;
        }
        if(this.customerType == 'ETB' && this.applicantRecord.CIF_Modification_Successful__c){
            return true;
        }
        return false;
    }

    async setInitialData(){
        if (this.spinnerImage == undefined) {
            this.spinnerImage = await getSpinnerImage(this.applicantRecord.Loan__c);
        }
        this.applicantRecord = JSON.parse(JSON.stringify(this.applicantRecord))
        this.kycApprovalStatus = this.applicantRecord.Loan__r.OPS_KYC_Action__c?this.applicantRecord.Loan__r.OPS_KYC_Action__c:'';
        this.applicantName = (this.applicantRecord.First_Name__c?this.applicantRecord.First_Name__c+' ':'')+(this.applicantRecord.Middle_Name__c?this.applicantRecord.Middle_Name__c+' ':'')+(this.applicantRecord.Last_Name__c?this.applicantRecord.Last_Name__c:'')

        // Joshna - START OF CBS API Change Tracker updates
        this.applicantId = this.applicantRecord.Id;
        // Joshna - END OF CBS API Change Tracker updates

        /*if(this.applicantRecord.Middle_Name__c){
            this.applicantName = (this.applicantRecord.First_Name__c?this.applicantRecord.First_Name__c:'')+' '+this.applicantRecord.Middle_Name__c+' '+this.applicantRecord.Last_Name__c;
        }else{
            this.applicantName = this.applicantRecord.First_Name__c+' '+this.applicantRecord.Last_Name__c;
        }*/
        this.customerType = this.applicantRecord.Existing_Customer__c ==='Yes'?'ETB':'NTB';
        //if(this.customerType == 'ETB' && this.applicantRecord.CIF_No__c){
        if(this.customerType == 'ETB'){
            this.buttonLabel = 'Update CIF'
        }else{
            this.buttonLabel = 'Create CIF'
        }
        if(this.userType!='User'){
            this.cifButtonDisabled=true
            this.disableExposureButton = true
        }else{
            //SFAU-4473
            if(this.insCheck == 'Failed'){
                this.disableButtons()
                return;
            }
            //SFAU-4473
            if(this.customerType == 'NTB' && this.applicantRecord.CIF_No__c){
                this.cifButtonDisabled=true
                this.ckycInsertDisabled=false
            }
            if(this.customerType == 'NTB' && !this.applicantRecord.CIF_No__c){
                this.cifButtonDisabled=false
            }
            
            if(this.customerType == 'ETB' && (this.applicantRecord.KYC_Type__c!='CBS' || !this.applicantRecord.CBS_Signature_Available__c || !this.applicantRecord.CBS_Image_Available__c) && !this.applicantRecord.CIF_Modification_Successful__c){
                this.cifButtonDisabled=false
            }
            if(this.customerType == 'ETB' && (this.applicantRecord.KYC_Type__c!='CBS' || !this.applicantRecord.CBS_Signature_Available__c || !this.applicantRecord.CBS_Image_Available__c) && this.applicantRecord.CIF_Modification_Successful__c){
                this.ckycInsertDisabled=false
            }
            this.disableCKYCInsert = this.applicantRecord.Loan__r.LAN__c?false:true
            
        }
        if(this.applicantRecord.Loan__r.OPS_KYC_Action__c!='Approve' || this.applicantRecord.Loan__r.Stage__c!='Ops Maker'){
            this.disableButtons()
        }
        
        this.isLoading=false
        // Joshna - START OF CBS API Change Tracker updates
        if (this.applicantRecord.CIF_No__c) {
            this.hasCIF = true;
        }
        // Joshna - END OF CBS API Change Tracker updates
    }

    disableButtons(){
        this.cifButtonDisabled=true
        this.disableExposureButton=true
        if(this.applicantRecord.Loan__r.LAN__c){
            this.disableCKYCInsert=false
        }else{
            this.disableCKYCInsert=true
        }
        //this.ckycInsertDisabled=true
    }

    handleExposureEvent(event){
        this.disableExposureButton = true
        this.dispatchEvent(new CustomEvent('exposurefetched',{
            detail:{
                applicantRecordId : event.detail.applicantRecordId
            }
        }));

    }

    async handleCreateCIF(){
        this.cifButtonDisabled=true
        if(this.customerType === 'NTB'){
            this.callCIFCreateAPI()
        }else if(this.customerType === 'ETB'){
            if(this.applicantRecord.KYC_Type__c!='CBS' && (!this.applicantRecord.CBS_Signature_Available__c || !this.applicantRecord.CBS_Image_Available__c)){
                Promise.all([this.callCIFCreateAPI(), this.callCIFModifyAPI()]).then((values)=>{
                    console.log('Success '+values)
                })
            }else if(!this.applicantRecord.CBS_Signature_Available__c || !this.applicantRecord.CBS_Image_Available__c){
                this.callCIFCreateAPI()
            }else if(this.applicantRecord.KYC_Type__c!='CBS'){
                this.callCIFModifyAPI()
            }
        }
    }
    
    handleSelectCIF(event){
        this.applicantRecord = JSON.parse(JSON.stringify(this.applicantRecord))
        this.applicantRecord.CIF_No__c = event.detail
        //this.updateCIFNo(this.applicantRecord.CIF_No__c);
        this.updateRecordCIF(this.applicantRecord.CIF_No__c,false);
    }

    updateCIFNo(cifNo){
        this.isLoading=true
        const fields = {Id:this.applicantRecord.Id, CIF_No__c: cifNo};
        const recordInput = { fields };
        updateRecord(recordInput).then(() => {
            this.isLoading=false
            this.ckycInsertDisabled = false
            //this.showToast('Success','CIF Created Successfully','success')
            const event = new ShowToastEvent({
                title: 'Success',
                message: 'CIF Created Successfully',
                variant: 'success',
            });
            this.dispatchEvent(event);
            this.dispatchEvent(new CustomEvent('cifcreated',{
                detail:{
                    applicantRecordId: this.applicantRecord.Id
                }
            }
            ));
        })
        .catch(error => {
            this.isLoading=false
            this.cifButtonDisabled=false
            this.errorInCIFCreation=true
            this.errorInCIFModification=true
            this.showToast('Error',error.body.output.errors[0].errorCode,'error')
        });
    }

    callCIFCreateAPI(){
        this.isLoading=true
        //this.showToast('Info','CIF Creation Initiated','warning')
        callCIFCreationCallout({recordId: this.applicantRecord.Id}).then((data=>{ 
            let callOutData =  JSON.parse(data)
            data = JSON.parse(callOutData.response)
            if(callOutData.statusCode && callOutData.statusCode!=200){
                this.cifButtonDisabled=false
                this.errorInCIFCreation=true
                this.isLoading = false
                this.retry = true
                this.showToast('Error', 'API Error: ' + callOutData.checklistNumber + ' Response: ' + callOutData.statusCode + '- ' + callOutData.status , 'error');
            }
            if(data && data.TransactionStatus && data.TransactionStatus.ResponseMessage === 'Success'){
                this.errorInCIFCreation=false
                if(!this.errorInCIFCreation || !this.errorInCIFModification){
                    this.cifButtonDisabled=true
                    this.ckycInsertDisabled=false
                    // Joshna - START OF CBS API Change Tracker updates
                    this.hasCIF = true;
                    // Joshna - END OF CBS API Change Tracker updates
                }else{
                    this.cifButtonDisabled=false
                }
                if(data.MatchFound){
                    this.showCarousel = true
                    this.customerList = data.MatchFound;
                }else if(data.ApplicantReturn && data.ApplicantReturn.length>0 && data.ApplicantReturn[0].CustomerId){
                    this.applicantRecord = JSON.parse(JSON.stringify(this.applicantRecord))
                    var cifNumber = data.ApplicantReturn[0].CustomerId.toString()
                    this.applicantRecord.CIF_No__c = cifNumber
                    //this.updateCIFNo(cifNumber)
                    this.updateRecordCIF(this.applicantRecord.CIF_No__c,false);
                }else{
                    this.cifButtonDisabled=false
                    this.showToast('Error','CIF Creation API - CIF Not Found','error')
                }
                this.isLoading = false
            }
            else if (data && data.TransactionStatus && data.TransactionStatus.ResponseMessage === 'Failure') {
                this.cifButtonDisabled=false
                this.errorInCIFCreation=true
                this.isLoading = false
                this.retry = true
                var errorMessages;
                data.TransactionStatus.ExtendedErrorDetails.messages.forEach(element => {
                    errorMessages = element.message + '; '
                });
                this.showToast('Warning', 'CIF Creation API - '+errorMessages, 'warning')

                if(JSON.stringify(data.TransactionStatus.ValidationErrors)=='[null]'){//SFAU-4927
                    data.TransactionStatus.ValidationErrors = undefined
                }
                if (data.TransactionStatus.ValidationErrors && data.TransactionStatus.ValidationErrors.length > 0) {
                    var validations;
                    data.TransactionStatus.ValidationErrors.forEach(element => {
                        validations = (element.AttributeName?element.AttributeName:'')+' '+element.ErrorMessage + '; '
                    });

                    this.showToast('Warning', 'CIF Creation API - '+validations, 'warning')
                }
            }
            else if(data && data.ServiceExecutionStatus && data.ServiceExecutionStatus === 'ERROR'){
                this.cifButtonDisabled=false
                this.errorInCIFCreation=true
                this.isLoading = false
                this.retry = true
                if(data.Errors.Error.Message.includes('<Message>')){
                    var str = data.Errors.Error.Message
                    this.showToast('Error', 'CIF Creation API - '+str.substring(
                        str.indexOf("<Message>") + 1, 
                        str.lastIndexOf("</Message>")
                    ), 'warning')
                }else{
                    this.showToast('Error', data.Errors.Error.Message, 'warning')
                }
            }else if(data && data.TransactionStatus && data.TransactionStatus.ResponseMessage === 'Incomplete'){
                this.cifButtonDisabled=false
                this.errorInCIFCreation=true
                //this.isLoading = false
                this.retry = true
                var errorMessages;
                if(data.ApplicantReturn && data.ApplicantReturn.length>0 && data.ApplicantReturn[0].CustomerId){
                    this.applicantRecord = JSON.parse(JSON.stringify(this.applicantRecord))
                    var cifNumber = data.ApplicantReturn[0].CustomerId.toString()
                    this.applicantRecord.CIF_No__c = cifNumber
                    //this.updateCIFNo(cifNumber)
                    this.updateRecordCIF(this.applicantRecord.CIF_No__c,false);
                }
                data.TransactionStatus.ExtendedErrorDetails.messages.forEach(element => {
                    errorMessages = element.message + '; '
                });
                this.showToast('Warning', 'CIF Creation API - '+errorMessages, 'warning')
                if(JSON.stringify(data.TransactionStatus.ValidationErrors)=='[null]'){//SFAU-4927
                    data.TransactionStatus.ValidationErrors = undefined
                }
                if (data.TransactionStatus.ValidationErrors && data.TransactionStatus.ValidationErrors.length > 0) {
                    var validations;
                    
                    data.TransactionStatus.ValidationErrors.forEach(element => {
                        validations = (element.AttributeName?element.AttributeName:'')+' '+element.ErrorMessage + '; '
                    });

                    this.showToast('Warning', 'CIF Creation API - '+validations, 'warning')
                }

                
            }else{
                this.isLoading = false
                this.errorInCIFCreation=true
                this.cifButtonDisabled=false
                this.retry = true
                //this.showToast('Error', callOutData, 'error')

            }
            /*else{
                this.cifButtonDisabled=false
                this.showToast('Error',data.TransactionStatus.ExtendedErrorDetails.messages.message,'error')
            } */
            this.isLoading=false
        })).catch(error=>{
            this.cifButtonDisabled=false
            this.errorInCIFCreation=true
            this.isLoading=false
            this.showToast('Error',error,'error')
        })
    }

    callCIFModifyAPI(){
        this.isLoading=true
        //this.showToast('Info','CIF Modification Initiated','warning')
        callCIFModifyCallout({recordId: this.applicantRecord.Id}).then((data=>{
            let callOutData =  JSON.parse(data)
            data = JSON.parse(callOutData.response)
            if(callOutData.statusCode && callOutData.statusCode!=200){
                this.cifButtonDisabled=false
                this.errorInCIFModification=true
                this.showToast('Error', 'API Error: ' + callOutData.checklistNumber + ' Response: ' + callOutData.statusCode + '- ' + callOutData.status , 'error');
                this.isLoading=false
            }
            if(data.TransactionStatus.ResponseMessage === 'Success'){
                this.errorInCIFModification=false
                if(!this.errorInCIFCreation || !this.errorInCIFModification){
                    this.cifButtonDisabled=true
                    this.ckycInsertDisabled = false
                } 
                else{
                    this.cifButtonDisabled=false
                }
                this.cifButtonDisabled=true
                this.updateRecordCIF ('',true);
                this.isLoading=false
                /*
                const fields = {Id:this.applicantRecord.Id, CIF_Modification_Successful__c: true};
                const recordInput = { fields };
                updateRecord(recordInput).then(() => {
                }).catch(error => {
                    this.cifButtonDisabled=false
                    this.errorInCIFModification=true
                    this.showToast('Error',error.body.output.errors[0].errorCode,'error')
                });
                //this.showToast('Success','CIF Modification Successful','success')
                const event = new ShowToastEvent({
                    title: 'Success',
                    message: 'CIF Modification Successful',
                    variant: 'success',
                });
                this.dispatchEvent(event);
                */
            }else{
                this.cifButtonDisabled=false
                this.errorInCIFModification=true
                this.showToast('Error','CIF Modification API - '+data.TransactionStatus.ExtendedErrorDetails.messages.message,'error')
                if(data.TransactionStatus.ValidationErrors!=null){
                    this.showToast('Warning','CIF Modification API - '+data.TransactionStatus.ValidationErrors.ErrorMessage,'warning')
                }
                this.isLoading=false
            }
        })).catch(error=>{
            this.errorInCIFModification=true
            this.cifButtonDisabled=false
            this.showToast('Error',error,'error')
            this.isLoading=false
        })
    }

    handleCKYCInsert(){
        this.isLoading = true;
        ckycInsertApiHandler({applcntId: this.applicantRecord.Id, loanApplId : this.applicantRecord.Loan__c}).then((data=>{
            if (data === 'Completed') {
                this.showToast('Success', 'Successfully created data', 'success', 'dismissable');
            } else {
                this.showToast('Error', data, 'error', 'dismissable');
                this.ckycInsertDisabled = false;
            }
	        this.isLoading = false;
        })).catch((error=>{
            this.isLoading = false;
            this.showToast('Error',error.body.message,'error')
        }))
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'sticky'
        });
        this.dispatchEvent(event);
    }

    // Joshna - START OF CBS API Change Tracker updates
    submitPSLBSR() {
        this.disableCBSBSRPSL = true;
        const fields = { Id: this.applicantRecord.Id, is_BSR_PSL_API_successful__c: true };
        const recordInput = { fields };
        updateRecord(recordInput).then(() => {
        }).catch(error=>{
        });
        // ater callout this.disableCBSBSRPSL = false (if already created)
        submitCIFDetails({
            applicantId: this.applicantRecord.Id
        })
        .then(data =>{
            if (data === 'Completed') {
                this.showToast('Success', 'Submitted details to CBS', 'success', 'dismissable');
            } else {
                this.showToast('Error', 'CBS rejected these details. Please recheck', 'error', 'dismissable');
                this.disableCBSBSRPSL = false;
            }
            this.dispatchLMSEvent()
        })
        .catch(error =>{
            this.showToast('Error', error?.message, 'error', 'dismissable');
            this.disableCBSBSRPSL = false;
        })
    }
    // Joshna - END OF CBS API Change Tracker updates

    // Joshna - START OF CBS API Change Tracker updates
    @wire(isComplete, { loanId: '', applicantId : '$applicantId' })
    wiredDate({ error, data }) {
        if (data) {
            this.disableCBSBSRPSL = data;
        } else if (error) {
            this.disableCBSBSRPSL = true;
        }
    }
    // Joshna - END OF CBS API Change Tracker updates


    dispatchLMSEvent(){
        const payload = { recordIdOfSobject: this.applicantRecord.Id, refreshPage: 'Yes'};
        publish(this.messageContext, pageRefreshOnMaterialFieldChange, payload);
    }

    /* START - SFAU-5602 */
    updateRecordCIF(cifNo, blnCIFModify){
        let obj = {};
        obj.Id = this.applicantRecord.Id;
        if (blnCIFModify) {
            obj.CIF_Modification_Successful__c = true;
        }
        else {
            obj.CIF_No__c = cifNo;
        }
        this.isLoading=true
        updateRecordServer({
            jsoAppObj : JSON.stringify(obj),
            blnModifyCIF : blnCIFModify
        }).then(data =>{
            if (data.blnSuccess == true) {
                this.isLoading=false
                const event = new ShowToastEvent({
                    title: 'Success',
                    message: data.strMsg,
                    variant: 'success',
                });
                this.dispatchEvent(event);
                if(!blnCIFModify) {
                    this.dispatchEvent(new CustomEvent('cifcreated',{
                        detail:{
                            applicantRecordId: this.applicantRecord.Id
                        }
                    }
                    ));
                }
                this.isLoading=false;
            } else if (data.blnSuccess == false) {
                this.isLoading=false
                this.cifButtonDisabled=false
                this.errorInCIFCreation=true
                this.errorInCIFModification=true
                this.showToast('Error',data.strMsg,'error')
            }
        }).catch(error => {
            this.isLoading=false
            this.cifButtonDisabled=false
            this.errorInCIFCreation=true
            this.errorInCIFModification=true
            this.showToast('Error',error.body.output.errors[0].errorCode,'error')
        });
    }
    /* END - SFAU-5602 */
}