import { LightningElement, api, track } from 'lwc';
import getPaymentFavourings from '@salesforce/apex/LoanDisbursementOpsController.getPaymentFavourings'
import doNEFTPayment from '@salesforce/apex/PaymentNEFTAPIController.doNEFTPayment'
import doIMPSPayment from '@salesforce/apex/PaymentIMPSAPIController.doIMPSPayment'
import doRTGSPayment from '@salesforce/apex/PaymentRTGSAPIController.doRTGSPayment'
import doIFTPayment from '@salesforce/apex/PaymentIFTAPIController.doIFTPayment'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getSpinnerImage } from 'c/customSpinner';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import updatePaymentParent from '@salesforce/apex/LoanDisbursementOpsController.updatePaymentParent'
import updatePaymentFavouringAtOpsAuth from '@salesforce/apex/RecordAccessExceptionHandler.updatePaymentFavouringAtOpsAuth'
import updatePaymentRecord from '@salesforce/apex/LoanDisbursementOpsController.updatePaymentRecord'
import sendPaymentNotification from '@salesforce/apex/LoanDisbursementOpsController.sendPaymentNotification'
import checkIfPaymentAlreadyDisbursed from '@salesforce/apex/LoanDisbursementOpsController.checkIfPaymentAlreadyDisbursed'
import checkIfPaymentAlreadyReleased from '@salesforce/apex/Utility.checkIfPaymentAlreadyReleased'


import FORM_FACTOR from '@salesforce/client/formFactor';


const FAILED_STATUS = 'Failed';
const PENDING_STATUS = 'Pending';
const COMPLETE_STATUS = 'Complete';
const COMPLETED_DISBURSEMENT_STAGE = 'Do Disbursement'
const PAYMENT_MODE_TA = 'TA'
const NEFT_API = 'NEFT'
const IMPS_API = 'IMPS'
const IFT_API = 'IFT'
const RTGS_API = 'RTGS'
// SFAU-5676
const POOL_DISBURSEMENT_PM = [RTGS_API, 'Transfer', NEFT_API];

export default class PaymentDetailsOpsAuthor extends LightningElement {

    @api parentId
    @api displayValidateButton
    @api displayReleaseButton
    @api loanAppId
    @api totalCharges
    @api disbursementAmount
    @api completedStage
    @api userType
    @track paymentFavouringList
    paymentFavouringMap = new Map;
    displayValidatePaymentsSection = false
    paymentRecord;
    spinnerImage;
    isLoading = false
    paymentsReleasedList =[]
    isMobile = false

    async connectedCallback() {
        if (this.spinnerImage == undefined) {
            this.spinnerImage = await getSpinnerImage(this.loanAppId);
        }
        this.isLoading = true
        this.getPaymentFavouringsRecords()
        this.isMobile = (FORM_FACTOR == 'Small');
        
    }

    @api
    getPaymentFavouringsRecords(allowCheque){
        let isSuccess=true
        this.paymentFavouringList=[]
        this.paymentFavouringMap = new Map()
        this.paymentsReleasedList = []
        getPaymentFavourings({ recordId: this.parentId }).then((data => {
            this.isLoading = false
            this.paymentFavouringList = data
            data.forEach(input => {
                this.paymentFavouringMap.set(input.Id, input);
                let doRelease = ( allowCheque || (!allowCheque && input.Payment_Mode__c != 'Cheque') ) && (input.Payment_Favouring_Status__c == PENDING_STATUS);
                if(doRelease){
                    this.paymentsReleasedList.push(input.Id)
                }
                /*if(input.is_Payment_Favouring_Modified__c && !input.is_Validated_By_Author__c){
                    isSuccess=false
                }*/
            })

            /*if(isSuccess){
                this.dispatchEvent(new CustomEvent('enabledodisburse',{
                    detail: {
                        enableDoDisburseButton: false
                    }
                }));
            }*/
            
            const evt = setTimeout(() => {
                this.handleEnablePaymentReleaseButton();
            }, 1000);
            /*if (this.completedStage == COMPLETED_DISBURSEMENT_STAGE) {
                const evt = setTimeout(() => {
                    this.handleEnablePaymentReleaseButton();
                  }, 1000);
                
            }else{
                this.isLoading = false
            }*/
        })).catch((error=>{
            this.isLoading = false
        }))
    }

