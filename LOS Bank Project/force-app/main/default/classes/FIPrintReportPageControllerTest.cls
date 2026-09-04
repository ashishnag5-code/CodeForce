@isTest
public with sharing class FIPrintReportPageControllerTest {
    @testSetup 
    static void setup() {
        Document_Master__c  docMaster = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name   			 = 'AUWheels0006',
            Document_Name__c = 'Application Aadhaar Picture',
            Document_Id__c = 'AUWheels0053'       

            
        ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c      = '10201',
            Stage__c        = 'QDE'
            
        ),true);
        
        
        Applicant__c appl  = (Applicant__c) TestFactory.createSObject(new Applicant__c(
            First_Name__c  = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c   = 'Mandal',
            Email__c       = 'test@gmail.com',            
            KYC_Type__c	   = 'Aadhaar - Biometric',
            KYC_Status__c  = 'Pending',
            Loan__c		   =  loanAppl.Id           
        ),true);

        Field_Investigation__c fieldInvestigationObj= (Field_Investigation__c)TestFactory.createSObject((new Field_Investigation__c( 
            Name = appl.First_Name__c,
        Loan_Application__c =loanAppl.Id,
         Applicant__c=appl.Id,
         FI_Status__c ='Negative',
         Proposed_vehicle__c=GlobalConstants.AUTOLOANNEW,
         Applicant_Type__c='Applicant' )),true);
        
        Address__c  addrss = (Address__c )TestFactory.createSObject(new Address__c (
            Address_Line_1__c = 'C-20',
            Address_Line_2__c = 'Govindpuri',
            Address_Line_3__c = 'New Delhi',
            City__c      	  = 'New Delhi',
            Pincode__c        = '110001',
            Address_Type__c   = 'Permanent',
			Applicant__c 	  =  appl.Id   
        ),true);       
        
        Document_Checklist__c   docChecklst = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMaster.Id,
            Applicant__c    = appl.Id ,
            Field_Investigation__c=fieldInvestigationObj.Id
          
        ),true);
        
        ContentVersion newFile = (ContentVersion) TestFactory.createSObject(new ContentVersion  (
            PathOnClient = 'EKYC Applicant Image.jpeg',
            Title = 'EKYC Applicant Image',
            VersionData = Blob.valueOf('Sample content')      
        ),true);
        
        //Query the contentDocumentId
        ContentVersion insertedFile = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:newFile.Id];
        
        //Link the file with the product
        ContentDocumentLink  linkedFile  = (ContentDocumentLink) TestFactory.createSObject(new ContentDocumentLink   (
            LinkedEntityId=docChecklst.Id, 
            ContentDocumentId=insertedFile.ContentDocumentId
        ),true);
       

    }

    @isTest
    public static void FIPrintReportPageTest(){
        Test.startTest();
        Field_Investigation__c objFi = [Select Id from Field_Investigation__c limit 1];
        ApexPages.currentPage().getParameters().put('recId', String.valueOf(objFi.Id));
        FIPrintReportPageController ff= new FIPrintReportPageController();
        Test.StopTest();

    }
    @isTest
    public static void FIPrintReportPageController_V3(){
        Test.startTest();
        Field_Investigation__c objFi = [Select Id from Field_Investigation__c limit 1];
		PageReference pageRef = Page.FIPrintReportPage_V3;
		Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id', String.valueOf(objFi.Id));
		ApexPages.StandardController sc = new ApexPages.StandardController(objFi);
		FIPrintReportPageController_V3	controller = new FIPrintReportPageController_V3(sc);
        
        FIPrintReportPageController_V3.getDateInUserLocale(String.valueOf(System.NOW()));
        Test.stopTest();
    }
}