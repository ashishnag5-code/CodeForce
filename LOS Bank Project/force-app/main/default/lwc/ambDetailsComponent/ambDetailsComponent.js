import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createAmbRecord from '@salesforce/apex/BSACreditController.createAmbRecord';
import updateAmbRecord from '@salesforce/apex/BSACreditController.updateAmbRecord';
import getBankRecords from '@salesforce/apex/BSACreditController.getBankRecords';
import validateRecordEdit from '@salesforce/apex/ComponentProfileRestrictionController.validateRecordEdit'//4733

export default class AmbDetailsComponent extends LightningElement {
    //API Attributes
    @api bankAccountRecords;
    @api applicantId;

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
    monthlist =[];
    duplicatesCounter=0;

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
                this.ambViewRecords=null;
                this.showAmbNewFormView = true;
            }
        } else {
            this.ambViewRecords=null;
            this.showAmbNewFormView = true;
        }
        this.setIsEditRestricted()
    }

    async setIsEditRestricted(){
        this.isEditRestricted = await validateRecordEdit({compName: 'financialView' ,recordId: this.applicantId})
    }

    handleAnalysis(analysisVal) {
        let analysisData = JSON.parse(analysisVal); //this.bankAccountRecords[0].analysisFullData
        let ambValues = [];
        const monthlyBalancesDetails = analysisData.monthlyBalancesDetails;
        console.log('monthlyBalancesDetails-->' +JSON.stringify(monthlyBalancesDetails));
        let counter = 0;
        let balance5Total =0;
        let balance15Total =0;
        let balance25Total = 0;
        let ambTotal = 0;
        let amcTotal = 0;
       /* for (let month in monthlyBalancesDetails) {
            if (monthlyBalancesDetails.hasOwnProperty(month)) {
                counter = counter+1;
                this.counterVal = counter;
                 let monthYearString = month;
                let [monthVal, year] = monthYearString.split("-");
                let balances = monthlyBalancesDetails[month];
                // Create a new object for the current month with the desired structure
                const monthData = {
                    amb: balances.AMB,
                    amc: balances.AMC,
                    balance5: balances['5'],
                    balance15: balances['15'],
                    balance25: balances['25'],
                    averageBalance: (parseFloat(balances['5']) + parseFloat(balances['15']) + parseFloat(balances['25']))/3,
                    month: monthVal,
                    year: year,
                    recordId: this.bankAccountRecords[0].recordId,
                    manualcheck: (balances['ManualCheck'] != null) ? (balances['ManualCheck']) : false
                };
                ambValues.push(monthData);
                balance5Total = balance5Total + parseFloat(balances['5']);
                balance15Total = balance15Total + parseFloat(balances['15']);
                balance25Total = balance25Total + parseFloat(balances['25']);
                ambTotal = ambTotal + parseFloat(balances.AMB);
                amcTotal = amcTotal + parseFloat(balances.AMC);
            }
        }*/
        for(let i=0; i<monthlyBalancesDetails.length; i++){
            counter = counter+1;
            this.counterVal = counter;
            let monthYearString = monthlyBalancesDetails[i]['Month-Year'];
            let [monthVal, year] = monthYearString.split("-");
             // Create a new object for the current month with the desired structure
             let balances =  monthlyBalancesDetails[i];
             const monthData = {
                amb: (balances.AMB).toFixed(2),
                amc: balances.AMC,
                averageBalanceOn5th: balances['averageBalanceOn5th'].toFixed(2),
                averageBalanceOn15th: balances['averageBalanceOn15th'].toFixed(2),
                averageBalanceOn25th: balances['averageBalanceOn25th'].toFixed(2),
                
                averageBalance: (parseFloat(balances['averageBalanceOn5th']) + parseFloat(balances['averageBalanceOn15th']) + parseFloat(balances['averageBalanceOn25th'])/3).toFixed(2),
                month: monthVal,
                year: year,
                recordId: this.bankAccountRecords[0].recordId,
                manualcheck: (balances['ManualCheck'] != null) ? (balances['ManualCheck']) : false
            };
            ambValues.push(monthData);
            balance5Total = balance5Total + parseFloat(balances['averageBalanceOn5th']);
            balance15Total = balance15Total + parseFloat(balances['averageBalanceOn15th']);
            balance25Total = balance25Total + parseFloat(balances['averageBalanceOn25th']);
            ambTotal = ambTotal + parseFloat(balances.AMB);
            amcTotal = amcTotal + parseFloat(balances.AMC);

        
        }

        this.ambViewRecords = ambValues;
        this.balance5Average = (balance5Total/counter).toFixed(2);
        this.balance15Average = (balance15Total/counter).toFixed(2);
        this.balance25Average = (balance25Total/counter).toFixed(2);
        this.ambAverage = ambTotal.toFixed(2);
        this.amcAverage = (amcTotal/counter).toFixed(2);
        this.balanceAverage =  ((parseFloat(this.balance5Average) +parseFloat(this.balance15Average) + parseFloat(this.balance25Average)) /3).toFixed(2);

        console.log('ambValues-->' + JSON.stringify(this.ambViewRecords));
        console.log('balance5Average-->' + this.balance5Average +'-- ' +  this.balance15Average +'---' + this.balance25Average);
    }
    showParentTable() {
        this.dispatchEvent(new CustomEvent('backaction', {
            detail: 'false',
            bubbles: true,
            composed: true
        }));
    }

    addAmbNewRow(event) {
        if(this.isEditRestricted){
            this.showErrorMessage('You do not have Access Rights to add AMB Details', 'error');
            return
        }
        ++this.keyIndex;
        var newItem = [{
            id: this.keyIndex
        }];
        this.ambList = this.ambList.concat(newItem);

    }
    removeAmbRow(event) {
        if (this.ambList.length >= 2) {
            this.ambList = this.ambList.filter(function (element) {
                return parseInt(element.id) !== parseInt(event.target.accessKey);
            });
        }
    }

    handleNew() {
        if(this.isEditRestricted){
            this.showErrorMessage('You do not have Access Rights to add AMB Details', 'error');
            return
        }
       // this.showView = false;
        this.showAmbNewFormView = true;
        // this.addAmbNewRow();
    }
    handleNewFormBack(){
        this.showAmbNewFormView = false;
    }

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
    }
    handleAverage(){
        let averageBalance =  (this.balance5 + this.balance15 + this.balance25)/3;
        this.averageBalanceVal = averageBalance;
        this.ambRecord.averageBalance = averageBalance;
        console.log('averageBalance-->' +averageBalance);
    }
    handleEditChange(event) {
        this.ambSelectedRecords[event.target.name] = event.target.value;
    }
    handleSubmit() {
        if(this.isEditRestricted){
            this.showErrorMessage('You do not have Access Rights to update AMB Details', 'error');
            return
        }
        if(this.ambRecord.month!=undefined && this.ambRecord.year!=undefined &&  this.ambRecord.amb!=undefined && this.ambRecord.amc!=undefined && this.ambRecord.averageBalanceOn5th!=undefined && this.ambRecord.averageBalanceOn15th!=undefined && this.ambRecord.averageBalanceOn25th!=undefined && this.ambRecord.averageBalance!=undefined){
        this.duplicatesCounter = this.duplicatesCounter +1;
        this.isLoaded = true;

        this.ambRecord.recordId = this.bankAccountRecords[0].recordId;
        console.log('bsaRecord-->' + JSON.stringify(this.ambRecord));
        console.log('amblatest-->' + parseFloat(this.ambRecord.amb));
        const ambLatest = parseFloat(this.ambRecord.amb);
        const ambAverage = parseFloat(this.ambAverage);
        let counter = this.counterVal +1;
        const ambTotal = ambAverage +  ambLatest;
        let ambActualAverage =   (ambTotal) /counter;
        console.log('ambTotal-->' +ambTotal);
        console.log('counter--<' +counter);
        console.log(' this.ambActualAverage-->' +ambActualAverage);
        let analysisData;
        let monthlyBalancesDetails;
        let reqJSON='';
        if(this.analysisJSON!=='' && this.analysisJSON!=null){
             analysisData = JSON.parse(this.analysisJSON);
             monthlyBalancesDetails = analysisData.monthlyBalancesDetails;
             reqJSON = JSON.stringify(monthlyBalancesDetails);
        }
        //this.bankAccountRecords[0].analysisFullData
        console.log('monthlyBalancesDetails[-->' +JSON.stringify(monthlyBalancesDetails));
        console.log('reqJSON->' +JSON.stringify(reqJSON));
        console.log('this.ambRecord.month->' +this.ambRecord.month);
        let jsonString = reqJSON.toLowerCase();
        let monthtoCheck = this.ambRecord.month;

       if(this.duplicatesCounter == 1){
        this.monthlist.push(monthtoCheck.toLowerCase());
       }
        let hasDuplicates = this.findDuplicates(monthtoCheck,this.monthlist);
        console.log('hasDuplicates-->' +hasDuplicates);
       
            if( jsonString.includes(monthtoCheck.toLowerCase()) || hasDuplicates == true ){
                this.showErrorMessage('The data for the mentioned month already exists. Please add data for a different month', 'error');
                this.isLoaded = false;
            }else{
                this.showAmbNewFormView = false;
                createAmbRecord({
                    bsaRecord: JSON.stringify(this.ambRecord),
                    ambAverage: ambActualAverage,
                    applicantId: this.applicantId
                })
                .then(result => {
                    this.isLoaded = false;
                    this.ambRecord={};
                    // console.log('result-->' + JSON.stringify(result));
                    // this.inputsDisabled = true;
                    this.showModal = true;
                    this.showMessage('AMB Record Created Successfully', 'success');
                   
                    this.averageBalanceVal=null;
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

/*   handleEditSubmit(event) {
        this.isLoaded = true;
        console.log('editeedValues-->' + JSON.stringify(this.ambSelectedRecords));
        const selectedRecords = this.ambSelectedRecords;
        const originalArray = this.ambViewRecords;

        //Replacing the edited values in an Array with the Original Array
        const updatedArray = originalArray.map(obj => {
            if (obj.month === this.selectedMonth) {
                return selectedRecords;
            } else {
                return obj;
            }
        });
        console.log('updatedArray-->' + JSON.stringify(updatedArray));

        //Forming to appropriate JSON
        const input = updatedArray;

        const output = input.reduce((result, item) => {
            const {
                month,
                year
            } = item;
            const key = `${month}-${year}`;
            const {
                amb,
                amc,
                balance5,
                balance15,
                balance25,
                averageBalance,
                manualcheck
            } = item;

            // If the key does not exist in the result object, add it with initial values
            if (!result[key]) {
                result[key] = {
                    "5": 0,
                    "15": 0,
                    "25": 0,
                    "AMB": 0,
                    "AMC": 0,
                    "ManualCheck": false,
                    "Average of Custom Days": 0
                };
            }

            // Update the values for the key
            result[key]["5"] += parseFloat(balance5) || 0;
            result[key]["15"] += parseFloat(balance15) || 0;
            result[key]["25"] += parseFloat(balance25) || 0;
            result[key]["AMB"] += parseFloat(amb) || 0;
            result[key]["AMC"] += parseFloat(amc) || 0;
            result[key]["Average of Custom Days"] += parseFloat(averageBalance) || 0;
            result[key]["ManualCheck"] = result[key]["ManualCheck"] || manualcheck;

            return result;
        }, {});

        // Convert the result object to the desired format
        const monthlyBalancesDetails = Object.entries(output).reduce((result, [key, value]) => {
            result[key] = value;
            // delete value["ManualCheck"];
            delete value["Average of Custom Days"];
            return result;
        }, {});

        const finalArray = {
            monthlyBalancesDetails
        };
        console.log('finalArray-->' + JSON.stringify(finalArray));

        updateAmbRecord({
                bsaUpdatedRecord: JSON.stringify(finalArray),
                bankRecordId: this.bankRecordId
            })
            .then(result => {
                this.isLoaded = false;

            }).catch(error => {
                console.log('error in updation-->' + JSON.stringify(error));
                this.isLoaded = false;
            });

    }*/
    
    handleEditSubmit(event) {
        if(this.isEditRestricted){
            this.showErrorMessage('You do not have Access Rights to update AMB Details', 'error');
            return
        }
        this.isLoaded = true;
        console.log('editeedValues-->' + JSON.stringify(this.ambSelectedRecords));
        let parsedData = JSON.parse( this.analysisJSON);
        let oldkey = this.selectedMonth +'-' +this.selectedYear;
        let key = this.ambSelectedRecords.month +'-' + this.ambSelectedRecords.year;
        console.log('key-->' +key);
        let ambtotal = this.ambAverage - this.selectedAMB
        let ambNewTotal = ambtotal +parseFloat(this.ambSelectedRecords.amb);
        let ambAverage = ambNewTotal/this.counterVal;
        console.log('parsedData-->' +JSON.stringify(parsedData,null,2));
        console.log('ambAverage-->' +ambAverage);
        let recFound = false;
        for(let i=0; i<parsedData.monthlyBalancesDetails.length; i++) {
            console.log('parsedData[i]-->' +parsedData.monthlyBalancesDetails[i]["Month-Year"]);
            if(parsedData.monthlyBalancesDetails[i]["Month-Year"] === key) {
                parsedData.monthlyBalancesDetails[i]["averageBalanceOn5th"] = this.ambSelectedRecords.averageBalanceOn5th;
                parsedData.monthlyBalancesDetails[i]["averageBalanceOn15th"] = this.ambSelectedRecords.averageBalanceOn15th;
                parsedData.monthlyBalancesDetails[i]["averageBalanceOn25th"] = this.ambSelectedRecords.averageBalanceOn25th;
                parsedData.monthlyBalancesDetails[i]["AMB"] = this.ambSelectedRecords.amb;
                parsedData.monthlyBalancesDetails[i]["AMC"] = this.ambSelectedRecords.amc;
                parsedData.monthlyBalancesDetails[i]["Average of Custom Days"] = this.ambSelectedRecords.averageBalance;
                parsedData.monthlyBalancesDetails[i].ManualCheck = true;
                recFound = true;
            }
         }
         if(recFound == false){
         for(let i=0; i<parsedData.monthlyBalancesDetails.length; i++) {
            if(parsedData.monthlyBalancesDetails[i]["Month-Year"] === oldkey) {
                delete parsedData.monthlyBalancesDetails[i]["Month-Year"];
                delete  parsedData.monthlyBalancesDetails[i]["averageBalanceOn5th"];
                delete  parsedData.monthlyBalancesDetails[i]["averageBalanceOn15th"];
                delete  parsedData.monthlyBalancesDetails[i]["averageBalanceOn25th"];
                delete  parsedData.monthlyBalancesDetails[i]["AMB"];
                delete  parsedData.monthlyBalancesDetails[i]["AMC"];
                delete  parsedData.monthlyBalancesDetails[i]["Average of Custom Days"];
                delete  parsedData.monthlyBalancesDetails[i]["ManualCheck"];
                
                parsedData.monthlyBalancesDetails[i]["averageBalanceOn5th"] = this.ambSelectedRecords.averageBalanceOn5th;
                parsedData.monthlyBalancesDetails[i]["averageBalanceOn15th"] = this.ambSelectedRecords.averageBalanceOn15th;
                parsedData.monthlyBalancesDetails[i]["averageBalanceOn25th"] = this.ambSelectedRecords.averageBalanceOn25th;
                parsedData.monthlyBalancesDetails[i]["AMB"] = this.ambSelectedRecords.amb;
                parsedData.monthlyBalancesDetails[i]["AMC"] = this.ambSelectedRecords.amc;
                parsedData.monthlyBalancesDetails[i]["Average of Custom Days"] = this.ambSelectedRecords.averageBalance;
                parsedData.monthlyBalancesDetails[i].ManualCheck = true;
                parsedData.monthlyBalancesDetails[i]["Month-Year"] =key;
         }
        }
      }
       
      /*  if( parsedData.monthlyBalancesDetails.hasOwnProperty(key)){
            parsedData.monthlyBalancesDetails[key]["averageBalanceOn5th"] = this.ambSelectedRecords.averageBalanceOn5th;
            parsedData.monthlyBalancesDetails[key]["averageBalanceOn15th"] = this.ambSelectedRecords.averageBalanceOn15th;
            parsedData.monthlyBalancesDetails[key]["averageBalanceOn25th"] = this.ambSelectedRecords.averageBalanceOn25th;
            parsedData.monthlyBalancesDetails[key]["AMB"] = this.ambSelectedRecords.amb;
            parsedData.monthlyBalancesDetails[key]["AMC"] = this.ambSelectedRecords.amc;
            parsedData.monthlyBalancesDetails[key]["Average of Custom Days"] = this.ambSelectedRecords.averageBalance;
            parsedData.monthlyBalancesDetails[key].ManualCheck = true;
        } else{
            delete  parsedData.monthlyBalancesDetails[oldkey];
            parsedData.monthlyBalancesDetails[key] = {
                "averageBalanceOn5th":  this.ambSelectedRecords.averageBalanceOn5th,
                "averageBalanceOn15th":  this.ambSelectedRecords.averageBalanceOn15th,
                "averageBalanceOn25th":  this.ambSelectedRecords.averageBalanceOn25th,
                "AMB":this.ambSelectedRecords.amb,
                "AMC":this.ambSelectedRecords.amc,
                "Average of Custom Days":this.ambSelectedRecords.averageBalance,
                "ManualCheck":true
         }*/
         console.log('finalArray-->' + JSON.stringify(parsedData,null,2));       
       

        updateAmbRecord({
            bsaUpdatedRecord: JSON.stringify(parsedData),
            bankRecordId: this.bankRecordId,
            ambAverage : ambAverage,
            isAmb : true
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
        //this.handeRefreshEvent();
        this.showMessage('AMB Record Updated Successfully', 'success');
        this.handeRefreshEvent();
        this.showEditForm = false;
        this.showView = true;
        this.isLoaded = false;

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

    handleOkay() {
        this.showModal = false;
        this.handleNew();
       // this.addAmbNewRow();
    }

    handleReject() {
        this.showModal = false;
        this.showAmbNewFormView = false;
        this.showView = true;
        this.ambList =[];
        this.addAmbNewRow();
        this.handeRefreshEvent();
    }

    handeRefreshEvent() {
        /*   this.dispatchEvent(new CustomEvent('refresh', {
               detail: this.applicantId
           }));*/
        this.isLoaded = true;
        getBankRecords({
                applicantId: this.applicantId
            }).then(result => {
                let bankAllRecords = result;
                let selectedData = bankAllRecords.filter(item => item.recordId === this.bankAccountRecords[0].recordId); // this.ambSelectedRecords.recordId
                this.handleAnalysis(selectedData[0].analysisFullData);
                //console.log('bankAllRecords-->' + JSON.stringify(bankAllRecords))
                //console.log('this.bankAccountRecords[0].recordId-->' +this.bankAccountRecords[0].recordId);
                // console.log('selectedData-->' + JSON.stringify(selectedData));
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
            this.showErrorMessage('You do not have Access Rights to edit AMB Details', 'error');
            return
        }
        const recordId = event.currentTarget.dataset.id;
        this.selectedMonth = event.currentTarget.title;
        this.selectedAMB = parseFloat(event.currentTarget.alternativeText);
        this.selectedYear = event.currentTarget.dataset.recordName;
        let ambRecords = this.ambViewRecords;
        //Filter the data from ambrecords for the selected Month 
        let selectedData = ambRecords.filter(item => item.month === this.selectedMonth);
        this.ambSelectedRecords = selectedData[0];
        console.log('selectedData-->' + JSON.stringify(selectedData));
        this.bankRecordId = recordId;
        this.showEditForm = true;
        this.showAmbNewFormView = false;
        this.showView = false;
    }

    handleRowDeleteAction(event){
        if(this.isEditRestricted){
            this.showErrorMessage('You do not have Access Rights to delete AMB Details', 'error');
            return
        }
        this.isLoaded = true;
        this.bankRecordId =  event.currentTarget.dataset.id;
        this.selectedMonth = event.currentTarget.title;
        this.selectedYear = event.currentTarget.dataset.recordName;
        this.selectedAMB = parseFloat(event.currentTarget.alternativeText);

        let ambtotal = this.ambAverage - this.selectedAMB
        let counter = this.counterVal - 1;
        let ambAverage = ambtotal/counter;

        console.log('ambAverage-->' +ambAverage);

        let key = this.selectedMonth +'-' +this.selectedYear;
        let parsedData = JSON.parse( this.analysisJSON);
        
        //Delete the selected Month AMB Details
       //delete  parsedData.monthlyBalancesDetails[key];
        for(let i=0; i<parsedData.monthlyBalancesDetails.length; i++) {
            if(parsedData.monthlyBalancesDetails[i]["Month-Year"] === key) {
                delete parsedData.monthlyBalancesDetails[i]["Month-Year"];
                delete  parsedData.monthlyBalancesDetails[i]["averageBalanceOn5th"];
                delete  parsedData.monthlyBalancesDetails[i]["averageBalanceOn15th"];
                delete  parsedData.monthlyBalancesDetails[i]["averageBalanceOn25th"];
                delete  parsedData.monthlyBalancesDetails[i]["AMB"];
                delete  parsedData.monthlyBalancesDetails[i]["AMC"];
                delete  parsedData.monthlyBalancesDetails[i]["Average of Custom Days"];
                delete  parsedData.monthlyBalancesDetails[i]["ManualCheck"];
                
         }
        }
        parsedData.monthlyBalancesDetails = parsedData.monthlyBalancesDetails.filter(obj => Object.keys(obj).length > 0);
       // parsedData.monthlyBalancesDetails = parsedData.monthlyBalancesDetails.filter(obj => obj["Month-Year"] !== key);
        updateAmbRecord({
            bsaUpdatedRecord: JSON.stringify(parsedData),
            bankRecordId: this.bankRecordId,
            ambAverage : ambAverage,
            isAmb : true
        })
        .then(result => {
            this.isLoaded = false;
            this.showMessage('AMB Record Deleted Successfully', 'success');
            this.handeRefreshEvent();
        }).catch(error => {
            console.log('error in updation-->' + JSON.stringify(error));
            this.isLoaded = false;
        });

    }
    handleBack() {
        this.showEditForm = false;
        this.showAmbNewFormView = false;
        this.showView = true;
    }

    handleAmbRecord(event){
        this.ambRecord = event.detail;
    }
}