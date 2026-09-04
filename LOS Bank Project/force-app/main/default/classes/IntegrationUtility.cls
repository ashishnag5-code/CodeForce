/*****
 * Class Name: IntegrationUtility
 * Description: Integration Utility
 * Test Class Name: IntegrationUtilityTest
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Nov-08-2023          -   Mohit M.            -   SFAU-5566 - vahhan api issue
*/

public without sharing class IntegrationUtility {
    
    public static Blob encryptData(String algorithmName, Blob privateKey, Blob initializationVector, Blob clearText){
        return Crypto.encrypt(algorithmName,privateKey,initializationVector,clearText);
    }
    
    public static blob decryptData(String algorithmName, Blob privateKey, Blob initializationVector, Blob clearText){
        return Crypto.decrypt(algorithmName,privateKey,initializationVector,clearText);
    }
    
    
    public static ResponseWrapper doRestCallout(RequestWrapper requestInstance) {
        if (requestInstance.masterRecord == null) {
            throw new HandledException('Integration Master details are mandatory for initiating an interface');
        }
        if (String.isBlank(requestInstance.method)) {
            throw new HandledException('Method is mandatory for initiating an interface');
        }
        if (String.isBlank(requestInstance.endpointURL) && String.isBlank(requestInstance.masterRecord.End_Point_URL__c)) {
            throw new HandledException('Endpoint URL is mandatory. Update these details in master or in the input parameters');
        }
        ResponseWrapper responseInstance = new ResponseWrapper();
        HTTPResponse response;
        String strResBody;
        Boolean isBlobRequest = false;
        List<Integration_Checklist__c> lstchecklistRecord = new List<Integration_Checklist__c>();
        system.debug('requestInstance====>'+requestInstance);
        Integration_Checklist__c checklistRecord = requestInstance.checklistRecord;
        system.debug('checklistRecord====>'+checklistRecord);
        checklistRecord.Is_Latest__c = true;
        checklistRecord.Integration_Master__c = requestInstance.masterRecord.Id;
        try {
            HttpRequest request = new HttpRequest();
            request.setMethod(requestInstance.method);
            if(!String.isBlank(requestInstance.masterRecord.Timeout__c)){
                request.setTimeout(Integer.valueOf(requestInstance.masterRecord.Timeout__c));
            }
            else{
                request.setTimeout(requestInstance.timeOut);
            }
            String urlQueryParams;
            if(requestInstance!= null && requestInstance.urlParamsMap != null){
                urlQueryParams = generateURLQueryParams(requestInstance.urlParamsMap);
            }
            /*
if(String.isBlank(requestInstance.endpointURL)){ // use urlQueryParams instead.
request.setEndPoint(requestInstance.masterRecord.End_Point_URL__c);
}else{
request.setEndPoint(requestInstance.endpointURL);
}
*/
            if(!String.isBlank(urlQueryParams)){
                request.setEndPoint(requestInstance.masterRecord.End_Point_URL__c + urlQueryParams);
                checklistRecord.Request__c = urlQueryParams;
            }else{
                request.setEndPoint(requestInstance.masterRecord.End_Point_URL__c);
            }
            if(requestInstance.masterRecord.Include_Certificate__c) {
                request.setClientCertificateName('sfdc');
            }
            requestInstance.contentType = requestInstance.masterRecord.Content_Type__c;
            //requestInstance.contentType = String.isBlank(requestInstance.contentType) ? Label.Rest_Integration_Default_ContentType : requestInstance.contentType;
            if (String.isNotBlank(requestInstance.contentType)) {
                request.setHeader('content-type', requestInstance.contentType);
            }
            
            if(requestInstance.headersMap != null && !requestInstance.headersMap.isEmpty())        
            {
                for(String header : requestInstance.headersMap.keySet() ) 
                {                        
                    request.setHeader( header, requestInstance.headersMap.get(header));
                }
            } 
            if(requestInstance.masterRecord.API_Key__c != null){
                request.setHeader( 'apikey', requestInstance.masterRecord.API_Key__c);
            } 
            if(requestInstance.masterRecord.Apiuser__c != null){
                request.setHeader( 'apiuser', requestInstance.masterRecord.Apiuser__c);
            }
            if(requestInstance.request != null) {
                request.setBody(requestInstance.request);
                if (requestInstance.request.length() >= 131072 || Test.isRunningTest()) {
                    requestInstance.captureRequestInAttachment = true;
                }
            }
            if(requestInstance.requestBlob != null) {            
                request.setBodyAsBlob(requestInstance.requestBlob);
                isBlobRequest = true;
            }
            checklistRecord.Request_Initiated_At__c = System.now();
            if(requestInstance.method == 'POST'){
                if (requestInstance.captureRequestInAttachment) {
                    checklistRecord.Is_Request_In_Attachment__c = true;
                } else {
                    checklistRecord.Request__c = LogMaskingUtility.returnMaskedData(requestInstance.request,null,requestInstance.masterRecord.Name); //requestInstance.request;
                }
            }
            
            if(requestInstance.masterRecord.Disable_api__c && String.isNotBlank(requestInstance.masterRecord.Static_response__c)){
                //get static payload from static resource when API is disabled
                StaticResource sr= [SELECT Id, body FROM StaticResource WHERE Name =: requestInstance.masterRecord.Static_response__c];
                response = new HTTPResponse();
                response.setStatus('200');
                strResBody = sr.body.toString(); 
                response.setBody(strResBody);
                responseInstance.statusCode = 200;
            }
            else{
                //get original payload from API when not disabled
                Http http = new Http();
                system.debug('%%request '+request);
                response = http.send(request);
                if(request.getBodyAsBlob() != null){
                    checklistRecord.Request_Size__c = request.getBodyAsBlob().size();
                }
                // START - SFAU-5566 - vahhan api issue
                if(response !=null && response.getBodyAsBlob() != null ){
                checklistRecord.Response_Size__c = response.getBodyAsBlob().size();
                }
                // END - SFAU-5566 - vahhan api issue
                strResBody = response.getBody();
                responseInstance.statusCode = response.getStatusCode();
                checklistRecord.Status_Code__c = String.valueOf(responseInstance.statusCode);
                system.debug(LoggingLevel.Info,'Response Status ' + response.getStatusCode());
            }
            if(strResBody.length() >= 131072){
                requestInstance.captureResponseInAttachment = true;
            }
            checklistRecord.Response_Received_At__c = System.now();
            if (requestInstance.captureResponseInAttachment) {
                checklistRecord.Is_Response_In_Attachment__c = true;
            } else {
                checklistRecord.Response__c = LogMaskingUtility.returnMaskedData(null,strResBody,requestInstance.masterRecord.Name); //strResBody;
            }
            responseInstance.response = strResBody;
            responseInstance.status = response != null ? response.getStatus() : 'Server Error';
            //response = new HTTPResponse();
            //response.setBody('{"status":"success","message":"Saved Successfully"}'); // Completed
            checklistRecord.Status__c = 'Completed'; // trigger layer uses callback service to set this to failed if response is not intact
        } catch(CalloutException ex) {
            // no logging required here because we're already capturing this in Integration Checklist
            checklistRecord.Response__c = String.valueOf(response);
            checklistRecord.Status__c = 'Failed';
            System.debug('exception--->' +ex.getMessage() +'---' +ex.getLineNumber());
            Log.error(ex, Log.SeverityType.valueOf('High'),null);
            DatabaseUtility.upsertRecords(lstchecklistRecord, '');
       //     Savepoint sp = Database.setSavepoint(); Not needed.
        //    Database.RollBack(sp);
            throw ex;
        } catch (Exception ex) {
            System.debug('exception--->' +ex.getMessage() +'---' +ex.getLineNumber());
            // DatabaseUtility.upsertRecords(lstchecklistRecord, '');
            // Savepoint sp = Database.setSavepoint(); 
            // Database.RollBack(sp);
            Log.error(ex, Log.SeverityType.valueOf('High'),null);
            // throw ex;
            
        }
        
        system.debug('checklistRecord before>> ');
        lstchecklistRecord.add(checklistRecord);
        DatabaseUtility.upsertRecords(lstchecklistRecord, '');

        responseInstance.checklistRecord = checklistRecord;
        responseInstance.checklistNumber = checklistRecord.Id != null ? [ SELECT Name FROM Integration_CheckList__c WHERE Id =: checklistRecord.Id ].Name : checklistRecord.Id;
        //Savepoint sp = Database.setSavepoint();
        //system.debug(LoggingLevel.Info,' checklist record  '+lstchecklistRecord[0].Request_Id__c);
       // system.debug('response.getBody()'+response.getBody());
        //upsert checklistRecord;
        if (requestInstance.captureRequestInAttachment || requestInstance.captureResponseInAttachment) {
            List<ContentVersion> calloutDetails = new List<ContentVersion>();
            if (requestInstance.captureRequestInAttachment) {
                calloutDetails.add(
                    new ContentVersion(
                        VersionData = (isBlobRequest ? requestInstance.requestBlob : Blob.valueOf(LogMaskingUtility.returnMaskedData(requestInstance.request,null,requestInstance.masterRecord.Name))),
                        Title = 'Request', Document_Type__c = 'Callout Request', PathOnClient = 'Request.txt', FirstPublishLocationId = checklistRecord.Id));
            }
            if (requestInstance.captureResponseInAttachment) {
                if(requestInstance.masterRecord.Disable_api__c && String.isNotBlank(requestInstance.masterRecord.Static_response__c)){
                    calloutDetails.add(new ContentVersion(VersionData = Blob.valueOf(strResBody), Title = 'Response', Document_Type__c = 'Callout Response', PathOnClient = 'Response.txt', FirstPublishLocationId = checklistRecord.Id));
                }
                else{
                    calloutDetails.add(
                        new ContentVersion(
                            VersionData = Blob.valueOf(LogMaskingUtility.returnMaskedData(null, response?.getBody(), requestInstance.masterRecord.Name)),
                            Title = 'Response',
                            Document_Type__c = 'Callout Response',
                            PathOnClient = 'Response.txt',
                            FirstPublishLocationId = checklistRecord.Id
                        )
                    );
                }
            }
            //upsert calloutDetails;
            DatabaseUtility.upsertRecords(calloutDetails, '');
        }
        return responseInstance;
    }
    
    public class ResponseWrapper {
        public String response;
        public String status;
        public String additionalResponse;
        public String checklistNumber;
        public Integer statusCode;
        public Integration_Checklist__c checklistRecord;
    }
    
    public class RequestWrapper {
        public String request;
        public Blob requestBlob;
        public Map<String,String> headersMap;
        public Map<String,String> urlParamsMap;        
        public String contentType;
        public Integer timeOut = 120000;
        public String method;
        public Integration_Master__c masterRecord;
        public Boolean captureResponseInAttachment = false;
        public Boolean captureRequestInAttachment = false;
        // use this when URL should include request parameters. If this is not set, the method will use URL in master
        public String endpointURL;
        public Integration_Checklist__c checklistRecord;
    }
    
    public static String generateURLQueryParams(Map<String,String> urlParamsMap){
        String strURLQueryParams;
        if(urlParamsMap != null){
            for(String strURLQueryParam : urlParamsMap.keySet()){
                system.debug('strURLQueryParam >> '+strURLQueryParam);
                if(strURLQueryParams!=null){
                    strURLQueryParams += strURLQueryParam + '=' + urlParamsMap.get(strURLQueryParam)+ '&';
                }else{
                    strURLQueryParams = strURLQueryParam + '=' + urlParamsMap.get(strURLQueryParam) + '&';
                }
            }
        }
        system.debug('strURLQueryParams>> '+strURLQueryParams);
        //remove & from the URL end
        if(strURLQueryParams.endsWith('&')){
            system.debug('in if '+strURLQueryParams);
            strURLQueryParams = strURLQueryParams.removeEnd('&');
        }
        system.debug('strURLQueryParams>> '+strURLQueryParams);
        return strURLQueryParams;
    }
    
    
    public static String getReferenceId(){
        Integer charLength = 25;
        String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash).left(charLength);
        system.debug('##########' + hexDigest );
        return 'SFDC'+Label.Callback_Environment+'_'+hexDigest;
    }

    public static String getApplicationRelatedReferenceId(String applicationId){
        Integer charLength = 20;
        String hashString = applicationId + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash).left(charLength);
        system.debug('##########' + hexDigest );
        return hexDigest;
    }
    
    public static void updateIntegrationChecklist(String recordId,String response,Integer statusCode,String objIntMapper,String request){
        List<Integration_Checklist__c> lstIntegrationChecklist = new List<Integration_Checklist__c>();
        Boolean boolIsRespAttachment = false;
        Integration_Checklist__c objIntegrationStatusRec = new Integration_Checklist__c();
        lstIntegrationChecklist = [
            SELECT ID,is_Latest__c
            from Integration_Checklist__c
            where Applicant__c = :recordId AND is_Latest__c = true
            AND Integration_Master__c = :objIntMapper WITH SECURITY_ENFORCED
        ];
        if (statusCode == 200) {
            objIntegrationStatusRec.Status__c = 'Completed';
        } else {
            objIntegrationStatusRec.Status__c = 'Failed';
        }
        objIntegrationStatusRec.Response_Received_At__c = dateTime.now();
        if(response.length() < 131072){
            objIntegrationStatusRec.Response__c = response;
        }
        else{
            boolIsRespAttachment = true;
            objIntegrationStatusRec.Is_Response_In_Attachment__c = true;
        }
        objIntegrationStatusRec.Request__c = request;
        objIntegrationStatusRec.Integration_Master__c = objIntMapper;
        if(recordId != null && recordId != ''){
            String sobjectType = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
            if(sobjectType == 'Applicant__c'){
                objIntegrationStatusRec.Applicant__c = recordId;
            } else if(sobjectType == 'Loan_Application__c') {
                objIntegrationStatusRec.Loan_Application__c = recordId;
            }
        }
        if (!lstIntegrationChecklist.isEmpty()) {
            for (Integration_Checklist__c objIntegrationStatus : lstIntegrationChecklist) {
                objIntegrationStatus.is_Latest__c = false;
            }
        }
        objIntegrationStatusRec.is_Latest__c = true;
        lstIntegrationChecklist.add(objIntegrationStatusRec);
        try{
            //upsert lstIntegrationChecklist;
            DatabaseUtility.upsertRecords(lstIntegrationChecklist, '');
            System.debug('boolIsRespAttachment: ' + boolIsRespAttachment);
            System.debug('recordId: ' + recordId);
            if(boolIsRespAttachment && !String.isBlank(recordId)){
                List<Integration_Checklist__c> lstIntCheckList = [SELECT Id from Integration_Checklist__c 
                                                                  WHERE Applicant__c = :recordId AND is_Latest__c = true AND Integration_Master__c = :objIntMapper WITH SECURITY_ENFORCED limit 1];
                if(!lstIntCheckList.isEmpty()){
                    List<ContentVersion> calloutDetails = new List<ContentVersion>();
                    calloutDetails.add(new ContentVersion(VersionData = Blob.valueOf(response), Title = 'Response', PathOnClient = 'Response.txt', FirstPublishLocationId = lstIntCheckList[0].Id));
                    //upsert calloutDetails;
                    DatabaseUtility.upsertRecords(calloutDetails, '');
                }
            }          
        } 
        catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }      
    }
      
    public static Integration_Master__c getIntegrationMasterRecord(String name){
        Integration_Master__c objIntMapper;
        system.debug('name' +name);
        objIntMapper = [
            SELECT id, Name, End_Point_URL__c, IV__c, Encryption_Key__c,Apiuser__c,API_Key__c,HTTP_Method__c,Timeout__c, Include_Certificate__c, Disable_api__c , Static_response__c, Channel__c, Content_Type__c  
            FROM Integration_Master__c
            WHERE Name = :name and Active__c = true WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        system.debug(objIntMapper+'objIntMapper');
        return objIntMapper;
        
    }
    
    public static Document_Master__c getDocumentMasterRecord(String name){
        Document_Master__c objIntMapper;
        objIntMapper = [
            SELECT id, Name FROM Document_Master__c
            WHERE Name = :name WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return objIntMapper;
        
    }
    
    // This method is used to replace reserved words in JSON
    public static String mogrifyJSON(String data, Map<String, String> replacements) {
        // Regex to match the start of the line and the key
        // surrounded by quotes and ending with a colon
        String regexFormat = '(?m)^\\s*"{0}"\\s*:';
        
        // Replacement format of the new key surrounded by
        // quotes and ending with a colon
        String replacementFormat = '"{0}" :';
        
        /*// A map of existing key to replacement key
        Map<String, String> replacements = new Map<String, String> {
        'case' => 'case_x'
        };  */
        
        // Since our JSON can come in formatted however the
        // endpoint wants, we need to format it to a standard
        // we know and can handle
        system.debug('data in mogrifyJSON-- '+data);
        String formattedJSON = JSON.serializePretty(JSON.deserializeUntyped(data));
        system.debug('before formattedJSON-- '+formattedJSON);
        // Iterate over all the keys we want to replace
        for (String key : replacements.keySet()) {
            // Generate our regex based on the key
            String regex = String.format(
                regexFormat,
                new List<String> {key}
            );
            
            // Generate our replacement
            String replacement = String.format(
                replacementFormat,
                new List<String> {replacements.get(key)}
            );
            
            // Find all and replace
            formattedJSON = formattedJSON.replaceAll(regex, replacement);
        }
        system.debug('after ormattedJSON-- '+formattedJSON);
        return formattedJSON;
    }
    
}