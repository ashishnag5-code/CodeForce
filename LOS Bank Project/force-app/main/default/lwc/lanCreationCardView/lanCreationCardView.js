import { api, LightningElement, track, wire } from 'lwc';
import callLANCreationCallout from '@salesforce/apex/LANCreationController.callLANCreationCallout'
import checkIfLANAlreadyExists from '@salesforce/apex/LANCreationController.checkIfLANAlreadyExists'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { getSpinnerImage } from 'c/customSpinner';
import callCBSSIApi from '@salesforce/apex/CBSStandingInstructionServiceController.callCBSSIApi'
import callCollateralModificationCallout from '@salesforce/apex/CollateralModificationAPIController.callCollateralModificationCallout'
import getLatestNote from '@salesforce/apex/NotepadComponentController.getLatestNote'
import generateDisbursalVoucher from '@salesforce/apex/LANCreationController.generateDisbursalVoucher';
import callCollateralLinkageCallout from '@salesforce/apex/CollateralLinkageAPIController.callCollateralLinkageCallout';
import isComplete from '@salesforce/apex/CBSBSRPSLAPIController.isComplete';
import submitLANDetails from '@salesforce/apex/CBSBSRPSLAPIController.submitLANDetails';
import CurrentUserId from '@salesforce/user/Id';
import sendSIotification from '@salesforce/apex/LANCreationController.sendSIotification'
import getCollateralEnquiryList from '@salesforce/apex/CustomCollateralEnquiryController.getCollateralEnquiryList';
import {
    APPLICATION_SCOPE,
    createMessageContext,
    MessageContext,
    publish,
    releaseMessageContext,
    subscribe,
    unsubscribe,
} from 'lightning/messageService';
import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c';
import COW_PRODUCT_NAMES from '@salesforce/label/c.COW_Product_Names';//R2-2634

export default class LanCreationComponent extends LightningElement {

    @wire(MessageContext)
    messageContext;
    @api spinnerImage;
    loanApp={}
    cowProducts = COW_PRODUCT_NAMES//R2-2634
    @track loanAppRecord
    @track totalApplicantsFull = [];
    boolNorecordsFull=false;
    @api 
    get loanAppRecordParameter(){
        return this.loanApp
    }

    get showCollaterakList(){
        return this.totalApplicantsFull && this.totalApplicantsFull.length > 0
    }

    set loanAppRecordParameter(value){
        if(value){
            this.loanApp = value
            this.loanAppRecord = value
            var delay = setTimeout(() => {
                this.setValuesForFields();
            }, 100);
            
        }
    }

    tablecolumn = [
            {
                label: 'Collateral ID',
                fieldName: 'strCollateralId',
                type: 'text',
            },
            {
                label: 'Collateral Type',
                fieldName: 'strCollateralType',
                type: 'text'
        
            },
            {
                label: 'Product Name_ Code',
                fieldName: 'strProductNameCode',
                type: 'text'
        
            },
            {
                label: 'Linkage Type',
                fieldName: 'type',
                type: 'text'
        
            },
            {
                label: 'Customer Name',
                fieldName: 'strPropertyOwnerName',
                type: 'text'
        
            },
            {
                label: 'Cust ID',
                fieldName: 'strCustomerId',
                type: 'text'
        
            },
            {
                label: 'Linked Account',
                fieldName: 'AccountNumber',
                type: 'text'
        
            },
            {
                label: 'Relationship',
                fieldName: 'AccountCustomerRelation',
                type: 'String'
        
            },
            {
                label: 'Value',
                fieldName: 'MarketValue',
                type: 'text'
        
            },
            {
                label: 'Considered',
                fieldName: 'isWaived',
                type: 'boolean'
            }
        ];
 
