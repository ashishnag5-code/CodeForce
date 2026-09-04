import { LightningElement, api } from 'lwc';

export default class FileUploadPDQ extends LightningElement {
    @api item;
    @api recordId;
    @api finalResult = {};
    @api showUploadOption;
    displayUpload=false;
    relatedFiles = [];
    showfiles = false;
    isFileTypePDF = false;
    isFileTypeImage = false;
    isNonPreviewableFile = false;
    fileURL;
    showPreview = false;
    
    connectedCallback(){
        if(this.item.value != undefined){
            this.relatedFiles = this.item.value;
            this.showfiles = true;
        }
        this.finalResult = {name : this.item.QualifiedApiName, value : this.relatedFiles};
        if(this.showUploadOption == 'No'){
            this.displayUpload = false;
        }else if(this.showUploadOption == 'Yes'){
            this.displayUpload = true;
        }
    }

    handleUploadFinished(event){
        console.log('event====='+JSON.stringify(event.detail.files));
        this.showfiles = false;
        let newfiles = [];
        event.detail.files.forEach(element => {
            var temp = element;
            temp.downloadURL = '/sfc/servlet.shepherd/version/download/'+temp.contentVersionId;
            newfiles.push(temp);
        });

        if(this.relatedFiles != undefined){
            this.relatedFiles.forEach(element => {
                newfiles.push(element);
            });
        }
        this.relatedFiles = newfiles;
        this.showfiles = true;
        this.finalResult = {name : this.item.QualifiedApiName, value : this.relatedFiles};
    }
    
    previewFile(event) {
        this.showPreview = true;
        console.log('name===='+JSON.stringify(event.target.name) + JSON.stringify(event.target.getAttribute('value')) );
        if (event.target.name.includes('pdf')) {
            this.isFileTypePDF = true;
            this.isFileTypeImage = false;
            this.isNonPreviewableFile = false;
            this.fileURL = event.target.getAttribute('value');
        } else if (event.target.name.includes('jpg') || event.target.name.includes('jpeg') || event.target.name.includes('gif') || event.target.name.includes('png')
            || event.target.name.includes('tiff') || event.target.name.includes('bmp')) {
            this.isFileTypePDF = false;
            this.isFileTypeImage = true;
            this.isNonPreviewableFile = false;
            this.fileURL = event.target.getAttribute('value');
        } else {
            this.isFileTypePDF = false;
            this.isFileTypeImage = false;
            this.isNonPreviewableFile = true;
        }
    }
    closeModal() {
        this.showPreview = false;
        this.fileURL = null;
        this.isFileTypePDF = false;
        this.isFileTypeImage = false;
        this.isNonPreviewableFile = false;
    }
}