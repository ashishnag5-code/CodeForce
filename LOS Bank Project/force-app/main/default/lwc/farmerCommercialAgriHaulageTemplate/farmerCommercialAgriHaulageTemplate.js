import { LightningElement, track, wire, api } from 'lwc';

export default class CommercialAgriHaulageTeamplate extends LightningElement {

    @track commercialList=[{key:1}]
    
    @api recordTypeId
    @api applicantId
    @api financialId
    @api initialRecord;
    @api isR2 //R2-389
    @api loanId

    keyIndex=1;
    totalCommercialIncome=0;
    
    passIncomeToParent(event){
        var temp = event.detail.template
        var other = event.detail.other
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
                    totalIncome: this.totalCommercialIncome,
                    template:'farmer',
                    record: event.detail.record,  
                }                
            });
            this.dispatchEvent(selectedEvent);
    }

    calculateTotal(event){
        this.totalCommercialIncome = 0
        var list = this.commercialList

        list.forEach(element => {
            if(element.key == event.detail.key){
                
                if(event.detail.amount){
                    element.Net_Annual_Income__c = event.detail.amount;
                    if(event.detail.isDeleted){
                        this.totalCommercialIncome = this.totalCommercialIncome - event.detail.amount
                    }
                    else{
                        this.totalCommercialIncome = this.totalCommercialIncome + event.detail.amount
    
                    }
                }
            }else{
                if(element.Net_Annual_Income__c){
                    this.totalCommercialIncome = this.totalCommercialIncome + element.Net_Annual_Income__c
                }
            } 
        });
        this.agricultureOwnLandList=list
    }

    @api
    get commercialRecords(){
        return this.comRecs;
    }
    set commercialRecords(value){
        this.comRecs = value;
        
        if(value && value.length>0){
            this.commercialList=[]
            this.viewForm(value)
        }
    }

    @track changedDataList=[];
    @track changedData=false;
    viewForm(value){
        var index=1;
        this.totalCommercialIncome=0
        var recs = JSON.parse(JSON.stringify(value));
        recs.forEach(element => {
            element.key=index
            if(element.Net_Annual_Income__c){
                this.totalCommercialIncome = this.totalCommercialIncome + parseFloat(element.Net_Annual_Income__c);
            }
            
            index++;
        });
        this.keyIndex=index
        this.commercialList=recs;
        console.log('Check out this'+JSON.stringify(this.commercialList))
        this.changedData=true;
    }

    addCommercialIncome(){
        this.keyIndex = this.keyIndex+1;
        this.commercialList.push({key: this.keyIndex});
    }

    handleDeleteRow(event){
        var list = this.commercialList
        this.commercialList = list.filter(function (element) {
            return parseInt(element.key) != parseInt(event.detail)
        })

    }
    
}