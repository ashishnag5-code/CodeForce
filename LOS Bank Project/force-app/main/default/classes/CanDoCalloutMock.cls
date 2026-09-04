@isTest
global class CanDoCalloutMock implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{\"Status\":\"Success\",\"RequestNo\":\"4WCAN295244655\"}');
        res.setStatusCode(200);
        return res;
    }
}