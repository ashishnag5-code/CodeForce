import { LightningElement, track, api } from 'lwc';
import createFinancialRecords from '@salesforce/apex/financeController.createFinancialRecords';
import { toastWithMessage } from 'c/lwcutilities';

export default class TemplatesBasedOnEmpType extends LightningElement {

  @track renderSalaryTemplate = false;
  @track renderAssessed = false;
  @track renderDocAuditedTemplate = false;
  @track renderWithoutDocAuditedTemplate = false;
  @track renderFarmerTemplate = false;
  @track showOtherIncomeSection = false;
  @track showModal = false;
  @track childrecord = {};
  @track childrecordId;

  @api templateName;
  @api isMobile;
  @api loanId;
  @api currentApplicantId;
  @api applicantFinancialId;
  //@api childRecords
  @track childRecords

  templateType

  @track salariedData=[]
  @track assessedData=[]
  @track auditedData=[]
  @track withoutauditedData =[]
  @track dairy=[]
  @track rcl=[]
  @track ownland=[]
  @track commercial=[]
  @track otherIncome=[]
  


  @api
  setTemplates(templateName, childRecords) {
    this.resetTemplatesBooleanData()
    this.templateType = templateName
    const templateMap = {
      'Salaried_Document': 'renderSalaryTemplate',
      'Assessed_No_Document': 'renderAssessed',
      'Documented_With_Audited_financial': 'renderDocAuditedTemplate',
      'Documented_Without_Audited_financial': 'renderWithoutDocAuditedTemplate',
      'Farmer': 'renderFarmerTemplate',
      'NA': null
    };
    this.childRecords = childRecords
    this.getExistingRecordDetails();
    const templateProp = templateMap[this.templateType];
    if (templateProp !== null) {
      this[templateProp] = true;
    }
    this.showOtherIncomeSection=true
    console.log('renderSalaryTemplate->' + templateProp);
  }

  resetTemplatesBooleanData(){
    this.renderSalaryTemplate = false;
    this.renderAssessed = false;
    this.renderDocAuditedTemplate = false;
    this.renderWithoutDocAuditedTemplate = false;
    this.renderFarmerTemplate = false;
    this.showOtherIncomeSection = false;
  }

  getExistingRecordDetails() {
    if(this.childRecords && this.childRecords.length>0){
      this.childRecords.forEach(input=>{
        let name = input.RecordType.DeveloperName
        if(name == 'Farmer_Agriculture_Own_Land'){
          this.ownland.push(input)
        }else if(name == 'Farmer_Agriculture_Rented_Land'){
          this.rcl.push(input)
        }else if(name == 'Farmer_Commercial'){
          this.commercial.push(input)
        }else if(name == 'Farmer_Dairy_Business'){
          this.dairy.push(input)
        }else if(name == 'Salaried_Document'){
          this.salariedData.push(input)
        }else if(name == 'Assessed_No_Document'){
          this.assessedData.push(input)
        }else if(name == 'Documented_With_Audited_financial'){
          this.auditedData.push(input)
        }else if(name == 'Documented_Without_Audited_financial'){
          this.withoutauditedData.push(input)
        }else if(name == 'Other_Income'){
          this.otherIncome.push(input)
        }
      })
    }
  }

  handleSubmit(event) {
    this.childrecord = event.detail.record;
    this.childrecord.Applicant_Financials__c = this.applicantFinancialId;
    this.childrecord.Applicant__c = this.currentApplicantId;
    console.log('childrecord-->' + JSON.stringify(this.childrecord));
    createFinancialRecords({
      financeRecord: this.childrecord
    })
      .then(financials => {
        console.log('financials-->' + JSON.stringify(financials));
        this.childrecordId = financials;
        toastWithMessage(this, "", "success", "Financial Templates Created Successfully");
        this.dispatchSubmitEvent()
        this.showModal = true
      })
      .catch(error => {
        console.log('error in handleSubmit-->' + error);
      });
  }

  dispatchSubmitEvent() {
    this.dispatchEvent(new CustomEvent('childfinancialsubmit', {
      detail: {
        templateName: this.templateType
      }
    }));
  }

  handleFarmerSubmit(event) {
    this.dispatchSubmitEvent()
  }

  handleDeleteRecord(event){
    this.dispatchSubmitEvent();
  }
}