    @api userType
    @api loanType
    @track collateral = {};
    @track CollateralLinkageFailed = false
    @track CollateralCreationFailed = false
    @track retry = false
    @track showSyncNotes = false;
    @track notesButtonDisabled = false;
    @track modifyCollateralApplicable=false
    schemeName = '';
    mmvMasterName = ''
    lanButtonDisabled = false
    collateralDedupDisabled = true;
    retryButtonDisabled = false
    createSIButtonDisabled = false
    displayCardView = true;
    isLoading;
    hasLAN = false;
    disableCBSBSRPSL = false;
    @api primaryApplicant ={};
    async connectedCallback() {
        console.log('loanApp '+JSON.stringify(this.loanAppRecord));
        this.loanAppRecord = JSON.parse(JSON.stringify(this.loanAppRecord))
        
        if (this.spinnerImage == undefined) {
            this.spinnerImage = await getSpinnerImage(this.loanAppRecord.Id);
        }
        if(this.loanAppRecord.Total_Loan_Amount__c){
            this.loanAppRecord.Total_Loan_Amount__c = this.loanAppRecord.Total_Loan_Amount__c.toFixed(0);
        }
        if(this.loanAppRecord.ROI__c){
            this.loanAppRecord.ROI__c = this.loanAppRecord.ROI__c.toFixed(2);
        }
        if (this.loanAppRecord.LAN__c) {
            this.hasLAN = true;
        }
        if(this.loanAppRecord.Collaterals__r && this.loanAppRecord.Collaterals__r[0].BT_Loan_Status__c == 'Fore Closure Refinance'){
            this.lanButtonDisabled = true
            this.collateralDedupDisabled = false;
        }
        //this.setValuesForFields();
    }


    getCollateralList() {
        this.isLoading = true;
        console.log('record id is %% ' + JSON.stringify(this.primaryApplicant.Id));
        getCollateralEnquiryList({ strApplicantId: this.primaryApplicant.Id })
            .then(result => {
                console.log('getCollateralEnquiryList ' + JSON.stringify(result.collateralList))
                /* SFAU-5773 Start*/ 
               // this.totalApplicantsFull = result.collateralList;  Commented for SFAU-5773
                let totalCollList = result.collateralList;
               let cbsCollateralId = result.cbsCollateralId;
                totalCollList.forEach(element => {
                    if(cbsCollateralId = element.strCollateralId){
                        this.totalApplicantsFull.push(element);
                    }
                });
               /* let selectedList = this.selectedCollList ?? []; // Removed by Kunal - Not in use 21st Dec
                if (selectedList?.length > 0) {
                    for (let i = 0; i < selectedList.length; i++) {
                        for (let j = 0; i < totalCollList.length; j++) {
                            if (selectedList[i].strCollateralId === totalCollList[j].strCollateralId) {
                                totalCollList[j].isSelected = true;
                            }
                        }
                    }
                    this.totalApplicantsFull = totalCollList;
                }*/
                /* SFAU-5773 End*/ 

                if (this.totalApplicantsFull.length === 0) {
                    this.boolNorecordsFull = true;
                    this.lanButtonDisabled = false;
                    this.collateralDedupDisabled = true;
                    this.showToastMessage('', 'No collateral record found !', 'error', 'sticky')
                } else {
                    this.boolNorecordsFull = false;
                }
                this.sendDetailsToParent();
                this.isLoading = false;
            })
            .catch(error => {
                if (this.totalApplicantsFull.length === 0) {
                    this.boolNorecordsFull = true;
                } else {
                    this.boolNorecordsFull = false;
                }
                this.sendDetailsToParent();
                this.isLoading = false;
                console.log('result is ' + JSON.stringify(error));
            })
    }

    sendDetailsToParent() {
        const selectedEvent = new CustomEvent("collateraldetails", {detail: {
            collateralDetails : this.totalApplicantsFull
        }});
        
        this.dispatchEvent(selectedEvent);
    }

