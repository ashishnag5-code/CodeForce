/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 02-14-2023
 * @last modified by  : Harshit Goyal | Salesforce
 * @Logs
 * Last Modified Date	Modified by		User Story/Defect#
 * 16-01-2022			Mohit M.		SFAU-217
**/

public class AadharTokenUtil {
        /**
    * @description 
    * @author Harshit Goyal | Salesforce | 12-08-2022 
    * @param applicantId 
    * @return String 
    **/
    @AuraEnabled
    public static String getAddharNumberViaToken(String applicantId,String strAadhaarToken){
        String msterRecordName = GlobalConstants.SFDC_TOKEN_SERVICE;
        String aadharNumber ='';
        Applicant__c applicateRecord;
        HttpResponse response;
        Savepoint sp;
        Integration_Checklist__c checklistRecord;
        try
        {
            applicateRecord = [
                SELECT Id, Aadhaar_Number__c FROM Applicant__c
                WHERE Id = :applicantId  WITH SECURITY_ENFORCED LIMIT 1];
            Integration_Master__c objIntMapper =IntegrationUtility.getIntegrationMasterRecord(msterRecordName);
            Map<String,String> mapURLQueryParams;
            checklistRecord = new Integration_Checklist__c(Applicant__c = applicateRecord.Id);
            checklistRecord.Integration_Master__c = objIntMapper.Id;
            checklistRecord.Is_Latest__c = true;
            String endPointURL = objIntMapper.End_Point_URL__c;
            endPointURL = endPointURL.replace(GlobalConstants.GUID_VALUE, IntegrationUtility.getReferenceId());
            if(String.isNotBlank(strAadhaarToken)){
                endPointURL = endPointURL.replace(GlobalConstants.TOKEN_VALUE, strAadhaarToken);
            }else{
                endPointURL = endPointURL.replace(GlobalConstants.TOKEN_VALUE, applicateRecord.Aadhaar_Number__c);
            }
            
            endPointURL = endPointURL.replace(GlobalConstants.FORMAT_VALUE,'0');
            /*
            format 0 - for plain text
            format 6 - for masked value
            GUID - unique number
            */
            system.debug('endPointURL'+endPointURL);
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(endPointURL);
            String strContentType = objIntMapper.Content_Type__c;
            request.setHeader('content-type', strContentType);
            if(objIntMapper.Include_Certificate__c) {
                request.setClientCertificateName('sfdc');
            }
            request.setMethod('GET');
            checklistRecord.Request_Initiated_At__c = System.now();
            response = http.send(request);
            if(request.getBodyAsBlob() != null){
                checklistRecord.Request_Size__c = request.getBodyAsBlob().size();
            }
            checklistRecord.Response_Size__c = response.getBodyAsBlob().size();
            checklistRecord.Status__c = 'Completed';
            // If the request is successful, parse the JSON response.
            IntegrationUtility.ResponseWrapper responseInstance = new IntegrationUtility.ResponseWrapper();
          //  checklistRecord.Request__c = JSON.serialize(request);
            checklistRecord.Response__c = response.getBody();
          //  DatabaseUtility.upsertRecords(new List<Integration_CheckList__c>{checklistRecord}, '');
          //  sp = Database.setSavepoint();

            if (response.getStatusCode() == 200) {
                // Deserialize the JSON string into collections of primitive data types.
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                aadharNumber = String.valueOf(results.get(GlobalConstants.VALUE));
                responseInstance.statusCode = response.getStatusCode();
                responseInstance.response = response.getBody();
                responseInstance.status = response.getStatus();
                responseInstance.additionalResponse = aadharNumber;
            }else{
                Integration_Checklist__c icRecord = [SELECT Id,Name,Status__c From Integration_Checklist__c Where Id =: checklistRecord.Id];
                responseInstance.checklistRecord = icRecord;
                responseInstance.additionalResponse = null;
            }
            return JSON.serialize(responseInstance);
        }catch(CalloutException ex) {
            // no logging required here because we're already capturing this in Integration Checklist
            checklistRecord.Response__c = String.valueOf(response);
            checklistRecord.Status__c = 'Failed';
            System.debug('exception--->' +ex.getMessage() +'---' +ex.getLineNumber());
            Log.error(ex, Log.SeverityType.valueOf('High'),null);
            DatabaseUtility.upsertRecords(new List<Integration_CheckList__c>{checklistRecord}, '');
            sp = Database.setSavepoint();
            Database.RollBack(sp);
            throw ex;
        }
        catch(Exception objException){
            system.debug('Exception line '+objException.getLineNumber());
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),applicantId);
            return null;
        }
    }
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 02-14-2023 
    * @param applicantId 
    * @param strAadhaarNumber 
    * @return String 
    **/
    @AuraEnabled
    public static String getTokenViaAddharNumber(String applicantId, String strAadhaarNumber){
        //Applicant__c applicateRecord;
        String aadharToken ='';
        String msterRecordName = 'Aadhar Token Service';
        Applicant__c applicateRecord;
        try
        {
            applicateRecord = [
                SELECT Id, Aadhaar_Number__c FROM Applicant__c
                WHERE Id = :applicantId  WITH SECURITY_ENFORCED LIMIT 1];
            if(String.isBlank(strAadhaarNumber))
                throw new CustomException('Aadhaar Number should not be blank.');
            /*
             * applicateRecord = [
                SELECT Id, Aadhaar_Number__c FROM Applicant__c
                WHERE Id = :applicantId  WITH SECURITY_ENFORCED LIMIT 1];
			*/
            if(applicateRecord.Aadhaar_Number__c != strAadhaarNumber){
                Integration_Master__c objIntMapper =IntegrationUtility.getIntegrationMasterRecord(msterRecordName);
                String respBody;
                String requestBody = generateRequestBody(strAadhaarNumber);
                IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
                calloutRequestWrapper.request = requestBody;
                calloutRequestWrapper.method = 'POST';
                calloutRequestWrapper.masterRecord = objIntMapper;
                Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applicantId);
                calloutRequestWrapper.checklistRecord = checklistRecord;
                IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
                if(calloutResponseWrapper.statusCode == 200){
                    respBody = calloutResponseWrapper.response;
                    system.debug('respBodyAddharToken'+respBody);
                    Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(respBody);
                    system.debug('respBodyAddharToken results'+results);
                    aadharToken = String.valueOf(results.get('uid_token'));
                    calloutResponseWrapper.additionalResponse = aadharToken;
                    return JSON.serialize(calloutResponseWrapper);
                }else{
                    Integration_Checklist__c icRecord = [SELECT Id,Name,Status__c From Integration_Checklist__c Where Id =: calloutResponseWrapper.checklistRecord.Id];
                    calloutResponseWrapper.checklistRecord = icRecord;
                    calloutResponseWrapper.additionalResponse = null;
                    return JSON.serialize(calloutResponseWrapper);
                }
            }
            else{
                IntegrationUtility.ResponseWrapper calloutResponseWrapper = new IntegrationUtility.ResponseWrapper();
                calloutResponseWrapper.additionalResponse = applicateRecord.Aadhaar_Number__c;
                return JSON.serialize(calloutResponseWrapper);
            }

        }catch(Exception objException){
            system.debug('Exception line '+objException.getLineNumber());
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),applicantId);
            return null;
        }
    }
    public static String generateRequestBody(String aadharNumber){
        Applicant__c applicateRecord;
        AadharTokenReqWrapper.headers generateWrap = new AadharTokenReqWrapper.headers();
        generateWrap.sub_client_code = 'AUBANK121';
        generateWrap.actor_type = 'CUSTOMER';
        generateWrap.operation_mode = 'SYSTEM';
        generateWrap.channel_code = 'WEB_APP';
        generateWrap.channel_version = '2.5';
        generateWrap.function_sub_code = 'DEFAULT';
        generateWrap.function_code = 'TOKENIZE';
        generateWrap.run_mode = 'real';
        generateWrap.stan = IntegrationUtility.getReferenceId();
        generateWrap.user_handle_value = 'AUBANK';
        generateWrap.client_ip = '10.57.6.14';  
        generateWrap.location  = null;
        generateWrap.user_handle_type  = 'USERNAME';
        generateWrap.client_code  = 'AUBANK121';
        generateWrap.transmission_datetime  = '1600841904417';
        
        AadharTokenReqWrapper.request generateWrap2 = new AadharTokenReqWrapper.request();
        generateWrap2.ekyc_flag  = 'n';
        generateWrap2.hmac = '';
        generateWrap2.purpose  = 'TOKENIZE';
        generateWrap2.client_ref_number  = IntegrationUtility.getReferenceId();
        generateWrap2.tokenize_data = aadharNumber;
        AadharTokenReqWrapper.Skey skey = new AadharTokenReqWrapper.Skey();
        skey.ci  ='';
        skey.value = '';
        generateWrap2.skey = skey;
        AadharTokenReqWrapper wrapperData = new AadharTokenReqWrapper();
        wrapperData.headers = generateWrap;
        wrapperData.request = generateWrap2;
        wrapperData.RequestId = IntegrationUtility.getReferenceId();
        wrapperData.OriginatingChannel = Label.AdhaarTokenChannel;
        return JSON.serialize(wrapperData);
    }
    
    public class CustomException extends Exception{}
}