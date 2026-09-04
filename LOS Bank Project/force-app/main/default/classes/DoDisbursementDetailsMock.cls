@isTest
public with sharing class DoDisbursementDetailsMock implements HttpCalloutMock{

    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"TransactionStatus":{"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":[{"code":0},{"code":0}]}},"LoanBalanceResponse":{"CustomerShortName":"Ritesh","AccountCurrency":"1","MaturityDate":"2024-08-10","AccountStatus":6,"NextDueDate":"2023-07-10","NextInstallmentDueAmount":7364,"PrincipalBalance":0,"AmountDisbursedToday":95697,"InstallmentArrears":0,"OtherArrears":0,"MinAmountDue":0,"UncollectedInterest":0,"PenaltyArrears":0,"UnbilledPenaltyInterest":0,"UnbilledServiceCharge":0,"AmountPaidToday":0,"RpaBalance":0,"UnbilledInterest":0,"UnclearedFunds":0,"AvailableBalance":4303,"TotalOutstandings":95697}}');
        res.setStatusCode(200);
        return res;
    }

}