    setValuesForFields() {
        this.isLoading=true
        this.schemeName = this.loanAppRecord.Scheme__c ? this.loanAppRecord.Scheme__r.Scheme_Name__c : '';
        if (this.loanAppRecord.Collaterals__r && this.loanAppRecord.Collaterals__r.length > 0) {
            this.collateral = this.loanAppRecord.Collaterals__r[0];
            if (this.collateral.MMV_Master__c && this.collateral.MMV_Master__r.Make_Model_Variant__c) {
                this.mmvMasterName = this.collateral.MMV_Master__r.Make_Model_Variant__c
            }
        }
        if(this.loanType && (this.loanType === 'Used' || this.cowProducts.toUpperCase().includes(this.loanType.toUpperCase()))) {//added cow product name check R2-2634
            // In SVOH, Collateral Modification not required as we are sending new Collateral id in CBS => SFAU-5343 (Kunal)
            this.modifyCollateralApplicable= this.collateral.SVSH_SVOH__c && this.collateral.SVSH_SVOH__c != 'SVOH' && !(this.collateral.SVSH_SVOH__c == 'SVSH' && this.collateral.BT_Loan_Status__c == 'Fore Closure Refinance' ) && this.collateral.Collateral_Id_in_CBS__c? true:false //R2-2765
            if(this.modifyCollateralApplicable){
                this.template.querySelector('[data-id="modifyCollateral"').classList.remove('slds-hide')
                this.template.querySelector('[data-id="linkCollateral"').classList.remove('slds-hide')
                if(!this.loanAppRecord.Collateral_Modification_Used_COW__c){
                    this.template.querySelector('[data-id="modifyCollateral"').disabled=false
                }
                if(!this.loanAppRecord.Collateral_Linkage_Used_COW__c && this.loanAppRecord.Collateral_Modification_Used_COW__c){
                    this.template.querySelector('[data-id="linkCollateral"').disabled=false
                }
            }else{

            }
            
            
        }
        
        if(this.loanAppRecord.Repayment_Mode__c === 'Standing Instructions'){
            this.template.querySelector('[data-id="SIButton"').classList.remove('slds-hide')
        }
        if(this.loanAppRecord.isNoteSynced__c==true){
            this.notesButtonDisabled = true;
        }

        this.disableButtons()
    }

    disableButtons(){
        if(this.userType!='User' || this.loanAppRecord.OPS_KYC_Action__c!='Approve' || this.loanAppRecord.Stage__c!='Ops Maker'){
            this.template.querySelectorAll('lightning-button').forEach((input=>{
                input.disabled = true
            }))
            this.isLoading=false
            return;
        }
        if((this.loanType && (this.loanType === 'Used' || this.cowProducts.toUpperCase().includes(this.loanType.toUpperCase()))) && (!this.loanAppRecord.Collateral_Linkage_Used_COW__c || !this.loanAppRecord.Collateral_Modification_Used_COW__c) && this.modifyCollateralApplicable){//added cow product name check R2-2634
            this.lanButtonDisabled=true
            //Send latest note 
            this.showSyncNotes = false;
            this.isLoading=false
            return;
        }
        if(this.loanAppRecord.LAN__c && this.loanAppRecord.is_Collateral_Creation_Successful__c && this.loanAppRecord.is_Collateral_Linkage_Successful__c){
            this.lanButtonDisabled=true
            //Send latest note 
            this.showSyncNotes = true;
        }
        if(this.loanAppRecord.LAN__c && (!this.loanAppRecord.is_Collateral_Creation_Successful__c || !this.loanAppRecord.is_Collateral_Linkage_Successful__c)){
            this.template.querySelector('[data-id="createLan"]').label='Retry'
            this.showSyncNotes = true;
        }
        
        this.isLoading=false
    }

    handleCreateSI(){
        callCBSSIApi({recordId: this.loanAppRecord.Id}).then((data=>{
            if(data.TransactionStatus && data.TransactionStatus.ResponseMessage === 'Success'){
                this.showToast('Success','SI Creation Successful','success')
                this.createSIButtonDisabled=false
                this.sendNotification(); //Notification 
            }else{
                if(data.TransactionStatus.ExtendedErrorDetails && data.TransactionStatus.ExtendedErrorDetails.messages.length>0){
                    var validations;
                    data.TransactionStatus.ExtendedErrorDetails.messages.forEach(element => {
                        validations = element.message;
                    });
                    this.showToast('Error',validations,'error', 'sticky')
                }
                if(data.TransactionStatus.ValidationErrors && data.TransactionStatus.ValidationErrors.length>0){
                    var validations;
                    data.TransactionStatus.ValidationErrors.forEach(element => {
                        validations = element.ErrorMessage;
                    });
                    this.showToast('Error',validations,'error', 'sticky')
                }
            }
        })).catch((error=>{
            this.showToast('Error',error.body.message,'error', 'sticky')
        }))
    }

