import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createAmcRecord from '@salesforce/apex/BSACreditController.createAmcRecord';
import updateAmcRecord from '@salesforce/apex/BSACreditController.updateAmbRecord';
import getBankRecords from '@salesforce/apex/BSACreditController.getBankRecords';
import StayInTouchSubject from '@salesforce/schema/User.StayInTouchSubject';
import validateRecordEdit from '@salesforce/apex/ComponentProfileRestrictionController.validateRecordEdit'//4733

export default class AmcDetailsComponent extends LightningElement {

    //API Attributes
    @api bankAccountRecords;
    @api applicantId;

    //Boolean Attributes
    showView = false;
    isLoaded = false;
    showAmcNewFormView = false;
    showModal = false;

    //Array Attributes
    amcList = [{
        id: 0
    }];
    amcRecord = {};
    amcViewRecords = {};
    amcSelectedRecords;
    monthlist =[];
    duplicatesCounter=0;

    //Decimal Attributes
    keyIndex = 0;
    creditAverage = 0;
    salaryCreditAverage =0;
    salaryTotal =0;
    counterVal = 0;
    selectedAMC =0;

    //String Attributes
    bankRecordId = '';
    selectedMonth = '';
    selectedYear='';
    analysisJSON = '';
    @track isEditRestricted

    connectedCallback() {
        console.log('bankAccountRecords-->' + JSON.stringify(this.bankAccountRecords));
        if (this.bankAccountRecords != '' && this.bankAccountRecords != null) {
            this.showView = true;
            if(this.bankAccountRecords[0].analysisFullData!== '' && this.bankAccountRecords[0].analysisFullData!=null){
                this.analysisJSON = this.bankAccountRecords[0].analysisFullData;
                console.log('analysisJSON-->' + JSON.stringify(this.analysisJSON));
                this.handleAnalysis(this.analysisJSON);
            }else{
                this.addAmcNewRow();
                this.amcViewRecords=null;
                this.showAmcNewFormView = true;
               
            }
        } else {
            this.amcViewRecords=null;
            this.showAmcNewFormView = true;
        }
        this.setIsEditRestricted()
    }

    async setIsEditRestricted(){
        this.isEditRestricted = await validateRecordEdit({compName: 'financialView' ,recordId: this.applicantId})
    }

    handleAnalysis(analysisVal) {
        let analysisData = JSON.parse(analysisVal); //this.bankAccountRecords[0].analysisFullData
        let amcValues = [];
        const monthlyCreditsDetails = analysisData.monthlyCreditsDetails;
        let counter = 0;
        let creditTotal =0;
        let salaryTotal =0;
       
     /*   for (let month in monthlyCreditsDetails) {
            if (monthlyCreditsDetails.hasOwnProperty(month)) {
                counter = counter+1;
                this.counterVal = counter;
                let monthYearString = month;
                let [monthVal, year] = monthYearString.split("-");
                let balances = monthlyCreditsDetails[month];
                // Create a new object for the current month with the desired structure
                const monthData = {
                    credit: balances['Credit'],
                    salarycredit: balances['Salary Credit'],
                    month: monthVal,
                    year: year,
                    recordId: this.bankAccountRecords[0].recordId,
                    manualcheck: (balances['ManualCheck'] != null) ? (balances['ManualCheck']) : false
                };
                amcValues.push(monthData);
                creditTotal = creditTotal + parseFloat(balances['Credit']);
                salaryTotal = salaryTotal + parseFloat(balances['Salary Credit']);
                
            }
        }*/

        for(let i=0; i<monthlyCreditsDetails.length; i++){
            counter = counter+1;
            this.counterVal = counter;
            let monthYearString = monthlyCreditsDetails[i]['Month-Year'];
            let [monthVal, year] = monthYearString.split("-");
             // Create a new object for the current month with the desired structure
             let balances =  monthlyCreditsDetails[i];
            // Create a new object for the current month with the desired structure
            const monthData = {
                credit: balances['Credit'].toFixed(2),
                salarycredit: balances['Salary Credit'] !=undefined ?  balances['Salary Credit'].toFixed(2) :0,
                month: monthVal,
                year: year,
                recordId: this.bankAccountRecords[0].recordId,
                manualcheck: (balances['ManualCheck'] != null) ? (balances['ManualCheck']) : false
            };
            amcValues.push(monthData);
            //creditTotal = creditTotal + balances['Credit']!=null? parseFloat(balances['Credit']):0;
            creditTotal = creditTotal +  parseFloat(balances['Credit']);
            
            if( balances['Salary Credit']!=undefined){
                console.log('balance-->' +balances['Salary Credit']);
                salaryTotal = salaryTotal + balances['Salary Credit'];
            }
           
            console.log('salaryInsideLoop-->' +salaryTotal);
        
        }
        console.log('salaryTotal-->' +salaryTotal);
        this.salaryTotal = creditTotal;
        this.amcViewRecords = amcValues;
        this.creditAverage = (creditTotal/counter).toFixed(2);
        this.salaryCreditAverage = (salaryTotal/counter).toFixed(2);

        console.log('amcViewRecords-->' + JSON.stringify(this.amcViewRecords));
        console.log('this.salaryCreditAverage -->' +this.salaryCreditAverage );
    }

