import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
//updated few fields - R2 - 1801
const FIELDS = ['Field_Investigation__c.Mobile_Number_of_Landlord__c','Field_Investigation__c.Neighbor_Check_Mobile_Number__c','Field_Investigation__c.Mobile_no_of_Boss_HR__c',
  'Field_Investigation__c.Reference_Mobile_no__c','Field_Investigation__c.Reference1_Mobile__c','Field_Investigation__c.Reference2_Mobile__c',
  'Field_Investigation__c.Mobile_No__c','Field_Investigation__c.Residence_own_by_borrower_TW__c','Field_Investigation__c.Is_the_owner_of_AGRI_land__c',
  'Field_Investigation__c.Borrower_or_family_prof_fall_in_negative__c','Field_Investigation__c.Is_the_Residence_owned_by_the_Borrower__c','Field_Investigation__c.Present_vehicle_in_family__c','Field_Investigation__c.Was_the_vehicle_Re_possessed__c','Field_Investigation__c.Does_Customer_have_Driving_License__c','Field_Investigation__c.Employment_status__c','Field_Investigation__c.Office_business_Ownership__c','Field_Investigation__c.Contact_No__c'
];
export default class FieldInvestigationQuestionaireRepeativeCode extends LightningElement {
  @api recordId;
  @api checkPermanent;
  @api checkTwoWheelerType;
  @api checkAutoLoan;
  @api checkOffice;
  @api checkVehicle;
  @api checkCurrent;
  @api borrowerList;
  @api isMandatory;
  @api fieldList = {};
  @api checkForVechicle = false;
  @api saveButtonName;
  @api vechicle;
  @api checkvechicle;
  @track isLoaded = true;
  @api currentdatetime = '';
  @api applicantType = '';
  @api currentdate = '';
  @api currenttime='';
  @api userwithempcode = '';
  @api renderApplicantComponent = false;
  isResidenceChecked = false; //R2 - 1801
  
  //updated few fields R2 - 1801 start
  phoneFieldsAPIIds = ['Mobile_Number_of_Landlord__c','Mobile_no_of_Boss_HR__c','Contact_No__c','Neighbor_Check_Mobile_Number__c','Reference_Mobile_no__c',
                      'Reference1_Mobile__c','Reference2_Mobile__c','Mobile_No__c','Contact_No']
  @track validInputNumberMap = {'Mobile_Number_of_Landlord__c':true,'Mobile_no_of_Boss_HR__c':true,'Contact_No__c':true,'Neighbor_Check_Mobile_Number__c':true,
                                'Reference_Mobile_no__c':true,'Reference1_Mobile__c':true,'Reference2_Mobile__c':true,'Mobile_No__c':true,'Contact_No':true
                                };

  @track renderedFieldsParentFieldsAPI = ['Residence_own_by_borrower_TW__c','Is_the_owner_of_AGRI_land__c','Borrower_or_family_prof_fall_in_negative__c','Is_the_Residence_owned_by_the_Borrower__c','Present_vehicle_in_family__c','Was_the_vehicle_Re_possessed__c','Does_Customer_have_Driving_License__c','Employment_status__c','Office_business_Ownership__c']
  @track renderedFieldsObject = {'Residence_own_by_borrower_TW__c':['Name_of_Property_Owner__c','Name_of_property_owner_confirmed_from__c','Relationship_with_Property_Owner__c','Tentative_value_of_the_property__c'],
                                 'Is_the_owner_of_AGRI_land__c':['How_many_acres_Bigha__c','Tentative_value_of_the_Land__c'],
                                 'Borrower_or_family_prof_fall_in_negative__c':['Name_of_person__c','Profile_of_the_person__c'],
                                 'Residence_own_by_borrower_TW__c_Rented':['Name_of_landlord__c','Mobile_Number_of_Landlord__c','Amount_of_Rent_in_Rs__c','Permanent_Address_of_Borrower__c'],
                                 'Present_vehicle_in_family__c':['Vehicle_Make__c','Vehicle_Number__c'],
                                 'Was_the_vehicle_Re_possessed__c':['Detail_of_default__c','Who_will_drive_this_vehicle__c','Does_Customer_have_Driving_License__c'],
                                 'Does_Customer_have_Driving_License__c':['ExperienceOfDrivingWith_Com_vehicle__c','Use_of_vehice_for_what_purpose__c'],
                                 'Is_the_Residence_owned_by_the_Borrower__c':['Name_of_Property_Owner__c','Name_of_property_owner_confirmed_from__c','Relationship_with_Property_Owner__c','Tentative_value_of_the_property__c'],
                                 'Is_the_Residence_owned_by_the_Borrower__c_Rented':['Name_of_landlord__c','Mobile_Number_of_Landlord__c','Amount_of_Rent_in_Rs__c','Permanent_Address_of_Borrower__c'],
                                 'Employment_status__c':['Office_business_Ownership__c','Business_nature__c','Year_in_present_Employment_business__c','Property_situated_in_a_negative_area__c'],
                                 'Employment_status__c_Salaried':['Office_FI_Company_Name__c','Company_Address__c','Contact_No__c','No_of_Year_in_present_Employment__c','Name_of_reporting_Boss_HR__c','Mobile_no_of_Boss_HR__c'],
                                 'Office_business_Ownership__c':['No_of_years_in_the_same_property__c']
                                };
  //updated few fields R2 - 1801 end
  @track mobileValuesInput = {};
  @track initialMobileValuesMap = {};
  @track borrowerListNew = [];
  @track parentFieldsInitialValue = [];
  @api openingRemarks='';
 
