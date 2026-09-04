import { LightningElement, api } from 'lwc';
import upsertData from '@salesforce/apex/LoanDetailsController.upsertData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class VpiEmiScheduleChild extends LightningElement {

    @api stageNumber
    @api loanApp;
    @api keyId;
    @api addSchedule;
    emiSchedule={}
    isSaved;
    @api isRecordSaved

    emiScheduleValue
    @api 
    get insertedEmiSchedule(){
        return this.emiScheduleValue
    }

    set insertedEmiSchedule(value){
        this.emiScheduleValue=value
        if(value && Object.keys(value).length>0){
            this.emiSchedule=JSON.parse(JSON.stringify(value))
            this.isSaved=true
        }else{
            this.emiSchedule={}
            this.isSaved=false
        }
    }


    connectedCallback(){
        if(this.emiSchedule && Object.keys(this.emiSchedule).length<=0){
            this.emiSchedule.Stage_Number__c = this.stageNumber
            this.emiSchedule.Loan_Application__c=this.loanApp.Id
            
        }
            
    }

    handleChange(event){
        this.emiSchedule[event.target.name]=event.target.value
        this.isSaved=false
    }

    handleValidations() {
        var valid;
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {
            valid = true
        } else {
            valid = false;
        }
        return valid;
    }

    saveSchedule(){

        if(this.handleValidations()){
            console.log('EMI Schedule '+JSON.stringify(this.emiSchedule))
            upsertData({schedule: this.emiSchedule, recordId: this.loanApp.Id, tenure: this.loanApp.Tenure__c}).then((data)=>{
                this.emiSchedule=data
                console.log(JSON.stringify(data))
                this.isSaved=true
                this.dispatchEvent(new CustomEvent('saveschedule',{
                    detail: {
                        data:data,
                        key: this.keyId,
                        isSaved: this.isSaved
                    }
                }));
            }).catch((error)=>{
                this.showToastMessage('Error',error.body.message,'error')
            })
        }else{
            this.showToastMessage('Error','Please fill All the Mandatory Details','error')
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
        this.addSchedule=true
        this.dispatchEvent(new CustomEvent('rowaction',{
            detail:{
                isAdd: this.addSchedule,
                key: this.keyId,
                isSaved: this.isSaved,
                data: this.emiSchedule
            }
            
        }));
        
    }

    handleReject(){
        this.addSchedule=false
        this.dispatchEvent(new CustomEvent('rowaction',{
            detail:{
                isAdd: this.addSchedule,
                key: this.keyId,
                isSaved: this.isSaved,
                data: this.emiSchedule
            }
            
        }));
    }
}