    handleModifyCollateral(){
        this.isLoading=true
        callCollateralModificationCallout({recordId: this.loanAppRecord.Id, parentCmp : 'lanCreate' }).then((data=>{
            let callOutData = JSON.parse(data)
            data = JSON.parse(callOutData.response)
            if(callOutData && callOutData.statusCode!=200){
                this.isLoading = false
                this.showToast('Error', 'API Error: ' + callOutData.checklistNumber + ' Response: ' + callOutData.statusCode + '- ' + callOutData.status , 'error');
            }
            this.isLoading=false
            if(data.TransactionStatus.ResponseMessage === 'Success'){
                this.showToast('Success','Collateral Modification Successful','success')
                this.template.querySelector('[data-id="modifyCollateral"]').disabled = true
                if(this.loanAppRecord.Stage__c=='Ops Maker'){
                    this.loanAppRecord.Collateral_Modification_Used_COW__c=true
                    const fields = { Id: this.loanAppRecord.Id, Collateral_Modification_Used_COW__c: true };
                    const recordInput = { fields };
                    updateRecord(recordInput).then(() => {
                        this.isLoading = false
                        this.template.querySelector('[data-id="linkCollateral"]').disabled = false
                    });

                }
            }else{
                if(data.TransactionStatus.ExtendedErrorDetails && data.TransactionStatus.ExtendedErrorDetails.messages.length>0){
                    var validations;
                    data.TransactionStatus.ExtendedErrorDetails.messages.forEach(element => {
                        validations = element.message;
                    });
                    this.showToast('Error',validations,'error', 'sticky')
                }
                if(data.TransactionStatus.ValidationErrors && data.TransactionStatus.ValidationErrors.length>0){
                    var validationsMessages;
                    data.TransactionStatus.ValidationErrors.forEach(element => {
                        validationsMessages = element.ErrorMessage;
                    });
                    this.showToast('Warning',validationsMessages,'warning', 'sticky')
                }
            }
        })).catch((error=>{
            this.isLoading=false
            this.showToast('Error',error.body.message,'error', 'sticky')
        }))
    }

    handleLinkCollateral(){
        this.isLoading=true
        callCollateralLinkageCallout({recordId: this.loanAppRecord.Id}).then((data=>{
            let callOutData = JSON.parse(data)
            data = JSON.parse(callOutData.response)
            this.isLoading=false
            if(callOutData && callOutData.statusCode!=200){
                this.isLoading = false
                this.showToast('Error', 'API Error: ' + callOutData.checklistNumber + ' Response: ' + callOutData.statusCode + '- ' + callOutData.status , 'error');
            }
            
            else if(data.TransactionStatus.ResponseMessage === 'Success'){
                this.showToast('Success','Collateral Linkage Successful','success')
                this.template.querySelector('[data-id="linkCollateral"]').disabled = true
                if(this.loanAppRecord.Stage__c=='Ops Maker'){
                    this.loanAppRecord.Collateral_Linkage_Used_COW__c=true
                    const fields = { Id: this.loanAppRecord.Id, Collateral_Linkage_Used_COW__c: true };
                    const recordInput = { fields };
                    updateRecord(recordInput).then(() => {
                        this.isLoading = false
                        this.template.querySelector('[data-id="linkCollateral"]').disabled = true
                        this.lanButtonDisabled=false
                    });

                }
                
            }else{
                if(data.TransactionStatus.ExtendedErrorDetails && data.TransactionStatus.ExtendedErrorDetails.messages.length>0){
                    var validations;
                    data.TransactionStatus.ExtendedErrorDetails.messages.forEach(element => {
                        validations = element.message;
                    });
                    this.showToast('Error',validations,'error', 'sticky')
                }
            }
        })).catch((error=>{
            this.isLoading=false
            this.showToast('Error',error.body.message,'error', 'sticky')
        }))
    }

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    handleCreateLANAction() {
        if(!this.loanAppRecord.LAN__c){
            this.handleCreateLAN('None')
        }else if(this.loanAppRecord.LAN__c && !this.loanAppRecord.is_Collateral_Creation_Successful__c){
            this.CollateralCreationFailed=true
            this.handleCreateLAN('CollateralCreation')
        }else if(this.loanAppRecord.LAN__c && this.loanAppRecord.is_Collateral_Creation_Successful__c && !this.loanAppRecord.is_Collateral_Linkage_Successful__c){
            this.CollateralLinkageFailed=true
            this.handleCreateLAN('CollateralLinkage')
        }
        
    }

    
    handleCreateLAN(failureCause) {
        this.isLoading = true
        this.lanButtonDisabled = true
        this.retryButtonDisabled = true
        console.log('loanId in create lan '+this.loanAppRecord.Id);
        // SFAU-5526
        checkIfLANAlreadyExists({loanId: this.loanAppRecord.Id}).then((result=>{
            if(result == 'Success'){
                this.createLAN(failureCause);
            }
        })).catch((error=>{
            this.isLoading = false
            this.showToast('Error', error.message || error.body.message, 'error', 'sticky');
        }))
    }

