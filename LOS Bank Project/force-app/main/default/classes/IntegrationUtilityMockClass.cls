global class IntegrationUtilityMockClass implements HttpCalloutMock{

    public string checkTestMethod;
    public IntegrationUtilityMockClass(String checkTestMethod) {
        this.checkTestMethod = checkTestMethod;
    }
  
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        if(checkTestMethod == 'nsdlVerificationHandlerUITestMethod') {
            nsdlVerificationHandlerUITestMethod(res);          
        }
        else if(checkTestMethod == 'mobileOtpVerificationHandlerTestMethod') {
            mobileOtpVerificationHandlerTestMethod(res);
        }        
        return res;
    }

    public HttpResponse nsdlVerificationHandlerUITestMethod(HttpResponse res) {
        res.setHeader('Content-Type', 'application/json');
        LOSNsdlResponseWrapper prepareJson = new LOSNsdlResponseWrapper();
        prepareJson.response = new List<LOSNsdlResponseWrapper.Response>();
        LOSNsdlResponseWrapper.Response responseObj = new LOSNsdlResponseWrapper.Response();
        responseObj.Title = 'Mr';
        responseObj.FirstName = 'Anil';
        responseObj.LastName = 'Sharma';
        responseObj.Seeding = 'Y';
        responseObj.Status = 'E';       
        prepareJson.response.add(responseObj);
        res.setBody(JSON.serialize(prepareJson));
        // res.setBody('{"headers" : {"responseCode" : "200", "responseMsg" : "Success"} ,"response" : [{"Title":"Ms","FirstName":"Shanaya","MiddleName":"Sood","LastName":"Kapoor","Status":"Existing and Valid","Seeding":"Y"}]}');
        res.setStatusCode(200); 
        return res;
    }

    public HttpResponse mobileOtpVerificationHandlerTestMethod(HttpResponse res) {
        res.setHeader('Content-Type', 'application/json');
        LOSNsdlResponseWrapper prepareJson = new LOSNsdlResponseWrapper();
        prepareJson.response = new List<LOSNsdlResponseWrapper.Response>();
        LOSNsdlResponseWrapper.Response responseObj = new LOSNsdlResponseWrapper.Response();
        responseObj.Title = 'Mr';
        responseObj.FirstName = 'Anil';
        responseObj.LastName = 'Sharma';
        responseObj.Seeding = 'Y';
        responseObj.Status = 'E';       
        prepareJson.response.add(responseObj);
        res.setBody(JSON.serialize(prepareJson));
        // res.setBody('{"headers" : {"responseCode" : "200", "responseMsg" : "Success"} ,"response" : [{"Title":"Ms","FirstName":"Shanaya","MiddleName":"Sood","LastName":"Kapoor","Status":"Existing and Valid","Seeding":"Y"}]}');
        res.setStatusCode(200); 
        return res;
    }
}