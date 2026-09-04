@isTest
public with sharing class CPVWaiverDocumentsControllerTest {
    
    @TestSetup
    static void makeData(){

        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Loan_Amount__c  = 12000,
            Product__c='10201',
            Tenure__c=12,
            EMI__c=100,
            ROI__c=0
        ),true); 

        Id recId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId();
        Applicant__c applicant = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            loan__c  = loanAppl.Id,
            First_Name__c   = 'Caroline',
            Last_Name__c  = 'Forbes',
            RecordTypeId = recId
        ),true);


        Document_Master__c master = new Document_Master__c(Document_Name__c  = 'Electricity Bill', Name='Electricity Bill');
        insert master;


        Document_Checklist__c doc = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Status__c  = 'Received',
            Amount__c   = 1000,
            Applicant__c  = applicant.Id,
            Document_Master__c = master.Id,
            Document_Verification_Status__c=GlobalConstants.VERIFIED
        ),true);
        
        Contentversion objCV = new Contentversion(Title = 'ABC', PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=doc.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        insert objCV;

		Id cartRecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('Cart').getRecordTypeId();
        //CART Account
        Bank_Account_Records__c cartAccountInstance = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
            Applicant__c = applicant.Id,
            Account_Type__c = 'ODCC',
            Loan_Amount__c =1000,
            EMI_Amount__c =200,
            RecordTypeId = cartRecordTypeId,
            Analysis_Data__c = '{"monthlyBalancesDetails":"","monthlyCreditsDetails":"","bankName":"AU","accountType":"SAVING","toBeConsidered":false,"status":"OTHERS"}',
            Account_Opening_Date__c = System.today()
        ),true);
        Integration_Master__c CanDOIntegrationMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='Karza Address Split',
            End_Point_URL__c='https://service.aubank.in/SFDCCanDoLeadService/candoLead',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
        Integration_Master__c CanDOIntegrationMaster2 = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='Karza Multiple Address Match',
            End_Point_URL__c='https://service.aubank.in/SFDCCanDoLeadService/candoLead',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
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
            Applicant__c =applicant.Id,
            Status__c='Owned',
            Address_Type__c='Current',
            Type__c='Bungalow',
            Stability__c ='7',
            Source_Type__c ='Cart',
            Latest_Cibil_Address_Match_Score__c=100
        ),true);
    }

    @isTest
    public static void testGetApplicants(){
        Test.startTest();
        Applicant__c app = [Select Id from Applicant__c limit 1];
        ContentVersion cv = [Select Id from ContentVersion limit 1];
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        CPVWaiverDocumentsController.getApplicants(app.Id);
        CPVWaiverDocumentsController.getApplicantDetails(app.Id);
        CPVWaiverDocumentsController.deleteBankStatement(app.Id,conDocId);
        Test.stopTest();
    }
    @isTest
    public static void getProductType(){
        Test.startTest();
        Loan_Application__c app = [Select Id from Loan_Application__c limit 1];
        Applicant__c appli = [Select Id from Applicant__c limit 1];
        CPVWaiverDocumentsController.getProductType(app.Id);
        CPVWaiverDocumentsController.getProductType(appli.Id);
        Test.stopTest();
    }
    
	@isTest
    public static void getVerifiedRecords(){
        Test.startTest();
        Applicant__c app = [Select Id from Applicant__c limit 1];
        CPVWaiverDocumentsController.getVerifiedRecords(app.Id,new List<String> {'Electricity Bill'});
        Test.stopTest();
    }
    @isTest
    public static void checkIfAlreadyUploadedForFinancials(){
        Test.startTest();
        Applicant__c app = [Select Id from Applicant__c limit 1];
        CPVWaiverDocumentsController.checkIfAlreadyUploadedForFinancials(app.Id,new List<String> {'Electricity Bill'});
        Test.stopTest();
    }
    @isTest
    public static void viewLatestUploadedBankStatement(){
        Test.startTest();
        Applicant__c app = [Select Id from Applicant__c limit 1];
        CPVWaiverDocumentsController.viewLatestUploadedBankStatement(app.Id,'Electricity Bill');
        try {
           CPVWaiverDocumentsController.viewLatestUploadedBankStatement(app.Id,'Electricity'); 
        } catch(Exception exp){}
        Test.stopTest();
    }
    @isTest
    public static void getUploadedITRS(){
        Test.startTest();
        Applicant__c app = [Select Id from Applicant__c limit 1];
        CPVWaiverDocumentsController.getUploadedITRS(app.Id,'Electricity Bill');
        try {
           CPVWaiverDocumentsController.getUploadedITRS(app.Id,'Electricity'); 
        } catch(Exception exp){}
        Test.stopTest();
    }
    @isTest
    public static void getAmount(){
        Test.startTest();
        Applicant__c app = [Select Id from Applicant__c limit 1];
        CPVWaiverDocumentsController.getAmount(app.Id,'Electricity Bill');
        Test.stopTest();
    }
    @isTest
    public static void checkIfAlreadyUploaded(){
        Test.startTest();
        Applicant__c app = [Select Id from Applicant__c limit 1];
        CPVWaiverDocumentsController.checkIfAlreadyUploaded(app.Id,'Electricity Bill');
        Test.stopTest();
    }
    @isTest
    public static void initalizeRelationNameMatchPer(){
        Test.startTest();
        Document_Checklist__c dc = [Select Id from Document_Checklist__c limit 1];
        //CPVWaiverDocumentsController.initalizeRelationNameMatchPer(dc.Id);
        Test.stopTest();
    }
    @isTest
    public static void markVerified(){
        Test.startTest();
        Applicant__c app = [Select Id from Applicant__c limit 1];
        KarzaElectricityBillHandler.KarzaElectricityBillResult obj = new KarzaElectricityBillHandler.KarzaElectricityBillResult();
        obj.address = 'SHOP IN-217-A G/F F/P SHAHPUR JAT NEW DELHI 110049';
        obj.amount_payable = '2730.00';
        obj.bill_amount = '';
        obj.bill_date = '';
        obj.bill_due_date = '20-05-2019';
        obj.bill_issue_date = '';
        obj.consumer_name = 'ABC';
        obj.consumer_number = '2374';
        obj.email_address = '';
        obj.mobile_number = '';
        obj.total_amount = '';
        CPVWaiverDocumentsController.markVerified(app.Id,'Electricity Bill','78776',JSON.serialize(obj),100);
        Document_Master__c master = [Select Id,Document_Name__c,Name from Document_Master__c limit 1];
        master.Document_Name__c = 'gas bill';
        master.name='gas bill';
        update master;
        CPVWaiverDocumentsController.markVerified(app.Id,'gas bill','78776','{"GivenUpSubsidy":"1000"}',100);
        master.Document_Name__c = 'png bill';
        master.name='png bill';
        update master;
        CPVWaiverDocumentsController.markVerified(app.Id,'png bill','78776','{"Bill_Amount":"1000"}',100);
        Test.stopTest();
    }
    
    @isTest
    public static void addressMatch(){
        Test.setMock(HttpCalloutMock.class, new addressMock());
        Test.startTest();
        Applicant__c applicant = [Select Id from Applicant__c limit 1];
        Loan_Application__c loanApp = [Select Id from Loan_Application__c limit 1];
        CPVWaiverDocumentsController.addressMatch('',applicant.Id,loanApp.Id,'');
        Test.stopTest();
    }
    @isTest
    public static void callValidateAddressMatch(){
        Test.setMock(HttpCalloutMock.class, new addressMock());
        Test.startTest();
        Applicant__c applicant = [Select Id from Applicant__c limit 1];
        Loan_Application__c loanApp = [Select Id from Loan_Application__c limit 1];
        Address__c  addInstance = new Address__c(
            Address_Line_1__c ='AL1',
            Address_Line_2__c ='AL2',
            Address_Line_3__c ='AL3',
            State__c='MAHARASHTRA',
            City__c='EAST DELHI',
            Area_Name__c='JAGJIT NAGAR',
            Area_Type__c='Urban',
            Taluka__c='NA',
            Pincode__c='110053',
            Land_mark__c='Testing',
            Applicant__c =applicant.Id,
            Status__c='Owned',
            Address_Type__c='Current',
            Type__c='Bungalow',
            Source_Type__c ='Cart');
        CPVWaiverDocumentsController.callValidateAddressMatch(JSON.serialize(addInstance),applicant.Id,'Current');
        Test.stopTest();
    }
    @isTest
    public static void getServiceProviderInformation(){
        Test.startTest();
        Applicant__c applicant = [Select Id from Applicant__c limit 1];
        Loan_Application__c loanApp = [Select Id from Loan_Application__c limit 1];
        Generic_Master__c objGM = new Generic_Master__c(Status__c ='Active', State__c='Rajasthan', Stage_Type__c='Kuch', Stage_Number__c =13123,
                                                       Recordtypeid=Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByDeveloperName().get('Address_Type').getRecordTypeId());
        insert objGM;
        CPVWaiverDocumentsController.getServiceProviderInformation('Address_Type');
        Test.stopTest();
    }
    private class addressMock implements HttpCalloutMock{
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            LOSAddressSplitHandler.AddressSplitResponseWrapper objResponse = new LOSAddressSplitHandler.AddressSplitResponseWrapper();
            /*
            LOSAddressSplitHandler.AddressSplitResponseResultWrapper objASPRW = new LOSAddressSplitHandler.AddressSplitResponseResultWrapper();
            objASPRW.Care_Of ='132';
            objASPRW.House = 'L4';
            objASPRW.Floor ='First';
            objASPRW.Building ='Ananda';
            objASPRW.Complex ='B';
            objASPRW.Street ='TestAddressline1';
            objASPRW.Untagged ='';
            objASPRW.locality ='';
            objASPRW.State ='MAHARASHTRA';
            objASPRW.District ='';
            objASPRW.City ='Jaipur';
            objASPRW.Landmark ='';
            objASPRW.Pin =302026;
            */
            objResponse.request_id = '1132321';
            objResponse.status_code = '200';
            //objResponse.result = objASPRW;
            String strBody = JSON.serialize(objResponse);
            res.setBody(strBody);
            res.setStatusCode(200);
            return res;
        }
    }
}