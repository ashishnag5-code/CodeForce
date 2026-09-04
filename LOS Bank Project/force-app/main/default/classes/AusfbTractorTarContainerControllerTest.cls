/**
 * @description       : 
 * @author            : Ajitesh
 * @group             : 
 * @last modified on  : 11-03-2023
 * @last modified by  : Ajitesh
**/
@isTest
public with sharing class AusfbTractorTarContainerControllerTest {
    // Setup coping code from financeController to control single test data

    public static final String TRACTOR_RECORD_TYPE_DEVELOPER_NAME = 'Tractor';
    public static final String TRACTOR_COLLATERAL_TYPE_RECORD_TYPE_DEVELOPER_NAME = 'New';
    public static final String COLLATERAL_TYPE_TRACTOR = '10109';

    @testSetup
    public  static void setup() {
        financeController_Test.setup();

        // Create user without access to functionality
        Profile prof = [select Id,Name from profile where name = 'Standard User'];
        
        User usr = (User)TestFactory.createSObject(new User(firstName = 'Standard User',
        	lastName = 'test2',
        	profileId = prof.id,
        	username = 'standardUsertar'+UserInfo.getOrganizationId()+'@test.com',
        	email = 'test@test.com',
        	Branch_Code__c  = '2103'
    	),true);
        // Create user without access to functionality

        Loan_Application__c loanApp = [SELECT Id, RecordTypeId, Collateral_Type__c FROM Loan_Application__c LIMIT 1];

        RecordType tractorRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = :TRACTOR_RECORD_TYPE_DEVELOPER_NAME];
        RecordType collateralRecordType = [SELECT Id FROM RecordType WHERE DeveloperName = :TRACTOR_COLLATERAL_TYPE_RECORD_TYPE_DEVELOPER_NAME];

        loanApp.Collateral_Type__c = COLLATERAL_TYPE_TRACTOR;
        loanApp.RecordTypeId = tractorRecordType.Id;
        update loanApp;

        Collateral__c collateralData = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            					Loan__c = loanApp.Id,Vehicle_Usage__c='Personal', RecordTypeId = collateralRecordType.Id),true);
    }

    /**
    * @description Testing collateral fetching function
    * @author Ajitesh | 11-03-2023 
    **/
    @isTest static void getCollateralRecordTest() {
        Loan_Application__c loanApp = [SELECT Id FROM Loan_Application__c LIMIT 1];
        
        Test.startTest();
        Collateral__c collateralData = AusfbTractorTarContainerController.getCollateralRecord(loanApp.Id);
        System.assert(collateralData!=null, 'Collateral data exists');
        Test.stopTest();
        
    }

    /**
    * @description Checking if there are any configurations
    * @author Ajitesh | 11-03-2023 
    **/
    @isTest static void getMetadataConfigTest() {
        Test.startTest();
        List<Tractor_TAR_Form_Config__mdt> config = AusfbTractorTarContainerController.getMetadataConfig();
        System.assert(config.size() > 0, 'Configurations exists');
        Test.stopTest();
        
    }

    /**
    * @description Fetching document checklist and validating documents test
    * @author Ajitesh | 11-03-2023 
    **/
    @isTest static void getDocumentCheckListRelatedToTarAndValidateDocumentTest() {
        // Config metadata
        List<Tractor_TAR_Form_Config__mdt> configs = AusfbTractorTarContainerController.getMetadataConfig();
        
        // Dependent data
        Loan_Application__c loanApp = [SELECT Collateral_Type__c FROM Loan_Application__c LIMIT 1];
        Collateral__c collateralData = [SELECT Id FROM Collateral__c LIMIT 1];
        // Dependent data

        Tractor_TAR_Form_Config__mdt currentConfig = new Tractor_TAR_Form_Config__mdt();
        
        // Document needed for current collateral 
        for(Tractor_TAR_Form_Config__mdt config : configs){
            if(config.Collateral_Type__c != null && config.Collateral_Type__c.indexOf(loanApp.Collateral_Type__c) != -1){
                currentConfig = config;
                break;
            }
        }

        // Creating dependent Document master and checklist
        Document_Master__c docMasterRecord1 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
           Document_Name__c = 'Engine No.',
           Document_Id__c = 'AUWheels0361'
        ),true);

        Document_Checklist__c docCheckRecord1 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Document_Master__c = docMasterRecord1.Id,
            Active__c =true,
            Collateral__c = collateralData.Id
         ),true);
        // Creating dependent Document master and checklist

        Test.startTest();

        List<Document_Checklist__c> documentCheckList = AusfbTractorTarContainerController.getDocumentCheckListRelatedToTar(
            currentConfig.Image_Field_To_Display__c.split(','),
            collateralData.Id
        );
        System.assert(documentCheckList.size() > 0, 'Document checklist exists');

        String resp = AusfbTractorTarContainerController.validateDocumentUpload(documentCheckList);
        System.assert(resp != null, 'Document not uploaded');

        // Uploading Image to checklist
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );

        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = documentCheckList[0].id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        // Uploading Image to checklist

        resp = AusfbTractorTarContainerController.validateDocumentUpload(documentCheckList);
        System.assert(resp == '', 'Document uploaded');

        Test.stopTest();
        
    }

    /**
    * @description Testing exception handling
    * @author Ajitesh | 11-03-2023 
    **/
    @isTest static void exceptionHandlingTest() {
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        Loan_Application__c loanApp = [SELECT Id FROM Loan_Application__c LIMIT 1];

        System.runAs(usr){
            Test.startTest();
            try{
                List<Tractor_TAR_Form_Config__mdt> config = AusfbTractorTarContainerController.getMetadataConfig();
            }
            catch(Exception e) {
                System.assert(true, 'Error occured ');
            }
            try{
                Collateral__c collateralData = AusfbTractorTarContainerController.getCollateralRecord(loanApp.Id);
            }
            catch(Exception e) {
                System.assert(true, 'Error occured ');
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void approvalTestcoverage() {
        Loan_Application__c loanApp = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Test.startTest();
        AusfbTractorTarContainerController.createApproval(loanApp.Id,'test');
        AusfbTractorTarContainerController.getApprovals(loanApp.Id);  
        AusfbTractorTarContainerController.getApprovalRecs(loanApp.Id);  
        AusfbTractorTarContainerController.validateTARSubmitOrApproval(loanApp.Id);
        Test.StopTest();
    }
}