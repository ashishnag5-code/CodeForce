import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import QuestionnaireScreenName from '@salesforce/label/c.Questionnaire_Screen_Name';
import { loadStyle } from 'lightning/platformResourceLoader';
import opsAccordion from '@salesforce/resourceUrl/opsAccordion';
//import getPrintQuestionaire from '@salesforce/apex/FieldInvestigationQuestionaireController.getPrintQuestionaire';
import FORM_FACTOR from '@salesforce/client/formFactor';
import ProfileName from '@salesforce/schema/User.Profile.Name'; //this scoped module imports the current user profile name

import Applicant_Type from "@salesforce/schema/Field_Investigation__c.Applicant_Type__c";
import createDeviation from '@salesforce/apex/Utility.createDeviation';
import Proposed_vehicle from "@salesforce/schema/Field_Investigation__c.Proposed_vehicle__c";
import Type_of_address from "@salesforce/schema/Field_Investigation__c.Type_of_address__c";
import Customer_Type from "@salesforce/schema/Field_Investigation__c.Customer_Type__c";
import Opening_Remarks from "@salesforce/schema/Field_Investigation__c.Opening_Remarks__c";
import Fill_Questionaire from "@salesforce/schema/Field_Investigation__c.Fill_Questionaire__c";
import Full_Allocated_Address from "@salesforce/schema/Field_Investigation__c.Full_Allocated_Address__c";
import Distance from "@salesforce/schema/Field_Investigation__c.Distance__c";   
import Stage from "@salesforce/schema/Field_Investigation__c.Stage__c";
import FI_Status from "@salesforce/schema/Field_Investigation__c.FI_Status__c";
import FI_Profile_Status from "@salesforce/schema/Field_Investigation__c.FI_Profile_Status__c";
import FI_Conducted_Date_Time from "@salesforce/schema/Field_Investigation__c.FI_Conducted_Date_Time__c";
import FI_Submission_Date_Time from "@salesforce/schema/Field_Investigation__c.FI_Submission_Date_Time__c";
import Application_Product_Type from "@salesforce/schema/Field_Investigation__c.Loan_Application_Product_Type__c";
import FI_AGENT from "@salesforce/schema/Field_Investigation__c.FI_Agent__c";
import Name from '@salesforce/schema/User.Name';
import Employee_Code from '@salesforce/schema/User.Employee_Code__c';
import Applicant from "@salesforce/schema/Field_Investigation__c.Applicant__c";
import fiphotodocmaster from '@salesforce/label/c.FI_Photo_Doc_Master_Number';
import fiPrintButton from '@salesforce/label/c.Field_Investigation_Print_Button';
import FI_Questionnaire_Required_Message from '@salesforce/label/c.FI_Questionnaire_Required_Message';
import getLatLongAddressDistance from '@salesforce/apex/MapMyIndiaDistanceController.getLatLongAddressDistance';
import updateFieldInvestigationRecord from '@salesforce/apex/CreateFieldInvestigatiionRecord.updateFieldInvestigationRecord';
import getUserAssignedPermissions from '@salesforce/apex/CreateFieldInvestigatiionRecord.getUserAssignedPermissions';
import getProfileAddressNegativePicklistValues from '@salesforce/apex/CreateFieldInvestigatiionRecord.getProfileAddressNegativePicklistValues';
import tractorQuestionnaireCheck from '@salesforce/apex/CreateFieldInvestigatiionRecord.tractorQuestionnaireCheck';
import FI_Owner from "@salesforce/schema/Field_Investigation__c.OwnerId";
import FI_CurrentLocation from "@salesforce/schema/Field_Investigation__c.Punch_the_Location_for_Geo_tag__c";
/*
import hasRetriggerPermission from '@salesforce/customPermission/ReTrigger_FI_Record';
import hasReassignPermission from '@salesforce/customPermission/ReAssign_FI_Record';*/


import Id from '@salesforce/user/Id';

import Credit_Manager from "@salesforce/schema/Field_Investigation__c.Credit_Manager__c";
import Send_Back_Counter from "@salesforce/schema/Field_Investigation__c.Send_Back_Counter__c";
import Loan_Application_Stage from "@salesforce/schema/Field_Investigation__c.Loan_Application__r.Stage__c";
import ContactMobile from '@salesforce/schema/Case.ContactMobile';

const fields = [Applicant,Applicant_Type, Proposed_vehicle, Type_of_address, Customer_Type, Opening_Remarks,Fill_Questionaire,Full_Allocated_Address,Distance, 
    Credit_Manager,FI_Status,Stage, FI_Profile_Status, FI_AGENT, FI_Conducted_Date_Time,FI_Submission_Date_Time,Send_Back_Counter,Application_Product_Type, FI_Owner,
    FI_CurrentLocation, Loan_Application_Stage
];

export default class RecordEditFormCreateExampleLWC extends NavigationMixin(LightningElement) {
    
