/*****
 * Test Class Name: ChargesControllerTest
 * Description: 
 * Class Name: ChargesController 
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Oct-26-2023          -   Mohit M             -   SFAU-5392 - LS Charges Deviations and Approval
 */
@isTest
public class ChargesControllerTest {
    @testSetup static void setup() {
        
        Account dealerMaster = (Account)TestFactory.createSObject(new Account(
            Name ='TestAccount',
            Account_Code__c='2103',
            Purchase_City__c='Jaipur',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId()
        ),true);

        Account state = (Account)TestFactory.createSObject(new Account(
            Name ='Madhya Pradesh',
            Account_Name__c = 'Madhya Pradesh',
            Account_Code__c='MP',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('State').getRecordTypeId()
        ),true);

        Account region = (Account)TestFactory.createSObject(new Account(
            Name ='Region',
            Account_Code__c='JPR',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Region').getRecordTypeId()
        ),true);
        Account bhub = (Account)TestFactory.createSObject(new Account(
            Name ='HUB',
            Account_Code__c='101',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Hub').getRecordTypeId()
        ),true);

        Account branchMaster = (Account)TestFactory.createSObject(new Account(
            Name ='Branch M',
            Account_Code__c='21034',
            Purchase_City__c='Indore',
            Business_HUB__c=bhub.Id,
            State__c = state.id,
            Region__c = region.Id,
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Branch').getRecordTypeId()
        ),true);
        
        Scheme_Master__c objSM = (Scheme_Master__c)TestFactory.createSObject(new Scheme_Master__c(
            Scheme_Name__c='Normal',
            START_DATE__c  = system.today(),
            EXPIRY_DATE__c   = system.today().addDays(365),
            Is_InActive__c  = false,
            Scheme_Code__c	 = '101'
        ),true);
        Charges_Master__c objCM = (Charges_Master__c)TestFactory.createSObject(new Charges_Master__c(
            Scheme__c = objSM.Id,
            Product_Code__c = '10201',
            Cibil_MIN__c = 70,
            Cibil_Max__c = 100,
            Cibil_Include__c = 80,
            Min_Amount__c = 500,
            Max_Amount__c = 500000,
            Type_of_Loan__c ='New',
            SC_Name__c ='Normal',
            Tax_Percentage__c = 20,
            Rate_value_As_per_Policy__c = 10,
            Collateral_Type__c  = '10101',
            Customer_Type__c = 'ETB',
            Fuel_Type__c='Petrol',
            Vehicle_Usages__c='Personal',
            SC_Code__c = '101',
            Is_territory_General__c = 'FALSE',
            Is_Make_model_General__c = 'FALSE',
            Is_Dealer_General__c = 'FALSE',
            Deviation_Applicable__c = 'Yes',
            Customer_category__c = 'NA'
        ),true);
        
        Charges_Master__c objCM2 = (Charges_Master__c)TestFactory.createSObject(new Charges_Master__c(
            Scheme__c = objSM.Id,
            Product_Code__c = '10201',
            Cibil_MIN__c = 70,
            Cibil_Max__c = 100,
            Cibil_Include__c = 80,
            Min_Amount__c = 500,
            Max_Amount__c = 500000,
            Type_of_Loan__c ='New',
            SC_Name__c ='Vintage Model Fees',
            Tax_Percentage__c = 20,
            Rate_value_As_per_Policy__c = 10,
            Collateral_Type__c  = '10101',
            Customer_Type__c = 'ETB',
            Fuel_Type__c='Petrol',
            Vehicle_Usages__c='Personal',
            SC_Code__c = '102',
            Is_territory_General__c = 'FALSE',
            Is_Make_model_General__c = 'FALSE',
            Is_Dealer_General__c = 'FALSE',
            Deviation_Applicable__c = 'No',
            Customer_category__c = 'NA'
        ),true);

        Charges_Master__c objCM3 = (Charges_Master__c)TestFactory.createSObject(new Charges_Master__c(
            Scheme__c = objSM.Id,
            Product_Code__c = '10201',
            Cibil_MIN__c = 70,
            Cibil_Max__c = 100,
            Cibil_Include__c = 80,
            Min_Amount__c = 500,
            Max_Amount__c = 500000,
            Type_of_Loan__c ='New',
            SC_Name__c ='Vintage Model Fees',
            Tax_Percentage__c = 20,
            Rate_value_As_per_Policy__c = 10,
            Collateral_Type__c  = '10101',
            Customer_Type__c = 'ETB',
            Fuel_Type__c='Petrol',
            Vehicle_Usages__c='Personal',
            SC_Code__c = '103',
            Is_territory_General__c = 'TRUE',
            Is_Make_model_General__c = 'TRUE',
            Is_Dealer_General__c = 'TRUE',
            Deviation_Applicable__c = 'No',
            Customer_category__c = 'NA'
        ),true);

        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Non Individual',
            Stage__c ='QDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Scheme__c = objSM.Id,
            Dealer_Master__c = dealerMaster.Id,
            Branch_Master__c = branchMaster.Id
        ),true);
        
        BRE_Response__c objBREResponse = (BRE_Response__c)TestFactory.createSObject(new BRE_Response__c(
            BRE_Request_Id__c='IC001001001',
            Loan_Application__c =loanAppl.Id,
            Is_Confirmed__c = true
        ),true);
        
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            Customer_Grade__c ='Premium',
            Customer_Type__c ='Non Individual',
            KYC_Type__c='Driving License',
            AU_Employee__c = 'Yes',
            AU_Employment_status__c='Active',
            Date_of_Joining__c = System.today().addDays(-60),
            Education_qualification__c='GRADUATE'
        ),true);
        
        //Address Insertion
        Address__c  addInstance = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c ='TestAddressline1',
            Address_Line_2__c ='TestAddressline2',
            Address_Line_3__c ='TestAddressline3',
            State__c='MAHARASHTRA',
            City__c='EAST DELHI',
            Area_Name__c='JAGJIT NAGAR',
            Area_Type__c='Urban',
            Taluka__c='NA',
            Pincode__c='110053',
            Land_mark__c='Testing',
            Applicant__c =appl.Id,
            Status__c='Owned',
            Address_Type__c='Current',
            Type__c='Bungalow',
             Stability__c ='7',
            Latest_Cibil_Address_Match_Score__c=100
        ),true);
        
        //Address Insertion
        Address__c  addInstance2 = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c ='TestAddressline1',
            Address_Line_2__c ='TestAddressline2',
            Address_Line_3__c ='TestAddressline3',
            State__c='MAHARASHTRA',
            City__c='EAST DELHI',
            Area_Name__c='JAGJIT NAGAR',
            Area_Type__c='Urban',
            Taluka__c='NA',
            Pincode__c='110053',
            Land_mark__c='Testing',
            Applicant__c =appl.Id,
            Status__c='Owned',
            Address_Type__c='Office',
            Office_Email_address__c = 'testfactory@aubank.com',
            Office_Email_Verification_Status__c = 'Verified',
            Type__c='Bungalow',
             Stability__c ='7'
        ),true);
        
        Document_Master__c  docMaster = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name = 'AUWheels0006',
            Document_Name__c = 'PAN'
        ),true);
        
        Document_Checklist__c docChkRecord = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id,
            Applicant__c = appl.Id,
            Document_Master__c = docMaster.Id,
            Document_Name__c ='PAN',
            Document_Number__c = 'BEMPN6666N'
        ),true);
        
        Applicant_Financials_Details__c objFDSD = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
            Applicant__c =appl.Id,
            Monthly_Income__c = 100000, 
            Monthly_Obligation__c=1000, 
            Consider_Income_for_Eligibility__c='Yes', 
            Monthly_Net_Profit__c=1000000, 
            Average_Monthly_Salary__c=100000,
            Type_Of_Employment__c='Self Employed Professional',
            RecordTypeId=Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Salaried_Document').getRecordTypeId()),true);
        
        ID modelRecTypeId=Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByDeveloperName().get('Model').getRecordTypeId();
        ID makeRecTypeId=Schema.SObjectType.MMV_Master__c.getRecordTypeInfosByDeveloperName().get('Make').getRecordTypeId();
        MMV_Master__c  modelmmvMaster = (MMV_Master__c)TestFactory.createSObject(new MMV_Master__c (
            Name='ZX MT_DIESEL', RecordTypeId = modelRecTypeId
        ),true); 
        MMV_Master__c  makemmvMaster = (MMV_Master__c)TestFactory.createSObject(new MMV_Master__c (
            Name='ZX MT_DIESEL', RecordTypeId = makeRecTypeId
        ),true);
        
        //MMV Insertion
        MMV_Master__c mmvMaster = (MMV_Master__c )TestFactory.createSObject(new MMV_Master__c (
            Name ='ZX MT_DIESEL',
            Collateral_Type__c ='Automobile',
            Model__c=modelmmvMaster.Id,
            Make__c = makemmvMaster.Id
        ),true);
        
        // Collateral Insertion
        Collateral__c  collateralNew = (Collateral__c )TestFactory.createSObject(new Collateral__c (
            Loan__c =loanAppl.Id,
            MMV_Master__c =mmvMaster.Id,
            Vehicle_Number__c='TN12345567',
            Certified_Value__c='1234',
            Collateral_Name__c ='10101',
            Pincode__c = '302026',
            City__c = 'Jaipur',
            Registration_City__c = 'Jaipur',
            Engine_Category__c ='BS6',
            Manufacture_year_month__c = '202212',
            Fuel_Type__c='Petrol',
            Vehicle_Usage__c = 'Personal',
            RecordTypeId=Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('New').getRecordTypeId()
        ),true);
        // Collateral Insertion
        Collateral__c  collateralUsed = (Collateral__c )TestFactory.createSObject(new Collateral__c (
            Loan__c =loanAppl.Id,
            MMV_Master__c =mmvMaster.Id,
            Vehicle_Number__c='TN12345567',
            Certified_Value__c='1234',
            Collateral_Name__c ='10101',
            Pincode__c = '302026',
            City__c = 'Jaipur',
            Engine_Category__c ='BS4',
            Registration_City__c = 'Jaipur',
            Manufacture_year_month__c = '202212',
            Fuel_Type__c='Petrol',
            RecordTypeId=Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId(),
            IDV__c = '10'
        ),true);

        // Collateral Insertion
        Valuation__c  valueRecord = (Valuation__c )TestFactory.createSObject(new Valuation__c (
            Collateral__c =collateralUsed.Id,
            Valuer_Name_Code__c = 'Cando'
        ),true);
        
        Location_Master__c  lcMaster = (Location_Master__c )TestFactory.createSObject(new Location_Master__c (
            Name ='302026',
            Area_Name__c ='JAGJIT NAGAR',
            Area_Type__c ='Urban',  
            City__c ='Jaipur',
            State__c ='RAJASTHAN',
            Taluka__c ='NA',
            Zip_Code__c = '302026'
        ),true);
        
        //CanDo Lead Integration Master
        Integration_Master__c CanDOIntegrationMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='FICO BRE',
            End_Point_URL__c='https://service.aubank.in/SFDCCanDoLeadService/candoLead',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
        
        Integration_Checklist__c  intChecklist = (Integration_Checklist__c )TestFactory.createSObject(new Integration_Checklist__c(
            is_Latest__c = true,
            Applicant__c= appl.Id,
            Request_Id__c='IC001001001',
            Integration_Master__c = CanDOIntegrationMaster.Id,
            Loan_Application__c = loanAppl.Id,
            Callback_Request__c = '{"message":{"requestTime":"Jun 23, 2023 12:48:46.873 PM IST","dmElapsedTime":90,"application":{"product":[{"noOfTopUp":0,"existingGroupExposure":500000,"loanType":"NEW","requestedLoanAmountForSingleUnit":0,"requestedROI":10.84,"schemeId":"Scheme 0001","requestedInstallmentAmount":10831,"roiAsPerMaster":0,"noOfUnits":0,"rateType":"FIXED","sourcingDetails":{"sourcingCategory":"NOT_RATED","sourcingClass":"NON_TA","sourcingChannel":"DEALER_NEW_VEHICLE"},"productDecision":{"isAppliedPromoCode":false,"productDecision":"NSTP","schemeDecision":[{"subjectivityMessages":[],"schemeType":"STP","maxLTV":0,"maxEligibileLoanAmount":0,"finalIRR":0,"finalProcessingFee":0,"schemeName":"STP_NTB","isEligible":false,"schemeId":"STP_NTB","schemDecision":"NSTP","maxEligibileTenure":0,"eligibilityRules":[{"reasonText":"AML status is pending","ruleLevel":"AML NORM","overrideAuthority":"L0","applicantType":"PRIMARY","rulesetName":"RS_STP_Common_Eligibility_Rules","reasonCode":"AML_STP_COMM001","ruleId":"AML_Status_Check","applicantId":"A-00009168","outcome":"NSTP"},{"reasonText":"Current address is not in Geo limit range","ruleLevel":"OGL NORM","overrideAuthority":"L0","applicantType":"PRIMARY","rulesetName":"RS_STP_Common_Eligibility_Rules","reasonCode":"GEO_LIMIT_STP_COMM001","ruleId":"Geo_Limit_Check","applicantId":"A-00009168","outcome":"NSTP"},{"reasonText":"no owned house","ruleLevel":"OHP NORM","overrideAuthority":"L0","applicantType":"PRIMARY","rulesetName":"RS_STP_Common_Eligibility_Rules","reasonCode":"STABILITY_STP_COMM001","ruleId":"Stability_Own_House_Check","applicantId":"A-00009168","outcome":"NSTP"},{"reasonText":"Age norm not met","ruleLevel":"AGE NORM","overrideAuthority":"L0","applicantType":"PRIMARY","rulesetName":"RS_STP_Common_Eligibility_Rules","reasonCode":"AGE_STP_COMM001","ruleId":"Salaried_Age_Norm","applicantId":"A-00009168","outcome":"NSTP"},{"reasonText":"Salaried in Bank statement in last 6 months is less than 30K","ruleLevel":"INCOME NORM","applicantType":"PRIMARY","rulesetName":"RS_STP_ApplicantRules","reasonCode":"INCOME_SAL_ELIG_001","ruleId":"Income_Validation_SAL","applicantId":"A-00009168","outcome":"NSTP"},{"reasonText":"On Exshowroom LTV is more than 90%.","ruleLevel":"LTV NORM","applicantType":"PRIMARY","rulesetName":"RS_STP_ApplicantRules","reasonCode":"ON_EXSHOWROOM_LTV_ELIG_003","ruleId":"OnExshowroom_LTV_Upto_90Perc_SAL","applicantId":"A-00009168","outcome":"NSTP"}]},{"schemeType":"BUSINESS","maxLTV":0,"calculatedVariables":[],"maxEligibileLoanAmount":0,"finalIRR":0,"finalProcessingFee":0,"schemeName":"Govt Employee Scheme","isEligible":false,"schemeId":"Scheme 0004","schemDecision":"NSTP","maxEligibileTenure":0,"eligibilityRules":[{"reasonText":"Applicant is not defined as IB type.","ruleLevel":"CUSTOMER GRADE NORM","applicantType":"PRIMARY","rulesetName":"RS_BS_ApplicantRules","reasonCode":"CUSTOMER_GRADE_ELIG_001","ruleId":"IB_Allowed","applicantId":"A-00009168","ruleDescription":"Applicant is not defined as IB type.","outcome":"NSTP"},{"reasonText":"EMPLOYMENT NORM","ruleLevel":"BUS_ELIGIBILITY","applicantType":"PRIMARY","rulesetName":"RS_BS_ApplicantRules","reasonCode":"EMP_ELIG_005","ruleId":"Govt_applicant_allowed","applicantId":"A-00009168","ruleDescription":"EMPLOYMENT NORM","outcome":"NSTP"},{"reasonText":"Applicant doesnâu0080u0099t taken any preferred loans in past.","ruleLevel":"BUREU NORM","applicantType":"PRIMARY","rulesetName":"RS_BS_ApplicantRules","reasonCode":"CIBIL_ELIG_005","ruleId":"EXISTING_LOANS_CHECK","applicantId":"A-00009168","ruleDescription":"Applicant doesnâu0080u0099t taken any preferred loans in past.","outcome":"NSTP"},{"reasonText":"Income criteria not met.","ruleLevel":"INCOME NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"INCOME_ELIG_001","ruleId":"Documented_Income_GTE350K","ruleDescription":"Income criteria not met.","outcome":"NSTP"},{"reasonText":"Income should be more than 2 times of EMI","ruleLevel":"INCOME EMI NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"INCOME_EMI_ELIG_001","ruleId":"Income_emi_ratio","ruleDescription":"Income should be more than 2 times of EMI","outcome":"NSTP"},{"reasonText":"CIBIL Score norm not met.","ruleLevel":"CIBIL SCORE NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"CIBIL_SCORE_ELIG_001","ruleId":"CIBIL_SCORE_GTE_725_NTC","ruleDescription":"CIBIL Score norm not met.","outcome":"NSTP"}]},{"schemeType":"BUSINESS","maxLTV":0,"calculatedVariables":[],"maxEligibileLoanAmount":0,"finalIRR":0,"finalProcessingFee":0,"schemeName":"On Road Salaried Scheme","isEligible":false,"schemeId":"Scheme 0006","schemDecision":"NSTP","maxEligibileTenure":0,"eligibilityRules":[{"reasonText":"Applicant is not defined as IB type.","ruleLevel":"CUSTOMER GRADE NORM","applicantType":"PRIMARY","rulesetName":"RS_BS_ApplicantRules","reasonCode":"CUSTOMER_GRADE_ELIG_001","ruleId":"IB_Allowed","applicantId":"A-00009168","ruleDescription":"Applicant is not defined as IB type.","outcome":"NSTP"},{"reasonText":"EMPLOYMENT NORM","ruleLevel":"BUS_ELIGIBILITY","applicantType":"PRIMARY","rulesetName":"RS_BS_ApplicantRules","reasonCode":"EMP_ELIG_002","ruleId":"Salaried_applicant_allowed_GOVT_CAT_A_B","applicantId":"A-00009168","ruleDescription":"EMPLOYMENT NORM","outcome":"NSTP"},{"reasonText":"Applicant doesnâu0080u0099t taken any preferred loans in past.","ruleLevel":"BUREU NORM","applicantType":"PRIMARY","rulesetName":"RS_BS_ApplicantRules","reasonCode":"CIBIL_ELIG_005","ruleId":"EXISTING_LOANS_CHECK","applicantId":"A-00009168","ruleDescription":"Applicant doesnâu0080u0099t taken any preferred loans in past.","outcome":"NSTP"},{"reasonText":"Income should be more than 2 times of EMI","ruleLevel":"INCOME EMI NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"INCOME_EMI_ELIG_001","ruleId":"Income_emi_ratio","ruleDescription":"Income should be more than 2 times of EMI","outcome":"NSTP"},{"reasonText":"CIBIL Score norm not met.","ruleLevel":"CIBIL SCORE NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"CIBIL_SCORE_ELIG_002","ruleId":"CIBIL_SCORE_GTE_725","ruleDescription":"CIBIL Score norm not met.","outcome":"NSTP"}]},{"schemeType":"BUSINESS","maxLTV":0,"calculatedVariables":[],"maxEligibileLoanAmount":0,"finalIRR":0,"finalProcessingFee":0,"schemeName":"Super Supreme New Scheme","isEligible":false,"schemeId":"Scheme 0009","schemDecision":"NSTP","maxEligibileTenure":0,"eligibilityRules":[{"reasonText":"Applicant is not defined as IB type.","ruleLevel":"CUSTOMER GRADE NORM","applicantType":"PRIMARY","rulesetName":"RS_BS_ApplicantRules","reasonCode":"CUSTOMER_GRADE_ELIG_001","ruleId":"IB_Allowed","applicantId":"A-00009168","ruleDescription":"Applicant is not defined as IB type.","outcome":"NSTP"},{"reasonText":"Applicant doesnâu0080u0099t taken any preferred loans in past.","ruleLevel":"BUREU NORM","applicantType":"PRIMARY","rulesetName":"RS_BS_ApplicantRules","reasonCode":"CIBIL_ELIG_005","ruleId":"EXISTING_LOANS_CHECK","applicantId":"A-00009168","ruleDescription":"Applicant doesnâu0080u0099t taken any preferred loans in past.","outcome":"NSTP"},{"reasonText":"Income criteria not met.","ruleLevel":"INCOME NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"INCOME_ELIG_001","ruleId":"Documented_Income_GTE350K","ruleDescription":"Income criteria not met.","outcome":"NSTP"},{"reasonText":"Income should be more than 2 times of EMI","ruleLevel":"INCOME EMI NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"INCOME_EMI_ELIG_001","ruleId":"Income_emi_ratio","ruleDescription":"Income should be more than 2 times of EMI","outcome":"NSTP"},{"reasonText":"CIBIL Score norm not met.","ruleLevel":"CIBIL SCORE NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"CIBIL_SCORE_ELIG_002","ruleId":"CIBIL_SCORE_GTE_725","ruleDescription":"CIBIL Score norm not met.","outcome":"NSTP"},{"reasonText":"Final asset cost is less than 800k","ruleLevel":"ASSET COST NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"ASSET_COST_ELIG_001","ruleId":"New_Min_Asset_Cost_GTE_800K","ruleDescription":"Final asset cost is less than 800k","outcome":"NSTP"}]},{"schemeType":"BUSINESS","maxLTV":0,"calculatedVariables":[],"maxEligibileLoanAmount":0,"finalIRR":0,"finalProcessingFee":0,"schemeName":"Super Supreme Used Govt","isEligible":false,"schemeId":"Scheme 0013","schemDecision":"NSTP","maxEligibileTenure":0,"eligibilityRules":[{"reasonText":"Applicant is not defined as IB type.","ruleLevel":"CUSTOMER GRADE NORM","applicantType":"PRIMARY","rulesetName":"RS_BS_ApplicantRules","reasonCode":"CUSTOMER_GRADE_ELIG_001","ruleId":"IB_Allowed","applicantId":"A-00009168","ruleDescription":"Applicant is not defined as IB type.","outcome":"NSTP"},{"reasonText":"EMPLOYMENT NORM","ruleLevel":"BUS_ELIGIBILITY","applicantType":"PRIMARY","rulesetName":"RS_BS_ApplicantRules","reasonCode":"EMP_ELIG_005","ruleId":"Govt_applicant_allowed","applicantId":"A-00009168","ruleDescription":"EMPLOYMENT NORM","outcome":"NSTP"},{"reasonText":"Applicant doesnâu0080u0099t taken any preferred loans in past.","ruleLevel":"BUREU NORM","applicantType":"PRIMARY","rulesetName":"RS_BS_ApplicantRules","reasonCode":"CIBIL_ELIG_005","ruleId":"EXISTING_LOANS_CHECK","applicantId":"A-00009168","ruleDescription":"Applicant doesnâu0080u0099t taken any preferred loans in past.","outcome":"NSTP"},{"reasonText":"Loan is not applicable other than Used","ruleLevel":"LOAN TYPE NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"LOANTYPE_ELIG_002","ruleId":"LoanType_Used_Required","ruleDescription":"Loan is not applicable other than Used","outcome":"NSTP"},{"reasonText":"Income criteria not met.","ruleLevel":"INCOME NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"INCOME_ELIG_001","ruleId":"Documented_Income_GTE350K","ruleDescription":"Income criteria not met.","outcome":"NSTP"},{"reasonText":"CIBIL Score norm not met.","ruleLevel":"CIBIL SCORE NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"CIBIL_SCORE_ELIG_001","ruleId":"CIBIL_SCORE_GTE_725_NTC","ruleDescription":"CIBIL Score norm not met.","outcome":"NSTP"}]},{"schemeType":"BUSINESS","maxLTV":0,"calculatedVariables":[],"maxEligibileLoanAmount":0,"finalIRR":0,"finalProcessingFee":0,"schemeName":"Au Employee Scheme","isEligible":false,"schemeId":"Scheme 0002","schemDecision":"NSTP","maxEligibileTenure":0,"eligibilityRules":[{"reasonText":"ETB Customer required","ruleLevel":"ETB NORM","applicantType":"PRIMARY","rulesetName":"RS_BS_ApplicantRules","reasonCode":"ETB_ELIG_003","ruleId":"ETB_Customer_Allowed","applicantId":"A-00009168","ruleDescription":"ETB Customer required","outcome":"NSTP"},{"reasonText":"Applicant should be AU employee.","ruleLevel":"AU EMPLOYEE NORM","applicantType":"PRIMARY","rulesetName":"RS_BS_ApplicantRules","reasonCode":"AU_ELIG_002","ruleId":"Include_AU_Applicant","applicantId":"A-00009168","ruleDescription":"Applicant should be AU employee.","outcome":"NSTP"}]},{"schemeType":"BUSINESS","maxLTV":0,"calculatedVariables":[],"maxEligibileLoanAmount":0,"finalIRR":0,"finalProcessingFee":0,"schemeName":"Super Supreme Urban Scheme","isEligible":false,"schemeId":"Scheme 0010","schemDecision":"NSTP","maxEligibileTenure":0,"eligibilityRules":[{"reasonText":"Applicant is not defined as IB type.","ruleLevel":"CUSTOMER GRADE NORM","applicantType":"PRIMARY","rulesetName":"RS_BS_ApplicantRules","reasonCode":"CUSTOMER_GRADE_ELIG_001","ruleId":"IB_Allowed","applicantId":"A-00009168","ruleDescription":"Applicant is not defined as IB type.","outcome":"NSTP"},{"reasonText":"Applicant doesnâu0080u0099t taken any preferred loans in past.","ruleLevel":"BUREU NORM","applicantType":"PRIMARY","rulesetName":"RS_BS_ApplicantRules","reasonCode":"CIBIL_ELIG_005","ruleId":"EXISTING_LOANS_CHECK","applicantId":"A-00009168","ruleDescription":"Applicant doesnâu0080u0099t taken any preferred loans in past.","outcome":"NSTP"},{"reasonText":"Income criteria not met.","ruleLevel":"INCOME NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"INCOME_ELIG_002","ruleId":"Documented_Income_GTE600K","ruleDescription":"Income criteria not met.","outcome":"NSTP"},{"reasonText":"Income should be more than 2 times of EMI","ruleLevel":"INCOME EMI NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"INCOME_EMI_ELIG_001","ruleId":"Income_emi_ratio","ruleDescription":"Income should be more than 2 times of EMI","outcome":"NSTP"},{"reasonText":"CIBIL Score norm not met.","ruleLevel":"CIBIL SCORE NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"CIBIL_SCORE_ELIG_002","ruleId":"CIBIL_SCORE_GTE_725","ruleDescription":"CIBIL Score norm not met.","outcome":"NSTP"},{"reasonText":"Final asset cost is less than 800k","ruleLevel":"ASSET COST NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"ASSET_COST_ELIG_001","ruleId":"New_Min_Asset_Cost_GTE_800K","ruleDescription":"Final asset cost is less than 800k","outcome":"NSTP"}]},{"schemeType":"BUSINESS","maxLTV":0,"calculatedVariables":[],"maxEligibileLoanAmount":0,"finalIRR":0,"finalProcessingFee":0,"schemeName":"On Road Self Employee Scheme","isEligible":false,"schemeId":"Scheme 0007","schemDecision":"NSTP","maxEligibileTenure":0,"eligibilityRules":[{"reasonText":"Applicant is not defined as IB type.","ruleLevel":"CUSTOMER GRADE NORM","applicantType":"PRIMARY","rulesetName":"RS_BS_ApplicantRules","reasonCode":"CUSTOMER_GRADE_ELIG_001","ruleId":"IB_Allowed","applicantId":"A-00009168","ruleDescription":"Applicant is not defined as IB type.","outcome":"NSTP"},{"reasonText":"EMPLOYMENT NORM","ruleLevel":"BUS_ELIGIBILITY","applicantType":"PRIMARY","rulesetName":"RS_BS_ApplicantRules","reasonCode":"EMP_ELIG_003","ruleId":"Selfemployed_applicant_allowed","applicantId":"A-00009168","ruleDescription":"EMPLOYMENT NORM","outcome":"NSTP"},{"reasonText":"Applicant doesnâu0080u0099t taken any preferred loans in past.","ruleLevel":"BUREU NORM","applicantType":"PRIMARY","rulesetName":"RS_BS_ApplicantRules","reasonCode":"CIBIL_ELIG_005","ruleId":"EXISTING_LOANS_CHECK","applicantId":"A-00009168","ruleDescription":"Applicant doesnâu0080u0099t taken any preferred loans in past.","outcome":"NSTP"},{"reasonText":"Income criteria not met.","ruleLevel":"INCOME NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"INCOME_ELIG_002","ruleId":"Documented_Income_MIN_RLA_GTE600K","ruleDescription":"Income criteria not met.","outcome":"NSTP"},{"reasonText":"AQB should be >=3 times of EMI","ruleLevel":"AQB NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"INCOME_EMI_ELIG_002","ruleId":"AQB_emi_ratio","ruleDescription":"AQB should be >=3 times of EMI","outcome":"NSTP"},{"reasonText":"CIBIL Score norm not met.","ruleLevel":"CIBIL SCORE NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"CIBIL_SCORE_ELIG_002","ruleId":"CIBIL_SCORE_GTE_725","ruleDescription":"CIBIL Score norm not met.","outcome":"NSTP"}]},{"schemeType":"BUSINESS","maxLTV":0,"calculatedVariables":[],"maxEligibileLoanAmount":0,"finalIRR":0,"finalProcessingFee":0,"schemeName":"Super Supreme Used Non Govt","isEligible":false,"schemeId":"Scheme 0014","schemDecision":"NSTP","maxEligibileTenure":0,"eligibilityRules":[{"reasonText":"Applicant is not defined as IB type.","ruleLevel":"CUSTOMER GRADE NORM","applicantType":"PRIMARY","rulesetName":"RS_BS_ApplicantRules","reasonCode":"CUSTOMER_GRADE_ELIG_001","ruleId":"IB_Allowed","applicantId":"A-00009168","ruleDescription":"Applicant is not defined as IB type.","outcome":"NSTP"},{"reasonText":"Applicant doesnâu0080u0099t taken any preferred loans in past.","ruleLevel":"BUREU NORM","applicantType":"PRIMARY","rulesetName":"RS_BS_ApplicantRules","reasonCode":"CIBIL_ELIG_005","ruleId":"EXISTING_LOANS_CHECK","applicantId":"A-00009168","ruleDescription":"Applicant doesnâu0080u0099t taken any preferred loans in past.","outcome":"NSTP"},{"reasonText":"Loan is not applicable other than Used","ruleLevel":"LOAN TYPE NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"LOANTYPE_ELIG_002","ruleId":"LoanType_Used_Required","ruleDescription":"Loan is not applicable other than Used","outcome":"NSTP"},{"reasonText":"Income criteria not met.","ruleLevel":"INCOME NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"INCOME_ELIG_003","ruleId":"Documented_Income_GTE350K_SAL","ruleDescription":"Income criteria not met.","outcome":"NSTP"},{"reasonText":"CIBIL Score norm not met.","ruleLevel":"CIBIL SCORE NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"CIBIL_SCORE_ELIG_002","ruleId":"CIBIL_SCORE_GTE_725","ruleDescription":"CIBIL Score norm not met.","outcome":"NSTP"}]},{"schemeType":"BUSINESS","maxLTV":0,"calculatedVariables":[],"maxEligibileLoanAmount":0,"finalIRR":0,"finalProcessingFee":0,"schemeName":"On Road Maruti Alto Eeco","isEligible":false,"schemeId":"Scheme 0005","schemDecision":"NSTP","maxEligibileTenure":0,"eligibilityRules":[{"reasonText":"Applicant is not defined as IB type.","ruleLevel":"CUSTOMER GRADE NORM","applicantType":"PRIMARY","rulesetName":"RS_BS_ApplicantRules","reasonCode":"CUSTOMER_GRADE_ELIG_001","ruleId":"IB_Allowed","applicantId":"A-00009168","ruleDescription":"Applicant is not defined as IB type.","outcome":"NSTP"},{"reasonText":"Applicant doesnâu0080u0099t taken any preferred loans in past.","ruleLevel":"BUREU NORM","applicantType":"PRIMARY","rulesetName":"RS_BS_ApplicantRules","reasonCode":"CIBIL_ELIG_005","ruleId":"EXISTING_LOANS_CHECK","applicantId":"A-00009168","ruleDescription":"Applicant doesnâu0080u0099t taken any preferred loans in past.","outcome":"NSTP"},{"reasonText":"OHP criteria not met.","ruleLevel":"OHP NORM","applicantType":"PRIMARY","rulesetName":"RS_BS_AddressRules","reasonCode":"ADDRESS_ELIG_004","ruleId":"Current_Address_Owned_Allowed","applicantId":"A-00009168","ruleDescription":"OHP criteria not met.","outcome":"NSTP"},{"reasonText":"Branch region is not in Gujarat","ruleLevel":"BRANCH REGION NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"BRANCH_ELIG_001","ruleId":"Branch_Region_Allowed","ruleDescription":"Branch region is not in Gujarat","outcome":"NSTP"},{"reasonText":"CIBIL Score norm not met.","ruleLevel":"CIBIL SCORE NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"CIBIL_SCORE_ELIG_003","ruleId":"CIBIL_SCORE_GTE_700_NTC","ruleDescription":"CIBIL Score norm not met.","outcome":"NSTP"},{"reasonText":"Vehicle Model criteria not met","ruleLevel":"MODEL NORM","applicantType":"PRIMARY","rulesetName":"RS_BS_VehicleRules","reasonCode":"MODEL_ELIG_004","ruleId":"Allowed_Model_1","applicantId":"A-00009168","ruleDescription":"Vehcile allowed except Alto and EECO","outcome":"NSTP"}]},{"schemeType":"BUSINESS","maxLTV":0,"calculatedVariables":[],"maxEligibileLoanAmount":0,"finalIRR":0,"finalProcessingFee":0,"schemeName":"BRANCH_TOP_UP_SCHEME","isEligible":false,"schemeId":"Scheme 0012","schemDecision":"NSTP","maxEligibileTenure":0,"eligibilityRules":[{"reasonText":"Requested tenor is more than 48 months","ruleLevel":"MAX TENURE NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"MAX_TENOR_ELIG_007","ruleId":"Tenor_4Years","ruleDescription":"Tenure is more than norm","outcome":"NSTP"},{"reasonText":"not a top up request","ruleLevel":"TOP UP NORM","rulesetName":"RS_BS_ApplicationRules","reasonCode":"TOP_UP_001","ruleId":"Topup_Request_Check","ruleDescription":"not a Top Up Request","outcome":"NSTP"}]},{"schemeType":"NORMAL","maxLTV":75,"maxEligibileLoanAmount":500000,"finalIRR":14,"finalProcessingFee":5900,"schemeName":"Normal","isEligible":true,"schemeId":"Scheme 0001","schemDecision":"NSTP","maxEligibileTenure":60,"deviationsDetails":[{"reasonText":"GEO LIMIT EXCEED","ruleLevel":"OGL NORM","overrideAuthority":"S4","applicantType":"PRIMARY","calculatedVariables":[{"fieldName":"DISTANCE_FROM_BRANCH","level":"Policy","fieldType":"Integer","fieldValue":"100"},{"fieldName":"DISTANCE_FROM_BRANCH","level":"Actual","fieldType":"Integer","fieldValue":"249.0"}],"rulesetName":"RS_NTSP_CommonDeviations","reasonCode":"GEO_LIIMIT_DEV005","ruleId":"GeoLimitsCheck","applicantId":"A-00009168","outcome":"NSTP"},{"reasonText":"applicant age < 24 years","ruleLevel":"AGE NORM","overrideAuthority":"S4","applicantType":"PRIMARY","rulesetName":"RS_NTSP_CommonDeviations","reasonCode":"AGE_NORM_DEV001","ruleId":"Applicant_Age_Check","applicantId":"A-00009168","outcome":"NSTP"},{"reasonText":"No house ownership","ruleLevel":"RESIDENCE STABILITY NORM","overrideAuthority":"S4","applicantType":"PRIMARY","rulesetName":"RS_NSTP_NON_LUXARY_DEVIATIONS","reasonCode":"NON_LUXARY_RS_DEV001","ruleId":"Residence_Stability_NIB_Check","applicantId":"A-00009168","outcome":"NSTP"},{"reasonText":"LTV check failed","ruleLevel":"LTV NORM","overrideAuthority":"S4","applicantType":"PRIMARY","calculatedVariables":[{"fieldName":"LTV","level":"Policy","fieldType":"Real","fieldValue":"75.0"},{"fieldName":"LTV","level":"Actual","fieldType":"Real","fieldValue":"102.04081632653062"}],"rulesetName":"RS_NSTP_NON_LUXARY_DEVIATIONS","reasonCode":"NON_LUXARY_LTV_DEV001","ruleId":"New_LTV_Check","applicantId":"A-00009168","outcome":"NSTP"}],"eligibilityRules":[]}],"ruleAudits":[]},"requestedTenor":60,"productType":"AUTO_LOAN_NEW","requestedLoanAmount":500000,"existingTWExposure":0,"vehicleDetails":{"ltvOnVehicleCost":0,"loanAmountOnBody":0,"isVahanDataFetched":false,"vehicleCategory":"A","currentOwnerName":"","otherFundingItemsDetails":{"otherCosts":0,"insuranceAmount":0,"rtoAmount":10000,"lsAmount":0,"apportionedLoanAmount":500000,"assecessoriesAmount":0},"hoursMeterReading":0,"ownerSerialNumber":"","isTARSubmitted":false,"ltvOfferedOnBody":0,"newVehicleCostDetails":{"insurance":100000,"otherCosts":50000,"fairMarketValue":0,"finalCost":700000,"discount":10000,"onRoadPrice":600000,"approvedCustomerEquity":0,"costToBeConsidered":0,"netOfDiscountPrice":490000,"exShowroomPrice":500000,"priceVariance":0,"absoloutAmount":0,"rtoTaxes":10000,"assecessories":50000},"kmMeterReading":0,"HPNFinanciersName":"","variant":"MARUTI_CIAZ_ZXIPLUS_PETROL","model":"CIAZ","registrationCity":"","make":"MARUTI","maxFundingCap":0,"isRegisterable":false,"challanOverdueAmount":1000,"engineCategory":"BS6","vehicleUsage":"PERSONAL","maxLTV":75,"loanAmountOnChasisAndFullYBuild":0,"ltvOnRoad":83.33,"vehicleColour":"","isLuxaryVehicle":false,"isAccessoriesFunding":false,"fuelType":"PETROL","isVehicleDelivered":false,"isBlackListed":false,"bodyCost":0,"ltvExShowroom":102.04,"ltvOnFinalCost":71.43,"manufactureYear":2021,"manufactureMonth":4},"totalExposure":500000,"subProductType":"CAR","requestedPF":5900,"productCode":"10201","existingWheelExposure":0,"triggerDetails":{"sourcingTriggerLevel":"L1","branchTriggerType":"NA","dealerTriggerType":"NA","roTriggerType":"NA","sourcingTriggerType":"NA","branchTriggerLevel":"L1","roTriggerLevel":"L1","dealerTriggerLevel":"L1"},"existingTotalExposure":500000,"isTopUp":false,"apportionedLoanAmount":0}],"applicants":[{"relatedPartyStatus":"NO_MATCH","isPDSubmitted":false,"constitution":"INDIVIUDAL","isPhysicallyChallenged":false,"gender":"Male","customerRiskProfile":"NORMAL","isBiometricAddressNotChanged":true,"isLeadToLeadPartialMatch":true,"fcsToEMIRatio":0,"applicantDecision":{"fiInitiationDetails":[{"fiType":"CURRENT","isFIRequired":true,"pinCodeCategory":"NON_WORKING"},{"fiType":"PERMANENT","isFIRequired":false,"pinCodeCategory":"NON_WORKING"}],"calculatedVariables":[{"fieldName":"MAX_AL_SANCTION_AMOUNT_GT75Perc_POS_PAID","level":"Applicant","fieldType":"real","fieldValue":"0.0"},{"fieldName":"MAX_AL_SANCTION_AMOUNT","level":"Applicant","fieldType":"real","fieldValue":"0.0"},{"fieldName":"IS_AL_OPENED_L24M","level":"Applicant","fieldType":"boolean","fieldValue":"false"},{"fieldName":"IS_EXPECTED_LOANS_EXIST","level":"Applicant","fieldType":"boolean","fieldValue":"false"},{"fieldName":"IS_GT75Perc_POS_PAID_AL_ACTIVE","level":"Applicant","fieldType":"boolean","fieldValue":"false"},{"fieldName":"CAR_COUNT_DPD_60PLUS_ALL_ACCS_L36M","level":"Applicant","fieldType":"integer","fieldValue":"0"},{"fieldName":"CAR_COUNT_WRITEOFF_PRINCIPAL","level":"Applicant","fieldType":"integer","fieldValue":"0"},{"fieldName":"CAR_AL_ENQUIRIES_COUNT_L6M","level":"Applicant","fieldType":"integer","fieldValue":"1"},{"fieldName":"CAR_IS_90P_DPD_L12M","level":"Applicant","fieldType":"boolean","fieldValue":"false"},{"fieldName":"AVG_DELAY","level":"Applicant","fieldType":"integer","fieldValue":"0.0"},{"fieldName":"WRITE_OFF_FLAG","level":"Applicant","fieldType":"boolean","fieldValue":"false"},{"fieldName":"SETTLED_FLAG","level":"Applicant","fieldType":"boolean","fieldValue":"false"},{"fieldName":"COUNT_DPD_30PLUS_ALL_ACCS_L12M","level":"Applicant","fieldType":"integer","fieldValue":"0"},{"fieldName":"PEAK_DELAY","level":"Applicant","fieldType":"integer","fieldValue":"0"},{"fieldName":"COUNT_DPD_0P_L1M","level":"Applicant","fieldType":"integer","fieldValue":"0"},{"fieldName":"COUNT_OVERDUE_GTE_5K","level":"Applicant","fieldType":"integer","fieldValue":"0"},{"fieldName":"NON_RESTRUCTURED_WRITE_OFF_SETTLED_GTE_5K","level":"Applicant","fieldType":"boolean","fieldValue":"false"},{"fieldName":"COUNT_DPD_0P_AU_L1M","level":"Applicant","fieldType":"integer","fieldValue":"0"},{"fieldName":"COUNT_DPD_90PLUS_ALL_ACCS_SACTION_AMT_GT5K","level":"Applicant","fieldType":"integer","fieldValue":"0"},{"fieldName":"COUNT_DPD_90PLUS_ALL_ACCS","level":"Applicant","fieldType":"integer","fieldValue":"0"},{"fieldName":"CIBIL_SCORE","level":"Applicant","fieldType":"integer","fieldValue":"110"},{"fieldName":"CAR_IS_30P_DPD_L1M","level":"Applicant","fieldType":"boolean","fieldValue":"false"},{"fieldName":"ENQUIRIES_COUNT_L2M","level":"Applicant","fieldType":"integer","fieldValue":"3"},{"fieldName":"CAR_IS_HL_BL_AL_CV_GT_50Perc_PROPOSED_LA_DPD0P_L6M","level":"Applicant","fieldType":"boolean","fieldValue":"true"},{"fieldName":"CAR_IS_DPD0P_L6M_EXL_30DPD_OD_LTE5K","level":"Applicant","fieldType":"integer","fieldValue":"true"},{"fieldName":"TOTAL_REQUESTED_LOAN_AMOUNT","level":"Applicant","fieldType":"integer","fieldValue":"500000.0"},{"fieldName":"IS_RENTED_RCO_PROFILE","level":"Applicant","fieldType":"boolean","fieldValue":"false"},{"fieldName":"CURR_ADDR_OWNERSHIP_STATUS","level":"Applicant","fieldType":"string","fieldValue":"OWNED"},{"fieldName":"CURRENT_ADD_LOCATION_SUB_TYPE","level":"Applicant","fieldType":"string","fieldValue":"METRO"},{"fieldName":"CURRENT_ADD_LOCATION_TYPE","level":"Applicant","fieldType":"string","fieldValue":"URBAN"},{"fieldName":"PERM_ADD_PIN_CODE_CATEGORY","level":"Applicant","fieldType":"string","fieldValue":"NON_WORKING"},{"fieldName":"CURRENT_ADD_DISTANCE_FROM_BRANCH","level":"Applicant","fieldType":"real","fieldValue":"249.0"},{"fieldName":"CURRENT_ADD_RESIDENCE_TIME","level":"Applicant","fieldType":"real","fieldValue":"84.0"},{"fieldName":"LATEST_AMB","level":"Applicant","fieldType":"real","fieldValue":"0.0"},{"fieldName":"IS_CIBIL_ADDRESS_MATCHED","level":"Applicant","fieldType":"boolean","fieldValue":"false"},{"fieldName":"MAX_CASA_VINTAGE","level":"Applicant","fieldType":"integer","fieldValue":"0"},{"fieldName":"MAX_ASSET_VINTAGE","level":"Applicant","fieldType":"integer","fieldValue":"0"},{"fieldName":"ETB_TYPE_APPLICANT","level":"Applicant","fieldType":"string","fieldValue":"NA"},{"fieldName":"IS_EXISTING_CUST_FI1_PRODUCT","level":"Applicant","fieldType":"boolean","fieldValue":"false"},{"fieldName":"IS_EXISTING_CUST_FI2_PRODUCT","level":"Applicant","fieldType":"boolean","fieldValue":"false"},{"fieldName":"CIBIL_SEGMENTATION","level":"Applicant","fieldType":"string","fieldValue":"THIN_CIBIL"},{"fieldName":"IS_VERIFICATIONREPORTDATA_AVAILABLE","level":"Applicant","fieldType":"boolean","fieldValue":"false"},{"fieldName":"IS_RENETED_PROFILE","level":"Applicant","fieldType":"boolean","fieldValue":"false"},{"fieldName":"IS_OFFICE_EMIAL_VERIFIED","level":"Applicant","fieldType":"boolean","fieldValue":"true"},{"fieldName":"IS_CURRENT_ADDRESS_RENTED","level":"Applicant","fieldType":"boolean","fieldValue":"false"},{"fieldName":"IS_OHP_VALIDATED","level":"Applicant","fieldType":"boolean","fieldValue":"false"},{"fieldName":"MAX_OD_VINTAGE","level":"Applicant","fieldType":"real","fieldValue":"0"},{"fieldName":"IS_CURRENT_ADD_NEGATIVE","level":"Applicant","fieldType":"boolean","fieldValue":"false"},{"fieldName":"ETB_LIABILITY_3M_VINTAGE","level":"Applicant","fieldType":"boolean","fieldValue":"false"},{"fieldName":"ETB_ASSET_3M_VINTAGE","level":"Applicant","fieldType":"boolean","fieldValue":"false"},{"fieldName":"REPAYMENT_TRACK_SEGEMENATION","level":"Applicant","fieldType":"string","fieldValue":"ETR"},{"fieldName":"IS_AGE_NORM_MET","level":"Applicant","fieldType":"boolean","fieldValue":"true"},{"fieldName":"IS_CIBIL_PHONE_MATCHED","level":"Applicant","fieldType":"boolean","fieldValue":"false"},{"fieldName":"MAX_TW_VINTAGE","level":"Applicant","fieldType":"real","fieldValue":"0.0"},{"fieldName":"MAX_CA_VINTAGE","level":"Applicant","fieldType":"integer","fieldValue":"0"}],"bureauBasedIncomeEstimation":{"existingAccountIncomeDtls":[],"sumOfActiveCCLimit":0,"ccBasedEstimatedIncome":0,"noOfActiveCC":0,"estimatedIncome":0,"incomeMultiplier":0,"obligationBasedEstimatedIncome":0,"maxEMIAmount":0,"maxFOIR":0},"bureauBasedCommitmentDTls":{"existingAccountCommitment":[],"existingCommitment":0},"uwCriterias":[{"ruleId":"BIOMETRIC_EXISTING_LIABILITY_CUSTOMER_CATEGORY_A","rulesetName":"RS_STDCPVWaiverRules","reasonCode":"CPV Waived on Biometric","reasonText":"CPV Waived on Biometric","ruleLevel":"AADHAR_BIOMETRIC_CPV_WAIVER","applicantId":"196655438","applicantType":"PRIMARY"}]},"existingCustomer":false,"negativePartyStatus":"NO_MATCH","customerType":"I","freeToFinanceRatio":0,"idDetaiis":[{"idType":"PAN","isVerified":true},{"idType":"AADHAAR","isVerified":true}],"karzaData":[{"matchType":"PENDING","scoreOrValue":0,"subType":"APPLICANT_NAME","karzaVerificationType":"KYC"}],"applicantType":"PRIMARY","relationWithApplicant":"SELF","customerSegment":"SALARIED","isAUEmployee":false,"applicantId":"A-00009168","isFinancialApplicant":true,"expansionRatio":0,"noOfDependents":0,"shareholdingPercent":0,"address":[{"country":"IN","isResiCumOffice":false,"city":"AGRA","addressType":"CURRENT","isNegativeArea":false,"ownershipStatus":"OWNED","locationType":"URBAN","distanceFromBranch":249,"timeAtCurrentCity":0,"timeAtCurrentAddress":84,"pinCode":"282001","district":"NA","taluka":"NA","propertyType":"INDEPENDENT_HOUSE","pinCodeCategory":"NON_WORKING","locationSubType":"METRO","state":"Uttar Pradesh"},{"country":"IN","isResiCumOffice":false,"city":"Agra","addressType":"PERMANENT","isNegativeArea":false,"ownershipStatus":"OWNED","locationType":"URBAN","distanceFromBranch":0,"timeAtCurrentCity":0,"timeAtCurrentAddress":84,"pinCode":"282001","district":"Agra","taluka":"Dhanoli","propertyType":"INDEPENDENT_HOUSE","pinCodeCategory":"NON_WORKING","locationSubType":"METRO","state":"Uttar Pradesh"}],"cfrStatus":"NO_MATCH","isLeadToLeadFullMatch":true,"internalRiskScore":4,"employmentDetails":{"totalWorkExperience":24,"employmentType":"SALARIED_PRIVATE","employerName":"AU SMALL FINANCE BANK LIMITED","companyCategory":"CAT_A","timeWithCurrentEmployer":24},"dateOfBirth":"2000-11-08T00:00:00Z","emailDetails":[{"emailType":"PERSONAL","isEmailIdVerified":false}],"customerSubGrade":"SFO","ekycType":"OTP","isAgriRevenueProof":false,"incomeData":{"itrAmount":0,"yearlyObligation":0,"documentITRIncome":0,"totalMonthlyIncome":100000,"totalYearlyIncome":0,"verfiedAgriIncome":0,"monthlyIncentive":0,"grossRecPrevYear":0,"otherIncome":0,"grossRecCurrYear":0,"assessedIncome":0,"monthlyObligation":30000,"documentIncome":0,"yealryBonus":0,"patCurrYear":0,"patPrevYear":0,"documentSalariedIncome":0},"isETBAddressNotChanged":true,"amlStatus":"PENDING","nationality":"INDIAN","customerSegmentSubType":"SALARIED","isLeadToCustomerPartialMatch":false,"totalRelationshipValue":0,"etbType":"ROYALE","noOfCattle":0,"customerGrade":"IB","age":264,"maritalStatus":"SINGLE"}],"documentsReceived":[{"documentDate":"2023-06-20T00:00:00Z","documentDescription":"Pan Card/Form 60","isVerified":false,"documentId":"AUWheels0001","documentName":"Pan Card/Form 60","stabilityDate":"2023-06-20T00:00:00Z"},{"documentDate":"2023-06-20T00:00:00Z","documentDescription":"Aadhaar Card","isVerified":false,"documentId":"AUWheels0003","documentName":"Aadhaar Card","stabilityDate":"2023-06-20T00:00:00Z"}],"randomNumber":70,"applicationDecision":{"strategyUsed":"CHAMPION","calculatedVariables":[{"fieldName":"IS_CIBIL_SURROGATE","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"IS_FARMER_SURROGATE","level":"Application","fieldType":"boolean","fieldValue":"true"},{"fieldName":"IS_BANKING_SURROGATE","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"isFIRequired","level":"Application","fieldType":"boolean","fieldValue":"true"},{"fieldName":"MAX_FOIR","level":"Application","fieldType":"real","fieldValue":"70.0"},{"fieldName":"FOIR_DECLARED","level":"Application","fieldType":"real","fieldValue":"30.0"},{"fieldName":"COAPP_AGE_AT_TENURE","level":"Application","fieldType":"real","fieldValue":"0"},{"fieldName":"CO_APPLICANT_AGE","level":"Application","fieldType":"integer","fieldValue":"0"},{"fieldName":"IS_KNOCKED_OUT","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"IS_6M_BANKING_PRESENT","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"TOTAL_DECLARED_MONTHLY_INCOME","level":"Application","fieldType":"real","fieldValue":"100000.0"},{"fieldName":"ACCEPETABLE_DISTANCE_FROM_BRANCH","level":"Application","fieldType":"real","fieldValue":"100"},{"fieldName":"COAPP_CUSTOMER_SEGMENTATION_APPLICATION","level":"Application","fieldType":"string","fieldValue":"NA"},{"fieldName":"IS_OWNED_HOUSE","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"ETB_TYPE_APPLICATION","level":"Application","fieldType":"string","fieldValue":""},{"fieldName":"CO_APPLICANT_GURANTOR_AGE","level":"Application","fieldType":"integer","fieldValue":"0"},{"fieldName":"IS_CO_APPLICANT_GURANTOR_PRESENT","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"IS_CO_APPLICANT_PRESENT","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"FINAL_IRR","level":"Application","fieldType":"real","fieldValue":"14.0"},{"fieldName":"OVERRIDE_RATE_ADJUSTMENT_VALUE","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"ADJUSTED_OVERRIDE_RATE","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"OVERRIDE_RATE","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"ADJUSTED_BASE_RATE","level":"Application","fieldType":"real","fieldValue":"14.0"},{"fieldName":"BASE_RATE_ADJUSTMENT_VALUE","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"BASE_RATE_SEGMENT","level":"Application","fieldType":"string","fieldValue":"rateSegment6"},{"fieldName":"BASE_RATE","level":"Application","fieldType":"real","fieldValue":"14.0"},{"fieldName":"MAX_LTV","level":"Application","fieldType":"real","fieldValue":"75.0"},{"fieldName":"IS_GUARATOR_AVAILABLE","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"MIN_CIBIL_SCORE","level":"Application","fieldType":"integer","fieldValue":"110"},{"fieldName":"IS_WHEEL_PRODUCT","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"IS_3M_BANKING_PRESENT","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"IS_COMPANY_GOVT_PROVIDED_HOUSE","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"CUSTOMER_GRADE","level":"Application","fieldType":"string","fieldValue":"NIB"},{"fieldName":"PRIMARY_APPLICANT_AGE","level":"Application","fieldType":"integer","fieldValue":"264"},{"fieldName":"PRIMARY_APPLICANT_AGE_AT_TENOR","level":"Application","fieldType":"integer","fieldValue":"324"},{"fieldName":"MAX_TENURE","level":"Application","fieldType":"integer","fieldValue":"84"},{"fieldName":"MAX_CO_APP_BUSINESS_VINTAGE","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"HIGHEST_BUSI_EMP_STABILITY","level":"Application","fieldType":"real","fieldValue":"2.0"},{"fieldName":"IS_3MNTH_SALARY_CREDITED","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"TOTAL_DOCUMENTED_MONTHLY_INCOME","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"TOTAL_CREDIT_TXN_COUNT_L6M","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"TOTAL_AMB_L6M","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"TOTAL_AMC_L6M","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"TOTAL_VERIFIED_INCOME","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"TOTAL_DECLARED_OBLIGATION","level":"Application","fieldType":"real","fieldValue":"30000.0"},{"fieldName":"INTERNAL_OBLIGATION","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"FINAL_PF","level":"Application","fieldType":"real","fieldValue":"5900.0"},{"fieldName":"BUREAU_BASED_OBLIGATION","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"FOIR_AGRI","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"FOIR_DOCUMENTED","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"FOIR_VERIFIED","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"COMPUTED_OBLIGATION","level":"Application","fieldType":"real","fieldValue":"10831.0"},{"fieldName":"TOTAL_AVG_SALARY_L6M","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"MONTH1_CREDIT_TXN_AMOUNT","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"MONTH2_CREDIT_TXN_AMOUNT","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"MONTH3_CREDIT_TXN_AMOUNT","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"MONTH4_CREDIT_TXN_AMOUNT","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"MONTH5_CREDIT_TXN_AMOUNT","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"MONTH6_CREDIT_TXN_AMOUNT","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"MAX_CC_VINTAGE","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"IS_EXISTING_CUST_FI1_PRODUCT_FOR_PRIMARY","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"IS_BUREAU_OBLIGATION_COMPUTED_ONCE","level":"Application","fieldType":"boolean","fieldValue":"true"},{"fieldName":"ADJUSTED_IRR","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"IS_STP_APPLICABLE","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"VEHICLE_CATGEORY","level":"Application","fieldType":"string","fieldValue":"CAR"},{"fieldName":"IS_BUSINESS_ELIGIBLE","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"CUSTOMER_SEGEMENTATION","level":"Application","fieldType":"String","fieldValue":"SALARIED"},{"fieldName":"GRADE_MAX_ELIGIBLE_LOAN_AMT","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"FINAL_ADJUSTED_OVERRIDE_PF","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"ADJUSTED_PF_RATE","level":"Application","fieldType":"real","fieldValue":"1.15"},{"fieldName":"FINAL_ADJUSTED_BASE_PF","level":"Application","fieldType":"real","fieldValue":"5750.0"},{"fieldName":"ADJUSTED_OVERRIDE_PF_RATE","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"PF_RATE_ADJUSTMENT_VALUE","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"PF_RATE","level":"Application","fieldType":"real","fieldValue":"1.15"},{"fieldName":"IS_IRRIGATED_LAND","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"TOTAL_LAND_IN_ACRES","level":"Application","fieldType":"integer","fieldValue":"0"},{"fieldName":"REQUESTED_LTV","level":"Application","fieldType":"real","fieldValue":"102.04081632653062"},{"fieldName":"PRIMARY_APPLICATION_CUSTOMER_SEGMENT","level":"Application","fieldType":"string","fieldValue":"SALARIED"},{"fieldName":"MIN_WHEELS_VINTAGE","level":"Application","fieldType":"real","fieldValue":"999999"},{"fieldName":"MIN_OTHER_ASSETS_VINTAGE","level":"Application","fieldType":"real","fieldValue":"999999"},{"fieldName":"TOTAL_INWARD_CHEQUE_BOUNCE_L6M","level":"Application","fieldType":"inetger","fieldValue":"0"},{"fieldName":"OVERRIDE_PF_RATE","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"OVERRIDE_PF_RATE_ADJUSTMENT_VALUE","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"IS_6MNTH_SALARY_CREDITED","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"IS_LTV_NORM_MET","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"COM_DEV_AGE_NORM_AUTHORITY_LEVEL","level":"Application","fieldType":"string","fieldValue":"S4"},{"fieldName":"COM_DEV_AGE_NORM_REASON_TEXT","level":"Application","fieldType":"string","fieldValue":"applicant age < 24 years"},{"fieldName":"IS_TENURE_NORM_MET","level":"Application","fieldType":"boolean","fieldValue":"true"},{"fieldName":"NON_LUX_TENURE_NORM_AUTHORITY_LEVEL","level":"Application","fieldType":"string","fieldValue":""},{"fieldName":"NON_LUX_TENURE_NORM_REASON_TEXT","level":"Application","fieldType":"string","fieldValue":""},{"fieldName":"SCHEME_NAME","level":"Application","fieldType":"string","fieldValue":"NORMAL_NON-LUXURY_SCHEME"},{"fieldName":"LTV_NOD","level":"Application","fieldType":"real","fieldValue":"102.04081632653062"},{"fieldName":"MAX_VINTAGE_NEGATIVE","level":"Application","fieldType":"real","fieldValue":"0"},{"fieldName":"PRIMARY_CIBIL_SCORE","level":"Application","fieldType":"real","fieldValue":"110.0"},{"fieldName":"IS_ALLOWED_UNDER_NEGATIVE","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"MIN_INCOME","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"IS_FLEETDETAILS_AVAILABLE","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"IS_WORKED_NORM_MET","level":"Application","fieldType":"boolean","fieldValue":"true"},{"fieldName":"FI_INITIATION","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"FI1_PRODUCT","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"FI2_PRODUCT","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"NON_LUX_LTV_NORM_AUTHORITY_LEVEL","level":"Application","fieldType":"string","fieldValue":"S4"},{"fieldName":"IS_MULTI_ASSET_APP","level":"Application","fieldType":"boolean","fieldValue":"false"},{"fieldName":"IRR","level":"Application","fieldType":"real","fieldValue":"14.0"},{"fieldName":"BRANCH_TOP_UP_PROGRAM","level":"Application","fieldType":"string","fieldValue":""},{"fieldName":"MAX_CO_APPLICANT_AGE","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"MIN_CO_APPLICANT_AGE_AT_TENOR","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"MAX_RATE","level":"Application","fieldType":"real","fieldValue":"25.0"},{"fieldName":"MIN_RATE","level":"Application","fieldType":"real","fieldValue":"7.99"},{"fieldName":"PRIMARY_ACCOUNT_OS","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"MAX_ELIGIBLE_LOAN_AMOUNT","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"ORIGINAL_LOAN_AMOUNT","level":"Application","fieldType":"real","fieldValue":"0.0"},{"fieldName":"LTV_NORM_AUTHORITY_LEVEL","level":"Application","fieldType":"boolean","fieldValue":""},{"fieldName":"LUX_SUBJ_MSG","level":"Application","fieldType":"string","fieldValue":""},{"fieldName":"LUX_SUBJ_TYPE","level":"Application","fieldType":"string","fieldValue":""}],"systemDecision":"NSTP","systemDecisionDate":"2023-06-23T07:18:50Z","uwAuthority":"L1","ruleAudits":[{"ruleId":"","metaphorName":"FN_PreProcessing"},{"ruleId":"","metaphorName":"FN_ProductPreProcessing"},{"ruleId":"","metaphorName":"FN_ApplicationInitializations"},{"ruleId":"","metaphorName":"FN_ApplicationDerivations"},{"ruleId":"","metaphorName":"FN_DeriveCoAppCustomerSegment"},{"ruleId":"rule7","metaphorName":"DTAB_DeriveVehicleCategory"},{"ruleId":"rule403","metaphorName":"DTAB_AcceptableDistanceFromBranch"},{"ruleId":"","metaphorName":"FN_ApplicantInitializations"},{"ruleId":"","metaphorName":"FN_ApplicantDerivations"},{"ruleId":"","metaphorName":"FN_ApplicantBureauDerivations"},{"ruleId":"rule1","metaphorName":"DTAB_RepaymentTrackSegmentation"},{"ruleId":"rule1","metaphorName":"DTAB_DeriveCustomerSegmentation"},{"ruleId":"","metaphorName":"FN_AppendApplicantCalculatedVariables"},{"ruleId":"","metaphorName":"FN_KnockoutDecision"},{"ruleId":"","metaphorName":"FN_FOIRComputation"},{"ruleId":"","metaphorName":"FN_ApplicantInitializations"},{"ruleId":"","metaphorName":"FN_ApplicantDerivations"},{"ruleId":"","metaphorName":"FN_ApplicantBureauDerivations"},{"ruleId":"rule1","metaphorName":"DTAB_RepaymentTrackSegmentation"},{"ruleId":"rule1","metaphorName":"DTAB_DeriveCustomerSegmentation"},{"ruleId":"rule6","metaphorName":"DTAB_BaseRateSegmentation"},{"ruleId":"rule1","metaphorName":"DTAB_GetMinMaxRate"},{"ruleId":"rule22","metaphorName":"DTAB_MetroBaseRateTable"},{"ruleId":"rule22","metaphorName":"DTAB_MetroPFRateTable"},{"ruleId":"","metaphorName":"FN_ComputeIRR"},{"ruleId":"","metaphorName":"FN_ComputeFinalPF"},{"ruleId":"rule13","metaphorName":"DTAB_STPSchemeSelection"},{"ruleId":"","metaphorName":"FN_FI_Initiation"},{"ruleId":"rule1","metaphorName":"DTAB_FI_InitiationRules"},{"ruleId":"","metaphorName":"FN_Processing_FI_Waiver"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"AML_Status_Check","metaphorName":"RS_STP_Common_Eligibility_Rules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"Geo_Limit_Check","metaphorName":"RS_STP_Common_Eligibility_Rules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"Stability_Own_House_Check","metaphorName":"RS_STP_Common_Eligibility_Rules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"Salaried_Age_Norm","metaphorName":"RS_STP_Common_Eligibility_Rules"},{"ruleId":"rule1","metaphorName":"DTAB_CIBIL_SURROGATE"},{"ruleId":"Banking_Surrogate5","metaphorName":"RS_BANKING_SURROGATE"},{"ruleId":"Banking_Surrogate6","metaphorName":"RS_BANKING_SURROGATE"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"Banking_Cibil_Surrogate","metaphorName":"RS_STP_ApplicationRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"Income_Validation_SAL","metaphorName":"RS_STP_ApplicantRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"OnExshowroom_LTV_Upto_95Perc","metaphorName":"RS_STP_ApplicantRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"OnExshowroom_LTV_Upto_90Perc","metaphorName":"RS_STP_ApplicantRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"OnExshowroom_LTV_Upto_90Perc_SAL","metaphorName":"RS_STP_ApplicantRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"OnExshowroom_LTV_Upto_85Perc_Farmer","metaphorName":"RS_STP_ApplicantRules"},{"ruleId":"","metaphorName":"fn_AppendSubjectivityRules"},{"ruleId":"FI_POSITIVE","metaphorName":"RS_STP_Subjectivity_Messages_Rules"},{"ruleId":"","metaphorName":"fn_AppendSubjectivityRules"},{"ruleId":"NTB_TVR","metaphorName":"RS_STP_Subjectivity_Messages_Rules"},{"ruleId":"","metaphorName":"fn_AppendSubjectivityRules"},{"ruleId":"OHP","metaphorName":"RS_STP_Subjectivity_Messages_Rules"},{"ruleId":"","metaphorName":"FN_Derive_AU_Employee_EligibleLoanAmount"},{"ruleId":"","metaphorName":"FN_Compute_OutstandingBalance"},{"ruleId":"","metaphorName":"FN_Compute_OutstandingBalance"},{"ruleId":"","metaphorName":"FN_Derive_BranchTopUp_MaxEligibleLoanAmount"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"ETB_Customer_Allowed","metaphorName":"RS_BS_ApplicantRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"IB_Allowed","metaphorName":"RS_BS_ApplicantRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"Salaried_applicant_allowed_GOVT_CAT_A_B","metaphorName":"RS_BS_ApplicantRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"Selfemployed_applicant_allowed","metaphorName":"RS_BS_ApplicantRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"Govt_applicant_allowed","metaphorName":"RS_BS_ApplicantRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"Include_AU_Applicant","metaphorName":"RS_BS_ApplicantRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"EXISTING_LOANS_CHECK","metaphorName":"RS_BS_ApplicantRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"Current_Address_Owned_Allowed","metaphorName":"RS_BS_AddressRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"LoanType_Used_Required","metaphorName":"RS_BS_ApplicationRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"Documented_Income_GTE350K","metaphorName":"RS_BS_ApplicationRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"Documented_Income_GTE600K","metaphorName":"RS_BS_ApplicationRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"Documented_Income_MIN_RLA_GTE600K","metaphorName":"RS_BS_ApplicationRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"Documented_Income_GTE500K","metaphorName":"RS_BS_ApplicationRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"Documented_Income_GTE350K_SAL","metaphorName":"RS_BS_ApplicationRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"Branch_Region_Allowed","metaphorName":"RS_BS_ApplicationRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"Income_emi_ratio","metaphorName":"RS_BS_ApplicationRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"AQB_emi_ratio","metaphorName":"RS_BS_ApplicationRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"CIBIL_SCORE_GTE_725_NTC","metaphorName":"RS_BS_ApplicationRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"CIBIL_SCORE_GTE_725","metaphorName":"RS_BS_ApplicationRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"CIBIL_SCORE_GTE_700_NTC","metaphorName":"RS_BS_ApplicationRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"CIBIL_SCORE_GTE_700","metaphorName":"RS_BS_ApplicationRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"New_Min_Asset_Cost_GTE_800K","metaphorName":"RS_BS_ApplicationRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"Tenor_4Years","metaphorName":"RS_BS_ApplicationRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"Topup_Request_Check","metaphorName":"RS_BS_ApplicationRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"Electric_Allowed","metaphorName":"RS_BS_VehicleRules"},{"ruleId":"","metaphorName":"FN_AppendEligibilityUWCriteria"},{"ruleId":"Allowed_Model_1","metaphorName":"RS_BS_VehicleRules"},{"ruleId":"","metaphorName":"FN_GeneratingSchemeDecision"},{"ruleId":"","metaphorName":"FN_UpdateSchemeDecision"},{"ruleId":"","metaphorName":"FN_AppendSchemeDecisions"},{"ruleId":"","metaphorName":"FN_GovernmentScheme_PreProcessing"},{"ruleId":"","metaphorName":"FN_UpdateBusinessSchemeDecision"},{"ruleId":"","metaphorName":"FN_AppendSchemeDecisions"},{"ruleId":"","metaphorName":"FN_OnRoadSalaried_PreProcessing"},{"ruleId":"","metaphorName":"FN_UpdateBusinessSchemeDecision"},{"ruleId":"","metaphorName":"FN_AppendSchemeDecisions"},{"ruleId":"","metaphorName":"FN_SuperSupremeNew_PreProcessing"},{"ruleId":"","metaphorName":"FN_UpdateBusinessSchemeDecision"},{"ruleId":"","metaphorName":"FN_AppendSchemeDecisions"},{"ruleId":"","metaphorName":"FN_SuperSupremeUsedGovt_PreProcessing"},{"ruleId":"","metaphorName":"FN_UpdateBusinessSchemeDecision"},{"ruleId":"","metaphorName":"FN_AppendSchemeDecisions"},{"ruleId":"","metaphorName":"FN_AU_Employee_PreProcessing"},{"ruleId":"","metaphorName":"FN_UpdateBusinessSchemeDecision"},{"ruleId":"","metaphorName":"FN_AppendSchemeDecisions"},{"ruleId":"","metaphorName":"FN_SuperSupremeUrban_PreProcessing"},{"ruleId":"","metaphorName":"FN_UpdateBusinessSchemeDecision"},{"ruleId":"","metaphorName":"FN_AppendSchemeDecisions"},{"ruleId":"","metaphorName":"FN_OnRoadSelfEmployed_PreProcessing"},{"ruleId":"","metaphorName":"FN_UpdateBusinessSchemeDecision"},{"ruleId":"","metaphorName":"FN_AppendSchemeDecisions"},{"ruleId":"","metaphorName":"FN_SuperSupremeUsedNonGovt_PreProcessing"},{"ruleId":"","metaphorName":"FN_UpdateBusinessSchemeDecision"},{"ruleId":"","metaphorName":"FN_AppendSchemeDecisions"},{"ruleId":"","metaphorName":"FN_ONROAD_MARUTHI_PreProcessing"},{"ruleId":"","metaphorName":"FN_UpdateBusinessSchemeDecision"},{"ruleId":"","metaphorName":"FN_AppendSchemeDecisions"},{"ruleId":"","metaphorName":"FN_BranchTopUp_PreProcessing"},{"ruleId":"","metaphorName":"FN_UpdateBusinessSchemeDecision"},{"ruleId":"","metaphorName":"FN_AppendSchemeDecisions"},{"ruleId":"","metaphorName":"FN_DetermineBusinessEligibility"},{"ruleId":"","metaphorName":"FN_GeneratingCommonScheme"},{"ruleId":"rule4","metaphorName":"DTAB_Non_Luxary_ApplicantAgeDeviationCriteria"},{"ruleId":"","metaphorName":"FN_AppendCalVariablesInUWCriteria"},{"ruleId":"","metaphorName":"FN_AppendCalVariablesInUWCriteria"},{"ruleId":"","metaphorName":"FN_AppendDeviaitonsUWCriteriaInSchemeDecision"},{"ruleId":"GeoLimitsCheck","metaphorName":"RS_NTSP_CommonDeviations"},{"ruleId":"","metaphorName":"FN_AppendDeviaitonsUWCriteriaInSchemeDecision"},{"ruleId":"Applicant_Age_Check","metaphorName":"RS_NTSP_CommonDeviations"},{"ruleId":"","metaphorName":"FN_AppendSchemeDecisions"},{"ruleId":"","metaphorName":"FN_NormalSchemeInitializaitons"},{"ruleId":"","metaphorName":"FN_ApplicantInitializations"},{"ruleId":"","metaphorName":"FN_ApplicantDerivations"},{"ruleId":"","metaphorName":"FN_ApplicantBureauDerivations"},{"ruleId":"rule1","metaphorName":"DTAB_RepaymentTrackSegmentation"},{"ruleId":"rule1","metaphorName":"DTAB_DeriveCustomerSegmentation"},{"ruleId":"rule1","metaphorName":"DTAB_Non_Luxary_DeriveMaxFOIR"},{"ruleId":"LTV_NOD_GT100","metaphorName":"RS_Non_Luxary_LTVCheck"},{"ruleId":"","metaphorName":"FN_AppendDeviaitonsUWCriteriaInSchemeDecision"},{"ruleId":"Residence_Stability_NIB_Check","metaphorName":"RS_NSTP_NON_LUXARY_DEVIATIONS"},{"ruleId":"","metaphorName":"FN_AppendCalVariablesInUWCriteria"},{"ruleId":"","metaphorName":"FN_AppendCalVariablesInUWCriteria"},{"ruleId":"","metaphorName":"FN_AppendDeviaitonsUWCriteriaInSchemeDecision"},{"ruleId":"New_LTV_Check","metaphorName":"RS_NSTP_NON_LUXARY_DEVIATIONS"},{"ruleId":"","metaphorName":"FN_AppendNormalSchemeDecisions"},{"ruleId":"rule1","metaphorName":"DTAB_ExposureBasedAuthorityLevel"},{"ruleId":"","metaphorName":"FN_UpdateSTPScheme"},{"ruleId":"","metaphorName":"FN_ProductPostProcessing"},{"ruleId":"","metaphorName":"FN_PostProcessing"},{"ruleId":"","metaphorName":"FN_AppendApplicationCalcualtedVariables"}]},"applicationInfo":{"rmCode":"nayan.das","roName":"Nayan Das","applicationNumber":"RAJ0000007454","applicationCounter":1,"branchName":"Pratap Nagar Jaipur","branchRegion":"Rajasthan_01","rmName":"Nayan Das","applicationStage":"QDE","transactionId":"SFDCUAT_a89ec8c66c83be0015597e829","roCode":"nayan.das","branchCode":"2216","cityCategory":"","applicationId":"RAJ0000007454","branchHub":"HUB0034","leadId":"","applicationDate":"2023-06-23T06:52:31Z"}},"responseTime":"Jun 23, 2023 7:18:50.56 AM UTC","dmResponseTime":"Jun 23, 2023 7:18:50.56 AM UTC","decisionService":"DS_CAR","dmRequestTime":"Jun 23, 2023 7:18:50.47 AM UTC","responseStatus":"SUCCESS","callType":"DP_ELIGIBILITY","elapsedTime":-12596313}}'
        ),true);
        
        Integration_Checklist__c  intChecklist2 = (Integration_Checklist__c )TestFactory.createSObject(new Integration_Checklist__c(
            is_Latest__c = true,
            Applicant__c= appl.Id,
            Request_Id__c='IC001001002',
            Integration_Master__c = CanDOIntegrationMaster.Id,
            Loan_Application__c = loanAppl.Id,
            Callback_Request__c = '{"message":{"requestTime":"Jun 23, 2023 12:48:46.873 PM IST","dmElapsedTime":90,"responseStatus":"ERROR","error":[{"errorCode":"401","description":"Bad Request"}]}}'
        ),true);
        
        Fleet__c objFleet = (Fleet__c)TestFactory.createSObject(new Fleet__c(
            Loan_Application__c=loanAppl.Id,
            Relationship_with_borrower__c = 'Father',
            Vehicle_Number__c  = '7847',
            Name = 'Bike', 
            Vehicle_Make_Model__c = '2022', 
            MFG_Year__c='2022', 
            HPN_Status__c='Free'
        ),true);
        
        Bureau_Results__c  brRslt = (Bureau_Results__c )TestFactory.createSObject(new Bureau_Results__c(
            Name = 'CIBIL Score',
            Bureau__c = 'CIBIL',
            Applicant__c = appl.Id,
            Bureau_Response__c = 'Pass'
        ),true);
        
        Id cbsRecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CBS').getRecordTypeId();
        Id cartRecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('Cart').getRecordTypeId();
        //CART Account
        Bank_Account_Records__c cartAccountInstance = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
            Applicant__c = appl.Id,
            Account_Type__c = 'ODCC',
            Loan_Amount__c =1000,
            EMI_Amount__c =200,
            RecordTypeId = cartRecordTypeId,
            Analysis_Data__c = '{"monthlyBalancesDetails":"","monthlyCreditsDetails":"","bankName":"AU","accountType":"SAVING","toBeConsidered":false,"status":"OTHERS"}',
            Account_Opening_Date__c = System.today()
        ),true);
        
        
        Field_Investigation__c fieldInvestigationObj= (Field_Investigation__c)TestFactory.createSObject(new Field_Investigation__c( 
            Name = appl.First_Name__c,
            Loan_Application__c =loanAppl.Id,
            Applicant__c=appl.Id,
            FI_Status__c ='POSITIVE',
            Proposed_vehicle__c=GlobalConstants.AUTOLOANNEW,
            Applicant_Type__c='Applicant',
            Re_Trigger__c = false,
            Type_of_Address__c='Current'
        ),true);
        
        

        /*Charge__c ch= new Charge__c(Value_Type__c = 'Fixed',Deviation_Applicable__c='Yes',
                    Charge_Amount__c=200,Rate_value_As_per_Policy__c=675,SC_Code__c='101',
                                    Actual_rate__c=270, Loan_Application__c =loanAppl.Id
                                    );
        insert ch;*/

        MMV_Master__c  modelmvM = (MMV_Master__c)TestFactory.createSObject(new MMV_Master__c (
            Name='ZX MT_DIESEL1', RecordTypeId = modelRecTypeId
        ),true); 
        MMV_Master__c  makemvM = (MMV_Master__c)TestFactory.createSObject(new MMV_Master__c (
            Name='ZX MT_DIESEL2', RecordTypeId = makeRecTypeId
        ),true);
        
        Master_Junction_Mapping__c objJM = new Master_Junction_Mapping__c(Charges__c=objCM3.Id, Make_Model__c = modelmvM.Id,
        RecordTypeId=Schema.SObjectType.Master_Junction_Mapping__c.getRecordTypeInfosByDeveloperName().get('Charge').getRecordTypeId(),
        SC_Name__c='Rajasthan',SC_Code__c='101',Value_Type__c = 'Fixed',Sequence_NO__c=1,Territory__c=branchMaster.Id);
        insert objJM;

        Master_Junction_Mapping__c objJM2 = new Master_Junction_Mapping__c(Charges__c=objCM3.Id,  Make_Model__c = makemvM.Id,
        RecordTypeId=Schema.SObjectType.Master_Junction_Mapping__c.getRecordTypeInfosByDeveloperName().get('Charge').getRecordTypeId(),
        SC_Name__c='Rajasthan',SC_Code__c='101',Value_Type__c = 'Fixed',Sequence_NO__c=2,Territory__c=bhub.Id);
        insert objJM2;

        Master_Junction_Mapping__c objJM3 = new Master_Junction_Mapping__c(Charges__c=objCM3.Id,  Make_Model__c = modelmvM.Id,
        RecordTypeId=Schema.SObjectType.Master_Junction_Mapping__c.getRecordTypeInfosByDeveloperName().get('Charge').getRecordTypeId(),
        SC_Name__c='Rajasthan',SC_Code__c='101',Value_Type__c = 'Fixed',Sequence_NO__c=3,Territory__c=state.Id);
        insert objJM3;

        Master_Junction_Mapping__c objJM4 = new Master_Junction_Mapping__c(Charges__c=objCM3.Id,  Make_Model__c = modelmvM.Id,
        RecordTypeId=Schema.SObjectType.Master_Junction_Mapping__c.getRecordTypeInfosByDeveloperName().get('Charge').getRecordTypeId(),
        SC_Name__c='Rajasthan',SC_Code__c='101',Value_Type__c = 'Fixed',Sequence_NO__c=4,Territory__c=region.Id);
        insert objJM4;

        Master_Junction_Mapping__c objJM5 = new Master_Junction_Mapping__c(Charges__c=objCM3.Id,  Make_Model__c = makemvM.Id,
        RecordTypeId=Schema.SObjectType.Master_Junction_Mapping__c.getRecordTypeInfosByDeveloperName().get('Charge').getRecordTypeId(),
        SC_Name__c='Rajasthan',SC_Code__c='101',Value_Type__c = 'Fixed',Sequence_NO__c=4,Territory__c=region.Id);
        insert objJM5;

    }
    
    static testmethod void testGetCustomMetaRecStageProfle(){
        Test.startTest();
            ChargesController.getCustomMetaRecStageProfle();
        Test.stopTest();
    }
    
    static testmethod void testGetBurRes(){
        Test.startTest();
            String ApplicantId = [Select Id from Applicant__c].Id;
            ChargesController.getBurRes(ApplicantId,'CIBIL');
    }
    
    static testmethod void testGetCollateral(){
        Test.startTest();
            String LoanAppId = [Select Id from Loan_Application__c].Id;
            ChargesController.getCollateral(LoanAppId);
        Test.stopTest();
    }
    
    static testmethod void testSchemeQuery(){
        Test.startTest();
            ChargesController.product = '10201';
            ChargesController.burScore = 80;
            ChargesController.loanAmount = 300000;
            //ChargesController.manufactureYear = '1990';
            ChargesController.schemeQuery('Normal','No Charges');
        Test.stopTest();
    }
    static testmethod void testSchemeQueryNoCharges(){
        Test.startTest();
            ChargesController.product = '10201';
            ChargesController.burScore = 80;
            ChargesController.loanAmount = 300000;
            //ChargesController.manufactureYear = '1990';
            ChargesController.schemeQuery('Normal',null);
        Test.stopTest();
    }
    
    static testmethod void testMakeDefaultValLst(){
        Test.startTest();
            ChargesController.product = '10201';
            ChargesController.burScore = 80;
            ChargesController.loanAmount = 300000;
        // ChargesController.manufactureYear = '1990';
            ChargesController.collatType = '10101';
            ChargesController.custmerType = 'ETB';
            ChargesController.fuelTypeFromColl='Petrol';
            ChargesController.vehclUsageFromColl = 'Personal';
            ChargesController.scCodeVSChargeMstrMap = new Map<String, Charges_Master__c>();
            ChargesController.loanApplcRecList = [Select Id,Dealer_Master__c,Dealer_Master__r.Account_Code__c,Branch_Master__c,Branch_Master__r.Account_Code__c,Branch_Master__r.State_Code__c,Branch_Master__r.Hub_Code__c,Branch_Master__r.Region_Code__c, (Select Id, Make__c, Model__c from Collaterals__r) from Loan_Application__c];
            Charges_Master__c objNormal = [Select Id from Charges_Master__c where SC_Name__c = 'Normal' Limit 1];
            ChargesController.makeDefaultValLst();
            ChargesController.product = '10201';
            ChargesController.burScore = 80;
            ChargesController.schemeNameFromLoan='Normal';
            ChargesController.collatType = '10101';
            ChargesController.custmerType = 'ETB';  
            ChargesController.overrideDefaultValLst();
            String LoanAppId = [Select Id from Loan_Application__c].Id;
            ChargesController.chargesHandler(LoanAppId);
        Test.stopTest();
    }
    
    static testmethod void testCreateChargeRecord(){
        Test.startTest();
            ChargesController.loanAmount = 300000;
            ChargesController.processingFee = 3000;
            ChargesController.collatType = '10101';
            ChargesController.custmerType = 'ETB';    
            List<Charges_Master__c> lstobjCM = [SELECT id, Product_Code__c, Is_territory_General__c, Is_Make_model_General__c, Is_Dealer_General__c,
                                                        Collateral_Type__c, Customer_Type__c, Fuel_Type__c, Vehicle_Usages__c,
                                                        SC_Name__c, SC_Code__c, Value_Type__c, Sequence_NO__c, Dedn_Cod__c, 
                                                        Rate_value_As_per_Policy__c, Tax_Applicable__c, Tax_Percentage__c, 
                                                        Min_charges__c, Max_Charges_SOC__c, Customer_category__c, Model_Age__c, 
                                                        Deviation_Applicable__c, Shown_to_UI__c
                                                        FROM Charges_Master__c];
            String LoanAppId = [Select Id from Loan_Application__c].Id;
            List<Charge__c> lstCharge = new List<Charge__c>();
            ChargesController.custmerType = 'ETB';  
            for (Charges_Master__c objCM : lstobjCM) {
                objCM.Value_Type__c = 'Percent';
                ChargesController.createChargeRecord(objCM);
                objCM.Value_Type__c = 'Fixed';
                ChargesController.createChargeRecord(objCM);
                ChargesController.isFromBre = true;
                Charge__c objCharges = ChargesController.createChargeRecord(objCM);
                
                objCharges.Loan_Application__c = LoanAppId;
                lstCharge.add(objCharges);
            }
            insert lstCharge;
            ChargesController.chargesHandler(LoanAppId);
            ChargesController.collatType = '10101';
            ChargesController.custmerType = 'ETB';  
            ChargesController.overrideDefaultValLst();
            ChargesController.chargesHandler (LoanAppId);
            
            
        Test.stopTest();
    }
    
    static testmethod void testChargesHandler(){
        Test.startTest();
            String LoanAppId = [Select Id from Loan_Application__c].Id;
            ChargesController.chargesHandler(LoanAppId);
        Test.stopTest();
    }
    
    static testmethod void testGetLoanAppl(){
        Test.startTest();
            String LoanAppId = [Select Id from Loan_Application__c].Id;
            ChargesController.getLoanAppl(LoanAppId);
        Test.stopTest();
    }
    
    static testmethod void testGetMasterJuncMapping(){
        Test.startTest();
            ChargesController.getMasterJuncMapping(null,null);
        Test.stopTest();
    }
    
    static testmethod void testGetScreenType(){
        Test.startTest();
            ChargesController.getScreenType(System.label.AUSFNewScreen);
            ChargesController.getScreenType(System.label.AUSFUsedScreen);
            ChargesController.getScreenType(System.label.AUSFCowScreen);
            ChargesController.getScreenType('Return Null');
        Test.stopTest();
    }
    
    static testmethod void testInitialize(){
        Test.startTest();
            String loanAppId = [Select Id from Loan_Application__c].Id;
            ChargesController.initialize(loanAppId);
        Test.stopTest();
    }
    
    static testmethod void testSaveCharges(){
        Test.startTest();
            String loanAppId = [Select Id from Loan_Application__c].Id;
            ChargesController.saveCharges(new List<Charge__c>{new Charge__c(Value_Type__c = 'Fixed',External_Id_For_Upsert__c = '12345', Deviation_Applicable__c='Yes',Total_Amount__c=100000,
                                                                            Charge_Amount__c=200,Rate_value_As_per_Policy__c=675,SC_Code__c='101',
                                        Actual_rate__c=270, Loan_Application__c =loanAppId)});
        Test.stopTest();
    }
    
    static testmethod void testCalculateStampDutyCharge(){
        Test.startTest();
            ChargesController.loanAmount = 300000;
            List<Stamping_Charges_Calculation__mdt> stampChrgesCalculationLst = [SELECT id, MasterLabel,Is_Stamping_Act_Loan_Cap_Less_than__c,
                                                                                As_per_Stamping_Act_Loan_Cap__c, As_per_Stamping_Act__c, As_per_Stamping_Act_Value_Type__c,
                                                                                Guarantee_Deed_Loan_Cap__c, Is_Guarantee_Deed_Loan_Cap_Less_than__c,
                                                                                Guarantee_Deed_Each_Gaurantor__c, Guarantee_Deed_Value_Type__c,
                                                                                Round_off_Upper_side_on_A_By_Rs__c, POA__c, Surcharge__c
                                                                                FROM Stamping_Charges_Calculation__mdt
                                                                                WHERE State__c ='Rajasthan'];
            ChargesController.FldsWrapper objFW = new ChargesController.FldsWrapper();
            ChargesController.calculateStampDutyCharge(objFW,stampChrgesCalculationLst);
            //LoanTriggerService.calculateStampDutyCharge(objFW,stampChrgesCalculationLst,ChargesController.loanAmount);
        Test.stopTest();
    }
    
    static testmethod void testCalculateStampDutyCharge2(){
        Test.startTest();
            ChargesController.loanAmount = 3000000;
            List<Stamping_Charges_Calculation__mdt> stampChrgesCalculationLst = [SELECT id, MasterLabel,Is_Stamping_Act_Loan_Cap_Less_than__c,
                                                                                As_per_Stamping_Act_Loan_Cap__c, As_per_Stamping_Act__c, As_per_Stamping_Act_Value_Type__c,
                                                                                Guarantee_Deed_Loan_Cap__c, Is_Guarantee_Deed_Loan_Cap_Less_than__c,
                                                                                Guarantee_Deed_Each_Gaurantor__c, Guarantee_Deed_Value_Type__c,
                                                                                Round_off_Upper_side_on_A_By_Rs__c, POA__c, Surcharge__c
                                                                                FROM Stamping_Charges_Calculation__mdt
                                                                                WHERE State__c ='Rajasthan'];
            ChargesController.FldsWrapper objFW = new ChargesController.FldsWrapper();
            ChargesController.calculateStampDutyCharge(objFW,stampChrgesCalculationLst);
        Test.stopTest();
	}
    static testmethod void recalculate(){
        Test.startTest();
            Loan_Application__c la = [Select Id,Product__c from Loan_Application__c];
            Set<Id> loanSet = new Set<Id>();
            loanSet.add(la.Id);
            Charge__c chargeInstance = new Charge__c();
            chargeInstance.Value_Type__c = 'Percent';
            chargeInstance.Loan_Application__c = la.Id;
            chargeInstance.Actual_rate__c = 1;
            insert chargeInstance;
            
            ChargesController.loanApplcRecList = [SELECT Id, Product__c  FROM Loan_Application__c WHERE Id = :la.Id] ;
            loanTriggerService.recalculateCharges(loanSet);
            /*SELECT Id, Actual_rate__c, Charge_Amount__c, Tax_Amount__c, Total_Amount__c,Loan_Application__r.Loan_Amount__c,Loan_Application__c,
                                        Charges_Name__c, SC_Code__c, Value_Type__c, Sequence_NO__c, Dedn_Cod__c, 
                                        Rate_value_As_per_Policy__c, Tax_Applicable__c, Tax_Percentage__c, 
                                        Min_charges__c, Max_Charges_SOC__c, Customer_category__c, Model_Age__c, 
                                        Deviation_Applicable__c, Shown_to_UI__c 
                                        FROM Charge__c 
                                        WHERE Loan_Application__c IN :loanIds
                                        AND Value_Type__c='Percent'*/
        Test.stopTest();
    }
    
    static testmethod void testOverrideChargeAmount(){
        Test.startTest();
            Loan_Application__c la = [Select Id,Product__c from Loan_Application__c];
            la.Product__c = '10301';
            update la;
            ChargesController.loanApplcRecList = [Select Id,Product__c,Dealer_Master__c,Dealer_Master__r.Account_Code__c,Dealer_Master__r.Processing_Fees__c,Dealer_Master__r.Document_Charges__c from Loan_Application__c];
            ChargesController.FldsWrapper objFW = new ChargesController.FldsWrapper();
            objFW.taxPercentage=10;
            objFW.scName = 'Processing Fees';
            objFW.chargeAmount = 10000;
            ChargesController.overrideChargeAmount(objFW);
            objFW.scName = 'Documentation Charges';
            ChargesController.overrideChargeAmount(objFW);
        Test.stopTest();
    }

    static testmethod void testwrapperFldsOfMasterJuncMapp(){
        Test.startTest();
            List<Master_Junction_Mapping__c> lstMJP = [SELECT Id, SC_Name__c, SC_Code__c, Value_Type__c, Sequence_NO__c, Dedn_Cod__c, Rate_value_As_per_Policy__c, Tax_Applicable__c, Tax_Percentage__c, Min_charges__c, Max_Charges_SOC__c, Customer_category__c, Model_Age__c, Deviation_Applicable__c, Shown_to_UI__c 
            FROM Master_Junction_Mapping__c];

            List<Charges_Master__c> lstobjCM = [SELECT id, Product_Code__c, Is_territory_General__c, Is_Make_model_General__c, Is_Dealer_General__c,
                                                        Collateral_Type__c, Customer_Type__c, Fuel_Type__c, Vehicle_Usages__c,
                                                        SC_Name__c, SC_Code__c, Value_Type__c, Sequence_NO__c, Dedn_Cod__c, 
                                                        Rate_value_As_per_Policy__c, Tax_Applicable__c, Tax_Percentage__c, 
                                                        Min_charges__c, Max_Charges_SOC__c, Customer_category__c, Model_Age__c, 
                                                        Deviation_Applicable__c, Shown_to_UI__c
                                                        FROM Charges_Master__c];

            
            ChargesController.wrapperFldsOfMasterJuncMapp(lstMJP[0]);
            ChargesController.wrapperFldsOfChargeMstr(lstobjCM[0]);
            

        Test.stopTest();
    }

    static testmethod void testOverrideDefaultValLst(){
        Test.startTest();
            ChargesController.loanAmount = 300000;
            ChargesController.processingFee = 3000;
            ChargesController.collatType = '10101';
            ChargesController.custmerType = 'ETB';    
            List<Charges_Master__c> lstobjCM = new List<Charges_Master__c>();
            for (Charges_Master__c obj : [SELECT id, Product_Code__c, Is_territory_General__c, Is_Make_model_General__c, Is_Dealer_General__c,
                                                        Collateral_Type__c, Customer_Type__c, Fuel_Type__c, Vehicle_Usages__c,
                                                        SC_Name__c, SC_Code__c, Value_Type__c, Sequence_NO__c, Dedn_Cod__c, 
                                                        Rate_value_As_per_Policy__c, Tax_Applicable__c, Tax_Percentage__c, 
                                                        Min_charges__c, Max_Charges_SOC__c, Customer_category__c, Model_Age__c, 
                                                        Deviation_Applicable__c, Shown_to_UI__c
                                                        FROM Charges_Master__c]){
                obj.Is_territory_General__c = 'TRUE';
                obj.Is_Make_model_General__c = 'TRUE';
                obj.Is_Dealer_General__c = 'TRUE';
                lstobjCM.add(obj);

            }
            update lstobjCM;
            String LoanAppId = [Select Id from Loan_Application__c].Id;
            List<Charge__c> lstCharge = new List<Charge__c>();
            ChargesController.custmerType = 'ETB';
            Integer iext = 1;
            for (Charges_Master__c objCM : lstobjCM) {
                objCM.Value_Type__c = 'Percent';
                ChargesController.createChargeRecord(objCM);
                objCM.Value_Type__c = 'Fixed';
                ChargesController.createChargeRecord(objCM);
                ChargesController.isFromBre = true;
                Charge__c objCharges = ChargesController.createChargeRecord(objCM);
                objCharges.External_Id_For_Upsert__c = 'charge'+iext;
                objCharges.Loan_Application__c = LoanAppId;
                lstCharge.add(objCharges);
                iext++;
            }
            insert lstCharge;
            ChargesController.chargesHandler(LoanAppId);
            ChargesController.collatType = '10101';
            ChargesController.custmerType = 'ETB';
            List<Master_Junction_Mapping__c> lstUpdateMJM = new List<Master_Junction_Mapping__c>();
            for (Master_Junction_Mapping__c obj : [Select Id, Charges__c from Master_Junction_Mapping__c]) {
            
                obj.Charges__c =  lstobjCM[0].Id;
                lstUpdateMJM.add(obj);
            }
            update lstUpdateMJM;
            ChargesController.overrideDefaultValLst();
            ChargesController.saveCharges (lstCharge);
            
            
        Test.stopTest();
    }

    static testmethod void testSetStaticVariables(){
        Test.startTest();
            ChargesController.loanAmount = 300000;
            ChargesController.processingFee = 3000;
            ChargesController.collatType = '10101';
            ChargesController.custmerType = 'ETB';    
            List<Charges_Master__c> lstobjCM = new List<Charges_Master__c>();
            for (Charges_Master__c obj : [SELECT id, Product_Code__c, Is_territory_General__c, Is_Make_model_General__c, Is_Dealer_General__c,
                                                        Collateral_Type__c, Customer_Type__c, Fuel_Type__c, Vehicle_Usages__c,
                                                        SC_Name__c, SC_Code__c, Value_Type__c, Sequence_NO__c, Dedn_Cod__c, 
                                                        Rate_value_As_per_Policy__c, Tax_Applicable__c, Tax_Percentage__c, 
                                                        Min_charges__c, Max_Charges_SOC__c, Customer_category__c, Model_Age__c, 
                                                        Deviation_Applicable__c, Shown_to_UI__c
                                                        FROM Charges_Master__c]){
                obj.Is_territory_General__c = 'TRUE';
                obj.Is_Make_model_General__c = 'TRUE';
                obj.Is_Dealer_General__c = 'TRUE';
                lstobjCM.add(obj);

            }
            update lstobjCM;
            List<Loan_Application__c> lstLA = [Select Id from Loan_Application__c Limit 1];
            String LoanAppId = lstLA[0].Id;
            List<Charge__c> lstCharge = new List<Charge__c>();
            ChargesController.custmerType = 'ETB';
            for (Charges_Master__c objCM : lstobjCM) {
                objCM.Value_Type__c = 'Percent';
                ChargesController.createChargeRecord(objCM);
                objCM.Value_Type__c = 'Fixed';
                ChargesController.createChargeRecord(objCM);
                ChargesController.isFromBre = true;
                Charge__c objCharges = ChargesController.createChargeRecord(objCM);
                
                objCharges.Loan_Application__c = LoanAppId;
                lstCharge.add(objCharges);
            }
            insert lstCharge;
            ChargesController.chargesHandler(LoanAppId);
            ChargesController.collatType = '10101';
            ChargesController.custmerType = 'ETB';
            List<Master_Junction_Mapping__c> lstUpdateMJM = new List<Master_Junction_Mapping__c>();
            for (Master_Junction_Mapping__c obj : [Select Id, Charges__c from Master_Junction_Mapping__c]) {
            
                obj.Charges__c =  lstobjCM[0].Id;
                lstUpdateMJM.add(obj);
            }
            update lstUpdateMJM;
            ChargesController.overrideDefaultValLst();
            
            ChargesController.scCodeVSChargeMstrMap = NULL;
            ChargesController.loanApplcId = LoanAppId;
            ChargesController.loanApplcRecList = lstLA;
            ChargesController.applcId = LoanAppId;
            ChargesController.loanAmount = 10000;
            ChargesController.product = '10101';
            ChargesController.custmerType = 'I';
            ChargesController.custmerCategory = '';
            ChargesController.burScore = 700;
            ChargesController.strScreen = 'New';
            ChargesController.collatType = '';
            ChargesController.fuelTypeFromColl = 'Petrol';
            ChargesController.vehclUsageFromColl = 'Personal';
            ChargesController.idv = 100;
            ChargesController.schemeNameFromLoan = 'Normal';

            ChargesController.FldsWrapper objFW = new ChargesController.FldsWrapper();
            objFW.Id = '';
            objFW.scName = '';
            objFW.scCode = '';
            objFW.valueType = '';
            objFW.sequenceNO = 1;
            objFW.dednCod = null;
            objFW.rateValueAsPerPolicy = 2;
            objFW.taxApplicable = '';
            objFW.taxPercentage = 10;
            objFW.minCharges = 10;
            objFW.maxChargesSOC = 10;
            objFW.customerCategory = '';
            objFW.modelAge = '';
            objFW.deviationApplicable = '';
            objFW.shownToUI = '';
            
            objFW.chargeAmount = 20;
            objFW.taxAmount = 100;
            objFW.totalAmount = 500;
            objFW.isRaiseDeviation = false;
            objFW.allowMinValue = true;
            objFW.isShownAtUI = true;
            
        Test.stopTest();
    }

        /**
        * @description Testing of fetching stamping charges individually for Tractor
        * @author Ajitesh | 11-21-2023 
        * @param ; 
        * @return Loan_Application__c 
        **/
    @isTest static void getStampingChargeApplicableRecordTst(){
        Loan_Application__c loanApp = [SELECT Id FROM Loan_Application__c WHERE Branch_Master__r.State__r.Account_Name__c='Madhya Pradesh' LIMIT 1];
        Test.startTest();
        Stamping_Charges_Calculation__mdt s = ChargesController.getStampingChargeApplicableRecord(loanApp.Id);
        System.assert(s != null, 'fetched stamping charges individually');
        Test.stopTest();

    }
    
}