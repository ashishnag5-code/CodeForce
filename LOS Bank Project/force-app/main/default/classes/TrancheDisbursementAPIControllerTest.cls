@isTest
public class TrancheDisbursementAPIControllerTest {
    @TestSetup
    static void makeData(){
        Account dealerMaster = (Account)TestFactory.createSObject(new Account(
        Name ='TestAccount',
        Account_Code__c='2103',
        Purchase_City__c='Jaipur'),true);
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
            Loan_Amount__c  = 10000,
            Product__c='10201',
            Customer_Type__c='Non Individual',
            Stage__c ='QDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Dealer_Master__c = dealerMaster.Id,
            LAN__c = '1232321',
            Mode_of_Disbursement__c = 'CASA',
            Narration__c='Kuch Bhi',
            Disbursement_Session_Id__c='123123',
            Disbursement_Date__c = system.today(),
            Branch_Master__c = branchMaster.Id
        ),true);

        //CanDo Lead Integration Master
        Integration_Master__c CanDOIntegrationMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
            Name ='Tranche Disbursement',
            End_Point_URL__c='https://service.aubank.in/SFDCCanDoLeadService/candoLead',
            Apiuser__c ='SFDC',
            API_Key__c ='epikey',
            HTTP_Method__c='POST',
            Timeout__c='120000',
            Active__c = true
        ),true);
    }
    static testmethod void testTransactionStatusCallout(){
        test.setMock(HttpCalloutMock.class, new TransactionStatusCalloutMockTest('trancheDisbursementAPI'));
        Loan_Application__c loanAppl = [Select Id from Loan_Application__c];
        TrancheDisbursementAPIController.generateTrancheDisbursement(loanAppl.Id,10000);
    }

    static testmethod void testTrancheDisbursementAPIHandler(){
        TrancheDisbursementAPIHandler obj = new TrancheDisbursementAPIHandler();
        obj.generateJSONResponse(null);
        TrancheDisbursementAPIHandler.MessageWrapper objMW = new TrancheDisbursementAPIHandler.MessageWrapper();
        objMW.code=200;
        objMW.message='SUCCESS';
        TrancheDisbursementAPIHandler.ExtendedErrorDetailsWrapper objEEDW = new TrancheDisbursementAPIHandler.ExtendedErrorDetailsWrapper();
        objEEDW.messages = new List<TrancheDisbursementAPIHandler.MessageWrapper>{objMW};
        TrancheDisbursementAPIHandler.TransactionStatusWrapper objTSW = new TrancheDisbursementAPIHandler.TransactionStatusWrapper();
        objTSW.ExtendedErrorDetails = objEEDW;
        objTSW.ResponseCode = '200';
        objTSW.ResponseMessage = 'SUCCESS';
        TrancheDisbursementAPIHandler.TrancheDisbursementResponseWrapper objTDRW = new TrancheDisbursementAPIHandler.TrancheDisbursementResponseWrapper();
        objTDRW.TransactionStatus = objTSW;
        objTDRW.HostDisbursementSessionId=123123;
    }
}