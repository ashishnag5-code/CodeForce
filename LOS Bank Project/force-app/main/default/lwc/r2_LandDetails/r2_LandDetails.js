import { LightningElement, track, api, wire } from 'lwc';
import { getPicklistValuesByRecordType, getObjectInfo } from 'lightning/uiObjectInfoApi';
import FINANCIAL_OBJECT from '@salesforce/schema/Applicant_Financials_Details__c';
import LOAN_APPLICATION_OBJECT from '@salesforce/schema/Loan_Application__c';
import getRelatedProfilingMaster from '@salesforce/apex/financeController.getRelatedProfilingMaster'
import getFinancialWrapper from '@salesforce/apex/FinancialViewTemplateR2Controller.getFinancialWrapper'
import upsertIncome from '@salesforce/apex/AgricultureIncomeDetailsController.upsertIncome'
import getCurrentUserDetails from '@salesforce/apex/FinancialViewTemplateR2Controller.getCurrentUserDetails'
import { showToastMessage, setPicklistsValues, validate, getUniqueValue, getApplicantName } from 'c/lwcutilities';
import getVisibleFieldsForFinancials from '@salesforce/apex/FinancialViewTemplateR2Controller.getVisibleFieldsForFinancials'
import { getSpinnerImage } from 'c/customSpinner';
import updateLoanApp from '@salesforce/apex/FinancialViewTemplateR2Controller.updateLoanApp';
import checkForFinancials from '@salesforce/apex/FinancialViewTemplateR2Controller.checkForFinancials';
import deactiveExistingFinancials from '@salesforce/apex/FinancialViewTemplateR2Controller.deactiveExistingFinancials'
import updateRelatedApplicant from '@salesforce/apex/FinancialViewTemplateR2Controller.updateRelatedApplicant'
import getRevisitScreens from '@salesforce/apex/FinancialViewTemplateR2Controller.getRevisitScreens'
import updateRelatedApplicants from '@salesforce/apex/FinancialViewTemplateR2Controller.updateRelatedApplicants'
import FORM_FACTOR from '@salesforce/client/formFactor';
import getMaterialFields from '@salesforce/apex/Utility.getMaterialFields';
import checkMaterialFields from '@salesforce/apex/Utility.checkMaterialFields';
import restricAccess from '@salesforce/apex/ComponentProfileRestrictionController.restricAccess';
import getFinancialStatus from '@salesforce/apex/financeController.getFinancialStatus';

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

export default class R2_LandDetails extends LightningElement {

    @api insideRecordPage
    @api recordId;
    messageContext = createMessageContext();
    @track unitOptions;
    @track employmentTypeOptions;
    @track incomeEligibilityOptions;
    @track landEligibilityOptions;
    @track agriOwnedByOptions;
    @track parentFinancialRecord={}
    breReRunFields = [];
    @track applicantsData;
    @track loanStage;
    @track currentApplicantId
    @track currentApplicant
    @track sectorOptions
    @track industryOptions
    @track subIndustryOptions
    @track occupationOptions
    @track parentRecordTypeId
    @track loanApplication={}
    @track allParentFinancials
    @track loanRecordTypeId
    @track customerGradeOptions
    @track methodOfAssessmentOptions;
    @track pickListValues
    @track incomeProfileMaster
    @track primaryApplicant
    @track currentUser
    @track applicantRecType;
    @track considerIncome=false
    @api spinnerImage;
    @track isLoading;
    @track coApplicants=[]
    @track agriOwnedByOtherOptions
    @track displayAgriPicklist
    @track showCompanyDropdown
    @track showCompanyTextBox
    @track companyTextBoxLabel="Company Name"
    @track initialMethodOfAssessment
    @track initialEmploymentType
    @track initialConsiderForIncome
    @track initialLandInAcre
    @track reVisitScreen
    @track screens
    @track activeSections=['A','B'];
    @track loadAdditionalDetails=false
    @track screenType
    @track isMobile=false
    @track initialParentFinancial
    @track initiaLoanApplication
    @track displaylandFields=false;
    @track loadViabilitySheet
    fieldValidations = {
        'Land_Owner_Name__c': /^[a-zA-Z ]+$/
    };
    showWorkExperienceField = true;
    isSalaried = false;

    @api 
    async renderValuesPredefined(selectedId, applicantData){
        if(this.spinnerImage == undefined){
            this.spinnerImage = await getSpinnerImage(this.recordId);
        }
        this.isLoading=true
        this.isMobile = FORM_FACTOR=='Small'?true:false
        this.loadAdditionalDetails=false
        this.coApplicants=[]
        this.applicantsData = applicantData;
        this.applicantsData.forEach(input=>{
            if(input.RecordType.DeveloperName=='Co_Applicant'){
                this.coApplicants.push(input)
            }
            
        })
        this.loanStage  =  applicantData[0].Loan__r.Stage__c;
        this.currentApplicantId = selectedId
        applicantData.forEach(input=>{
            if(input.Id == this.currentApplicantId){
                this.currentApplicant = JSON.parse(JSON.stringify(input))
                this.loadViabilitySheet=true
                if(input.AU_Employee__c=='Yes'){
                    this.showCompanyDropdown=false
                    this.showCompanyTextBox=true
                }
            }
            if(input.RecordType.DeveloperName=='Primary_Applicant'){
                this.primaryApplicant = JSON.parse(JSON.stringify(input))
            }
        })
        this.visibleFields = await getVisibleFieldsForFinancials({strScreen: 'Land Details',strStage: this.loanStage, typeOfWheeler: 'Tractor'})
        this.visibleFields.forEach(input=>{
            this.template.querySelector('[data-id="'+input+'"]').classList.remove('slds-hide')
            this.template.querySelector('[data-name="'+input+'"]').classList.add('validate')
        })
        this.setInitialData()
    }

    @wire(getObjectInfo, { objectApiName: FINANCIAL_OBJECT })
    objectInfo({data, error}){
        if(data){
            console.log('inside farmer financial getObj Info')
            const rtis = data.recordTypeInfos;
            this.parentRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Financial Parent');
        }
    }

    @wire(getObjectInfo, { objectApiName: LOAN_APPLICATION_OBJECT })
    loanInfo({data, error}){
        if(data){
            const rtis = data.recordTypeInfos;
            this.loanRecordTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Tractor');
        }
    }

