@isTest
public class AUSF_MarkSTPController_Test {
    
    @testSetup 
    static void setup() {
        Profile prof = [select Id,Name from profile where name = 'Credit Manager'];
        User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
                                                            lastName = 'test2',
                                                            profileId = prof.id,
                                                            username = 'test'+UserInfo.getOrganizationId()+'@test.com',
                                                            email = 'test@test.com',
                                                            Branch_Code__c  = '2103',
                                                            Authority_Level__c  = 'L1'
                                                           ),true);
        Account brMaster = (Account)TestFactory.createSObject(new Account(
            Name = '2222',
            Account_Code__c = '1111',
            Account_Name__c = 'Test Location'
        ),true);
        
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),false);
        
        insert grp; 
        
        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            Branch_Queue__c=grp.Id
        ),true);
        
        AccountTeamMember accTeamMember = (AccountTeamMember)TestFactory.createSObject(new AccountTeamMember(
            TeamMemberRole='Credit', accountId = accInstance.id, Active__c = true, UserId =usr.Id
        ),true);
        
        AccountTeamMember accTeamMember2 = (AccountTeamMember)TestFactory.createSObject(new AccountTeamMember(
            TeamMemberRole='Credit', accountId = accInstance.id, Active__c = true, UserId =userInfo.getUserId()
        ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Branch_Master__c = accInstance.Id, BRE_Decision__c='STP'
        ),true);
        
    }
    
    @isTest
    public static void checkIfValidLoggedInUserTest(){
        User usrRecord = [SELECT Id FROM User WHERE Profile.Name = 'Credit Manager' AND FirstName='test1'];
        Profile salesProfile = [SELECT Id, Name FROM Profile Where Name = 'Sales'];
        Account accRecord = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Branch_Master__c = accRecord.Id, BRE_Decision__c='STP'
        ),true);
        List<AccountTeamMember> actMember = [Select Id, UserId, User.Name, TeamMemberRole FROM AccountTeamMember WHERE AccountId=:accRecord.Id];
        Boolean resp1 = AUSF_MarkSTPController.checkIfValidLoggedInUser('');
        SYstem.runAs(usrRecord){
            Test.startTest();
            Boolean resp = AUSF_MarkSTPController.checkIfValidLoggedInUser(loanAppl.Id);
            Test.stopTest();
        }
        
    }
    
    @isTest
    public static void checkIfValidLoggedInUserTest2(){
        User usrRecord = [SELECT Id, profileId FROM User WHERE Profile.Name = 'Credit Manager' AND FirstName='test1'];
        Account accRecord = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Branch_Master__c = accRecord.Id, BRE_Decision__c='STP',
            RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId()
        ),true);
        List<AccountTeamMember> actMember = [Select Id, UserId, User.Name, TeamMemberRole FROM AccountTeamMember WHERE AccountId=:accRecord.Id];
        SYstem.runAs(usrRecord){
            Test.startTest();
            Boolean resp = AUSF_MarkSTPController.checkIfValidLoggedInUser(loanAppl.Id);
            Test.stopTest();
        }
        
    }
    
    @isTest
    public static void checkIfValidLoggedInUserTest3(){
        User usrRecord = [SELECT Id, profileId FROM User WHERE Profile.Name = 'Credit Manager' AND FirstName='test1'];
        Account accRecord = [SELECT Id FROM Account WHERE Name = '2222' LIMIT 1];
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Branch_Master__c = accRecord.Id, BRE_Decision__c='STP',
            RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId()
        ),true);
        SYstem.runAs(usrRecord){
            Test.startTest();
            Boolean resp = AUSF_MarkSTPController.checkIfValidLoggedInUser(loanAppl.Id);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void checkIfValidLoggedInUserTest4(){
        User usrRecord = [SELECT Id, profileId FROM User WHERE Profile.Name = 'Credit Manager' AND FirstName='test1'];
        Account accRecord = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Branch_Master__c = accRecord.Id, BRE_Decision__c='STP',
            RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId()
        ),true);
        List<AccountTeamMember> actMember = [Select Id, UserId, User.Name, TeamMemberRole FROM AccountTeamMember WHERE AccountId=:accRecord.Id];
        Test.startTest();
        Boolean resp = AUSF_MarkSTPController.checkIfValidLoggedInUser(loanAppl.Id);
        Test.stopTest();
        
    }
    
    
    @isTest
    public static void markSTPOk_NotOkTest2(){
        
        
        Account accRecord = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Branch_Master__c = accRecord.Id, BRE_Decision__c='STP',
            RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId()
        ),true);
        Test.startTest();
        List<AccountTeamMember> accTeamMember = [Select Id, TeamMemberRole from AccountTeamMember WHErE AccountId=:accRecord.Id];
        for(AccountTeamMember act : accTeamMember){
            act.TeamMemberRole = 'Branch Manager';
        }
        AUSF_MarkSTPController.markSTPOk_NotOk(loanAppl.Id, 'Ok', 'remarks');
        update accTeamMember;
        AUSF_MarkSTPController.markSTPOk_NotOk(loanAppl.Id, 'Ok', 'remarks');
        Test.stopTest();
        
    }
    
     @isTest
    public static void markSTPOk_NotOkTest3(){
        
        
        Account accRecord = [SELECT Id FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Branch_Master__c = accRecord.Id, BRE_Decision__c='STP',
            RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId()
        ),true);
        Test.startTest();
        List<AccountTeamMember> accTeamMember = [Select Id, TeamMemberRole from AccountTeamMember WHErE AccountId=:accRecord.Id];
        
        delete accTeamMember;
        AUSF_MarkSTPController.markSTPOk_NotOk(loanAppl.Id, 'Ok', 'remarks');
        Test.stopTest();
        
    }
    
}