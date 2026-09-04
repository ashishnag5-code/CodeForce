import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getPropertyCollaterals from "@salesforce/apex/ausfPropertyCollateralController.getPropertyCollaterals";
import upsertManualCollateral from "@salesforce/apex/ausfPropertyCollateralController.upsertManualCollateral";
import LightningConfirm from 'lightning/confirm';
// import { updateDisabledOnFieldTokens } from 'c/ausfAddManualCollateral';

// Custom Spinner settings
import { getSpinnerImage } from 'c/customSpinner';
// Custom Spinner settings

//:TODO - import is failing because of dependency order need to make a util component & move this method
export const updateDisabledOnFieldTokens = ( allFields, fieldsToDisable = [], disabledValue ) => {
  allFields.forEach(field => {
      const fieldKey = field.name ?? field.dataset.id ?? field.dataset.name;
      if(fieldsToDisable.includes(fieldKey?.toLowerCase())){
          field.disabled = disabledValue;
      }
  });
}

export default class AusfFDRecordForm extends LightningElement {
  editAdress = false;
  addinformation = false;
  @api recordId;
  @api applicantId;
  @api loanApplication;

  addressLst = [];
  editRecordId;
  showAddressInsertion = true;
  recordCount;
  @track addressList;
  @track collateralObj = {};
  showMainSection = true;
  isLoaded = false;
  showOfficeLabels = false;
  counter = 0;
  showingwarningIcon = false;
  appId;
  selectedRecords = {};

  _configurations;
  get configurations(){
    return this._configurations;
  }

   // Custom Spinner settings
   async spinnerImageMethod() {
    if(this.spinnerImage == undefined){
        this.spinnerImage = await getSpinnerImage(this.appId);
    }
  }
  // Custom Spinner settings

  @api set configurations(value){
    if(value){
      this._configurations = value;
    }
  }

  get approvalSubmissionStyles(){
    return this.isLoaded ? 'pointer-events: none;' : '';
  }

  connectedCallback() {
    console.log("insideAddressComponent--->");
    this.getApplicants();
  }

  @api
  getApplicants() {
    // console.log('this.applicantId.Id-->' +JSON.stringify(this.applicantId));
    console.log("this.recordId-->" + this.recordId);
    //let appId;
    if (this.recordId != null) {
      this.appId = this.recordId;
    } else {
      this.appId = this.applicantId.Id;
    }
    this.spinnerImageMethod();
    // if (this.applicantId.Id != undefined && this.applicantId.Id!=null) {
    if (this.appId !== undefined && this.appId !== null) {
      getPropertyCollaterals({
        recId: this.appId,
        collateralType:'FD'
      })
        .then((data) => {
          console.log("data is " + JSON.stringify(data));
          this.addressLst = data.propertyCollateralList;
          this.recordCount = data.recCount;
        })
        .catch((error) => {
          console.error("error " + error);
        });
    }
  }

  handleCancelForm() {
    this.addinformation = false;
    this.handleReset();
  }

  handleReset() {
    let obj = {};
    this.collateralObj = obj;
  }

  handleSubmit(event) {
    event.preventDefault();
    const fields = event.detail.fields;
    fields.FD_amount__c = this.collateralObj.FD_amount__c;
    fields.FD_Number__c = this.collateralObj.FD_Number__c;
    fields.Current_Owner_Name__c = this.collateralObj.Current_Owner_Name__c;
    fields.Additional_collateral_valid_till_date__c =
      this.collateralObj.Additional_collateral_valid_till_date__c;

    if (this.isInputValid()) {
      this.template.querySelector("lightning-record-edit-form").submit(fields);
    }
    console.log(
      "onsubmit event recordEditForm" + JSON.stringify(event.detail.fields)
    );
  }
  handleSuccess(event) {
    this.isLoaded = true;
    console.log("onsuccess event recordEditForm", event.detail.id);
    this.showMessage("Record Updated Successfully", "success");
    this.editAdress = false;
    this.showMainSection = true;
    this.addinformation = false;
    this.handleReset();
    this.getApplicants();
    this.isLoaded = false;
  }
  async handleConfirmClick() {
    const result = await LightningConfirm.open({
        message: 'Active FD must be done with AU bank before disbursement.',
        variant: 'headerless',
        label: 'this is the aria-label value',
        // setting theme would have no effect
    });
    console.log('result '+result)
  }