    @api
    handleEnablePaymentReleaseButton() {
         /* Updated by Kunal : SFAU-5824 - Start  */
    //    const result = await checkIfPaymentAlreadyReleased({paymentIds: this.paymentsReleasedList});
        checkIfPaymentAlreadyReleased({ paymentIds: this.paymentsReleasedList })
        .then(result => {
            this.isLoading = false
            if(this.userType!='Group'){
                this.template.querySelectorAll('lightning-button').forEach(input => {
                    var currentPayFav = this.paymentFavouringMap.get(input.accessKey)
                    //adding Is_Payment_Triggered check for multiple payment disbursed issue - Neha
                    if(((currentPayFav.Payment_Favouring_Status__c==FAILED_STATUS || currentPayFav.Payment_Favouring_Status__c==PENDING_STATUS) && !currentPayFav.Is_Payment_Triggered__c) && this.userType=='Ops Author'){//added usertype check (RO triggered Payment Release)
                        if (currentPayFav.is_Payment_Favouring_Modified__c && !currentPayFav.is_Validated_By_Author__c && !(currentPayFav.Payment_Mode__c == PAYMENT_MODE_TA || (currentPayFav.Payment_Recipient__c == 'CSD' && currentPayFav.Margin_Money_Action__c == 'Yes'))) {
                            if (input.classList.contains('validatePayment')) {
                                input.classList.remove('slds-hide')
                                input.disabled = false
                            }
                            /*if (currentPayFav.Payment_Mode__c == PAYMENT_MODE_TA) {
                                input.disabled = true
                            } else {
                                input.disabled = false
                            }*/
                        }else {
                            if (this.completedStage == COMPLETED_DISBURSEMENT_STAGE){
                                if (input.classList.contains('releasePayment')) {
                                    if( ( (currentPayFav.Is_Pool_Disbursement_Successful__c && currentPayFav.Payment_Mode__c != 'Cheque') || (currentPayFav.Payment_Mode__c == 'Cheque' && currentPayFav.Is_Cheque_Pool_Disburse_Successful__c)) && (POOL_DISBURSEMENT_PM.includes(currentPayFav.Payment_Mode__c))){
                                        input.classList.remove('slds-hide')
                                    }else if(currentPayFav.Payment_Mode__c == IMPS_API){
                                        input.classList.remove('slds-hide')
                                    }
                                }
                                // SFAU-5676 - Release button is not required in case of Cheque: 30/11
                                if (currentPayFav.Payment_Mode__c == PAYMENT_MODE_TA || (currentPayFav.Payment_Mode__c == 'Cheque' && currentPayFav.Is_Cheque_Pool_Disburse_Successful__c) || (currentPayFav.Payment_Recipient__c == 'CSD' && currentPayFav.Margin_Money_Action__c == 'Yes')) {
                                    input.disabled = true
                                    this.handlePostReleaseSteps(currentPayFav.Id,'','')
                                } else {
                                    input.disabled = result && result.hasOwnProperty(currentPayFav.Id) ? result[currentPayFav.Id] : input.disabled ; //false
                                }
                            }
                            
            
                        }
                    }
                    
        
                })
            }
        }).catch(error => {
            this.isLoading = false
            this.showToastMessage('','Something is wrong.','Error');
            return
        })
         /* Updated by Kunal : SFAU-5824 - End  */
        
    }

    handleValidatePayment(event) {
        this.displayValidatePaymentsSection = true
        this.paymentRecord = this.paymentFavouringMap.get(event.target.accessKey)
    }

