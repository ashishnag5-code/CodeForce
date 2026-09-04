import { LightningElement, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
export default class FileUploadLWCDummy extends LightningElement {
    @api recordId;
    get acceptedFormats() {
        return ['.pdf', '.png','.jpg','.jpeg'];
    }
    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        let uploadedFileNames = '';
        for(let i = 0; i < uploadedFiles.length; i++) {
            uploadedFileNames += uploadedFiles[i].name + ', ';
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: uploadedFiles.length + ' Files uploaded Successfully: ' + uploadedFileNames,
                variant: 'success',
            }),
        );
    }
    handleDrag(event) {
        if (event.dataTransfer.items) {
            for (let i = 0; i < event.dataTransfer.items.length; i++){
                const item = event.dataTransfer.items[i];
                if (item.type && !item.type.includes('image') && !item.type.includes('pdf')) {
                    const file = item.getAsFile();
                    let nameSplit = file.name.split(".");
                    //let fileType = item.type.split("/");
                    this.showToast('Error', `Sorry, the following file types are not supported: ${nameSplit[(nameSplit.length-1)]}`, 'error');
                }
            }
        }        
    }
    handleError(){
        console.log('INSID FILE UPLOAD ERROR');
    }
}