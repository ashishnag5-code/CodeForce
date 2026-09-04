import { LightningElement, api, track, wire } from 'lwc';
import approveCancellationRecordsAssigned from '@salesforce/apex/SystemGenerateDocumentsController.approveCancellationRecordsAssigned';
import approveSystemGeneratedDocuments from '@salesforce/apex/SystemGenerateDocumentsController.approveSystemGeneratedDocuments';
import getDocumentApprovalRecords from '@salesforce/apex/SystemGenerateDocumentsController.getDocumentApprovalRecords';
import sendBackDocuments from '@salesforce/apex/UserApprovalLWCController.sendBackDocuments';
import approveDocumentLetters from '@salesforce/apex/UserApprovalLWCController.approveDocumentLetters';
import updatePaymentFavouringApprovals from '@salesforce/apex/SystemGenerateDocumentsController.updatePaymentFavouringApprovals';
import lsChargesRejectedMessage from '@salesforce/label/c.LSChargeRBMApprovalReject';
import PaymentFavouringApprovalRejectMessage from '@salesforce/label/c.PaymentFavouringApprovalReject';
import PaymentFavouringApprovalApproved from '@salesforce/label/c.PaymentFavouringApprovalApproved';


import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getSpinnerImage } from 'c/customSpinner';
import { NavigationMixin } from "lightning/navigation";
import { getRecord } from 'lightning/uiRecordApi';
import BRE_Icons from "@salesforce/resourceUrl/BRE_Icons";
import My_Resource from '@salesforce/resourceUrl/ausfIcons';
import FORMFACTOR from '@salesforce/client/formFactor'


const FIELDS=['Loan_Application__c.Stage__c'];
// SFAU-4471 - RBM Approval is required if LS Charge is not taken
const RBM_LS_CHARGE_APPROVAL_TYPE = 'LSChargeApproval';
const PAYMENT_FAVOURING_APPROVAL_TYPE = 'OEMApproval';
const RBM_SYSTEM_GEN_DOCS_APPROVAL_TYPE = 'SystemGeneratedDocs';

export default class Ausf_CreditApproveLWC extends NavigationMixin(LightningElement)  {
    @api recordId;
    @api spinnerImage;
    isSending = false;
    selectedLetterCount = 0;
    generatedLetterSuccessfully = [];
    @track renderViewSanctionCancelButton = false;
    @track renderDOCancelButton = false;
    @track  isCreditStage = false;
    @track renderSanctionButton = false;
    @track renderDOButton = false;
    generateDoSanction = My_Resource + '/ausfIcons/Generate-DO-sanction.png';
    cancelDoSanction   = My_Resource + '/ausfIcons/Cancel-DO-sanction.png';
    chargeApprovalIcon = My_Resource + '/ausfIcons/RBM-Approval-icon.png';
    @track approvalRecordsList = [];

    @track renderButtons ={'generateSanction':false,'cancelSanctionButton':false,'cancelDOButton':false,'generateDO':false,'OEMApproval':false}
    @track selectedApprovalType = {};
    @track renderApprovalModal = false;
	@track isLargeDevice = true;

    get allowDocumentPreview(){
        return !!this.selectedApprovalType?.documentName;
    }
    get typeOfApproval(){
        return this.selectedApprovalType?.documentName ? RBM_SYSTEM_GEN_DOCS_APPROVAL_TYPE : PAYMENT_FAVOURING_APPROVAL_TYPE;
    }

