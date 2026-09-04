@isTest
global class CanDoCancelCalloutMock implements HttpCalloutMock {
	
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Status":"Success","Result":"Lead already cancelled successfully","RequestNo":"4WRTL295519676"}');
        res.setStatusCode(200);
        return res;
    }
    
}