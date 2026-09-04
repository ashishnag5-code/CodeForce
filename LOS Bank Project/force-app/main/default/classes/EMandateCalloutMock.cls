@isTest
global class EMandateCalloutMock implements HttpCalloutMock  {
	global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"Status":"Accepted","Description":"Link generated Successfully ","Code":"0"}');
        res.setStatusCode(200);
        return res;
    }
}