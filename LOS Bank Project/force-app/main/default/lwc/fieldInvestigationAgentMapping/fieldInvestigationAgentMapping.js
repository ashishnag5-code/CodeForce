import { LightningElement, track, api, wire } from 'lwc';
import getRelatedFI from '@salesforce/apex/FieldInvestigationAgentMappingController.getRelatedFI';
import updateOwner from '@salesforce/apex/FieldInvestigationAgentMappingController.updateOwner';
import fetchRelatedApplicantAddress from '@salesforce/apex/CreateFieldInvestigatiionRecord.fetchRelatedApplicantAddress';
import FORM_FACTOR from '@salesforce/client/formFactor';
import fiApplicant from '@salesforce/label/c.Re_Assign_FI_Agent_Applicant';
import fiApplication from '@salesforce/label/c.Re_Assign_FI_Agent_Application';
import fiButtonProfileName from '@salesforce/label/c.Fi_ReAssign_Profile_Name';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import ProfileName from '@salesforce/schema/User.Profile.Name';
import fi from '@salesforce/label/c.Re_Assign_FI_Agent_FI';
import getUserAssignedPermissions from '@salesforce/apex/CreateFieldInvestigatiionRecord.getUserAssignedPermissions';
import getLoanRelatedAddress from '@salesforce/apex/CreateFieldInvestigatiionRecord.getApplicantRelatedAddress';


import Id from '@salesforce/user/Id';

export default class FieldInvestigationAgentMapping extends LightningElement {
    label = {
        fiApplicant,
        fiApplication,
        fi
    };

    @api fromMobile;
    @api applicationRecordType = '';

    @track FIRecords;
    @track isModalOpen = false;
    @track selectedRecord = [];
    @track userId = '';
    @api recordId;
    @api objectApiName;
    @api isReTrigger=false;
    @api isRetriggerPermission ;
    @api isReassignPermission;
    @track enableDisableActionButton = false;
    @api test='';
    @track isRenderPermissionSetCOmplete = false;
    @track currentUserProfileName = '';
    selectAll=false;
    showReassign=false;
    fiName;
    employeeCode;
    @track isfirstPage = true;
    fiRecordId;
    agentCode;
    ownerName;
    isLoaded = false;
    // isFiUser =false;
    CMUserId = Id;
    //  showCheckBox=true;
    isMobile;
    @track columns = [{
        label: 'Name',
        fieldName: 'Name',
        type: 'text',
    },
    {
        label: 'Application Name',
        fieldName: 'ApplicationName',
        type: 'text',
    },
    {
        label: 'Applicant Type',
        fieldName: 'Applicant_Type__c',
        type: 'text',
    },
    {
        label: 'Address Type',
        fieldName: 'Type_of_address__c',
        type : 'text'
    },
    {
        label: 'Zip Code',
        fieldName: 'Pincode',
        type: 'text',
    },
    {
        label: 'Owner Name',
        fieldName: 'OwnerName',
        type: 'text',
    },
    {
        label: 'Status',
        fieldName: 'Status__c',
        type: 'text',
    },
    {
        label: 'FI Agent',
        fieldName: 'FI_Agent__c',
        type: 'text',
    }
    ];
    get getHeaderLabel() {
        if(this.isReTrigger){
            return 'Re-Trigger'
        }
        else{
            if (this.objectApiName == 'Applicant__c') {
                return this.label.fiApplicant;
            }
            else if (this.objectApiName == 'Loan_Application__c') {
                return this.label.fiApplication;
            }
            else if (this.objectApiName == 'Field_Investigation__c') {
                return this.label.fi;
            }
        }
        
    }
    /* handleEmployeeValue(event) {
         this.employeeCode = event.target.value;
 
     }*/

