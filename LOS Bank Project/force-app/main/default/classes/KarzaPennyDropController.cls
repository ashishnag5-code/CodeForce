public with sharing class KarzaPennyDropController {
    @AuraEnabled
    public static String karzaPennyDropCallOut(String strIFSCCode, String strAccNumber, Id loanAppId) {
        String respBody='';
        KarzaPennyDropHandler.KarzaPennyDropResponseWrapper karzaResponse;
        String returnValue='';
        try{                        
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c();
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Karza Penny Drop');
            Map<String,String> reqParam = new Map<String,String>();
            reqParam.put('consent','Y');
            reqParam.put('IFSC',strIFSCCode);
            reqParam.put('AccNum',strAccNumber);
            reqParam.put('ReqId',IntegrationUtility.getReferenceId());
            reqParam.put('Channel',objIntMapper.Apiuser__c);
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;            
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.urlParamsMap = reqParam;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            System.debug('calloutRequestWrapper->' +calloutRequestWrapper);
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
            respBody = calloutResponseWrapper.response;

            karzaResponse = (KarzaPennyDropHandler.KarzaPennyDropResponseWrapper) JSON.deserialize (respBody, KarzaPennyDropHandler.KarzaPennyDropResponseWrapper.class);
            
            //Notification 
           if(karzaResponse.result!=null && karzaResponse.result.bankResponse == 'Transaction Successful'){ 
                NotificationHandler.sendNotification('Bank account validation for auto payment',loanAppId,'');
               returnValue = karzaResponse.result.accountName;
            }
            System.debug('karzaResponse-->' +karzaResponse.result.accountName);
            //END
        }
        catch(Exception objException) {
            system.debug('Exception occurred '+objException);
        }
        return returnValue;
    }
}