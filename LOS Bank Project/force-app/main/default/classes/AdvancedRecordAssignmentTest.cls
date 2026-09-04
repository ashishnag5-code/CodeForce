@isTest
public class AdvancedRecordAssignmentTest {
    @testSetup static void setup() {
        Account branchMaster = (Account)TestFactory.createSObject(new Account(
            Name ='Branch M',
            Account_Code__c='21034',
            Purchase_City__c='Jaipur',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Branch').getRecordTypeId()
        ),true);

        Profile prof = [select Id,Name from profile where name = 'Field Investigator'];
        User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
                                                            lastName = 'test2',
                                                            profileId = prof.id,
                                                            username = 'testARA'+UserInfo.getOrganizationId()+'@test.com',
                                                            email = 'test@test.com',
                                                            Branch_Code__c  = '21034'
                                                           ),true);
        Branch_Field_Investigation_Master__c branchFIMaster = (Branch_Field_Investigation_Master__c)TestFactory.createSObject(new Branch_Field_Investigation_Master__c(
            Branch_Name__c =branchMaster.Id,
            FI_Agent__c=usr.Id,
            Is_Active__c=true,
            Pin_Code__c='302026',
            Unique_Id__c='302026-0',
            RecordTypeId=Schema.SObjectType.Branch_Field_Investigation_Master__c.getRecordTypeInfosByDeveloperName().get('Two_Wheeler').getRecordTypeId()
        ),true);

        Branch_Field_Investigation_Master__c branchFIMaster2 = (Branch_Field_Investigation_Master__c)TestFactory.createSObject(new Branch_Field_Investigation_Master__c(
            Branch_Name__c =branchMaster.Id,
            FI_Agent__c=usr.Id,
            Is_Active__c=true,
            Pin_Code__c='302026',
            Unique_Id__c='302026-1',
            RecordTypeId=Schema.SObjectType.Branch_Field_Investigation_Master__c.getRecordTypeInfosByDeveloperName().get('Two_Wheeler').getRecordTypeId()
        ),true);

        AccountTeamMember accTeamMember = (AccountTeamMember)TestFactory.createSObject(new AccountTeamMember(
            TeamMemberRole='Branch Manager', accountId = branchMaster.id, Active__c = true, UserId =usr.id,Zip_Code__c='302026'
        ),true);
    }

    static testmethod void testRoundRobingAssigFieldInvestigationFalse(){
        AdvancedRecordAssignment.lstBranchAndFIMapping = [Select Id,Branch_Name__c,FI_Agent__c,Is_Active__c,Pin_Code__c,Unique_Id__c from Branch_Field_Investigation_Master__c];
        AdvancedRecordAssignment.roundRobingAssigFieldInvestigation('Field_Investigation', new Set<String>{'302026'},'Stage__c');
    }
    static testmethod void testRoundRobingAssigFieldInvestigationTrue(){
        AdvancedRecordAssignment.isRoundRobin = True;
        AdvancedRecordAssignment.lstBranchAndFIMapping = [Select Id,Branch_Name__c,FI_Agent__c,Is_Active__c,Pin_Code__c,Unique_Id__c from Branch_Field_Investigation_Master__c];
        AdvancedRecordAssignment.roundRobingAssigFieldInvestigation('Field_Investigation', new Set<String>{'302026'},'Stage__c');
    }

    static testmethod void testRoundRoundRobingAssigTeamMemberFalse(){
        AdvancedRecordAssignment.isRoundRobin = False;
        AdvancedRecordAssignment.lstAccountTeamMember = [Select Id,UserId,Active__c,accountId,TeamMemberRole,Zip_Code__c from AccountTeamMember];
        AdvancedRecordAssignment.roundRobingAssigTeamMember('Field_Investigation', new Set<String>{'302026'},'Stage__c');
    }

    static testmethod void testRoundRoundRobingAssigTeamMemberTrue(){
        AdvancedRecordAssignment.isRoundRobin = True;
        AdvancedRecordAssignment.lstAccountTeamMember = [Select Id,UserId,Active__c,accountId,TeamMemberRole,Zip_Code__c from AccountTeamMember];
        AdvancedRecordAssignment.roundRobingAssigTeamMember('Field_Investigation', new Set<String>{'302026'},'Stage__c');
    }
}