@isTest
public class QueryTriggerTest {
@testSetup static void setup() {
        Profile prof = [select Id,Name from profile where name like '%Credit%'];

        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        List<User> testusr=[select Id from User where Id = :UserInfo.getUserId()];         
        System.runAs(testusr[0]) {
        Id branchRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();

        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            RecordTypeId=branchRecordTypeId,
            Branch_Queue__c=grp.Id
        ),true); 


        User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
            lastName = 'test2',
            profileId = prof.id,
            username = 'test'+UserInfo.getOrganizationId()+'@test.com',
            email = 'test@test.com',
            Branch_Code__c  = '2103'
        ),false);
        
        insert usr;
            
        Query__c query= new Query__c( 
                                     Assigned_To__c=usr.Id, Remarks__c ='Test',Status__c ='New');
        insert query;
            
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
        Query__c acc = [SELECT Id from Query__c];
        acc.Status__c='In Progress';
        update acc;
        Test.stopTest();
    }
    @isTest
    public static void beforeUpdateTest(){
      Query__c qc=new Query__c(Remarks__c ='Testing',Status__c='New',Assigned_To__c=UserInfo.getUserId());
      Query__c qc2=new Query__c(Id=qc.Id,Remarks__c ='Testing',Status__c='New',Assigned_To__c=UserInfo.getUserId());
      Test.startTest();
        Map<Id,Query__c> oldQMap=new Map<Id,Query__c>();
        Map<Id,Query__c> newQMap=new Map<Id,Query__c>();
        oldQMap.put(qc.Id,qc);
        newQMap.put(qc.Id, qc2);
        QueryTriggerService.beforeUpdate(oldQMap,newQMap);
      Test.stopTest();  
    }
    
     @isTest
    public static void afterInsertTest(){
           User objUser = [SElect id from User where Profile.Name = 'Credit Manager' and IsActive=true Limit 1];
           system.assertEquals(true,objuser != NULL);
          Query__c qc=new Query__c(Remarks__c ='Testing',Status__c='New',Assigned_To__c=objUser.Id);
          insert qc;
          Test.startTest();
            List<Query__c> qcList=new List<Query__c>();
            qcList.add(qc);
            try{
                QueryTriggerService.afterInsert(qcList);
            }
            catch(Exception ex) {}
            
          Test.stopTest();  
    }
}