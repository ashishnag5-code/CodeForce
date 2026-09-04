@IsTest
private class SFApp_ConfigService_Test {
    
    @TestSetup
    static void makeData(){
        SFApp_Config__c conf = new SFApp_Config__c();
        conf.Name = 'TESTCONFIG';
        conf.Is_Stored_File__c = true;
        insert conf;
        

        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = Blob.valueOf('TEST DOCUMENT');
        cv.Title = 'TEST TITLE';
        cv.PathOnClient = 'TESTPATH'; 
        insert cv;

        ContentVersion c = [
                                SELECT ContentDocumentId 
                                FROM ContentVersion 
                                WHERE Id =: cv.Id
                            ];
        
        ContentDocumentLink link = new ContentDocumentLink();
        link.ContentDocumentId = c.ContentDocumentId;
        link.LinkedEntityId = conf.Id;
        insert link;


    }

    @isTest static void testGetConfig() {
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://sfapp66.my.salesforce.com/services/apexrest/config/'
            + 'TESTCONFIG';
        request.httpMethod = 'GET';
        RestContext.request = request;
        // Call the method to test
        String contData = SFApp_ConfigService.doGet();
         // Verify results
        System.assertEquals('TEST DOCUMENT', contData);
    }


}