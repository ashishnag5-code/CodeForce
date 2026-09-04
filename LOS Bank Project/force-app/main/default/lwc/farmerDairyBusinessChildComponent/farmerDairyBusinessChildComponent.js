import { api, LightningElement, track } from 'lwc';
import markRecordsInactive from '@salesforce/apex/AgricultureIncomeDetailsController.deleteFinancialRecords' // R2 Updated
import upsertIncome from '@salesforce/apex/AgricultureIncomeDetailsController.upsertIncome'
import getVisibleFieldsForLoanDetails from '@salesforce/apex/AgricultureIncomeDetailsController.getVisibleFieldsForLoanDetails';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import renderDeleteAction from '@salesforce/apex/AgricultureIncomeDetailsController.renderDeleteAction'; //R2

export default class FarmerDairyBusinessTemplate extends LightningElement {
    isDelete = true; //R2
    @api financialId
    @api applicantId
    @api recordTypeId
    @api loanId

    Id='';
    keyId;
    record={}
    showRecordViewForm=false;
    displayButtons=true;
    readOnly=false;
    edit=false;
    @api isR2; //R2-389

    No_of_Cattle__c=0;
    Daily_Supply_of_Milk_Ltrs__c=0
    Average_Sale_Price_Per_Liter__c=0
    Daily_Collection__c=0
    Monthly_Receipts__c=0
    Profit_Margin__c=0
    Monthly_Net_Income__c=0
    Any_Other_Income__c=0
    Any_Other_Expense__c=0
    Total_Net_Income__c=0

    @api changedData;
    keyval
    @api 
    get sendKey(){
        return this.keyval
    }
    set sendKey(value){
        this.keyval = value
        if(value){
            this.keyId = value
        }
    }

    connectedCallback(){
        this.getVisibleFields();
        this.handleDeleteVisbility();//R2
    }

    loadSpinner=false;
    keyIndex = 0;
    dairyTotalIncome = 0;
    initialRec;
    
    initialRec
    @api 
    get initialRecord(){
        return this.initialRec;
    }
    set initialRecord(value){
        this.initialRec = value
        if(value && value.RecordTypeId == this.recordTypeId){
            let dummy = JSON.parse(JSON.stringify(value))
            this.readOnly = true;
            this.edit = true
            this.showRecordViewForm=true;
            this.Id=value.Id
            //this.keyId=this.sendKey;
            this.record = dummy;
            console.log(value);
        }
    }

    remo;
    @api
    get newRecord(){
        return this.remo;
    }
    set newRecord(value){
        this.remo = value;
        if(value){
            this.record = JSON.parse(JSON.stringify(value));
            this.handleNewMappings();

        }
    }


    getVisibleFields(){
        getVisibleFieldsForLoanDetails({ strScreen :'Farmer - Dairy', strStage :'QDE', strProfile :''})
        .then(result => {
            
            console.log('result is '+JSON.stringify(result));
            result.forEach(input => {
                this.template.querySelectorAll('[data-id="'+input+'"]').forEach(element =>{
                    element.classList.remove('slds-hide');
                })
            });
            if(this.isR2 && this.edit){
                this.template.querySelector('lightning-accordion').activeSectionName=""
            }
        })
        .catch(error => {
            console.log('result is '+error);
        })
    }

    handleClose(event){
        if(this.record.Id){
            this.showRecordViewForm = true 
             
        }
        this.readOnly = true;
        this.edit = true; 
        if(this.isR2){
            this.template.querySelector('lightning-accordion').activeSectionName=""
        }
    }
      //R2
      async handleDeleteVisbility(){
        const isDelete = await renderDeleteAction({ recordId: this.loanId});
        this.isDelete = isDelete;
        console.log('isDelete-->' +isDelete);
        }
    handleEdit(event){
        
        this.readOnly = false;
        this.edit = false; 
        this.showRecordViewForm = false
        this.getVisibleFields();
        if(this.isR2){
            this.template.querySelector('lightning-accordion').activeSectionName="A"
        }
    }

    setStringDefaultValues(data){
        return data?data:''
    }

    setNumericDefaultValues(data){
        return data?data:0
    }

