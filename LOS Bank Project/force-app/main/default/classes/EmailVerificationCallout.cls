@isTest
global class EmailVerificationCallout implements HttpCalloutMock{

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('https://example.com/example/test', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"result":{"meta":{"params":{"email":"meenakshigoyal286@gmail.com"}},"data":{"disposable":false,"webmail":true,"result":true,"accept_all":false,"smtp_check":true,"regexp":true,"mx_records":true,"email":"meenakshigoyal286@gmail.com"}},"request_id":"822c0fb2-f46e-4184-b7fc-a5eb0d01bda3","status-code":"101"}');
        res.setStatusCode(200);
        return res;
    }
}