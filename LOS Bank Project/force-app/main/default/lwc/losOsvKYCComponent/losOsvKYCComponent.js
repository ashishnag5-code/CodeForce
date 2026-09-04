import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import DocumentAadhaar from '@salesforce/label/c.DocumentAadhaar';
import getVersionFilesRec from '@salesforce/apex/LOSDocumentUploadController.getVersionFiles';
import updateOCRDate from '@salesforce/apex/LOSDocumentUploadController.updateOCRData';
import getTokenViaAddharNumber from '@salesforce/apex/AadharTokenUtil.getTokenViaAddharNumber';
import getAadhaarNumViaToken from '@salesforce/apex/LOSAdharKycController.getAadhaarNum';

import DocumentDL from '@salesforce/label/c.DocumentDL';
import DocumentPan from '@salesforce/label/c.DocumentPan';
import DocumentPassport from '@salesforce/label/c.DocumentPassport';
import DocumentVoter from '@salesforce/label/c.DocumentVoter';

import {  updateRecord } from 'lightning/uiRecordApi';
import Applicant_ID_FIELD from '@salesforce/schema/Applicant__c.Id';
import Applicant_KYCTYPE_FIELD from '@salesforce/schema/Applicant__c.KYC_Type__c';
import { NavigationMixin } from 'lightning/navigation';
import Generic_API_Error from '@salesforce/label/c.Generic_API_Error';
import validateRecordEdit from '@salesforce/apex/ComponentProfileRestrictionController.validateRecordEdit';

export default class LosOsvKYCComponent extends NavigationMixin(LightningElement) {
    Generic_API_Error = Generic_API_Error;

    @api spinnerImage;
    @api recordId;
    @api applicant = {};
    @api applicantId;
    @api kyc;
    @api parentId;
    @track docName;
    @track showUploadComponent = false;
    @track showOCRDetails = false;
    @track error = '';
    @track oldAadhaarValue = '';
    consent = false;
    documentIdsMap = [];
    falseValue = false;
    trueValue = true;
    isloading = false;
    disableOkButton = false;
    aadhaarNumberOnUi;
    aadhaarNumberViaToken;
    docImage = '';
    docImageBase64='';
    @track blnRestrictEdit

    @track dataValues = [];
        applicantRec;
        documentChkRecord;
        documentNumber;
        isAadhar;
        contentVersionId;
        eventdocName;
        

    label = {
        DocumentAadhaar,
        DocumentDL,
        DocumentPan,
        DocumentPassport,
        DocumentVoter
    };
    DocumentAadhaarPreview = DocumentAadhaar + 'preview';


    connectedCallback() {
        this.applicantId = this.applicant.Id;
        this.docName = DocumentAadhaar;
        this.oldAadhaarValue = this.applicant.Aadhaar_Number__c;
        this.getAadhaarNumber();
        this.checkRestrictRecord()
    }

    //4733
    checkRestrictRecord () {
        validateRecordEdit({
            compName: 'ausfb_customerDetailComponent' ,recordId: this.applicantId
            }).then(data => {
                if (data) {
                    this.blnRestrictEdit = data.blnRestrictEdit;
                    this.blnGoNext = data.blnMoveNext;
                }
            }).catch(error => {
                console.log('error is ' + JSON.stringify(error));
            })
    }

    showKYCOptions() {
        console.log('Back to KYC Subtype option selection');
        this.dispatchEvent(new CustomEvent('subkycselection'));
    }

    isApiIssue = false;

    getAadhaarNumber() {
        
        getAadhaarNumViaToken({applicationId: this.applicantId , aadhaaarToken : this.applicant.Aadhaar_Number__c })
            .then(result => {
                let responseVal = JSON.parse(result);
                if(responseVal != null && responseVal.additionalResponse != null) {
                    let aadharNumber = responseVal.additionalResponse;
                    this.aadhaarNumberViaToken = aadharNumber;
                    this.maskNumber();
                    this.getVersionFiles();
                }else if(responseVal != null){ 
                    let checklist = responseVal.checklistRecord;
                    this.showToastEvent('Error', 'API Error: ' + checklist.Name + ' Response: ' + responseVal.statusCode + '- ' + responseVal.status , 'error');
                    this.isApiIssue = true;
                    return;
                }
            })
            .catch(error => {
                this.error = error;
            });
    }

    maskNumber() {
        let aadhaarNum = this.aadhaarNumberViaToken;
        this.aadhaarNumberOnUi = aadhaarNum.replace(/\d(?=\d{4})/g, '*');
    }

