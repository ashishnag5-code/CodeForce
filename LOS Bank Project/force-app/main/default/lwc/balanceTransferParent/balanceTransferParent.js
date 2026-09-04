import { LightningElement, track, api } from 'lwc';
import getInternalBTDetails from '@salesforce/apex/BalanceTransferController.getInternalBTDetails'
import upsertData from '@salesforce/apex/BalanceTransferController.upsertData'
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import deleteBT from '@salesforce/apex/BalanceTransferController.deleteBT'


export default class BalanceTransferInternalParent extends LightningElement {
    
    addBT=true;
    @api btType;
    @api fieldsToBeDisabled;
    @track totalPOS=0
    keyIndex=0;
    @track recordCount=0
    @api loanApp;
    @api collateral
    @api productDetails
    @api btCaseType
    key=0
    btMap=new Map()
    collateralVSbtMap=new Map()
    type
    @track btList=[]
    btRecord={}
    loanVsPOSMap=new Map()
    loadIt=false
    @track hideSection=false
    @track readOnly=true
    @track isDelete=false
    isInternalBT=false
    isExternalBT=false
    @track btLoanStatusOptions=[]
    @track loanNumberOptions=[]
    instituteReadOnly=true
    displayButtons=true 

    connectedCallback(){
        this.initBTComponent()
    }

    initBTComponent(){
        this.btMap=new Map();
        this.btList=[]
        
        this.isInternalBT=this.btType==='Internal'?true:false

        //set  BT Loan Status
        if(this.collateral){
            //this.type = this.productDetails.get(this.collateral.Product__c).Sub_Product__c
            if(this.btType==='Internal'){
                this.btLoanStatusOptions=[]
                if(this.btCaseType==='Cash on Wheels'){
                    this.btLoanStatusOptions.push({label:'Top Up',value:'Top Up'})
                    this.btLoanStatusOptions.push({label:'Fore Closure Refinance',value:'Fore Closure Refinance'})
                    
                }else if(this.btCaseType==='Used'){
                    this.btLoanStatusOptions.push({label:'Adjustment by this Loan',value:'Adjustment by this Loan'})
                    this.btLoanStatusOptions.push({label:'Closed by Customer',value:'Closed by Customer'})
                }
            }
        }

        //set Loan Number
        if(this.collateral && this.collateral.Collateral_Search_Results__c){
            var collateralDets= JSON.parse(this.collateral.Collateral_Search_Results__c)
            collateralDets.forEach(input=>{
                this.loanVsPOSMap.set(input.AccountNumber,input.CollateralUnusedValue)
                
            })
            Array.from(this.loanVsPOSMap.keys()).forEach(input=>{
                this.loanNumberOptions.push({label:input,value:input})
            })
        }

        

        //get existing BT Record Details
        getInternalBTDetails({recordId: this.loanApp.Id, type:this.btType}).then((data=>{
            this.loadIt=true
            this.btMap = new Map()
            this.keyIndex=0
            if(data.bTRecordList && data.bTRecordList.length>0){
                this.keyIndex=0
                data.bTRecordList.forEach(input => {
                    input.isChecked=false
                    input.key =this.keyIndex
                    var instituteTempId = data.instituteList.filter(function (element) {
                        return element.Bank_Name__c == input.Financial_Institute_Name__c
                    })
                    input.InstituteId = instituteTempId[0].Id
                    
                    this.btMap.set(input.key, input)
                    this.keyIndex++
                });
                this.btList = Array.from(this.btMap.values())  
                this.recordCount = this.btList.length
                this.totalPOS=0
                this.calculateTotals()

            }
        }))
        console.log('initial details '+JSON.stringify(this.btList))

        if(this.fieldsToBeDisabled && this.fieldsToBeDisabled.length>0){
            this.displayButtons=false
            this.fieldsToBeDisabled.forEach((input=>{
                if(this.template.querySelectorAll('[data-name="'+input+'"]')){
                    this.template.querySelectorAll('[data-name="'+input+'"]').forEach((inputToBeDisabled=>{
                        inputToBeDisabled.disabled = true
                        inputToBeDisabled.classList.add('slds-p-left_small')
                    }))
                } 
            }))
        }
        
    }
    
