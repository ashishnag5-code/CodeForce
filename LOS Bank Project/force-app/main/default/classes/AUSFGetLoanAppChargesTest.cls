@isTest
public class AUSFGetLoanAppChargesTest {
   @testSetup static void setup() {
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10
        ),true);
   }
     @IsTest
    static void testConstructor() {
        Loan_Application__c loanApp = [SELECT Id from Loan_Application__c];
           Test.startTest();
        AUSFGetLoanAppCharges ausfGetLoanAppCharges = new AUSFGetLoanAppCharges();
        ausfGetLoanAppCharges.loanApplId = loanApp.Id;
        Test.stopTest();
    }
}