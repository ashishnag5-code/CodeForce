import { LightningElement,api,track } from 'lwc';
import GenerateRandomNumber from '@salesforce/apex/AUSFVehicleController.GenerateRandomNumber';
import handleCandoLeadApi from '@salesforce/apex/AUSFValuationController.handleCandoLeadApi';
import getValueMasterDetails from '@salesforce/apex/AUSFValuationController.getValueMasterDetails';
import handleUpdateValuation from '@salesforce/apex/AUSFValuationController.handleUpdateValuation';
import getLoanSchemeMasterDetails from '@salesforce/apex/AUSFValuationController.getLoanSchemeMasterDetails';
//import getDetails from '@salesforce/apex/AUSFValuationController.getLatestValuationDetails';
import getCollateralDetails from '@salesforce/apex/AUSFValuationController.getCollateralDetails';
import handleUpdateCollateral from '@salesforce/apex/AUSFValuationController.handleUpdateCollateral';
import {NavigationMixin} from 'lightning/navigation';
import branchTopup from '@salesforce/label/c.AUSF_Branch_topup';
import getLatestValuationRecords from '@salesforce/apex/AUSFValuationController.getLatestValuationRecords';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getGradingValue from '@salesforce/apex/AUSFValuationController.getGradingValue';
import {
    APPLICATION_SCOPE,
    createMessageContext,
    MessageContext,
    publish,
    releaseMessageContext,
    subscribe,
    unsubscribe,
} from 'lightning/messageService';
import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c';

export default class AusfValuationDetails extends NavigationMixin(LightningElement) {

    trueValue = true;
    falseValue = false;
    isloading = false;
    @track valuationRecord = {};
    collateralEditRecord = {};
    messageContext = createMessageContext();
    //API Attributes
    @api valuerNameCodeOptions = []
    @api loanApplication;

    //String Attributes
    loanId;
    variant;
    integrationName = 'CANDOLEAD';
    actionName = '';
    showValuation = true;
    mmvMasterName = '';
    collateralName = '';
    stateVal = '';
    phoneVal = '';
    collateralRecord;
    valuationResponseRecord;
    filesDate;
    valuationRecordId = '';
    allocationDateAndTime;
    referenceId;
    collateralId = '';
    valuerName ='';
    contactName = '';
    currentMonth;


    //Array Attributes
    contactOptions = [];
    valueMasterDetails = [];
    triggerSelectedArray = [];
    valuationDetails = [];
    combinedData = [];
    actionOptions = [];
    stateList = [];
    valRecord;
    

    //Boolean Attributes
    showOtherPicklist = false;
    //showOtherSection = false;
    onValuationDisableCheck = false;
    showCancelButton = false;
    responseStatus = false;
    showDocumentPopup = false;
    actionDisableCheck = false;
    showContactPicklist = true;
    valuerDisable = false;
    showExistingDetails = false;
    showSecondValuation = false;
    hasRevoked = false;
    ValuerNameChanged = false;
    revokedSuccessful = false;

    //Decimal Attributes
    valuationAmount = 0;

    collateralMap = new Map();
    collatralData;

    @api
    get defaultValue() {
        return this.defaultValue;
    }

    set defaultValue(value) {
        if( value =='' || value == undefined ||  this.valuerNameCodeOptions.length ==0){
            let optionValuer = [{label:'Auto Inspect',value:'Auto Inspect'},{label:'Other valuation',value:'Other valuation'},{label:'Cando',value:'Cando'}];
             this.valuerNameCodeOptions = optionValuer;
        }

        console.log('defaultValue is ' + JSON.stringify(value))
        this.valuationRecord.Valuer_Name_Code__c = value
        this.valuerName = value;
        
    }

    @api
    get vehicleRecord() {
        return this.vehicleRecord;
    }

