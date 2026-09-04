import { LightningElement, track, wire, api } from 'lwc';
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';
import FORMFACTOR from '@salesforce/client/formFactor'
import FINANCIAL_OBJECT from '@salesforce/schema/Applicant_Financials_Details__c';
import LOAN_APPLICATION_OBJECT from '@salesforce/schema/Loan_Application__c';
import getEmploymentType from '@salesforce/apex/financeController.getEmploymentType'
import getRelatedProfilingMaster from '@salesforce/apex/financeController.getRelatedProfilingMaster'
import getFinancialWrapper from '@salesforce/apex/FinancialViewTemplateR2Controller.getFinancialWrapper'
import upsertIncome from '@salesforce/apex/AgricultureIncomeDetailsController.upsertIncome'
import getCurrentUserDetails from '@salesforce/apex/FinancialViewTemplateR2Controller.getCurrentUserDetails'
import getViabilityTemplatesMapping from '@salesforce/apex/FinancialViewTemplateR2Controller.getViabilityTemplatesMapping'
import deactiveExistingFinancials from '@salesforce/apex/FinancialViewTemplateR2Controller.deactiveExistingFinancials'
import { toastWithMessage, farmerCheck, validate,getVisibleFields,getUniqueValue,getApplicantName,setPicklistsValues, addMonths, STAGE_FTB, STAGE_FTU, showToastMessage } from 'c/lwcutilities';
import getRevisitScreens from '@salesforce/apex/FinancialViewTemplateR2Controller.getRevisitScreens'
import updateRelatedApplicant from '@salesforce/apex/FinancialViewTemplateR2Controller.updateRelatedApplicant'
import updateRelatedApplicants from '@salesforce/apex/FinancialViewTemplateR2Controller.updateRelatedApplicants'
import updateLoanApp from '@salesforce/apex/FinancialViewTemplateR2Controller.updateLoanApp';
import { getSpinnerImage } from 'c/customSpinner';
import getMaterialFields from '@salesforce/apex/Utility.getMaterialFields';
import checkMaterialFields from '@salesforce/apex/Utility.checkMaterialFields';
import newDLIssuedInfoMessage from '@salesforce/label/c.FTUCustomerBasedOnDLIssuedDate';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
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

const APPLICABLE_DL_ISSUE_GRADE_TYPES = [ 'Commercial_Vehicle', 'Construction_Equipment' ];
const X3W_COLLATERAL_TYPES = [ '10106', '10107' ];

