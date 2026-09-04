@isTest
public with sharing class FetchUdyamCertControllerTest {
    @TestSetup
    public static void setupData(){
        Integration_Master__c intMaster = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name  = 'Fetch Udyam Certificate',
            Apiuser__c = 'SFDC',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://api.aubankuat.in/sfdckyc/SFDCKarzaUdyamRegistrationService/udhyamAuth',
            HTTP_Method__c = 'GET',
            API_Key__c = '12345'
        ),true); 

        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345'
        ),true); 

        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c  = 'Caroline',
            Last_Name__c = 'Forbes',
            Loan__c = loanAppl.Id
        ),true); 

        Document_Master__c master = new Document_Master__c(Document_Name__c  = 'Udyam Certificate', Name='AUWheels0021');
        insert master;


        Document_Checklist__c doc = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Status__c  = 'Received',
            Document_Verification_Status__c=GlobalConstants.VERIFIED,
            Applicant__c  = appl.Id,
            Document_Number__c='3534',
            Document_Master__c = master.Id
        ),true);
    }

    @isTest
    public static void fetchUdyamCertificateTest(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FetchUdyamCertControllerMockAPI());
        FetchUdyamCertHandler.ResponseWrapper response = new FetchUdyamCertHandler.ResponseWrapper();
        Applicant__c appl = [SELECT Id, First_Name__c FROM Applicant__c];
        FetchUdyamCertController.fetchUdyamCertificate(appl.Id);
        ContentVersion cv = FetchUdyamCertController.getUdyamCertificate(appl.Id);
        System.assertEquals(cv!=null, true,'Success');
        Test.stopTest();

    }
}