    set vehicleRecord(value) {
        console.log('value is ' + JSON.stringify(value))
        this.valuationRecord.Product__c = value.Loan__r.Product__c != null ? value.Loan__r.Product__c : '';
        this.valuationRecord.Collateral_Type__c = value.Collateral_Type__c != null ? value.Collateral_Type__c : '';
        this.valuationRecord.MMV_Master__c = value.MMV_Master__c != null ? value.MMV_Master__c : '';
        //this.mmvMasterName = value.MMV_Master__c != null ? value.MMV_Master__r.Name : '';
        this.mmvMasterName = value.Variant__c != null ? value.Variant__c : '';
        this.collateralName = value.Collateral_Name__c != null ? value.Collateral_Name__c : '';
        this.valuationRecord.Vehicle_Number__c = value.Vehicle_Number__c != null ? value.Vehicle_Number__c : '';
        this.loanId = value.Loan__c != null ? value.Loan__c : '';
        this.variant = value.Variant__c != null ? value.Variant__c : '';

        this.getMasterDetails(this.loanId);
        //this.getLoanDetails(this.loanId);

        this.getCollateralValues(value.Id, this.loanId);


    }

    get actions() {
        return [{
                label: 'Trigger',
                value: 'Trigger'
            },
            {
                label: 'Revoke',
                value: 'Revoke'
            },
            {
                label: 'Reassign',
                value: 'Reassign'
            },
            {
                label: 'Retrigger',
                value: 'Retrigger'
            },
        ];
    }

    get acceptedFormats() {
        return ['.pdf', '.png'];
    }


    // Expose the labels to use in the template.
    label = {
        branchTopup

    };

    connectedCallback() {
        this.showValuation = true;
        this.handleRandomNumber();
        this.loadValuation();
        // this.handleInitialValues();
        // this.getExistingValuationDetails('a016s000003bd5cAAA');
        const TODAY = new Date();
        this.currentMonth = TODAY.getMonth()+1;

    }
    handleInitialValues() {

        console.log('defaultValue is ' + JSON.stringify(value))
        this.valuationRecord.Valuer_Name_Code__c = this.defaultValue


        let value = this.vehicleRecord;
        this.valuationRecord.Product__c = value.Loan__r.Product__c;
        this.valuationRecord.Collateral_Type__c = value.Collateral_Type__c;
        this.valuationRecord.MMV_Master__c = value.MMV_Master__c;
        this.mmvMasterName = value.MMV_Master__r.Name;
        this.collateralName = value.Collateral_Name__c;
        this.valuationRecord.Vehicle_Number__c = value.Vehicle_Number__c;
        this.loanId = value.Loan__c;
        this.variant = value.Variant__c;

        this.getMasterDetails(this.loanId);
        this.getCollateralValues(value.Id, this.loanId);



    }

    loadValuation(){
        
        getLatestValuationRecords({
            loanId: this.loanId
        })
        .then(data => {
          console.log('valuationData-->' +JSON.stringify(data)); 
            if(data!='' && data!=null){
                this.valuerName = data[0]!=null ? data[0].Valuer_Name_Code__c!=null ? data[0].Valuer_Name_Code__c : '' :'';
                this.contactName = data[0]!=null ? data[0].Coordinate_for_valuation_POC__c!=null ? data[0].Coordinate_for_valuation_POC__c :'' :'';
                this.phoneVal = data[0]!=null ? data[0].Contact_Person_Mobile_Number__c!=null ?  data[0].Contact_Person_Mobile_Number__c : '' :'';
                this.actionVal = data[0]!=null ?  data[0].Action__c!=null ?  data[0].Action__c  :'' :'';

                this.valuationRecord.Valuer_Name_Code__c = this.valuerName;
                if(this.valuerName == 'Other valuation'){
                    this.showOtherPicklist = true;
                }
                this.valuationRecord.Coordinate_for_valuation_POC__c = this.contactName;
                this.valuationRecord.Contact_Person_Mobile_Number__c = this.phoneVal;
                this.valuationRecord.Action__c = this.actionVal;
                this.actionName = this.actionVal;

                this.triggerSelectedArray.push(this.actionName); 
                this.ValuerNameChanged = false;
                this.loadAllActionOptions();
                this.integrationName =   data[0].Valuer_Name_Code__c == 'Cando' ? 'CANDOLEAD' : data[0].Valuer_Name_Code__c == 'Auto Inspect' ? 'GENNEWLEAD' : 'Other valuation'; // R2
            }else{
                this.ValuerNameChanged = true; //added because this is the first time they are sending for valuation
                let options =[];
                options.push({
                    label: 'Trigger',
                    value: 'Trigger'
                });
                this.actionOptions = options;
            }

        })


        getGradingValue({loanId: this.loanId}) //SFAU-3419
        .then(data => {
                if(data == true){
                    this.showMessage('You needs to upload Certified Valuation mandatorily before sending to credit (Document Name - Certified Valuation)','info');
                }
          })
    }

