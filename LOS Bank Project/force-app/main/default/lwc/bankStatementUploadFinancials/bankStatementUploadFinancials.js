import { api, LightningElement, track } from 'lwc';
import checkIfAlreadyUploadedForFinancials from '@salesforce/apex/CPVWaiverDocumentsController.checkIfAlreadyUploadedForFinancials'
import calculateAverageSalary from '@salesforce/apex/MultipleFileUploadController.calculateAverageSalary';
import checkCartFetchButton from '@salesforce/apex/financeController.checkCartFetchButton';
import getCartStatement from '@salesforce/apex/financeController.getCartStatement';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import viewLatestUploadedBankStatement from '@salesforce/apex/CPVWaiverDocumentsController.viewLatestUploadedBankStatement'
import getApplicantDetails from '@salesforce/apex/CPVWaiverDocumentsController.getApplicantDetails'
//import deleteBankStatement from '@salesforce/apex/CPVWaiverDocumentsController.deleteBankStatement'
import deleteBankStatement from '@salesforce/apex/RecordAccessExceptionHandler.deleteBankStatement'
import {NavigationMixin} from 'lightning/navigation';
import getUploadedITRS from '@salesforce/apex/CPVWaiverDocumentsController.getUploadedITRS'
import { updateRecord } from 'lightning/uiRecordApi';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';//4733

export default class BankStatementUploadFinancials extends NavigationMixin(LightningElement) {

    isUploadFile = false;
    received=false
    amount
    label
    @track hideButtons=false
    @api documentType
    @api applicantId
    isFetchApi=false
    showFetchButton = false;
    @api showonlyItr;
    currentSelectedDocument='';
    @track displayITRS=false
    @track itrStatements=[]
    casaOptions=[];
    selectedBankAccountNumber;
    isloading = false;
    //removeViewStatement = false;
    isDialogVisible = false;
    applicantDetails;
    @track initialLabel="Please Upload Statement"
    @track documentMasterName=''
    @track isEditRestricted //4733

    async connectedCallback(){
        console.log('applicantId-- ', this.applicantId);
        this.applicantDetails = await getApplicantDetails({recordId: this.applicantId})
        //4733
        this.isEditRestricted = await restricAccess({compName: 'financialView' ,loanId: this.applicantDetails.Loan__c})
        if(!this.isEditRestricted){
            this.handleCheckCartVisibility();
        }
    }

    handleCheckCartVisibility(){
        checkCartFetchButton({applicantId: this.applicantId})
        .then((data)=>{
            if(data!=null && data.length>0){
                this.showFetchButton = true;
                let records = data;
                let options=[];
                for (var key in records) {
                    options.push({
                        label: records[key].Account_Number__c,
                        value: records[key].Account_Number__c
                    });
                 }
                 this.casaOptions = options;
                 // SFAU-5144 Started - if only one CASA account then setting by default.
                 this.selectedBankAccountNumber = this.casaOptions && this.casaOptions.length == 1 ? this.casaOptions[0].value : this.selectedBankAccountNumber;
                 // SFAU-5144 Started - if only one CASA account then setting by default.
            }else{
                this.showFetchButton = false;
            }
        })
    }
    handleChange(event){
        this.selectedBankAccountNumber = event.target.value;
    }