    get modelHeader(){
        return `Approve ${this.selectedApprovalType?.documentName ? this.selectedApprovalType?.documentName : 'Payment Favouring Approval'}`;
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            console.log('error '+JSON.stringify(error))

        } else if (data) {
            //alert(data.fields.Stage__c.value)
            this.isCreditStage = (data.fields.hasOwnProperty('Stage__c'))?data.fields.Stage__c.value=='Credit':false;
        }
    }

    async spinnerImageMethod() {
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.recordId);
        }
    }
    connectedCallback(){
        this.spinnerImageMethod();
        this.getUserAssociatedApprovals();
		this.isLargeDevice = (FORMFACTOR != 'Small')

    }

    getUserAssociatedApprovals(){
        this.isSending = true;
        getDocumentApprovalRecords({loanId : this.recordId})
        .then(res=>{
            let docResp = res;
            let approvalRecordsListLocal = [];
            docResp.forEach(document=>{
                if(document.documentName == 'Sanction Letter'){
                    this.renderButtons.generateSanction = true;
                }
                if(document.documentName == 'Sanction Cancelled letter'){
                    this.renderButtons.cancelSanctionButton = true;
                }
                if(document.documentName == 'DO Cancelled letter'){
                    this.renderButtons.cancelDOButton = true;
                }
                if(document.documentName == 'Delivery Order'){
                    this.renderButtons.generateDO = true;
                }
                if(document.recordApprovalType == 'OEMApproval'){
                    this.renderButtons.OEMApproval = true;
                }
                approvalRecordsListLocal.push(document);
            })
            this.approvalRecordsList = approvalRecordsListLocal;
            this.isSending = false;
        })
        .catch(err=>{
            console.log('err'+JSON.stringify(err));
            this.isSending=false;
        })
    }

    openApprovalModal(evt){
        this.renderApprovalModal = true;
        let approvalRecords = this.approvalRecordsList;
        approvalRecords.forEach(record=>{
            if(record.documentName == evt.currentTarget.dataset.id){
                this.selectedApprovalType = record;

            } else if( !record.documentName && evt.currentTarget.dataset.id === PAYMENT_FAVOURING_APPROVAL_TYPE ){
                this.selectedApprovalType = record;
            }
        })
    }

    closeModal(){
        this.renderApprovalModal = false;
        this.selectedApprovalType = {};
    }

    handlePreviewClick(){
        let docPDFPageName = this.selectedApprovalType.pdfPageName;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
            url: '/apex/'+docPDFPageName+'?applicationId='+this.recordId
        }
        });
    }

    handleRemarkChange(evt){
        this.selectedApprovalType.remarks = evt.detail.value;
    }

    handleRejectClick(){
        this.isSending = true;
        console.log('test send Back data '+JSON.stringify(this.selectedApprovalType));
        if(this.handleRemarkValidation()){
            if(this.typeOfApproval === PAYMENT_FAVOURING_APPROVAL_TYPE){
                updatePaymentFavouringApprovals({
                    loanId : this.recordId,
                    status : 'Rejected',
                    remarks : this.selectedApprovalType.remarks
                })
                .then(res=>{
                    this.closeModal();
                    this.isSending = false;
                    this.showToast('Success!', PaymentFavouringApprovalRejectMessage ,'success');
                    this.navigateToRecordPage();
                })
                .catch(err=>{
                    this.isSending = false
                    this.showToast('Error!',JSON.stringify(err.body.message),'error');
                    this.closeModal();
                    this.navigateToRecordPage();
                })
            }
            else{
                sendBackDocuments({
                    loanApplicationId : this.recordId,//this.recordId,
                    letterType : this.selectedApprovalType.documentName,
                    remarks : this.selectedApprovalType.remarks,
                    isTatkalSanction : this.selectedApprovalType.isTatkalSanction,
                    approvalType: this.typeOfApproval
                })
                .then(res=>{
                    this.closeModal();
                    this.isSending = false;
                    this.showToast('Success!', this.typeOfApproval === PAYMENT_FAVOURING_APPROVAL_TYPE ? PaymentFavouringApprovalRejectMessage : 'Success in Sending Back the Document','success');
                    this.navigateToRecordPage();
                })
                .catch(err=>{
                    this.isSending = false
                    this.showToast('Error!',JSON.stringify(err.body.message),'error');
                    this.closeModal();
                    this.navigateToRecordPage();
                })
            }
        }
        else{
            this.isSending = false;
            return;
        }
    }

    handleRemarkValidation(){
        let isValid = true;
        let reason = this.template.querySelector("lightning-textarea");
        if(!reason.value) {
            isValid = false;
            reason.setCustomValidity("Please provide valid remarks to proceed");
        } else {
            isValid = true;
            reason.setCustomValidity(""); // clear previous value
        }
        reason.reportValidity();
        return isValid;
    }

    handleApproveClick(){
        this.isSending = true;
        if(this.typeOfApproval === PAYMENT_FAVOURING_APPROVAL_TYPE){
            updatePaymentFavouringApprovals({
                loanId : this.recordId,
                status : 'Approved',
                remarks : this.selectedApprovalType.remarks
            })
            .then(res=>{
                this.closeModal();
                this.isSending = false;
                this.showToast('Success!',PaymentFavouringApprovalApproved,'success');
                this.navigateToRecordPage();
            })
            .catch(err=>{
                this.isSending = false
                this.showToast('Error!',JSON.stringify(err.body.message),'error');
                this.closeModal();
                this.navigateToRecordPage();
            })
        }
        else{
            approveDocumentLetters({
                loanApplicationId : this.recordId,
                letterType : this.selectedApprovalType.documentName,
                remarks : '',
                isTatkalSanction : this.selectedApprovalType.isTatkalSanction,
                approvalType: this.selectedApprovalType?.documentName ? RBM_SYSTEM_GEN_DOCS_APPROVAL_TYPE : PAYMENT_FAVOURING_APPROVAL_TYPE
            })
            .then(res=>{
                if(res.isError){
                    this.isSending = false;
                    this.showToast('Error!',res.message,'error');
                    this.closeModal();
                    this.navigateToRecordPage();

                }
                else{
                    this.isSending = false;
                    this.showToast('Success!',res.message,'success');
                    this.closeModal();
                    this.navigateToRecordPage();

                }

            })
            .catch(err=>{
                this.isSending = false
                this.showToast('Error!',JSON.stringify(err.body.message),'error');
                this.closeModal();
                this.navigateToRecordPage();

            })
        }
    }

	navigateToRecordPage() {
		this[NavigationMixin.Navigate]({
		  type: "standard__recordPage",
		  attributes: {
			objectApiName: "Loan_Application__c",
			actionName: "view",
			recordId: this.recordId
		  }
		});
	  }

    // renderRemarksSection = false;

    // handleCancelLetterApproval(){
    //     //this.renderRemarksSection = true;


    //     if(this.renderViewSanctionCancelButton){
    //         this.selectedLetterCount++;
    //         this.handleCancelLetterApprovalHelper('Sanction Cancelled letter')

    //     }
    //     if(this.renderDOCancelButton){
    //         this.selectedLetterCount++;
    //         this.handleCancelLetterApprovalHelper('DO Cancelled letter')
    //     }
    //     if(!this.renderDOCancelButton && !this.renderViewSanctionCancelButton){
    //         this.showToast('Error','No Approval Records associated with the User','error');
    //     }
    // }

    // handleCancelLetterApprovalHelper(letterType){
    //     this.isSending = true;
    //     approveCancellationRecordsAssigned({
    //         loanApplicationId : this.recordId,
    //         letterType : letterType
    //     })
    //     .then(res=>{
    //         this.isSending =false;
    //         console.log('resp '+JSON.stringify(res));
    //         if(res.isError){
    //             this.showToast('Error!',res.message,'error');

    //         }
    //         else{
    //             //this.showToast('Success!',res.message,'success');
    //             this.generatedLetterSuccessfully.push(res);
    //             this.validateAllLettersSent();
    //         }
    //     })
    //     .catch(err=>{
    //         console.log('error '+JSON.stringify(err));
    //         //this.showToast('Error!',JSON.stringify(err.body.message),'error');
    //         this.isSending=false;
    //     })
    // }

    // approveSystemGeneratedDocuments(evt){
    //     if(this.renderSanctionButton){
    //         this.selectedLetterCount++;
    //         this.systemDocsApprovalHelper('Sanction Letter')
    //     }
    //     if(this.renderDOButton){
    //         this.selectedLetterCount++;
    //         this.systemDocsApprovalHelper('Delivery Order')
    //     }


    // }

    // systemDocsApprovalHelper(letterType){
    //     this.isSending = true;
    //     approveSystemGeneratedDocuments({
    //         loanApplicationId : this.recordId,
    //         letterType : letterType
    //     })
    //     .then(res=>{
    //         this.isSending =false;
    //         console.log('resp '+JSON.stringify(res));
    //         if(res.isError){
    //             this.showToast('Error!',res.message,'error');

    //         }
    //         else{
    //             //this.showToast('Success!',res.message,'success');
    //             this.generatedLetterSuccessfully.push(res);
    //             this.validateAllLettersSent();
    //         }
    //     })
    //     .catch(err=>{
    //         console.log('error '+JSON.stringify(err));
    //         this.showToast('Error!',JSON.stringify(err.body.message),'error');
    //         this.isSending=false;
    //     })

    // }

    // validateAllLettersSent() {
    //     if(!this.generatedLetterSuccessfully) {
    //         return
    //     }
    //     if(this.generatedLetterSuccessfully.length == this.selectedLetterCount) {
    //         this.isSending = false;
    //         this.showToast('SUCCESS','Letters Generated Successfully','success');
    //     }

    // }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
}