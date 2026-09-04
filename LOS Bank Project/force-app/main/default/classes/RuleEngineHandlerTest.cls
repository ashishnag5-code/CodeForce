/* Source Class 1: RuleEngineHandler
*
*/

@isTest
public class RuleEngineHandlerTest {
	@testSetup static void setup() {
    	Document_Master__c  docMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(Name ='AUWheels0053', Document_Id__c = 'AUWheels0053', Document_Name__c  ='FI Photos', Active__c = true),true);
        
        List<Rule_Definition__c> lstRuleDef = new List<Rule_Definition__c>();
        Rule_Definition__c objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'QDE,DDE',
        Rule_Condition__c = 'Contains', 
        Subject_Field__c = 'Loan_Stage__c', Target_Object__c = 'Applicant__c',
        Value_Field__c = 'Value', 
        Sequence__c = 1, Rule_Name__c = 'Applicant Rule'),false);
        lstRuleDef.add(objRuleDef);

        objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'QDE,DDE',
        Rule_Condition__c = 'Equals', 
        Subject_Field__c = 'Loan_Stage__c', Target_Object__c = 'Applicant__c',
        Value_Field__c = 'Value', 
        Sequence__c = 1, Rule_Name__c = 'Applicant Rule'),false);
        lstRuleDef.add(objRuleDef);

        objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'QDE,DDE',
        Rule_Condition__c = 'Not Equals', 
        Subject_Field__c = 'Loan_Stage__c', Target_Object__c = 'Applicant__c',
        Value_Field__c = 'Value', 
        Sequence__c = 1, Rule_Name__c = 'Applicant Rule'),false);
        lstRuleDef.add(objRuleDef);

        objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'QDE,DDE',
        Rule_Condition__c = 'Starts With', 
        Subject_Field__c = 'Loan_Stage__c', Target_Object__c = 'Applicant__c',
        Value_Field__c = 'Value', 
        Sequence__c = 1, Rule_Name__c = 'Applicant Rule'),false);
        lstRuleDef.add(objRuleDef);

        objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'QDE,DDE',
        Rule_Condition__c = 'Does not Contains', 
        Subject_Field__c = 'Loan_Stage__c', Target_Object__c = 'Applicant__c',
        Value_Field__c = 'Value', 
        Sequence__c = 1, Rule_Name__c = 'Applicant Rule'),false);
        lstRuleDef.add(objRuleDef);

        objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'QDE,DDE',
        Rule_Condition__c = 'Includes', 
        Subject_Field__c = 'Loan_Stage__c', Target_Object__c = 'Applicant__c',
        Value_Field__c = 'Value', 
        Sequence__c = 1, Rule_Name__c = 'Applicant Rule'),false);
        lstRuleDef.add(objRuleDef);

        objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'QDE,DDE',
        Rule_Condition__c = 'Excludes', 
        Subject_Field__c = 'Loan_Stage__c', Target_Object__c = 'Applicant__c',
        Value_Field__c = 'Value', 
        Sequence__c = 1, Rule_Name__c = 'Applicant Rule'),false);
        lstRuleDef.add(objRuleDef);

        /*
        objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'QDE,DDE',
        Rule_Condition__c = 'Less Than', 
        Subject_Field__c = 'Loan_Stage__c', Target_Object__c = 'Applicant__c',
        Value_Field__c = 'Value', 
        Sequence__c = 1, Rule_Name__c = 'Applicant Rule'),false);
        lstRuleDef.add(objRuleDef);

        objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'QDE,DDE',
        Rule_Condition__c = 'Greater Than', 
        Subject_Field__c = 'Loan_Stage__c', Target_Object__c = 'Applicant__c',
        Value_Field__c = 'Value', 
        Sequence__c = 1, Rule_Name__c = 'Applicant Rule'),false);
        lstRuleDef.add(objRuleDef);

        objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'QDE,DDE',
        Rule_Condition__c = 'Less or equal', 
        Subject_Field__c = 'Loan_Stage__c', Target_Object__c = 'Applicant__c',
        Value_Field__c = 'Value', 
        Sequence__c = 1, Rule_Name__c = 'Applicant Rule'),false);
        lstRuleDef.add(objRuleDef);

        objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'QDE,DDE',
        Rule_Condition__c = 'Greater or equal', 
        Subject_Field__c = 'Loan_Stage__c', Target_Object__c = 'Applicant__c',
        Value_Field__c = 'Value', 
        Sequence__c = 1, Rule_Name__c = 'Applicant Rule'),false);
        lstRuleDef.add(objRuleDef);

        objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'QDE,DDE',
        Rule_Condition__c = 'Between', 
        Subject_Field__c = 'Loan_Stage__c', Target_Object__c = 'Applicant__c',
        Value_Field__c = 'Value', 
        Sequence__c = 1, Rule_Name__c = 'Applicant Rule'),false);
        lstRuleDef.add(objRuleDef);
        */
        insert lstRuleDef;
        
        Rule_Driver__c objRuleDriver = (Rule_Driver__c )TestFactory.createSObject(new Rule_Driver__c ( Configuring_For__c = 'Document Checklist', 
        Effective_To__c = System.Today().addDays(365), Effective_From__c = System.Today().addDays(-10), Logical_Expression__c = '1', Target_Value__c = 'AUWheels0053', Match_Criteria__c = 'All Match'),false);
        insert objRuleDriver; 
        
        List<Rule_Definition_Driver_Mapping__c> lstDriverMapping = new List<Rule_Definition_Driver_Mapping__c>();
        for (Rule_Definition__c objRuleD : [Select Id from Rule_Definition__c]) {
            Rule_Definition_Driver_Mapping__c objMap = (Rule_Definition_Driver_Mapping__c )TestFactory.createSObject(new Rule_Definition_Driver_Mapping__c ( 
                Rule_Driver_ID__c = objRuleDriver.Id ,
                Rule_ID__c = objRuleD.Id 
            ),false);
            lstDriverMapping.add(objMap);
        }
        insert lstDriverMapping;

    
    }
    
    @isTest 
    static void testRuleCondition1() {
        RecordType LoanRecordType = [Select id from RecordType where Name = 'Four Wheeler' and sObjectType = 'Loan_Application__c' LIMIT 1];
        Test.startTest();
        	Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                Application_Number__c  = 'AP-12345',
                Product__c = '10201',
                Adhar_Card__c   = 123456,
                Loan_Amount__c  = 1000,
                RC_Limit_On_Hold__c=true,
                Stage__c='QDE',
                Final_Exposure__c =10,
                Emi_Frequency__c = 'HALF YEARLY',
                EMI_Date__c = '10',
                First_EMI_Date__c = Date.newInstance(2023, 01, 09),
                RecordTypeId = LoanRecordType.Id
            ),true);
            
            Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',Existing_Customer__c  = 'No',
            Loan__c =loanAppl.Id,
            Dob__c = Date.parse('09/01/1989'),
            Mobile_Number__c='1234567890',
            PAN__c='BKDPK4370H',
            KYC_Status__c = 'Pending',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);

        Set<String> setIds = new Set<String>();
        setIds.add(appl.Id);

        Map<Id,Rule_Driver__c> lstRuleDriver = new Map<Id, Rule_Driver__c>([Select id, Logical_Expression__c, Match_Criteria__c, (Select Id, Rule_ID__r.Target_Object__c, Rule_ID__r.Target_Object_Record_Type__c, Target_Owner__c from Rule_Definition_Driver_Mappings__r) from Rule_Driver__c Limit 1 ]);
        

        RuleEngineHandler objRuleEngine = new RuleEngineHandler();
        objRuleEngine.main('Applicant__c', setIds, lstRuleDriver.keySet(),'Document Checklist');
        objRuleEngine.identifyMatchingRules ();


        Test.stopTest();
    }

    @isTest 
    static void testRuleCondition2() {
        List<Rule_Definition__c> lstRuleDefDelete = [Select Id from Rule_Definition__c];
        delete lstRuleDefDelete;

        List<Rule_Definition_Driver_Mapping__c> lstRuleDriverMappingDelete = [Select Id from Rule_Definition_Driver_Mapping__c];
        delete lstRuleDriverMappingDelete;

        List<Rule_Driver__c> lstRuleDriverDelete = [Select id from Rule_Driver__c];
        delete lstRuleDriverDelete;

        List<Rule_Definition__c> lstRuleDef = new List<Rule_Definition__c>();
        Rule_Definition__c objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'QDE,DDE',
        Rule_Condition__c = 'Less Than', 
        Subject_Field__c = 'Age__c', Target_Object__c = 'Applicant__c',
        Value_Field__c = 'Value', 
        Sequence__c = 1, Rule_Name__c = 'Applicant Rule'),false);
        lstRuleDef.add(objRuleDef);

        objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'QDE,DDE',
        Rule_Condition__c = 'Greater Than', 
        Subject_Field__c = 'Age__c', Target_Object__c = 'Applicant__c',
        Value_Field__c = 'Value', 
        Sequence__c = 1, Rule_Name__c = 'Applicant Rule'),false);
        lstRuleDef.add(objRuleDef);

        objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'QDE,DDE',
        Rule_Condition__c = 'Less or equal', 
        Subject_Field__c = 'Age__c', Target_Object__c = 'Applicant__c',
        Value_Field__c = 'Value', 
        Sequence__c = 1, Rule_Name__c = 'Applicant Rule'),false);
        lstRuleDef.add(objRuleDef);

        objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'QDE,DDE',
        Rule_Condition__c = 'Greater or equal', 
        Subject_Field__c = 'Age__c', Target_Object__c = 'Applicant__c',
        Value_Field__c = 'Value', 
        Sequence__c = 1, Rule_Name__c = 'Applicant Rule'),false);
        lstRuleDef.add(objRuleDef);

        insert lstRuleDef;
        
        Rule_Driver__c objRuleDriver = (Rule_Driver__c )TestFactory.createSObject(new Rule_Driver__c ( Configuring_For__c = 'Document Checklist', 
        Effective_To__c = System.Today().addDays(365), Effective_From__c = System.Today().addDays(-10), Logical_Expression__c = '1', Target_Value__c = 'AUWheels0053', Match_Criteria__c = 'All Match'),false);
        insert objRuleDriver; 
        
        List<Rule_Definition_Driver_Mapping__c> lstDriverMapping = new List<Rule_Definition_Driver_Mapping__c>();
        for (Rule_Definition__c objRuleD : [Select Id from Rule_Definition__c]) {
            Rule_Definition_Driver_Mapping__c objMap = (Rule_Definition_Driver_Mapping__c )TestFactory.createSObject(new Rule_Definition_Driver_Mapping__c ( 
                Rule_Driver_ID__c = objRuleDriver.Id ,
                Rule_ID__c = objRuleD.Id 
            ),false);
            lstDriverMapping.add(objMap);
        }
        insert lstDriverMapping;

        RecordType LoanRecordType = [Select id from RecordType where Name = 'Four Wheeler' and sObjectType = 'Loan_Application__c' LIMIT 1];
        Test.startTest();
        	Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                Application_Number__c  = 'AP-12345',
                Product__c = '10201',
                Adhar_Card__c   = 123456,
                Loan_Amount__c  = 1000,
                RC_Limit_On_Hold__c=true,
                Stage__c='QDE',
                Final_Exposure__c =10,
                Emi_Frequency__c = 'HALF YEARLY',
                EMI_Date__c = '10',
                First_EMI_Date__c = Date.newInstance(2023, 01, 09),
                RecordTypeId = LoanRecordType.Id
            ),true);
            
            Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',Existing_Customer__c  = 'No',
            Loan__c =loanAppl.Id,
            Dob__c = Date.parse('09/01/1989'),
            Mobile_Number__c='1234567890',
            PAN__c='BKDPK4370H',
            KYC_Status__c = 'Pending',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);

        Set<String> setIds = new Set<String>();
        setIds.add(appl.Id);

        Map<Id,Rule_Driver__c> lstRuleDriver = new Map<Id, Rule_Driver__c>([Select id, Logical_Expression__c, Match_Criteria__c, (Select Id, Rule_ID__r.Target_Object__c, Rule_ID__r.Target_Object_Record_Type__c, Target_Owner__c from Rule_Definition_Driver_Mappings__r) from Rule_Driver__c Limit 1 ]);
        

        RuleEngineHandler objRuleEngine = new RuleEngineHandler();
        objRuleEngine.main('Applicant__c', setIds, lstRuleDriver.keySet(),'Document Checklist');
        objRuleEngine.identifyMatchingRules ();


        Test.stopTest();
    }
}