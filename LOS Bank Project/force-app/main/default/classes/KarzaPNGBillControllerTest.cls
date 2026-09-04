@isTest
public with sharing class KarzaPNGBillControllerTest {
    
    public class PNGBillCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            system.debug('req.getEndpoint()'+req.getEndpoint());
            if (req.getEndpoint().contains('KarzaPNGAuth')) {
                res.setBody('{"status-code": "101","request_id": "6e45c3be-d901-11e7-a52b-637127438281","result": {"Bill_No": "R201710675351","Due_Date": "31/10/2017","Bill_Amount": "357.0000","mobile": "9925111620","Customer_Address": "SHOP IN-217-A G/F F/P SHAHPUR JAT NEW DELHI 110049","Bill_Date": "20171016","Email": "dishantm.gajjar@adani.com","Customer_Name": "Dishant Gajjar"}}');
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
            Name  = 'Karza PNG Bill',
            Apiuser__c = 'SFDC',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/KarzaPNGAuth?',
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

        Document_Master__c master = new Document_Master__c(Document_Name__c  = 'PNG Bill');
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
    public static void testPNGControllerMethod1(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PNGBillCallout());
        KarzaPNGBillHandler.KarzaPNGBillResponseWrapper response = new KarzaPNGBillHandler.KarzaPNGBillResponseWrapper();
        Id loanAppl = [SELECT Id FROM Loan_Application__c].Id;
        Id appl = [SELECT Id FROM Applicant__c].Id;
        String strResponse;
        strResponse = KarzaPNGBillController.karzaPNGBillCallOut('8784876',appl,loanAppl,'service12');
        Test.stopTest();

    }
/*
    @isTest
    public static void testPNGControllerMethod2(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PNGBillCallout());
        KarzaPNGBillHandler.KarzaPNGBillResponseWrapper karzaResponse = new KarzaPNGBillHandler.KarzaPNGBillResponseWrapper();
        karzaResponse.status_code = '101';
        karzaResponse.request_id = '3874jhgp';
        karzaResponse.result = new KarzaPNGBillHandler.KarzaPNGBillResult();
        karzaResponse.result.Bill_No = 'kjes327468';
        karzaResponse.result.Due_Date = '31/10/2017';
        karzaResponse.result.Bill_Amount = '876';
        karzaResponse.result.Customer_Address = 'Goa 887';
        karzaResponse.result.mobile = '8748347854';
        karzaResponse.result.Bill_Date = '';
        karzaResponse.result.Email = '';
        karzaResponse.result.Customer_Name = 'Naruto';
        Id loanAppl = [SELECT Id FROM Loan_Application__c].Id;
        Id appl = [SELECT Id FROM Applicant__c].Id;
        LOSKarzaAddressMatchIntHandler.AddressMatchResponseWrapper objWrapper = KarzaPNGBillController.addressmatch(karzaResponse,appl,loanAppl);
        Test.stopTest();

    }*/
}