    handleMappings(){
        if(this.recordTypeId)
            this.record.RecordTypeId = this.recordTypeId
        if(this.applicantId)
            this.record.Applicant__c = this.applicantId; 
        if(this.financialId){
            this.record.Applicant_Financials__c = this.financialId;
        }
        this.record.No_of_Cattle__c = this.setNumericDefaultValues(this.No_of_Cattle__c)
        this.record.Daily_Supply_of_Milk_Ltrs__c = this.setNumericDefaultValues(this.Daily_Supply_of_Milk_Ltrs__c)
        this.record.Average_Sale_Price_Per_Liter__c = this.setNumericDefaultValues(this.Average_Sale_Price_Per_Liter__c)
        this.record.Annual_Income_Unit_Rs__c = this.setNumericDefaultValues(this.Annual_Income_Unit_Rs__c)
        this.record.Daily_Collection__c = this.setNumericDefaultValues(this.Daily_Collection__c)
        this.record.Monthly_Receipts__c = this.setNumericDefaultValues(this.Monthly_Receipts__c)
        this.record.Monthly_Net_Income__c = this.setNumericDefaultValues(this.Monthly_Net_Income__c)
        this.record.Any_Other_Income__c = this.setNumericDefaultValues(this.Any_Other_Income__c)
        this.record.Any_Other_Expense__c = this.setNumericDefaultValues(this.Any_Other_Expense__c)
        this.record.Total_Net_Income__c = this.setNumericDefaultValues(this.Total_Net_Income__c)
        if(this.Id){
            this.record.Id = this.Id;
        }
        this.record.Profit_Margin__c = this.setNumericDefaultValues(this.Profit_Margin__c) // 24 AUG || SFAU-4983
    }

    handleNewMappings(){
        if(this.record.RecordTypeId)
            this.recordTypeId = this.record.RecordTypeId
        if(this.record.Applicant__c)
        this.applicantId = this.record.Applicant__c
        if(this.record.Applicant_Financials__c)
            this.financialId= this.record.Applicant_Financials__c; 

        this.No_of_Cattle__c = this.setNumericDefaultValues(this.record.No_of_Cattle__c)
        this.Daily_Supply_of_Milk_Ltrs__c = this.setNumericDefaultValues(this.record.Daily_Supply_of_Milk_Ltrs__c)
        this.Average_Sale_Price_Per_Liter__c = this.setNumericDefaultValues(this.record.Average_Sale_Price_Per_Liter__c)
        this.Annual_Income_Unit_Rs__c = this.setNumericDefaultValues(this.record.Annual_Income_Unit_Rs__c)
        this.Daily_Collection__c = this.setNumericDefaultValues(this.record.Daily_Collection__c)
        this.Monthly_Receipts__c = this.setNumericDefaultValues(this.record.Monthly_Receipts__c)
        this.Monthly_Net_Income__c = this.setNumericDefaultValues(this.record.Monthly_Net_Income__c)
        this.Any_Other_Income__c = this.setNumericDefaultValues(this.record.Any_Other_Income__c)
        this.Any_Other_Expense__c = this.setNumericDefaultValues(this.record.Any_Other_Expense__c)
        this.Total_Net_Income__c = this.setNumericDefaultValues(this.record.Total_Net_Income__c)
        this.Profit_Margin__c = this.setNumericDefaultValues(this.record.Profit_Margin__c) // 24 AUG || SFAU-4983
        if(this.record.Id){
            this.Id = this.record.Id;
        }
        this.setModeToReadOnlyInChild();
    }

    setModeToReadOnlyInChild(){
        if(this.record.Id){
            this.readOnly=true
            this.displayButtons=false
            this.edit=true
            this.showRecordViewForm=true
        }
    }

