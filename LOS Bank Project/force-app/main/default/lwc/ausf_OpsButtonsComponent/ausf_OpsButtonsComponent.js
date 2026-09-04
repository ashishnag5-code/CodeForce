import { LightningElement, api, wire, track } from 'lwc';
import getLoanId from '@salesforce/apex/OpsSummaryButtonsController.getLoanId'
import handleOpsValidation from '@salesforce/apex/OpsSummaryButtonsController.handleOpsValidation'
import updateAssignmentOwner from '@salesforce/apex/OpsAssignementUtility.updateAssignmentOwner'
import doOpsAssignment from '@salesforce/apex/OpsAssignementUtility.doOpsAssignment'
import doOpsAssignmentAction from '@salesforce/apex/OpsAssignementUtility.doOpsAssignmentAction'
import markAssignmentComplete from '@salesforce/apex/OpsAssignementUtility.markAssignmentComplete'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import checkIfDisbursementDone from '@salesforce/apex/OpsSummaryButtonsController.checkIfDisbursementDone'
import updateAssignmentPendingStatus from '@salesforce/apex/OpsAssignementUtility.updateAssignmentPendingStatus'
import updateMotorInsDevRecord from '@salesforce/apex/LoanDisbursementOpsController.updateMotorInsDevRecord'
import sendOpsNotification from '@salesforce/apex/OpsSummaryButtonsController.sendOpsNotification' //Notification
import uId from '@salesforce/user/Id'; // Getting the User Id


export default class Ausf_OpsButtonsComponent extends LightningElement {
    @api recordId;
    loanAssignmentRecord;
    strLoggedInOpsUserType;
    strLoanAppStage;
    boolShowButtons;
    isOpenModal = false;
    remarksValue = '';
    currentUserId = uId;

    @track
    boolShowAcceptButton;
    @track
    boolIsStageMaker;
    @track
    boolIsStageAuthor;
    @track
    showSubmitButtons;
    @track
    boolIsFinalDisbursement;
    isLoading;


    connectedCallback() {
        getLoanId({ recordId: this.recordId }).then(data => {
            console.log('%%% ' + JSON.stringify(data));
            this.loanAssignmentRecord = data.objAssignment;
            this.strLoanAppStage = data.objAssignment.Stage__c;
            this.boolShowButtons = data.showButtons;
            this.boolShowAcceptButton = data.showAcceptButton;
            this.showSubmitButtons = data.showSubmitButtons;
            this.strLoggedInOpsUserType = data.strLoggedInOpsUserType;
            this.boolIsFinalDisbursement = data.boolIsFinalDisbursement;
            this.checkButtonVisibility(this.loanAssignmentRecord.Ops_Stage__c);
            this.renderMarkPendingButton = (this.loanAssignmentRecord.Sub_Status__c == 'Pending');
        }).catch((error) => {
            this.showToastEvent('Error', 'We Encountered an Error while processing your file' + error, 'error');
        })
    }

    handlePendingSubStatus(){
        updateAssignmentPendingStatus({assignmentId : this.recordId}).then(data=>{
            this.showToast('Success','Record Marked in Pending Status','success');
            window.location.reload();
        })
        .catch(err=>{
            this.showToastEvent('Error', 'We Encountered an Error while processing your file' + error, 'error');
        })
    }

    checkButtonVisibility(strStage){
        this.boolIsStageMaker = false;
        this.boolIsStageAuthor = false;
        if (strStage == 'Ops Maker' && this.strLoggedInOpsUserType == 'Ops Maker') {
            this.boolIsStageMaker = true;
            this.boolIsStageAuthor = false;
        }
        else if (strStage == 'Ops Author' && this.strLoggedInOpsUserType == 'Ops Author') {
            this.boolIsStageMaker = false;
            this.boolIsStageAuthor = true;
        }
    }

    handleInputChange(event) {
        this.remarksValue = event.detail.value;
    }

