global class CIFCreationControllerMock implements HttpCalloutMock {
    public string checkTestMethod;
    
    public CIFCreationControllerMock() {
        this.checkTestMethod = 'CIF Creation';
    }
    public CIFCreationControllerMock(String checkTestMethod) {
        this.checkTestMethod = checkTestMethod;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        if(checkTestMethod == 'CIF Creation') {
            methodCIFCreation(res);          
        }
        if(checkTestMethod == 'CIF Modification') {
            methodCIFModification(res);        
        }
        return res;
    }
    
    public HttpResponse methodCIFCreation(HttpResponse res) {
        res.setHeader('Content-Type', 'application/json');
        CIFCreationApiHandler.CIFCreationApiResponseWrapper responseObj = new CIFCreationApiHandler.CIFCreationApiResponseWrapper();
        CIFCreationApiHandler.MatchFoundWrapper mFW = new CIFCreationApiHandler.MatchFoundWrapper();
        CIFCreationApiHandler.AddressResponseWrapper mFWarW = new CIFCreationApiHandler.AddressResponseWrapper();
        mFWarW.Country='India';
        mFWarW.Line='L1';
        mFWarW.State='Rajasthan';
        mFWarW.Zip='302026';
        mFW.Address = mFWarW;
        mFW.LeadId = 'LDSA1232';
        mFW.CustomerID = '7070707070';
        
        CIFCreationApiHandler.TransactionStatusWrapper tSW = new CIFCreationApiHandler.TransactionStatusWrapper();
        CIFCreationApiHandler.ExtendedErrorDetailsWrapper tSWEED = new CIFCreationApiHandler.ExtendedErrorDetailsWrapper();
        CIFCreationApiHandler.MessagesWrapper tSWEEDMW = new CIFCreationApiHandler.MessagesWrapper();
        tSWEEDMW.code=200;
        tSWEEDMW.message='SUCCESS';
        tSWEED.messages = new List<CIFCreationApiHandler.MessagesWrapper>{tSWEEDMW};
        
        CIFCreationApiHandler.ValidationErrorsWrapper tSWVEW = new CIFCreationApiHandler.ValidationErrorsWrapper();
        tSWVEW.AttributeName='Kuch Bhi';
        tSWVEW.ErrorMessage='No Error';
        
        tSW.ResponseCode = '200';
        tSW.ResponseMessage='SUCCESS';
        tSW.ExtendedErrorDetails = tSWEED;
        tSW.ValidationErrors = new List<CIFCreationApiHandler.ValidationErrorsWrapper>{tSWVEW};
        
        CIFCreationApiHandler.ErrorsWrapper ew = new CIFCreationApiHandler.ErrorsWrapper();
        CIFCreationApiHandler.ErrorWrapper ewew = new CIFCreationApiHandler.ErrorWrapper();
        ewew.Code = '200';
        ewew.Message = 'SUCCESS';
        ew.Error = ewew;
        
        CIFCreationApiHandler.ApplicantReturnWrapper arw = new CIFCreationApiHandler.ApplicantReturnWrapper();
        arw.CustomerId = 7070;
        arw.LeadId = '7070707070';
        
        responseObj.MatchFound = new List<CIFCreationApiHandler.MatchFoundWrapper>{mFW};
        responseObj.TransactionStatus = tSW;
        responseObj.ServiceExecutionStatus='Active';
        responseObj.Errors = ew;
        responseObj.ApplicantReturn = new List<CIFCreationApiHandler.ApplicantReturnWrapper>{arw};
        res.setBody(JSON.serialize(responseObj));
        res.setStatusCode(200); 
        return res;
    }
    
    public HttpResponse methodCIFModification(HttpResponse res) {
        res.setHeader('Content-Type', 'application/json');
        CIFModificationHandler.CIFModificationApiResponseWrapper responseObj = new CIFModificationHandler.CIFModificationApiResponseWrapper();
        
        
        CIFModificationHandler.TransactionStatusWrapper tSW = new CIFModificationHandler.TransactionStatusWrapper();
        CIFModificationHandler.ExtendedErrorDetailsWrapper tSWEED = new CIFModificationHandler.ExtendedErrorDetailsWrapper();
        CIFModificationHandler.MessagesWrapper tSWEEDMW = new CIFModificationHandler.MessagesWrapper();
        tSWEEDMW.code='200';
        tSWEEDMW.message='SUCCESS';
        tSWEED.messages = tSWEEDMW;
        
        CIFModificationHandler.ValidationErrorsWrapper tSWVEW = new CIFModificationHandler.ValidationErrorsWrapper();
        tSWVEW.AttributeName = 'Kuch Bhi';
        tSWVEW.AttributeValue = 'Kuch Bhi';
        tSWVEW.ErrorCode = '200';
        tSWVEW.ErrorMessage = 'Kuch Bhi';
        
        tSW.ResponseCode='200';
        tSW.ResponseMessage='SUCCESS';
        tSW.ExtendedErrorDetails = tSWEED;
        tSW.ValidationErrors = tSWVEW;
            
        responseObj.TransactionStatus = tSW;
        responseObj.CustomerId = '7070707070';
        res.setBody(JSON.serialize(responseObj));
        res.setStatusCode(200); 
        return res;
    }
}