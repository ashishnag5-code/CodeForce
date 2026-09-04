public with sharing class ConsentInitiateCalloutController {
    
    public static void consentInitiateCallout() {
        ConsentInitiateCalloutHandler.ConsentInitiateResposeWrapper responseWrapper;
        try{
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c();
            ConsentInitiateCalloutHandler.ConsentInitiateRequestWrapper tw = new ConsentInitiateCalloutHandler.ConsentInitiateRequestWrapper();
            tw.profileId = 'auBankAA_pl_lending';
            tw.userId= 'ODg5MjUzMjA3OEBhbnVtYXRp';
            tw.txnId = 'f0044333-3747-4323-a872-4d752f92746f';//Test-123-20221110-1  25c01d0c-824c-4f86-aad5-7fa249983847
            tw.fiTypes = new List<String>{'DEPOSIT'};
            tw.returnUrl = 'https://www.acmebank.com/';
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Consent-Initiate');
            Map<String,String> reqParam = new Map<String,String>();
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;            
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.urlParamsMap = null;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            calloutRequestWrapper.request = JSON.serialize(tw);
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
            system.debug('code is here');
            String respBody = calloutResponseWrapper.response;
            system.debug('yash '+respBody);
            Decimal t = (Decimal)JSON.deserialize('100.0',Decimal.Class);
            
        }catch(Exception ex) {
            system.debug('exception '+ex.getStackTraceString());
            
        }
    }
    
    public static void consentInitiateCallout2() {
        try{
            ConsentInitiateCalloutHandler.ConsentInitiateResposeWrapper responseWrapper;
            ConsentInitiateCalloutHandler.ConsentInitiateRequestWrapper tw = new ConsentInitiateCalloutHandler.ConsentInitiateRequestWrapper();
            tw.profileId = 'auBankAA_pl_lending';
            tw.userId= 'ODg5MjUzMjA3OEBhbnVtYXRp';
            tw.txnId = 'Test-123-20221110-1';//Test-123-20221110-1  25c01d0c-824c-4f86-aad5-7fa249983847 f0044333-3747-4323-a872-4d752f92746f
            tw.fiTypes = new List<String>{'DEPOSIT'};
            tw.returnUrl = 'https://www.acmebank.com/';
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setHeader('apikey','49b56941-9972-4250-b26a-a2ea54ccd1de');
            request.setHeader('apiuser','SFDC');
            request.setMethod('POST');
            request.setEndpoint('https://service.aubank.in/SFDCPerfiosFIUAPIService/ConsentInitiation');
            String jsonInp= JSON.serialize(tw);	
            system.debug('yash json '+jsonInp);
            request.setBody(jsonInp);
            request.setTimeout(120000);
            HttpResponse response = http.send(request);
            // If the request is successful, parse the JSON response.
            System.debug('Response ' + response.getBody());
            responseWrapper = (ConsentInitiateCalloutHandler.ConsentInitiateResposeWrapper)JSON.deserialize(response.getBody(),ConsentInitiateCalloutHandler.ConsentInitiateResposeWrapper.class);
            System.debug('Response ' + responseWrapper);
            if(responseWrapper.status == '200'){
                if(responseWrapper.redirectURL!=null){
                    NotificationHandler.sendNotification('Consent Initiated','a016s000003bd5cAAA',String.valueOf(responseWrapper.redirectURL));
                }
            }
            System.debug('Response ' + response.getStatus());
            
        }catch(Exception ex) {
            system.debug('exception '+ex);
        }
    }
    
    
}