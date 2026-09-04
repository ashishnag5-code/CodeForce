@isTest
public class KarzaGSTAuthControllerTest {
    @testsetup static void setup(){
        
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
        
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321',
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
        Integration_Master__c integrationMast = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Karza GST Authentication',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/KarzaGSTService/gstVerify',
            HTTP_Method__c = 'POST',
            API_Key__c = '123454',
            Include_Certificate__c = true,
            Apiuser__c = 'SFDCf'           
        ),true);  
    }
    
    @isTest
    public static void karzaGSTCallOutTest(){
        Applicant__c appObj = [SELECT Id FROM Applicant__c LIMIT 1];
        KarzaGSTAuthController.karzaGSTCallOut('27AAACR5055K1Z7',appObj.Id);
    }
}