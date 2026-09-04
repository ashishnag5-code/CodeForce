public with sharing class CkycDownloadController {
  //  public static String customMetadataType;
    public static String masterRecord;
    public static String custmerType;

    public CkycDownloadController(String customerType) {
        custmerType = customerType;
        if(customerType == 'Individual') {
            masterRecord = 'CKYC Download Authentication';
        }
        else if(customerType == 'Non Individual'){
            masterRecord = 'CKYC Download Non Individual Authentication';
        }
    }

    public String ckycDownloadCallout(String ckycNumber, String dob, String applicantId) {
        String respBody;    
        
        Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord(masterRecord); 
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applicantId);
        
        String requestBody = generateRequest(ckycNumber, dob);

        system.debug('%%'+requestBody);
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
        calloutRequestWrapper.masterRecord = objIntMapper;
        calloutRequestWrapper.checklistRecord = checklistRecord;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);   
        respBody = calloutResponseWrapper.response;
        system.debug('respBody-- '+respBody);
        return respBody;
    }

    public String generateRequest(String ckycNumber, String dob) {
        
        DownloadRequestWrapper downReqObj = new DownloadRequestWrapper();
        downReqObj.requestId              = IntegrationUtility.getReferenceId();
        downReqObj.dob                    = dob;
        downReqObj.Channel                = 'SFDC';
        downReqObj.ckycnumber             = ckycnumber;
        if(custmerType == 'Non Individual') {
            downReqObj.CustomerType       = 'C';
        }
        String req                        = JSON.serialize(downReqObj, true);
        return req;
    }

    public DownloasUiResponse downloadCkycResult(String ckycNumber, String dob, String applicantId, String customerType){

        CkycDownloadController obj  = new CkycDownloadController(customerType);
        
        String downloadCkycResponse = obj.ckycDownloadCallout(ckycNumber, dob, applicantId);
        DownloasUiResponse uiRespObj        = new DownloasUiResponse();

        if(String.isNotBlank(downloadCkycResponse) && downloadCkycResponse != 'Not Found.') {
            uiRespObj.Response   = (DownloadResponseWrapper) System.JSON.deserialize(downloadCkycResponse, DownloadResponseWrapper.class);
         //   uiRespObj.metadata   = new List<Sobject>();
         //   uiRespObj.metadata   = CkycOnBoardingController.getMetadataRecord(customMetadataType);     
        }
        else if(downloadCkycResponse == 'Not Found.') {
            uiRespObj.message = downloadCkycResponse;
        }
        return uiRespObj;
    }

    public class DownloadRequestWrapper {
        @AuraEnabled public String requestId;
        @AuraEnabled public String dob;
        @AuraEnabled public String channel;
        @AuraEnabled public String ckycnumber;
        @AuraEnabled public String CustomerType;
    }

    public class DownloasUiResponse{
          @AuraEnabled public DownloadResponseWrapper Response;
          @AuraEnabled public List<Sobject> metadata;
          @AuraEnabled public String message;
      }

    public class DownloadResponseWrapper {
        @AuraEnabled public PersonalDetails personalDetails;   
        @AuraEnabled public List<Imagedetails> imageDetails;   
        @AuraEnabled public List<Identitydetails> identityDetails;   
        @AuraEnabled public String message;
        @AuraEnabled public String error_cd;      
    }

    public class PersonalDetails {
        @AuraEnabled public String FULLNAME;
        @AuraEnabled public String DOB;
        @AuraEnabled public String GENDER;
        @AuraEnabled public String MOB_NUM;
        @AuraEnabled public String FATHER_FULLNAME;
        @AuraEnabled public String MOTHER_FULLNAME;
        @AuraEnabled public String MARITAL_STATUS;
        @AuraEnabled public String CORRES_LINE1;
        @AuraEnabled public String CORRES_LINE2;
        @AuraEnabled public String CORRES_LINE3;
        @AuraEnabled public String CORRES_CITY;
        @AuraEnabled public String CORRES_DIST;
        @AuraEnabled public String CORRES_STATE;
        @AuraEnabled public String CORRES_COUNTRY;
        @AuraEnabled public String CORRES_PIN;
        @AuraEnabled public String PERM_LINE1;
        @AuraEnabled public String PERM_LINE2;
        @AuraEnabled public String PERM_LINE3;
        @AuraEnabled public String PERM_CITY;
        @AuraEnabled public String PERM_DIST;
        @AuraEnabled public String PERM_STATE;
        @AuraEnabled public String PERM_COUNTRY;
        @AuraEnabled public String PERM_PIN;
        @AuraEnabled public String OFF_TEL_NUM;
        @AuraEnabled public String EMAIL;
        @AuraEnabled public String OCCUPATION;
        @AuraEnabled public String PERM_POA;
        @AuraEnabled public String CONSTI_TYPE;
    }

    public class Imagedetails { 
        @AuraEnabled public String IMAGE_CODE;
        @AuraEnabled public String IMAGE_DATA;
    }

    public class Identitydetails { 
        @AuraEnabled public String IDENT_NUM;
        @AuraEnabled public String IDENT_TYPE;
    }
}