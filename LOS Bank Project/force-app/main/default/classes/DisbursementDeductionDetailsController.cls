public with sharing class DisbursementDeductionDetailsController {
    
    @AuraEnabled
    public static LoanDisbursementDeductionsApiHandler.DisbursementDeductionResponseWrapper generateDisbursementDeductions(String recordId, Decimal netDisbursementAmount){
        String respBody;
        LoanDisbursementDeductionsApiHandler.DisbursementDeductionResponseWrapper responseWrapper;
        try{
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c = recordId);
            Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Disbursement Deduction Details');
            List<Loan_Application__c> loanApps = [SELECT Id, Branch_Master__c, Branch_Master__r.Account_Code__c, LAN__c, 
                                                    Mode_of_Disbursement__c, Disbursement_Date__c, Total_Loan_Amount__c
                                                    FROM Loan_Application__c WHERE Id=:recordId WITH SECURITY_ENFORCED];
            if(loanApps!=null && loanApps.size()>0){
                String requestBody = LoanDisbursementDeductionsApiHandler.generateRequest(loanApps[0], netDisbursementAmount)[0];
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
                responseWrapper = (LoanDisbursementDeductionsApiHandler.DisbursementDeductionResponseWrapper) JSON.deserialize(respBody, LoanDisbursementDeductionsApiHandler.DisbursementDeductionResponseWrapper.class);
                /*if(responseWrapper!=null && responseWrapper.DeductionDetails!=null && responseWrapper.DeductionDetails.size()>0){
                    Loan_Application__c loan = new Loan_Application__c();
                    loan.Id = recordId;
                    loan.Deduction_Details__c = JSON.serializePretty(responseWrapper.DeductionDetails,false);
                    update loan;
                }*/
            }           
        }catch(Exception e){
            Log.error(e,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),recordId);
        }
        return responseWrapper;                      
    }
}