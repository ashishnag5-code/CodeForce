@IsTest
private class KarzaITRControllerTest {
    @IsTest
    static void testGenerateRequest() {
        // Create test data
        Map<String, Object> reqParam = new Map<String, Object>();
        reqParam.put('base64', 'example_base64');
        reqParam.put('password', 'example_password');

        Test.startTest();
        // Call the generateRequest method
        List<String> result = KarzaITRController.generateRequest(reqParam);
		Test.stopTest();
        
        // Verify the result
        System.assertEquals(1, result.size(), 'Expected a single serialized JSON string');
        String serializedJson = result[0];
        System.assertNotEquals(null, serializedJson, 'Serialized JSON should not be null');

        // Deserialize the JSON string
        KarzaITRController.ITRDetailsRequestWrapper deserializedWrapper =
            (KarzaITRController.ITRDetailsRequestWrapper) JSON.deserialize(serializedJson, KarzaITRController.ITRDetailsRequestWrapper.class);

        // Verify the deserialized object
        System.assertNotEquals(null, deserializedWrapper.requestId, 'requestId should not be null');
        System.assertEquals('SFDC', deserializedWrapper.channel, 'channel should be "SFDC"');
        System.assertEquals('example_base64', deserializedWrapper.file_b64, 'file_b64 should match the input base64');
        System.assertEquals('example_password', deserializedWrapper.password, 'password should match the input password');
    }
}