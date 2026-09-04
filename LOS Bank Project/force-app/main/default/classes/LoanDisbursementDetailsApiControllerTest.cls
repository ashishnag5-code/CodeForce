@isTest
public class LoanDisbursementDetailsApiControllerTest {
public class LoanDisbursementDetailsApiResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'Application/json');
            res.setBody('{"TransactionStatus":{"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":[{"code":0}]}},"AccountBranchCode":2100,"AccountProduct":10201,"AccountCurrency":1,"AccountScheduleCode":1021,"AccountTerm":36,"SanctionedAmount":250000,"DisbursementAmount":0,"ScheduleDrawnOn":0,"ProducedId":"0"}');
            res.setStatusCode(200);
            return res;    
        }
    }
    @testSetup static void setup() {
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
        
        
        Integration_Master__c intmassearch2 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Disbursement Details',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/FicoBREService',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
    }
    @isTest
    public static void getAadhaarNumApiTest(){
        Test.startTest();
        Loan_Application__c loanAppl = [SELECT ID FROM Loan_Application__c LIMIT 1];
        test.setMock(HttpCalloutMock.class, new LoanDisbursementDetailsApiResponse());
        LoanDisbursementDetailsApiHandler.LoanDisbursementResponseWrapper loanwrapper=new LoanDisbursementDetailsApiHandler.LoanDisbursementResponseWrapper();
        loanwrapper.TransactionStatus=null;
        loanwrapper.AccountBranchCode=null;
        loanwrapper.AccountProduct=null;
        loanwrapper.AccountCurrency=null;
        loanwrapper.AccountScheduleCode=null;
         loanwrapper.AccountTerm=null;
        loanwrapper.SanctionedAmount=null;
        loanwrapper.ScheduleDrawnOn=null;
        loanwrapper.ProducedId=null;
        loanwrapper.DisbursementAmount=null;
        LoanDisbursementDetailsApiController.generateLoanDisbursementDetails(loanAppl.id);
        Test.stopTest();
    }

    
    @isTest static void testTransactionStatusWrapper(){
        LoanDisbursementDetailsApiHandler.TransactionStatusWrapper transactionStatus = new LoanDisbursementDetailsApiHandler.TransactionStatusWrapper();
        transactionStatus.ResponseMessage='';
        transactionStatus.ResponseCode='';
        transactionStatus.ExtendedErrorDetails=null;
        
        LoanDisbursementDetailsApiHandler.ExtendedErrorDetailsWrapper extendedWrapper = new LoanDisbursementDetailsApiHandler.ExtendedErrorDetailsWrapper();
        extendedWrapper.messages=null;
        
        LoanDisbursementDetailsApiHandler.MessagesWrapper messageWrapper = new LoanDisbursementDetailsApiHandler.MessagesWrapper();
        messageWrapper.code=2;
        messageWrapper.message='';
        
        
    }
    
}