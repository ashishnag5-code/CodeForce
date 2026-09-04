import { api, LightningElement, track } from 'lwc';

export default class FarmerDairyBusinessTemplate extends LightningElement {

    finid;
    @api financialId
    @api applicantId
    @api recordTypeId
    @api loanId
    @track dairyBusinessList=[{ key: 1}]
    @track activeSections=[1];
    displayButtons=true;
    loadSpinner=false;
    keyIndex = 1;
    dairyTotalIncome = 0;
    initialRec;
    showRecordViewForm=false;
    @api isR2 //R2-389
    
    @api initialRecord

    passIncomeToParent(event){
        var temp = event.detail.template
        var other=event.detail.other
        const selectedEvent = new CustomEvent("calculatemonthlyincome", {
            detail:{
                template: temp,
                other: other
                }                
            });
            this.dispatchEvent(selectedEvent);
    }

    handleFarmerEvent(event){
        const selectedEvent = new CustomEvent("farmerevent", {
            detail:{
                    totalIncome: this.dairyTotalIncome,
                    template:'farmer',
                    record: event.detail.record,  
                }                
            });
            this.dispatchEvent(selectedEvent);
    }

    calculateTotal(event){
        this.dairyTotalIncome = 0
        var list = this.dairyBusinessList
        list.forEach(element => {
            if(element.key == event.detail.key){
                
                if(event.detail.amount){
                    element.Total_Net_Income__c = event.detail.amount;
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
        this.dairyBusinessList=list

    }

    dairyRecs
    @api 
    get dairyRecords(){
        return this.dairyRecs;
    }
    
    set dairyRecords(value){
        this.dairyRecs = value;
        
        if(value && value.length>0){
            this.dairyBusinessList=[]
            this.viewForm(value)
        }
    }

    @track changedDataList=[];
    @track changedData=false;
    viewForm(value){
        var index=1;
        this.dairyTotalIncome=0
        var recs = JSON.parse(JSON.stringify(value));
        recs.forEach(element => {
            element.key=index
            if(element.Total_Net_Income__c){
                this.dairyTotalIncome = this.dairyTotalIncome + parseFloat(element.Total_Net_Income__c);
            }
            index++;
        });
        this.keyIndex=index
        this.dairyBusinessList=recs;
        console.log('Check out this'+JSON.stringify(this.dairyBusinessList))
        this.changedData=true;
    }

    addDairyBusinessIncome(event){
        this.keyIndex = this.keyIndex+1;
        this.activeSections.push( this.dairyBusinessList.length+1);
        console.log((JSON.stringify(this.dairyBusinessList)));
        this.dairyBusinessList.push({key: this.keyIndex});
    }

    handleDeleteRow(event){
        var list = this.dairyBusinessList
        this.dairyBusinessList = list.filter(function (element) {
            return parseInt(element.key) != parseInt(event.detail)
        })

    }
    
}