public class LOSMobileOtpController {
    
    @AuraEnabled 
    public static String mobileOtpVerificationHandler(String mobileNumber,String otp,String objectId,String otpValue) {
        Integration_Master__c objIntMapper =IntegrationUtility.getIntegrationMasterRecord(otpValue);
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = objectId
           );// Id = objectId 
        String respBody;
        //JUL 31
        String previousRequestId='';
        if(otpValue == 'Mobile Validate OTP'){
            Integration_Checklist__c intCheckList = [SELECT id,name,Request__c,Integration_Master__r.Name
                                                     FROM Integration_Checklist__c
                                                     WHERE (Integration_Master__r.Name = 'Mobile Generate OTP' OR  Integration_Master__r.Name ='Mobile Resend OTP') ORDER BY CreatedDate DESC LIMIT 1];

            Map<String,Object> request = (Map<String,Object>) JSON.deserializeUntyped(intCheckList.Request__c);
            previousRequestId = String.valueOf(request.get('requestId'));
            previousRequestId = previousRequestId.replace('_','');
        }
        //END
        String requestBody = createRequestBody(otpValue,mobileNumber,otp,objIntMapper,previousRequestId);
         IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
        calloutRequestWrapper.masterRecord = objIntMapper;
         calloutRequestWrapper.checklistRecord = checklistRecord;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
        Integration_Checklist__c icRecord = [SELECT Id,Name,Status__c From Integration_Checklist__c Where Id =: calloutResponseWrapper.checklistRecord.Id];
        calloutResponseWrapper.checklistRecord = icRecord;
        respBody = calloutResponseWrapper.response;
         /* if(otpValue == 'Mobile Validate OTP'){
            respBody = '{"RequestStatus":"Success"}';
            return respBody;
        }  */
        
            return JSON.serialize(calloutResponseWrapper);
      
        
    } 
    
    public static String createRequestBody(String requestType,String mobileNumber,String otp,Integration_Master__c objIntMapper,String previousRequestId){
        Map<String,Object> paramMap = new map<String,Object>();
        String requestBody;
        paramMap.put('mobileNumber',mobileNumber);
        paramMap.put('encryptionKey',objIntMapper.Encryption_Key__c);
        paramMap.put('iv',objIntMapper.IV__c);
        if(requestType == 'Mobile Validate OTP'){
            paramMap.put('otp',otp);
            paramMap.put('custRef',previousRequestId);//JUL 31
        }
        requestBody=LOSMobileOtpHandler.generateRequest(paramMap)[0];
        return requestBody;
    }    
}