public with sharing class CBSStandingInstructionServiceController {
    @AuraEnabled
    public static CBSSIService.CBSSIServiceResponseWrapper callCBSSIApi(Id recordId){
        CBSSIService.CBSSIServiceResponseWrapper responseWrapper = new CBSSIService.CBSSIServiceResponseWrapper();
        try{
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('CBS SI Service');

            List<Loan_Application__c> loanList = [SELECT Id, Branch_Master__c, Branch_Master__r.Account_Code__c, LAN__c, Repayment_Account_Number__c 
            FROM Loan_Application__c WHERE id=:recordId];
            Map<String,Loan_Application__c> reqParam = new Map<String,Loan_Application__c>();
            if(loanList!=null && loanList.size()>0){
                reqParam.put('LoanApplication',loanList[0]);
            }
            String requestBody= CBSSIService.generateRequest(reqParam)[0];
            system.debug('%%'+requestBody);
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c=recordId);
            String objectId = '';
            IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper); 
            String respBody = calloutResponseWrapper.response;
    
            system.debug('respBody '+respBody);
            responseWrapper = (CBSSIService.CBSSIServiceResponseWrapper) JSON.deserialize(respBody, CBSSIService.CBSSIServiceResponseWrapper.class);
        }catch(Exception e) {
            //throw new AuraHandledException(e.getMessage());
            Log.error(e,Log.SeverityType.valueOf('High'),recordId);
        }
        return responseWrapper;
    }
}