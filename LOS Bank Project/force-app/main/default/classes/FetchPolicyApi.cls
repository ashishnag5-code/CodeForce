public with sharing class FetchPolicyApi {
    
  public Static List<Applicant__c> getApplicant(String applcntId) {
      List<Applicant__c> applicantList = [SELECT Id,  Mobile_Number__c, DOB__c                                            
                                          FROM Applicant__c 
                                          WHERE Id =:applcntId WITH SECURITY_ENFORCED];
      
      return applicantList;
  }

    public String fetchApi(String applcntId, String masterRecord) {
        String respBody;
        
        Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord(masterRecord); 
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applcntId);
        
        String requestBody = generateRequest(applcntId);
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

    public String generateRequest(String applicantId) {
        
        List<Applicant__c> applicant      = getApplicant(applicantId).size() > 0 ? getApplicant(applicantId) : new List<Applicant__c>();
        Applicant__c applcntObj = applicant[0];

        FetchApiWrapper fetchApiObj = new FetchApiWrapper();
        fetchApiObj.AuthToken       = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9';
        fetchApiObj.MobileNo        = applcntObj.Mobile_Number__c; // '9892800209';
        fetchApiObj.DOB             = String.valueOf(applcntObj.DOB__c); // '11-15-1990'
        fetchApiObj.UniqueID        = IntegrationUtility.getReferenceId();
        String reqObject            = JSON.serialize(fetchApiObj);

        return reqObject;
    }

    @AuraEnabled
    public Static String fetchApiHandler(String applicantId, String masterRecodName){ 

        FetchPolicyApi fetchApiObj = new FetchPolicyApi();
        String fetchApiResp = fetchApiObj.fetchApi(applicantId, masterRecodName);
        return fetchApiResp;
    }

    public class FetchApiWrapper {
     
        @AuraEnabled public String AuthToken;
        @AuraEnabled public String MobileNo;
        @AuraEnabled public String DOB;
        @AuraEnabled public String UniqueID;
    }

    public class FetchApiResponse{
        @AuraEnabled public list<ResponseData> ResponseData{get;set;}
        @AuraEnabled public String ErrorMessage{get;set;}
        @AuraEnabled public String Status{get;set;}
    }

	public class ResponseData{
		@AuraEnabled public String PolicyTerm{get;set;}
		@AuraEnabled public String Premium{get;set;}
		@AuraEnabled public String PPT{get;set;}
		@AuraEnabled public String SumAssured{get;set;}
		@AuraEnabled public String PolicyIssueDate{get;set;}
		@AuraEnabled public String MobileNo{get;set;}
		@AuraEnabled public String PolicyStartDate{get;set;}
		@AuraEnabled public String PersonName{get;set;}
		@AuraEnabled public String PolicyExpiryDate{get;set;}
		@AuraEnabled public String CompanyName{get;set;}
		@AuraEnabled public String Transactiondate{get;set;}
		@AuraEnabled public String ProductName{get;set;}
		@AuraEnabled public String Policycopy{get;set;}
		@AuraEnabled public String PolicyNo{get;set;}
		@AuraEnabled public String UniqueID{get;set;}
	}
}