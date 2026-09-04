import { LightningElement, track, api } from 'lwc';
import getEmiDetails from '@salesforce/apex/LoanDetailsController.getEmiDetails';
import upsertData from '@salesforce/apex/LoanDetailsController.upsertData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import deleteEmiDetails from '@salesforce/apex/LoanDetailsController.deleteEmiDetails';
import { refreshApex } from '@salesforce/apex';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';//4733

export default class VpiParent extends LightningElement {

    @track scheduleList=[]
    keyIndex=0;
    @track recordCount=0
    stageNumber=1;
    @api loanApp;
    scheduleMap=new Map()
    deleteRecords=[]
    readOnly=true
    @track hideSection=false
    @track isEditRestricted//4733
    @track isDelete=false
    handleHideSection(){
        this.hideSection=true
    }
    handleOpenSection(){
        this.hideSection=false
    }

    async connectedCallback(){
        getEmiDetails({recordId: this.loanApp.Id}).then((data=>{
            if(data && data.length>0){
                this.keyIndex=0
                this.stageNumber=1
                data.forEach(input => {
                    input.key=this.keyIndex
                    input.isChecked=false
                    this.scheduleMap.set(this.keyIndex, input)
                    this.keyIndex++
                    this.stageNumber++
                });
                this.scheduleList = Array.from(this.scheduleMap.values())  
                this.recordCount = this.scheduleList.length
                this.readOnly=true
            }
        }))
        this.isEditRestricted = await restricAccess({compName: 'loanDetails' ,loanId: this.loanApp.Id})

    }

    handleEdit(){
        if(this.isEditRestricted){
            this.showToastMessage('Access Restricted','You do not have access to modify VPI Details','error','sticky')
            return
        }
        this.readOnly=false
    }

    handleReject(){
        this.readOnly=true
    }

    handleAddNewSchedule(){
        if(this.isEditRestricted){
            this.showToastMessage('Access Restricted','You do not have access to add VPI Details','error','sticky')
            return
        }
        this.scheduleMap.set(this.keyIndex, {key:this.keyIndex, Stage_Number__c:this.stageNumber,isChecked:false })
        this.scheduleList = Array.from(this.scheduleMap.values())  
        this.stageNumber++
        this.keyIndex++
    }

    handleValidations(){
        var valid;
        const allValid1 = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (allValid1) {
            valid = true
        } else {
            valid = false;
        }


        return valid;
    }

    checkedCount=0
    handleChange(event){

        var record = this.scheduleMap.get(event.target.accessKey)
        if(event.target.name==='isChecked'){
            record[event.target.name]=event.target.checked
            this.checkedCount=event.target.checked==true?this.checkedCount+1:this.checkedCount-1
            this.isDelete=this.checkedCount==0?false:true
        }else{
            record[event.target.name]=event.target.value
        }
        this.scheduleMap.set(event.target.accessKey, record)
        this.scheduleList = Array.from(this.scheduleMap.values())  

    }

    showToastMessage(titleValue, messageValue, variantValue, mode){

        const event = new ShowToastEvent({
            title: titleValue,
            message: messageValue,
            variant: variantValue,
            mode: mode
        });
        this.dispatchEvent(event);

    }

