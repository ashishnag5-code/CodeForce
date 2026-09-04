@isTest
public class ShareContentDocumentWithoutSharingTest {
    
	@testSetup static void setup() {  
        // Test data setup
    	Loan_Application__c loanApp = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                    Application_Number__c  = 'AP-12345', Adhar_Card__c = 123456, Name='Test',
                    Loan_Amount__c  = 1000, Product__c='10301', Customer_Type__c='Individual',
                    Stage__c ='DDE', EMI_Date__c = '10/3/2022'),true);
    	//ContentVersion contentVersion = (ContentVersion)TestFactory.createSObject(new ContentVersion(
        //    Title = 'TestMaster.pdf', Loan_Application__c = loanApp.Name),true);

             ContentVersion contentVersionObj = (ContentVersion)TestFactory.createSObject(new ContentVersion(VersionData = Blob.valueOf('Test Data'),Title = 'PDTelePD Questionare',ContentLocation= 's',
                                                                                                     PathOnClient='testCases.txt',Loan_Application__c = loanApp.Id,
                                                                                                     FirstPublishLocationId = loanApp.Id), true);
    }

    /*
    @isTest
    public static void testGetLatestEmiSchedule() {
        
        Loan_Application__c loanApp = [Select Id,Name from Loan_Application__c LIMIT 1];

        ContentVersion contentVersion = [Select Id from ContentVersion LIMIT 1];

        Test.startTest();
        ContentVersion result = ShareContentDocumentWithoutSharing.getLatestEmiSchedule(loanApp, 'TestMaster');
        Test.stopTest();

        // Perform assertions
        //System.assertEquals(contentVersion.Id, result.Id);
    }
    */
}