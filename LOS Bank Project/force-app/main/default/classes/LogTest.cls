@isTest
public class LogTest {
    @isTest
    public static void debugTest(){
        Log.debug('message');
    }
    
    @isTest
    public static void debugTest2(){
        Log.debug('message',new List<Object>());
    }
    
    
    
    @isTest
    public static void debugTest4(){
        try{
            sObject obj;
            String msg = (String)obj.get('');
        }
        catch(Exception e){
            Log.debug(e);
        }
    }
    @IsTest
    static void testLogAPIDetails() {
        // Create test data
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint('https://example.com/api');
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{"name": "John"}');

        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"success": true}');

        DateTime startTime = DateTime.now();
        DateTime endTime = startTime.addSeconds(1);

        String apiServiceName = 'ExampleService';
        Decimal successAPIStatusCode = 200;
        Log.SeverityType severity = Log.SeverityType.Low;

        // Call the method under test
        Test.startTest();
        Log.logAPIDetails(request, response, startTime, endTime, apiServiceName, successAPIStatusCode, severity);
        Test.stopTest();

        // Perform assertions or use system asserts to verify the expected behavior
        // Add assertions or use system asserts as needed
    }

    @IsTest
    static void testLogAPIDetails_Error() {
        // Create test data
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint('https://example.com/api');
        request.setHeader('Content-Type', 'application/json');

        HttpResponse response = new HttpResponse();
        response.setStatusCode(404);
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"error": "Not found"}');

        DateTime startTime = DateTime.now();
        DateTime endTime = startTime.addSeconds(1);

        String apiServiceName = 'ExampleService';
        Decimal successAPIStatusCode = 200;
        Log.SeverityType severity = Log.SeverityType.High;

        // Call the method under test
        Test.startTest();
        Log.logAPIDetails(request, response, startTime, endTime, apiServiceName, successAPIStatusCode, severity);
        Test.stopTest();

        // Perform assertions or use system asserts to verify the expected behavior
        // Add assertions or use system asserts as needed
    }

    @IsTest
    static void testLogAPIDetails_CustomSeverity() {
        // Create test data
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint('https://example.com/api');
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{"name": "John"}');

        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"success": true}');

        DateTime startTime = DateTime.now();
        DateTime endTime = startTime.addSeconds(1);

        String apiServiceName = 'ExampleService';
        Decimal successAPIStatusCode = 200;
        Log.SeverityType severity = Log.SeverityType.Medium;

        // Call the method under test
        Test.startTest();
        Log.logAPIDetails(request, response, startTime, endTime, apiServiceName, successAPIStatusCode, severity);
        Test.stopTest();

        // Perform assertions or use system asserts to verify the expected behavior
        // Add assertions or use system asserts as needed
    }
     @IsTest
    static void testError() {
        // Test the error(String message, SeverityType severity, String sObjectId) method
        Log.error('An error occurred.', Log.SeverityType.High, '001');

        // Add assertions or use system asserts to verify the expected behavior
        // Add assertions or use system asserts as needed
    }

    @IsTest
    static void testError_WithValues() {
        // Test the error(String message, List<Object> values, SeverityType severity, String sObjectId) method
        List<Object> values = new List<Object> { 'Value 1', 'Value 2' };
        Log.error('An error occurred.', values, Log.SeverityType.Medium, '001');

        // Add assertions or use system asserts to verify the expected behavior
        // Add assertions or use system asserts as needed
    }

    @IsTest
    static void testError_WithAsyncJobId() {
        // Test the error(String message, Id asyncJobId, SeverityType severity, String sObjectId) method
        Id asyncJobId = null;
        Log.error('An error occurred.', asyncJobId, Log.SeverityType.Low, '001');

        // Add assertions or use system asserts to verify the expected behavior
        // Add assertions or use system asserts as needed
    }

  


    @IsTest
    static void testError_WithStackTrace() {
        // Test the error(String message, String stackTrace, List<Object> values, Id asyncJobId, SeverityType severity, String sObjectId) method
        List<Object> values = new List<Object> { 'Value 1', 'Value 2' };
        Id asyncJobId = null;
        Log.error('An error occurred.', 'Sample stack trace.', values, asyncJobId, Log.SeverityType.Low, '001');

        // Add assertions or use system asserts to verify the expected behavior
        // Add assertions or use system asserts as needed
    }
}