  handleAdditionalInformationClick() {
    this.handleConfirmClick();
    this.handleReset();
    this.addinformation = true;
    this.applyMaterialSettings();
    this.collateralObj.Loan__c = this.appId;
    this.collateralObj.Apportioned_Loan_Amount__c = 1;
    /*GenerateRandomNumber({
      length: 15
    })
      .then((data) => {
        console.log("data is " + JSON.stringify(data));
        this.collateralObj.Collateral_ID__c = data;
        this.collateralObj.Loan__c = this.appId;
        this.collateralObj.Apportioned_Loan_Amount__c = 1;
        console.log(
          "this.collateralObj in apex--" + JSON.stringify(this.collateralObj)
        );
      })
      .catch((error) => {
        console.error("error " + error);
      });*/
    // this.addressApplicationRecord.Applicant__c =  this.applicantId.Id;

    //this.getInitialValues();
    console.log("this.collateralObj--" + JSON.stringify(this.collateralObj));
  }
  showMessage(message, variant) {
    const event = new ShowToastEvent({
      title: "",
      variant: variant,
      mode: variant === 'error' ? 'sticky' : 'dismissible',
      message: message
    });
    this.dispatchEvent(event);
  }

  handleRowAction(event) {
    this.isLoaded = true;
    const recordId = event.currentTarget.dataset.id;
    console.log("recordId " + recordId);
    this.showMainSection = false;
    this.editAdress = true;
    this.editRecordId = recordId;
    this.collateralObj = this.addressLst.find((item) => item.Id === recordId);
    console.log("collateralObj " + JSON.stringify(this.collateralObj));
    this.isLoaded = false;
  }

  isInputValid() {
    let isValid = true;
    let inputFields = this.template.querySelectorAll(".validate");
    inputFields.forEach((inputField) => {
      if (!inputField.value) {
        inputField.setCustomValidity("Complete this field");
        inputField.reportValidity();
        isValid = false;
      }
    });
    return isValid;
  }

  handleRecordUpdateCancel() {
    this.editAdress = false;
    this.showMainSection = true;
  }

  handleValueChange(event) {
    let currentObj = Object.assign({}, this.collateralObj);
    currentObj[event.target.name] = event.target.value;
    this.collateralObj = currentObj;
    console.log(
      "addressApplicationRecord-->" + JSON.stringify(this.collateralObj)
    );
  }

  handleSubmitForm() {
    this.collateralObj.Type_Of_Existing_Collateral__c = "Manual";
    this.collateralObj.Collateral_Type__c = "FD";
    console.log("collateralObj RECORD-->" + JSON.stringify(this.collateralObj));
    if (this.isInputValid()) {
      this.isLoaded = true;
      upsertManualCollateral({ collateral: this.collateralObj })
        .then((address) => {
          console.log("success-->" + JSON.stringify(address));
          this.isLoaded = false;
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Success",
              message: "Collateral created",
              variant: "success"
            })
          );
          this.editAdress = false;
          this.addinformation = false;
          this.showMainSection = true;

          console.log("success1-->" + JSON.stringify(this.applicantId));
          this.getApplicants();
        })
        .catch((error) => {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error creating record",
              message: error.body.message,
              variant: "error",
              mode : 'sticky'
            })
          );
        });
    }
    // }
  }

  async applyMaterialSettings(){
    await Promise.resolve();
    const fieldTokens = this.template.querySelectorAll('lightning-input, lightning-combobox');
    console.log(updateDisabledOnFieldTokens);
    updateDisabledOnFieldTokens([ ...fieldTokens ], this._configurations.materialSettings, true);
  }
}