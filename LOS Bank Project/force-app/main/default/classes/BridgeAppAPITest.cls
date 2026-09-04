@isTest
private class BridgeAppAPITest {
    
    @isTest
    static void testUploadDocumentFail() {
        // Test data setup
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        // Set request parameters
        req.requestUri = '/SalesforceDocumentAPI/uploadDocument';
        req.httpMethod = 'POST';
        req.addParameter('integrationchecklistId', 'IntegrationChecklistId');
        req.addParameter('contenttype', 'application/json');
        req.addParameter('name', 'TestFile.txt');
        req.requestBody = Blob.valueOf('Test file content');
        
        // Test the uploadDocument method
        Test.startTest();
        RestContext.request = req;
        RestContext.response = res;
        BridgeAppAPI.uploadDocument();
        Assert.isTrue(RestContext.response.responseBody.toString().containsIgnoreCase('Error'), 'Document uploaded successfully');
        Test.stopTest();
        
    }
    
    @isTest
    static void testUploadDocumentPass() {
        
        // Test data setup
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        // Set request parameters
        req.requestUri = '/SalesforceDocumentAPI/uploadDocument';
        req.httpMethod = 'POST';
        req.addParameter('integrationchecklistId', acc.Id);
        req.addParameter('contenttype', 'application/json');
        req.addParameter('name', 'TestFile.txt');
        req.requestBody = Blob.valueOf('Test file content');
        
        // Test the uploadDocument method
        Test.startTest();
        RestContext.request = req;
        RestContext.response = res;
        BridgeAppAPI.uploadDocument();
        Assert.isTrue(RestContext.response.responseBody.toString().containsIgnoreCase('Success'), 'Document did not upload');
        Test.stopTest();
    }
}