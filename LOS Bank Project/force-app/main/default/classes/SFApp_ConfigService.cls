@RestResource(urlMapping='/config/*')
global with sharing class SFApp_ConfigService {

    @HttpGet
    global static String doGet() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String configName = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        SFApp_Config__c config = [
                                    SELECT Id , Is_Stored_File__c
                                    FROM SFApp_Config__c 
                                    WHERE Name =: configName
                                   ];
        if(config.Is_Stored_File__c){
            ContentDocumentLink link = [
                                        SELECT ContentDocumentId 
                                        FROM ContentDocumentLink 
                                        WHERE LinkedEntityId =: config.Id
                                    ];
            ContentVersion version = [
                                        SELECT Id, VersionData, Title, FileType 
                                        FROM ContentVersion
                                        WHERE ContentDocumentId =: link.ContentDocumentId 
                                        AND IsLatest = true
                                        ];
            return version.VersionData.toString();
        }
        else{
            // Custom JSON to be created and returned if needed
        }
        return '{}';
    }

}