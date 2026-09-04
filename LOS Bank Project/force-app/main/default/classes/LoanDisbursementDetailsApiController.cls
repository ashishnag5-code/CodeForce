public with sharing class LoanDisbursementDetailsApiController {
    
    @AuraEnabled
    public static LoanDisbursementDetailsApiHandler.LoanDisbursementResponseWrapper generateLoanDisbursementDetails(String recordId){
        LoanDisbursementDetailsApiHandler.LoanDisbursementResponseWrapper responseWrapper;
        String respBody;
        try{
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c = recordId);
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Disbursement Details');
            List<Loan_Application__c> loanApps = [SELECT Id, Branch_Master__c, Branch_Master__r.Account_Code__c, LAN__c 
                                                    FROM Loan_Application__c WHERE Id=:recordId];
            if(loanApps!=null && loanApps.size()>0){
                String requestBody = LoanDisbursementDetailsApiHandler.generateRequest(loanApps[0])[0];
                String objectId = '';
                system.debug('%%'+requestBody);
                IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
                calloutRequestWrapper.request = requestBody;
                calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
                calloutRequestWrapper.masterRecord = objIntMapper;
                calloutRequestWrapper.checklistRecord = checklistRecord;
                IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
                respBody = calloutResponseWrapper.response;
                responseWrapper = (LoanDisbursementDetailsApiHandler.LoanDisbursementResponseWrapper)JSON.deserialize (respBody, LoanDisbursementDetailsApiHandler.LoanDisbursementResponseWrapper.class);
            }           
        }catch(Exception e){
            Log.error(e,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),recordId);
        }
        return responseWrapper;                      
    }
}