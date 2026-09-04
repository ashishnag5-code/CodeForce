import { LightningElement,track,api } from 'lwc';
import deleteRecord from '@salesforce/apex/NotepadComponentController.deleteRecord';
import saveRecord from '@salesforce/apex/NotepadComponentController.saveRecord';
import getApplicantData from '@salesforce/apex/NotepadComponentController.getApplicantData';
import getNotes from '@salesforce/apex/NotepadComponentController.getNotes';
import getValidRecordId from '@salesforce/apex/OpsSummaryPageController.getValidRecordId';
import sendNotepadDetails from '@salesforce/apex/NotepadComponentController.sendNotepadDetails';
import getRelatedApplicants from '@salesforce/apex/NotepadComponentController.getRelatedApplicants';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { getSpinnerImage } from 'c/customSpinner';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';

export default class AusfNotepadComponent extends NavigationMixin(LightningElement) {
    @api spinnerImage;
    @api recordId;
    @track addIcon = true;
    @track addReferencesScreen = false;
    @track notesStartDate;
    @track noteTypeCust = false;
    @track noteTypeLoan = false;
    @track cif;
    @track applicant;
    @track loanId;
    @track isLoading;
    @track notepadData = {};
    cbsData = {};
    @track notesList;
    @track addFetchScreen=false;
    @track applicantOptions = [];
    @track appId;
    @track applicantValue;
    @track columns = [
        {label : 'SRL No.', fieldName : 'rowNumber',type : 'number'},
        { label: 'Type', fieldName: 'Note_Type__c' },
        //{ label: 'Name', fieldName: 'Name' },
        { label: 'Reason for Notes', fieldName: 'Reason_for_Notes__c'},
        { label: 'Severity', fieldName: 'Severity__c'},
        { label: 'Notes Date', fieldName: 'CreatedDate'},
        { label: 'Notes Start Date', fieldName: 'Notes_Start_Date__c' },
        { label: 'Notes End Date', fieldName: 'Notes_End_Date__c'},
        { label: 'EMP Code & Name', fieldName: 'Emp_Code_Name__c'},
        { label: 'Notes', fieldName: 'Notes__c'},
        { label: 'Source', fieldName: 'Source__c'},
        {
            type: 'action',
            typeAttributes: { rowActions: this.getRowActions },
        },
    ];
    @track disableFetch=false;
    @track fetchApplicantOptions=[];
    
   connectedCallback(){
        this.getRecordLoanApplicationId();
        
    }

    getRecordLoanApplicationId(){
        getValidRecordId({
            assignmentId : this.recordId
        })
        .then(res=>{
            this.recordId = res;
            if(this.spinnerImage == undefined){
                this.spinnerImage = getSpinnerImage(this.recordId);
            }
            this.isLoading = true;
            this.fetchRecords();
            this.getApplicants();
        })
    }

