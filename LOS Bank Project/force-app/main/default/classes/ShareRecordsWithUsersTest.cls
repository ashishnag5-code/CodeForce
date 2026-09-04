@IsTest
public class ShareRecordsWithUsersTest {
    
    @testSetup static void setup() {

        Profile prof = [select Id,Name from profile where name like '%Credit%'];
		Group grp = (Group )TestFactory.createSObject(new Group(Name ='Group1',Type='Queue'),true); 

        System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]) {
            Account dummyAccHub = (Account)TestFactory.createSObject(new Account (
                Name ='DummyAccountHub', Account_Code__c = '2203', Branch_Queue__c = grp.Id, 
                RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Hub').getRecordTypeId()),true);

            Account dummyAccRegion = (Account)TestFactory.createSObject(new Account (
                Name ='DummyAccountRegion', Account_Code__c = '1101', Branch_Queue__c = grp.Id, 
                RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Region').getRecordTypeId()),true);
            
            Account dummyAccZone = (Account)TestFactory.createSObject(new Account (
                Name ='DummyAccountZone', Account_Code__c = '2304', Branch_Queue__c = grp.Id, 
                RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Zone').getRecordTypeId()),true);

            Account dummyAccNational = (Account)TestFactory.createSObject(new Account (
                Name ='DummyAccountNational', Account_Code__c = '1202', Branch_Queue__c = grp.Id, 
                RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('National').getRecordTypeId()),true);

            Account accInstance = (Account)TestFactory.createSObject(new Account (
                Name ='TestAccount', Account_Code__c = '2103', Branch_Queue__c = grp.Id, Business_HUB__c = dummyAccHub.Id, 
                Region__c = dummyAccRegion.Id, Zone__c = dummyAccZone.Id, National__c = dummyAccNational.Id,
                RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Branch').getRecordTypeId()),true);

            Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                    Application_Number__c  = 'AP-12345', Adhar_Card__c = 123456, 
                    Loan_Amount__c  = 1000, Product__c='10301', Customer_Type__c='Individual',
                    Stage__c ='DDE', EMI_Date__c = '10/3/2022', Tenure__c = 10,
                    Branch_Master__c = accInstance.Id),true);

            // Loan_Application__c loanAppl1 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            //         Application_Number__c  = 'AP-67890', Adhar_Card__c = 2345676, 
            //         Loan_Amount__c  = 1000, Product__c='10201', Customer_Type__c='Individual',
            //         Stage__c ='DDE', EMI_Date__c = '10/3/2022', Tenure__c = 10,
            //         Branch_Master__c = accInstance.Id),true);

            User usr = (User)TestFactory.createSObject(
                new User(firstName = 'test1', lastName = 'test2', profileId = prof.id,
                username = 'test'+UserInfo.getOrganizationId()+'@test.com', 
                email = 'test@test.com', Branch_Code__c  = '2103',Product_Accessible__c = 'All New'),true);

            User usr2 = (User)TestFactory.createSObject(
                new User(firstName = 'test11', lastName = 'test22', profileId = prof.id,
                username = 'testt'+UserInfo.getOrganizationId()+'@testt.com', 
                email = 'testt@testt.com', Branch_Code__c  = '2000',Product_Accessible__c = 'All Used'),true);

            User usr3 = (User)TestFactory.createSObject(
                new User(firstName = 'testt1', lastName = 'testt2', profileId = prof.id,
                username = 'testtt'+UserInfo.getOrganizationId()+'@testtt.com', 
                email = 'testtt@testtt.com', Branch_Code__c  = '2104',Product_Accessible__c = 'All New'),true);

            AccountTeamMember atm = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
                AccountId =accInstance.Id, UserId=usr2.Id, TeamMemberRole = 'Branch Manager'),true);   
            
            AccountTeamMember atm2 = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
                AccountId =accInstance.Id, UserId=usr.Id, TeamMemberRole = 'Team Lead'),true);   

            AccountTeamMember atmZH = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
                AccountId =dummyAccZone.Id, UserId=usr3.Id, TeamMemberRole = 'Zonal Head (ZBM)'),true);
            
            AccountTeamMember atmHH = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
                AccountId =dummyAccHub.Id, UserId=usr3.Id, TeamMemberRole = 'Hub Head (CBM)'),true);
            
            AccountTeamMember atmNH = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
                AccountId =dummyAccNational.Id, UserId=usr3.Id, TeamMemberRole = 'National Head (NBM/ NPM)'),true);
            
            AccountTeamMember atmRH = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
                AccountId =dummyAccRegion.Id, UserId=usr3.Id, TeamMemberRole = 'Region Head (RBM)'),true);

        }
    }

    @IsTest
    static void testShareLoanBasedOnProductAccess() {
        
        Map<Id, Loan_Application__c> oldApplicationsMap = new Map<Id, Loan_Application__c>();
        Map<Id, Loan_Application__c> newApplicationsMap = new Map<Id, Loan_Application__c>();
        Loan_Application__c loanAppl = [Select id, Product__c FROM Loan_Application__c LIMIT 1];
        oldApplicationsMap.put(loanAppl.Id, loanAppl);
        
        loanAppl.Product__c = '10302';
        update loanAppl;
        newApplicationsMap.put(loanAppl.Id, loanAppl);
        
        Test.startTest();
        ShareRecordsWithUsers.shareLoanBasedOnProductAccess(oldApplicationsMap, newApplicationsMap, 'Update');
        Test.stopTest();
        
    }
    
    @IsTest
    static void testUpdateRecordAccessOnChangeOfRole() {
        
        Map<Id, AccountTeamMember> oldAcTeamMembersMap = new Map<Id, AccountTeamMember>();
        Map<Id, AccountTeamMember> newAcTeamMembersMap = new Map<Id, AccountTeamMember>();
        AccountTeamMember testTeamMember = [Select id, AccountId, TeamMemberRole, UserId FROM AccountTeamMember WHERE TeamMemberRole = 'Branch Manager' LIMIT 1];

        oldAcTeamMembersMap.put(testTeamMember.Id, testTeamMember);
        
        testTeamMember.TeamMemberRole = 'Team Lead';
        update testTeamMember;
        newAcTeamMembersMap.put(testTeamMember.Id, testTeamMember);
        
        Test.startTest();
        ShareRecordsWithUsers.updateRecordAccessOnChangeOfRole(oldAcTeamMembersMap, newAcTeamMembersMap, 'Update');
        ShareRecordsWithUsers.updateRecordAccessOnChangeOfRole(oldAcTeamMembersMap, newAcTeamMembersMap, 'Delete');
        ShareRecordsWithUsers.updateRecordAccessOnChangeOfRole(oldAcTeamMembersMap, newAcTeamMembersMap, 'Insert');
        Test.stopTest();
    }
    
    @isTest
    public static void testUpdateRecordAccessOnChangeOfUser() {

        Map<Id, User> oldUsersMap = new Map<Id, User>();
        Map<Id, User> newUsersMap1 = new Map<Id, User>();
        Map<Id, User> newUsersMap2 = new Map<Id, User>();

        User oldUser = [Select Id, Product_Accessible__c from User WHERE Product_Accessible__c = 'All Used' LIMIT 1];
		oldUsersMap.put(oldUser.Id, oldUser);
       
        oldUser.Product_Accessible__c = 'All New';
        update oldUser;
        newUsersMap1.put(oldUser.Id, oldUser);
        
        oldUser.Product_Accessible__c = null;
        update oldUser;
        newUsersMap2.put(oldUser.Id, oldUser);

        Test.startTest();
        ShareRecordsWithUsers.updateRecordAccessOnChangeOfUser(oldUsersMap, newUsersMap1, 'Update');
        ShareRecordsWithUsers.updateRecordAccessOnChangeOfUser(oldUsersMap, newUsersMap2, 'Update');
        Test.stopTest();
    }
}