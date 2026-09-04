import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateOCRDate from '@salesforce/apex/LOSDocumentUploadController.updateOCRData';
import getDocumentChecklist from '@salesforce/apex/LOSDocumentUploadController.getDocumentChecklist';
import FORM_FACTOR from '@salesforce/client/formFactor';
export default class LosGenericDocumentUpload extends LightningElement {
@api recordId;
@api uploadtypename;
@track showUpload = false;
@api documentNumber;
@api applicantId;
@api loanId;
@api collateralId;
documentMasterName
@api 
get docName(){
    return this.documentMasterName;
}
set docName(value){
    var temp = this.docName
    this.documentMasterName=value
    if(temp && temp!=value){
        this.getDocChecklistRecords()
    }
}
@api isloading;
@api showUploadComponent =false;
@api showInputBox = false;
@api isModelNeeded =false;
@api isapplicantPage =false;
@api isdocmanager =false;
@api hidefiledetails =false;
@api fieldInvetigationId='';
@api isliveonly = false;
title;
showOCRDetails = false;
dataValues = [];
applicantRecord;
docChkRecord;
isAadhar = false;
isMobile=false;
versionId;
@api isForm60 = false;
docImage = '';
docImageBase64='';

connectedCallback(){
    this.getDocChecklistRecords()
}

@api
getDocChecklistRecords(){
    console.log('this.loanId this.loanId'+this.loanId);
    console.log('this.lshowUploadComponent'+this.showUploadComponent);

    if(FORM_FACTOR=='Small'){
        this.isMobile = true;
    }else{
        this.isMobile = false;
    }
    if(this.recordId){
        this.applicantId = this.recordId;
    }
    this.isloading = true;
    getDocumentChecklist({
        applicantId : this.applicantId,
        docName : this.docName,
        loanId : this.loanId,
        fieldInvestId : this.fieldInvetigationId,
        collateralId: this.collateralId
    }).then(result => {
        console.log('result'+result);
        let parseResult=JSON.parse(result);
        if(parseResult.isSuccess && parseResult.docChkList && parseResult.docChkList.length>0){
            if(parseResult.docChkList[0] && parseResult.docChkList[0].Document_Master__r){
                this.uploadtypename = parseResult.docChkList[0].Document_Master__r.Document_Name__c;
                this.title = 'Upload ' +this.uploadtypename;
            }else{
                this.showToastEvent('', this.uploadtypename+' is Not Applicable for this Application', 'warning');
            }
            
        }else{
            this.showToastEvent('', this.uploadtypename+' is Not Applicable for this Application', 'warning');
            console.log('No result found.');
            console.log('Error message'+parseResult.message);
        }
        this.isloading = false;
    }).catch(error => {
        this.error = error;
        this.isloading = false;
    });
}

renderedCallback(){
    this.showUpload = true;
}
handleUploadClick(event){
    console.log('docName'+this.docName+'applicantId'+this.applicantId+'');
    //this.docName =event.currentTarget.dataset.name;
    this.showUploadComponent = true;
}
handleSuccess(event){
    //this.showUploadComponent = false;
    if(event.detail.isSuccess && event.detail.documentNumber){
        console.log('event.detail.documentNumber'+event.detail.documentNumber);
        this.documentNumber = event.detail.documentNumber;
        var ocrMap = event.detail.octResultMap;
        this.applicantRecord = event.detail.applicantRecord;
        this.docChkRecord = event.detail.docChkRecord;
        this.isAadhar = event.detail.isAadhar;
        this.versionId = event.detail.versionId;
        console.log('ocrMap'+ocrMap);
        console.log('ocrMap'+JSON.stringify(ocrMap));
        for (var key in ocrMap) {
            if(key == 'documentBase64'){
                if (ocrMap[key] !== undefined && ocrMap[key] !== null) {
                    this.docImage = 'data:image/png;base64,' +  ocrMap[key];
                }
                this.docImageBase64 = ocrMap[key];
                //this.dataValues.push({ key: key, value: this.docImage });
            } else if (key == 'Aadhar Number') {
                let maskedValue = ocrMap[key];
                maskedValue = maskedValue === undefined || maskedValue === null ? '' : ('********' + maskedValue.substring(maskedValue.length - 4));
                this.dataValues.push({key: key, value: maskedValue });
            } else{
                this.dataValues.push({ key: key, value: ocrMap[key] });
            }
            console.log('key', key, ocrMap[key]);
        }
        this.dataValues.reverse();
        let dataValuesForEvent = JSON.parse(JSON.stringify(this.dataValues));
        dataValuesForEvent.push({ key: 'documentBase64', value: this.docImageBase64 });
        if(this.isapplicantPage || (this.isMobile && this.isdocmanager)){
            const resultEvent = {isSuccess:true,docName: this.docName,showOCRInParent:true,ocrData: dataValuesForEvent, applicantRec: JSON.stringify(this.applicantRecord), documentChkRecord: JSON.stringify(this.docChkRecord),isAadhar: this.isAadhar,contentVersionId :this.versionId,documentNumber:event.detail.documentNumber,base64: event.detail.base64,fileName: event.detail.fileName};
            const documentHandlerEvent = new CustomEvent('documentsuccess', {
                detail : resultEvent
            });
            this.dispatchEvent(documentHandlerEvent);
            this.showUploadComponent = false;
        }else{
            this.showOCRDetails = true;
            this.showUpload=false;
            this.showInputBox =false;
        }

        console.log('dataValues'+this.dataValues);
    }else if(event.detail.isSuccess && event.detail.showGreenTick){
        console.log('Show GreenTick')
        const resultEvent = {isSuccess:true,showGreenTick:event.detail.showGreenTick,docName:this.docName,versionId:event.detail.versionId,base64: event.detail.base64,fileName: event.detail.fileName};
        const greenTickEvent = new CustomEvent('documentsuccess', {
            detail : resultEvent
        });
        this.dispatchEvent(greenTickEvent);
    }else if(event.detail.isSuccess){
        console.log('losGeneric NO OCR & Success')
        this.versionId = event.detail.versionId;
        const resultEvent = {isSuccess:true,versionId:this.versionId,base64: event.detail.base64,fileName: event.detail.fileName};
        const documentHandlerEvent = new CustomEvent('documentsuccess', {
            detail : resultEvent
        });
        this.dispatchEvent(documentHandlerEvent);
    }else{
        this.showToastEvent('Error', event.detail.errorMessage, 'error');
        //this.showUploadComponent = false;
    }

}
hideModalBox() {  
    this.showUploadComponent = false;
    const resultEvent = {isSuccess:true,};
    const documentHandlerEvent = new CustomEvent('cancel', {
        detail : resultEvent
    });
    this.dispatchEvent(documentHandlerEvent);
}
okClick(){
 this.updateRecords(true);
}
notOkClick(){
    //this.updateRecords(false);
    console.log('');
    //this.showUploadComponent = false;
    this.showToastEvent('Success', 'Details Updated Succesfully!!', 'success');
    this.showUploadComponent = false;
    const resultEvent = {isSuccess:true};
    const documentHandlerEvent = new CustomEvent('documentsuccess', {
    detail : resultEvent
    });
    this.dispatchEvent(documentHandlerEvent);
}
updateRecords(isOkBoolean){
    this.isloading= true;
    this.applicantRecord['documentBase64'] = this.docImageBase64;
    updateOCRDate({ applicantRec: JSON.stringify(this.applicantRecord), documentChkRecord: JSON.stringify(this.docChkRecord),isAadhar: this.isAadhar,isOk :isOkBoolean,contentVersionId :this.versionId })
    .then(result => {
        this.isloading= false;
        let parseResult=JSON.parse(result);
        if(parseResult.isSuccess){
            this.showToastEvent('Success', 'Details Updated Succesfully!!', 'success');
            this.showUploadComponent = false;
            const resultEvent = {isSuccess:true};
            const documentHandlerEvent = new CustomEvent('documentsuccess', {
            detail : resultEvent
            });
            this.dispatchEvent(documentHandlerEvent);
        }else{
            this.showToastEvent('Error', 'We Encountered an Error while updating details!!', 'error');
            this.showUploadComponent = false;
            const resultEvent = {isSuccess:false};
            const documentHandlerEvent = new CustomEvent('documentsuccess', {
            detail : resultEvent
            });
            this.dispatchEvent(documentHandlerEvent);
        }
    })
    .catch(error => {
        this.isloading= false;
        this.error = error;
        console.log('error', error);
        this.showUploadComponent = false;
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
handleOCRBUtton(event){
    const resultEventOCR = {isSuccess:true,docName:event.detail.docName,documentId : event.detail.documentId,documentType : event.detail.documentType,applicantId : event.detail.applicantId};
    const ocrEvent = new CustomEvent('ocrbutton', {
        detail : resultEventOCR
    });
    this.dispatchEvent(ocrEvent);
}
@api handleOCRClickParent() {
    //alert('Inside OCR Child1');
    this.template.querySelector("c-los-document-upload").handleOCRClickParent();
}
}