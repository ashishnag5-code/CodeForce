@isTest
public class LOSNsdlController_Test {
    @testSetup 
    static void setup() {
        
        Integration_Master__c  intMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c(
            Active__c        = true,
            End_Point_URL__c = 'demoEndpoint',
            HTTP_Method__c   = 'GET',
            API_Key__c       =' demoApiKey',
            Timeout__c       = '12000',
            Apiuser__c       = 'apiuser',
            Name             = 'LOSNsdl'        
        ),true);

        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c      = '10201',
            Stage__c        = 'QDE'
            
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c  = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c   = 'Mandal',
            Email__c       = 'test@gmail.com',
            Loan__c        = loanAppl.Id
            
        ),true);

        Integration_Checklist__c  intChecklist = (Integration_Checklist__c )TestFactory.createSObject(new Integration_Checklist__c(
            is_Latest__c          = true,
            Applicant__c          = appl.Id,
            Integration_Master__c = intMaster.Id
        ),true);
    }
    
    @isTest 
    static void nsdlVerificationHandlerUITestMethod(){
        Test.startTest();
        
            Test.setMock(HttpCalloutMock.class, new IntegrationUtilityMockClass('nsdlVerificationHandlerUITestMethod'));
            Integration_Checklist__c objIntegCheckList = [Select Id from Integration_Checklist__c where is_Latest__c = true limit 1];
            LOSNsdlController.nsdlVerificationHandlerUI('DNMPR0123W', String.valueOf(objIntegCheckList.Id), 'LOSNsdl');
        Test.stopTest();
    } 
    
    @isTest 
    static void nsdlVerificationHandlerUITestMethod1(){
        Test.startTest();
        Applicant__c app = [SELECT Id FROM Applicant__c Limit 1];
        LOSNsdlController.getApplicantDetails(app.Id);
        LOSNsdlController.updateStatus(app.Id,'');
        Test.stopTest();
    } 
}