    allAgriOwnedByOptions=[]
    @wire(getPicklistValuesByRecordType, {objectApiName: FINANCIAL_OBJECT, recordTypeId:'$parentRecordTypeId'})
    financialPicklists({error, data}){
        var picklistMap = new Map()
        if(data){
            picklistMap = data.picklistFieldValues
            this.incomeEligibilityOptions = picklistMap['Consider_Income_for_Eligibility__c'].values
            this.unitOptions = picklistMap['Unit_Land_Area__c'].values
            this.landEligibilityOptions = picklistMap['Consider_Land_for_Eligibility__c'].values
            this.unitOptions = picklistMap['Unit_Land_Area__c'].values
            this.agriOwnedByOptions = picklistMap['Agri_Owned_By__c'].values
            this.allAgriOwnedByOptions = picklistMap['Agri_Owned_By__c'].values
        }
    }

    @wire(getPicklistValuesByRecordType, {objectApiName: LOAN_APPLICATION_OBJECT, recordTypeId:'$loanRecordTypeId'})
    loanPicklists

    async setInitialData(){
        this.currentUser = await getCurrentUserDetails()
        const response = await getFinancialWrapper({applicantId: this.currentApplicantId, applicants: this.applicantsData})
        this.incomeProfileMaster = Array.from(response.profileMasterList)
        this.pickListValues = response.picklistValues
        /*if(this.incomeProfileMaster && this.incomeProfileMaster.length>0){
            let options=[]
            this.incomeProfileMaster.forEach(input=>{
                options.push({label:input.Type_of_Employment__c, value:input.Type_of_Employment__c})
            })
            this.employmentTypeOptions = getUniqueValue(options)
        }*/
        this.parentFinancialRecord = response && response.parentFinancial?response.parentFinancial:{}
        this.initialParentFinancial = JSON.parse(JSON.stringify(this.parentFinancialRecord))
        this.screenType = this.parentFinancialRecord.Id ? 'Edit' : 'New';
        this.loadAdditionalDetails=this.loanStage=='QDE' && this.currentApplicantId?true:false
        this.loanApplication = response && response.relatedLoan?response.relatedLoan:{}
        this.initiaLoanApplication = JSON.parse(JSON.stringify(this.loanApplication))
        let screenResp = await getRevisitScreens({loanId: this.loanApplication.Id})
        let key = this.currentApplicant.RecordType.Name+'_'+this.currentApplicant.Customer_Name__c
        this.screens = screenResp[key]?screenResp[key]:''
        if(this.screens.includes('Financial;')){
            this.reVisitScreen = true
            if(this.parentFinancialRecord.Consider_Land_for_Eligibility__c){
                showToastMessage(this, "", "warning", "Applicant Details were changed. Please update the Land Details again", "sticky");
            }
        }
        this.setTypeOfEmploymentOptions()
        // R2-1684
        /*if(this.loanApplication.Original_Vehicle_Usage__c == 'Agri' && this.currentApplicant.RecordType.DeveloperName=='Primary_Applicant' && this.currentApplicant.Customer_Type__c !== 'Non Individual'){
            this.employmentTypeOptions = this.employmentTypeOptions.filter(function (element) {
                return element.label == 'Farmer';
            });
            this.parentFinancialRecord.Type_Of_Employment__c='Farmer'
        }
        if(this.currentApplicant.RecordType.DeveloperName=='Primary_Applicant' && this.loanApplication.Collateral_Type__c == '10109' && this.currentApplicant.AU_Employee__c!='Yes'){
            this.employmentTypeOptions = this.employmentTypeOptions.filter(function (element) {
                return (element.label != 'Salaried - Private' && element.label != 'Salaried - Government');
            });
        }*///moved to single method
        /* R2-18 -- Primary Applicant with Vehicle Usage Commercial
        if(this.loanApplication.Original_Vehicle_Usage__c == 'Commercial' && this.currentApplicant.RecordType.DeveloperName=='Primary_Applicant'){
            this.employmentTypeOptions = this.employmentTypeOptions.filter(element => element.value === 'Self Employed Non-Professional');
            this.parentFinancialRecord.Type_Of_Employment__c='Self Employed Non-Professional';
        }*///Commented under R2-1680
        let employmentType=this.parentFinancialRecord.Type_Of_Employment__c
        this.initialEmploymentType=employmentType
        this.initialMethodOfAssessment=this.parentFinancialRecord.Method_Of_Assesment__c
        this.initialConsiderForIncome=this.parentFinancialRecord.Consider_Income_for_Eligibility__c
        this.initialLandInAcre=this.parentFinancialRecord.Agri_Land_in_Acres__c
        this.getMethodOfAssessmentOptions()
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
        this.allParentFinancials = response && response.allParentFinancials?response.allParentFinancials:[]
        this.applicantRecType =  this.currentApplicant.RecordType.DeveloperName
        this.setDefaultValueforConsiderIncomeForEligibility(false)
        this.setDefaultValueforConsiderLandForEligibility()
        this.setCustomerGradeOptions()
        this.setAgriOwnedBy(true)
        this.setLandOwner()
        this.setCompanyOptions()
        this.calculateAgriLandInAcres()
        this.disableFieldsAsPerMetadata()
        this.template.querySelectorAll('.disableForAUEmployee').forEach(input=>{
            input.disabled=true
        })
        this.isLoading=false

    }

