import { LightningElement, wire, api, track } from 'lwc';
import fetchTVR from '@salesforce/apex/TVRLoanApplicationPageController.fetchTVR';
import deleteTVR from '@salesforce/apex/TVRLoanApplicationPageController.deleteTVR';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
//import { CurrentPageReference } from 'lightning/navigation';
import Employee_Code from "@salesforce/schema/User.Employee_Code__c";
import Employee_Id from "@salesforce/schema/User.Employee_Id__c";
import Name from "@salesforce/schema/User.Name";
import TVR_OBJECT from '@salesforce/schema/TVR__c';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


const fields = [Employee_Code, Name, Employee_Id];

import Id from '@salesforce/user/Id';

// <!-- Internal observation -->
// Custom Spinner settings
import { getSpinnerImage } from 'c/customSpinner';
// Custom Spinner settings
// <!-- Internal observation -->

export default class TvrLoanApplicationPage extends NavigationMixin(LightningElement)  {
    records;
    @api recordId;
    sortedColumn;
    sortedDirection = 'asc';
    initialRecords;
    userId = Id;
    todayDate;
    @track employeeCode;
    @track Name;
    @track mobileNumber;
    applicantMap;
    resetpage = false;
    tvrDoneWithOptions;
    fieldLabelTVRDoneWith;
    tvrDoneWith;
    isTwoWheeler=false;
    remarks;
    isLoaded=true;
    isAttributeRequired=true;
    trueValue = true;
    phoneNumber = '';
    @track isTVRdonewithSelected=false


    
    handleFieldChange(event) {
        // Get the input field element
        const inputField = event.target;
        // Set the type property to "number"
        inputField.type = "number";

    }
    
    @wire(getRecord, {
        recordId: "$userId",
        fields
    })
    wiredRecord({ error, data }) {
        if (data) {
            //console.log('value>>>' + JSON.stringify(data));
            this.employeeCode = data.fields.Employee_Id__c.value;
            this.Name = data.fields.Name.value;
        }
    }
    closeQuickAction() {
      //  const value = event.target.value;
        const cancelEvent = new CustomEvent("cancel", {});
        // Fire the custom event
        this.dispatchEvent(cancelEvent);
        }


    @wire(getObjectInfo, { objectApiName: TVR_OBJECT })
    oppInfo({ data, error }) {
        if (data)
            this.fieldLabelTVRDoneWith = data.fields.TVR_Done_With__c.label;
    }

    handleNameChange(evt){
        this.Name = evt.target.value;
    }

    handleEmpIdChange(evt){
        this.employeeCode = evt.target.value;
    }

    handlePhoneNumberChange(evt){
        this.mobileNumber = evt.target.value;
    }
    
    selectionChangeHandler(event) {
        //commenting as code was errorneous by Yash
        // var selectedOption = event.target.value;
        // // console.log('selectedOption>>>>>' +JSON.stringify(selectedOption));
        // //  console.log('label>>>>>' + JSON.stringify(event.target.selected));
        // for (const key in this.tvrDoneWithOptions) {
        //     if (Object.hasOwnProperty.call(this.tvrDoneWithOptions, key)) {
        //         console.log('selectedOption>>>>>' + JSON.stringify(this.tvrDoneWithOptions[key]));
        //         if (this.tvrDoneWithOptions[key].value == selectedOption) {
        //             this.tvrDoneWith = this.tvrDoneWithOptions[key].label;
        //         }

        //     }
        // }
        // this.mobileNumber = selectedOption;
        var selectedOption = event.target.value;

        if(selectedOption =='')
            this.isTVRdonewithSelected = false;

        this.tvrDoneWithOptions.forEach(data=>{
            if(data.value == selectedOption){
                this.tvrDoneWith = data.label;
                this.mobileNumber = data.mobile;
                this.remarks = data.remark
                this.isTVRdonewithSelected = true;
            }
        })




    }
    /*@wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }*/

