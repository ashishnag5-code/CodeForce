@isTest
public with sharing class DisbursementDetailsMock implements HttpCalloutMock{

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"TransactionStatus":{"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":[{"code":0}]}},"AccountBranchCode":2100,"AccountProduct":10201,"AccountCurrency":1,"AccountScheduleCode":1021,"AccountTerm":30,"SanctionedAmount":500000,"DisbursementAmount":0,"ScheduleDrawnOn":0,"ProducedId":"0"}');
        res.setStatusCode(200);
        return res;
    }

}