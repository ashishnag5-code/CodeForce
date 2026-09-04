import { LightningElement,api, track } from 'lwc';
import getFinancialStatus from '@salesforce/apex/financeController.getFinancialStatus';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRecordTypeOfApplication from '@salesforce/apex/financeController.getRecordTypeOfApplication';
import getWorkingFinancialDetails from '@salesforce/apex/FinancialViewTemplateR2Controller.getWorkingFinancialDetails';
import isPanMandatory from '@salesforce/apex/FinancialViewTemplateR2Controller.isPanMandatory';
import { toastWithMessage} from 'c/lwcutilities';

// Porting DL logic from LosAddIndNonInd file
import FORM_FACTOR from '@salesforce/client/formFactor';
import DocumentDL from '@salesforce/label/c.DocumentDL';
const FIELDS_TO_UPPER_CASE = ['driving_license_id__c'];
import updateOCRData from '@salesforce/apex/LOSDocumentUploadController.updateOCRData';
// Porting DL logic from LosAddIndNonInd file

// Checking if already DL exist for the current application
import checkIfDLNeedsTobeFilledForNewCE from '@salesforce/apex/financeController.checkIfDLNeedsTobeFilledForNewCE';

const SMALL_FORM_FACTOR_LITERAL = 'Small';
const LARGE_FORM_FACTOR_LITERAL = 'Large';
// Checking if already DL exist for the current application

// Updating DL number if only number is entered
import { updateRecord } from "lightning/uiRecordApi";
// Updating DL number if only number is entered

import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
    createMessageContext
  } from 'lightning/messageService';
import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c';

export default class IncomeDetailsParent extends LightningElement {
    @api recordId;
    errorOnChild;
    isLoading;
    @api spinnerImage;
    @api insideRecordPage
    @track displayFinancialComponent=false
    isworkingFinancial=false;

    // Flag to open pop to fill DL for new CE 
    applicantId;
    docCheckId;
    counterPopUp = 0;
    messageDisplay = true;
    isMobile = false;
    showDLModal = false;
    showUploadComponent = false;
    trueValue = true;
    falseValue = false;
    modelNeeded = true;
    // Porting DL logic from LosAddIndNonInd file
    label = {
        DocumentDL,
    };
    docName = DocumentDL;
    docImageBase64='';
    documentNumber;
    applicantRec = {};
    isAadhar;
    contentVersionId;
    eventdocName;
    showOCRDetails;
    drivingLicense; //R2-2628
    // Porting DL logic from LosAddIndNonInd file

    // Flag to open pop to fill DL for new CE 
    
    subscription = null;

    @api nextHandler() {
        this.nextHandlerHelperAsyncAwaitModel();
    }

    handleSuccess(event){
        const Obj = {};
        //Obj.applicantRecord = this.applicantIdInput;
        this.errorOnChild = '';
        Obj.errorOnChild = this.errorOnChild;
        Obj.next = this.errorOnChild == '' ? true : false;
        console.log('Obj', Obj);
        this.dispatchEvent(new CustomEvent('next', {
            detail: Obj
        }));   
    }

