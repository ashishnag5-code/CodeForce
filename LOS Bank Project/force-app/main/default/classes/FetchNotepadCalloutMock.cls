@isTest
global class FetchNotepadCalloutMock implements HttpCalloutMock  {
	global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"TransactionStatusType":{"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":{"code":"0"}}},"CustMemoDetails":[{"MemoNumber":"1","EndDate":"20240101","MemoText":"Low sevirity","ReasonForMemo":"0","Severity":"L","StartDate":"20230104"}],"MemoNumber":"1"}');
        res.setStatusCode(200);
        return res;
    }
}