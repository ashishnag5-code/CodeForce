@isTest
public with sharing class KarzaElectricityBillControllerTest {
    
    public class ElectricityBillCallout implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            if (req.getEndpoint().contains('KarzaElectricityBill')) {
                res.setBody('{"status_code": "101","request_id": "4112f27e-f41f-43c9-825a-02c226de50c5","result": {"address": "SHOP IN-217-A G/F F/P SHAHPUR JAT NEW DELHI 110049","amount_payable": "2730.00","bill_amount": "","bill_date": "","bill_due_date": "20-05-2019","bill_issue_date": "","bill_no": "","consumer_name": "SHRI BHAGWAN","consumer_number": "102452589","email_address": "rahulpanwar04@gmail.com","mobile_number": "9268920233","total_amount": ""}}');
            } else{
                res.setBody('{"RequestId" : "50f29fae-5dfd-4b1c-82c5-664a392d328b","Result" : {"Score" : "1.0","Match" : "True"},"StatusCode" : "101"}'); 
            } 
            return res;
        }
    }

    @TestSetup
    public static void makeData(){
        Integration_Master__c intMaster = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name  = 'Karza Electricity Bill',
            Apiuser__c = 'SFDC',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/KarzaElectricityBill?',
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

        Document_Master__c master = new Document_Master__c(Document_Name__c  = 'Electricity Bill');
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
    public static void testElectricityControllerMethod1(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ElectricityBillCallout());
        KarzaElectricityBillHandler.KarzaElectricityBillResponseWrapper response = new KarzaElectricityBillHandler.KarzaElectricityBillResponseWrapper();
        Id loanAppl = [SELECT Id FROM Loan_Application__c].Id;
        Id appl = [SELECT Id FROM Applicant__c].Id;
        String strResponse;
        strResponse = KarzaElectricityBillController.karzaElectricityBillCallOut('8784876',appl,loanAppl,'serviceprovider123');
        Test.stopTest();

    }
    /*
    @isTest
    public static void testElectricityControllerMethod2(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ElectricityBillCallout());
        KarzaElectricityBillHandler.KarzaElectricityBillResponseWrapper karzaResponse = new KarzaElectricityBillHandler.KarzaElectricityBillResponseWrapper();
        karzaResponse.status_code='101';
        karzaResponse.request_id='NHY7655';
        karzaResponse.result = new KarzaElectricityBillHandler.KarzaElectricityBillResult();
        karzaResponse.result.address = 'SHOP IN-217-A G/F F/P SHAHPUR JAT NEW DELHI 110049';
        karzaResponse.result.amount_payable='2730.00';
        karzaResponse.result.bill_amount = '';
        karzaResponse.result.bill_date = '';
        karzaResponse.result.bill_due_date = '20-05-2019';
        karzaResponse.result.bill_issue_date = '';
        karzaResponse.result.consumer_name = 'ABC';
        karzaResponse.result.consumer_number = '2374';
        karzaResponse.result.email_address = '';
        karzaResponse.result.mobile_number = '';
        karzaResponse.result.total_amount = '';
        Id loanAppl = [SELECT Id FROM Loan_Application__c].Id;
        Id appl = [SELECT Id FROM Applicant__c].Id;
        LOSKarzaAddressMatchIntHandler.AddressMatchResponseWrapper objWrapper = KarzaElectricityBillController.addressmatch(karzaResponse,appl,loanAppl);
        Test.stopTest();
    }*/
    
}