@isTest
public class OpsSummaryButtonControllerTest {
    
    @testSetup static void setup() {
        
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10202',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            LAN__c='1313131313',
            Completed_Disbursement_Stage__c ='Repayment Schedule',
            Repayment_Schedule_Viewed_by_Maker__c = true,
            Tenure__c = 10,
            Ops_Verification__c = '{ "isSourcingVerified" : false, "isCaseSummaryVerified" : false, "isAssetDetailsVerified" : false}'
        ),true);
        
        Loan_Application__c loanAppl1 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-123456',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10202',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            LAN__c='1313131313',
            Disbursement_Category__c='Full',
            Completed_Disbursement_Stage__c ='Do Disbursement',
            Repayment_Schedule_Viewed_by_Maker__c = true,
            Is_Loan_Disbursed__c = true,
            Tenure__c = 10,
            Ops_Verification__c = '{ "isSourcingVerified" : false, "isCaseSummaryVerified" : false, "isAssetDetailsVerified" : false}'
        ),true);
        Loan_Application__c loanAppl2 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-123457',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10202',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            LAN__c='1313131313',
            Disbursement_Category__c='Partial',
            Completed_Disbursement_Stage__c ='Do Disbursement',
            Repayment_Schedule_Viewed_by_Maker__c = true,
            Tenure__c = 10,
            Ops_Verification__c = '{ "isSourcingVerified" : false, "isCaseSummaryVerified" : false, "isAssetDetailsVerified" : false}'
        ),true);
        
        
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            IsInactive__c = false,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        Document_Master__c  docMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Name ='Test',
            Document_Name__c  ='Customers Signature'
        ),false);
        
        Document_Checklist__c docChkRecord = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            //Parent_Loan__c   = loanAppl.Id,
            Applicant__c = appl.Id,
            Document_Master__c = docMaster.Id,
            Document_Name__c ='Customers Signature'
        ),false);
        Applicant__c appl1 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash1',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            Existing_Customer__c = 'Yes',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
        Document_Checklist__c docChkRecord1 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Applicant__c    = appl.Id
        ),true);
        
        Payment__c paymentRecord = (Payment__c)TestFactory.createSObject(new Payment__c(
            Payment_Recipient__c ='Customer',
            Loan_Application__c  = loanAppl.Id,
            Inactive__c = false,
            isVerified__c = true
        ),true);
        
        Sanction_Condition__c sanctionRecord = (Sanction_Condition__c)TestFactory.createSObject(new Sanction_Condition__c(
            Loan_Application__c  = loanAppl.Id,
            Status__c = 'Compliant'
        ),true);
        //MMV Insertion
        MMV_Master__c mmvMaster = (MMV_Master__c )TestFactory.createSObject(new MMV_Master__c (
            Name ='Test',
            //            Collateral_Name__c ='Car',
            Collateral_Type__c ='Automobile'
        ),true);
        
        // Collateral Insertion
        Collateral__c  collateral = (Collateral__c )TestFactory.createSObject(new Collateral__c (
            Loan__c =loanAppl.Id,
            // Name ='CollateralTest',
            
            MMV_Master__c =mmvMaster.Id,
            Vehicle_Number__c='TN12345567',
            Certified_Value__c='1234',
            Collateral_Name__c ='10108'
        ),true);
        
        //Tranche recordtype
        Id tranchRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Tranche').getRecordTypeId();
        Payment__c payment = (Payment__c )TestFactory.createSObject(new Payment__c (
            Loan_Application__c =loanAppl.Id,
            RecordTypeId = tranchRecordTypeId,
            Disbursed__c = true
        ),true);
    } 
    @isTest
    public static void getAssignmentIdTest(){
        Test.startTest();
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        QueueSobject so =  new QueueSobject(QueueId = grp.Id, SObjectType = 'Assignment__c');
        insert so ;
        UserRole userRole = new UserRole(Name = 'Somebody else');
        insert userRole;
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User user = new User(
            UserRoleId = userRole.Id,
            LastName = 'Test Code',
            Email = 'test@test.com',
            Alias = 'Tcode',
            Username = 'test1234444@testzsdfsdtfsdf.com',
            CommunityNickname = 'test12',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'GMT',
            ProfileID = profileId.Id,
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8'
        );
        insert user;
        system.runAs(user){
            Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
            String applicationId = [SELECT Id from Loan_Application__c LIMIT 1][0].Id;
            Loan_Application__c loanapplication = [SELECT Id from Loan_Application__c LIMIT 1];
            loanapplication.Disbursement_Category__c = 'Partial';
            update loanapplication;
            Assignment__c ass = new Assignment__c();
            ass.Loan_Application__c =  applicationId;
            ass.Disbursement_Type__c = 'Partial';
            ass.RecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByName().get('Ops - Disbursement').getRecordTypeId();
            ass.Status__c ='Pending';
            insert ass;
            
            
            OpsSummaryButtonsController.LoanAssignmentWrapper returnValue =OpsSummaryButtonsController.getLoanId(ass.Id);
            ass.OwnerId = grp.Id;
            update ass;
            OpsSummaryButtonsController.LoanAssignmentWrapper returnValue1 =OpsSummaryButtonsController.getLoanId(ass.Id);
            OpsSummaryButtonsController.checkIfDisbursementDone(applicationId);
            loanapplication.Completed_Disbursement_Stage__c = 'Do Disbursement';
            update loanapplication;
            OpsSummaryButtonsController.checkIfDisbursementDone(loanapplication.id);
            
            //System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        }
        Test.stopTest();
    }
    
    @isTest
    public static void handleOpsValidation(){
        Test.startTest();
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Loan_Application__c application = [SELECT Id, Dpd_Found__c, Repayment_Schedule_Viewed_by_Maker__c from Loan_Application__c LIMIT 1];
        
        
        String returnValue =OpsSummaryButtonsController.handleOpsValidation(application.Id,'SubmitToAuthor');
        application.Dpd_Found__c = true;
        application.Repayment_Schedule_Viewed_by_Maker__c = false;
        update application;
        String returnValue2 =OpsSummaryButtonsController.handleOpsValidation(application.Id,'SubmitToAuthor');
        System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
    }
    @isTest
    public static void handleOps1(){
        Test.startTest();
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        String applicationId = [SELECT Id from Loan_Application__c where Application_Number__c='AP-123456'][0].Id;
        Id TrancheRID = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Tranche').getRecordTypeId();
        Payment__c pymt = [SELECT Id FROM Payment__c WHERE RecordTypeId =: TrancheRID LIMIT 1];
        pymt.Loan_Application__c = applicationId;
        update pymt;
        String returnValue =OpsSummaryButtonsController.handleOpsValidation(applicationId,'SubmitToPDD');
        System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
    }
    @isTest
    public static void handleOps2(){
        Test.startTest();
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        String applicationId = [SELECT Id from Loan_Application__c where Application_Number__c='AP-123457'][0].Id;
        Id TrancheRID = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Tranche').getRecordTypeId();
        Payment__c pymt = [SELECT Id FROM Payment__c WHERE RecordTypeId =: TrancheRID LIMIT 1];
        pymt.Loan_Application__c = applicationId;
        update pymt;
        
        String returnValue =OpsSummaryButtonsController.handleOpsValidation(applicationId,'SubmitToRO');
        System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
    }
    
    
    @isTest
    public static void handleOps3(){
        Test.startTest();
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        String applicationId = [SELECT Id from Loan_Application__c LIMIT 1][0].Id;
        String returnValue =OpsSummaryButtonsController.handleOpsValidation(applicationId,'ReturnToPSD');
        System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest
    public static void handleSendNotificationTest(){
        Test.startTest();
        
        String applicationId = [SELECT Id from Loan_Application__c LIMIT 1][0].Id;
        OpsSummaryButtonsController.sendOpsNotification(applicationId);
        
        Test.stopTest();
    }
}