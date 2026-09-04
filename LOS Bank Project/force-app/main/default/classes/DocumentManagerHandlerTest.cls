@isTest
public class DocumentManagerHandlerTest {
    @testSetup static void makeData(){
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Loan_Amount__c  = 12000,
            Product__c='10201',
            Tenure__c=12,
            EMI__c=100,
            ROI__c=0
        ),true); 
        
        Id recId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId();
        Applicant__c applicant = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            loan__c  = loanAppl.Id,
            First_Name__c   = 'Caroline',
            Last_Name__c  = 'Forbes',
            RecordTypeId = recId
        ),true);
        
        
        Document_Master__c master = new Document_Master__c(Document_Name__c  = 'Electricity Bill', Name='Electricity Bill');
        insert master;
        
        Document_Checklist__c doc = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Status__c  = 'Received',
            Amount__c   = 1000,
            Applicant__c  = applicant.Id,
            Document_Master__c = master.Id,
            Document_Verification_Status__c=GlobalConstants.VERIFIED
        ),true);
        Contentversion objCV = new Contentversion(Title = 'ABC', PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=doc.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        insert objCV;
    }
    testmethod static void getDocumentChecklist(){
        Applicant__c objApp = [Select Id from Applicant__c limit 1];
        DocumentManagerHandler.getDocumentChecklist(objApp.Id);
    }
    testmethod static void getVersionFiles(){
        Applicant__c objApp = [Select Id from Applicant__c limit 1];
        DocumentManagerHandler.getVersionFiles(objApp.Id);
    }
}