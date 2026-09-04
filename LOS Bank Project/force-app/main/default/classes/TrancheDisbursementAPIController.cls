public with sharing class TrancheDisbursementAPIController {
    
    @AuraEnabled
    public static TrancheDisbursementAPIHandler.TrancheDisbursementResponseWrapper generateTrancheDisbursement(String recordId, Decimal netDisbursementAmount){
        String respBody;
        TrancheDisbursementAPIHandler.TrancheDisbursementResponseWrapper responseWrapper;
        try{
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c = recordId);
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Tranche Disbursement');
            List<Loan_Application__c> loanApps = [SELECT Id, Mode_of_Disbursement__c, Branch_Master__c, 
                                                    Branch_Master__r.Account_Code__c, LAN__c, Schedule_Code__c,
                                                    Disbursement_Date__c, Total_Loan_Amount__c, Narration__c, Disbursement_Session_Id__c,
                                                    Total_Charges__c, OwnerId
                                                    FROM Loan_Application__c WHERE Id=:recordId];
            if(loanApps!=null && loanApps.size()>0){
                String requestBody = TrancheDisbursementAPIHandler.generateRequest(loanApps[0], netDisbursementAmount)[0];
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
                responseWrapper = (TrancheDisbursementAPIHandler.TrancheDisbursementResponseWrapper) JSON.deserialize(respBody, TrancheDisbursementAPIHandler.TrancheDisbursementResponseWrapper.class);
                
            }           
        }catch(Exception e){
            Log.error(e,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),recordId);
        }
        return responseWrapper;                      
    }
}