    // Added to have couple of server calls sequentially  
    // Check for financial data previously developed
    // Then check if DL is mandatory for new CE vehicles
    async nextHandlerHelperAsyncAwaitModel(){


        if(this.template.querySelector('c-financial-information').getLoanRecordType() == 'Commercial_Vehicle' || this.template.querySelector('c-financial-information').getLoanRecordType() == 'Construction_Equipment'){
            this.isworkingFinancial =  await getWorkingFinancialDetails({loanId: this.recordId})  
            if(!this.isworkingFinancial){
                toastWithMessage(this, "", "Error", "Please ensure that at least one individual is designated as a working member");  
                return;   
            }
             let error= await isPanMandatory({loanId: this.recordId})
            console.log('errorMsg-->' +this.errorMsg);
            if(error.length >0){
                toastWithMessage(this, "", "Error", error[0]);  
                return;   
            }
           }
       
        try{
            

            let recordTypeOfApplication = await getRecordTypeOfApplication({loanId: this.recordId})
           
            if(recordTypeOfApplication == 'Tractor'){
                this.template.querySelector('c-financial-information').nextHandlerChild('Tractor')
            }
            else{

                
                const Obj = {};
    
                let data = await getFinancialStatus({loanId : this.recordId});
                
                console.log('mandatoryDDEParameter-->' +data.mandatoryDDEParameter);
                
               // if(!this.template.querySelector('c-financial-information').checkCustomerGradeValidation()) return;
                
                if(data.resultCheck == true){
                    if(data.mandatoryDDEParameter == true){
                        this.showErrorMessage('Some of the Required fields are missing please edit to proceed', 'error');
                        return;
                    }else{
                        //Obj.applicantRecord = this.applicantIdInput;
                        this.errorOnChild = '';
                        Obj.errorOnChild = this.errorOnChild;
                        Obj.next = this.errorOnChild == '' ? true : false;
                        console.log('Obj', Obj);
                        
                    }
                    
                }else{
                    this.showErrorMessage('Details are missing for '+data.validationNames, 'error');
                    
                    //Obj.applicantRecord = this.applicantIdInput;
                    this.errorOnChild = 'Please fill the Details for the Applicant';
                    Obj.errorOnChild = '';
                    Obj.next = this.errorOnChild == '' ? true : false;
                    console.log('Obj', Obj);
                    
                }
                try{
                    this.docCheckId = await checkIfDLNeedsTobeFilledForNewCE({applicantId : this.applicantId});

                    if(this.applicantId !== null  && this.counterPopUp === 0 && this.docCheckId != null){
                        this.showDLModal = true;
                        setTimeout(()=>this.template.querySelector('.slds-modal').focus());
                        return;
                    }
                }
                catch(e){
                    console.log('Something wrong in filling DL values for new CE ' +e);
                    toastWithMessage(this, 'Error!', 'error', 'Something wrong in filling DL values for CE!');
                }
                this.dispatchEvent(new CustomEvent('next', {
                    detail: Obj
                }));
            }

            
        }
        catch(error){
            console.log('error in financialStatus' +error);
        }
    }



    // Check if loan has product eligible for DL check and input 
    handleProductEligbleForDLCheck = (event) => {
        this.applicantId = event.detail.mainApplicantId;
    }
    // Check if loan has product eligible for DL check and input

    showErrorMessage(message, variant) {
        const event = new ShowToastEvent({
            title: '',
            variant: variant,
            mode: 'sticky',
            message: message
        });
        this.dispatchEvent(event);
    }

    
    // add new CE DL input Modal controls
    handleCancelDLModal = () => {
        this.showDLModal = false;
        this.counterPopUp++;
        this.nextHandlerHelperAsyncAwaitModel();
    }

    handleCancelDLModalWithFiringNextAction(){
        this.showDLModal = false;
    }

    // add new CE DL input Modal controls


    // Porting DL logic from LosAddIndNonInd file

    hanldeOcrClick(event) {
        console.log('clickButton' + event.currentTarget.dataset.name);
        //alert('OCRBUTTONCLICK'+event.currentTarget.dataset.name);
        this.template.querySelector("c-los-generic-document-upload").handleOCRClickParent();
    }

    connectedCallback(){

        if (FORM_FACTOR == 'Small') {
            this.isMobile = true;
            this.modelNeeded = false;
        } else {
            this.isMobile = false;
        }
        this.displayFinancialComponent=true
        this.subscribeToMessageChannel()
        
    }

    hanleCancel() {
        this.showUploadComponent = false;
    }


    handleValuChange(event) {
        let inputValue = event.target.value;
        let fldName = event.target.name;
        if (FIELDS_TO_UPPER_CASE.includes(fldName?.toLowerCase())) {
            if (inputValue)
                inputValue = inputValue.toUpperCase();
        }
        this.drivingLicense = inputValue; //R2-2628
        this.isInputValid();
    }


    isInputValid() {
        let inputField = this.template.querySelector(".validate");
        inputField.reportValidity();
        return inputField.checkValidity();
        
    }

    handleOpenDLForm = () => {
        this.messageDisplay = false;
        
    }

    hanldeUploadClick = () => {

        this.showUploadComponent = true;
        setTimeout(() => {
            if(FORM_FACTOR === SMALL_FORM_FACTOR_LITERAL)
                this.template.querySelector(".losGenericCmp").style.display='none';
        });
    }

