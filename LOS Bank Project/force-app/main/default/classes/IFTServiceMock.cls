@isTest
public with sharing  class IFTServiceMock implements HttpCalloutMock{
    Public Integer statusCode;
    public IFTServiceMock(Integer statusCode){
        this.statusCode = statusCode;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        if(statusCode == 102){
            res.setStatusCode(200);
            res.setBody('{"TransactionStatus": {"ResponseCode": "0","ResponseMessage": "Failed"},"ErrorCode": "0","TransactionReferenceNo": "IFT722432123331236"}');
        }else if(statusCode != 200){
            res.setStatusCode(101);
            res.setBody('{"TransactionStatus": {"ResponseCode": "0","ResponseMessage": "Failed"},"ErrorCode": "0","TransactionReferenceNo": "IFT722432123331236"}');
        }else{
            res.setBody('{"TransactionStatus": {"ResponseCode": "0","ResponseMessage": "Success"},"ErrorCode": "0","TransactionReferenceNo": "IFT722432123331236"}');
            res.setStatusCode(200);
        }
        return res;
    }
}