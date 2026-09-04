@isTest
public class LeadAssignmentControllerTest {
 @testSetup static void setup() {
        Profile prof = [select Id,Name from profile where name like '%Credit%'];

		Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
         
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Stage__c ='DDE',
            Wheels_Exposure__c=500,
            Final_Exposure__c =1000
        ),true);
     
		System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]) {

        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
           	Account_Code__c='2103',
           	Branch_Queue__c=grp.Id
        ),true); 

        User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
        	lastName = 'test2',
        	profileId = prof.id,
        	username = 'test'+UserInfo.getOrganizationId()+'@test.com',
        	email = 'test@test.com',
        	Branch_Code__c  = '2103'
    	),true);
    	AccountTeamMember atm = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
        	AccountId =accInstance.Id,
        	UserId=usr.Id,
        	TeamMemberRole = 'Branch Manager'
       	),true);                                                                                                                        
      }
    }
      @isTest 
    static void getLeadNumberTest(){
        List<Loan_Application__c> loanApp = [SELECT Id,Product__c from Loan_Application__c];
        LeadAssignmentController.getLeadNumber(loanApp[0].Id);
    }
       @isTest 
    static void getLeadDetailsTest(){
        List<Loan_Application__c> loanApp = [SELECT Id,Product__c from Loan_Application__c];
        List<String> idList = new List<String>();
        idList.add(loanApp[0].Id);
     	LeadAssignmentController.getLeadDetails(idList);
    }
    @isTest 
    static void changeLeadOwnerTest(){
        List<Loan_Application__c> loanApp = [SELECT Id,Product__c from Loan_Application__c];
        List<String> idList = new List<String>();
        idList.add(loanApp[0].Id);
        user useRecord = [Select id from User LIMIT 1];
        List<Account> atmRec = [SELECT Id from Account];
        LeadAssignmentController.changeLeadOwner(idList,useRecord.Id,atmRec[0].Id);
    }
      @isTest 
    static void searchLeadRecordTest(){
        List<Loan_Application__c> loanApp = [SELECT Id,Product__c from Loan_Application__c];
        List<String> idList = new List<String>();
        idList.add(loanApp[0].Id);
        List<Account> atmRec = [SELECT Id from Account];
        LeadAssignmentController.searchLeadRecord(idList,atmRec[0].Id);
    }
     @isTest 
    static void searchLeadRecordNULLTest(){
        List<String> accIdList = new List<String>();
        List<Account> atmRec = [SELECT Id from Account]; 
        accIdList.add(atmRec[0].Id);
        LeadAssignmentController.searchLeadRecord(accIdList,atmRec[0].Id);
    }
    @isTest 
    static void getLeadDetailsTestNegative(){
        List<Loan_Application__c> loanApp = [SELECT Id,Product__c from Loan_Application__c];
        List<String> idList = new List<String>();
        idList.add(loanApp[0].Id);
     	LeadAssignmentController.getLeadDetails(null);
    }

    @isTest static void verifyLeadAssignmentToTCUqueue(){
        Id loanId = [ SELECT id FROM Loan_Application__c  LIMIT 1 ].Id;
        map<String, Object> result = LeadAssignmentController.getLeadNumber( loanId );
        Id tcuQueueId = (Id)result.get('tcuQueueId');

        Test.startTest();
        map<String, Object> response = LeadAssignmentController.assignLeadsToTcu( new Loan_Application__c[]{ new Loan_Application__c( Id = loanId, OwnerId = tcuQueueId )} );
        Test.stopTest();

        Assert.isTrue( (Boolean)response.get('isSuccess'), 'Lead should get successfully assigned to TCU Queue' );
    }

    @isTest static void verifyLeadAssignmentToTCUqueueFailure(){
        Id loanId = [ SELECT id FROM Loan_Application__c  LIMIT 1 ].Id;

        Test.startTest();
        map<String, Object> response = LeadAssignmentController.assignLeadsToTcu( new Loan_Application__c[]{ new Loan_Application__c( Id = loanId, OwnerId = null )} );
        Test.stopTest();

        Assert.isTrue( ((Object[])response.get('errors')).size() > 0, 'Errors should be returned since Queue Id was not provided' );
    }
    
}