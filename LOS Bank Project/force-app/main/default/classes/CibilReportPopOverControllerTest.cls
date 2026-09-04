@isTest
public class CibilReportPopOverControllerTest {
    @testSetup static void setup() {
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true
            
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Customer_Type__c ='Individual',
            Residential_Status__c ='Resident',
            Loan__c =loanAppl.Id
            
        ),true);
        
        Integration_Master__c  intMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c(
            Active__c  = true,
            End_Point_URL__c ='https://service.aubank.in/CIBILServiceV1',
            HTTP_Method__c ='POST',
            API_Key__c ='epikey',
            Timeout__c ='12000',
            Apiuser__c='SFDC',
            Name = 'Cibil Individual'
            
        ),true);
        
        Integration_Checklist__c intChecklist = new Integration_Checklist__c();
        intChecklist.Response__c  = '{"Testing":"Testing"}';
        intChecklist.Loan_Application__c  = loanAppl.Id; 
        intChecklist.Integration_Master__c  = intMaster.Id; 
        intChecklist.Request_Id__c = '644a0f30c76c5a00e823e11e';
        intChecklist.Applicant__c=appl.Id;
        insert intChecklist;
        
        Bureau_Results__c  brRslt = (Bureau_Results__c )TestFactory.createSObject(new Bureau_Results__c(
            Name = 'CIBIL Score',
            Bureau__c = 'CIBIL',
            Applicant__c = appl.Id
        ),true);
        
        Document_Master__c  docMaster = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name          = 'AUWheels0006',
            Document_Name__c = 'CIBIL'
            
        ),true);
        
        Document_Checklist__c   docChecklst = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMaster.Id,
            Applicant__c    = appl.Id
        ),true);
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Cibil';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Cibil');
        cv.IsMajorVersion = true;
        Insert cv;
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = docChecklst.Id;
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id][0].ContentDocumentId;
        cdl.shareType = 'V';
        ContentDocumentLink cdl2 = New ContentDocumentLink();
        cdl.LinkedEntityId = brRslt.Id;
        cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id][0].ContentDocumentId;
        cdl.shareType = 'V';
        Insert cdl;  
    }
    @isTest
    public static void getApplicantCibilTest(){
        Applicant__c appl=[Select Id from Applicant__c LIMIT 1];   
        Test.startTest();
        CibilReportPopOverController.getApplicantCibil(appl.Id);
        Test.stopTest();
    }    
    
}