    handleUploadFile(event){
        //4733 start
        if(this.isEditRestricted){
            const evt = new ShowToastEvent({
                title: 'Access Restricted',
                message: 'You do not have access to edit Financial Details',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            return
        }
        //4733 end
        this.displayITRS = false
        this.received = false
        this.hideButtons=true
        let docTypeToBeChecked=[];
        if(this.applicantDetails.Loan__r.Stage__c=='QDE' && this.applicantDetails.Loan__r.RecordType.DeveloperName!='Tractor'){
            this.initialLabel = "Please Upload Bank Statement"
            this.documentType='Bank Statement'
            this.currentSelectedDocument='AUWheels0107'
            docTypeToBeChecked.push('Bank Statement');
        }else if((this.documentType == 'Bank ITR Statement' || this.documentType=='Bank Account Statement')){
            docTypeToBeChecked.push('Bank Statement');
            docTypeToBeChecked.push('ITR Statement');
        }else if(this.documentType == 'Bank Statement'){
            docTypeToBeChecked.push('Bank Statement')
            this.currentSelectedDocument='AUWheels0107'
        }else if(this.documentType == 'ITR Statement'){
            docTypeToBeChecked.push('ITR Statement')
            this.currentSelectedDocument='AUWheels0077'
        }
        this.documentMasterName = this.documentType.replace(' ','_')
        if(this.documentType == 'Bank Statement'){
            checkIfAlreadyUploadedForFinancials({recordId: this.applicantId, documentType: docTypeToBeChecked}).then((data)=>{
                if(data && data.Status__c==='Received'){
                    this.received=true
                    this.amount=data.Amount__c
                    this.label = 'Statement Uploaded'
                    this.hideButtons = true
                    this.handleBankStatementUploaded();
                }else{
                    this.isUploadFile = true
                    //this.hideButtons = true
                    this.hideButtons = true
                }
            })
        }else if(this.documentType== 'ITR Statement'){
            getUploadedITRS({recordId: this.applicantId, docName: 'AUWheels0077'}).then((data=>{
                if(data && data.length>0){
                    this.displayITRS = true
                    this.itrStatements = data
                    this.isUploadFile = true
                    this.hideButtons = true
                }else{
                    this.isUploadFile = true
                    this.hideButtons = true
                }
            }))
            
        }
        else{
            this.isUploadFile = true
            //this.hideButtons = false
        }
    }

    handleEnableFetchDetails(event){

    }

    //Method to dispatch event to parent comp once bank statement uplaoded
    handleBankStatementUploaded(){
        this.dispatchEvent(new CustomEvent('bankstuploaded', {
            detail: true
        })) 
        this.event = setTimeout(() => {
            if(this.currentSelectedDocument=='AUWheels0077'){
                this.template.querySelector('[data-id="fetchButton"]').classList.add('slds-hide')
            }
          }, 100);
        
    }
    
   /* handleFetchApi(event){
        calculateAverageSalary({recordId: this.applicantId}).then((data)=>{
            if(data && data.length>0){
                data.forEach(input=>{
                    if(input.cartError){
                        this.showToastEvent('', data[0].cartError, 'warning');
                    }
                })
                this.dispatchEvent(new CustomEvent('cartcallbackmonthlyincome', {
                    detail: data
                }))
                 
            }else{
                this.showToastEvent('', 'No Salary Details Found', 'warning');
            }
            
        }).catch((error)=>{
            console.log(error);
        })
        
    }*/
    handleFetchApi(event){
        calculateAverageSalary({recordId: this.applicantId}).then((data)=>{
            if(data && data.length>0){
                let newData=[];
                data.forEach(input=>{
                    if(input.cartError){
                        this.showToastEvent('', data[0].cartError, 'error');
                    }else{
                        newData.push(input);
                    }
                })
               
                if(newData && newData.length>0){
                    this.dispatchEvent(new CustomEvent('cartcallbackmonthlyincome', {
                        detail: newData
                    }))
                }
                
                 
            }else{
                this.showToastEvent('', 'We havent received the callback yet and please wait for some time', 'warning');
            }
            
        }).catch((error)=>{
            console.log(error);
        })
        
    }

    showToastEvent(titleValue, messageValue, variantValue){
        const event = new ShowToastEvent({
            title: titleValue, 
            message: messageValue,
            variant: variantValue
        });
        this.dispatchEvent(event);
    }

    handleSelectedDocumentType(event){
        if(event.detail.documentType){
            this.currentSelectedDocument = event.detail.documentType
        }
        if(this.currentSelectedDocument == 'AUWheels0107'){
            this.hideButtons = true
            this.displayITRS = false
            this.checkDocumentToBeViewed()
        }
        if(this.currentSelectedDocument == 'AUWheels0077'){
            getUploadedITRS({recordId: this.applicantId, docName: 'AUWheels0077'}).then((data=>{
                if(data && data.length>0){
                    this.displayITRS = true
                    this.itrStatements = data
                    this.isUploadFile = true
                    this.hideButtons = true
                }
            }))
        }
    }

    async checkDocumentToBeViewed(){
        let documentTypeList = ['Bank Statement']
        let data = await checkIfAlreadyUploadedForFinancials({recordId: this.applicantId, documentType: documentTypeList})
            if(data && data.Status__c==='Received'){
                this.received=true
                this.amount=data.Amount__c
                this.label = 'Statement Uploaded'
                this.hideButtons = true
                this.handleBankStatementUploaded();
            }else{
                this.isUploadFile = true
                //this.hideButtons = true
                this.hideButtons = true
            }
    }

    viewLatestBankStatement(){
        viewLatestUploadedBankStatement({recordId: this.applicantId, docName:this.currentSelectedDocument}).then((data=>{
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state : {
                    recordIds: data,
                    selectedRecordId: data
                }
            })
        })).catch((error=>{
            console.log(error)
        }))
    }
    //3131
    deleteFile(event){
        console.log('event name in parent-- ', event.target.name);
        if(event.target.name === 'openConfirmation'){
            //it can be set dynamically based on your logic
            this.originalMessage = 'test message';
            //shows the component
            this.isDialogVisible = true;
        }else if(event.target.name === 'confirmModal'){
            console.log('event details- ', event.detail.status);
            //when user clicks outside of the dialog area, the event is dispatched with detail value  as 1
            if(event.detail !== 1){
                //gets the detail message published by the child component
                this.displayMessage = 'Status: ' + event.detail.status + '. Event detail: ' + JSON.stringify(event.detail.originalMessage) + '.';

                //you can do some custom logic here based on your scenario
                if(event.detail.status === 'confirm') {
                    this.captureBankStatementDocRecordId();
                }else if(event.detail.status === 'cancel'){
                    //do something else
                }
            }
            this.isDialogVisible = false;
        }
    }
    // deleteFile(event){
    //     this.isDialogVisible = true;
    //     //this.captureBankStatementDocRecordId();
    // }
    captureBankStatementDocRecordId(){
        viewLatestUploadedBankStatement({recordId: this.applicantId, docName:this.currentSelectedDocument}).then((data=>{
            this.deleteContentDocument(data);     

        })).catch((error=>{
            console.log(error);
        }))
    }
    
