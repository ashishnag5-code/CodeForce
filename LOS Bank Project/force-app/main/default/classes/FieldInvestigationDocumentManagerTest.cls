@isTest
public with sharing class FieldInvestigationDocumentManagerTest {
    
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
    static void getVersionFilesTest(){
        Test.startTest();     
        Field_Investigation__c objFi = [Select Id from Field_Investigation__c limit 1];
        List<FieldInvestigationDocumentManager.ResponseListWrapper> ResultWrapper= FieldInvestigationDocumentManager.getVersionFiles(objFi.id,'Field_Investigation__c');
        System.assertEquals(ResultWrapper[0].recordId != null,true,'AssertMsg');      

        Test.stopTest();
    }  

    @isTest
    public static void deactivateDocumentTest(){
        Test.startTest();
        contentDocument objCondoc = [Select Id from contentDocument limit 1];
        
        String ResultWrapper= FieldInvestigationDocumentManager.deactivateDocument(objCondoc.id);
        System.assertEquals(ResultWrapper != null,true,'AssertMsg');  
        Test.StopTest();

    }

}