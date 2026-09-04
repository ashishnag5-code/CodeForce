@isTest
public with sharing class IBBCalloutMockFail implements HttpCalloutMock{
	public HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status":200,"ForRetailPrice":[868831,893296,911108],"message":"success"}');
        res.setStatusCode(400);
        return res;
    }
}