export default class FinancialViewTemplateCommercial extends LightningElement {
    //list and string Attributes
    @track unitOptions;
    @track employmentTypeOptions;
    @track fleetEligibilityOptions;
    @track incomeEligibilityOptions;
    @track customerSegOptions;
    @track landOptions;
    @track subGradeOptions;
    @track refinedsubGradeOptionsOptions
    @track agriOwnedByOptions;
    @track parentFinancialRecord = {}
    @track applicantsData;
    @track loanStage;
    @track currentApplicantId
    @track currentApplicant
    @track sectorOptions
    @track industryOptions
    @track subIndustryOptions
    @track occupationOptions
    @track parentRecordTypeId
    @track loanApplication = {}
    @track allParentFinancials
    @track loanRecordTypeId
    @track customerGradeOptions
    @track primaryApplicant
    @track currentUser
    @track profileMasterData = []
    @track assesmentOptions = []
    breTrackingFieldList=[];
    @track coApplicants=[]
    @track typeofEmployment;
    @track applicantFinancialId; //to store the parent FinancialsId 
    @track applicantRecType; // to store the applicant recordtype
    @track pickListValues;
    @track viabilityData;
    @track applicantId
    @track readAlways= false;
    @track activeSubSections =['A','B','C'];
    @track displaylandFields=false;
    @track isDataUpdated=false;

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
    @track isLoading;
    incomeElgibilityDisable = false;
    @track isapplicantData=false;
    @api recordId;
    //Boolean Attributes
    @track isboolFamily = false;
    @track isfarmer = false; // Type of Employment - Farmer Flag
    @track isDDE; // identifier for DDE Stage
    @track isQDE; // identifier for DDE Stage
    @track  isChildTemplates = false; //identifier for to show child templates 
    @track displayAgriPicklist = false;
    @track isSubGrade = false;
    @track isDeactivateTemplates = false;
    @track istypeofEmpDisabled =false;
    @track isCmpNameDisabled =false;
    @track reVisitScreen
    @track screens
    @track screenType;
    @track isMobile;
    @track initiaLoanApplication;
    showWorkExperienceField = true;
    isSalaried = false;
    messageContext = createMessageContext();
    isGradeApplicable = false;
   async connectedCallback() {
        if (FORMFACTOR == 'Small') {
            this.isMobile = true
        } else {
            this.isMobile = false
        }
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.recordId);
        }
        this.disableFieldsAsPerMetadata();
    }

    async disableFieldsAsPerMetadata(){
        this.fieldsToBeDisabled = await getMaterialFields({strScreen:'Land Details',strLoanId:this.loanId});
        if(this.fieldsToBeDisabled){
            this.fieldsToBeDisabled.forEach((input=>{
                if(this.template.querySelectorAll('[data-name="'+input+'"]')){
                    this.template.querySelectorAll('[data-name="'+input+'"]').forEach((inputToBeDisabled=>{
                        inputToBeDisabled.disabled = true
                    }))
                }
            }))
        }
        this.isLoading=false
    }

    // Set intial values
    @api
    renderValuesPredefined(selectedId, applicantData) {
        
        this.isLoading=true
        this.applicantsData = applicantData;
        this.loanStage = applicantData[0].Loan__r.Stage__c;
        this.currentApplicantId = selectedId
        this.isapplicantData =false;
        this.primaryApplicant='';
        this.coApplicants=[];
        applicantData.forEach(input => {
            if (input.Id == this.currentApplicantId) {
                //this.currentApplicant = input
                this.currentApplicant = JSON.parse(JSON.stringify(input))
            }
            if (input.RecordType.DeveloperName == 'Primary_Applicant') {
               // this.primaryApplicant = input
               this.primaryApplicant = JSON.parse(JSON.stringify(input))
            }
            if(input.RecordType.DeveloperName=='Co_Applicant'){
                this.coApplicants.push(input)
            }
        })

        //console.log('this.currentApplicant-->' + JSON.stringify(this.currentApplicant));
         setTimeout(() => {
                     this.loanStage != 'QDE' ? this.isDDE = true : false;
                     this.loanStage == 'QDE' ? this.isQDE = true : false;
                     this.isapplicantData =true;
                  }, 400);
       
        this.setInitialData()
    }


    //get the parent financial record type
    @wire(getObjectInfo, { objectApiName: FINANCIAL_OBJECT })
    objectInfo({ data, error }) {
        if (data) {
            console.log('inside farmer financial getObj Info')
            const rtis = data.recordTypeInfos;
            this.parentRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Financial Parent');
        }
    }

    //get picklist values for all picklistFields
    @wire(getPicklistValuesByRecordType, { objectApiName: FINANCIAL_OBJECT, recordTypeId: '$parentRecordTypeId' })
    financialPicklists({ error, data }) {
        var picklistMap = new Map()
        if (data) {
            picklistMap = data.picklistFieldValues
            this.fleetEligibilityOptions = picklistMap['Consider_Fleet_for_Eligibility__c'].values
            this.incomeEligibilityOptions = picklistMap['Consider_Income_for_Eligibility__c'].values
            this.customerGradeOptions = picklistMap['Customer_Grade__c'].values
            this.subGradeOptions = picklistMap['Sub_Grade__c'].values
            this.refinedsubGradeOptionsOptions = picklistMap['Sub_Grade__c'].values
            this.customerSegOptions = picklistMap['Customer_Segment__c'].values
            this.landOptions = picklistMap['Unit_Land_Area__c'].values
            //this.unitOptions = picklistMap['Unit_Land_Area__c'].values
            this.agriOwnedByOptions = picklistMap['Agri_Owned_By__c'].values
        }
    }


    // set intial date when component loads
    async setInitialData() {
        
        const data = await getViabilityTemplatesMapping();
        this.viabilityData = data;
        const optionsListData = await getEmploymentType({ entityType: this.currentApplicant.Customer_Type__c })
        
        this.profileMasterData = optionsListData;
       
        let options = [];
        let tempList = new Set();
        let optionsList = Array.from(optionsListData)

        // Salaried Option should not be available for Applicant
        if (optionsList && optionsList.length > 0) {
            optionsList.forEach(input => {
                const employmentType = input.Type_of_Employment__c;
                const isPrimaryApplicant = this.currentApplicant.RecordType.DeveloperName === 'Primary_Applicant';
                this.isGradeApplicable = (isPrimaryApplicant == true) ? true : false; // R2-2818
                if (!tempList.has(employmentType)) {
                    if (isPrimaryApplicant && (employmentType !== 'Salaried - Private' && employmentType !== 'Salaried - Government')) {
                        options.push({ label: employmentType, value: employmentType });
                    } else if (!isPrimaryApplicant) {
                        options.push({ label: employmentType, value: employmentType });
                    }
                    tempList.add(employmentType);

                }
            });
             this.employmentTypeOptions = options
            let AUEmployee = this.currentApplicant.AU_Employee__c;
            if(AUEmployee == 'Yes'){
                this.assesmentOptions.push({ label:'Salaried', value: 'Salaried' })
                 this.employmentTypeOptions.push({ label:'Salaried - Private', value: 'Salaried - Private' })
                 this.parentFinancialRecord.Type_Of_Employment__c = 'Salaried - Private';
                 this.parentFinancialRecord.Method_Of_Assesment__c='Salaried'
                 this.parentFinancialRecord.Company_Name__c = 'AU Small Finance bank';
                 this.readAlways=true;
            }else{
                this.readAlways = false;
            }
        }

        const response = await getFinancialWrapper({ applicantId: this.currentApplicantId, applicants: this.applicantsData })
        console.log('response-->' +JSON.stringify(response));
        this.pickListValues = response.picklistValues
        this.parentFinancialRecord = response && response.parentFinancial ? JSON.parse(JSON.stringify(response.parentFinancial)) : {}
        this.applicantFinancialId = this.parentFinancialRecord ? this.parentFinancialRecord.Id :'';
        this.screenType = this.applicantFinancialId ? 'Edit' : 'New';
        this.loanApplication = response && response.relatedLoan ? response.relatedLoan : {}
        this.initiaLoanApplication = JSON.parse(JSON.stringify(this.loanApplication))
        this.isfarmer = farmerCheck(this.parentFinancialRecord.Type_Of_Employment__c);
        if (this.isfarmer == false) {
            this.handleCheckFarmerValidation('remove');
        } else {
            this.handleCheckFarmerValidation('add');
        }
        let screenResp = await getRevisitScreens({loanId: this.loanApplication.Id})
        let key = this.currentApplicant.RecordType.Name+'_'+this.currentApplicant.Customer_Name__c
        this.screens = screenResp[key]?screenResp[key]:''
        if(this.screens.includes('Financial;')){
            this.reVisitScreen = true
            if(this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c){
                toastWithMessage(this, "", "warning", "Relationship with Applicant was changed. Please update the Customer Details again", "sticky");
            }
        }
        let employmentType=this.parentFinancialRecord.Type_Of_Employment__c
        this.getMethodOfAssessmentOptions(this.parentFinancialRecord.Type_Of_Employment__c);
         //Work experience
        if(this.parentFinancialRecord.Type_Of_Employment__c == 'Salaried - Private' ||this.parentFinancialRecord.Type_Of_Employment__c =='Salaried - Government'|| this.parentFinancialRecord.Type_Of_Employment__c =='Self Employed Non-Professional' || this.parentFinancialRecord.Type_Of_Employment__c == 'Self Employed Professional' || this.parentFinancialRecord.Type_Of_Employment__c =='Business'  ){
            this.showWorkExperienceField =true;
            if(employmentType == 'Salaried - Private' || employmentType == 'Salaried - Government'){
                this.isSalaried = true;
            }else{
                this.isSalaried = false;
            }
        }else{
            this.showWorkExperienceField =false;
            this.isSalaried = false;
        }
        let sector=this.parentFinancialRecord.Sector__c
        let industry=this.parentFinancialRecord.Industry__c
        let subIndustry=this.parentFinancialRecord.Sub_Industry__c
        let occupation=this.parentFinancialRecord.Occupation__c
        this.handlegetRelatedPicklistValues('Type_Of_Employment__c', employmentType, 'RT - Employment Type', 'RT - Sector','');  
        this.handlegetRelatedPicklistValues('Sector__c', sector, 'RT - Sector', 'RT - Industry',employmentType);
        this.handlegetRelatedPicklistValues('Industry__c', industry, 'RT - Industry', 'RT - Sub Industry',employmentType + '~' +sector);
        this.handlegetRelatedPicklistValues('Sub_Industry__c', subIndustry, 'RT - Sub Industry', 'RT - Occupation',employmentType + '~' + sector + '~' + industry);
        this.handlegetRelatedPicklistValues('Occupation__c', occupation, 'RT - Occupation', 'RT - Employment Type',employmentType + '~' + sector + '~' + industry + '~' + subIndustry);
        this.allParentFinancials = response && response.allParentFinancials ? response.allParentFinancials : []
        this.applicantRecType =  this.currentApplicant.RecordType.DeveloperName
        this.currentUser = await getCurrentUserDetails()
        this.setDefaultValueforConsiderFleetForEligibility()
        this.setDefaultValueforConsiderIncomeForEligibility(false)
        this.setCustomerGradeOptions()
        this.handleCheckFamilyAgri('Agri_Owned_By__c', this.parentFinancialRecord.Agri_Owned_By__c);
        this.getSubGradeOptions(false);
        this.isLoading=false
        this.employmentTypeOptions = options
            let AUEmployee = this.currentApplicant.AU_Employee__c;
            if(AUEmployee == 'Yes'){
                this.assesmentOptions.push({ label:'Salaried', value: 'Salaried' })
                 this.employmentTypeOptions.push({ label:'Salaried - Private', value: 'Salaried - Private' })
                 this.parentFinancialRecord.Type_Of_Employment__c = 'Salaried - Private';
                 this.parentFinancialRecord.Method_Of_Assesment__c='Salaried'
                 this.parentFinancialRecord.Company_Name__c = 'AU Small Finance bank';
                 this.readAlways=true;
            }
    }

    async handleChange(event) {
        this.isDataUpdated = true;
        let name = event.target.name
        let value = event.target.value
        this.parentFinancialRecord[name] = value
        if(this.applicantRecType == 'Primary_Applicant' && this.parentFinancialRecord.Consider_Income_for_Eligibility__c == 'No' && name === 'Consider_Income_for_Eligibility__c' && value !== 'Yes' ){
            toastWithMessage(this, "", "Error", "Consider Income For Eligibility cannnot be set to No for Primary Applicant");  
            return;   
        }
        if (name == 'Agri_Owned_By__c' || name == 'Size_of_Agri_Land__c') {
            this.breTrackingFieldList.push('Agri_Owned_By__c');
            this.breTrackingFieldList.push('Agri_Land_in_Acres__c');
            this.handleCheckFamilyAgri(name, value)
        } else if(name == 'Unit_Land_Area__c'){
            this.breTrackingFieldList.push('Agri_Land_in_Acres__c');
            this.handleCheckFamilyAgri('Size_of_Agri_Land__c', this.parentFinancialRecord.Size_of_Agri_Land__c);
        }
        else if(name == 'Consider_Income_for_Eligibility__c'){
            this.breTrackingFieldList.push('Consider_Income_for_Eligibility__c');
        } 
        else if(name == 'Consider_Fleet_for_Eligibility__c'){
            this.breTrackingFieldList.push('Consider_Fleet_for_Eligibility__c');
        } 
        else if (name == 'Customer_Grade__c') {
            value = await this.validateCustomerGradeByDLIssuedDate({ ...this.loanApplication, Customer_Grade__c: value }, this.primaryApplicant );

            this.breTrackingFieldList.push('Customer_Grade__c');
            this.getSubGradeOptions(true);
            this.isDeactivateTemplates = true;
            this.parentFinancialRecord.Customer_Grade__c = value;
            this.parentFinancialRecord.Sub_Grade__c ='';
            this.loanApplication.Sub_Grade__c = ''
            this.loanApplication.Customer_Grade__c = value
        } else if (name == 'Type_Of_Employment__c') {
            this.breTrackingFieldList.push('Type_Of_Employment__c');
            this.assesmentOptions=[]
            this.sectorOptions = []
            this.industryOptions = []
            this.subIndustryOptions = []
            this.occupationOptions = []
            this.parentFinancialRecord.Method_Assesment__c=null;
            this.parentFinancialRecord.Method_Assesment__c='';
            this.parentFinancialRecord.Sector__c='';
            this.parentFinancialRecord.Industry__c='';
            this.parentFinancialRecord.Sub_Industry__c='';
            this.parentFinancialRecord.Occupation__c='';

            this.getMethodOfAssessmentOptions(value);
            this.handlegetRelatedPicklistValues(name, value, 'RT - Employment Type', 'RT - Sector');
            this.isfarmer = farmerCheck(value);
            this.setDefaultValueforConsiderIncomeForEligibility(true)
            if (this.isfarmer == false) {
                this.handleCheckFarmerValidation('remove');
            } else {
                this.handleCheckFarmerValidation('add');
            }
            if(this.isDDE){
                this.handlegetRelatedPicklistValues('Type_Of_Employment__c', value, 'RT - Employment Type', 'RT - Sector','');  
            }
             //Work Experience
            if(value == 'Salaried - Private' || value =='Salaried - Government'|| value =='Self Employed Non-Professional' || value == 'Self Employed Professional' || value =='Business'  ){
                this.showWorkExperienceField =true;
                if(value == 'Salaried - Private' || value =='Salaried - Government'){
                    this.isSalaried = true;
                }else{
                    this.isSalaried = false;
                }
            }else{
                this.showWorkExperienceField =false;
                this.isSalaried = false;
               // this.parentFinancialRecord.Total_Work_Experience__c ='0';
            }
            
            this.isDeactivateTemplates = true
        }else if (name == 'Method_Of_Assesment__c') {
            let record = this.profileMasterData;
            const matchingRecord = record.find((item) =>
            item.Type_of_Employment__c === this.typeofEmployment &&
            item.Method_Assesment__c === value
            );
            console.log('matchingRecord-->' +JSON.stringify(matchingRecord));
            if (matchingRecord) {
                this.templateName = matchingRecord.Financial_Template__c;
            }
            this.isDeactivateTemplates = true

        }else if(name == 'Sector__c') {
            let queryParams = this.parentFinancialRecord.Type_Of_Employment__c;
            this.handlegetRelatedPicklistValues('Sector__c', value, 'RT - Sector', 'RT - Industry', queryParams);
            this.industryOptions=[]
            this.subIndustryOptions=[]
            this.occupationOptions=[]         
        }else if(name == 'Industry__c') {
            let queryParams = this.parentFinancialRecord.Type_Of_Employment__c + '~' +this.parentFinancialRecord.Sector__c
            this.handlegetRelatedPicklistValues('Industry__c', value, 'RT - Industry', 'RT - Sub Industry', queryParams);
            this.subIndustryOptions=[]
            this.occupationOptions=[]    
        }else if(name == 'Sub_Industry__c') {
            let queryParams = this.parentFinancialRecord.Type_Of_Employment__c + '~' + this.parentFinancialRecord.Sector__c + '~' + this.parentFinancialRecord.Industry__c
            this.handlegetRelatedPicklistValues('Sub_Industry__c', value, 'RT - Sub Industry', 'RT - Occupation', queryParams);
            this.occupationOptions=[]
        }else if(name == 'Occupation__c') {
            let queryParams = this.parentFinancialRecord.Type_Of_Employment__c + '~' + this.parentFinancialRecord.Sector__c + '~' + this.parentFinancialRecord.Industry__c+ '~' + this.parentFinancialRecord.Sub_Industry__c
            this.handlegetRelatedPicklistValues('Occupation__c', value, 'RT - Occupation', 'RT - Employment Type', queryParams);
        }else if(name == 'Sub_Grade__c'){
            this.isDeactivateTemplates = true;
            this.loanApplication.Sub_Grade__c = value
        }

       
    }

    getMethodOfAssessmentOptions(picklistVal) {
        this.assesmentOptions = this.profileMasterData
          .filter(record => record.Type_of_Employment__c === picklistVal)
          .map(record => ({
            label: record.Method_Assesment__c,
            value: record.Method_Assesment__c
          }));
      }
      
    handleCheckFamilyAgri(fieldName, fieldValue) {
        if(fieldValue!=null && fieldValue!=''){
            this.displaylandFields=true;
            if (fieldName == 'Agri_Owned_By__c') {
                if (fieldValue == 'Family other than Co-applicant') {
                    this.isboolFamily = true;
                    this.displayAgriPicklist=false
                }else if(fieldValue.includes('COB')){
                    if(this.coApplicants && this.coApplicants.length>0){
                        this.displayAgriPicklist=true
                        this.isboolFamily = false;
                        let options=[]
                        this.coApplicants.forEach(input=>{
                            let name = getApplicantName(input)
                            options.push({label: name, value: name})
                        })
                        this.agriOwnedByOtherOptions = getUniqueValue(options)
                        if(this.coApplicants.length==1){
                            this.parentFinancialRecord.Agri_Owned_By_Other__c = getApplicantName(this.coApplicants[0])
                        }
                    }else{
                        this.displayAgriPicklist=false
                        this.isboolFamily = false;
                    }
                } else if(fieldValue.includes('Landless')){
                    this.displaylandFields=false;
                    this.isboolFamily = false; //R2-2624
                }
                else{
                    this.displayAgriPicklist=false
                    this.isboolFamily = false;
                    this.parentFinancialRecord.Agri_Owned_By_Other__c ='';
                    /*if(!this.template.querySelector('[data-name="Agri Owned By Other"]').classList.contains('slds-hide')){
                        this.template.querySelector('[data-name="Agri Owned By Other"]').classList.add('slds-hide')
                    }*/
                }
            }

            if(fieldName == 'Size_of_Agri_Land__c'){

                let landSizeInAcres;

                if(this.parentFinancialRecord.Unit_Land_Area__c  == 'Hectare'){
                 landSizeInAcres = parseFloat(this.parentFinancialRecord.Size_of_Agri_Land__c) * 2.47;
                }
                 else if(this.parentFinancialRecord.Unit_Land_Area__c  == 'Acre'){
                 landSizeInAcres = parseFloat(this.parentFinancialRecord.Size_of_Agri_Land__c);
                 }
                 else if(this.parentFinancialRecord.Unit_Land_Area__c  == 'Bigha'){
                    landSizeInAcres = parseFloat(this.parentFinancialRecord.Size_of_Agri_Land__c * 0.619);  
                 }
                 else if(this.parentFinancialRecord.Unit_Land_Area__c  == 'Killa'){
                    landSizeInAcres = parseFloat(this.parentFinancialRecord.Size_of_Agri_Land__c); 
                 }
                 else if(this.parentFinancialRecord.Unit_Land_Area__c  == 'Canal'){
                    landSizeInAcres = parseFloat(this.parentFinancialRecord.Size_of_Agri_Land__c * 0.124); 
                 }

                 this.parentFinancialRecord.Agri_Land_in_Acres__c = landSizeInAcres;

            }
        }
       
    }

    //Method to add/remove the validation class for farmer related fields based on conditions
    handleCheckFarmerValidation(operation) {
        const comboboxElements = this.template.querySelectorAll('lightning-combobox[data-name="agri"]');
        if (comboboxElements.length > 0) {
            comboboxElements.forEach((comboboxElement) => {
                if (operation == 'remove') {
                    comboboxElement.classList.remove('validate');
                } else {
                    if (!comboboxElement.classList.contains('validate')) {
                        comboboxElement.classList.add('validate');
                    }
                }
            });
        }
    }
    //Method to set customer grade options based on recordtype
    setCustomerGradeOptions(){
        if(this.loanApplication.RecordType.DeveloperName == 'Commercial_Vehicle'){
            this.customerGradeOptions = setPicklistsValues(this.pickListValues.Customer_Grade_Commercial_Vehicle.split(','))
        } else if(this.loanApplication.RecordType.DeveloperName == 'Construction_Equipment'){
            this.customerGradeOptions = setPicklistsValues(this.pickListValues.Customer_Grade_Construction_Equipment.split(','))
        }
        
    }
    setDocVerified(value){
        this.docVerified=value
    }
    handleBankStatementUploaded() {
        this.bankStatementUploaded = true;
        this.gradeValue = 'IB';
    }
    deleteContentDocument(event){
        //Neha-3838
        if(this.docVerified){
            this.monthlyVal=0
            this.parentFinancialRecord.Monthly_Income__c=0
            this.monthlyEditIncome=0
            let target = {name:'Monthly_Income__c',value:''}
            let event = {target}
            this.handleChange(event)
            this.docVerified = false;
        }
       
    }
    handleCartMonthlyIncome(event) { //june30
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
            this.parentFinancialRecord.Monthly_Income__c = this.monthlyVal;
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
    handleEnableFetchDetails(event) {
        if (event.detail){
            this.fetchDetails = true;
        }else{
            this.fetchDetails = false;  
        }
    }

    getSubGradeOptions(subGradeCheck) {
        this.isSubGrade = subGradeCheck;
        let data = this.viabilityData;
        let subGradeOptions=[];
        let ceProducts =['10401','10402','10403','10405','10406','10407']
        let currentProduct =this.loanApplication.Product__c
        if(this.loanApplication.Product__c && this.parentFinancialRecord.Customer_Grade__c){
            if(ceProducts.includes(currentProduct)){
                 data.forEach(dataInstance => {
                if (
                         dataInstance.Product__c.includes(this.loanApplication.Product__c) &&
                         dataInstance.Customer_Grade__c.includes(this.parentFinancialRecord.Customer_Grade__c) 
                     ) {
                        if( dataInstance.Sub_Grade__c && dataInstance.Sub_Grade__c.includes(',')){
                         subGradeOptions= setPicklistsValues(dataInstance.Sub_Grade__c.split(','))
                        } else if(dataInstance.Sub_Grade__c && !dataInstance.Sub_Grade__c.includes(',')){
                         subGradeOptions.push({label:dataInstance.Sub_Grade__c,value:dataInstance.Sub_Grade__c})
                        }
                         
                     }
             });
            }else{
                 data.forEach(dataInstance => {
                if (
                         dataInstance.Product__c.includes(this.loanApplication.Product__c) &&
                         dataInstance.Collateral_Type__c.includes(this.loanApplication.Collateral_Type__c) &&
                         dataInstance.Customer_Grade__c.includes(this.parentFinancialRecord.Customer_Grade__c) 
                     ) {
                        if( dataInstance.Sub_Grade__c && dataInstance.Sub_Grade__c.includes(',')){
                         subGradeOptions= setPicklistsValues(dataInstance.Sub_Grade__c.split(','))
                        } else if(dataInstance.Sub_Grade__c && !dataInstance.Sub_Grade__c.includes(',')){
                         subGradeOptions.push({label:dataInstance.Sub_Grade__c,value:dataInstance.Sub_Grade__c})
                        }
                         
                     }
             });
            }
           
             if(subGradeOptions.length==0){
                 this.isSubGrade = false;
                 this.parentFinancialRecord.Sub_Grade__c ='';
             }else{
                this.isSubGrade = true;
             }
             this.refinedsubGradeOptionsOptions = getUniqueValue(subGradeOptions);
        }
    }
    

    handlegetRelatedPicklistValues(picklistName, picklistValue, passType, retType, queryParams) {
        this.isLoading = true;
        getRelatedProfilingMaster({ selectedValue: picklistValue, passingType: passType, returnType: retType, queryParams: queryParams }).then(data => {
            this.profilingData = data;
            let options = [];
            data.forEach(input=>{
                if(input.Name !='Business'){
                    if(this.currentApplicant.Marital_Satus__c  == 'Single' || this.currentApplicant.Gender__c =='Male'){
                        if(input.Name!='Housewife'){
                            options.push({label: input.Name,value: input.Name});
                        }     
                    }else{
                        options.push({label: input.Name, value: input.Name});
                    }
                }
            })
            if(picklistName == 'Type_Of_Employment__c') {
                this.sectorOptions = getUniqueValue(options);
            }
            if(picklistName == 'Sector__c') {
                this.industryOptions = getUniqueValue(options);
            }
            if(picklistName == 'Industry__c') {
                let tempOptions=[];
                data.forEach(input=>{
                    if(input.Sector__r.Name == this.parentFinancialRecord.Sector__c){
                        tempOptions.push({label: input.Name, value: input.Name});
                    }
                })
                this.subIndustryOptions = getUniqueValue(tempOptions);
            }
            if(picklistName == 'Sub_Industry__c') {
                let tempOptions=[];
                data.forEach(input=>{
                    if(input.Industry__r.Name == this.parentFinancialRecord.Industry__c){
                        tempOptions.push({label: input.Name, value: input.Name});
                    }
                })
                this.occupationOptions = getUniqueValue(tempOptions);
            }
            this.isLoading = false;
            
        }).catch(error => {
            this.isLoading = false;
            console.log('error in getRelatedProfilingMaster-->' + JSON.stringify(error));
        })
    }


    handleSave() {
        restricAccess({
            compName: 'financialViewComm' ,loanId: this.loanApplication.Id
            })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    showToastMessage(this, "", "error", "You do not have access to save/edit Viability", "dismissable");
                    /*const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save/edit Payment Favourings',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);*/
                }
                else{
                    let inputFields = this.template.querySelectorAll(".validate");
                    if (validate(inputFields)) {
                        this.isLoading=true
                        if(this.loanStage=='QDE'){
                            const objChild = this.template.querySelector('c-additional-financial-component');
                            var valid = objChild.updateApplicantData( this.parentFinancialRecord?.Type_Of_Employment__c ); //R2-2675 - Single applicant cant have employment type housewife
                        }
                            
                    if (((this.loanStage=='QDE' && valid) || this.loanStage!='QDE')) {
                        this.isChildTemplates = true;
                        this.parentFinancialRecord.RecordTypeId = this.parentRecordTypeId
                        this.parentFinancialRecord.Applicant__c = this.currentApplicantId
                        console.log('this.parentFinancialRecord-->' + JSON.stringify(this.parentFinancialRecord));
                        this.isLoading = true;
                        upsertIncome({ record: this.parentFinancialRecord }).then(data => {
                    
                            toastWithMessage(this, "", "success", "Details Updated Successfully");
                            this.isDataUpdated =false;
                            
                            this.parentFinancialRecord.Id = data.Id
                            this.applicantFinancialId =  data.Id
                            if(this.isDeactivateTemplates){
                                this.deactiveFinancials();
                            }
                            this.updateLoanApp()
                            this.isLoading = false;
                            checkMaterialFields({
                                strScreen: "Land Details",
                                strLoanId: this.loanId, //this.recordId
                                lstFieldsAPI : this.breTrackingFieldList
                    
                            }).then(data => {
                    
                            })
                            .catch(error => {
                                console.log('error in material' + JSON.stringify(error));
                            })
                        }).catch(error => {
                            console.log('Error-> ' +JSON.stringify(error))
                            this.isLoading = false;
                        })
                        }else{
                            this.isLoading=false
                            showToastMessage(this, "", "error", "Please fill Mandatory Details", "sticky");
                        }
                        
                    }
                }
            })
            .catch(error=>{
                console.log('error is ' + JSON.stringify(error));

            })
     }
    // set default for Consider Fleet Picklist based on the applicant and relation combination
   /* setDefaultValueforConsiderFleetForEligibility(){
        if(!this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c ||  this.reVisitScreen){
            if(this.applicantRecType == 'Primary_Applicant'){
                this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c='Yes'
            }else if(this.applicantRecType=='Guarantor' || this.applicantRecType=='Co_Applicant'){
                let relations =[]
                if(this.primaryApplicant.Customer_Type__c=='Individual'){
                    if(this.primaryApplicant.Gender__c=='Female'){
                        relations = ['FATHER IN LAW','HUSBAND','SON','DAUGHTER','MOTHER IN LAW','GRAND FATHER IN LAW','GRAND MOTHER IN LAW','BROTHER']
                    }else{
                        relations = ['FATHER','MOTHER','GRAND FATHER','GRAND MOTHER','HUSBAND','SON','DAUGHTER','BROTHER']
                    }
                }else if(this.primaryApplicant.Customer_Type__c=='Non Individual'){
                    relations = ['PARTNER','DIRECTOR','TRUSTEE']
                }
                if(relations.includes(this.currentApplicant.Relationship_with_applicant__c.toUpperCase())){
                    if(this.currentApplicant.Relationship_with_applicant__c.toUpperCase()=='BROTHER'){
                        if(this.applicantRecType=='Co_Applicant'){
                            this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c='Yes'
                        }else if(this.applicantRecType=='Guarantor'){
                            this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c='No'
                        }
                    }else if(this.currentApplicant.Relationship_with_applicant__c.toUpperCase()=='DAUGHTER'){
                        if(this.currentApplicant.Marital_Satus__c=='Single'){
                            this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c='Yes'
                        }else{
                            this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c='No'
                        }
                    }else{
                        this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c='Yes'
                    }
                    
                }else{
                    this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c='No'
                }
            }
        }
        if(this.applicantRecType=='Co_Applicant' && this.currentUser.Profile.Name=='Credit Manager'){
            if(this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c=='No'){
                this.template.querySelector('[data-name="Consider_Fleet_for_Eligibility__c"]').disabled=false
            }else if(this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c=='Yes'){
                this.template.querySelector('[data-name="Consider_Fleet_for_Eligibility__c"]').disabled=true
            }
        }
    }*/

    setDefaultValueforConsiderFleetForEligibility(){
        if(this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c!=null){
            if(this.applicantRecType == 'Primary_Applicant'){
            this.template.querySelector('[data-name="Consider_Fleet_for_Eligibility__c"]').disabled=true;
            }else{
                this.template.querySelector('[data-name="Consider_Fleet_for_Eligibility__c"]').disabled=false;  
            }
        }else{
             //this.template.querySelector('[data-name="Consider_Fleet_for_Eligibility__c"]').disabled=false;
             if(this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c || this.reVisitScreen){
            if(this.applicantRecType == 'Primary_Applicant'){
                this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c='Yes'
                this.template.querySelector('[data-name="Consider_Fleet_for_Eligibility__c"]').disabled=true;
            }else if(this.applicantRecType=='Guarantor' || this.applicantRecType=='Co_Applicant'){
                this.template.querySelector('[data-name="Consider_Fleet_for_Eligibility__c"]').disabled=false;
                let relations =[]
                if(this.currentApplicant.Customer_Type__c=='Individual'){
                    if(this.primaryApplicant.Gender__c=='Female'){
                        if(this.primaryApplicant.Marital_Status__c=='Married'){
                            relations = ['FATHER IN LAW','HUSBAND','SON','DAUGHTER','MOTHER IN LAW','GRAND FATHER IN LAW','GRAND MOTHER IN LAW','BROTHER','WIFE','SPOUSE']
                        }else{
                            relations = ['FATHER','SON','DAUGHTER','MOTHER','GRAND FATHER','GRAND MOTHER','BROTHER','WIFE','SPOUSE']
                        }
                    }else{
                        relations = ['FATHER','MOTHER','GRAND FATHER','GRAND MOTHER','HUSBAND','SON','DAUGHTER','BROTHER','DAUGHTER IN LAW','WIFE','SPOUSE']
                    }
                }else if(this.currentApplicant.Customer_Type__c=='Non Individual'){
                    relations = ['KARTA','DIRECTOR','PROPRIETOR','PARTNER','TRUSTEE','SHAREHOLDER']
                }
                if(relations.includes(this.currentApplicant.Relationship_with_applicant__c.toUpperCase())){
                    if(this.currentApplicant.Relationship_with_applicant__c.toUpperCase()=='BROTHER'){
                        if(this.applicantRecType=='Co_Applicant'){
                            this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c='Yes'
                        }else if(this.applicantRecType=='Guarantor'){
                            this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c='No'
                        }
                    }else if(this.currentApplicant.Relationship_with_applicant__c.toUpperCase()=='DAUGHTER'){
                        if(this.currentApplicant.Marital_Status__c=='Single'){
                            this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c='Yes'
                        }else{
                            this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c='No'
                        }
                    }
                    else{
                        this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c='Yes'
                    }
                }else{
                    this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c='No'
                }
            }else if(this.applicantRecType=='BO'){
                if(!this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c){
                    this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c = 'No'
                }
                if(this.primaryApplicant.Customer_Type__c=='Non Individual'){
                    let relations = ['KARTA','DIRECTOR','PROPRIETOR','PARTNER','TRUSTEE','SHAREHOLDER']
                    if(relations.includes(this.currentApplicant.Relationship_with_applicant__c.toUpperCase())){
                        this.template.querySelector('[data-name="Consider_Fleet_for_Eligibility__c"]').disabled=false
                       // this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c='Yes'
                    }else{
                        this.template.querySelector('[data-name="Consider_Fleet_for_Eligibility__c"]').disabled=true
                    }
                }else{
                    this.template.querySelector('[data-name="Consider_Fleet_for_Eligibility__c"]').disabled=false
                }    
                
            }
        }

        }
       
        if(this.applicantRecType=='Co_Applicant' && this.currentUser.Profile.Name=='Credit Manager'){
            if(this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c=='No'){
                this.template.querySelector('[data-name="Consider_Fleet_for_Eligibility__c"]').disabled=false
            }else if(this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c=='Yes'){
                this.template.querySelector('[data-name="Consider_Fleet_for_Eligibility__c"]').disabled=true
            }
        }
    }

    
    async updateApplicant(){
        this.isLoading=true
        let updateRelatedMembers=false
        let modifiedApplicant = {Id: this.currentApplicantId, Type_Of_Employment__c: this.parentFinancialRecord.Type_Of_Employment__c,Consider_Fleet_for_Eligibility__c :this.parentFinancialRecord.Consider_Fleet_for_Eligibility__c   } //added Consider fleet on applicant for R2-829
        let screens = this.currentApplicant.Re_Visit_Screens__c?JSON.parse(this.currentApplicant.Re_Visit_Screens__c):new Map()
        if(this.initiaLoanApplication.Customer_Grade__c!=this.loanApplication.Customer_Grade__c && this.loanApplication.RecordType.DeveloperName=='Tractor'){
            screens['LoanDetails']=true
            showToastMessage(this, "", "error", "Please Update Loan Details as Customer Grade has changed", "sticky");
        }
        if(this.reVisitScreen){
            screens['Financial']=false
        }else{
            if(this.currentApplicant.RecordType.DeveloperName=='Primary_Applicant' && this.primaryApplicant.Marital_Status__c!=this.currentApplicant.Marital_Status__c
                && this.currentApplicant.Gender__c=='Female'){
                    updateRelatedMembers=true;
            }
        }
        modifiedApplicant.Re_Visit_Screens__c = JSON.stringify(screens)
        const resp = await updateRelatedApplicant({applicant:modifiedApplicant})
        //const materialFields = await checkMaterialFields({strScreen:'Land Details',strLoanId:this.loanApplication.Id,lstFieldsAPI: this.breReRunFields})
        this.isLoading=false
        if(updateRelatedMembers){
            this.isLoading=true
            const relatedAppl = await updateRelatedApplicants({loanId: this.loanApplication.Id})
            this.isLoading=false
        }
        //if(this.initialLandInAcre!=this.parentFinancialRecord.Agri_Land_in_Acres__c){
            const payload = { recordIdOfSobject: this.loanApplication.Id, refreshPage: 'Yes'};
            publish(this.messageContext, pageRefreshOnMaterialFieldChange, payload);
        //}
    }

    updateLoanApp(){
        updateLoanApp({loan: this.loanApplication}).then((data=>{
            if(data=='Success'){
                this.updateApplicant()
                //toastWithMessage(this, "", "success", "Customer Grade Updated Successfully", "dismissable");
            }else if(data=='Failure'){
                //toastWithMessage(this, "", "error", "Insufficient Access to Loan Application", "sticky");
            }
        })).catch((error=>{
            console.log('error__>' +JSON.stringify(error));
        }))
    }



    //Method to check if child records are there and the templates are changed then deactivating the existing records
    deactiveFinancials(){
        deactiveExistingFinancials({currentApplicantId : this.currentApplicantId})
        .then(data => {
            //console.log('deactivated')
            
        }).catch(error => {
            console.log('Error-> ' +JSON.stringify(error))
        })
    }
    
     /*setDefaultValueforConsiderIncomeForEligibility(){

            if(this.applicantRecType == 'Primary_Applicant'){
                this.parentFinancialRecord.Consider_Income_for_Eligibility__c='Yes'
                this.incomeElgibilityDisable=true
            }
            else if( this.applicantRecType == 'Co_Applicant' ){
                this.parentFinancialRecord.Consider_Income_for_Eligibility__c='Yes' 
                this.incomeElgibilityDisable=false
            
            }else if(this.applicantRecType=='Guarantor' || this.applicantRecType == 'BO'){
                this.parentFinancialRecord.Consider_Income_for_Eligibility__c='No'
                this.incomeElgibilityDisable=false
            }
        
    }*/
    setDefaultValueforConsiderIncomeForEligibility(sentFromChange){
        if(!this.coApplicants || (this.coApplicants && this.coApplicants.length==0)){
           // this.template.querySelector('[data-name="Consider_Income_for_Eligibility__c"]').classList.remove('validate')
          
        }
        if(this.applicantRecType == 'Primary_Applicant'){
            if(!this.parentFinancialRecord.Consider_Income_for_Eligibility__c){
                this.parentFinancialRecord.Consider_Income_for_Eligibility__c='Yes'
            }
            if(this.parentFinancialRecord.Type_Of_Employment__c=='Housewife'){
               // this.template.querySelector('[data-name="Consider_Income_for_Eligibility__c"]').disabled=false
            }else{
               // this.template.querySelector('[data-name="Consider_Income_for_Eligibility__c"]').disabled=true
            }
            if(sentFromChange){
                if(this.parentFinancialRecord.Type_Of_Employment__c=='Unemployed'){
                    this.parentFinancialRecord.Consider_Income_for_Eligibility__c='No'
                }else{
                    this.parentFinancialRecord.Consider_Income_for_Eligibility__c='Yes'
                }
            }
        }else{
           // this.template.querySelector('[data-name="Consider_Income_for_Eligibility__c"]').disabled=false
            if(!this.parentFinancialRecord.Consider_Income_for_Eligibility__c){
                if(this.applicantRecType=='Co_Applicant' &&  !this.parentFinancialRecord.Consider_Income_for_Eligibility__c){
                    this.parentFinancialRecord.Consider_Income_for_Eligibility__c='Yes';
                }else if(this.applicantRecType == 'Guarantor' &&  !this.parentFinancialRecord.Consider_Income_for_Eligibility__c){
                    this.parentFinancialRecord.Consider_Income_for_Eligibility__c='No'
                }else if(this.applicantRecType == 'BO' &&  !this.parentFinancialRecord.Consider_Income_for_Eligibility__c){
                    this.parentFinancialRecord.Consider_Income_for_Eligibility__c='No'
                }
            }       
        }
        this.considerIncome = this.parentFinancialRecord.Consider_Income_for_Eligibility__c=='Yes'?true:false
    }

   /* addEventHandler(event){
      
       if(event.detail.auval == 'Yes'){
          this.employmentTypeOptions.push({ label:'Salaried - Private', value: 'Salaried - Private' })
          this.assesmentOptions.push({ label:'Salaried', value: 'Salaried' })
          this.parentFinancialRecord.Type_Of_Employment__c= 'Salaried - Private';
          this.parentFinancialRecord.Method_Of_Assesment__c= 'Salaried';
          this.parentFinancialRecord.Company_Name__c = 'AU Small Finance bank';
          this.readAlways = true;

        }else{
          this.employmentTypeOptions = this.employmentTypeOptions.filter(option => option.value !== 'Salaried - Private');
          this.parentFinancialRecord.Type_Of_Employment__c= '';
          this.parentFinancialRecord.Method_Of_Assesment__c= '';
          this.parentFinancialRecord.Company_Name__c = '';
          this.readAlways = false;
        }
    }*/
    addEventHandler(event){
        this.isDataUpdated=true;
        let fieldName = event.detail.fieldName
        let fieldValue = event.detail.fieldValue
        this.currentApplicant[fieldName]=fieldValue
        if(fieldName=='Marital_Status__c'){
            this.setDefaultValueforConsiderFleetForEligibility()
        }else if(fieldName=='AU_Employee__c'){
            if(fieldValue=='Yes'){
                this.employmentTypeOptions.push({ label:'Salaried - Private', value: 'Salaried - Private' })
                this.assesmentOptions.push({ label:'Salaried', value: 'Salaried' })
                this.parentFinancialRecord.Type_Of_Employment__c= 'Salaried - Private';
                this.parentFinancialRecord.Method_Of_Assesment__c= 'Salaried';
                this.parentFinancialRecord.Company_Name__c = 'AU Small Finance bank';
                this.readAlways = true;
            }else{
                this.employmentTypeOptions = this.employmentTypeOptions.filter(option => option.value !== 'Salaried - Private' && option.value !== 'Salaried - Government');
                this.parentFinancialRecord.Type_Of_Employment__c= '';
                this.parentFinancialRecord.Method_Of_Assesment__c= '';
                this.parentFinancialRecord.Company_Name__c = '';
                this.readAlways = false;
            }
        }
        
    }
    
    /**
     * R2-788 - Commercial
     * @param {Object} param0 
     * @param {Object} primaryApplicant 
     * @returns 
     */
    async validateCustomerGradeByDLIssuedDate( { Customer_Grade__c: customerGrade, Collateral_Type__c: collateralType, ...loanApp }, primaryApplicant  = { } ){
        const vehicleType = loanApp.RecordType.DeveloperName;
        if( customerGrade !== STAGE_FTB || !APPLICABLE_DL_ISSUE_GRADE_TYPES.includes( vehicleType ) || this.currentUser.Profile.Name === 'Credit Manager' ){
            return customerGrade;
        }

        let isValid = true;
        if( !primaryApplicant.Driving_License_Issue_Date__c ){
            isValid = false;
        } else if( X3W_COLLATERAL_TYPES.includes(collateralType) && addMonths( new Date(), -6 ) < new Date( primaryApplicant.Driving_License_Issue_Date__c ) ){
            isValid = false;
        } else if( addMonths( new Date(), -12 ) < new Date( primaryApplicant.Driving_License_Issue_Date__c ) ){
            isValid = false;
        }
        
        if( !isValid ){
            showToastMessage( this, '', 'info', newDLIssuedInfoMessage , 'sticky' );
            return STAGE_FTU;
        }
        return customerGrade;
    }

     //Work Experience
    get WorkOptions(){
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
      return options;
    }
    //END
}