@isTest
public class CollateralLinkageAPIControllerTest {

    public class CollateralLinkageAPIMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"key": "value"}'); 
            res.setStatusCode(200);
            return res;
        }
    }
    @testSetup static void setup() {
        
        Group grp = (Group)TestFactory.createSObject(new Group(Name ='Group1', Type='Queue'), true);
        
        Integration_Master__c intmasdetailSF = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Collateral Linkage',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/CustomerService/getCustomer360Details',
            HTTP_Method__c = 'GET',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);

        Account accInstance = (Account)TestFactory.createSObject(new Account(
            Name ='TestAccount', Account_Code__c='2103', Branch_Queue__c=grp.Id
        ), true);

       Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345', Adhar_Card__c   = 123456, Loan_Amount__c  = 1000, Product__c='10201', Customer_Type__c='Individual',
            Stage__c ='DDE', EMI_Date__c = '10/3/2022', Tenure__c = 10, Branch_Master__c = accInstance.Id ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash', Middle_Name__c = 'Kumar', Last_Name__c = 'Mandal', CIF_No__c = '576321', Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId() ),true);
        Collateral__c col = new Collateral__c();
        col.Collateral_ID__c = '123456';
        col.Final_Cost__c = 5000000;
        col.Collateral_Id_in_CBS__c = '123456';
        col.POS__c = 'postest';
        col.Linked_Account_Number__c = '123456789';
        //col.Collateral_Name__c = 'Car';
        col.RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('New').getRecordTypeId();
        col.Loan__c = loanAppl.id;
        insert col;
    }
    @isTest
    static void testCallCollateralLinkageCallout() {
		Loan_Application__c loanAppl = [Select Id From Loan_Application__c];

        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Loan_Application__c = loanAppl.Id);
		insert checklistRecord;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CollateralLinkageAPIMock());

        String result = CollateralLinkageAPIController.callCollateralLinkageCallout(loanAppl.Id);
        //System.assertEquals('{"key": "value"}', result);
		CollateralLinkageAPIHandler ctr = new CollateralLinkageAPIHandler();
        ctr.generateJSONResponse(null);
        CollateralLinkageAPIHandler.CollateralLinkageResponseWrapper ctwrap = New CollateralLinkageAPIHandler.CollateralLinkageResponseWrapper();
        CollateralLinkageAPIHandler.TransactionStatusWrapper tranwrap = new CollateralLinkageAPIHandler.TransactionStatusWrapper();
		ctwrap.TransactionStatus = tranwrap;
        CollateralLinkageAPIHandler.MessagesWrapper msgwrap = new CollateralLinkageAPIHandler.MessagesWrapper();
        msgwrap.code = 'test';
        msgwrap.message = 'test';
        CollateralLinkageAPIHandler.ExtendedErrorDetailsWrapper exwrap = new CollateralLinkageAPIHandler.ExtendedErrorDetailsWrapper();
        exwrap.messages = new list<CollateralLinkageAPIHandler.MessagesWrapper>{msgwrap};
        tranwrap.ResponseCode = 'test';
        tranwrap.ResponseMessage = 'test';
        tranwrap.ExtendedErrorDetails = exwrap;
        Test.stopTest();
    }
}