public with sharing class BitlyKarix {


    public static void sendKarixRequest(String phoneNo, String publicURL, String applicantId, String contentVersionId){
        generateKarixRequest(phoneNo,publicURL,applicantId,contentVersionId);
    }

    @future(callout = true)
    public static void generateKarixRequest(String phoneNo, String publicURL, String applicantId, String contentVersionId) {
        Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Karix URL Shortner');
        Map < String, Object > reqParam = new Map < String, Object > ();
        reqParam.put('MobileNumber', phoneNo);
        reqParam.put('Channel', objIntMapper.Apiuser__c);
        reqParam.put('RequestId', IntegrationUtility.getReferenceId());
        reqParam.put('LongURL', publicURL); //https://ausfb2022--dev1.sandbox.my.salesforce.com/sfc/p/6s0000004XUL/a/6s000000GsJ7/qLK57zm2lqdhBwDC9fBVZmNZfX2004EYZfzQzpzE1a0
        String recordId = applicantId;
        String requestBody = NotificationIntegrationHandler.generateShortenURLServiceRequest(reqParam)[0];
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = recordId);
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
        calloutRequestWrapper.masterRecord = objIntMapper;
        calloutRequestWrapper.checklistRecord = checklistRecord;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
        String respBody = calloutResponseWrapper.response;
        system.debug('respBody-->' + respBody);
        NotificationIntegrationHandler.KarixResponseWrapper response;
        if (respBody != null) {
            response = (NotificationIntegrationHandler.KarixResponseWrapper) JSON.deserialize(respBody, NotificationIntegrationHandler.KarixResponseWrapper.class);
        }
	
        //added by pavan to avoid null pointer exception
        if(response<> null && response.shortUrl <> null){
        String shortURL = (String) response.shortUrl;
            contentVersionUpdation(contentVersionId, shortURL);
        }
       
    }


    
    public static void contentVersionUpdation(String recordId, String url) {
        System.debug('shortUrl-->' +url);
        if(String.isNotBlank(recordId)) {
            ContentVersion cvInstance = new ContentVersion();
            cvInstance.ID = recordId;
            cvInstance.Shortend_Public_Url__c = url;
            update cvInstance;
            System.debug('cvInstance-->' +cvInstance);
        }

       

    }

}