    label = {
        fiphotodocmaster,
        fiPrintButton,
        FI_Questionnaire_Required_Message
    };
    @api recordId;
    @api objectApiName;
    @track isRemarksMandatory = false;
    @track isAddressMandatory = false;
    @track showQuestionnaireLink = false;
    @track IsQuestionnaireComponentActive = false;
    @track IsFiComponentActive = true;
    @track isNegativeReasonMandatory = false;
    @track isNegativeReasonDisable = true;
    @track isNegativeReasonValue;
    @track applicantType;
    @track proposedVehicle;
    @track typeOfAddress;
    @track QuestionnaireLinkName = QuestionnaireScreenName;
    @track currentLocation = '';
    @track checkCustomerTypeForIndividual;
    @track stageValue;
    @track openingRemarks;
    @track CheckIfrendered =false;
    @track fillQuestionaire;
    @track ownerIdCM;
    @track imagesList=[];
    @track isMobile = FORM_FACTOR=='Small'?true:false;
    @track fullallocatedaddress;
    @track error = false;
    @track errorMsg = '';
    @track fiprofilestatus = '';
    @track blnSavedSuccess = false;
    @track fiagentId = '';
    @track fullname = '';
    @track empcode = '';
    @track userwithempcode = '';
    @track ficunducteddatetime = '';
    @track fisummitiondatetime = '';
    @track blnhasEditPermission = false;
    @track isRetriggerPermissionGranted = false;
    @track isReassignPermissionGranted = false;
    @track isEditPermissionGranted= false;
    @track isPermissionSetCompleted = false;
    @track isUploadPermissionGranted = false;
    isTractor = false;
    trueValue =true;
    falseValue =false;
    applicantId;
    isImagesVisible=true;
    isUploadImages=true;
    showUploadPhotoOption=true;
    isLoaded=true;
    @track isFormEdit=false;
    //showWaiveOffReason=false;
    //showOtherWaiveOffReason=false;
    isFiProfile=false;
    disableOtherWaiveOffReason=false;
    disableWaiveOffReason=false;
    reqWaiveOffOtherReason=false;
    currentFIstatus = '';
    currentStage = '';
    @track renderSendBackComments = false;
    @track isTwoWheelerFI = false;
    @track openingMarksRequired = true;
    @track waiveOffMandatory = false;
    @track vehicleType = '';
    @track loggedInUserId = Id;
    @track fiRecordOwner = '';
    @track applicationStage = '';

    loadStyles() {
        loadStyle(this, opsAccordion);
    }

    // NOTE : Renderedcallback() only works for child components to parent DOM
    renderedCallback(){
        console.log('inside renderCallback');
        this.loadStyles();
    }
    
    @wire(getRecord, { recordId: Id, fields: [ProfileName, Name, Employee_Code] })
    userDetails({data }) {
        if (data) {
            if (data.fields.Profile.value != null) {
                data.fields.Profile.value.fields.Name.value ==  "Field Investigator"? this.isFiProfile=true:this.isFiProfile=false;
                this.fullname = data.fields.Name.value;
                this.empcode = data.fields.Employee_Code__c.value;       
            }
        }
    }
    

    @wire(getRecord, {
        recordId: "$recordId",
        fields
    })
    //   fieldInvestigation;
    wiredRecord({ error, data }) {

        if (data) {
            console.log('Data>>>'+JSON.stringify(data));
            this.applicantType = data.fields.Applicant_Type__c.value;
            this.proposedVehicle = data.fields.Proposed_vehicle__c.value;
            this.typeOfAddress = data.fields.Type_of_address__c.value;
            this.openingRemarks = data.fields.Opening_Remarks__c.value;
            this.fillQuestionaire =data.fields.Fill_Questionaire__c.value; 
            this.applicantId=data.fields.Applicant__c.value; 
            this.fullallocatedaddress=data.fields.Full_Allocated_Address__c.value;
            this.Distance = data.fields.Distance__c.value;
            this.ownerIdCM = data.fields.Credit_Manager__c.value;
            this.currentFIstatus = data.fields.FI_Status__c.value;
            this.currentStage = data.fields.Stage__c.value;
            this.fiprofilestatus = data.fields.FI_Profile_Status__c.value;
            this.fiagentId = data.fields.FI_Agent__c.value;
            this.ficunducteddatetime = data.fields.FI_Conducted_Date_Time__c.value;
            this.fisummitiondatetime = data.fields.FI_Submission_Date_Time__c.value;
            this.fiRecordOwner = data.fields.OwnerId.value;
           // this.ownerIdCM =data.fields.Loan_Application__r.value.fields.Credit_Manger__c.value; 
           if(this.currentFIstatus == 'Negative' || this.fiprofilestatus == 'Negative'){
            this.isNegativeReasonDisable = false;
           }

           if(data.fields.hasOwnProperty('Send_Back_Counter__c')){
            let senBackCounterObj = data.fields.Send_Back_Counter__c;
            if(senBackCounterObj.hasOwnProperty('value')){
                if(senBackCounterObj.value>0){
                    this.renderSendBackComments = true;
                }
            }
           }

            this.isTwoWheelerFI = (this.proposedVehicle.includes('Two'));
            this.vehicleType = (data.fields.Loan_Application_Product_Type__c.value);
            this.isTractor = this.vehicleType?.includes('Tractor');

            console.log('hiii>>>' + this.openingRemarks);
            if (data.fields.Customer_Type__c.value == 'Individual') {
                this.checkCustomerTypeForIndividual = true;
                console.log('checkCustomerTypeForIndividual>>>' + this.checkCustomerTypeForIndividual);
            }
            else {
                this.checkCustomerTypeForIndividual = false;
            }

            if(data.fields.hasOwnProperty('Punch_the_Location_for_Geo_tag__c')){
                this.currentLocation = data.fields.Punch_the_Location_for_Geo_tag__c.value 
            }
            if(data.fields.hasOwnProperty('Loan_Application__r')){
                this.applicationStage = data.fields.Loan_Application__r.value.fields.Stage__c.value;
            }

            this.setQuestionarrieLink(data.fields.Opening_Remarks__c.value);
        }
        if(error){
            //alert('here '+JSON.stringify(error));
        }

    }

