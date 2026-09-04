public class DownloadReportCalloutController {
    
    public static void downloadAnalysedReportCallout(){
        try{
            DownloadReportCalloutHandler.DownloadReportResponseWrapper responseWrapper;
            DownloadReportCalloutHandler.DownloadReportRequestWrapper requestObj = new DownloadReportCalloutHandler.DownloadReportRequestWrapper();
            requestObj.txnId = 'f0044333-3747-4323-a872-4d752f92746f';
            requestObj.type = 'INSIGHTS';
            requestObj.format = 'xlsx';
            String jsonInput = JSON.serialize(requestObj);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('apikey','49b56941-9972-4250-b26a-a2ea54ccd1de');
            request.setHeader('apiuser','SFDC');
            request.setHeader('content-type', Label.Rest_Integration_Default_ContentType);
            request.setMethod('POST');
            request.setEndpoint('https://service.aubank.in/SFDCPerfiosFIUAPIService/DownloadAnalysedReport');
            request.setBody(jsonInput);
            request.setTimeout(120000);
            HttpResponse response = http.send(request);
            // If the request is successful, parse the JSON response.
            System.debug('Response ' + response.getBody());
            responseWrapper = (DownloadReportCalloutHandler.DownloadReportResponseWrapper)JSON.deserialize(response.getBody(),DownloadReportCalloutHandler.DownloadReportResponseWrapper.class);
            System.debug('Response ' + responseWrapper);
            System.debug('Response ' + response.getStatus());
            
        }catch(Exception ex){
            
        }
    }

}