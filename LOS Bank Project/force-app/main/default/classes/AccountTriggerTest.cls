@isTest
public class AccountTriggerTest {

    @testSetup static void setup() {
        Profile prof = [select Id,Name from profile where name like '%Credit%'];

		Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
         
		System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]) {
    	Id branchRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();

        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
           	Account_Code__c='2103',
            RecordTypeId=branchRecordTypeId,
           	Branch_Queue__c=grp.Id,
            RC_Limit_Amount__c = 1000
        ),true); 
        
        accInstance.RC_Limit_Amount__c = 2000;
        accInstance.Account_Code__c='3201';
        update accInstance;

        User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
        	lastName = 'test2',
        	profileId = prof.id,
        	username = 'test'+UserInfo.getOrganizationId()+'@test.com',
        	email = 'test@test.com',
            Product_Accessible__c='All 2W'	,                                              
        	Branch_Code__c  = '2103'
    	),true);
    	AccountTeamMember atm = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
        	AccountId =accInstance.Id,
        	UserId=usr.Id,
        	TeamMemberRole = 'Account Manager'
       	),true);                                                                                                                        
      }
    }
    @isTest 
    static void getAccountTeamMemberTest() {
        Test.startTest();
        Account acc = [SELECT Id from Account];
        Test.stopTest();
    }
    @isTest 
    static void getAccountTeamMemberTest2() {
        Test.startTest();
        AccountTriggerService ats=new AccountTriggerService();        
        ats.beforeInsert(new List<sObject>() );
        ats.afterUpdate(new List<sObject>() , new Map<Id,sObject>() ,new Map<Id,sObject>() );
        ats.beforeDelete(new Map<Id,sObject>() );
        ats.afterDelete(new Map<Id,sObject>() );
        ats.afterUndelete(new Map<Id,sObject>() );        
        Test.stopTest();
    }
    
}