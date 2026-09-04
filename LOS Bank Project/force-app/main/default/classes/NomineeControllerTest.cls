@isTest
public with sharing class NomineeControllerTest {
    
    @TestSetup
    static void makeData(){        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Total_Exposure__c  = 12000
        ),true); 

        List<Applicant__c> nominees = new List<Applicant__c>();
        nominees.add(createNomineeRecords('FATHER',30,loanAppl.Id));
        nominees.add(createNomineeRecords('MOTHER',40,loanAppl.Id));
        insert nominees;
    }

    

    public static Applicant__c createNomineeRecords(String relation, Integer percent, Id loanId){
        Applicant__c app = new Applicant__c();
        app.Customer_Name__c='Name';
        app.Profile__c='Service';
        Date newDate = Date.newInstance(1997,10,10);
        app.Dob__c=newDate;
        app.Relationship_with_applicant__c=relation;
        app.Percentage_Share_for_Nomination__c=percent;
        app.Nominee_Address__c='Address 998';
        app.Mobile_Number__c='3749473';
        app.IsInactive__c=false;
        app.Loan__c=loanId;
        app.RecordtypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Nominee').getRecordTypeId();
        return app;
    }

    @isTest
    public static void testupsertData(){
        Test.startTest();
        Id loanId = [select id from Loan_Application__c limit 1].id;
        List<Applicant__c> applicants = [select id, name, Customer_Name__c, Profile__c, Dob__c, Relationship_with_applicant__c, Percentage_Share_for_Nomination__c, Nominee_Address__c, Mobile_Number__c, IsInactive__c, Loan__c, RecordTypeId from Applicant__c];
        NomineeController.upsertData(createNomineeRecords('AUNT',30,loanId), loanId);
        NomineeController.getNomineeDetails(loanId);
        NomineeController.getRelationOptions();
        NomineeController.deleteNominee(applicants[0].Id);
        Test.stopTest();
    }

}