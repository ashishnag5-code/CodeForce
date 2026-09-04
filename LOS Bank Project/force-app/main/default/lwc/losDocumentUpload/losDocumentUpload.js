import { LightningElement,api } from 'lwc';
import FORM_FACTOR from '@salesforce/client/formFactor';
import { NavigationMixin } from "lightning/navigation";
import getDocumentChecklist from '@salesforce/apex/LOSDocumentUploadController.getDocumentChecklist';
import getOCRData from '@salesforce/apex/LOSDocumentUploadController.getOCRData';
import checkUploadDocumentBridgeApp from '@salesforce/apex/LOSDocumentUploadController.checkUploadDocumentBridgeApp';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FileUploadNotSupportMessage from '@salesforce/label/c.FileUploadNotSupportMessage';
import polarInterval from '@salesforce/label/c.FileUploadInterval';
import PolarMaxLimit from '@salesforce/label/c.FileUploadMaxLimit';
import cartCalloutOnSubmitMobile from '@salesforce/apex/MultipleFileUploadController.cartCalloutOnSubmitMobile';
import LightningAlert from 'lightning/alert';
import getAmount from '@salesforce/apex/CPVWaiverDocumentsController.getAmount'
import getVersionFilesByChecklist from '@salesforce/apex/LOSDocumentUploadController.getVersionFilesByChecklistId';

export default class LosDocumentUpload  extends NavigationMixin(LightningElement) {
    @api applicant = {};
    @api applicantId ='';
    @api loanId ='';
    @api collateralId ='';
    @api uploadtypename;
    @api calledFromDocManager;
    @api showUploadComponent;
    @api showInputBox;
    @api docName =''; // Example - AUWheels0001
    @api isapplicantPage =false;
    @api isdocmanager =false;
    @api hidefiledetails =false;
    @api fieldInvetigationId = '';
    @api isliveonly = false;
    @api isForm60 = false
    isMobile = false;
    showDocumentUpload =true;
    isloading= false;
    showOCRButton =false;
    showOCRButtonDocManager = false;
    documentType ='';
    docFullName = '';
    documentChecklistRecord;
    notSupportedInDesktop=true;
    ocrNeeded =false;
    docRecordId ='';
    showPasswordInput;
    galleryRestrict;
    noOfPage;
    autoMerge;
    autoZip;
    pdfDirectUpload;
    amountRequired;
    cartCalloutRequired;
    error;
    versionId ='';
    event1;
    event1Interval = 0;
    showSummaryCart = false;
    password;
    amount;
    maxFileSize;
    multipleUpload = false;
    systemGenerated = false;
    eSign = false;
    kycDocUploaded = false;
    get options() {
        return [
            { label: 'Physical Upload', value: 'Physical Upload' },
            { label: 'SmartKYC', value: 'SmartKYC' },
        ];
    }
    connectedCallback(){
        // Need to handle result if null;
        // Result in wrapper formate = success,message,body
        if(FORM_FACTOR=='Small'){
            this.isMobile = true;   
        }else{
            this.isMobile = false;
        }
        this.getDocumentChecklistMethod();
    }

    handleClickUpload(event){
        if(!this.multipleUpload && this.calledFromDocManager){
            this.checkAlreadyUploadedFile(event);
        }else{
            this.openBridegAppParent(event);
        }
    }

    checkAlreadyUploadedFile(event){
        getVersionFilesByChecklist({
            recordId : this.docRecordId
        }).then(result=>{
            if(result && result.length > 0){
                this.showToastEvent('File Upload Limit Exceed', 'Only one file can be uploaded', 'Error');
            }else{
                this.openBridegAppParent(event);
            }
        }).catch(error=>{

        })
    }
    