    loadAllActionOptions(){
        let options =[];
        options.push({
            label: 'Trigger',
            value: 'Trigger'
        });

        options.push({
            label: 'Revoke',
            value: 'Revoke'
        });

        options.push({
            label: 'Reassign',
            value: 'Reassign'
        });

        options.push({
            label: 'Retrigger',
            value: 'Retrigger'
        });

        this.actionOptions = options;
    }
    /* getLoanDetails(loanId){
          this.isloading = true;
         getDetails({loanId: loanId})
          .then(data => {   
              if(data){
                  let valuationDetails = data;
                  console.log('valuationDetails-->' +JSON.stringify(valuationDetails));
                  
                  this.valuationDetails = data;
                 // this.valRecord = valuationDetails[0];
                  this.isloading = false;
                  this.showExistingDetails = true;
              }else{
                  this.showExistingDetails = false;
              }
             // this.showExistingDetails = false; //will comment afterwards used for testing
            })
            .catch(error => {
                console.log('errorin getMaster '+JSON.stringify(error));
                this.isloading = false;
            })
          
      }*/
    /* renderedCallback() {
       console.log('FORM_FACTOR-->' +FORM_FACTOR);
       if(FORM_FACTOR =='Large'){ // Large Small
         const tableCells = this.template.querySelectorAll('.table-container td');
           tableCells.forEach(cell => {
            cell.classList.add('rowWidth');
          });
          const table = this.template.querySelector('.table-container');
          table.classList.add('tableMobileWidth');
        }
       
     }*/


    getCollateralValues(collateralId, loanId) {
        this.isloading = true;
        getCollateralDetails({
                collateralId: collateralId,
                loanId: loanId
            })
            .then(data => {
                console.log('collateraldata-->'+JSON.stringify(data));
                this.collateralId = data.Collateral[0].Id;
                if (data.Valuation.length > 0) {

                    const valuation1 = data.Valuation[0];
                    // Get the second valuation node
                    const valuation2 = data.Valuation[1];
                    // Combine valuation nodes and collateral node into a single array

                    const combined = {};
                    data.Valuation.forEach((val, i) => {
                        combined[`Valuation${i + 1}`] = val;
                    });
                    combined.Collateral = data.Collateral[0];
                    this.collatralData = data.Collateral[0];
                    this.combinedData.push(combined);
                    console.log('combinedRecords-->' + JSON.stringify(this.combinedData));
                    let combinedString = JSON.stringify(combined);
                    if (combinedString.includes('Valuation2')) {
                        this.showSecondValuation = true;
                    } else {
                        this.showSecondValuation = false;
                    }
                    console.log('showSecondValuation-->' + this.showSecondValuation);

                    this.showExistingDetails = true;
                } else {
                    this.showExistingDetails = false;
                }

            })
            .catch(error => {
                console.log('errorin getCollateralDetails ' + JSON.stringify(error));
                this.isloading = false;
            })
        this.isloading = false;


    }
    /*  getExistingValuationDetails(loanId){
          console.log('insideexisting');
        
      }*/
    handleRandomNumber() {
        this.isloading = true;
        GenerateRandomNumber({
                length: 15
            })
            .then(data => {
                this.referenceId = data;
                let currDate = new Date().toISOString().substring(0, 16);
                this.allocationDateAndTime = currDate;
                // console.log('date is ' + currDate + ' ' + data);
                this.valuationRecord.Reference_ID__c = this.referenceId;
                //  this.valuationRecord.Allocation_Date_Time__c = this.allocationDateAndTime;

                this.isloading = false;
                this.isloading = false;
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
                this.isloading = false;
            })
    }
    getMasterDetails(loanId) {
        this.isloading = true;

        getValueMasterDetails({
                loanId: loanId
            })
            .then(data => {
                //if (data.length >0) {
                     console.log('valueMaster-->' +JSON.stringify(data));
                     this.valueMasterDetails =  data.valueMasterList;
                     let masterList = data.valueMasterList;
                     let options=[];
                     for (var key in masterList) {
                        options.push({
                            label: masterList[key].State__c,
                            value: masterList[key].State__c
                        });
                     }
                     this.stateList = this.getUniqueValue(options);
                    /*this.valueMasterDetails = data.selectedValueMaster;*/
                    if(data.selectedValueMaster.length>0){
                        this.stateVal =  data.selectedValueMaster[0].State__c!=undefined ? data.selectedValueMaster[0].State__c:'';
                        this.getContactDetails(this.stateVal );
                    }
                    this.isloading = false;
              //  }

            })
            .catch(error => {
                console.log('errorin getMaster ' + error);
                this.isloading = false;
            })
        this.isloading = false;
    }

