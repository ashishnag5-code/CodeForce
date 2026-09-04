import { LightningElement,track,api,wire } from 'lwc';
import searchLoanApplication from '@salesforce/apex/DocumentTrackerController.searchLoanApplication';
import saveRecords from '@salesforce/apex/DocumentTrackerController.saveRecords';
import checkForLoanDispatchJS from '@salesforce/apex/DocumentTrackerController.checkForLoanDispatch';

import { getRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ProfileName from '@salesforce/schema/User.Profile.Name';
import Id from '@salesforce/user/Id';
import DocumentTracker_Dispatch_to_RPC from '@salesforce/resourceUrl/DocumentTracker_Dispatch_to_RPC';
import DocumentTracker_Dispatch_to_CPC from '@salesforce/resourceUrl/DocumentTracker_Dispatch_to_CPC';
import DocumentTracker_Not_Received from '@salesforce/resourceUrl/DocumentTracker_Not_Received';
import DocumentTracker_Received_at_RPC from '@salesforce/resourceUrl/DocumentTracker_Received_at_RPC';
import DocumentTracker_Received_at_CPC from '@salesforce/resourceUrl/DocumentTracker_Received_at_CPC';
import DocumentTracker_Send_to_Store from '@salesforce/resourceUrl/DocumentTracker_Send_to_Store';
import { refreshApex } from '@salesforce/apex';
import { RefreshEvent } from 'lightning/refresh';
import { updateRecord } from 'lightning/uiRecordApi'

// Custom Spinner settings
import { getSpinnerImage } from 'c/customSpinner';
// Custom Spinner settings


export default class AusfDocumentTrackerCmp extends LightningElement {
    searchKey;
    isloading = false;
    @track title='';
    @track userProfileName;
    @track isRO = false;
    @track isRPCCPC = false;
    @track isRPC = false;
    @track isCPC = false;
    @track showTable = false;
    showSelectedTable = true;
    @track isStatusSelected = false;
    @track showInputFields = true;
    @track showInputFieldsRO = true;
    @track searchField = '';
    @track loanApps;
    @track typeValue='';
    @track searchFieldRPC='';
    @track courierDate = '';
    @track awbNumber = '';
    @track RPCQueueName = '';
    @track isRIT = false;
    //rpcName='';
    courierName = '';
    remarksValue = '';
    isNonStatusScreen = true;
    @track searchOptions = [{label:'Loan Number', value: 'Loan Number'},{label:'Phone Number',value:'Phone Number'},{label:'LAN',value:'LAN'},{label:'Application ID',value:'Application ID'},{label:'Customer Name',value:'Customer Name'}];
    @track searchOptionsRPC = [{label:'Loan Number', value: 'Loan Number'},{label:'AWB Number',value:'AWB Number'},{label:'Phone Number',value:'Phone Number'},{label:'LAN',value:'LAN'},{label:'Application ID',value:'Application ID'},{label:'Customer Name',value:'Customer Name'}];
    @track typeOptions = [{label:'Physical File Tracker', value: 'Physical_File_Tracker'},{label:'Repayment Instrument Tracker',value:'Repayment_Instrument_Tracker'}];
    @track selectedRows = [];
    @track columns = [
        {label:'SF Application ID' , fieldName:'ApplicationId'},
        {label:'AWB Number', fieldName:'AWBNumber'},
        {label:'Product Name' , fieldName:'Product' },
        {label:'Customer Name' , fieldName:'CustomerName' },
        {label:'Loan Account Number' , fieldName:'AccountNumber'},
        {label:'Dealer Name' , fieldName:'DealerName'},
        {label:'RO Name and Employee ID' , fieldName:'RODetails'},
        {label:'Branch' , fieldName:'Branch'},
        {label:'Hub' , fieldName:'BranchHub'},
        {label:'State' , fieldName:'BranchState'},
        {label:'LAN' , fieldName:'LAN'} ,
        /*{label:'Add details' , fieldName:'Add details',
        type: 'url',
        typeAttributes: {
            rowActions: 'Add Details',
            menuAlignment: 'right'
        }
        },*/
        {
            type: "button", typeAttributes: {  
            label: 'Add Details',  
            name: 'Add Details',  
            title: 'Add Details',  
            disabled: false,  
            value: 'add',   variant:"base"
            } 
        }
    ]
    @track columnsPFT = [
        {label:'SF Application ID' , fieldName:'ApplicationId'},
        {label:'AWB Number', fieldName:'AWBNumber'},
        {label:'Product Name' , fieldName:'Product' },
        {label:'Customer Name' , fieldName:'CustomerName' },
        {label:'Loan Account Number' , fieldName:'AccountNumber'},
        {label:'Dealer Name' , fieldName:'DealerName'},
        {label:'RO Name and Employee ID' , fieldName:'RODetails'},
        {label:'Branch' , fieldName:'Branch'},
        {label:'Hub' , fieldName:'BranchHub'},
        {label:'State' , fieldName:'BranchState'},
        {label:'LAN' , fieldName:'LAN'} 
    ]
    @track columnsRO = [
        {label:'SF Application ID' , fieldName:'ApplicationId'},
        {label:'Customer Name' , fieldName:'CustomerName' },
        {label:'Stage', fieldName:'Stage'},
        {label:'Loan Amount', fieldName:'LoanAmount'},
        {label:'LAN' , fieldName:'LAN'}  ,
        {
            type: "button", typeAttributes: {  
            label: 'Add Details',  
            name: 'Add Details',  
            title: 'Add Details',  
            disabled: false,  
            value: 'add',  variant:"base"
            } 
        }
    ]

    @track columnsPFTRO = [
        {label:'SF Application ID' , fieldName:'ApplicationId'},
        {label:'Customer Name' , fieldName:'CustomerName' },
        {label:'Stage', fieldName:'Stage'},
        {label:'Loan Amount', fieldName:'LoanAmount'},
        {label:'LAN' , fieldName:'LAN'}
    ]

    @track columnsViewStatus = [
        {label:'SF Application ID' , fieldName:'ApplicationId'},
        {label:'Customer Name' , fieldName:'CustomerName' },
        {label:'Product Name' , fieldName:'Product' },
        {label:'Application Status', fieldName:'applicationStatus'}
        
    ]
    tablecolumn = [];
    @track selectedLoanApps = [];
    @track appStatusOptions = [{label:'Dispatch to RPC',value:'Dispatch to RPC'},{label:'Dispatch to CPC from RPC/COM',value:'Dispatch to CPC from RPC/COM'}];
    //@track dispatchOptions = [{label:'RPC',value:'RPC'},{label:'CPC',value:'CPC'}];
    docTrackerObj = {};
    @track dispatchToRPCLogoUrl = DocumentTracker_Dispatch_to_RPC;
    @track dispatchToCPCLogoUrl = DocumentTracker_Dispatch_to_CPC;
    @track receivedAtRPCLogoUrl = DocumentTracker_Received_at_RPC;
    @track receivedAtCPCLogoUrl = DocumentTracker_Received_at_CPC;
    @track sendToStoreLogoUrl = DocumentTracker_Send_to_Store;
    @track notReceivedLogoUrl = DocumentTracker_Not_Received;
    @track today;
   
    //pooja 
    selectedLoanId ='';
    showLoanDetail = false;
    selectedEMIStatus;
    selectedDocType;
    selectedEMIOpt;
    EMIOptions = [
        { label: 'Cash', value: 'Cash' },
        { label: 'Cheque', value: 'Cheque' },
        { label: 'Online', value: 'Online'},
    ];
    DocTypeOptions = [
        { label: 'NEW', value: 'NEW' },
        { label: 'OTC', value: 'OTC' },
        { label: 'Additional', value: 'Additional' },
    ];
    EMIStatusOptions = [
        { label: 'CPC', value: 'CPC' },
        { label: 'RPC', value: 'RPC' },
        { label: 'Branch', value: 'Branch' },
    ];

    async handleRowActions(event) {
        const recId =  event.detail.row.Id;  
        const actionName = event.detail.action.name;  
        if ( actionName === 'Add Details' ) {
            this.showLoanDetail=true;
            console.log('default value '+event.detail.row.docType);
            console.log('default value '+event.detail.row.firstEMIStatus);
            var i = this.loanApps.findIndex(row => row.Id == event.detail.row.Id)
            if(!this.loanApps[i].docType){
                this.selectedDocType = 'NEW';
            }
            else{
                this.selectedDocType=this.loanApps[i].docType;
            }
            if(!this.loanApps[i].firstEMIStatus){
                this.selectedEMIStatus = 'CPC';
            }
            else{
                this.selectedEMIStatus=this.loanApps[i].firstEMIStatus;
            }
            this.selectedLoanId = recId;
            await this.spinnerImageMethod(this.selectedLoanId);

            console.log('wrap obj '+JSON.stringify(event.detail.row));
            this.RPCQueueName = event.detail.row.RPCQueueName;
        }

        console.log('recId--- ', this.showLoanDetail);
        console.log('actionName--- ', actionName);
    }

     // Custom Spinner settings
     async spinnerImageMethod(selectedLoanId) {
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(selectedLoanId);
        }
    }
    // Custom Spinner settings
    
    closeModal(){
        this.showLoanDetail = false;
    }
    recordToSave;
    
    handleFormSuccess(){
        this.closeModal();
        this.showToast('Success','Record updated successfully!', 'success');
        this.dispatchEvent(new RefreshEvent());
    }
    showToast(title, message ,variant) {
        // Handle any custom form success logic here (if needed)
        // For example, show a toast message on successful record save
        const toastEvent = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: variant === 'error' ? 'sticky' : 'dismissible'
        });
        this.dispatchEvent(toastEvent);
    }
    //Ended Pooja
    @wire(getRecord, { recordId: Id, fields: [ProfileName] })
    userDetails({ error, data }) {
        if (error) {
            this.error = error;
        } else if (data) {
            if (data.fields.Profile.value != null) {
                this.userProfileName = data.fields.Profile.value.fields.Name.value;
                console.log('profile name '+this.userProfileName);
                if(this.userProfileName=='Sales' || this.userProfileName=='COM' || this.isRO ){//|| this.userProfileName=='System Administrator'){
                    this.isRO = true;
                    this.searchOptions = [{label:'Loan Number', value: 'Loan Number'},{label:'Phone Number',value:'Phone Number'},{label:'LAN',value:'LAN'},{label:'Application ID',value:'Application ID'},{label:'Customer Name',value:'Customer Name'}];
                }  
                else if(this.userProfileName=='Operations' || this.isRPCCPC){
                    console.log('rpc cpc');
                    this.isRPCCPC = true;
                }
                else if(this.userProfileName=='System Administrator'){
                    this.isRO = true;
                }

                if(this.isRO){
                    this.tablecolumn = this.columnsRO;
                }else{
                    this.tablecolumn = this.columns;
                }
            }
        }
    }
    
    connectedCallback(){
        console.log('In Document Tracker');
        this.today = new Date().toISOString().slice(0,10);
        //this.dispatchOptions = this.dispatchTo.data.values;
    }
    handlePicklistChange(event){
        console.log('event '+JSON.stringify(event.target.fieldName)+' '+event.target.value);
        var i = this.loanApps.findIndex(row => row.Id == this.selectedLoanId);
        if(event.target.fieldName=='FirstEMI_Status__c'){
            this.loanApps[i]['firstEMIStatus'] = event.target.value;
        }
        if(event.target.fieldName=='Document_Type__c'){
            this.loanApps[i]['docType']= event.target.value;
        }
    }
    handleSearchKey(event){
        this.searchKey = event.detail.value;
    }

    handleChange(event){
        console.log('value '+event.detail.value);
        if(event.target.name=='SearchBy'){
            this.searchField = event.detail.value;
            this.searchKey = '';
            this.loanApps = [];
            this.selectedLoanApps = [];
            this.showTable = false;
        }
        else if(event.target.name=='RecordType'){
            this.typeValue = event.detail.value;   
            this.loanApps = [];
            this.selectedLoanApps = [];     
            if(this.typeValue=='Repayment_Instrument_Tracker' && this.appStatusValue!='View Status'){
                this.isRIT = true;
                if(this.isRO){
                    this.tablecolumn = this.columnsRO;
                }
                else{
                    this.tablecolumn = this.columns;
                }
            }
            else if(this.appStatusValue!='View Status'){
                this.isRIT = false;
                if(this.isRO){
                    this.tablecolumn = this.columnsPFTRO;
                }
                else{
                    this.tablecolumn = this.columnsPFT;
                }
            }
        }
        else if(event.target.name=='Courier_Date__c'){
            this.courierDate = event.detail.value;
        }
        else if(event.target.name=='AWB_Number__c'){
            this.awbNumber = event.detail.value;
        }
        // else if(event.target.name=='Assigned_RPC__c'){
        //     this.rpcName = event.detail.value;
        // }
        else if(event.target.name=='Courier_Name__c'){
            this.courierValue = event.detail.value;
        }
        else if(event.target.name=='Remarks__c'){
            this.remarksValue = event.detail.value;
        }
    }

    SearchLoanApplication(onLoad){
        this.isloading = true;
        this.showTable = true;
        console.log('searchby '+this.searchField);
        console.log('Type '+this.typeValue);
        if(this.searchField=='' || this.typeValue==''){
            const event = new ShowToastEvent({
                title: 'Error',
                message:'Please select Search by and Type option first',
                variant:'error',
                mode : 'sticky'
            });
            this.dispatchEvent(event);
            this.isloading = false;
            return;
        } 
       /* if(this.searchKey=='' || this.typeValue==''){
            this.loanApps = [];
            return;
        } */ 
        let userProfile = '';
        if(this.isRO){
            userProfile = 'RO';
        }
        else if(this.isRPCCPC){
            userProfile = 'RPCCPC';
        }
        searchLoanApplication({
            searchKey: this.searchKey,
            searchBy: this.searchField,
            type: this.typeValue,
            userProfile: userProfile,
            buttonName: this.appStatusValue
        })
        .then(data =>{
            console.log('data '+JSON.stringify(data));
            this.loanApps = data;
            this.isloading = false;
            if(data?.length==0 && !onLoad){
                const event = new ShowToastEvent({
                    title: 'Error',
                    message:'Data not found',
                    variant:'error',
                    mode : 'sticky'
                });
                this.dispatchEvent(event);
                this.showTable = false;
            }else if(data?.length==0){
                this.showTable = false;
            }
        })
        .catch(error =>{
            console.log('error '+JSON.stringify(error));
            const event = new ShowToastEvent({
                title: 'Error',
                message: JSON.stringify(error),
                variant:'error',
                mode : 'sticky'
            });
            this.dispatchEvent(event);
            this.isloading = false;
        })
    }

    getSelectedRow(event){
        let selectedRow = event.detail.selectedRows;
        if(event.detail.selectedRows==null && event.detail.config==null){
            return;
        }
        this.selectedRows = event.detail.selectedRows.map(row => row.Id);
        console.log('event '+JSON.stringify(event.detail));
        console.log('selected row '+JSON.stringify(selectedRow));
        this.selectedLoanApps = this.selectedLoanApps.slice();
        if(event.detail.config.selection=='selectAllRows'){
            this.selectedLoanApps = [];
            for(var i=0;i<selectedRow.length;i++){
                selectedRow[i]['row'] = event.detail.config.value;
                this.selectedLoanApps.push(selectedRow[i]);
            }
            return;
        }
        else if(event.detail.config.selection=='deselectAllRows'){
            this.selectedLoanApps = [];
            return;
        }
        let index = -1; 
        let rowNo=''; 
        for(var i=0;i<selectedRow.length;i++){
            if(selectedRow[i].Id == event.detail.config.value){
                if(this.selectedLoanApps.findIndex(row => row.Id == event.detail.config.value)<0){
                    rowNo = event.detail.config.value;
                    index = i;
                    console.log('add----- '+i+' '+rowNo);
                    break;
                }
            }
        }
        if(selectedRow[0]!=null && index!=-1){
            selectedRow[index]['row'] = event.detail.config.value;
            this.selectedLoanApps.push(selectedRow[index]);
        }
        else{
            console.log('delete row '+event.detail.config.value);
            this.selectedLoanApps.splice(this.selectedLoanApps.findIndex(row => row.row == event.detail.config.value), 1);
        }
        console.log('selectedLoanApps '+JSON.stringify(this.selectedLoanApps));
    }

    saveRecord(){
        if (this.courierDate !== null && this.courierDate !== undefined) {
            let courierDateInst = Date.parse(this.courierDate);
            if (courierDateInst > new Date()) {
                const event = new ShowToastEvent({
                    title: 'Error',
                    message:'Courier Date cannot be a future date',
                    variant:'error',
                    mode : 'sticky'
                });
                this.dispatchEvent(event);
                return;
            }
        }
        if(this.selectedLoanApps.length==0){
            const event = new ShowToastEvent({
                title: 'Error',
                message:'Please select Loan Applications first',
                variant:'error',
                mode : 'sticky'
            });
            this.dispatchEvent(event);
            return;
        }
        var flag = true;
        const elements1 = this.template.querySelectorAll('lightning-combobox');
        elements1.forEach( input => {
            //console.log('lightning-combobox element input-->'+input.name);
            //console.log('lightning-combobox element value input-->'+input.value); 
            this.docTrackerObj[input.name] = input.value;
            if(input.value=='' || input.value==null || input.value==='undefined') {
                input.setCustomValidity("Please fill all the mandatory fields");
            }
            else{
                input.setCustomValidity('');
            }
            input.reportValidity();
        });
        const elements2 = this.template.querySelectorAll('lightning-input');
        elements2.forEach( input => {
            //console.log('lightning-combobox element input-->'+input.name);
            //console.log('lightning-combobox element value input-->'+input.value); 
            this.docTrackerObj[input.name] = input.value;
            if((input.value=='' || input.value==null || input.value==='undefined') && input.name!='searchKey') {
                input.setCustomValidity("Please fill all the mandatory fields");
                flag = false;
            }
            else{
                input.setCustomValidity('');
            }
            input.reportValidity();
        });
        /** for 3131 */
        const elements3 = this.template.querySelectorAll('lightning-textarea');
        elements3.forEach( input => {
            this.docTrackerObj[input.name] = input.value;
        });
        console.log('docTrackerObj--- ',JSON.stringify (this.docTrackerObj));
        this.docTrackerObj['Application_Status__c'] = this.appStatusValue;
        if(flag){
            let userProfile = '';
            if(this.isRO){
                userProfile = 'RO';
            }
            else if(this.isRPCCPC){
                userProfile = 'RPCCPC';
            }
            
            console.log('selectedLoanApps '+JSON.stringify(this.selectedLoanApps));
            console.log('docTrackerObj '+JSON.stringify(this.docTrackerObj));
            if(this.typeValue=='Repayment_Instrument_Tracker'){
                this.checkForLoanDispatch(userProfile);
            }
            else{
                this.saveRecordJS(userProfile);
            }
            
        }
    }
    //Pooja 
    saveRecordJS(userProfile){
        saveRecords({
                loanAppsList: this.selectedLoanApps,
                docTrackerObj : this.docTrackerObj,
                userProfile : userProfile
            })
            .then(data =>{
                console.log('save records '+JSON.stringify(data));
                if(data!=null && data.includes('Success')){
                    const event = new ShowToastEvent({
                        title: 'Success',
                        message:'Records submitted successfully',
                        variant:'success'
                    });
                    this.dispatchEvent(event);
                    this.courierDate = '';
                    this.awbNumber = '';
                    this.searchField = '';
                    this.searchKey = '';
                    this.selectedLoanApps = [];
                    this.loanApps = [];
                    this.typeValue = '';
                    //this.rpcName = '';
                    this.courierName = '';
                    this.remarksValue = '';
                    this.showTable = false;
                    this.dispatchEvent(new RefreshEvent());
                }
                //window.location.reload();
            })
            .catch(error =>{
                console.log('error saving records '+JSON.stringify(error));
                const event = new ShowToastEvent({
                    title: 'Error',
                    message:'Something went wrong',
                    variant:'error',
                    mode : 'sticky'
                });
                this.dispatchEvent(event);
            })
    }
    checkForLoanDispatch(userProfile){
        checkForLoanDispatchJS({
                loanAppsList: this.selectedLoanApps
            })
            .then(data =>{
                console.log('data-- ', data)
                if(data.length >0){
                var msg = 'Selected loan(s) '+data+' is/are not ready to dispatch';
                 const event = new ShowToastEvent({
                    title: 'Error',
                    message:msg,
                    variant:'error',
                    mode : 'sticky'
                });
                this.dispatchEvent(event);
                }else{
                    this.saveRecordJS(userProfile);
                }
            })
            .catch(error =>{
                console.log('error saving records '+JSON.stringify(error));
                const event = new ShowToastEvent({
                    title: 'Error',
                    message:'Something went wrong',
                    variant:'error',
                    mode : 'sticky'
                });
                this.dispatchEvent(event);
            })
    }
    showForm(event){
        console.log('event.detail '+JSON.stringify(event.currentTarget.name));
        this.appStatusValue = event.currentTarget.name;
        this.isStatusSelected = true;
        this.title = event.currentTarget.name;
        var searchFieldTemp = 'Loan Number';
        this.isNonStatusScreen = true;
        if(event.currentTarget.name.includes('Received') || event.currentTarget.name.includes('Disbursed')){
            this.showInputFields = false;
        }
        else{
            this.showInputFields = true;
            
        }
        if(event.currentTarget.name.includes('View Status')){
            debugger;
            this.isNonStatusScreen = false;
            this.showInputFields = false;
            this.showInputFieldsRO = false;
            var options = [{label:'AWB Number', value: 'AWB Number'},{label:'LAN',value:'LAN'},{label:'Application ID',value:'Application ID'}];
            if(this.isRO){
                this.searchOptions = options;
            }
            if(this.isRPCCPC){
                this.searchOptionsRPC = options;
            }
            searchFieldTemp = 'AWB Number';
            this.showSelectedTable =false;
            this.tablecolumn = this.columnsViewStatus;
        }else{
             this.showSelectedTable = true;
             this.showInputFieldsRO = true;
        }

        if(event.currentTarget.name.includes('Store')){
            this.typeOptions = [{label:'Physical File Tracker', value: 'Physical_File_Tracker'}];
        }
        else{
            this.typeOptions = [{label:'Physical File Tracker', value: 'Physical_File_Tracker'},{label:'Repayment Instrument Tracker',value:'Repayment_Instrument_Tracker'}];
        }
        if(this.isRO){
            this.searchField = searchFieldTemp;
            this.typeValue = 'Physical_File_Tracker';
            this.searchKey = '';
            if(this.appStatusValue!='View Status'){
                this.tablecolumn = this.columnsPFTRO;
            }
            this.SearchLoanApplication(true);
        }
        else if(this.isRPCCPC){
            this.searchField = searchFieldTemp;
            this.typeValue = 'Physical_File_Tracker';
            this.searchKey = '';
            if(this.appStatusValue!='View Status'){
                this.tablecolumn = this.columnsPFT;
            }
            this.SearchLoanApplication(true);
        }
    }
    loadPreviousScreen(){
        this.isStatusSelected = false;
        this.courierDate = '';
        this.awbNumber = '';
        this.searchField = '';
        this.searchKey = '';
        //this.rpcName = '';
        this.courierName = '';
        this.remarksValue = '';
        this.selectedLoanApps = [];
        this.loanApps = [];
        this.typeValue = '';
        this.showTable = false;
        this.reset();
    }

    reset(){
        if(this.isRO){
            this.searchOptions = [{label:'Loan Number', value: 'Loan Number'},{label:'Phone Number',value:'Phone Number'},{label:'LAN',value:'LAN'},{label:'Application ID',value:'Application ID'},{label:'Customer Name',value:'Customer Name'}];
            this.tablecolumn = this.columnsRO;
         }

         if(this.isRPCCPC){
            this.searchOptionsRPC = [{label:'Loan Number', value: 'Loan Number'},{label:'AWB Number',value:'AWB Number'},{label:'Phone Number',value:'Phone Number'},{label:'LAN',value:'LAN'},{label:'Application ID',value:'Application ID'},{label:'Customer Name',value:'Customer Name'}];
            this.tablecolumn = this.columns;
        }
    }
}