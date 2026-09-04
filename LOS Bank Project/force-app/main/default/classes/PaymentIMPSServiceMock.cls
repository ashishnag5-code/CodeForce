@isTest
public with sharing class PaymentIMPSServiceMock implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"TransactionStatusType": {"ResponseCode": "0","ResponseMessage": "Success","ExtendedErrorDetails": {"messages": {"code": "0"}}},"RetrievalReferenceNumber": "122918289825"}');
        res.setStatusCode(200);
        return res;
    }
}