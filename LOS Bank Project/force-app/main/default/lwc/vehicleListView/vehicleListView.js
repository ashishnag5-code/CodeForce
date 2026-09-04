import { LightningElement, api,wire,track} from 'lwc';
    import { NavigationMixin } from 'lightning/navigation';
    import getStateValues from '@salesforce/apex/AddressComponentHandler.getLocations';
    import { ShowToastEvent } from 'lightning/platformShowToastEvent';
    import getApplicantAddress from '@salesforce/apex/AddressComponentHandler.getApplicantAddress';
    import getAddressInfo from '@salesforce/apex/AddressComponentHandler.getAddressInfo';
    import getProductMetadataValues from '@salesforce/apex/AddressComponentHandler.getProductMetadataValues';
    import NAME_FIELD from '@salesforce/schema/Address__c.Address_Line_1__c';
    import ADDRESS_FIELD from '@salesforce/schema/Address__c.Address_Line_2__c';
    import STATE_FIELD from '@salesforce/schema/Address__c.State__c';
    import CITY_FIELD from '@salesforce/schema/Address__c.City__c';
    import ADDRESSTYPE_FIELD from '@salesforce/schema/Address__c.Address_Type__c';
    import ADDRESS_OBJECT from '@salesforce/schema/Address__c';
    import { createRecord } from 'lightning/uiRecordApi';
    
    
    export default class VehicleListView extends NavigationMixin(LightningElement) {
        editAdress = false;
        addinformation = false;
        stateValue = '';
        cityValue = '';
        talukaValue = '';
        areaValue = '';
        addressLine1Value='';
        addressLine2Value='';
        addressLine3Value='';
        addressTypeValue ='';
        PincodeValue='';
        LandMarkValue='';
        @api recordId ='a026s000001272WAAQ';
        @api applicantId;
        @api loanApplication;
    
        stateOptions=[];
        cityOptions =[];
        talukaOptions = [];
        areaOptions = [];
        areaTypeOptions =[];
        stabilityOptions =[];
        residenceStatusOptions =[];
        residenceTypeOptions=[];
        addressTakenFromOptions=[];
        fields = [NAME_FIELD, ADDRESS_FIELD,STATE_FIELD,CITY_FIELD,ADDRESSTYPE_FIELD];
        recordformId ='';
        showrecordform = false;
        addressLst=[];
        editRecordId;
        showAddressInsertion = true;
        addressTypes;
        recordCount;
        @track addressList;
        addressApplicationRecord = {};
        showMainSection = true;
        areNameValue;
        areaTypeValue;
        selectedAddresstype;
        selectedProduct;
        viewMorePartial = false
        residenceStatusTypeValue='';
        stabilityValue='';
        addressTakenFromValue='';
        residenceStatusValue='';
        isLoaded= false;
        showOfficeLabels=false;
        sameAsOptions=[];
        counter=0;
        sameasValue='';
        showSameAsDropDown=true;
        OfficeNoValue='';
        
    
        selectedRecords= {};
    
    
        connectedCallback() {
            console.log('insideAddressComponent--->');
            this.getApplicants();
        }
    
        @api
        getApplicants() {
            console.log('this.applicantId.Id-->' +JSON.stringify(this.applicantId));
          
            if (this.applicantId.Id != undefined && this.applicantId.Id!=null) {
                getApplicantAddress({
                        recId: 'a026s000001272WAAQ'//this.applicantId.Id
                    })
                    .then(data => {
                        this.addressLst = data.applicantAddressList;
                        this.showAddressInsertion = data.boolIsAddressInsertionAllowed;
                        this.addressTypes = data.strAddressTypes;
                        this.recordCount = data.recCount;
                        this.selectedProduct =data.applicantAddressList[0].Product__c;
    
                        console.log('addressData-->' + JSON.stringify(data));
                        console.log('bool-->' +  this.selectedProduct);
                        let options = [];
                        let existingAddress = data.strAddressTypes;
                       
                        let allAddress = ['Permanent','Current', 'Office','Touch Point'];
                        for (var key in allAddress) {
                            console.log('dataVal[key]' + allAddress[key]);
                            if (!existingAddress.includes(allAddress[key])) {
                                options.push({
                                    label: allAddress[key],
                                    value: allAddress[key]
                                });
                            }
                        }
                        this.addressList = options;
                    })
                    .catch(error => {
                        console.log('error is ' + JSON.stringify(error));
                      
                        //this.accounts = undefined;
                    })
            }else{
                let options=[];
                options.push({ label: 'Permanent', value: 'Permanent' });
                options.push({ label: 'Current', value: 'Current' });
                options.push({ label: 'Office', value: 'Office' });
                options.push({ label: 'Touch Point', value: 'Touch Point' });
                this.addressList = options;
            }
    
    
        }
    
        getInitialValues(){
            getApplicantAddress({
                recId: this.applicantId.Id
            })
            .then(data => {
                this.addressLst = data.applicantAddressList;
                this.showAddressInsertion = data.boolIsAddressInsertionAllowed;
                this.addressTypes = data.strAddressTypes;
                this.recordCount = data.recCount;
                this.selectedProduct =data.applicantAddressList[0].Product__c;
                //this.selectedAddresstype = data.applicantAddressList[0].Address_Type__c;
    
                console.log('addressData-->' + JSON.stringify(data));
                console.log('bool-->' +  this.selectedProduct);
                let options = [];
                let existingAddress = data.strAddressTypes;
               
                let allAddress = ['Permanent','Current', 'Office','Touch Point'];
                for (var key in allAddress) {
                    console.log('dataVal[key]' + allAddress[key]);
                    if (!existingAddress.includes(allAddress[key])) {
                        options.push({
                            label: allAddress[key],
                            value: allAddress[key]
                        });
                    }
                }
                this.addressList = options;
            })
            .catch(error => {
                console.log('error is ' + JSON.stringify(error));
              
                //this.accounts = undefined;
            })
        }
        
    
        viewMoreHandler(event) {
            if(event!=undefined && event.currentTarget.dataset !=undefined ){
                if (event.currentTarget.dataset.recordName == 'ViewMoreInformation') {
                    var recordId = event.currentTarget.dataset.id;
                    this.viewMorePartial = true;
                    console.log('recordId-->' + recordId);
        
                    let records = this.addressLst;
                    let addressrecords = [];
        
                    for (let i = 0; i < this.addressLst.length; i++) {
                        if (this.addressLst[i].Id == recordId) {
                            addressrecords.push(records[i]);
                        }
                    }
                    console.log('addressrecords-->' + JSON.stringify(addressrecords));
                    this.selectedRecords = addressrecords;
                }
            }
        }
    
        viewLessHandler(event){
            this.viewMorePartial = false;
        }
        handleRecordForm(event) {
            console.log('onsubmit event');
            event.preventDefault(); // stop the form from submitting
            const fields = event.detail.fields;
            console.log('onsubmit event recordEditForm'+ JSON.stringify(event.detail.fields.Address_Type__c));
            let addressValues = event.detail.fields.Address_Type__c;
            if(!this.addressTypes.includes(addressValues)){
                fields.Applicant__c = this.applicantId.Id; // modify a field
                this.template.querySelector('lightning-record-form').submit(fields);
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Address Duplicate',
                        message: 'You cannot insert the ' + addressValues +' Address',
                        variant: 'error'
                    }),
                );
            }
    
            //fields.Applicant__c = 'a006s0000015TaEAAU'; // modify a field
           // this.template.querySelector('lightning-record-form').submit(fields);
        }
        handlerecordformSuccess(event){
            console.info("END handleSuccess < ", event.detail.id, " >");
            this.recordformId = event.detail.id;
            this.addinformation = false;
           
          //  this.showrecordform = true;
          }
         handleCancelForm(event){
            this.addinformation= false;
            this.handleReset();
          }
    
         handleReset(){
            this.addressLine1Value = '';
            this.addressLine2Value = '';
            this.addressLine3Value = '';
            this.stateValue =  '';
            this.cityValue =  '';
            this.areNameValue =  '';
            this.talukaValue =  '';
            this.areaTypeValue =  '';
            this.residenceStatusValue =  '';
            this.residenceStatusTypeValue =  '';
            this.stabilityValue = '';
            this.addressTakenFromValue = '';
            this.PincodeValue = '';
            this.LandMarkValue = '';
            
         }
    
         handlePicklistChange(event) {
            var locationMetrics = event.currentTarget.dataset.name;
          //  this.addressApplicationRecord[event.target.dataset.name] = event.target.value;
    
            if(locationMetrics == 'State'){
                this.stateValue = event.target.value;
            }
            if(locationMetrics == 'City'){
                this.cityValue = event.target.value;
            }
            if(locationMetrics == 'Taluka'){
                this.talukaValue = event.target.value;
            }
            if(locationMetrics == 'Areaname'){
                this.areNameValue = event.target.value;
            }
            if(locationMetrics == 'AreaType'){
                this.areaTypeValue = event.target.value;
            }
            if(locationMetrics == 'Status'){
                this.residenceStatusValue = event.target.value;
            }
            if(locationMetrics == 'Type'){
                this.residenceStatusTypeValue = event.target.value;
            }
            if(locationMetrics == 'Stability'){
                this.stabilityValue = event.target.value;
            }
            if(locationMetrics == 'AddressTakenFrom'){
                this.addressTakenFromValue = event.target.value;
            }
           
            console.log('this.residenceStatusTypeValue-->' +this.residenceStatusTypeValue);
            console.log('this.addressTakenFromValue-->' +this.addressTakenFromValue);
        }
    
        handlePinCodeChange(event){
            let pinCodeVal = event.target.value;
            this.PincodeValue = pinCodeVal;
            console.log('pincodeVal-->' +event.target.value);
           // this.addressApplicationRecord[event.target.name] = event.target.value;
           this.getPicklistOptions(pinCodeVal);
        }
    
    
        getPicklistOptions(pincodes){
            this.isLoaded = true;
            getStateValues({ pinCode:pincodes })
            .then(data => {
                if (data) {
                 
                    console.log('PicklistValues-->' +JSON.stringify(data));
                    this.stateOptions = data['State'];
                    this.cityOptions = data['City'];
                    this.talukaOptions = data['Taluka'];
                    this.areaOptions = data['Areaname'];
                    this.areaTypeOptions = data['AreaType'];
                    this.stabilityOptions = data['Stability'];
    
                    // if there is only one option default the value
                    if(this.stateOptions.length == 1){
                        this.stateValue =data['State'][0].value;
                    }
                    if(this.cityOptions.length == 1){
                        this.cityValue =  data['City'][0].value;
                    }
                    if(this.talukaOptions.length == 1){
                        this.talukaValue =data['Taluka'][0].value;
                    }
                    if(this.areaOptions.length == 1){
                        this.areNameValue = data['Areaname'][0].value;
                    }
                    if(this.areaTypeOptions.length == 1){
                        this.areaTypeValue = data['AreaType'][0].value;
                    }
                    
                   console.log('stateoptionlenght-->' + data['State'][0].value);
                   this.isLoaded = false;
                }
            })
            .catch(error => {
                console.log('error is '+JSON.stringify(error));
                this.isLoaded = false;
            })
        }
    
        handleSubmit(event) {
            event.preventDefault();
            
            const fields = event.detail.fields;
            
            fields.State__c = this.stateValue;
            fields.City__c = this.cityValue;
            fields.Taluka__c = this.talukaValue;
            fields.Area_Name__c = this.areNameValue;
            fields.Status__c = this.residenceStatusValue;
            fields.Type__c = this.residenceStatusTypeValue;
            fields.Stability__c = this.stabilityValue;
            fields.Address_Source__c = this.addressTakenFromValue;
            fields.Address_Type__c = this.addressTypeValue;
            fields.Address_Line_1__c = this.addressLine1Value;
            fields.Address_Line_2__c = this.addressLine2Value;
            fields.Address_Line_3__c = this.addressLine3Value;
            fields.Area_Type__c = this.areaTypeValue;
            fields.Land_mark__c = this.LandMarkValue;
            if(this.isInputValid()){
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            }
            console.log('onsubmit event recordEditForm'+ JSON.stringify(event.detail.fields));
        }
        handleSuccess(event) {
            this.isLoaded = true;
            console.log('onsuccess event recordEditForm', event.detail.id);
            this.showMessage('Record Updated Successfully','success');
            this.editAdress = false;
            this.showMainSection = true;
            this.addinformation = false;
            this.handleReset();
            this.getApplicants();
            this.isLoaded = false;
        }
        handleAdditionalInformationClick(event) {
        /*    this.counter =  this.counter +1;
            console.log(' this.counter-->' + this.counter);
    
            let options = [];
            let existingAddress = [];
            let existingOptions = this.addressList;
            
    
            if (this.counter != 1) {
                this.addressList=[];
                for (var key in existingOptions) {
                    let existingval = existingOptions[key].value;
                    if (!existingval.includes(this.addressTypeValue)) {
                        //existingAddress.push( existingOptions[key].value);
                        existingAddress.push({
                            label: existingOptions[key].label,
                            value: existingOptions[key].value
                        });
                    }
                }
              
                    this.addressList = existingAddress;
            
                console.log('insideaddinform');
            }*/
            this.handleReset();
            this.addinformation = true;
            this.addressApplicationRecord.Applicant__c =  this.applicantId.Id; 
            this.getInitialValues();
          console.log('this.addressList--' +JSON.stringify( this.addressList));
       }
        cancelMethod(event){
             this.editAdress = false;
        }
        editMethod(event){
            this.editAdress = true;
            console.log('editttt'+this.editAdress);
        }
        showMessage(message,variant){
            const event = new ShowToastEvent({
                title: '',
                variant: variant,
                mode: 'dismissable',
                message: message
            });
            this.dispatchEvent(event);
        }
    
        handleRowAction(event) {
           this.isLoaded = true;
            const recordId = event.currentTarget.dataset.id;
            this.selectedProduct = event.currentTarget.alternativeText;
             /* this.stateValue = event.currentTarget.alternativeText;
            this.talukaValue =event.currentTarget.title;
            this.areaValue= event.currentTarget.dataset.actionName;*/
    
            const pincode = event.currentTarget.dataset.recordName
           
             this.showMainSection = false;
            this.editRecordId = recordId;
            
          
            
            //get the picklist values from the current address record pincode
            //this.getPicklistOptions(pincode);
             getAddressInfo({
                     recId: recordId
                 })
                 .then(data => {
                     if (data) {
    
                         console.log('addressinfodata__' + JSON.stringify(data));
                         this.stateValue = data[0].State__c;
                         this.cityValue = data[0].City__c;
                         this.talukaValue = data[0].Taluka__c;
                         this.areNameValue = data[0].Area_Name__c;
                         this.residenceStatusValue = data[0].Status__c;
                         this.residenceStatusTypeValue = data[0].Type__c;
                         this.stabilityValue = data[0].Stability__c;
                         this.addressTakenFromValue = data[0].Address_Source__c;
                         this.addressTypeValue = data[0].Address_Type__c;
                         this.addressLine1Value=data[0].Address_Line_1__c;
                         this.addressLine2Value=data[0].Address_Line_2__c;
                         this.addressLine3Value=data[0].Address_Line_3__c;
                         this.pinCodeVal = data[0].Pincode__c;
                        this.LandMarkValue = data[0].Land_mark__c;
    
                       
                      let existingOptions = this.addressList;
                        let existingValues=[];
                        for (var key in existingOptions) {
                            existingValues.push( existingOptions[key].value);
                          }
      
                        if (!existingValues.includes(this.addressTypeValue)) {
                        this.addressList.push({
                            label: this.addressTypeValue,
                            value: this.addressTypeValue
                        });
                       
                        }
                        this.editAdress = true;
                        
                       /* if( this.addressTypeValue!=null){
                            this.handleSameAsLogic();
                        }*/
                        this.isLoaded = false;
                        this.getPicklistOptions(pincode);
                        this.handleAddressDependenceValues();
    
                         console.log('existingOptions-->' + JSON.stringify(existingOptions));
                        console.log(' this.addressList-->' +JSON.stringify( this.addressList));
                     }
    
                 })
                 .catch(error => {
                     console.log('result is ' + error)
                     this.error = error;
                     //this.accounts = undefined;
                 })
    
      }
    
      isInputValid() {
            let isValid = true;
            let inputFields = this.template.querySelectorAll(".validate");
            inputFields.forEach(inputField => {
                if (!inputField.value) {
                    inputField.setCustomValidity("Complete this field");
                    inputField.reportValidity();
                    isValid = false;
                }
            });
            return isValid;
        }
    
        handleRecordUpdateCancel(){
            this.editAdress = false;
            this.showMainSection = true;
        }
    
    
        handleAddressType(event){
         
            console.log('insideaddreesschange');
            let name = event.target.name;
           if(name == 'Address_Line_1__c'){
                this.addressLine1Value =  event.target.value;
            }
            if(name =='Address_Line_2__c'){
                this.addressLine2Value =  event.target.value;
            }
            if(name =='Address_Line_3__c'){
                this.addressLine3Value =  event.target.value;
            }
            if(name == 'Office_Number__c'){
                this.OfficeNoValue = event.target.value;
            }
          /*  if(name =='Address_Type__c'){
                this.addressTypeValue =  event.target.value;
            }
            if(name =='Land_mark__c'){
                this.LandMarkValue =  event.target.value;
            }*/
           
    
            this.addressApplicationRecord[event.target.name] = event.target.value;
            this.selectedAddresstype = event.target.value;
            let residenceOptions=[];
            let residenceTypeOptions=[];
            let addressTakenOptions =[];
            let options =[];
            let typeOptions =[];
            let addresstkFromOptions=[];
            console.log('selectedProduct-->' +this.selectedProduct);
            console.log('selectedAddress-->' +this.selectedAddresstype);
           if( event.target.name =='Address_Type__c'){
          
             this.handleSameAsLogic();
          
            this.showOfficeLabels =((this.selectedAddresstype =='Office')? true:false);
           
        
            this.addressTypeValue =  event.target.value;
            this.isLoaded= true;
                getProductMetadataValues({ AddressType:this.selectedAddresstype,Product:this.selectedProduct})
                .then(data => {
                    console.log('addressTypeDat-->' +JSON.stringify(data));
    
                   
                    residenceOptions = data['ResidenceStatus'];
                    residenceTypeOptions= data['ResidenceType'];
                    addressTakenOptions = data['AddressTakenFrom'];
    
                    for (var key in residenceOptions) {
                        options.push({ label: residenceOptions[key], value: residenceOptions[key] });
                    }
                    for (var key in residenceTypeOptions) {
                        typeOptions.push({ label: residenceTypeOptions[key], value: residenceTypeOptions[key] });
                    }
                    for (var key in addressTakenOptions) {
                        addresstkFromOptions.push({ label: addressTakenOptions[key], value: addressTakenOptions[key] });
                    }
                    
                    this.residenceStatusOptions = options;
                    this.residenceTypeOptions = typeOptions;
                    this.addressTakenFromOptions = addresstkFromOptions;
                    this.isLoaded= false;
                    
                })
                .catch(error => {
                    console.log('error is '+JSON.stringify(error));
                    this.error = error;
                    //this.accounts = undefined;
                })
    
            }
            console.log('addressApplicationRecord-->' +JSON.stringify(this.addressApplicationRecord));
        }
    
        handleAddressDependenceValues(){
            getProductMetadataValues({ AddressType:'Permanent',Product:this.selectedProduct})
            .then(data => {
                console.log('addressTypeDat-->' +JSON.stringify(data));
    
                let residenceOptions=[];
            let residenceTypeOptions=[];
            let addressTakenOptions =[];
            let options =[];
            let typeOptions =[];
            let addresstkFromOptions=[];
                residenceOptions = data['ResidenceStatus'];
                residenceTypeOptions= data['ResidenceType'];
                addressTakenOptions = data['AddressTakenFrom'];
    
                for (var key in residenceOptions) {
                    options.push({ label: residenceOptions[key], value: residenceOptions[key] });
                }
                for (var key in residenceTypeOptions) {
                    typeOptions.push({ label: residenceTypeOptions[key], value: residenceTypeOptions[key] });
                }
                for (var key in addressTakenOptions) {
                    addresstkFromOptions.push({ label: addressTakenOptions[key], value: addressTakenOptions[key] });
                }
                
                this.residenceStatusOptions = options;
                this.residenceTypeOptions = typeOptions;
                this.addressTakenFromOptions = addresstkFromOptions;
                this.isLoaded= false;
                
            })
            .catch(error => {
                console.log('error in productvalues '+JSON.stringify(error));
                this.error = error;
                //this.accounts = undefined;
            })
    
        }
    
        handleSameAsLogic(){
            let sameasOptions=[];
          if(this.selectedAddresstype =='Permanent'){
            sameasOptions.push({ label: 'New', value: 'New' });
          }else if(this.selectedAddresstype =='Current'){
            sameasOptions.push({ label: 'New', value: 'New' });
            sameasOptions.push({ label: 'Permanent', value: 'Permanent' });
          }else if(this.selectedAddresstype =='Office'){
            sameasOptions.push({ label: 'New', value: 'New' });
            sameasOptions.push({ label: 'Permanent', value: 'Permanent' });
            sameasOptions.push({ label: 'Current', value: 'Current' });
          }else if(this.selectedAddresstype =='Touch Point'){
            this.showSameAsDropDown = false;
          }
          this.sameAsOptions=sameasOptions;
        }
    
        handleCopyInfo(event){
           /* let boxes = this.template.querySelectorAll('.chckBox');
            console.log('boxes-->' +boxes);
            let currentBox = event.target.name;
            console.log(currentBox);
          //  console.log(Array.from(boxes));
           // const boxArray = Array.from(boxes);
           console.log(boxArray)
            for (let i = 0; i < boxes.length; i++) {
                let box = boxes[i];
                console.log(box.name);
                console.log(box.checked);
                if (box.name !== currentBox && box.checked){
                    box.checked =false;
                    console.log(box.checked);
                }
            }*/
    
    
    
    
                let selectionOption = event.target.value;
                if(selectionOption!='New'){
                    this.handleReset();
                }
              
             //   if(selectionOption =='Permanent'){
                    let existingValues =this.addressLst;
                    for (var key in existingValues) {
                        if(existingValues[key].Address_Type__c == selectionOption){
                            this.addressLine1Value = existingValues[key].Address_Line_1__c;
                            this.addressLine2Value = existingValues[key].Address_Line_2__c;
                            this.addressLine3Value = existingValues[key].Address_Line_3__c;
                            this.stateValue =  existingValues[key].State__c;
                            this.cityValue =  existingValues[key].City__c;
                            this.areNameValue =  existingValues[key].Area_Name__c;
                            this.talukaValue =  existingValues[key].Taluka__c;
                            this.areaTypeValue =  existingValues[key].Area_Type__c;
                            this.residenceStatusValue =  existingValues[key].Status__c;
                            this.residenceStatusTypeValue =  existingValues[key].Type__c;
                            this.stabilityValue = existingValues[key].Stability__c;
                            this.addressTakenFromValue = existingValues[key].Address_Source__c;
                            this.PincodeValue = existingValues[key].Pincode__c;
                            this.pinCodeVal = existingValues[key].Pincode__c;
                            this.LandMarkValue = existingValues[key].Land_mark__c;
                         }
                    }
                    this.getPicklistOptions(this.PincodeValue);
    
            //    }
                console.log('insidecopy-->' + this.addressLine1Value );
    
        }
      
        handleSubmitForm(){
           console.log('insubmitform-->'+this.addressLine1Value);
          //  if(this.addressApplicationRecord.City__c ==''){
                 this.addressApplicationRecord.Address_Line_1__c =this.addressLine1Value;
                  this.addressApplicationRecord.Address_Line_2__c =this.addressLine2Value;
                  this.addressApplicationRecord.Address_Line_3__c =this.addressLine3Value;
                this.addressApplicationRecord.City__c =this.cityValue;
                this.addressApplicationRecord.Area_Type__c =this.areaTypeValue;
                this.addressApplicationRecord.State__c =this.stateValue;
                this.addressApplicationRecord.Taluka__c = this.talukaValue; 
                this.addressApplicationRecord.Area_Name__c =this.areNameValue;
                this.addressApplicationRecord.Status__c = this.residenceStatusValue;
                this.addressApplicationRecord.Type__c = this.residenceStatusTypeValue;
                this.addressApplicationRecord.Stability__c = this.stabilityValue;
                //this.addressApplicationRecord.Land_mark__c= this.LandMarkValue;
                this.addressApplicationRecord.Pincode__c=this.PincodeValue;
                this.addressApplicationRecord.Address_Source__c =this.addressTakenFromValue;
                this.addressApplicationRecord.Office_Number__c =this.OfficeNoValue;
        //    }
            const fields = this.addressApplicationRecord;
            console.log('FinaladdressApplicationRecord-->' +JSON.stringify(this.addressApplicationRecord));
            const recordInput = { apiName: ADDRESS_OBJECT.objectApiName, fields };
    
            
            if(this.isInputValid()){
                createRecord(recordInput)
                .then(address => {
                    console.log('success-->' +JSON.stringify(address));
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Address created',
                            variant: 'success',
                        }),
                    );
                    this.editAdress = false;
                    this.addinformation = false;
                    this.showMainSection = true;
                    
                    console.log('success1-->' +JSON.stringify(this.applicantId));
                    this.getApplicants();
                 
                    
                   
                })
                .catch(error => {
        
                 
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error creating record',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    );
                });
            }
    
       }
    
    
        @api
        nextHandler() {
            console.log('insideaddressinnexthandler');
            let recordPermanentFound = this.addressLst.find((item) => item.Address_Type__c === 'Permanent');
            let recordCurrentFound = this.addressLst.find((item) => item.Address_Type__c === 'Current');
    
            console.log('recordPermanentFound-->' + JSON.stringify(recordPermanentFound));
            console.log('recordCurrentFound-->' + JSON.stringify(recordCurrentFound));
            console.log('next-->' + JSON.stringify(this.loanApplication));
            if ((recordPermanentFound != undefined) && (recordCurrentFound != undefined)) {
                if (recordPermanentFound.Address_Type__c == 'Permanent' && recordCurrentFound.Address_Type__c == 'Current') {
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.loanApplication.Id,
                            objectApiName: 'Loan_Application__c',
                            actionName: 'view'
                        },
                    });
                }
            } else {
               let message = (recordPermanentFound!=undefined)?'Current Address Type':'Permanent Address Type';
                this.showMessage('Please add '+message+' to Proceed Further', 'error');
                let returnObj = {
                    'next': false,
                    'errorOnChild' :'Please add Permanent and Current Addresses to Proceed Further',
                }
    
                this.dispatchEvent(new CustomEvent('next', {
                    detail: returnObj
                }));
             }
    
        }
    }