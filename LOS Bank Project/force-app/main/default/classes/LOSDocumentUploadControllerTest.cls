/**
* @description       : 
* @author            : Harshit Goyal | Salesforce
* @group             : 
* @last modified on  : 01-03-2023
* @last modified by  : Harshit Goyal | Salesforce
**/
@istest
public with sharing class LOSDocumentUploadControllerTest {
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"value":"843880605528"}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
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
    private class VoterMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{\"requestId\":\"cb43f55c-21f8-4df2-8bad-be8d6bae5413\",\"result\":{\"documents\":[{\"documentType\":\"VOTER\",\"subType\":\"FRONT\",\"pageNo\":1,\"ocrData\":{\"voterId\":{\"value\":\"WB/20/136/681023\",\"confidence\":1.0},\"name\":{\"value\":\"BANDAYAPADAY TIRTHANKA\",\"confidence\":1.0},\"dob\":{\"value\":\"\",\"confidence\":0},\"gender\":{\"value\":\"MALE\",\"confidence\":0.83},\"ageAsPerDate\":{\"value\":\"1.1.1995\",\"confidence\":1.0},\"relationName\":{\"value\":\"DILIP\",\"confidence\":0.51},\"age\":{\"value\":\"24\",\"confidence\":0.99}},\"additionalDetails\":{},\"qualityChecks\":[{\"score\":0.85,\"flag\":false,\"type\":\"BRIGHTNESS\"},{\"score\":1.0,\"flag\":true,\"type\":\"BLACK_AND_WHITE\"},{\"score\":0.35,\"flag\":false,\"type\":\"BLUR\"},{\"score\":0.28,\"flag\":false,\"type\":\"CUT_CARD\"}],\"documentLink\":null}]},\"statusCode\":101}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    } 
    private class PanMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{\"requestId\":\"ef59603f-7721-4765-abf6-26846f200473\",\"result\":{\"documents\":[{\"documentType\":\"PAN\",\"subType\":\"\",\"pageNo\":1,\"ocrData\":{\"dob\":{\"value\":\"20/08/1985\",\"confidence\":1.0},\"doi\":{\"value\":\"\",\"confidence\":0},\"father\":{\"value\":\"SUSHIL KUMAR GUPTA\",\"confidence\":0.89},\"name\":{\"value\":\"SHASHANK GUPTA\",\"confidence\":1.0},\"pan\":{\"value\":\"AQDPG5537F\",\"confidence\":1.0}},\"additionalDetails\":{},\"qualityChecks\":[{\"score\":0.45,\"flag\":false,\"type\":\"BRIGHTNESS\"},{\"score\":0.0,\"flag\":false,\"type\":\"BLACK_AND_WHITE\"},{\"score\":0.4,\"flag\":false,\"type\":\"BLUR\"},{\"score\":0.21,\"flag\":false,\"type\":\"CUT_CARD\"}],\"documentLink\":null}]},\"statusCode\":101}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    private class PassportMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{\"requestId\":\"e44274c8-f12a-473f-9801-2b3c6dff5530\",\"result\":{\"documents\":[{\"documentType\":\"PASSPORT\",\"subType\":\"FRONT\",\"pageNo\":1,\"ocrData\":{\"countryCode\":{\"value\":\"IND\",\"confidence\":0.97},\"dob\":{\"value\":\"17/07/1988\",\"confidence\":0.9},\"doe\":{\"value\":\"30/10/2026\",\"confidence\":0.9},\"doi\":{\"value\":\"31/10/2016\",\"confidence\":0.9},\"gender\":{\"value\":\"MALE\",\"confidence\":0.98},\"givenName\":{\"value\":\"ANIL KUMAR\",\"confidence\":0.97},\"nationality\":{\"value\":\"INDIAN\",\"confidence\":0.98},\"passportNumber\":{\"value\":\"P5278407\",\"confidence\":0.99},\"placeOfBirth\":{\"value\":\"KARIMNAGAR, TELANGANA\",\"confidence\":0.95},\"placeOfIssue\":{\"value\":\"HYDERABAD\",\"confidence\":0.97},\"surname\":{\"value\":\"NEELAM\",\"confidence\":0.97},\"type\":{\"value\":\"P\",\"confidence\":0.97},\"mrzLine1\":{\"value\":\"P<INDNEELAM<<ANIL<KUMAR<<<<<<<<<<<<<<<<<<<<<\",\"confidence\":0.97},\"mrzLine2\":{\"value\":\"P5278407<0IND8807179M2610302<<<<<<<<<<<<<<<0\",\"confidence\":0.97}},\"additionalDetails\":{},\"qualityChecks\":[{\"score\":0.61,\"flag\":false,\"type\":\"BRIGHTNESS\"},{\"score\":0.0,\"flag\":false,\"type\":\"BLACK_AND_WHITE\"},{\"score\":0.02,\"flag\":false,\"type\":\"BLUR\"},{\"score\":0.22,\"flag\":false,\"type\":\"CUT_CARD\"}],\"documentLink\":null}]},\"statusCode\":101}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    private class DLMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{\"requestId\":\"cd6289cc-27a9-46b5-b8aa-03bfd2ebe7ba\",\"result\":{\"documents\":[{\"documentType\":\"DL\",\"subType\":\"\",\"pageNo\":null,\"ocrData\":{\"dlNo\":{\"value\":\"MP45N-2013-0022386\",\"confidence\":0.81},\"name\":{\"value\":\"HARSHIT\",\"confidence\":0.83},\"dob\":{\"value\":\"21-12-1994\",\"confidence\":0.71},\"doi\":{\"value\":\"26-02-2013\",\"confidence\":0.97},\"doe\":{\"value\":\"25-02-2033\",\"confidence\":0.93},\"relationName\":{\"value\":\"RAJENDRA GOYAL GOYAL\",\"confidence\":0.8},\"address\":{\"value\":\"C. S. A. MARG RANPAUR JHABUA, MP\",\"confidence\":0.8},\"pin\":{\"value\":\"\",\"confidence\":0.0}},\"additionalDetails\":{\"faceDetected\":true,\"addressSplit\":{\"building\":\"\",\"city\":\"\",\"district\":\"Jhabua\",\"pin\":\"\",\"floor\":\"\",\"house\":\"\",\"locality\":\"RANPAUR\",\"state\":\"\",\"street\":\"C. S. A. MARG\",\"complex\":\"\",\"landmark\":\"\",\"untagged\":\"MP\"}}}]},\"statusCode\":101}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    private class InvalidMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{\"requestId\":\"cd6289cc-27a9-46b5-b8aa-03bfd2ebe7ba\",\"result\":{\"documents\":null},\"statusCode\":101}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    @testSetup 
    static void setup() {
        Integration_Master__c  intMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c(
            Active__c  = true,
            End_Point_URL__c ='emailendpoint',
            HTTP_Method__c ='GET',
            API_Key__c ='epikey',
            Timeout__c ='12000',
            Apiuser__c='apiuser',
            Name = 'DocumentCompressService'
            
        ),true);
        Integration_Master__c  intMaster1 = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c(
            Active__c  = true,
            End_Point_URL__c ='emailendpoint',
            HTTP_Method__c ='GET',
            API_Key__c ='epikey',
            Timeout__c ='12000',
            Apiuser__c='apiuser',
            Name = 'Adhar OCR'
            
        ),true);
        Integration_Master__c  intMaster2 = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c(
            Active__c  = true,
            End_Point_URL__c ='emailendpoint',
            HTTP_Method__c ='GET',
            API_Key__c ='epikey',
            Timeout__c ='12000',
            Apiuser__c='apiuser',
            Name = 'Voter ID OCR'
            
        ),true);
        Integration_Master__c  intMaster3 = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c(
            Active__c  = true,
            End_Point_URL__c ='emailendpoint',
            HTTP_Method__c ='GET',
            API_Key__c ='epikey',
            Timeout__c ='12000',
            Apiuser__c='apiuser',
            Name = 'Passport OCR'
            
        ),true);
        Integration_Master__c  intMaster4 = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c(
            Active__c  = true,
            End_Point_URL__c ='emailendpoint',
            HTTP_Method__c ='GET',
            API_Key__c ='epikey',
            Timeout__c ='12000',
            Apiuser__c='apiuser',
            Name = 'Pan Card OCR'
            
        ),true);
        Integration_Master__c  intMaster5 = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c(
            Active__c  = true,
            End_Point_URL__c ='emailendpoint',
            HTTP_Method__c ='GET',
            API_Key__c ='epikey',
            Timeout__c ='12000',
            Apiuser__c='apiuser',
            Name = 'Driving License OCR'
            
        ),true);
        Document_Master__c  docMaster = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name          = 'AUWheels0006',
            Document_Name__c = 'Application Aadhaar Picture'
            
        ),true);
        Document_Master__c  docMaster2 = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name          = 'AUWheels0009',
            Document_Name__c = 'EKYC PDF'
            
        ),true);
        
        Document_Master__c  docMaster3 = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name          = 'AUWheels0001',
            Document_Name__c = 'Pan/Form60',
            Document_Id__c = System.Label.DocumentPan
        ),true);

        
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c      = '10201',
            Stage__c        = 'QDE'
            
        ),true);
        
        Applicant__c appl  = (Applicant__c) TestFactory.createSObject(new Applicant__c(
            First_Name__c  = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c   = 'Mandal',
            Email__c       = 'test@gmail.com',            
            KYC_Type__c     = 'Aadhaar - Biometric',
            KYC_Status__c  = 'Pending',
            Aadhaar_Number__c = '123456786543',
            Loan__c       =  loanAppl.Id,
            Aadhaar_Address__c = 'House no 123 ~ Sarai Kale Khan ~ Delhi ~ 110013 ~ 110013 ~ 110013 ~ 110013'
        ),true);
        
        Address__c  addrss = (Address__c )TestFactory.createSObject(new Address__c (
            Address_Line_1__c = 'C-20',
            Address_Line_2__c = 'Govindpuri',
            Address_Line_3__c = 'New Delhi',
            City__c          = 'New Delhi',
            Pincode__c        = '110001',
            Address_Type__c   = 'Permanent',
            Applicant__c     =  appl.Id          
        ),true);       
        
        Document_Checklist__c   docChecklst = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMaster.Id,
            Applicant__c    = appl.Id
        ),true);
        Document_Checklist__c   docChecklst2 = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMaster2.Id,
            Applicant__c    = appl.Id
        ),true);
         Document_Checklist__c   docChecklst3 = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMaster3.Id,
            Applicant__c    = appl.Id
        ),true);
        
        //Create Document
        ContentVersion cv3 = new ContentVersion();
        cv3.Title = 'Test Document';
        cv3.PathOnClient = 'TestDocument.pdf';
        cv3.VersionData = Blob.valueOf('Test Content');
        cv3.IsMajorVersion = true;
        cv3.isActive__c = true;
        Insert cv3;
        
        //Get Content Documents
        Id conDocId3 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv3.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl3 = New ContentDocumentLink();
        cdl3.LinkedEntityId = docChecklst3.Id;
        cdl3.ContentDocumentId = conDocId3;
        cdl3.shareType = 'V';
        Insert cdl3;
        
        
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        cv.isActive__c = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = docChecklst.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        //Create Document
        ContentVersion cv2 = new ContentVersion();
        cv2.Title = 'Test Document';
        cv2.PathOnClient = 'TestDocument.pdf';
        cv2.VersionData = Blob.valueOf('Test Content');
        cv2.IsMajorVersion = true;
        cv2.isActive__c = true;
        Insert cv2;
        
        //Get Content Documents
        Id conDocId2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv2.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = docChecklst2.Id;
        cdl2.ContentDocumentId = conDocId2;
        cdl2.shareType = 'V';
        Insert cdl2;
        
    }
    static testMethod void  uploadFileTest(){
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Applicant__c appl =[SELECT id,First_Name__c,Loan__c FROM Applicant__c LIMIT 1];
        Document_Checklist__c docChkRec = [SELECT Id FROM Document_Checklist__c LIMIT 1];
        Document_Master__c  docMaster = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name          = 'AUWheels0003',
            Document_Name__c = 'Aadhaar Card'
            
        ),true);
        Document_Checklist__c   docChecklst = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMaster.Id,
            Applicant__c    = appl.Id
        ),true);
        Test.startTest();
        LOSDocumentUploadController.uploadFile('Test Content New', 'TestFileHarshit', docChkRec.Id, appl.Id,appl.Loan__c);
        //LOSDocumentUploadController.uploadFile('Test Content New', 'TestFileHarshit', docChecklst.Id, appl.Id);
        //LOSDocumentUploadController.getDocumentChecklist(appl.Id,'AUWheels0006');
        //LOSDocumentUploadController.getDocumentChecklist('123434443','AUWheels0006');
        appl.Aadhaar_Number__c ='843880605528';
        //LOSDocumentUploadController.updateOCRData(JSON.serialize(appl) ,JSON.serialize(docChkRec),true);
        //LOSDocumentUploadController.updateOCRData('' ,'',true);
        Test.stopTest();
    }
    
    static testMethod void  updateOcrData(){
        List<Applicant__c> applicants = [SELECT Id,PAN__c,Aadhaar_Number__c,Aadhaar_Address__c,Mobile_Number__c FROM Applicant__c Order by Createddate desc];
        List<Document_Checklist__c> checks = [SELECT Id FROM Document_Checklist__c Where Applicant__c != null AND Document_Master__r.Document_Name__c = 'EKYC PDF'];
        List<ContentVersion> cvs = [SELECT Id FROM ContentVersion];
        Test.startTest();
        String response = LOSDocumentUploadController.updateOCRData(JSON.serialize(applicants[0]) , JSON.serialize(checks[0]), true, true, cvs[0].Id);
        System.assertEquals(String.isNotBlank(response), true);  
         Test.stopTest();
    }
        static testMethod void  updateOcrData2(){
        List<Applicant__c> applicants = [SELECT Id,PAN__c,Aadhaar_Number__c,Aadhaar_Address__c,Mobile_Number__c FROM Applicant__c Order by Createddate desc];
        List<Document_Checklist__c> checks = [SELECT Id FROM Document_Checklist__c Where Applicant__c != null AND Document_Master__r.Document_Name__c = 'EKYC PDF'];
        List<ContentVersion> cvs = [SELECT Id FROM ContentVersion];
        Test.startTest();
        applicants[0].Aadhaar_Address__c = 'House no 123 ~ Sarai Kale Khan ~ Delhi ~ 110013';
        String response = LOSDocumentUploadController.updateOCRData(JSON.serialize(applicants[0]) , JSON.serialize(checks[0]), true, true, cvs[0].Id);
        System.assertEquals(String.isNotBlank(response), true);  
         Test.stopTest();
    }
    
    static testMethod void versionFileTest(){
        List<Applicant__c> applicants = [SELECT Id,PAN__c,Mobile_Number__c FROM Applicant__c Order by Createddate desc];
        List<Document_Checklist__c> checks = [SELECT Id FROM Document_Checklist__c Where Applicant__c != null AND Document_Master__r.Document_Name__c = 'Application Aadhaar Picture'];
        Map<String,String> response = LOSDocumentUploadController.getVersionFiles(applicants[0].Id);
        System.assertEquals(response != null, true);    
    }
    
    @isTest
    static void handleLargeFileTest(){
        List<Applicant__c> applicants = [SELECT Id,PAN__c,Mobile_Number__c FROM Applicant__c Order by Createddate desc];
        List<Document_Checklist__c> checks = [SELECT Id FROM Document_Checklist__c Where Applicant__c != null AND Document_Master__r.Document_Name__c = 'Application Aadhaar Picture'];
        List<ContentVersion> cvs = [SELECT Id FROM ContentVersion];
        Test.startTest();
            LOSDocumentUploadController.handleStandardUpload(cvs[0].Id,checks[0].Id,applicants[0].Id,'');
        Test.stopTest();
            //  System.assertEquals(response != null, true);    
   }
    
    static testMethod void checkUploadDocumentBridgeAppTest(){
        List<Applicant__c> applicants = [SELECT Id,PAN__c,Mobile_Number__c FROM Applicant__c Order by Createddate desc];
        List<Document_Checklist__c> checks = [SELECT Id FROM Document_Checklist__c Where Applicant__c != null AND Document_Master__r.Document_Name__c = 'Application Aadhaar Picture'];
        String response = LOSDocumentUploadController.checkUploadDocumentBridgeApp(checks[0].Id);
        System.assertEquals(String.isNotBlank(response), true);    
    }
    
    static testMethod void checkUploadDocumentLargeFileTest(){
        List<Applicant__c> applicants = [SELECT Id,PAN__c,Mobile_Number__c FROM Applicant__c Order by Createddate desc];
        List<Document_Checklist__c> checks = [SELECT Id FROM Document_Checklist__c Where Applicant__c != null AND Document_Master__r.Document_Name__c = 'Application Aadhaar Picture'];
        String response = LOSDocumentUploadController.checkUploadDocumentLargeFile(checks[0].Id,'3500');
        System.assertEquals(String.isNotBlank(response), true);  
    }
    
    static testMethod void  aadharOCRTest(){
        Test.setMock(HttpCalloutMock.class, new AadharMock());
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c LIMIT 1];
        Document_Checklist__c docChkRec = [SELECT Id FROM Document_Checklist__c LIMIT 1];
        Test.startTest();
        LOSDocumentUploadController.getOCRData(docChkRec.Id,'AADHAAR',appl.Id);
        Test.stopTest();
    }
    static testMethod void  voterOCRTest(){
        Test.setMock(HttpCalloutMock.class, new VoterMock());
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c LIMIT 1];
        Document_Checklist__c docChkRec = [SELECT Id FROM Document_Checklist__c LIMIT 1];
        Test.startTest();
        LOSDocumentUploadController.getOCRData(docChkRec.Id,'VOTER',appl.Id);
        Test.stopTest();
    }
    static testMethod void  panOCRTest(){
        Test.setMock(HttpCalloutMock.class, new PanMock());
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c LIMIT 1];
        Document_Checklist__c docChkRec = [SELECT Id FROM Document_Checklist__c LIMIT 1];
        Test.startTest();
        LOSDocumentUploadController.getOCRData(docChkRec.Id,'PAN',appl.Id);
        Test.stopTest();
    }
    static testMethod void  passportOCRTest(){
        Test.setMock(HttpCalloutMock.class, new PassportMock());
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c LIMIT 1];
        Document_Checklist__c docChkRec = [SELECT Id FROM Document_Checklist__c LIMIT 1];
        Test.startTest();
        LOSDocumentUploadController.getOCRData(docChkRec.Id,'PASSPORT',appl.Id);
        Test.stopTest();
    }
    static testMethod void  dlOCRTest(){
        Test.setMock(HttpCalloutMock.class, new DLMock());
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c LIMIT 1];
        Document_Checklist__c docChkRec = [SELECT Id FROM Document_Checklist__c LIMIT 1];
        Test.startTest();
        LOSDocumentUploadController.getOCRData(docChkRec.Id,'DL',appl.Id);
        Test.stopTest();
    }
    static testMethod void  invalidOCRTest(){
        Test.setMock(HttpCalloutMock.class, new InvalidMock());
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c LIMIT 1];
        Document_Checklist__c docChkRec = [SELECT Id FROM Document_Checklist__c LIMIT 1];
        Test.startTest();
        LOSDocumentUploadController.getOCRData(docChkRec.Id,'DL',appl.Id);
        LOSDocumentUploadController.getOCRData(docChkRec.Id,'PASSPORT',appl.Id);
        LOSDocumentUploadController.getOCRData(docChkRec.Id,'PAN',appl.Id);
        LOSDocumentUploadController.getOCRData(docChkRec.Id,'VOTER',appl.Id);
        LOSDocumentUploadController.getOCRData(docChkRec.Id,'AADHAAR',appl.Id);
        Test.stopTest();
    }
    @isTest
    public static void testgetDocumentChecklist(){
        List<Loan_Application__c> loanApps = [SELECT Id FROM Loan_Application__c];
        List<Applicant__c> apps = LOSDocumentManagerController.getApplicants(loanApps[0].Id);
        String result =  LOSDocumentUploadController.getDocumentChecklist(apps[0].Id,'Application Aadhaar Picture','','',''  );
        System.assertEquals(String.isBlank(result), false);
    }
    
    /*@isTest
    public static void testHandleStandardUpload(){
        List<ContentVersion> lstContentVersion = [SELECT Id FROM ContentVersion WHERE Title = 'Test Document'];
        List<Document_Checklist__c> docChecks = [SELECT Id FROM Document_Checklist__c LIMIT 1];
        List<Loan_Application__c> loanApps = [SELECT Id FROM Loan_Application__c LIMIT 1];
        List<Applicant__c> appl =[SELECT id,First_Name__c FROM Applicant__c LIMIT 1];
        Test.startTest();
        String result =  LOSDocumentUploadController.handleStandardUpload(lstContentVersion[0].Id,docChecks[0].Id,appl[0].Id,loanApps[0].Id);
        System.assertEquals(String.isBlank(result), false);
        Test.stopTest();
    }*/
    
    @isTest
    public static void testGetVersionFilesByChecklistId(){
        List<Document_Checklist__c> docChecks = [SELECT Id FROM Document_Checklist__c Where Document_Master__r.Document_Id__c =: System.Label.DocumentPan  LIMIT 1];
        Test.startTest();
        LOSDocumentUploadController.getVersionFilesByChecklistId(docChecks[0].Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testGetVersionFilesByChecklist() {
        List<Document_Checklist__c> docChecks = [SELECT Id,Applicant__c FROM Document_Checklist__c Where Document_Master__r.Document_Id__c =: System.Label.DocumentPan LIMIT 1];
        Test.startTest();
        try{
        	LOSDocumentUploadController.getVersionFilesByChecklist(docChecks[0].Applicant__c);
        }
        catch(Exception e) {
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testHandleLargeFile() {
        List<ContentVersion> lstContentVersion = [SELECT Id FROM ContentVersion WHERE Title = 'Test Document'];
        List<Document_Checklist__c> docChecks = [SELECT Id FROM Document_Checklist__c LIMIT 1];
        List<Loan_Application__c> loanApps = [SELECT Id FROM Loan_Application__c LIMIT 1];
        List<Applicant__c> appl =[SELECT id,First_Name__c FROM Applicant__c LIMIT 1];
        Test.startTest();
        LOSDocumentUploadController.handleLargeFile(lstContentVersion[0].Id,docChecks[0].Id,appl[0].Id,loanApps[0].Id);
        Test.stopTest();
    }
    
}