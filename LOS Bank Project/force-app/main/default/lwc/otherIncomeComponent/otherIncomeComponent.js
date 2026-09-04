import { LightningElement, track, wire, api } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import APPLICANTFINANCIALDETAILS_OBJECT from '@salesforce/schema/Applicant_Financials_Details__c';
import METHODOFASSESSMENT from '@salesforce/schema/Applicant_Financials_Details__c.Method_Of_Assesment__c';
import OTHERINCOMEPICKLIST from '@salesforce/schema/Applicant_Financials_Details__c.Other_Income_Picklist__c';
import markRecordsInactive from '@salesforce/apex/AgricultureIncomeDetailsController.markRecordsInactive';
import upsertIncome from '@salesforce/apex/AgricultureIncomeDetailsController.upsertIncome';
import getVisibleFieldsForLoanDetails from '@salesforce/apex/AgricultureIncomeDetailsController.getVisibleFieldsForLoanDetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OtherIncomeComponent extends LightningElement {

    @track isIncomeTypeOther = false;
    @track methodOfAssessmentOptions ='';
    @track otherIncomeOptions='';
    @track otherIncomeList=[{ key:1}];
    @api financialId;
    @api applicantId;
    @api loanId
    recordTypeId;
    keyIndex=1;
    @track edit=false;
    @track close=false;
    @track activeSections=[1];
    @track loadSpinner = false;
    @track readOnly = false;
    displayRecordEditForm = false;
    @track otherInc=[];
    displayButtons=true;
    @api spinnerImage;
    @api isR2
    
    passIncomeToParent(event){
        var temp = event.detail.template
        const selectedEvent = new CustomEvent("calculatemonthlyincome", {
            detail:{
                template: temp,
                }                
            });
            this.dispatchEvent(selectedEvent);
    }

    @api
    get otherIncomeRecords(){
        return this.otherInc;
    }
    set otherIncomeRecords(value){
        this.otherInc=value
        
        if(value && value.length>0){
            this.otherIncomeList=[]
            this.viewForm(value)
        }

        /*if(value && value.length>0){
            console.log('otherIncomeRecords '+JSON.stringify(value));
            var index=1;
            var idval=0
            this.displayRecordEditForm = true
            this.activeSections=[];
            var recs = JSON.parse(JSON.stringify(value));
            recs.forEach(element => { 
                element.Name=index;
                element.readOnly = true
                element.edit = true   
                element.displayRecordEditForm = true
                this.activeSections.push(index);
                element.idVal = idval
                index++
                idval++
                
                if(element.Other_Income_Picklist__c == 'Other'){
                    element.isIncomeTypeOther = true;
                    
                }
                else{
                    element.isIncomeTypeOther = false;
                }
            
        });
        
        this.displayButtons = false;
        
        this.otherIncomeList = recs;
        console.log('recs '+JSON.stringify(this.otherIncomeList));
        
        }*/

    }

    handleCloseAll(event){
        this.dispatchEvent(new CustomEvent('home', {
            detail: {
                redirect: false,
                template: 'other'
            }
        }));
    }

    @track changedData=false;
    viewForm(value){
        var index=1;
        var recs = JSON.parse(JSON.stringify(value));
        recs.forEach(element => {
            element.key=index
            index++;
        });
        this.otherIncomeList=recs;
        this.changedData=true;
    }

    addAdditionalOtherIncome(event){
        this.keyIndex = this.keyIndex+1;
        this.otherIncomeList.push({key: this.keyIndex});
    }


    /*handleClose(event){
        if(this.otherIncomeList[event.target.accessKey].Id){
            this.otherIncomeList[event.target.accessKey].displayRecordEditForm = true
             
        }
            this.otherIncomeList[event.target.accessKey].readOnly = true;
            this.otherIncomeList[event.target.accessKey].edit = true; 
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title, 
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    connectedCallback(){
        this.getFields();
    }

    getFields(){
        getVisibleFieldsForLoanDetails({strScreen :'Other Income', strStage :'QDE', strProfile :'' })
        .then(result => {
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

    saveIncome(event){
        var accessid = event.target.accessKey;

        this.otherIncomeList[accessid].RecordTypeId = this.recordTypeId
        if(this.financialId)
            this.otherIncomeList[accessid].Applicant_Financials__c = this.financialId;
        this.otherIncomeList[accessid].Applicant__c = this.applicantId;

        upsertIncome({record: this.otherIncomeList[accessid]}).then((data)=>{
            let dummy = this.otherIncomeList;
            console.log(dummy);
            console.log('Access Id '+ accessid);
            console.log('Data '+JSON.stringify(data));
            dummy[accessid].Id = data.Id;
            dummy[accessid].readOnly = true;
            dummy[accessid].displayRecordEditForm = true;
            dummy[accessid].edit = true;
            if(dummy[accessid].Other_Income_Picklist__c=='Other')
                dummy[accessid].isIncomeTypeOther = true;
            else 
                dummy[accessid].isIncomeTypeOther = false;
            
            this.otherIncomeList = dummy;
            console.log('Other Income List'+JSON.stringify(this.otherIncomeList));

            const selectedEvent = new CustomEvent("calculatemonthlyincome", {
                detail:{
                        template: 'other',
                    }                
                });
                this.dispatchEvent(selectedEvent);
        })
    }

    

    @wire(getObjectInfo, { objectApiName: APPLICANTFINANCIALDETAILS_OBJECT })
    objectInfo({data, error}){
        if (data){
            const rtis = data.recordTypeInfos;
            this.recordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Other Income');
        }
    };

    @wire (getPicklistValues, {recordTypeId: '$recordTypeId', fieldApiName: METHODOFASSESSMENT})
    retrieveMethodOfAssessment({error, data}){
        if(data){
            this.methodOfAssessmentOptions = data.values;
        }
    }

    @wire (getPicklistValues, {recordTypeId: '$recordTypeId', fieldApiName: OTHERINCOMEPICKLIST})
    retrieveOtherIncome({error, data}){
        if(data){
            this.otherIncomeOptions = data.values;
        }
    }

    handleChange(event){
        var key = event.target.accessKey;
        var value = event.target.value;
        var name = event.target.name;

        if(name == 'Other_Income_Picklist__c'){
            this.otherIncomeList[key].Other_Income_Picklist__c = value;
            if(value == 'Other'){
                this.otherIncomeList[key].isIncomeTypeOther = true;
            }
            else{
                this.otherIncomeList[key].isIncomeTypeOther = false;
                this.otherIncomeList[key].Other_If_Any__c = '';
            }
        }
        else if(name == 'Other_If_Any__c'){
            this.otherIncomeList[key].Other_If_Any__c = value;
        }
        else if(name == 'Monthly_Income__c'){
            this.otherIncomeList[key].Monthly_Income__c = value;
        }
        else if(name == 'Method_Of_Assesment__c'){
            this.otherIncomeList[key].Method_Of_Assesment__c = value;
        }

        this.getFields();
    }

    handleEdit(event){
        this.otherIncomeList[event.target.accessKey].readOnly = false;
        this.otherIncomeList[event.target.accessKey].edit = false; 
        this.otherIncomeList[event.target.accessKey].displayRecordEditForm = false
        this.getFields();
         
    }

    addAdditionalOtherIncome(){
        this.keyIndex = this.keyIndex+1;
        this.activeSections.push(this.otherIncomeList.length+1);
        this.otherIncomeList.push({idVal: this.keyIndex, Name: this.otherIncomeList.length+1, readOnly: false, Monthly_Income__c:0});
        this.getFields();
        
    }
   
    handleDeleteRow(event){

        let list=[];
        list = this.otherIncomeList;
        var record = list.filter(function (element) {
            return parseInt(element.idVal) == parseInt(event.target.accessKey);
        
        })
        if(record[0].Id){
            markRecordsInactive({afd :record[0].Id}).then((data)=>{
                console.log('Success');
                const selectedEvent = new CustomEvent("calculatemonthlyincome", {
                    detail:{ 
                        template: 'other',
                    }                
                });
                this.dispatchEvent(selectedEvent);
            }).catch((error)=>{
                console.log('Error')

            })
        }
        list = list.filter(function (element) {
            return parseInt(element.idVal) != parseInt(event.target.accessKey);
        
        })
        var sections=[]
        var Name = 1;
        list.forEach(element => {
            element.Name = Name;
            sections.push(Name);
            Name++; 
        });
        this.otherIncomeList = list;
        this.activeSections=sections;
    }*/

    handleDeleteRow(event){
        var list = this.otherIncomeList
        this.otherIncomeList = list.filter(function (element) {
            return parseInt(element.key) != parseInt(event.detail)
        })
    }
    calculateTotal(event){
       
        var list = this.otherIncomeList
     /*   list.forEach(element => {
            if(element.key == event.detail.key){
                
                if(event.detail.amount){
                    element.Monthly_Income__c = event.detail.amount;
                    if(event.detail.isDeleted){
                        this.dairyTotalIncome = this.dairyTotalIncome - event.detail.amount
                    }
                    else{
                        this.dairyTotalIncome = this.dairyTotalIncome + event.detail.amount
    
                    }
                }
            }else{
                if(element.Total_Net_Income__c){
                    this.dairyTotalIncome = this.dairyTotalIncome + element.Total_Net_Income__c
                }
            } 
        });
        this.dairyBusinessList=list*/

    }

}