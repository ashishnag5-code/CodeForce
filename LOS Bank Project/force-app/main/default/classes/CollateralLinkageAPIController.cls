public with sharing class CollateralLinkageAPIController {
    public CollateralLinkageAPIController() {

    }

    @AuraEnabled
    public static String callCollateralLinkageCallout(Id recordId){
        CollateralLinkageAPIHandler.CollateralLinkageResponseWrapper linkageWrapper = new CollateralLinkageAPIHandler.CollateralLinkageResponseWrapper ();
        IntegrationUtility.ResponseWrapper calloutResponseWrapper;
        try{
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Collateral Linkage');
            Map<String,String> reqParam = new Map<String,String>();
            reqParam.put('LoanApplication',recordId);
            reqParam.put('Channel',objIntMapper.Apiuser__c);
            String requestBody= CollateralLinkageAPIHandler.generateRequest(reqParam)[0];
            system.debug('%%'+requestBody);
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c=recordId);
            String objectId = '';
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper); 
            /*String respBody = calloutResponseWrapper.response;   
            system.debug('respBody '+respBody);
            linkageWrapper = (CollateralLinkageAPIHandler.CollateralLinkageResponseWrapper) JSON.deserialize(respBody, CollateralLinkageAPIHandler.CollateralLinkageResponseWrapper.class);
            */
        }catch(Exception e) {
            Log.error(e,Log.SeverityType.valueOf('High'),recordId);

        }
        return JSON.serialize(calloutResponseWrapper);
    }
}