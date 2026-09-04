import { LightningElement,api } from 'lwc';

export default class AmbChildComponent extends LightningElement {

    @api key;

    //Boolean Attributes
    showView = false;
    isLoaded = false;
    showAmbNewFormView = false;
    showModal = false;

    //Array Attributes
    ambList = [{
        id: 0
    }];
    ambRecord = {};
    ambViewRecords = {};
    ambSelectedRecords;

    //Decimal Attributes
    keyIndex = 0;
    averageBalanceVal = 0;
    balance5=0;
    balance15=0;
    balance25=0;
    balance5Average=0;
    balance15Average=0;
    balance25Average=0;
    balanceAverage = 0;
    ambAverage =0;
    amcAverage = 0;
    counterVal =0;
    selectedAMB =0;

    //String Attributes
    bankRecordId = '';
    selectedMonth = '';
    selectedYear = '';
    analysisJSON = '';


    handleChange(event) {
        this.ambRecord[event.target.name] = event.target.value;
        let fieldName = event.target.name;
        let fieldValue = event.target.value;
        if (fieldName == 'averageBalanceOn5th') {
            this.balance5 = parseFloat(fieldValue);
        } else if (fieldName == 'averageBalanceOn15th') {
            this.balance15 = parseFloat(fieldValue);
        } else if (fieldName == 'averageBalanceOn25th') {
            this.balance25 = parseFloat(fieldValue);
           this.handleAverage();
            /*this.averageBalanceVal = averageBalance;
            console.log('averageBalanceVal-->'+this.averageBalanceVal);
            this.ambRecord.averageBalance =  this.averageBalanceVal;*/


        }
        this.dispatchEvent(new CustomEvent('ambdetails', {
            detail: this.ambRecord
        }));
    }
    handleAverage(){
        let averageBalance =  (this.balance5 + this.balance15 + this.balance25)/3;
        this.averageBalanceVal = averageBalance;
        this.ambRecord.averageBalance = averageBalance;
        console.log('averageBalance-->' +averageBalance);
        this.dispatchEvent(new CustomEvent('ambdetails', {
            detail: this.ambRecord
        }));
    }

}