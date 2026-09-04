import { LightningElement,api,track } from 'lwc';

export default class LosDocumentUploadParent extends LightningElement {
@api aadharNumber;
@api applicantId;
@api recordId;
docName;
showUploadComponent=false;
isShowAdditionalInformationsPicklist = false;
AdditionalInformationoptions = [
    { label: 'VoterId', value: 'AUWheels0002' },
    { label: 'Driving Licence', value: 'AUWheels0004' },
    { label: 'Passport', value: 'AUWheels0005' },
];
@track allAdditionalInformationvalues = [];
/*fileUploadWrapper = [
    { uploadTypeName: 'VoterId', docName: 'AUWheels0002' },
    { uploadTypeName: 'Driving Licence', docName: 'AUWheels0004' },
    { uploadTypeName: 'Passport', docName: 'AUWheels0005' },
];*/
@track fileUploadWrapper = [];
connectedCallback(){
    if(this.recordId){
        this.applicantId = this.recordId;
    }
}
handleAdditionalInformationClick() {
    console.log('this.isShowAdditionalInformationsPicklist', this.isShowAdditionalInformationsPicklist);
    this.isShowAdditionalInformationsPicklist = true;

}
handleUploadClick(event){
    this.docName =event.currentTarget.dataset.name;
    this.showUploadComponent = true;
}
handleSuccess(event){
    this.showUploadComponent = false;
    console.log('event.detail.documentNumber'+event.detail.documentNumber);
    this.aadharNumber = event.detail.documentNumber;
}
handleAdditionalInformationChange(event) {
    let valueStr;
    let labelStr
    this.AdditionalInformationoptions?.find((val)=>{
        if(val.value == event.target.value){
            valueStr = val.value;
            labelStr = val.label
        }
    })
    if (!this.allAdditionalInformationvalues.includes(labelStr)) {
        this.allAdditionalInformationvalues.push(labelStr);
        const record = {uploadTypeName: labelStr,docName: valueStr};
        this.fileUploadWrapper.push(record);
    }
    console.log('fileUploadWrapper'+JSON.stringify(this.fileUploadWrapper));
    console.log('this.allAdditionalInformationvalues'+JSON.stringify(this.allAdditionalInformationvalues));
    
}
handleRemove(event) {
    let labelStr;
    const valueRemoved = event.target.name;
    console.log('valueRemoved', valueRemoved);
    const index = this.fileUploadWrapper?.findIndex((val)=>{
        if(val.docName == event.target.name){
            labelStr = val.uploadTypeName;
            return true;
        }
    })
    this.allAdditionalInformationvalues.splice(this.allAdditionalInformationvalues.indexOf(labelStr), 1);
    if(index != -1){
        this.fileUploadWrapper.splice(index,1);
    }
    console.log('fileUploadWrapper Remove'+JSON.stringify(this.fileUploadWrapper));
    
}
}