    //Bug4031 changes start here
    handleStartDateChange(event){
        let selected = new Date(event.target.value);
        let min = new Date();
        min.setHours(0, 0, 0, 0);
        if (selected < min)
            this.dispatchEvent(new ShowToastEvent({
                title: 'Enter valid date',
                variant: 'error',
                message: 'Start date cannot be past date',
                mode : 'sticky'
            }));
    }
    handleEndDateChange(event){
        let startDate = new Date(this.template.querySelector('lightning-input-field[data-id="StartDate"').value);
        startDate.setHours(0, 0, 0, 0);
        let endDate = new Date(event.target.value);
        if (endDate < startDate){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Enter valid date',
                variant: 'error',
                message: 'End date cannot be less than start date'
            }));
        }
    }
    //Bug4031 changes end here

    getApplicants(){
        getRelatedApplicants({
            loanId:this.recordId
        })
        .then(data =>{
            console.log('data in applicants  '+JSON.stringify(data));
            let options = [];
            let fetchOptions = [];
            for (var key in data) {
                options.push({
                    label: data[key].First_Name__c+' '+data[key].Last_Name__c,
                    value: data[key].Id
                });
                if(data[key].Existing_Customer__c=='Yes'){
                    fetchOptions.push({
                        label: data[key].First_Name__c+' '+data[key].Last_Name__c,
                        value: data[key].Id
                    });
                }
            }
            this.applicantOptions = options;
            this.fetchApplicantOptions = fetchOptions;
            console.log('fetch applicant option '+this.fetchApplicantOptions);
            if(this.fetchApplicantOptions.length==0){
                this.disableFetch = true;
            }

        })
        .catch(error=>{
            console.log('error '+JSON.stringify(error));
        })
    }

    addCreateScreenIcon(){
        this.cif = '';
        this.noteTypeCust = false;
        this.noteTypeLoan = false;
        const date = new Date();
        console.log('date '+date);
        var current_date = date.getFullYear()+"-"+(date.getMonth()+1)+"-"+ date.getDate();
        console.log(current_date); 
        this.notesStartDate = current_date;
        this.addReferencesScreen = true;
        this.addFetchScreen=false;
    }

    fetchRecords(){
        getNotes({
            loanId:this.recordId
        })
        .then(data => {
            console.log('notes data '+JSON.stringify(data));
            //this.fetchData = data;
            let result = JSON.parse(JSON.stringify(data));
            console.log('result==> ' + JSON.stringify(result));
            

            for(var i=0; i<result.length; i++){
                result[i].rowNumber = i+1;
            }
            this.notesList = result;
            this.isLoading = false;
        })
        .catch(error => {
            console.log('error in notes '+JSON.stringify(error));
        })
        console.log('notelist '+JSON.stringify(this.notesList));
    }

    showFetchScreen(){
        this.addFetchScreen = true;
        this.addReferencesScreen = false;
    }

    fetchCBSData(){
        this.isLoading = true;
        let noteData = {};
        noteData['Customer_ID__c'] = this.cif;
        console.log('noteData in fetchCBSData '+JSON.stringify(noteData));
        sendNotepadDetails({
            notepadData:noteData,
            action:'i',
            loanId: this.recordId,
            appId: this.appId
        })
        .then(data=> {
            this.isLoading = false;
            console.log('cbsdata '+JSON.stringify(data));
            if(data==null){
                const event = new ShowToastEvent({
                    title: 'Error',
                    message:'Something went wrong',
                    variant:'error',
                    mode : 'sticky'
                });
                this.dispatchEvent(event);
            }
            else if(data?.TransactionStatusType?.ResponseMessage=='Failure'){
                let msg = data?.TransactionStatusType?.ExtendedErrorDetails?.messages?.message;
                console.log('msg '+msg);
                const event = new ShowToastEvent({
                    title: 'Error',
                    message: msg,
                    variant:'error',
                    mode : 'sticky'
                });
                this.dispatchEvent(event);
            }
            else{
                this.cbsData = data;
                this.fetchRecords();
                this.isLoading = false; 
            }
        })
        .catch(error=> {
            console.log(JSON.stringify(error));
        })
    }

    handleCancel(event) {
        this.addReferencesScreen   = false;
        this.addIcon               = true;
        this.addFetchScreen = false;
        this.appId = '';
        this.applicantValue = '';
    }
    handleChange(event){
        console.log('event.target.name '+event.target.name+' '+event.target.value);
        if(event.target.fieldName=='Note_Type__c'){
            if(event.detail.value=='Customer ID'){
                this.noteTypeCust = true;
                this.noteTypeLoan = false;
                this.applicantValue = '';
            }
            else if(event.detail.value=='Loan ID'){
                this.noteTypeLoan  = true;
                this.noteTypeCust = false;
                this.loanId = this.recordId;
                this.applicantValue = '';
                this.cif = '';
            }
            else{
                this.noteTypeLoan  = false;
                this.noteTypeCust = false;
                this.applicantValue = '';
                this.cif = '';
            }
        }
        if(event.target.name=='Applicant__c' ){
            console.log('applicant id '+event.detail.value);
            var id = ''+event.detail.value;
            this.applicantValue = id;
            this.getCIFId(id);
        }
        if(event.target.name=='Applicant'){
            var id = ''+event.target.value;
            this.appId = id;
            this.getCIFId(id);
        }

    }
    getCIFId(id){
        getApplicantData({
            applicantId: id
        })
        .then(data => {
            console.log('Applicant '+JSON.stringify(data));
            this.cif = data[0].CIF_No__c;
        })
        .catch(error=>{
            console.log(JSON.stringify(error));
        })
    }
    handleSave(){
        restricAccess({
            compName: 'ausfNotepadComponent' ,loanId: this.recordId
            })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save Notepad',
                        variant: 'error',
                        mode : 'sticky'
                    });
                    this.dispatchEvent(evt);
                }else{
        this.addReferencesScreen = false;
        this.notepadData = {};
        const elements = this.template.querySelectorAll('lightning-input-field');
            elements.forEach( input => {
                console.log('lightning-input-field element input-->'+input.name);
                console.log('lightning-input-field element value input-->'+input.value);
                var name = input.name;
                this.notepadData[name]=input.value;
            });
            //Bug4031 changes start here
            let min = new Date();
            min.setHours(0, 0, 0, 0);
            console.log('start date '+this.notepadData['Notes_Start_Date__c']);
            let startDate = new Date(this.notepadData['Notes_Start_Date__c']);
            let endDate = new Date(this.notepadData['Notes_End_Date__c'])
            if (startDate < min){
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Enter valid date',
                    variant: 'error',
                    message: 'Start date cannot be past date',
                    mode : 'sticky'
                }));
                this.addReferencesScreen = true;
                return;
            }
            if (endDate < startDate){
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Enter valid date',
                    variant: 'error',
                    message: 'End date cannot be less than start date',
                    mode : 'sticky'
                }));
                this.addReferencesScreen = true;
                return;
            }
            //Bug4031 changes end here

            this.notepadData['Applicant__c'] = this.applicantValue;
            this.applicantValue = '';
            this.notepadData['Source__c'] = 'Salesforce';
            this.notepadData['Severity__c'] = 'L';
            console.log('notepad data ------ '+JSON.stringify(this.notepadData));
        if(/*this.notepadData['Name']==null || this.notepadData['Name']=='' ||*/ this.notepadData['Note_Type__c']==null || this.notepadData['Note_Type__c']=='' || (this.noteTypeLoan==true && this.notepadData['Loan_Application__c']===null) || (this.noteTypeCust==true && this.notepadData['Applicant__c']==null)){
            console.log('inside if');
            const event = new ShowToastEvent({
                title: 'Error',
                message:'Please complete the required fields',
                variant:'error',
                mode : 'sticky'
            });
            this.dispatchEvent(event);
        }
        else{
            saveRecord({
                notepadData: this.notepadData,
            })
            .then(data =>{
                console.log('data '+JSON.stringify(data));
                /*sendNotepadDetails({
                    notepadData: this.notepadData,
                    action:'a',
                    loanId: this.recordId,
                    appId: this.notepadData['Applicant__c']
                })
                .then(data=> {
                    console.log('insert data '+JSON.stringify(data));
                    
                })
                .catch(error=> {
                    console.log(JSON.stringify(error));
                })*/
                const event = new ShowToastEvent({
                    title: 'Success',
                    message:'Record Saved Successfully',
                    variant:'Success'
                });
                this.dispatchEvent(event);
                
                this.fetchRecords();
            })
            .catch(error =>{
                console.log('error in saving '+JSON.stringify(error));
            })
        }
    }
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
            })
        
    }
    getRowActions(row, doneCallback){
        const actions = [];
            if (row['Source__c']!='CBS') {
                actions.push({
                    'label': 'Edit',
                    'name': 'edit'
                });
                actions.push({
                    'label': 'Delete',
                    'name': 'delete'
                });
            } else {
                actions.push({
                    'label': 'No Action',
                    'name': 'No Action'
                });
            }
            setTimeout(() => {
                doneCallback(actions);
            }, 200);
    }
    handleRowAction(event) {
        const row = event.detail.row;
        console.log('row '+JSON.stringify(row));
            const actionName = event.detail.action.name;
            console.log('row '+JSON.stringify(row));
            switch (actionName) {
                case 'delete':
                    this.deleteRow(row);
                    break;
                case 'edit':
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: row.Id,
                            objectApiName: 'Notepad__c',
                            actionName: 'edit'
                        }
                    });
                    break;
                default:
            }
        //}
    }

    deleteRow(row) {
        const { id } = row;
        console.log(row);
        deleteRecord({
            recordId:row.Id
        })
        .then(data => {
            const event = new ShowToastEvent({
                title: 'Success',
                message:'Record deleted Successfully',
                variant:'Success'
            });
            this.dispatchEvent(event);
           this.fetchRecords();
        })
        .catch(error => {
            console.log('delete failed '+JSON.stringify(error));
        })
        
    }
    
    showRowDetails(row) {
        this.record = row;
    }
}