@isTest
public class AccountTeamMemberTriggerTest {
  @testSetup static void setup() {
        Profile prof = [select Id,Name from profile where name like '%Credit%'];

		Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
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
        	TeamMemberRole = 'Account Manager'
       	),true);                                                                                                                        
      }
   }
    @IsTest
    public static void updateAccountTeamMenberTest(){
        AccountTeamMember atm = [SELECT Id,Employee_Name__c  from AccountTeamMember];
        atm.Employee_Name__c = 'Test';
        update atm;
    }    
     @IsTest
    public static void deleteAccountTeamMenberTest(){
        AccountTeamMember atm = [SELECT Id,Employee_Name__c  from AccountTeamMember];
      	Test.startTest();
        	delete atm;
        Test.stopTest();
    }  
        @IsTest
    static void BeforeInsertTest() {
   
        AccountTeamMemberTriggerService service = new AccountTeamMemberTriggerService();
        List<AccountTeamMember> newRecordList = new List<AccountTeamMember>();
      
        Test.startTest();
        service.beforeInsert(newRecordList);
        Test.stopTest();
       
    }
          @IsTest
    static void afterUndeleteTest() {
   
        AccountTeamMemberTriggerService service = new AccountTeamMemberTriggerService();
       	Map<Id, AccountTeamMember> newRecordMap = new Map<Id, AccountTeamMember>();
        Test.startTest();
        service.afterUndelete(newRecordMap);
        Test.stopTest();
       
    }
}