    handleAccept() {
        updateAssignmentOwner({ strAssignmentId: this.recordId }).then(data => {
            if (data) {
                this.checkButtonVisibility(this.loanAssignmentRecord.Ops_Stage__c);
                this.boolShowAcceptButton = false;
                this.showSubmitButtons = true;
                this.showToast('Success', 'Accepted Successfully', 'success')
                window.location.reload();
            }
            else {
                this.showToast('Error', 'Already Accepted', 'error')
            }
        }).catch((error) => {
            this.showToastEvent('Error', 'We Encountered an Error while processing your file' + error, 'error');
        })
        /*
        updateAssignmentOwner({strAssignmentId: this.recordId}).then(data=>{
            if(data){
                console.log('%% '+data);
                //this.boolShowAcceptButton = false;
            }
        }).catch((error)=>{
            this.showToastEvent('Error', 'We Encountered an Error while processing your file'+error, 'error');
        })*/
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'sticky'
        });
        this.dispatchEvent(event);
    }

   async handleSubmittoAuthor(){
        let response = await this.validateSubmit('SubmitToAuthor');
        if(response == true){
            //this.updateLoanAppRecord('Successfully Submitted to','Ops Author');
            if(this.strLoanAppStage == 'Ops Maker'){
                const fields = { Id: this.loanAssignmentRecord.Loan_Application__c, Stage__c: 'Ops Author' };
                const recordInput = { fields };
                updateRecord(recordInput).then(() => {
                    doOpsAssignmentAction({ objLoanApplication: fields , strAssignmentType : 'Ops - Disbursement',strStage : 'Ops Author' , strCaseType : 'SubmitToAuthor'}).then(data => {
                        this.isLoading = false
                        this.checkButtonVisibility('Ops Author');
                        this.showToast('Success', 'Successfully Submitted to Author', 'success')
                    }).catch((error) => {
                        this.showToastEvent('Error', 'We Encountered an Error while processing your file' + error, 'error');
                    })
                });
            }
            else{
                const fields = { Id: this.loanAssignmentRecord.Loan_Application__c};
                doOpsAssignment({ objLoanApplication: fields , strAssignmentType : 'Ops - Disbursement',strStage : 'Ops Author'}).then(data => {
                    this.isLoading = false
                    this.checkButtonVisibility('Ops Author');
                    this.showToast('Success', 'Successfully Submitted to Author', 'success')
                }).catch((error) => {
                    this.showToastEvent('Error', 'We Encountered an Error while processing your file' + error, 'error');
                })
            }
            this.sendNotification(); //Notification
        }
    }

    async handleSubmittoPDD(){
        let response = await this.validateSubmit('SubmitToPDD');
        if(response == true){
            //this.updateLoanAppRecord('Successfully Submitted to','PDD');
            const fields = { Id: this.loanAssignmentRecord.Loan_Application__c, Stage__c: 'PDD', Disbursement_Status__c: 'Fully Disbursed', Is_Loan_Disbursed__c: true};
            const recordInput = { fields };
            updateRecord(recordInput).then(() => {
                const assignmentfields = { Id: this.loanAssignmentRecord.Id };
                console.log('inside');
                markAssignmentComplete({ objAssignment: assignmentfields}).then(data => {
                    this.isLoading = false
                    this.checkButtonVisibility('PDD');
                    this.showToast('Success', 'Successfully Submitted to PDD', 'success')
                }).catch((error) => {
                    this.showToastEvent('Error', 'We Encountered an Error while processing your file' + error, 'error');
                })
            });
        }
    }

    async handleSubmitPartiallyDisbursed(){
        let response = await this.validateSubmit('SubmitToRO');
        if(response == true){
            const fields = { Id: this.loanAssignmentRecord.Loan_Application__c, Stage__c: 'Partially Disbursed',Disbursement_Status__c: 'Partially Disbursed',
                                Completed_Disbursement_Stage__c : '', Repayment_Schedule_Viewed_by_Maker__c	: false };
            const recordInput = { fields };
            updateRecord(recordInput).then(() => {
                const assignmentfields = { Id: this.loanAssignmentRecord.Id };
                markAssignmentComplete({ objAssignment: assignmentfields}).then(data => {
                    this.isLoading = false
                    this.checkButtonVisibility('Partially Disbursed');
                    this.showToast('Success', 'Successfully Submitted to PDD', 'success')
                }).catch((error) => {
                    this.showToastEvent('Error', 'We Encountered an Error while processing your file' + error, 'error');
                })
            }); 
        }
    }

    cancel() {
        this.isOpenModal = false;
    }

    openModal() {
        this.isOpenModal = true;
    }

    submitRemarks() {
        this.updateRemarks();
        this.handleReturntoPSD();

        this.isOpenModal = false;
    }

    updateAssignmentSubStatus(){
        const fields = { Id: this.loanAssignmentRecord.Id, Sub_Status__c: 'Rework'};
        const recordInput = { fields };
        updateRecord(recordInput).then(() => {
            console.log('Inside updateRemarks');
        });
    }

    updateRemarks() {
        const fields = { Id: this.loanAssignmentRecord.Loan_Application__c, Remarks__c: this.remarksValue};
        const recordInput = { fields };
        updateRecord(recordInput).then(() => {
            console.log('Inside updateRemarks');
        });
    }

    async handleReturntoPSD(){
        let response = await this.validateSubmit('ReturnToPSD');
        if(response == true){
            this.updateLoanAppRecord('Successfully Returned to','PSD');
            this.updateAssignmentSubStatus();
            this.updateMotorInsDeviation(this.loanAssignmentRecord.Loan_Application__c)
        }
        /*const fields = { Id: this.loanAssignmentRecord.Loan_Application__c, Stage__c: 'PSD' };
        const recordInput = { fields };
        updateRecord(recordInput).then(() => {
            this.isLoading = false
            this.showToast('Success', 'Successfully Returned to PSD', 'success')
        });*/
    }

    //4473 start
    updateMotorInsDeviation(loanIdTemp){
        updateMotorInsDevRecord({loanId:loanIdTemp,value:false}).then((data=>{

        })).catch(error=>{

        })

    }
    //4473 end 

    async handleReturntoMaker(){
        if(this.loanAssignmentRecord.Ops_Stage__c == 'Ops Author'){
            let disbursmentDone = await checkIfDisbursementDone({recordId: this.loanAssignmentRecord.Loan_Application__c})
            if(disbursmentDone){
                this.showToast('Error', 'Loan has been Disbursed. Application cannot be returned to Ops Maker', 'error')
            }else{
                this.updateLoanAppRecord('Successfully Returned to','Ops Maker');
            }
        }else{
            this.updateLoanAppRecord('Successfully Returned to','Ops Maker');
        }
        
        /*const fields = { Id: this.loanAssignmentRecord.Loan_Application__c, Stage__c: 'Ops Maker' };
        const recordInput = { fields };
        updateRecord(recordInput).then(() => {
            this.isLoading = false
            this.showToast('Success', 'Successfully Returned to Ops Maker', 'success')
        });*/
    }

    updateLoanAppRecord(strMessage, strStage){
        if(strStage == 'Ops Maker'){
            const fields = { Id: this.loanAssignmentRecord.Loan_Application__c, Stage__c: strStage, Completed_Disbursement_Stage__c:'' };
            const recordInput = { fields };
            updateRecord(recordInput).then(() => {
                if(strMessage == 'Successfully Returned to'){
                    doOpsAssignmentAction({ objLoanApplication: fields , strAssignmentType : 'Ops - Disbursement' , strStage : 'Ops Maker' , strCaseType : 'SendBack'}).then(data => {
                this.checkButtonVisibility(strStage);
                this.isLoading = false
                        this.showMessage('Successfully Submitted to Maker', 'success')
                    }).catch((error) => {
                        this.showToastEvent('Error', 'We Encountered an Error while processing your file' + error, 'error');
                    })
                }
                else{
                    doOpsAssignment({ objLoanApplication: fields , strAssignmentType : 'Ops - Disbursement' , strStage : 'Ops Maker'}).then(data => {
                        this.checkButtonVisibility(strStage);
                        this.isLoading = false
                        this.showMessage('Successfully Submitted to Maker', 'success')
                    }).catch((error) => {
                        this.showToastEvent('Error', 'We Encountered an Error while processing your file' + error, 'error');
                    })
                }
            });
        }
        else{
            const fields = { Id: this.loanAssignmentRecord.Loan_Application__c, Stage__c: strStage, Ops_Sent_Back_User__c : this.currentUserId };
            const recordInput = { fields };
            updateRecord(recordInput).then(() => {
                this.checkButtonVisibility(strStage);
                this.isLoading = false
                this.showToast('Success', strMessage + ' '+ strStage, 'success')
            });
        }
    }

    validateSubmit(buttonType){
        //Validation

        this.isLoading = true;
        return new Promise((resolve, reject) => {
            let response = false;
            handleOpsValidation({  loanId: this.loanAssignmentRecord.Loan_Application__c, type:buttonType })
            .then(data => {
               console.log('data-->' +JSON.stringify(data));
                if (data == 'Success') {
                    response = true;
                }else{
                    this.showErrorMessage(data, 'error');
                    //response = true;
                }
                this.isLoading = false;
                resolve(response);
            })
            .catch(error => {
                this.isLoading = false;
                reject('');
                //this.showErrorMessage(JSON.stringify(error), 'error');
            });
        })


        //return true;
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

     //29 AUG added notification 
     sendNotification(){
        sendOpsNotification({ loanId: this.loanAssignmentRecord.Loan_Application__c }).then((data => {
           console.log('sent notification successfully');
        })).catch((error => {
            this.isLoading = false
            this.showToastMessage('', IFT_API+' Failed - '+error, 'error', 'sticky')
        }))
    }
    //end
}