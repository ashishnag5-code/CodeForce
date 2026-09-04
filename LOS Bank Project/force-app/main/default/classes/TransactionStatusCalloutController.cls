public class TransactionStatusCalloutController {
    
    public static void transactionStatusCallout() {
        try{
            TransactionStatusCalloutHandler.TransactionStatusResponseWrapper responseWrapper;
            TransactionStatusCalloutHandler.TransactionStatusRequestWrapper requestObj = new TransactionStatusCalloutHandler.TransactionStatusRequestWrapper();
            requestObj.txnId = 'Test-123-20221110-1';
            String jsonInput = JSON.serialize(requestObj);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('apikey','49b56941-9972-4250-b26a-a2ea54ccd1de');
            request.setHeader('apiuser','SFDC');
            request.setHeader('content-type', Label.Rest_Integration_Default_ContentType);
            request.setMethod('POST');
            request.setEndpoint('https://service.aubank.in/SFDCPerfiosFIUAPIService/TransactionStatus');
            request.setBody(jsonInput);
            request.setTimeout(120000);
            HttpResponse response = http.send(request);
            // If the request is successful, parse the JSON response.
            System.debug('Response ' + response.getBody());
            responseWrapper = (TransactionStatusCalloutHandler.TransactionStatusResponseWrapper)JSON.deserialize(response.getBody(),TransactionStatusCalloutHandler.TransactionStatusResponseWrapper.class);
            System.debug('Response ' + responseWrapper);
            System.debug('Response ' + response.getStatus());
            
        }catch(Exception ex){
            
        }
    }

}