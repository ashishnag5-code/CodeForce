@isTest
public class VehicleTriggerHandlerTest {
    
    @testSetup static void setup() {  
    	Loan_Application__c loanApp = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                            			Application_Number__c = 'AP-12345',Adhar_Card__c = 123456,
            							Loan_Amount__c = 1000,Product__c='10201'),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
                            First_Name__c = 'Vikash',Middle_Name__c = 'Kumar',Last_Name__c = 'Mandal',Loan__c =loanApp.Id,
            				Customer_Name__c='Vikas',Customer_Type__c='Individual'),true);
        Collateral__c collat = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            					Loan__c = loanApp.Id,Vehicle_Usage__c='Personal'),true);
        Document_Master__c docMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            							Name = 'Test Document', Document_Category__c = 'Vehicle Document', 
            							Document_Sub_Category__c = 'Vehicle Document', Document_ID__c = 'AUWheels0008'),true);
		Document_Checklist__c docChecklist = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            								Applicant__c = appl.Id, Collateral__c = collat.Id, Document_Master__c = docMaster.Id, 
            								Loan_Application__c =loanApp.Id),true);
        Rule_Driver__c  ruleDriver = (Rule_Driver__c)TestFactory.createSObject(new Rule_Driver__c(
            							Configuring_For__c = 'Document Checklist', Effective_From__c = datetime.now().addDays(-10),
            							Effective_To__c = datetime.now().addDays(10), Object_Name__c = 'Collateral__c'/*Applicant__c,Collateral__c*/,
        								Match_Criteria__c = 'First Match'),true);
        Rule_Definition__c ruleDef = (Rule_Definition__c)TestFactory.createSObject(new Rule_Definition__c(
            					Effective_To__c = datetime.now(), Target_Object__c = 'Document_Checklist__c'/*Target_Object_Record_Type__c = ''*/,
        						Attribute_Fixed_Value__c = 'Auto Loan (New) ;Two Wheeler (New) ;Car Taxi (New) ;Construction Equipment (New) ;CV Loading (New) ;CV Passenger (New) ;Tractor (New)',
        						Subject_Object__c = 'Loan_Application__c', Subject_Field__c = 'RecordType.DeveloperName',
        						Rule_Condition__c = 'Contains', Value_Field__c = 'Field'),true);
        Rule_Definition_Driver_Mapping__c rulDefDriverMap = (Rule_Definition_Driver_Mapping__c)TestFactory.createSObject(new Rule_Definition_Driver_Mapping__c(
        						Rule_ID__c = ruleDef.Id, Rule_Driver_ID__c = ruleDriver.Id, Target_Owner__c = 'AUWheels0008'),true);
        Collateral__c collat2 = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            					Loan__c = loanApp.Id,Vehicle_Usage__c='Personal'),true);
    }
    
    @isTest
    static void testAfterInsert() {    
        Test.startTest();
        Test.stopTest();
    }
}