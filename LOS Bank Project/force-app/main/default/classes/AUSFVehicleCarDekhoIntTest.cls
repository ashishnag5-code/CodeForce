@isTest
public class AUSFVehicleCarDekhoIntTest {
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
            Name = 'Car Dekho Pricing',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/CarDekhoService/VariantPriceByCity',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
        
    }
      @isTest
    	public static void callCarDekhoAPITest(){
        Test.startTest();
        	test.setMock(HttpCalloutMock.class, new CarDekhoServiceMock());
        	AUSFVehicleCarDekhoInt.callCarDekhoAPI('46','49');
        Test.stopTest();
    }
       @isTest
    static void testCarDekhoFailureResponseWrapper() {
        AUSFVehicleCarDekhoIntHandler.CarDekhoFailureResponseWrapper wrapper = new AUSFVehicleCarDekhoIntHandler.CarDekhoFailureResponseWrapper();
        
        // Set some sample values to the wrapper properties
        Map<String, String> errorsMap = new Map<String, String>();
        errorsMap.put('Error1', 'Error message 1');
        errorsMap.put('Error2', 'Error message 2');
        wrapper.errors = errorsMap;
        
        // Perform assertions to verify the values are set correctly
        System.assertEquals(errorsMap, wrapper.errors, 'The errors map should be set correctly');
        
    }
    @isTest
    static void testCarDekhoResponseWrapper() {
        AUSFVehicleCarDekhoIntHandler.CarDekhoResponseWrapper wrapper = new AUSFVehicleCarDekhoIntHandler.CarDekhoResponseWrapper();
        
        // Set some sample values to the wrapper properties
        wrapper.id = 123;
        wrapper.insurance = 5000;
        wrapper.ex_showroom_price = 50000;
        wrapper.on_road_price = 60000;
        wrapper.updated_date ='12-12-2021';
        wrapper.rto = 4;
        // Set other properties as needed
        
        // Perform assertions to verify the values are set correctly
        System.assertEquals(123, wrapper.id, 'The id should be set correctly');
        System.assertEquals(5000, wrapper.insurance, 'The insurance should be set correctly');
        // Add more assertions for other properties
        
    }

    @isTest static void verifyCarDekhoApiFailure(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CarDekhoServiceFailureMock( 400, JSON.serialize(new map<String, Object>{ 'errors' => null, 'response' => new map<String, Object>() })));
            AUSFVehicleCarDekhoInt.callCarDekhoAPI('46','49');
        Test.stopTest();
    }

    public with sharing class CarDekhoServiceFailureMock implements HttpCalloutMock{
        public Integer statusCode;
        public String responseBody;

        public CarDekhoServiceFailureMock( Integer statusCode, String responseBody ){
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }

        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody( responseBody );
            res.setStatusCode( statusCode );
            return res;
        }
    }
}