    createLAN(failureCause){
        callLANCreationCallout({ recordId: this.loanAppRecord.Id, failureReason: failureCause }).then((data => {
            let callOutData = JSON.parse(data)
            data = JSON.parse(callOutData.response)
            if(callOutData && callOutData.statusCode!=200){
                this.isLoading = false
                this.retry = true
                this.lanButtonDisabled = true
                this.retryButtonDisabled=false
                this.showToast('Error', 'API Error: ' + callOutData.checklistNumber + ' Response: ' + callOutData.statusCode + '- ' + callOutData.status , 'error');
            }
            if(data.AccountId && data.TransactionStatus.ResponseMessage === 'Success'){
                this.retryButtonDisabled = true
                this.lanButtonDisabled=true
                this.showToast('Success', 'LAN, Collateral, Collateral Linkage Creation Successfully', 'success')
                this.loanAppRecord = JSON.parse(JSON.stringify(this.loanAppRecord))
                this.loanAppRecord.LAN__c = data.AccountId
           /*    let todaysDate = new Date()
                let lanCreationDate = todaysDate.getFullYear() + '-' + (todaysDate.getMonth()+1).toString().padStart(2, '0') + '-' + todaysDate.getDate().toString().padStart(2, '0');
                this.showToast('Success', 'LAN, Collateral, Collateral Linkage Creation Successfully', 'success')
                const fields = { Id: this.loanAppRecord.Id, LAN__c: data.AccountId, LAN_Created_By__c: CurrentUserId,
                    LAN_Creation_Date__c: lanCreationDate, is_Collateral_Linkage_Successful__c: true, is_Collateral_Creation_Successful__c:true };
                const recordInput = { fields };
                updateRecord(recordInput).then(() => {
                    this.isLoading = false
                    this.dispatchLMSEvent()
                    //Send latest note 
                    this.showSyncNotes = true;
                    this.generateDisbursalVoucher()
                });
            */

                this.isLoading = false
                this.dispatchLMSEvent()
                //Send latest note 
                this.showSyncNotes = true;
                this.generateDisbursalVoucher()
                this.hasLAN = true;
            }
            else{
                if (data.AccountId) {
                    this.lanButtonDisabled = true
                    this.retryButtonDisabled=true
                    this.loanAppRecord = JSON.parse(JSON.stringify(this.loanAppRecord))
                    this.loanAppRecord.LAN__c = data.AccountId
                  /*  let todaysDate = new Date()
                    let lanCreationDate = todaysDate.getFullYear() + '-' + (todaysDate.getMonth()+1).toString().padStart(2, '0') + '-' + todaysDate.getDate().toString().padStart(2, '0');
                    const fields = { Id: this.loanAppRecord.Id, LAN__c: data.AccountId, LAN_Created_By__c: CurrentUserId,
                        LAN_Creation_Date__c: lanCreationDate };
                    const recordInput = { fields };
                    updateRecord(recordInput).then(() => {
                        this.isLoading = false
                        this.showToast('Success', 'LAN Creation Successfull', 'success')
                    });
                  */

                    this.isLoading = false
                    this.showToast('Success', 'LAN Creation Successfull', 'success')

                }
                if (data.TransactionStatus.ResponseMessage === 'Success') {
                    this.isLoading = false
                    this.retryButtonDisabled = true
                    this.lanButtonDisabled=true
                    this.showToast('Success', 'LAN, Collateral, Collateral Linkage Creation Successfully', 'success')
                 /*   const fields = { Id: this.loanAppRecord.Id, is_Collateral_Linkage_Successful__c: true, is_Collateral_Creation_Successful__c:true };
                    const recordInput = { fields };
                    updateRecord(recordInput).then(() => {
                        this.isLoading = false
                        this.dispatchLMSEvent()
                        //Send latest note 
                        this.showSyncNotes = true;
                        this.generateDisbursalVoucher()
                    });
                 */   
                    this.isLoading = false
                    this.dispatchLMSEvent()
                    //Send latest note 
                    this.showSyncNotes = true;
                    this.generateDisbursalVoucher()
                    this.hasLAN = true;
                }
                if (data.TransactionStatus.ResponseMessage === 'Incomplete') {
                    this.isLoading = false
                    this.lanButtonDisabled=true
                    this.retryButtonDisabled=false
                    if (data.TransactionStatus.ExtendedErrorDetails.messages && data.TransactionStatus.ExtendedErrorDetails.messages.length > 0) {
                        data.TransactionStatus.ExtendedErrorDetails.messages.forEach(element => {
                            if (element.code != 0 && element.message.includes('CollateralCreation')) {
                                this.showToast('Error', 'Collateral Creation has Failed', 'error', 'sticky')
                                this.retry = true
                                this.CollateralCreationFailed = true
                                this.showToast('Warning', element.message, 'warning', 'sticky')

                            }
                            if (element.code == 0 && element.message.includes('CollateralCreation')) {
                           /*     const fields = { Id: this.loanAppRecord.Id, is_Collateral_Creation_Successful__c: true };
                                const recordInput = { fields };
                                setTimeout(() => {
                                    updateRecord(recordInput).then(() => {
                                        this.isLoading = false
                                        this.showToast('Success', 'Collateral Creation Successfull', 'success')
                                    });
                                }, 2000);
                            */    
                                this.isLoading = false
                                this.showToast('Success', 'Collateral Creation Successfull', 'success')
                            }
                            if (element.code != 0 && element.message.includes('CollateralLinkage')) {
                                this.showToast('Error', 'CollateralLinkage Creation has Failed', 'error', 'sticky')
                                this.CollateralCreationFailed = false
                                this.retry = true
                                this.CollateralLinkageFailed = true
                                this.showToast('Warning', element.message, 'warning', 'sticky')
                            }
                            if (element.code == 0 && element.message.includes('CollateralLinkage')) {
                            /*    const fields = { Id: this.loanAppRecord.Id, is_Collateral_Linkage_Successful__c: true };
                                const recordInput = { fields };
                                setTimeout(() => {
                                    updateRecord(recordInput).then(() => {
                                        this.isLoading = false
                                        this.showToast('Success', 'Collateral Creation Successfull', 'success')
                                        console.log('loanId '+this.loanAppRecord.Id);
                                        this.dispatchLMSEvent()
                                        this.generateDisbursalVoucher()
                                        //Send latest note 
                                        this.showSyncNotes = true;
                                    });
                                }, 2000);
                            */    
                                this.isLoading = false
                                this.showToast('Success', 'Collateral Creation Successfull', 'success')
                                console.log('loanId '+this.loanAppRecord.Id);
                                this.dispatchLMSEvent()
                                this.generateDisbursalVoucher()
                                //Send latest note 
                                this.showSyncNotes = true;
                            }
                        });

                        if (data.TransactionStatus.ValidationErrors && data.TransactionStatus.ValidationErrors.length > 0) {
                            var validations;
                            data.TransactionStatus.ValidationErrors.forEach(element => {
                                validations = element.ErrorMessage + '\n'
                            });

                            this.showToast('Warning', validations, 'warning', 'sticky')
                        }

                    }

                    this.isLoading = false
                }
                if (data.TransactionStatus.ResponseMessage === 'Failure') {
                    this.isLoading = false
                    this.retry = true
                    this.lanButtonDisabled=true
                    this.retryButtonDisabled=false
                    var errorMessages;
                    data.TransactionStatus.ExtendedErrorDetails.messages.forEach(element => {
                        errorMessages = element.message + '\n'
                    });
                    this.showToast('Warning', errorMessages, 'warning', 'sticky')

                    if (data.TransactionStatus.ValidationErrors && data.TransactionStatus.ValidationErrors.length > 0) {
                        var validations;
                        data.TransactionStatus.ValidationErrors.forEach(element => {
                            validations = element.ErrorMessage + '\n'
                        });

                        this.showToast('Warning', validations, 'warning')
                    }
                }
            }

        })).catch((error => {
            this.isLoading = false
            this.showToast('Error', error.body.message, 'error', 'sticky')
        }))
    }

