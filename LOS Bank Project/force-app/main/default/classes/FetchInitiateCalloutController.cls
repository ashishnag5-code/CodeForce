public with sharing class FetchInitiateCalloutController {
    
    public static void fetchInitiateCallout(){
        try{
            FetchInitiateCalloutHandler.FetchInitiateResponseWrapper responseWrapper;
            FetchInitiateCalloutHandler.FetchInitiateRequestWrapper requestObject = new FetchInitiateCalloutHandler.FetchInitiateRequestWrapper();
            List<FetchInitiateCalloutHandler.AccountInnerWrapper> accWrapper = new List<FetchInitiateCalloutHandler.AccountInnerWrapper>();
            accWrapper.add(new FetchInitiateCalloutHandler.AccountInnerWrapper('ACME-FI','fKL3ShXRFROjqfhl','DEPOSIT'));
            requestObject.accounts = accWrapper;
            requestObject.profileId = 'auBankAA_pl_lending';
            requestObject.txnId = 'Test-123-20221110-1';
            requestObject.userId = 'ODg5MjUzMjA3OEBhbnVtYXRp';
            String jsonInput = JSON.serialize(requestObject);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('apikey','49b56941-9972-4250-b26a-a2ea54ccd1de');
            request.setHeader('apiuser','SFDC');
            request.setHeader('content-type', Label.Rest_Integration_Default_ContentType);
            request.setMethod('POST');
            request.setEndpoint('https://service.aubank.in/SFDCPerfiosFIUAPIService/FetchInitiation');
            request.setBody(jsonInput);
            request.setTimeout(120000);
            HttpResponse response = http.send(request);
            // If the request is successful, parse the JSON response.
            System.debug('Response ' + response.getBody());
            responseWrapper = (FetchInitiateCalloutHandler.FetchInitiateResponseWrapper)JSON.deserialize(response.getBody(),FetchInitiateCalloutHandler.FetchInitiateResponseWrapper.class);
            System.debug('Response ' + responseWrapper);
            System.debug('Response ' + response.getStatus());
            
        }catch(Exception ex){
            system.debug('exception '+ex);
        }
    }

}