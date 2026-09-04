import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import upsertData from '@salesforce/apex/BalanceTransferController.upsertData'
import deleteBT from '@salesforce/apex/BalanceTransferController.deleteBT'
import getFinancialInstitutes from '@salesforce/apex/BalanceTransferController.getFinancialInstitutes'



export default class BalanceTransferInternalChild extends LightningElement {

    @api addBT;
    @api btType
    @api productDetails
    @api loanApp;
    @api keyId;
    @api isRecordSaved
    @api productType
    @api type
    @api collateral
    @api readOnly

    hideInpLabel=true
    @track btRecord={}
    loanVsPOSMap=new Map()
    instituteRecordTypeId

    @track loanNumberOptions=[]
    @track isInternal;
    @track loadIt=false
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

        
        this.isInternal=this.btType==='Internal'?true:false
        
        if(this.btRecord && Object.keys(this.btRecord).length==1){
            this.btRecord.Loan_Application__c=this.loanApp.Id
            this.btRecord.keyId=this.keyId
            this.btRecord.isChecked=false
            this.btRecord.BT_Type__c=this.btType
            if(this.btType==='Internal'){
                //this.btRecord.POS__c=this.collateral.POS__c
                //this.btRecord.Loan_Number__c=this.collateral.Linked_Account_Number__c
                this.btRecord.Financial_Institute_Name__c='Au Small Finance Bank Limited'
            }
            
        }
        getFinancialInstitutes({name:this.btRecord.Financial_Institute_Name__c}).then((data)=>{
            if(data[0] && data[0].Id){
                this.defaultInstitute=data[0].Id
            }
            this.loadIt=true
        })
        
        if(this.btType==='Internal'){
            this.btLoanStatusOptions=[]
            if(this.type==='Used'){
                this.btLoanStatusOptions.push({label:'Adjustment by this Loan',value:'Adjustment by this Loan'})
                this.btLoanStatusOptions.push({label:'Closed by Customer',value:'Closed by Customer'})
            }else if(this.type==='Cash on Wheels'){
                this.btLoanStatusOptions.push({label:'Top Up',value:'Top Up'})
                this.btLoanStatusOptions.push({label:'Fore Closure Refinance',value:'Fore Closure Refinance'})
            }
        }

        if(this.collateral && this.collateral.Collateral_Search_Results__c){
            var collateralDets= JSON.parse(this.collateral.Collateral_Search_Results__c)
            collateralDets.forEach(input=>{
                this.loanVsPOSMap.set(input.AccountNumber,input.CollateralUnusedValue)
                
            })
            Array.from(this.loanVsPOSMap.keys()).forEach(input=>{
                this.loanNumberOptions.push({label:input,value:input})
            })
        }
        

        
    }

    handleChange(event){

        if(event.target.name==='NOC_before_Disbursement__c'){
            this.btRecord[event.target.name]=event.target.checked
        }else if(event.target.name==='isChecked'){
            this.btRecord.isChecked=event.target.checked 

        }else{
            this.btRecord[event.target.name]=event.target.value
        }

        if(event.target.name==='Loan_Number__c'){
            this.btRecord.POS__c=this.loanVsPOSMap.get(event.target.value)
        }
        
    }

    @api
    getRecord(){
       
            this.dispatchEvent(new CustomEvent('recordchange',{
                detail:{
                    record:this.btRecord,
                    valid:this.handleValidations()
                }
            }
            ));
        
        
    }

    handleLookupSelect(event){
        this.btRecord.Financial_Institute_Name__c=event.detail.name
    }

    handleValidations(){
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
}