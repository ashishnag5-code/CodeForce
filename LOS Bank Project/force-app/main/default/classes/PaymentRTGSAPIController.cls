public with sharing class PaymentRTGSAPIController {
    
    @AuraEnabled
    public static String doRTGSPayment(String recordId, String paymentFavouringId){
        String respBody;
        PaymentRTGSAPIHandler.PaymentRTGSAPIResponseWrappper responseWrapper;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper;
        try{
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c = recordId,Payment__c = paymentFavouringId);
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Payment RTGS');
            Map<String,String> reqParam = new Map<String,String>();
            reqParam.put('LoanId',recordId);
            reqParam.put('PaymentId',paymentFavouringId);
            reqParam.put('Channel',objIntMapper.Channel__c);
            String requestBody = PaymentRTGSAPIHandler.generateRequest(reqParam)[0];
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
            responseWrapper = (PaymentRTGSAPIHandler.PaymentRTGSAPIResponseWrappper) JSON.deserialize(respBody, PaymentRTGSAPIHandler.PaymentRTGSAPIResponseWrappper.class);
              */              
        }catch(Exception e){
            Log.error(e,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),recordId);
        }
        return JSON.serialize(calloutResponseWrapper);                      
    }
}