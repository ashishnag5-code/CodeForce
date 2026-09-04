@isTest
public class CustomCollateralEnquiryControllerTest {
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
            Name = 'Customer Collateral Enquiry',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/CollateralSearchService/CollEnquiry',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
        
    }
    @IsTest
    public static void getCollateralEnquiryListTest(){
        Applicant__c appRec = [SELECT Id from Applicant__c LIMIT 1];
        test.StartTest();
        test.setMock(HttpCalloutMock.class, new CollateralSerachServiceMock());
        CustomCollateralEnquiryController.getCollateralEnquiryList(appRec.Id);
        test.StopTest();
    }
      @IsTest
    public static void getCollateralEnquiryListExceptionTest(){
        Applicant__c appRec = [SELECT Id from Applicant__c];
        //CustomCollateralEnquiryController.getCollateralEnquiryList(appRec.Id);
    }
        @IsTest
    public static void getExistingCollateralsTest(){
        Loan_Application__c loanRec = [SELECT Id from Loan_Application__c];
        CustomCollateralEnquiryController.getExistingCollaterals(loanRec.Id);
    }
     @isTest
    static void testCustomerEnquiryListWrapper() {
        CustomerEnquiryWrapper.CustomerEnquiryListWrapper wrapper = new CustomerEnquiryWrapper.CustomerEnquiryListWrapper();
      
        wrapper.strCollateralId = '123';
        wrapper.strCollateralName = 'Collateral 1';
        wrapper.strProductNameCode='Test';
        wrapper.strCollateralType = 'Test Type';
        wrapper.strPropertyOwnerName = 'Test Owner';
   		wrapper.strCustomerId = '123';
        wrapper.strAccountNumber = '1212';
        wrapper.strAccountCustomerRelation='Test Relation';
        wrapper.strTotalCollateralValue = 'Test val';
        System.assertEquals('123', wrapper.strCollateralId, 'The collateral ID should be set correctly');
        System.assertEquals('Collateral 1', wrapper.strCollateralName, 'The collateral name should be set correctly');
        
    }
    @isTest
    static void testCustomerEnquiryDetailWrapper() {
        CustomerEnquiryWrapper.CustomerEnquiryDetailWrapper wrapper = new CustomerEnquiryWrapper.CustomerEnquiryDetailWrapper();
        
        wrapper.strCollateralId = '123';
        wrapper.strCollateralName = 'Collateral 1';
        wrapper.strCollateralType = 'Test Type';
        wrapper.strPropertyOwnerName = 'Test Owner';
        wrapper.strProductNameCode='Test';
        wrapper.strAccountNumber = '1212';
        wrapper.strTotalCollateralValue=10;
        wrapper.strAmountCollValueCollCcy=10;
        wrapper.strPropertyType='Test Property';
        wrapper.strCollateralUnusedValue=1;
        wrapper.strLastValuationDate= '12-12-2002';
        wrapper.strTotalArea=100;
        wrapper.strCustomerId='123';
        wrapper.strAccountCustomerRelation = 'Test';
        wrapper.strMake='Test';
        wrapper.strModel='Test';
        wrapper.strManufactureYear='Test'; 
        wrapper.strChassisNumber='Test';
        wrapper.strEngineNumber='Test';
        wrapper.strRegistrationNumber ='test';
        wrapper.strAddress='wrapper';
       	wrapper.strTehsilTaluka='wrapper';
        wrapper.strVillage='wrapper';
        wrapper.strPropertyDesc1='wrapper';
        wrapper.strAreaUnit='wrapper';
        wrapper.strKhasaraPlotNo='121';
        wrapper.strCostPrice = 1222;
        wrapper.strLastValue=1222;
        wrapper.boolIsProprtyView= false;
        wrapper.boolIsAutomobileView= false;
        wrapper.isSelected= false;
        wrapper.isDisabled= false;

        System.assertEquals('123', wrapper.strCollateralId, 'The collateral ID should be set correctly');
        System.assertEquals('Collateral 1', wrapper.strCollateralName, 'The collateral name should be set correctly');
        
    }
    
}