    getDocumentChecklistMethod(){
        this.isloading = true;
        console.log('this.docName : ' + this.applicantId + ' ' + this.loanId + ' ' + this.docName);
      getDocumentChecklist({
        applicantId : this.applicantId,
        docName : this.docName,
        loanId : this.loanId,
        fieldInvestId : this.fieldInvetigationId,
        collateralId : this.collateralId
    }).then(result => {
        console.log('result>>>>'+result);
        let parseResult=JSON.parse(result);
        if(parseResult.isSuccess && parseResult.docChkList){
            this.documentChecklistRecord = parseResult.docChkList;
            console.log('this.documentChecklistRecord'+this.documentChecklistRecord[0].Id);
            this.docRecordId =this.documentChecklistRecord[0].Id;
            this.maxFileSize = this.documentChecklistRecord[0].Document_Master__r.File_Size__c ? this.documentChecklistRecord[0].Document_Master__r.File_Size__c : 3500;
            this.pdfDirectUpload = this.documentChecklistRecord[0].Pdf_Direct_Upload__c ? this.documentChecklistRecord[0].Pdf_Direct_Upload__c : false;
            this.systemGenerated = this.documentChecklistRecord[0].Document_Master__r.System_Generated__c;
            this.eSign = this.documentChecklistRecord[0].Document_Master__r.Consider_for_E_Sign__c;
            console.log('this.documentChecklistRecord'+this.documentChecklistRecord[0].Document_Master__r.Not_Supported_In_Desktop__c);
            this.notSupportedInDesktop = this.documentChecklistRecord[0].Document_Master__r.Not_Supported_In_Desktop__c;
            if(this.notSupportedInDesktop && this.template.querySelector('[data-id="errorMessage"]')){
                //this.template.querySelector('[data-id="errorMessage"]').setError(FileUploadNotSupportMessage);
                this.template.querySelector('[data-id="errorMessage"]').innerHTML += FileUploadNotSupportMessage;
                this.template.querySelector('[data-id="errorMessage"]').classList.remove('slds-hide');
            }
            //SFAU-5652
            if(this.documentChecklistRecord[0].Document_Master__r.Document_Category__c == 'Resident Document' || this.documentChecklistRecord[0].Document_Master__r.Document_Sub_Category__c == 'KYC'){
                this.kycDocUploaded = true;
            }
            this.ocrNeeded = this.isForm60 || (this.documentChecklistRecord[0] && this.documentChecklistRecord[0].Applicant__c && (this.documentChecklistRecord[0].Applicant__r.Bureau_Score__c || this.documentChecklistRecord[0].Applicant__r.Existing_Customer__c == 'Yes')) ? false : this.documentChecklistRecord[0].Document_Master__r.OCR_Needed__c;
            this.documentType = this.documentChecklistRecord[0].Document_Master__r.OCR_Document_Type__c;
            this.showPasswordInput = this.documentChecklistRecord[0].Document_Master__r.Password_Needed__c;
            this.galleryRestrict = this.documentChecklistRecord[0].Document_Master__r.Gallery_Restrict__c;
            this.noOfPage = this.documentChecklistRecord[0].Document_Master__r.No_of_Pages__c;
            this.autoMerge = this.documentChecklistRecord[0].Document_Master__r.Automerge__c;
            this.autoZip = this.documentChecklistRecord[0].Document_Master__r.Auto_Zip__c;
            this.amountRequired = this.documentChecklistRecord[0].Document_Master__r.Amount_Required__c;
            this.cartCalloutRequired = this.documentChecklistRecord[0].Document_Master__r.Cart_Callout_Required__c;
            this.docFullName =  this.documentChecklistRecord[0].Document_Master__r.Document_Name__c;
            this.multipleUpload = this.documentChecklistRecord[0].Document_Master__r.Multiple_Upload__c;
            
            if (this.isliveonly == true || this.isliveonly == "true") {
                this.galleryRestrict = true;
            }
            if(this.ocrNeeded){
                const resultEvent = {isSuccess:true,docName:this.docName,documentId : this.docRecordId,documentType : this.documentType,applicantId : this.applicantId};
                const ocrEventHandler = new CustomEvent('ocrbutton', {
                    detail : resultEvent
                });
                this.dispatchEvent(ocrEventHandler);
            }else if(FORM_FACTOR=='Small' && this.isapplicantPage){
               this.event1 = setInterval(() => {
                this.checkForDocumentUpload(this.docRecordId);
              }, polarInterval);
            }
            if(FORM_FACTOR=='Small'){
                this.isMobile = true;
                if(this.isapplicantPage){
                    this.openBridegApp();
                }
                
            }else{
                this.isMobile = false;
            }
        }else{
            console.log('No result found.');
            console.log('Error message'+parseResult.message);
        }
        this.isloading = false;
    })
    .catch(error => {
        this.error = error;
        this.isloading = false;
    });
    console.log('Inside connectedCallback!');
}
    checkForDocumentUpload(documentRecordId){
        this.event1Interval= this.event1Interval+polarInterval;
        checkUploadDocumentBridgeApp({
            docRecordId : documentRecordId
        }).then(result => {
            let parseResult=JSON.parse(result);
            if(parseResult.isSuccess){
                if(this.cartCalloutRequired || this.amountRequired){
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
                    this.showSummaryCart = true;
                    clearTimeout(this.event1);
                }
                else{

                    const resultEvent = {isSuccess:true,showGreenTick:true,versionId:parseResult.successRecordId};
                    const documentHandlerEvent = new CustomEvent('documentsuccess', {
                        detail : resultEvent
                    });
                    this.dispatchEvent(documentHandlerEvent);
                    clearTimeout(this.event1);
                }
            }else{
                if(this.checkCounter() == false){
                    console.log('counter'+this.event1Interval);
                }else{
                    const resultEvent = {isSuccess:false};
                    const documentHandlerEvent = new CustomEvent('documentsuccess', {
                        detail : resultEvent
                    });
                    this.dispatchEvent(documentHandlerEvent);
                }
            }
            console.log('result'+result);
            this.isloading = false;
        })
        .catch(error => {
            this.error = error;
            this.isloading = false;
            console.error('CompleteError'+error);
            const resultEvent = {isSuccess:false};
            const documentHandlerEvent = new CustomEvent('documentsuccess', {
                detail : resultEvent
            });
            this.dispatchEvent(documentHandlerEvent);

        });
    }
    checkCounter() {
        if (this.event1Interval > PolarMaxLimit) {
            clearInterval(this.event1);
            this.event1Interval = 0;
            return true;
        }
        return false;
    }
    showToastEvent(titleValue, messageValue, variantValue){
        const event = new ShowToastEvent({
            title: titleValue, 
            message: messageValue,
            variant: variantValue
        });
        this.dispatchEvent(event);
    }
    renderedCallback() {
        if(!!this.fieldInvetigationId){
          //  this.getDocumentChecklistMethod();
        }

        console.log(' this.applicantId>>'+ this.applicantId+'this.docName>>'+this.docName+'this.loanId>>>'+this.loanId+'this.fieldInvetigationId>>>'+this.fieldInvetigationId);

        console.log('Inside renderedCallback!');
        console.log('Error>>>'+this.error);
        
    }
    handleChange(event) {
        this.radiovalue = event.detail.value;
    }
    handleSuccess(event){
        console.log('Inside Event Result!!!');
        if(event.detail.isSuccess && this.ocrNeeded){
            console.log('OCR NEEDED');
            //this.showOCRButton = true;
            this.versionId = event.detail.versionId;
            if(!this.isMobile){
                this.doOCR();
            }

        }else if(event.detail.isSuccess){
            console.log('NO OCR & Success');
            this.showOCRButton = false;
            this.showUploadComponent = false;
            this.versionId = event.detail.versionId;
            const resultEvent = {isSuccess:true,versionId:event.detail.versionId,base64: event.detail.base64,fileName: event.detail.fileName};
            const documentHandlerEvent = new CustomEvent('documentsuccess', {
                detail : resultEvent
            });
            this.dispatchEvent(documentHandlerEvent);
        }else{
            console.log('NO OCR & Failed');
            this.showOCRButton = false;
            const resultEvent = {isSuccess:false,base64: event.detail.base64,fileName: event.detail.fileName};
            const documentHandlerEvent = new CustomEvent('documentsuccess', {
                detail : resultEvent
            });
            this.dispatchEvent(documentHandlerEvent);
        }
    }
    doOCR(){
        this.showToastEvent('Info', 'OCR of uploaded document in progress !!', 'info');
        console.log('OCR BUtton');
        this.isloading = true;
        getOCRData({
            documentId : this.docRecordId,
            documentType : this.documentType,
            applicantId : this.applicantId
        }).then(result => {
            let parseResult=JSON.parse(result);
            if(parseResult.isSuccess && parseResult.documentNumber){
                console.log('Document Number'+parseResult.documentNumber);
                this.versionId = parseResult.successRecordId;
                const resultEvent = {isSuccess:true,documentNumber:parseResult.documentNumber,octResultMap:parseResult.ocrResultMap,applicantRecord:parseResult.applicantRecord,docChkRecord:parseResult.docChkRecord,isAadhar:parseResult.isAadhar,versionId:this.versionId};
                const documentHandlerEvent = new CustomEvent('documentsuccess', {
                    detail : resultEvent
                });
                this.dispatchEvent(documentHandlerEvent);
            }else{
                console.log('Something Went wrong.');
                console.log('Error message'+parseResult.message);
                const resultEvent = {isSuccess:false,errorMessage:parseResult.message};
                const documentHandlerEvent = new CustomEvent('documentsuccess', {
                    detail : resultEvent
                });
                this.dispatchEvent(documentHandlerEvent);
            }
            console.log('result'+result);
            this.isloading = false;
        })
        .catch(error => {
            //alert('Error ... ' + JSON.stringify(error));
            this.error = error;
            this.isloading = false;
        });
    }
    openBridegAppParent(event){
        this.openBridegApp(event);
        if(!this.ocrNeeded){
            this.event1 = setInterval(() => {
                this.checkForDocumentUpload(this.docRecordId);
              }, polarInterval);
        }

    }
    randomString(length) {
        var result = '';
        var characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        var charactersLength = characters.length;
        for ( var i = 0; i < length; i++ ) {
            result += characters.charAt(Math.floor(Math.random() * charactersLength));
        }
        return result;
    }
    openBridegApp(event){
        if(event?.currentTarget?.dataset?.id == 'openBridgeButton'){
           // this.showOCRButtonDocManager = true;
        }
        let randomString =  this.randomString(8);
        let randomStringFinal = this.docRecordId+randomString;
        let noOfPage;
        if(!!this.noOfPage){
            noOfPage = this.noOfPage;
        }else{
            noOfPage ='n';
        }
        let finalURL = "aubridge://document/" + this.docRecordId+"/"+this.galleryRestrict+"/"+noOfPage+"/"+randomStringFinal+"/"+this.autoMerge+"/"+this.autoZip+"/"+this.maxFileSize+"/"+this.pdfDirectUpload;
        //let finalURL = "aubridge://document/" + this.docRecordId+"/"+this.galleryRestrict+"/"+thirdParam;
        console.log('finalURL'+finalURL);
        // LightningAlert.open({
        //     message: finalURL,
        //     theme: 'error', // a red theme intended for error states
        //     label: 'Error!', // this is the header text
        // });
        this[NavigationMixin.Navigate]({
            type: "standard__webPage",
            attributes: {
                url : finalURL
            },
        });
    }
    @api handleOCRClickParent() {
        this.doOCR();
    }