    async saveIncome(event){

        //4733 start
        const isEditRestricted = await restricAccess({compName: 'financialView' ,loanId: this.loanId})
        if(isEditRestricted){
            const evt = new ShowToastEvent({
                title: 'Access Restricted',
                message: 'You do not have access to edit Financial Details',
                variant: 'error',
                mode: 'sticky'
            });
            this.dispatchEvent(evt);
            return
        }
        //4733 end

        this.handleMappings();

        if(!this.financialId && !this.record.Applicant_Financials__c){
            console.log('Event was fired ');
            const selectedEvent = new CustomEvent("farmerevent", {
                detail:{
                        totalIncome: this.dairyTotalIncome,
                        template:'farmer',
                        record: this.record,  
                    }                
                });
                this.dispatchEvent(selectedEvent);
        }
        else{
            upsertIncome({record: this.record}).then((data)=>{

            this.record.Id = data.Id;
            this.readOnly = true;
            this.edit = true;
            this.showRecordViewForm=true;   
            const selectedEvent = new CustomEvent("calculatemonthlyincome", {
                detail:{ 
                    template: 'farmer',
                    other: true
                }                
            });
            this.dispatchEvent(selectedEvent);
        })
    }

    }

    
    calculateDailyCollection(key, val){
        if(val == 1){
            var num1 = parseFloat(this.Daily_Supply_of_Milk_Ltrs__c);
            var num2 = parseFloat(this.Average_Sale_Price_Per_Liter__c);
            this.Daily_Collection__c = num1 * num2;
            if(this.Daily_Collection__c){
                this.Monthly_Receipts__c = parseFloat(this.Daily_Collection__c) * 30;
                // Joshna - R2-2365 - copied this from profit margin logic as change in monthly receipts should in-turn calculate monthly net income and total net income
                var number1 = parseFloat(this.Monthly_Receipts__c);
                var number2 = parseFloat(this.Profit_Margin__c);
                if(number2!=0){ // START || 24 AUG || updated for SFAU-4983 
                    number2 = number2/100;
                }//END

                this.Monthly_Net_Income__c = number1 * number2;
                this.calculateDailyCollection(key, 2);
                // Joshna - end of changes - R2-2365
            } 
        }
        if(val == 2){
            this.Total_Net_Income__c=0
            this.dairyTotalIncome=0
            var num1 = parseFloat(this.Any_Other_Income__c);
            var num2 = parseFloat(this.Any_Other_Expense__c);
            var num3 = parseFloat(this.Monthly_Net_Income__c);
            
            
                this.Total_Net_Income__c = (num1 + num3) - num2;
                
            this.dispatchEvent(new CustomEvent('calculatetotal',{
                detail:{
                    amount: this.Total_Net_Income__c,
                    template: this.type,
                    key:this.keyId,
                    isDeleted: false
                }
            }));
            /*this.dairyBusinessList.forEach(element => {
                this.dairyTotalIncome = this.dairyTotalIncome + parseFloat(element.Total_Net_Income__c);
                
            });*/
        }    
    }


    handleDailyCollection(event){
        var key = event.target.accessKey;
        if(event.target.name == 'Daily_Supply_of_Milk_Ltrs__c'){
            this.Daily_Supply_of_Milk_Ltrs__c = event.target.value?parseFloat(event.target.value):0;
        }
        if(event.target.name == 'Average_Sale_Price_Per_Liter__c'){
            this.Average_Sale_Price_Per_Liter__c = event.target.value?parseFloat(event.target.value):0;
        }
        this.calculateDailyCollection(key,1);
    }

    handleprofitMarginChange(event){
        var key = event.target.accessKey;
        this.Profit_Margin__c = event.target.value? parseFloat(event.target.value):0;
        var num1 = parseFloat(this.Monthly_Receipts__c);
        var num2 = parseFloat(this.Profit_Margin__c);
        if(num2!=0){ // START || 24 AUG || updated for SFAU-4983 
            num2 = num2/100;
        }//END
        
        
        this.Monthly_Net_Income__c = num1 * num2;
        this.calculateDailyCollection(key,1);
        this.calculateDailyCollection(key,2);
    }

    handleChange(event){
        var key = event.target.accessKey;
        var name = event.target.name;
        if(name == 'Any_Other_Income__c'){
            this.Any_Other_Income__c = event.target.value? parseFloat(event.target.value):0;
            this.calculateDailyCollection(key,2);  
        }
        if(name == 'Any_Other_Expense__c'){
            this.Any_Other_Expense__c = event.target.value? parseFloat(event.target.value):0;
            this.calculateDailyCollection(key,2);  
        }
        if(name == 'No_of_Cattle__c'){
            this.No_of_Cattle__c = event.target.value? parseFloat(event.target.value):0;
        }
    }

    /*addDairyBusinessIncome(event){
        this.keyIndex = this.keyIndex+1;
        this.activeSections.push( this.dairyBusinessList.length+1);
        console.log((JSON.stringify(this.dairyBusinessList)));
        this.dairyBusinessList.push({key: this.keyIndex, Name: this.dairyBusinessList.length+1, readOnly: false});
        this.getVisibleFields();
    }*/

    handleDeleteRow(event){
        if(this.record.Id){
            markRecordsInactive({afd :this.record.Id}).then((data)=>{
                const selectedEvent = new CustomEvent("calculatemonthlyincome", {
                    detail:{ 
                        template: 'farmer',
                    }                
                });
                this.dispatchEvent(selectedEvent);
                this.dispatchEvent(new CustomEvent('deletedrecord',{
                    detail: this.keyId
                }));
                this.dispatchEvent(new CustomEvent('calculatetotal',{
                    detail: this.Net_Annual_Income__c
                }));
            }).catch((error)=>{
            })
        }
    }

}