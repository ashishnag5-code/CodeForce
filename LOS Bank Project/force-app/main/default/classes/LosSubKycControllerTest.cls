@isTest
public with sharing class LosSubKycControllerTest {
   @TestSetup
    static void makeData(){
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Loan_Amount__c  = 12000,
            Product__c='10201',
            Tenure__c=12,
            EMI__c=100,
            ROI__c=0,
            Stage__c='DDE',Repayment_By__c ='Caroline Forbes'
        ),true);  

        Applicant__c applicant = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            loan__c  = loanAppl.Id,
            First_Name__c   = 'Caroline',
            Last_Name__c  = 'Forbes',
            RecordtypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId(),
            Total_Exposure__c  = 12000
        ),true);
    }


    @isTest
    public static void testgetVisibleFieldsForLoanDetails(){
        Test.startTest();
        Loan_Application__c loan = [SELECT Id, Disbursement_Category__c, Schedule_Type__c from Loan_Application__c LIMIT 1];
        
        Applicant__c app = [SELECT Id FROM Applicant__c LIMIT 1 ];
        Document_Master__c dm = new Document_Master__c();
        dm.Document_ID__c = 'AUWheels0051';
        dm.Document_Name__c ='Aadhaar Card';
        insert dm;
        Document_Checklist__c dc = new Document_Checklist__c();
        dc.Document_Master__c = dm.Id;
        dc.Applicant__c = app.id;
        dc.Loan_Application__c = loan.Id;
        insert dc;
        //LosSubKycController.getApplicant(app.Id); 
        LosSubKycController.getDocumentChecklistId(app.Id);
        Test.stopTest();
    }
}