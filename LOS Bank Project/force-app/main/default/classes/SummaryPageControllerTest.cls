@IsTest
public class SummaryPageControllerTest {
    @testsetup
    static void testDataSetup() {
        Account accInstance = (Account)TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103'
        ),true);

        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c = '10201',
            ROI__c = 17.0,
            EMI__c = 13,
            RBP__c = 10,
            Branch_Master__c = accInstance.Id
        ),false);
        
        Loan_Application__c loanApp2 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c = '10201',
            ROI__c = 17.0,
            EMI__c = 13,
            Branch_Master__c = accInstance.Id,
            Valuation_Completion_Date__c = Date.today() - 1,
            RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId()
        ),false);
        insert new List<Loan_Application__c>{loanAppl, loanApp2};

        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Mobile_Number__c = '9999999999',
            Aadhaar_Number__c = '9999999999',
            PAN__c = '9999999999',
            Loan__c =loanAppl.Id,
            RecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId()
        ),false);

         Applicant__c appl2 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Mobile_Number__c = '9999999999',
            Aadhaar_Number__c = '9999999999',
            PAN__c = '9999999999',
            Loan__c =loanApp2.Id,
            RecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId()
        ),false);

        insert new List<Applicant__c> {appl, appl2};
        
        Collateral__c testCollateralRec = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId(),
            Loan__c = loanAppl.Id,
            Collateral_Type__c = 'Existing ',
            Registration_Number__c = '123456Test',
            Ex_Showroom_Price__c = 100,
            Discount__c = 10,
            Net_of_Discount_Price__c = 10,
            Final_Cost__c = 10,
            LTV_offered_On_final_cost__c = 10,
            Apportioned_Loan_Amount__c = 10
        ),true);
        
        Address__c testAddressRec = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c = 'test address1',
            Address_Line_2__c = 'test address2',
            Address_Line_3__c = 'Existing ',
            State__c = '123456Test',
            City__c = 'testcity',
            Pincode__c = 'testPincode',
            Applicant__c = appl.Id,
            Address_Type__c = 'Current'
            
        ),true);
        
        Bureau_Results__c  resultRec = (Bureau_Results__c )TestFactory.createSObject(new Bureau_Results__c (
            Applicant__c  = appl.Id,
            Bureau_Score__c  = 100
            
        ),true);
        
        Loan_Application_Approval__c applicationAppTest = (Loan_Application_Approval__c  )TestFactory.createSObject(new Loan_Application_Approval__c  (
            Loan_Application__c   = loanAppl.Id,
            Approver__c   = UserInfo.getUserId(),
            Approval_Type__c = 'Credit',
            Approver_Level__c  = 'L0',
            Type__c = 'Highest'
            
        ),false);

        Loan_Application_Approval__c applicationAppTest2 = (Loan_Application_Approval__c  )TestFactory.createSObject(new Loan_Application_Approval__c  (
            Loan_Application__c   = loanApp2.Id,
            Approver__c   = UserInfo.getUserId(),
            Approval_Type__c = 'Pricing',
            Approver_Level__c  = 'L0',
            Type__c = 'Highest'
            
        ),false);
        insert new List<Loan_Application_Approval__c> {applicationAppTest, applicationAppTest2};

        Document_Master__c docMasterRecord1 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
           Document_Name__c = 'Voter ID Card'
        ),true);
        
        Document_Checklist__c docCheckRecord1 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
           Document_Master__c = docMasterRecord1.Id,
           Applicant__c = appl.Id, Document_Number__c = 'lalala'
        ),true);
    }
    
    @IsTest
    public static void testGetApplicationDetails() {
        List<Loan_Application__c> lst = [SELECT Id from Loan_Application__c];
        Test.startTest();
        SummaryPageWrapperController.ApplicationDetailWrapper returnWrapper = SummaryPageController.getApplicationDetails(lst[0].Id);
        returnWrapper = SummaryPageController.getApplicationDetails(lst[1].Id);
        Test.stopTest();
        System.assertEquals(returnWrapper!=null, true);
    }
    
    @IsTest
    public static void testGetApplicantDetails() {
        Test.startTest();
        Loan_Application__c application = [SELECT Id, Branch_Master__c, OwnerId from Loan_Application__c LIMIT 1];
        DateTime dt = Datetime.now();
        String currentMonth = dt.format('MMM');
        String lastMonth = dt.addMonths(-1).format('MMM');
        WIRR__c wirrRec = new WIRR__c(User__c = application.OwnerId, Month__c = currentMonth, Branch__c = application.Branch_Master__c);
        insert wirrRec;
        
        List<SummaryPageWrapperController.ApplicantDetailWrapper> returnWrapper = SummaryPageController.getApplicantDetails(application.Id);
        SummaryPageController.getPricingDetails(application.Id);
        SummaryPageController.getPricingDetails(null);
        Test.stopTest();
        System.assertEquals(returnWrapper!=null, true);
    }

    @IsTest
    public static void testGetApplicantDetailsW1() {
        Test.startTest();
        Loan_Application__c application = [SELECT Id, Branch_Master__c, OwnerId from Loan_Application__c LIMIT 1];
        DateTime dt = Datetime.now();
        String currentMonth = dt.format('MMM');
        String lastMonth = dt.addMonths(-1).format('MMM');
        WIRR__c wirrRecLM = new WIRR__c(User__c = application.OwnerId, Month__c = lastMonth, Branch__c = application.Branch_Master__c);
        insert wirrRecLM;
        
        List<SummaryPageWrapperController.ApplicantDetailWrapper> returnWrapper = SummaryPageController.getApplicantDetails(application.Id);
        SummaryPageController.getPricingDetails(application.Id);
        SummaryPageController.getPricingDetails(null);
        Test.stopTest();
        System.assertEquals(returnWrapper!=null, true);
    }

    @IsTest
    public static void testGetApplicantDetailsW2() {
        Test.startTest();
        Loan_Application__c application = [SELECT Id, Branch_Master__c, OwnerId from Loan_Application__c LIMIT 1];
        DateTime dt = Datetime.now();
        String currentMonth = dt.format('MMM');
        String lastMonth = dt.addMonths(-1).format('MMM');
        WIRR__c wirrRecUser = new WIRR__c(User__c = application.OwnerId, Month__c = currentMonth);
        insert wirrRecUser;
        
        List<SummaryPageWrapperController.ApplicantDetailWrapper> returnWrapper = SummaryPageController.getApplicantDetails(application.Id);
        SummaryPageController.getPricingDetails(application.Id);
        SummaryPageController.getPricingDetails(null);
        Test.stopTest();
        System.assertEquals(returnWrapper!=null, true);
    }

    @IsTest
    public static void testGetApplicantDetailsW3() {
        Test.startTest();
        Loan_Application__c application = [SELECT Id, Branch_Master__c, OwnerId from Loan_Application__c LIMIT 1];
        DateTime dt = Datetime.now();
        String currentMonth = dt.format('MMM');
        String lastMonth = dt.addMonths(-1).format('MMM');
        WIRR__c wirrRecLMUser = new WIRR__c(User__c = application.OwnerId, Month__c = lastMonth);
        insert wirrRecLMUser;
        
        List<SummaryPageWrapperController.ApplicantDetailWrapper> returnWrapper = SummaryPageController.getApplicantDetails(application.Id);
        SummaryPageController.getPricingDetails(application.Id);
        SummaryPageController.getPricingDetails(null);
        Test.stopTest();
        System.assertEquals(returnWrapper!=null, true);
    }
    
    @IsTest
    public static void testGetApprovalDetails() {
        List<Loan_Application__c> lst = [SELECT Id from Loan_Application__c];
        Test.startTest();
        SummaryPageWrapperController.ApprovalDetailWrapper returnWrapper = SummaryPageController.getApprovalDetails(lst[0].Id);
        returnWrapper = SummaryPageController.getApprovalDetails(lst[1].Id);
        Test.stopTest();
        System.assertEquals(returnWrapper!=null, true);
    }
    
    @IsTest
    public static void testGetVisibleFields() {
        Test.startTest();
        List<String> returnWrapper = SummaryPageController.getVisibleFields('Summary Page Applicant','DDE','');
        Test.stopTest();
        System.assertEquals(returnWrapper!=null, true);
    }
    @IsTest
    public static void testsetAddress() {
        Address__c addr = [SELECT Id, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, City__c, State__c, Pincode__c FROM Address__c LIMIT 1];
        Test.startTest();
        STring addressVal = SummaryPageController.setAddress(addr);
        Test.stopTest();
        
    }
    
    @IsTest
    public static void testsetModeOfPaymentValue() {
        Test.startTest();
        STring test1 = SummaryPageController.setModeOfPaymentValue('Test');
        STring test2 = SummaryPageController.setModeOfPaymentValue('TA Dealer');
        Test.stopTest();
        
    }

}