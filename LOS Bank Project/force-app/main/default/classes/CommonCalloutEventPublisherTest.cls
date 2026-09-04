@isTest
public class CommonCalloutEventPublisherTest {
    @testSetup static void setup() {
        Account branchMaster = (Account)TestFactory.createSObject(new Account(
            Name ='Branch M',
            Account_Code__c='21034',
            Purchase_City__c='Jaipur',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Branch').getRecordTypeId()
        ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,BRE_Status__c = Label.BRE_Status_Received
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
        Opportunity opp = new Opportunity(Name='Opp',CloseDate=System.today().addDays(30),AccountId=branchMaster.Id,StageName='New');
        insert opp;
        Integration_Master__c intmassearch2 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'Disbursement Details',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://serviceuatsfdc.aubankuat.in/DisburseLoanService/getLoanDisbursementDetails',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC',
            Source_of_Entry__c='Applicant__c'
        ),true);
        Integration_Checklist__c intCheck = (Integration_Checklist__c)TestFactory.createSObject(new Integration_Checklist__c(
            Request__c = 'Disbursement Details',
            Response__c = '',
            Applicant__c = appl.Id,
            Loan__c =opp.Id,
            Integration_Master__c = intmassearch2.Id
        ),true);
        Interface_Inputs__c objII = new Interface_Inputs__c(Child_Relationship_Name__c='Applicant__c',Field_Name__c='First_Name__c',Integration_Master__c=intmassearch2.Id,Re_Triggers_Interface__c=false);
        insert objII;
    }
    testmethod static void main(){
        Test.startTest();
        List<Integration_Checklist__c> lstIC = [Select Id,Request__c,Response__c,Applicant__c,Integration_Master__c,Loan__c from Integration_Checklist__c];
        CommonCalloutEventPublisher objCCEP = new CommonCalloutEventPublisher(lstIC);
        objCCEP.createPEs();
        Test.stopTest();
    }
    testmethod static void constructInputWrapper(){
        Test.startTest();
        List<Integration_Master__c> lstICM = [Select Id,Source_of_Entry__c,(Select Id,Name,Child_Relationship_Name__c,Field_Name__c from Interface_Inputs__r) from Integration_Master__c];
        List<Integration_Checklist__c> lstIC = [Select Id,Request__c,Response__c,Applicant__c,Integration_Master__c,Loan__c from Integration_Checklist__c];
        CommonCalloutEventPublisher objCCEP = new CommonCalloutEventPublisher();
        objCCEP.constructInputWrapper(lstICM[0],lstIC[0],lstIC[0].Applicant__c);
        Test.stopTest();
    }
}