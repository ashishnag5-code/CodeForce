@isTest
public class lwcpdfReaderWithSaveControllerTest {
    @testSetup static void setup() {
        Profile prof = [select Id,Name from profile where name like '%Credit%'];

		Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
         
        Loan_Application__c  loanInstance = (Loan_Application__c  )TestFactory.createSObject(new Loan_Application__c  (
            Name ='TestLoan'
        ),true); 
            
            


        User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
        	lastName = 'test2',
        	profileId = prof.id,
        	username = 'test'+UserInfo.getOrganizationId()+'@test.com',
        	email = 'test@test.com',
        	Branch_Code__c  = '2103'
    	),true);
                                                                                                                          
      }
    


    @isTest 
    static void getAccountTeamMemberTest() {
        Test.startTest();
        Loan_Application__c loanassigns = [SELECT Id from Loan_Application__c];
        lwcpdfReaderWithSaveController.getSaveNameFromRecordField(loanassigns.Id,'Name');
        Test.stopTest();
    }
    @isTest 
    static void getAccountTeamMemberTest2() {
        Test.startTest();
        Loan_Application__c loanassigns = [SELECT Id from Loan_Application__c];
        lwcpdfReaderWithSaveController.fetchVFPDFOutput('/apex/LoanAgreementDocument');
        lwcpdfReaderWithSaveController.saveToSalesforce('Test',loanassigns.Id, 'Test123');        
        Test.stopTest();
    }
    
}