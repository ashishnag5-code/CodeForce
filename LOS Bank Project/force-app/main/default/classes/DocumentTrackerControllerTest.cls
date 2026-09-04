@isTest
public class DocumentTrackerControllerTest {
	@testSetup static void setup() {
        
        Account dealerMaster = (Account)TestFactory.createSObject(new Account(
        Name ='TestAccount',
        Account_Code__c='2103',
        Purchase_City__c='Jaipur'),true);
        
        Account stateObj = (Account)TestFactory.createSObject(new Account(
            Name  = 'state',
            Account_Name__c = 'xyz'
        ),true);
        
        Account accObj = (Account)TestFactory.createSObject(new Account(
            Name  = 'Acc',
            State__c = stateObj.Id,
            RPC_FT_RIT_Queue__c = 'RPC - MH TW'
        ),true);
        
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-123405',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10',
            Tenure__c = 10,
            Dealer_Master__c = dealerMaster.Id,
            Branch_Master__c = accObj.Id,
            Disbursement_Date__c = Date.valueOf('2023-01-01'),
            Is_Loan_Disbursed__c = true
        ),true);
        
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321',
            Loan__c =loanAppl.Id,
            Mobile_Number__c = '9999999999',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
       Document_Tracker__c docTrackObj = (Document_Tracker__c)TestFactory.createSObject(new Document_Tracker__c(
            Loan_Application__c=loanAppl.Id,
            Application_Status__c = 'Send to Store'
        ),true);
    }
    
    @isTest
    public static void searchLoanApplicationTest(){
        List<DocumentTrackerController.loanWrapper> loanWrap; //= DocumentTrackerController.searchLoanApplication('9999999999', 'Mobile_Number__c', 'Physical_File_Tracker', 'RO', 'Dispatch to RPC');
        loanWrap = DocumentTrackerController.searchLoanApplication('0', 'Loan Number', 'Physical_File_Tracker', 'RPCCPC', 'Dispatch to RPC');
        loanWrap = DocumentTrackerController.searchLoanApplication('0', 'Loan Number', 'Physical_File_Tracker', 'RO', 'Dispatch to RPC');
        loanWrap = DocumentTrackerController.searchLoanApplication('0', 'Loan Number', 'Physical_File_Tracker', 'RPCCPC', 'Received at RPC');
        loanWrap = DocumentTrackerController.searchLoanApplication('0', 'Loan Number', 'Physical_File_Tracker', 'RPCCPC', 'Received at CPC');
        loanWrap = DocumentTrackerController.searchLoanApplication('0', 'Loan Number', 'Physical_File_Tracker', 'RPCCPC', 'Received at Store');
        loanWrap = DocumentTrackerController.searchLoanApplication('0', 'Loan Number', 'Physical_File_Tracker', 'RPCCPC', 'Disbursed File Not Received at Store');
    }
    
    @isTest 
    public static void saveRecords(){
        List<Loan_Application__c> loanAppsList = [SELECT Id FROM Loan_Application__c];
        //Document_Tracker__c docTrackerObj = [SELECT Id,Loan_Application__c,Application_Status__c FROM Document_Tracker__c];
        Map<String,String> docTrackerObj = new Map<String,String>();
        docTrackerObj.put('Loan_Application__c',''+loanAppsList[0].Id);
        docTrackerObj.put('Application_Status__c','Dispatch to CPC from RPC/COM');
        docTrackerObj.put('Courier_Date__c','2023-08-01');
        docTrackerObj.put('RecordType','Repayment_Instrument_Tracker');
        DocumentTrackerController.saveRecords(loanAppsList, docTrackerObj, 'RO');
        DocumentTrackerController.saveRecords(loanAppsList, docTrackerObj, 'RPCCPC');
        docTrackerObj.put('RecordType','Physical_File_Tracker');
        docTrackerObj.put('Application_Status__c','Send to Store');
        DocumentTrackerController.saveRecords(loanAppsList, docTrackerObj, 'RPCCPC');
        docTrackerObj.put('Application_Status__c','Dispatch to RPC');
        DocumentTrackerController.saveRecords(loanAppsList, docTrackerObj, 'RO');
    }
    
    @IsTest
    static void testCheckForLoanDispatch(){
        List<Loan_Application__c> loanAppsList = [SELECT Id FROM Loan_Application__c];
        Test.startTest();
        List<String> retValues = DocumentTrackerController.checkForLoanDispatch(loanAppsList);
        Test.stopTest();
    }
}