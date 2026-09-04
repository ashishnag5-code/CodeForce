@isTest
public class OpsAssignementUtilityTest {
    @testSetup static void setup() {
         Account  accountInstance = (Account)TestFactory.createSObject(new Account(
            Name='ParentAccount',
            Grading__c ='Platinum-Certified',
            Certified_Value__c = 'Yes'
        ),true);
        
        Account  accountChildInstance = (Account)TestFactory.createSObject(new Account(
            Name='childAccount',
            State__c=accountInstance.Id,
            TW_Disbursement_Author_Queue__c = 'Group1'
        ),true);
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022', 
            Branch_Master__c =accountChildInstance.Id,
            Tenure__c = 10,
            RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId()
        ),true);
        
        Loan_Application__c loanAppMaker = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-98765',
            Adhar_Card__c   = 987654,
            Loan_Amount__c  = 10000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='Ops Maker',
            EMI_Date__c = '10/3/2022', 
            Branch_Master__c =accountChildInstance.Id,
            Tenure__c = 7
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
        assignment.Status__c = 'Pending';
        insert assignment;
    }
    
    @isTest
    public static void updateAssOwnerTest(){
        Test.startTest();
            Assignment__c ass = [SELECT Id FROM Assignment__c LIMIT 1];
            Boolean isTrue = OpsAssignementUtility.updateAssignmentOwner(ass.Id);
            System.assertEquals(isTrue, false);
        Test.stopTest();
    }
    
    @isTest
    public static void submitOwnerTest(){
    Test.startTest();
        Loan_Application__c loanAppl = [SELECT Id,OwnerId,RecordTypeId FROM Loan_Application__c LIMIT 1];
            Assignment__c ass = [SELECT Id FROM Assignment__c LIMIT 1];
            //OpsAssignementUtility.doOpsAssignment(loanAppl,'Ops - KYC','Ops Maker');
            OpsAssignementUtility.doOpsAssignmentAction(loanAppl,'Ops - KYC','Ops Maker','');
            OpsAssignementUtility.doOpsAssignment(loanAppl,'Ops - Disbursement','Ops Maker');
            Id newRecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Four Wheeler').getRecordTypeId();
            loanAppl.RecordTypeId = newRecordTypeId;
          loanAppl.Disbursement_Category__c = 'Partial';
            update loanAppl;
            OpsAssignementUtility.doOpsAssignmentAction(loanAppl,'Ops - KYC','Ops Maker','');
          OpsAssignementUtility.doOpsAssignment(loanAppl,'Ops - Disbursement','Ops Maker');
            OpsAssignementUtility.submittoOpsAuthor(ass);
            OpsAssignementUtility.markAssignmentComplete(ass);
        Test.stopTest();
    }
    
    @isTest
    public static void grpAssOwnerTest(){
    Test.startTest();
        Group grp = (Group )TestFactory.createSObject(new Group (
                Name ='Group1',
                Type='Queue'
            ),true); 
            QueueSobject so =  new QueueSobject(QueueId = grp.Id, SObjectType = 'Assignment__c');
            insert so ;
            UserRole userRole = new UserRole(Name = 'Somebody else');
            insert userRole;
            
            Profile profileId = [SELECT Id FROM Profile WHERE Name Like '%Admin%' LIMIT 1];
    
            User user = new User(
                UserRoleId = userRole.Id,
                LastName = 'Test Code',
                Email = 'test@test.com',
                Alias = 'Tcode',
                Username = 'test1234444@testzsdfsdtfsdf.com',
                CommunityNickname = 'test12',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'GMT',
                ProfileID = profileId.Id,
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8'
            );
            insert user;
            system.runAs(user){
                Assignment__c ass = [SELECT Id FROM Assignment__c LIMIT 1];
                ass.OwnerId = grp.Id;
                update ass;
                OpsAssignementUtility.updateAssignmentOwner(ass.Id);
            List<Loan_Application__c> loanAppList = [SELECT Id,OwnerId,Product__c FROM Loan_Application__c LIMIT 2];
            Loan_Application__c loanAppl = loanAppList[0];
            Loan_Application__c loanAppMaker = loanAppList[1];
            OpsAssignementUtility.doOpsAssignmentAction(loanAppMaker,'Ops - KYC','Ops Maker','');
                
            //Product New, Four Wheeler
            OpsAssignementUtility.doOpsAssignmentAction(loanAppl,'Ops - Disbursement','Ops Maker','');
            OpsAssignementUtility.doOpsAssignment(loanAppl,'Ops - Disbursement','Ops Author');
            
            //Product New, Two Wheeler
            loanAppl.RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId();
            update loanAppl;
            OpsAssignementUtility.doOpsAssignment(loanAppl,'Ops - Disbursement','Ops Maker');
            OpsAssignementUtility.doOpsAssignment(loanAppl,'Ops - Disbursement','Ops Author');
            OpsAssignementUtility.doOpsAssignment(loanAppl,'Ops - PDD','Ops Maker');
            OpsAssignementUtility.doOpsAssignment(loanAppl,'Ops - PDD','Ops Author');
            OpsAssignementUtility.doOpsAssignment(loanAppl,'Credit - BSR/ PSL','Ops Author');
            
            /*Product New, Tractor
            loanAppl.RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Tractor').getRecordTypeId();
            update loanAppl;
            OpsAssignementUtility.doOpsAssignment(loanAppl,'Ops - Disbursement','Ops Maker');
            OpsAssignementUtility.doOpsAssignment(loanAppl,'Ops - Disbursement','Ops Author');
                
            //Product New, Commercial Vehicle   
            loanAppl.RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Commercial Vehicle').getRecordTypeId();
            update loanAppl;
            OpsAssignementUtility.doOpsAssignment(loanAppl,'Ops - Disbursement','Ops Maker');
            OpsAssignementUtility.doOpsAssignment(loanAppl,'Ops - Disbursement','Ops Author');
              
            //Product Used, Commercial Vehicle 
            loanAppl.Product__c = '10202';
            update loanAppl;
            OpsAssignementUtility.doOpsAssignment(loanAppl,'Ops - Disbursement','Ops Maker');
            OpsAssignementUtility.doOpsAssignment(loanAppl,'Ops - Disbursement','Ops Author');
                
            //Product Used, Tractor 
            loanAppl.RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Tractor').getRecordTypeId();
            update loanAppl;
            OpsAssignementUtility.doOpsAssignment(loanAppl,'Ops - Disbursement','Ops Maker');
            OpsAssignementUtility.doOpsAssignment(loanAppl,'Ops - Disbursement','Ops Author');*/
                
            /*Product Used, Two Wheeler
            loanAppl.RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId();
            update loanAppl;
            OpsAssignementUtility.doOpsAssignment(loanAppl,'Ops - Disbursement','Ops Maker');
            OpsAssignementUtility.doOpsAssignment(loanAppl,'Ops - Disbursement','Ops Author');
               
            //Product Used, Four Wheeler
            loanAppl.RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Four Wheeler').getRecordTypeId();
            update loanAppl;
            OpsAssignementUtility.doOpsAssignment(loanAppl,'Ops - Disbursement','Ops Maker');
            OpsAssignementUtility.doOpsAssignment(loanAppl,'Ops - Disbursement','Ops Author');*/
            }
        Test.stopTest();
    }
    
    @IsTest
    static void testUpdateAssignmentPendingStatus(){
        Assignment__c assignRecord = [SELECT Id FROM Assignment__c LIMIT 1];
        Test.startTest();
        OpsAssignementUtility.updateAssignmentPendingStatus(assignRecord.Id);
        Test.stopTest();
    }

}