@isTest
public class DownloadReportCalloutControllerTest {
    testmethod static void downloadAnalysedReportCallout(){
        Test.setMock(HttpCalloutMock.class, new DownloadReportCalloutMock());
        Test.startTest();
        DownloadReportCalloutController.downloadAnalysedReportCallout();
        Test.stopTest();
    }
    private class DownloadReportCalloutMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            DownloadReportCalloutHandler.DownloadReportResponseWrapper objResponse = new DownloadReportCalloutHandler.DownloadReportResponseWrapper();
            objResponse.success = true;
            objResponse.status = 'Success';
            objResponse.txnId = 'true';
            objResponse.errorMessage = 'true';
            objResponse.errorCode = 'true';
            objResponse.timestamp = 'true';
            objResponse.report = 'true';
            String strBody = JSON.serialize(objResponse);
            res.setBody(strBody);
            res.setStatusCode(200);
            return res;
        }
    }
}