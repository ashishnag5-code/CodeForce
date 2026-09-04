public with sharing class DoDisbursementAPIController {

    @AuraEnabled
    public static String generateDoDisbursement(String recordId, Decimal netDisbursementAmount){
        String respBody;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper;
        DoDisbursementAPIHandler.DoDisbursementResponseWrapper responseWrapper;
        try{
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c = recordId);
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Do Disbursement');
            Map<String,String> reqParam = new Map<String,String>();
            reqParam.put('LoanId',recordId);
            reqParam.put('Channel',objIntMapper.Channel__c);
            reqParam.put('NetDisbursementAmount',String.valueOf(netDisbursementAmount));
            String requestBody = DoDisbursementAPIHandler.generateRequest(reqParam)[0];
            String objectId = '';
            system.debug('%%'+requestBody);
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
            /*respBody = calloutResponseWrapper.response;
            system.debug('Response Body '+respBody);
            responseWrapper = (DoDisbursementAPIHandler.DoDisbursementResponseWrapper) JSON.deserialize(respBody, DoDisbursementAPIHandler.DoDisbursementResponseWrapper.class);
            */           
                
        }catch(Exception e){
            Log.error(e,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),recordId);
        }
        //return responseWrapper;    
        return JSON.serialize(calloutResponseWrapper);             
    }

    //Notification 
    @AuraEnabled
    public static void sendDisbursedNotification(String loanId){
        try {
            NotificationHandler.sendNotification('ON Disbursement',loanId,'');
        } catch (Exception e) {
           System.debug('exception-->' +e);
        }
    }
    //END
}