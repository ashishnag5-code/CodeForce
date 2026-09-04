@isTest
public with sharing class AddressMatchCalloutMock implements HttpCalloutMock{

    public HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"RequestId" : "50f29fae-5dfd-4b1c-82c5-664a392d328b","Result" : {"Score" : "1.0","Match" : "True"},"StatusCode" : "101"}');
        res.setStatusCode(200);
        return res;
    }

}