    handleRetryCreateLAN() {
        if (this.CollateralCreationFailed) {
            this.handleCreateLAN('CollateralCreation')
        }
        else if (this.CollateralLinkageFailed) {
            this.handleCreateLAN('CollateralLinkage')
        } else {
            this.handleCreateLAN('None')
        }


    }

    dispatchLMSEvent(){
        const payload = { recordIdOfSobject: this.loanAppRecord.Id, refreshPage: 'Yes'};
        publish(this.messageContext, pageRefreshOnMaterialFieldChange, payload);
    }

    generateDisbursalVoucher(){
        generateDisbursalVoucher({loanApplicationId: this.loanAppRecord.Id}).then((data=>{
            this.showToast('Success', 'Disbursement Voucher Generated Successful', 'success');
        })).catch((error=>{
            this.showToast('Error', 'Disbursement Voucher Generation Failed', 'error', 'sticky');
        }))
    }

    navigateToLoanDetailView() {
        this.dispatchEvent(new CustomEvent('displayloandetails'));
    }

    syncNotes(){
        console.log('loanApp '+JSON.stringify(this.loanAppRecord));
        this.isLoading = true;
        console.log('loanId in sync notes '+this.loanAppRecord.Id);
        getLatestNote({
            loanId: this.loanAppRecord.Id
        })
        .then(data =>{
            console.log('data '+JSON.stringify(data));
            this.isLoading = false;
            /*if(data.includes('successfully') || data.includes('Success')){
                this.showToast('Success', data, 'success');
                this.notesButtonDisabled = true;
            }
            else if(data.includes('Failure')){
                this.showToast('', data?.TransactionStatusType?.ExtendedErrorDetails?.messages?.message, 'error');
            }
            else if(data.includes('Error')){
                this.showToast('', data, 'error');
            }*/

            if(data==null){
                this.showToast('', 'There are no notes to sync', 'error', 'sticky');
            }
            else if(data?.TransactionStatusType?.ResponseMessage=='Success'){
                this.showToast('Success', 'Notes Synced successfully', 'success');
                this.notesButtonDisabled = true;
            }
            else if(data?.TransactionStatusType?.ResponseMessage=='Failure'){
                let msg = data?.TransactionStatusType?.ExtendedErrorDetails?.messages?.message;
                console.log('msg '+msg);
                this.showToast('', msg, 'error', 'sticky');
            }
            else if(data.includes('Error')){
                this.showToast('Error', 'Something went wrong', 'error', 'sticky');
            }
            
        })
        .catch(error =>{
            this.isLoading = false;
            console.log('Error '+JSON.stringify(error));
            this.showToast('Error', 'Something went wrong', 'error', 'sticky');
        })
    }

