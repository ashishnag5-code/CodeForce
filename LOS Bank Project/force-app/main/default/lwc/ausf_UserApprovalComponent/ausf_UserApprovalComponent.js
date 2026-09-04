import { LightningElement, track, wire, api } from 'lwc';
import approveDocumentLetters from '@salesforce/apex/UserApprovalLWCController.approveDocumentLetters';
import sendBackDocuments from '@salesforce/apex/UserApprovalLWCController.sendBackDocuments';
import getUserRelatedRecords from '@salesforce/apex/UserApprovalLWCController.getUserRelatedRecords';
import lsChargesRejectedMessage from '@salesforce/label/c.LSChargeRBMApprovalReject';
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getSpinnerImage } from 'c/customSpinner';


// SFAU-4471 - RBM Approval is required if LS Charge is not taken
const RBM_LS_CHARGE_APPROVAL_TYPE = 'LSChargeApproval';
const RBM_SYSTEM_GEN_DOCS_APPROVAL_TYPE = 'SystemGeneratedDocs';

const GENERIC_ACTIONS = [
    { label: 'Send Back', name: 'Send Back' },
    { label: 'Approve', name: 'Approve' },
    { label: 'View Letter', name: 'view' },
];
const LS_APPROVAL_ACTIONS = [
    { label: 'Send Back', name: 'Send Back' },
    { label: 'Approve', name: 'Approve' },
];

const LS_APPROVAL_COLUMNS = [ 
    {label: 'Loan Application', fieldName: 'loanRecLink', type: 'url',
        typeAttributes: {label: { fieldName: 'loanName' }, target: '_blank'}},
    { label: 'Approval Level', fieldName: 'approvalLevel'},
    { label: 'Approval Type', fieldName: 'approvalType'},
    { label: 'Remarks', fieldName: 'remarks'},
    
    {   
        type: 'action',
        initialWidth:'100px',
        typeAttributes: { rowActions: LS_APPROVAL_ACTIONS },
    },  
];

const GENERIC_COLUMNS = [ 
    {label: 'Loan Application', fieldName: 'loanRecLink', type: 'url',
        typeAttributes: {label: { fieldName: 'loanName' }, target: '_blank'}},
    { label: 'Document Name', fieldName: 'docName'},
    { label: 'Approval Level', fieldName: 'approvalLevel'},
    { label: 'Approval Type', fieldName: 'approvalType'},
    { label: 'Remarks', fieldName: 'remarks'},
    {   
        type: 'action',
        initialWidth:'100px',
        typeAttributes: { rowActions: GENERIC_ACTIONS },
    },  
];

export default class Ausf_UserApprovalComponent extends NavigationMixin(LightningElement){
    @track data=[];
    @api recordId;
    @api typeOfApproval;
    // @track columns = [];
    @track renderRemarksModal = false;
    @track remark = '';
    @track sendBackData = {};
    @api spinnerImage;
    isSending = false;
    get columns(){
        return this.isLSApproval ? LS_APPROVAL_COLUMNS : GENERIC_COLUMNS;
    }

    get isLSApproval(){
        return this.typeOfApproval === RBM_LS_CHARGE_APPROVAL_TYPE;
    }
    get title(){
        return this.isLSApproval ? 'Loan Suraksha Charge Approval' : 'System Generated Documents Approval';
    }

    async spinnerImageMethod() {
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.recordId);
        }
        console.log('%%spinner image '+this.spinnerImage);
    }

    connectedCallback(){
        this.getInitData();
    }

    getInitData(){
        getUserRelatedRecords({
            loanApplicationId : this.recordId,
            rbmApprovalType: this.typeOfApproval ?? RBM_SYSTEM_GEN_DOCS_APPROVAL_TYPE
        })
        .then(res=>{
            console.log('res '+JSON.stringify(res));
                this.data = res ?? [];
        })
        .catch(err=>{
            this.showToast('Error!','Error in loading the data','error');
            console.log('err '+JSON.stringify(err));
        })
    }

    handleRowAction(evt){
        const actionName = evt.detail.action.name;
        const row = evt.detail.row;
        //alert('action Name '+actionName)
        if(actionName == 'view'){
            this.renderPDF(row);
        }
        else if(actionName == 'Approve'){
            this.approveDocumentLetter(row);
        }
        else if(actionName == 'Send Back'){
            this.sendBackApprovalRequest(row);
        }
        
    }

    approveDocumentLetter(data){
        this.isSending = true;
        approveDocumentLetters({
            loanApplicationId : data.loanId,//this.recordId,
            letterType : data.docName,
            remarks : '',
            isTatkalSanction : data.isTatkalSanction,
            approvalType: this.typeOfApproval ?? RBM_SYSTEM_GEN_DOCS_APPROVAL_TYPE
        })
        .then(res=>{
            //alert('success');
            console.log('testyash '+JSON.stringify(res));
            if(res.isError){
                this.isSending = false;
                this.showToast('Error!',res.message,'error');

            }
            else{
                this.isSending = false;
                this.showToast('Success!',res.message,'success');
                //this.createFeedItemRecords(data.loanId);
                this.getInitData();
               
            }
            
        })
        .catch(err=>{
            this.isSending = false
            console.log('error '+JSON.stringify(err));
            this.showToast('Error!',JSON.stringify(err.body.message),'error');
            
        })
    }

    createFeedItemRecords(loanId){
        //alert('in custom feed');
        createCustomFeedRecords({
            loanId : loanId,
            body : 'Sanction Letter generated successfully for Loan Application: '
        })
        .then(res=>{

        })
        .catch(err=>{
            this.showToast('Error!','Error','error');

        })
    }

    

    renderPDF(data){
        //alert(evt.currentTarget.dataset.id)
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
            url: '/apex/'+data.docPDFName+'?applicationId='+data.loanId
        }
        });
    }

    sendBackApprovalRequest(data){
        this.renderRemarksModal = true;
        this.sendBackData = data;
    }

    rejectDetails(){
        this.isSending = true;
        console.log('test send Back data '+JSON.stringify(this.sendBackData));
        if(this.handleRemarkValidation()){
            sendBackDocuments({
                loanApplicationId : this.sendBackData.loanId,//this.recordId,
                letterType : this.sendBackData.docName,
                remarks : this.remark,
                isTatkalSanction : this.sendBackData.isTatkalSanction
            })
            .then(res=>{
                //alert('success');
                this.closeModal();
                this.isSending = false;
                this.showToast('Success!', this.isLSApproval ? lsChargesRejectedMessage : 'Sucess in Sending Back the Document','success');
                this.getInitData();
                
                
                
                
            })
            .catch(err=>{
                this.isSending = false
                console.log('error '+JSON.stringify(err));
                this.showToast('Error!',JSON.stringify(err.body.message),'error');
                this.closeModal();
                
            })

        }
        else{
            return;
        }
        


    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            // mode: 'dismissable'
            mode: variant === 'error' ? 'sticky' : 'dismissible'
        });
        this.dispatchEvent(event);
    }

    handleRemarkChange(evt){
        this.remark = evt.target.value;
    }

    closeModal(){
        //('inside');
        this.renderRemarksModal = false;
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


}