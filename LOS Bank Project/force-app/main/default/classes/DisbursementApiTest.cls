@isTest
public class DisbursementApiTest {
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
        Date start = Date.newInstance(1999, 12, 31);
        Date endDate = Date.newInstance(1999, 12, 31);
        Scheme_Master__c scheme1 = (Scheme_Master__c)TestFactory.createSObject(new Scheme_Master__c(
            START_DATE__c  = start,
            EXPIRY_DATE__c   = endDate,
            Is_InActive__c  = false,
            Scheme_Name__c = 'Normal', Vehicle_Category__c ='TestCat'
        ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual', 
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',Disbursement_Session_Id__c = '3243',
            Tenure__c = 10,BRE_Status__c = Label.BRE_Status_Received,LAN__c = '9001020130397051',General_Ledger__c='250408455',Narration__c ='DEL0000000245 Abhishek  Kasera GL',
            Disbursement_Date__c = system.today() , Schedule_Code__c = '1021',
            Branch_Master__c = accInstance.Id, BRE_Selected_Scheme__c = scheme1.id , Mode_of_Disbursement__c = 'GL'
        ),true);
         
        Charge__c chargeIns  = (Charge__c)TestFactory.createSObject(new Charge__c (
            Charges_Name__c ='test name',
            Sequence_NO__c=1,
            Total_Amount__c =333 , Loan_Application__c = loanAppl.Id
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
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/DisburseLoanService/getLoanDisbursementDetails',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
        Integration_Master__c intmassearch3 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Do Disbursement',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/DisburseLoanService/getLoanDisbursementDetails',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
        Integration_Checklist__c intCheck1 = (Integration_Checklist__c)TestFactory.createSObject(new Integration_Checklist__c(
            Request__c = 'Do Disbursement',
            Response__c = '',Loan_Application__c = loanAppl.Id,
            Applicant__c = appl.Id,
            Integration_Master__c = intmassearch2.Id
            
        ),true);
        
        
    } 
    
    @isTest
    public static void getLADetailsTest(){ 
        Applicant__c appl = [SELECT ID FROM Applicant__c LIMIT 1];
        DisbursementApi obj = new DisbursementApi();
        test.setMock(HttpCalloutMock.class, new DisbursementDetailsMock());
        //obj.fetchApi(appl.Id, 'Disbursement Details');
    }
    @isTest
    public static void testMethodForDoDisburesement(){ 
        Loan_Application__c loanAppl = [SELECT ID,Mode_of_Disbursement__c,General_Ledger__c FROM Loan_Application__c  LIMIT 1];
        DoDisbursementAPIController obj = new DoDisbursementAPIController();
        test.setMock(HttpCalloutMock.class, new DoDisbursementDetailsMock());
        DoDisbursementAPIController.generateDoDisbursement(loanAppl.Id, 10000.00);
    }
    
    @isTest public static void testWrapperMethod(){
        DoDisbursementAPIHandler.DoDisbursementResponseWrapper dodisbursementWrapper = new DoDisbursementAPIHandler.DoDisbursementResponseWrapper();
        dodisbursementWrapper.LoanBalanceResponse =null;
        dodisbursementWrapper.TransactionStatus=null;
        
        DoDisbursementAPIHandler.LoanBalanceResponseWrapper loanBalanceWrapper = new DoDisbursementAPIHandler.LoanBalanceResponseWrapper();
        loanBalanceWrapper.NextInstallmentDueAmount=2;
        loanBalanceWrapper.MinAmountDue=2;
        loanBalanceWrapper.UnclearedFunds=2;
        loanBalanceWrapper.AmountDisbursedToday=2;
        loanBalanceWrapper.PenaltyArrears=2;
        loanBalanceWrapper.MaturityDate='';
        loanBalanceWrapper.OtherArrears=2;
        loanBalanceWrapper.NextDueDate='';
        loanBalanceWrapper.InstallmentArrears=2;
        loanBalanceWrapper.UnbilledServiceCharge=2;
        loanBalanceWrapper.PrincipalBalance=2;
        loanBalanceWrapper.RpaBalance=2;
        loanBalanceWrapper.AccountStatus=2;
        loanBalanceWrapper.AmountPaidToday=2;
        loanBalanceWrapper.UncollectedInterest=2;
        loanBalanceWrapper.AvailableBalance=2;
        loanBalanceWrapper.AccountCurrency='';
        loanBalanceWrapper.CustomerShortName='';
        loanBalanceWrapper.UnbilledPenaltyInterest=2;
        loanBalanceWrapper.TotalOutstandings=2;
        loanBalanceWrapper.UnbilledInterest=2;
        
        DoDisbursementAPIHandler.TransactionStatusWrapper transWrapper = new DoDisbursementAPIHandler.TransactionStatusWrapper();
        transWrapper.ResponseCode='';
        transWrapper.ResponseMessage='';
        transWrapper.ExtendedErrorDetails=null;
        
        DoDisbursementAPIHandler.ExtendedErrorDetailsWrapper extendedWrapper = new DoDisbursementAPIHandler.ExtendedErrorDetailsWrapper();
        extendedWrapper.messages=null;
        
        DoDisbursementAPIHandler.MessageWrapper messageWrapper = new DoDisbursementAPIHandler.MessageWrapper();
        messageWrapper.code = 2;
        messageWrapper.message='';
    }
    
}