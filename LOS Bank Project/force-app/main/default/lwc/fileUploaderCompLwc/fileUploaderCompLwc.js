import { LightningElement, api ,track} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFile from '@salesforce/apex/LOSDocumentUploadController.uploadFile';
import AcceptedFileFormate from '@salesforce/label/c.AcceptedFileFormate';
export default class FileUploaderCompLwc extends LightningElement {
    @api recordId;
    @api applicant = {};
    @api showPasswordInput;
    fileData;
    MAX_FILE_SIZE = 4000000; //Max file size 4.0 MB 
    fileName;
    isloading= false;
    acceptedFormat = AcceptedFileFormate;
    password='';
    @track uploadedFiles=[];
    filesUploaded = false;
    handleClick(){
        this.isloading =true;
        const applicantId = this.applicant.Id;
        const resultEvent = {isSuccess:true};
        const {base64, filename, recordId} = this.fileData;
        uploadFile({ base64, filename, recordId ,applicantId}).then(result=>{
            let parseResult=JSON.parse(result);
            if(parseResult.isSuccess ){
                const successhandlerEvent = new CustomEvent('successhandler', {
                    detail : resultEvent
                });
                this.dispatchEvent(successhandlerEvent);
                this.isloading =false;
                this.fileData = null
                this.showToastEvent('Success', 'File Uploaded Successfully', 'success');
            }else{
                this.showToastEvent('Error', 'We Encountered an Error while processing your file', 'error');
                
            }
        }).catch(error => {
            this.error = error;
            console.log('error'+error);
            this.isloading =false;
            this.showToastEvent('Error', 'We Encountered an Error while processing your file', 'error');
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
        if (event.target.files.length > 0) {
            const file = event.target.files[0];
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
            }
            reader.readAsDataURL(file);
        }
        
    }
    doSave(event) {
        if(this.template.querySelector('[data-id="fileId"]') && this.template.querySelector('[data-id="fileId"]').files.length>0){
            console.log('INSIDE UPLOAD');
            this.uploadHelper();
        }else {
            alert('Please Select a Valid File');
        }
    }
    uploadHelper(){
        var fileInput = this.template.querySelector('[data-id="fileId"]').files;
        var file = fileInput[0];
        // check the selected file size, if select file size greter then MAX_FILE_SIZE,
        // then show a alert msg to user,hide the loading spinner and return from function  
        console.log('file.size'+file.size);
        if (file.size > this.MAX_FILE_SIZE) {
            //component.set("v.showLoadingSpinner", false);
            //component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
            //return;
            //let title = 'Alert : File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size;
            //this.toast(title,"info");
            this.showToastEvent('Error Uploading File', 'File Size should be less than 4MB', 'Error');
            console.log('FileSIZE HIGHER'+file.size);
        }else{
            this.handleClick();
        }
    }
    handlePasswordChange(event){
        this.password = event.detail.value;
    }
}