    submitPSLBSR() {
        this.isLoading = true;
        this.disableCBSBSRPSL = true;
        const fields = { Id: this.loanAppRecord.Id, is_BSR_PSL_API_successful__c: true };
        const recordInput = { fields };
        updateRecord(recordInput).then(() => {
            //this.dispatchLMSEvent()
        }).catch(error=>{
        });
        // ater callout this.disableCBSBSRPSL = false (if already created)
        submitLANDetails({
            loanId: this.loanAppRecord.Id
        })
        .then(data =>{
            this.isLoading = false;
            if (data === 'Completed') {
                this.showToast('Success', 'Submitted details to CBS', 'success', 'dismissable');
            } else {
                this.showToast('Error', 'CBS rejected these details. Please recheck', 'error', 'dismissable');
                this.disableCBSBSRPSL = false;
            }
            this.dispatchLMSEvent()
        })
        .catch(error =>{
            this.isLoading = false;
            this.showToast('Error', error?.message, 'error', 'dismissable');
            this.disableCBSBSRPSL = false;
        })
    }

    @wire(isComplete, { loanId: '$loanAppRecord.Id', applicantId : '' })
    wiredDate({ error, data }) {
        if (data) {
            this.disableCBSBSRPSL = data;
        } else if (error) {
            this.disableCBSBSRPSL = true;
        }
    }
      //29 AUG added notification 
      sendNotification(){
        sendSIotification({ loanId: this.loanAppRecord.Id }).then((data => {
           console.log('sent notification successfully');
        })).catch((error => {
            this.isLoading = false
            this.showToastMessage('', IFT_API+' Failed - '+error, 'error', 'sticky')
        }))
    }
    //end

    showToastMessage(variantVal,messageVal){
        const event = new ShowToastEvent({
            title: variantVal,
            message: messageVal,
            variant: variantVal
        });
        this.dispatchEvent(event);
    }
}