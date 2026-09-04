global class TransactionStatusCalloutMockTest implements HttpCalloutMock {
	public string checkTestMethod;
    
    public TransactionStatusCalloutMockTest() {
        this.checkTestMethod = 'transactionStatus';
    }
    public TransactionStatusCalloutMockTest(String checkTestMethod) {
        this.checkTestMethod = checkTestMethod;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        if(checkTestMethod == 'transactionStatus') {
            transactionStatusMethod(res);          
        }
        if(checkTestMethod == 'trancheDisbursementAPI') {
            //trancheDisbursementAPIMethod(res);
            transactionStatusMethod(res);        
        }
        return res;
    }
    
    public HttpResponse transactionStatusMethod(HttpResponse res) {
        res.setHeader('Content-Type', 'application/json');
        TransactionStatusCalloutHandler.TransactionStatusResponseWrapper responseObj = new TransactionStatusCalloutHandler.TransactionStatusResponseWrapper();
        responseObj.success = true;
        responseObj.status = 'SUCCESS';
        responseObj.txnId = 'Test-123-20221110-1';
        responseObj.errorMessage = null;
        responseObj.errorCode = null;  
        responseObj.timestamp = '';
        res.setBody(JSON.serialize(responseObj));
        res.setStatusCode(200); 
        return res;
    }
    /*public HttpResponse trancheDisbursementAPIMethod(HttpResponse res) {
        res.setHeader('Content-Type', 'application/json');
        TrancheDisbursementAPIHandler.TrancheDisbursementResponseWrapper responseObj = new TrancheDisbursementAPIHandler.TrancheDisbursementResponseWrapper();
        TrancheDisbursementAPIHandler.TransactionStatusWrapper objTSW = new TrancheDisbursementAPIHandler.TransactionStatusWrapper();
        objTSW.ResponseCode = '200';
        objTSW.ResponseMessage='SUCCESS';
        responseObj.HostDisbursementSessionId = 123232313;
        responseObj.TransactionStatus = objTSW;
        res.setBody(JSON.serialize(responseObj));
        res.setStatusCode(200); 
        return res;
    }*/
}