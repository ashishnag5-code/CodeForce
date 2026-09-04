@isTest
public without sharing class KarixIntegrationMock implements HttpCalloutMock{
    public HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"statusCode":"200","statusDesc":"Successfully Accepted","shortUrl":"http://1kx.in/DUvfEHO5w4y","requestId":"3112111113122008000","userRef":"9873244393","shortCode":"DUvfEHO5w4y"}');
        res.setStatusCode(200);
        return res;
    }
}