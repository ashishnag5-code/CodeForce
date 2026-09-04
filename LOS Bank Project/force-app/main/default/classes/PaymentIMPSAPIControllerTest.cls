@isTest
public class PaymentIMPSAPIControllerTest {
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
            Payment_Recipient__c = 'Dealer',
            Loan_Application__c  = loanAppl.Id
        ),true);
     
     Payment__c paymentRec1 = (Payment__c)TestFactory.createSObject(new Payment__c(
            Beneficiary_Name__c = 'Test',
            Net_Amount__c = 500,
            Payment_Recipient__c = 'Customer',
            Loan_Application__c  = loanAppl.Id
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
            Name = 'Payment IMPS',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/CBSIMPSPaymentService',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
        
    }
        @isTest
    public static void doIMPSPaymentTest(){
        Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c];
        List<Payment__c> paymentRec = [SELECT Id,Payment_Recipient__c from Payment__c];
        test.setMock(HttpCalloutMock.class, new PaymentIMPSServiceMock());
        PaymentIMPSAPIController.doIMPSPayment(loanAppl.Id,paymentRec[0].Id);
        PaymentIMPSAPIController.doIMPSPayment(loanAppl.Id,paymentRec[1].Id);
    }
      @IsTest
    static void testPaymentIMPSAPIResponseWrapper() {
        // Create test data
        PaymentIMPSAPIHandler.PaymentIMPSAPIResponseWrappper responseWrapper = new PaymentIMPSAPIHandler.PaymentIMPSAPIResponseWrappper();
        responseWrapper.TransactionStatusType = new PaymentIMPSAPIHandler.cls_TransactionStatusType();
        responseWrapper.TransactionStatusType.ResponseCode = '0';
        responseWrapper.TransactionStatusType.ResponseMessage = 'Success';
        responseWrapper.TransactionStatusType.ExtendedErrorDetails = new PaymentIMPSAPIHandler.cls_ExtendedErrorDetails();
        responseWrapper.TransactionStatusType.ExtendedErrorDetails.messages = new List<PaymentIMPSAPIHandler.cls_messages>{
            new PaymentIMPSAPIHandler.cls_messages()
        };
        responseWrapper.TransactionStatusType.ExtendedErrorDetails.messages[0].code = '0';
        responseWrapper.TransactionStatusType.ExtendedErrorDetails.messages[0].message = 'Message';
        responseWrapper.RetrievalReferenceNumber = '306117639834';
        
        // Test the serialization and deserialization
        String serializedResponseWrapper = JSON.serialize(responseWrapper);
        PaymentIMPSAPIHandler.PaymentIMPSAPIResponseWrappper deserializedResponseWrapper = (PaymentIMPSAPIHandler.PaymentIMPSAPIResponseWrappper)JSON.deserialize(serializedResponseWrapper, PaymentIMPSAPIHandler.PaymentIMPSAPIResponseWrappper.class);
        PaymentIMPSAPIHandler pay = New PaymentIMPSAPIHandler();
        pay.generateJSONResponse(null);
        // Verify the deserialized response
        System.assertEquals(responseWrapper.TransactionStatusType.ResponseCode, deserializedResponseWrapper.TransactionStatusType.ResponseCode);
        System.assertEquals(responseWrapper.TransactionStatusType.ResponseMessage, deserializedResponseWrapper.TransactionStatusType.ResponseMessage);
        System.assertEquals(responseWrapper.TransactionStatusType.ExtendedErrorDetails.messages[0].code, deserializedResponseWrapper.TransactionStatusType.ExtendedErrorDetails.messages[0].code);
        System.assertEquals(responseWrapper.TransactionStatusType.ExtendedErrorDetails.messages[0].message, deserializedResponseWrapper.TransactionStatusType.ExtendedErrorDetails.messages[0].message);
        System.assertEquals(responseWrapper.RetrievalReferenceNumber, deserializedResponseWrapper.RetrievalReferenceNumber);
    }
}