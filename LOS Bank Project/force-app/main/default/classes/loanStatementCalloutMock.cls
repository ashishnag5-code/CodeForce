@isTest
global class loanStatementCalloutMock implements HttpCalloutMock{

     global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"AccountStatementDetails": [{"AccountID": "123423234","DebitedAmount": "2510","CreditedAmount": "0","RunningBalance": "2510","RunningTotal": "3642955965.9","TxnDate": "30-JUL-2022","ValueDate": "30-JUL-2022"}]}');
        res.setStatusCode(200);
        return res;
    }
}