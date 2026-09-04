@isTest
public class LoanAssignmentTriggerTest {
    @testSetup static void setup() {
        Profile prof = [select Id,Name from profile where name like '%Operations%'];
        Profile prof1 = [select Id,Name from profile where name like '%System Admin%'];

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
        
        User usr1 = (User)TestFactory.createSObject(new User(firstName = 'test1',
            lastName = 'test3',
            profileId = prof.id,
            username = 'test'+UserInfo.getOrganizationId()+'@test1.com',
            email = 'test@test.com',
            Branch_Code__c  = '2103'
        ),true);
         
        Loan_Application__c  loanInstance = (Loan_Application__c  )TestFactory.createSObject(new Loan_Application__c  (
            Name ='TestLoan', OwnerId = usr.Id
        ),true); 
        
        Document_Tracker__c docTrac = (Document_Tracker__c  )TestFactory.createSObject(new Document_Tracker__c  (
            Loan_Application__c = loanInstance.Id
        ),true); 
            
            
        Assignment__c loanassigns=   (Assignment__c  )TestFactory.createSObject(new Assignment__c  (
            Name ='TestAssignment',Loan_Application__c=loanInstance.Id,Status__c='Pending ' , OwnerId = usr.Id
        ),true);  

        Assignment__Share sharedRecord = new Assignment__Share();
        sharedRecord.AccessLevel = 'Read';
        sharedRecord.ParentId = loanassigns.Id;//[Select Id,RecordType.Name from Assignment__c where Loan_Application__c=:objLoanApp.Id AND RecordType.Name = 'Ops - KYC' limit 1].Id;
        sharedRecord.UserOrGroupId = usr1.Id;
        insert sharedRecord;
        
                                                                                                                          
      }
    


    @isTest 
    static void getAccountTeamMemberTest() {
        Test.startTest();
        Assignment__c loanassigns = [SELECT Id,OwnerId,Loan_Application__c,Status__c from Assignment__c];
        User user = [Select Id from User where lastName = 'test3' limit 1];
        loanassigns.Status__c='Complete';
        update loanassigns;    
        
        List<Assignment__c> lstAssignment = new List<Assignment__c>();
        lstAssignment.add(loanassigns);
        LoanAssignmentTriggerService ats=new LoanAssignmentTriggerService(); 
        ats.shareApplicationToOwner(lstAssignment);
            
        Test.stopTest();
    }
    @isTest 
    static void getAccountTeamMemberTest2() {
        Test.startTest();
        LoanAssignmentTriggerService ats=new LoanAssignmentTriggerService();        
        ats.beforeInsert(new List<sObject>() );
        ats.afterUpdate(new List<sObject>() , new Map<Id,sObject>() ,new Map<Id,sObject>() );
        ats.beforeDelete(new Map<Id,sObject>() );
        ats.afterDelete(new Map<Id,sObject>() );
        ats.afterUndelete(new Map<Id,sObject>() );        
        Test.stopTest();
    }
    
}