    async disableFieldsAsPerMetadata(){
        this.fieldsToBeDisabled = await getMaterialFields({strScreen:'Land Details',strLoanId:this.loanApplication.Id});
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

    setLandOwner(){
        /*if(!this.parentFinancialRecord.Land_Owner_Name__c){
            this.template.querySelector('[data-id="Land_Owner_Name__c"]').classList.add('slds-hide')
            this.template.querySelector('[data-name="Land_Owner_Name__c"]').classList.remove('validate')
        }*///R2-57 changes
        if( this.template.querySelector('[data-name="Land_Owner_Name__c"]')){
            this.template.querySelector('[data-name="Land_Owner_Name__c"]').classList.remove('validate')
        }

    }

    setTypeOfEmploymentOptions(){
        if(this.incomeProfileMaster && this.incomeProfileMaster.length>0){
            let options=[]
            this.incomeProfileMaster.forEach(input=>{
                options.push({label:input.Type_of_Employment__c, value:input.Type_of_Employment__c})
            })
            this.employmentTypeOptions=options
            if(this.loanApplication.Original_Vehicle_Usage__c == 'Agri' && this.currentApplicant.RecordType.DeveloperName=='Primary_Applicant' && this.currentApplicant.Customer_Type__c !== 'Non Individual' && this.currentApplicant.AU_Employee__c!='Yes'){
                this.employmentTypeOptions = this.employmentTypeOptions.filter(function (element) {
                    return element.label == 'Farmer';
                });
                this.parentFinancialRecord.Type_Of_Employment__c='Farmer'
            }
            if(this.currentApplicant.RecordType.DeveloperName=='Primary_Applicant' && this.loanApplication.Collateral_Type__c == '10109' && this.currentApplicant.AU_Employee__c!='Yes'){
                this.employmentTypeOptions = this.employmentTypeOptions.filter(function (element) {
                    return (element.label != 'Salaried - Private' && element.label != 'Salaried - Government');
                });
            }
            if(this.currentApplicant.AU_Employee__c=='Yes'){
                this.employmentTypeOptions = []
                this.employmentTypeOptions.push({ label:'Salaried - Private', value: 'Salaried - Private' })
            }
            this.employmentTypeOptions = getUniqueValue(this.employmentTypeOptions)
            if(this.employmentTypeOptions && this.employmentTypeOptions.length==1){
                this.parentFinancialRecord.Type_Of_Employment__c = this.employmentTypeOptions[0].value
                this.getMethodOfAssessmentOptions()
            }
            
        }
    }

    setCompanyOptions(){
        this.showCompanyTextBox=false
        this.showCompanyDropdown=false
        if((this.parentFinancialRecord.Type_Of_Employment__c=='Salaried - Private' || this.parentFinancialRecord.Type_Of_Employment__c=='Salaried - Government') && this.currentApplicant.AU_Employee__c!='Yes'){
            this.companyTextBoxLabel="Company Name"
            this.showCompanyDropdown=true
            if(this.parentFinancialRecord.Company_Master__c && this.parentFinancialRecord.Company_Master__r.Company_Name__c=='Others'){
                this.showCompanyTextBox=true
            }
        }else if(this.currentApplicant.AU_Employee__c=='Yes'){
            this.companyTextBoxLabel="Company/Business Name"
            this.showCompanyTextBox=true
            this.showCompanyDropdown=false
            this.parentFinancialRecord.Company_Name__c='AU Small Finance Bank'
            if(this.template.querySelector('[data-name="Company_Name__c"]')){
                this.template.querySelector('[data-name="Company_Name__c"]').disabled=true
            }
        }else{
            this.companyTextBoxLabel="Company/Business Name"
            this.showCompanyTextBox=true
            this.showCompanyDropdown=false
        }
    }

    setCustomerGradeOptions(){
        if(this.loanApplication.Collateral_Type__c == '10109'){
            if(this.loanApplication.Original_Vehicle_Usage__c=='Agri'){
                this.customerGradeOptions = setPicklistsValues(this.pickListValues.Customer_Grade_Tractor_Agri.split(','))
                this.template.querySelector('[data-name="Customer_Grade__c"]').disabled=true
            }else if(this.loanApplication.Original_Vehicle_Usage__c=='Commercial'){
                this.customerGradeOptions = setPicklistsValues(this.pickListValues.Customer_Grade_Tractor_Commercial.split(','))
                this.template.querySelector('[data-name="Customer_Grade__c"]').disabled=false
            }
        }else if(this.loanApplication.Collateral_Type__c=='10133'){
            this.template.querySelector('[data-name="Customer_Grade__c"]').disabled=false
            if(this.loanApplication.Original_Vehicle_Usage__c=='Agri'){
                this.customerGradeOptions = setPicklistsValues(this.pickListValues.Customer_Grade_SPH_Agri.split(','))      
            }else if(this.loanApplication.Original_Vehicle_Usage__c=='Commercial'){
                this.customerGradeOptions = setPicklistsValues(this.pickListValues.Customer_Grade_SPH_Commercial.split(','))      
            }
            
        } else if( this.loanApplication.Original_Vehicle_Usage__c === 'Agri' ){ //R2-1746
            this.customerGradeOptions = setPicklistsValues( this.pickListValues.Customer_Grade_Implement_Agri.split(',') );
        } else if( this.loanApplication.Original_Vehicle_Usage__c === 'Commercial' ){
            this.customerGradeOptions = setPicklistsValues( this.pickListValues.Customer_Grade_Implement_Commercial.split(',') );
        }
    }

    handleLookupSelect(event) {
        if (event.detail.value != undefined) {
            let selectedValue = event.detail.value;
            let selectedName = event.detail.name;
            let fieldName = event.detail.fieldapi;
            if (fieldName !== null && selectedName !== null) {
                this.parentFinancialRecord.Company_Name__c = selectedName;
                this.parentFinancialRecord.Company_Master__c = selectedValue;
                if(selectedName == 'Others'){
                    this.showCompanyTextBox = true;
                }else{
                    this.showCompanyTextBox = false;
                }
            }
        }else{
            this.parentFinancialRecord.Company_Name__c = '';
            this.parentFinancialRecord.Company_Master__c = '';
        }
    }

    setDefaultValueforConsiderIncomeForEligibility(sentFromChange){
        /*if(!this.coApplicants || (this.coApplicants && this.coApplicants.length==0)){
            this.template.querySelector('[data-name="Consider_Income_for_Eligibility__c"]').classList.remove('validate')
            this.template.querySelector('[data-id="Consider_Income_for_Eligibility__c"]').classList.add('slds-hide')
        }*///This field will always be present on UI. Updated Comments on R2-64
        if(this.applicantRecType == 'Primary_Applicant'){
            if(!this.parentFinancialRecord.Consider_Income_for_Eligibility__c){
                this.parentFinancialRecord.Consider_Income_for_Eligibility__c='Yes'
            }
            if(this.parentFinancialRecord.Type_Of_Employment__c=='Housewife'){
                if(this.template.querySelector('[data-name="Consider_Income_for_Eligibility__c"]')){
                    this.template.querySelector('[data-name="Consider_Income_for_Eligibility__c"]').disabled=false
                }
            }else{
                if(this.template.querySelector('[data-name="Consider_Income_for_Eligibility__c"]')){
                    this.template.querySelector('[data-name="Consider_Income_for_Eligibility__c"]').disabled=true
                }
            }
            if(sentFromChange){
                if(this.parentFinancialRecord.Type_Of_Employment__c=='Unemployed'){
                    this.parentFinancialRecord.Consider_Income_for_Eligibility__c='No'
                }else{
                    this.parentFinancialRecord.Consider_Income_for_Eligibility__c='Yes'
                }
            }
        }else{
            if(this.template.querySelector('[data-name="Consider_Income_for_Eligibility__c"]')){
                this.template.querySelector('[data-name="Consider_Income_for_Eligibility__c"]').disabled=false
            }
            if(!this.parentFinancialRecord.Consider_Income_for_Eligibility__c){
                if(this.applicantRecType=='Co_Applicant'){
                    this.parentFinancialRecord.Consider_Income_for_Eligibility__c='Yes';
                }else if(this.applicantRecType == 'Guarantor'){
                    this.parentFinancialRecord.Consider_Income_for_Eligibility__c='No'
                }else if(this.applicantRecType == 'BO'){
                    this.parentFinancialRecord.Consider_Income_for_Eligibility__c='No'
                }
            }       
        }
        this.considerIncome = this.parentFinancialRecord.Consider_Income_for_Eligibility__c=='Yes'?true:false
    }

    setDefaultValueforConsiderLandForEligibility(){
         if(this.parentFinancialRecord.Consider_Land_for_Eligibility__c!=null){
            if(this.applicantRecType == 'Primary_Applicant'){
            this.template.querySelector('[data-name="Consider_Land_for_Eligibility__c"]').disabled=true;
            }else{
                this.template.querySelector('[data-name="Consider_Land_for_Eligibility__c"]').disabled=false;  
            }
        }

        if(!this.parentFinancialRecord.Consider_Land_for_Eligibility__c || this.reVisitScreen){
            
            if(this.applicantRecType == 'Primary_Applicant'){
                this.parentFinancialRecord.Consider_Land_for_Eligibility__c='Yes'
            }else if(this.applicantRecType=='Guarantor' || this.applicantRecType=='Co_Applicant'){
                this.template.querySelector('[data-name="Consider_Land_for_Eligibility__c"]').disabled=false;  
                let relations =[]
                if(this.currentApplicant.Customer_Type__c=='Individual'){
                    if(this.primaryApplicant.Gender__c=='Female'){
                        if(this.primaryApplicant.Marital_Status__c=='Married'){
                            relations = ['FATHER IN LAW','HUSBAND','SON','DAUGHTER','MOTHER IN LAW','GRAND FATHER IN LAW','GRAND MOTHER IN LAW','BROTHER','SPOUSE','WIFE']
                        }else{
                            relations = ['FATHER','SON','DAUGHTER','MOTHER','GRAND FATHER','GRAND MOTHER','BROTHER']
                        }
                    }else{
                        relations = ['FATHER','MOTHER','GRAND FATHER','GRAND MOTHER','HUSBAND','SON','DAUGHTER','BROTHER','DAUGHTER IN LAW','WIFE','SPOUSE']
                    }
                }else if(this.currentApplicant.Customer_Type__c=='Non Individual'){
                    relations = ['KARTA','DIRECTOR','PROPRIETOR','PARTNER','TRUSTEE','SHAREHOLDER']//['PARTNER','DIRECTOR','TRUSTEE']
                }
                if(relations.includes(this.currentApplicant.Relationship_with_applicant__c.toUpperCase())){
                    if(this.currentApplicant.Relationship_with_applicant__c.toUpperCase()=='BROTHER'){
                        if(this.applicantRecType=='Co_Applicant'){
                            this.parentFinancialRecord.Consider_Land_for_Eligibility__c='Yes'
                        }else if(this.applicantRecType=='Guarantor'){
                            this.parentFinancialRecord.Consider_Land_for_Eligibility__c='No'
                        }
                    }else if(this.currentApplicant.Relationship_with_applicant__c.toUpperCase()=='DAUGHTER'){
                        if(this.currentApplicant.Marital_Status__c=='Single'){
                            this.parentFinancialRecord.Consider_Land_for_Eligibility__c='Yes'
                        }else{
                            this.parentFinancialRecord.Consider_Land_for_Eligibility__c='No'
                        }
                    }
                    else{
                        this.parentFinancialRecord.Consider_Land_for_Eligibility__c='Yes'
                    }
                }else{
                    this.parentFinancialRecord.Consider_Land_for_Eligibility__c='No'
                }
            }else if(this.applicantRecType=='BO'){
                this.template.querySelector('[data-name="Consider_Land_for_Eligibility__c"]').disabled=false
                this.parentFinancialRecord.Consider_Land_for_Eligibility__c = 'No'
                /*if(this.currentApplicant.Customer_Type__c=='Individual'){
                    let relations = ['KARTA','DIRECTOR','PROPRIETOR','PARTNER','TRUSTEE','SHAREHOLDER']
                    if(relations.includes(this.currentApplicant.Relationship_with_applicant__c.toUpperCase())){
                        //this.template.querySelector('[data-name="Consider_Land_for_Eligibility__c"]').disabled=false
                        this.parentFinancialRecord.Consider_Land_for_Eligibility__c = 'Yes'
                    }else{
                        this.parentFinancialRecord.Consider_Land_for_Eligibility__c = 'No'
                        //this.template.querySelector('[data-name="Consider_Land_for_Eligibility__c"]').disabled=true
                    }
                }else{
                    //this.template.querySelector('[data-name="Consider_Land_for_Eligibility__c"]').disabled=false
                }*/    
                
            }
        }
        if(this.applicantRecType=='Co_Applicant' && this.currentUser.Profile.Name=='Credit Manager'){
            if(this.parentFinancialRecord.Consider_Land_for_Eligibility__c=='No'){
                this.template.querySelector('[data-name="Consider_Land_for_Eligibility__c"]').disabled=false
            }else if(this.parentFinancialRecord.Consider_Land_for_Eligibility__c=='Yes'){
                this.template.querySelector('[data-name="Consider_Land_for_Eligibility__c"]').disabled=true
            }
        }else if(this.currentUser.Profile.Name=='Credit Manager'){
            this.template.querySelector('[data-name="Consider_Land_for_Eligibility__c"]').disabled=true
        }
    }

    getMethodOfAssessmentOptions(){
        let options=[]
        this.incomeProfileMaster.forEach(input=>{
            if(input.Type_of_Employment__c==this.parentFinancialRecord.Type_Of_Employment__c){
                options.push({label:input.Method_Assesment__c, value:input.Method_Assesment__c})
            }
        })
        if(this.currentApplicant.AU_Employee__c=='Yes'){
            options=[]
            options.push({label:'Salaried', value:'Salaried'})
        }
        this.methodOfAssessmentOptions  = getUniqueValue(options)     
        if(!this.parentFinancialRecord.Method_Of_Assesment__c && this.methodOfAssessmentOptions && this.methodOfAssessmentOptions.length==1){
            this.parentFinancialRecord.Method_Of_Assesment__c = this.methodOfAssessmentOptions[0].value
        }   
    }

    handleChange(event){
        let name = event.target.name
        let value = event.target.value
        this.parentFinancialRecord[name] = value
        if(name=='Size_of_Agri_Land__c' || name=='Unit_Land_Area__c'){
            this.breReRunFields.push('Agri_Land_in_Acres__c')
            this.calculateAgriLandInAcres()
        }else if(name=='Agri_Owned_By__c'){
            this.breReRunFields.push('Agri_Owned_By__c')
            this.setAgriOwnedBy(false)
        }else if(name == 'Type_Of_Employment__c') {
            this.breReRunFields.push('Type_Of_Employment__c')
            this.handlegetRelatedPicklistValues('Type_Of_Employment__c', value, 'RT - Employment Type', 'RT - Sector','');  
            this.sectorOptions=[]
            this.industryOptions=[]
            this.subIndustryOptions=[]
            this.occupationOptions=[]
            this.setDefaultValueforConsiderIncomeForEligibility(true)
            // R2-2400 - START
            this.parentFinancialRecord.Method_Of_Assesment__c=''
            this.parentFinancialRecord.Sector__c = null;
            this.parentFinancialRecord.Industry__c = null;
            this.parentFinancialRecord.Sub_Industry__c = null;
            this.parentFinancialRecord.Occupation__c = null;
            // R2-2400 - END
            this.getMethodOfAssessmentOptions()
            this.setCompanyOptions()
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
                this.parentFinancialRecord.Total_Work_Experience__c ='0';
            }
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
        }else if(name == 'Customer_Grade__c'){
            this.breReRunFields.push('Customer_Grade__c')
            this.loanApplication.Customer_Grade__c = value
        }else if(name == 'Company_Name__c'){
            //this.setCompanyOptions()
        }else if(name == 'Consider_Income_for_Eligibility__c'){
            this.breReRunFields.push('Consider_Income_for_Eligibility__c')
        }
    }

