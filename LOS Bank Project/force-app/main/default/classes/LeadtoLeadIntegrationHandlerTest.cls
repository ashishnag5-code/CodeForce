@isTest
public class LeadtoLeadIntegrationHandlerTest {
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
            Branch_Master__c = branchMaster.Id,
            recordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId()
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
    }
    testmethod static void generateRequest(){
        Test.startTest();
        Applicant__c objAppl = [Select Id, Loan__c, Loan__r.Product__c,Mobile_Number__c,PAN__c,CIF_No__c,Aadhaar_Number__c from Applicant__c limit 1];
        LeadtoLeadIntegrationHandler.generateRequest(objAppl);
        Test.stopTest();
    }
    testmethod static void generateJSONResponse(){
        Test.startTest();
        new LeadtoLeadIntegrationHandler().generateJSONResponse(null);
        Test.stopTest();
    }
    testmethod static void mapIntWraptoUIWrap(){
        Test.startTest();
        LeadtoLeadIntegrationHandler.LeadtoLeadResponseWrapper objLeadtoLeadWrapper = new LeadtoLeadIntegrationHandler.LeadtoLeadResponseWrapper();
        LeadtoLeadIntegrationHandler.cls_TransactionStatus objCLSTS = new LeadtoLeadIntegrationHandler.cls_TransactionStatus();
        objCLSTS.ResponseCode = '200';
        objCLSTS.ResponseMessage = 'Success';
        objLeadtoLeadWrapper.TransactionStatus = objCLSTS;
        
        LeadtoLeadIntegrationHandler.cls_CRMFetchResults objCLSCRMFR = new LeadtoLeadIntegrationHandler.cls_CRMFetchResults();
        LeadtoLeadIntegrationHandler.cls_NewDataSet objCLSNDS = new LeadtoLeadIntegrationHandler.cls_NewDataSet();
        LeadtoLeadIntegrationHandler.cls_Table1 objCLST = new LeadtoLeadIntegrationHandler.cls_Table1();
        objCLST.Applicationstatus='Documents Collected';
        objCLST.BranchName='2011';
        objCLST.LeadId='2474';
        objCLST.CustomerName='ASFASFASF ASFASFAS';
        objCLST.CustomerMobileNumber='9679679679';
        objCLST.LeadCreationDate='08-01-2021 14:13:43';
        objCLST.ProductName='Home Construction';
        objCLST.BranchCode='Jaipur_Central Office_Mansarovar';
        objCLST.LoanAmount='324124124';
        objCLSNDS.Table1 = new List<LeadtoLeadIntegrationHandler.cls_Table1>{objCLST};
        objCLSCRMFR.NewDataSet = new List<LeadtoLeadIntegrationHandler.cls_NewDataSet>{objCLSNDS};
        objLeadtoLeadWrapper.CRMFetchResults = new List<LeadtoLeadIntegrationHandler.cls_CRMFetchResults>{objCLSCRMFR};
        Applicant__c objAppl = [Select Id, Loan__c, Loan__r.Product__c,Mobile_Number__c,PAN__c,CIF_No__c,Aadhaar_Number__c from Applicant__c limit 1];
        LeadtoLeadIntegrationHandler.mapIntWraptoUIWrap(objLeadtoLeadWrapper,objAppl);
        Test.stopTest();
    }
}