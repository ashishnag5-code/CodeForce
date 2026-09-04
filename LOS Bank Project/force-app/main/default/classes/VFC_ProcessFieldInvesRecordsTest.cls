@IsTest
public class VFC_ProcessFieldInvesRecordsTest {
    
    @testSetup static void setup() { 
    	Loan_Application__c loanApp = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
               	Customer_Name__c = 'Test Customer', Stage__c = 'Pricing', Product__c = '10301', ROI__c = 12.4, Disbursed_Tranche__c = 5,
                RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId(),
                Total_Loan_Amount__c = 10000),true);
        
        Applicant__c applicant = (Applicant__c)TestFactory.createSObject(new Applicant__c(
                                Cibil_Report_Verified_by_Credit__c = false, First_Name__c = 'Test', Last_Name__c = 'User', Loan__c = loanApp.Id, 
                                isInactive__c = false, RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Guarantor').getRecordTypeId()),true);
    
        Field_Investigation__c fieldInvest1 = (Field_Investigation__c)TestFactory.createSObject(new Field_Investigation__c(
        		Applicant__c = applicant.Id, Loan_Application__c = loanApp.Id, Name = 'Test Field Investigation 1'),true);
        
        Field_Investigation__c fieldInvest2 = (Field_Investigation__c)TestFactory.createSObject(new Field_Investigation__c(
        		Applicant__c = applicant.Id, Loan_Application__c = loanApp.Id, Name = 'Test Field Investigation 2'),true);
        
        Field_Investigation__c fieldInvest3 = (Field_Investigation__c)TestFactory.createSObject(new Field_Investigation__c(
        		Applicant__c = applicant.Id, Loan_Application__c = loanApp.Id, Name = 'Test Field Investigation 3'),true);
    }
            
    @isTest
    static void testRedirectToLC() {
        // Create a StandardSetController with selected records
        List<Field_Investigation__c> selectedFieldInvestigations = [SELECT Id FROM Field_Investigation__c LIMIT 3];
        ApexPages.StandardSetController testStandardSetController = new ApexPages.StandardSetController(selectedFieldInvestigations);

        // Instantiate the VFC_ProcessFieldInvesRecords class
        VFC_ProcessFieldInvesRecords testController = new VFC_ProcessFieldInvesRecords(testStandardSetController);

        // Call the redirectToLC method
        Test.startTest();
        PageReference resultPage = testController.redirectToLC();
        Test.stopTest();
    }
}