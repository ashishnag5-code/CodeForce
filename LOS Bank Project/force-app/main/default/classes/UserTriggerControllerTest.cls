@isTest
public class UserTriggerControllerTest {
    @testSetup
    public static void setup(){
        User u=new User();
        u.ProfileId=[SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        u.LastName='TestUser';
        u.Email='ausfbUser@test.com';
        u.Username='ausfbUser@test.com'+System.currentTimeMillis();
        u.CompanyName='TEST';
        u.Title='title';
        u.Alias='alias';
        u.TimeZoneSidKey='America/Los_Angeles';
        u.EmailEncodingKey ='UTF-8';
        u.LanguageLocaleKey='en_US';
        u.LocaleSidKey='en_US';
        insert u;
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        Account accInstance = (Account)TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            Branch_Queue__c=grp.Id
        ),true);
        AccountTeamMember accTeamMember = (AccountTeamMember)TestFactory.createSObject(new AccountTeamMember(
            TeamMemberRole='Branch Manager', accountId = accInstance.id, Active__c = true, UserId =u.id
        ),true);
        
    }
    @isTest
    public static void addUserToQueueAndAccTeamTest(){
        List<AccountTeamMember> accTeamMember=[Select Id,AccountId,UserId,Scheme_Master__c,Approver_Level__c,Deviation_Level__c,Collateral__c,Active__c,Type_of_Employment__c, Customer_Grade__c, Product__c, OpportunityAccessLevel,AccountAccessLevel,CaseAccessLevel from AccountTeamMember LIMIT 1];
        UserTriggerController u=new UserTriggerController(JSON.serialize(accTeamMember),false,true,false);
        Test.startTest();
        Id enqueueId=System.enqueueJob(u);
        Test.stopTest();
        
    }
    @isTest
    public static void addUserToQueueAndAccTeamDeleteTest(){
        List<AccountTeamMember> accTeamMember=[Select Id,AccountId,UserId,Scheme_Master__c,Approver_Level__c,Deviation_Level__c,Collateral__c,Active__c,Type_of_Employment__c, Customer_Grade__c, Product__c, OpportunityAccessLevel,AccountAccessLevel,CaseAccessLevel from AccountTeamMember LIMIT 1];
        UserTriggerController u=new UserTriggerController(JSON.serialize(accTeamMember),false,false,true);
        Test.startTest();
        Id enqueueId=System.enqueueJob(u);
        Test.stopTest();
        
    }
    
    @isTest
    public static void addUserToQueueAndAccTeamTest1(){
        Id profileId=[SELECT Id FROM Profile WHERE Name = 'Sales'].Id; 
        User u1 = new User(LastName = 'Test Code',Email = 'test@test.com',Alias = 'Tcode',Username = 'test1234444@testzsdfsdtfsdf.com',CommunityNickname = 'test12',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',ProfileID = profileId,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8');
        insert u1;
        User u2 = new User(Id=u1.Id,Title='Team Lead',LastName = 'Test Code',Email = 'test1@test.com',Alias = 'Tcode1',Username = 'test1234444@testzsdfsdtfsdf.com1',CommunityNickname = 'test123',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',ProfileID = profileId,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',IsActive=true,Branch_Code__c='2103,2103');
        User u3 = new User(Id=u1.Id,Title='Team Lead',LastName = 'Test Code',Email = 'test2@test.com',Alias = 'Tcode2',Username = 'test1234444@testzsdfsdtfsdf.com2',CommunityNickname = 'test123',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',ProfileID = profileId,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',IsActive=true,Branch_Code__c='2103');
        List<User> oldUser=new List<User>{u1};
            List<User> newUser=new List<User>{u2};
                List<User> newUserwithoutComma=new List<User>{u3};    
                    Map<Id,User> userMap=new Map<Id,User>();  
        userMap.put(u1.Id,u2);
        Map<Id,User> userMap1=new Map<Id,User>();
        userMap1.put(u1.Id,u3);
        Test.startTest();
        UserTriggerController.addUserToQueueAndAccTeam(newUser,userMap);
        UserTriggerController.addUserToQueueAndAccTeam(newUserWithoutComma,userMap1);
        Test.stopTest(); 
    }
    
    @isTest
    public static void addUserToQueueAndAccTeamUpdateTest(){
        Id profileId=[SELECT Id FROM Profile WHERE Name = 'Sales'].Id; 
        User u1 = new User(LastName = 'Test Code',Email = 'test@test.com',Alias = 'Tcode',Username = 'test1234444@testzsdfsdtfsdf.com',CommunityNickname = 'test12',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',ProfileID = profileId,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',Branch_Code__c='2100,2100');
        insert u1;
        User u2 = new User(Id=u1.Id,Title='Team Lead',LastName = 'Test Code',Email = 'test1@test.com',Alias = 'Tcode1',Username = 'test1234444@testzsdfsdtfsdf.com1',CommunityNickname = 'test123',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',ProfileID = profileId,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',IsActive=true,Branch_Code__c='2103,2103');
        List<User> oldUser=new List<User>{u1};
            List<User> newUser=new List<User>{u2};
                Map<Id,User> oldUserMap=new Map<Id,User>();
        oldUserMap.put(u1.Id,u1);
        Map<Id,User> userMap=new Map<Id,User>();  
        userMap.put(u1.Id,u2);
        Test.startTest();
        UserTriggerController.addUserToQueueAndAccTeamUpdate(newUser,oldUserMap,userMap);
        Test.stopTest();
        
    }
    
    @isTest
    public static void addUserToQueueAndAccTeamUpdateTestWithoutComma(){
        Id profileId=[SELECT Id FROM Profile WHERE Name = 'Sales'].Id; 
        User u1 = new User(LastName = 'Test Code',Email = 'test@test.com',Alias = 'Tcode',Username = 'test1234444@testzsdfsdtfsdf.com',CommunityNickname = 'test12',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',ProfileID = profileId,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',Branch_Code__c='2100,2100');
        insert u1;
        User u2 = new User(Id=u1.Id,Title='Team Lead',LastName = 'Test Code',Email = 'test1@test.com',Alias = 'Tcode1',Username = 'test1234444@testzsdfsdtfsdf.com1',CommunityNickname = 'test123',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',ProfileID = profileId,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',IsActive=true,Branch_Code__c='2103');
        List<User> oldUser=new List<User>{u1};
            List<User> newUser=new List<User>{u2};
                Map<Id,User> oldUserMap=new Map<Id,User>();
        user u23 =u1;
        u2.IsActive = false;
        oldUserMap.put(u1.Id,u23);
        Map<Id,User> userMap=new Map<Id,User>();  
        userMap.put(u1.Id,u2);
        Test.startTest();
        UserTriggerController.addUserToQueueAndAccTeamUpdate(newUser,oldUserMap,userMap);
        Test.stopTest();
        
    }
    
    @isTest
    public static void addUserToQueueAndAccTeamUpdateTestNewUserWithoutComma(){
        Id profileId=[SELECT Id FROM Profile WHERE Name = 'Sales'].Id; 
        User u1 = new User(LastName = 'Test Code',Email = 'test@test.com',Alias = 'Tcode',Username = 'test1234444@testzsdfsdtfsdf.com',CommunityNickname = 'test12',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',ProfileID = profileId,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',Branch_Code__c='2100,2100');
        insert u1;
        User u2 = new User(Id=u1.Id,Title='Team Lead',LastName = 'Test Code',Email = 'test1@test.com',Alias = 'Tcode1',Username = 'test1234444@testzsdfsdtfsdf.com1',CommunityNickname = 'test123',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',ProfileID = profileId,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',IsActive=true);
        List<User> oldUser=new List<User>{u1};
            List<User> newUser=new List<User>{u2};
                Map<Id,User> oldUserMap=new Map<Id,User>();
        oldUserMap.put(u1.Id,u1);
        Map<Id,User> userMap=new Map<Id,User>();  
        userMap.put(u1.Id,u2);
        Test.startTest();
        UserTriggerController.addUserToQueueAndAccTeamUpdate(newUser,oldUserMap,userMap);
        Test.stopTest();
        
    }
    
    @isTest
    public static void addUserToQueueAndAccTeamUpdateTestWithBlankBranch(){
        Id profileId=[SELECT Id FROM Profile WHERE Name = 'Sales'].Id; 
        User u1 = new User(LastName = 'Test Code',Email = 'test@test.com',Alias = 'Tcode',Username = 'test1234444@testzsdfsdtfsdf.com',CommunityNickname = 'test12',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',ProfileID = profileId,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8');
        insert u1;
        User u2 = new User(Id=u1.Id,Title='Team Lead',LastName = 'Test Code',Email = 'test1@test.com',Alias = 'Tcode1',Username = 'test1234444@testzsdfsdtfsdf.com1',CommunityNickname = 'test123',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',ProfileID = profileId,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',IsActive=true,Branch_Code__c='2103');
        List<User> oldUser=new List<User>{u1};
            List<User> newUser=new List<User>{u2};
                Map<Id,User> oldUserMap=new Map<Id,User>();
        oldUserMap.put(u1.Id,u1);
        Map<Id,User> userMap=new Map<Id,User>();  
        userMap.put(u1.Id,u2);
        Test.startTest();
        UserTriggerController.addUserToQueueAndAccTeamUpdate(newUser,oldUserMap,userMap);
        Test.stopTest();
        
    }
    @isTest
    public static void addUserToQueueAndAccTeamUpdateTestWithBranchNotHavingComma(){
        Id profileId=[SELECT Id FROM Profile WHERE Name = 'Sales'].Id; 
        User u1 = new User(LastName = 'Test Code',Email = 'test@test.com',Alias = 'Tcode',Username = 'test1234444@testzsdfsdtfsdf.com',CommunityNickname = 'test12',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',ProfileID = profileId,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',Branch_Code__c='2103');
        insert u1;
        User u2 = new User(Id=u1.Id,Title='Team Lead',LastName = 'Test Code',Email = 'test1@test.com',Alias = 'Tcode1',Username = 'test1234444@testzsdfsdtfsdf.com1',CommunityNickname = 'test123',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',ProfileID = profileId,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',IsActive=true,Branch_Code__c='2103');
        List<User> oldUser=new List<User>{u1};
            List<User> newUser=new List<User>{u2};
                Map<Id,User> oldUserMap=new Map<Id,User>();
        oldUserMap.put(u1.Id,u1);
        Map<Id,User> userMap=new Map<Id,User>();  
        userMap.put(u1.Id,u2);
        Test.startTest();
        UserTriggerController.addUserToQueueAndAccTeamUpdate(newUser,oldUserMap,userMap);
        Test.stopTest();
        
    }
    
    @isTest
    public static void addUserToQueueAndAccTeamUpdateTestWithBranchCodeNotChanged(){
        Id profileId=[SELECT Id FROM Profile WHERE Name = 'Sales'].Id; 
        User u1 = new User(LastName = 'Test Code',Email = 'test@test.com',Alias = 'Tcode',Username = 'test1234444@testzsdfsdtfsdf.com',CommunityNickname = 'test12',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',ProfileID = profileId,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',Branch_Code__c='2103,2103');
        insert u1;
        User u2 = new User(Id=u1.Id,Title='Team Lead',LastName = 'Test Code',Email = 'test1@test.com',Alias = 'Tcode1',Username = 'test1234444@testzsdfsdtfsdf.com1',CommunityNickname = 'test123',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',ProfileID = profileId,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',IsActive=true,Branch_Code__c='2103,2103');
        List<User> oldUser=new List<User>{u1};
            List<User> newUser=new List<User>{u2};
                Map<Id,User> oldUserMap=new Map<Id,User>();
        oldUserMap.put(u1.Id,u1);
        Map<Id,User> userMap=new Map<Id,User>();  
        userMap.put(u1.Id,u2);
        Test.startTest();
        UserTriggerController.addUserToQueueAndAccTeamUpdate(newUser,oldUserMap,userMap);
        Test.stopTest();
        
    }
    
    @isTest
    public static void addUserToQueueAndAccTeamUpdateTestWithOldUserInactive(){
        Id profileId=[SELECT Id FROM Profile WHERE Name = 'Sales'].Id; 
        User u1 = new User(LastName = 'Test Code',Email = 'test@test.com',Alias = 'Tcode',Username = 'test1234444@testzsdfsdtfsdf.com',CommunityNickname = 'test12',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',ProfileID = profileId,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',Branch_Code__c='2103,2103');
        insert u1;
        User u2 = new User(Id=u1.Id,Title='Team Lead',LastName = 'Test Code',Email = 'test1@test.com',Alias = 'Tcode1',Username = 'test1234444@testzsdfsdtfsdf.com1',CommunityNickname = 'test123',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',ProfileID = profileId,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',IsActive=true,Branch_Code__c='2103');
        List<User> oldUser=new List<User>{u1};
            List<User> newUser=new List<User>{u2};
                Map<Id,User> oldUserMap=new Map<Id,User>();
        oldUserMap.put(u1.Id,u1);
        Map<Id,User> userMap=new Map<Id,User>();  
        userMap.put(u1.Id,u2);
        Test.startTest();
        UserTriggerController.addUserToQueueAndAccTeamUpdate(newUser,oldUserMap,userMap);
        Test.stopTest();
        
    }
    
    @isTest
    public static void addUserToQueueAndAccTeamUpdateTestWithOldUserBranchWithoutComma(){
        Id profileId=[SELECT Id FROM Profile WHERE Name = 'Sales'].Id; 
        User u1 = new User(LastName = 'Test Code',Email = 'test@test.com',Alias = 'Tcode',Username = 'test1234444@testzsdfsdtfsdf.com',CommunityNickname = 'test12',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',ProfileID = profileId,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',Branch_Code__c='2103');
        insert u1;
        User u2 = new User(Id=u1.Id,Title='Team Lead',LastName = 'Test Code',Email = 'test1@test.com',Alias = 'Tcode1',Username = 'test1234444@testzsdfsdtfsdf.com1',CommunityNickname = 'test123',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',ProfileID = profileId,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',IsActive=true,Branch_Code__c='2103,2103');
        List<User> oldUser=new List<User>{u1};
            List<User> newUser=new List<User>{u2};
                Map<Id,User> oldUserMap=new Map<Id,User>();
        oldUserMap.put(u1.Id,u1);
        Map<Id,User> userMap=new Map<Id,User>();  
        userMap.put(u1.Id,u2);
        Test.startTest();
        UserTriggerController.addUserToQueueAndAccTeamUpdate(newUser,oldUserMap,userMap);
        Test.stopTest();
        
    }
    
    @isTest
    public static void addUserToQueueAndAccTeamUpdateTestWithOldUserBranchWithoutCode(){
        Id profileId=[SELECT Id FROM Profile WHERE Name = 'Sales'].Id; 
        User u1 = new User(LastName = 'Test Code',Email = 'test@test.com',Alias = 'Tcode',Username = 'test1234444@testzsdfsdtfsdf.com',CommunityNickname = 'test12',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',ProfileID = profileId,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',Branch_Code__c='2103');
        insert u1;
        User u2 = new User(Id=u1.Id,Title='Team Lead',LastName = 'Test Code',Email = 'test1@test.com',Alias = 'Tcode1',Username = 'test1234444@testzsdfsdtfsdf.com1',CommunityNickname = 'test123',LocaleSidKey = 'en_US',TimeZoneSidKey = 'GMT',ProfileID = profileId,LanguageLocaleKey = 'en_US',EmailEncodingKey = 'UTF-8',IsActive=true,Branch_Code__c='2103,2103');
        List<User> oldUser=new List<User>{u1};
            List<User> newUser=new List<User>{u2};
                Map<Id,User> oldUserMap=new Map<Id,User>();
        oldUserMap.put(u1.Id,u1);
        Map<Id,User> userMap=new Map<Id,User>();  
        userMap.put(u1.Id,u2);
        Test.startTest();
        UserTriggerController.addUserToQueueAndAccTeamUpdate(newUser,oldUserMap,userMap);
        Test.stopTest();
        
    }
    
}