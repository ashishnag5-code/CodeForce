@isTest
public class ConsentInitiateCalloutControllerTest {
    @testSetup static void setup() {
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        
        Account accInstance = (Account)TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            Branch_Queue__c=grp.Id
        ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10301',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Branch_Master__c = accInstance.Id
        ),true);
        Payment__c paymentRec = (Payment__c)TestFactory.createSObject(new Payment__c(
            Beneficiary_Name__c = 'Test',
            Net_Amount__c = 500,
            Loan_Application__c  = loanAppl.Id
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',Existing_Customer__c  = 'Yes',
            CIF_No__c = '576321', Customer_Grade__c = 'NIB',Aadhaar_Number__c = '123412341234',
            Loan__c =loanAppl.Id,Type_of_Employment__c = 'Business',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
        
        Integration_Master__c intmassearch1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Consent-Initiate',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/IPHRTGSPaymentServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
    }
    testmethod static void testCallout1(){
        Test.setMock(HttpCalloutMock.class, new ConsentInitiateCalloutMock());
        Test.startTest();
        ConsentInitiateCalloutController.consentInitiateCallout();
        Test.stopTest();
    }
    testmethod static void testCallout2(){
        Test.setMock(HttpCalloutMock.class, new ConsentInitiateCalloutMock());
        Test.startTest();
        ConsentInitiateCalloutController.consentInitiateCallout2();
        Test.stopTest();
    }
    
    testmethod static void testCalloutRequestWrapper(){
        ConsentInitiateCalloutHandler.AdditionalParamsWrapper ap = new ConsentInitiateCalloutHandler.AdditionalParamsWrapper();
        ap.routingUrl='www.google.com';
        ap.sourceSystem='Google';
        ConsentInitiateCalloutHandler.OptionalParamsWrapper op = new ConsentInitiateCalloutHandler.OptionalParamsWrapper();
        op.consentNotification='Success';
        op.dataNotification='Success';
        op.reportNotification='Success';
        ConsentInitiateCalloutHandler.DataInnerWrapper diw = new ConsentInitiateCalloutHandler.DataInnerWrapper();
        diw.acceptancePolicy='OK';
        diw.employerName='SF';
        diw.facility='None';
        diw.loanAmount='100000';
        diw.loanDuration='5 years';
        diw.loanType='Gold';
        diw.processingType='Free';
        diw.todAllowed='None';
        diw.uploadingScannedStatements='None';
        diw.yearMonthFrom='June';
        diw.yearMonthTo='December';
        ConsentInitiateCalloutHandler.PassThroughParamsWrapper ptpw = new ConsentInitiateCalloutHandler.PassThroughParamsWrapper();
        ptpw.data = diw;
        ptpw.target='Completed';
        
        ConsentInitiateCalloutHandler.ConsentInitiateRequestWrapper tw = new ConsentInitiateCalloutHandler.ConsentInitiateRequestWrapper();
        tw.profileId = 'auBankAA_pl_lending';
        tw.userId= 'ODg5MjUzMjA3OEBhbnVtYXRp';
        tw.txnId = 'f0044333-3747-4323-a872-4d752f92746f';
        tw.fiTypes = new List<String>{'DEPOSIT'};
        tw.returnUrl = 'https://www.acmebank.com/';
        tw.startDate = '01-01-2023';
        tw.endDate = '12-12-2023';
        tw.additionalParams = ap;
        tw.optionalParams = op;
        tw.passThroughParams = new List<ConsentInitiateCalloutHandler.PassThroughParamsWrapper>{ptpw};
    }
    
    private class ConsentInitiateCalloutMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            ConsentInitiateCalloutHandler.ConsentInitiateResposeWrapper objResponse = new ConsentInitiateCalloutHandler.ConsentInitiateResposeWrapper();
            objResponse.consentHandle='consentHandle';
            objResponse.errorCode='errorCode';
            objResponse.errorMessage='errorMessage';
            objResponse.redirectURL='www.google.com';
            objResponse.status='200';
            objResponse.txnId='txnId200';
            res.setBody(JSON.serialize(objResponse));
            res.setStatusCode(200);
            return res;
        }
    }
}