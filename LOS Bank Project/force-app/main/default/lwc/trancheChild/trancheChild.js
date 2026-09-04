import { LightningElement, api, track } from 'lwc';
import getVisibleFieldsForLoanDetails from '@salesforce/apex/TrancheController.getVisibleFieldsForLoanDetails'
import upsertData from '@salesforce/apex/TrancheController.upsertData'
import deleteTranche from '@salesforce/apex/TrancheController.deleteTranche'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';

export default class TrancheChild extends LightningElement {

    @api trancheNumber
    @api loanApp;
    @api keyId;
    @api addTranche;
    trancheRecord={}
    isSaved=true
    @api isRecordSaved

    recordEmptyFields = ['Loan_Application__c','Tranche_Number__c'];
    trancherecordValue
    @api 
    get insertedTrancheRecord(){
        return this.trancherecordValue
    }

    set insertedTrancheRecord(value){
        this.trancherecordValue=value
        if(value && Object.keys(value).length>0){
            this.trancheRecord=JSON.parse(JSON.stringify(value))
            if(this.trancheRecord.Id){
                this.isSaved=true
            }else{
                this.isSaved=false
            }
            
        }else{
            this.trancheRecord={}
            this.isSaved=false
        }
    }


    connectedCallback(){
        this.getVisibleFields()
        if(this.trancheRecord && Object.keys(this.trancheRecord).length<=0){
            this.trancheRecord.Tranche_Number__c = this.trancheNumber
            
        }
        
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

    getVisibleFields(){
        getVisibleFieldsForLoanDetails({ strScreen :'Tranche Details', strStage :'DDE', strProfile :''  })
        .then(result => {
            console.log('result is '+JSON.stringify(result));
            result.forEach(input => {
                this.template.querySelectorAll('[data-id="'+input+'"]').forEach(element =>{
                    element.classList.remove('slds-hide');
                })
            });
            
        })
        .catch(error => {
            console.log('result is '+error);
        })

    }

    handleChange(event){
        if(event.target.value){
            this.handleValidations()
        }
        this.trancheRecord[event.target.name]=event.target.value
        this.isSaved=false
    }

    saveTranche(){

        if(this.handleValidations()){
            if(!this.trancheRecord.Loan_Application__c){
                this.trancheRecord.Loan_Application__c=this.loanApp.Id
            }

            console.log('EMI Schedule '+JSON.stringify(this.trancheRecord))
            this.isSaved=true
            upsertData({tranche: this.trancheRecord}).then((data)=>{
                this.trancheRecord=data
    
                console.log(JSON.stringify(data))
                this.dispatchEvent(new CustomEvent('savetranche',{
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
            this.showToastMessage('Error','Please fill all the Mandatory Details','error')
        }
        
    }

    deleteTranche(){
        console.log('EMI Schedule '+JSON.stringify(this.trancheRecord))
        if(this.trancheRecord.Id){
            deleteTranche({recordId: this.trancheRecord.Id}).then((data)=>{
                this.trancheRecord=data
                console.log(JSON.stringify(data))
                this.dispatchEvent(new CustomEvent('deletetranche',{
                    detail: {
                        data:data,
                        key: this.keyId
                    }
                }));
            }).catch((error)=>{
                this.showToastMessage('Error',error.body.message,'error')
            })
        }else{
            this.dispatchEvent(new CustomEvent('deletetranche',{
                detail: {
                    data:this.trancheRecord,
                    key: this.keyId
                }
            }));
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

    handleEditRejectAction(value){
        this.addTranche=value
        this.dispatchEvent(new CustomEvent('rowaction',{
            detail:{
                data:this.trancheRecord,
                isAdd: this.addTranche,
                key: this.keyId,
                isSaved: this.isSaved
            }
            
        }));
        
    }

    handleRowAction(){
        this.handleEditRejectAction(true)
    }

    handleReject(){
        if(Object.keys(this.trancheRecord).length==1 && Object.keys(this.trancheRecord)[0]==='Tranche_Number__c'){
            this.deleteTranche()
        }else{
            this.handleEditRejectAction(false)
        }
        
        
    }
}