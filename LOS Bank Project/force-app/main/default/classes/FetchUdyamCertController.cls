public with sharing class FetchUdyamCertController {
    @AuraEnabled
    public static String fetchUdyamCertificate(String applicantId){
        String respBody;
        FetchUdyamCertHandler.ResponseWrapper responseWrapper;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper;
        ResponseWrapper completeResponse = new ResponseWrapper();
        try{
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applicantId);
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Fetch Udyam Certificate');
            Map<String,String> reqParam = new Map<String,String>();
            reqParam.put('ApplicantId',applicantId);
            reqParam.put('Channel',objIntMapper.Channel__c);
            String requestBody = FetchUdyamCertHandler.generateRequest(reqParam)[0];
            String objectId = '';
            system.debug('%%'+requestBody);
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
            System.debug('calloutResponseWrapper.statusCode '+calloutResponseWrapper.statusCode);
            completeResponse.calloutResponseWrapper = calloutResponseWrapper;
            if(calloutResponseWrapper.statusCode==200){
                FetchUdyamCertHandler.ResponseWrapper responseWrap = new FetchUdyamCertHandler.ResponseWrapper();
                responseWrap = (FetchUdyamCertHandler.ResponseWrapper) JSON.deserialize(calloutResponseWrapper.response, FetchUdyamCertHandler.ResponseWrapper.class);
                System.debug('responseWrap '+responseWrap);
                if(responseWrap!=null && responseWrap.result.pdfData!=null){
                    ContentVersion cv = new ContentVersion();
                    cv.VersionData = EncodingUtil.base64Decode(responseWrap.result.pdfData);
                    cv.Title = 'Udyam Certificate_'+System.now();
                    cv.PathOnClient = 'Udyam Certificate_'+System.now()+'.pdf';
                    if(Schema.sObjectType.ContentVersion.isCreateable()){
                        insert cv;
                    }
                    ContentDocumentLink cdl = new ContentDocumentLink();
                    cdl.LinkedEntityId = [SELECT Id FROM Document_Checklist__c WHERE Applicant__c=:applicantId AND Document_Master__r.name='AUWheels0021'].Id;
                    cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
                    if(Schema.sObjectType.ContentDocumentLink.isCreateable()){
                        insert cdl;
                    }
                    completeResponse.contentDocument = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id=:cv.Id];
                }
            }
             
        }catch(Exception e){
            Log.error(e,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),applicantId);
        }
        return JSON.serialize(completeResponse);                 
    }

    @AuraEnabled
    public Static ContentVersion getUdyamCertificate(String applicantId){
        List<Document_Checklist__c> docChecklist = [SELECT Id FROM Document_Checklist__c WHERE Applicant__c=:applicantId AND Document_Master__r.name='AUWheels0021' WITH SECURITY_ENFORCED];
        if(!docChecklist.isEmpty()){
            List<ContentDocumentLink> cdl = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:docChecklist[0].Id];
            if(!cdl.isEmpty()){
                List<ContentVersion> cv = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId=:cdl[0].ContentDocumentId ORDER By CreatedDate desc];
                if(!cv.isEmpty()){
                    return cv[0];
                }
            }
        }

        
        return null;

    }

    public Class ResponseWrapper{
        @AuraEnabled public IntegrationUtility.ResponseWrapper calloutResponseWrapper;
        @AuraEnabled public ContentVersion contentDocument;
    }
}