@isTest
public class DisbursementDeductionDetailsCtrlTest {
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
            EMI_Date__c = '10/3/2022',
            LAN__c = '1232321',
            Disbursement_Date__c = system.today(),
            Mode_of_Disbursement__c = 'CASA',
            Tenure__c = 10,BRE_Status__c = Label.BRE_Status_Received,
            Branch_Master__c = accInstance.Id, BRE_Selected_Scheme__c = scheme1.id,
            Schedule_Code__c = '00001'
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
            Name = 'Disbursement Deduction Details',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/DisburseLoanService/getLoanDisbursementDetails',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
        Integration_Master__c intmassearch = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Disbursement Stage',
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
    public static void testGenerateDisbursementDeductions(){ 
        Loan_Application__c appl = [SELECT ID FROM Loan_Application__c LIMIT 1];
        test.setMock(HttpCalloutMock.class, new DisbursementDetailsMock());
        DisbursementDeductionDetailsController.generateDisbursementDeductions(appl.Id,100000);
    }
    
    @isTest
    public static void testGenerateJSONResponse(){ 
        LoanDisbursementDeductionsApiHandler objCls = new LoanDisbursementDeductionsApiHandler();
        objCls.generateJSONResponse(null);
        LoanDisbursementDeductionsApiHandler.DisbursementDeductionResponseWrapper obj = new LoanDisbursementDeductionsApiHandler.DisbursementDeductionResponseWrapper();
        LoanDisbursementDeductionsApiHandler.TransactionStatusWrapper obj2 = new LoanDisbursementDeductionsApiHandler.TransactionStatusWrapper();
        LoanDisbursementDeductionsApiHandler.ExtendedErrorDetailsWrapper obj3 = new LoanDisbursementDeductionsApiHandler.ExtendedErrorDetailsWrapper();
        LoanDisbursementDeductionsApiHandler.MessageWrapper obj4 = new LoanDisbursementDeductionsApiHandler.MessageWrapper();
        obj4.code = 101;
        obj4.message = 'Kuch bhi';
        obj3.messages = new List<LoanDisbursementDeductionsApiHandler.MessageWrapper>{obj4};
        obj2.ResponseCode = '500';
        obj2.ResponseMessage = 'Error';
        obj2.ExtendedErrorDetails = obj3;
        obj.TransactionStatus = obj2;
    }
    
    @isTest
    public static void testGenerateDisbursementStage(){ 
        Loan_Application__c appl = [SELECT ID FROM Loan_Application__c LIMIT 1];
        test.setMock(HttpCalloutMock.class, new DisbursementDetailsMock());
        DisbursementStageApiController.generateDisbursementStage(appl.Id,100000);
    }
    
    @isTest
    public static void testStageAPIGenerateJSONResponse(){ 
        DisbursementStageApiHandler objCls = new DisbursementStageApiHandler();
        objCls.generateJSONResponse(null);
        DisbursementStageApiHandler.DisbursementStageResponseWrappper obj = new DisbursementStageApiHandler.DisbursementStageResponseWrappper();
        DisbursementStageApiHandler.TransactionStatusWrapper obj2 = new DisbursementStageApiHandler.TransactionStatusWrapper();
        DisbursementStageApiHandler.ExtendedErrorDetailsWrapper obj3 = new DisbursementStageApiHandler.ExtendedErrorDetailsWrapper();
        DisbursementStageApiHandler.MessageWrapper obj4 = new DisbursementStageApiHandler.MessageWrapper();
        obj4.code = 101;
        obj4.message = 101;
        obj3.messages = new List<DisbursementStageApiHandler.MessageWrapper>{obj4};
        obj2.ResponseCode = '500';
        obj2.ResponseMessage = 'Error';
        obj2.ExtendedErrorDetails = obj3;
        obj.TransactionStatus = obj2;
        obj.SessionId = '12312424213123';
    }
    
}