    handleEdit(){
        this.readOnly=false
        this.instituteReadOnly=false
    }
    
    handleOpenSection(){
        this.hideSection=false
    }

    handleHideSection(){
        this.hideSection=true
    }

    handleAddNewBTInternalRecord(){

        this.keyIndex++
        this.key=this.keyIndex;
        
        var newRecord = {key:this.key, BT_Type__c:this.btType, Loan_Application__c:this.loanApp.Id, isChecked:false}
        if(this.btType==='Internal'){
            newRecord.Financial_Institute_Name__c='Au Small Finance Bank Limited'
        }
        this.btMap.set(this.keyIndex, newRecord)
        this.btList = Array.from(this.btMap.values())
        
    }

    handleChange(event){
        var accesskey = parseInt(event.target.accessKey)
        var record = this.btMap.get(accesskey)
        if(event.target.name==='isChecked'){
            record[event.target.name]=event.target.checked
            this.checkedCount=event.target.checked==true?this.checkedCount+1:this.checkedCount-1
            this.isDelete=this.checkedCount==0?false:true
        }else if(event.target.name==='NOC_before_Disbursement__c'){
            record[event.target.name]=event.target.checked
        }else if(event.target.name==='Loan_Number__c'){
            record[event.target.name]=event.target.value
            record.POS__c=this.loanVsPOSMap.get(event.target.value)
            this.calculateTotals()
        }else{
            record[event.target.name]=event.target.value
        }
        this.btMap.set(accesskey, record)
        this.btList = Array.from(this.btMap.values()) 
        if(event.target.name=='BT_Amount__c'){
            this.calculateTotals()
        }
    }

    /*isValid=true
    handleChanges(event){
        this.btMap.set(event.detail.record.keyId, event.detail.record)
        if(!(event.detail.valid && this.isValid)){
            this.isValid=false
        }
    }*/

    showToastMessage(titleValue, messageValue, variantValue){

        const event = new ShowToastEvent({
            title: titleValue,
            message: messageValue,
            variant: variantValue
        });
        this.dispatchEvent(event);

    }

