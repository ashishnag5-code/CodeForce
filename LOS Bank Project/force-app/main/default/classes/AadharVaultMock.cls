@isTest
public with sharing class AadharVaultMock implements HttpCalloutMock{

    public HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(' {"value":"843880605528"}');
        res.setStatusCode(200);
        return res;
    }

}