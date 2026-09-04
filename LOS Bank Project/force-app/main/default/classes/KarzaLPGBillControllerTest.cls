@isTest
public with sharing class KarzaLPGBillControllerTest {
    
    public class LPGBillCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            if (req.getEndpoint().contains('KarzaLPG')) {
                res.setBody('{"status-code": 101,"request_id": "73cdbde2-80f7-11e7-8f0c-e7e769f70bd1","result": {"status": "Active","ApproximateSubsidyAvailed": "0.0","SubsidizedRefillConsumed": "10","pin": "","ConsumerEmail": "Not Available","DistributorCode": "186834","BankName": "Not Applicable","IFSCCode": "Not Applicable","city/town": "","AadhaarNo": "**** **** 7460","ConsumerContact": "******9349","DistributorAddress": "SHOP NO 1 MANUSMRITI BLDG GR FLOOR TUKARAM NAGAR, 421201","ConsumerName": "MRS SUSHAMA M SHIRHATTI","ConsumerNo": "50431060","DistributorName": "SHIVSHAKTI BHARATGAS AGENCY","BankAccountNo": "Not Applicable","GivenUpSubsidy": "No","ConsumerAddress": "PLNO 125PUSHPA AJANTA NR NANDIVALI TELEPHONE EX THANA MAHARASHTRA Maharas 421201","LastBookingDate": "24-Feb-2017","TotalRefillConsumed": ""}}');
                return res;
            } else{
                res.setBody('{"RequestId" : "50f29fae-5dfd-4b1c-82c5-664a392d328b","Result" : {"Score" : "1.0","Match" : "True"},"StatusCode" : "101"}');
                return res;
            } 
        }
    }

    @TestSetup
    public static void makeData(){
        Integration_Master__c intMaster = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name  = 'Karza LPG Bill',
            Apiuser__c = 'SFDC',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/KarzaLPG?',
            HTTP_Method__c = 'GET',
            API_Key__c = '12345'
        ),true); 

        Integration_Master__c intmassearch1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Karza Address Match',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/KarzaAddressMatchServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);

        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345'
        ),true); 

        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c  = 'Caroline',
            Last_Name__c = 'Forbes',
            Loan__c = loanAppl.Id
        ),true); 

        Address__c address = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c = 'A',
            Address_Line_2__c = 'B',
            Address_Line_3__c = 'C',
            Address_Type__c = 'Current',
            State__c = 'Goa',
            City__c = 'Ponda',
            Pincode__c='403404',
            Applicant__c=appl.Id
        ),true);

        Document_Master__c master = new Document_Master__c(Document_Name__c  = 'Gas Bill');
        insert master;


        Document_Checklist__c doc = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Status__c  = 'Received',
            Document_Verification_Status__c=GlobalConstants.VERIFIED,
            Amount__c   = 1000,
            Applicant__c  = appl.Id,
            Document_Master__c = master.Id
        ),true);
    }

    @isTest
    public static void testLPGControllerMethod1(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LPGBillCallout());
        KarzaLPGBillHandler.KarzaLPGBillResponseWrapper response = new KarzaLPGBillHandler.KarzaLPGBillResponseWrapper();
        Id loanAppl = [SELECT Id FROM Loan_Application__c].Id;
        Id appl = [SELECT Id FROM Applicant__c].Id;
        KarzaLPGBillController.karzaLPGBillCallOut('8784876',appl,loanAppl);
        Test.stopTest();

    }
/*
    @isTest
    public static void testLPGControllerMethod2(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LPGBillCallout());
        KarzaLPGBillHandler.KarzaLPGBillResponseWrapper karzaResponse = new KarzaLPGBillHandler.KarzaLPGBillResponseWrapper();
        karzaResponse.status_code = '101';
        karzaResponse.request_id = 'sjdf766';
        karzaResponse.result = new KarzaLPGBillHandler.KarzaLPGBillResult();
        karzaResponse.result.status = 'Active';
        karzaResponse.result.ApproximateSubsidyAvailed = '0.0';
        karzaResponse.result.SubsidizedRefillConsumed = '10';
        karzaResponse.result.pin = '';
        karzaResponse.result.ConsumerEmail = '';
        karzaResponse.result.DistributorCode = '34535';
        karzaResponse.result.BankName = '';
        karzaResponse.result.IFSCCode = '';
        karzaResponse.result.AadhaarNo = '**** **** 7460';
        karzaResponse.result.ConsumerContact = '******9347';
        karzaResponse.result.DistributorAddress = '767 Raigad';
        karzaResponse.result.ConsumerName = 'Neeta';
        karzaResponse.result.ConsumerNo = '38478';
        karzaResponse.result.DistributorName = 'SHIVSHAKTI BHARATGAS AGENCY';
        karzaResponse.result.BankAccountNo = '';
        karzaResponse.result.GivenUpSubsidy = 'No';
        karzaResponse.result.ConsumerAddress = '8727643';
        karzaResponse.result.LastBookingDate = '24-Feb-2017';
        karzaResponse.result.TotalRefillConsumed = '';
        Id loanAppl = [SELECT Id FROM Loan_Application__c].Id;
        Id appl = [SELECT Id FROM Applicant__c].Id;
        LOSKarzaAddressMatchIntHandler.AddressMatchResponseWrapper objWrapper = KarzaLPGBillController.addressmatch(karzaResponse,appl,loanAppl);
        Test.stopTest();

    }*/
}