    addAmcNewRow(event) {
        if(this.isEditRestricted){
            this.showErrorMessage('You do not have Access Rights to add AMC Details', 'error');
            return
        }
        ++this.keyIndex;
        var newItem = [{
            id: this.keyIndex
        }];
        this.amcList = this.amcList.concat(newItem);

    }
    removeAmcRow(event) {
        if (this.amcList.length >= 2) {
            this.amcList = this.amcList.filter(function (element) {
                return parseInt(element.id) !== parseInt(event.target.accessKey);
            });
        }
    }

    showParentTable(){
        this.dispatchEvent(new CustomEvent('backaction', {
            detail: 'false',bubbles: true, composed: true
        }));
    }

    handleChange(event) {
        this.amcRecord[event.target.name] = event.target.value;
        let fieldName = event.target.name;
        let fieldValue = event.target.value;
    }
    handleEditChange(event) {
        this.amcSelectedRecords[event.target.name] = event.target.value;
    }

    handleEditSubmit(event) {
        if(this.isEditRestricted){
            this.showErrorMessage('You do not have Access Rights to update AMC Details', 'error');
            return
        }
        this.isLoaded = true;
        console.log('editeedValues-->' + JSON.stringify(this.amcSelectedRecords));
        let parsedData = JSON.parse( this.analysisJSON);
        let oldkey = this.selectedMonth +'-' +this.selectedYear;
        let key = this.amcSelectedRecords.month +'-' + this.amcSelectedRecords.year;
        console.log('key-->' +key);
        let amctotal = this.salaryTotal - this.selectedAMC
        let amcNewTotal = amctotal +parseFloat(this.amcSelectedRecords.credit);
        let amcAverage = amcNewTotal/this.counterVal;
        console.log('amcAverage-->' +amcAverage);

       /* if( parsedData.monthlyCreditsDetails.hasOwnProperty(key)){
            parsedData.monthlyCreditsDetails[key].Credit = this.amcSelectedRecords.credit;
            parsedData.monthlyCreditsDetails[key]["Salary Credit"] = this.amcSelectedRecords.salarycredit;
            parsedData.monthlyCreditsDetails[key].ManualCheck = true;
            
        } else{
            delete  parsedData.monthlyCreditsDetails[oldkey];
            parsedData.monthlyCreditsDetails[key] = {
                "Credit": this.amcSelectedRecords.credit,
                "Salary Credit": this.amcSelectedRecords.salarycredit,
                "ManualCheck":true
         }
     }*/
     let recFound = false;
     for(let i=0; i<parsedData.monthlyCreditsDetails.length; i++) {
       
        if(parsedData.monthlyCreditsDetails[i]["Month-Year"] === key) {
            parsedData.monthlyCreditsDetails[i].Credit = this.amcSelectedRecords.credit;
            parsedData.monthlyCreditsDetails[i]["Salary Credit"] = this.amcSelectedRecords.salarycredit;
            parsedData.monthlyCreditsDetails[i].ManualCheck = true;
            recFound = true;
        }
     }
     if(recFound == false){
     for(let i=0; i<parsedData.monthlyCreditsDetails.length; i++) {
        if(parsedData.monthlyCreditsDetails[i]["Month-Year"] === oldkey) {
            delete parsedData.monthlyCreditsDetails[i]["Credit"];
            delete  parsedData.monthlyCreditsDetails[i]["Salary Credit"];
            delete  parsedData.monthlyCreditsDetails[i]["ManualCheck"];
            parsedData.monthlyCreditsDetails[i].Credit = this.amcSelectedRecords.credit;
            parsedData.monthlyCreditsDetails[i]["Salary Credit"] = this.amcSelectedRecords.salarycredit;
            parsedData.monthlyCreditsDetails[i].ManualCheck = true;
            parsedData.monthlyCreditsDetails[i]["Month-Year"] =key;
     }
    }
  }
       
        console.log('finalArray-->' + JSON.stringify(parsedData));

        updateAmcRecord({
            bsaUpdatedRecord: JSON.stringify(parsedData),
            bankRecordId: this.bankRecordId,
            ambAverage : amcAverage,
            isAmb : false
        })
        .then(result => {
            this.isLoaded = false;

        }).catch(error => {
            console.log('error in updation-->' + JSON.stringify(error));
            this.isLoaded = false;
        });


    }


