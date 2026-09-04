@isTest
public class UserTriggerTest {
    @testSetup static void setup() {
        Profile prof = [select Id,Name from profile where name like '%Credit%'];
		Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 

        User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
        	lastName = 'test2',
        	profileId = prof.id,
        	username = 'test'+UserInfo.getOrganizationId()+'@test.com',
        	email = 'test@test.com',
        	Branch_Code__c  = '2103'
    	),true);
        
        
        Account accInstance = (Account)TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            Branch_Queue__c=grp.Id
        ),true);
        AccountTeamMember accTeamMember = (AccountTeamMember)TestFactory.createSObject(new AccountTeamMember(
            TeamMemberRole='Branch Manager', accountId = accInstance.id, Active__c = true, UserId =usr.id
        ),true);
                                                                                                                          
      }
    


    @isTest 
    static void getAccountTeamMemberTest() {
        Test.startTest();
            User usr = [SELECT firstName from User where email='test@test.com'];
            usr.firstName='Test11';
            update usr;        
        Test.stopTest();
    }
    @isTest 
    static void getAccountTeamMemberTest2() {
        Test.startTest();
        try{
        	
            Map<Id,User> mapUser = new Map<Id,User>();
        	Profile prof = [select Id,Name from profile where name like 'Sales'];
            User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
                lastName = 'test3',
                profileId = prof.id,
                username = 'test3'+UserInfo.getOrganizationId()+'@test.com',
                email = 'test3@test.com',
                Branch_Code__c  = '2103',
                Title = 'Regional Officer',
                IsActive = true
            ),true);
            mapUser.put(null,usr);
            UserTriggerService ats=new UserTriggerService();        
            ats.beforeInsert(mapUser.values());
            
            String strusername = 'test'+UserInfo.getOrganizationId()+'@test.com';
            Map<Id,User> mapExistUser = new Map<Id,User>([Select Id, Name, Title, Email, Branch_Code__c, IsActive, ProfileId,Product_Accessible__c from User where username =: strusername]);
            Map<Id,User> mapExistUser1 = new Map<Id,User>([Select Id, Name, Title, Email, Branch_Code__c, IsActive, ProfileId,Product_Accessible__c from User where username =: strusername]);
            for(User useer: mapExistUser1.values()){
                useer.IsActive = false;
                mapExistUser1.put(useer.Id,useer);
            }
            system.assertEquals(true,mapExistUser.size()>0);
            ats.afterUpdate(mapExistUser.values() , mapExistUser1 ,mapExistUser );
            ats.beforeDelete(mapExistUser );
            ats.afterDelete(mapExistUser );
            ats.afterUndelete(mapExistUser ); 
            
            
        }catch(exception e){
            system.debug('Error');
        }
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
        UserTriggerService ussser = new UserTriggerService();
        ussser.afterInsert(newUser,userMap);
        ussser.beforeUpdate(null,null,null);
        //UserTriggerController.addUserToQueueAndAccTeam(newUser,userMap);
        //UserTriggerController.addUserToQueueAndAccTeam(newUserWithoutComma,userMap1);
        Test.stopTest(); 
    }
}