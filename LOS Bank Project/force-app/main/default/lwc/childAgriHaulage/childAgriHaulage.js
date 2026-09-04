import { LightningElement, track, wire, api } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import FINANCE from '@salesforce/schema/Scale_of_Finance__c';
import TYPE_OF_INCOME from '@salesforce/schema/Scale_of_Finance__c.Type_of_Income__c';
import PROOF from '@salesforce/schema/Applicant_Financials_Details__c.Proof__c';
import getIncomeSource from '@salesforce/apex/AgricultureIncomeDetailsController.getIncomeSource';
import upsertIncome from '@salesforce/apex/AgricultureIncomeDetailsController.upsertIncome';
import getVisibleFieldsForLoanDetails from '@salesforce/apex/AgricultureIncomeDetailsController.getVisibleFieldsForLoanDetails';
import markRecordsInactive from '@salesforce/apex/AgricultureIncomeDetailsController.deleteFinancialRecords'; //R2 Updated
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import renderDeleteAction from '@salesforce/apex/AgricultureIncomeDetailsController.renderDeleteAction'; //R2
export default class ChildAgriHaulage extends LightningElement {
    isDelete = true; //R2
    @api recordTypeId
    @api financialId
    @api applicantId
    @api loanId
    Id='';
    keyId;
    record={}
    showRecordViewForm=false;
    displayButtons=true;
    readOnly=false;
    edit=false;
    incomeRecId
    Type_of_Income__c=''
    Income_Source__c=''
    Unit__c=''
    Annual_Income_Unit_Rs__c=0
    Proof__c=''
    Document_Type__c=''
    Net_Annual_Income__c=0
    commercialDetails
    @track proofOptions
    @track typeOfIncomeOptions
    @track incomeSourceOptions
    @api changedData
    @api isR2 //R2-389
    keyval;
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
        getVisibleFieldsForLoanDetails({ strScreen :'Farmer - Commercial', strStage :'QDE', strProfile :''})
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

