@isTest
global class odLimitInquiryCalloutMock implements HttpCalloutMock  {

    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{\"TransactionStatus\":{\"ResponseCode\":\"0\",\"ResponseMessage\":\"Success\",\"ExtendedErrorDetails\":{\"messages\":[{\"code\":\"0\",\"message\":null}]},\"ValidationErrors\":[{\"ApplicableAttributes\":null,\"AttributeName\":null,\"AttributeValue\":null,\"ErrorCode\":null,\"ErrorMessage\":null}]},\"accountNo\":\"2206210944321296\",\"OverdraftDetails\":[{\"limitNo\":\"1\",\"OverdraftDetail\":{\"codIntIndex\":\"12203\",\"drawingPower\":10000,\"endDate\":\"20230131\",\"fixedInterestRate\":13.75,\"flgInternalFD\":\"N\",\"internalAccountVariance\":0,\"isSecured\":\"N\",\"limitAgainstSalary\":\"N\",\"limitAmount\":10000,\"limitNo\":\"1\",\"limitVariance\":0,\"netInterestRate\":13,\"nextexpiryDate\":\"18000101\",\"reason\":\"0\",\"renewalMode\":\"NONE\",\"startDate\":\"20221229\"},\"TermDepositCollateral\":{\"accountId\":null,\"collateralCode\":0,\"collateralType\":null,\"collateralValue\":null,\"depositId\":0,\"description\":null,\"isInterestRateChangePropagated\":null,\"lendableMargin\":null}}]}');
        res.setStatusCode(200);
        return res;
    }
}