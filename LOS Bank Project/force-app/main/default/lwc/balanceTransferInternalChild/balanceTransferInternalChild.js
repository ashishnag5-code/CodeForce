import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import upsertData from '@salesforce/apex/BalanceTransferController.upsertData'
import deleteBT from '@salesforce/apex/BalanceTransferController.deleteBT'

export default class BalanceTransferInternalChild extends LightningElement {
    @api addBT;

    @api productDetails
    @api loanApp;
    @api keyId;
    btRecord={}
    isSaved;
    @api isRecordSaved
    @api productType
    @api type

    @api collateral

    @track btLoanStatusOptions
    btValue
    @api 
    get insertedBt(){
        return this.btValue
    }

    set insertedBt(value){
        this.btValue=value
        if(value && Object.keys(value).length>0){
            this.btRecord=JSON.parse(JSON.stringify(value))
        }
        else{
            this.btRecord={}
        }
    }

    
    
    connectedCallback(){

        if(this.btRecord && Object.keys(this.btRecord).length<=0){
            this.btRecord.Loan_Application__c=this.loanApp.Id
            this.btRecord.keyId=this.keyId
            this.btRecord.isSaved=false
            this.btRecord.BT_Type__c='Internal'
            this.btRecord.POS__c=this.collateral.POS__c
            this.btRecord.Loan_Number__c=this.collateral.Linked_Account_Number__c
        }
        
        this.btLoanStatusOptions=[]
        if(this.type==='Cash on Wheels'){
            this.btLoanStatusOptions.push({label:'Adjustment by this Loan',value:'Adjustment by this Loan'})
            this.btLoanStatusOptions.push({label:'Closed by Customer',value:'Closed by Customer'})
        }
        if(this.type==='Used'){
            this.btLoanStatusOptions.push({label:'Top Up',value:'Top Up'})
            this.btLoanStatusOptions.push({label:'Fore Closure Refinance',value:'Fore Closure Refinance'})
        }
    }

    handleChange(event){
        this.btRecord[event.target.name]=event.target.value
        this.isSaved=false
    }

    saveBT(){
        console.log('BT '+JSON.stringify(this.btRecord))
        var key = this.btRecord.keyId
        upsertData({bt: this.btRecord}).then((data)=>{
            this.btRecord=data
            console.log(JSON.stringify(data))
            this.isSaved=true
            this.dispatchEvent(new CustomEvent('savebt',{
                detail: {
                    data:data,
                    key: key,
                    isSaved: this.isSaved
                }
            }));
        }).catch((error)=>{
            this.showToastMessage('Error',error.body.message,'error')
        })
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
        this.addBT=true
        this.dispatchEvent(new CustomEvent('rowaction',{
            detail:{
                isAdd: this.addBT,
                key: this.btRecord.keyId,
                isSaved: this.isSaved,
                data: this.btRecord
            }
            
        }));
        
    }

    handleReject(){
        this.addBT=false
        this.dispatchEvent(new CustomEvent('rowaction',{
            detail:{
                isAdd: this.addBT,
                key: this.btRecord.keyId,
                isSaved: this.isSaved,
                data: this.btRecord
            }
            
        }));
    }

    deleteBT(){
        console.log('BT '+JSON.stringify(this.btRecord))
        var key = this.btRecord.keyId
        if(this.btRecord.Id){
            deleteBT({recordId: this.btRecord.Id}).then((data)=>{
                this.btRecord=data
                console.log(JSON.stringify(data))
                this.dispatchEvent(new CustomEvent('deletebt',{
                    detail: {
                        data:data,
                        key: key
                    }
                }));
            }).catch((error)=>{
                this.showToastMessage('Error',error.body.message,'error')
            })
        }else{
            this.dispatchEvent(new CustomEvent('deletebt',{
                detail: {
                    data:this.btRecord,
                    key: key
                }
            }));
        }
        
    }
}