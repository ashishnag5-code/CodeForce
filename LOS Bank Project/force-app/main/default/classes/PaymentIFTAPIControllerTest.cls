@isTest
public class PaymentIFTAPIControllerTest {
   @testSetup static void setup() {
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        
        Account accInstance = (Account)TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            Branch_Queue__c=grp.Id
        ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10301',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Branch_Master__c = accInstance.Id
        ),true);
        Payment__c paymentRec = (Payment__c)TestFactory.createSObject(new Payment__c(
            Beneficiary_Name__c = 'Test',
            Net_Amount__c = 500,
            Loan_Application__c  = loanAppl.Id,
            Payment_Mode__c = 'Cheque'
        ),true);
        Payment__c paymentRec2 = (Payment__c)TestFactory.createSObject(new Payment__c(
            Beneficiary_Name__c = 'Test',
            Net_Amount__c = 500,
            Loan_Application__c  = loanAppl.Id,
            Payment_Mode__c = 'NEFT'
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',Existing_Customer__c  = 'Yes',
            CIF_No__c = '576321', Customer_Grade__c = 'NIB',Aadhaar_Number__c = '123412341234',
            Loan__c =loanAppl.Id,Type_of_Employment__c = 'Business',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
        
        Integration_Master__c intmassearch1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Payment IFT ',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/CBSFundTransferService',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
        
    }
    @isTest
    public static void getLADetailsTest(){
    	Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c];
        Payment__c paymentRec = [SELECT Id from Payment__c WHERE Payment_Mode__c = 'Cheque'];
        test.setMock(HttpCalloutMock.class, new IFTServiceMock(200));
        Test.startTest();
        PaymentIFTAPIController.doIFTPayment(loanAppl.Id,paymentRec.Id,'No','50000','disbursePaymentCheque');
        Test.stopTest();
    }

    @isTest
    public static void getLADetailsPoolTest(){
    	Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c];
        Payment__c paymentRec = [SELECT Id from Payment__c WHERE Payment_Mode__c = 'Cheque'];
        test.setMock(HttpCalloutMock.class, new IFTServiceMock(200));
        Test.startTest();
        PaymentIFTAPIController.doIFTPayment(loanAppl.Id,paymentRec.Id,'Yes','50000','disbursePaymentCheque');
        Test.stopTest();
    }
    
    @isTest
    public static void narrativeLengthTest(){
    	Loan_Application__c loanAppl = [SELECT Id, Narration__c from Loan_Application__c];
        loanAppl.Narration__c = 'This narration has a invalid length of more than 30 characters';
        update loanAppl;
        Payment__c paymentRec = [SELECT Id from Payment__c WHERE Payment_Mode__c = 'Cheque'];
        test.setMock(HttpCalloutMock.class, new IFTServiceMock(200));
        Test.startTest();
        PaymentIFTAPIController.doIFTPayment(loanAppl.Id,paymentRec.Id,'Yes','50000','disbursePaymentCheque');
        Test.stopTest();
    }
    
    @isTest
    public static void narrativeLengthTest2(){
    	Loan_Application__c loanAppl = [SELECT Id, Narration__c from Loan_Application__c];
        loanAppl.Narration__c = 'This narration is valid';
        update loanAppl;
        Payment__c paymentRec = [SELECT Id from Payment__c WHERE Payment_Mode__c = 'Cheque'];
        test.setMock(HttpCalloutMock.class, new IFTServiceMock(101));
        Test.startTest();
        PaymentIFTAPIController.doIFTPayment(loanAppl.Id,paymentRec.Id,'Yes','50000','disbursePaymentCheque');
        PaymentIFTAPIHandler.PaymentIFTAPIRequestWrappper requestWrapper = new PaymentIFTAPIHandler.PaymentIFTAPIRequestWrappper();
        requestWrapper.ReferenceNumber = 'SFDC80a1a1c7b220b61e65225ef762151722';
        String responseString ='{"TransactionStatus": {"ResponseCode": "0","ResponseMessage": "Success"},"ErrorCode": "0","TransactionReferenceNo": "IFT722432123331236"}';

        PaymentIFTAPIHandler.PaymentIFTAPIResponseWrappper responseWrapper = (PaymentIFTAPIHandler.PaymentIFTAPIResponseWrappper) JSON.deserialize(responseString, PaymentIFTAPIHandler.PaymentIFTAPIResponseWrappper.class);	
		Test.stopTest();
    }
        @isTest
    public static void narrativeLengthTest3(){
    	Loan_Application__c loanAppl = [SELECT Id, Narration__c from Loan_Application__c];
        loanAppl.Narration__c = 'This narration is valid';
        update loanAppl;
        Payment__c paymentRec = [SELECT Id from Payment__c WHERE Payment_Mode__c = 'NEFT'];
        test.setMock(HttpCalloutMock.class, new IFTServiceMock(102));
        Test.startTest();
        PaymentIFTAPIController.doIFTPayment(loanAppl.Id,paymentRec.Id,'Yes','50000','disbursePaymentque');
        PaymentIFTAPIHandler.PaymentIFTAPIRequestWrappper requestWrapper = new PaymentIFTAPIHandler.PaymentIFTAPIRequestWrappper();
        requestWrapper.ReferenceNumber = 'SFDC80a1a1c7b220b61e65225ef762151722';
        String responseString ='{"TransactionStatus": {"ResponseCode": "0","ResponseMessage": "Success"},"ErrorCode": "0","TransactionReferenceNo": "IFT722432123331236"}';

        PaymentIFTAPIHandler.PaymentIFTAPIResponseWrappper responseWrapper = (PaymentIFTAPIHandler.PaymentIFTAPIResponseWrappper) JSON.deserialize(responseString, PaymentIFTAPIHandler.PaymentIFTAPIResponseWrappper.class);	
		Test.stopTest();
    }
    
    
}