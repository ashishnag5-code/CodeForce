import { LightningElement, api ,track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/LOSDocumentUploadController.uploadFile';
import AcceptedFileFormate from '@salesforce/label/c.AcceptedFileFormate';
import NOMRALFILESIZE from '@salesforce/label/c.NOMRALFILESIZE';
import handleStandardUpload from '@salesforce/apex/LOSDocumentUploadController.handleStandardUpload';
import polarInterval from '@salesforce/label/c.FileUploadInterval';
import PolarMaxLimit from '@salesforce/label/c.FileUploadMaxLimit';
import cartCalloutOnSubmit from '@salesforce/apex/MultipleFileUploadController.cartCalloutOnSubmit';
import checkUploadDocumentLargeFile from '@salesforce/apex/LOSDocumentUploadController.checkUploadDocumentLargeFile';
import getVersionFilesByChecklist from '@salesforce/apex/LOSDocumentUploadController.getVersionFilesByChecklistId';

import getAmount from '@salesforce/apex/CPVWaiverDocumentsController.getAmount'
export default class LosFileUploadGeneric extends LightningElement {
    @api recordId;
    @api applicantId;
    @api loanId;
    @api showPasswordInput;
    @api ocrNeeded;
    @api docName ='';
    @api docFullName ='';
    @api hidefiledetails =false;
    @api amountNeeded = false;
    @api cartCalloutRequired = false;
    @api isdocmanager =false;
    @api calledFromDocManager;
    @api showSummaryCart =false;
    @api maxFileSize;
    @api systemGenerated;
    @api multipleUpload;
    @api kycDocUploaded;
    amount;
    error;
    showButtons = true;
    fileData;
    MAX_FILE_SIZE = parseInt(NOMRALFILESIZE); //Max file size 3.5 MB 
    fileName;
    isloading= false;
    acceptedFormat = AcceptedFileFormate;
    password='';
    @track uploadedFiles=[];
    filesUploaded = false;
    showCustomUpload = true;
    largeFileEvent;
    largeFileIntervalTotal =0;
    contentVersionId='';
    fileUploadResult;
    acceptedFormats
    connectedCallback(){
        let docMaxSize = this.maxFileSize ? parseInt( (parseFloat(this.maxFileSize)) * 1000 ) : undefined;
        if(docMaxSize > this.MAX_FILE_SIZE){
            //SFAU-5652
            this.acceptedFormats = this.docName === 'Asset Verification' || this.kycDocUploaded ? ['.png', '.jpg','.jpeg', '.pdf' ] : ['.pdf','.zip'];
            this.showCustomUpload = false;
        }else{
            this.showCustomUpload = true;
        }

        if(this.docName == 'AUWheels0093' || this.docName == 'AUWheels0091'){
            getAmount({recordId: this.applicantId, documentType:this.docName}).then((data=>{
                this.amount = data
                let element = this.template.querySelector('[data-id="amountValue"]');
                if(this.amount && element){
                    element.disabled=true
                }
            }))
            
        }
        
    /*  if(this.docName =='AUWheels0008'){
            this.showCustomUpload = false;
        }else{
            this.showCustomUpload = true;
        }
    */ 
        
    }

    handleClickUpload(event){
        if(!this.multipleUpload && this.calledFromDocManager){
            this.checkAlreadyUploadedFile(event);
        }else if(this.showCustomUpload){
            this.handleFilesChange(event);
        }else if(!this.showCustomUpload){
            this.handleUploadFinished(event)
        }
    }

    checkAlreadyUploadedFile(event){
        getVersionFilesByChecklist({
            recordId : this.recordId
        }).then(result=>{
            if(result && result.length > 0){
                this.showToastEvent('File Upload Limit Exceed', 'Only one file can be uploaded', 'Error');
            }else if(this.showCustomUpload){
                this.handleFilesChange(event);
            }else if(this.showCustomUpload){
                this.handleUploadFinished(event)
            }
        }).catch(error=>{

        })
    }

    handleChange(event){
        this.amount = event.target.value;
    }

    handleUpload(){
        this.isloading =true;
        const applicantId = this.applicantId;
        const loanId = this.loanId;
        let fileNameVar = this.fileData.filename ? this.fileData.filename.split('.') : undefined;
        if(fileNameVar && fileNameVar.length > 1){
            this.fileData.filename = this.systemGenerated ?  fileNameVar[0] + '_eSigned.' + fileNameVar[1] : this.fileData.filename;
        }
        const {base64, filename, recordId} = this.fileData;
        uploadFile({ base64, filename, recordId ,applicantId,loanId}).then(result=>{
            let parseResult=JSON.parse(result);
            if(parseResult.isSuccess){
                if(this.cartCalloutRequired || this.amountNeeded){
                    this.cartCalloutOnSubmit(parseResult,false);
                }
                else{
                    let resultEvent = {isSuccess:true,versionId : parseResult.successRecordId,base64 : this.fileData.base64, fileName: this.fileData.fileName};
                    let successhandlerEvent = new CustomEvent('successhandler', {
                        detail : resultEvent
                    });
                    this.dispatchEvent(successhandlerEvent);
                    this.isloading =false;
                    this.fileData = null
                    this.showToastEvent('Success', 'File Uploaded Successfully', 'success');
                }
            }else{
                this.showToastEvent('Error', 'We Encountered an Error while processing your file', 'error');
                let resultEvent = {isSuccess:false};
                let errorhandlerEvent = new CustomEvent('successhandler', {
                    detail : resultEvent
                });
                this.dispatchEvent(errorhandlerEvent);
            }
        }).catch(error => {
            this.error = error;
            console.log('error'+error);
            this.isloading =false;
            this.showToastEvent('Error', 'We Encountered an Error while processing your file', 'error');
            let resultEvent = {isSuccess:false};
                let errorhandlerEvent = new CustomEvent('successhandler', {
                    detail : resultEvent
                });
            this.dispatchEvent(errorhandlerEvent);
        });
    }
    showToastEvent(titleValue, messageValue, variantValue){
        const event = new ShowToastEvent({
            title: titleValue, 
            message: messageValue,
            variant: variantValue
        });
        this.dispatchEvent(event);
    }
    handleFilesChange(event) {
        var fileName = 'No File Selected..';
        var list = [];
        if (this.uploadedFiles.length<1 && event.detail.files.length > 0) {
            if(this.docName == 'AUWheels0093' || this.docName == 'AUWheels0091'){
                getAmount({recordId: this.applicantId, documentType:this.docName}).then((data=>{
                    this.amount = data
                    if(this.amount){
                        this.event = setTimeout(() => {
                            this.template.querySelector('[data-id="amountValue"]').disabled=true
                            this.template.querySelector('[data-id="amountValue"]').value = this.amount
                          }, 100);
                       
                    }
                }))
                
            }
            const file = event.detail.files[0];
            var reader = new FileReader()
            reader.onload = () => {
                var base64 = reader.result.split(',')[1]
                this.fileData = {
                    'filename': file.name,
                    'base64': base64,
                    'recordId': this.recordId
                }
                console.log(this.fileData);
                console.log('fileName'+this.fileData.filename);
                this.filesUploaded = true;
                list.push({name: file.name, size: file.size, status:'Ready to Submit'})
                this.uploadedFiles = this.uploadedFiles.concat(list)
                this.fileName = this.fileData.filename;
                if(this.hidefiledetails){
                    this.doSave();
                }
            }
            reader.readAsDataURL(file);
        }else{
            this.showToastEvent('File Upload Limit Exceed', 'Only one file can be uploaded', 'Error');
        }
        
    }
    doSave(event) {
        if(this.template.querySelector('[data-id="fileId"]') && this.template.querySelector('[data-id="fileId"]').files.length>0){
            console.log('INSIDE UPLOAD');
            var fileInput = this.template.querySelector('[data-id="fileId"]').files;
            var file = fileInput[0];
            // check the selected file size, if select file size greter then MAX_FILE_SIZE,
            // then show a alert msg to user,hide the loading spinner and return from function  
            console.log('file.size'+file.size);
            if (file.size > this.MAX_FILE_SIZE) {
                this.showToastEvent('Error Uploading File', 'File Size should be less than 3.5MB', 'Error');
                console.log('FileSIZE HIGHER'+file.size);
            }else{
                if(this.handleValidations()){
                    this.handleUpload();
                }
            }
        }else {
            alert('Please Select a Valid File');
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
    handlePasswordChange(event){
        this.password = event.detail.value;
    }
    handleDeleteFile(){
        this.uploadedFiles=[];
        this.fileData=[];
        this.filesUploaded = false;
        this.password=''
    }
    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        let uploadedFileNames = '';
        let versionId ='';
        if (this.uploadedFiles.length<1 && event.detail.files.length > 0) {

            for(let i = 0; i < uploadedFiles.length; i++) {
                uploadedFileNames += uploadedFiles[i].name + ', ';
                versionId = uploadedFiles[i].contentVersionId;
            }
            console.log('versionId'+versionId);
            this.isloading= true;
            handleStandardUpload({
                contentVersionId : versionId,
                recordId : this.recordId,
                applicantId: this.applicantId,
                loanId : this.loanId
            }).then(result => {
                let parseResult=JSON.parse(result);
                if(parseResult.isSuccess && parseResult.polarNeeded){
                    this.isloading= true;
                    let fileSizeToSend = parseResult.fileSize;
                    this.largeFileEvent = setInterval(() => {
                        this.largeFileIntervalTotal= this.largeFileIntervalTotal+parseInt(polarInterval);
                        checkUploadDocumentLargeFile({
                            docRecordId : this.recordId,
                            currentFileSize : fileSizeToSend
                        }).then(result => {
                            let parseResult=JSON.parse(result);
                            if(parseResult.isSuccess){
                                if(this.cartCalloutRequired || this.amountNeeded){
                                    this.contentVersionId=parseResult.successRecordId;
                                    this.showSummaryCart = true;
                                    let list=[];
                                    list.push({name: uploadedFileNames, size: parseResult.fileSize, status:'Ready to Submit'})
                                    this.uploadedFiles = this.uploadedFiles.concat(list)
                                    this.fileUploadResult = parseResult;
                                    //this.cartCalloutOnSubmit(parseResult,true);
                                }
                                else{
                                    const resultEvent = {isSuccess:true,versionId:parseResult.successRecordId};
                                    const documentHandlerEvent = new CustomEvent('successhandler', {
                                        detail : resultEvent
                                    });
                                    this.dispatchEvent(documentHandlerEvent);
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Success',
                                            message: 'File Uploaded Successfully',
                                            variant: 'success',
                                        }),
                                    );
                                } 
                                this.isloading= false;
                                clearTimeout(this.largeFileEvent);
                            }else{
                                if(this.checkCounter() == false){
                                    console.log('counter'+this.largeFileIntervalTotal);
                                }else{
                                    this.isloading= false;
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Error',
                                            message: 'Something went wrong, please try again!!',
                                            variant: 'error',
                                        }),
                                    );
                                }
                            }
                            console.log('result'+result);
                            
                        })
                        .catch(error => {
                            this.error = error;
                            console.error('CompleteError'+error);
                            this.isloading = false;
                        });
                    }, polarInterval);
                }else if(parseResult.isSuccess){
                    if(this.cartCalloutRequired || this.amountNeeded){
                        this.contentVersionId=parseResult.successRecordId;
                        this.showSummaryCart = true;
                        let list=[];
                        list.push({name: uploadedFileNames, size: parseResult.fileSize, status:'Ready to Submit'})
                        this.uploadedFiles = this.uploadedFiles.concat(list)
                        this.fileUploadResult = parseResult;
                        //this.cartCalloutOnSubmit(parseResult,true);
                    }
                    else{
                        const resultEvent = {isSuccess:true};
                        const documentHandlerEvent = new CustomEvent('successhandler', {
                            detail : resultEvent
                        });
                        this.dispatchEvent(documentHandlerEvent);
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: ' File Uploaded Successfully ',
                                variant: 'success',
                            }),
                        );
                    }
                    this.isloading = false;
                }else if(!parseResult.isSuccess){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: parseResult.message,
                            variant: 'error',
                        }),
                    );
                    this.isloading = false;
                }
            })
            .catch(error => {
                this.error = error;
                console.error('CompleteError'+error);
                this.isloading = false;
            });
        }else{
            this.showToastEvent('File Upload Limit Exceed', 'Only one file can be uploaded', 'Error');
        }

    }
    checkCounter() {
        if (this.largeFileIntervalTotal > PolarMaxLimit) {
            clearInterval(this.largeFileEvent);
            this.largeFileIntervalTotal = 0;
            return true;
        }
        return false;
    }

    submitToCart(event) {
        this.cartCalloutOnSubmit(this.fileUploadResult,true);
    }

    cartCalloutOnSubmit(parseResult, boolCheck){
        this.isloading = true;
        cartCalloutOnSubmit({cvObject: this.fileData, recordId: this.applicantId, password: this.password, documentType: this.docFullName, amount: this.amount, contentVersionId:this.contentVersionId}).then((data)=>{
            console.log(data)
            //this.disableDelete = true;
            //this.uploadProgress = false;
            if(data == 'Submitted'){
                if(this.isdocmanager && !boolCheck){
                    let resultEvent = {isSuccess:true,versionId : parseResult.successRecordId};
                    let successhandlerEvent = new CustomEvent('successhandler', {
                        detail : resultEvent
                    });
                    this.dispatchEvent(successhandlerEvent);
                }
                else if(this.isdocmanager && boolCheck){
                    const resultEvent = {isSuccess:true,versionId:parseResult.successRecordId};
                    const documentHandlerEvent = new CustomEvent('successhandler', {
                        detail : resultEvent
                    });
                    this.dispatchEvent(documentHandlerEvent);
                }
                else{
                    this.dispatchEvent(new CustomEvent('enablefetchdetails', {
                        detail: true , bubbles: true, composed:true
                    }))
                    //this.showToastEvent('Success', 'File Uploaded Successfully', 'success');
                    /*list.forEach(element1 => {
                        if(element1.key == element.key){
                            element1.status = data;
                            //element1.isUploaded = true;
                            //element1.disableDelete = true;
                        }
                    })*/
                    this.dispatchEvent(new CustomEvent('detailsreceived', {
                        detail: {
                            isreceived: true,
                            amount: this.amount,
                        },
                        bubbles : true,
                        composed : true
                        
                    }))
                }
                this.isloading =false;
                this.fileData = null
                this.showSummaryCart=false;
                this.showToastEvent('Success', 'File Uploaded Successfully', 'success');
            }
            else{
                this.showToastEvent('Error', 'We Encountered an Error while processing your file', 'error');
                if(data && data.includes(';;;')){
                    var message = data.split(';;;');
                    if(message && message[0]=='Rejected' && message[1]){
                        this.showToastEvent('', message[1], 'error');
                    }
                }
                this.isloading =false;
                /*list.forEach(element1 => {
                    if(element1.key == element.key){
                        element1.status = data;
                        element1.isUploaded = false;
                        element1.disableDelete = false;
                    }
                })*/
            }
            
            //this.uploadedFiles=[];
            //this.uploadedFiles = this.uploadedFiles.concat(list)
            
        }).catch((error)=>{
            this.showToastEvent('Error', 'We Encountered an Error while processing your file'+error, 'error');
        })
    }
}