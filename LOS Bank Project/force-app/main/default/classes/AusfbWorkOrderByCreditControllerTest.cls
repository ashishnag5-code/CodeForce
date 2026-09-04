/**
 * @description       : Test Class for Work Order controller LWC Component
 * @author            : Ajitesh
 * @group             : 
 * @last modified on  : 10-29-2023
 * @last modified by  : Ajitesh
**/
@isTest
public with sharing class AusfbWorkOrderByCreditControllerTest {
    
    // Setup coping code from financeController to control single test data
    @testSetup
    public  static void setup() {
        Profile prof = [select Id,Name from profile where name like '%Credit%'];
        
        User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
        	lastName = 'test2',
        	profileId = prof.id,
        	username = 'test'+UserInfo.getOrganizationId()+'@test.com',
        	email = 'test@test.com',
        	Branch_Code__c  = '2103'
    	),true);
        System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]) {
            financeController_Test.setup();
        }
        
    }

    /**
    * @description Initial data load check
    * @author Ajitesh | 10-29-2023 
    **/
    @isTest static void getInitialDataTest() {
        Loan_Application__c loanRec = [SELECT Id FROM Loan_Application__c LIMIT 1];
        
        Test.startTest();
        List<Work_Order__c> workOrder = AusfbWorkOrderByCreditController.getInitialData(loanRec.Id);
        System.assertEquals(workOrder.size(), 0,'Assertion Message');
        Test.stopTest();

    }

    /**
    * @description View and Edit rights check
    * @author Ajitesh | 10-29-2023 
    **/
    @isTest static void viewAndEditRightTest() {
        Loan_Application__c loanRec = [SELECT Id FROM Loan_Application__c LIMIT 1];

        Map<String,Boolean> resp = new Map<String,Boolean>();

        
        Test.startTest();

        // Non applicable product
        resp = AusfbWorkOrderByCreditController.viewAndEditRight(loanRec.Id);
        System.assertEquals(resp.get('visible'), false,'WO not visible');
        

        // Applicable product
        loanRec.Product__c = '10104';
        update loanRec;
        resp = AusfbWorkOrderByCreditController.viewAndEditRight(loanRec.Id);
        System.assertEquals(resp.get('visible'), false,'WO not visible');

        // Applicable stage
        loanRec.Stage__c = 'Credit';
        update loanRec;
        resp = AusfbWorkOrderByCreditController.viewAndEditRight(loanRec.Id);
        System.assertEquals(resp.get('visible'), true,'WO visible');

        Test.stopTest();

    }

    /**
    * @description DML operation test
    * @author Ajitesh | 10-29-2023 
    **/
    @isTest static void upsertWorkOrdersTest() {
        Loan_Application__c loanRec = [SELECT Id FROM Loan_Application__c LIMIT 1];

        Test.startTest();

        // Valid DML
        List<Work_Order__c> workOrders = new List<Work_Order__c>();
        workOrders.add( new Work_Order__c (
            age_work_completed__c = 20, 
            Completion_date__c = Date.newInstance(2022,09,09), 
            Contract_start_date__c = Date.newInstance(2022,09,09), 
            Name_of_the_Principal__c = 'Applicant Name', 
            Nature_of_Work__c = 'Construction', 
            S_No__c = 1, 
            Value_of_contract_Rs_in_lacs__c = 30, 
            Unexecuted_CIH_Rs_in_Lacs__c = 40,
            Loan_Application__c = loanRec.Id
        ));

        workOrders.add( new Work_Order__c (
            age_work_completed__c = 20, 
            Completion_date__c = Date.newInstance(2022,09,09), 
            Contract_start_date__c = Date.newInstance(2022,09,09), 
            Name_of_the_Principal__c = 'Applicant Name', 
            Nature_of_Work__c = 'Construction', 
            S_No__c = 1, 
            Value_of_contract_Rs_in_lacs__c = 30, 
            Unexecuted_CIH_Rs_in_Lacs__c = 40,
            Loan_Application__c = loanRec.Id
        ));

        workOrders = AusfbWorkOrderByCreditController.upsertWorkOrders(workOrders, loanRec.Id);
        System.assertEquals(workOrders.size(), 2,'Assertion Message');
        Test.stopTest();
    }
        
}