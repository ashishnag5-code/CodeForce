@isTest
private class DocumentChecklistHandlerTest {
    
    @isTest
    static void testAfterUpdate() {
        // Test data setup
        ContentVersion newFile = new ContentVersion();
        newFile.PathOnClient = 'TestFile';
        newFile.Title = 'TestFile';
        newFile.VersionData = Blob.valueOf('sample content');
        insert newFile;
        ContentVersion insertedFile = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:newFile.Id];
        
        List<Document_Checklist__c> documents = new List<Document_Checklist__c>();
        for (Integer i = 0; i < 5; i++) {
            Document_Checklist__c doc = new Document_Checklist__c(Active__c  = true, Needs_Compression__c =false);
            documents.add(doc);
        }
        insert documents;
         //Link the file with the product
        ContentDocumentLink linkedFile = new ContentDocumentLink(LinkedEntityId=documents[0].Id, ContentDocumentId=insertedFile.ContentDocumentId);
        insert linkedFile;
        
        Test.setMock(HttpCalloutMock.class, new AadharMock());
        test.startTest();
        Integration_Master__c intmassearch2 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'DocumentCompressService',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/AadharTokenizationServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Include_Certificate__c = true,
            Apiuser__c = 'SFDC'           
        ),true);
        List<Document_Checklist__c> newDocCheck = [Select Id,Needs_Compression__c from Document_Checklist__c];
        List<Document_Checklist__c> lstToUpdate = new List<Document_Checklist__c>();
        for(Document_Checklist__c doc : newDocCheck){
            doc.Needs_Compression__c = true;
            lstToUpdate.add(doc);
        }
        update lstToUpdate;
        Map<id,sObject> sobjMap = new Map<id,sObject>();
        DocumentChecklistTriggerService obj = new DocumentChecklistTriggerService();
        obj.beforeInsert(lstToUpdate);
        obj.afterInsert(lstToUpdate,sobjMap);
        obj.beforeUpdate(lstToUpdate,sobjMap,sobjMap);
        obj.beforeDelete(sobjMap);
        obj.afterDelete(sobjMap);
        obj.afterUndelete(sobjMap);
        test.stopTest();
    }
    
     private class AadharMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{\"requestId\":\"de0ee687-c706-465c-92ca-aa6e8df2bea2\",\"result\":{\"documents\":[{\"documentType\":\"AADHAAR\",\"subType\":\"FRONT_TOP\",\"pageNo\":1,\"ocrData\":{\"aadhaar\":{\"value\":\"237417330177\",\"confidence\":0.91},\"address\":{\"value\":\"S/O ,Rajendra Goyal 26 C S A Marg Ranapur Ranapur Ranapur Jhabua Madhya Pradesh - 457993\",\"confidence\":0.96},\"name\":{\"value\":\"Harshit Goyal\",\"confidence\":0.15},\"phone\":{\"value\":\"9685591059\",\"confidence\":1.0},\"pin\":{\"value\":\"457993\",\"confidence\":0},\"vid\":{\"value\":\"9117412486362525\",\"confidence\":0.8}},\"additionalDetails\":{\"inputMaskStatus\":{\"isMasked\":false,\"maskedBy\":null,\"confidence\":null},\"outputMaskStatus\":false,\"verhoeffCheck\":true,\"qr\":null,\"barcode\":null,\"addressSplit\":{\"building\":\"\",\"city\":\"\",\"district\":\"Jhabua\",\"pin\":\"457993\",\"floor\":\"\",\"house\":\"26 C\",\"locality\":\"Ranapur Ranapur Ranapur\",\"state\":\"Madhya Pradesh\",\"street\":\"S A Marg\",\"complex\":\"\",\"landmark\":\"\",\"untagged\":\"\"},\"careOfDetails\":{\"relation\":\"FATHER\",\"name\":\"Rajendra Goyal\"}},\"qualityChecks\":[{\"score\":0.86,\"flag\":false,\"type\":\"BRIGHTNESS\"},{\"score\":0.0,\"flag\":false,\"type\":\"BLACK_AND_WHITE\"},{\"score\":0.36,\"flag\":false,\"type\":\"BLUR\"},{\"score\":0.05,\"flag\":false,\"type\":\"CUT_CARD\"}]},{\"documentType\":\"AADHAAR\",\"subType\":\"FRONT_BOTTOM\",\"pageNo\":1,\"ocrData\":{\"aadhaar\":{\"value\":\"237417330177\",\"confidence\":1.0},\"dob\":{\"value\":\"21/12/1994\",\"confidence\":0.98},\"father\":{\"value\":\"\",\"confidence\":0},\"gender\":{\"value\":\"MALE\",\"confidence\":0.99},\"husband\":{\"value\":\"\",\"confidence\":0},\"mother\":{\"value\":\"\",\"confidence\":0},\"name\":{\"value\":\"Harshit Goyal\",\"confidence\":1.0},\"vid\":{\"value\":\"9117412486362525\",\"confidence\":0.8},\"yob\":{\"value\":\"\",\"confidence\":0}},\"additionalDetails\":{\"inputMaskStatus\":{\"isMasked\":false,\"maskedBy\":null,\"confidence\":null},\"outputMaskStatus\":false,\"verhoeffCheck\":true,\"qr\":null,\"barcode\":null},\"qualityChecks\":[{\"score\":0.88,\"flag\":false,\"type\":\"BRIGHTNESS\"},{\"score\":0.0,\"flag\":false,\"type\":\"BLACK_AND_WHITE\"},{\"score\":0.85,\"flag\":true,\"type\":\"BLUR\"},{\"score\":0.0,\"flag\":false,\"type\":\"CUT_CARD\"}]},{\"documentType\":\"AADHAAR\",\"subType\":\"BACK\",\"pageNo\":1,\"ocrData\":{\"aadhaar\":{\"value\":\"237417330177\",\"confidence\":1.0},\"address\":{\"value\":\"S/0, Rajendra Goyal, 26, C SA Marg, Ranapur, jhabua, Madhya Ranapur, Pradesh - 457993\",\"confidence\":1.0},\"pin\":{\"value\":\"457993\",\"confidence\":1.0},\"vid\":{\"value\":\"\",\"confidence\":0}},\"additionalDetails\":{\"inputMaskStatus\":{\"isMasked\":false,\"maskedBy\":null,\"confidence\":null},\"outputMaskStatus\":false,\"verhoeffCheck\":true,\"qr\":null,\"barcode\":null,\"addressSplit\":{\"building\":\"\",\"city\":\"\",\"district\":\"Jhabua\",\"pin\":\"457993\",\"floor\":\"\",\"house\":\"S / 0 26\",\"locality\":\"Ranapur\",\"state\":\"\",\"street\":\"C SA Marg\",\"complex\":\"\",\"landmark\":\"\",\"untagged\":\"Madhya Ranapur, Pradesh\"},\"careOfDetails\":{\"relation\":\"\",\"name\":\"\"}},\"qualityChecks\":[{\"score\":0.87,\"flag\":false,\"type\":\"BRIGHTNESS\"},{\"score\":0.0,\"flag\":false,\"type\":\"BLACK_AND_WHITE\"},{\"score\":0.34,\"flag\":false,\"type\":\"BLUR\"},{\"score\":0.0,\"flag\":false,\"type\":\"CUT_CARD\"}]}]},\"statusCode\":101}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
}