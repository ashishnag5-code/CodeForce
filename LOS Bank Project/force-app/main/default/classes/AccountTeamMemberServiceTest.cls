@isTest
public with sharing class AccountTeamMemberServiceTest {
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
            TeamMemberRole = 'Branch Manager',
            Cancellation_Level__c  = 'Cancellation 1',
            RBM_Approval_Level__c  = 'DO 1'
        ),true);                                                                                                                        
      }
    }
    @isTest 
    static void getAccountTeamMemberTest() {
        Test.startTest();
        Account acc = [SELECT Id from Account];
        list<AccountTeamMember> atm=AccountTeamMemberService.getAccountTeamMember('WHERE AccountId = \'' + acc.Id + '\'');           
        Test.stopTest();
    }
    @isTest 
    static void getAccountTeamMemberTest2() {
        Test.startTest();
        list<AccountTeamMember> atm2=AccountTeamMemberService.getAccountTeamMember('');
        System.assertEquals(atm2.size()==0,false,'AssertMsg');
        Test.stopTest();
    }
     @isTest 
    static void deleteQueueMemberTest(){
        AccountTeamMember atmRec = [SELECT Id,UserId,AccountId from AccountTeamMember];
        Map<Id,AccountTeamMember> atmMap = new Map<Id,AccountTeamMember>();
        atmMap.put(atmRec.Id, atmRec);
        Test.startTest();
        AccountTeamMemberTriggerController.deleteQueueMember(atmMap);   
        Test.stopTest();     
    }
}