    createDevation() {
        // declare an object with a property `sobjectType` to help the middleware parse 
        // this object into an `Account` on the server
        var Deviation__c=
        {
            Loan_Application__c : 'a016s000003bSsmAAE',
            Level__c : 'S1',
            Details__c : 'Test',
            Deviation_Type__c : 'FI-Negative',
            Active__c : true

        };
        var listobjDeviation=[];
        listobjDeviation.push(Deviation__c);
        console.log('listobjDeviation>>'+JSON.stringify(listobjDeviation));

        createDeviation({lstDeviation: listobjDeviation})
            .then(result => {
                console.log(result);
            })
            .catch(error => {
                console.log(error);
            });
    }

    hideModalBox(){
        this.isActiveIFrame = false;
    }

    handlePrint(){
        if(FORM_FACTOR=='Small'){
        this.isMobile=true;
        }
        //this.testURL = '/apex/FIPrintReportPage?recId='+this.recordId + '&blnm='+this.isMobile;
        //this.isActiveIFrame = true;
        
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                url: '/apex/FIPrintReportPage?recId='+this.recordId + '&blnm='+this.isMobile
            }
            });
        //}
    }

    @track section = ['Basic Details','FI Summary'];
    handleSectionToggle(evt){
        this.section = evt.detail.openSections;
    }

    handlError(evt){
        //alert('in error  here'+JSON.stringify(evt.detail));
        this.isLoaded=false;
    }
    handleFiStatus(event) {
        console.log('vent.target.value ' + event.target.value);
        console.log('isFiProfile :: ' + this.isFiProfile);
        if(this.isFiProfile){
            fields.FI_Status__c = event.target.value;
            this.fiprofilestatus = event.target.value;
        }
        else{
            this.currentFIstatus = event.target.value;
        }
      
        
        console.log('isFiProfile :: ' + this.isFiProfile);
        if (event.target.value == 'Negative' || event.target.value == 'Positive' || event.target.value == 'Waived Off' ){
            console.log('vent.target.value 111 ' + event.target.value);
            this.template.querySelector('lightning-input-field[data-id="stage"]').value = 'Closed';
            this.currentStage = 'Closed';
            console.log('vent.target.value  111 ' + event.target.value);
        }
        else if(event.target.value == 'Cancelled'){
            this.template.querySelector('lightning-input-field[data-id="stage"]').value = 'New';
            this.currentStage = 'New';
        }
        else {
            console.log('vent.target.value 222' + event.target.value);
            this.template.querySelector('lightning-input-field[data-id="stage"]').value = 'In Progress';
            console.log('vent.target.value 222  ' + event.target.value);
            
        }
        console.log('condition 1 ');
        if(event.target.fieldName == 'FI_Status__c' || event.target.fieldName == 'FI_Profile_Status__c'){
            if(event.target.value == 'Waived off'){
                if(this.isTwoWheelerFI || !this.isTwoWheelerFI){
                    this.openingMarksRequired = false;
                    this.waiveOffMandatory = true;
                }

            }
            if(event.target.value == 'Negative'){
                this.isNegativeReasonMandatory = true ;
                this.isNegativeReasonDisable = false;
                this.negativeReasonsSelectedValue.Address_Negative_Reason = '';
                this.negativeReasonsSelectedValue.Profile_Negative_Reason = '';
                this.negativeReasonsSelectedMultipleValuesObject.Address_Negative_Reason = [];
                this.negativeReasonsSelectedMultipleValuesObject.Profile_Negative_Reason = [];
            }
            else{
                this.isNegativeReasonDisable = true;
                this.isNegativeReasonMandatory = false; 
                this.negativeReasonsSelectedValue.Address_Negative_Reason = '';
                this.negativeReasonsSelectedValue.Profile_Negative_Reason = '';
                this.negativeReasonsSelectedMultipleValuesObject.Address_Negative_Reason = [];
                this.negativeReasonsSelectedMultipleValuesObject.Profile_Negative_Reason = [];
                let validityResult = this.checkNegativeComboboxFields(event.target.value,event.target.value);
                //this.template.querySelector('lightning-input-field[data-id="otherReason"]').value = '';    
                
                //this.template.querySelector('lightning-input-field[data-id="negativeReason"]').value = null change as replaced by other reason and profile related
            }
        }
        this.checkWaivedOffCondn();

    }
    @track negativeProfileReasonOptions = [{label:'None',value:''}]
    @track negativeAddressReasonOptions = [{label:'None',value:''}]
    @track negativeReasonsSelectedValue = {'Profile_Negative_Reason':'','Address_Negative_Reason':''}

    handleOnLoad(event){
        const fieldsDef = event.detail.records[this.recordId].fields;
        getUserAssignedPermissions({})
        .then(res=>{ 
            //alert('yash '+JSON.stringify(res));    
            console.log('test '+JSON.stringify(res)+' '+fieldsDef.Proposed_vehicle__c.value);       
            this.isRetriggerPermissionGranted = res.isRetriggerPermission;
            this.isReassignPermissionGranted = res.isReassignPermission;
            this.isUploadPermissionGranted = res.isUploadPermission;
            this.isFormEdit = res.isEditPermission && fieldsDef.Stage__c.value != 'Closed' && fieldsDef.Stage__c.value != 'Waived off' && this.checkIfOwnerViewing();

            this.isPermissionSetCompleted = true;
            if(this.isFormEdit) {
                //this.handleConditions(event);
                this.checkWaivedOffCondn();
                // this.negativeReasonsSelectedValue.Profile_Negative_Reason = fieldsDef.Profile_Negative_Reasons__c.value;

                // this.negativeReasonsSelectedValue.Address_Negative_Reason = fieldsDef.Address_Negative_Reason__c.value;

                
                
                this.getProfileAddressPicklistValues(fieldsDef.Proposed_vehicle__c.value);
            }

        })
        .catch(err=>{
            console.log('err'+JSON.stringify(err));

        })
        this.isLoaded=false;
        
    }

    @track isDisabledField = false;
    checkIfOwnerViewing(){
        if(!this.isFiProfile){
            if(this.loggedInUserId != this.fiRecordOwner && this.currentStage == 'Assigned'){
                this.isDisabledField = true;
                this.isAddressMandatory = false;
                this.isRemarksMandatory = false;
                this.openingMarksRequired = false;
                this.isUploadPermissionGranted = false;
                return true;
            }
            
            else if(this.loggedInUserId != this.fiRecordOwner && this.currentStage != 'Assigned'){
                this.isDisabledField = true;
                this.isAddressMandatory = false;
                this.isRemarksMandatory = false;
                this.openingMarksRequired = false;
                this.isUploadPermissionGranted = false;
                return false;
            }
            else if(this.loggedInUserId == this.fiRecordOwner){
                return true;
            }

        }
        else{
            return (this.loggedInUserId == this.fiRecordOwner);
        }
        //return ((this.currentStage == 'Assigned' && !this.isFiProfile) || (this.currentStage == 'In Progress' && this.loggedInUserId == this.fiRecordOwner));
    }

    setQuestionarrieLink(openingRemarks){
        //let openingRemarks = this.template.querySelector('lightning-input-field[data-id="openingRemarks"]').value;
        if(openingRemarks == 'Lets Start' || openingRemarks == 'Door Lock'){
            this.showQuestionnaireLink = true;
        }
        else
            this.showQuestionnaireLink = false;

    }


    getProfileAddressPicklistValues(vehicleType) {
        getProfileAddressNegativePicklistValues({
            vehicleType : this.vehicleType
        })
        .then(res=>{
            if(res.profileRelated.length) {
                let profileReasons = res.profileRelated;
                let profileReasonsLocal = [];
                profileReasonsLocal= [{label:'None',value:''}]
                for(var d in profileReasons){
                    profileReasonsLocal.push({
                        label:profileReasons[d].label,
                        value:profileReasons[d].value
                    })

                }
                this.negativeProfileReasonOptions = profileReasonsLocal;
            }
            if(res.addressRelated.length) {
                let addressreasons = res.addressRelated;
                let addressReasonsLocal = [];
                addressReasonsLocal= [{label:'None',value:''}]
                for(var d in addressreasons){
                    addressReasonsLocal.push({
                        label:addressreasons[d].label,
                        value:addressreasons[d].value
                    })

                }
                this.negativeAddressReasonOptions = addressReasonsLocal;

            }

        })
        .catch(error=>{
            console.error(error);

        })
    }

    @track negativeReasonsSelectedMultipleValuesObject={'Profile_Negative_Reason':[],'Address_Negative_Reason':[]};
    handleNegativePicklistCHange(evt){
        this.negativeReasonsSelectedValue[evt.currentTarget.dataset.id] = evt.detail.value;
        if(evt.detail.value!=''){
            this.setMultipleNegativeReasonsValues(evt.currentTarget.dataset.id, evt.detail.value);
        }
    }
    setMultipleNegativeReasonsValues(reasonName, value){
        if(this.negativeReasonsSelectedMultipleValuesObject.hasOwnProperty(reasonName)){
            let existingValues = this.negativeReasonsSelectedMultipleValuesObject[reasonName];
            if(!existingValues.includes(value)){
                existingValues.push(value);
            }
            this.negativeReasonsSelectedMultipleValuesObject[reasonName] = existingValues;
        }
        else{
            let newValue = [];
            newValue.push(value);
            this.negativeReasonsSelectedMultipleValuesObject[reasonName] = newValue;
        }
    }
    handlePillRemove(evt){
        let exixtingValues = this.negativeReasonsSelectedMultipleValuesObject[evt.currentTarget.dataset.key];
        let updatedValues = [];
        exixtingValues.forEach(val=>{
            if(val != evt.currentTarget.dataset.id){
                updatedValues.push(val);
            }
        })
        this.negativeReasonsSelectedMultipleValuesObject[evt.currentTarget.dataset.key] = updatedValues;
        this.negativeReasonsSelectedValue[evt.currentTarget.dataset.key] = '';
    }

    checkWaivedOffCondn(){
            try {
                var disableWaiveOff =false;
                var disableother= false;
                this.template.querySelector('lightning-input-field[data-id="fiStatus"]').value !='Waived off'?disableWaiveOff=true:this.template.querySelector('lightning-input-field[data-id="waiveOffReason"]').value !='Other'?disableother=true:disableother=false;
        
                if(disableWaiveOff){ 
                    this.template.querySelector('lightning-input-field[data-id="waiveOffReason"]').value =null;
                    this.template.querySelector('lightning-input-field[data-id="waiveOffOtherReason"]').value=null;
                    this.disableWaiveOffReason=true;
                    this.reqWaiveOffOtherReason=false;
                     disableother= true;
                }
                if(disableother){
                this.template.querySelector('lightning-input-field[data-id="waiveOffOtherReason"]').value=null;
                this.disableOtherWaiveOffReason=true;
                this.reqWaiveOffOtherReason=false;

        
                }
                if(!disableother){
                    this.disableOtherWaiveOffReason=false;
                    this.reqWaiveOffOtherReason=true;

        
                }
                 if(!disableWaiveOff){
                    this.disableWaiveOffReason=false;
        
                } 
                }catch(error){
                    console.log('this.error>>>>>' + JSON.stringify(error));
        
                }
        
    }
   /* get checkWaiveOff(){
        if(this.showWaiveOffReason)
        {
            return true;
        }
        else{
            return false;
        }
      //  this.showOtherReason ? return true:return false;
    }
    get checkOther(){
        if(this.showOtherWaiveOffReason)
        {
            return true;
        }
        else{
            return false;
        }
     //  this.showOtherWaiveOffReason ? return true:return false;

    }*/
    handleUploadCompVisiblity(event){       
        //alert('here yash '+event.detail.showUploadComponent)
        this.showUploadPhotoOption=event.detail.showUploadComponent;
    }
    handleSuccessUpload(){
        this.isImagesVisible=false;
        this.isUploadImages=!this.isUploadImages;

      //  this.isUploadImages=true;
    }
    /*  get getopeningRemarks(){
        return this.openingRemarks=='Lets Start' ?null:this.openingRemarks;
      }*/
    renderedCallback() {
        this.isImagesVisible=true;
       
         // this.handleConditions(true);

    }
    
    handleQuestionaireComponent() {
       
        if (this.fiagentId != null && this.fiagentId != '' && this.fiagentId != undefined && this.fiagentId != 'undefined' && Id == this.fiagentId) {
            this.userwithempcode = this.fullname + ' & ' + this.empcode;    
        }
        // console.log('this.ficunducteddatetime ' + this.ficunducteddatetime);
        // console.log('this.fisummitiondatetime ' + this.fisummitiondatetime);
        if (this.IsFiComponentActive == true) {
            var fields = [];
            var newdate = this.getCurrentDateTime();
            fields['FI_Conducted_Date_Time__c'] = (this.ficunducteddatetime!= null && this.ficunducteddatetime != '' && this.ficunducteddatetime != undefined && this.ficunducteddatetime != 'undefined' ? this.ficunducteddatetime : newdate.toISOString());
            //fields['FI_Submission_Date_Time__c'] = (this.fisummitiondatetime!= null && this.fisummitiondatetime != '' && this.fisummitiondatetime != undefined && this.fisummitiondatetime != 'undefined' ? this.fisummitiondatetime : newdate);
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            this.IsQuestionnaireComponentActive = !this.IsQuestionnaireComponentActive;
            this.IsFiComponentActive = !this.IsFiComponentActive;
            //console.log('this.IsQuestionnaireComponentActive>>>' + this.IsQuestionnaireComponentActive + 'this.IsFiComponentActive>>>>' + this.IsFiComponentActive);
        }
        else {
            this.IsQuestionnaireComponentActive = !this.IsQuestionnaireComponentActive;
            this.IsFiComponentActive = !this.IsFiComponentActive;
            //console.log('this.IsQuestionnaireComponentActive>>>' + this.IsQuestionnaireComponentActive + 'this.IsFiComponentActive>>>>' + this.IsFiComponentActive);
        }
        
       // setTimeout(function(){
            
            
       // }, 3000);
        
       

    }

    hideQuestionnaireForTractor() {
        this.IsQuestionnaireComponentActive = !this.IsQuestionnaireComponentActive;
        this.IsFiComponentActive = !this.IsFiComponentActive;
    }

    handleChildResponse() {
        this.handleQuestionaireComponent();
    }


    handleConditions(event) {
        //console.log('yash is Here '+ JSON.stringify(event.target))
        //var addressMatch = '';
        
        var addressMatch = (this.template.querySelector('lightning-input-field[data-id="addressMatch"]')!={}|| this.template.querySelector('lightning-input-field[data-id="addressMatch"]')!=undefined)?
            this.template.querySelector('lightning-input-field[data-id="addressMatch"]').value:'';
        this.openingRemarks = this.template.querySelector('lightning-input-field[data-id="openingRemarks"]').value;

        //alert(addressMatch);
        
        if (this.openingRemarks == 'Customer Not Interested' || this.openingRemarks == 'Address Not Traceable') {
            this.isRemarksMandatory = true;
            this.showQuestionnaireLink = false;

        }
        else if (this.openingRemarks == 'Lets Start' || this.openingRemarks == 'Door Lock') {
            if(event.target == null){
                var fields={};
                fields['Stage__c'] = 'In Progress';
                fields['FI_Profile_Status__c'] = 'In Progress';
                fields['FI_Status__c'] = 'In Progress';
                fields['Opening_Remarks__c'] = this.openingRemarks;
                this.template.querySelector('lightning-record-edit-form').submit(fields);

            }
            else if(event.target!=null && event.target.fieldName == 'Opening_Remarks__c'){
                var fields={};
                fields['Stage__c'] = 'In Progress';
                fields['FI_Profile_Status__c'] = 'In Progress';
                fields['FI_Status__c'] = 'In Progress';
                fields['Opening_Remarks__c'] = this.openingRemarks;
                this.template.querySelector('lightning-record-edit-form').submit(fields);
            }
            this.isRemarksMandatory = false;
            this.showQuestionnaireLink = true;
        }
        if (addressMatch == 'No') {
            this.isAddressMandatory = true;
        }
        else if(addressMatch == 'Yes' || addressMatch == '') {
            this.isAddressMandatory = false;

        }
        
      /*  if( this.openingRemarks !=null &&  addressMatch !=null)
        this.CheckIfrendered =true;*/
        
        /*  if(event.target.fieldName == 'Opening_Remarks__c'){
              if (event.target.value == 'Customer Not Interested' || event.target.value == 'Address Not Traceable') {
                  this.isRemarksMandatory = true;
                  this.showQuestionnaireLink=false;
  
              }
              else if(event.target.value == 'Lets Start' || event.target.value == 'Door Lock'){
                  this.isRemarksMandatory = false;
                  this.showQuestionnaireLink=true;
              }
              //when Opening remarks is Door lockedß
             /* else if{
                  this.showQuestionnaireLink=false;
                  this.isRemarksMandatory = false;
              }*/

        /* }
         if(event.target.fieldName == 'Address_match__c'){
             if (event.target.value == 'No') {
                 this.isAddressMandatory=true;
             }
             else{
                 this.isAddressMandatory=false;
 
             }
         }*/



    }

    getCurrentDateTime() {
        var today = new Date();
        var todayDate = String(today.getDate()).padStart(2, '0');
        var todayMonth = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var year = today.getFullYear();
        var currentOffset = today.getTimezoneOffset();

        var ISTOffset = 330;   // IST offset UTC +5:30 

        var ISTTime = new Date(today.getTime() + (ISTOffset + currentOffset) * 60000);

        // ISTTime now represents the time in IST coordinates

        var hh = ISTTime.getHours();
        var m = ISTTime.getMinutes();
        var s = ISTTime.getSeconds();
        var dd = "am";
        var h = hh;
        if (h >= 12) {
            h = hh - 12;
            dd = "pm";
        }
        if (h == 0) {
            h = 12;
        }
        m = m < 10 ? "0" + m : m;

        s = s < 10 ? "0" + s : s;
        var replacement = h + ":" + m;
        replacement += " " + dd;
        var currentDateTime = todayDate + '/' + todayMonth + '/' + year + ', ' + replacement;
        let dateFormed = new Date(year,today.getMonth(),todayDate,hh,m,s);
    
        return dateFormed;


    }

    handleSuccess(event) {
        console.log('Success ... ');
        console.log('Success ... ' + this.fillQuestionaire);
        console.log('Success ... ' + this.openingRemarks);
        console.log('Success ... ');
        console.log('Success ... ');

        this.isLoaded=false;
        if(this.blnSavedSuccess && (this.fillQuestionaire ||this.openingRemarks == 'Customer Not Interested' || this.openingRemarks == 'Address Not Traceable' ||this.openingRemarks == 'Door Lock')) {
            this.template.querySelector('c-common-toast').showToast('success','<strong>Successfully Submitted<strong/>','utility:success',10000);
            this.createDevation();
        }
        //console.log('onsuccess event recordEditForm', event.detail.id);

    }

    async onSubmitHandler(event) {
        event.preventDefault();
        this.error = false; 
        this.errorMsg = '';
        this.isLoaded=true;
        this.blnSavedSuccess = false;
        const fields = event.detail.fields;

        //alert(fields.FI_Status__c+' Profile '+fields.FI_Profile_Status__c)
        if(this.isFiProfile){
            fields.FI_Status__c = fields.FI_Profile_Status__c;
            this.currentFIstatus = fields.FI_Profile_Status__c;
            this.fiprofilestatus = fields.FI_Profile_Status__c;
        }
        else {
            fields.FI_Profile_Status__c =fields.FI_Status__c;
            this.currentFIstatus = fields.FI_Status__c;
            this.fiprofilestatus = fields.FI_Status__c;
        }
        //alert(fields.FI_Status__c+' Profile '+fields.FI_Profile_Status__c)


        if(fields.FI_Profile_Status__c == 'Waived off' || fields.FI_Status__c == 'Waived off'){
            if(this.isTwoWheelerFI || !this.isTwoWheelerFI){
                fields['Stage__c']='Waived off';
                this.isFormEdit = false;
                this.template.querySelector('lightning-record-edit-form').submit(fields);
                return;
            }
        }

        if(this.currentLocation == '' || this.currentLocation == null){
            if(this.isMobile){
                this.template.querySelector('c-common-toast').showToast('error','<strong>Please enter Location to Proceed<strong/>','utility:error',10000);
                this.isLoaded = false;
                return;
            }
        }

        // R2-2575 - START
        if (this.isTractor) {
            let isQuestionnaireFilled = false;
            isQuestionnaireFilled = await tractorQuestionnaireCheck({
                fieldInvestigationId : this.recordId
            });
            if (!isQuestionnaireFilled) {
                this.template.querySelector('c-common-toast').showToast('error','<strong>Please complete questionnaire to proceed<strong/>','utility:error',10000);
                this.isLoaded = false;
                return;
            }
        }
        // R2-2575 - END

        if(this.isTractor || this.fillQuestionaire ||this.openingRemarks == 'Customer Not Interested' || this.openingRemarks == 'Address Not Traceable' ||this.openingRemarks == 'Door Lock' ){
            event.preventDefault();
            if(this.isFiProfile){
                fields.FI_Status__c = fields.FI_Profile_Status__c;
            }
            else {
                fields.FI_Profile_Status__c =fields.FI_Status__c;
            }  
            if(this.isFiProfile){
                fields.FI_Profile_Status__c == 'Positive' || fields.FI_Profile_Status__c == 'Negative' ? fields.Stage__c = 'Closed' :true;
                fields.FI_Status__c = fields.FI_Profile_Status__c;
            }
            else {
                fields.FI_Status__c == 'Positive' || fields.FI_Status__c == 'Negative' ? fields.Stage__c = 'Closed' :fields.FI_Status__c == 'Cancelled'  ? fields.Stage__c = 'Cancelled' : fields.FI_Status__c == 'Waived off'?fields.Stage__c = 'Closed':true;
                fields.FI_Profile_Status__c =fields.FI_Status__c;
            }  

            fields.Is_Send_Back__c = false;
           
            if(!this.checkNegativeComboboxFields(fields.FI_Status__c, fields.FI_Profile_Status__c)) {
                // console.log('fields.Punch_the_Location_for_Geo_tag__c>>>>' + fields.Punch_the_Location_for_Geo_tag__c);
                // console.log('Stage ' + fields.Stage__c);
                // console.log('this.Credit_Manager ' + this.ownerIdCM);
                
                // fields.Profile_Negative_Reasons__c = this.negativeReasonsSelectedValue.Profile_Negative_Reason;
                // fields.Address_Negative_Reason__c = this.negativeReasonsSelectedValue.Address_Negative_Reason;
                fields.Profile_Negative_Reasons__c = this.negativeReasonsSelectedMultipleValuesObject['Profile_Negative_Reason'].join(';');
                fields.Address_Negative_Reason__c = this.negativeReasonsSelectedMultipleValuesObject['Address_Negative_Reason'].join(';');
                //console.log('onsubmit event recordEditForm>>' + JSON.stringify(event.detail.fields));

                updateFieldInvestigationRecord ({strFields : JSON.stringify(event.detail.fields), recordId : this.recordId, blnFIProfile : this.isFiProfile, blnfinalupdate : true})
                .then(result => {
                    //console.log(JSON.stringify(result));
                    this.isLoaded = false;
                    if (result.blnSuccess == true){
                        let msgSuccess = result.strMessage;
                        this.errorMsg = msgSuccess
                        this.template.querySelector('c-common-toast').showToast('success','<strong>'+msgSuccess+'<strong/>','utility:success',10000);
                        this.blnSavedSuccess = true;
                    }
                    else{
                        this.template.querySelector('c-common-toast').showToast('error',result.strMessage,'utility:error',10000);
                    }
                    
                })
                .catch(error => {
                    console.log(error);
                    this.template.querySelector('c-common-toast').showToast('error','Error in Saving Record','utility:error',10000);
                    this.isLoaded = false;
                });
            } else{
                this.isLoaded = false;
                let validityResp = this.checkNegativeComboboxFields(fields.FI_Status__c, fields.FI_Profile_Status__c);
            }
        } else{
            if(!this.checkNegativeComboboxFields(fields.FI_Status__c, fields.FI_Profile_Status__c)) {
                //alert('inside here '+this.fiprofilestatus+' '+this.currentFIstatus+' stage '+this.currentStage)
                this.isLoaded = false;
                // this.error = true;
                // fields.FI_Status__c = this.currentFIstatus;
                // fields.FI_Profile_Status__c = this.fiprofilestatus;
                // fields.Stage__c = this.currentStage;
                // fields.Profile_Negative_Reasons__c = this.negativeReasonsSelectedValue.Profile_Negative_Reason;
                // fields.Address_Negative_Reason__c = this.negativeReasonsSelectedValue.Address_Negative_Reason;
                if(this.currentStage!='Closed'){
                    fields.FI_Status__c = this.currentFIstatus;
                    fields.FI_Profile_Status__c = this.fiprofilestatus;
                    fields.Stage__c = this.currentStage;
                    fields.Is_Send_Back__c = false;
                    // fields.Profile_Negative_Reasons__c = this.negativeReasonsSelectedValue.Profile_Negative_Reason;
                    // fields.Address_Negative_Reason__c = this.negativeReasonsSelectedValue.Address_Negative_Reason;
                    fields.Profile_Negative_Reasons__c = this.negativeReasonsSelectedMultipleValuesObject['Profile_Negative_Reason'].join(';');
                    fields.Address_Negative_Reason__c = this.negativeReasonsSelectedMultipleValuesObject['Address_Negative_Reason'].join(';');
                    this.error = true;
                    this.errorMsg = FI_Questionnaire_Required_Message;
                    this.template.querySelector('c-common-toast').showToast('warning','<strong>Fill up Questionnaire<strong/>','utility:warning',10000);
                    this.template.querySelector('lightning-record-edit-form').submit(fields);
                }
                else if(this.currentStage == 'Closed'){
                    this.error = true;
                    this.errorMsg = FI_Questionnaire_Required_Message;
                    this.template.querySelector('c-common-toast').showToast('warning','<strong>Fill up Questionnaire<strong/>','utility:warning',10000);
                }
            } else{
                this.isLoaded = false;
                let validityResp = this.checkNegativeComboboxFields(fields.FI_Status__c, fields.FI_Profile_Status__c);
            }
        }
    }

    /*
    checkNegativeComboboxFields(fiStatus, fiProfileStatus) {
        let isError = false;
        let isErrorProfileReason = false;
        let isErrorAddressReason = false;
        if(fiStatus == 'Negative' || fiProfileStatus == 'Negative') {
            let negativeProfileReasonList = [];
            let negativeAddressReasonList = [];
            if(this.negativeReasonsSelectedMultipleValuesObject.hasOwnProperty('Profile_Negative_Reason')){
                negativeProfileReasonList = this.negativeReasonsSelectedMultipleValuesObject.Profile_Negative_Reason;
            }
            if(this.negativeReasonsSelectedMultipleValuesObject.hasOwnProperty('Address_Negative_Reason')){
                negativeAddressReasonList = this.negativeReasonsSelectedMultipleValuesObject.Address_Negative_Reason;
            }
            let profileReasonDropDown = this.template.querySelector('lightning-combobox[data-id="Profile_Negative_Reason"]');
            if(!negativeProfileReasonList || negativeProfileReasonList==[] || !negativeProfileReasonList.length){
                isErrorProfileReason = true;
                profileReasonDropDown.setCustomValidity('Profile Reason is Required');
                
                }
                else{
                isErrorProfileReason = false;
                profileReasonDropDown.setCustomValidity('');
                }
            profileReasonDropDown.reportValidity();
            let addresseReasonDropDown = this.template.querySelector('lightning-combobox[data-id="Address_Negative_Reason"]');
            if(!negativeAddressReasonList || negativeAddressReasonList==[] || !negativeAddressReasonList.length){
                isErrorAddressReason = true;
                addresseReasonDropDown.setCustomValidity('Address Reason is Required');
            }
            else{
                isErrorAddressReason = false;
                addresseReasonDropDown.setCustomValidity('');
            }
            addresseReasonDropDown.reportValidity();
            isError = isErrorAddressReason || isErrorProfileReason;
            // let dropDownFields = this.template.querySelectorAll('lightning-combobox');
            // dropDownFields.forEach(comboboxValue=>{
            //     // if(comboboxValue.value==''||!comboboxValue.value){
            //     //     isError = true;
            //     //     comboboxValue.setCustomValidity("Reasons Required");
                
            //     // }
            //     if(negativeProfileReasonList==[] ||  negativeAddressReasonList==[]){
            //         alert('yash')
            //         isError = true;
            //         comboboxValue.setCustomValidity("Reasons Required New check");
                
            //     }
            //     else{
            //         isError = false;
            //         comboboxValue.setCustomValidity("")
            //     }
            //     comboboxValue.reportValidity();
            // })
        }
        else{
            let dropDownFields = this.template.querySelectorAll('lightning-combobox');
            dropDownFields.forEach(comboboxValue=>{
                comboboxValue.setCustomValidity("");
                comboboxValue.reportValidity();
            })
        }
        
        return isError;
    }*/

    checkNegativeComboboxFields(fiStatus, fiProfileStatus) {
        let isError = false;
        let isErrorProfileReason = false;
        let isErrorAddressReason = false;
        if(fiStatus == 'Negative' || fiProfileStatus == 'Negative') {
            let negativeProfileReasonList = [];
            let negativeAddressReasonList = [];
            if(this.negativeReasonsSelectedMultipleValuesObject.hasOwnProperty('Profile_Negative_Reason')){
                negativeProfileReasonList = this.negativeReasonsSelectedMultipleValuesObject.Profile_Negative_Reason;
            }
            if(this.negativeReasonsSelectedMultipleValuesObject.hasOwnProperty('Address_Negative_Reason')){
                negativeAddressReasonList = this.negativeReasonsSelectedMultipleValuesObject.Address_Negative_Reason;
            }
            let profileReasonDropDown = this.template.querySelector('lightning-combobox[data-id="Profile_Negative_Reason"]');
            let addresseReasonDropDown = this.template.querySelector('lightning-combobox[data-id="Address_Negative_Reason"]');

            if(!negativeProfileReasonList || negativeProfileReasonList==[] || !negativeProfileReasonList.length){
                isErrorProfileReason = true;
            }
            else{
                isErrorProfileReason = false;
            }
            if(!negativeAddressReasonList || negativeAddressReasonList==[] || !negativeAddressReasonList.length){
                isErrorAddressReason = true;
            }
            else{
                isErrorAddressReason = false;
            }
            isError = isErrorAddressReason && isErrorProfileReason;
            if(isError){
                profileReasonDropDown.setCustomValidity('Please select either a Negative Profile or Address Reason to proceed');
                addresseReasonDropDown.setCustomValidity('Please select either a Negative Profile or Address Reason to proceed');

            }
            else{
                profileReasonDropDown.setCustomValidity('');
                addresseReasonDropDown.setCustomValidity('');
            }
            profileReasonDropDown.reportValidity();
            addresseReasonDropDown.reportValidity();
            
        }
        else{
            let dropDownFields = this.template.querySelectorAll('lightning-combobox');
            dropDownFields.forEach(comboboxValue=>{
                comboboxValue.setCustomValidity("");
                comboboxValue.reportValidity();
            })
        }
        
        return isError;
    }

    geolocation() {

        if(this.loggedInUserId != this.fiRecordOwner){
            this.template.querySelector('c-common-toast').showToast('error','<strong>FI Record-Report can only be filled and edited by Owner only.<strong/>','utility:error',10000);
            return;
        }

        var latitude;
        var longitude;
        this.isLoaded = true;
        this.error = false;
        this.errorMsg = ''
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(position => {

                // Get the Latitude and Longitude from Geolocation API
                latitude = Math.round(position.coords.latitude);
                longitude = Math.round(position.coords.longitude);
                var loclatlong = longitude + ',' + latitude;
                // Add Latitude and Longitude to the markers list.
                this.currentLocation = 'Lat:' + latitude + ',' + 'Long:' + longitude;
                this.template.querySelector('lightning-input-field[data-id="geolocation"]').value = this.currentLocation;
                
                getLatLongAddressDistance({strCurrentLatandLong: loclatlong, recordId: this.recordId , strAddress: this.fullallocatedaddress, integrationChecklistId: null})
                .then(result => {
                    console.log(JSON.stringify(result));
                    if (result.blnError == false){
                        this.template.querySelector('lightning-input-field[data-id="distance"]').value = result.dblDistance;
                    }
                    else if (result.blnError == true && result.strMsg != ''){
                        this.error = true;
                        this.errorMsg = result.strMsg;
                    }
                    this.isLoaded = false;
                })
                .catch(error => {
                    console.log(error);
                    this.isLoaded = false;
                });
                
                
                return 'Lat:' + latitude + ',' + 'Long:' + longitude;
            });

        }
    }

}