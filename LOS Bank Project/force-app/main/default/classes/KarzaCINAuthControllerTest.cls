@IsTest
private class KarzaCINAuthControllerTest {
    @IsTest
    static void testKarzaCINCallOut() {
        
        Integration_Master__c objIntMapper = new Integration_Master__c(
            Name = 'Karza CIN Authentication',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/SFDCKarza/CompanyLLPMasterData',
            HTTP_Method__c = 'GET',
            Active__c = true
        );
        insert objIntMapper;
        
        Integration_Master__c objIntMapper1 = new Integration_Master__c(
            Name = 'CIN Verification',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/SFDCKarza/CompanyLLPMasterData',
            HTTP_Method__c = 'GET',
            Active__c = true
        );
        insert objIntMapper1;
        
       /* Integration_Checklist__c checklistRecord = new Integration_Checklist__c(
            Applicant__c = 'a24C3000000fxtmIAA'
        );
        insert checklistRecord;*/
        
        String cinNo = 'ABC123';
        //String applicantId = checklistRecord.Applicant__c;
        
        Test.setMock(HttpCalloutMock.class, new KarzaCINAuthControllerMock());
        
        Test.startTest();
        String response = KarzaCINAuthController.karzaCINCallOut(cinNo, null);
        Test.stopTest();
        
        
        System.assertNotEquals(null, response, 'Response should not be null');
        System.assertNotEquals('', response, 'should not be empty');
        System.assert(response != null && response.contains('mock response'), 'Response should contain expected data');
        
        List<Integration_Checklist__c> checklists = [SELECT Id FROM Integration_Checklist__c];
        System.assertEquals(1, checklists.size());
        
    }
    
    @IsTest
    static void testKarzaCINCallOut_Exception() {
        
        Integration_Master__c objIntMapper = new Integration_Master__c(
            Name = 'Karza CIN Authentication',
            End_Point_URL__c = 'https://example.com/api/',
            HTTP_Method__c = 'POST'
        );
        insert objIntMapper;
        
        String cinNo = 'ABC123';
        String applicantId = '001XXXXXXXXXXXX';
        
        
        Test.setMock(HttpCalloutMock.class, new KarzaCINAuthControllerExceptionMock());
        
        
        Test.startTest();
        String response = KarzaCINAuthController.karzaCINCallOut(cinNo, applicantId);
        Test.stopTest();
        
        
        System.assertEquals(null, response, 'should be null');
    }
    
    
    private class KarzaCINAuthControllerMock implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"response": "mock response"}');
            return res;
        }
    }
    
    
    private class KarzaCINAuthControllerExceptionMock implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            
            throw new CalloutException('Error occurred during the callout');
        }
    }
}