@IsTest
public class COMShareApplicationRecordHandlerTest {
    @testSetup
    static void testDataSetup() {
        Group qGroup=new Group(Name='Test Queue',Type='Queue');
        insert qGroup;
        QueuesObject q= new QueuesObject (SobjectType='Loan_Application__c',QueueId=qGroup.id);
        insert q;
         
    }
    
    @isTest
    public static void testPublishCOMPlatformEventRecords() {
        String groupId = [SELECT Id from Group Where NAME='Test Queue' LIMIT 1][0].Id;
        Account accRec = (Account)TestFactory.createSObject(new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId(),
            Name = 'Test Account',
            Branch_Queue__c = groupId//'00G6s000001TiSyEAK'
        ),true);
        
        AccountTeamMember atmRec = (AccountTeamMember)TestFactory.createSObject(new AccountTeamMember(
            AccountId = accRec.Id,
            TeamMemberRole  ='Com',
            UserId = UserInfo.getUserId(),
            AccountAccessLevel = 'Read',
            CaseAccessLevel = 'Read',
            ContactAccessLevel = 'Read',
            OpportunityAccessLevel = 'Read'
        ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c = '10201',
            ROI__c = 17.0,
            EMI__c = 13,
            Branch_Master__c = accRec.Id,
            Stage__c = 'DDE'
        ),true);
        
        
        /*
        Account acc = [SELECT Id, Branch_Queue__c FROM Account LIMIT 1];
        acc.Branch_Queue__c = qGroup.id;
        update acc;*/
        
        Set<Id> loanIds = new Set<Id>();
        for(Loan_Application__c appl : [SELECT Id FROM Loan_Application__c]){
            loanIds.add(appl.Id);
        }
        Test.startTest();
        COMShareApplicationRecordHandler.publishCOMPlatformEventRecords(loanIds);
        Test.stopTest();
    }

}