 /*   unMaskNumber() {

        let aadhaarNumb = this.aadhaarNumberOnUi;
        if(aadhaarNumb.includes('*')) {      
            this.aadhaarNumberOnUi = this.aadhaarNumberViaToken;
        }
        else {
            this.maskNumber();
        }
    }  */

    

    showToastEvent(titleValue, messageValue, variantValue) {
        const event = new ShowToastEvent({
            title: titleValue,
            message: messageValue,
            variant: variantValue
        });
        this.dispatchEvent(event);
    }

    updateRecords(isOkBoolean) {
        this.isloading = true;
        this.disableOkButton = true;
        console.log('Before ... ' + JSON.stringify(this.applicant));
        //this.applicant['KYC_Status__c'] = 'Complete';
        let obj = this.applicant;
        console.log('After ... 1 ');
        console.log('After ... 2 ' );
        console.log('After ... 3 ');
        this.applicant['documentBase64'] = this.docImageBase64;
        updateOCRDate({ applicantRec: JSON.stringify(this.applicant), documentChkRecord: this.documentChkRecord, isAadhar: this.isAadhar, isOk: isOkBoolean, contentVersionId: this.contentVersionId })
            .then(result => {
                this.isloading = false;
                let parseResult = JSON.parse(result);
                if (parseResult.isSuccess) {
                    console.log(' this.documentNumber ' + this.documentNumber + '  ' + JSON.stringify(this.documentNumber));
                    this.showToastEvent('Success', 'Details Updated Succesfully!!', 'success');
                    this.showUploadComponent = false;
                    obj['Kyc_Status__c'] = 'Complete';
                    //const resultEvent = { isSuccess: true };
                    if (this.eventdocName == DocumentPan) {
                        //this.applicant.PAN__c = this.documentNumber;
                    } else if (this.eventdocName == DocumentVoter) {
                        //this.applicant.Voter_Id__c = this.documentNumber;
                    } else if (this.eventdocName == DocumentAadhaar) {
                        obj['Aadhaar_Number__c'] = this.documentNumber;
                        obj['Kyc_Status__c'] = 'Complete';
                        //this.applicant.Aadhaar_Number__c = this.documentNumber;
                        if (this.documentNumber != this.oldAadhaarValue) {
                            //this.generateAadhaarToken(this.documentNumber);
                        }
                    } else if (this.eventdocName == DocumentDL) {
                        //this.applicant.Driving_License_Id__c = this.documentNumber;
                    } else if (this.eventdocName == DocumentPassport) {
                        //this.applicant.Passport_Number__c = this.documentNumber;
                    }
                    console.log('object update ' + JSON.stringify(obj));
                    this.applicant = JSON.parse(JSON.stringify(obj)) ;
                    console.log('this.applicant update ' + JSON.stringify(this.applicant));

                    const documentHandlerEvent = new CustomEvent('updateapplicant', {
                        detail: {
                            'applicant': this.applicant
                        }
                    });
                    this.dispatchEvent(documentHandlerEvent);
                    this.showOCRDetails = false;
                    this.showUploadComponent = false;
                    this.isloading = false;
                    setTimeout(() => {
                        this.getVersionFiles();
                    }, 1000);
                } else {
                    this.showToastEvent('Error', 'We Encountered an Error while updating details!!', 'error');
                    this.showUploadComponent = false;
                    const resultEvent = { isSuccess: false };
                    const documentHandlerEvent = new CustomEvent('documentsuccess', {
                        detail: resultEvent
                    });
                    this.dispatchEvent(documentHandlerEvent);
                    this.showOCRDetails = false;
                    this.showUploadComponent = false;
                    this.isloading = false;
                }
            })
            .catch(error => {
                this.disableOkButton = false;
                this.isloading = false;
                this.error = error;
                console.log('error', error);
                alert('Error ' + JSON.stringify(error));
                this.showUploadComponent = false;
            })

           
    }

    stampKYCType(){
        const FIELDS = {};
        FIELDS[Applicant_ID_FIELD.fieldApiName] =  this.applicantId;
        FIELDS[Applicant_KYCTYPE_FIELD.fieldApiName] = 'Aadhaar - Physical Document';
        const recordInputForUpdate ={fields: FIELDS};
            updateRecord(recordInputForUpdate)
                .then(result => {
                    console.log('updateKYCType');
                })
                .catch(error => {
                    console.log(JSON.stringify(error));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });
    }