    handleSuccess(event) {
        this.isLoaded = true;
        this.handeRefreshEvent();
        this.showMessage('AMC Record Updated Successfully', 'success');
       // this.handeRefreshEvent();
        this.showEditForm = false;
        this.showView = true;
        this.isLoaded = false;

    }

    handleSubmit() {
        if(this.isEditRestricted){
            this.showErrorMessage('You do not have Access Rights to update AMC Details', 'error');
            return
        }
        if(this.amcRecord.month!=undefined && this.amcRecord.year!=undefined &&  this.amcRecord.credit!=undefined && this.amcRecord.salarycredit!=undefined){
        this.isLoaded = true;
        this.duplicatesCounter = this.duplicatesCounter +1;
        this.amcRecord.recordId = this.bankAccountRecords[0].recordId;
        console.log('bsaRecord-->' + JSON.stringify(this.amcRecord));
        let total = parseFloat(this.salaryTotal) + parseFloat(this.amcRecord.credit);
        
        let counter = this.counterVal +1;
        let amcAverageVal = total/counter;
        console.log('amcAverageVal-->' +amcAverageVal);

        let analysisData = JSON.parse(this.analysisJSON); //this.bankAccountRecords[0].analysisFullData
        
        let monthlyCreditsDetails = analysisData.monthlyCreditsDetails;
        let reqJSON = JSON.stringify(monthlyCreditsDetails);
        console.log('monthlyCreditsDetails[-->' +JSON.stringify(monthlyCreditsDetails));

        let jsonString = reqJSON.toLowerCase();
        let monthtoCheck = this.amcRecord.month;

       if(this.duplicatesCounter == 1){
        this.monthlist.push(monthtoCheck.toLowerCase());
       }
        let hasDuplicates = this.findDuplicates(monthtoCheck,this.monthlist);
        console.log('hasDuplicates-->' +hasDuplicates);

        if(jsonString.includes(this.amcRecord.month) || hasDuplicates == true){
            this.showErrorMessage('The data for the mentioned month already exists. Please add data for a different month', 'error');
            this.isLoaded = false;
            this.amcRecord.month='';
        }else{
            this.showAmcNewFormView = false;
            createAmcRecord({
                bsaRecord: JSON.stringify(this.amcRecord),
               amcAverage :amcAverageVal,
                applicantId: this.applicantId
            })
            .then(result => {
                this.isLoaded = false;
                this.amcRecord={};
                // console.log('result-->' + JSON.stringify(result));
                // this.inputsDisabled = true;
                this.showModal = true;
                this.showMessage('AMC Record Created Successfully', 'success');
                
                this.handeRefreshEvent();
            }).catch(error => {
                console.log('error-->' + JSON.stringify(error));
                this.isLoaded = false;
            });
        }
    }else{
        this.isLoaded = false;
        this.showErrorMessage('Please Fill All the Details','error');
    }


       
    }

    findDuplicates(checkValue,monthlist) {
        let duplicates = [];
        
       /* for (let i = 0; i < arr.length; i++) {
          for (let j = i + 1; j < arr.length; j++) {
            if (arr[i] === arr[j] && !duplicates.includes(arr[i])) {
              duplicates.push(arr[i]);
            }
          }
        }*/
        let checkFound = false;
        for(let i=0; i< monthlist.length ;i++){
            if(monthlist[i]==checkValue){
                checkFound = true;
            }
        }
        
        return checkFound;
      }



    showMessage(message, variant) {
        const event = new ShowToastEvent({
            title: '',
            variant: variant,
            mode: 'dismissable',
            message: message
        });
        this.dispatchEvent(event);
    }
    showErrorMessage(message, variant) {
        const event = new ShowToastEvent({
            title: '',
            variant: variant,
            mode: 'sticky',
            message: message
        });
        this.dispatchEvent(event);
    }

