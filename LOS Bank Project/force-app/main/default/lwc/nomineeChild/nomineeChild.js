import { LightningElement, api, track, wire } from 'lwc';
import upsertData from '@salesforce/apex/NomineeController.upsertData' 
import deleteNominee from '@salesforce/apex/NomineeController.deleteNominee' 
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getSpinnerImage } from 'c/customSpinner';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import APPLICANT_OBJECT from '@salesforce/schema/Applicant__c';
import APPOINTEE_RELATIONSHIP from '@salesforce/schema/Applicant__c.Appointee_Relationship__c';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';//4733

export default class NomineeChild extends LightningElement {
    @api addNominee;
    @api relationOptions
    @api loanApp;
    @api keyId;
    nomineeRecord={}
    isSaved;
    @api isRecordSaved
    todaysDate=''
    @api spinnerImage;
    @track isLoading;
    @track showAppointee = false;
    @track isEditRestricted//4733
    nomineeValue
    @api 
    get insertedNominee(){
        return this.nomineeValue
    }

    set insertedNominee(value){
        this.nomineeValue=value
        if(value && Object.keys(value).length>0){
            this.nomineeRecord=JSON.parse(JSON.stringify(value))
            this.isSaved=true
        }else{
            this.nomineeRecord={}
            //this.nomineeRecord.keyId=this.keyId
            //this.nomineeRecord.Loan__c=this.loanApp.Id
            this.isSaved=false
        }
    }
    
    @wire(getObjectInfo, { objectApiName: APPLICANT_OBJECT })
    applicantMetadata;

    @wire(getPicklistValues,
        {
            recordTypeId: '$applicantMetadata.data.defaultRecordTypeId', 
            fieldApiName: APPOINTEE_RELATIONSHIP
        }
    )
    appointeeRelationshipPicklist;

