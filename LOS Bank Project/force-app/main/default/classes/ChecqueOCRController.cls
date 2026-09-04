public with sharing class ChecqueOCRController {
    @AuraEnabled
    public static String chequeOcrCallOut(String loanAppId, String file64) {
        String respBody;
        
        Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord('Cheque OCR'); 
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c  = loanAppId);
        
        String requestBody = generateRequest(file64);

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

    public static String generateRequest(String file64){

        ChequeOcrRequestWrapper requestWrapper = new ChequeOcrRequestWrapper();
        requestWrapper.RequestId = IntegrationUtility.getReferenceId();
        requestWrapper.Channel = Label.ChequeOCRChannel;       
        requestWrapper.fileB64 = file64;
        String req = JSON.serialize(requestWrapper);
        return req;
    }

    public static void chqueOcrHandler(String applicantId, String masterRecord, String file64) {
        //ChecqueOCRController obj = new ChecqueOCRController();
        String ocrResponse = ChecqueOCRController.chequeOcrCallOut(applicantId, file64);
    }

    public class ChequeOcrRequestWrapper {
        @AuraEnabled public String RequestId;
        @AuraEnabled public String Channel;
        @AuraEnabled public String fileB64;
    }

    public class ChequeOcrResponseWrapper {
        public Result result;
        public String requestId;	//06586b54-2d9d-4807-ba98-e83d8c38e128
        public Integer statusCode;	//101      
    }

    public class Result {
        public BankDetails bankDetails;
        public String bank;	//ICICI BANK LIMITED
        public String chequeNo;	//100831
        public String accNo;	//
        public String micr;	//500229009
        public Name[] name;
        public String ifsc;	//ICIC0006308
    }
    public class BankDetails {
        public String address;	//KHARKHANA
        public String city;	//HYDERABAD, SECUNDERABAD CANTONMENT
        public String contact;	//0
        public String district;	//HYDERABAD
        public String state;	//ANDHRA PRADESH
        public String branch;	//KHARKHANA
    }
    public class Name {
    }
}