    handleNew() {
        if(this.isEditRestricted){
            this.showErrorMessage('You do not have Access Rights to add AMC Details', 'error');
            return
        }
        //  this.showView = false;
        this.showAmcNewFormView = true;
        // this.addAmbNewRow();
    }
    handleNewFormBack(){
        this.showAmcNewFormView = false;
    }

    handleOkay() {
        this.showModal = false;
        this.handleNew();
        this.addAmcNewRow();
    }
    handleReject() {
        this.showModal = false;
        this.showAmcNewFormView = false;
        this.showView = true;
        this.amcList =[];
        this.addAmcNewRow();
        this.handeRefreshEvent();
    }
    handeRefreshEvent() {
      
        this.isLoaded = true;
        getBankRecords({
                applicantId: this.applicantId
            }).then(result => {
                let bankAllRecords = result;
                let selectedData = bankAllRecords.filter(item => item.recordId === this.bankAccountRecords[0].recordId); // this.ambSelectedRecords.recordId
                this.handleAnalysis(selectedData[0].analysisFullData);
                this.isLoaded = false;
                this.showView = true;
            })
            .catch(error => {
                this.isLoaded = false;
                console.log('error in bank details-->' + error);
            })
    }
    handleRowAction(event) {
        if(this.isEditRestricted){
            this.showErrorMessage('You do not have Access Rights to edit AMC Details', 'error');
            return
        }
        const recordId = event.currentTarget.dataset.id;
        this.selectedMonth = event.currentTarget.title;
        this.selectedYear = event.currentTarget.dataset.recordName;
        let amcRecords = this.amcViewRecords;
        this.selectedAMC = parseFloat(event.currentTarget.alternativeText);
        //Filter the data from ambrecords for the selected Month 
        let selectedData = amcRecords.filter(item => item.month === this.selectedMonth);
        this.amcSelectedRecords = selectedData[0];
        
        console.log('selectedData-->' + JSON.stringify(selectedData));
        this.bankRecordId = recordId;
        this.showEditForm = true;
        this.showAmcNewFormView = false;
        this.showView = false;
    }
    handleRowDeleteAction(event){
        if(this.isEditRestricted){
            this.showErrorMessage('You do not have Access Rights to delete AMC Details', 'error');
            return
        }
        this.isLoaded = true;
        this.bankRecordId =  event.currentTarget.dataset.id;
        this.selectedMonth = event.currentTarget.title;
        this.selectedYear = event.currentTarget.dataset.recordName;
        this.selectedAMC = parseFloat(event.currentTarget.alternativeText);

        let amctotal = this.salaryTotal - this.selectedAMC
        let counter = this.counterVal - 1;
        let amcAverage = amctotal/counter;

        console.log('amcAverage-->' +amcAverage);
        let key = this.selectedMonth +'-' +this.selectedYear;
        let parsedData = JSON.parse( this.analysisJSON);
        
        //Delete the selected Month AMC Details
        //delete  parsedData.monthlyCreditsDetails[key];

        for(let i=0; i<parsedData.monthlyCreditsDetails.length; i++) {
            if(parsedData.monthlyCreditsDetails[i]["Month-Year"] === key) {
                delete parsedData.monthlyCreditsDetails[i]["Credit"];
                delete  parsedData.monthlyCreditsDetails[i]["Salary Credit"];
                delete  parsedData.monthlyCreditsDetails[i]["ManualCheck"];
                delete  parsedData.monthlyCreditsDetails[i]["Month-Year"];
                
         }
        }

        parsedData.monthlyCreditsDetails = parsedData.monthlyCreditsDetails.filter(obj => Object.keys(obj).length > 0);

        updateAmcRecord({
            bsaUpdatedRecord: JSON.stringify(parsedData),
            bankRecordId: this.bankRecordId,
            ambAverage : amcAverage,
            isAmb : false
        })
        .then(result => {
            this.isLoaded = false;
            this.showMessage('AMC Record Deleted Successfully', 'success');
            this.handeRefreshEvent();
        }).catch(error => {
            console.log('error in updation-->' + JSON.stringify(error));
            this.isLoaded = false;
        });
    }
    handleBack() {
        this.showEditForm = false;
        this.showAmcNewFormView = false;
        this.showView = true;
    }

}