@isTest
public class CkycDownloadControllerTest {
    @testSetup
    static void Setup(){
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c = '10201',
            ROI__c = 17.0,
            EMI__c = 13
        ),true);
        
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Mobile_Number__c = '9999999999',
            Aadhaar_Number__c = '9999999999',
            PAN__c = '9999999999',
            Loan__c =loanAppl.Id,
            RecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId()
        ),true);
    }
    @IsTest
    public static void testPDFWrapper() {
        List<Integration_Master__c> IM = new List<Integration_Master__c>();
        List<Applicant__c> lstApplicant = [SELECT Id, Name FROM Applicant__c LIMIT 1];
        
        Integration_Master__c inMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='CKYC Download Authentication',
            End_Point_URL__c='https://service.aubank.in/SFDCKarzaPinCodeService/getDistance',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
            ),false);
        
        IM.add(inMaster);
        insert IM;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new DistanceCalloutMock());
        CkycDownloadController cntrl = new CkycDownloadController('Individual');
        CkycDownloadController.masterRecord = 'CKYC Download Authentication';
        //cntrl.ckycDownloadCallout('123456', '01-02-1980', lstApplicant[0].Id);
        cntrl.generateRequest('123456', '01-02-1980');
        cntrl.downloadCkycResult('123456', '01-02-1980', lstApplicant[0].Id, 'Individual');
        Test.stopTest();
    }
}