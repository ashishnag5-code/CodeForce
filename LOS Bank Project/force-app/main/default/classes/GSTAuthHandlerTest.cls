@isTest
public class GSTAuthHandlerTest {
    @isTest
    static void testGenerateRequest() {
        
        Map<String, Object> paramsMap = new Map<String, Object>();
        paramsMap.put('gstin', 'GSTIN123');
        
        
        List<String> result = GSTAuthHandler.generateRequest(paramsMap);
        
       
        System.assertEquals(1, result.size(), 'Just a single JSON request');
        GSTAuthHandler.GSTRequestWrapper requestWrapper = (GSTAuthHandler.GSTRequestWrapper) JSON.deserialize(result[0], GSTAuthHandler.GSTRequestWrapper.class);
        System.assertEquals('SFDC', requestWrapper.channel, 'SFDC');
        System.assertEquals('Y', requestWrapper.consent, 'Y');
        System.assertEquals('GSTIN123', requestWrapper.gstin, 'GSTIN123');
        System.assertNotEquals(null, requestWrapper.requestId, 'RequestId to be assigned a value');
    }
    
@isTest
static void testParse() {
    
    GSTAuthHandler.GSTResponseWrapper expectedResponse = new GSTAuthHandler.GSTResponseWrapper();
    expectedResponse.statusCode = 200;
    expectedResponse.requestId = 'RequestId123';
    expectedResponse.result = new GSTAuthHandler.Result();
    expectedResponse.result.gstin = 'GSTIN123';
    expectedResponse.result.lgnm = 'Test Company';
    
   
    String expectedJson = JSON.serialize(expectedResponse);
    
   
    GSTAuthHandler.GSTResponseWrapper result = GSTAuthHandler.parse(expectedJson);
    
    
    System.assertEquals(expectedResponse.statusCode, result.statusCode, 'status code to match');
    System.assertEquals(expectedResponse.requestId, result.requestId, 'request ID to match');
    System.assertEquals(expectedResponse.result.gstin, result.result.gstin, 'GSTIN to match');
    System.assertEquals(expectedResponse.result.lgnm, result.result.lgnm, 'company name to match');
    
    String emptyJson = '{}';
    GSTAuthHandler.GSTResponseWrapper nullResult = GSTAuthHandler.parse(emptyJson);

    String invalidJson = '{ "statusCode": 200, "requestId": "RequestId123" }'; 
    GSTAuthHandler.GSTResponseWrapper invalidResult = GSTAuthHandler.parse(invalidJson);
}

}