    showToastMessage(titleValue, messageValue, variantValue, mode) {
        const event = new ShowToastEvent({
            title: titleValue,
            message: messageValue,
            variant: variantValue,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    handleEnablePaymentReleaseEvent(event) {
        let isSuccess=true
        this.displayValidatePaymentsSection = false
        var currentPayment = this.paymentFavouringMap.get(event.detail.id)
        if (event.detail.enableButton) {
            getPaymentFavourings({recordId:this.loanAppId}).then((data=>{
                    if(data && data.length>0){
                        data.forEach(element=>{
                            if(element.is_Payment_Favouring_Modified__c && !element.is_Validated_By_Author__c){
                                isSuccess=false
                            }
                        })
                        if(isSuccess){
                            this.template.querySelectorAll('[data-id="' + event.detail.id + '"]').forEach(input => {
                                if (input.classList.contains('validatePayment')) {
                                    input.classList.add('slds-hide')
                                }
                                /*if(this.completedStage == COMPLETED_DISBURSEMENT_STAGE){
                                    if (input.classList.contains('releasePayment')) {
                                        input.classList.remove('slds-hide')
                                    }
                                }*/
                                
                
                            })
                            this.dispatchEvent(new CustomEvent('enabledodisburse',{
                                detail: {
                                    enableDoDisburseButton: false
                                }
                            }));
                            //this.template.querySelector('[data-id="disburseLoan"]').disabled = false;
                        }
                    }
                }))
            
            
        }
    }

    handlePostReleaseSteps(releasedPaymentFavId, sessionReferenceNumber, txnRefNo){
        if (releasedPaymentFavId) {
            this.paymentsReleasedList = this.paymentsReleasedList.filter(val => val !== releasedPaymentFavId);
            this.template.querySelectorAll('[data-id="' + releasedPaymentFavId + '"]').forEach(input => {
                if (input.classList.contains('releasePayment')) {
                    input.disabled = true
                }
            })
            this.updatePaymentFavouringStatus(releasedPaymentFavId, COMPLETE_STATUS, sessionReferenceNumber, txnRefNo) 
            if(this.paymentsReleasedList.length==0){
                this.updateParentDisbursement()
            }
            this.sendNotification(); //Notification 
        }
    }

    updateParentDisbursement(){
        this.isLoading=true
        updatePaymentParent({recordId: this.parentId, loanAppId: this.loanAppId}).then((data=>{
            this.isLoading=false
            this.showToastMessage('','Disbursement Successful','success')
        })).catch((error=>{
            this.isLoading=false
            this.showToastMessage('','Disbursement Failed','error', 'sticky')
        }))                         
    }

     handleReleasePayment(event) {
        // 19 August 2023 Yash
        // Commented for Transaction Number Enhancement
        // Uncommented 23rd Nov - Double Payment Issue - Release button can be clicked only once.
       // this.disableReleaseButton(event.target.accessKey);

        var currentPayment = this.paymentFavouringMap.get(event.target.accessKey)
        this.template.querySelectorAll('[data-id="'+currentPayment.Id+'"]').forEach(input=>{
            input.disabled=true
        })
        //adding updatePaymentRecord and checkIfPaymentAlreadyDisbursed methods for multiple payment disbursed issue - Neha
       
       /* const latestPayment = await checkIfPaymentAlreadyDisbursed({paymentId: currentPayment.Id})
        if(latestPayment && (latestPayment.Payment_Favouring_Status__c==COMPLETE_STATUS || latestPayment.Is_Payment_Triggered__c)){
            this.showToastMessage('','Payment is Already Triggered. Please Refresh the Page to Check Latest Details','warning')
            return
        }
        */

        let paymentIds = [];
        paymentIds.push(currentPayment.Id);
        /* Added by Kunal : SFAU-5824 - Start  */
      //  const result = await checkIfPaymentAlreadyReleased({paymentIds: paymentIds}); 
        checkIfPaymentAlreadyReleased({ paymentIds: paymentIds })
        .then(result => {
            if(result && result[currentPayment.Id] == true){ 
                this.showToastMessage('','Payment is Already Triggered. Please Refresh the Page to Check Latest Details','warning');
                return
            }else if(!result){
                this.showToastMessage('','Something is wrong.','Error');
                return
            }else{
                this.releasePayment(currentPayment); // SFAU-5824
            }
        }).catch(error => {
            this.showToastMessage('','Something is wrong.','Error');
            return
        })
         /* Added by Kunal : SFAU-5824 - End  */
    }

    // SFAU-5824 
    releasePayment(currentPayment){
       // const disablePaymentRelease = await updatePaymentRecord({paymentId : currentPayment.Id})
        updatePaymentRecord({ paymentId: currentPayment.Id })
        .then(result => {
            if (currentPayment.Payment_Mode__c == NEFT_API) {
                this.doNEFTPaymentMethod(currentPayment)
            } else if (currentPayment.Payment_Mode__c == IMPS_API) {
                this.doIMPSPaymentMethod(currentPayment)
            } else if (currentPayment.Payment_Mode__c == RTGS_API) {
                this.doRTGSPaymentMethod(currentPayment)
            } else if (currentPayment.Payment_Mode__c == 'Cheque' || currentPayment.Payment_Mode__c == 'Transfer') {
                this.doIFTPaymentMethod(currentPayment)
            }
        }).catch(error => {
            this.showToastMessage('','Something is wrong.','Error');
            
        })
    }

    disableReleaseButton(paymentRecId){
        let payments = this.paymentFavouringList;
        payments.forEach(rec=>{
            if(rec.Id == paymentRecId){
                rec.Is_Payment_Triggered__c = true;
            }
        })
        updatePaymentRecord({
            paymentId : paymentRecId
        })
        .then(res=>{
            

        })
        .catch(err=>{
            this.showToastMessage('', err, 'error', 'sticky')
        })
    }


    doNEFTPaymentMethod(currentPayment) {
        this.showToastMessage('', NEFT_API+' in Progress', 'warning', 'sticky')
        this.isLoading = true
        doNEFTPayment({ recordId: currentPayment.Loan_Application__c, paymentFavouringId: currentPayment.Id }).then((data => {
            let callOutData = JSON.parse(data)
            data = JSON.parse(callOutData.response)
            this.isLoading = false
            let request = JSON.parse(callOutData.checklistRecord.Request__c)
            if(callOutData.statusCode!=200){
                this.showToastMessage('Error', 'API Error: ' + callOutData.checklistNumber + ' Response: ' + callOutData.statusCode + '- ' + callOutData.status , 'error','sticky');
                this.updatePaymentFavouringStatus(currentPayment.Id, FAILED_STATUS,'',request.SettlementRequest.TransactionReferenceNumber)                                          
            }else if(data.SettlementResponse.Status == 'Success'){
                this.showToastMessage('', NEFT_API+' Completed', 'success')
                this.handlePostReleaseSteps(currentPayment.Id, data.SettlementResponse.IPHREF,request.SettlementRequest.TransactionReferenceNumber)
                this.isLoading = false                                         
            }else{
                let respMessage = data.SettlementResponse.Remarks?data.SettlementResponse.Remarks:''
                respMessage = data.SettlementResponse.Remarks?data.SettlementResponse.ResponseCodeDescription:''
                this.showToastMessage('Error', 'API Error: ' + callOutData.checklistNumber + ' Response: ' + respMessage + ' Code - ' + data.SettlementResponse.Code , 'error','sticky');
                this.updatePaymentFavouringStatus(currentPayment.Id, FAILED_STATUS,'','')                                    
            }
            
        })).catch((error => {
            this.isLoading = false
            this.showToastMessage('', NEFT_API+' Failed - '+error, 'error', 'sticky')
        }))
    }

    doIMPSPaymentMethod(currentPayment) {
        this.showToastMessage('', IMPS_API+' in Progress', 'warning', 'sticky')
        this.isLoading = true
        doIMPSPayment({ recordId: currentPayment.Loan_Application__c, paymentFavouringId: currentPayment.Id }).then((data => {
            let callOutData = JSON.parse(data)
            data = JSON.parse(callOutData.response)
            this.isLoading = false
            let request = JSON.parse(callOutData.checklistRecord.Request__c)
            if(callOutData.statusCode!=200){
                this.showToastMessage('Error', 'API Error: ' + callOutData.checklistNumber + ' Response: ' + callOutData.statusCode + '- ' + callOutData.status , 'error','sticky');
                this.updatePaymentFavouringStatus(currentPayment.Id, FAILED_STATUS,'',request.ReferenceNumber)                                          
            }else if(data.TransactionStatusType && data.TransactionStatusType.ResponseMessage == 'Success'){
                this.showToastMessage('', IMPS_API+' Completed', 'success')
                this.handlePostReleaseSteps(currentPayment.Id, data.RetrievalReferenceNumber,request.ReferenceNumber)                                      
            }else{
                if(data.TransactionStatusType && data.TransactionStatusType.ExtendedErrorDetails){
                    var errors;
                    data.TransactionStatusType.ExtendedErrorDetails.messages.forEach(input=>{
                        errors = input.message+'; '
                    })
                    this.showToastMessage(IMPS_API+' Failed', errors, 'error', 'sticky')
                }else{
                    this.showToastMessage('', IMPS_API+' Failed', 'error', 'sticky')
                }
                this.updatePaymentFavouringStatus(currentPayment.Id, FAILED_STATUS,'','')                                          
            }
        })).catch((error => {
            this.isLoading = false
            this.showToastMessage('', IMPS_API+' Failed - '+error, 'error')

        }))
    }

    doRTGSPaymentMethod(currentPayment) {
        this.showToastMessage('', RTGS_API+' in Progress', 'warning', 'sticky')
        this.isLoading = true
        doRTGSPayment({ recordId: currentPayment.Loan_Application__c, paymentFavouringId: currentPayment.Id }).then((data => {
            let callOutData = JSON.parse(data)
            data = JSON.parse(callOutData.response)
            this.isLoading = false
            let request = JSON.parse(callOutData.checklistRecord.Request__c)
            if(callOutData.statusCode!=200){
                this.showToastMessage('Error', 'API Error: ' + callOutData.checklistNumber + ' Response: ' + callOutData.statusCode + '- ' + callOutData.status , 'error','sticky');
                this.updatePaymentFavouringStatus(currentPayment.Id, FAILED_STATUS,'',request.SettlementRequest.TransactionReferenceNumber)                                          
            }else if(data.SettlementResponse.Status == 'Success'){
                this.isLoading = false
                this.showToastMessage('', RTGS_API+' Completed', 'success')
                this.handlePostReleaseSteps(currentPayment.Id, data.SettlementResponse.IPHREF,request.SettlementRequest.TransactionReferenceNumber)
            }else{
                this.showToastMessage('Error', 'API Error: ' + callOutData.checklistNumber + ' Response: ' + data.SettlementResponse.ResponseCodeDescription + ' Code - ' + data.SettlementResponse.Code , 'error','sticky');
                this.updatePaymentFavouringStatus(currentPayment.Id, FAILED_STATUS,'','')                                          
            }
            
        })).catch((error => {
            this.isLoading = false
            this.showToastMessage('', RTGS_API+' Failed - '+error, 'error')
        }))
    }

    doIFTPaymentMethod(currentPayment) {
        this.showToastMessage('', IFT_API+' in Progress', 'warning', 'sticky')
        this.isLoading = true
        doIFTPayment({ recordId: currentPayment.Loan_Application__c, paymentFavouringId: currentPayment.Id }).then((data => {
            this.isLoading = false
            let callOutData = JSON.parse(data)
            data = JSON.parse(callOutData.response)
            let request = JSON.parse(callOutData.checklistRecord.Request__c)
            if(callOutData.statusCode!=200){
                this.showToastMessage('Error', 'API Error: ' + callOutData.checklistNumber + ' Response: ' + callOutData.statusCode + '- ' + callOutData.status , 'error','sticky');
                this.updatePaymentFavouringStatus(currentPayment.Id, FAILED_STATUS,'',request.ReferenceNumber)                                          
            }else if(data.TransactionStatus.ResponseMessage == 'Success'){
                
                this.showToastMessage('', IFT_API+' Completed', 'success')
                this.handlePostReleaseSteps(currentPayment.Id, data.TransactionReferenceNo,request.ReferenceNumber)
            }else{
                let errorMessage = data.TransactionStatus.ResponseMessage+(data.TransactionStatus.ValidationErrors && data.TransactionStatus.ValidationErrors.ErrorMessage?' - '+data.TransactionStatus.ValidationErrors.ErrorMessage:'')
                this.showToastMessage('Error','API Error: '+callOutData.checklistNumber+ ' Response: ' +errorMessage, 'error', 'sticky')
                this.updatePaymentFavouringStatus(currentPayment.Id, FAILED_STATUS,'','')                                          
            }
        })).catch((error => {
            this.isLoading = false
            this.showToastMessage('', IFT_API+' Failed - '+error.message.body, 'error', 'sticky')
        }))
    }

    async updatePaymentFavouringStatus(payFavId, status, sessionReferenceNumber, txnReferenceNo){
        var fields;
        if(sessionReferenceNumber){
            fields = { Id: payFavId, Payment_Favouring_Status__c: status, UTR_Number__c: sessionReferenceNumber, Txn_Reference_Number__c: txnReferenceNo}
        }else{
            fields = { Id: payFavId, Payment_Favouring_Status__c: status, Txn_Reference_Number__c: txnReferenceNo}
        }
        /*const recordInput = { fields };
        updateRecord(recordInput).then(() => {
            this.getPaymentFavouringsRecords()
            //refreshApex(this.paymentFavouringList);
        }).catch((error=>{

        }))*/
        let resp = await updatePaymentFavouringAtOpsAuth({paymentStr: JSON.stringify(fields)})
        if(resp){
            this.dispatchEvent(new CustomEvent('refreshonpaymentreleased',{
                detail: {
                    refresh: true
                }
            }));
            //this.getPaymentFavouringsRecords()
        }else{
            this.showToastMessage('','Something went Wrong', 'error')
        }
        
    }
     //29 AUG added notification 
     sendNotification(){
        sendPaymentNotification({ loanId: this.loanAppId }).then((data => {
           console.log('sent notification successfully');
        })).catch((error => {
            this.isLoading = false
            this.showToastMessage('', IFT_API+' Failed - '+error, 'error', 'sticky')
        }))
    }
    //end
}