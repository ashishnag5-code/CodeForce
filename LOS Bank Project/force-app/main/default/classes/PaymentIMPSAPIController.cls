public with sharing class PaymentIMPSAPIController {
    
    @AuraEnabled
    public static String doIMPSPayment(String recordId, String paymentFavouringId){
        String respBody;
        PaymentIMPSAPIHandler.PaymentIMPSAPIResponseWrappper responseWrapper;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper;
        try{
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c = recordId,Payment__c = paymentFavouringId);
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Payment IMPS');
            Map<String,String> reqParam = new Map<String,String>();
            reqParam.put('LoanId',recordId);
            reqParam.put('PaymentId',paymentFavouringId);
            reqParam.put('Channel',objIntMapper.Channel__c);
            String requestBody = PaymentIMPSAPIHandler.generateRequest(reqParam)[0];
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
            responseWrapper = (PaymentIMPSAPIHandler.PaymentIMPSAPIResponseWrappper) JSON.deserialize(respBody, PaymentIMPSAPIHandler.PaymentIMPSAPIResponseWrappper.class);            
              */      
        }catch(Exception e){
            Log.error(e,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),recordId);
        }
        return JSON.serialize(calloutResponseWrapper);                      
    }
}