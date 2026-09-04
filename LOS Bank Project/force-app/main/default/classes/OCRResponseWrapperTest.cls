@isTest
public class OCRResponseWrapperTest {

    static testMethod void testConstructorInitialization() {
        /*OCRResponseWrapper.Details details = new OCRResponseWrapper.Details();
        system.debug('details::'+details.gender.conf);
        System.assertEquals(0, details.gender.conf);
        System.assertEquals('', details.gender.value);

        OCRResponseWrapper.Dob dob = new OCRResponseWrapper.Dob();
        System.assertEquals(0, dob.conf);
        System.assertEquals('', dob.value);

        OCRResponseWrapper.Gender gender = new OCRResponseWrapper.Gender();
        System.assertEquals(0.0, gender.conf);
        System.assertEquals('', gender.value);

        OCRResponseWrapper.Result result = new OCRResponseWrapper.Result();
        System.assertEquals('', result.type);*/
    }

    static testMethod void testParseMethod() {
        String sampleJson = '{' +
                            '  "result": [{' +
                            '    "details": {' +
                            '      "gender": {"conf": 0.95, "value": "Male"},' +
                            '      "voterid": {"conf": 0.90, "value": "V12345"}' +
                            '    },' +
                            '    "type": "IDCard"' +
                            '  }],' +
                            '  "requestId": "Req123",' +
                            '  "statusCode": 200' +
                            '}';

        OCRResponseWrapper parsedResponse = OCRResponseWrapper.parse(sampleJson);

        System.assertEquals('Req123', parsedResponse.requestId);
        System.assertEquals(200, parsedResponse.statusCode);
        System.assertEquals(1, parsedResponse.result.size());
        System.assertEquals(0.95, parsedResponse.result[0].details.gender.conf);
        System.assertEquals('Male', parsedResponse.result[0].details.gender.value);
    }
}