    handleClose(){
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

    @wire(getObjectInfo, { objectApiName: FINANCE })
    objectInfo({data, error}){
        if(data){
            const rtis = data.recordTypeInfos;
            this.incomeRecId = Object.keys(rtis).find(rti => rtis[rti].name === 'Commercial Income');   
        }
    }
    @wire (getPicklistValues, {recordTypeId: '$recordTypeId', fieldApiName: PROOF})
    retrieveProof({error, data}){
        if(data){
            this.proofOptions = data.values;
        }
    }

    @wire (getPicklistValues, {recordTypeId: '$incomeRecId', fieldApiName: TYPE_OF_INCOME})
    retrieveIncomeOptions({error, data}){
        if(data){
            this.typeOfIncomeOptions = data.values;
        }
    }

    handleMappings(){
        if(this.recordTypeId)
            this.record.RecordTypeId = this.recordTypeId
        if(this.applicantId)
            this.record.Applicant__c = this.applicantId; 
        if(this.financialId){
            this.record.Applicant_Financials__c = this.financialId;
        }
        this.record.Type_of_Income__c = this.setStringDefaultValues(this.Type_of_Income__c)
        this.record.Income_Source__c = this.setStringDefaultValues(this.Income_Source__c)
        this.record.Unit__c = this.setStringDefaultValues(this.Unit__c)
        this.record.Annual_Income_Unit_Rs__c = this.setNumericDefaultValues(this.Annual_Income_Unit_Rs__c)
        this.record.Proof__c = this.setStringDefaultValues(this.Proof__c)
        this.record.Document_Type__c = this.setStringDefaultValues(this.Document_Type__c)
        this.record.Net_Annual_Income__c = this.setNumericDefaultValues(this.Net_Annual_Income__c)
        if(this.Id){
            this.record.Id = this.Id;
        }

    }

    setStringDefaultValues(data){
        return data?data:''
    }

    setNumericDefaultValues(data){
        return data?data:0
    }

    handleNewMappings(){
        if(this.record.RecordTypeId)
            this.recordTypeId = this.record.RecordTypeId
        if(this.record.Applicant__c)
        this.applicantId = this.record.Applicant__c
        if(this.record.Applicant_Financials__c)
            this.financialId= this.record.Applicant_Financials__c; 
        
        this.Type_of_Income__c = this.setStringDefaultValues(this.record.Type_of_Income__c)
        this.Income_Source__c = this.setStringDefaultValues(this.record.Income_Source__c)
        this.Unit__c = this.setStringDefaultValues(this.record.Unit__c)
        this.Annual_Income_Unit_Rs__c = this.setNumericDefaultValues(this.record.Annual_Income_Unit_Rs__c)
        this.Proof__c = this.setStringDefaultValues(this.record.Proof__c)
        this.Document_Type__c = this.setStringDefaultValues(this.record.Document_Type__c)
        this.Net_Annual_Income__c = this.setNumericDefaultValues(this.record.Net_Annual_Income__c)
        if(this.record.Id){
            this.Id = this.record.Id;
        }
        this.setModeToReadOnlyInChild();
        this.getIncome(this.Type_of_Income__c)

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
            const selectedEvent = new CustomEvent("farmerevent", {
                detail:{
                        totalIncome: this.totalCommercialIncome,
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
                //this.keyId = this.sendKey
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

    handleEdit(event){
        this.readOnly = false;
        this.edit = false; 
        this.showRecordViewForm = false
        this.getVisibleFields();
        let recId = this.incomeRecId
        this.incomeRecId=''
        this.incomeRecId=recId
        if(this.isR2){
            this.template.querySelector('lightning-accordion').activeSectionName="A"
        }
    }

    handleTypeOfIncomeChange(event){
       
        this.Type_of_Income__c = event.target.value;
        this.incomeSourceOptions=[];
        this.Income_Source__c=''
        this.Annual_Income_Unit_Rs__c=0;
        this.Net_Annual_Income__c=0;
        this.dispatchEvent(new CustomEvent('calculatetotal',{
            detail:{
                amount: this.Net_Annual_Income__c,
                key: this.keyId,
                isDeleted: false
            }
        })
        );
        this.getIncome(event.target.value);
    }

    getIncome(value){
        getIncomeSource({incomeType: value}).then((result)=>{
            this.commercialDetails = result;
            var picklist=[];
            result.forEach(element => {
                var newItem = {label: element.Income_Source__c, value: element.Income_Source__c}
                picklist.push(newItem);
            });
            this.incomeSourceOptions = picklist;
        }).catch((error)=>{
            console.log('Error '+error);
        })
    }

    handleIncomeSourceChange(event){
        this.Income_Source__c = event.target.value;

        this.commercialDetails.forEach(element => {
            if(element.Income_Source__c == this.Income_Source__c){
                this.Annual_Income_Unit_Rs__c = parseFloat(element.Annual_Income_Unit_Rs__c);
                //this.totalCommercialIncome = this.totalCommercialIncome + element.Annual_Income_Unit_Rs__c;
                if(this.Unit__c){
                    this.Net_Annual_Income__c = parseFloat(this.Unit__c) * this.Annual_Income_Unit_Rs__c
                    this.dispatchEvent(new CustomEvent('calculatetotal',{
                        detail:{
                            amount: this.Net_Annual_Income__c,
                            key: this.keyId,
                            isDeleted: false
                        }
                    })
                    );

                }
            }
        });
       
        
    }
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
                    detail:{
                        amount: this.Net_Annual_Income__c,
                        key: this.keyId,
                        isDeleted: true
                    }
                }));
            }).catch((error)=>{
            })
        }else{
            this.dispatchEvent(new CustomEvent('deletedrecord',{
                detail: this.keyId
            }));
            this.dispatchEvent(new CustomEvent('calculatetotal',{
                detail:{
                    amount: this.Net_Annual_Income__c,
                    key: this.keyId,
                    isDeleted: true
                }
            }));
        }

        
    }

    @api 
    setModeToReadOnlyInChild(){
        if(this.record.Id){
            this.readOnly=true
            this.displayButtons=false
            this.edit=true
            this.showRecordViewForm=true
        }
    }
    handleChange(event){
        var name = event.target.name;
        var value = event.target.value
        if(name == 'Proof__c'){
            this.Proof__c = value;
        }
        if(name == 'Unit__c'){
            this.Unit__c = value?value:0;
            this.Net_Annual_Income__c = parseFloat(value) * this.Annual_Income_Unit_Rs__c
            this.dispatchEvent(new CustomEvent('calculatetotal',{
                detail:{
                    amount: this.Net_Annual_Income__c,
                    key: this.keyId,
                    isDeleted: false
                }
            })
            );
        }
        
        if(name == 'Document_Type__c'){
            this.Document_Type__c = value;
        } 
    }


}