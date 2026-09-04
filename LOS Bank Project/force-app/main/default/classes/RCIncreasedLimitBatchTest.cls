@isTest
public class RCIncreasedLimitBatchTest {
    @testSetup static void setup() {
        Account dealerMaster = (Account)TestFactory.createSObject(new Account(
        Name ='TestAccount',
        Account_Code__c='2103',
        RC_Limit_Increased__c=true,
            RC_Limit_Amount__c = 10000,
            RC_Limit_Count__c = 2000,
            RC_Limit_Used_Amount__c=1000,
            Ad_Hoc_Limit_Amount__c = 9000,
            Ad_Hoc_Limit_Used_Amount__c = 10,
            RC_Limit_Used_Count__c=1,
            Ad_Hoc_Limit_Count__c=10,
            Ad_Hoc_Limit_Used_Count__c=1,
            Ad_Hoc_Date__c = System.today()+30,
        Purchase_City__c='Jaipur'),true);
        
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
            RC_Limit_On_Hold__c= true,
            Total_Loan_Amount__c=10,
            Dealer_Master__c = dealerMaster.Id
        ),true);
    }
    testmethod static void testRCIncreasedLimitBatchNoId(){
        String accId = [Select Id from Account limit 1].Id;
        Test.startTest();
        Database.executeBatch(new RCIncreasedLimitBatch());
        Test.stopTest();
    }
    testmethod static void testRCIncreasedLimitBatchWithId(){
        String accId = [Select Id from Account limit 1].Id;
        Test.startTest();
        Database.executeBatch(new RCIncreasedLimitBatch(new Set<String>{accId}));
        Test.stopTest();
    }
    testmethod static void testRCIncreasedLimitBatchWithIdElse(){
        Account acc = [Select Id from Account limit 1];
        Loan_Application__c loanAppl = [Select Id,Total_Loan_Amount__c from Loan_Application__c];
        loanAppl.Total_Loan_Amount__c = 17000;
        update loanAppl;
        Test.startTest();
        Database.executeBatch(new RCIncreasedLimitBatch(new Set<String>{acc.Id}));
        Test.stopTest();
    }
}