@isTest
public class SignDeskEsignApiControllerTest {
    @testSetup static void setup() {
        Account dealerMaster = (Account)TestFactory.createSObject(new Account(
            Name ='TestAccount',
            Account_Code__c='2103',
            Purchase_City__c='Jaipur',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId()
        ),true);
        Account branchMaster = (Account)TestFactory.createSObject(new Account(
            Name ='Branch M',
            Account_Code__c='21034',
            Purchase_City__c='Jaipur',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Branch').getRecordTypeId()
        ),true);
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Non Individual',
            Stage__c ='QDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Dealer_Master__c = dealerMaster.Id,
            Branch_Master__c = branchMaster.Id
        ),true);
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            Customer_Grade__c ='Premium',
            Customer_Type__c ='Non Individual',
            KYC_Type__c='Driving License',
            AU_Employee__c = 'Yes',
            AU_Employment_status__c='Active',
            Date_of_Joining__c = System.today().addDays(-60),
            Dob__c = System.today().addYears(-30),
            Education_qualification__c='GRADUATE',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        //Address Insertion
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
            Type__c='Bungalow',
             Stability__c ='7',
            Latest_Cibil_Address_Match_Score__c=100
        ),true);
        Document_Master__c  docMaster = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name = 'AUWheels0006',
            Document_Name__c = 'PAN',
            Consider_for_E_Sign__c = true
        ),true);
        
        Document_Checklist__c docChkRecord = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id,
            Loan_Application__c = loanAppl.Id,
            Applicant__c = appl.Id,
            Document_Master__c = docMaster.Id,
            Document_Name__c ='PAN',
            Document_Number__c = 'BEMPN6666N'
        ),true);
        Contentversion objCV = new Contentversion(Title = 'ABC', PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=docChkRecord.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        insert objCV;
        
        //ESignDesk Lead Integration Master
        Integration_Master__c CanDOIntegrationMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='ESignDesk',
            End_Point_URL__c='https://service.aubank.in/SFDCCanDoLeadService/candoLead',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
        Integration_Checklist__c  intChecklist2 = (Integration_Checklist__c )TestFactory.createSObject(new Integration_Checklist__c(
            is_Latest__c = true,
            Applicant__c= appl.Id,
            Request_Id__c=docChkRecord.Id,
            Integration_Master__c = CanDOIntegrationMaster.Id,
            Loan_Application__c = loanAppl.Id,
            Callback_Request__c = '{"message":{"requestTime":"Jun 23, 2023 12:48:46.873 PM IST","dmElapsedTime":90,"responseStatus":"ERROR","error":[{"errorCode":"401","description":"Bad Request"}]}}'
        ),true);
        
        String loanAppName = [Select Id,Name from Loan_Application__c where Id=:loanAppl.Id].Name;
        Contentversion objCVLoanApp = new Contentversion(Title = 'Repayment_SI.pdf', isActive__c=true,PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Loan_Application__c=loanAppName, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        insert objCVLoanApp;
    }
    testmethod static void checkIfEsignEnabled(){
        SignDeskEsignApiController.checkIfEsignEnabled();
    }
    testmethod static void requiredDocumentsUploadCheck(){
        String loanAppId = [Select Id from Loan_Application__c].Id;
        SignDeskEsignApiController.requiredDocumentsUploadCheck(loanAppId);
    }
    testmethod static void requiredDocumentsUploadCheckNoRec(){
        String loanAppId = [Select Id from Applicant__c].Id;
        SignDeskEsignApiController.requiredDocumentsUploadCheck(loanAppId);
    }
    testmethod static void callSignDeskAPiSI(){
        Test.setMock(HttpCalloutMock.class, new CallSignDeskAPiMock());
        String loanAppId = [Select Id from Loan_Application__c].Id;
        List<Id> cvIds = new List<Id>();
        Test.startTest();
        SignDeskEsignApiController.callSignDeskAPi(loanAppId, cvIds,'journeyType','SI');
        Test.stopTest();
    }
    testmethod static void callSignDeskAPiLoanAgreement(){
        Test.setMock(HttpCalloutMock.class, new CallSignDeskAPiMock());
        String loanAppId = [Select Id from Loan_Application__c].Id;
        List<Id> cvIds = new List<Id>();
        Test.startTest();
        SignDeskEsignApiController.callSignDeskAPi(loanAppId, cvIds,'journeyType','Loan Agreement');
        Test.stopTest();
    }
    testmethod static void fieldInvestigationStatusCheckTest(){
        String loanAppId = [Select Id from Loan_Application__c].Id;
        SignDeskEsignApiController.fieldInvestigationStatusCheck(loanAppId);
  
    }
    testmethod static void handleEsignSignDeskAPICallback(){
        Map<Id,ContentVersion> mapCV = new Map<Id,ContentVersion>([Select Id from ContentVersion]);
        Test.startTest();
        try{
            SignDeskEsignApiController.handleEsignSignDeskAPICallback(mapCV);
        } catch(Exception exp){}
        
        Test.stopTest();
    }
    private class CallSignDeskAPiMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            SignDeskEsignApiHandler.SignDeskEsignApiResponseWrapper objResponse = new SignDeskEsignApiHandler.SignDeskEsignApiResponseWrapper();
            SignDeskEsignApiHandler.SignerInfoWrapper siw = new SignDeskEsignApiHandler.SignerInfoWrapper();
            siw.signer_ref_id = '31232';
            siw.signer_id = '31232';
            siw.document_id = '31232';
            siw.invitation_link = '31232';
            siw.reference_doc_id = '31232';
            objResponse.api_response_id = '112321312';
            objResponse.docket_id = '112321312';
            objResponse.message = 'SUCCESS';
            objResponse.error = '';
            objResponse.response_time_stamp = '112321312';
            objResponse.status = 'SUCCESS';
            objResponse.signer_info = new List<SignDeskEsignApiHandler.SignerInfoWrapper>{siw};
            res.setBody(JSON.serialize(objResponse));
            res.setStatusCode(200);
            return res;
        }
    }
}