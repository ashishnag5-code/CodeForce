import { LightningElement, track, api, wire } from 'lwc';

export default class FarmerOwnLandRclTemplate extends LightningElement {

    @api applicantId
    @api financialId
    @api recordTypeName
    @api recordTypeId
    @api type;
    @api initialRecord
    @api loanId
    @api isR2 //R2-389

    @track agricultureOwnLandList=[{ key: 1}];
    keyIndex = 1;
    ownLandTotalIncome = 0;

    
    passIncomeToParent(event){
        var temp = event.detail.template
        var other= event.detail.other
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
                    totalIncome: this.ownLandTotalIncome,
                    template:'farmer',
                    record: event.detail.record,  
                }                
            });
            this.dispatchEvent(selectedEvent);
    }

    calculateTotal(event){

        this.ownLandTotalIncome = 0
        var list = this.agricultureOwnLandList
        list.forEach(element => {
            if(element.key == event.detail.key){
                
                if(event.detail.amount){
                    element.Net_Revenue__c = event.detail.amount;
                    if(event.detail.isDeleted){
                        this.ownLandTotalIncome = this.ownLandTotalIncome - event.detail.amount
                    }
                    else{
                        this.ownLandTotalIncome = this.ownLandTotalIncome + event.detail.amount
    
                    }
                }
            }else{
                if(element.Net_Revenue__c){
                    this.ownLandTotalIncome = this.ownLandTotalIncome + element.Net_Revenue__c
                }
            } 
        });
        this.agricultureOwnLandList=list
    }

    newRecs;
    @api 
    get newRecords(){
        return this.newRecs;
    }
    set newRecords(value){
        this.newRecs = value;
        if(value && value.length>0){
            this.agricultureOwnLandList=[];
            this.viewForm(value)
        }
    }

    @track changedDataList=[];
    @track changedData=false;
    viewForm(value){
        var index=1;
        this.ownLandTotalIncome=0
        var recs = JSON.parse(JSON.stringify(value));
        recs.forEach(element => {
            element.key=index
            if(element.Net_Revenue__c){
                this.ownLandTotalIncome = this.ownLandTotalIncome + parseFloat(element.Net_Revenue__c);
            }
            index++;
        });
        this.keyIndex=index
        //this.changedDataList=recs;
        this.agricultureOwnLandList=recs
        console.log('Check out this'+JSON.stringify(this.changedDataList))
        this.changedData=true;
    }

    addOwnLandIncome(event){
        this.keyIndex = this.keyIndex+1;
        console.log((JSON.stringify(this.agricultureOwnLandList)));
        this.agricultureOwnLandList.push({key: this.keyIndex});
    }

    handleDeleteRow(event){
        var list = this.agricultureOwnLandList
        this.agricultureOwnLandList = list.filter(function (element) {
            return parseInt(element.key) != parseInt(event.detail)
        })

    }

}