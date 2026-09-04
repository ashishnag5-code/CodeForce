/**
* @description       : 
* @author            : Harshit Goyal | Salesforce
* @group             : 
* @last modified on  : 02-14-2023
* @last modified by  : Harshit Goyal | Salesforce
**/
@RestResource(urlMapping ='/DocumentCompressAPI')
global with sharing class LosCompressRestResource {
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 12-08-2022 
    **/
    @HttpPost
    global static void getDocCompressed(){
        String applicantId ='';
        String recordId ='';
        try
        {
            RestRequest req = RestContext.request;
            RestResponse res = Restcontext.response;
          //  system.debug('RequestBodySTRING'+req.requestBody.toString());
            Boolean isError = false;
            String errorMessage ='';
            String fileName='';
            String base64Content='';
            Map<String, Object> bidgeAppRequest = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
            String base64String = req.requestBody.toString();
            Map<String, Object> bidgeAppDocRequest = (Map<String, Object>) JSON.deserializeUntyped(req.requestBody.toString());
            if(bidgeAppDocRequest.containsKey(GlobalConstants.APPLICANT_ID)){
                applicantId = String.valueOf(bidgeAppDocRequest.get(GlobalConstants.APPLICANT_ID));
                system.debug('Applicant Id: '+applicantId);
            }else{
                isError = true;
                errorMessage= GlobalConstants.APPLICANT_MISSING;
                system.debug('Applicant Id: missing');
            }
            if(bidgeAppDocRequest.containsKey('Name')){
                fileName = String.valueOf(bidgeAppDocRequest.get('Name'));
                system.debug('File name: missing');
            }else{
                isError = true;
                errorMessage= 'File Name Missing';
            }
         //   fileName = 'File' + System.now() + '.pdf';
            if(bidgeAppDocRequest.containsKey('base64String')){
                base64Content = String.valueOf(bidgeAppDocRequest.get('base64String'));
                system.debug('file content: '+base64Content);
            }else{
                isError = true;
                errorMessage= 'Base64 Content missing';
            }
            if(bidgeAppDocRequest.containsKey('recordId')){
                recordId = String.valueOf(bidgeAppDocRequest.get('recordId'));
                system.debug('recordId: '+recordId);
            }else{
                isError = true;
                errorMessage= 'Base64 Content missing';
            }
            DocumentCompressReqResWrapper.LOSDocCompressResWrapper wrapData;
           // wrapData= DocumentCompressAPI.getCompresssedDocument(base64Content,fileName,applicantId,null);

            if(String.isBlank(applicantId)){
                List<Document_Checklist__c> docChecks = [SELECT Id,Loan_Application__c, Collateral__c,Collateral__r.Loan__c FROM Document_Checklist__c Where Id =: recordId ];
                applicantId = !docChecks.IsEmpty() && docChecks[0].Collateral__c != null ?  docChecks[0].Collateral__r.Loan__c : docChecks[0].Loan_Application__c != null ? docChecks[0].Loan_Application__c : '';
                isError = String.isNotBlank(applicantId) ? false : isError;
                wrapData= DocumentCompressAPI.getCompresssedDocument(base64Content,fileName,null,applicantId);
            }else{
                wrapData= DocumentCompressAPI.getCompresssedDocument(base64Content,fileName,applicantId,null);
            }

            if(wrapData.OutputStatus == System.Label.LOS_DocCompress_Success){
                //cv.VersionData = EncodingUtil.base64Decode(wrapData.OutputFileBase64string);
                updateContentVersion(recordId,wrapData.OutputFileBase64string,fileName);
            }else{
                errorMessage = ' API Issue: ' +  wrapData.checklistRecord.Name + ' Response: ' + wrapData.statusCode + '- ' + wrapData.OutputStatus; 
                isError = true;
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

    private static void updateContentVersion(String recordId, String base64Content, String fileName){
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64Content);
        cv.Title = filename;
        cv.PathOnClient = filename;
        if(Schema.sObjectType.ContentVersion.isCreateable()){
          insert cv;
        }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
          SELECT ContentDocumentId 
          FROM ContentVersion 
          WHERE Id =: cv.Id
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        if(Schema.sObjectType.ContentDocumentLink.isCreateable()){
          insert cdl;
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