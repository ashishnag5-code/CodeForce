@isTest
public class VehiclesControllerTest {

    @testSetup static void setup() { 
        Loan_Application__c loanApp = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                    Customer_Name__c = 'Test Customer 1', Stage__c = 'Pricing', Product__c = '10301', Disbursed_Tranche__c = 5, 
                    RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId(),
                    ROI__c = 12.4, Total_Loan_Amount__c = 10000),true);
    }
    
    @isTest
    static void testgetVehicleData() {
        Loan_Application__c loanApp = [SELECT Id FROM Loan_Application__c LIMIT 1];        
        Test.startTest();
        VehiclesController.getVehicleData(loanApp.Id);       
        Test.stopTest();
    }
}