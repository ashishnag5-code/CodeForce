@isTest
public class ApplicationFormPDFControllerTest {
	@isTest
    public static void getLoanApplTest(){
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        
        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            Branch_Queue__c=grp.Id,
            Purchase_State__c = 'Raj',
            Product__c = '4W',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId()
        ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10301',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Dealer_Master__c = accInstance.Id,
            Sourcing_channel__c  = 'Commercial Associate With Rc Limit',
            Branch_Master__c = accInstance.Id,
            References__c = '[{"Name":"twst","Relationship_With_Borrower":"Father","Mobile_Number":"8888888888","IsActive":"true"},{"Name":"tst","Relationship_With_Borrower":"Father","Mobile_Number":"8888888888","IsActive":"true"}]'
        ),true);
        
        BSR_PSL_Details__c  bsrObj = (BSR_PSL_Details__c )TestFactory.createSObject(new BSR_PSL_Details__c (
            Loan_Application__c = loanAppl.Id,
            RecordTypeId = Schema.SObjectType.BSR_PSL_Details__c.getRecordTypeInfosByName().get('BSR').getRecordTypeId()
        ),true);
        
        List<Applicant__c> lstApp = new List<Applicant__c>();
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar', Aadhaar_Number__c = '203389457612',
            Last_Name__c = 'Mandal',Existing_Customer__c  = 'Yes',
            CIF_No__c = '576321', Customer_Grade__c = 'NIB',
            Loan__c =loanAppl.Id,Type_of_Employment__c = 'Business',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),false);
        lstApp.add(appl);
        
        Applicant__c coappl1 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar', Passport_Number__c = 'J87126409',
            Last_Name__c = 'Mandal',Existing_Customer__c  = 'Yes',
            CIF_No__c = '576321', Customer_Grade__c = 'NIB',
            Loan__c =loanAppl.Id,Type_of_Employment__c = 'Business',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Co_Applicant').getRecordTypeId()
        ),false);
        lstApp.add(coappl1);
        
        Applicant__c coappl2 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',Existing_Customer__c  = 'Yes',
            CIF_No__c = '576321', Customer_Grade__c = 'NIB',
            Loan__c =loanAppl.Id,Type_of_Employment__c = 'Business',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Co_Applicant').getRecordTypeId()
        ),false);
        lstApp.add(coappl2);
        
        Applicant__c guran = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar', Driving_License_Id__c = '123456789012',
            Last_Name__c = 'Mandal',Existing_Customer__c  = 'Yes',
            CIF_No__c = '576321', Customer_Grade__c = 'NIB',
            Loan__c =loanAppl.Id,Type_of_Employment__c = 'Business',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Guarantor').getRecordTypeId()
        ),false);
        lstApp.add(guran);
        
         Applicant__c boappl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar', Voter_Id__c = '123456789012',
            Last_Name__c = 'Mandal',Existing_Customer__c  = 'Yes',
            CIF_No__c = '576321', Customer_Grade__c = 'NIB',
            Loan__c =loanAppl.Id,Type_of_Employment__c = 'Business',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('BO').getRecordTypeId()
        ),false);
        lstApp.add(boappl);
        
        insert lstApp;
        
        Applicant_Financials_Details__c af2 = new Applicant_Financials_Details__c();
        af2.RecordTypeId=Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Financial_Parent').getRecordTypeId();
        af2.Applicant__c = appl.Id;
        af2.Monthly_Income__c = 2000;
        af2.Monthly_Obligation__c = 5000;
        af2.Consider_Income_for_Eligibility__c = 'Yes';
        af2.Total_Work_Experience__c = '12';
        insert af2;
        
        List<Document_Master__c> lstDocumentMaster = new List<Document_Master__c>();
        Document_Master__c docuMaster1 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Document_Id__c = 'AUWheels0001',
            Document_Name__c = 'Live Photo'
        ), false);
        lstDocumentMaster.add(docuMaster1);
        
        docuMaster1 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Document_Id__c = 'AUWheels0003',
            Document_Name__c = 'Aadhaar Card'
        ), false);
        lstDocumentMaster.add(docuMaster1);
        insert lstDocumentMaster;
        
        List<Document_Checklist__c> lstInsertDocCheck = new List<Document_Checklist__c>();
        for (Applicant__c objApp : lstApp) {
            for (Document_Master__c objDocM : lstDocumentMaster) {
                Document_Checklist__c doc = new Document_Checklist__c(Active__c  = true, Applicant__c = objApp.Id, Document_Master__c = objDocM.Id, Status__c = 'Received');
                lstInsertDocCheck.add(doc);
            }
        }
        if (lstInsertDocCheck.size()>0)
            insert lstInsertDocCheck;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(loanAppl);
        ApexPages.currentPage().getParameters().put('id', loanAppl.Id);
        
        //SystemGeneratedEsignDocumentsController eCntrl = new SystemGeneratedEsignDocumentsController();
        ApplicationFormPDFController acntrl = new ApplicationFormPDFController();
        //ApplicationFormPDFController cntrl = new ApplicationFormPDFController(eCntrl);
    }
    
    @IsTest
    static void testReferences(){
        Test.startTest();
        ApplicationFormPDFController.References testRef = new ApplicationFormPDFController.References();
        Test.stopTest();
    }
}