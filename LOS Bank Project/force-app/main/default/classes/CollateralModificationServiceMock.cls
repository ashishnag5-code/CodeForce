@isTest
public with sharing class CollateralModificationServiceMock implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"PostingDate":"20221205","CollateralId":"106000900323866","TransactionStatus":{"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":[{"code":0}]}}}');
        res.setStatusCode(200);
        return res;
    }
}