import { LightningElement, api, wire, track } from 'lwc';
//import { getRecord } from 'lightning/uiRecordApi';
import checkIfEsignEnabled from '@salesforce/apex/SignDeskEsignApiController.checkIfEsignEnabled'
//const FIELDS = ['Loan_Application__c.DO_Status__c', 'Loan_Application__c.Sanction_Status__c', 'Loan_Application__c.Stage__c'];
import FORMFACTOR from '@salesforce/client/formFactor'
import getLoanApplication from '@salesforce/apex/AUSFPSDButtonsController.getLoanApplication'
import handlePSDValidation from '@salesforce/apex/AUSFPSDButtonsController.handlePSDValidation' 
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import doOpsAssignment from '@salesforce/apex/OpsAssignementUtility.doOpsAssignment'
import BRE_Icons from "@salesforce/resourceUrl/BRE_Icons";
import My_Resource from '@salesforce/resourceUrl/ausfIcons';
import handleSendBackToRO from '@salesforce/apex/AUSFPSDButtonsController.handleSendBackToRO'
import checkIfPricingApprovalRequired from '@salesforce/apex/AUSFPSDButtonsController.checkIfPricingApprovalRequired'
import BypassPSDSubmitValidations from '@salesforce/label/c.Bypass_PSD_Submit_Validations';
import { RefreshEvent } from 'lightning/refresh';
import {
    subscribe,
    unsubscribe,
    APPLICATION_SCOPE,
    MessageContext,
    createMessageContext
  } from 'lightning/messageService';
  import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c';
import { reduceErrors } from 'c/lwcutilities';

export default class Ausf_SystemGenerateDocuments extends LightningElement {
    @api recordId;
    @track loanId;
    errorMessage = '';
    @track renderButtons ={'generateButton':false,'cancelButton':false,'rejectButton':false, 
                            'generateEsignButton':false, 'submitToMaker': false}

    submitToOpsMaker   = My_Resource + '/ausfIcons/Submit-to-Ops-maker.png';
    generateDoSanction = My_Resource + '/ausfIcons/Generate-DO-sanction.png';
    cancelDoSanction   = My_Resource + '/ausfIcons/Cancel-DO-sanction.png';
    generateEsign      = My_Resource + '/ausfIcons/Generate-E-sign.png';
    sendBackIcon       = My_Resource + '/ausfIcons/10_Rejected.png';

    loanApplicationRecord = {};
    isSmallDevice=false
    isLargeDevice=false
    loadEsign=false
    breRunIcon = BRE_Icons + '/BRE_Icons/BRE-run-(button).png';
    @track isLoaded = false;
    runBre = false;
    breRunRequired = false;
    subscription = null;

    connectedCallback(){
        this.subscribeToMessageChannel()
        this.setInitialData()
    }

    @api
    setInitialData(){
        if(FORMFACTOR == 'Small'){
            this.isSmallDevice = true
            this.isLargeDevice=false
        }else{
            this.isSmallDevice = false
            this.isLargeDevice=true
        }
        this.loadEsign=true
        this.getLoanDetails()
    }

    @track renderRCLimitOnHoldError = false;

    pfMismatchedError = false;

    get showSendBackToRO(){
        return this.loanApplicationRecord && this.loanApplicationRecord.Stage__c == 'PSD';
    }
    getLoanDetails(){
        getLoanApplication({recordId: this.recordId}).then((data=>{
            console.log('data-->'+JSON.stringify(data));
            //this.loanApplicationRecord = data;
            this.loanApplicationRecord = data.loanApplication;
           
            this.loanId = this.loanApplicationRecord.Id
            if(this.loanApplicationRecord.Stage__c == 'PSD'){
                this.breRunRequired = data.isBreReRunRequired == true ? true : false;
                this.pfMismatchedError = data.isPFmismatched == true ? true : false;
                if(this.loanApplicationRecord.DO_Status__c == 'Cancelled' && this.loanApplicationRecord.Sanction_Status__c == 'Cancelled') {
                    this.renderButtons.rejectButton = true;
                }
                else {
                    this.renderButtons.rejectButton = false;
                }
                this.renderButtons.generateButton = true
                if(this.breRunRequired  == true){
                    this.renderButtons.submitToMaker = false;
                }else{
                    this.renderButtons.submitToMaker = true
                }
                
                this.renderButtons.cancelButton = true
                this.renderRCLimitOnHoldError = this.loanApplicationRecord.RC_Limit_On_Hold__c;
                this.checkifEsignFeatureEnabled()
            }
        })).catch((error=>{

        }))
    }

