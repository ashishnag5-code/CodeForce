@isTest
public class AmlTest {
    @testSetup
    static void testDataSetup() {
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Stage__c='QDE'
            
        ), true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Mobile_Number__c = '9999999999',
            Aadhaar_Number__c = '9999999999',AML_Status__c ='Approved',
            PAN__c = '9999999999',
            Loan__c =loanAppl.Id
        ),true);
        Bureau_Results__c BureauRes = (Bureau_Results__c)TestFactory.createSObject(new Bureau_Results__c(
            Applicant__c = appl.id, Bureau__c = 'CIBIL',
            Account_High_Credit_Amount__c = 100
        ),true);
        Address__c  addInstance = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c ='TestAddressline1',
            Address_Line_2__c ='TestAddressline2',
            Address_Line_3__c ='TestAddressline3',
            State__c='MAHARASHTRA',
            City__c='EAST DELHI',
            Area_Name__c='JAGJIT NAGAR',
            Area_Type__c='Urban',
            Taluka__c='NA',
            Pincode__c='110053',
            Land_mark__c='Testing',
            Applicant__c =appl.Id,
            Status__c='Owned',
            Address_Type__c='Current',
            Type__c='Bungalow'
        ),true);
         Integration_Master__c intmassearch1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'AML',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://api.aubankuat.in/sfdckyc/Clari5RestAPIService/fraudCheck',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
        
        Integration_Checklist__c  intChecklist = (Integration_Checklist__c )TestFactory.createSObject(new Integration_Checklist__c(
            is_Latest__c = true,
            Applicant__c= appl.Id,
            Request_Id__c='IC001001001',
            Integration_Master__c = intmassearch1.Id,
            Loan_Application__c = loanAppl.Id,
            Callback_Request__c = '{"AML_ACTION":null,"batch_mode":"O","callbackurl":"https://osb.aubank.in/Clari5CallBack/callback","datetime":"2023-10-13 23:18:02","errorCode":null,"errorMessage":null,"fields":[{"name":"name","value":"Shanaya  Kapoor"},{"name":"passport","value":"NIL"},{"name":"pan","value":"NIL"},{"name":"mobile","value":"9167266106"},{"name":"email","value":"NIL"},{"name":"driving_license","value":"NIL"},{"name":"aadhar_no","value":"1730521410821212"},{"name":"ckyc","value":"NIL"},{"name":"vid","value":"NIL"},{"name":"address","value":"Test, test, NORTH WEST DELHI, 110085"},{"name":"cinno","value":"NIL"},{"name":"identification_id_1","value":"NIL"},{"name":"identification_id_2","value":"NIL"},{"name":"identification_id_3","value":"NIL"},{"name":"dob","value":"6-10-2004"},{"name":"e/i","value":"I"},{"name":"nationality","value":"INDIA"},{"name":"country","value":"INDIA"},{"name":"gender","value":"Male"}],"MATCH":null,"referenceid":"SFDCUAT_80cbe5373bed41d395321ac06","refid":"DEL0000036763","status":null,"systemname":"SFDC","userid":"SYS"}',
            Response__c = '{"AML_ACTION":"Approved","ReferenceId":"SFDCUAT_80cbe5373bed41d395321ac06","systemName":"SFDC","UserId":"SYS","BatchMode":"O","Refid":"DEL0000036763","MATCH":"NO","status":{"status":"success","errorDetails":""}}'
        ), true);

    }

    @isTest
    static void testMethod1() {
        Applicant__c applicant = [SELECT Id, Customer_Name__c, Passport_Number__c, PAN__c, Mobile_Number__c, Email__c, Driving_License_Id__c, Aadhaar_Number__c, CKYC__c,
            Voter_Id__c, CIN__c, Dob__c, Gender__c, Customer_Type__c FROM Applicant__c];
        Aml.getApplicant(applicant.Id);
        Aml.getUpdatedApplicantCibil(applicant.Id);
        Aml.getRelatedFilesByRecordId(applicant.Id);
        Aml.getIntegCheckList(applicant.Id);
        AMLWrapper wrapperInst = new AMLWrapper();
        wrapperInst.fields = new List<AMLWrapper.Fields>();
        Aml.applcntRecLst = new List<Applicant__c>{applicant};
        Aml.generateFieldsJSON(wrapperInst);
    }
    @isTest
    static void testMethod3() {
        Applicant__c applicant = [SELECT Id, Customer_Name__c, Passport_Number__c, PAN__c, Mobile_Number__c, Email__c, Driving_License_Id__c, Aadhaar_Number__c, CKYC__c,
            Voter_Id__c, CIN__c, Dob__c, Gender__c, Customer_Type__c FROM Applicant__c];
        Address__c addr = [SELECT Id, Name FROM Address__c LIMIT 1];
        
         Bureau_Results__c BureauRes = (Bureau_Results__c)TestFactory.createSObject(new Bureau_Results__c(
           Applicant__c = applicant.id,
           Account_High_Credit_Amount__c = 100,
           Bureau__c = 'CIBIL'
       ),true);
        
        addr.Bureau_Results__c = BureauRes.Id;
        update addr;
        
        Id cartRecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('Cart').getRecordTypeId();
        Bank_Account_Records__c cartAccountInstance = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
            Applicant__c = applicant.Id,
            Account_Type__c = 'ODCC',
            Loan_Amount__c =1000,
            EMI_Amount__c =200,
            RecordTypeId = cartRecordTypeId,
            Bureau_Results__c = BureauRes.Id,
            Analysis_Data__c = '{"monthlyBalancesDetails":"","monthlyCreditsDetails":"","bankName":"AU","accountType":"SAVING","toBeConsidered":false,"status":"OTHERS"}',
            Account_Opening_Date__c = System.today()
        ), true);
        
        Test.setMock(HttpCalloutMock.class, new AMLMock());
        test.StartTest();
        Aml.callAmlHandler(applicant.Id);
        test.stopTest();
        Aml.callAml(applicant.Id);
        //Create Document
        List<ContentVersion> cvList = new List<ContentVersion>();
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Cibil';
        cv.PathOnClient = 'Cibil.txt';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        cv.isActive__c = true;
        cvList.add(cv) ;
        
        //Create Document
        ContentVersion cv2 = new ContentVersion();
        cv2.Title = 'Response';
        cv2.PathOnClient = 'Response.txt';
        cv2.VersionData = Blob.valueOf('Test Content');
        cv2.IsMajorVersion = true;
        cv2.isActive__c = true;
        cvList.add(cv2) ;
        insert cvList;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        //Get Content Documents
        Id conDocId2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv2.Id].ContentDocumentId;
        
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = BureauRes.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        cdlList.add(cdl);
        
        
        
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = BureauRes.Id;
        cdl2.ContentDocumentId = conDocId2;
        cdl2.shareType = 'V';
        cdlList.add(cdl2);
        insert cdlList;
        
        Aml.cloneRelatedFiles(new List<Bureau_Results__c>{BureauRes},BureauRes);
    }
     @isTest
    static void testMethod2() {
        Applicant__c applicant = [SELECT Id, Customer_Name__c, Passport_Number__c, PAN__c, Mobile_Number__c, Email__c, Driving_License_Id__c, Aadhaar_Number__c, CKYC__c,
            Voter_Id__c, CIN__c, Dob__c, Gender__c, Customer_Type__c FROM Applicant__c];
        Address__c addr = [SELECT Id, Name FROM Address__c LIMIT 1];
        
         Bureau_Results__c BureauRes = (Bureau_Results__c)TestFactory.createSObject(new Bureau_Results__c(
           Applicant__c = applicant.id,
           Account_High_Credit_Amount__c = 100,
           Bureau__c = 'CIBIL'
       ),true);
        
        addr.Bureau_Results__c = BureauRes.Id;
        update addr;
        
        Id cartRecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('Cart').getRecordTypeId();
        Bank_Account_Records__c cartAccountInstance = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
            Applicant__c = applicant.Id,
            Account_Type__c = 'ODCC',
            Loan_Amount__c =1000,
            EMI_Amount__c =200,
            RecordTypeId = cartRecordTypeId,
            Bureau_Results__c = BureauRes.Id,
            Analysis_Data__c = '{"monthlyBalancesDetails":"","monthlyCreditsDetails":"","bankName":"AU","accountType":"SAVING","toBeConsidered":false,"status":"OTHERS"}',
            Account_Opening_Date__c = System.today()
        ), true);
        
        Test.setMock(HttpCalloutMock.class, new AMLMock());
        test.StartTest();
        Aml.callAmlHandler(applicant.Id);
        test.stopTest();
        Aml.callAml(applicant.Id);
        //Create Document
        List<ContentVersion> cvList = new  List<ContentVersion>();
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Cibil';
        cv.PathOnClient = 'Cibil.txt';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        cv.isActive__c = true;
        cvList.add(cv);
        
        //Create Document
        ContentVersion cv2 = new ContentVersion();
        cv2.Title = 'Response';
        cv2.PathOnClient = 'Response.txt';
        cv2.VersionData = Blob.valueOf('Test Content');
        cv2.IsMajorVersion = true;
        cv2.isActive__c = true;
        cvList.add(cv2);
        insert cvList;
        
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        //Get Content Documents
        Id conDocId2 = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv2.Id].ContentDocumentId;
        
        //Create ContentDocumentLink
        List<ContentDocumentLink> cdlLink = new  List<ContentDocumentLink>(); 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = BureauRes.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        cdlLink.add(cdl);
        
        
        
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl2.LinkedEntityId = BureauRes.Id;
        cdl2.ContentDocumentId = conDocId2;
        cdl2.shareType = 'V';
        cdlLink.add(cdl2);
        insert cdlLink;
        
        Aml.cloneCibilRecords(applicant.Id,applicant.Id);
        
    }
    @isTest
    static void testAmlFunctionality() {
        Applicant__c applicant = [SELECT Id FROM Applicant__c LIMIT 1];
        Loan_Application__c loanAppl = [SELECT Id, Name FROM Loan_Application__c LIMIT 1];
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Mobile_Number__c = '9999999999',
            Aadhaar_Number__c = '9999999999',
            PAN__c = '9999999999',
            Last_CIBIL_Run_Date__c = Date.today(),
            Loan__c =loanAppl.Id
        ),true);
        
        Bureau_Results__c BureauRes = (Bureau_Results__c)TestFactory.createSObject(new Bureau_Results__c(
           Applicant__c = appl.id,
           Account_High_Credit_Amount__c = 100
       ),true);
        
        appl.Bureau_Results__c = BureauRes.Id;
        update appl;

        Test.setMock(HttpCalloutMock.class, new AmlHttpCalloutMock());
        Test.startTest();
        List<Applicant__c> applicantList = Aml.getApplicant(applicant.Id);
        Aml.getUpdatedApplicantCibil(applicant.Id);
        Aml.ContentDocumentWrapper relatedFiles = Aml.getRelatedFilesByRecordId(applicant.Id);
        List<Integration_Checklist__c> checklist = Aml.getIntegCheckList(applicant.Id);
        Aml.CallAmlHandlerWrapper amlHandlerResponse = Aml.callAmlHandler(appl.Id);
        Aml.checkExistingApplicantCibil(appl.Id);
        System.assertNotEquals(null, applicantList);
        System.assertNotEquals(null, relatedFiles);
        System.assertNotEquals(null, checklist);
        System.assertNotEquals(null, amlHandlerResponse);
        Test.stopTest();
    }
    @isTest
    static void testGetTypeOfWheeler() {
        Applicant__c applicant = [SELECT Id, Loan__r.Product__c FROM Applicant__c LIMIT 1];
        String typeOfWheeler = Aml.getTypeOfWheeler(applicant.Id);
        System.assertNotEquals(null, typeOfWheeler);
    }

    @isTest
    static void testAppWrapper() {
        Applicant__c currentApplicant = [SELECT Id FROM Applicant__c LIMIT 1];
        Applicant__c existingApplicant = new Applicant__c();

        Aml.appWrapper wrapperInstance = new Aml.appWrapper(currentApplicant, existingApplicant);
        System.assertEquals(currentApplicant, wrapperInstance.currentApplicant);
        System.assertEquals(existingApplicant, wrapperInstance.existingApplicant);
    }


    private class AmlHttpCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"response": "your expected response"}');
            res.setStatusCode(200);
            return res;
        }
    }
}