  fi = {};
  field;
  value;

  @track section = ['Applicant Details','Reference Details'];
  handleSectionToggle(evt){
      this.section = evt.detail.openSections;
  }

  connectedCallback(){
  }

  @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
          this.showToast('ERROR!','Error in loading initial Record.','error')
            
        } else if (data) {
            for(var d in data.fields){
              if(this.renderedFieldsParentFieldsAPI.includes(d)){
                this.parentFieldsInitialValue.push({
                  apiName : d,
                  value : data.fields[d].value
                });
                
              }
              else{
                this.initialMobileValuesMap[d] = data.fields[d].value;
              }
              
            }
            this.updateBorrowerDataList();

        }
    }

    updateBorrowerDataList(){
      let borrowerListNew = [];
      borrowerListNew = JSON.parse(JSON.stringify(this.borrowerList));
      for(var d in borrowerListNew){
        if(this.phoneFieldsAPIIds.includes(borrowerListNew[d].apiName)){
          if(this.initialMobileValuesMap.hasOwnProperty(borrowerListNew[d].apiName)){
            borrowerListNew[d].defaultValue = this.initialMobileValuesMap[borrowerListNew[d].apiName];
          }
          else{
            borrowerListNew[d].defaultValue = '';
          }
        }
      }

      this.borrowerListNew = borrowerListNew;
      this.updateQuestionWithParent_DependentFields()
    }

    updateQuestionWithParent_DependentFields(){
      this.isResidenceChecked = false; // R2 - 1801
      if(this.parentFieldsInitialValue){
        for(var d in this.parentFieldsInitialValue){
          this.checkAndRenderOtherFields(this.parentFieldsInitialValue[d].apiName, this.parentFieldsInitialValue[d].value);
        }
      }
    }
  

  handleBack() {
    if (!this.checkForVechicle) {
      const storeEvent = new CustomEvent('myeventback', {
        detail: {}
      }
      );
      this.dispatchEvent(storeEvent);
    }
    else {
      const storeEvent = new CustomEvent('myeventtotab1', {
        detail: {}
      }
      );
      this.dispatchEvent(storeEvent);
    }
  }
  handleSuccess() {
    if (!this.checkForVechicle) {
      const storeEvent = new CustomEvent('myeventnext', {
        detail: {}
      }
      );
      this.dispatchEvent(storeEvent);
    }
    else {
      const storeEvent = new CustomEvent('onsuccess', {
        detail: {}
      }
      );
      this.dispatchEvent(storeEvent);
    }
    this.isLoaded = false;


  }
  handleOnload() {
    this.isLoaded = false;
  }
  handleError(evt) {
    //alert('error'+JSON.stringify(evt.detail));
    this.isLoaded = false;

  }
  handleSubmit(event) {
    event.preventDefault();
    if(this.isPresentVehicleInFamilyError){
      this.showToast('Error!','Please check if correct values are added for Current Vehicle in the family','error');
      return;
    }
    
    if(this.validateMobileNumberInputs()){
      this.isLoaded = true;
      const fields = event.detail.fields;
      console.log('fields start '+JSON.stringify(this.mobileValuesInput));
      for(var key in this.mobileValuesInput){
        fields[key] = this.mobileValuesInput[key]
      }
      //alert(fields['Mobile_No__c'])
      console.log('fields end '+JSON.stringify(fields));
      if (this.checkForVechicle)
    
        fields.Fill_Questionaire__c = true;
      // fields.Stage__c='In Progress';

      //console.log('onsubmit Ques event recordEditForm>>' + JSON.stringify(event.detail.fields));

      this.template.querySelector('lightning-record-edit-form').submit(fields);

    }
    else{
      this.showToast('ERROR!','Please provide valid input for Phone Numbers','error');
    }
  }

  validateMobileNumberInputs(){
    let numberObj = this.validInputNumberMap;
    for(var key in numberObj){
     if(!numberObj[key]){
      return numberObj[key]
     }
    }
    return true;
  }

  showToast(title,message,variant) {
    const evt = new ShowToastEvent({
        title: title,
        message: message,
        variant: variant,
        mode: 'dismissable'
    });
    this.dispatchEvent(evt);
}

  // checkPhoneNumberValidity(dataId){
  //   let checkField = this.template.querySelector('lightning-input-field[data-id="'+dataId+'"]');
  //   var regex = /^(\d{3})[- ]?(\d{3})[- ]?(\d{4})$/;
  //   this.validInputNumberMap[dataId] = regex.test(checkField.value);
  // }
  // handleFocustOut(evt){
  //   if(this.phoneFieldsAPIIds.includes(evt.currentTarget.dataset.id)){
  //     this.checkPhoneNumberValidity(evt.currentTarget.dataset.id);
  //   }

  // }

  handleMobileValueChange(evt){
    this.mobileValuesInput[evt.currentTarget.dataset.id] = evt.target.value;
    console.log('test mobile '+JSON.stringify(this.mobileValuesInput));
  }

  @track isErrorResponse = false;

  handleFocustOutMobile(evt){
    let checkField = this.template.querySelector('lightning-input[data-id="'+evt.currentTarget.dataset.id+'"]');
    if(checkField.value!=''){
      var regex = /^(\d{3})[- ]?(\d{3})[- ]?(\d{4})$/;
      if (!regex.test(checkField.value)) {
        checkField.setCustomValidity("Please provide a valid phone number");
        this.isErrorResponse = true;
        this.validInputNumberMap[evt.currentTarget.dataset.id] = false;
      } 
      else {
        checkField.setCustomValidity("");
        this.isErrorResponse = false;
        this.validInputNumberMap[evt.currentTarget.dataset.id] = true;
      }
    }
    else{
      checkField.setCustomValidity("");
      this.isErrorResponse = false;
      this.validInputNumberMap[evt.currentTarget.dataset.id] = true;
    }
    checkField.reportValidity();
    
  }

  @track isPresentVehicleInFamilyError = false;

  checkAndRenderOtherFields(fieldAPIName, fieldValue){
    //R2- 1801 start
    if(!this.isResidenceChecked && fieldAPIName == 'Is_the_Residence_owned_by_the_Borrower__c'){
      this.isResidenceChecked = true;
      if(fieldValue == 'Owned'||fieldValue == 'Parental'||fieldValue == 'Relative'||fieldValue=='Owned – Self/Spouse/parental'){
        this.hide_RenderDependentFields(fieldAPIName, false);
      }
      else{
        this.hide_RenderDependentFields(fieldAPIName, true);
      }
      if(fieldValue == 'Rented with Family'|| fieldValue == 'Rented – Bachelor accommodation'){
        this.hide_RenderDependentFields(fieldAPIName+'_Rented', false);
      }
      else{
        this.hide_RenderDependentFields(fieldAPIName+'_Rented', true);
      }
    }
    /*if(fieldAPIName=='Is_the_Residence_owned_by_the_Borrower__c'){
      if(fieldValue == 'Rented with Family'|| fieldValue == 'Rented – Bachelor accommodation'){
        console.log('@@enter if2');
        this.hide_RenderDependentFields(fieldAPIName+'_Rented', false);
      }
      else{
        console.log('@@enter else2');
        this.hide_RenderDependentFields(fieldAPIName+'_Rented', true);
      }
    }*/
    if(!this.isResidenceChecked && fieldAPIName=='Residence_own_by_borrower_TW__c'){
      this.isResidenceChecked = true;
      if(fieldValue == 'Owned'||fieldValue == 'Parental'||fieldValue == 'Relative'||fieldValue=='Owned – Self/Spouse/parental'){
        this.hide_RenderDependentFields(fieldAPIName, false);
      }
      else{
        this.hide_RenderDependentFields(fieldAPIName, true);
      }
      if(fieldValue == 'Rented with Family'||fieldValue=='Rented – Bachelor accommodation'){
        this.hide_RenderDependentFields(fieldAPIName+'_Rented', false);
      }
      else{
        this.hide_RenderDependentFields(fieldAPIName+'_Rented', true);
      }
    }
    /*if(fieldAPIName=='Residence_own_by_borrower_TW__c'){
      if(fieldValue == 'Rented with Family'||fieldValue=='Rented – Bachelor accommodation'){
        console.log('@@enter if4');
        this.hide_RenderDependentFields(fieldAPIName+'_Rented', false);
      }
      else{
        console.log('@@enter else4');
        this.hide_RenderDependentFields(fieldAPIName+'_Rented', true);
      }
    }*/

    // R2- 1801 end

    if(fieldAPIName=='Is_the_owner_of_AGRI_land__c'){
      if(fieldValue == 'Yes'){
        this.hide_RenderDependentFields(fieldAPIName, false);
      }
      else{
        this.hide_RenderDependentFields(fieldAPIName, true);
      }
    }
    if(fieldAPIName=='Borrower_or_family_prof_fall_in_negative__c'){
      if(fieldValue == 'Yes'){
        this.hide_RenderDependentFields(fieldAPIName, false);
      }
      else{
        this.hide_RenderDependentFields(fieldAPIName, true);
      }
    }
    if(fieldAPIName == 'Present_vehicle_in_family__c'){
      if(fieldValue != null && fieldValue != ''){ //R2 - 1801
        let selectedValues = fieldValue.split(';');
        let selectedValuesWONA = [];
        if(!selectedValues.includes('NA')){
          this.hide_RenderDependentFields(fieldAPIName, false);
        }
        else{
          if(selectedValues.length>1){
            this.showToast('ERROR!','No Other Value can be selected with NA','warning');
            for (let each in selectedValues) {
              if (selectedValues[each] != 'NA') {
                selectedValuesWONA.push(selectedValues[each]);
              }
            }
            this.template.querySelector('lightning-input-field[data-id="Present_vehicle_in_family__c"]').value = selectedValuesWONA.join(';');
          }
          this.hide_RenderDependentFields(fieldAPIName, true);
        }

      }
      //R2 - 1801
      else{
        this.hide_RenderDependentFields(fieldAPIName, true);
      }
      

      
    }
    if(fieldAPIName == 'Was_the_vehicle_Re_possessed__c'){
      if(fieldValue == 'Yes'){
        this.hide_RenderDependentFields(fieldAPIName, false);   
      }
      else{
        this.hide_RenderDependentFields(fieldAPIName, true);  
      }
    }
    if(fieldAPIName == 'Does_Customer_have_Driving_License__c'){
      if(fieldValue == 'Yes – Commercial Vehicle License'){
        this.hide_RenderDependentFields(fieldAPIName, false);   
      }
      else{
        this.hide_RenderDependentFields(fieldAPIName, true);  
      }
    }
    // R2 - 1801 start
    if(fieldAPIName=='Employment_status__c'){
      if(fieldValue == 'Self employed'){
        this.hide_RenderDependentFields(fieldAPIName, false);
      }
      else{
        this.hide_RenderDependentFields(fieldAPIName, true);
      }
      if(fieldValue == 'Salaried'){
        this.hide_RenderDependentFields(fieldAPIName+'_Salaried', false);
      }
      else{
        this.hide_RenderDependentFields(fieldAPIName+'_Salaried', true);
      }
    }
    if(fieldAPIName == 'Office_business_Ownership__c'){
      if(fieldValue == 'Rented'){
        this.hide_RenderDependentFields(fieldAPIName, false);   
      }
      else{
        this.hide_RenderDependentFields(fieldAPIName, true);  
      }
    }
    // R2 - 1801 end
  }

  checkIFOtherValuesSelectedWithNA(presentVehicleSelectedValues){
    let isErrorResp = false;
    if(presentVehicleSelectedValues.includes('NA') && presentVehicleSelectedValues.length>1){
      this.showToast('ERROR!','No Other Value can be selected with NA','error');
      isErrorResp = true;
    }
    return isErrorResp;
    
  }


  hide_RenderDependentFields(fieldAPIName, isHidden){
    try{
      let fieldList = this.renderedFieldsObject[fieldAPIName];    
      let borrowerList = this.borrowerListNew;
      borrowerList.forEach(record=>{
        if(fieldList.includes(record.apiName)){
          record.isNotFirstTimeRendered = isHidden;       
          if(this.openingRemarks!='Door Lock'){
            record.isMandatory = !isHidden;
          }
          
        }
      })

      this.borrowerListNew = borrowerList;

    }catch(e){
      console.log('error '+JSON.stringify(e))
    }
    

  }





  
  handleOnChange(event) {
    this.isResidenceChecked = false; // R2 - 1801
    this.checkAndRenderOtherFields(event.target.fieldName, event.target.value);
    
    // if (event.target.fieldName == 'Present_vehicle_in_family__c') {
    //   this.template.querySelector('lightning-input-field[data-id="Vehicle_Make__c"]').value = null;

    //   if(this.template.querySelector('lightning-input-field[data-id="Vehicle_Number__c"]') != null){
    //     this.template.querySelector('lightning-input-field[data-id="Vehicle_Number__c"]').value = null;
    //   }
    // }

    this.field = event.target.fieldName;
    this.value = event.target.value;
    console.log('value>>>' + event.target.value);
    const storeEvent = new CustomEvent('myevent', {
      detail:
      {
        value: this.value,
        fieldName: this.field
      }
    }
    );
    this.dispatchEvent(storeEvent);
  }

  
}