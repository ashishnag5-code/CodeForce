@isTest
global class BitlyKarixCalloutMock implements HttpCalloutMock{
	global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"userRef": "9963731085","statusDesc": "Successfully Accepted","shortUrl": "http://1kx.in/DUvfZSDP1Dl","requestId": "3110816590957446000","shortCode": "DUvfZSDP1Dl","statusCode": "200"}');
        res.setStatusCode(200);
        return res;
    }

}