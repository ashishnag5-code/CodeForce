import { LightningElement, track, api } from 'lwc';
//import uploadFiles from '@salesforce/apex/MultipleFileUploadController.uploadFiles';
//import uploadFile from '@salesforce/apex/MultipleFileUploadController.uploadFile';
import cartCalloutOnSubmit from '@salesforce/apex/MultipleFileUploadController.cartCalloutOnSubmit';
import calculateAverageSalary from '@salesforce/apex/MultipleFileUploadController.calculateAverageSalary';
import getDocumentMaster from '@salesforce/apex/MultipleFileUploadController.getDocumentMaster';
import getApplicableDocumentMasters from '@salesforce/apex/MultipleFileUploadController.getApplicableDocumentMasters'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class UploadMultipleFiles extends LightningElement {

    @api applicantRecordId;
    @api applicantId
    @api loanAppId
    @api recordId;
    @api readAttribute;
    @api headingValue=''
    @api documentType=''
    @api showonlyItr;
    @track documentMasterId=''
    @api documentMasterName
    @track loadGenericDocument=false;
    @track trueValue = true;
    @track falseValue = false;
    @track hidefiledetails = false;
    applicableDocumentMasters=[];
    selectedDocumentMaster=[];
    @track uploadedFiles=[];
    @track uploadProgress=false
    @track currentFile;
    hideRadioButtons=false
    filesUploaded = false;
    fileData=[];
    keyIndex = 1;
    loadSpinner=false;
    enableFetchDetails = false;
    password='';
    disableDelete = false;
    showButtons = true;
    amount;

    /*columns = [
        { label: 'File Name', fieldName: 'name' },
        { label: 'File Size', fieldName: 'size'},
        { label: 'Status', fieldName: 'status'},
        {label: 'Action',
            type: 'button-icon',
            typeAttributes: {
                iconName: 'utility:delete',
                variant: 'border-filled',
                alternativeText: 'Delete',
                disabled: {fieldName: 'disableDelete'}
            }
        }
    ];*/

    handleSuccess(event){
        console.log('%%% in handle success');
    }

    handleSuccessResp(){
        if(this.documentMasterId == 'AUWheels0077' || this.documentMasterId == 'AUWheels0107'){
            this.hidefiledetails=true
        }
    }

    connectedCallback(){
        if(this.documentType == 'Bank ITR Statement' || this.documentType == 'Bank Account Statement'){
            this.documentMasterName = 'Bank_ITR_Statement'
        }
        getApplicableDocumentMasters({documentMaster: this.documentMasterName}).then((data=>{
            var documentsList=[]
            if(data.length>0){
                data.forEach(input=>{
                    if(this.showonlyItr == 'true'){
                        if(input.Document_Name__c !='Bank Statement'){
                            documentsList.push({label:input.Document_Name__c, value:input.Name})
                        }
                    }else{
                        documentsList.push({label:input.Document_Name__c, value:input.Name})
                    }
                    
                })
                this.applicableDocumentMasters = documentsList;
                if(this.applicableDocumentMasters && this.applicableDocumentMasters.length==1){
                    this.documentMasterId=this.applicableDocumentMasters[0].value;
                    this.loadGenericDocument=true
                    this.hideRadioButtons=true
                }
                
            }
            
           console.log('documentsList-->' +JSON.stringify(documentsList));
           
        })).catch((error=>{
            console.log(error)
        }))
        /*getDocumentMaster({strDocumentName: this.documentType}).then((data)=>{
            this.documentMasterId = data.Name;
            this.loadGenericDocument = true;
        }).catch((error)=>{
            console.log(error);
        })*/
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

    get acceptedTypes(){
        return '.pdf, .zip'
    }

    handleClose(event){
        this.dispatchEvent(new CustomEvent('handleclose',{
            detail: true
        }));
    }

    @api
    handleFetchDetails(){
        calculateAverageSalary({recordId: this.applicantRecordId}).then((data)=>{
            if(data && data.length>0){
                if(data[0].cartError){
                    this.showToastEvent('', data[0].cartError, 'error');
                }else{
                    this.dispatchEvent(new CustomEvent('cartcallbackmonthlyincome', {
                        detail: data
                    }))
                }
            }else{
                this.showToastEvent('Error', 'No Salary Details Found', 'Error');
            }
            
        }).catch((error)=>{
            console.log(error);
        })
    }

    handleChange(event){
        this.amount = event.target.value;
    }

    handleDocumentSelection(event){
        this.loadGenericDocument = false;
        this.selectedDocumentMaster = event.target.value;
        this.documentMasterId = this.selectedDocumentMaster;
        this.dispatchEvent(new CustomEvent('selecteddocumenttype', {
            detail: {
                documentType: this.documentMasterId
            }
        }))
        let timeout = setTimeout(() => {
            this.loadGenericDocument = true;
        },1000);
        

        /*getDocumentMaster({strDocumentName: this.documentType}).then((data)=>{
            this.documentMasterId = data.Name;
            this.loadGenericDocument = true;
        }).catch((error)=>{
            console.log(error);
        })*/
    }

    handlePasswordChange(event){
        this.password = event.detail.value;
    }

    showToastEvent(titleValue, messageValue, variantValue){
        const event = new ShowToastEvent({
            title: titleValue, 
            message: messageValue,
            variant: variantValue
        });
        this.dispatchEvent(event);
    }

    handleFilesChange(event){
        
        
        if(this.uploadedFiles.length<1){

            this.filesUploaded = true;
            var files = Array.from(event.target.files)
            console.log(event.target.files);

            files.forEach(element => {
                var list = [];
                if(element.size>3146000){
                    this.showToastEvent('Error Uploading File', 'File Size should be less than 3MB', 'Error');
                }
                else{
                    var reader = new FileReader();
                    reader.onload = () =>{
                        console.log(reader.result);
                        var base64Val = reader.result.split(',')[1];
                        var newFileData = {key:this.keyIndex, fileName: element.name, base64: base64Val, size: element.size};
                        this.fileData.push(newFileData);
                        list.push({key:this.keyIndex, name: element.name, size: element.size, isUploaded:'in Progress', status:'Ready to Submit'})
                        this.uploadedFiles = this.uploadedFiles.concat(list)
                        this.keyIndex++;
                        console.log('fileData '+JSON.stringify(this.fileData)) 
                        console.log('uploaded files '+JSON.stringify(this.uploadedFiles))   
                    }
                    reader.readAsDataURL(element);
                }
            });   
        }
        else{
            this.showToastEvent('File Upload Limit Exceed', 'Only one file can be uploaded', 'Error');
        }
    }

    handleDeleteFile(){
        this.uploadedFiles=[];
        this.fileData=[];
        this.filesUploaded = false;
        this.password=''
        this.dispatchEvent(new CustomEvent('enablefetchdetails', {
            detail: false
        })) 
    }

    @api
    hideButtons(){
        this.showButtons = false;
    }

    handleSubmit(){

        if(this.handleValidations()){
        console.log('Uploaded Files '+JSON.stringify(this.uploadedFiles));
        this.fileData.forEach(element => {
            var list = this.uploadedFiles
            
            console.log('List '+JSON.stringify(list));
            this.uploadProgress = true;
            this.currentFile = element.fileName;
            console.log('Password '+this.password)
            cartCalloutOnSubmit({cvObject: element, recordId: this.applicantId, password: this.password, documentType: this.documentType, amount: this.amount, contentVersionId:''}).then((data)=>{
                console.log(data)
                this.disableDelete = true;
                this.uploadProgress = false;
                if(data == 'Submitted'){
                    /*if(this.documentType){
                        alert('documenttype '+this.documentType)
                    }*/
                    this.dispatchEvent(new CustomEvent('enablefetchdetails', {
                        detail: true
                    }))
                    /*this.dispatchEvent(new CustomEvent('selecteddocumenttype', {
                        detail: {
                            documentType: this.documentType
                        }
                    }))*/
                    this.showToastEvent('Success', 'File Uploaded Successfully', 'success');
                    list.forEach(element1 => {
                        if(element1.key == element.key){
                            element1.status = data;
                            //element1.isUploaded = true;
                            //element1.disableDelete = true;
                        }
                    })
                    this.dispatchEvent(new CustomEvent('detailsreceived', {
                        detail: {
                            isreceived: true,
                            amount: this.amount
                        }
                        
                    }))
                }
                else{
                    this.showToastEvent('Error', 'We Encountered an Error while processing your file', 'error');
                    list.forEach(element1 => {
                        if(element1.key == element.key){
                            element1.status = data;
                            element1.isUploaded = false;
                            element1.disableDelete = false;
                        }
                    })
                }
                
                this.uploadedFiles=[];
                this.uploadedFiles = this.uploadedFiles.concat(list)
                
            }).catch((error)=>{
                this.showToastEvent('Error', 'We Encountered an Error while processing your file'+error, 'error');
            })
            
        });
    }
    else{
        this.showToastEvent('Error', 'Mandatory Details Missing', 'error');
    }

        
    }

    
}