    // <!-- Internal observation -->
     // Custom Spinner settings
     async spinnerImageMethod() {
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.recordId);
        }
    }
    // Custom Spinner settings
    // <!-- Internal observation -->

    async handleSubmit(event) {
        event.preventDefault();
        this.isLoaded = true;
        let fields = event.detail.fields;
        if(await this.checkRestriction()){
            if(!this.checkValidName() && !this.checkValidEMpId() && !this.checkMobileNumberValid()){
                fields['Name_Of_Employee__c'] = this.Name;
                fields['Employee_ID__c'] = this.employeeCode;
                fields['Mobile_Number__c'] = this.mobileNumber;
    
                console.log('submit>>'+JSON.stringify(event.detail.fields));
                this.template.querySelector('lightning-record-edit-form').submit(fields);
            }
        }
        this.isLoaded = false;
        
    }


    checkValidName(){
        let isErr = false;
        let checkField = this.template.querySelector('lightning-input[data-id="Name_Of_Employee__c"]');
        var regex = /^[a-zA-Z ]*$/;
        if (!regex.test(checkField.value)) {
            //alert(regex.test(checkField.value));
            //checkField.setCustomValidity("Please provide a valid check value");
            isErr = true;            
        } 
        else {
            //checkField.setCustomValidity("");
            isErr = false;
        }
        return isErr;

    }

    checkValidEMpId(){
        let isErr = false;
        let checkField = this.template.querySelector('lightning-input[data-id="Employee_ID__c"]');
        var regex = /^[0-9]*$/;
        if(checkField.value!=''){
            if (!regex.test(checkField.value)) {
                //alert(regex.test(checkField.value));
                checkField.setCustomValidity("Please provide a valid employee id");
                this.template.querySelector('c-common-toast').showToast('warning', '<strong>' + 'Please provide a valid employee id' + '<strong/>', 'utility:warning', 10000);
    
                isErr = true;            
            } 
            else {
                checkField.setCustomValidity("");
                isErr = false;
            }

        }
        else{
            checkField.setCustomValidity("Please provide a valid employee id");
            isErr = true; 

        }
        
        return isErr;
    }

    checkMobileNumberValid(){
        let isErr = false;
        let checkField = this.template.querySelector('lightning-input[data-id="Mobile_Number__c"]');
        const mobielNumber = checkField?.value ?? this.mobileNumber;
        var regex = /^[0-9]*$/;
        if (!regex.test(mobielNumber)) {
            //alert(regex.test(checkField.value));
            //checkField.setCustomValidity("Please provide a valid Phone Number");
            this.template.querySelector('c-common-toast').showToast('warning', '<strong>' + 'Please provide a valid phone number' + '<strong/>', 'utility:warning', 10000);
            isErr = true;            
        } 
        else if(mobielNumber.length<10){
            checkField.setCustomValidity("Your Entry is too short");
            this.template.querySelector('c-common-toast').showToast('warning', '<strong>' + 'Your Entry is too short' + '<strong/>', 'utility:warning', 10000);
            isErr = true;
        }
        else if(regex.test(mobielNumber) && mobielNumber.length==10) {
          //  checkField.setCustomValidity("");
            isErr = false;
        }
        return isErr;
    }

    handleDelete(event) {
        const evtId = event.currentTarget.dataset.id;
        restricAccess({
            compName: 'tvrLoanApplicationPage' ,loanId: this.recordId
            })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to delete Charges',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);
                }else{
                    this.isLoaded=true;
                    deleteTVR({ tvrId: evtId})
                        .then(result => {
                            if (result.isSuccess) {
                                this.template.querySelector('c-common-toast').showToast('success', '<strong>Successfully Deleted<strong/>', 'utility:success', 10000);
                                this.getTVR();
                            }
                            else {
                                this.template.querySelector('c-common-toast').showToast('warning', '<strong>' + result.message + '<strong/>', 'utility:warning', 10000);
                                this.isLoaded=false;
                            }
                        })
                        .catch(error => {
                            console.log('this.error>>>>>' + JSON.stringify(error));
                            this.template.querySelector('c-common-toast').showToast('Error', '<strong>' + error + '<strong/>', 'utility:Error', 10000);
                            this.isLoaded=false;
                        });
                    }
                })
                .catch(error => {
                    this.isLoaded=false;
                    console.log('error is ' + JSON.stringify(error));
                })
    }
    handleReset() {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }
    handleError(){
        this.isLoaded=false;

    }
    async  checkRestriction() {
        this.isLoaded = true;
        let data = await restricAccess({compName: 'tvrLoanApplicationPage' ,loanId: this.recordId});
        if(data){
            const evt = new ShowToastEvent({
                title: 'Access Restricted',
                message: 'You do not have access to save TVR Loan',
                variant: 'error',
                mode: 'dismissable' 
            });
            this.dispatchEvent(evt);
            return false;
        }
        else{
            return true;
        }
        // restricAccess({
        //     compName: 'tvrLoanApplicationPage' ,loanId: this.recordId
        //     })
        //     .then(data => {
        //         console.log('data is ' + JSON.stringify(data));
        //         if (data) {
        //             const evt = new ShowToastEvent({
        //                 title: 'Access Restricted',
        //                 message: 'You do not have access to save TVR Loan',
        //                 variant: 'error',
        //                 mode: 'dismissable' 
        //             });
        //             this.dispatchEvent(evt);
        //             this.isLoaded = false;
        //         }else{
        //         this.isLoaded=true;
        //         //c//c/addressInformationCompononsole.log('submit>>'+JSON.stringify(event.detail.fields));
        //         //console.log('submit>>'+this.tvrDoneWith);
        //         let fields = [];
        //         if((this.Name != undefined && this.Name != "" && this.Name != "undefined")
        //             && (this.todayDate != undefined && this.todayDate != "" && this.todayDate != "undefined")
        //             && (this.employeeCode != undefined && this.employeeCode != "" && this.employeeCode != "undefined")
        //             && (this.tvrDoneWith != undefined && this.tvrDoneWith != "" && this.tvrDoneWith != "undefined")
        //             && (this.mobileNumber != undefined && this.mobileNumber != "" && this.mobileNumber != "undefined")
        //             && (this.remarks != undefined && this.remarks != "" && this.remarks != "undefined")){
        //                 try{
        //                     fields['Name_Of_Employee__c'] = this.Name;
        //                     fields['Employee_ID__c'] = this.employeeCode;
        //                     fields['Mobile_Number__c'] = this.mobileNumber;
        //                     fields['Remark__c'] = this.remarks;
        //                     fields['TVR_Done_With__c'] = this.tvrDoneWith;
        //                     fields['Loan_Application__c'] = this.recordId;
        //                     fields['TVR_Date__c'] = this.recordId;
        //                     if(!this.checkValidName() && !this.checkValidEMpId() && !this.checkMobileNumberValid()){
        //                         this.template.querySelector('lightning-record-edit-form').submit(fields);
        //                         this.template.querySelector('c-common-toast').showToast('success', '<strong>Successfully Created<strong/>', 'utility:success', 10000);
        //                         this.handleReset();
        //                         this.getTVR();
        //                     }
        //                     else{
        //                         this.isLoaded=false;
        //                     }
        //                 }
        //                 catch(e){
        //                     this.template.querySelector('c-common-toast').showToast('error', 'Something went wrong! Please contact system administrator', 'utility:error', 10000);
        //                 }
                        
        //         }
        //         else{
        //             this.template.querySelector('c-common-toast').showToast('error', 'Please fill mandatory values', 'utility:error', 10000);
        //             this.isLoaded=false;
        //         }
        //     //  this.resetpage = true;
        //     }
        // })
        // .catch(error => {
        //     //alert('error '+)
        //     this.isLoaded=false;
        //     console.log('error is ' + JSON.stringify(error));
        // })
        
    }
    handleSuccess() {
        this.template.querySelector('c-common-toast').showToast('success', '<strong>Successfully Created<strong/>', 'utility:success', 10000);
        if (this.resetpage == true) {
            this.handleReset();
        }
        this.getTVR();
        
        // // <!-- Internal observation -->
        // setTimeout(() => {
        //     this.template.querySelector('c-common-toast').showToast('success', '<strong>Successfully Created<strong/>', 'utility:success', 10000);
        //     if (this.resetpage == true) {
        //         this.handleReset();
        //     }
        //     this.getTVR();
    
        // },1000)
        // // <!-- Internal observation -->
        
        
    }
    handleTVRForm(event) {
        /*  if (event.currentTarget.dataset.id == 'tvrDoneWith') {
              console.log('this.applicantMap>>>' + JSON.stringify(this.applicantMap));
              if (Object.hasOwnProperty.call(this.applicantMap, event.target.value)) {
                  this.mobileNumber = this.applicantMap[event.target.value].Mobile_Number__c;
              }
          }
          else if (event.currentTarget.dataset.id == 'TVRDate') {
              event.preventDefault();
              var tvrDate = event.target.value;
              if (tvrDate > this.todayDate) {
                  this.template.querySelector('lightning-input-field[data-id="TVRDate"]').reset();
                  console.log('this.joo>>>' + this.template.querySelector('lightning-input-field[data-id="TVRDate"]').value);
  
              }
          }*/
    }

    setTVROptions(data){
        let tvrOptionsList = [];
        data.forEach(rec=>{
            tvrOptionsList.push({
                label : rec.tvrOptionLabel,
                value : rec.tvrOptionValue+' '+rec.tvrOptionLabel,
                remark : (rec.isTwoWheeler)?rec.remarks:'',
                isTwoWheeler : rec.isTwoWheeler,
                mobile : rec.tvrOptionValue
            })
            
        })
        console.log('tvrOptions '+JSON.stringify(tvrOptionsList))
        this.tvrDoneWithOptions = tvrOptionsList;
    }


    async getTVR() {
        // <!-- Internal observation -->
        await this.spinnerImageMethod();
        // <!-- Internal observation -->
        fetchTVR({ loanApplicationId: this.recordId })
            .then(result => {
                if (result.isSuccess) {
                    
                    this.todayDate = result.todayDate;
                    // this.applicantMap = result.mapTypeVsAppl;
                    this.setTVROptions(result.tvrOptions);
                    //this.tvrDoneWithOptions = result.tvrDoneWithOptions;
                    //this.records = result.lstTvr;
                    let tempRecords = JSON.parse(JSON.stringify(result.lstTvr));
                    this.records = tempRecords.map(row => {
                        return { ...row, isDeleteable: row.CreatedById == this.userId ? true : false };
                    })
                    //console.log('this.records>>>>>' + JSON.stringify(this.records));

                }
                else{
                    //console.log('message>>>>>' +result.message);

                }
                this.isLoaded=false;
            })
            .catch(error => {
                //console.log('this.error>>>>>' + JSON.stringify(error));
                this.template.querySelector('c-common-toast').showToast('Error', '<strong>' + error + '<strong/>', 'utility:Error', 10000);
                this.isLoaded=false;
            });
    }
    connectedCallback() {
        this.getTVR();
    }



}