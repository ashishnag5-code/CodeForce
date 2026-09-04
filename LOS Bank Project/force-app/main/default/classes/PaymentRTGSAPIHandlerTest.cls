@isTest
public class PaymentRTGSAPIHandlerTest {
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
        Payment__c paymentRec = (Payment__c)TestFactory.createSObject(new Payment__c(
            Beneficiary_Name__c = 'Test',
            Net_Amount__c = 500,
            Account_Number__c = '1312312312312',
            IFSC_Code__c = 'HDFC0004444',
            Loan_Application__c  = loanAppl.Id
        ),true);
    }
    
    testmethod static void generateRequest(){
        Map<String,String> paramsMap= new Map<String,String>();
        Loan_Application__c objLA = [Select Id from Loan_Application__c limit 1];
        Payment__c objPayment = [Select Id from Payment__c limit 1];
        paramsMap.put('LoanId',objLA.Id);
        paramsMap.put('PaymentId',objPayment.Id);
        paramsMap.put('Channel',GlobalConstants.RTGS_SOURCE);
        Test.startTest();
        PaymentRTGSAPIHandler.generateRequest(paramsMap);
        new PaymentRTGSAPIHandler().generateJSONResponse(null);
        PaymentRTGSAPIHandler.PaymentRTGSAPIResponseWrappper objResponse = new PaymentRTGSAPIHandler.PaymentRTGSAPIResponseWrappper();
        PaymentRTGSAPIHandler.cls_SettlementResponse objSR = new PaymentRTGSAPIHandler.cls_SettlementResponse();
        objSR.Code='200';
        objSR.IPHREF='IPHREF';
        objSR.Remarks='Success';
        objSR.ResponseCode='200';
        objSR.ResponseCodeDescription='Success';
        objSR.Status='Success';
        objSR.TransactionReferenceNumber='1312323122';
        objResponse.SettlementResponse = objSR;
        Test.stopTest();
    }
}