    handleSignDeskEsign(){
        this.template.querySelector('c-generate-esign-component').handleGenerateEsign()
    }

    handleReturnToSummary(){
        this.dispatchEvent(new CustomEvent('returntosummary'));
    }

    handleGenerateEsignClick(){
        this.dispatchEvent(new CustomEvent('generateesignclick'));
    }

    checkifEsignFeatureEnabled(){
        checkIfEsignEnabled().then((data=>{
            this.renderButtons.generateEsignButton = data;
        }))
    }

    /*@wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            
        } else if (data) {
            this.loanApplicationRecord = data;
            if(this.loanApplicationRecord.fields.Stage__c.value == 'PSD'){
                if(this.loanApplicationRecord.fields.DO_Status__c.value == 'Cancelled' && this.loanApplicationRecord.fields.Sanction_Status__c.value == 'Cancelled') {
                    this.renderButtons.rejectButton = true;
                }
                else {
                    this.renderButtons.rejectButton = false;
                }
                this.renderButtons.generateButton = true
                this.renderButtons.submitToMaker = true
                this.renderButtons.cancelButton = true
                this.checkifEsignFeatureEnabled()
            }
            
        }
    }*/

    handleDocumentGenerate(evt) {
        this.template.querySelector('c-ausf_-generate-document-button-l-w-c').renderComponent(this.loanApplicationRecord);

    }

    handleCancelDocument(evt) {
        this.template.querySelector('c-ausf_-cancel-documents-button-l-w-c').renderComponent(this.loanApplicationRecord);

    }

    handleSendBackToRO(){
            this.isLoaded = true;
        handleSendBackToRO({ loanId: this.loanId, Stage: 'DDE'}).then(data => {
            this.isLoaded = false;
            this.showMessage('Successfully Submitted to DDE', 'success');
            // refresh the standard related list
            window.location.reload()
        }).catch((error) => {
            this.isLoaded = false;
            const errorMessage = reduceErrors( error ).join?.() ?? 'We Encountered an Error while processing your file';
            this.showErrorMessage( errorMessage , 'error');
            //this.showToastEvent('Error', 'We Encountered an Error while processing your file' + error, 'error');
        })
    }

    async  handleSubmitToMaker(){
       //this.validateSubmit();
        if(this.renderRCLimitOnHoldError){
            this.showErrorMessage('Loan Application currently on hold due to RC Limit','error');
            return;
        }

        if(this.pfMismatchedError){
            this.showErrorMessage('Loan amount or Charges have been modified, Please update Payment favouring','error');
            return;
        }

        this.isLoaded=true
        let sendApplicationToPricing;
        let isError = false;
        await checkIfPricingApprovalRequired({loanId: this.loanId}).then(data => {
            sendApplicationToPricing = data;
            this.isLoaded = false
        }).catch((error) => {
            this.isLoaded = false
            let message = error.message || error.body.message;
            this.showErrorMessage( message, 'error');
            isError = true;
            return;
        })
        if(isError){
            return;
        }
        if(sendApplicationToPricing=='Failed'){
            setTimeout(() => {
                this.showErrorMessage('Application sent back to Pricing due to Change in Charges','success');
            }, 500); 
            console.log('sendApplicationToPricing --- '+sendApplicationToPricing)
            setTimeout(() => {
                window.location.reload();
                this.isLoaded=false
            }, 2000); 
            return;
        }
        this.isLoaded=false

         if( this.loanApplicationRecord?.Is_Valuation_Verification_Required__c ){ // SFAU-4091 * Valuation have received, Credit has to verify the updated vehicle details
            this.updateVehicleDetailsBasedOnValuationReceived( this.loanApplicationRecord.Id );
          }


       let response =  await this.validateSubmit();
        //SFAU-5147 || START 
        let result = await  getLoanApplication({recordId: this.recordId})
        let loanRecord = result.loanApplication;
        if(loanRecord !=null){
            if(loanRecord.isLoanAmtChanged__c){
             this.showMessage('Loan amount modified please refresh the charges', 'ERROR');
             response = false;
            }else if(result.isSizeIssue){ // SFAU-5841 - Photo Issue [Kunal]
                this.showMessage('Pls crop the live photo, signature image and upload again', 'ERROR');
                response = false;
            }
        }
        //END
       //response = true;
       response = BypassPSDSubmitValidations.toLowerCase() === "true" ? true : response ;
       console.log('responseinsub-->' +response);
       if(response == true){
            console.log('inside');
            const fields = { Id: this.loanId, Stage__c: 'Ops Maker' };
            const recordInput = { fields };
            console.log('inside');
            updateRecord(recordInput).then(() => {
                doOpsAssignment({ objLoanApplication: fields , strAssignmentType : 'Ops - Disbursement' , strStage : 'Ops Maker'}).then(data => {
                    this.isLoaded = false
                    //this.checkButtonVisibility('Ops Author');
                    this.showMessage('Successfully Submitted to Maker', 'success')
                }).catch((error) => {
                    this.showToastEvent('Error', 'We Encountered an Error while processing your file' + error, 'error');
                })
            });
        }
    }