    setAgriOwnedBy(fromInit){
        this.displaylandFields = true;
        if(!fromInit){
            this.parentFinancialRecord.Agri_Owned_By_Other__c=''
        }
        let value = this.parentFinancialRecord.Agri_Owned_By__c
        if(value && value.includes('Self')){
            this.parentFinancialRecord.Land_Owner_Name__c = (this.currentApplicant.First_Name__c?this.currentApplicant.First_Name__c+' ':'')+
            (this.currentApplicant.Middle_Name__c?this.currentApplicant.Middle_Name__c+' ':'')+
            (this.currentApplicant.Last_Name__c?this.currentApplicant.Last_Name__c:'')//R2-2353
            this.template.querySelector('[data-id="Land_Owner_Name__c"]')?.classList.remove('slds-hide')
            this.template.querySelector('[data-name="Land_Owner_Name__c"]')?.classList.remove('validate')
            this.template.querySelector('[data-name="Land_Owner_Name__c"]').disabled=true
            this.template.querySelector('[data-id="Size_of_Agri_Land__c"]').classList.remove('slds-hide')
            this.template.querySelector('[data-name="Size_of_Agri_Land__c"]').classList.add('validate')
            this.template.querySelector('[data-id="Agri_Land_in_Acres__c"]').classList.remove('slds-hide')
            this.template.querySelector('[data-name="Agri_Land_in_Acres__c"]').classList.add('validate')
            this.template.querySelector('[data-id="Unit_Land_Area__c"]').classList.remove('slds-hide')
            this.template.querySelector('[data-name="Unit_Land_Area__c"]').classList.add('validate')
        // R2-2413 - START
        } else if (value && value.includes('Landless')) {
            this.parentFinancialRecord.Land_Owner_Name__c='';
            this.template.querySelector('[data-name="Land_Owner_Name__c"]').disabled=true;
            this.fieldValidations = {};
        // R2-2413 - END
        } else {
            if(value && (value.includes('Family other than Co-applicant') || value.includes('COB'))){
                if((fromInit && !this.parentFinancialRecord.Land_Owner_Name__c) || !fromInit){
                    this.parentFinancialRecord.Land_Owner_Name__c=''
                }
            }
            this.template.querySelector('[data-name="Land_Owner_Name__c"]').disabled=false
            this.fieldValidations = {
                'Land_Owner_Name__c': /^[a-zA-Z ]+$/
            };
        }
        if(value && value.includes('Self')){
            this.displayAgriPicklist=false
            this.template.querySelector('[data-id="Size_of_Agri_Land__c"]').classList.remove('slds-hide')
            this.template.querySelector('[data-name="Size_of_Agri_Land__c"]').classList.add('validate')
            this.template.querySelector('[data-id="Agri_Land_in_Acres__c"]').classList.remove('slds-hide')
            this.template.querySelector('[data-name="Agri_Land_in_Acres__c"]').classList.add('validate')
            this.template.querySelector('[data-id="Unit_Land_Area__c"]').classList.remove('slds-hide')
            this.template.querySelector('[data-name="Unit_Land_Area__c"]').classList.add('validate')
            this.template.querySelector('[data-id="Agri_Owned_By_Other__c"]')?.classList.add('slds-hide')
            this.template.querySelector('[data-name="Agri_Owned_By_Other__c"]')?.classList.remove('validate')
            this.parentFinancialRecord.Agri_Owned_By_Other__c=''
            this.parentFinancialRecord.Agri_Owned_By_Other__c=(this.currentApplicant.First_Name__c?this.currentApplicant.First_Name__c+' ':'')+
            (this.currentApplicant.Middle_Name__c?this.currentApplicant.Middle_Name__c+' ':'')+
            (this.currentApplicant.Last_Name__c?this.currentApplicant.Last_Name__c:'')

        }else if(value && value.includes('Family other than Co-applicant')){
            this.displayAgriPicklist=false
            this.template.querySelector('[data-id="Land_Owner_Name__c"]')?.classList.remove('slds-hide')
            this.template.querySelector('[data-name="Land_Owner_Name__c"]')?.classList.remove('validate')
            this.template.querySelector('[data-name="Land_Owner_Name__c"]').disabled=false
            this.template.querySelector('[data-id="Agri_Owned_By_Other__c"]')?.classList.remove('slds-hide')
            this.template.querySelector('[data-name="Agri_Owned_By_Other__c"]')?.classList.add('validate')
            this.template.querySelector('[data-id="Size_of_Agri_Land__c"]')?.classList.remove('slds-hide')
            this.template.querySelector('[data-name="Size_of_Agri_Land__c"]')?.classList.add('validate')
            this.template.querySelector('[data-id="Agri_Land_in_Acres__c"]')?.classList.remove('slds-hide')
            this.template.querySelector('[data-name="Agri_Land_in_Acres__c"]')?.classList.add('validate')
            this.template.querySelector('[data-id="Unit_Land_Area__c"]')?.classList.remove('slds-hide')
            this.template.querySelector('[data-name="Unit_Land_Area__c"]')?.classList.add('validate')
        }else if(value && value.includes('COB')){
            this.template.querySelector('[data-id="Agri_Owned_By_Other__c"]')?.classList.remove('slds-hide')
            this.template.querySelector('[data-name="Agri_Owned_By_Other__c"]')?.classList.add('validate')
            this.template.querySelector('[data-id="Size_of_Agri_Land__c"]')?.classList.add('slds-hide')
            this.template.querySelector('[data-name="Size_of_Agri_Land__c"]')?.classList.remove('validate')
            this.parentFinancialRecord.Size_of_Agri_Land__c=''
            this.template.querySelector('[data-id="Agri_Land_in_Acres__c"]')?.classList.add('slds-hide')
            this.template.querySelector('[data-name="Agri_Land_in_Acres__c"]')?.classList.remove('validate')
            this.parentFinancialRecord.Agri_Land_in_Acres__c=''
            this.template.querySelector('[data-id="Unit_Land_Area__c"]')?.classList.add('slds-hide')
            this.template.querySelector('[data-name="Unit_Land_Area__c"]')?.classList.remove('validate')
            this.parentFinancialRecord.Unit_Land_Area__c=''
            this.template.querySelector('[data-id="Land_Owner_Name__c"]')?.classList.remove('slds-hide')
            this.template.querySelector('[data-name="Land_Owner_Name__c"]')?.classList.remove('validate')
            this.template.querySelector('[data-name="Land_Owner_Name__c"]').disabled=false
            this.parentFinancialRecord.Land_Owner_Name__c=''
            this.template.querySelector('[data-id="Agri_Land_in_Acres__c"]')?.classList.add('slds-hide')
            this.template.querySelector('[data-name="Agri_Land_in_Acres__c"]')?.classList.remove('validate')
            this.parentFinancialRecord.Agri_Land_in_Acres__c=''
            if(this.coApplicants && this.coApplicants.length>0){
                this.displayAgriPicklist=true
                let options=[]
                this.coApplicants.forEach(input=>{
                    let name = getApplicantName(input)
                    options.push({label: name, value: name})
                })
                this.agriOwnedByOtherOptions = options
                if(this.coApplicants.length==1){
                    if(!fromInit){
                        this.parentFinancialRecord.Agri_Owned_By_Other__c = getApplicantName(this.coApplicants[0])
                    }
                }
            }else{
                this.displayAgriPicklist=false
            }
        }else if(value && value.includes('Landless')){
            this.displaylandFields=false;
            if(!this.template.querySelector('[data-id="Agri_Owned_By_Other__c"]').classList.contains('slds-hide')
            || !this.template.querySelector('[data-id="Size_of_Agri_Land__c"]').classList.contains('slds-hide')
            || !this.template.querySelector('[data-id="Agri_Land_in_Acres__c"]').classList.contains('slds-hide')
            || !this.template.querySelector('[data-id="Unit_Land_Area__c"]').classList.contains('slds-hide')){
                this.template.querySelector('[data-id="Agri_Owned_By_Other__c"]').classList.add('slds-hide')
                this.template.querySelector('[data-name="Agri_Owned_By_Other__c"]').classList.remove('validate')
                this.parentFinancialRecord.Agri_Owned_By_Other__c=''
                this.template.querySelector('[data-id="Size_of_Agri_Land__c"]').classList.add('slds-hide')
                this.template.querySelector('[data-name="Size_of_Agri_Land__c"]').classList.remove('validate')
                this.parentFinancialRecord.Size_of_Agri_Land__c=''
                this.template.querySelector('[data-id="Agri_Land_in_Acres__c"]').classList.add('slds-hide')
                this.template.querySelector('[data-name="Agri_Land_in_Acres__c"]').classList.remove('validate')
                this.parentFinancialRecord.Agri_Land_in_Acres__c=''
                this.template.querySelector('[data-id="Unit_Land_Area__c"]').classList.add('slds-hide')
                this.template.querySelector('[data-name="Unit_Land_Area__c"]').classList.remove('validate')
                this.parentFinancialRecord.Unit_Land_Area__c=''
                this.template.querySelector('[data-id="Land_Owner_Name__c"]')?.classList.add('slds-hide')
                this.template.querySelector('[data-name="Land_Owner_Name__c"]')?.classList.remove('validate')
                //this.template.querySelector('[data-name="Customer_Grade__c"]').disabled=false
            }
        }else if (value && !value.includes('Self')){
            this.displayAgriPicklist=false
            if(!this.template.querySelector('[data-id="Agri_Owned_By_Other__c"]').classList.contains('slds-hide')
            || !this.template.querySelector('[data-id="Size_of_Agri_Land__c"]').classList.contains('slds-hide')){
                this.template.querySelector('[data-id="Agri_Owned_By_Other__c"]').classList.add('slds-hide')
                this.template.querySelector('[data-name="Agri_Owned_By_Other__c"]').classList.remove('validate')
                this.parentFinancialRecord.Agri_Owned_By_Other__c=''
                this.template.querySelector('[data-id="Size_of_Agri_Land__c"]').classList.add('slds-hide')
                this.template.querySelector('[data-name="Size_of_Agri_Land__c"]').classList.remove('validate')
                this.parentFinancialRecord.Size_of_Agri_Land__c=''
                this.template.querySelector('[data-id="Agri_Land_in_Acres__c"]').classList.add('slds-hide')
                this.template.querySelector('[data-name="Agri_Land_in_Acres__c"]').classList.remove('validate')
                this.parentFinancialRecord.Agri_Land_in_Acres__c=''
                this.template.querySelector('[data-id="Unit_Land_Area__c"]').classList.add('slds-hide')
                this.template.querySelector('[data-name="Unit_Land_Area__c"]').classList.remove('validate')
                this.parentFinancialRecord.Unit_Land_Area__c=''
                //this.template.querySelector('[data-name="Customer_Grade__c"]').disabled=false
            }
        }
        this.removeValidityErrors('Agri_Owned_By_Other__c')
        this.removeValidityErrors('Land_Owner_Name__c')
        this.removeValidityErrors('Size_of_Agri_Land__c')
        this.removeValidityErrors('Agri_Land_in_Acres__c')
        this.removeValidityErrors('Unit_Land_Area__c')
        this.calculateAgriLandInAcres()
        if(this.currentApplicant.RecordType.DeveloperName=='Co_Applicant' || this.currentApplicant.RecordType.DeveloperName=='Guarantor' || this.currentApplicant.RecordType.DeveloperName=='BO'){
            this.agriOwnedByOptions = this.allAgriOwnedByOptions.filter(function (element) {
                return (element.label == 'Self' || element.label == 'Landless');
            });
        }else{
            this.agriOwnedByOptions = this.allAgriOwnedByOptions
        }
        


    }