    @api
    calculateNoOfInstallments(){
        var total;
        if(this.loanApp.Emi_Frequency__c.toUpperCase().includes('MONTHLY')){
            total=this.loanApp.Tenure__c-1;
        }else if(this.loanApp.Emi_Frequency__c.toUpperCase().includes('HALF YEARLY') && this.loanApp.Schedule_Type__c=='VPI'){
            if(this.loanApp.Tenure__c%6==0){
                total=(this.loanApp.Tenure__c/6)
            }else{
                total=(Math.floor(this.loanApp.Tenure__c/6))+1;
            }
        }else if(this.loanApp.Emi_Frequency__c.toUpperCase().includes('HALF YEARLY') && this.loanApp.Schedule_Type__c=='EPI'){
            total=(this.loanApp.Tenure__c/6)
        }else if(this.loanApp.Emi_Frequency__c.toUpperCase().includes('QUARTERLY') && this.loanApp.Schedule_Type__c=='VPI'){
            if(this.loanApp.Tenure__c%3==0){
                total=(this.loanApp.Tenure__c/3)
            }else{
                total=(Math.floor(this.loanApp.Tenure__c/3))+1
            }
            
        }else if(this.loanApp.Emi_Frequency__c.toUpperCase().includes('QUARTERLY') && loanApp.Schedule_Type__c=='EPI'){
            total=(this.loanApp.Tenure__c/3)
        }
        return parseInt(total);
    }
    @api vpiValidation(){
        var list=[]
        var map=new Map()
        list=Array.from(this.scheduleMap.values())
        let totalInstAmount=0;
        list.forEach(element=>{
            map.set(element.Stage_Number__c, element.Installment_Number__c)
            totalInstAmount = totalInstAmount+parseFloat(element.Installment_Amount__c)
        })
        var mapAsc = new Map([...map.entries()].reverse());
        var total = this.calculateNoOfInstallments()
        /*if(this.loanApp.RecordType.Name=='Tractor'){
            if(this.loanApp.Emi_Frequency__c.toUpperCase().includes('MONTHLY')){
                total=this.loanApp.Tenure__c-1;
            }else if(this.loanApp.Emi_Frequency__c.toUpperCase().includes('HALF YEARLY')){
                total=Math.floor((this.loanApp.Tenure__c/6)-1);
            }else if(this.loanApp.Emi_Frequency__c.toUpperCase().includes('QUARTERLY')){
                total=Math.floor((this.loanApp.Tenure__c/3)-1);
            }
        }else{
            total=this.loanApp.Tenure__c-1
        }*/
        
        //var total=this.loanApp.Tenure__c-1;
        
        var isValid=true
        Array.from(mapAsc.values()).forEach(input=>{
            if(parseInt(input)<=total){
                total=input
            }else{
                isValid=false
            }
        })
        if(totalInstAmount>this.loanApp.Total_Loan_Amount__c){
            isValid=false
        }
        return isValid;
    }

    handleSave(){
        if(this.isEditRestricted){
            this.showToastMessage('Access Restricted','You do not have access to save/modify VPI Details','error', 'sticky')
            return
        }
        if(this.handleValidations()){
            var map=new Map()
            var totalInstAmount = 0
            var list=[]
            list=Array.from(this.scheduleMap.values())
            this.listToUpdate=[]
            list.forEach(element=>{
                element.Loan_Application__c=this.loanApp.Id
                this.listToUpdate.push(element)
                map.set(element.Stage_Number__c, parseInt(element.Installment_Number__c))
                totalInstAmount = totalInstAmount+ parseFloat(element.Installment_Amount__c);
            })
            var mapAsc = new Map([...map.entries()].reverse());
            //var total=this.loanApp.Tenure__c-1;
            var total;
            var noOfInst;
            var total = this.calculateNoOfInstallments();
            noOfInst=total
            /*if(this.loanApp.Emi_Frequency__c.toUpperCase().includes('MONTHLY')){
                total=this.loanApp.Tenure__c-1;
            }else if(this.loanApp.Emi_Frequency__c.toUpperCase().includes('HALF YEARLY')){
                total=Math.floor((this.loanApp.Tenure__c/6)-1);
            }else if(this.loanApp.Emi_Frequency__c.toUpperCase().includes('QUARTERLY')){
                total=Math.floor((this.loanApp.Tenure__c/3)-1);
            }*/
            var isValid=true
            Array.from(mapAsc.values()).forEach(input=>{
                if(parseInt(input)<=total){
                    total=input
                }else{
                    isValid=false
                }
            })
            if(totalInstAmount>this.loanApp.Total_Loan_Amount__c){
                isValid=false
            }
            if(isValid){
                upsertData({schedule: this.listToUpdate, recordId: this.loanApp.Id, tenure: parseInt(this.loanApp.Tenure__c)}).then((data)=>{
                    this.dispatchEvent(new CustomEvent('vpimodified',{
                        detail: {
                            modified: true
                        }
                    }));
                    this.updateModifiedData(data)
                })

            }else{
                //this.showToastMessage('Error','Please check the Upto Installment Sequence. Maximum Installments can be upto '+(this.loanApp.Tenure__c-1)+'. Total Installment Amount should be less than or equal to '+(this.loanApp.Total_Loan_Amount__c),'error')
                this.showToastMessage('Error','Please check the Upto Installment Sequence. Maximum Installments can be upto '+(noOfInst)+'. Total Installment Amount should be less than or equal to '+(this.loanApp.Total_Loan_Amount__c),'error','sticky')

            }
            
        }else{
            this.showToastMessage('Error','Please fill the Mandatory Details','error','sticky')
        } 
    }

