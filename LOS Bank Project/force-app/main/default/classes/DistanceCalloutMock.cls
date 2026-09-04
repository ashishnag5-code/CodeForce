@isTest
global class DistanceCalloutMock implements HttpCalloutMock  {
 global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"requestId":"23e527df-1af8-463e-bc1c-35c741f7d19f","result":{"fromPincode":"110075","toPincode":"313011","estDistance":"679","isAcceptable":false},"statusCode":101}');
        res.setStatusCode(200);
        return res;
    }
}