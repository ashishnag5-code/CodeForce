/*******************************************************************************************
* @Name         SystemGeneratedEventTriggerTest
* @Author       Yash Shukla
* @Description   Test Class to handle the System generated Documents Trigger
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer           Date               Description
*-------------------------------------------------------------------------------------------
*  1.0             Yash Shukla        16/10/2023         Initial Creation
*******************************************************************************************/
@IsTest
public class SystemGeneratedEventTriggerTest {
    
    @testsetup static void setup(){
        Document_Master__c  docMaster = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name          = 'AUWheels0010',
            Document_Name__c = 'Delivery Order'
        ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10', 
            Tenure__c = 10
        ),true);
        
        Collateral__c testCollateralRec = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId(),
            Loan__c = loanAppl.Id,
            Collateral_Type__c = 'Existing ',
            Registration_Number__c = '123456Test',
            Ex_Showroom_Price__c = 100,
            Discount__c = 10,
            Net_of_Discount_Price__c = 10,
            Final_Cost__c = 10,
            LTV_offered_On_final_cost__c = 10,
            Apportioned_Loan_Amount__c = 10,
            RTO_Taxes__c = 100.00,
            Insurance__c = 1000.00
        ),true);
        
        Document_Checklist__c   docChecklst = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMaster.Id,
            Loan_Application__c= loanAppl.Id,
            Document_Name__c = 'Delivery Order'
        ),true);
    }
    
    @IsTest
    static void testEventInsert(){
        Sobject[] platEvents = new List<Sobject>();
        String loanId = [SELECT Id FROM Loan_Application__c LIMIT 1].Id;
        System_Generated_Document_Event__e eventRec = new System_Generated_Document_Event__e();
        eventRec.Letter_Type__c = 'DELIVERY ORDER';
        eventRec.Loan_Application_Id__c = loanId;
        platEvents.add(eventRec);
        Test.startTest();
        EventBus.publish(platEvents);
    	Test.getEventBus().deliver();
        Test.stopTest();
        
        
    }

}