     validateSubmit() {
      this.isLoaded = true;
        return new Promise((resolve, reject) => {
            let response = false;
            handlePSDValidation({  loanId: this.loanId })
            .then(data => {
               console.log('data-->' +JSON.stringify(data));
                if (data == 'Success') {
                    response = true;
                    this.errorMessage = '';
                }else{
                    let messaage = data.replace(/\\n/g, '\n').replace(/\\r/g, '');
                    this.showErrorMessage(messaage, 'error');
                    this.errorMessage = messaage;
                   // response = true;
                }
                this.isLoaded = false;
                resolve(response);
            })
            .catch(error => {
                this.isLoaded = false;
                reject('');
                //this.showErrorMessage(JSON.stringify(error), 'error');
            });
        })
       
    }


        
          
           
    
   /* validateSubmit() {
        //Validation
        this.isLoaded = true;
        handlePSDValidation({
                loanId: this.loanId
            })
            .then((data => {
                console.log('data-->' + data);
                if (data == 'Success') {
                    const fields = {
                        Id: this.loanId,
                        Stage__c: 'Ops Maker'
                    };
                    const recordInput = {
                        fields
                    };
                    updateRecord(recordInput).then(() => {
                        doOpsAssignment({
                            objLoanApplication: fields,
                            strAssignmentType: 'Ops - Disbursement'
                        }).then(data => {
                            this.isLoading = false
                            //this.checkButtonVisibility('Ops Author');
                            this.showMessage('Successfully Submitted to Maker', 'success')
                            this.isLoaded = false;
                        }).catch((error) => {
                            this.showToastEvent('Error', 'We Encountered an Error while processing your file' + error, 'error');
                            this.isLoaded = false;
                        })
                    });
                } else {
                    this.isLoaded = false;
                    this.showErrorMessage(data, 'error');
                }
            })).catch((error => {
                console.log('error-->' + JSON.stringify(error));
                this.showErrorMessage(JSON.stringify(error), 'error');
                this.isLoaded = false;
            }))


    }*/
    showMessage(message, variant) {
        const event = new ShowToastEvent({
            title: '',
            variant: variant,
            mode: 'dismissable',
            message: message
        });
        this.dispatchEvent(event);
    }

    showErrorMessage(message, variant) {
        const event = new ShowToastEvent({
            title: '',
            variant: variant,
            mode: 'sticky',
            message: message
        });
        this.dispatchEvent(event);
    }
    
    /*
    handleRejectDocument(evt) {
        this.template.querySelector('c-ausf_reject-document-button-l-w-c').renderComponent(this.loanApplicationRecord);
    }*/

    handleRefresh(evt) {
        if(evt.detail) {
            window.location.reload();
        }
    }

    handleBre(){
        this.runBre = true;
    }
    async handleModelActions(){
        this.runBre = false;
    }


//    @wire(MessageContext)
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
          this.setInitialData()
        }
      }
    
      unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
      }
    
      disconnectedCallback() {
          this.unsubscribeToMessageChannel();
      }
    
}