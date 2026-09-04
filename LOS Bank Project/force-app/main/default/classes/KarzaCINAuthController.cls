public class KarzaCINAuthController {

    @AuraEnabled
    public static String karzaCINCallOut(String cmpName, String applicantId) {
        String respBody;
        try{
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('CIN Verification');
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applicantId);
            Map<String,Object> reqParam = new Map<String,Object>();
            reqParam.put('companyName',cmpName);
            
            String request = CINAuthHandler.generateRequest(reqParam);
			objIntMapper.End_Point_URL__c+= request;
            String objectId = '';
            system.debug('%%'+objIntMapper.End_Point_URL__c);
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            //calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
            system.debug('calloutResponseWrapper '+calloutResponseWrapper);
            respBody = calloutResponseWrapper.response;
            system.debug('respBody '+respBody);
        }
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),applicantId);
        }
        return respBody;
    }

    @AuraEnabled
    public static String karzaDirectorDetailsCallOut(String cinNumber,String applicantId) {
        String respBody;
        try{
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('MCA Verification');
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applicantId);
            Map<String,Object> reqParam = new Map<String,Object>();
            reqParam.put('consent','Y');
            reqParam.put('cin',cinNumber);
            String requestBody = generateMCARequest.generateRequest(reqParam)[0];
            system.debug('requestBody::'+requestBody);
            String objectId = '';
            system.debug('%%'+objIntMapper.End_Point_URL__c);
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
            system.debug('calloutResponseWrapper director:: '+calloutResponseWrapper);
            respBody = calloutResponseWrapper.response;
            system.debug('respBody '+respBody);
        }
        catch(Exception objException) {
            Log.error(objException,Log.SeverityType.valueOf('High'),applicantId);
        }
        return respBody;
    }

}