@isTest
public class ApprovalEditOverrideControllerTest {
    @testSetup static void setup() {
        Account branchMaster = (Account)TestFactory.createSObject(new Account(
            Name ='Branch M',
            Account_Code__c='21034',
            Purchase_City__c='Jaipur',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Branch').getRecordTypeId()
        ),true);
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
            Branch_Master__c = branchMaster.Id
        ),true);
    }
    static testmethod void testGetApplicationFromApproval(){
        try {
           ApprovalEditOverrideController.getApplicationFromApproval(null); 
        }catch(Exception exp){}
        String approvalId = [Select Id from Loan_Application__c].Id;
        try{
            ApprovalEditOverrideController.getApplicationFromApproval(approvalId);
        }catch(Exception exp){}
    }
}