    getUniqueValue(myList){
        let uniqueList = myList.reduce((accumulator, currentValue) => {
            if (!accumulator.find(item => JSON.stringify(item) === JSON.stringify(currentValue))) {
              accumulator.push(currentValue);
            }
            return accumulator;
          }, []);
          uniqueList.sort((a, b) => a.label.localeCompare(b.label)); 
          return uniqueList;
    }


    getContactDetails(selectedVal) {
        let options = [];
        let record =  this.valueMasterDetails;
        for (var key in record) {
            //  if (masterList[key].Type_of_Employment__c == this.employmentEditValue) {
            if( record[key].State__c == selectedVal )  {
                options.push({
                    label: record[key].Agency_Name__c,
                    value: record[key].Agency_Name__c
                });
            }  
            //  }
        }
        this.contactOptions = options;
    }

    handleChange(event) {
        let picklistField = event.target.name;
        let picklistValue = event.target.value;
        this.valuationRecord[picklistField] = event.target.value;

        let triggerChangeOptions = [];
        triggerChangeOptions = this.triggerSelectedArray;
        if(picklistField == 'Other_state_and_list_from_master__c'){
            //jul4
            this.getContactDetails(picklistValue);
        }
        if (picklistField == 'Coordinate_for_valuation_POC__c') {
           this.getMobileOptions(event.target.value);
            
        }
        if (picklistField == 'Contact_Person_Mobile_Number__c') {
            this.phoneVal = picklistValue;
        }



        if (picklistField == 'Action__c') {
            this.actionName = event.target.value;
            if (this.actionName == 'Revoke') {
                this.showCancelButton = true;
                this.hasRevoked = true;
            } else if ((this.actionName == 'Reassign') || (this.actionName == 'Retrigger')) {
                this.handleRandomNumber();
                this.onValuationDisableCheck = false;
                this.showCancelButton = false;
                
            } else {
                this.showCancelButton = false;
                this.onValuationDisableCheck = false;
                this.valuerDisable = false;
               
            }
            triggerChangeOptions.push(picklistValue);
            this.triggerSelectedArray = triggerChangeOptions;
        }

        if (picklistField == 'Valuer_Name_Code__c') {
            this.showOtherPicklist = false;
            if (picklistValue == 'Cando') {
                this.integrationName = 'CANDOLEAD';
                // this.showContactPicklist = false;
            } else if (picklistValue == 'Auto Inspect') {
                this.integrationName = 'GENNEWLEAD';
                this.showContactPicklist = true;
            } else if (picklistValue == 'Other valuation') {
                this.showOtherPicklist = true;
                this.integrationName = 'Other valuation';
            }
            this.ValuerNameChanged = true;
        }

        if (picklistField == 'Valuation_Amount__c') {
            this.valuationAmount = picklistValue;
        }
        //this.handleDataMissMatch(); //we need to remove afterwards
    }
    getMobileOptions(selectedValue) {
        let masterDetails = this.valueMasterDetails;
        let phoneValue;
        for (var key in masterDetails) {
            if (masterDetails[key].Agency_Name__c == selectedValue) {
                phoneValue = masterDetails[key].Phone_No__c;
            }
        }

        this.phoneVal = phoneValue;

    }
    handleSubmit() {
        console.log('this.actionName' + this.actionName);
        console.log('this.integrationName' + this.integrationName);
        console.log('this.record' + JSON.stringify(this.valuationRecord));
        this.loadAllActionOptions();
        let responseVal;
        const numbers = this.triggerSelectedArray;
        let actionCompleted = false;
        if ((numbers.includes('Trigger')) && (numbers.includes('Retrigger') && (numbers.length == 3))) {
            actionCompleted = true;
        }
        console.log('numbers-->' + numbers);

        let selectedAction = this.actionName;
        const duplicates = numbers.filter((number, index) => numbers.indexOf(number) !== index);


        console.log('actionCompleted-->' + actionCompleted);
        console.log('numbers.length-->' + numbers);
        console.log('duplicateCheck-->' + duplicates.length);
        console.log('this.valuationRecord-->' +JSON.stringify(this.valuationRecord));
       
        if (this.isInputValid()) {
            this.isloading = true;
           // if ((duplicates.length != 0) || ((actionCompleted == true) && (numbers.length >= 3))) { 
            console.log('this.ValuerNameChanged==>' +this.ValuerNameChanged);
            console.log('this.hasRevoked==>' +this.hasRevoked);
            console.log('this.revokedSuccessful==>' +this.revokedSuccessful);


            if( (this.ValuerNameChanged == false) &&  (this.showCancelButton == false) ){ //(this.hasRevoked == false) &&
                
                //this.showMessage('The action has already been completed, so please choose a different one', 'error');
                this.showMessage('Please Revoke the Valuation or Change the Valuer Name to Proceed', 'error');
                this.isloading = false;
            } else {   //END
                if ((this.actionName == 'Trigger') || (this.actionName == 'Reassign') || (this.actionName == 'Retrigger')) {
                    
                    // This should be added only in Other valuation 
                    if (this.showOtherPicklist == true) {
                        this.valuationRecord.Other_state_and_list_from_master__c = this.stateVal;
                        this.valuationRecord.Contact_Person_Mobile_Number__c = this.phoneVal;
                    }
                    this.valuationRecord.Collateral__c = this.collateralId;
                    this.showSuccessMessage('Valuation Request Sent Successfully', 'success');
                    this.ValuerNameChanged = false;
                    this.onValuationDisableCheck = true;
                    this.valuerDisable = true;
                    handleCandoLeadApi({
                            valuationRecord: this.valuationRecord,
                            integrationName: this.integrationName,
                            loanId: this.loanId,
                            variantName: this.variant
                        })
                        .then(data => {
                            
                            responseVal = data;
                            this.responseStatus = responseVal.boolResponse;
                            this.valuationRecordId = responseVal.valuationId;
                            //this.valuationResponseRecord = responseVal.valuationRecord;
                            console.log('responseStatus-->' + JSON.stringify(responseVal));
                            if ((this.responseStatus == false) && (this.integrationName != 'Other valuation')) {
                                this.showDocumentPopup = true;

                            } else {
                                //   this.showOtherSection = true;
                                // this.handleDataMissMatch(); will do afterwards
                                const payload = { recordIdOfSobject: this.loanId, refreshPage: 'Yes'};
                                publish(this.messageContext, pageRefreshOnMaterialFieldChange, payload); // R2 Change
                            }
                            
                           
                            this.isloading = false;
                        })
                        .catch(error => {
                            console.log('error is ' + JSON.stringify(error));
                            this.isloading = false;
                        })
                }
                if (this.actionName == 'Revoke') {
                   
                    this.isloading = true;
                    console.log('updateHandler-->' + this.valuationRecord.Vehicle_Number__c);

                    handleUpdateValuation({
                            referenceNo: this.referenceId,
                            actionName: 'Revoke',
                            valuationAmount: 0,
                            valuationVehicleNumber: this.valuationRecord.Vehicle_Number__c
                        })
                        .then(data => {
                            this.showSuccessMessage('Valuation Revoked Successfully', 'success');
                            this.ValuerNameChanged = true;
                            this.revokedSuccessful = true;
                            this.isloading = false;
                        })
                        .catch(error => {
                            console.log('error is ' + JSON.stringify(error));
                            this.isloading = false;
                        })
                }
            }
            this.isloading = false;
        }
    }


