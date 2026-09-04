@isTest
public with sharing class AadharTokenServiceMock implements HttpCalloutMock{

    public HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"TransactionStatus":{"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":[{"code":"0"}]}},"uid_token":"890534009355"}');
        res.setStatusCode(200);
        return res;
    }

}