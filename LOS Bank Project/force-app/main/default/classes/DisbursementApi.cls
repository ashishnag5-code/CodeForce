public with sharing class DisbursementApi {
    
    public String fetchApi(String applcntId, String masterRecord) {
        String respBody;
        
        Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord(masterRecord); 
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applcntId);
        
        String requestBody = generateRequest(applcntId, masterRecord);
        system.debug('%%'+requestBody);
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
        calloutRequestWrapper.masterRecord = objIntMapper;
        calloutRequestWrapper.checklistRecord = checklistRecord;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
        system.debug('calloutResponseWrapper '+calloutResponseWrapper);
        respBody = calloutResponseWrapper.response;
  
        return respBody;
    }

    public String generateRequest(String applicantId, String masterRecord) {
        
        return null;
    }

    public class DisbursementApiWrappper {
        @AuraEnabled public String AuthToken;
        @AuraEnabled public String LoanReferenceNumber;
        @AuraEnabled public String ApplicationStatus;
        @AuraEnabled public String LastUpdatedOn;
        @AuraEnabled public String ApprovedTenure;
        @AuraEnabled public String ApprovedLoanAmount;
        @AuraEnabled public String LoanTypeId;
        @AuraEnabled public String ApplicantId;
        @AuraEnabled public String ProcessingFee;
        @AuraEnabled public String Address;
        @AuraEnabled public String PinCode;
        @AuraEnabled public String CustomerID;
        @AuraEnabled public String LoanaccountNumber;
        @AuraEnabled public List<Productinput> Productinput;   
    }

    public class Productinput {
        @AuraEnabled public String ProductCode;
        @AuraEnabled public String PremiumAmount;
    }
}