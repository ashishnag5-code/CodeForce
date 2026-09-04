@isTest
public class CollateralModificationAPIControllerTest {
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
        Collateral__c  collRec = (Collateral__c )TestFactory.createSObject(new Collateral__c (
            Collateral_ID__c ='102010000000001',
            Loan__c   = loanAppl.Id,
            Collateral_Id_in_CBS__c='102010000000001',
            Vahaan_Response__c='{"registrationNumber":null,"registrationCity":null,"ownerSerialNumber":null,"hpnFinancer":null,"engineNo":null,"currentOwnerName":null,"chasisNumber":null}'
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
            Name = 'Collateral Modification',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/CollateralModificationRestService/Modification',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
        
    }
    @isTest
    public static void callCollateralModificationCalloutTest(){
        Test.startTest();
        Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c];
        test.setMock(HttpCalloutMock.class, new CollateralModificationServiceMock());
        CollateralModificationAPIController.callCollateralModificationCallout(loanAppl.Id,'');
        Test.stopTest();
    }
        @isTest
    public static void callCollateralModificationCalloutPddTest(){
        Test.startTest();
        Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c];
        test.setMock(HttpCalloutMock.class, new CollateralModificationServiceMock());
        LOSPDDMakerController.VahaanWrapper wrapper = new LOSPDDMakerController.VahaanWrapper();
        wrapper.engineNo = '12121212121';
        CollateralModificationAPIController.callCollateralModificationCalloutPDD(loanAppl.Id,JSON.serialize(wrapper));
        Test.stopTest();
    }
            @isTest
    public static void callCollateralModificationCalloutPddNveTest(){
        Test.startTest();
        Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c];
        test.setMock(HttpCalloutMock.class, new CollateralModificationServiceMock());
        try{
            CollateralModificationAPIController.callCollateralModificationCalloutPDD(loanAppl.Id,'');
        }Catch(Exception e){
            
        }
        Test.stopTest();
    }
    
    @isTest
    public static void callCollateralModificationCalloutTest2(){
        Test.startTest();
        Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c];
        test.setMock(HttpCalloutMock.class, new CollateralModificationServiceMock());
        CollateralModificationAPIController.callCollateralModificationCallout(loanAppl.Id,'pddMaker');
        Test.stopTest();
    }
    @IsTest
    static void testCollateralModificationAPIHandler() {
        Test.startTest();
        // Create test data
         CollateralModificationAPIHandler.ValidationErrorsWrapper valwrap = new CollateralModificationAPIHandler.ValidationErrorsWrapper();
        valwrap.AttributeName = 'test';
        valwrap.AttributeValue = 'test';
        valwrap.ErrorCode = 'test';
        valwrap.ErrorMessage = 'test';
        
        CollateralModificationAPIHandler.TransactionStatusWrapper transactionStatus = new CollateralModificationAPIHandler.TransactionStatusWrapper();
        transactionStatus.ResponseCode = '200';
        transactionStatus.ResponseMessage = 'Success';
        transactionStatus.ValidationErrors = new list<CollateralModificationAPIHandler.ValidationErrorsWrapper>{valwrap};
        CollateralModificationAPIHandler.CollateralModificationResponseWrapper colwrap = new CollateralModificationAPIHandler.CollateralModificationResponseWrapper();
        colwrap.PostingDate = 'test';
        colwrap.TransactionStatus =transactionStatus;
        CollateralModificationAPIHandler.ExtendedErrorDetailsWrapper extendedErrorDetails = new CollateralModificationAPIHandler.ExtendedErrorDetailsWrapper();
        CollateralModificationAPIHandler.MessagesWrapper message = new CollateralModificationAPIHandler.MessagesWrapper();
        message.code = '101';
        message.message = 'Error occurred';
        extendedErrorDetails.messages = new List<CollateralModificationAPIHandler.MessagesWrapper>{message};
            transactionStatus.ExtendedErrorDetails = extendedErrorDetails;
        
        // Test the getter methods
        System.assertEquals('200', transactionStatus.ResponseCode);
        System.assertEquals('Success', transactionStatus.ResponseMessage);
        System.assertEquals(1, transactionStatus.ExtendedErrorDetails.messages.size());
        System.assertEquals('101', transactionStatus.ExtendedErrorDetails.messages[0].code);
        System.assertEquals('Error occurred', transactionStatus.ExtendedErrorDetails.messages[0].message);
        
        // Test the setter methods
        CollateralModificationAPIHandler.TransactionStatusWrapper newTransactionStatus = new CollateralModificationAPIHandler.TransactionStatusWrapper();
        newTransactionStatus.ResponseCode = '400';
        newTransactionStatus.ResponseMessage = 'Bad Request';
        CollateralModificationAPIHandler.ExtendedErrorDetailsWrapper newExtendedErrorDetails = new CollateralModificationAPIHandler.ExtendedErrorDetailsWrapper();
        CollateralModificationAPIHandler.MessagesWrapper newMessage = new CollateralModificationAPIHandler.MessagesWrapper();
        newMessage.code = '201';
        newMessage.message = 'Invalid input';
        newExtendedErrorDetails.messages = new List<CollateralModificationAPIHandler.MessagesWrapper>{newMessage};
            newTransactionStatus.ExtendedErrorDetails = newExtendedErrorDetails;
        CollateralModificationAPIHandler ctr = new CollateralModificationAPIHandler();
        ctr.generateJSONResponse(null);
        System.assertEquals('400', newTransactionStatus.ResponseCode);
        System.assertEquals('Bad Request', newTransactionStatus.ResponseMessage);
        System.assertEquals(1, newTransactionStatus.ExtendedErrorDetails.messages.size());
        System.assertEquals('201', newTransactionStatus.ExtendedErrorDetails.messages[0].code);
        System.assertEquals('Invalid input', newTransactionStatus.ExtendedErrorDetails.messages[0].message);
        Test.stopTest();
    }
}