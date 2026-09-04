@IsTest
public class OpsSummaryPageControllerTest {
    
    @testSetup
    static void testDataSetup() {
        Account accRecRegion = (Account)TestFactory.createSObject(new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Region').getRecordTypeId(),
            Name = 'Test Account region'
        ),true);
        
        Account accRecHub = (Account)TestFactory.createSObject(new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Hub').getRecordTypeId(),
            Name = 'Test Account hub',
            Region__c = accRecRegion.Id
        ),true);
        
        Account accRecBranch = (Account)TestFactory.createSObject(new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId(),
            Name = 'Test Account Branch',
            Business_HUB__c  = accRecHub.Id//'00G6s000001TiSyEAK'
        ),true);
        
        Account accRecDealer = (Account)TestFactory.createSObject(new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId(),
            Name = 'Test Account dealer'
            //Branch_Queue__c = groupId//'00G6s000001TiSyEAK'
        ),true);
        
         Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Ops_Verification__c = '{ "isSourcingVerified" : false, "isCaseSummaryVerified" : false, "isAssetDetailsVerified" : false}',
            Branch_Master__c = accRecBranch.Id,
            Repayment_Mode__c = 'NACH without PDC',
            Total_Charges__c = 100,
            Total_Loan_Amount__c = 10000,
            ROI__c = 4.2
        ),true);
        
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Father_Name__c = 'Dadda',
            Spouse_Name__c = 'Hubby',
            Mobile_Number__c = '9999999999',
            Aadhaar_Number__c = '9999999999',
            PAN__c = '9999999999',
            Loan__c =loanAppl.Id,
            RecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId()
        ),true);
        
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
            Apportioned_Loan_Amount__c = 10,
            Manufacture_year_month__c = '202303'
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
       
        Profile prof = [select Id,Name from profile where name like '%Credit%'];
        User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
                                                            lastName = 'test2',
                                                            profileId = prof.id,
                                                            username = 'test'+UserInfo.getOrganizationId()+'@test.com',
                                                            email = 'test@test.com',
                                                            Branch_Code__c  = '2103'
                                                           ),true);
        list<Loan_Application_Approval__c> lstLoanAppApproval = new List<Loan_Application_Approval__c>();
        Loan_Application_Approval__c applicationAppTest = (Loan_Application_Approval__c  )TestFactory.createSObject(new Loan_Application_Approval__c  (
            Loan_Application__c   = loanAppl.Id,
            Approver__c   = usr.Id,
            Approval_Status__c ='Pending',
            Approval_Type__c = 'Credit',
            Type__c = 'Highest',
            Is_Assigned_Approver__c = true),false);
        lstLoanAppApproval.add(applicationAppTest);
        insert lstLoanAppApproval;
        Payment__c p = new Payment__c(
        RecordTypeId =  Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Balance Transfer').getRecordTypeId() ,
        Loan_Application__c = loanAppl.Id ,
        BT_Type__c ='External');
        insert p;
    }
    
    @isTest
    public static void testGetOpsCategoryDetails() {
        String applicationId = [SELECT Id from Loan_Application__c LIMIT 1][0].Id;
        Test.startTest();
        SummaryPageWrapperController.OpsCaseCategory returnWrapper = OpsSummaryPageController.getOpsCategoryDetails(applicationId);
        OpsSummaryPageController.getOpsSourcingDetails(applicationId);
        Test.stopTest();
        System.assertEquals(returnWrapper!=null, true);
        
    }
    
    @isTest
    public static void testGetOpsAssetDetails() {
        String applicationId = [SELECT Id from Loan_Application__c LIMIT 1][0].Id;
        Test.startTest();
        SummaryPageWrapperController.OpsAssetDetails returnWrapper = OpsSummaryPageController.getOpsAssetDetails(applicationId);
        Test.stopTest();
        System.assertEquals(returnWrapper!=null, true);
        
    }
    
    @isTest
    public static void testGetAssignmentRecordLoanId() {
        String applicationId = [SELECT Id from Loan_Application__c LIMIT 1][0].Id;
        Assignment__c  assignmentRec = (Assignment__c)TestFactory.createSObject(new Assignment__c(
            Loan_Application__c  = applicationId,
            Name = 'Test Assignment'
        ),true);
        Test.startTest();
        String returnApplicationId = OpsSummaryPageController.getAssignmentRecordLoanId(assignmentRec.Id);
        Test.stopTest();
        System.assertEquals(returnApplicationId!=null, true);
        
    }
    
    @isTest
    public static void testRemainingMethods() {
        String applicationId = [SELECT Id from Loan_Application__c LIMIT 1][0].Id;
        Assignment__c  assignmentRec = (Assignment__c)TestFactory.createSObject(new Assignment__c(
            Loan_Application__c  = applicationId,
            Name = 'Test Assignment'
        ),true);
        Test.startTest();
        OpsSummaryPageController.verifyRecordSection('isCaseSummaryVerified',applicationId);
        OpsSummaryPageController.verifyRecordSection('isAssetDetailsVerified',applicationId);
        OpsSummaryPageController.setVerificationWrapper(applicationId);
        OpsSummaryPageController.setVerificationWrapper(assignmentRec.Id);
        Test.stopTest();
        
    }
  
    @IsTest
    public static void testGetValidRecordId(){
        String loanApplicationId = [SELECT Id FROM Loan_Application__c LIMIT 1].Id;
        Assignment__c  resultRec = (Assignment__c )TestFactory.createSObject(new Assignment__c (
            Loan_Application__c  = loanApplicationId
        ),true);
        Test.startTest();
        String validId = OpsSummaryPageController.getValidRecordId(resultRec.Id);
        Test.stopTest();
    }
    
}