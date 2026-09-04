@isTest
public class GenerateRespWrapperTest {
    @isTest
    static void testParse() {
        
        GenerateRespWrapper expectedResponse = new GenerateRespWrapper();
        expectedResponse.response_data = new GenerateRespWrapper.response_data();
        expectedResponse.response_data.data = 'PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPE90cFJlcyB0eG49Im51bGwiIGNvZGU9IjYyNTcyMzY3ZDgzYTRmOWE5NjFkMGMxMGRjYmJjNTIyIiB0cz0iMjAyMS0xMS0wMlQxNzozMzo1NS44ODErMDU6MzAiIHJldD0ieSIgaW5mbz0iMDF7QSwyMDIxLTExLTAyVDE3OjM0OjMyLDIuNSxlZTI5NDMwMjMxNGIzZDRmZDBlMDdkYzJjNDMwNDk1NDgxNGI5NDlhNzExNjk5YjVhYjQ5Mjg5NTRmYWJmZDRjLGE1ZDllZmJjODFkOGNmNDNlNmY2ZDRjZjZhZDg2YjQ0YWRlNzAzNDlhYTA0NjJkZmJkZDIyMjFkNDUyNmM1MWIsYTVkOWVmYmM4MWQ4Y2Y0M2U2ZjZkNGNmNmFkODZiNDRhZGU3MDM0OWFhMDQ2MmRmYmRkMjIyMWQ0NTI2YzUxYiwqKioqKioqOTUwNSxOQX0iLz4=';
        expectedResponse.response_data.format = 'XML';
        expectedResponse.response_status = new GenerateRespWrapper.response_status();
        expectedResponse.response_status.code = '000';
        expectedResponse.response_status.message = 'OTP sent successfully';
        expectedResponse.response_status.status = 'SUCCESS';

        
        String expectedJson = JSON.serialize(expectedResponse);

        
        GenerateRespWrapper result = GenerateRespWrapper.parse(expectedJson);

        
        System.assertEquals(expectedResponse.response_data.data, result.response_data.data);
        System.assertEquals(expectedResponse.response_data.format, result.response_data.format);
        System.assertEquals(expectedResponse.response_status.code, result.response_status.code);
        System.assertEquals(expectedResponse.response_status.message, result.response_status.message);
        System.assertEquals(expectedResponse.response_status.status, result.response_status.status);

       
        String nullJson = null;
        //GenerateRespWrapper nullResult = GenerateRespWrapper.parse(nullJson);
        //System.assert(nullResult == null, 'null result when parsing null JSON string');

        
        String emptyJson = '{}';
        GenerateRespWrapper emptyResult = GenerateRespWrapper.parse(emptyJson);

        String invalidJson = '{ "response_data": { "data": "Invalid data" } }'; 
        GenerateRespWrapper invalidResult = GenerateRespWrapper.parse(invalidJson);
    }
}