/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 11-18-2022
 * @last modified by  : Harshit Goyal | Salesforce
**/
@RestResource(urlMapping='/SalesforceDocumentAPI/*')
global class BridgeAppAPI{
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 11-18-2022 
    **/
    @HttpPost
    global static void uploadDocument(){
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        system.debug('IDFROM REQUEST'+req.params.get('integrationchecklistId'));
        string integrationchecklistId = req.params.get('integrationchecklistId');
        string contenttype = req.params.get('contenttype');
        string name = req.params.get('name');
        String jsonString = req.requestBody.toString();

    try
    {
        //Insert ContentVersion
        ContentVersion cVersion = new ContentVersion();
        cVersion.PathOnClient = name;//File name with extention
        cVersion.Title = name;//Name of the file
        cVersion.VersionData = EncodingUtil.base64Decode(jsonString);//File content
        Insert cVersion;

        //After saved the Content Verison, get the ContentDocumentId
        Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;

        //Insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocument;//Add ContentDocumentId
        Id newId = Id.valueOf(integrationchecklistId);
        cDocLink.LinkedEntityId = Id.valueOf(newId);//Add attachment parentId
        //cDocLink.LinkedEntityId = 'a0D6s000002ig0xEAA';
        Insert cDocLink;

        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(generateJSON('Success',conDocument,''));

    }
    catch(Exception e){
        system.debug('Exception line '+e.getLineNumber());
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(generateJSON('Error','',e.getMessage()));
    }
    }
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 11-18-2022 
    * @param Status 
    * @param Content 
    * @param error 
    * @return string 
    **/
    private static string generateJSON(String Status,String Content,String error){
        JSONGenerator jsGen = JSON.createGenerator(true);
        jsGen.writeStartObject();
        jsGen.writeStringField('Status',Status);
        jsGen.writeStringField('ContentID', Content);
        jsGen.writeStringField('Error', error);
        jsGen.writeEndObject();
        return jsGen.getAsString();
    }
}