@isTest
global class CartStatementCalloutMock implements HttpCalloutMock{

     global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"docId":"DOC05221314","status":"Submitted","message":null,"periodStart":null,"periodEnd":null,"documents":null,"fileName":"dea7d4ab-90bf-4fab-95ac-6313c37690b9.json","uploadTime":1684149816473,"ocrFile":false,"fileCount":1,"totalPages":1,"error":false}');
        res.setStatusCode(200);
        return res;
    }
}