import { LightningElement,api  } from 'lwc';
import getBankRecords from '@salesforce/apex/BSACreditController.getBankRecords';


export default class BsaCreditParent extends LightningElement {
    @api recordId;

    //String Attributes
    labelVal = 'Please Select the Applicant';
    applicantId = '';
    accesskey;

    //Array Attributes
   

    amcList = [{
        id: 0
    }];

    bankRecords = [];
    ambRecord=[];
    amcRecord=[];

    //Decimal Attributes
    keyIndex = 0;

    //Boolean Attributes
    isLoaded = false;
    showTable = false;
    showAmb = false;
    showAmc = false;
    ambRecordsPresent = false;
    amcRecordsPresent = false;
    bankStatementUploaded = false;
    
    addAmcNewRow(event) {
        ++this.keyIndex;
        var newItem = [{
            id: this.keyIndex
        }];
        this.amcList = this.amcList.concat(newItem);
    }

    
    removeAmcRow(event) {
        console.log('key-->' + event.target.accessKey);
        if (this.amcList.length >= 2) {
            this.amcList = this.amcList.filter(function (element) {
                return parseInt(element.id) !== parseInt(event.target.accessKey);
            });
        }
    }


    handleChange(event) {

        let selected = event.detail;
        let picklistName = selected.target.name;
        let picklistValue = selected.target.value;
        this.applicantId = picklistValue;

        this.getBankDetails(this.applicantId);
       
    }

    handleShowAmb(event) {
        console.log('amb-->' +event.detail);
        //this.bankRecords
        if(event.detail!=null){
            this.ambRecord  = this.bankRecords.filter(function (element) {
                return (element.recordId) === (event.detail);
            });
            if( (this.ambRecord!=undefined) && (this.ambRecord!='')){
                this.ambRecordsPresent = true;
                this.showAmb = true;
                this.showTable = false;
            } else{
                this.ambRecordsPresent = false;
            } 
            console.log('this.ambRecord-->' +JSON.stringify(this.ambRecord));
        }
       
    }

    handleShowAmc(event) {
        if(event.detail!=null){
            this.amcRecord  = this.bankRecords.filter(function (element) {
                return (element.recordId) === (event.detail);
            });
            if( (this.amcRecord!=undefined) && (this.amcRecord!='')){
                this.amcRecordsPresent = true;
                this.showAmc = true;
                this.showTable = false;
            } else{
                this.amcRecordsPresent = false;
            } 
            console.log('this.amcRecord-->' +JSON.stringify(this.amcRecord));
        }

    }

    handleshowTable() {
      //  this.showTable = true;
        this.showAmb = false;
        this.showAmc = false;
        this.getBankDetails(this.applicantId);
    }


    getBankDetails(applicantId) {
        this.isLoaded = true;
        getBankRecords({
                applicantId: applicantId
            }).then(result => {
                console.log('bankrecords-->' + JSON.stringify(result));
                this.bankRecords = result;
                this.isLoaded = false;
                this.showTable = true;
            })
            .catch(error => {
                this.isLoaded = false;
                console.log('error in bank details-->' + JSON.stringify(error));
            })
    }

    handleRefresh(event){
        this.getBankDetails(event.detail);
    }
   /* handleCallBackRefresh(){
        console.log('callbackRefeersh');
        this.getBankDetails(this.applicantId);
    }*/

    handleBankStatementUploaded() {
        this.bankStatementUploaded = true;
       
    }
    /*handleEnableFetchDetails(event) {
        if (event.detail)
            this.fetchDetails = true;
        else
            this.fetchDetails = false;
    }*/
    handleCartMonthlyIncome(event){

    }

}