@isTest
public with sharing class PaymentRTGSServiceMock implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"SettlementResponse": {"Status": "QueuedTo GPSNEFT","ResponseCodeDescription": "Request Successfully Processed","ResponseCode": "RBAPI00G001","Remarks": "Payment Generated Successfully with ID: 34533","IPHREF": "N069201000000028","Code": "201","TransactionReferenceNumber": "34533"}}');
        res.setStatusCode(200);
        return res;
    }
}