@isTest
public class CAMReportChildComponentsTest {
    
    @testSetup static void setup() {
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        
        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            Branch_Queue__c=grp.Id
        ),true);
        
        Account state =(Account )TestFactory.createSObject(new Account (
            Name ='Dealer State',
            Account_Name__c = 'Dealer State',
            Account_Code__c='2109',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('State').getRecordTypeId()
        ),true);

        Account dealerAccount =(Account )TestFactory.createSObject(new Account (
            Name ='Dealer Account',
            Account_Code__c='2105',
            State__c=state.Id,
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId()
        ),true);
        
        Date start = Date.newInstance(1999, 12, 31);
        Date endDate = Date.newInstance(1999, 12, 31);
        Scheme_Master__c scheme1 = (Scheme_Master__c)TestFactory.createSObject(new Scheme_Master__c(
            START_DATE__c  = start,
            EXPIRY_DATE__c   = endDate,
            Is_InActive__c  = false,
            Scheme_Name__c = 'Normal', Vehicle_Category__c ='TestCat'
        ),true);
        Map<String, Boolean> baseCreditVerificationTabs = new Map<String, Boolean>();
        baseCreditVerificationTabs.put('PSL',false);
        baseCreditVerificationTabs.put('TAR',true);
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            EMI_Frequency__c = 'MONTHLY',
            Dealer_Master__c=dealerAccount.Id,
            Tenure__c = 10,BRE_Status__c = Label.BRE_Status_Received,
            Branch_Master__c = accInstance.Id, BRE_Selected_Scheme__c = scheme1.id,
            Base_Credit_Verification__c = JSON.serialize(baseCreditVerificationTabs),
            RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Tractor').getRecordTypeId()
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal1',
            CIF_No__c = '576322', 
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        Applicant__c addMatchappl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal1',
            CIF_No__c = '576322', 
            Loan__c =loanAppl.Id,
            applicant__c=appl.Id,
            Bureau_Score__c='101',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Additional_Match').getRecordTypeId()
        ),true);
        Applicant__c appl1 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Test',
            Middle_Name__c = 'abc',
            Last_Name__c = 'Mandal1',
            CIF_No__c = '576652', 
            Loan__c =loanAppl.Id,
            Lead_Dedupe_Verified_By_Credit__c=true,
            Customer_Dedupe_Verified_By_Credit__c=true,
            Cibil_Report_Verified_by_Credit__c=true,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        Address__c addressCurrent = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Type__c = 'Current',
            Source_Type__c = null,
            Applicant__c = appl.Id,
            FI_Report_Verified__c = true
        ),true);
        Address__c addressPermanent = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Type__c = 'Permanent',
            Source_Type__c = null,
            Applicant__c = appl1.Id
        ),true);
        Address__c addressTP = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Type__c = 'Touch Point',
            Source_Type__c = null,
            Applicant__c = appl1.Id
        ),true);
        Address__c addressOffice = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Type__c = 'Office',
            Source_Type__c = null,
            Applicant__c = appl1.Id
        ),true);
        Bank_Account_Records__c bank1 = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
            RecordTypeId=Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByDeveloperName().get('CBS').getRecordTypeId(),
            Applicant__c=appl1.Id,
            Average_Monthly_Balance__c = 10
        ),true);
        
        Bank_Account_Records__c bank2 = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
            RecordTypeId=Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByDeveloperName().get('CBS').getRecordTypeId(),
            Applicant__c=appl1.Id,
            Average_Monthly_Balance__c = 30
        ),true);
        
        
        Collateral__c coll= new Collateral__c(Loan__c=loanAppl.Id,Original_Vehicle_Usage__c = 'Test',
                                             RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId());
        insert coll;
        
        Valuation__c val= new Valuation__c(Name='TestVal',Collateral__c=coll.Id);
        Test.startTest();
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Vahaan',
            PathOnClient = 'Vahaan.jpg',
            Request_id__c ='Req1',
            VersionData = Blob.valueOf('Test Content'),
            Origin = 'H'
        );
        insert contentVersion; 
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = bank1.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        insert cdl;
        
         Applicant_Financials_Details__c objFDSD = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
            Applicant__c =appl.Id,
            Monthly_Income__c = 100000, 
            Monthly_Obligation__c=1000, 
            Consider_Income_for_Eligibility__c='Yes', 
            Monthly_Net_Profit__c=1000000, 
            Average_Monthly_Salary__c=100000,
             Net_Revenue__c = 10000,
            Type_Of_Employment__c='Self Employed Professional',
            RecordTypeId=Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Farmer_Agriculture_Own_Land').getRecordTypeId()), false);

        Applicant_Financials_Details__c objFDFP = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
            Applicant__c =appl.Id,
            Monthly_Income__c = 100000, 
            Monthly_Obligation__c=1000, 
            Consider_Income_for_Eligibility__c='Yes', 
            Monthly_Net_Profit__c=1000000, 
            Average_Monthly_Salary__c=100000,
            Net_Revenue__c =100000,
            Type_Of_Employment__c='Salaried - Private',
            RecordTypeId=Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Financial_Parent').getRecordTypeId()), false);
        
        Applicant_Financials_Details__c objFDFP1 = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
            Applicant__c =appl1.Id,
            Monthly_Income__c = 100000, 
            Monthly_Obligation__c=1000, 
            Consider_Income_for_Eligibility__c='Yes', 
            Monthly_Net_Profit__c=1000000, 
            Average_Monthly_Salary__c=100000,
            Net_Revenue__c =100000,
            Type_Of_Employment__c='Salaried - Private',
            RecordTypeId=Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Financial_Parent').getRecordTypeId()), false);
        
        Applicant_Financials_Details__c objFDFPSENP = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
            Applicant__c =appl.Id,
            Monthly_Income__c = 100000, 
            Monthly_Obligation__c=1000, 
            Consider_Income_for_Eligibility__c='Yes', 
            Monthly_Net_Profit__c=1000000, 
            Average_Monthly_Salary__c=100000,
            Net_Revenue__c = 1000,
            Type_Of_Employment__c='Self Employed Non-Professional',
            RecordTypeId=Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Farmer_Agriculture_Rented_Land').getRecordTypeId()), false);
        Applicant_Financials_Details__c objFDAND = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
            Applicant__c =appl.Id,
            Monthly_Income__c = 100000, 
            Monthly_Obligation__c=1000, 
            Consider_Income_for_Eligibility__c='Yes', 
            Monthly_Net_Profit__c=1000000, 
            Average_Monthly_Salary__c=100000,
            Net_Annual_Income__c = 1000,
            Type_Of_Employment__c='Self Employed Professional',
            RecordTypeId=Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Farmer_Commercial').getRecordTypeId()), false);
        
        Applicant_Financials_Details__c objFDAgri = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
            Applicant__c =appl.Id,
            Monthly_Income__c = 100000, 
            Monthly_Obligation__c=1000, 
            Net_Annual_Income__c = 1000,
            Total_Net_Income__c = 1000,
            Consider_Income_for_Eligibility__c='Yes', 
            Monthly_Net_Profit__c=1000000, 
            Average_Monthly_Salary__c=100000,
            Type_Of_Employment__c='Farmer',
            RecordTypeId=Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Farmer_Dairy_Business').getRecordTypeId()), false);
        
        Applicant_Financials_Details__c objFDAgriVia = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
            Applicant__c =appl.Id,
            Monthly_Income__c = 100000, 
            Monthly_Obligation__c=1000, 
            Consider_Income_for_Eligibility__c='Yes', 
            Monthly_Net_Profit__c=1000000, 
            Average_Monthly_Salary__c=100000,
            Net_Surplus__c = 10000,
            Type_Of_Employment__c='Farmer',
            RecordTypeId=Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Viability_Sheet_Self_Propelled_Harvester').getRecordTypeId()), false);
        
        Applicant_Financials_Details__c objFDAgriOth = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
            Applicant__c =appl.Id,
            Monthly_Income__c = 100000, 
            Monthly_Obligation__c=1000, 
            Consider_Income_for_Eligibility__c='Yes', 
            Monthly_Net_Profit__c=1000000, 
            Average_Monthly_Salary__c=100000,
            Net_Surplus__c = 10000,
            Type_Of_Employment__c='Farmer',
            RecordTypeId=Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Other_Income').getRecordTypeId()), false);
        
        insert new List<Applicant_Financials_Details__c>{objFDFP1,objFDAgriVia,objFDAgriOth,objFDAgri, objFDAND, objFDFPSENP, objFDFP, objFDSD};
        
        Integration_Master__c intmassearch2 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Cibil Individual',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/FicoBREService',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
        Integration_Checklist__c intCheck = (Integration_Checklist__c)TestFactory.createSObject(new Integration_Checklist__c(
            Request__c = 'Cibil Individual',
            Response__c = '',//{"response_status":{"code":"97","message":"K-100-Resident authentication failed","status":"FAIL","txnID":"UKC:10-USR001-SFDC-20230519130219-"}}',
            Applicant__c = appl1.Id,
            Integration_Master__c = intmassearch2.Id
            
        ),true);
        Document_Master__c panDocMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Document_Name__c='Pan Card/Form 60',
            Name = 'AUWheels00001'),true);
        Document_Checklist__c panDocChecklist = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c(
            Document_Master__c=panDocMaster.Id,
            Applicant__c=appl1.Id,
            Match_Percentage__c=0.76
        ),true);
        Document_Master__c livePhotoDocMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Document_Name__c='Live Photo',
            Name = 'AUWheels00004'),true);
        Document_Checklist__c livePhotoDocChecklist = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c(
            Document_Master__c=livePhotoDocMaster.Id,
            Applicant__c=appl1.Id,
            Match_Percentage__c=0.76
        ),true);
        Field_Investigation__c fieldInvestigationObj = (Field_Investigation__c)TestFactory.createSObject((new Field_Investigation__c( 
            Name = appl.Customer_Name__c,
            Loan_Application__c =loanAppl.Id,
            Address_lookup__c=addressCurrent.id,
            Applicant__c=appl.Id,
            FI_Status__c ='In Progress',
            
            Applicant_Type__c='Applicant' )),true);
        
            Test.stopTest();
        
    }
    
    @isTest
    public static void testGetCbs() {
        String result = CAMReportChildComponentsController.getCbs();
        System.assertEquals('CBS', result, 'The getCbs method should return "CBS"');
    }
    
    @isTest
    public static void testGetLead() {
        String result = CAMReportChildComponentsController.getLead();
        System.assertEquals('Lead', result, 'The getLead method should return "Lead"');
    }
    
    @isTest
    public static void testGetProd() {
        String result = CAMReportChildComponentsController.getProd();
        System.assertEquals('Prod', result, 'The getProd method should return "Prod"');
    }
    
    @isTest
    public static void testGetListSize() {
        // Set up the test data
        List<Applicant__c> applicants = new List<Applicant__c>();
        applicants.add(new Applicant__c());
        
        // Set the applicants in the controller
        CAMReportChildComponentsController.applicants = applicants;
        
        // Call the getListSize method
        String expectedListSize = 'multiple';
        String actualListSize = CAMReportChildComponentsController.getListSize();
    }
    
    @isTest
    public static void testHandleCreditVerify() {
        // Call the handleCreditVerify method
        CAMReportChildComponentsController.handleCreditVerify();
        
        // Verify that notverifiedRiskScore is set to false
        Boolean expectedRiskScore = false;
        Boolean actualRiskScore = CAMReportChildComponentsController.notverifiedRiskScore;
        System.assertEquals(expectedRiskScore, actualRiskScore, 'The handleCreditVerify method should set notverifiedRiskScore to false');
    }
    @isTest
    public static void testUpdateCibilReportCheck(){
        Test.startTest();
        Applicant__c app = [SELECT id from Applicant__c WHERE RecordType.DeveloperName='Primary_Applicant' LIMIT 1];
        CAMReportChildComponentsController.updateCibilReportCheck(app.id);
        Test.stopTest();
    }
    
    public static void testupdateFIReportCheck(){
        Test.startTest();
        Applicant__c app = [SELECT id from Applicant__c WHERE RecordType.DeveloperName='Primary_Applicant' LIMIT 1];
        CAMReportChildComponentsController.updateFIReportCheck(app.id);
        Test.stopTest();
    }
    
    @isTest
    public static void testClassProperties() {
        // Create test data for Loan_Application__c
        Loan_Application__c loan = new Loan_Application__c();
        insert loan;
        
        // Create test data for Collateral__c
        Collateral__c collateral = new Collateral__c();
        
        // Create test data for Applicant__c
        Applicant__c applicant = new Applicant__c();
        
        // Create test data for Applicant_Financials_Details__c
        List<Applicant_Financials_Details__c> financial = new List<Applicant_Financials_Details__c>{
            new Applicant_Financials_Details__c(),
                new Applicant_Financials_Details__c()
                };
                    
                    // Create test data for List<Applicant__c>
                    List<Applicant__c> applicants = new List<Applicant__c>{
                        new Applicant__c(),
                            new Applicant__c()
                            };
                                
                                // Create test data for List<Id>
                                List<Id> applicantIdsForAdditionalMatch = new List<Id>{
                                    applicants[0].Id,
                                        applicants[1].Id
                                        };
                                            
                                            // Create test data for List<Address__c>
                                            List<Address__c> addressList = new List<Address__c>{
                                                new Address__c(),
                                                    new Address__c()
                                                    };
                                                        
                                                        // Create test data for List<Bank_Account_Records__c>
                                                        List<Bank_Account_Records__c> exposureDetailsForAppBanks = new List<Bank_Account_Records__c>{
                                                            new Bank_Account_Records__c(),
                                                                new Bank_Account_Records__c()
                                                                };
                                                                    
                                                                    // Create test data for List<Bank_Account_Records__c>
                                                                    List<Bank_Account_Records__c> cbsRecordsFD = new List<Bank_Account_Records__c>{
                                                                        new Bank_Account_Records__c(),
                                                                            new Bank_Account_Records__c()
                                                                            };
                                                                                
                                                                                // Create test data for List<Bank_Account_Records__c>
                                                                                List<Bank_Account_Records__c> cartRecords = new List<Bank_Account_Records__c>{
                                                                                    new Bank_Account_Records__c(),
                                                                                        new Bank_Account_Records__c()
                                                                                        };
                                                                                            
                                                                                            // Create test data for Map<Id, List<Bank_Account_Records__c>>
                                                                                            Map<Id, List<Bank_Account_Records__c>> exposureBankRecords = new Map<Id, List<Bank_Account_Records__c>>();
        exposureBankRecords.put(applicants[0].Id, exposureDetailsForAppBanks);
        exposureBankRecords.put(applicants[1].Id, new List<Bank_Account_Records__c>());
        
        // Create test data for List<Fleet__c>
        List<Fleet__c> fleetRecords = new List<Fleet__c>{
            new Fleet__c(),
                new Fleet__c()
                };
                    
                    // Create test data for List<TVR__c>
                    List<TVR__c> tvrRecords = new List<TVR__c>{
                        new TVR__c(),
                            new TVR__c()
                            };
                                
                                // Create test data for List<Document_Checklist__c>
                                List<Document_Checklist__c> cpvDetails = new List<Document_Checklist__c>{
                                    new Document_Checklist__c(),
                                        new Document_Checklist__c()
                                        };
                                            
                                            // Set the values for class properties
                                            CAMReportChildComponentsController.loan = loan;
        CAMReportChildComponentsController.collateral = collateral;
        CAMReportChildComponentsController.applicant = applicant;
        CAMReportChildComponentsController.financial = financial;
        CAMReportChildComponentsController.applicants = applicants;
        CAMReportChildComponentsController.applicantIdsForAdditionalMatch = applicantIdsForAdditionalMatch;
        CAMReportChildComponentsController.addressList = addressList;
        CAMReportChildComponentsController.exposureDetailsForAppBanks = exposureDetailsForAppBanks;
        CAMReportChildComponentsController.cbsRecordsFD = cbsRecordsFD;
        CAMReportChildComponentsController.cartRecords = cartRecords;
        CAMReportChildComponentsController.exposureBankRecords = exposureBankRecords;
        CAMReportChildComponentsController.fleetRecords = fleetRecords;
        CAMReportChildComponentsController.tvrRecords = tvrRecords;
        CAMReportChildComponentsController.cpvDetails = cpvDetails;
        CAMReportChildComponentsController.applicantnameMap = new Map<Id, String>{
            applicants[0].Id => 'Applicant 1',
                applicants[1].Id => 'Applicant 2'
                };
                    
                    CAMReportChildComponentsController.applicantsizeMap = new Map<Id, Integer>{
                        applicants[0].Id => 2,
                            applicants[1].Id => 1
                            };
                                
                                CAMReportChildComponentsController.applicantExposure = new List<Bank_Account_Records__c>{
                                    new Bank_Account_Records__c(),
                                        new Bank_Account_Records__c()
                                        };
                                            
                                            CAMReportChildComponentsController.exposureCBSAccounts = new List<Bank_Account_Records__c>{
                                                new Bank_Account_Records__c(),
                                                    new Bank_Account_Records__c()
                                                    };
                                                        
                                                        CAMReportChildComponentsController.cibilRecords = new List<Bank_Account_Records__c>{
                                                            new Bank_Account_Records__c(),
                                                                new Bank_Account_Records__c()
                                                                };
                                                                    
                                                                    CAMReportChildComponentsController.loanAppApprovalRecords = new List<Loan_Application_Approval__c>{
                                                                        new Loan_Application_Approval__c(),
                                                                            new Loan_Application_Approval__c()
                                                                            };
                                                                                
                                                                                CAMReportChildComponentsController.deviationRecords = new List<Deviation__c>{
                                                                                    new Deviation__c(),
                                                                                        new Deviation__c()
                                                                                        };
                                                                                            
                                                                                            CAMReportChildComponentsController.fieldInvestigationRecords = new List<FiSummaryViewWrapper>{
                                                                                                new FiSummaryViewWrapper(),
                                                                                                    new FiSummaryViewWrapper()
                                                                                                    };
                                                                                                        
                                                                                                        CAMReportChildComponentsController.sanctionConditions = new List<Sanction_Condition__c>{
                                                                                                            new Sanction_Condition__c(),
                                                                                                                new Sanction_Condition__c()
                                                                                                                };
                                                                                                                    
                                                                                                                    CAMReportChildComponentsController.queries = new List<Query__c>{
                                                                                                                        new Query__c(),
                                                                                                                            new Query__c()
                                                                                                                            };
                                                                                                                                
                                                                                                                                CAMReportChildComponentsController.productRT = new ProductRTMap__mdt();
        
        CAMReportChildComponentsController.fiReportsVerifiedForApp = 'Verified';
        CAMReportChildComponentsController.endUseOfVehicle = 'Personal';
        CAMReportChildComponentsController.sentFrom = 'Sales';
        CAMReportChildComponentsController.subPage = 'Page 1';
        CAMReportChildComponentsController.riskScoreVerified = true;
        
        CAMReportChildComponentsController.listSize = 'Large';
        CAMReportChildComponentsController.productDetails = 'Details';
        
        CAMReportChildComponentsController.additionalMatchScore = new Map<Id, String>{
            applicants[0].Id => 'Match Score 1',
                applicants[1].Id => 'Match Score 2'
                };
                    
                    CAMReportChildComponentsController.applicantVSAadharPhoto = new Map<String, String>{
                        'Applicant 1' => 'Aadhar Photo 1',
                            'Applicant 2' => 'Aadhar Photo 2'
                            };
                                
                                CAMReportChildComponentsController.applicantVSLivePhoto = new Map<String, String>{
                                    'Applicant 1' => 'Live Photo 1',
                                        'Applicant 2' => 'Live Photo 2'
                                        };
                                            
                                            CAMReportChildComponentsController.cibilReports = new Map<String, String>{
                                                'Report 1' => 'Data 1',
                                                    'Report 2' => 'Data 2'
                                                    };
                                                        
                                                        CAMReportChildComponentsController.notverifiedRiskScore = false;
        
        CAMReportChildComponentsController.loanId = loan.Id;
        CAMReportChildComponentsController.cellData = 'Cell Data';
        CAMReportChildComponentsController.labelData = 'Label Data';
        CAMReportChildComponentsController.pageBlockSectionCSS = 'CSS';
        CAMReportChildComponentsController.lcDetails = 'Details';
        CAMReportChildComponentsController.applicantName = 'Applicant';
        CAMReportChildComponentsController.dealerNameAndCode = 'Dealer';
        CAMReportChildComponentsController.counter = 1;
        CAMReportChildComponentsController.factor = 'Factor';
        CAMReportChildComponentsController.RO = new User();
        CAMReportChildComponentsController.preApprovedOfferAmount = 'Offer Amount';
        CAMReportChildComponentsController.tableStyle = 'Table Style';
        CAMReportChildComponentsController.tableStyleForBank = 'Table Style for Bank';
        
        CAMReportChildComponentsController.tableRowStyle = 'Row Style';
        CAMReportChildComponentsController.tableHeadStyle = 'Head Style';
        CAMReportChildComponentsController.tableDataStyle = 'Data Style';
        CAMReportChildComponentsController.tableHeadDataStyle = 'Head Data Style';
        CAMReportChildComponentsController.tableHeadDataStyleForBank = 'Head Data Style for Bank';
        CAMReportChildComponentsController.tableCellDataStyleForBank = 'Cell Data Style for Bank';
        
    }
    
    @isTest
    static void testTrackAppvsFiRecords() {
        // Test data setup
        List<FiSummaryViewWrapper> fieldInvestigationRecords = new List<FiSummaryViewWrapper>();
        FiSummaryViewWrapper wrapper = new FiSummaryViewWrapper();
        wrapper.entity = 'Entity';
        wrapper.partyName = 'PartyName';
        fieldInvestigationRecords.add(wrapper);
        
        CAMReportChildComponentsController.fieldInvestigationRecords = fieldInvestigationRecords;
        
        // Call the method to be tested
        CAMReportChildComponentsController.trackAppvsFiRecords();
        
        // Verify the results
        List<String> expectedFiReportsVerifiedForApp = new List<String>();
        expectedFiReportsVerifiedForApp.add('Entity_PartyName_TP');
        expectedFiReportsVerifiedForApp.add('Entity_PartyName_Current');
        expectedFiReportsVerifiedForApp.add('Entity_PartyName_Office');
        expectedFiReportsVerifiedForApp.add('Entity_PartyName_Permanent');
        
        System.assertEquals(JSON.serialize(expectedFiReportsVerifiedForApp), CAMReportChildComponentsController.fiReportsVerifiedForApp);
    }
    
    @isTest
    static void testGetPreApprovedOfferAmount() {
        
        // Test data setup
        Loan_Application__c loan = new Loan_Application__c();
        insert loan;
        
        Pre_Approved_Offer__c offer = new Pre_Approved_Offer__c();
        offer.FirstOfferAmount__c = 1000;
        offer.Is_Selected__c = true;
        offer.Loan_Application__c = loan.Id;
        insert offer;
        
        // Call the method to be tested
        Test.startTest();
        String preApprovedOfferAmount = null;
        
        // Set the CAMReportChildComponentsController's loan.Id to the inserted loan.Id
        CAMReportChildComponentsController.loan = loan;
        
        // Retrieve the pre-approved offer amount
        preApprovedOfferAmount = CAMReportChildComponentsController.getPreApprovedOfferAmount();
        Test.stopTest();
        // Verify the results
        System.assertEquals('1000.00', preApprovedOfferAmount);
    }
    @isTest
    static void testGetCibilReports() {
        // Test data setup
        List<Id> applicantIds = new List<Id>();
        List<Applicant__c> applicants = new List<Applicant__c>();
        // Populate the applicantIds list with test data
        
        // Create test Bureau_Results__c records
        List<Bureau_Results__c> bureauResults = new List<Bureau_Results__c>();
        // Populate the bureauResults list with test data
        
        // Create test ContentDocumentLink records
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        // Populate the cdlList with test data
        
        // Create test ContentVersion records
        List<ContentVersion> contentList = new List<ContentVersion>();
        // Populate the contentList with test data
        
        // Set the required objects in the class using JSON serialization
        CAMReportChildComponentsController.applicantIds = (List<Id>)JSON.deserialize(JSON.serialize(applicantIds), List<Id>.class);
        CAMReportChildComponentsController.applicants = (List<Applicant__c>)JSON.deserialize(JSON.serialize(applicants), List<Applicant__c>.class);
        CAMReportChildComponentsController.cibilReports = new Map<String, String>();
        
        CAMReportChildComponentsController.applicants = [SELECT Id FROM Applicant__c WHEre RecordType.DeveloperName='Additional_Match'];
        List<Id> appIds = new List<Id>();
        for(Applicant__c appl : CAMReportChildComponentsController.applicants){
            appIds.add(appl.Id);
        }
        CAMReportChildComponentsController.applicantIds = appIds;
        
        // Call the method to be tested
        Test.startTest();
        Map<String, String> cibilReports = CAMReportChildComponentsController.getCibilReports();
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetDealerNameAndCode() {
        Test.startTest();
        Loan_Application__c loan = [SELECT Id, Dealer_Master__c, Dealer_Master__r.Account_Name__c, Dealer_Master__r.Account_Code__c from Loan_Application__c];
        CAMReportChildComponentsController.loan = loan;
        String dealerNameAndCode = CAMReportChildComponentsController.getDealerNameAndCode();
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetEndUseOfVehicle() {
        Test.startTest();
        Loan_Application__c loan = [SELECT Id, (SELECT Id, End_use_of_Vehicle__c FROM BSR_PSL_Details__r) FROM Loan_Application__c];
        CAMReportChildComponentsController.loan = loan;
        CAMReportChildComponentsController.getEndUseOfVehicle();
        BSR_PSL_Details__c  bsrpsl = (BSR_PSL_Details__c ) TestFactory.createSObject(new BSR_PSL_Details__c (
            RecordTypeId=Schema.SObjectType.BSR_PSL_Details__c .getRecordTypeInfosByDeveloperName().get('PSL').getRecordTypeId(),
            Loan_Application__c=loan.Id,
            End_use_of_Vehicle__c='Personal'
        ),true);
        loan = [SELECT Id, (SELECT Id, End_use_of_Vehicle__c FROM BSR_PSL_Details__r) FROM Loan_Application__c];
        CAMReportChildComponentsController.getEndUseOfVehicle();
        Test.stopTest();
        
    }
    
    @isTest
    static void testGetApplicantIdsForAdditionalMatch() {
        // Test data setup
        List<Applicant__c> applicants = new List<Applicant__c>();
        applicants = [SELECT Id, (SELECT Id, Bureau_Score__c FROM Applicants__r) FROM Applicant__c];
        List<Id> applicantIds = new List<Id>();
        
        // Populate the applicants list with test data
        
        // Set the required objects in the class using JSON serialization
        CAMReportChildComponentsController.applicants = (List<Applicant__c>)JSON.deserialize(JSON.serialize(applicants), List<Applicant__c>.class);
        CAMReportChildComponentsController.applicantIds = (List<Id>)JSON.deserialize(JSON.serialize(applicantIds), List<Id>.class);
        CAMReportChildComponentsController.additionalMatchScore = new Map<Id, String>();
        CAMReportChildComponentsController.applicantIdsForAdditionalMatch = new List<Id>();
        
        // Call the method to be tested
        Test.startTest();
        Map<Id, String> additionalMatchScore = CAMReportChildComponentsController.getApplicantIdsForAdditionalMatch();
        Test.stopTest();
        
    }
    @isTest
    static void testConstructor() {
        // Test data setup
        Loan_Application__c loan = new Loan_Application__c();
        // Set other required fields for Loan_Application__c
        
        // Set the sentFrom value for the constructor
        CAMReportChildComponentsController.sentFrom = 'PDF';
        
        // Call the constructor
        Test.startTest();
        CAMReportChildComponentsController controller = new CAMReportChildComponentsController();
        CAMReportChildComponentsController.sentFrom = 'test';
        CAMReportChildComponentsController controller2 = new CAMReportChildComponentsController();
        Test.stopTest();
        
        
    }
    @isTest
    static void testUpdateCreditVerification() {
        // Test data setup
        String loanId = 'testLoanId';
        String verificationType = 'testVerificationType';
        
        // Call the method to be tested
        Test.startTest();
        CAMReportChildComponentsController.updateCreditVerification(loanId, verificationType);
        Test.stopTest();
        
    }
    
    /*@isTest
static void testUpdateCibilReportCheck() {

Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
Application_Number__c  = 'AP-12345',
Adhar_Card__c   = 123456,
Loan_Amount__c  = 1000,
Product__c='10201',
Customer_Type__c='Individual',
Stage__c ='DDE',
EMI_Date__c = '10/3/2022'
),true);
Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
First_Name__c = 'Vikash',
Middle_Name__c = 'Kumar',
Last_Name__c = 'Mandal1',
CIF_No__c = '576322', 
Loan__c =loanAppl.Id,
RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
),true);
String appRecId=String.valueOf(appl.Id);
// Call the method to be tested
Test.startTest();
// CAMReportChildComponentsController.updateCibilReportCheck(appRecId);
Test.stopTest();


}*/
    
    
    
    @isTest
    static void testGetAddressTypeValues() {
        Test.startTest();
        List<Applicant__c> applicants= [SELECT Id,Loan__c, (SELECT Geo_Limit__c, Applicant__c, Applicant__r.RecordType.DeveloperName, Stability__c, Distance_from_Branch__c, Address_Type__c, Status__c,
                                                    Address_Line_1__c, Address_Line_2__c, Source_Type__c, Address_Line_3__c, City__c, State__c, Pincode__c, ETB_Address_Match_Score__c, CART_Address_Match_Score__c, Latest_Cibil_Address_Match_Score__c FROM Addresses__r WHERE Address_Type__c != null
                                                    AND (Source_Type__c = null OR Source_type__c='CBS') Order by Applicant__r.RecordType.Name, CreatedDate Desc) from Applicant__c];
        Loan_Application__c loan = [SELECT Id,RecordType.DeveloperName,Original_Vehicle_Usage__c FROM Loan_Application__c WHERE Id =: applicants[0].Loan__c];
        List<Id> applicantIds = new List<Id>();
        List<Address__c> addressList = new List<Address__c>();
        for(Applicant__c app: applicants){
            applicantIds.add(app.Id);
            if(app.Addresses__r!=null && app.Addresses__r.size()>0){
                List<Address__c> addressListTemp = new List<Address__c>();
                Map<String,Address__c> addMap = new Map<String,Address__c>();
                for(Address__c add: app.Addresses__r){
                    String key = add.Source_Type__c!=null?add.Source_Type__c:'SF';
                    addMap.put(key+'_'+add.Address_Type__c, add);
                }
                if(addMap.containsKey('SF_Permanent')){
                    addressList.add(addMap.get('SF_Permanent'));
                }else{
                    if(addMap.containsKey('CBS_Permanent')){
                        addressList.add(addMap.get('CBS_Permanent'));
                    }
                }
                if(addMap.containsKey('SF_Current')){
                    addressList.add(addMap.get('SF_Current'));
                }else{
                    if(addMap.containsKey('CBS_Current')){
                        addressList.add(addMap.get('CBS_Current'));
                    }
                }
                if(addMap.containsKey('SF_Touch Point')){
                    addressList.add(addMap.get('SF_Touch Point'));
                }else{
                    if(addMap.containsKey('CBS_Touch Point')){
                        addressList.add(addMap.get('CBS_Touch Point'));
                    }
                }
                if(addMap.containsKey('SF_Office')){
                    addressList.add(addMap.get('SF_Office'));
                }else{
                    if(addMap.containsKey('CBS_Office')){
                        addressList.add(addMap.get('CBS_Office'));
                    }
                }
                
                
                
            }
            
        }
        
        CAMReportChildComponentsController.applicantIds = applicantIds;
        CAMReportChildComponentsController.loan = loan;
        CAMReportChildComponentsController.addressList = addressList;
        /*
Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
Application_Number__c  = 'AP-12345',
Adhar_Card__c   = 123456,
Loan_Amount__c  = 1000,
Product__c='10201',
Customer_Type__c='Individual',
Stage__c ='DDE',
EMI_Date__c = '10/3/2022'
),true);
Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
First_Name__c = 'Vikash',
Middle_Name__c = 'Kumar',
Last_Name__c = 'Mandal1',
CIF_No__c = '576322', 
Loan__c =loanAppl.Id,
RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
),true);


Loan_Application__c loanAppl = 

// Test data setup
List<Id> applicantIds = new List<Id>{ appl.id };
List<Address__c> addressList = new List<Address__c>{
new Address__c(Address_Type__c = 'Current', Applicant__c = appl.id),
new Address__c(Address_Type__c = 'Permanent', Applicant__c = appl.id),
new Address__c(Address_Type__c = 'Office', Applicant__c = appl.id),
new Address__c(Address_Type__c = 'Touch Point', Applicant__c = appl.id)
};
CAMReportChildComponentsController.applicantIds = applicantIds;
CAMReportChildComponentsController.addressList = addressList;
*/
        
        // Call the method to be tested
        CAMReportChildComponentsController.getAddressTypeValues();
        
        Test.stopTest();
        
    }
    
    @isTest
    static void testgetCartDocDetail(){
        List<Id> applicantIds = new List<Id>();
        List<Bank_Account_Records__c> exposureBankRecords = [SELECT Id,OD_Limit_Sanctioned__c, InstallmentsOverDue__c, Is_Enquiry_Type__c, Applicant_Type__c, Average_Monthly_Balance__c, Average_Monthly_Credit__c, No_of_Bouncing__c, Total_Credit__c, Applicant__r.Name, Total_Debit__c, Inward_Cheque_Bounce__c, Current_Balance__c, Outward_Cheque_Bounce__c, Total_Salary__c, Payment_Frequency__c, No_of_Emi_Paid__c, Loan_Overdue_EMI__c, Amount_Overdue__c, Highest_Overall_DPD__c, Highest_12_Month_DPD__c, Average_Delay__c, Owenership_Indicator__c, Current_Status__c, Loan_Amount__c, Name_of_the_Financier__c, Type_of_Loan__c, Payment_History_Start_Date__c, Payment_History_End_Date__c, Date_Of_Enquiry__c, Customer_Relationship__c, Loan_Number__c, Account_Opening_Date__c,Account_Closing_Date__c, Account_Name__c,Account_Number__c,Bank_Name__c,Branch_Name__c,Account_Type__c,Statement_Start_Date__c,Statement_End_Date__c, EMI_Amount__c,RecordType.DeveloperName, Product__c, Product_Code__c, POS__c, Tenure__c, Applicant__r.First_Name__c, Applicant__r.Middle_Name__c, Applicant__r.Last_Name__c, Applicant__r.RecordType.DeveloperName FROM Bank_Account_Records__c];
        List<Applicant__c> applicants= [SELECT Id,Loan__c,RecordType.DeveloperName, (SELECT Geo_Limit__c, Applicant__c, Applicant__r.RecordType.DeveloperName, Stability__c, Distance_from_Branch__c, Address_Type__c, Status__c,
            Address_Line_1__c, Address_Line_2__c, Source_Type__c, Address_Line_3__c, City__c, State__c, Pincode__c, ETB_Address_Match_Score__c, CART_Address_Match_Score__c, Latest_Cibil_Address_Match_Score__c FROM Addresses__r WHERE Address_Type__c != null
            AND (Source_Type__c = null OR Source_type__c='CBS') Order by Applicant__r.RecordType.Name, CreatedDate Desc) from Applicant__c];
         List<Collateral__c> collateral = [SELECT ID FROM  Collateral__c];
        for(Applicant__c app: applicants){
            if(app.RecordType.DeveloperName == 'Primary_Applicant'){
                applicantIds.add(app.Id);
            }
            
        }
        List<Applicant_Financials_Details__c> applicantFinancialsR2 = [SELECT Id,Applicant__c,RecordType.DeveloperName,Type_Of_Employment__c,Applicant__r.Loan__r.EMI_Frequency__c,Applicant__r.Loan__r.EMI__c,Monthly_Obligation__c,Applicant__r.RecordType.Name,Net_Revenue__c,Net_Annual_Income__c,Total_Net_Income__c,Monthly_Income__c,Net_Surplus__c,Total_Income__c FROM Applicant_Financials_Details__c];
        CAMReportChildComponentsController.applicantFinancialsR2 = applicantFinancialsR2;
        CAMReportChildComponentsController.applicantIds = applicantIds;
        CAMReportChildComponentsController.collateral = collateral[0];
        CAMReportChildComponentsController.cartRecords = exposureBankRecords; 
        CAMReportChildComponentsController.applicants = applicants;
        Test.startTest();
        CAMReportChildComponentsController.getCartDocDetail();
        CAMReportChildComponentsController.getValuations();
        CAMReportChildComponentsController.getAQBByApplicant();
        
        Test.stopTest();
    }
     
    @IsTest
    static void testGetCpvDetailsList() {
        // Test data setup
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022'
        ),true);
        Test.startTest();
        Applicant__c appl1 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal1',
            CIF_No__c = '576322', 
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        Applicant__c appl2 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Test',
            Middle_Name__c = 'abc',
            Last_Name__c = 'Mandal1',
            CIF_No__c = '576652', 
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        List<Id> applicantIds = new List<Id>{appl1.id, appl2.id};
            List<Document_Checklist__c> cpvDetails = new List<Document_Checklist__c>();
        
        Document_Checklist__c doc1 = new Document_Checklist__c();
        doc1.Applicant__c = appl1.id;
        doc1.Document_Master__r = new Document_Master__c(Name = 'AUWheels0093');
        doc1.Address_Match_Score__c = 80;
        doc1.Match_Percentage__c = 90;
        cpvDetails.add(doc1);
        
        Document_Checklist__c doc2 = new Document_Checklist__c();
        doc2.Applicant__c = appl2.id;
        doc2.Document_Master__r = new Document_Master__c(Name = 'AUWheels0091');
        doc2.Address_Match_Score__c = 70;
        doc2.Match_Percentage__c = 95;
        cpvDetails.add(doc2);
        
        CAMReportChildComponentsController.applicantIds = applicantIds;
        CAMReportChildComponentsController.cpvDetails = cpvDetails;
        
        // Call the method
        Map<Id, List<Document_Checklist__c>> result = CAMReportChildComponentsController.getCpvDetailsList();
        Test.stopTest();
    }
    
    @IsTest
    static void testGetRiskScoreVerified() {
        // Test data setup
        Loan_Application__c loanApp = new Loan_Application__c();
        loanApp.Base_Credit_Verification__c = '{"Risk Score Sheet": true}';
        
        CAMReportChildComponentsController.loan = loanApp;
        
        // Call the method
        Boolean result = CAMReportChildComponentsController.getRiskScoreVerified();
        
        // Assertion
        System.assertEquals(true, result);
    }
    
    @IsTest
    static void testUpdateCreditRemarks() {
        // Test data setup
        Loan_Application__c loanApp = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022'
        ),true);
        // Call the method
        Test.startTest();
        CAMReportChildComponentsController.updateCreditRemarks(loanApp.Id, 'Test remarks');
        Test.stopTest();
        
        // Assertions
        Loan_Application__c updatedLoanApp = [SELECT Id, Credit_Remarks__c FROM Loan_Application__c WHERE Id = :loanApp.Id];
        System.assertEquals('Test remarks', updatedLoanApp.Credit_Remarks__c);
    }
    
    @IsTest
    static void testGetIdentifiersList() {
        // Test data setup
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022'
        ),true);
        Test.startTest();
        Applicant__c appl1 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal1',
            CIF_No__c = '576322', 
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        Applicant__c appl2 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Test',
            Middle_Name__c = 'abc',
            Last_Name__c = 'Mandal1',
            CIF_No__c = '576652', 
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        List<Id> applicantIds = new List<Id>{appl1.id, appl2.id};
            List<Document_Checklist__c> cpvDetails = new List<Document_Checklist__c>();
        
        Document_Checklist__c doc1 = new Document_Checklist__c();
        doc1.Applicant__c = appl1.id;
        doc1.Document_Master__r = new Document_Master__c(Name = 'AUWheels0093');
        doc1.Address_Match_Score__c = 80;
        doc1.Match_Percentage__c = 90;
        cpvDetails.add(doc1);
        
        Document_Checklist__c doc2 = new Document_Checklist__c();
        doc2.Applicant__c = appl2.id;
        doc2.Document_Master__r = new Document_Master__c(Name = 'AUWheels0091');
        doc2.Address_Match_Score__c = 70;
        doc2.Match_Percentage__c = 95;
        cpvDetails.add(doc2);
        
        CAMReportChildComponentsController.applicantIds = applicantIds;
        CAMReportChildComponentsController.cpvDetails = cpvDetails;
        
        Map<Id, List<Document_Checklist__c>> result = CAMReportChildComponentsController.getIdentifiersList();
        Test.stopTest();
    }
    
    @IsTest
    static void testGetCartBankDetail() {
        // Test data setup
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022'
        ),true);
        Test.startTest();
        Applicant__c appl1 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal1',
            CIF_No__c = '576322', 
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        Applicant__c appl2 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Test',
            Middle_Name__c = 'abc',
            Last_Name__c = 'Mandal1',
            CIF_No__c = '576652', 
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        List<Id> applicantIds = new List<Id>{appl1.id, appl2.id};
            List<Document_Checklist__c> cpvDetails = new List<Document_Checklist__c>();
        
        Document_Checklist__c doc1 = new Document_Checklist__c();
        doc1.Applicant__c = appl1.id;
        doc1.Document_Master__r = new Document_Master__c(Name = 'AUWheels0093');
        doc1.Address_Match_Score__c = 80;
        doc1.Match_Percentage__c = 90;
        cpvDetails.add(doc1);
        
        Document_Checklist__c doc2 = new Document_Checklist__c();
        doc2.Applicant__c = appl2.id;
        doc2.Document_Master__r = new Document_Master__c(Name = 'AUWheels0091');
        doc2.Address_Match_Score__c = 70;
        doc2.Match_Percentage__c = 95;
        cpvDetails.add(doc2);
        
        CAMReportChildComponentsController.applicantIds = applicantIds;
        CAMReportChildComponentsController.cpvDetails = cpvDetails;
        
        Map<Id, Document_Checklist__c> result = CAMReportChildComponentsController.getCartBankDetail();
        Test.stopTest();
    }
    @IsTest
    static void testGetApplicantVsCPVReason() {
        // Test data setup
        List<Applicant__c> applicants = new List<Applicant__c>();
        Applicant__c applicant1 = new Applicant__c();
        applicant1.First_Name__c = 'John';
        applicant1.Last_Name__c = 'Doe';
        applicants.add(applicant1);
        
        Applicant__c applicant2 = new Applicant__c();
        applicant2.First_Name__c = 'Jane';
        applicant2.Last_Name__c = 'Smith';
        applicant2.CPV_Waive_off_Reason__c = 'Missing documents';
        applicants.add(applicant2);
        
        List<FiSummaryViewWrapper> fieldInvestigationRecords = new List<FiSummaryViewWrapper>();
        FiSummaryViewWrapper wrapper1 = new FiSummaryViewWrapper();
        wrapper1.applicantName = 'John Doe';
        fieldInvestigationRecords.add(wrapper1);
        
        FiSummaryViewWrapper wrapper2 = new FiSummaryViewWrapper();
        wrapper2.applicantName = 'Jane Smith';
        fieldInvestigationRecords.add(wrapper2);
        
        CAMReportChildComponentsController.applicants = applicants;
        CAMReportChildComponentsController.fieldInvestigationRecords = fieldInvestigationRecords;
        
        Test.startTest();
        Map<String, String> result = CAMReportChildComponentsController.getApplicantVsCPVReason();
        Test.stopTest();
    }
    @IsTest
    static void testGetKeys() {
        Test.startTest();   
        List<Bank_Account_Records__c> exposureBankRecords = [SELECT OD_Limit_Sanctioned__c, InstallmentsOverDue__c, Is_Enquiry_Type__c, Applicant_Type__c, Average_Monthly_Balance__c, Average_Monthly_Credit__c, No_of_Bouncing__c, Total_Credit__c, Applicant__r.Name, Total_Debit__c, Inward_Cheque_Bounce__c, Current_Balance__c, Outward_Cheque_Bounce__c, Total_Salary__c, Payment_Frequency__c, No_of_Emi_Paid__c, Loan_Overdue_EMI__c, Amount_Overdue__c, Highest_Overall_DPD__c, Highest_12_Month_DPD__c, Average_Delay__c, Owenership_Indicator__c, Current_Status__c, Loan_Amount__c, Name_of_the_Financier__c, Type_of_Loan__c, Payment_History_Start_Date__c, Payment_History_End_Date__c, Date_Of_Enquiry__c, Customer_Relationship__c, Loan_Number__c, Account_Opening_Date__c,Account_Closing_Date__c, Account_Name__c,Account_Number__c,Bank_Name__c,Branch_Name__c,Account_Type__c,Statement_Start_Date__c,Statement_End_Date__c, EMI_Amount__c,RecordType.DeveloperName, Product__c, Product_Code__c, POS__c, Tenure__c, Applicant__r.First_Name__c, Applicant__r.Middle_Name__c, Applicant__r.Last_Name__c, Applicant__r.RecordType.DeveloperName FROM Bank_Account_Records__c];
        CAMReportChildComponentsController.exposureDetailsForAppBanks = exposureBankRecords;
        CAMReportChildComponentsController.getKeys();
        Test.stopTest();
    }
    
    @IsTest
    static void testGetApplicantVSAadharPhoto() {
        Test.startTest();
        List<Applicant__c> applicants = [SELECT Id from Applicant__c];
        List<Id> applicantIds = new List<Id>();
        for(Applicant__c app: applicants){
            applicantIds.add(app.Id);
        }
        CAMReportChildComponentsController.applicantIds = applicantIds;
        Map<String, String> result = CAMReportChildComponentsController.getApplicantVSAadharPhoto();
        Test.stopTest();
    }

    static void getFinancialRecordR2Test() {
        List<Applicant__c> applicants = [SELECT Id, RecordType.Name, Loan__c from Applicant__c];
        List<Id> applicantIds = new List<Id>();
        for(Applicant__c app: applicants){
            applicantIds.add(app.Id);
        }
        CAMReportChildComponentsController.applicantIds = applicantIds;
        List<Applicant_Financials_Details__c> financials = [SELECT Id,applicant__c, applicant__r.RecordType.Name, Type_Of_Employment__c, Monthly_Total_Income__c, Other_Income__c, Company_Name__c, Monthly_Income__c, Total_Net_Income__c, Net_Annual_Income__c, Net_Revenue__c, Monthly_Obligation__c, Consider_Income_for_Eligibility__c, Average_Monthly_Salary__c,RecordType.DeveloperName, Monthly_Net_Profit__c, Applicant__r.Loan__r.Consolidation_Obligation__c, Applicant__r.RecordType.DeveloperName, Applicant__r.Loan__r.FOIR_Percentage__c, Company_Master__r.Company_Name__c, Applicant__r.Loan__r.EMI__c, Applicant__r.Loan__r.EMI_Frequency__c, Net_Surplus__c, Total_Income__c FROM Applicant_Financials_Details__c];
        system.debug('financials in test '+financials);
        CAMReportChildComponentsController.applicants = applicants;
        CAMReportChildComponentsController.applicantFinancialsR2 = new List<Applicant_Financials_Details__c>();
        CAMReportChildComponentsController.applicantFinancialsR2 = financials;
        List<Bank_Account_Records__c> banks = new List<Bank_Account_Records__c>();
        Bank_Account_Records__c bank = new Bank_Account_Records__c();
        bank.Is_Enquiry_Type__c=false;
        bank.RecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByDeveloperName().get('CIBIL').getRecordTypeId();
        bank.EMI_Considered_for_Obligation__c='Yes';
        bank.EMI_Amount__c = 1000;
        banks.add(bank);
        Bank_Account_Records__c bank1 = new Bank_Account_Records__c();
        bank1.Maturity_Date__c=Date.newInstance(2024, 09, 09);
        bank1.Account_Type__c='Loan';
        bank1.RecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByDeveloperName().get('CBS').getRecordTypeId();
        bank1.EMI_Amount__c = 1000;
        banks.add(bank1);
        insert banks;
        CAMReportChildComponentsController.cbsCibilLoans = [SELECT Id, EMI_Amount__c, Applicant__c from Bank_Account_Records__c];
        CAMReportChildComponentsController.getFinancialRecordR2();
        System.assertEquals([SELECT Id, EMI_Amount__c, Applicant__c from Bank_Account_Records__c].size()>0,true,'Success');
    }
    
    @isTest
    public static void testQuarterly(){
        Test.startTest();
        Loan_Application__c loanData = [SELECT Id, Base_Credit_Verification__c, RecordType.DeveloperName FROM Loan_Application__c];
        Loan_Application__c loan = new Loan_Application__c(Id=loanData.Id, EMI_Frequency__c='QUARTERLY');
        update loan;
        getFinancialRecordR2Test();
        Test.stopTest();
    }
    
    @isTest
    public static void testMonthly(){
        Test.startTest();
        Loan_Application__c loanData = [SELECT Id, Base_Credit_Verification__c, RecordType.DeveloperName FROM Loan_Application__c];
        Loan_Application__c loan = new Loan_Application__c(Id=loanData.Id, EMI_Frequency__c='MONTHLY');
        update loan;
        getFinancialRecordR2Test();
        Test.stopTest();
    }
    
    @isTest
    public static void testHalfYearly(){
        Test.startTest();
        Loan_Application__c loanData = [SELECT Id, Base_Credit_Verification__c, RecordType.DeveloperName FROM Loan_Application__c];
        Loan_Application__c loan = new Loan_Application__c(Id=loanData.Id, EMI_Frequency__c='HALF YEARLY');
        update loan;
        getFinancialRecordR2Test();
        Test.stopTest();
    }
    
    @isTest
    public static void getTabNamesTest(){
        Test.startTest();
        Loan_Application__c loan = [SELECT Id, Base_Credit_Verification__c, RecordType.DeveloperName FROM Loan_Application__c];
        CAMReportChildComponentsController.loan = loan;
        List<Applicant__c> applicants = [SELECT Id, RecordType.Name, First_Name__c, Middle_Name__c, Last_Name__c, CIBIL_Report_Verified_By_Credit__c, Lead_Dedupe_Verified_By_Credit__c, Customer_Dedupe_Verified_By_Credit__c, (SELECT Id FROM Addresses__r WHERE Address_Type__c IN ('Permanent','Current')) from Applicant__c WHERE Loan__c=:loan.Id];
        List<Id> applicantIds = new List<Id>();
        CAMReportChildComponentsController.applicants = applicants;
        Applicant__c primeApplicant = new Applicant__c();
        for(Applicant__c app: applicants){
            applicantIds.add(app.Id);
            if(app.RecordType.Name == 'Applicant'){
                primeApplicant= app;
            }
        }
        System.debug('Primary Applicant '+primeApplicant);
        Field_Investigation__c fi1 = new Field_Investigation__c(FI_Status__c='Positive', Applicant__c=primeApplicant.Id, Address_Lookup__c=primeApplicant.Addresses__r[0].Id, Loan_Application__c=loan.Id);
        Field_Investigation__c fi2 = new Field_Investigation__c(FI_Status__c='Positive', Applicant__c=primeApplicant.Id, Address_Lookup__c=primeApplicant.Addresses__r[0].Id, Loan_Application__c=loan.Id);
        List<Field_Investigation__c> fiRecords = new List<Field_Investigation__c>{fi1, fi2};
        insert fiRecords;
        Map<String,String> mapOfTabs = CAMReportChildComponentsController.getTabNames();
        System.assertEquals(mapOfTabs.get('TAR'), 'Verified', 'Success');
        Test.stopTest();
    }
    
    @isTest
    public static void getStateTest(){
        Test.startTest();
        Loan_Application__c loan = [SELECT Id, Dealer_Master__r.State__r.Account_Name__c FROM Loan_Application__c];
        CAMReportChildComponentsController.loan = loan;
        String state = CAMReportChildComponentsController.getState();
        System.assertEquals(state, 'Dealer State', 'Success');
        Test.stopTest();
    }
    
    @IsTest
    static void testGetCartDocDetail2() {
        Test.startTest();
        CAMReportChildComponentsController.cartRecords = [SELECT ID From Bank_Account_Records__c];
        Map<String,String> retVal = CAMReportChildComponentsController.getCartDocDetail();
        Test.stopTest();
    }
    
    
    @IsTest
    static void testGetValuations2() {
        String loanId = [SELECT ID From Loan_Application__c LIMIT 1].ID;
        Collateral__c testCollateralRec = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId(),
            Loan__c = loanId,
            Collateral_Type__c = 'Existing ',
            Registration_Number__c = '123456Test',
            Ex_Showroom_Price__c = 100,
            Discount__c = 10,
            Net_of_Discount_Price__c = 10,
            Final_Cost__c = 10,
            LTV_offered_On_final_cost__c = 10,
            Apportioned_Loan_Amount__c = 10,
            RTO_Taxes__c = 100.00,
            Insurance__c = 1000.00
        ),true);
        Valuation__c val = (Valuation__c)TestFactory.createSObject(new Valuation__c(
            Valuer_Name_Code__c = '1234',
            Coordinate_for_valuation_POC__c = '12345',
            Collateral__c = testCollateralRec.Id,
            Final_remarks__c = 'Test'
            
        ),true);
        Test.startTest();
        CAMReportChildComponentsController.collateral = testCollateralRec;
        Valuation__c retVal = CAMReportChildComponentsController.getValuations();
        delete val;
        Valuation__c retVal1 = CAMReportChildComponentsController.getValuations();
        Test.stopTest();
    }
    
    @IsTest
    static void testGetAQBByApplicant2() {
        CAMReportChildComponentsController.cartRecords = [SELECT ID, Applicant__c, Average_Monthly_Balance__c From Bank_Account_Records__c];
        CAMReportChildComponentsController.applicants = [SELECT Id FROM Applicant__c];
        Test.startTest();
        map<Id, String> retMap = CAMReportChildComponentsController.getAQBByApplicant();
        Test.stopTest();
    }
    
    @IsTest
    static void testSTaticValues2() {
        CAMReportChildComponentsController.creditRemarks = 'Test Remarks';
        CAMReportChildComponentsController.valuation = new Valuation__c();
        CAMReportChildComponentsController.vehiclededup = 'Test';
        CAMReportChildComponentsController.subProduct = 'Test';
        CAMReportChildComponentsController.vahaanPdf = 'Test';
        CAMReportChildComponentsController.amountRoundOff = 100.00;
        CAMReportChildComponentsController.bureauScor = '10';
        CAMReportChildComponentsController.ltv = '10';
        CAMReportChildComponentsController.pslDetails = new BSR_PSL_Details__c();
        CAMReportChildComponentsController.loan = [SELECT Id, Loan_Amount__c FROM Loan_Application__c LIMIT 1];
        Collateral__c testCollateralRec = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId(),
            Loan__c = CAMReportChildComponentsController.loan.Id,
            Collateral_Type__c = 'Existing ',
            Registration_Number__c = '123456Test',
            Ex_Showroom_Price__c = 100,
            Discount__c = 10,
            Net_of_Discount_Price__c = 10,
            Final_Cost__c = 10,
            LTV_offered_On_final_cost__c = 10,
            Apportioned_Loan_Amount__c = 10,
            RTO_Taxes__c = 100.00,
            Insurance__c = 1000.00
        ),true);
        CAMReportChildComponentsController.collateral = testCollateralRec;
        
        //CAMReportChildComponentsController.loanAmountIncLsAndInsurance = 
        
        
        
    }
    
    @IsTest
    static void testupdateFIReportCheck22() {
        String fiId = [Select Id From Field_investigation__c LIMIT 1].Id;
        Test.startTest();
        CAMReportChildComponentsController.updateFIReportCheck(fiId);
        Test.stopTest();
    }
    
    
    
}