@isTest
public class LANCreationAPIHandlerTest {
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
            Product__c='10202',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Branch_Master__c = accInstance.Id
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',Existing_Customer__c  = 'Yes',
            CIBIL_Status__c ='Completed',
            CIF_No__c = '576321', Customer_Grade__c = 'NIB',
            Loan__c =loanAppl.Id,Type_of_Employment__c = 'Business',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
          Document_Master__c docMasterRecord1 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
           Document_Name__c = 'EKYC PDF'
        ),true);
        
          Document_Checklist__c docCheckRecord1 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
           Document_Master__c = docMasterRecord1.Id,
           Applicant__c = appl.Id
        ),true);
        Date start = Date.newInstance(1999, 12, 31);
        Date endDate = Date.newInstance(1999, 12, 31);
        Scheme_Master__c scheme1 = (Scheme_Master__c)TestFactory.createSObject(new Scheme_Master__c(
            START_DATE__c  = start,
            EXPIRY_DATE__c   = endDate,
            Is_InActive__c  = false,
            Scheme_Name__c = 'Normal', Vehicle_Category__c ='TestCat'
        ),true);
        Deviation__c  dev = (Deviation__c)TestFactory.createSObject(new Deviation__c(
            Loan_Application__c  = loanAppl.id , Active__c  = true,Deviation_Type__c  ='COW-No HPN-Customer'
        ),true);
            
        Id ltvRecordTypeId = Schema.SObjectType.Depreciated_Grid__c.getRecordTypeInfosByName().get('LTV').getRecordTypeId();
        Depreciated_Grid__c dep = (Depreciated_Grid__c)TestFactory.createSObject(new Depreciated_Grid__c(
            RecordTypeId= ltvRecordTypeId ,Customer_Grade__c = 'NIB' , Vehicle_Usage__c = 'Personal',Category__c ='A;B',
            Scheme__c = scheme1.Id
        ),true);
        Collateral__c coll = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Owner_Serial_number__c='1111', vehicle_color__c = 'Blue', Kilometer__c = '10', 
            Loan__c = loanAppl.id, Chasis_Number__c ='12445', Engine_Number__c ='43232',
            Vehicle_Number__c  ='124234' , Vehicle_Usage__c  = 'Personal' , Scheme__c = scheme1.Id, 
            Vehicle_Category__c  = 'TestCat',Collateral_Name__c ='10108'
        ),true);
        

    }
   @isTest
    public static void generateRequestTest(){
        Loan_Application__c loanRec = [SELECT Id from Loan_Application__c];
      	Map<String, String> paramsMap = new Map<String, String>();
    	paramsMap.put('LoanId', loanRec.Id);
        LANCreationAPIHandler.generateRequest(paramsMap);
    }
    @isTest
    static void testLANCreationApiResponseWrapper() {
        LANCreationAPIHandler.LANCreationApiResponseWrapper wrapper = new LANCreationAPIHandler.LANCreationApiResponseWrapper();
        LANCreationAPIHandler.TransactionStatusWrapper transactionStatus = new LANCreationAPIHandler.TransactionStatusWrapper();
        
        wrapper.TransactionStatus = transactionStatus;
        wrapper.AccountId = '123';
        System.assertEquals(transactionStatus, wrapper.TransactionStatus, 'The TransactionStatus should be set correctly');
        System.assertEquals('123', wrapper.AccountId, 'The AccountId should be set correctly');
        
    }
     @isTest
    static void testTransactionStatusWrapper() {
        LANCreationAPIHandler.TransactionStatusWrapper wrapper = new LANCreationAPIHandler.TransactionStatusWrapper();
        
        // Set some sample values to the wrapper properties
        wrapper.ResponseCode = '200';
        wrapper.ResponseMessage = 'Success';
        // Set other properties as needed
        
        // Perform assertions to verify the values are set correctly
        System.assertEquals('200', wrapper.ResponseCode, 'The ResponseCode should be set correctly');
        System.assertEquals('Success', wrapper.ResponseMessage, 'The ResponseMessage should be set correctly');
        // Add more assertions for other properties
        
    }
    
    @isTest
    static void testValidationErrorsWrapper() {
        LANCreationAPIHandler.ValidationErrorsWrapper wrapper = new LANCreationAPIHandler.ValidationErrorsWrapper();
        
        // Set some sample values to the wrapper properties
        wrapper.ErrorMessage = 'Validation Error';
        
        // Perform assertions to verify the values are set correctly
        System.assertEquals('Validation Error', wrapper.ErrorMessage, 'The ErrorMessage should be set correctly');
        
    }
    
    @isTest
    static void testExtendedErrorDetailsWrapper() {
        LANCreationAPIHandler.ExtendedErrorDetailsWrapper wrapper = new LANCreationAPIHandler.ExtendedErrorDetailsWrapper();
        List<LANCreationAPIHandler.MessagesWrapper> messagesList = new List<LANCreationAPIHandler.MessagesWrapper>();
        wrapper.messages = messagesList;
        System.assertEquals(messagesList, wrapper.messages, 'The messages list should be set correctly');
        
    }
    
    @isTest
    static void testMessagesWrapper() {
        LANCreationAPIHandler.MessagesWrapper wrapper = new LANCreationAPIHandler.MessagesWrapper();
        wrapper.code = 123;
        wrapper.message = 'Test Message';
        System.assertEquals(123, wrapper.code, 'The code should be set correctly');
        System.assertEquals('Test Message', wrapper.message, 'The message should be set correctly');
        
    }
    
}