    handleLookupSelect(event){
        var record = this.btMap.get(event.detail.key)
        record.Financial_Institute_Name__c=event.detail.name
        this.btMap.set(event.detail.key, record)
        this.btList = Array.from(this.btMap.values())
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

    handleSave(event){
        if(this.handleValidations()){
            console.log('this.btList '+JSON.stringify(this.btList))
            this.btList=Array.from(this.btMap.values())
            upsertData({bt: this.btList, loanId: this.loanApp.Id, type:this.btType, collateralId:this.collateral.Id}).then((data)=>{
                this.updateModifiedData(data);
            }).catch((error)=>{
                this.showToastMessage('Error',error.body.message,'error')
            })
        }else{
            this.showToastMessage('Error','Please Fill the Mandatory Details','error')
        }

    }

    @api getUnsavedData(){
        if(!this.readOnly){
            return true
        }else{
            return false
        }
    }

    handleDeleteAction(event){

        this.btList=Array.from(this.btMap.values())
        this.checkedCount=0
        this.isDelete=false
        var updateDeletedRecordsWithId=[]
        var updateNonDeletedRecordsWithIds=[]
        var updateNonDeletedRecordsWithoutIds=[]

        this.btList.forEach(element=>{
            if(element.isChecked){
                if(element.Id){
                    updateDeletedRecordsWithId.push(element.Id)
                }
                this.btMap.delete(element.key)
            }else{
                if(element.Id)
                    updateNonDeletedRecordsWithIds.push(element)
                else{
                    updateNonDeletedRecordsWithoutIds.push(element)
                }
            }
        })

        this.btList=Array.from(this.btMap.values())

        if(updateDeletedRecordsWithId.length>0){
            deleteBT({recordIds: updateDeletedRecordsWithId, loanId: this.loanApp.Id, type:this.btType}).then((data)=>{
                this.updateModifiedData(data)
                updateNonDeletedRecordsWithoutIds.forEach(input=>{
                    //if(!input.Id)
                    this.btMap.set(input.key, input)

                })
                this.btList=Array.from(this.btMap.values())
                
            })
        }else{
            this.btMap=new Map()
            this.keyIndex=0
            updateNonDeletedRecordsWithIds.forEach(input=>{
                input.key=this.keyIndex
                this.keyIndex++
                this.btMap.set(input.key, input)
            })
            updateNonDeletedRecordsWithoutIds.forEach(input=>{
                input.key=this.keyIndex
                this.keyIndex++
                this.btMap.set(input.key, input)
            })
            this.btList=Array.from(this.btMap.values())
        }
        this.recordCount = this.btList.length
        this.calculateTotals() 
    }

    

    updateModifiedData(data){
        this.keyIndex=0
        this.showToastMessage('Success','BT Records Updated Successfully','success')
        this.btMap=new Map();
        this.btList = []
        if(data.bTRecordList && data.bTRecordList.length>0){
            this.keyIndex=0
            data.bTRecordList.forEach(input => {
                var instituteTempId = data.instituteList.filter(function (element) {
                    return element.Bank_Name__c == input.Financial_Institute_Name__c
                })
                input.InstituteId = instituteTempId[0].Id
                input.key=this.keyIndex
                input.isChecked=false
                this.btMap.set(this.keyIndex, input)
                this.keyIndex++
        });
        this.readOnly=true
        this.instituteReadOnly=true
        this.btList = Array.from(this.btMap.values())  
        this.recordCount = this.btList.length
        refreshApex(this.btList);
        this.calculateTotals()
        }
    }

    /*@api
    getBTValidation(){
        var isUnsaved;      
        this.btList.forEach(input => {
            if(input.isSaved==false){
                isUnsaved=true
            }
        });   
        this.dispatchEvent(new CustomEvent('bt',{
            detail: {
                template:'BT Internal',
                isUnsaved: isUnsaved,
            }
        }));
            
    }*/

    calculateTotals(){
        this.totalPOS=0
        if(this.btType=='Internal'){
            this.btList.forEach(element=>{
                if(element.POS__c)
                    this.totalPOS=parseFloat(element.POS__c)+this.totalPOS
            })
        }
        if(this.btType=='External'){
            this.btList.forEach(element=>{
                if(element.BT_Amount__c)
                    this.totalPOS=parseFloat(element.BT_Amount__c)+this.totalPOS
            })
        }
        
    }

    /*handleSave(event){
        console.log('event.data '+JSON.parse(JSON.stringify(event.detail.data)))
        //event.detail.data.isSaved = event.detail.isSaved
        event.detail.data.keyId = event.detail.key
        this.btMap.set(event.detail.key, JSON.parse(JSON.stringify(event.detail.data)))
        //this.keyId=event.detail.key;
        this.btList = Array.from(this.btMap.values())
        this.recordCount = this.btList.length
        console.log('Bt list '+JSON.stringify(this.btList))
        //this.addBT=false
        this.calculateTotals()

    }*/

    /*handleRowAction(event){
        this.addBT=event.detail.isAdd
        event.detail.data.isSaved=event.detail.isSaved
        event.detail.data.keyId = event.detail.key
        this.btMap.set(event.detail.key, JSON.parse(JSON.stringify(event.detail.data)))
        this.btList = Array.from(this.btMap.values())
        if(this.addBT){
            this.btRecord =this.btMap.get(event.detail.key)
            //this.keyId=event.detail.key;

        }
    }*/

    /*handleDeleteAction(event){
        this.btMap.delete(event.detail.key)
        this.btList = Array.from(this.btMap.values())
        this.recordCount = this.btList.length
        this.addBT=false
        this.calculateTotals()
    }*/

    @api 
    checkIfAllLoanSelected(){
        return this.btList.length == this.loanNumberOptions.length;
    }
}