    @wire(getRecord, { recordId: '$CMUserId', fields: [ProfileName] })
    userDetails({ data }) {
        if (data) {
            console.log('data>>>' + JSON.stringify(data));
            console.log('fiButtonProfileName>>>' + JSON.stringify(fiButtonProfileName));
            //let text = "Credit Manager\r\nSystem Administrator\r\ntest";
            const myArray = fiButtonProfileName.split(",");
            console.log('myArray>>>' + JSON.stringify(myArray));
            this.currentUserProfileName = data.fields.Profile.value.fields.Name.value;

            this.dispatchEvent(new CustomEvent('successdisplay'));
            for (const key in myArray) {
                if (Object.hasOwnProperty.call(myArray, key) && myArray[key] == data.fields.Profile.value.fields.Name.value) {
                    this.showReassign=true;
                    console.log('showReassign>>>' + JSON.stringify(this.showReassign));
                }
                // else{
                //     this.showReassign = (this.applicationRecordType == 'Four Wheeler');
                // }
            }




        }

        /* if (data.fields.Profile.value != null) {
            data.fields.Profile.value.fields.Name.value ==  "Field Investigator"? this.isFiUser=true:this.isFiUser=false;
            console.log('isFiUser>>>'+JSON.stringify(this.isFiUser));
 
         }*/
    }


    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 

    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
        this.objectApiName != 'Field_Investigation__c' ? this.isfirstPage = true : this.isfirstPage = false;
        this.selectedRecord = [];
        if(this.objectApiName == 'Field_Investigation__c'){
            this.selectedRecord.push(this.recordId);
        }
        this.userId = '';
        this.getFi();
        this.getRelatedApplicantAddresses();

    }
    get containerStyle(){
        if(this.isMobile && this.objectApiName =='Loan_Application__c')
        return 'max-height: 30%'
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    handleDataTable() {
        this.selectedRecord = [];
        var selected = this.template.querySelector('lightning-datatable').getSelectedRows();
        for (const key in selected) {
            this.selectedRecord.push(selected[key].Id);
        }
        console.log('this.selectedRecord@@>>>' + JSON.stringify(this.selectedRecord));

        // this.selectedRecord = this.template.querySelector('lightning-datatable').getSelectedRows();
    }
    handleSelectAll(event){
        if(this.isReTrigger && this.isMobile){
            this.handleSelectAllReTriggerMobile();
            return;
        }
        let i;
        this.selectAll=!this.selectAll;
        if(!this.selectAll)
             this.selectedRecord=[];
        let checkboxes = this.template.querySelectorAll('[data-id=checked]');
        for(i=0; i<checkboxes.length; i++) {
            checkboxes[i].checked = this.selectAll;
            if(this.selectAll)
                this.selectedRecord.push(this.FIRecords[i].Id);
       }
    //   this.selectedRecord.push(fiRecd)
             //console.log('this.checkboxes>>>'+JSON.stringify(this.checkboxes));
             console.log('event.target.checked*>>>'+JSON.stringify(event.target.checked));
    }
    handleSelect(event) {
        //   event.preventDefault();
        //event.currentTarget.dataset.id
        console.log('event.target.checked*>>>' + JSON.stringify(event.target.checked));

        /* let i;
            let checkboxes = this.template.querySelector('[data-id='+event.currentTarget.dataset.id+']')
            for(i=0; i<checkboxes.length; i++) {
                checkboxes[0].checked = event.target.checked;
           }
                 console.log('this.checkboxes>>>'+JSON.stringify(this.checkboxes));
                 console.log('event.target.checked*>>>'+JSON.stringify(event.target.checked));
    */
        //  this.showBool= !this.showBool;
        //console.log('this.showBool>>>'+JSON.stringify(this.showBool));
        console.log('event.target.checked*>>>' + JSON.stringify(event.target.checked));
        var fiRecd = event.currentTarget.dataset.key;
        console.log('fiRecd??' + JSON.stringify(fiRecd));

        var pop = false;
        event.target.checked ? this.selectedRecord.push(fiRecd) : pop = true;
        if (pop) {
            const index = this.selectedRecord.indexOf(fiRecd);
            console.log('this.index>>>' + JSON.stringify(index));

            if (index > -1) { // only splice array when item is found
                this.selectedRecord.splice(index, 1); // 2nd parameter means remove one item only
            }
        }

        console.log('this.selectedRecord>>>' + JSON.stringify(this.selectedRecord));
        //  console.log('this.selectedRecord.length>>>'+JSON.stringify(this.selectedRecord.length));



    }
    get handleNextButton() {
        // console.log('this.selectedRecord.length>>>' + JSON.stringify(this.selectedRecord.length));
        // return this.selectedRecord.length > 0 ? false : true;
        if(this.isReTrigger){
            return (!this.selectedAddressIds.length>0)

        }
        else {
            return this.selectedRecord.length > 0 ? false : true;
        }
        
    }
    get handleAssignButton() {
        return this.userId.length > 0 ? false : true;

    }
    get gethandleAssignToMeButton() {
        return this.userId.length > 0 ? true : false;

    }
    handleUserId(event) {
        this.userId = event.target.value;
        console.log('userId>>>' + this.userId.length);
    }
    handleOnLoad() {
        this.isLoaded = true;
    }
    renderedCallback() {
        this.isLoaded = true;

    }
    handleAgentCode(event) {
        this.agentCode = event.target.value;
    }
    assignToCM() {
        updateOwner({ CmId: this.CMUserId, lstFi: this.selectedRecord , loanId : this.recordId })
            .then(result => {
                if (result.isSuccess) {
                    this.template.querySelector('c-common-toast').showToast('success', '<strong>' + result.message + '<strong/>', 'utility:success', 10000);
                    this.isModalOpen = false;
                }
                else {
                    this.template.querySelector('c-common-toast').showToast('warning', '<strong>' + result.message + '<strong/>', 'utility:warning', 10000);

                }
            })
            .catch(error => {
                console.log('this.error>>>>>' + JSON.stringify(error));
                let errorMessage = error.hasOwnProperty('body')?error.body.message:JSON.stringify(error);

                this.template.querySelector('c-common-toast').showToast('Error', '<strong>' + errorMessage+ '<strong/>', 'utility:error', 10000);
            });
    }
    assignFiAgent() {
       

        updateOwner({ userId: this.userId, lstFi: this.selectedRecord,loanId : this.recordId })
            .then(result => {
                if (result.isSuccess) {
                    this.template.querySelector('c-common-toast').showToast('success', '<strong>' + result.message + '<strong/>', 'utility:success', 10000);
                    this.isModalOpen = false;
                }
                else {
                    this.template.querySelector('c-common-toast').showToast('warning', '<strong>' + result.message + '<strong/>', 'utility:warning', 10000);

                }
            })
            .catch(error => {
                console.log('this.error>>>>>' + JSON.stringify(error));
                console.log('this.error.message>>>>>' + JSON.stringify(error.body.message));
                let errorMessage = error.hasOwnProperty('body')?error.body.message:JSON.stringify(error);
                this.template.querySelector('c-common-toast').showToast('Error', '<strong>' + errorMessage + '<strong/>', 'utility:error', 10000);
            });
    }

    addressRecords = [];
    dataTableColumns = [{
        label: 'Applicant Name',
        fieldName: 'applicantName',
        type: 'text',
    },
    {
        label: 'Applicant Type',
        fieldName: 'applicantType',
        type: 'text',
    },
    {
        label: 'Address Type',
        fieldName: 'addressType',
        type: 'text',
    },
    {
        label: 'Address',
        fieldName: 'address',
        type: 'text',
    }]

    getRelatedApplicantAddresses(){
        if(this.objectApiName!='Loan_Application__c'){
            return;
        }
        getLoanRelatedAddress({
            recordId : this.recordId
        })
        .then(res=>{
            console.log('res '+JSON.stringify(res));
            this.addressRecords = [];
            if(res && res.length){
                this.addressRecords = res;
                //alert('YASH '+JSON.stringify(this.addressRecords));
            }
        })
        .catch(err=>{
            console.log('err '+JSON.stringify(err));
        })

    }

    @track selectedAddressIds = [];
    handleTableRowSelection(evt){
        this.selectedAddressIds = [];
        var selected = this.template.querySelector('lightning-datatable').getSelectedRows();
        for (const key in selected) {
            this.selectedAddressIds.push(selected[key].addressRecId);
        }
        console.log('test '+JSON.stringify(this.selectedAddressIds))

    }

    handleMobileAddressSelect(evt){
        let addressRecordsLocal = this.addressRecords;
        addressRecordsLocal.forEach(rec=>{
            if(rec.addressRecId == evt.currentTarget.dataset.id){
                rec.checked = evt.target.checked; 
            }
        })
        this.addressRecords = addressRecordsLocal;
        this.setAddressIdsForMobile();
    }

    handleSelectAllReTriggerMobile(){
        let addressRecordsLocal = this.addressRecords;
        addressRecordsLocal.forEach(rec=>{
            rec.checked = true;
        })
        this.addressRecords = addressRecordsLocal;
        this.setAddressIdsForMobile();
    }

    setAddressIdsForMobile(){
        if(this.isMobile){
            this.selectedAddressIds=[];
            this.addressRecords.forEach(rec=>{
                if(rec.checked){
                    this.selectedAddressIds.push(rec.addressRecId)
                }
            })
        }

    } 

    getFi() {
        if (this.objectApiName != 'Field_Investigation__c')
        //alert('object nme '+this.objectApiName);
            getRelatedFI({ recordId: this.recordId, objectName: this.objectApiName })
                .then(result => {
                    console.log('fi record '+JSON.stringify(result));
                    if (result.isSuccess) {

                        let tempRecords = JSON.parse(JSON.stringify(result.lstFI));
                        tempRecords = tempRecords.map(row => {
                            let pincode = '';
                            if(row.hasOwnProperty('Address_lookup__r')){
                                let addressValue = row.Address_lookup__r;
                                if(addressValue.hasOwnProperty('Pincode__c')){
                                    pincode = addressValue.Pincode__c;

                                }
                            }
                            return { ...row, OwnerName: row.Owner.Name, Pincode: pincode, ApplicationName: row.Loan_Application__r.Name };
                        })
                        this.FIRecords = tempRecords;
                        console.log('FIRecords>>>' + JSON.stringify(this.FIRecords));

                    }
                    else {
                        if(this.isfirstPage && !this.isReTrigger){
                            console.log('call from here');
                            this.template.querySelector('c-common-toast').showToast('warning', '<strong>' + result.message + '<strong/>', 'utility:warning', 10000);

                        }
                        

                    }
                })
                .catch(error => {
                    console.log('this.error>>>>>' + JSON.stringify(error));
                    this.template.querySelector('c-common-toast').showToast('Error', '<strong>' + error + '<strong/>', 'utility:error', 10000);

                });
    }
    get getButtonLabel(){

        return this.isReTrigger ?'Re Trigger FI':'Re Assign FI';
    }
    handleReTrigger(){
        this.setAddressIdsForMobile();
        if(!this.selectedAddressIds){
            this.template.querySelector('c-common-toast').showToast('Error', '<strong>' + 'Please select a address record to continue' + '<strong/>', 'utility:Error', 10000);
            return;
        }
        var loanApplicationId;
        
        if(this.FIRecords){
             loanApplicationId=this.FIRecords[0].Loan_Application__c;
        }
        else{
            if(this.objectApiName == 'Loan_Application__c'){
                loanApplicationId = this.recordId;
            }
        }
        console.log('starte'+loanApplicationId+' '+this.selectedAddressIds);

        fetchRelatedApplicantAddress({recordId:loanApplicationId, blnRetriggerFI: true, lstFiIds: [], lstAddressIds:this.selectedAddressIds })
                .then(result => {
                    console.log('result$$' + JSON.stringify(result));

                    this.template.querySelector('c-common-toast').showToast('success', '<strong>Success<strong/>', 'utility:success', 10000);
                    this.isModalOpen=false;
                    /* if (result.isSuccess) {

                        let tempRecords = JSON.parse(JSON.stringify(result.lstFI));
                        tempRecords = tempRecords.map(row => {
                            return { ...row, OwnerName: row.Owner.Name, Pincode: row.Address_lookup__r.Pincode__c, ApplicationName: row.Loan_Application__r.Name };
                        })
                        this.FIRecords = tempRecords;
                        console.log('FIRecords>>>' + JSON.stringify(this.FIRecords));

                    }
                    else {
                        this.template.querySelector('c-common-toast').showToast('warning', '<strong>' + result.message + '<strong/>', 'utility:warning', 10000);

                    }*/
                })
                .catch(error => {
                    console.log('this.error>>>>>' + JSON.stringify(error));
                    this.template.querySelector('c-common-toast').showToast('Error', '<strong>' + error + '<strong/>', 'utility:Error', 10000);

                });
    }
    connectedCallback() {
        // console.log('reTrigger>>>>'+this.isReTrigger+' '+this.isRetriggerPermission+' '+this.isReassignPermission);
        // this.enableDisableActionButton = !((this.isReTrigger)?this.isRetriggerPermission:this.isReassignPermission);
        this.getUserAssignedPermissions();
        
        if (FORM_FACTOR == 'Small') {
            this.isMobile = true;
        }
        else {
            this.isMobile = false;
        }

        if (this.objectApiName == 'Field_Investigation__c') {
            this.isfirstPage = false;
            this.selectedRecord.push(this.recordId);
        }
        this.getFi();
        this.getRelatedApplicantAddresses();
    }

    getUserAssignedPermissions(){
        getUserAssignedPermissions({})
        .then(res=>{ 
            this.isRetriggerPermission = res.isRetriggerPermission;
            this.isReassignPermission = res.isReassignPermission;
            this.isRenderPermissionSetCOmplete = true;  
            this.enableDisableActionButton = !((this.isReTrigger)?this.isRetriggerPermission:this.isReassignPermission);  
            if(this.currentUserProfileName == 'Field Investigator' && this.applicationRecordType == 'Four Wheeler'){
                this.showReassign = true;
            }
            console.log('perm set '+JSON.stringify(res))
        })
        .catch(err=>{
            console.log('err'+JSON.stringify(err));
    
        })
    }
    handleNextPrevious(event) {
        /* if(!this.isMobile){
             this.selectedRecord = this.template.querySelector('lightning-datatable').getSelectedRows();
         }
         this.isLoaded = false;
         var selectedRecord = this.template.querySelector('lightning-datatable').getSelectedRows();
         this.selectedRecord = selectedRecord;
         console.log("getSelectedRows => ", JSON.stringify(this.template.querySelector('lightning-datatable').getSelectedRows()));
         this.fiRecordId = selectedRecord[0].Id;
         // this.userId=selectedRecord[0].Owner.Id;
         // this.ownerName=selectedRecord[0].Owner.Name;
         this.isfirstPage = false;
         // this.fiName=selectedRecord[0].Name;*/
        this.isfirstPage = !this.isfirstPage;
        if (event.currentTarget.dataset.id == 'previous') {
            this.selectedRecord = [];
            this.userId = '';
        }


        //  this.selectedRecord

    }

    async handleSave(event) {

        const updatedFields = event.detail.draftValues;

        await updateAccounts({ data: updatedFields })
            .then(result => {

                console.log(JSON.stringify("Apex update result: " + result));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Account(s) updated',
                        variant: 'success'
                    })
                );

                refreshApex(this.wiredRecords).then(() => {
                    this.draftValues = [];
                });

            }).catch(error => {

                console.log('Error is ' + JSON.stringify(error));
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating or refreshing records',
                        message: error.body.message,
                        variant: 'error'
                    })
                );

            });

    }

}