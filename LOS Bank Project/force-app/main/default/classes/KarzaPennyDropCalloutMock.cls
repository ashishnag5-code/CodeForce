@isTest
global class KarzaPennyDropCalloutMock implements HttpCalloutMock{
	
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{  "status-code": "101", "request_id": "1e5a875e-e590-11e7-a842-373db1bff361",  "result": {    "bankTxnStatus": true,   "accountNumber": "352352",    "ifsc": "AUBL0002493" "accountName": "Mr  AUBANK", "bankResponse": "Transaction Successful"  }}');
        res.setStatusCode(200);
        return res;
    }
    
}