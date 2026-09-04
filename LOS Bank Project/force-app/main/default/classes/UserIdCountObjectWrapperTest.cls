@isTest
public with sharing class UserIdCountObjectWrapperTest {
    @testSetup static void setup() {
        Profile prof = [select Id,Name from profile where name like '%Credit%'];
        User usr = (User)TestFactory.createSObject(new User(
            firstName = 'test1',
            lastName = 'test2',
            profileId = prof.id,
            username = 'test'+UserInfo.getOrganizationId()+'@test.com',
            email = 'test@test.com',
            Branch_Code__c  = '1111'
        ),true);
        
    }
    testmethod static void testUserIdCountObjectWrapper(){
        Test.startTest();
        try{
            new UserIdCountObjectWrapper(null); 
        } catch(Exception exp){}
        Test.stopTest();
    }
    testmethod static void testUserIdCountObjectWrapperCompareTo1(){
        Test.startTest();
        try{
            UserIdCountObjectWrapper.UserIdCountObject wrap=  new UserIdCountObjectWrapper.UserIdCountObject();
            wrap.userId = UserInfo.getUserId();
            wrap.assignedRecordsCount = null;
            wrap.crMgrId = null;
            wrap.brMgrId = null;
            UserIdCountObjectWrapper userWrap = new UserIdCountObjectWrapper(wrap);
            userWrap.compareTo(userWrap);
        } catch(Exception exp){}
        Test.stopTest();
    }
    testmethod static void testUserIdCountObjectWrapperCompareTo2(){
        Test.startTest();
        try{
            UserIdCountObjectWrapper.UserIdCountObject wrap=  new UserIdCountObjectWrapper.UserIdCountObject();
            wrap.userId = UserInfo.getUserId();
            wrap.assignedRecordsCount = null;
            wrap.crMgrId = null;
            wrap.brMgrId = null;
            UserIdCountObjectWrapper userWrap = new UserIdCountObjectWrapper(wrap);
            UserIdCountObjectWrapper userWrap2 = new UserIdCountObjectWrapper(wrap);
            userWrap.obj.assignedRecordsCount = 1;
            userWrap2.compareTo(userWrap);
        } catch(Exception exp){}
        Test.stopTest();
    }
    
}