    generateAadhaarToken(strAadhaar) {
        console.log('strAadhaar' + strAadhaar);
        getTokenViaAddharNumber({
            applicantId: this.applicant.Id,
            strAadhaarNumber: strAadhaar
        })
            .then((result) => {
                console.log('Aadhaar Result' + result);
                if (result != null) {
                    //this.applicant.Aadhaar_Number__c = result;
                    //this.applicant['KYC_Status__c'] = '';
                    console.log('this.ApplicantRecordAadhhar' + this.applicant['Aadhaar_Number__c']);
                    return result;
                }
            })
            .catch((error) => {
                this.disableOkButton = false;
                console.log('Aadhaar Error' + error);
                this.error = error;
                alert('Error Token ' + JSON.stringify(error));
                return null;
            });
    }

    
    /*
    hanldeUploadClick(event) {
        this.docName = event.currentTarget.dataset.name;
        this.showUploadComponent = false;
        console.log('uploadValue' + event.currentTarget.dataset.name);
        setTimeout(() => {
            this.showUploadComponent = true;
        }, 500);
    }
    */

    okClick() {
        this.updateRecords(true);
    }

    handleSuccessUpload(event) {
        let pan = this.applicant.PAN__c;
        if (event.detail.isSuccess && event.detail.showOCRInParent) {
            console.log('Inside Final Success!!!!');
            this.dataValues = [];
            event.detail.ocrData.forEach(element => {
                if( element.key == 'documentBase64'){
                    this.docImage = 'data:image/png;base64, ' +  element.value;
                    this.docImageBase64 = element.value;
                    delete this.dataValues['documentBase64'];
                }else{
                    this.dataValues.push(element);
                }

            });
            this.applicant = JSON.parse(event.detail.applicantRec);
            this.applicant["PAN__c"] = pan;
            this.documentChkRecord = event.detail.documentChkRecord;
            this.documentNumber = event.detail.documentNumber;
            this.isAadhar = event.detail.isAadhar;
            this.contentVersionId = event.detail.contentVersionId;
            this.eventdocName = event.detail.docName;
            this.showOCRDetails = true;
            this.getVersionFiles();
        } else if (event.detail.isSuccess && event.detail.showGreenTick) {
            this.getVersionFiles();
            this.showUploadComponent = false;
        } else if (event.detail.isSuccess) {
            console.log('losAddIndNonIndClone NO OCR & Success');
            this.getVersionFiles();
            this.showUploadComponent = false;
        } else {
            this.showToastEvent('Error', event.detail.errorMessage, 'error');
            //this.showUploadComponent = false;
        }
    }

    handlePreviewClick(event) {
        console.log('PreviewCLick' + event.currentTarget.dataset.id);
        let dataValue = event.currentTarget.dataset.id?.replace('preview', '');
        let contentDocumentId;
        this.documentIdsMap.forEach(function (value, key) {
            console.log(value['key'] + " = " + value['value']);
            if (dataValue == value['key']) {
                console.log('clickedValue' + value['value']);
                contentDocumentId = value['value'];
            }
        })
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                // assigning ContentDocumentId to show the preview of file
                selectedRecordId: contentDocumentId
            }
        })
    }


    getVersionFiles() {
        getVersionFilesRec({
            recordId: this.applicant.Id
        })
            .then((result) => {
                if (result != null) {
                    console.log('resultFile' + result);
                    console.log('resultJSON' + JSON.stringify(result));
                    for (var key in result) {
                        this.documentIdsMap.push({ key: key, value: result[key] });
                        
                        let dataVlaue = '[data-id=\"' + key + 'preview' + '\"]';
                        if (this.template.querySelector(dataVlaue)) {
                            this.template.querySelector(dataVlaue).classList.remove('slds-hide');
                        }
                        
                    }
                    console.log('this.documentIdsMap' + this.documentIdsMap);
                }
            })
            .catch((error) => {
                this.error = error;
            });
    }

    /*
    handleOCRButton(event) {
        
        if (event.detail.isSuccess) {
            let dataVlaue = '[data-id=\"' + event.detail.docName + '\"]';
            if (this.isMobile) {
                this.template.querySelector(dataVlaue).classList.remove('slds-hide');
            }
        }
    }
    */

    

    hanleCancel() {
        this.showUploadComponent = false;
        this.docName = '';

    }

    updateConsent(event){
        this.consent = event.detail.consent;
         //Stamp the KYC Type on Applicant
         this.stampKYCType();
        if(this.consent){
            this.consent = true;
        }
        else {
            this.consent = false;
        }
        this.sendConsentToParent();
    }

    sendConsentToParent(){
        const consentEvent = new CustomEvent('consentchange', {
            detail: {
                'consent': this.consent,
                'apiIssue': this.isApiIssue
            }
        });
        this.dispatchEvent(consentEvent);
    }
}