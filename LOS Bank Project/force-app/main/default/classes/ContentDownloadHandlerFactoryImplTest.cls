@isTest
public class ContentDownloadHandlerFactoryImplTest {
    @testSetup static void setup() {
         Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
         
            
        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            Branch_Queue__c=grp.Id
        ),true);
        Date start = Date.newInstance(1999, 12, 31);
        Date endDate = Date.newInstance(1999, 12, 31);
        Scheme_Master__c scheme1 = (Scheme_Master__c)TestFactory.createSObject(new Scheme_Master__c(
            START_DATE__c  = start,
            EXPIRY_DATE__c   = endDate,
            Is_InActive__c  = false,
            Scheme_Name__c = 'Normal', Vehicle_Category__c ='TestCat'
        ),true);
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,BRE_Status__c = Label.BRE_Status_Received,
            Branch_Master__c = accInstance.Id, BRE_Selected_Scheme__c = scheme1.id
        ),true);
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            Bureau_Score__c = '680',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        Document_Master__c  docMaster = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name = 'AUWheels0006',
            Document_Name__c = 'PAN',
            Download_Profiles__c = 'System Administrator'
        ), false);
        insert docMaster;
        Document_Checklist__c docChkRecord = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id,
            Applicant__c = appl.Id,
            Document_Master__c = docMaster.Id,
            Document_Name__c ='PAN',
            Document_Number__c = 'BEMPN6666N'
        ), false);
        insert docChkRecord;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Response';
        cv.PathOnClient = 'Response.txt';
        cv.VersionData = Blob.valueOf('test');
        cv.IsMajorVersion = true;
        Insert cv;
        
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = docChkRecord.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
    }
    
    @IsTest
    static void testGetContentDownloadHandler() {
        List<Id> cvIds = new List<Id>();
        for(ContentVersion cv : [SELECT ID FROM ContentVersion]){
            cvIds.add(cv.Id);
        }
        Test.startTest();
        ContentDownloadHandlerFactoryImpl cdf = new ContentDownloadHandlerFactoryImpl();
        cdf.getContentDownloadHandler(cvIds,null);
        Test.stopTest();
    }
    
    @IsTest
    static void testGetContentDownloadHandler1() {
        List<Id> cvIds = new List<Id>();
        Document_Master__c  docMaster = [SELECT Id,Download_Profiles__c FROM Document_Master__c limit 1];
        docMaster.Download_Profiles__c = null;
        update docMaster;
        for(ContentVersion cv : [SELECT ID FROM ContentVersion]){
            cvIds.add(cv.Id);
        }
        Test.startTest();
        ContentDownloadHandlerFactoryImpl cdf = new ContentDownloadHandlerFactoryImpl();
        cdf.getContentDownloadHandler(cvIds,null);
        Test.stopTest();
    }
}