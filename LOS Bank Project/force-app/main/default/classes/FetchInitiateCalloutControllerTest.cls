@isTest
public class FetchInitiateCalloutControllerTest {
	testmethod static void downloadAnalysedReportCallout(){
        Test.setMock(HttpCalloutMock.class, new FetchInitiateCalloutMock());
        Test.startTest();
        FetchInitiateCalloutController.fetchInitiateCallout();
        Test.stopTest();
    }
    private class FetchInitiateCalloutMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            FetchInitiateCalloutHandler.FetchInitiateResponseWrapper objResponse = new FetchInitiateCalloutHandler.FetchInitiateResponseWrapper();
            objResponse.consentHandle = 'true';
            objResponse.redirectURL = ''+URL.getOrgDomainUrl();
            objResponse.status = 'Success';
            objResponse.txnId = ''+Math.random();
            objResponse.errorMessage = 'No Error';
            objResponse.errorCode = '0';
            objResponse.timestamp = ''+System.now();
            String strBody = JSON.serialize(objResponse);
            res.setBody(strBody);
            res.setStatusCode(200);
            return res;
        }
    }
}