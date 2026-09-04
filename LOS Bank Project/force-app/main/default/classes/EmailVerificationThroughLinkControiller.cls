public with sharing class EmailVerificationThroughLinkControiller extends EmailVerificationWrapper {


    public static List<Address__c> applcntAddressLst;

    @AuraEnabled(cacheable=true)
    public static List<Address__c> getApplicantAddress(String applcntId, String addressType) {
        List<Address__c> applcntAddressList = [SELECT Office_Email_address__c, Office_Email_Verification_Status__c
                                               FROM Address__c
                                               WHERE (Applicant__c =: applcntId AND Address_Type__c =: addressType) WITH SECURITY_ENFORCED];
        return applcntAddressList;
    }

    @AuraEnabled
    public static void saveVerifiedEmailStatus(String verify, Address__c addressRec) {

        addressRec.Office_Email_Verification_Status__c = verify;
        system.debug('addressRec before insert--'+addressRec);
        if (Schema.sObjectType.Address__c.isUpdateable()) {
            update addressRec;
        }
        system.debug('addressRec after insert--'+addressRec);      
    }

    @AuraEnabled 
    public static ResponseWrapper emailOtpVerificationHandler( Map<Object, String> params) {

        String masterRecOrRequestType = params.get('masterRecordName');
        Integration_Master__c objIntMapper = IntegrationUtility.getIntegrationMasterRecord(masterRecOrRequestType);
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = params.get('applcntId'));
        String respBody;
        EmailVerificationThroughLinkControiller emailVerifObj = new EmailVerificationThroughLinkControiller();
        String requestBody = emailVerifObj.createRequestBody(params);
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
        calloutRequestWrapper.masterRecord = objIntMapper;
        calloutRequestWrapper.checklistRecord = checklistRecord;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
        respBody = calloutResponseWrapper.response;
        ResponseWrapper responseBody = (ResponseWrapper)JSON.deserialize(respBody, ResponseWrapper.class);

        //Calling Verify Otp Notification
        if(masterRecOrRequestType == 'Verify OTP For Email'){
            //get the loan id
            Applicant__c applicantInstance = [SELECT id,Loan__c 
                                             FROM Applicant__c 
                                             WHERE id=:params.get('applcntId') 
                                             WITH SECURITY_ENFORCED];
            NotificationHandler.sendNotification('Successful Email id verification',applicantInstance.Loan__c,'');
        }
        return responseBody;
        
    }  
    
    public String createRequestBody(Map<Object, String> paramsMap) {
        applcntAddressLst  = new List<Address__c>();
        String requestType = paramsMap.get('masterRecordName');
        String requestBody = '';

        if(requestType == 'Generate OTP For Email') {
            String applcntId   = paramsMap.get('applcntId');
            applcntAddressLst  = getApplicantAddress(applcntId, 'Office');
            requestBody = generateRequestForOtp(paramsMap);
        }
        else if(requestType == 'Verify OTP For Email') {
            requestBody = generateRequestForVerifyOtp(paramsMap);
        }           
        return requestBody;
    }
    
    public String generateRequestForOtp(Map<Object, String> paramsMap) {
        String emailId                     = paramsMap.get('emailId');
        GenerateOtpWrapper generateOtpObj  = new GenerateOtpWrapper();
        generateOtpObj.requestId           = IntegrationUtility.getReferenceId();
        generateOtpObj.channel             = 'SFDC';
        generateOtpObj.email               = emailId;
        String body                        = JSON.serialize(generateOtpObj);
        return body;
    }

    public String generateRequestForVerifyOtp(Map<Object, String> paramsMap) {
        String reqId                       = paramsMap.get('reqId');
        String otpVal                      = paramsMap.get('enterOTPValue');
        VerifyOtpWrapper generateOtpObj    = new VerifyOtpWrapper();
        generateOtpObj.requestId           = reqId;
        generateOtpObj.channel             = 'SFDC';
        generateOtpObj.otp                 =  otpVal;
        String body                        = JSON.serialize(generateOtpObj);
        return body;
    }
}