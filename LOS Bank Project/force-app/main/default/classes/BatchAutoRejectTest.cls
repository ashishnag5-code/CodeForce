@isTest
public class BatchAutoRejectTest {
    @testSetup static void setup() {
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10301',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Disbursement_Date__c = System.today()-60
        ),true);
    }
    
     @isTest static void batchclass() {
        Loan_Application__c loan =[SELECT id,Application_Number__c from Loan_Application__c WHERE Application_Number__c='AP-12345'];
        Test.startTest();
        BatchAutoReject ba= new BatchAutoReject();
        Id jobid= Database.executeBatch(ba,5);
        Test.stopTest();
    }
    
    @isTest
     static  void testschedule() {
		Test.StartTest();
        BatchAutoRejectSchedule testsche = new BatchAutoRejectSchedule();
		String cronExpression = '0 0 0 * * ?'; // Daily at midnight
		system.schedule('Test status Check', cronExpression, testsche );
       	
		Test.stopTest();
	}

}