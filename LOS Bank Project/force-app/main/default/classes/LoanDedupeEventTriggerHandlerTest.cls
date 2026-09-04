@isTest
public with sharing class LoanDedupeEventTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Follow_Up_Date__c = System.today(),
            Follow_Up_Time__c = Time.newInstance(1, 2, 3, 4),
            RecordTypeId = Utility.getRecordTypeId( SObjectType.Loan_Application__c.getSObjectType(), GlobalConstants.FOURWHEELER ),
            Mobile__c = '98749837493',
            Product__c = '10201'
        ), true );
        
        // Duplicate loans
        TestFactory.createSObject(new Loan_Application__c(
            Follow_Up_Date__c = System.today(),
            Follow_Up_Time__c = Time.newInstance(1, 2, 3, 4),
            RecordTypeId = Utility.getRecordTypeId( SObjectType.Loan_Application__c.getSObjectType(), GlobalConstants.FOURWHEELER ),
            Mobile__c = '98749837493',
            Product__c = '10201'
        ), true );

        Loan_Application__c duplicateLead = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Follow_Up_Date__c = System.today(),
            Follow_Up_Time__c = Time.newInstance(1, 2, 3, 4),
            RecordTypeId = Utility.getRecordTypeId( SObjectType.Loan_Application__c.getSObjectType(), GlobalConstants.FOURWHEELER ),
            Product__c = '10201'
        ), true );

        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Mobile_Number__c = '98749837493',
            Loan__c = duplicateLead.Id,
            Customer_Type__c = 'Non Individual',
            Constitution_Type__c = 'Sole Proprietary'
            
        ),true);
    }

    @isTest static void verifyLoanDedupePEInt(){ //NOPMD

        Id loanId = [ SELECT Id FROM Loan_Application__c WHERE Mobile__c != NULL LIMIT 1 ].Id;
        Test.startTest();
        
        EventBus.publish(
            new Loan_Dedupe__e(
                Record_Id__c = loanId,
                Type__c = 'Mobile'
            )
        );      
        Test.stopTest();

        Assert.isTrue([ SELECT Is_Duplicate__c FROM Loan_Application__c WHERE Id =: loanId LIMIT 1 ].Is_Duplicate__c, 'Lead should have been marked as duplicate' );
    }
}