    handleSuccessDocUpload(event) {
        if (event.detail.isSuccess && event.detail.showOCRInParent) {
            console.log('Inside Final Success!!!!');
            this.dataValues = [];
            event.detail.ocrData.forEach(element => {
                if( element.key == 'documentBase64'){
                    if (element.value !== undefined && element.value !== null) {
                        this.docImage = 'data:image/png;base64,' +  element.value;
                    }
                    this.docImageBase64 = element.value;
                    delete this.dataValues['documentBase64'];
                } else if (element.key == 'Aadhar Number') {
                    let maskedValue = element.value;
                    maskedValue = maskedValue === undefined || maskedValue === null ? '' : ('********' + maskedValue.substring(maskedValue.length - 4));
                    this.dataValues.push({key: element.key, value: maskedValue});
                } else {
                    this.dataValues.push(element);
                }

            });
           
            this.applicantRec = event.detail.applicantRec;
            this.documentChkRecord = event.detail.documentChkRecord;
            this.documentNumber = event.detail.documentNumber;
            this.isAadhar = event.detail.isAadhar;
            this.contentVersionId = event.detail.contentVersionId;
            this.eventdocName = event.detail.docName;
            this.showOCRDetails = true;
            this.template.querySelector(".validate").value = this.documentNumber;
        } else if (event.detail.isSuccess && event.detail.showGreenTick) {
            this.hanleCancel();
            
        } else if (event.detail.isSuccess) {
            console.log('losAddIndNonIndClone NO OCR & Success');
            this.hanleCancel();
            
        } else {
            this.showToastEvent('Error', event.detail.errorMessage, 'error');
            //this.showUploadComponent = false;
        }
        

    }

    handleOCRButton(event) {
        if (event.detail.isSuccess) {
            let dataVlaue = '[data-id=\"' + event.detail.docName + '\"]';
            if (this.isMobile) {
                this.template.querySelector(dataVlaue).classList.remove('slds-hide');
            }
        }
    }

    updateRecords(){
        
        if(!this.isInputValid()){
            return;
        }

        this.isLoading= true;

        if(this.applicantRec && this.applicantRec.Id){
            try{
                this.applicantRec = JSON.parse(this.applicantRec);
                this.applicantRec['documentBase64'] = this.docImageBase64;
                let isOkBoolean = true;
                updateOCRData({ applicantRec: JSON.stringify(this.applicantRec), documentChkRecord: this.documentChkRecord,isAadhar: this.isAadhar,isOk :isOkBoolean,contentVersionId :this.contentVersionId })
                .then(result => {
                    this.isLoading= false;
                    let parseResult=JSON.parse(result);
                    if(parseResult.isSuccess){
                        toastWithMessage(this, 'Success!', 'success', 'Details Updated Successfully!');
                        
                    }else{
                        toastWithMessage(this, 'Error!', 'error', 'We Encountered an Error while updating details!');
                    }
                    this.hanleCancel();
                    this.handleCancelDLModal();
                })
                .catch(error => {
                    this.error = error;
                    console.log('error', error);
                    
                })
            }
            catch(e){
                console.log('error', e);
            }
        }
        else{
            this.documentNumber = this.template.querySelector('.validate').value;
            const fields = {};
            fields [ 'Id' ] = this.docCheckId;
            fields [ 'Document_Number__c'] = this.documentNumber;
            const recordInput = { fields };
            updateRecord(recordInput)
            .then(() => {
                const fieldsApplicant = {};
                fieldsApplicant [ 'Id' ] = this.applicantId;
                fieldsApplicant [ 'Driving_License_Id__c'] = this.documentNumber;
                const recordInputApplicant = { fields : fieldsApplicant };
                updateRecord(recordInputApplicant)
                .then(() => {
                    toastWithMessage(this, 'Success!', 'success', 'Details Updated Successfully!');
                    this.hanleCancel();
                    this.handleCancelDLModal();
                })
                .catch(e => {
                    console.log('Error while updating applicant DL no ' + e);
                    toastWithMessage(this, 'Error!', 'error', 'We Encountered an Error while updating DL no on applicant!');
                });
                
              })
              .catch((error) => {
                console.log('Error while updating document number directly ' + error);
                toastWithMessage(this, 'Error!', 'error', 'We Encountered an Error while updating details!');
              });
        }
        this.isLoading= false;
    }
 
    // Porting DL logic from LosAddIndNonInd file
    
    messageContext = createMessageContext();
    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                pageRefreshOnMaterialFieldChange,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE }
            );
        }
    }
    
    handleMessage(message){
        if(message.refreshPage=='Yes'){
            this.displayFinancialComponent=false
            setTimeout(() => {
                this.connectedCallback()
            }, 300);
        }
    }  
    
    unsubscribeToMessageChannel(){
        unsubscribe(this.subscription);
        this.subscription = null;
    }
    
    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }
}