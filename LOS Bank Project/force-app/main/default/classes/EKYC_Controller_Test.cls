@isTest
public class EKYC_Controller_Test {
    @testSetup 
    static void setup() {

        Document_Master__c  docMaster = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name             = 'AUWheels0006',
            Document_Name__c = 'Application Aadhaar Picture'
            
        ),true);
        
        Document_Master__c  docMaster1 = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name             = 'AUWheels0007',
            Document_Name__c = 'EKYC PDF'
            
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
            KYC_Type__c    = 'Aadhaar - Biometric',
            KYC_Status__c  = 'Pending',
            Loan__c        =  loanAppl.Id,
            Aadhaar_Number__c='123456'
        ),true);
        
        Address__c  addrss = (Address__c )TestFactory.createSObject(new Address__c (
            Address_Line_1__c = 'C-20',
            Address_Line_2__c = 'Govindpuri',
            Address_Line_3__c = 'New Delhi',
            City__c           = 'New Delhi',
            Pincode__c        = '110001',
            Address_Type__c   = 'Permanent',
            Applicant__c      =  appl.Id          
        ),true);       
        
        Document_Checklist__c   docChecklst = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMaster.Id,
            Applicant__c    = appl.Id            
        ),true);
        
        Document_Checklist__c   docChecklst1 = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMaster1.Id,
            Applicant__c    = appl.Id            
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
        
        Integration_Master__c  intMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c(
            Active__c  = true,
            End_Point_URL__c ='https://serviceuatsfdc.aubankuat.in/SFDCAadharVaultService/getValue?Guid=guidValue&Source=SFDC&Token=tokenValue&Format=formatValue',
            HTTP_Method__c ='GET',
            API_Key__c ='epikey',
            Timeout__c ='12000',
            Apiuser__c='apiuser',
            Content_Type__c = 'application/json',
            Name = 'SFDCAadharVaultService'
            
        ),true);

    }
    
    @isTest 
    static void mobileOtpVerificationHandlerTestMethod(){
        Test.startTest(); 
        Test.setMock(HttpCalloutMock.class,new AadharTokenUtilMock());
        Applicant__c applcnt = [Select Id, KYC_Type__c from Applicant__c limit 1];
        applcnt.KYC_Status__c  = 'Complete';
        
        PageReference pageRef = Page.EKYC_PDF; // Add your VF page Name here
        pageRef.getParameters().put('id', applcnt.Id);
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController standardController = new ApexPages.standardController(applcnt); //instantiate the Applicant object controller
        EKYC_Controller ext = new EKYC_Controller(standardController);

        update applcnt;
        System.assertEquals('Complete', applcnt.KYC_Status__c, 'KYC status not updated');
        Test.stopTest();
    }                                                              
}