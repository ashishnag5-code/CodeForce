@isTest
public class UtilityTest {
    @testSetup static void setup() {
    
        // Create test data
        Trigger_Deactivation_Settings__c trigSetup = new Trigger_Deactivation_Settings__c ();
        trigSetup.AccountTeamMember_Trigger__c = true;
        trigSetup.SetupOwnerId = UserInfo.getUserId();
        insert trigSetup;
        
        Document_Master__c  docMasterRec = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(Name ='AUWheels0053', Document_Id__c = 'AUWheels0053', Document_Name__c  ='FI Photos', Active__c = true),true);
        
        List<Rule_Definition__c> lstRuleDef = new List<Rule_Definition__c>();
        Rule_Definition__c objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'Lead,QDE,DDE',
                                                                                                               Rule_Condition__c = 'Contains', 
                                                                                                               Subject_Field__c = 'Loan_Stage__c', Target_Object__c = 'Applicant__c',
                                                                                                               Value_Field__c = 'Value', 
                                                                                                               Sequence__c = 1, Rule_Name__c = 'Applicant Rule'),false);
        lstRuleDef.add(objRuleDef);
        
        objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'Lead,QDE,DDE',
                                                                                            Rule_Condition__c = 'Equals', 
                                                                                            Subject_Field__c = 'Loan_Stage__c', Target_Object__c = 'Applicant__c',
                                                                                            Value_Field__c = 'Value', 
                                                                                            Sequence__c = 1, Rule_Name__c = 'Applicant Rule'),false);
        lstRuleDef.add(objRuleDef);
        
        objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'Lead,QDE,DDE',
                                                                                            Rule_Condition__c = 'Not Equals', 
                                                                                            Subject_Field__c = 'Loan_Stage__c', Target_Object__c = 'Applicant__c',
                                                                                            Value_Field__c = 'Value', 
                                                                                            Sequence__c = 1, Rule_Name__c = 'Applicant Rule'),false);
        lstRuleDef.add(objRuleDef);
        
        objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'Lead,QDE,DDE',
                                                                                            Rule_Condition__c = 'Starts With', 
                                                                                            Subject_Field__c = 'Loan_Stage__c', Target_Object__c = 'Applicant__c',
                                                                                            Value_Field__c = 'Value', 
                                                                                            Sequence__c = 1, Rule_Name__c = 'Applicant Rule'),false);
        lstRuleDef.add(objRuleDef);
        
        objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'Lead,QDE,DDE',
                                                                                            Rule_Condition__c = 'Does not Contains', 
                                                                                            Subject_Field__c = 'Loan_Stage__c', Target_Object__c = 'Applicant__c',
                                                                                            Value_Field__c = 'Value', 
                                                                                            Sequence__c = 1, Rule_Name__c = 'Applicant Rule'),false);
        lstRuleDef.add(objRuleDef);
        
        objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'Lead,QDE,DDE',
                                                                                            Rule_Condition__c = 'Includes', 
                                                                                            Subject_Field__c = 'Loan_Stage__c', Target_Object__c = 'Applicant__c',
                                                                                            Value_Field__c = 'Value', 
                                                                                            Sequence__c = 1, Rule_Name__c = 'Applicant Rule'),false);
        lstRuleDef.add(objRuleDef);
        
        objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'Lead,QDE,DDE',
                                                                                            Rule_Condition__c = 'Excludes', 
                                                                                            Subject_Field__c = 'Loan_Stage__c', Target_Object__c = 'Applicant__c',
                                                                                            Value_Field__c = 'Value', 
                                                                                            Sequence__c = 1, Rule_Name__c = 'Applicant Rule'),false);
        lstRuleDef.add(objRuleDef);
        
        insert lstRuleDef;
        
        Rule_Driver__c objRuleDriver = (Rule_Driver__c )TestFactory.createSObject(new Rule_Driver__c ( Configuring_For__c = 'Document Checklist', 
                                                                                                      Effective_To__c = System.Today().addDays(365), Effective_From__c = System.Today().addDays(-10), Logical_Expression__c = '1', Target_Value__c = 'AUWheels0053', Match_Criteria__c = 'All Match'),false);
        insert objRuleDriver; 
        
        List<Rule_Definition_Driver_Mapping__c> lstDriverMapping = new List<Rule_Definition_Driver_Mapping__c>();
        for (Rule_Definition__c objRuleD : [Select Id from Rule_Definition__c]) {
            Rule_Definition_Driver_Mapping__c objMap = (Rule_Definition_Driver_Mapping__c )TestFactory.createSObject(new Rule_Definition_Driver_Mapping__c ( 
                Rule_Driver_ID__c = objRuleDriver.Id ,
                Rule_ID__c = objRuleD.Id 
            ),false);
            lstDriverMapping.add(objMap);
        }
        insert lstDriverMapping;
        
        Profile prof = [select Id,Name from profile where name like '%Credit%'];
        
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        
        Id leadRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Four_Wheeler').getRecordTypeId();        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Stage__c ='QDE',
            Wheels_Exposure__c=500,
            Final_Exposure__c =1000,
            BRE_Decision__c = 'NSTP',
            RecordTypeId = leadRecordTypeId
        ),true);
        
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            Customer_Type__c = 'Individual',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
        Document_Master__c  docMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c (
            Name = 'Live Photo', Mandatory__c = true,
            X2W_Stage__c = 'PSD',
            X4W_Stage__c = 'PSD',
            Individual_NI__c = 'All',
            Document_Name__c = 'Live Photo'
        ),false);
        
        Document_Master__c  docMasterDL = (Document_Master__c)TestFactory.createSObject(new Document_Master__c (
            Name = 'Driving Licence', Mandatory__c = true,
            X2W_Stage__c = 'PSD',
            X4W_Stage__c = 'PSD',
            Individual_NI__c = 'All',
            Document_Name__c = 'Driving Licence'
        ),false);
        Document_Master__c  docMasterAadhaar = (Document_Master__c)TestFactory.createSObject(new Document_Master__c (
            Name = 'Aadhaar Card', Mandatory__c = true,
            X2W_Stage__c = 'PSD',
            X4W_Stage__c = 'PSD',
            Individual_NI__c = 'All',
            Document_Name__c = 'Aadhaar Card'
        ),false);
        insert new List<Document_Master__c>{docMaster,docMasterDL,docMasterAadhaar};
            
            
            Document_Checklist__c docChkRecord = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
                Parent_Loan__c   = loanAppl.Id,
                Applicant__c = appl.Id,
                Document_Master__c = docMaster.Id,
                Document_Name__c ='Live Photo',
                Document_Number__c = 'BEMPN6666E',
                Name_Match_Score__c = 100,
                Active__c = true,
                Api_Response__c='{"Result":"SUCCESS"}'
            ),false);
        Document_Checklist__c docChkRecord2 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id,
            Applicant__c = appl.Id,
            Document_Master__c = docMaster.Id,
            Document_Name__c ='Live Photo',
            Document_Number__c = 'BEMPN6666E',
            Name_Match_Score__c = 100,
            Active__c = true,
            Api_Response__c='{"Result":"SUCCESS"}'
        ),false);
        Document_Checklist__c docChkRecordDL = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id,
            Applicant__c = appl.Id,
            Document_Master__c = docMasterDL.Id,
            Document_Name__c ='Driving Licence',
            Document_Number__c = 'BEMPN6666E',
            Name_Match_Score__c = 100,
            Active__c = true,
            Api_Response__c='{"Result":"SUCCESS"}'
        ),false);
        Document_Checklist__c docChkRecordDL2 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id,
            Applicant__c = appl.Id,
            Document_Master__c = docMasterDL.Id,
            Document_Name__c ='Driving Licence',
            Document_Number__c = 'BEMPN6666E',
            Name_Match_Score__c = 100,
            Active__c = true,
            Api_Response__c='{"Result":"SUCCESS"}'
        ),false);
        Document_Checklist__c docChkRecordAadhaar = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id,
            Applicant__c = appl.Id,
            Document_Master__c = docMasterAadhaar.Id,
            Document_Name__c ='Aadhaar Card',
            Document_Number__c = 'BEMPN6666E',
            Name_Match_Score__c = 100,
            Api_Response__c='{"Result":"SUCCESS"}'
        ),false);
        
        Document_Checklist__c docChkRecordAadhaar2 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id,
            Applicant__c = appl.Id,
            Document_Master__c = docMasterAadhaar.Id,
            Document_Name__c ='Aadhaar Card',
            Document_Number__c = 'BEMPN6666E',
            Name_Match_Score__c = 100,
            Active__c = true,
            Api_Response__c='{"Result":"SUCCESS"}'
        ),false);
        insert new List<Document_Checklist__c>{docChkRecord,docChkRecord2,docChkRecordDL,docChkRecordDL2,docChkRecordAadhaar,docChkRecordAadhaar2};
            Contentversion objCV = new Contentversion(Title = 'ABC', PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=docChkRecord.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        // insert objCV;
        Contentversion objCV2 = new Contentversion(Title = 'ABC', PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=docChkRecord2.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        // insert objCV2;
        
        Contentversion objCVDL = new Contentversion(Title = 'ABC', PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=docChkRecordDL2.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        //insert objCVDL;
        Contentversion objCVAadhar = new Contentversion(Title = 'ABC', PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=docChkRecordAadhaar.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        Contentversion objCVAadhar2 = new Contentversion(Title = 'ABC', PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=docChkRecordAadhaar2.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        Contentversion objCVDL2 = new Contentversion(Title = 'ABC',IsActive__c = true, PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=docChkRecordDL.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        
        List<Contentversion> conVersionList = new List<Contentversion>{objCV,objCV2,objCVDL,objCVAadhar,objCVAadhar2,objCVDL2};
        ContentVersionTriggerHandler.boolTriggerRun = false;
            insert conVersionList;
        
        Map<Id, ContentVersion> conMap = new Map<Id, ContentVersion>([Select ContentDocumentId FROM ContentVersion WHERE Id in: conVersionList]);
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = docChkRecordDL2.Id;
        cdl.ContentDocumentId = conMap.get(objCVDL2.Id).ContentDocumentId;
        cdl.shareType = 'V';
        // Insert cdl;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = docChkRecordDL.Id;
        cdl2.ContentDocumentId = conMap.get(objCVDL.Id).ContentDocumentId;
        cdl2.shareType = 'V';
        // Insert cdl2;
        ContentDocumentLink cdl3 = New ContentDocumentLink();
        cdl3.LinkedEntityId = docChkRecord.Id;
        cdl3.ContentDocumentId = conMap.get(objCV.Id).ContentDocumentId;
        cdl3.shareType = 'V';
        
        ContentDocumentLink cdl4 = New ContentDocumentLink();
        cdl4.LinkedEntityId = docChkRecord2.Id;
        cdl4.ContentDocumentId = conMap.get(objCV2.Id).ContentDocumentId;
        cdl4.shareType = 'V';
        
        ContentDocumentLink cdl5 = New ContentDocumentLink();
        cdl5.LinkedEntityId = docChkRecordAadhaar.Id;
        cdl5.ContentDocumentId = conMap.get(objCVAadhar.Id).ContentDocumentId;
        cdl5.shareType = 'V';
        
        ContentDocumentLink cdl6 = New ContentDocumentLink();
        cdl6.LinkedEntityId = docChkRecordAadhaar2.Id;
        cdl6.ContentDocumentId = conMap.get(objCVAadhar2.Id).ContentDocumentId;
        cdl6.shareType = 'V';
        
        new List<ContentDocumentLink>{cdl,cdl2,cdl3,cdl4,cdl5,cdl6};
            Collateral__c coll= new Collateral__c(Loan__c=loanAppl.Id);
        coll.RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId();
        insert coll;
        //Sector
        Id sectorRecordTypeId = Schema.SObjectType.Profiling_Master__c.getRecordTypeInfosByName().get('RT - Sector').getRecordTypeId();
        Profiling_Master__c profMaster = (Profiling_Master__c)TestFactory.createSObject(new Profiling_Master__c(
            Name='Manufacturer',
            Entity_Type__c = 'Individual',
            RecordTypeId = sectorRecordTypeId
        ),true);
        
        //Industry
        Id industryRecordTypeId = Schema.SObjectType.Profiling_Master__c.getRecordTypeInfosByName().get('RT - Industry').getRecordTypeId();
        Profiling_Master__c industryMaster = (Profiling_Master__c)TestFactory.createSObject(new Profiling_Master__c(
            Name='Construction & Civil Engineering',
            Sector__c = profMaster.Id,
            RecordTypeId = industryRecordTypeId
        ),true);
        
        //SubIndustry
        Id subIndustryRecordTypeId = Schema.SObjectType.Profiling_Master__c.getRecordTypeInfosByName().get('RT - Sub Industry').getRecordTypeId();
        Profiling_Master__c subIndustryMaster = (Profiling_Master__c)TestFactory.createSObject(new Profiling_Master__c(
            Name='Metal Cutlery',
            Sector__c = profMaster.Id,
            Industry__c =industryMaster.Id,
            RecordTypeId = subIndustryRecordTypeId
        ),true);
        
        //Occupation
        Id occupationRecordTypeId = Schema.SObjectType.Profiling_Master__c.getRecordTypeInfosByName().get('RT - Occupation').getRecordTypeId();
        Profiling_Master__c occupationMaster = (Profiling_Master__c)TestFactory.createSObject(new Profiling_Master__c(
            Name='Manufacturer',
            Sector__c = profMaster.Id,
            Industry__c = industryMaster.Id,
            Sub_Industry__c =subIndustryMaster.Id,
            Group__c = 'MANUFACTURING',
            Sub_Group__c= 'Food products',
            Occupation_Group__c= 'MEAT',
            PSL_Classification_Category__c = 'PSL- Micro',
            PSL_Classification_Type__c = 'PSL-Agri',
            PSL_Code__c = 'AGFC0105',
            PSL_Description__c = 'AGFC0105-Loans to individual farmers under the Kisan Credit Card Scheme',
            PSL_Segment__c = 'AGFC01 - Farm Credit Individual',
            RecordTypeId = occupationRecordTypeId
        ),true);
        
        // Applicant Financials Insertion
        Id parentRecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Financial Parent').getRecordTypeId();
        Applicant_Financials_Details__c applParentFinancials = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
            Applicant__c = appl.Id,
            RecordTypeId = parentRecordTypeId,
            isActive__c = true,
            Type_Of_Employment__c ='Salaried - Private',
            Method_Of_Assesment__c ='Salaried',
            Monthly_Income__c =100,
            Monthly_Obligation__c =50,
            Other_Income__c =80,
            Consider_Income_for_Eligibility__c='Yes'
        ),true);
        
        BSR_PSL_Details__c  bsrObj = (BSR_PSL_Details__c )TestFactory.createSObject(new BSR_PSL_Details__c (
            Loan_Application__c = loanAppl.Id,
            RecordTypeId = Schema.SObjectType.BSR_PSL_Details__c.getRecordTypeInfosByName().get('BSR').getRecordTypeId()
        ),true);
        
        BSR_PSL_Details__c  pslObj = (BSR_PSL_Details__c )TestFactory.createSObject(new BSR_PSL_Details__c (
            Loan_Application__c = loanAppl.Id,
            RecordTypeId = Schema.SObjectType.BSR_PSL_Details__c.getRecordTypeInfosByName().get('PSL').getRecordTypeId()
        ),true);
        
        System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]) {
            
            Account accInstance = (Account )TestFactory.createSObject(new Account (
                Name ='TestAccount',
                Account_Code__c='2103',
                Branch_Queue__c=grp.Id
            ),true); 
            
            Loan_Application_Approval__c applicationAppTest = (Loan_Application_Approval__c  )TestFactory.createSObject(new Loan_Application_Approval__c  (
                Loan_Application__c   = loanAppl.Id,
                Approver__c   = UserInfo.getUserId(),
                Approval_Type__c = 'Credit',
                Approver_Level__c  = 'L0',
                Type__c = 'Highest'
                
            ),false);
            
            Loan_Application_Approval__c applicationAppTest2 = (Loan_Application_Approval__c  )TestFactory.createSObject(new Loan_Application_Approval__c  (
                Loan_Application__c   = loanAppl.Id,
                Approver__c   = UserInfo.getUserId(),
                Approval_Type__c = 'Pricing',
                Approver_Level__c  = 'L0',
                Type__c = 'Highest'
                
            ),false);
            insert new List<Loan_Application_Approval__c> {applicationAppTest, applicationAppTest2};
                
                
                User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
                                                                    lastName = 'test2',
                                                                    profileId = prof.id,
                                                                    username = 'test'+UserInfo.getOrganizationId()+'@test.com',
                                                                    email = 'test@test.com',
                                                                    Branch_Code__c  = '2103'
                                                                   ),true);
            usr.IsActive = true;
            update usr;
            AccountTeamMember atm = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
                AccountId =accInstance.Id,
                UserId=usr.Id,
                TeamMemberRole = 'Branch Manager'
            ),true);                                                                                                                        
        }
        
        Id paymentFavRecId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId();
        Payment__c payment = new Payment__c(Loan_application__c = loanAppl.Id, recordTypeId = paymentFavRecId);
        insert payment;
        
        Integration_Master__c im = new Integration_Master__c(Name = 'Payment NEFT');
        insert im;
        
        Integration_Checklist__c ic = new Integration_Checklist__c(Payment__c = payment.Id, Status__c = 'Completed', integration_master__c = im.Id);
        insert ic;
    }
    
    @isTest 
    static void getRestrictProfileTest(){
        Test.startTest();
        Utility.getRestrictProfile('Credit');
        Test.stopTest();
    }
    
    @isTest 
    static void fetchBranchMasterRecordTest(){
        Test.startTest();
        user objUser = [Select id from user where FirstName = 'Test1' and LastName = 'test2'];
        System.runAs(objUser) {
            Utility.fetchBranchMasterRecord();
        }
        Test.stopTest();
    }
    
    @isTest 
    static void getTypeOfWheelerTest(){
        Test.startTest();
        Utility.getTypeOfWheeler('10201');
        Utility.getTypeOfWheeler('10214');
        Utility.getTypeOfWheeler('10405');
        Utility.getTypeOfWheeler('10505');
        Utility.getTypeOfWheeler('10309');
        Test.stopTest();
    }
    
    @isTest 
    static void getVisibleFieldsTest(){
        Test.startTest();
        try {
            Utility.getVisibleFields ('Loan Details', 'QDE', 'Credit');
        }
        catch (Exception ex){}
        
        Test.stopTest();
    }
    
    @isTest 
    static void getVisibleFieldsProductTest(){
        Test.startTest();
        try {
            Utility.getVisibleFields ('Loan Details', 'QDE', 'Credit', 'Two Wheeler', 'Individual');
        }
        catch(Exception ex){}
        Test.stopTest();
    }
    
    @isTest 
    static void getMaterialFieldsTest(){
        Test.startTest();
        user objUser = [Select id from user where FirstName = 'Test1' and LastName = 'test2'];
        Loan_Application__c objLA = [Select Id from Loan_Application__c];
        System.runAs(objUser) {
            Utility.getMaterialFields('Loan Details',objLA.Id);
        }
        Test.stopTest();
    }
    
    @isTest 
    static void getVisibleFieldsForCustomerTest(){
        Test.startTest();
        try {
            Utility.getVisibleFieldsForCustomer ('Loan Details', 'QDE', 'Credit', 'Individual');
        }
        catch(Exception ex){}
        Test.stopTest();
    }
    
    @isTest 
    static void getWizardSettingsTest(){
        Test.startTest();
        Utility.getWizardSettings ('Loan Details', 'QDE');
        Test.stopTest();
    }
    
    @isTest 
    static void getMandatoryDocsInOptionalsTest(){
        Test.startTest();
        user objUser = [Select id from user where FirstName = 'Test1' and LastName = 'test2'];
        Loan_Application__c objLA = [Select Id from Loan_Application__c];
        System.runAs(objUser) {
            try {
                Utility.getMandatoryDocsInOptionals(objLA.Id, 'PSD');
            }
            catch (Exception ex){}    
        }
        Test.stopTest();
    }
    
    @isTest 
    static void storeMatchResultsTest(){
        Test.startTest();
        user objUser = [Select id from user where FirstName = 'Test1' and LastName = 'test2'];
        Loan_Application__c objLA = [Select Id, (SElect id from Applicants__r) from Loan_Application__c];
        System.runAs(objUser) {
            Utility.storeMatchResults('Name','Name','Live Photo',10,objLA.Applicants__r[0].Id,false);
        }
        Test.stopTest();
    }
        @isTest 
    static void getApproalsForReworkTest(){
        Test.startTest();
        user objUser = [Select id from user where FirstName = 'Test1' and LastName = 'test2'];
        Loan_Application__c objLA = [Select Id,RecordType.Name, (SElect id,Customer_Type__c from Applicants__r) from Loan_Application__c];
        System.runAs(objUser) {
            Utility.getApproalsForRework(objLA);
            Utility.getApplicantByCustomerType(objLA.Applicants__r);
        }
        Test.stopTest();
    }
    
    @isTest 
    static void getDeviationTest(){
        Test.startTest();
        user objUser = [Select id from user where FirstName = 'Test1' and LastName = 'test2'];
        Loan_Application__c objLA = [Select Id, (SElect id from Applicants__r) from Loan_Application__c];
        System.runAs(objUser) {
            Deviation__c obj = Utility.getDeviation('','LTV Norm','Details__c','S1', objLA.Id,'',true);
            List<Deviation__c> lst = new List<Deviation__c>();
            lst.add(obj);
            Utility.createDeviation (lst);
        }
        Test.stopTest();
    }
    @isTest 
    static void checkUploadedDocsTest(){
        Test.startTest();
        user objUser = [Select id from user where FirstName = 'Test1' and LastName = 'test2'];
        Loan_Application__c objLA = [Select Id, (SElect id from Applicants__r) from Loan_Application__c];
        System.runAs(objUser) {
            Utility.checkUploadedDocs(objLA.Id,'PSD');
        }
        Test.stopTest();
    }
    
    @isTest 
    static void createBSRAssignmentTest(){
        Test.startTest();
        user objUser = [Select id from user where FirstName = 'Test1' and LastName = 'test2'];
        Loan_Application__c objLA = [Select Id,BRE_Decision__c, Branch_Master__c,Stage__c, BRE_Approval_Level__c, (SElect id from Applicants__r) from Loan_Application__c];
        System.runAs(objUser) {
            Utility.createBSRAssignment(new List<Loan_Application__c>{objLA},true);
        }
        Test.stopTest();
    }
    
    @isTest 
    static void checkMaterialFieldsTest(){
        Test.startTest();
        user objUser = [Select id from user where FirstName = 'Test1' and LastName = 'test2'];
        Loan_Application__c objLA = [Select Id,BRE_Decision__c, (SElect id from Applicants__r) from Loan_Application__c];
        System.runAs(objUser) {
            Utility.checkMaterialFields('AU_Employee__c',objLA.Id,new List<String>{'Customer Details'});
        }
        Test.stopTest();
    }
    @isTest 
    static void checkMaterialFieldsTest2(){
        Test.startTest();
        user objUser = [Select id from user where FirstName = 'Test1' and LastName = 'test2'];
        Loan_Application__c objLA = [Select Id,BRE_Decision__c, (SElect id from Applicants__r) from Loan_Application__c];
        System.runAs(objUser) {
            Utility.checkMaterialFields('AU_Employee__c',objLA.Applicants__r[0].Id,new List<String>{'Customer Details'});
        }
        Test.stopTest();
    }
    @isTest 
    static void getPageNameByDocNameTest(){
        Test.startTest();
        user objUser = [Select id from user where FirstName = 'Test1' and LastName = 'test2'];
        Loan_Application__c objLA = [Select Id,BRE_Decision__c, (SElect id from Applicants__r) from Loan_Application__c];
        System.runAs(objUser) {
            Utility.getPageNameByDocName();
        }
        Test.stopTest();
    }
    @isTest 
    static void getProductTypeNameTest(){
        Test.startTest();
        user objUser = [Select id from user where FirstName = 'Test1' and LastName = 'test2'];
        Loan_Application__c objLA = [Select Id,BRE_Decision__c,Stage__c, (SElect id,Type_Of_Employment__c,Risk_Identification__c,High_risk_Profile__c,Loan__r.RecordType.Name from Applicants__r) from Loan_Application__c];
        System.runAs(objUser) {
            Utility.getProductTypeName('10201');
            Utility.getSubProductName('10201');
            Utility.calculatePercentageDiff(50000,10000);
            Utility.getApplicantRiskCategoryBy(objLA.Applicants__r[0]);
            Utility.getHighRiskProfilesByVehicleType('New');
            
            Utility.getSObjectDirtyFields(objLA,objLA,new List<String>{'Stage__c'});
        }
        Test.stopTest();
    }
    @isTest 
    static void getApplicantsTest(){
        Test.startTest();
        user objUser = [Select id from user where FirstName = 'Test1' and LastName = 'test2'];
        Loan_Application__c objLA = [Select Id,BRE_Decision__c,Stage__c, (SElect id,Type_Of_Employment__c,Risk_Identification__c,High_risk_Profile__c,Loan__r.RecordType.Name from Applicants__r) from Loan_Application__c];
        System.runAs(objUser) {
            Utility.getApplicants(objLA.Applicants__r[0].Id);
        }
        Test.stopTest();
    }
    @isTest 
    static void getCurrentBREStatusTest(){
        Test.startTest();
        user objUser = [Select id from user where FirstName = 'Test1' and LastName = 'test2'];
        Loan_Application__c objLA = [Select Id,BRE_Decision__c,Pre_Approved_Flag__c,BRE_Run_for_PreApproved_Offer__c,BRE_ReRun_Required__c,Stage__c,Previous_Stage__c, (SELECT Id,Approval_Type__c,Type__c from Loan_Application_Approvers__r ) from Loan_Application__c];
        objLA.Stage__c = 'Credit';
        objLA.Previous_Stage__c = 'DDE';
        update objLA;
        objLA.Stage__c = 'DDE';
        objLA.Previous_Stage__c = 'Credit';
        update objLA;

        Loan_Application_Approval__c objApp = new Loan_Application_Approval__c();
        List<Loan_Application_Approval__c> lstLoanAppApproval = new List<Loan_Application_Approval__c>();
        Loan_Application_Approval__c loanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = objLA.Id,  Approval_Type__c = 'Credit' , Approver__c = UserInfo.getUserId(), Approval_Status__c = 'Send Back to RO',
            Archived__c = false, Approver_Level__c = 'L1', Type__c = 'Base'
        ),false);
        lstLoanAppApproval.add(loanAppApproval);
        Loan_Application_Approval__c loanAppApproval1 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = objLA.Id, Approver__c = UserInfo.getUserId() , Approval_Type__c = 'Credit', Approver_Level__c = 'L2', Type__c = 'Middle', Approval_Status__c = 'Send Back to RO'
        ),false);
        lstLoanAppApproval.add(loanAppApproval1);
        insert lstLoanAppApproval;
        System.runAs(objUser) {
            Utility.getCurrentBREStatus(objLA);
            objLA.BRE_ReRun_Required__c = true;
            Utility.getCurrentBREStatus(objLA);
            Utility.getApproverTypeToApproval(objLA.Loan_Application_Approvers__r);
            Utility.getApprovalRecordsToRework(objLA,'Credit');
        }
        Test.stopTest();
    }
    @IsTest
    public static void testGetApprovalDetails() {
        List<Loan_Application__c> lst = [SELECT Id from Loan_Application__c];
        Test.startTest();
        SummaryPageWrapperController.ApprovalDetailWrapper returnWrapper = SummaryPageController.getApprovalDetails(lst[0].Id);
        returnWrapper = SummaryPageController.getApprovalDetails(lst[0].Id);
        Test.stopTest();
        System.assertEquals(returnWrapper!=null, true);
    }
    @isTest 
    static void getLTVOfferedOnRoadPriceTest() {
        List<Loan_Application__c> lst = [SELECT Id,(SELECT Id,Apportioned_Loan_Amount__c,Vehicle_Cost__c FROM Collaterals__r) from Loan_Application__c];
        lst[0].Collaterals__r[0].Vehicle_Cost__c = 10000;
        Utility.getLTVOfferedOnRoadPrice(lst[0].Collaterals__r[0]);
    }
    @isTest 
    static void getLTVOfferedOnRoadPriceNewTest() {
        List<Loan_Application__c> lst = [SELECT Id,(SELECT Id,Apportioned_Loan_Amount__c,Vehicle_Cost__c,LS_Value__c FROM Collaterals__r) from Loan_Application__c];
        lst[0].Collaterals__r[0].On_Road_Price__c = 10000;
        Utility.getLTVOfferedOnRoadPriceNew(lst[0].Collaterals__r[0]);
    }
    @isTest 
    static void getLTVOfferedExshowroomPriceTest() {
        List<Loan_Application__c> lst = [SELECT Id,(SELECT Id,Apportioned_Loan_Amount__c,Net_of_Discount_Price__c,LS_Value__c FROM Collaterals__r) from Loan_Application__c];
        lst[0].Collaterals__r[0].On_Road_Price__c = 10000;
        Utility.getLTVOfferedExshowroomPrice(lst[0].Collaterals__r[0]);
    }
    @isTest 
    static void getLoanEligibilityTest() {
        List<Loan_Application__c> lst = [SELECT Id,(SELECT Id,Approved_LTV__c,Apportioned_Loan_Amount__c,Net_of_Discount_Price__c,LS_Value__c FROM Collaterals__r) from Loan_Application__c];
        lst[0].Collaterals__r[0].Apportioned_Loan_Amount__c = 10000;
        Utility.getLoanEligibility(lst[0].Collaterals__r[0]);
    }
    @isTest 
    static void getLTVOfferedOnFinalCostTest() {
        List<Loan_Application__c> lst = [SELECT Id,(SELECT Id,Loan__r.Total_Loan_Amount__c,Apportioned_Loan_Amount__c,Net_of_Discount_Price__c,LS_Value__c FROM Collaterals__r) from Loan_Application__c];
        lst[0].Collaterals__r[0].Final_Cost__c = 10000;
        Utility.getLTVOfferedOnFinalCost(lst[0].Collaterals__r[0]);
    }
    @isTest 
    static void splitCustomLabelTest() {
        Utility.splitCustomLabel('splitCustomLabel,splitCustomLabel,splitCustomLabel,splitCustomLabel');
    }
    @isTest 
    static void getLTVOfferedOnFinalCostNewTest() {
        List<Loan_Application__c> lst = [SELECT Id,(SELECT Id,Vehicle_Cost__c,Approved_LTV__c,Apportioned_Loan_Amount__c,Net_of_Discount_Price__c,LS_Value__c FROM Collaterals__r) from Loan_Application__c];
        lst[0].Collaterals__r[0].Final_Cost__c = 10000;
        Utility.getLTVOfferedOnFinalCostNew(lst[0].Collaterals__r[0]);
        lst[0].Collaterals__r[0].Apportioned_Loan_Amount__c = 10000;
        Utility.getCustomerEquity(lst[0].Collaterals__r[0]);
        lst[0].Collaterals__r[0].Apportioned_Loan_Amount__c = 10000;
        Utility.getLoanEligibilityNewVehicle(lst[0].Collaterals__r[0]);
        lst[0].Collaterals__r[0].Net_of_Discount_Price__c = 10000;
        Utility.getLTVOfferedOnExShowroom(lst[0].Collaterals__r[0]);
        
    }
    @isTest static void verifyApplicationForward2W(){
        Test.startTest();
        Profile prof = [select Id,Name from profile where name like '%Credit%'];
        User usr = (User)TestFactory.createSObject(new User(firstName = 'credapp1',
                                                            lastName = 'test2',
                                                            profileId = prof.id,
                                                            username = 'test'+UserInfo.getOrganizationId()+'@sstest.com',
                                                            email = 'test@test.com',
                                                            Branch_Code__c  = '2103',
                                                            Authority_Level__c = 'L2'
                                                           ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='Credit',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            BRE_Decision__c = 'STP',
            BRE_Approval_Level__c = 'L1',
            Valuation_Completion_Date__c = Date.today().addDays(-40),
            FI_Completion_Date__c = Date.today().addDays(-40),
            RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId()
        ),true);
        list<Loan_Application_Approval__c> lstLoanAppApproval = new List<Loan_Application_Approval__c>();
        Loan_Application_Approval__c loanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id,  Approval_Type__c = 'Credit' , Approver__c = usr.id,
            Archived__c = false, Approver_Level__c = 'L1', Type__c = 'Base'
        ),false);
        Loan_Application_Approval__c loanAppApproval1 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id, Approver__c = usr.id , Approval_Type__c = 'Credit', Approver_Level__c = 'L2', Type__c = 'Middle'
        ),false);
        Loan_Application_Approval__c loanAppApproval2 = (Loan_Application_Approval__c)TestFactory.createSObject(
            new Loan_Application_Approval__c(
                Loan_Application__c  = loanAppl.Id,
                Assigned_to_Queue__c = true,
                Approver__c = usr.id,
                Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING,
                Approver_Level__c = 'L3', Approval_Type__c = 'Credit', Type__c = 'Highest'
            ),false);
        
        
        lstLoanAppApproval.addAll(new Loan_Application_Approval__c[]{ loanAppApproval, loanAppApproval1, loanAppApproval2 });
        insert lstLoanAppApproval;
        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
        
        Account acc = [SELECT Id FROM Account Limit 1];
        List<AccountTeamMember> atms = new List<AccountTeamMember>();
        AccountTeamMember ac1 = new AccountTeamMember(
            UserId = usr.Id,
            AccountId = acc.Id,
            TeamMemberRole = 'Credit',
            Approver_Level__c = 'L7',
            Deviation_Level__c = 'S5'
        );
        
        atms.add(ac1);
        insert atms;
        Id loanId = loanAppl.Id;
        Field_Investigation__c fi = new Field_Investigation__c(Loan_Application__c = loanId);
        insert fi;
         BSR_PSL_Details__c  bsrObj = (BSR_PSL_Details__c )TestFactory.createSObject(new BSR_PSL_Details__c (
            Loan_Application__c = loanAppl.Id,
            RecordTypeId = Schema.SObjectType.BSR_PSL_Details__c.getRecordTypeInfosByName().get('BSR').getRecordTypeId()
        ),true);
        insert new Document_Checklist__c(Loan_Application__c = loanId);
        insert new Notepad__c(Loan_Application__c = loanId);
        
        Id cmUserId = [ SELECT Approver__c FROM Loan_Application_Approval__c WHERE Loan_Application__c =: loanId AND Approval_Type__c =: GlobalConstants.APPROVAL_TYPE_CREDIT LIMIT 1 ].Approver__c;
        System.runAs( new User( Id = cmUserId )){
            AUSFApproverController.shareLoanApp( loanId, UserInfo.getUserId(), 'L2S4', 'Reassign', new Loan_Application_Approval__c( Remarks__c = 'please verify financial details' ) );
            Utility.getTeamMembersByRole(atms);
            Utility.canCreditUserEdit(loanAppl,cmUserId);
            Utility.archiveRBMApprovals(new Set<Id>{loanId});
            Utility.archiveDeviations(new List<Deviation__c>());
            Utility.assignApprovalsForRework(lstLoanAppApproval);
        }
        Test.stopTest();
    }
    @isTest 
    static void getApiCustomErrorTest() {
        Utility.getApiCustomError('IC-12345','List index out of bound','API Error',500,'Exception');
        Utility.getChargesMappedByScCode(new List<Charge__c>());
    }
    @isTest static void saveRecordsTest(){
        Test.startTest();
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Loan_Application__c loan =[SELECT id,Loan_Amount__c FROM Loan_Application__c WHERE Application_Number__c='AP-12345'];
        List<BSR_PSL_Details__c> bsrPslRecs = [SELECT Id from BSR_PSL_Details__c where Loan_Application__c =: loan.Id];
        Applicant_Financials_Details__c finance =[SELECT id,Type_Of_Employment__c FROM Applicant_Financials_Details__c WHERE Applicant__c=:appl.Id];
        Map<String,String> applMap = new Map<String,String>();
        applMap.put('Id',appl.Id);
        applMap.put('First_Name__c','Vikash');
        
        Map<String,String> loanMap = new Map<String,String>();
        loanMap.put('Id',loan.Id);
        loanMap.put('Customer_Name__c','Vikash');
        
        Map<String,String> financeMap = new Map<String,String>();
        financeMap.put('Id',finance.Id);
        financeMap.put('Type_Of_Employment__c','Salaried - Private');
        
        Map<String,String> bsrPslMap = new Map<String,String>();
        bsrPslMap.put('PSL_Code__c','AGFC0105');
        bsrPslMap.put('PSL_Classification_Type__c','PSL-Agri');
        bsrPslMap.put('Group__c','MANUFACTURING');
        bsrPslMap.put('Sub_Group__c','Food products');
        bsrPslMap.put('Land_Holding_in_acre__c','12');
        bsrPslMap.put('Investment_in_P_M__c','12');
        Loan_Application_Approval__c loanAppApproval2 = (Loan_Application_Approval__c)TestFactory.createSObject(
            new Loan_Application_Approval__c(
                Loan_Application__c  = loan.Id,
                Assigned_to_Queue__c = true,
                Approver__c = UserInfo.getUserId(),
                Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING, Archived__c = FALSE,
                Approver_Level__c = 'L3', Approval_Type__c = GlobalConstants.APPROVAL_TYPE_CREDIT, Type__c = 'Highest'
            ),true);
        Utility.shareBSRPSLRecords(bsrPslRecs,loan.Id);
        //System.assertEquals('Success', result,'test');
    }
    
    @isTest
    public static void testDocOwnerChange(){
        Map<Id,Id> applicantIds = new Map<Id,Id>();
        Map<Id,Id> collateralIds = new Map<Id,Id>();
        Map<Id,Id> LoanIds = new Map<Id,Id>();
        List<Document_Checklist__c> docs = [SELECT Id,Applicant__c,Applicant__r.Loan__r.OwnerId,Loan_Application__c,Loan_Application__r.OwnerId,Collateral__c,Collateral__r.Loan__r.OwnerId FROM Document_Checklist__c];
        for(Document_Checklist__c doc : docs){
            if(doc.Loan_Application__c != null){
                LoanIds.put(doc.Loan_Application__c,doc.Loan_Application__r.OwnerId);
            }else if(doc.Applicant__c != null){
                applicantIds.put(doc.Applicant__c,doc.Applicant__r.Loan__r.OwnerId);
            }else if(doc.Collateral__c != null){
                collateralIds.put(doc.Collateral__c,doc.Collateral__r.Loan__r.OwnerId);
            }
        }
        try{
            Test.startTest();
            Utility.changeDocumentChecklistOwner('Loan_Application__c',LoanIds);
            Utility.changeDocumentChecklistOwner('Applicant__c',applicantIds);
            Utility.changeDocumentChecklistOwner('Collateral__c',collateralIds);
            Test.stopTest();
        }Catch(Exception e){
            
        }
    }
    
    
    @isTest static void testCheckIfPaymentAlreadyReleased(){
        Test.startTest();
        List<Payment__c> paymentList = [Select id, Payment_Favouring_Status__c, Is_Payment_Triggered__c from Payment__c limit 1];
        List<string> paymentIdList = new List<string>{paymentList[0].iD};     
        Utility.checkIfPaymentAlreadyReleased(paymentIdList);
        Test.stopTest();
    }
    /*@isTest static void testNI(){
        Test.startTest();
        List<Applicant__c> indApplicant = [SELECT Id,Loan__c FROM Applicant__c Where Customer_Type__c = 'Individual']; 
        //Applicant Insertion
        Applicant__c niApp = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Test',
            Middle_Name__c = 'Test',
            Last_Name__c = 'Mandal',
            CIF_No__c = '224455',
            Customer_Type__c = 'Non Individual',
            Loan__c =indApplicant[0].Loan__c
        ),true);
        Applicant_Relation__c relation = new Applicant_Relation__c();
        relation.Ind_Applicant__c = indApplicant[0].Id;
        relation.NI_Applicant__c = niApp.Id;
        relation.Loan_Application__c = indApplicant[0].Loan__c;
        insert relation;
        Utility.getApplicantByNonInd(niApp.Id);
        Test.stopTest();
    }
    */
    
    @isTest static void verifyProductNameByCode(){  // NOPMD - false-positive - The method uses custom metadata records which can not be added in Test env.
        Test.startTest();
        Utility.getProductNameByCode( '10501' );
        Test.stopTest();
    }

    @isTest static void verifyPicklistValuesByProductAndCollateralType(){ // NOPMD - false-positive - The method uses custom metadata records which can not be added in Test env.
        Test.startTest();
        Utility.getPicklistValuesByProductAndCollateralType( '10501', 'Vehicle_Type__c', '10108' );
        Test.stopTest();
    }

    @isTest static void verifyPicklistLabels(){
        map<String, String> apiToLabels = Utility.getPicklistApiToLabel( 'Loan_Application__c', 'Collateral_Type__c' );

        Assert.isTrue( !apiToLabels.isEmpty(), 'Picklist api to labels should be returned' );
    }
    
    @isTest static void getLTVOfferedTractorTest(){
        Loan_Application__c objLoanApp = new Loan_Application__c();
        
        Collateral__c collateral = new Collateral__c();
        collateral.LTV_Record__c = '{"Agri_0_Land__c":"3"}';
        
        Test.startTest();
        Utility.getLTVOfferedBasedGradeTractorNew(collateral,objLoanApp);
        Utility.getLTVOfferedBasedGradeTractorUsed(collateral,objLoanApp);
        LTV_Master__c objLTVMaster = new LTV_Master__c();
        Utility.getLTVOfferedTractorNew('Agri',0.00,'',objLTVMaster);
        Utility.getLTVOfferedTractorNew('Agri',1,'',objLTVMaster);
        Utility.getLTVOfferedTractorNew('Agri',5,'',objLTVMaster);   
        Utility.getLTVOfferedTractorNew('Commercial',5,'FTU',objLTVMaster);   
        Utility.getLTVOfferedTractorNew('Commercial',5,'FTB',objLTVMaster);   
        Utility.getLTVOfferedTractorNew('Commercial',5,'Transporter',objLTVMaster);   
        Utility.getLTVOfferedTractorNew('Commercial',5,'Captive',objLTVMaster);    
        Depreciated_Grid__c objDep = new Depreciated_Grid__c();
        Utility.getLTVOfferedTractorUsed('Agri',0.00,'',objDep);
        Utility.getLTVOfferedTractorUsed('Agri',1,'',objDep);
        Utility.getLTVOfferedTractorUsed('Agri',5,'',objDep);   
        Utility.getLTVOfferedTractorUsed('Commercial',5,'FTU',objDep);   
        Utility.getLTVOfferedTractorUsed('Commercial',5,'FTB',objDep);   
        Utility.getLTVOfferedTractorUsed('Commercial',5,'Transporter',objDep);   
        Utility.getLTVOfferedTractorUsed('Commercial',5,'Captive',objDep);      
        Test.stopTest();
    }
    
    
    @isTest static void getLTVOfferedTest(){
        Loan_Application__c objLoanApp = new Loan_Application__c();
        
        Collateral__c collateral = new Collateral__c();
        collateral.Apportioned_Loan_Amount__c = 25000;
        collateral.Cost_to_be_Consider__c = '15000';
        collateral.Net_of_Discount_Price__c = 5000;
        collateral.Collateral_Name__c = '10501';
        Utility.getLTVOffered(collateral);
        collateral.Collateral_Name__c = '10132';
        Utility.getLTVOffered(collateral);
    }
    
    @isTest static void getLoanEligibilityBasedGradeTractorTest(){
        Loan_Application__c objLoanApp = new Loan_Application__c();
        
        Collateral__c collateral = new Collateral__c();
        collateral.Apportioned_Loan_Amount__c = 25000;
        collateral.Cost_to_be_Consider__c = '15000';
        collateral.Net_of_Discount_Price__c = 5000;
        collateral.Max_Funding_Cap__c = '5';
        collateral.Collateral_Name__c = '10501';
        Utility.getLoanEligibilityBasedGradeTractor(collateral,'70');
        collateral.Collateral_Name__c = '10132';
        Utility.getLoanEligibilityBasedGradeTractor(collateral,'70');
    }
    
    
    @isTest static void getLTVOfferedCommercialTest(){
        Id cvRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Commercial_Vehicle').getRecordTypeId();        
        Id ceRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Construction_Equipment').getRecordTypeId();        
 
        Loan_Application__c objLoanApp = new Loan_Application__c();
        objLoanApp.RecordTypeId = cvRecordTypeId;
        insert objLoanApp;
       
        Collateral__c collateral = new Collateral__c();
        collateral.Loan__c = objLoanApp.Id;
        collateral.LTV_Record__c = '{"CE_FTB__c":"3"}';
        
        
        Test.startTest();
        Utility.getLTVBasedGradeCommercialNew(collateral,objLoanApp);
        Utility.getLTVBasedGradeCommercialUsed(collateral,objLoanApp);
        
        objLoanApp.RecordTypeId = ceRecordTypeId;
        update objLoanApp;
        
        Utility.getLTVBasedGradeCommercialNew(collateral,objLoanApp);
        Utility.getLTVBasedGradeCommercialUsed(collateral,objLoanApp);
        
        LTV_Master__c objLTVMaster = new LTV_Master__c();
        Utility.getLTVCENew('CE','FTB','',objLTVMaster);
        Utility.getLTVCENew('LTVInPercent','FTB','',objLTVMaster);
        Utility.getLTVCENew('LTVInPercent','FTU','',objLTVMaster);
        Utility.getLTVCENew('LTVInPercent','Hirer','Small',objLTVMaster);
        Utility.getLTVCENew('LTVInPercent','Hirer','Medium',objLTVMaster);
        Utility.getLTVCENew('LTVInPercent','Hirer','Large',objLTVMaster);
        Utility.getLTVCENew('LTVInPercent','Mine Owner','Small-1',objLTVMaster);
        Utility.getLTVCENew('LTVInPercent','Mine Owner','Medium-2-5',objLTVMaster);
        Utility.getLTVCENew('LTVInPercent','Mine Owner','Large-6+',objLTVMaster);
        Utility.getLTVCENew('LTVInPercent','Contractor','Small-1',objLTVMaster);
        Utility.getLTVCENew('LTVInPercent','Contractor','Medium-2-5',objLTVMaster);
        Utility.getLTVCENew('LTVInPercent','Contractor','Large-6+',objLTVMaster);
        Utility.getLTVCENew('LTVInPercent','Captive','With financials',objLTVMaster);
        Utility.getLTVCENew('LTVInPercent','Captive','Without financials',objLTVMaster);
        
        Utility.getLTVCVNew('CE','FTB','',objLTVMaster);
        Utility.getLTVCVNew('LTVInPercent','FTB','',objLTVMaster);
        Utility.getLTVCVNew('LTVInPercent','FTU','',objLTVMaster);
        Utility.getLTVCVNew('LTVInPercent','Transporter','SFO',objLTVMaster);
        Utility.getLTVCVNew('LTVInPercent','Transporter','MFO',objLTVMaster);
        Utility.getLTVCVNew('LTVInPercent','Transporter','LFO',objLTVMaster);
        Utility.getLTVCVNew('LTVInPercent','Captive','With financials',objLTVMaster);
        Utility.getLTVCVNew('LTVInPercent','Captive','Without financials',objLTVMaster);
        
        Test.stopTest();
    }
    
    
    @isTest static void getVehicleUsageOptionsByProductTest(){
        Test.startTest();
        Utility.getVehicleUsageOptionsByProduct('10201');
        Test.stopTest();
    }


    
}