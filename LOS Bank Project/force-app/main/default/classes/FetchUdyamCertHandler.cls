public with sharing class FetchUdyamCertHandler {
   
    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Applicant__c applicant;
        Map<String,String> paramsMap=(Map<String,String>)reqParam;
    
        List<Applicant__c> applicants = [SELECT Id, UDYAM_Registration_Number__c FROM Applicant__c WHERE Id=:paramsMap.get('ApplicantId') WITH SECURITY_ENFORCED];
        if(!applicants.isEmpty()){
            applicant = applicants[0];
        }
        RequestWrapper requestWrapper = new RequestWrapper();
        requestWrapper.isPDFRequired = 'Y';
        requestWrapper.channel = paramsMap.get('Channel');
        requestWrapper.guid = IntegrationUtility.getReferenceId();
        requestWrapper.udyamRegistrationNo = applicant.UDYAM_Registration_Number__c;
        requestWrapper.consent = 'Y';
        lstString.add(JSON.serializePretty(requestWrapper, false));  
        return lstString;
    }

    public class RequestWrapper{
        public String isPDFRequired;
        public String channel;
        public String guid;
        public String udyamRegistrationNo;
        public String consent;
    }

    public class ResponseWrapper{
        public String requestId;
        public ResultWrapper result;
        public String statusCode;
    }

    public class ResultWrapper{
        public String udyamRegistrationNo;
        public String dateOfRegistration;
        public String pdfData;
    }
}