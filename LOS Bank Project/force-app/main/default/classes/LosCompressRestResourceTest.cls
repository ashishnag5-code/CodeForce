@isTest
public class LosCompressRestResourceTest {
    @TestSetup
    public static void makeData(){
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            Branch_Queue__c=grp.Id
        ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Branch_Master__c = accInstance.Id
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
        Integration_Master__c intmassearch1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'DocumentCompressService',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/SFDCKarzaService/NameMatch',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
        ),true);
    }
    testmethod static void main(){
        Test.setMock(HttpCalloutMock.class, new LOSDocMock());
        Test.startTest();
        Applicant__c obj = [Select Id from Applicant__c limit 1];
        Loan_Application__c objLoan = [Select Id from Loan_Application__c limit 1];
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'apexrest/v1/DocumentCompressAPI';
        req.httpMethod = 'POST';
        String requestBody = '{"applicantId":"'+obj.Id+'","Name":"Hello","base64String":"Hello World","recordId":"'+objLoan.Id+'"}';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;
        LosCompressRestResource.getDocCompressed();
        Test.stopTest();
    }
    testmethod static void main2(){
        Test.setMock(HttpCalloutMock.class, new LOSDocMock());
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = 'apexrest/v1/DocumentCompressAPI';
        req.httpMethod = 'POST';
        String requestBody = '{"lead":"1234"}';
        req.requestBody = Blob.valueOf(requestBody);
        RestContext.request = req;
        RestContext.response = res;
        LosCompressRestResource.getDocCompressed();
        Test.stopTest();
    }
    private class LOSDocMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            DocumentCompressReqResWrapper.LOSDocCompressResWrapper objResponse = new DocumentCompressReqResWrapper.LOSDocCompressResWrapper();
            objResponse.OutputFileBase64string = 'Hello World';
            objResponse.OutputStatus = System.Label.LOS_DocCompress_Success;
            String strBody = JSON.serialize(objResponse);
            res.setBody(strBody);
            res.setStatusCode(200);
            return res;
        }
    }
}