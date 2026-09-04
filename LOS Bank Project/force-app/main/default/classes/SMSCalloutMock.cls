@isTest
global class SMSCalloutMock implements HttpCalloutMock {
	global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{\"TransactionStatus\":{\"ResponseCode\":\"0\",\"ResponseMessage\":\"Success\",\"ExtendedErrorDetails\":{\"messages\":{\"code\":\"0\",\"message\":\"8190008108:APP-HFTTEST-1675082002467-348-0101:Success\"}}}}');
        res.setStatusCode(200);
        return res;
    }
}