@isTest
global class exposureCASACalloutMock implements HttpCalloutMock{

    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "MiniStatement": [{ "TransactionAmount": "11", "TransactionType": "D", "TxnId": "FT-20220415165326461000000-060 ", "Description": "CC Payment via MB-4760-1697031349636820-20220415453236", "RunningTotal": "3642955965.9", "ChequeNumber": null, "ValueDate": "2022-04-15 00:00:00", "TransactionBranch": "2011", "TransactionDate": "2022-04-15 16:53:26" }]}');
        res.setStatusCode(200);
        return res;
    }
}