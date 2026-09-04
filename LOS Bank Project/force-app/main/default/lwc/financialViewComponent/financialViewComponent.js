import { LightningElement,api, track, wire } from 'lwc';
import getBankRecords from '@salesforce/apex/financeController.getBankRecords';
import getPremiumMetadata from '@salesforce/apex/financeController.getPremiumMetadata';
import getBureauResults from '@salesforce/apex/financeController.getBureauResults'
import getVisibleFields from '@salesforce/apex/financeController.getVisibleFields';
import getEmploymentType from '@salesforce/apex/financeController.getEmploymentType';
import getRelatedAddress from '@salesforce/apex/financeController.getRelatedAddress'
import FINANCIAL_OBJECT from '@salesforce/schema/Applicant_Financials_Details__c';
import ID_FIELD from '@salesforce/schema/Applicant__c.Id'; 
import FINCSGRADE_FIELD from '@salesforce/schema/Applicant_Financials_Details__c.Customer_Grade__c';
import FINID_FIELD from '@salesforce/schema/Applicant_Financials_Details__c.Id';
import FINEMP_FIELD from '@salesforce/schema/Applicant_Financials_Details__c.Type_Of_Employment__c';
import createFinancialRecords from '@salesforce/apex/financeController.createFinancialRecords';
import getFinancials from '@salesforce/apex/financeController.getFinancials';
import getFinancialChildDetails from '@salesforce/apex/financeController.getFinancialChildDetails';
import upsertIncome from '@salesforce/apex/AgricultureIncomeDetailsController.upsertIncome';
import getParentFinancialRecord from '@salesforce/apex/AgricultureIncomeDetailsController.getParentFinancialRecord';
import deactivateChildFinancials from '@salesforce/apex/financeController.deactivateChildFinancials';
import getProfilingMaster from '@salesforce/apex/financeController.getProfilingMaster';
import getRelatedProfilingMaster from '@salesforce/apex/financeController.getRelatedProfilingMaster';
import { createRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi'
import getApplicants from '@salesforce/apex/financeController.getApplicants';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getSummaryDetails from '@salesforce/apex/financeSummaryClass.getSummaryDetails';
import getCompanyCode from '@salesforce/apex/financeController.getCompanyCode'; 
import { loadStyle } from 'lightning/platformResourceLoader';
import opsAccordion from '@salesforce/resourceUrl/opsAccordion';
import FORM_FACTOR from '@salesforce/client/formFactor';
import getApplicantRiskCategory from '@salesforce/apex/financeController.getRiskCategoryBasedOnRiskIdentification';
import APPLICANT_2W_RISK_CATEGORY from '@salesforce/schema/Applicant__c.X2W_Risk_Category__c';
import APPLICANT_4W_RISK_CATEGORY from '@salesforce/schema/Applicant__c.X4W_Risk_Category__c';
import APPLICANT_RISK from '@salesforce/schema/Applicant__c.Risk_Category__c';
import checkMaterialFields from '@salesforce/apex/Utility.checkMaterialFields';
import getMaterialFields from '@salesforce/apex/Utility.getMaterialFields';
import applicantEmploymentUpdation from '@salesforce/apex/financeController.applicantEmploymentUpdation';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import validateAddressInfoJS from '@salesforce/apex/financeController.validateAddressInfo';
import CSGRADE_FIELD from '@salesforce/schema/Applicant__c.Customer_Grade__c';

import {createMessageContext,publish} from 'lightning/messageService'; // 24 JUL
import pageRefreshOnMaterialFieldChange from '@salesforce/messageChannel/RefreshOnMaterialFieldChange__c'; //24 JUL

export default class FinancialViewComponent extends LightningElement {

    //API Attributes
    @api financeId;
    @api key;
    @api showForm;
    @api setReadOnly;
    @api loanId;
    @api accessKey;
    @api memberid;
    @api applicantsData;
    @api applicantTypes;
    @api spinnerImage;
    initialTemplateName;
    monthlyCheck = false;
    monthlyCheck1 = false; //used for 2524 bug monthly obligation
    bankStatementUploaded = false;
    @track showEditViewChildTemplates = false;
    @track showChildTemplates = false;
    showUploadStatement = false
    isAuemployee = false;
    disableUpload = false
    @track renderOtherTemplate = false;
    showUploadFiles = false;
    populateData = false;
    @track showModal = false;
    isCompanyReadOnly = false;
    parentFinancePresent = false;
    @track renderSalaryTemplate = false;
    @track renderAssessedNoDocTemplate = false;
    @track renderDocAuditedTemplate = false;
    @track renderWithoutDocAuditedTemplate = false;
    isLoading = false;
    @track showViewForm = false;
    spouseName = '';
    readAttribute = false;
    readAlways = false;
    boolTwoWheeler = false;
    showDDEDependentFields = false;
    boolFourWheeler = false;
    editFinancials = false;
    showIndividualSave = false;
    renderAssessed = false;
    isNewDetails = true;
    showExistingdetails = false;
    isChildEditRecordsPresent = false;
    hideIncomeElgibility = false;
    allowEmploymentEditable = false;
    showSummary = false;
    incomeElgibilityDisable = false;
    isCompanyRequired = false;
    isDDE = false;
    isMainPicklistChanged = false;
    isCBSCheck = false;
    isCasaCheck = false;
    isETRCheck = false;
    isDPDCheck = false;
    isSalaried = false;
    monthlyIncomeCheck = false;
    showWorkExperienceField = true;
    applcntRecord = {};
    cartDataFetchInitialValue;
    financialParentId;
    loanStage;
    monthlyObligation;
    proposedEmi;
    salariedData = [];
    assessedData = [];
    auditedData = [];
    other = [];
    withoutauditedData = [];
    intialRecord;
    errorOnChild;
    cartMonthlyIncomeData;
    fetchDetails;
    childRecordfinancialId;
    onclickParentFinancialData;
    financialsData;
    memberDetailsValue;
    selectedApplicant;
    elgibityVal;
    applicantFinancialId;
    @track applicantId;
    commercial;
    ownland;
    dairy;
    rcl;
    childrecord;
    childrecordId;
    renderedTemplate;
    assesmentVal = '';
    @track typeofEmployment = '';
    @track methodofAssesment = '';
    templateName = '';
    strentityType = '';
    gradeValue = '';
    @track sectorEditValue = '';
    @track industryEditValue = '';
    @track subIndustryEditValue = '';
    @track occupationEditValue = '';
    @track OnChange = false;
    selectedapplicantType = '';
    @track employmentEditVal = '';
    @track employmentValue = '';
    @track assesmentEditVal = '';
    obligationHelpText = '';
    companyOptionsValue = '';
    companyDefaultId='';
    maritalStatus='';
    gender='';
    riskIdentified='';
    monthlyEditIncome=0;
    verifiedEditIncome =0;
    monthlyObligationEditIncome =0;
    otherEditIncome  = 0;
    @track isEditRestricted=false
    activeSections = ['A', 'B'];
    activeSubSections = ['B', 'C','D']
    profileMasterData = [];
    financialRecord = {};
    assesmentOptions = [];
    elgibilityOptions = [];
    employmentOptions = [];
    sectorOptions = [];
    industryOptions = [];
    subIndustryOptions = [];
    occupationOptions = [];
    gradeOptions = [];
    workExperienceOptions =[];
    profilingData=[];
    itemList = [{
        id: 0
    }];
    applicantsSummaryData;
    monthlyVal;
    loanAmount = 0;
    keyIndex = 0;
    exCustLiabilityMinRelationship = 0;
    exCustLiabilityEmiMultiplier = 0;
    exCustLiabilityMinCredit = 0;
    exCustLiabilityCreditCheck = 0;
    existingCBSLoanAmount = 0;
    existingCIBILLoanAmount = 0;
    existingLatestCIBILLoanAmount = 0;
    checklistMetadata;
    exCustLoanPercentage = 0;
    exCustMinRelationship = 0;
    autoloanMinPerc = 0;
    autoloanCIBILMinScore = 0;
    autolaonCIBILDefaultScore = 0;
    cibilloanCIBILMinScore = 0;
    cibilDPD = 0;
    cibilloanMinPerc = 0;
    loanCIBILScore = 0;
    selfEmpCIBILMinScore = 0;
    selfEmpCIBILDefScore = 0;
    selfEmpMinITR = 0;
    selfEmpMinAmountPerITR = 0;
    selfEmpFilingGap = 0;
    selfEmpEmiMultipler = 0;
    bankCIBILMinScore = 0;
    bankCIBILDefScore = 0;
    bankValidCompany;
    bankEmiMultiplier = 0;
    bankJobStability = 0;
    lfarmerCIBILMinScore = 0;
    lfarmerCIBILDefScore = 0;
    lfarmerMinBigha = 0;
    lfarmerMaxLoanAmt = 0;
    dfarmerCIBILMinScore = 0;
    dfarmerCIBILDefScore = 0;
    dfarmerMinNoCattle = 0;
    monthTotal = 0;
    inputMonthlyObligation;
    bureauObligation = 0;
    otherIncomeTotal = 0;
    verifiedIncomeTotal = 0;
    sixMonthAverageBalance = 0;
    @track totalWorkExperience;
    isMobile =false;
    @track docVerified = false;
    unEmployedDisableCheck = false;
    breTrackingFieldList=[];
    selectedApplicantData;
    isCompanyOther = false;
    othCompName='';
    isAUEmployee;
    isPhsicallyChallenged;
    disableTitle;
    spousNameRequired;
    otherIncomeReadOnly= false; //JUL21
    messageContext = createMessageContext(); //JUL 24
    loanLAN='';//SFAU-4066
    connectedCallback() {
        this.loadOptions();
        this.loadWorkOptions();
    }

    loadStyles() {
        loadStyle(this, opsAccordion);
    }
    setFormFactor() {
        switch (FORM_FACTOR) {
            case 'Large': {
                this.isMobile = false;
                break;
            }
            case 'Medium': {
                this.isMobile = true;
                break;
            }
            case 'Small': {
                this.isMobile = true;
                break;
            }
        }
    }

    renderedCallback(){
        this.loadStyles();
        this.setFormFactor();
    }

    loadOptions() {
        let elOptions = [];
        // let cusGradeOptions = [];
        //Assigning Elgibility Options
        elOptions.push({
            label: 'Yes',
            value: 'Yes'
        });
        elOptions.push({
            label: 'No',
            value: 'No'
        });

        this.elgibilityOptions = elOptions;
    }
    loadWorkOptions(){
        let options=[];
        options.push({
            label: '0 - 6 Months',
            value: '6'
        });
        
        options.push({
            label: '6 months to 1 years',
            value: '12'
        });
        options.push({
            label: '1 - 2 Year',
            value: '24'
        });
        options.push({
            label: '2 - 5 Year',
            value: '60'
        });
        options.push({
            label: '5+ Year',
            value: '61'
        });
        this.workExperienceOptions = options;
    }

    @api
    renderValues(selectedId) {
        this.isCompanyOther = false;
        this.readAlways = false;
        this.readAttribute = false;//JUL 24
        this.handleInitialAttributes(); //jul6
        this.financialRecord.Applicant__c = selectedId;
        this.applicantId = selectedId;
        this.getInitialData();
        this.getLoadDetails(selectedId);
        this.getApplicantSummaryData();
        this.showViewForm = true;
        this.OnChange = false;
        this.handleChildTemplatesReset();//12 Jul
        if(this.template.querySelector('c-bank-statement-upload-financials')!=undefined){ // SFAU-4275
            this.template.querySelector('c-bank-statement-upload-financials').handleClose(); 
        } //End
        
    }
    @api 
    renderValuesPredefined(selectedId, applicantData){
        this.boolTwoWheeler = (applicantData[0].Loan__r.RecordType.Name == 'Two Wheeler');
        this.applicantsData = applicantData;
        this.loanStage  =  applicantData[0].Loan__r.Stage__c;
        this.loanLAN = applicantData[0].Loan__r.LAN__c!=null ? applicantData[0].Loan__r.LAN__c :'';
        this.spouseName = applicantData[0].Spouse_Name__c;
        this.renderValues(selectedId);
    }
    handleInitialAttributes(){
        this.typeofEmployment = null;
        this.methodofAssesment = null;
        this.totalWorkExperience =null;
        this.employmentEditVal =null;
        this.assesmentEditVal =null;
        this.assesmentOptions=[];
        this.employmentOptions=[];
    }

    getTwoWheelerPicklistValues(selectedId) {
        getProfilingMaster({
                applicantId: selectedId
            }).then(data => {
                let options = [];
                for (var key in data) {
                    options.push({
                        label: data[key].Name,
                        value: data[key].Name
                    });
                }
                options.sort((a, b) => a.label.localeCompare(b.label)); //SFAU-2786
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
            })
    }


    getLoadDetails(applId) {
        this.isLoading = true;
        this.getBureauData(applId);
        // Method to get the premium check list custom metadata records
        getPremiumMetadata()
            .then(result => {
                this.checklistMetadata = result;
                this.loadMetadataMappings(this.checklistMetadata);
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
            })
    }

    loadMetadataMappings(checklist) {
        for (var key in checklist) {
            if (checklist[key].Type__c == 'Exisiting Cust Asset') {
                if (checklist[key].Name__c == 'Min Proposed Loan Percentage') {
                    this.exCustLoanPercentage = parseFloat(checklist[key].Value__c);
                }
                if (checklist[key].Name__c == 'Min Relationship') {
                    this.exCustMinRelationship = parseFloat(checklist[key].Value__c);
                }
            }
            if (checklist[key].Type__c == 'Exisiting Cust Libilities') {
                if (checklist[key].Name__c == 'EMI Multiplier') {
                    this.exCustLiabilityEmiMultiplier = parseFloat(checklist[key].Value__c);
                }
                if (checklist[key].Name__c == 'Min Relationship') {
                    this.exCustLiabilityMinRelationship = parseFloat(checklist[key].Value__c);
                }
                if (checklist[key].Name__c == 'Minimum Credit Entry') {
                    this.exCustLiabilityMinCredit = parseFloat(checklist[key].Value__c);
                }
                if (checklist[key].Name__c == 'Max Month for Credit Entry Check') {
                    this.exCustLiabilityCreditCheck = parseFloat(checklist[key].Value__c);
                }
            }

            if (checklist[key].Type__c == 'Auto loan Customer') {
                if (checklist[key].Name__c == 'Min Proposed loan percentage') {
                    this.autoloanMinPerc = checklist[key].Value__c;
                }
                if (checklist[key].Name__c == 'CIBIL Min Score') {
                    this.autoloanCIBILMinScore = checklist[key].Value__c; //700
                }
                if (checklist[key].Name__c == 'CIBIL Default Score') {
                    this.autolaonCIBILDefaultScore = checklist[key].Value__c;
                }
            }
            if (checklist[key].Type__c == 'CIBIL') {
                if (checklist[key].Name__c == 'Min Proposed loan percentage') {
                    this.cibilloanMinPerc = checklist[key].Value__c;
                }
                if (checklist[key].Name__c == 'CIBIL Min Score') {
                    this.cibilloanCIBILMinScore = parseFloat(checklist[key].Value__c);
                }
                if (checklist[key].Name__c == 'DPD Min Month') {
                    this.cibilDPD = parseFloat(checklist[key].Value__c);
                }
            }
            if (checklist[key].Type__c == 'Self Emp') {
                if (checklist[key].Name__c == 'CIBIL Min Score') {
                    this.selfEmpCIBILMinScore = checklist[key].Value__c;
                }
                if (checklist[key].Name__c == 'CIBIL Default Score') {
                    this.selfEmpCIBILDefScore = checklist[key].Value__c;
                }
                if (checklist[key].Name__c == 'Min ITR') {
                    this.selfEmpMinITR = checklist[key].Value__c;
                }
                if (checklist[key].Name__c == 'Min Amount per ITR') {
                    this.selfEmpMinAmountPerITR = checklist[key].Value__c;
                }
                if (checklist[key].Name__c == 'Filling Gap') {
                    this.selfEmpFilingGap = checklist[key].Value__c;
                }
                if (checklist[key].Name__c == 'EMI Multiplier') {
                    this.selfEmpEmiMultipler = parseFloat(checklist[key].Value__c);
                }
            }

            if (checklist[key].Type__c == 'Bank salaried') {
                if (checklist[key].Name__c == 'CIBIL Min Score') {
                    this.bankCIBILMinScore = checklist[key].Value__c;
                }
                if (checklist[key].Name__c == 'CIBIL Default Score') {
                    this.bankCIBILDefScore = checklist[key].Value__c;
                }
                if (checklist[key].Name__c == 'Valid Company') {
                    this.bankValidCompany = checklist[key].Value__c;
                }
                if (checklist[key].Name__c == 'EMI Multiplier') {
                    this.bankEmiMultiplier = checklist[key].Value__c;
                }
                if (checklist[key].Name__c == 'Job stability') {
                    this.bankJobStability = checklist[key].Value__c;
                }

            }
            if (checklist[key].Type__c == 'Large Farmer') {
                if (checklist[key].Name__c == 'CIBIL Min Score') {
                    this.lfarmerCIBILMinScore = checklist[key].Value__c;
                }
                if (checklist[key].Name__c == 'CIBIL Default Score') {
                    this.lfarmerCIBILDefScore = checklist[key].Value__c;
                }
                if (checklist[key].Name__c == 'Max Loan Amount') {
                    this.lfarmerMaxLoanAmt = checklist[key].Value__c;
                }
                if (checklist[key].Name__c == 'Minimum Bigha') {
                    this.lfarmerMinBigha = checklist[key].Value__c;
                }
            }
        }
        // Call the Bank Details Method
        this.getBankDetails(this.applicantId);
    }

    getBankDetails(applId) {
        this.isLoading = true;
        getBankRecords({
                applicantId: applId,
                accountType: 'Loan',
                minRelationship: 12
            }).then(result => {
                this.isCBSCheck = result.isCBSCheck
                this.isDPDCheck = result.isDPDCheck;
                this.isCasaCheck = result.isCasaCheck;
                this.sixMonthAverageBalance = (result.sixMonthAvgBalance != undefined) ? result.sixMonthAvgBalance : 0;
                this.isETRCheck = result.isETRCheck;
                this.existingCBSLoanAmount = result.cbsLoanAmount;
                this.existingCIBILLoanAmount = result.cibilLoanAmount;
                this.existingLatestCIBILLoanAmount = result.cibilLatestLoanAmount;
                if (result.monthlyObligation != 0) {
                    this.inputMonthlyObligation = result.monthlyObligation;
                    this.monthlyCheck1 = true;
                }else{
                    this.inputMonthlyObligation  =0;
                    this.monthlyCheck1 = false;
                }
                this.bureauObligation = result.monthlyObligation;
                this.isLoading = false;
                this.getExistingApplicantFinancials(this.memberid);
            })
            .catch(error => {
                this.isLoading = false;
            })
    }

    getExistingApplicantFinancials(applId) {
        this.isLoading = true;
        let data = this.applicantsData; // all Applicants Data
        if (data != null && data != '' && data != undefined) {
            for (var key in data) {
                if (data[key].Id == applId) {
                    if (data[key].AU_Employee__c == 'Yes') {
                        this.isAuemployee = true;
                    }
                    let product = data[key].Loan__r.Product__c;
                    this.loanStage = data[key].Loan__r.Stage__c;
                    this.loanAmount = data[key].Total_Loan_Amount__c;
                    this.proposedEmi = data[key].Loan__r.EMI__c;
                    let customerType = data[key].Customer_Type__c;
                    if (this.loanStage != 'QDE') {
                        this.bankStatementUploaded = true;//SFAU-4931
                        this.showDDEDependentFields = true;
                        this.monthlyIncomeCheck = true; //July3
                        this.isDDE = true;
                        this.obligationHelpText = 'From RTR + Exposure ' + this.bureauObligation;
                    } else {
                        this.showDDEDependentFields = false;
                        this.monthlyIncomeCheck = false;
                    }
                    if (product == '10301' || product == '10302' || product == '10303') {
                        this.getVisibleFieldsMetadata('Income Parent Two Wheeler', 'QDE');
                        this.boolTwoWheeler = true;
                        this.showDDEDependentFields = true;
                        if (this.boolTwoWheeler == true) {
                            if (customerType == 'Individual') {
                                if (this.loanAmount < 500000) {
                                    this.handleDisableMoreIncome();
                                    this.showIndividualSave = true;
                                    this.monthlyCheck = true;
                                }
                                if (this.loanAmount >= 500000) {
                                    this.showIndividualSave = false;
                                }
                            }
                            if (customerType == 'Non Individual') {
                                this.showIndividualSave = false;
                            }
                            this.handleBankStatementGradeLogic();
                        }
                    } else {
                        this.boolFourWheeler = true;
                        if (this.loanStage == 'QDE') {
                            this.showIndividualSave = true;
                            this.monthlyCheck = true;
                            this.getVisibleFieldsMetadata('Income Parent', 'QDE');
                        } else if (this.loanStage != 'QDE') {
                            this.showIndividualSave = false;
                            this.getVisibleFieldsMetadata('Income Parent DDE', 'DDE');
                        }
                        this.handleDisableMoreIncome();
                    }
                    this.handleCustomerGradeOptions();
                    
                    const loanAmt = parseFloat(this.loanAmount);
                    if (data[key].Existing_Customer__c == 'Yes') {
                        const existingAmt = this.existingCBSLoanAmount;
                        const minloanPerc = this.exCustLoanPercentage; //50%
                        const percAmt = minloanPerc * (loanAmt / 100);
                        if ((existingAmt >= percAmt) && (this.isCBSCheck == true)) {
                            this.gradeValue = 'Premium';
                        }
                        if (this.isCasaCheck == true) {
                            this.gradeValue = 'Premium';
                        }
                    }
                    if (data[key].Existing_Customer__c != 'Yes') {
                        const cibilAmt = this.existingCIBILLoanAmount;
                        const cibilLatestAmt = this.existingLatestCIBILLoanAmount;
                        const autoloanPerAmt = this.autoloanMinPerc * (loanAmt / 100);
                        const cibilloanPerAmt = this.cibilloanMinPerc * (loanAmt / 100);
                        if (cibilAmt >= autoloanPerAmt) {
                            if (this.isETRCheck == true) {
                                if (this.loanCIBILScore >= this.autoloanCIBILMinScore || this.loanCIBILScore == this.autolaonCIBILDefaultScore) {
                                    this.gradeValue = 'Premium';
                                }
                            }
                        }
                        if (cibilLatestAmt >= cibilloanPerAmt) { // Score Based Pending one only-higher one?), No DPD(Defaulters: CIBIL)(to check) in last 6 month in live loan and closed account(which account?) not more than 6 month (existing loan - PL/BL/HL/Auto Loan/CV/CE/Two-Wheeler/CD)
                            if (this.isDPDCheck == true) {
                                if (this.loanCIBILScore >= this.cibilloanCIBILMinScore) {
                                    this.gradeValue = 'Premium';
                                }
                            }
                        }
                    }
                }
            }
        }
        // AU Employee Check
        if (this.isAuemployee == true) {
            this.elgibityVal = 'Yes';
            this.incomeElgibilityDisable = false;
            this.handleAUCalculations();
        } else {
            this.readAlways = false;
        }
        if (this.boolTwoWheeler == true || this.showDDEDependentFields == true) {
            this.getTwoWheelerPicklistValues(applId);
        }
        this.getApplicantsData(applId);
        if (this.loanStage == 'DDE') {
            if (this.boolTwoWheeler == true && this.loanAmount > 500000) { // Company Required Logic
                this.isCompanyRequired = true;
            }
        }
        this.isLoading = false;
    }

    handleCustomerGradeOptions() {

        let cusGradeOptions = [];
        cusGradeOptions.push({
            label: 'IB',
            value: 'IB'
        });
        cusGradeOptions.push({
            label: 'NIB',
            value: 'NIB'
        });

        if (this.boolTwoWheeler == true) {
            cusGradeOptions.push({
                label: 'CIBIL Surrogate',
                value: 'CIBIL Surrogate'
            });
            cusGradeOptions.push({
                label: 'Banking Surrogate',
                value: 'Banking Surrogate'
            });
        } else if (this.boolFourWheeler == true) {
            cusGradeOptions.push({
                label: 'Premium',
                value: 'Premium'
            });
        }
        this.gradeOptions = cusGradeOptions;
    }

    getApplicantsData(applId) {
        getApplicants({
                applicantId: applId
            })
            .then(data => {
                if (data) {
                    this.selectedApplicantData = data[0];
                    this.selectedapplicantType = data[0].RecordType.Name;
                    this.maritalStatus =  data[0].Marital_Status__c;
                    this.verifiedEditIncome = data[0].Loan__r.Total_Verified_Income__c?data[0].Loan__r.Total_Verified_Income__c:0
                    this.verifiedIncomeTotal = this.verifiedEditIncome
                    this.docVerified = data[0].Financial_Details_Fetched_from_BSA__c //Neha-3838
                    this.cartDataFetchInitialValue=data[0].Financial_Details_Fetched_from_BSA__c
                    this.gender =  data[0].Gender__c;
                        if (this.selectedapplicantType == 'Applicant') {
                            this.incomeElgibilityDisable = true;
                            if(this.isAuemployee == true){ //13 JUl
                                this.incomeElgibilityDisable = false;
                            }
                        
                        } else if (this.selectedapplicantType == 'Co-Applicant') {
                            this.incomeElgibilityDisable = false;
                            this.elgibityVal = 'Yes';
                        }
                  
                    if ((this.selectedapplicantType == 'Guarantor') || (this.selectedapplicantType == 'BO')) {
                        this.elgibityVal = 'No';
                        if( this.showExistingdetails == false){
                            this.showIndividualSave = true;
                        }
                        this.incomeElgibilityDisable = false;
                    }
                }
            })
            .catch(error => {
            })
    }

    getBureauData(applId) {
        this.isLoading = true;
        getBureauResults({
                applicantId: applId
            })
            .then(result => {
                this.loanCIBILScore = result;
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
            })
    }

    handleAUCalculations() {
        this.readAlways = true;
        this.cmpValue = 'AU Small Finance Bank';
        this.companyName =  'AU Small Finance Bank';
        this.companyOptionsValue = 'AU Small Finance Bank';
        this.employmentEditVal = 'Salaried - Private';
        this.financialRecord.Company_Name__c = this.cmpValue;
        let options1 = [];
        options1.push({
            label: 'Salaried - Private',
            value: 'Salaried - Private'
        });
        this.employmentOptions = options1;
        this.employmentValue = 'Salaried - Private';
        let options = [];
        options.push({
            label: 'Salaried',
            value: 'Salaried'
        });
        this.assesmentOptions = options;
        this.assesmentVal = 'Salaried';
        this.assesmentEditVal = 'Salaried'; //JUL24
        this.templateName = 'Salaried_Document';
        this.isCompanyReadOnly = true;
        this.showDDEDependentFields = false;
        if (this.templateName == 'Salaried_Document') {
            this.showUploadStatement = true;
        } else {
            this.showUploadStatement = false;
        }
    }
    getVisibleFieldsMetadata(screenName, stageVal) {
        this.isLoading = true;
        getVisibleFields({
                strScreen: screenName,
                Stage: stageVal
            })
            .then(result => {
                result.forEach(input => {
                    this.template.querySelector('[data-id="' + input + '"]').classList.remove('slds-hide');
                });
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
            })
    }

    getInitialData() {
        this.isLoading = true;
        getFinancials({
                applicantId: this.applicantId
            })
            .then(result => {
                this.financialsData = result;
                if (this.financialsData != null && this.financialsData != '' && this.financialsData != undefined) {
                    this.showExistingdetails = true;
                    this.isNewDetails = false;
                    this.handleDisableMoreIncome();
                } else {
                    this.showExistingdetails = false;
                    this.isNewDetails = true;
                }
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
            })

        this.selectedApplicant = this.applicantId;
        let applicants = this.applicantsData;
        for (var key in applicants) {
            if (applicants[key].Id == this.applicantId) {
                let customerType = applicants[key].Customer_Type__c;
                this.strentityType = customerType;
            }
        }
        if (this.strentityType != '') {
            this.getIncomeProfileMasterData(this.strentityType);
        }

    }
    getIncomeProfileMasterData(etype) {
        this.isLoading = true;
        getEmploymentType({
                entityType: etype
            })
            .then(data => {
                this.profileMasterData = data;
                let options = [];
                let oparray = [];

                for (var key in data) {
                    let emp = data[key].Type_of_Employment__c;
                    if (!oparray.includes(emp)) {
                        oparray.push(data[key].Type_of_Employment__c);
                        options.push({
                            label: data[key].Type_of_Employment__c,
                            value: data[key].Type_of_Employment__c
                        });
                    }
                }
                options.sort((a, b) => a.label.localeCompare(b.label)); //SFAU-2786
                this.employmentOptions = options;
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
            })
    }

    setDocVerified(value){
        this.docVerified=value
    }

    handleChange(event) {
        this.OnChange = true;
        let record = this.profileMasterData;
        let picklistName = event.target.name;
        let picklistValue = event.target.value;
        let options = [];

        if (picklistName == 'Type_Of_Employment__c') { // now we need to pass the sector name and name of the picklist to get as options
            this.handlegetRelatedPicklistValues(picklistName, picklistValue, 'RT - Employment Type', 'RT - Sector','');
            this.employmentEditVal = picklistValue;
        }
        if (picklistName == 'Sector__c') { // now we need to pass the sector name and name of the picklist to get as options
            let queryParams = this.employmentEditVal;
            this.handlegetRelatedPicklistValues(picklistName, picklistValue, 'RT - Sector', 'RT - Industry',queryParams);
            this.sectorEditValue = picklistValue;
        }
        if (picklistName == 'Industry__c') {
            let queryParams = this.employmentEditVal + '~' + this.sectorEditValue;
            this.handlegetRelatedPicklistValues(picklistName, picklistValue, 'RT - Industry', 'RT - Sub Industry',queryParams);
            this.industryEditValue = picklistValue;
        }
        if (picklistName == 'Sub_Industry__c') {
            let queryParams = this.employmentEditVal + '~' + this.sectorEditValue + '~' + this.industryEditValue;
            this.handlegetRelatedPicklistValues(picklistName, picklistValue, 'RT - Sub Industry', 'RT - Occupation',queryParams);
            this.subIndustryEditValue = picklistValue;
        }
        
        if (picklistName == 'Occupation__c') {
            let queryParams = this.employmentEditVal + '~' + this.sectorEditValue + '~' + this.industryEditValue + '~' + this.subIndustryEditValue;
            this.handlegetRelatedPicklistValues(picklistName, picklistValue, 'RT - Occupation', 'RT - Employment Type',queryParams);
            this.occupationEditValue = picklistValue;
            //SFAU-3555
           if(this.customerType =='Non Individual'){    
                let masterData = this.profilingData;
                for (var key in masterData){
                 if(masterData[key].Name == 'Business' && masterData[key].Sector__r.Name == this.sectorEditValue && masterData[key].Industry__r.Name == this.industryEditValue &&  masterData[key].Sub_Industry__r.Name == this.subIndustryEditValue){ // &&  masterData[key].RecordType.Name == 'RT - Employment' 
                    this.riskIdentified = masterData[key].Risk__c;
                }
               }
               if(this.selectedApplicantData.Loan__r.RecordType.Name=='Four Wheeler'){
                    if(this.selectedApplicant.Politically_Exposed_Person__c=='Yes'){
                        this.riskIdentified = 'High';
                    }
               }
                this.handleApplicantRisk();
            }
        }
        if ((picklistName != 'Member')) {
            this.financialRecord[event.target.name] = event.target.value;
        }

        if (picklistName == 'Occupation__c' || picklistName == 'Type_Of_Employment__c') {
            this.breTrackingFieldList.push('Type_Of_Employment__c');
            this.typeofEmployment = this.employmentEditVal;
            if(this.typeofEmployment == 'Salaried - Private' || this.typeofEmployment =='Salaried - Government'){
                this.isSalaried = true;
                if( this.loanStage!='QDE'){
                    this.monthlyIncomeCheck = true; //JUL21         
                }
            }else{
                this.isSalaried = false;
                this.isCompanyOther = false;
            }
            if(this.typeofEmployment == 'Salaried - Private' || this.typeofEmployment =='Salaried - Government'|| this.typeofEmployment =='Self Employed Non-Professional' || this.typeofEmployment == 'Self Employed Professional' || this.typeofEmployment =='Business'  ){
                this.showWorkExperienceField =true;
            }else{
                this.showWorkExperienceField =false;
                this.financialRecord.Total_Work_Experience__c ='0';
            }
            this.isMainPicklistChanged = true; //used for deactivating the child
          //  if (this.allowEmploymentEditable == true) {
                this.employmentEditValue = this.typeofEmployment;
          //  }
            this.showUploadStatement = false;
            //if its applicant and house wife consider for income can me made as no
            if(this.selectedapplicantType == 'Applicant'){
                if(this.typeofEmployment == 'Housewife'){
                this.incomeElgibilityDisable = false;
                }else{
                    this.incomeElgibilityDisable = true;
                    this.elgibityVal = 'Yes';
                }
            }
            //End
             //Company Name Disable if we Select House Wife for Applicant/Co-Applicant for SFAU-2626 and 
            // if(this.selectedapplicantType == 'Applicant' || this.selectedapplicantType == 'Co-Applicant' || this.selectedapplicantType == 'BO' || this.selectedapplicantType =='Guarantor' || this.selectedapplicantType =='Non Individual'){
                if(this.typeofEmployment == 'Housewife' || this.typeofEmployment == 'Unemployed'){ // SFAU -2699
                    this.isCompanyReadOnly = true;
                }else{
                    this.isCompanyReadOnly = false;
                }
           // }
            //End 
            // UnEmployed Conditions Check - SFAU-2699
            if(this.typeofEmployment == 'Unemployed'){ //
                this.unEmployedDisableCheck = true;
                this.financialRecord.Monthly_Income__c =0;
            }else{
                this.unEmployedDisableCheck = false;
            }
            //END 
            //SFAU -2470 and SFAU-2481
           // if(this.selectedapplicantType == 'Applicant' || this.selectedapplicantType =='Co-Applicant' || this.selectedapplicantType =='Guarantor' ){
                if(this.typeofEmployment == 'Housewife' || this.typeofEmployment == 'Unemployed' || this.typeofEmployment == 'Retired - Non-Pensioner'){
                    this.elgibityVal ='No';
                    this.showIndividualSave = true;
                    this.breTrackingFieldList.push('Consider_Income_for_Eligibility__c'); //SFAU-3616
                }else{
                    this.elgibityVal ='Yes';
                    if( (this.loanStage !='QDE') || ((this.loanStage == 'QDE') && (this.boolTwoWheeler == true && this.loanAmount > 500000)) ){
                    this.showIndividualSave = false;
                    }
                    this.breTrackingFieldList.push('Consider_Income_for_Eligibility__c');//SFAU-3616
                }
            //}
            //END SFAU -2470
            for (var key in record) {
                if (record[key].Type_of_Employment__c == this.typeofEmployment) {
                    options.push({
                        label: record[key].Method_Assesment__c,
                        value: record[key].Method_Assesment__c
                    });
                }
            }
             //SFAU-3555 
            //if(this.customerType =='Individual'){
                let masterData = this.profilingData;
                 for (var key in masterData){
                     if( masterData[key].Name == this.typeofEmployment ){ 
                        this.riskIdentified = masterData[key].Risk__c;
                    }
                }
                if(this.selectedApplicantData.Loan__r.RecordType.Name=='Four Wheeler'){
                    if(this.selectedApplicantData?.High_risk_Profile__c?.includes('Politician')){
                        this.riskIdentified = 'High';
                    }
                    else{
                        for (var key in masterData){
                            if(masterData[key].Name == this.typeofEmployment && masterData[key].RecordType.Name == 'RT - Employment Type' && masterData[key].Sector__r.Name == this.sectorEditValue && masterData[key].Industry__r.Name == this.industryEditValue &&  masterData[key].Sub_Industry__r.Name == this.subIndustryEditValue){ 
                                this.riskIdentified = masterData[key].Risk__c;
                            }
                        }
                    }
                }
               this.handleApplicantRisk();
          //  }
            //END
            this.assesmentOptions = this.getUniqueValue(options);
              if (this.assesmentOptions.length == 1) {
                this.assesmentVal = options[0].value;
                this.isMainPicklistChanged = true; //used for deactivating the child
                this.methodofAssesment = options[0].value;
                this.financialRecord['Method_Of_Assesment__c'] = options[0].value;
                this.assesmentEditVal = options[0].value;
           
                for (var key in record) {
                if (record[key].Type_of_Employment__c == this.typeofEmployment && record[key].Method_Assesment__c == this.methodofAssesment) {
                    this.templateName = record[key].Financial_Template__c;
                }
                }
                this.initialTemplateName=this.templateName;//4733
                
                if (options[0].value == 'Salaried') {
                this.showUploadStatement = true
                }
                } //END
                let grade = this.gradeValue;
                this.handleUpdateApplicantValues(grade);
            }

        if (picklistName == 'Method_Of_Assesment__c') {
            this.breTrackingFieldList.push('Method_Of_Assesment__c');
            this.isMainPicklistChanged = true; //used for deactivating the child
            this.methodofAssesment = picklistValue;
            this.assesmentVal = picklistValue;//24Jul
          //  if (this.allowEmploymentEditable == true) {
                this.assesmentEditVal = picklistValue;
          //  }
            for (var key in record) {
                if (record[key].Type_of_Employment__c == this.typeofEmployment && record[key].Method_Assesment__c == this.methodofAssesment) {
                    this.templateName = record[key].Financial_Template__c;
                }
            }
            //this.renderFinanceTemplate();
            
            if (picklistValue == 'Salaried') {
                this.showUploadStatement = true
            }
            if(this.loanStage!='QDE'){
                if (picklistValue == 'Documented - ITR') { //JUL 21
                    this.monthlyIncomeCheck = false; 
                    this.otherIncomeReadOnly = true;
                }else{
                    this.otherIncomeReadOnly = false;
                    this.monthlyIncomeCheck = true; 
                }//END
            }
           
        }

        if (picklistName == 'Monthly_Obligation__c') {
            this.breTrackingFieldList.push('Monthly_Obligation__c');
            //this.monthlyObligation = picklistValue;
            this.inputMonthlyObligation = picklistValue;
            this.handleIBorNIBGradeCalculation();
        }
        if (picklistName == 'Monthly_Income__c') {
           
            if( this.monthlyEditIncome !=null && this.editFinancials == true){
                //let difference = picklistValue -  this.monthlyEditIncome;
                //SFAU-5296
                let difference = this.monthlyEditIncome - picklistValue;
                // SFAU-5474 - Mohit M. - Add Less condition
               // if(difference >= 5000 || difference <= 5000){
                // SFAU-5474 : Samridhi - Absolute diff > 5k
                if(Math.abs(difference) >= 5000){
                    this.breTrackingFieldList.push('Monthly_Income__c');
                    this.breRunMaterialFields();
                }
            }
            this.monthlyVal = picklistValue;
            this.handleIBorNIBGradeCalculation();
            this.docVerified=false
        }
        //added for 3131
        if (picklistName == 'Verified_Income__c') {
            this.monthlyVal = picklistValue;
        }
        if (picklistName == 'Customer_Grade__c') {
            if(this.gradeValue == 'IB' && picklistValue == 'NIB'){
                this.breTrackingFieldList.push('Customer_Grade__c');
            }
            this.gradeValue = picklistValue;
        }
        if (picklistName == 'Consider_Income_for_Eligibility__c') {
            this.breTrackingFieldList.push('Consider_Income_for_Eligibility__c');
            this.elgibityVal = picklistValue;
        }

        if(picklistName == 'Other_Income__c'){
            this.breTrackingFieldList.push('Other_Income__c');
        }
        this.isLoading = false;
    }

    handleApplicantRisk(){
         if(this.riskIdentified!=null && this.riskIdentified!=''){
                const fields = {};
        fields[ID_FIELD.fieldApiName] = this.applicantId;
            fields[APPLICANT_RISK.fieldApiName] = this.riskIdentified;
            const recordInput = {
                fields
            };
            
            updateRecord(recordInput)       
            .then(() => {

        })
        .catch(error => {
        });
        }
        
    }

    getUniqueValue(myList){
        let uniqueList = myList.reduce((accumulator, currentValue) => {
            if (!accumulator.find(item => JSON.stringify(item) === JSON.stringify(currentValue))) {
              accumulator.push(currentValue);
            }
            return accumulator;
          }, []);
          uniqueList.sort((a, b) => a.label.localeCompare(b.label)); //SFAU-2786
          return uniqueList;
    }

    handleIBorNIBGradeCalculation() { //june30
        if (this.boolFourWheeler == true) {
            let total = 0;
            total = parseFloat(this.inputMonthlyObligation) + parseFloat(this.proposedEmi);
            if(this.monthlyVal!=undefined && this.monthlyVal!=''){
                if(total!=0){
                    if ( this.monthlyVal > total ) {
                        this.gradeValue = 'IB';
                    } else if (this.monthlyVal == total || this.monthlyVal < total) {
                        this.gradeValue = 'NIB';
                    }
                }
               
            }else{
                this.handleCustomerGradeOptions();
                if(total!=0){
                    if (this.monthlyEditIncome > total ) {
                        this.gradeValue = 'IB';
                    } else if ( this.monthlyEditIncome == total || this.monthlyEditIncome < total) {
                        this.gradeValue = 'NIB';
                    }
                }
                
            }
            if(total!=undefined && this.monthlyVal!='' && this.monthlyVal!=undefined ){
                if(total == 0 &&  this.monthlyVal ==0){
                    this.gradeValue = 'NIB';
                }
            }
        }
    }

    handlegetRelatedPicklistValues(picklistName, picklistValue, passType, retType, queryParams) {
        this.isLoading = true;
        getRelatedProfilingMaster({
                selectedValue: picklistValue,
                passingType: passType,
                returnType: retType,
                queryParams: queryParams
            }).then(data => {
                this.profilingData = data;
                let options = [];
                if(this.strentityType == 'Individual'){
                    for (var key in data) {
                        if(data[key].Name !='Business'){
                            if(this.maritalStatus  == 'Single' || this.gender =='Male'){ //Added for 2982 SFAU-3023
                                if(data[key].Name !='Housewife'){
                                    options.push({
                                     label: data[key].Name,
                                     value: data[key].Name
                                     });
                             }
                          }else{
                            options.push({
                                label: data[key].Name,
                                value: data[key].Name
                                });
                          }
                        }
                     }
                }else{
                    for (var key in data) {
                        if(this.maritalStatus  == 'Single' || this.gender =='Male'){//Added for 2982 SFAU-3023
                           if(data[key].Name !='Housewife'){
                              options.push({
                                label: data[key].Name,
                                value: data[key].Name
                               });
                             }
                        }else{
                            options.push({
                                label: data[key].Name,
                                value: data[key].Name
                               });
                        }
                     }
                }
                if (picklistName == 'Type_Of_Employment__c') {
                    if(this.OnChange==true){
                        this.sectorEditValue ='';
                        this.industryEditValue ='';
                        this.subIndustryEditValue ='';
                        this.occupationEditValue ='';
                    }
                    this.sectorOptions = this.getUniqueValue(options);
                }
                if (picklistName == 'Sector__c') {
                    if(this.OnChange==true){
                        this.industryEditValue ='';
                        this.subIndustryEditValue ='';
                        this.occupationEditValue ='';
                    }
                    let industryOptions=[];
                    for (var key in data) {
                        if(data[key].Sector__r.Name == this.sectorEditValue ){
                                industryOptions.push({
                                    label: data[key].Name,
                                    value: data[key].Name
                                });
                        }
                     }
                   // this.industryOptions = this.getUniqueValue(options);
                   this.industryOptions = this.getUniqueValue(industryOptions);
                }
                if (picklistName == 'Industry__c') {
                    if(this.OnChange==true){
                        this.subIndustryEditValue ='';
                        this.occupationEditValue ='';
                    }
                    let industryOptions=[];
                    for (var key in data) {
                        if(data[key].Sector__r.Name == this.sectorEditValue && data[key].Industry__r.Name == this.industryEditValue){
                            industryOptions.push({
                                label: data[key].Name,
                                value: data[key].Name
                            });
                        }
                     }
                   // this.subIndustryOptions = this.getUniqueValue(options);
                   this.subIndustryOptions = this.getUniqueValue(industryOptions);
                }
                if (picklistName == 'Sub_Industry__c') {
                    if(this.OnChange==true){
                        this.occupationEditValue ='';
                    }
                    //this.occupationOptions =  this.getUniqueValue(options);
                    let occupationOptions=[];
                    for (var key in data) {
                        if(data[key].Sector__r.Name == this.sectorEditValue && data[key].Industry__r.Name == this.industryEditValue &&  data[key].Sub_Industry__r.Name ==  this.subIndustryEditValue){
                            occupationOptions.push({
                                label: data[key].Name,
                                value: data[key].Name
                            });
                        }
                     }
                     this.occupationOptions = this.getUniqueValue(occupationOptions);
                }
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
            })
    }

    handleEditChange(event) {
        let fieldName =  event.target.name;
        let fieldValue = event.target.value;

        if(fieldName =='Monthly_Income__c'){
            //this.breTrackingFieldList.push('Monthly_Income__c');
            
            if( this.monthlyEditIncome !=null){
                //let difference = fieldValue -  this.monthlyEditIncome;
                //SFAU-5296
                let difference = this.monthlyEditIncome - fieldValue;
                // SFAU-5474 - Mohit M. - Add Less condition
                //if(difference >= 5000 || difference <= 5000){
                // SFAU-5474 : Samridhi - Absolute diff > 5k
                if(Math.abs(difference) >= 5000){
                    this.breTrackingFieldList.push('Monthly_Income__c');
                    this.breRunMaterialFields();
                }
            }
            this.monthlyEditIncome = fieldValue;
            this.handleIBorNIBGradeCalculation();
            this.docVerified=false
        }else if(fieldName =='Monthly_Obligation__c'){
            this.breTrackingFieldList.push('Monthly_Obligation__c');
            this.monthlyObligationEditIncome = fieldValue;
            this.inputMonthlyObligation = fieldValue;
            this.handleIBorNIBGradeCalculation();
        }else if(fieldName =='Other_Income__c'){
            this.breTrackingFieldList.push('Other_Income__c');
            this.otherEditIncome = fieldValue;
        }else if(fieldName =='Verified_Income__c'){
        }// 3131
            
    }
    renderFinanceTemplate() {
        //First we need to save the parent in backend and show/render the child template
        this.validateAddress(); //pooja
        let showTemplate = false;
        if (this.loanStage == 'QDE') {
            showTemplate = true;
            this.handleDisableMoreIncome();
            if (this.boolFourWheeler == true) {
                showTemplate = false;
                this.showIndividualSave = true;
                this.monthlyCheck = true;
                this.handleDisableMoreIncome();
            }
        }
        if (this.strentityType == 'Individual') {
            if (this.boolTwoWheeler == true && this.loanAmount > 500000) {
                showTemplate = true;
                this.showIndividualSave = false;
            } else if (this.boolTwoWheeler == true && this.loanAmount < 500000) {
                showTemplate = false;
                this.handleDisableMoreIncome();
                this.showIndividualSave = true;
                this.monthlyCheck = true;
                
            }
        } else if (this.strentityType == 'Non Individual') {
            if (this.boolTwoWheeler == true) {
                showTemplate = true;
                this.showIndividualSave = false;
            }
        }


        if (this.templateName == 'Salaried_Document') {
            this.showUploadStatement = true;
        } else {
            this.showUploadStatement = false;
        }
        if (this.templateName != null && showTemplate == true) {
            this.showChildTemplates = true;
            this.handleTemplateConditions();
           
        }
    }
    handleTemplateConditions() {
            this.renderSalaryTemplate = false;
            this.renderAssessedNoDocTemplate = false;
            this.renderDocAuditedTemplate = false;
            this.renderWithoutDocAuditedTemplate = false;
            this.renderFarmerTemplate = false;

        if (this.templateName == 'Salaried_Document') {
            this.renderSalaryTemplate = true;
        }
        if (this.templateName == 'Assessed_No_Document') {
            this.renderAssessedNoDocTemplate = true;
        }

        if (this.templateName == 'Documented_With_Audited_financial') {
            this.renderDocAuditedTemplate = true;
        }
        if (this.templateName == 'Documented_Without_Audited_financial') {
            this.renderWithoutDocAuditedTemplate = true;
        }
        if (this.templateName == 'Farmer') {
            this.renderFarmerTemplate = true;
        }
        if (this.templateName == 'NA') {
            this.handleDisableMoreIncome();
            this.showIndividualSave = true;
            this.monthlyCheck = true;
        }
    }
    handleFilingGap() {
        let data = this.withoutauditedData;        
        for (let i = 0; i < data.length - 1; i++) {
            let date1 = new Date(data[i].Filing_Date__c);
            let date2 = new Date(data[i + 1].Filing_Date__c);
            var months;
            months = (date2.getFullYear() - date1.getFullYear()) * 12;
            months -= date1.getMonth();
            months += date2.getMonth();
            // let diffMonths = Math.abs(date2.getMonth() - date1.getMonth());
            if (months >= this.selfEmpFilingGap) {
                return true;
            }
        }
    }
    handleGradeLogic() {
        this.isLoading = true;
        // Method to get Child Applicant Financials for the Parent Applicant Financials
        getFinancialChildDetails({
                recId: this.applicantFinancialId
            }).then(data => {
                let childData = [];
                let withoutaudited = [];
                let ownland = [];
                let dairy = [];
                if (data != null && data != '' && data != undefined) {
                    for (var key in data) {
                        if (data[key].RecordType.DeveloperName == 'Documented_Without_Audited_financial') {
                            withoutaudited.push(data[key]);
                        } else if (data[key].RecordType.DeveloperName == 'Salaried_Document') {
                            childData.push(data[key]);
                        } else if (data[key].RecordType.DeveloperName == 'Farmer_Agriculture_Own_Land') {
                            ownland.push(data[key]);
                        } else if (data[key].RecordType.DeveloperName == 'Farmer_Dairy_Business') {
                            dairy.push(data[key]);
                        }
                    }
                }
                this.withoutauditedData = withoutaudited;
                this.salariedData = childData;
                this.ownland = ownland;
                this.dairy = dairy;
                if (this.templateName == 'Documented_Without_Audited_financial') {
                    this.isLoading = true;
                    getRelatedAddress({
                        applicantId: this.applicantId
                    }).then(data => {
                        if (data.isAddressEqual == false) {
                            this.handleSelfEmployeedCustomerGradeLogic();
                        }
                        this.isLoading = false;
                    }).catch(error => {
                        this.isLoading = false;
                    });
                }

                if (this.templateName == 'Salaried_Document') {
                    getRelatedAddress({
                        applicantId: this.applicantId
                    }).then(data => {
                        if (data.jobStability != '0-1 Year' && data.jobStability != '' && data.jobStability != undefined) { // need to have ofice address type check
                            this.handleBankSalariedCustomerGradeLogic();
                        }
                    }).catch(error => {
                        this.isLoading = false;
                    });
                }
                if (this.ownland != '' && this.ownland != undefined && this.ownland != null) {
                    this.handleLargeFarmerCustomerGradeLogic();
                }

                if (this.dairy != '' && this.dairy != undefined && this.dairy != null) {
                    this.handleDairyCustomerGradeLogic();
                }
                this.isLoading = false
            })
            .catch(error => {
                this.isLoading = false;
            });
    }
    handleDairyCustomerGradeLogic() {
        let data = this.dairy;
        let boolUpdateCheck = false;
        if (this.loanCIBILScore >= this.dfarmerCIBILMinScore || this.loanCIBILScore == this.dfarmerCIBILDefScore) {
            for (var key in data) {
                if (data[key].No_of_Cattle__c >= this.dfarmerMinNoCattle) {
                    this.gradeValue = 'Premium';
                    boolUpdateCheck = true;
                }
            }
        }
        if (boolUpdateCheck == true) {
            let grade = 'Premium';
            this.handleUpdateApplicantValues(grade);
            this.handleUpdateParentCustomerGrade(grade);
        }

    }
    handleLargeFarmerCustomerGradeLogic() {
        let data = this.ownland;        
        let areaCheck = false;
        for (var key in data) {
            const acreVal = data[key].Area_under_crop__c;
            if (data[key].Area_under_Crop_Unit__c == 'Acres') {
                const bighaVal = (acreVal * 1.6);
                if (bighaVal >= 8) {
                    areaCheck = true;
                }

            }
            if (data[key].Area_under_Crop_Unit__c == 'Bigha') {
                if (data[key].Area_under_crop__c >= 8) {
                    areaCheck = true;
                }
            }
            if (data[key].Area_under_Crop_Unit__c == 'Hectare') {
                const bighaVal = (acreVal * 3.95);
                if (bighaVal >= 8) {
                    areaCheck = true;
                }
            }
        }
        let boolUpdateCheck = false;
        if (this.loanCIBILScore >= this.lfarmerCIBILMinScore || this.loanCIBILScore == this.lfarmerCIBILMinScore) {
            if (this.loanAmount <= this.lfarmerMaxLoanAmt && areaCheck == true) {
                this.gradeValue = 'Premium';
                boolUpdateCheck = true;
            }
        }
        if (boolUpdateCheck == true) {
            let grade = 'Premium';
            this.handleUpdateApplicantValues(grade);
            this.handleUpdateParentCustomerGrade(grade);
        }
    }

    handleBankSalariedCustomerGradeLogic() {
        let data = this.salariedData;
        let boolUpdateCheck = false;
        let companyCheck=false;
        getCompanyCode({
            companyName: this.companyOptionsValue
        }).then(data => {
            companyCheck = data;
            if (this.loanCIBILScore >= this.bankCIBILMinScore || this.loanCIBILScore == this.bankCIBILDefScore) {
                // this.isLoading = true;
                // if (companyCheck == true) {
                     getBankRecords({
                             applicantId: this.applicantId,
                             accountType: '',
                             minRelationship: 12
                         }).then(result => {
                             
                             const totalEmi = result.totalEMI;
                             const noEmI = result.noOfEMI;
                             //const salaryAmt = result.monthAmount;
                             const salaryAmt = this.monthTotal;
                             const emi = 0;
                             if(noEmI!=NaN && noEmI!=0){
                                emi = (totalEmi / noEmI);
                             }
                             const emiMultipler = parseFloat(this.bankEmiMultiplier);
                             const emiFinalAmt =  emiMultipler * emi;
                             //emiFinalAmt = emiMultipler * emi; //3*EMI
                             
                             if (salaryAmt >= emiFinalAmt ) {
                                 this.gradeValue = 'Premium';
                                 boolUpdateCheck = true;
                             }
                             
                             if (boolUpdateCheck == true) {
                                 let grade = 'Premium';
                                 this.handleUpdateApplicantValues(grade);
                                 this.handleUpdateParentCustomerGrade(grade);
                             }
                            // this.isLoading = false;
                         })
                         .catch(error => {
                             this.isLoading = false;
                         })
                // }
             }
        }).catch(error => {
            this.isLoading = false;
        });

        
    }
    handleSelfEmployeedCustomerGradeLogic() {
        //Filing Date Calculation
        let boolCheck;
        let data1 = this.withoutauditedData;
        for (let i = 0; i < data1.length - 1; i++) {
            let date1 = new Date(data1[i].Filing_Date__c);
            let date2 = new Date(data1[i + 1].Filing_Date__c);
            var months;
            months = (date2.getFullYear() - date1.getFullYear()) * 12;
            months -= date1.getMonth();
            months += date2.getMonth();
            // let diffMonths = Math.abs(date2.getMonth() - date1.getMonth());
            months = -months;
            
        }
        const emi = parseFloat(this.proposedEmi);
        
        const emiAmt = (this.selfEmpEmiMultipler * emi);
        if (this.sixMonthAverageBalance > emiAmt) {
            if (months >= this.selfEmpFilingGap) {
                boolCheck = true;
            } else {
                boolCheck = false;
            }
        } else {
            boolCheck = false;
        }

        let boolUpdateCheck = false;
        if (this.templateName == 'Documented_Without_Audited_financial') {
            let data = this.withoutauditedData;
            for (var key in data) {
                if (this.loanCIBILScore >= this.selfEmpCIBILMinScore || this.loanCIBILScore == this.selfEmpCIBILDefScore) { // Applicant Bureau Score should be greater than or equal to one defined in custom metadata
                    if (data.length >= this.selfEmpMinITR) { // ITR should be min of 2 years
                        if (data[key].Annual_Net_Profit__c >= this.selfEmpMinAmountPerITR) { //Annual Amount should be greater than or equal to 6 lacs
                            if (boolCheck == true) { // Filing Gap should be greater than or equal to 6 months ie selfEmpFilingGap
                                this.gradeValue = 'Premium';
                                boolUpdateCheck = true;
                            }
                        }

                    }
                }
            }
            if (boolUpdateCheck == true) {
                let grade = 'Premium';
                this.handleUpdateApplicantValues(grade);
                this.handleUpdateParentCustomerGrade(grade);
            }
        }
    }

    async handleUpdateApplicantValues(grade) { //july26
       
        //if(grade =='Premium'){
            const fields = {};
            fields[ID_FIELD.fieldApiName] = this.applicantId;
            if(grade!='Premium'){
                fields[CSGRADE_FIELD.fieldApiName] = grade;
            }
            if(grade=='Premium' && this.boolTwoWheeler == false){
                fields[CSGRADE_FIELD.fieldApiName] = grade;
            }
            const updatedApplicant = await getApplicantRiskCategory({ draftApplicantRecord: fields, fieldApi: FINEMP_FIELD.fieldApiName }).catch( err => console.error(err) );
    
            fields[APPLICANT_2W_RISK_CATEGORY.fieldApiName] = updatedApplicant[APPLICANT_2W_RISK_CATEGORY.fieldApiName];
            fields[APPLICANT_4W_RISK_CATEGORY.fieldApiName] = updatedApplicant[APPLICANT_4W_RISK_CATEGORY.fieldApiName];
            const recordInput = {
                fields
            };
            updateRecord(recordInput)
                .then(() => {
                })
                .catch(error => {
                    
                });       
    }
    handleUpdateTypeOfEmployment(){
        let employmentVal;
        if(this.employmentValue!=null && this.employmentValue!=''){
            employmentVal = this.employmentValue;
        }
        if(this.typeofEmployment!=null && this.typeofEmployment!=''){
            employmentVal = this.typeofEmployment;
        }
        applicantEmploymentUpdation({
                    applicantId: this.applicantId,
                    typeOfEmployment :employmentVal,
                     gradeVal:this.gradeValue
                }).then(result => {
                })
                .catch(error => {                   
                })
        
    }

    handleUpdateParentCustomerGrade(grade) {
        // this.financialRecord.Customer_Grade__c = this.gradeValue;
        if(grade == 'Premium' && this.boolTwoWheeler == false){//july7
            const fields = {};
            fields[FINID_FIELD.fieldApiName] = this.applicantFinancialId
            fields[FINCSGRADE_FIELD.fieldApiName] = grade;
            const recordInput = {
                fields
            };
            updateRecord(recordInput)
                .then(() => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Financials updated',
                            variant: 'success'
                        })
                    );
                })
                .catch(error => {                    
                });
        }
    }

    handleDisableMoreIncome() {
        this.dispatchEvent(new CustomEvent('hideincome', {
            detail: 'false'
        }));
    }
    handleBankStatementGradeLogic() {
        if (this.boolTwoWheeler == true) {
            if (this.bankStatementUploaded == true) {
                this.gradeValue = 'IB';
            } else {
                this.gradeValue = 'NIB';
            }
        }
    }
    async validaOfficeAddress(event){ // new methos pooja
        //4733 start
        this.isEditRestricted = await restricAccess({compName: 'financialView' ,loanId: this.loanId})
        if(this.isEditRestricted){
            this.validateRestrictEdit();
            return
        }//end
        
         validateAddressInfoJS({applicantId: this.applicantId,  typeOfEmpployment : this.typeofEmployment})
        .then(result => {
            
            if(result){
                 this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Validation Error',
                        message: 'Office Address is mandatory for the selected Type of employment',
                        variant: 'Error',
                    }),
                );
            }
            else{
                this.handleEditSubmit(event);
            }
        })
        
    }

    async validateRestrictEdit(){
        const evt = new ShowToastEvent({
            title: 'Access Restricted',
            message: 'Financial Details were not saved',
            variant: 'warning',
            mode: 'sticky'
        });
        this.dispatchEvent(evt);   
        this.templateName=this.initialTemplateName
        if(this.showIndividualSave){
            this.handleReject()
            this.editFinancials=false
        }else{
            this.renderEditViewTemplate();
        }
        
    }
    async validateAddress(event){ //Pooja
        //4733 start
        this.isEditRestricted = await restricAccess({compName: 'financialView' ,loanId: this.loanId})
        if(this.isEditRestricted){
            this.validateRestrictEdit();
            return
        }
        //4733 end
        validateAddressInfoJS({applicantId: this.applicantId,  typeOfEmpployment : this.typeofEmployment})
        .then(result => {
            if(result){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Validation Error',
                        message: 'Office Address is mandatory for the selected Type of employment',
                        variant: 'Error',
                    }),
                );
            }
            else{
                
                 this.handleIndividualSave(event);
            }
            
        })
        .catch(error => {
            this.isLoading = false;
        })
    }
    // Saving parent alone for two wheelers for the income less than 5 lacs
    handleIndividualSave(event) {
        this.applicantId = this.applicantId;
        this.financialRecord.Customer_Grade__c = this.gradeValue;
        if (this.financialRecord.Monthly_Obligation__c == '' || this.financialRecord.Monthly_Obligation__c == null || this.financialRecord.Monthly_Obligation__c == undefined) {
            this.financialRecord.Monthly_Obligation__c = this.inputMonthlyObligation;
        }
        if (this.financialRecord.Consider_Income_for_Eligibility__c == '' || this.financialRecord.Consider_Income_for_Eligibility__c == null || this.financialRecord.Consider_Income_for_Eligibility__c == undefined) {
            this.financialRecord.Consider_Income_for_Eligibility__c = this.elgibityVal;
        }
        if (this.loanStage != 'QDE') {
            this.financialRecord.Bureau_Obligation__c = this.bureauObligation;
        }

        if (this.cmpValue != null) {
            this.handleFieldMappings();
        }
        const fields = this.financialRecord;
        const recordInput = {
            apiName: FINANCIAL_OBJECT.objectApiName,
            fields
        };
        
        if ((this.boolTwoWheeler == true) && (this.gradeValue == 'IB') && (this.bankStatementUploaded == false)) {
            this.showErrorMessage('Please upload the Income Documents to continue, or update the customer grade other than IB', 'error');
        } else if(this.isInputValid()) {

            //Make the New Details Screen Hide as soon as its a valid Save
            this.isNewDetails = false;
            //call child component update method to save additionaldetails
            if(!this.isDDE){
                const objChild = this.template.querySelector('c-additional-financial-component');
                var valid = objChild.updateApplicantData();
            }
           // if (this.isInputValid()) {
            if((!this.isDDE && valid) || this.isDDE){
                this.isLoading = true;
                createRecord(recordInput)
                    .then(financials => {
                        this.handleUpdateTypeOfEmployment();
                        
                        this.applicantFinancialId = financials.id;
                        this.financialParentId = financials.id;
                       this.parentFinancePresent = true;
                        //this.financialRecord='';
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Success',
                                message: 'Applicant Financials created',
                                variant: 'success',
                            }),
                        );
                        this.fetchDetails = false;
                        if (this.renderedTemplate == 'salary') {
                            this.template.querySelector("c-upload-multiple-files").hideButtons();
                        }
                       
                        this.showViewForm = false;

                        if (this.showIndividualSave == true) {
                            this.handleRender();
                        }
                        if (this.showIndividualSave == false) {
                            if (this.elgibityVal == 'Yes') {
                                this.showChildTemplates = true;
                            }

                        }
                        if(this.showIndividualSave == true ){ //|| this.loanStage =='Credit'
                            this.template.querySelector('c-foir-finance-component').getDetails(this.loanId); 
                         }
                        this.getApplicantSummaryData();
                      
                        this.inputMonthlyObligation =null;
                        if (this.loanStage == 'QDE') { //jul6
                            this.handleInitialAttributes();
                        }

                        //Neha-3838
                        this.updateApplicant()
                        //end
                        const payload = { recordIdOfSobject: this.loanApp.Id, refreshPage: 'Yes'}; //JUL 24
                        publish(this.messageContext, pageRefreshOnMaterialFieldChange, payload); //JUL 24
                        this.isLoading = false;
                    }).catch(error => {
                        this.isLoading = false;
                    });
            }
           // }
        }

    }

    handleSubmit(event) { // this will be now child submit
        this.childrecord = event.detail.record;
        this.childRecordfinancialId = event.detail.financialId;
        var temp = event.detail.template;

        if (temp == 'salary') {
            this.monthTotal = event.detail.salaryMonthVal;
            this.docVerified = event.detail.docVerified//Neha-3838
        }
        
        this.updateApplicant()
        this.financialRecord.Customer_Grade__c = this.gradeValue;

        if (this.childrecord.Applicant_Financials__c == '' || !this.childrecord.Applicant_Financials__c) {
            const fields = this.financialRecord;
            const recordInput = {
                apiName: FINANCIAL_OBJECT.objectApiName,
                fields
            };
            if (this.isInputValid()) {
                this.isLoading = true;
                if (temp == 'farmer') {
                    this.childrecord.Applicant_Financials__c = this.applicantFinancialId;
                    this.handleFarmerChildSubmit(this.applicantFinancialId);

                } else {
                    this.childrecord.Applicant_Financials__c = this.applicantFinancialId;
                    this.handleChildSubmit();
                }
                
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please fill all the Mandatory fields',
                        variant: 'error',
                    }),
                );
            }
        } else {
            this.childrecord.Applicant_Financials__c = this.applicantFinancialId;
            this.handleChildSubmit();
            this.readAttribute = true;
            this.readAlways = true;
        }
    }

    handleFieldMappings() {
       // this.financialRecord.Company_Name__c = this.cmpValue;
        //this.financialRecord.Type_Of_Employment__c = this.employmentValue;
        this.financialRecord.Type_Of_Employment__c = this.employmentEditVal;
        
        this.financialRecord.Method_Of_Assesment__c = this.assesmentVal;
    }

    handleCalculations(event) {
        var modal = event.detail.other;
        this.financialRecord.Id = this.applicantFinancialId;
        //this.financialRecord.Id = this.financialParentId;
        this.handleMonthIncomeParent();
        if (modal) {
            this.showModal = true
        }

        if (event.detail.template == 'farmer') {
            this.handleGradeLogic();
        }
    }

    handleMonthIncomeParent() { ////20 JUL 
        var totalIncome=0;
        
        getParentFinancialRecord({
            recordId: this.applicantFinancialId
        }).then((data) => {
            this.financialRecord.Id = this.applicantFinancialId;
            let monthlyIncome = (data.documentedIncome != null && data.documentedIncome != undefined ? data.documentedIncome : 0);
            totalIncome = data.documentedIncome;
            let difference = this.monthlyEditIncome - monthlyIncome;
            if(Math.abs(difference) >= 5000){
                this.breTrackingFieldList.push('Monthly_Income__c');
                this.breRunMaterialFields();
            }
            this.monthlyVal = data.documentedIncome;
            let total = 0;
            total = parseFloat(this.inputMonthlyObligation) + parseFloat(this.proposedEmi);
            if (monthlyIncome == total) {
                this.financialRecord.Customer_Grade__c = 'IB';
            } else if (monthlyIncome < total) {
                this.financialRecord.Customer_Grade__c = 'NIB';
            }
             //Jul 20 
             if( data.documentedIncome!=0){
                this.financialRecord.Monthly_Income__c = data.documentedIncome;
             }
             this.financialRecord.Other_Income__c = data.assessedIncome;
             //End
            
            this.handleRecords(this.financialRecord);


        })
           
    }
    handleChildSubmit() {
        this.isLoading = true;
        createFinancialRecords({
                financeRecord: this.childrecord
            })
            .then(financials => {
                this.childrecordId = financials;
                this.handleMonthIncomeParent()
                if (this.templateName == 'Documented_Without_Audited_financial' || this.templateName == 'Salaried_Document') { //address check should be there
                    this.handleGradeLogic();
                } 
                let grade = this.gradeValue;
                this.handleUpdateApplicantValues(grade);
                this.showModal = true;  
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
            });

    }

    handleRender() {
        this.isLoading = true;
        this.isNewDetails = false;
        this.getExistingApplicantFinancials(this.applicantId);
        this.getInitialData();
        this.showViewForm = true;
        this.showExistingdetails = true;
        this.isLoading = false;
        this.financialRecord = {};
        this.gradeValue = '';
        this.readAttribute = false;
        this.readAlways = false;
        this.monthlyVal = '';
        this.showEditViewChildTemplates = false;
        this.renderSalaryTemplate = false;
        this.renderAssessed = false;
        this.renderAssessedNoDocTemplate = false;
        this.renderWithoutDocAuditedTemplate = false;
        this.renderDocAuditedTemplate = false;
        this.renderFarmerTemplate = false;
        this.renderOtherTemplate = false;
        this.isMainPicklistChanged = false;
        this.inputMonthlyObligation =null;
    }

    handleChildTemplatesReset(){
        this.showEditViewChildTemplates = false;
        this.showChildTemplates = false;
        this.renderSalaryTemplate = false;
        this.renderAssessed = false;
        this.renderAssessedNoDocTemplate = false;
        this.renderWithoutDocAuditedTemplate = false;
        this.renderDocAuditedTemplate = false;
        this.renderFarmerTemplate = false;
        this.renderOtherTemplate = false;
    }
    handleFarmerChildSubmit(Id) {
        upsertIncome({
            record: this.childrecord
        }).then((data) => {
            this.intialRecord = data;
            //this.intialRecord.Id = data;

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Child Records created',
                    variant: 'success',
                }),
            );
            this.showModal = true;
            if (this.templateName == 'Farmer') {
                this.handleGradeLogic();
            }
            this.handleMonthIncomeParent();
            let grade = this.gradeValue;
            this.handleUpdateApplicantValues(grade);
            const payload = { recordIdOfSobject: this.loanApp.Id, refreshPage: 'Yes'}; //JUL 24
            publish(this.messageContext, pageRefreshOnMaterialFieldChange, payload); //JUL 24
            
        })
    }

    handleReadOnlyAttributes() {
        if (this.renderedTemplate == 'salary') {
            this.template.querySelector('c-salary-finance-component').handleReadOnly();
        }
        if (this.renderedTemplate == 'assessed') {
            this.template.querySelector('c-assessed-nodocumented-component').handleassessedReadOnly();
        }
        if (this.renderedTemplate == 'audited') {
            this.template.querySelector('c-document-audited-component').handledocReadOnly();
        }
        if (this.renderedTemplate == 'withoutaudited') {
            this.template.querySelector('c-document-without-audited-component').handledocReadOnly();
        }

    }

    handleParentUpdate() {
        this.financialRecord.Id = this.applicantFinancialId;
        this.handleMonthIncomeParent();
    }

    handleUpdate(event) {
        this.financialRecord.Id = this.applicantFinancialId;
        this.childrecord = event.detail.record;
        this.childrecord.Id = this.childrecordId;
        this.docVerified = event.detail.docVerified
        this.updateApplicant();
        this.handleChildSubmit();
        this.renderedTemplate = event.detail.template;
    }

    handleRecords(record) {
        createFinancialRecords({
                financeRecord: record
            })
            .then(financials => {
                this.applicantFinancialId = financials;
                //this.getVisibleFieldsMetadata();
                this.handleReadOnlyAttributes();
                //this.showViewForm = true;
                this.readAttribute = true;
                this.isLoading = false;
                this.getApplicantSummaryData();
            })
            .catch(error => {
            });
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

    handleEdit() {
        this.readAttribute = false;
        if (this.templateName == 'Salaried_Document') {
            this.showUploadStatement = true;
            this.disableUpload = false
        }
    }
    handleClose() {
        this.readAttribute = true;
        if (this.templateName == 'Salaried_Document') {
            this.showUploadStatement = false
            this.disableUpload = true
        }
    }
    handleResetAttributes() {
        this.financialRecord = '';
        this.gradeValue = '';
        this.monthlyVal = '';
        this.typeofEmployment =''//jul6
        this.methodofAssesment=''; //jul6
        this.totalWorkExperience ='' //jul6
        this.othCompName =''; //jul24
        this.isCompanyOther =false;//jul24
        this.readAttribute = false;
        this.readAlways = false;
        this.showChildTemplates = false;
        this.renderSalaryTemplate = false;
        this.renderDocAuditedTemplate = false;
        this.renderAssessed = false;
        this.renderWithoutDocAuditedTemplate = false;
        this.renderFarmerTemplate = false;

    }
    @api nextHandler() {
        if(this.checkforCustomerGradeUpdate) return;
        const Obj = {};
        //Obj.applicantRecord = this.applicantIdInput;
        this.errorOnChild = '';
        Obj.errorOnChild = this.errorOnChild;
        Obj.next = this.errorOnChild == '' ? true : false;
        this.dispatchEvent(new CustomEvent('next', {
            detail: Obj
        }));
    }
    @api checkforCustomerGradeUpdate(){
        return this.boolFourWheeler || this.template.querySelector('c-foir-finance-component').checkCustomerGrade()?true:false;
    }
    handleRowAction(event) {
        const recordId = event.currentTarget.dataset!=null ? event.currentTarget.dataset.id :'';
        var empType = event.currentTarget.dataset!=null ? event.currentTarget.dataset.recordName:'';
        this.typeofEmployment = event.currentTarget.dataset!=null ? event.currentTarget.dataset.recordName:''; // Used for fixing the template issues 
        this.employmentEditValue = event.currentTarget.dataset!=null ? event.currentTarget.dataset.recordName:''; //jul6
        var methodofassess =event.currentTarget.dataset!=null ?  event.currentTarget.alternativeText:'';
        
        if( this.loanLAN!='' && (this.loanStage== 'Ops Maker' || this.loanStage == 'Ops Author' || this.loanStage == 'PDD')){
           this.showErrorMessage('Financial Details cannot be edited', 'error');
        }else{
                        this.readAttribute = false;
                        var recordType;
                        let record = this.profileMasterData;
                        for (var key in record) {
                            if (record[key].Type_of_Employment__c == empType && record[key].Method_Assesment__c == methodofassess) {
                                recordType = record[key].Financial_Template__c;
                                this.templateName = record[key].Financial_Template__c;
                            }
                            
                        }
                        if(this.loanStage!='QDE'){
                            if(  methodofassess == 'Documented - ITR'){ //JUL 21
                                this.monthlyIncomeCheck = false; 
                                this.otherIncomeReadOnly = true;
                            }else{
                                this.otherIncomeReadOnly = false;
                                this.monthlyIncomeCheck = true; 
                            } //END
                        }
                      
                        this.isLoading = true;
                        getFinancialChildDetails({
                                recId: recordId
                            }).then(data => {
                                // this.onclickParentFinancialData = data;
                                this.OnChange = false; // Used to Fix the Picklist Change Issue
                                let parentData = [];
                                let childData = [];
                                let assesedData = [];
                                let audited = [];
                                let withoutaudited = [];
                                let other = [];
                                let commercial = [];
                                let ownland = [];
                                let dairy = [];
                                let rcl = [];
                                var salaryTemp = false;
                                
                                for (var key in data) {
                                    if (data[key].RecordType.DeveloperName == 'Financial_Parent') {
                                        parentData.push(data[key]);
                                        this.applicantFinancialId = data[key].Id;
                                    } else if (data[key].RecordType.DeveloperName == recordType && recordType == 'Salaried_Document') {
                                        childData.push(data[key]);
                                        this.isChildEditRecordsPresent = true;
                                    } else if (data[key].RecordType.DeveloperName == recordType && recordType == 'Assessed_No_Document') {
                                        assesedData.push(data[key]);
                                        this.isChildEditRecordsPresent = true;
                                    } else if (data[key].RecordType.DeveloperName == recordType && recordType == 'Documented_With_Audited_financial') {
                                        audited.push(data[key]);
                                        this.isChildEditRecordsPresent = true;
                                    } else if (data[key].RecordType.DeveloperName == recordType && recordType == 'Documented_Without_Audited_financial') {
                                        withoutaudited.push(data[key]);
                                        this.isChildEditRecordsPresent = true;
                                    } else if (data[key].RecordType.DeveloperName == 'Other_Income') {
                                        other.push(data[key]);
                                        this.isChildEditRecordsPresent = true;
                                    } else if (data[key].RecordType.DeveloperName == 'Farmer_Commercial') {
                                        commercial.push(data[key]);
                                        this.isChildEditRecordsPresent = true;
                                    } else if (data[key].RecordType.DeveloperName == 'Farmer_Dairy_Business') {
                                        dairy.push(data[key]);
                                        this.isChildEditRecordsPresent = true;
                                    } else if (data[key].RecordType.DeveloperName == 'Farmer_Agriculture_Rented_Land') {
                                        rcl.push(data[key]);
                                        this.isChildEditRecordsPresent = true;
                                    } else if (data[key].RecordType.DeveloperName == 'Farmer_Agriculture_Own_Land') {
                                        ownland.push(data[key]);
                                        this.isChildEditRecordsPresent = true;
                                    }
    
                                }
                                if (parentData != null && parentData != undefined) {
                                    this.onclickParentFinancialData = parentData;
                                    this.loadOptions();
                                }
    
    
                                // allow method of assessment and type of employment editable only in DDE Stage
                                if ( (this.loanStage == 'DDE') || (( parentData[0].Applicant__r.Loan__r.Product__c == '10301' || parentData[0].Applicant__r.Loan__r.Product__c =='10302' || parentData[0].Applicant__r.Loan__r.Product__c  == '10303') && (parentData[0].Applicant__r.Loan__r.Loan_Amount__c >= 500000))) {
                                   this.showDDEDependentFields = true; //24JUL
                                    this.allowEmploymentEditable = true;
                                    this.getIncomeProfileMasterData(this.strentityType);
                                } else {
                                    this.allowEmploymentEditable = false;
                                }
    
                                //Show sector editable Dependent fields only in  dde stage and two wheelr
                                for (var key in parentData) {
                                    this.customerType = parentData[key].Applicant__r.Customer_Type__c;
                                    if(parentData[key].Company_Master__c!=undefined){
                                        if(parentData[key].Company_Master__r.Company_Name__c != undefined && 
                                            parentData[key].Company_Master__r.Company_Name__c== 'Others'){
                                            this.isCompanyOther = true;
                                            if(parentData[key].Company_Name__c != undefined){
                                                this.othCompName = parentData[key].Company_Name__c;
                                            }
                                        }
                                    }
                                    this.companyOptionsValue =  parentData[key].Company_Name__c!=undefined ? parentData[key].Company_Name__c :'';
                                    if(this.isCompanyOther == true){
                                        this.companyOptionsValue = 'Others';
                                    }
                                    this.companyDefaultId =  parentData[key].Company_Master__c;
                                    this.elgibityVal = parentData[key].Consider_Income_for_Eligibility__c;
                                    this.gradeValue = parentData[key].Customer_Grade__c;
                                    this.monthlyEditIncome  =  parentData[key].Monthly_Income__c;
                                    if( parentData[key].Monthly_Obligation__c!='' &&  parentData[key].Monthly_Obligation__c!=null){
                                        this.monthlyObligationEditIncome  =  parentData[key].Monthly_Obligation__c;
                                    }else{
                                        this.monthlyObligationEditIncome  =0;
                                    }
                                    this.inputMonthlyObligation = parentData[key].Monthly_Obligation__c;
                                    this.otherEditIncome  =  parentData[key].Other_Income__c;
                                    this.employmentEditVal = parentData[key].Type_Of_Employment__c;
                                    this.handleLoadAssessmentOptions(this.employmentEditVal, parentData[key].Method_Of_Assesment__c);
                                    this.assesmentEditVal = parentData[key].Method_Of_Assesment__c;
                                    this.totalWorkExperience =  parentData[key].Total_Work_Experience__c;
                                    
                                        if(parentData[key].Type_Of_Employment__c == 'Salaried - Private' || parentData[key].Type_Of_Employment__c =='Salaried - Government'){
                                            this.isSalaried = true;
                                        }else{
                                            this.isSalaried = false;
                                            this.isCompanyOther = false;
                                            if(parentData[key].Company_Name__c!=undefined){ //Jul20
                                                this.othCompName =  parentData[key].Company_Name__c
                                            }
                                        }
                            
                                        if(parentData[key].Type_Of_Employment__c == 'Salaried - Private' ||parentData[key].Type_Of_Employment__c =='Salaried - Government'|| parentData[key].Type_Of_Employment__c =='Self Employed Non-Professional' || parentData[key].Type_Of_Employment__c == 'Self Employed Professional' ||parentData[key].Type_Of_Employment__c =='Business'  ){
                                            this.showWorkExperienceField =true;
                                        }else{
                                            this.showWorkExperienceField =false;
                                        }
    
                                        // UnEmployed Conditions Check - SFAU-2699
                                        if(parentData[key].Type_Of_Employment__c == 'Unemployed'){ //
                                        this.unEmployedDisableCheck = true;
                                        this.isCompanyReadOnly = true;
                                        }else{
                                        this.unEmployedDisableCheck = false;
                                        this.isCompanyReadOnly = false;
                                        }
    
                                        if(parentData[key].Type_Of_Employment__c =='Housewife'){
                                            this.isCompanyReadOnly = true;
                                        }
                                        //END 
                                          if(parentData[key].Type_Of_Employment__c == 'Housewife' || parentData[key].Type_Of_Employment__c == 'Unemployed' || parentData[key].Type_Of_Employment__c == 'Retired - Non-Pensioner'){
                                                this.showIndividualSave = true;
                                            }else{
                                                if (this.boolTwoWheeler == true && this.loanAmount > 500000) { //SFAU-4935
                                                    this.showIndividualSave = false;
                                                } else if (this.boolTwoWheeler == true && this.loanAmount < 500000) {
                                                    this.showIndividualSave = true;
                                                    this.otherIncomeReadOnly = false;
                                                    this.monthlyIncomeCheck = false; 
                                                } else if( this.loanStage !='QDE' && this.boolTwoWheeler == false ){
                                                    this.showIndividualSave = false;
                                                }
                                            }
                                        if (this.loanStage != 'QDE' || this.boolTwoWheeler == true) { // It should be there for all stages except QDE
                                        this.employmentEditVal = parentData[key].Type_Of_Employment__c;
                                        this.handlegetRelatedPicklistValues('Type_Of_Employment__c', this.employmentEditVal, 'RT - Employment Type', 'RT - Sector','');  
                                        this.sectorEditValue = parentData[key].Sector__c;
                                        this.handlegetRelatedPicklistValues('Sector__c', this.sectorEditValue, 'RT - Sector', 'RT - Industry',parentData[key].Type_Of_Employment__c);
                                        this.industryEditValue = parentData[key].Industry__c;
                                        this.handlegetRelatedPicklistValues('Industry__c', this.industryEditValue, 'RT - Industry', 'RT - Sub Industry',parentData[key].Type_Of_Employment__c + '~' + parentData[key].Sector__c);
                                        this.subIndustryEditValue = parentData[key].Sub_Industry__c;
                                        this.handlegetRelatedPicklistValues('Sub_Industry__c', this.subIndustryEditValue, 'RT - Sub Industry', 'RT - Occupation',parentData[key].Type_Of_Employment__c + '~' + parentData[key].Sector__c + '~' + parentData[key].Industry__c);
                                        this.occupationEditValue = parentData[key].Occupation__c;
                                        this.handlegetRelatedPicklistValues('Occupation__c', this.occupationEditValue, 'RT - Occupation', 'RT - Employment Type',parentData[key].Type_Of_Employment__c + '~' + parentData[key].Sector__c + '~' + parentData[key].Industry__c + '~' + parentData[key].Occupation__c);
                                    }
                                }
                    
                                if (childData != null && childData != undefined && childData.length != 0) {
                                    this.salariedData = childData;
                                    this.renderSalaryTemplate = true;
                                }
    
                                if (assesedData != null && assesedData != undefined && assesedData.length != 0) {
                                    this.assessedData = assesedData;
                                    this.renderAssessed = true;
                                }
                                if (audited != null && audited != undefined && audited.length != 0) {
                                    this.auditedData = audited;
                                    this.renderDocAuditedTemplate = true;
                                }
                                if (withoutaudited != null && withoutaudited != undefined && withoutaudited.length != 0) {
                                    this.withoutauditedData = withoutaudited;
                                    this.renderWithoutDocAuditedTemplate = true;
                                }
                                if (other != null && other != undefined && other.length != 0) {
                                    this.other = other;
                                    this.renderOtherTemplate = true
                                }
                                if (rcl != null && rcl != undefined && rcl.length != 0) {
                                    this.rcl = rcl;
                                    this.renderFarmerTemplate = true;
                                }
                                if (ownland != null && ownland != undefined && ownland.length != 0) {
                                    this.ownland = ownland;
                                    this.renderFarmerTemplate = true;
                                }
                                if (commercial != null && commercial != undefined && commercial.length != 0) {
                                    this.commercial = commercial;
                                    this.renderFarmerTemplate = true;
                                }
                                if (dairy != null && dairy != undefined && dairy.length != 0) {
                                    this.dairy = dairy;
                                    this.renderFarmerTemplate = true;
                                }
                                this.dispatchEvent(new CustomEvent('wizardevent', {
                                    detail: {
                                        value: '',
                                        name: 'Financials',
                                        mode: ''
                                    },
                                    bubbles: true,
                                    composed: true
                                }));
                                this.editFinancials = true;
                                this.showViewForm = false;
                                this.isLoading = false
                                if (methodofassess == 'Salaried') {
                                    this.showUploadStatement = true;
                                    this.disableUpload = false
                                }
                            })
                            .catch(error => {
                                this.isLoading = false;
                            });
        }
    }

    handleLoadAssessmentOptions(typeofEmployment, assessmentVal) {
        let record = this.profileMasterData;
        let options = [];
        for (var key in record) {
            if (record[key].Type_of_Employment__c == typeofEmployment) {
                options.push({
                    label: record[key].Method_Assesment__c,
                    value: record[key].Method_Assesment__c
                });
            }
        }
        this.assesmentOptions = options;
        this.assesmentEditVal = assessmentVal;

    }
    handleEditSubmit(event) {
        event.preventDefault();
      
        const fields = {};
        
        fields.Consider_Income_for_Eligibility__c = this.elgibityVal;
        fields.Customer_Grade__c = this.gradeValue;
        if(this.monthlyEditIncome!=undefined){
            fields.Monthly_Income__c = this.monthlyEditIncome;
        }else{
            this.monthlyEditIncome =0;
            fields.Monthly_Income__c = 0;
        }
        //3131
       

        if(this.otherEditIncome!=undefined){
        fields.Other_Income__c = this.otherEditIncome;
        }else{
            this.otherEditIncome =0;
            fields.Other_Income__c = 0;
        }
        if(this.monthlyObligationEditIncome!=undefined){
            fields.Monthly_Obligation__c = this.monthlyObligationEditIncome;
        } else{
            this.monthlyObligationEditIncome=0;
            fields.Monthly_Obligation__c =0;
        } 
        if(this.companyDefaultId!=undefined){
            fields.Company_Master__c = this.companyDefaultId;
        }
        if(this.companyOptionsValue!=undefined){
            if(this.isCompanyOther == true){
                fields.Company_Name__c =  this.othCompName ;
            }else{
                fields.Company_Name__c = this.companyOptionsValue;
            }
        }
        if(this.isSalaried == false){ //jul20
            fields.Company_Name__c =  this.othCompName;
        }
        
         if(this.employmentEditValue!=undefined){
            fields.Type_Of_Employment__c = this.employmentEditValue;
         }
         fields.Method_Of_Assesment__c = this.assesmentEditVal;
         fields.Total_Work_Experience__c = this.financialRecord.Total_Work_Experience__c;
        if (this.loanStage != 'QDE' ||  this.boolTwoWheeler == true) {
            fields.Sector__c = this.sectorEditValue;
            fields.Industry__c = this.industryEditValue;
            fields.Sub_Industry__c = this.subIndustryEditValue;
            fields.Occupation__c = this.occupationEditValue;
            fields.Bureau_Obligation__c = this.bureauObligation;
           
         if (this.isInputValid()) {
            //Here you need to check whether the fields are updated if its updated then call the child and make it as inactive
            if(this.onclickParentFinancialData[0].Customer_Grade__c == 'IB' && fields.Customer_Grade__c == 'NIB'){
                this.breTrackingFieldList.push('Customer_Grade__c');
            }

         if ((this.isChildEditRecordsPresent == true) && (this.isMainPicklistChanged == true)) {
                this.handleChildRecordsDeactivation();
            } else {
                this.renderEditViewTemplate();
            }
         }
        }
            if (this.isInputValid()) {
                
                //call child component update method to save additionaldetails
                if(!this.isDDE){
                    const objChild = this.template.querySelector('c-additional-financial-component');
                    var valid = objChild.updateApplicantData();
                }

                if((!this.isDDE && valid) || this.isDDE){        
                    if(this.showIndividualSave ==false){
                        if ( (this.isChildEditRecordsPresent == true) && (this.isMainPicklistChanged == true)) {
                            this.handleChildRecordsDeactivation();
                        } else {
                            this.renderEditViewTemplate();
                        }
                    }
                    //bre run check
                    this.breRunMaterialFields();
                    
                    this.template.querySelector('lightning-record-edit-form').submit(fields);
                    this.handleUpdateTypeOfEmployment();
                    
                    
                    if (this.templateName == 'Documented_Without_Audited_financial' || this.templateName == 'Salaried_Document') { //address check should be there
                        this.handleGradeLogic();
                    }
                }
                

            }
        let masterData = this.profilingData;
         for (var key in masterData){
             if( masterData[key].Name == this.employmentEditValue ){ // &&  masterData[key].RecordType.Name == 'RT - Employment' && masterData[key].Sector__r.Name == this.sectorEditValue && masterData[key].Industry__r.Name == this.industryEditValue &&  masterData[key].Sub_Industry__r.Name == this.subIndustryEditValue
                this.riskIdentified = masterData[key].Risk__c;
            }
        }

        if(this.selectedApplicantData.Loan__r.RecordType.Name=='Four Wheeler'){
            if(this.selectedApplicantData.High_risk_Profile__c?.includes('Politician')){
                this.riskIdentified = 'High';
            }
            else{
                for (var key in masterData){
                    if(masterData[key].Name == this.typeofEmployment && masterData[key].RecordType.Name == 'RT - Employment Type' && masterData[key].Sector__r.Name == this.sectorEditValue && masterData[key].Industry__r.Name == this.industryEditValue &&  masterData[key].Sub_Industry__r.Name == this.subIndustryEditValue ){ 
                        this.riskIdentified = masterData[key].Risk__c;
                    }
                }
            }

        }
        if(this.customerType =='Non Individual' && this.selectedApplicantData.Loan__r.RecordType.Name=='Four Wheeler'){    
            let masterData = this.profilingData;
            for (var key in masterData){
             if(masterData[key].Name == 'Business' && masterData[key].Sector__r.Name == this.sectorEditValue && masterData[key].Industry__r.Name == this.industryEditValue &&  masterData[key].Sub_Industry__r.Name == this.subIndustryEditValue){ // &&  masterData[key].RecordType.Name == 'RT - Employment' 
                this.riskIdentified = masterData[key].Risk__c;
            }
           }
            if(this.selectedApplicant.Politically_Exposed_Person__c=='Yes'){
                this.riskIdentified = 'High';
            }
            
        }
        if(this.isInputValid){
            this.updateApplicant()
        }
        this.handleApplicantRisk();
    }

    updateApplicant(){
        if(this.isInputValid){
            var fields = { Id: this.applicantId, Financial_Details_Fetched_from_BSA__c: this.docVerified}
            const recordInput = { fields };
            updateRecord(recordInput).then(() => {
            }).catch((error=>{
            }))        
        }
    }

    handleChildRecordsDeactivation() {
        this.isChildEditRecordsPresent = false;
        deactivateChildFinancials({
            recordId: this.applicantFinancialId
        }).then((data) => {
            this.showMessage('Record Deleted Successfully', 'success');
            this.isChildEditRecordsPresent = false;
            this.renderEditViewTemplate();
            this.salariedData.length = 0;
            this.assessedData.length = 0;
            this.auditedData.length = 0;
            this.withoutauditedData.length = 0;
            this.other.length = 0;
            this.isLoading = false;
        }).catch((error) => {
            this.isLoading = false;
        })
    }

    handleSuccess(event) {
        if(!this.isEditRestricted){
            this.showMessage('Record Updated Successfully', 'success');
        }
        if (this.isDDE == true &&  (this.showIndividualSave == true)) {
            this.handleRender();
            this.editFinancials = false;
            this.showViewForm = true;
        }
        if ( (this.isDDE == false) &&  (this.showIndividualSave == true)) { //testing
            this.handleRender();
            this.editFinancials = false;
            this.showViewForm = true;
        }
        this.getApplicantSummaryData();
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
   
    navigateToHome(event) {
        this.showEditViewChildTemplates = false;
        this.showModal = false;
        this.handleMonthIncomeParent();
        this.getInitialData();
        this.editFinancials = false;
        this.showViewForm = true;
        let template = event.detail.template;
        let redirect = event.detail.redirect;
        if (template == 'salary') {
            this.renderSalaryTemplate = redirect;
            this.docVerified=event.detail.docVerified
            this.updateApplicant()
        } else if (template == 'assessed') {
            this.renderAssessed = redirect;
        } else if (template == "documentaudited") {
            this.renderDocAuditedTemplate = redirect;
        } else if (template == 'withoutaudited') {
            this.renderWithoutDocAuditedTemplate = redirect;
        } else if (template == 'farmer') {
            this.renderFarmerTemplate = redirect;
        } else if (template == 'other') {
            this.renderOtherTemplate = redirect;
            this.showOtherIncomeSection = redirect;
            this.handleResetAttributes();
        }
        this.showUploadFiles = true
        this.handleReject();
        this.handleRender();
        let timeout = setTimeout(() => {
            this.template.querySelector('c-foir-finance-component').getDetails(this.loanId); 
        },2000);
    }

    handleOkay() {
        this.showOtherIncomeSection = true;
        this.showModal = false;
    }

    handleReject() {
        this.handleMonthIncomeParent();
        this.showOtherIncomeSection = false;
        this.showModal = false;
        this.showChildTemplates = false;
        let timeout = setTimeout(() => {
            this.handleRender();
        },1000);
        const payload = { recordIdOfSobject: this.loanId, refreshPage: 'Yes'}; 
        publish(this.messageContext, pageRefreshOnMaterialFieldChange, payload);
      
    }

    displayAverageMonthSalary(event) {
        if (!this.monthlyVal) {
            this.monthlyVal = event.detail.toFixed(2);
        }
    }

    handleFetchDetails() {
        this.template.querySelector("c-upload-multiple-files").handleFetchDetails();
    }

    handleCartMonthlyIncome(event) {
        const cartIncome = event.detail
        //changes done 3838
        if(!this.docVerified && ((this.monthlyVal && this.monthlyVal!='') || (this.monthlyEditIncome && this.monthlyEditIncome!=''))){
            this.docVerified = false;
        }else{
            this.cartMonthlyIncomeData = cartIncome;
            var month1 = (this.cartMonthlyIncomeData[0] && this.cartMonthlyIncomeData[0].salaryAmount) ? parseFloat(this.cartMonthlyIncomeData[0].salaryAmount) : 0
            var month2 = (this.cartMonthlyIncomeData[1] && this.cartMonthlyIncomeData[1].salaryAmount) ? parseFloat(this.cartMonthlyIncomeData[1].salaryAmount) : 0
            var month3 = (this.cartMonthlyIncomeData[2] && this.cartMonthlyIncomeData[2].salaryAmount) ? parseFloat(this.cartMonthlyIncomeData[2].salaryAmount) : 0
            this.monthlyVal = ((month1 + month2 + month3) / 3).toFixed(2)
            this.monthlyVal = this.monthlyVal?parseFloat(this.monthlyVal):0
            this.monthlyEditIncome = this.monthlyVal
            this.financialRecord.Monthly_Income__c = this.monthlyVal;
            let target = {name:'Monthly_Income__c',value:this.monthlyVal}
            let event = {target}
            this.handleChange(event)
            this.setDocVerified(true)
            if(this.boolTwoWheeler == true){
                this.gradeValue =='IB';
            }else{
                this.handleIBorNIBGradeCalculation();
            }
            this.populateData = true;
            this.docVerified = true;
        }
        
        if( this.editFinancials == true){
            if(this.monthlyEditIncome ==0){
                this.monthlyEditIncome =  this.monthlyVal; //SFAU-3072 
                if(this.boolTwoWheeler == true){
                    this.gradeValue =='IB';
                }else{
                    this.handleIBorNIBGradeCalculation();
                }
            }else{
                //this.docVerified = false; Neha-3838
            }
        }
        this.bankStatementUploaded = true; //SFAU-4931
    }

    handleEnableFetchDetails(event) {
        if (event.detail){
            this.fetchDetails = true;
        }else{
            this.fetchDetails = false;  
        }
    }
    deleteContentDocument(event){
        //Neha-3838
        if(this.docVerified){
            this.monthlyVal=0
            this.financialRecord.Monthly_Income__c=0
            this.monthlyEditIncome=0
            let target = {name:'Monthly_Income__c',value:''}
            let event = {target}
            this.handleChange(event)
            this.docVerified = false;
        }
       
    }
    handleShowEditView(event) {
        this.showUploadFiles = event.detail;
        this.showEditViewChildTemplates = event.detail;
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Records Updated Successfully',
                variant: 'success'
            })
        );
        this.handleRender();
        this.handleMonthIncomeParent();
    }

    handleCancel() {
        this.isLoading = true;
        this.editFinancials = false;
        this.showViewForm = true;
        this.isLoading = false;
        this.isCompanyOther =false;
    }

    renderEditViewTemplate() {
        if (this.loanStage == 'DDE') {
                this.handleEditViewLogic();
        } else {
            this.handleEditViewLogic();
        }
    }
    handleEditViewLogic() {
        if (this.isChildEditRecordsPresent == true) {
            this.showEditViewChildTemplates = true;
        } else {
            this.showChildTemplates = true;
            this.handleTemplateConditions();
        }
        this.editFinancials = false;
    }

    getApplicantSummaryData() {
        this.isLoading = true;
        getSummaryDetails({
                loanId: this.loanId
            })
            .then(data => {
                if (data) {
                    this.applicantsSummaryData = data;
                    this.showSummary = true;
                } else {
                    this.showSummary = false;
                }
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
            })
    }
    handleLookupSelect(event) {
     
        if (event.detail.value != undefined) {
            let selectedValue = event.detail.value;
            let selectedName = event.detail.name;
            let fieldName = event.detail.fieldapi;
            let objectName = event.detail.objApiName;
            if (fieldName !== null && selectedName !== null) {
               this.financialRecord.Company_Name__c = selectedName;
               this.financialRecord.Company_Master__c = selectedValue;
               this.companyDefaultId =selectedValue;
               this.companyOptionsValue = selectedName;
               if(selectedName == 'Others'){
                this.isCompanyOther = true;
               }else{
                this.isCompanyOther = false;
               }
            }
        }

    }
    handleBankStatementUploaded() {
        this.bankStatementUploaded = true;
        this.gradeValue = 'IB';
    }
    breRunMaterialFields(){
        let screenType= 'Financial Details';
        checkMaterialFields({
            strScreen: screenType,
            strLoanId: this.loanId, //this.recordId
            lstFieldsAPI : this.breTrackingFieldList

        }).then(data => {
        })
        .catch(error => {
        })
    }

    async disableFieldsAsPerMetadata(){
        const fieldsToBeDisabled = await getMaterialFields({strScreen:'Financial Details',strLoanId:this.loanId});
        if(fieldsToBeDisabled){
            fieldsToBeDisabled.forEach((input=>{
                    if(this.template.querySelectorAll('[data-name="'+input+'"]')){
                        this.template.querySelectorAll('[data-name="'+input+'"]').forEach((inputToBeDisabled=>{
                                inputToBeDisabled.disabled = true
                        }))
                    }
            }))
        }
    }
    handleOtherIncomeInsertion(event){ //jul8
        if(event.detail.template=='salary'){
            this.docVerified=event.detail.docVerified
            this.updateApplicant()
        }
        
        this.showModal = true;
    }

    handleInputCompanyName(event){
        this.financialRecord.Company_Name__c = event.detail.value;
        this.othCompName =  event.detail.value;
    }
    addEventHandler(event){
        if(event.detail.screen == 'New'){
            this.employmentEditVal = 'Salaried - Private';
            this.financialRecord.Type_Of_Employment__c = 'Salaried - Private';
            this.employmentValue =  'Salaried - Private';
        }
        else if(event.detail.screen == 'Edit'){
            this.employmentEditVal = 'Salaried - Private';
            this.employmentValue =  'Salaried - Private';
            this.employmentEditValue = this.employmentEditVal;
            this.financialRecord.Type_Of_Employment__c  = this.employmentEditVal;
        }
        if(event.detail.auval == 'Yes'){
            this.isSalaried = true;
            this.isAuemployee = true;
            this.elgibityVal = 'Yes';
            this.incomeElgibilityDisable = false;
            this.handleAUCalculations();
        }else{
            this.isAuemployee = false;
            this.readAlways = false;
        this.cmpValue = '';
        this.employmentValue='';
        this.employmentEditVal='';
        this.assesmentVal = '';
        this.templateName = '';
        this.isCompanyReadOnly = false;
        this.isCompanyOther = false;
        if(this.companyOptionsValue=='Others'){
            this.isCompanyOther = true;
            this.companyOptionsValue = '';
        }
        }
    }
}