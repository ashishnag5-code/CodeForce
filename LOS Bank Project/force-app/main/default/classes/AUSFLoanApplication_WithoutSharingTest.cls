@isTest
public with sharing class AUSFLoanApplication_WithoutSharingTest {
    @TestSetup
    static void makeData(){
        TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='Credit',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10
        ), true);
    }
    @isTest static void verifyLoanApplicationUpdates(){
        Test.startTest();
        Loan_Application__c[] applications = [ SELECT Id, Application_Number__c FROM Loan_Application__c LIMIT 1 ];
        applications[0].Application_Number__c = 'AP-45678';

        Loan_Application__c[] updatedApplications = AUSFLoanApplication_WithoutSharing.updateLoanApp( applications );
        Test.stopTest();

        Assert.areEqual(
            'AP-45678',
            updatedApplications[0].Application_Number__c,
            'Application Number should be updated'
        );
    }
    @isTest static void verifyApprovalUnlocking(){
        Test.startTest();
        AUSFLoanApplication_WithoutSharing.unlockApprovals([ SELECT Id FROM Loan_Application_Approval__c ]);
        Test.stopTest();
    }
    
    @isTest static void testGetRecords(){
        Test.startTest();
        DateTime thirtyDaysAgo = DateTime.now();
        String query = 'SELECT Id, Stage__c  FROM Loan_Application__c WHERE Stage__c != \'Rejected\'';
        List<SObject> records = AUSFLoanApplication_WithoutSharing.getRecords(query);
        Test.stopTest();
    }
    
    @isTest static void testupdateSObjectRecs(){
        Test.startTest();
        DateTime thirtyDaysAgo = DateTime.now();
        String query = 'SELECT Id, Stage__c  FROM Loan_Application__c WHERE Stage__c != \'Rejected\'';
        List<SObject> records = AUSFLoanApplication_WithoutSharing.getRecords(query);
        records = AUSFLoanApplication_WithoutSharing.updateSObjectRecs(records);
        Test.stopTest();
    }
}