    submitToCart(event) {
        this.isloading = true;
        cartCalloutOnSubmitMobile({recordId: this.applicantId, password: this.password, amount: this.amount, checklistRecordId: this.docRecordId}).then((data)=>{
            console.log(data)
            //this.disableDelete = true;
            //this.uploadProgress = false;
            if(data == 'Submitted'){
                if(this.isdocmanager){
                    const resultEvent = {isSuccess:true,showGreenTick:true};
                    const documentHandlerEvent = new CustomEvent('documentsuccess', {
                        detail : resultEvent
                    });
                    this.dispatchEvent(documentHandlerEvent);
                }
                else{
                    this.dispatchEvent(new CustomEvent('enablefetchdetails', {
                        detail: true , bubbles: true, composed:true
                    }))
                    this.dispatchEvent(new CustomEvent('detailsreceived', {
                        detail: {
                            isreceived: true,
                            amount: this.amount,
                        },
                        bubbles : true,
                        composed : true
                        
                    }))
                }
                this.isloading = false;
            }
            else{
                this.showToastEvent('Error', 'We Encountered an Error while processing your file', 'error');
                this.isloading =false;
            }
        }).catch((error)=>{
            this.showToastEvent('Error', 'We Encountered an Error while processing your file'+error, 'error');
            this.isloading = false;
        })
    }
    handlePasswordChange(event){
        this.password = event.detail.value;
    }
    handleChange(event){
        this.amount = event.target.value;
    }
}