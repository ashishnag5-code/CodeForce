/**
* @description       : 
* @author            : Harshit Goyal | Salesforce
* @group             : 
* @last modified on  : 02-14-2023
* @last modified by  : Harshit Goyal | Salesforce
**/
@RestResource(urlMapping='/BridegAppBiometricAPI/*')
global class LosBiometricRestResource {
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 12-08-2022 
    **/
    @HttpPost
    global static void postAddharDetails(){
        string applicantId ='';
        String xmlString='';
        String uidiResponse ='';
        Map<String,String> bioMetricDataMap = new Map<String,String>();
        try
        {
            RestRequest req = RestContext.request;
            RestResponse res = Restcontext.response;
            system.debug('RequestBody'+req);
            system.debug('RequestBodySTRING'+req.requestBody.toString());
            Boolean isError = false;
            String errorMessage ='';
            Map<String, Object> bidgeAppRequest = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
            if(bidgeAppRequest.containsKey(GlobalConstants.DATA)){
                xmlString = String.valueOf(bidgeAppRequest.get(GlobalConstants.DATA));
            }else{
                isError = true;
                errorMessage= GlobalConstants.BODY_ERROR;
            }
            if(String.isBlank(xmlString)){
                isError = true;
                errorMessage= GlobalConstants.DATA_BLANK;
            }
            if(bidgeAppRequest.containsKey(GlobalConstants.APPLICANT_ID)){
                applicantId = String.valueOf(bidgeAppRequest.get(GlobalConstants.APPLICANT_ID));
            }else{
                isError = true;
                errorMessage= GlobalConstants.APPLICANT_MISSING;
            }
            if(String.isBlank(applicantId)){
                isError = true;
                errorMessage= GlobalConstants.APPLICANT_BLANK;
            }
            if(String.isNotBlank(applicantId)){
                String applicantidCheck = String.escapeSingleQuotes(applicantId);
                Boolean returnValue = ((applicantidCheck.length() == 15 || applicantidCheck.length() == 18) && Pattern.matches('^[a-zA-Z0-9]*$', applicantidCheck));
                system.debug('returnValue'+returnValue);
                if(!returnValue){
                    isError = true;
                    errorMessage= GlobalConstants.APPLICANT_INVALID;
                }
            }
            system.debug('xmlString'+xmlString);
            system.debug('applicantId'+applicantId);
            Dom.Document doc = new Dom.Document();  
            doc.load( xmlString);
            Dom.XMLNode rootElement = doc.getRootElement();  
            system.debug('rootElement'+rootElement.getName());
            system.debug('rootElement.getChildElements()'+rootElement.getChildElements());
            if(rootElement.getChildElements().isEmpty()){
                isError = true;
                ErrorMessage= GlobalConstants.PIDATA_BLANK;
            }
            for ( Dom.XMLNode childElement : rootElement.getChildElements()) {  
                system.debug('childElement'+childElement.getName());
                if(childElement.getName()==GlobalConstants.DEVICE_INFO){
                    bioMetricDataMap.put(GlobalConstants.RDS_ID,childElement.getAttributeValue(GlobalConstants.RDSID, ''));
                    bioMetricDataMap.put(GlobalConstants.RDS_VER,childElement.getAttributeValue(GlobalConstants.RDSVER, ''));
                    bioMetricDataMap.put(GlobalConstants.DP_ID,childElement.getAttributeValue(GlobalConstants.DPID, ''));
                    bioMetricDataMap.put(GlobalConstants.DC,childElement.getAttributeValue(GlobalConstants.DC, ''));
                    bioMetricDataMap.put(GlobalConstants.MI,childElement.getAttributeValue(GlobalConstants.MI, ''));
                    bioMetricDataMap.put(GlobalConstants.MC,childElement.getAttributeValue(GlobalConstants.MC, ''));
                }
                if(childElement.getName()== GlobalConstants.HMAC_CAPTITAL){
                    bioMetricDataMap.put(GlobalConstants.HMAC_SMALL,childElement.getText());
                    
                }
                if(childElement.getName()== GlobalConstants.SKEY){
                    bioMetricDataMap.put(GlobalConstants.SKEYCI,childElement.getAttributeValue(GlobalConstants.CI, ''));
                    bioMetricDataMap.put(GlobalConstants.SKEYVALUE,childElement.getText());
                }
                if(childElement.getName()==GlobalConstants.DATA_CAPITAL){
                    bioMetricDataMap.put(GlobalConstants.DATA_TYPE,childElement.getAttributeValue(GlobalConstants.TYPE, ''));
                    bioMetricDataMap.put(GlobalConstants.DATA_VALUE,childElement.getText());
                }
                
            }
            system.debug('bioMetricDataMap'+bioMetricDataMap);
            system.debug('applicantId'+applicantId);
            if(!isError){
                //String localAddhar = LosBiometricRestResource.getAddharNumberViaToken(applicantId);
                Applicant__c  applicateRecord = [ SELECT Id, Aadhaar_Number__c FROM Applicant__c  WHERE Id = :applicantId  WITH SECURITY_ENFORCED LIMIT 1];
             //   String localAddhar = AadharTokenUtil.getAddharNumberViaToken(applicantId,applicateRecord.Aadhaar_Number__c);
                String response =  AadharTokenUtil.getAddharNumberViaToken(applicantId, applicateRecord.Aadhaar_Number__c);
                IntegrationUtility.ResponseWrapper wrapper = (IntegrationUtility.ResponseWrapper) JSON.deserialize(response,IntegrationUtility.ResponseWrapper.class);
                String localAddhar = wrapper.additionalResponse;
                // UIDAI Server call to verify data recived from Bridege App via Biometric.
                if(String.isNotBlank(localAddhar)){
                    uidiResponse = LOSBiometricKycController.biometricKychMethod(localAddhar,applicantId,'Aadhaar - Biometric',bioMetricDataMap);
                }else{
                    isError = true;
                    // Need to review this error message
                    errorMessage='Aadhar Number is invalid';
                }
                
                system.debug('uidiResponse'+uidiResponse);  
            }

            if(String.isNotBlank(uidiResponse)){
                LOSBiometricInfoData responseData = LOSBiometricKycController.parseResponseXML(uidiResponse);
                if(responseData.status ==GlobalConstants.STATUS_FAIL){
                    isError = true;
                    errorMessage='';
                }
            }
            RestContext.response.addHeader('Content-Type', 'application/json');
            if(isError){
                RestContext.response.responseBody = Blob.valueOf(generateJSON(GlobalConstants.ERROR,errorMessage));
            }else{
               RestContext.response.responseBody = Blob.valueOf(generateJSON(GlobalConstants.SUCCESS,errorMessage)); 
            }
            
            
        }
        catch(Exception objException){
            system.debug('Exception line '+objException.getLineNumber());
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(generateJSON(GlobalConstants.ERROR,objException.getMessage()));
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),applicantId);
        }
    }
    /**
* @description 
* @author Harshit Goyal | Salesforce | 11-27-2022 
* @param Status 
* @param Content 
* @param error 
* @return string 
**/
    private static string generateJSON(String status,String error){
        JSONGenerator jsGen = JSON.createGenerator(true);
        jsGen.writeStartObject();
        jsGen.writeStringField(GlobalConstants.STATUS,status);
        jsGen.writeStringField(GlobalConstants.ERROR, error);
        jsGen.writeEndObject();
        return jsGen.getAsString();
    }
}