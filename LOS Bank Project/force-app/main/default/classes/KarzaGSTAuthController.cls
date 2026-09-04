public class KarzaGSTAuthController {

    @AuraEnabled
    public static String karzaGSTCallOut(String gstNum, String applicantId) {
        String respBody;
        try{
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Karza GST Authentication');
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applicantId);
            Map<String,Object> reqParam = new Map<String,Object>();
            reqParam.put('gstin',gstNum);
            
            String requestBody = GSTAuthHandler.generateRequest(reqParam)[0];

            String objectId = '';
            system.debug('%%'+requestBody);
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
            system.debug('calloutResponseWrapper '+calloutResponseWrapper);
            respBody = calloutResponseWrapper.response;
        }
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),applicantId);
        }
        return respBody;
    }

}