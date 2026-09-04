/*****
 * Class Name: LOSNsdlController
 * Description: 
 * Test Class Name: LOSNsdlController_Test
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Dec-05-2023          -   Mohit Maheshwari    -   SFAU-5538 - CIF Number related change
 */
public with sharing class LOSNsdlController {
    
    @AuraEnabled
    public static Applicant__c getApplicantDetails(Id recordId){
        // SFAU-5538 - CIF Number related change - Add CIF_No__c and PAN__c in SOQL
        Applicant__c applicantRecord = [Select Id,Customer_Type__c,Dob__c,Voter_Id__c,Passport_Number__c,Driving_License_Id__c,Pan_Form60__c, NPR__c, NREGA__c, KYC_Type__c, KYC_Status__c,First_Name__c,Last_Name__c,Existing_Customer__c, PAN__c, CIF_No__c from Applicant__c where id=:recordId];
        return applicantRecord;
    }

    @AuraEnabled
    public static String nsdlVerificationHandlerUI(String panNumber,String applcntId,String msterRecordName) {
        String response = nsdlVerificationHandler(panNumber, applcntId, msterRecordName);
        system.debug('response-->>'+response);
        //LOSNsdlResponseWrapper.headers header = (LOSNsdlResponseWrapper.headers) System.JSON.deserialize(response, LOSNsdlResponseWrapper.headers.class);
        LOSNsdlResponseWrapper.UIResponse resp = new LOSNsdlResponseWrapper.UIResponse();
        
        // if(header.responseCode == '200'){        
        LOSNsdlResponseWrapper wrapper = LOSNsdlResponseWrapper.parse(response);        
        resp.Response = wrapper.response[0];
        resp.headers  = wrapper.headers;
        resp.Response.status = statusMapping(resp.Response.status);
        resp.metadata = getMetadataRecord('Pan');
        system.debug('Response : '+resp.Response);
        system.debug('metadata : '+JSON.serializePretty(resp.metadata));
        /* }else{
        resp.error = header.responseMsg;
        }*/
        return JSON.serialize(resp);
    }
    
    public static String statusMapping(String key){
        Map<String, Pan_Status_Mapping__mdt> mcs = Pan_Status_Mapping__mdt.getAll();
        return mcs.get(key).value__c;
    }
    
    public static List<Display_Data__mdt> getMetadataRecord(String rType){
        return [SELECT Id, Order__c, DeveloperName, MasterLabel, Display_on_UI__c, JSON_Key__c, API_Name__c FROM Display_Data__mdt where Type__c =: rType WITH SECURITY_ENFORCED order by Order__c];
    }
    
    public static String nsdlVerificationHandler(String panNumber,String applcntId,String msterRecordName) {
        Integration_Master__c objIntMapper =IntegrationUtility.getIntegrationMasterRecord(msterRecordName);
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        String respBody;
        LOSNsdlHandler objHandler=new LOSNsdlHandler();
        try {
            String requestBody = objHandler.generateRequest(getReqBodyKeyValueMap(panNumber))[0];
            system.debug('requestBody');
            /*Http http = new Http();
            HttpRequest request = new HttpRequest();
            request = IntegrationUtility.getHttpRequest(objIntMapper.End_Point_URL__c,objIntMapper.API_Key__c,objIntMapper.Apiuser__c,'POST',requestBody);
            HttpResponse res = http.send(request);
            respBody = res.getBody();*/
            // respBody = IntegrationUtility.doRestCallout(objIntMapper,requestBody,applcntId);
            
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applcntId);
            calloutRequestWrapper.request = requestBody;
            calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = checklistRecord;
            IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
            respBody=calloutResponseWrapper.response;
        
            //LOSNsdlResponseWrapper.headers parseDate = (LOSNsdlResponseWrapper.headers) System.JSON.deserialize(respBody, LOSNsdlResponseWrapper.headers.class);
            /* LOSNsdlResponseWrapper parseDate = LOSNsdlResponseWrapper.parse(respBody);
            system.debug('parsedate>>'+parseDate.headers);
            system.debug('parsedate>>'+parseDate.response);
            for(LOSNsdlResponseWrapper.response res1:parseDate.response){
            system.debug('res>>'+res1);
            }
            system.debug('respBody>>'+respBody); */
            //IntegrationUtility.updateIntegrationMasterRec('',respBody,res.getStatusCode(),objIntMapper.Id,requestBody);
        }
        catch (Exception ex) {
            Log.error('LOSNsdlController method nsdlVerificationHandler :: LINE NUMBER ' + ex.getLineNumber() + ' --  ' +  ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),applcntId);
            if (calloutRequestWrapper != NULL && calloutRequestWrapper.checklistRecord != NULl) {upsert calloutRequestWrapper.checklistRecord;}
        }
        return respBody;
        
    } 
    
    public static Map<String,Object> getReqBodyKeyValueMap(String panNumber){
        Map<String,Object> paramMap = new Map<String,Object>();
        paramMap.put('panNumber',panNumber);
        return paramMap;
    }

    @AuraEnabled
    public static void updateStatus(String applicantId, String type){
        Applicant__c appObj = [SELECT KYC_Status__c, KYC_Type__c FROM Applicant__c WHERE Id=:applicantId];
        appObj.KYC_Status__c = 'Complete';
        appObj.KYC_Type__c = type;
        update appObj;
    }
    
}