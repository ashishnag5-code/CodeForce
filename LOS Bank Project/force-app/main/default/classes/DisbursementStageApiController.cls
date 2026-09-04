public with sharing class DisbursementStageApiController {
    
    @AuraEnabled
    public static DisbursementStageApiHandler.DisbursementStageResponseWrappper generateDisbursementStage(String recordId, Decimal netDisbursementAmount){
        String respBody;
        DisbursementStageApiHandler.DisbursementStageResponseWrappper responseWrapper;
        try{
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c = recordId);
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Disbursement Stage');
            Map<String,String> reqParam = new Map<String,String>();
            reqParam.put('LoanId',recordId);
            reqParam.put('Channel',objIntMapper.Channel__c);
            //if(loanApps!=null && loanApps.size()>0){
                String requestBody = DisbursementStageApiHandler.generateRequest(reqParam, netDisbursementAmount)[0];
                String objectId = '';
                system.debug('%%'+requestBody);
                IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
                calloutRequestWrapper.request = requestBody;
                calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
                calloutRequestWrapper.masterRecord = objIntMapper;
                calloutRequestWrapper.checklistRecord = checklistRecord;
                IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
                respBody = calloutResponseWrapper.response;
                system.debug('Response Body '+respBody);
                responseWrapper = (DisbursementStageApiHandler.DisbursementStageResponseWrappper) JSON.deserialize(respBody, DisbursementStageApiHandler.DisbursementStageResponseWrappper.class);
                
            //}           
        }catch(Exception e){
            Log.error(e,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),recordId);
        }
        return responseWrapper;                      
    }
}