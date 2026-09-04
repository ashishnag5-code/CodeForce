@isTest
public class OpsKYCControllerTest {
    @testSetup static void setup() {
        Profile prof = [select Id,Name from profile where name like '%Credit%'];
        Group grp = (Group )TestFactory.createSObject(new Group(Name ='Group1',Type='Queue'),true);
        Group grp2 = (Group )TestFactory.createSObject(new Group(Name ='MH RPC - 4WH - Author',DeveloperName='MH_RPC_4WH', Type='Queue'),true);
        
        //System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]) {
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
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
        
        Document_Master__c  docMaster = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name          = 'AUWheels0006',
            Document_Name__c = 'Application Aadhaar Picture'
            
        ),true);
        
        Document_Checklist__c   docChecklst = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMaster.Id,
            Applicant__c    = appl.Id
        ),true);
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //Get Content Documents
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = docChecklst.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        
        Address__c  addrss = (Address__c )TestFactory.createSObject(new Address__c (
            Address_Line_1__c = 'C-20',
            Address_Line_2__c = 'Govindpuri',
            Address_Line_3__c = 'New Delhi',
            City__c          = 'New Delhi',
            Pincode__c        = '110001',
            Address_Type__c   = 'Permanent',
            Applicant__c     =  appl.Id          
        ),true); 
        
        Assignment__c assignment = new Assignment__c();
        assignment.RecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByName().get('Ops - KYC').getRecordTypeId();
        assignment.Loan_Application__c = loanAppl.Id;
        insert assignment;
        
        /* User usr = (User)TestFactory.createSObject(new User(
firstName = 'test1',
lastName = 'test2',
profileId = prof.id,
Branch_Code__c  = '1111',
username = 'test'+UserInfo.getOrganizationId()+'@test.com',
email = 'test@test.com',
IsActive = true
),true);
}*/
    }
    
    @isTest
    public static void getApplicantListTest(){
        Loan_Application__c loanAppl = [SELECT Id FROM Loan_Application__c LIMIT 1];
        List<Applicant__C> appList = OpsKYCController.getApplicantList(loanAppl.Id);
        System.assertEquals('Vikash', appList[0].First_Name__c);
    }
    
    @isTest
    public static void getDocumentChecklistRecordsTest(){
        Applicant__c appl = [SELECT Id FROM Applicant__c LIMIT 1];
        List<Document_Checklist__c> docList = OpsKYCController.getDocumentChecklistRecords(appl.Id);
        System.assertEquals('Application Aadhaar Picture', docList[0].Document_Master__r.Document_Name__c);
    }
    
    @isTest
    public static void getLinkedFilesTest(){
        Applicant__c appl = [SELECT Id FROM Applicant__c LIMIT 1];
        Map<String,String> docMap = OpsKYCController.getLinkedFiles(appl.Id);
        System.assertEquals(1, docMap.keySet().size());
    }
    
    @isTest
    public static void getAddressesTest(){
        Applicant__c appl = [SELECT Id FROM Applicant__c LIMIT 1];
        List<Address__c> addressList = OpsKYCController.getAddresses(appl.Id);
        System.assertEquals('C-20', addressList[0].Address_Line_1__c);
    }
    
    @isTest
    public static void updateRecordsTest(){
        //Applicant__c loanAppl = [SELECT Id FROM Applicant__c LIMIT 1];
        Document_Checklist__c doc = [SELECT Id FROM Document_Checklist__c LIMIT 1];
        List<Document_Checklist__c> listOfDoc = new List<Document_Checklist__c>();
        listOfDoc.add(doc);
        //Document_Checklist__c docCheckList = new Document_Checklist__c(Id=,Ops_Action__c='Pending');
        doc.Ops_Action__c = 'Pending';
        String result = OpsKYCController.updateRecords(listOfDoc);
        System.assertEquals(false, result.contains('Success'));
    }
    
    @isTest
    public static void updateAddressRecordsTest(){
        //Loan_Application__c loanAppl = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Address__c address = [SELECT Id FROM Address__c LIMIT 1];
        address.OPS_Action__c = 'Pending';
        List<Address__c> listOfAdd = new List<Address__c>();
        listOfAdd.add(address);
        String result = OpsKYCController.updateAddressRecords(listOfAdd);
        OpsKYCController.updateAddressRecords(null);
        System.assertEquals(true, result.contains('Success'));
    }
    
    @isTest
    public static void updateLoanRecordTest(){
        Assignment__c assignment = [SELECT Id FROM Assignment__c LIMIT 1];
        Loan_Application__c loanAppl = [SELECT Id FROM Loan_Application__c LIMIT 1];
        String result = OpsKYCController.updateLoanRecord('Rework','test',loanAppl.Id,assignment.Id);
        System.assertEquals(true, result.contains('Success'));
        result = OpsKYCController.updateLoanRecord('Approve','test',loanAppl.Id,assignment.Id);
        System.assertEquals(true, result.contains('Success'));
        Assignment__c asgnmnt = (Assignment__c)TestFactory.createSObject(new Assignment__c(
            RecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByName().get('Ops - Disbursement').getRecordTypeId(),
            Status__c='Pending',
            Loan_Application__c = loanAppl.Id
        ),true);
        assignment = [SELECT Id FROM Assignment__c WHERE RecordTypeId =: asgnmnt.RecordTypeId LIMIT 1];
        String resultt = OpsKYCController.updateLoanRecord('Rework','test',loanAppl.Id,assignment.Id);
        System.assertEquals(true, resultt.contains('Success'));
        OpsKYCController.reSubmitRecord(loanAppl.Id,assignment.Id,'test');
        
    }
    
    @isTest
    public static void getRecordInfoTest(){
        Loan_Application__c loanAppl = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Assignment__c assignment = [SELECT Id FROM Assignment__c LIMIT 1];
        sObject result = OpsKYCController.getRecordInfo(assignment.Id);
        OpsKYCController.getAddressSourceMetadata();
        System.assertEquals(!String.isBlank(result.Id),true );
    }
    
    @isTest
    public static void reSubmitRecordTest(){
        User usr = [Select Id from User LIMIT 1];
        Test.startTest();
        Loan_Application__c loanAppl = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Applicant__c applt = [SELECT Id FROM Applicant__c LIMIT 1];        	
        Assignment__c asgnmnt = (Assignment__c)TestFactory.createSObject(new Assignment__c(
            RecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByName().get('Ops - Disbursement').getRecordTypeId(),
            Status__c='Pending',
            Loan_Application__c = loanAppl.Id
        ),true);
        Assignment__c assignment = [SELECT Id FROM Assignment__c WHERE RecordTypeId =: asgnmnt.RecordTypeId LIMIT 1];
        try {
            QueueSobject queue = [SELECT id, Queue.Name, QueueId FROM QueueSobject WHERE Queue.DeveloperName LIKE 'MH_RPC_%' LIMIT 1];
            //(Group)TestFactory.createSObject(new Group(Name ='PDD_Author_Queue_All_Product',Type='Queue'),true);
            //PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'SFApp_Admin'];
            //insert new PermissionSetAssignment(AssigneeId = grp.id, PermissionSetId = ps.Id);
            assignment.OwnerId = queue.QueueId;
            update assignment;
            OpsKYCController.checkOwnerUser(assignment.Id);
            String result = OpsKYCController.reSubmitRecord(loanAppl.Id,assignment.Id,'bbb');
            OpsKYCController.updateApplicant(applt.Id,loanAppl.Id,true);
            OpsKYCController.getFIDetailsAssociatedWithApplicant(loanAppl.Id);
            System.assertEquals(true, result.contains('Success'));
        }
        catch (Exception ex) {}
        Test.stopTest();
    }
    @isTest
    public static void reSubmitRecordTest2(){
        User usr = [Select Id from User LIMIT 1];
        Test.startTest();
        Loan_Application__c loanAppl = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Applicant__c applt = [SELECT Id FROM Applicant__c LIMIT 1];        	
        Assignment__c asgnmnt = (Assignment__c)TestFactory.createSObject(new Assignment__c(
            RecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByName().get('Ops - Disbursement').getRecordTypeId(),
            Status__c='Pending',
            Loan_Application__c = loanAppl.Id
        ),true);
        Assignment__c assignment = [SELECT Id FROM Assignment__c WHERE RecordTypeId =: asgnmnt.RecordTypeId LIMIT 1];
        
        try {
            OpsKYCController.checkOwnerUser(assignment.Id);
            OpsKYCController.updateApplicant(applt.Id,loanAppl.Id,true);
            OpsKYCController.getFIDetailsAssociatedWithApplicant(loanAppl.Id);
//            System.assertEquals(true, result.contains('Success'));
        }
        catch (Exception ex) {}
        Test.stopTest();
    }
    
    @isTest
    static void testGetOpsResponseMetadataRecords(){
        Test.startTest();
        try{
            List<OpsKycDocumentsMetadata__mdt> resp1 = OpsKYCController.getOpsResponseMetadataRecords('');
        }catch(Exception ex){
            
        }
        try{
            List<OpsKycDocumentsMetadata__mdt> resp2 = OpsKYCController.getOpsResponseMetadataRecords('Test');
        }catch(Exception ex){
            
        }
            
            List<OpsKycDocumentsMetadata__mdt> resp3 = OpsKYCController.getOpsResponseMetadataRecords('Driving Licence');
        
        
        test.stopTest();
    }
}