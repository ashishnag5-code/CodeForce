@isTest
public class EMandateStatusServiceTest {
	@testSetup static void setup() {
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10
        ),true);
        Loan_Application__c loanAppl2 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12346',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10',
            Tenure__c = 10
        ),true);
        
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321',
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
        Integration_Master__c  intMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c(
            Active__c        = true,
            End_Point_URL__c = 'demoEndpoint',
            HTTP_Method__c   = 'POST',
            API_Key__c       =' demoApiKey',
            Timeout__c       = '12000',
            Apiuser__c       = 'apiuser',
            Name             = 'E-Mandate Registration'        
        ),true);
        
        Integration_Checklist__c  intChecklist = (Integration_Checklist__c )TestFactory.createSObject(new Integration_Checklist__c(
            is_Latest__c          = true,
            Integration_Master__c = intMaster.Id,
            Loan_Application__c = loanAppl.Id,
            Callback_Request__c = '{"ReferenceCode":1619860103890,"MerchantID":"NACH00000000000392","MndtReqId":"MNDT000000000000000001619860133581","ReqInitDate":"2021-05-01","NpciRefMsgID":"MNDT000000000000000001619860133581","MndtId":"AUBL7020311200008033","Accptd":"false","AccptRefNo":"NULL","ReasonCode":"AP28","ReasonDesc":"Mandate Registration Failed","RejectBy":"Bank","ErrorCode":"000","ErrorDesc":"NA","CycleDate":"NULL"}'
        ),true);
        
        Integration_Checklist__c  intChecklist2 = (Integration_Checklist__c )TestFactory.createSObject(new Integration_Checklist__c(
            is_Latest__c          = true,
            Integration_Master__c = intMaster.Id,
            Loan_Application__c = loanAppl2.Id,
            Callback_Request__c = '{"ReferenceCode":1619860103891,"MerchantID":"NACH00000000000392","MndtReqId":"MNDT000000000000000001619860133581","ReqInitDate":"2021-05-01","NpciRefMsgID":"MNDT000000000000000001619860133581","MndtId":"AUBL7020311200008033","Accptd":"true","AccptRefNo":"NULL","ReasonCode":"AP28","ReasonDesc":"Mandate Registration Failed","RejectBy":"Bank","ErrorCode":"000","ErrorDesc":"NA","CycleDate":"NULL"}'
        ),true);
    }
    
    @istest
    public static void checkCallbackStatusTest(){
        List<Integration_Checklist__c> icList = [SELECT Id,Loan_Application__c,Integration_Master__c,Integration_Master_Name__c,Callback_Request__c FROM Integration_Checklist__c];
        Test.startTest();
        EMandateStatusService.checkCallbackStatus(icList);
        Test.stopTest();
        EMandateStatusService.checkCallbackStatus(icList);
    }
}