    handleBackAction() {
        this.isloading = true;
        this.showValuation = false;
        this.dispatchEvent(new CustomEvent('navigatehome', {
            detail: 'false'
        }));
        this.isloading = false;

    }


    showMessage(message, variant) {
        const event = new ShowToastEvent({
            title: '',
            variant: variant,
            mode: 'sticky',
            message: message
        });
        this.dispatchEvent(event);
    }

    showSuccessMessage(message, variant) {
        const event = new ShowToastEvent({
            title: '',
            variant: variant,
            mode: 'dismissable',
            message: message
        });
        this.dispatchEvent(event);
    }

    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        this.filesDate = uploadedFiles;
        console.log('No. of files uploaded : ' + uploadedFiles.length);
    }

    handleOkay() {
        this.actionName
        handleUpdateValuation({
                referenceNo: this.referenceId,
                actionName: '',
                valuationAmount: this.valuationAmount,
                valuationVehicleNumber: this.valuationRecord.Vehicle_Number__c
            })
            .then(data => {
                this.showSuccessMessage('Valuation Amount Updated Successfully', 'success');
                this.closeModal();
               /* const Obj = {};
                Obj.applicantLst =  this.collatralData;
                this.dispatchEvent(new CustomEvent('newsave', {
                    detail:Obj
                }));*/
                const payload = { recordIdOfSobject: this.loanId, refreshPage: 'Yes'};
                publish(this.messageContext, pageRefreshOnMaterialFieldChange, payload); // R2 Change
                
                this.isloading = false;
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
                this.isloading = false;
            })
    }
    closeModal() {
        this.showDocumentPopup = false;
    }



    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll(".validate");
        inputFields.forEach(inputField => {
            if (!inputField.value) {
                inputField.setCustomValidity("Complete this field");
                inputField.reportValidity();
                isValid = false;
            } else {
                inputField.setCustomValidity('');
                inputField.reportValidity();
            }
        });
        return isValid;
    }

    handleReport(event) {
        //let recId = event.currentTarget.dataset.id;
        /*  let data =  this.combinedData[0].Valuation1.FileMap;
          let recordID =  this.combinedData[0].Valuation2.Id;
         let filesList = Object.keys(data).map(item=>({"label":data[item],
               "value": item
              
              }))

              
          console.log('recId-->' +JSON.stringify(filesList));*/

        if (event.target.name != '') {
            this.isloading = true;
            let fileId = event.target.name;
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state: {
                    selectedRecordId: fileId
                }
            })
            this.isloading = false;
        } else {
            this.isloading = true;
            this.showMessage('Please try again with another record as there is no file associated with this one.', 'error');
            this.isloading = false;
        }

    }

    handleSuccess(event){
     //   this.showSuccessMessage('Document uploaded successfully', 'success');
    }

    handleCollateralChange(event) {
        this.collateralEditRecord.Id = this.collateralId;
        if(event.target.name == 'Manufacture_year_month__c'){
            let val= event.target.value + this.currentMonth;
            this.collateralEditRecord['Manufacture_year_month__c'] =val;
        }else{
            this.collateralEditRecord[event.target.name] = event.target.value;
        }
        
    }
    handleCollateralEdit() {
        this.isloading = true;
        console.log(' this.collateralEditRecord-->' + JSON.stringify(this.collateralEditRecord));
        handleUpdateCollateral({
                collateralRecord: this.collateralEditRecord
            })
            .then(data => {
                this.showSuccessMessage('Collateral Updated Successfully', 'success');

                this.isloading = false;
            })
            .catch(error => {
                console.log('error is ' + error);
                this.isloading = false;
            })
    }

}