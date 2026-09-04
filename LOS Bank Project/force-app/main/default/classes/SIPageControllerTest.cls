@isTest
public class SIPageControllerTest {
	@testSetup static void setup() {
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Repayment_Account_Number__c = '123456789045678',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10',
            Tenure__c = 10,
            First_EMI_Date__c = system.today()
        ),true);
        
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321',
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
    }

    @isTest
    public static void getLADetailsTest(){
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];

        PageReference pageRef = Page.RepaymentSIVFPage;
        pageRef.getParameters().put('recordid', String.valueOf(loanObj.Id));
        Test.setCurrentPage(pageRef);
        SIPageController testAccPlan = new SIPageController();
        testAccPlan.getLADetails();
        
    }
}