    async connectedCallback(){
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.loanApp.Id);
        }
        var newDate = new Date()
        this.todaysDate = newDate.getFullYear() + '-' + (newDate.getMonth() + 1).toString().padStart(2, '0') + '-' + newDate.getDate().toString().padStart(2, '0');
        if(this.nomineeRecord && Object.keys(this.nomineeRecord).length<=0){  
            this.nomineeRecord.keyId=this.keyId
        }
        if(this.nomineeRecord?.Dob__c){
            let dob = new Date(this.nomineeRecord?.Dob__c);
            var diff_ms = Date.now() - dob.getTime();
            var age_dt = new Date(diff_ms); 
            let age = Math.abs(age_dt.getUTCFullYear() - 1970);
            console.log('age '+age);
            if(age<18){
                this.showAppointee = true;
            }
            else{
                this.showAppointee = false;
            }
        }
        //4733
        this.isEditRestricted = await restricAccess({compName: 'loanDetails' ,loanId: this.loanApp.Id})
    }

    handleChange(event){

        /*if(event.target.value){
            this.handleValidations()
        }*/
        console.log('inside');
        if(event.target.name == 'Profile__c'){

            console.log('inside 2');
            if(this.handleNomineeProfessionCheck(event.target.name,event.target.value)){
                return;
            }
        }
        if(event.target.name=='Dob__c'){
            let dob = new Date(event.target.value);
            var diff_ms = Date.now() - dob.getTime();
            var age_dt = new Date(diff_ms); 
            let age = Math.abs(age_dt.getUTCFullYear() - 1970);
            console.log('age '+age);
            if(age<18){
                this.showAppointee = true;
            }
            else{
                this.showAppointee = false;
            }
        }
        this.nomineeRecord[event.target.name]=event.target.value
        if(!this.isEditRestricted){//4733
            this.isSaved=false
        }
        
    }

    handleNomineeProfessionCheck(name,value){
        let checkField = this.template.querySelector('lightning-input[data-id="'+name+'"]');
        let regex = /^[a-zA-Z ]*$/;
        if(value != ''){
            if(!regex.test(value)){
                checkField.setCustomValidity("Please provide a valid input(Only Alphabets accepted)");
                this.isErrorResponse = true;

            }
            else{
                checkField.setCustomValidity("");
                this.isErrorResponse = false;
            }

        }
        else{
            checkField.setCustomValidity("");
            this.isErrorResponse = false;
        }
        return this.isErrorResponse;
        

    }

    handleValidations() {
        var valid;
        const allValid1 = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        const allValid2 = [
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid1 && allValid2) {
            valid = true
        } else {
            valid = false;
        }
        return valid;
    }

    saveNominee(){
        if(this.isEditRestricted){//4733
            this.showToastMessage('Access Restricted','You do not have access to change Nominee Details','error');
            return
        }
        if(this.showAppointee){
            let element = this.template.querySelector('lightning-input[data-id="Appointee_DoB__c"]');
            let dob = new Date(element.value);
            var diff_ms = Date.now() - dob.getTime();
            var age_dt = new Date(diff_ms); 
            let age = Math.abs(age_dt.getUTCFullYear() - 1970);
            console.log('age '+age);
            if(age<18){
                this.showToastMessage('Error','Age of Appointee cannot be less than 18','error');
                return;
            }
        }
        this.isLoading=true
        if(this.handleValidations()){
            if(!this.nomineeRecord.Loan__c){
                this.nomineeRecord.Loan__c=this.loanApp.Id
            }
            console.log('Nominee '+JSON.stringify(this.nomineeRecord))
            var key = this.nomineeRecord.keyId
            upsertData({nominee: this.nomineeRecord, recordId:this.loanApp.Id}).then((data)=>{
                this.isLoading=false
                this.nomineeRecord=data
                console.log(JSON.stringify(data))
                this.isSaved=true
                this.dispatchEvent(new CustomEvent('savenominee',{
                    detail: {
                        data:data,
                        key: key,
                        isSaved: this.isSaved
                    }
                }));
            }).catch((error)=>{
                this.isLoading=false
                this.showToastMessage('Error',error.body.message,'error')
            })
        }else{
            this.isLoading=false
            this.showToastMessage('Error','Your Input seems to be Invalid. Please enter correct details','error')
        }
        
    }

    showToastMessage(titleValue, messageValue, variantValue){

        const event = new ShowToastEvent({
            title: titleValue,
            message: messageValue,
            variant: variantValue
        });
        this.dispatchEvent(event);

    }

    handleRowAction(){
        this.addNominee=true
        this.dispatchEvent(new CustomEvent('rowaction',{
            detail:{
                isAdd: this.addNominee,
                key: this.nomineeRecord.keyId,
                isSaved: this.isSaved,
                data: this.nomineeRecord
            }
            
        }));
        
    }

    handleReject(){
        this.addNominee=false
        if(Object.keys(this.nomineeRecord).length==1){
            this.deleteNominee()
        }else{
            this.dispatchEvent(new CustomEvent('rowaction',{
                detail:{
                    isAdd: this.addNominee,
                    key: this.nomineeRecord.keyId,
                    isSaved: this.isSaved,
                    data: this.nomineeRecord
                }
                
            }));
        }
        
    }

    deleteNominee(){
        if(this.isEditRestricted){//4733
            this.showToastMessage('Access Restricted','You do not have access to delete Nominee Details','error');
            return
        }
        console.log('Nominee '+JSON.stringify(this.nomineeRecord))
        var key = this.nomineeRecord.keyId
        if(this.nomineeRecord.Id){
            deleteNominee({recordId: this.nomineeRecord.Id}).then((data)=>{
                this.nomineeRecord=data
                console.log(JSON.stringify(data))
                this.dispatchEvent(new CustomEvent('deletenominee',{
                    detail: {
                        data:data,
                        key: key
                    }
                }));
            }).catch((error)=>{
                this.showToastMessage('Error',error.body.message,'error')
            })
        }else{
            this.dispatchEvent(new CustomEvent('deletenominee',{
                detail: {
                    data:this.nomineeRecord,
                    key: key
                }
            }));
        }
        
    }
}