    removeValidityErrors(name){
        /*if(this.template.querySelector('[data-name="'+name+'"]')){
            let inputField = this.template.querySelector('[data-name="'+name+'"]')
            if(!inputField.classList.contains('validate')){
                let inputFields = [inputField]
                validate(inputFields)
            }
           
        }*/
    }

    async calculateAgriLandInAcres(){
        let areaLandInAcres=0
        let sizeOfLand = this.parentFinancialRecord.Size_of_Agri_Land__c && this.parentFinancialRecord.Size_of_Agri_Land__c!=''?parseFloat(this.parentFinancialRecord.Size_of_Agri_Land__c):0
        switch(this.parentFinancialRecord.Unit_Land_Area__c){
            case 'Hectare' : areaLandInAcres = sizeOfLand*2.47; break;
            case 'Acre' : areaLandInAcres = sizeOfLand; break;
            case 'Bigha' : areaLandInAcres = sizeOfLand*0.619; break;
            case 'Killa' :  areaLandInAcres = sizeOfLand; break;
            case 'Canal' : areaLandInAcres = sizeOfLand*0.124; break;
        }
        this.parentFinancialRecord.Agri_Land_in_Acres__c = areaLandInAcres
        let totalArea=0
        if(this.loanApplication.Original_Vehicle_Usage__c=='Agri' && this.loanApplication.Collateral_Type__c=='10109'){
            if(this.allParentFinancials && this.allParentFinancials.length>0){
                this.allParentFinancials.forEach(input=>{
                    //if(input.Applicant__r.Relationship_with_applicant__c.toUpperCase()!='OTHERS' && (input.Applicant__r.RecordType.DeveloperName=='Primary_Applicant' || input.Applicant__r.RecordType.DeveloperName=='Co_Applicant')){
                    if(input.Applicant__r.RecordType.DeveloperName=='Primary_Applicant' || (input.Applicant__r.RecordType.DeveloperName=='Co_Applicant' && input.Applicant__r.Relationship_with_applicant__c.toUpperCase()!='OTHERS')){
                        if(input.Applicant__c!=this.currentApplicantId){
                            totalArea = totalArea+input.Agri_Land_in_Acres__c
                        }
                    }
                }) 
                //if(this.currentApplicant.Relationship_with_applicant__c.toUpperCase()!='OTHERS' && (this.currentApplicant.RecordType.DeveloperName=='Primary_Applicant' || this.currentApplicant.RecordType.DeveloperName=='Co_Applicant')){
                if(this.currentApplicant.RecordType.DeveloperName=='Primary_Applicant' || (this.currentApplicant.RecordType.DeveloperName=='Co_Applicant' && this.currentApplicant.Relationship_with_applicant__c.toUpperCase()!='OTHERS')){
                    totalArea = totalArea+areaLandInAcres
                }
                
            }else{
                totalArea = areaLandInAcres
            }
            this.loanApplication.Net_Land_Holding_in_Acre__c=totalArea
            if(totalArea<=2.47){
                this.loanApplication.Customer_Grade__c='Marginal Farmer'
            }else if(totalArea>=2.48 && totalArea<=4.94){
                this.loanApplication.Customer_Grade__c='Small Farmer'
            }else if(totalArea>4.94){
                this.loanApplication.Customer_Grade__c='Large Farmer'
            }
            if(this.initiaLoanApplication.Customer_Grade__c!=this.loanApplication.Customer_Grade__c){
                this.breReRunFields.push('Customer_Grade__c')
            }
        }else{
            if(this.currentApplicant.RecordType.DeveloperName=='Primary_Applicant'){
                this.loanApplication.Net_Land_Holding_in_Acre__c=this.parentFinancialRecord.Agri_Land_in_Acres__c
            }
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

    checkIfOnlySpaceEntered(fieldApiName){
        let value = this.parentFinancialRecord[fieldApiName]
        if(value){
            let valueWithoutSpace = value.replaceAll(' ','')
            if(valueWithoutSpace==''){
                this.parentFinancialRecord[fieldApiName] = ''
            }
        }

    }

    handleParentSaveTemplate(){
        restricAccess({
            compName: 'landDetails' ,loanId: this.loanApplication.Id
            })
            .then(data => {
                console.log('data is ' + JSON.stringify(data));
                if (data) {
                    showToastMessage(this, "", "error", "You do not have access to save/edit Land Details", "dismissable");
                    /*const evt = new ShowToastEvent({
                        title: 'Access Restricted',
                        message: 'You do not have access to save/edit Payment Favourings',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(evt);*/
                }
                else{
                    this.checkIfOnlySpaceEntered('Land_Owner_Name__c')//users were able to save land details by just entering space
                    this.checkIfOnlySpaceEntered('Agri_Owned_By_Other__c')
                    let inputFields = this.template.querySelectorAll(".validate");
                    let fieldsWithFormats;
                    if(this.template.querySelector('[data-name="Land_Owner_Name__c"]') && this.template.querySelector('[data-name="Land_Owner_Name__c"]').classList.contains('validate')){
                        fieldsWithFormats = Object.keys( this.fieldValidations ).map( field => `lightning-input[data-name="${field}"]` );                    

                    }

                    if (validate(inputFields) && (!fieldsWithFormats || fieldsWithFormats.join( ',' ) === '' || validate( [...this.template.querySelectorAll( fieldsWithFormats.join( ',' ) )], this.fieldValidations ))) {
                        this.isLoading=true
                        if(this.loanStage=='QDE'){
                            const objChild = this.template.querySelector('c-additional-financial-component');
                            var valid = objChild.updateApplicantData( this.parentFinancialRecord?.Type_Of_Employment__c ); //R2-2675 - Single applicant cant have employment type housewife
                        }
                        
                        if (((this.loanStage=='QDE' && valid) || this.loanStage!='QDE')) {
                            this.parentFinancialRecord.RecordTypeId = this.parentRecordTypeId
                            this.parentFinancialRecord.Applicant__c = this.currentApplicantId
                            upsertIncome({record : this.parentFinancialRecord}).then(data=>{
                                this.isLoading=false
                                showToastMessage(this, "", "success", "Land Details Updated Successfully", "dismissable");
                                this.parentFinancialRecord.Id=data.Id
                                this.updateLoanApp()
                                this.updateChildFinancials()
                            }).catch(error=>{
                                this.isLoading=false
                                console.log('Error-> '+error.message.body)
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

    updateChildFinancials(){
        this.isLoading=true
        if( this.parentFinancialRecord.Type_Of_Employment__c!=this.initialEmploymentType || 
            this.parentFinancialRecord.Method_Of_Assesment__c!=this.initialMethodOfAssessment || 
            (this.initialConsiderForIncome!=this.parentFinancialRecord.Consider_Income_for_Eligibility__c && this.parentFinancialRecord.Consider_Income_for_Eligibility__c=='No')){
            deactiveExistingFinancials({currentApplicantId: this.currentApplicantId}).then(data=>{
                this.isLoading=false
            }).catch(error=>{
                this.isLoading=false
            })
        }else{
            this.isLoading=false
        }
       
    }

    /*updateApplicant(){
        this.isLoading=true
        if(this.reVisitScreen){
            let screens = JSON.parse(this.currentApplicant.Re_Visit_Screens__c)
            screens['Financial']=false
            let modifiedApplicant = {Id: this.currentApplicantId, Re_Visit_Screens__c:JSON.stringify(screens)}
            updateRelatedApplicant({applicant:modifiedApplicant}).then((data=>{
                this.isLoading=false
            })).catch(error=>{
                this.isLoading=false
            })
        }else{
            if(this.currentApplicant.RecordType.DeveloperName=='Primary_Applicant' && this.primaryApplicant.Marital_Status__c!=this.currentApplicant.Marital_Status__c
                && this.currentApplicant.Gender__c=='Female'){
                    updateRelatedApplicants({loanId: this.loanApplication.Id}).then((data=>{
                        this.isLoading=false
                    })).catch((error=>{
                        this.isLoading=false
                    }))
            }else{
                this.isLoading=false
            }
        }
    }*/

    async updateApplicant(){
        this.isLoading=true
        let updateRelatedMembers=false
        let modifiedApplicant = {Id: this.currentApplicantId, Type_Of_Employment__c: this.parentFinancialRecord.Type_Of_Employment__c}
        let screens = this.currentApplicant.Re_Visit_Screens__c?JSON.parse(this.currentApplicant.Re_Visit_Screens__c):new Map()
        if(this.initiaLoanApplication.Customer_Grade__c && this.initiaLoanApplication.Customer_Grade__c!=this.loanApplication.Customer_Grade__c && this.loanApplication.RecordType.DeveloperName=='Tractor'){
            screens['LoanDetails']=true
            showToastMessage(this, "", "warning", "Please update Loan Details as Customer Grade has changed", "sticky");
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
        const materialFields = await checkMaterialFields({strScreen:'Land Details',strLoanId:this.loanApplication.Id,lstFieldsAPI: this.breReRunFields})
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
                // R2-2380
                //showToastMessage(this, "", "success", "Customer Grade Updated Successfully", "dismissable");
            }else if(data=='Failure'){
                showToastMessage(this, "", "error", "Insufficient Access to Loan Application", "sticky");
            }
        })).catch((error=>{

        }))
    }

    @api
    async nextHandlerChild(){
        let allFieldsFilled = await getFinancialStatus({loanId : this.loanApplication.Id});
        if(allFieldsFilled.resultCheck == true){
            if(allFieldsFilled.mandatoryDDEParameter == true){
                showToastMessage(this, "", "error",'Some of the Required fields are missing please edit to proceed','sticky');
                return
            }
        }
        let response = await checkForFinancials({ applicantData: this.applicantsData, loanId : this.loanApplication.Id})
        if(response == 'Success'){
            const Obj = {};
            //Obj.applicantRecord = this.applicantIdInput;
            this.errorOnChild = '';
            Obj.errorOnChild = this.errorOnChild;
            Obj.next = this.errorOnChild == '' ? true : false;
            console.log('Obj', Obj);
            this.dispatchEvent(new CustomEvent('next', {
                detail: Obj
            }));            
        }else if(response == 'Incomplete'){
            showToastMessage(this, "", "error", "Please fill Land Details for all Applicants", "sticky");
        }

    }

    addEventHandler(event){
        let fieldName = event.detail.fieldName
        let fieldValue = event.detail.fieldValue
        this.currentApplicant[fieldName]=fieldValue
        if(fieldName=='Marital_Status__c'){
            this.setDefaultValueforConsiderLandForEligibility()
        }else if(fieldName=='AU_Employee__c'){
            this.showCompanyTextBox=true
            this.showCompanyDropdown=false
            if(fieldValue=='Yes'){
                this.setTypeOfEmploymentOptions()
                this.getMethodOfAssessmentOptions()
                this.parentFinancialRecord.Type_Of_Employment__c= 'Salaried - Private';
                this.parentFinancialRecord.Method_Of_Assesment__c= 'Salaried';
                this.parentFinancialRecord.Company_Name__c = 'AU Small Finance bank';
                this.template.querySelector('[data-name="Company_Name__c"]').disabled=true
            }else{
                this.setTypeOfEmploymentOptions()
                this.parentFinancialRecord.Type_Of_Employment__c= '';
                this.parentFinancialRecord.Method_Of_Assesment__c= '';
                this.parentFinancialRecord.Company_Name__c = '';
            }
            this.template.querySelectorAll('.disableForAUEmployee').forEach(input=>{
                input.disabled=fieldValue=='Yes'?true:false
            })
        }
        
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