    handleDeleteSelectedRows(){
        if(this.isEditRestricted){
            this.showToastMessage('Access Restricted','You do not have access to delete VPI Details','error','sticky')
            return
        }
        var updateDeletedRecordsWithId=[]
        var updateNonDeletedRecordsWithIds=[]
        var updateNonDeletedRecordsWithoutIds=[]
        this.isDelete=false
        this.scheduleList.forEach(element=>{
            if(element.isChecked){
                if(element.Id){
                    updateDeletedRecordsWithId.push(element.Id)
                }
                this.scheduleMap.delete(element.key)
            }else{
                if(element.Id)
                    updateNonDeletedRecordsWithIds.push(element)
                else{
                    updateNonDeletedRecordsWithoutIds.push(element)
                }
            }
        })

        this.scheduleList=Array.from(this.scheduleMap.values())

        if(updateDeletedRecordsWithId.length>0){
            deleteEmiDetails({recordIds: updateDeletedRecordsWithId, recordId: this.loanApp.Id}).then((data)=>{
                this.updateModifiedData(data)
                updateNonDeletedRecordsWithoutIds.forEach(input=>{
                    if(!input.Id)
                        this.scheduleMap.set(input.key, input)
                })
                this.scheduleList=Array.from(this.scheduleMap.values())
                this.dispatchEvent(new CustomEvent('vpimodified',{
                    detail: {
                        modified: true
                    }
                }));
                
            })
        }else{
            this.scheduleMap=new Map()
            this.stageNumber=1
            this.keyIndex=0
            updateNonDeletedRecordsWithIds.forEach(input=>{
                input.Stage_Number__c=this.stageNumber
                input.key=this.keyIndex
                this.stageNumber++
                this.keyIndex++
                this.scheduleMap.set(input.key, input)
            })
            updateNonDeletedRecordsWithoutIds.forEach(input=>{
                input.Stage_Number__c=this.stageNumber
                input.key=this.keyIndex
                this.stageNumber++
                this.keyIndex++
                this.scheduleMap.set(input.key, input)
            })
            this.scheduleList=Array.from(this.scheduleMap.values())
        }   
    }

    @api 
    getUnsavedData(){
        if(!this.readOnly){
            return true
        }else{
            return false
        }
    }

    updateModifiedData(data){
        this.keyIndex=0
        this.stageNumber=1
        this.showToastMessage('Success','VPI Schedule Records Updated Successfully','success','dismissible')
        this.scheduleMap=new Map();
        this.scheduleList = []
        if(data && data.length>0){
            this.keyIndex=0
            data.forEach(input => {
                input.key=this.keyIndex
                input.isChecked=false
                this.scheduleMap.set(this.keyIndex, input)
                this.keyIndex++
                this.stageNumber++
        });
        this.readOnly=true
        this.scheduleList = Array.from(this.scheduleMap.values())  
        this.recordCount = this.scheduleList.length
        refreshApex(this.scheduleList);
        }
    }

    //SFAU-5067 : Added by Samridhi
    @api
    getRecordCount(){
        console.log('length is: ', this.scheduleList.length);
        return this.scheduleList.length;
    }
}