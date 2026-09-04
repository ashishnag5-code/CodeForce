@isTest
public class ContentVersionTriggerTest {
    @testSetup static void setup() {
        Account branchMaster = (Account)TestFactory.createSObject(new Account(
            Name ='Branch M',
            Account_Code__c='21034',
            Purchase_City__c='Jaipur',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Branch').getRecordTypeId()
        ),true);
        
        Document_Master__c  docMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c (
            Name = 'AUWheels0008',
            Document_Name__c = 'Voter id Card',
            Multiple_Upload__c  = false
        ),true);
        
        Document_Checklist__c docChkRecord = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Document_Name__c ='Voter id Card',
            Document_Number__c = 'BEMPN6666E',
            Name_Match_Score__c = 100,
            Checklist_ID__c=branchMaster.Id,
            Document_Master__c=docMaster.Id
        ),true);
    }
   
    testmethod static void upsertVersionData(){
        Account objAcc = [Select Id from Account limit 1];
        Contentversion objCV = new Contentversion(Title = 'ABC', PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=objAcc.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        insert objCV;
        objCV.Title = 'ABCD';
        update objCV;
    }
    
    testmethod static void testContentVersionHandler(){
        Account objAcc = [Select Id from Account limit 1];
        Contentversion objCV = new Contentversion(Title = 'ABC', PathOnClient = 'test',Checklist_ID__c=objAcc.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        insert objCV;
        try{
          ContentVersionHandler.linkToDocumentCheckList(new List<Contentversion>{objCV});  
        } catch(Exception exp){}
        
    }
    
    testmethod static void upsertCDLData(){
        Document_Checklist__c objAcc = [Select Id from Document_Checklist__c limit 1];
        insert new Contentversion(Title = 'ABCD', PathOnClient = 'testD',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=objAcc.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        Contentversion objCV = new Contentversion(Title = 'ABC', PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=objAcc.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        insert objCV;
        String cdId = [Select Id,ContentDocumentId from Contentversion where id=:objCV.Id].ContentDocumentId;
        ContentDocumentLink cdl = [Select Id from ContentDocumentLink where ContentDocumentId=:cdId limit 1];
        cdl.ShareType = 'I';
        update cdl;
    }
    
    @isTest
    public static void remainingTests(){
      	Account objAcc = [Select Id from Account limit 1];
		Contentversion objCV = new Contentversion(Title = 'ABC', PathOnClient = 'test',Is_Compress__c=true,API_Source__c='Lead',Request_Id__c=objAcc.Id, VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body'));
        Map<Id,Contentversion> mapCV = new Map<Id,Contentversion>{objCV.Id=>objCV};
        List<Contentversion> listCV = new List<Contentversion>{objCV};
        ContentVersionTriggerService CVTS = new ContentVersionTriggerService();
        ContentDocumentLinkService CDLS = new ContentDocumentLinkService();
		CVTS.beforeUpdate(listCV,mapCV,mapCV);
		CDLS.beforeUpdate(listCV,mapCV,mapCV);
        CVTS.beforeDelete(mapCV);
        CDLS.beforeDelete(mapCV);
        CVTS.afterDelete(mapCV);
        CDLS.afterDelete(mapCV);
        CVTS.afterUndelete(mapCV);
        CDLS.afterUndelete(mapCV);
    }
}