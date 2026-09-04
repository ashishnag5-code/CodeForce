@isTest
public with sharing class RoleHierarchyAndVisibilityTest {
   
    @TestSetup
    static void makeData(){
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Stage__c='QDE',
            Emi_Frequency__c = 'HALF YEARLY',
            EMI_Date__c = '10'
        ),true);
    }
    @isTest
    public static void getAccessibleProductsTest(){
        Map<Id, Loan_Application__c> loans = new Map<Id, Loan_Application__c>([SELECT Id, Product_Applicable_for__c FROM Loan_Application__c]);
        system.debug('loans '+loans);
        List<Id> loanIds = new List<Id>();
        loanIds.addAll(loans.keySet());

        Database.executeBatch(new RoleHierarchyAndVisibilityBatch(loanIds));
        system.assertEquals([SELECT Id, Product_Applicable_for__c FROM Loan_Application__c][0].Product_Applicable_For__c.contains('Main - View All'), true, 'Success');
    }
}