    deleteContentDocument(data){
        console.log('data-- ', data);
        console.log('applicantId-- ', this.applicantId);
        deleteBankStatement({recordId: this.applicantId, conDocId:data}).then((result=>{
            console.log('data deleted');
            //this.removeViewStatement = true;
            this.handleClose();
            this.dispatchEvent(new CustomEvent('deleteremoveverified', {
                    detail: true
                }))
        })).catch((error=>{
            console.log(error);
        }))
    }
    // ended 3131
    @api
    handleClose(event){
        this.hideButtons=false
        this.isFetchApi=false
        this.isUploadFile=false
        this.received=false
        this.displayITRS=false
    }

    handleEvent(event){
        if(event.detail.isreceived){
            
            this.amount = event.detail.amount
            this.label = 'Statement Uploaded'
            this.handleBankStatementUploaded();
        }
        if(this.currentSelectedDocument == 'AUWheels0107'){
            this.received=true
            this.checkDocumentToBeViewed()
        }
        if(this.currentSelectedDocument == 'AUWheels0077'){
            this.displayITRS = false
            getUploadedITRS({recordId: this.applicantId, docName: 'AUWheels0077'}).then((data=>{
                if(data && data.length>0){
                    this.displayITRS = true
                    this.itrStatements = data
                    this.isUploadFile = true
                    this.hideButtons = true
                }
            }))
        }
    }

    handleViewITRDocument(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state : {
                recordIds: event.target.accessKey,
                selectedRecordId: event.target.accessKey
            }
        })
    }

    handleFetchDetails(){
        if(!this.selectedBankAccountNumber){
            this.showToastEvent('', 'Please select CASA Account.', 'error');
            return;
        }
        this.isloading = true;
        getCartStatement({
            applicantId: this.applicantId,
            accountNumber : this.selectedBankAccountNumber
        })
        .then(result => {
            this.showToastEvent('', 'Fetched Successful', 'success');
            var fields = { Id: this.applicantId, Cart_Statement_Service_Done__c: true }
            const recordInput = { fields };
            updateRecord(recordInput).then(() => {
                this.isloading = false;
            }).catch((error=>{
                this.isloading = false;
            }))           
        })
        .catch(error => {
            this.isLoading = false;
            console.log('error in cartStatement details-->' + JSON.stringify(error));
        })
    }
}