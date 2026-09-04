@isTest
public with sharing class FieldInvestigationServiceTest {
    
    @testSetup static void setup() {
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Stage__c='QDE'
            
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Email__c = 'test@gmail.com',
            Loan__c =loanAppl.Id
            
        ),true);
        
        
        Applicant__c appl1 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Punit',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Email__c = 'test@zoemail.net',
            Loan__c =loanAppl.Id
            
        ),true);
        
        Rule_Definition__c  ruleDef = (Rule_Definition__c)TestFactory.createSObject(new Rule_Definition__c(
            Rule_Condition__c = 'Not Equals',
            Subject_Field__c = 'Stage__c',
            Value_Field__c = 'Value',
            Sequence__c =1,
            Target_Object__c ='Document_Checklist__c',
            Rule_Name__c ='Field Investigation'
            
        ),true);
        Document_Master__c  docMaster = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name             = 'AUWheels0053',
            Document_Name__c = 'FI Photos',
            Document_Id__c = 'AUWheels0053',
            Document_Category__c='Others',
            Document_Sub_Category__c='Others',
            Active__c=true
        ),true);
        
        Rule_Driver__c  ruleDriver = (Rule_Driver__c)TestFactory.createSObject(new Rule_Driver__c(
            Configuring_For__c  ='Document Checklist',
            Effective_From__c  =Date.today()-1,
            Effective_To__c =Date.today()+1,
            Logical_Expression__c ='1',
            Object_Name__c ='Field_Investigation__c',
            Target_Value__c ='AUWheels0053',
            Match_Criteria__c ='All Match' 
            
        ),true);
        
        
        Rule_Definition_Driver_Mapping__c  ruleDefDriver = (Rule_Definition_Driver_Mapping__c )TestFactory.createSObject(new Rule_Definition_Driver_Mapping__c (
            Rule_Driver_ID__c = ruleDriver.Id,
            Rule_ID__c = ruleDef.Id
            
        ),true);
        Profile prof = [select Id,Name from profile where name like '%Credit Manager%'];
        
        
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
                UserId=usr.Id
            ),true);
            Field_Investigation__c fieldInvestigationObj = (Field_Investigation__c)TestFactory.createSObject((new Field_Investigation__c( 
                Name = appl.Customer_Name__c,
                Loan_Application__c =loanAppl.Id,
                Applicant__c=appl.Id,
                FI_Status__c ='Negative',
                Applicant_Type__c='Applicant',
                Credit_Manager__c = usr.Id)),true);
            
        } 
        
    }
    
    @isTest 
    static void updateFI() {
        String profileId = [SELECT Id, Name FROM Profile WHERE Name='Credit Manager' LIMIT 1].Id;
        User usr = (User)TestFactory.createSObject(new User(
            firstName = 'test1Credit',
            lastName = 'test2',
            profileId = profileId,
            username = 'test'+UserInfo.getOrganizationId()+'@testCredit.com',
            email = 'test@test.com',
            Branch_Code__c  = '1111'
        ),true);
        User usr2 = (User)TestFactory.createSObject(new User(
            firstName = 'test1Credit2',
            lastName = 'test2',
            profileId = profileId,
            username = 'test'+UserInfo.getOrganizationId()+'@testCredit2.com',
            email = 'test@test.com',
            Branch_Code__c  = '1111'
        ),true);
        
        FieldInvestigationService.getFieldInvestigationRecords(null);
        
        //}
        
    }
    @isTest 
    static void updateFITest() {
        Loan_Application__c loanAppl = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Applicant__c appl = [SELECT Id FROM Applicant__c LIMIT 1];
        String profileId = [SELECT Id, Name FROM Profile WHERE Name='Credit Manager' LIMIT 1].Id;
        
        User usr = (User)TestFactory.createSObject(new User(
            firstName = 'test1Credit',
            lastName = 'test2',
            profileId = profileId,
            username = 'test'+UserInfo.getOrganizationId()+'@testCredit.com',
            email = 'test@test.com',
            Branch_Code__c  = '1111'
        ),true);
        test.StartTest();
        Field_Investigation__c fi = (Field_Investigation__c)TestFactory.createSObject((new Field_Investigation__c( 
            Name = 'Test FI',
            Loan_Application__c =loanAppl.Id,
            Applicant__c=appl.Id,
            FI_Status__c ='In Progress',
            Applicant_Type__c='Applicant',
            Credit_Manager__c = usr.Id)),true);
        //Field_Investigation__c fi =[Select Id,name from Field_Investigation__c limit 1];
        fi.Name+='test';
        fi.FI_Status__c = 'Negative';
        fi.Credit_Manager__c=usr.Id;
        //fi.OwnerId = usr.Id;
        update fi;
        test.stopTest();
    }
     @isTest 
    static void updateFITest2() {
        Test.startTest();
        RuleEngineHandlerUtility rehu = new RuleEngineHandlerUtility();
        rehu.getComplexCriteriaEvaluation('AND', new Map<Integer, Boolean>{0=>false});
        Test.stopTest();
    }
    @isTest 
    static void updateFITest3() {
        Test.startTest();
        RuleEngineHandlerUtility rehu = new RuleEngineHandlerUtility();
        //RuleEngineHandlerUtility.evaluateAdvanceLogic('OR', new Map<Integer, Boolean>{0=>false});
        Test.stopTest();
    }
    
    @isTest 
    static void updateFITest3DeviationCheck() {
        Test.startTest();
        Loan_Application__c loanAppl = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Applicant__c appl = [SELECT Id FROM Applicant__c LIMIT 1];
        String profileId = [SELECT Id, Name FROM Profile WHERE Name='Credit Manager' LIMIT 1].Id;
        
        User usr = (User)TestFactory.createSObject(new User(
            firstName = 'test1Credit',
            lastName = 'test2',
            profileId = profileId,
            username = 'test'+UserInfo.getOrganizationId()+'@testCredit.com',
            email = 'test@test.com',
            Branch_Code__c  = '1111'
        ),true);
        Field_Investigation__c fi = (Field_Investigation__c)TestFactory.createSObject((new Field_Investigation__c( 
            Name = 'Test FI',
            Loan_Application__c =loanAppl.Id,
            Applicant__c=appl.Id,
            FI_Status__c ='In Progress',
            Applicant_Type__c='Applicant',
            Credit_Manager__c = usr.Id)),true);
        //Field_Investigation__c fi =[Select Id,name from Field_Investigation__c limit 1];
        fi.Name+='test';
        fi.FI_Status__c = 'Negative';
        fi.Re_Trigger__c = true;
        update fi;
        Deviation__c dev = (Deviation__c)TestFactory.createSObject(new Deviation__c(
            Deviation_Type__c = 'FI Negative',
            Loan_Application__c = loanAppl.Id,
            Field_Investigation__c = fi.Id,
            Source__c = 'Manual',
            Level__c = 'S4'
        ),true);
        Field_Investigation__c fi2 = (Field_Investigation__c)TestFactory.createSObject((new Field_Investigation__c( 
            Name = 'Test FI',
            Loan_Application__c =loanAppl.Id,
            Applicant__c=appl.Id,
            FI_Status__c ='In Progress',
            Applicant_Type__c='Applicant',
            Credit_Manager__c = usr.Id)),true);
        //Field_Investigation__c fi =[Select Id,name from Field_Investigation__c limit 1];
        fi2.Name+='test';
        fi2.FI_Status__c = 'Positive';
        fi2.Re_Trigger__c = false;
        fi2.Stage__c = 'Closed';
        update fi2;
        
        Test.stopTest();
    }
    
    @IsTest
    static void testdeleteShareFIRecords(){
        Test.startTest();
        Loan_Application__c loanAppl = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Applicant__c appl = [SELECT Id FROM Applicant__c LIMIT 1];
        String profileId = [SELECT Id, Name FROM Profile WHERE Name='Credit Manager' LIMIT 1].Id;
        
        User usr = (User)TestFactory.createSObject(new User(
            firstName = 'test1Credit',
            lastName = 'test2',
            profileId = profileId,
            username = 'test'+UserInfo.getOrganizationId()+'@testCredit.com',
            email = 'test@test.com',
            Branch_Code__c  = '1111'
        ),true);
        Field_Investigation__c fi = (Field_Investigation__c)TestFactory.createSObject((new Field_Investigation__c( 
            Name = 'Test FI',
            Loan_Application__c =loanAppl.Id,
            Applicant__c=appl.Id,
            FI_Status__c ='In Progress',
            Applicant_Type__c='Applicant',
            Credit_Manager__c = usr.Id)),true);
        //Field_Investigation__c fi =[Select Id,name from Field_Investigation__c limit 1];
        fi.Name+='test';
        fi.FI_Status__c = 'Negative';
        fi.Re_Trigger__c = true;
        update fi;
        Map<Id,Id> userMap = new Map<Id,Id>();
        userMap.put(fi.Id, usr.Id);
        FieldInvestigationService.deleteShareFIRecords(userMap);
        Test.stopTest();
    }
}