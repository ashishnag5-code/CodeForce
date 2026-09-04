@isTest
public class AUSFVehicleBikeDekhoTest {
   @testSetup static void setup() {
        //Loan Application Insertion
        /*Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10
        ),true);
            Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Customer_Type__c ='Individual',
            Residential_Status__c ='Resident',
            Bureau_Score__c = '10',
            Loan__c =loanAppl.Id
            
        ),true);
       Integration_Master__c BureauRes = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
           Applicant__c = appl.id,
           Account_High_Credit_Amount__c = 100
       ),true); */
        Integration_Master__c intmassearch1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Bike Dekho Pricing',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://service.aubank.in/KarzaAddressMatchServiceV1',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
   }
       @IsTest
    static void intTestMethod() {
        test.starttest();
        List<Object> recordList = new List<Object>();
        AUSFVehicleBikeDekhoIntHandler handler = new AUSFVehicleBikeDekhoIntHandler();
        handler.generateJSONResponse(recordList);
        Test.setMock(HttpCalloutMock.class, new BikeDekhoPricingMock());
        AUSFVehicleBikeDekhoInt.callBikeDekhoAPI('84', '784');
        test.stoptest();
    }
}