/**
 * @description       : 
 * @author            : AU Dev Team
 * @group             : 
 * @last modified on  : 12-14-2023
 * @last modified by  : Ajitesh
**/
@isTest
public class AUSFPSDButtonsControllerTest {
    @testSetup static void setup() {
        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            RC_Limit_Amount__c = 1000,
            RC_Limit_Used_Amount__c = 100,
            Ad_Hoc_Date__c = System.today().addDays(1),
            RC_Limit_Used_Count__c = 0
        ),true);
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10202',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Sourcing_Channel_Name__c = accInstance.Id,
            Total_Loan_Amount__c = 100,
            Total_Charges__c=100,
            Dpd_Checked_Date__c = System.today()-2,
            Repayment_Mode__c = 'E mandate without PDC'
        ),true);
        Profile prof = [select Id,Name from profile where name like '%Credit%'];
        User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
                                                            lastName = 'test2',
                                                            profileId = prof.id,
                                                            username = 'test'+UserInfo.getOrganizationId()+'@test.com',
                                                            email = 'test@test.com',
                                                            Branch_Code__c  = '2103'
                                                           ),true);
        list<Loan_Application_Approval__c> lstLoanAppApproval = new List<Loan_Application_Approval__c>();
        Loan_Application_Approval__c loanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id, Approver__c = usr.id, Approval_Type__c = GLOBALConstants.APPROVAL_TYPE_PRICING 
        ),false);
        Loan_Application_Approval__c loanAppApproval1 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id, Approver__c = usr.id 
        ),false);
        lstLoanAppApproval.add(loanAppApproval);
        insert lstLoanAppApproval;
        
        
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            IsInactive__c = false,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        Document_Master__c  docMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Name ='Test',
            Document_Name__c  ='Customers Signature'
        ),false);
        
        Document_Checklist__c docChkRecord = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            //Parent_Loan__c   = loanAppl.Id,
            Applicant__c = appl.Id,
            Document_Master__c = docMaster.Id,
            Document_Name__c ='Customers Signature'
        ),false);
        Applicant__c appl1 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash1',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            Existing_Customer__c = 'Yes',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
        Document_Checklist__c docChkRecord1 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Applicant__c    = appl.Id
        ),true);
        
        Payment__c paymentRecord = (Payment__c)TestFactory.createSObject(new Payment__c(
            Payment_Recipient__c ='Customer',
            Loan_Application__c  = loanAppl.Id,
            Net_amount__c = 200,
            Inactive__c = false,
            isVerified__c = true
        ),true);
        
        Sanction_Condition__c sanctionRecord = (Sanction_Condition__c)TestFactory.createSObject(new Sanction_Condition__c(
            Loan_Application__c  = loanAppl.Id,
            Status__c = 'Compliant'
        ),true);
        //MMV Insertion
        MMV_Master__c mmvMaster = (MMV_Master__c )TestFactory.createSObject(new MMV_Master__c (
            Name ='Test',
            //            Collateral_Name__c ='Car',
            Collateral_Type__c ='Automobile'
        ),true);
        
        // Collateral Insertion
        Collateral__c  collateral = (Collateral__c )TestFactory.createSObject(new Collateral__c (
            Loan__c =loanAppl.Id,
            // Name ='CollateralTest',
            
            MMV_Master__c =mmvMaster.Id,
            Vehicle_Number__c='TN12345567',
            Certified_Value__c='1234',
            Collateral_Name__c ='10108',
            Deferral_Category__c = 'RC Limit Deferral'
        ),true);
    } 
    
    @isTest
    public static void getLADetailsTest(){
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Document_Checklist__c docChkRecord = [SELECT Id,Applicant__c,Document_Name__c FROM Document_Checklist__c  LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c  FROM Loan_Application_Approval__c];
        List<String> recordIds = new List<String>{loanapp[0].Id};
            User usr = [SELECT Id FROM User LIMIT 1];
        Assignment__c assignment = new Assignment__c();
        assignment.RecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByName().get('Ops - KYC').getRecordTypeId();
        assignment.Loan_Application__c = loanObj.Id;
        insert assignment;
        try{
            //AUSFPSDButtonsController.getLoanApplication(assignment.Id);
        AUSFPSDButtonsController.getLoanApplication(loanObj.Id);
            AUSFPSDButtonsController.getLoanApplication(null);
        //AUSFPSDButtonsController.handlePSDValidation(loanObj.Id);
        AUSFPSDButtonsController.getAllApplicants(loanObj.Id);
        }
        catch(Exception ex){
            
        }
    }
    
    @isTest
    public static void getLADetailsTest1(){
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        
        Assignment__c assignment = new Assignment__c();
        assignment.RecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByName().get('Ops - KYC').getRecordTypeId();
        assignment.Loan_Application__c = loanObj.Id;
        insert assignment;
        Loan_Application__c loanApp = new Loan_Application__c();
        insert loanApp;
        try{
            AUSFPSDButtonsController.getLoanApplication(assignment.Id);
            AUSFPSDButtonsController.getAllApplicants(loanApp.Id);
        }
        catch(Exception ex){
            
        }
    }

    @isTest
    public static void getLADetailsTestWithAssignmentRecord(){

        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Assignment__c assignmentRecord = new Assignment__c(Loan_Application__c = loanObj.Id);
        insert assignmentRecord;
        Document_Checklist__c docChkRecord = [SELECT Id,Applicant__c,Document_Name__c FROM Document_Checklist__c  LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c  FROM Loan_Application_Approval__c];
        List<String> recordIds = new List<String>{loanapp[0].Id};
            User usr = [SELECT Id FROM User LIMIT 1];
        try{
        AUSFPSDButtonsController.getLoanApplication(assignmentRecord.Id);
        //AUSFPSDButtonsController.handlePSDValidation(loanObj.Id);
        //AUSFPSDButtonsController.getAllApplicants(loanObj.Id);
        }
        catch(Exception ex){
            
        }
    }
    
    @isTest
    public static void applicantTest(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        Applicant__c applicantRecord = [SELECT id,First_Name__c,Loan__c,SF_Exposure_JSON__c,Loan__r.Loan_Amount__c,Loan__r.Product__c 
                                        FROM Applicant__c
                                        WHERE First_Name__c ='Vikash'];
        List<Document_Checklist__c> dcList = new List<Document_Checklist__c>();
        Document_Checklist__c checklsit = new Document_Checklist__c();
        checklsit.Applicant__c =applicantRecord.Id;
        checklsit.Document_Name__c ='Customers Signature';  
        dcList.add(checklsit) ;
        
        Document_Checklist__c checklsit1 = new Document_Checklist__c();
        checklsit1.Applicant__c =applicantRecord.Id;
        checklsit1.Document_Name__c ='Customers Signature';  
        dcList.add(checklsit1) ;
        insert dcList;
        
        ContentVersion newFile = new ContentVersion();
        newFile.PathOnClient = 'TestFile';
        newFile.Title = 'TestFile';
        newFile.VersionData = Blob.valueOf('sample content');
        insert newFile;
        
        
        
        //Query the contentDocumentId
        ContentVersion insertedFile = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:newFile.Id];
        
        //Link the file with the product
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        ContentDocumentLink linkedFile = new ContentDocumentLink(LinkedEntityId=checklsit.Id, ContentDocumentId=insertedFile.ContentDocumentId);
        cdlList.add(linkedFile);
        ContentDocumentLink linkedFile1 = new ContentDocumentLink(LinkedEntityId=checklsit1.Id, ContentDocumentId=insertedFile.ContentDocumentId);
        cdlList.add(linkedFile1);
        insert cdlList;
        String profileId = [SELECT Id, Name FROM Profile WHERE Name='Credit Manager' LIMIT 1].Id;
        
        Test.startTest();
        User usr = (User)TestFactory.createSObject(new User(
            firstName = 'test1Credit',
            lastName = 'test2',
            profileId = profileId,
            username = 'testausmall'+UserInfo.getOrganizationId()+'@testCredit.com',
            email = 'test@test.com',
            Branch_Code__c  = '1111'
        ),true);
        Field_Investigation__c fi = (Field_Investigation__c)TestFactory.createSObject((new Field_Investigation__c( 
            Name = 'Test FI',
            Loan_Application__c =loanInstance.Id,
            Applicant__c=applicantRecord.Id,
            FI_Status__c ='In Progress',
            Applicant_Type__c='Applicant',
            Credit_Manager__c = usr.Id)),true);
        
        
        AUSFPSDButtonsController.handlePSDValidation(loanInstance.Id);
        Account acc = [SELECT Id,RC_Balance_Limit_Count__c FROM Account WHERE Name = 'TestAccount' LIMIT 1];
        acc.RC_Limit_Count__c = 1;
        acc.RC_Limit_Used_Count__c = 0;
        acc.RC_Limit_Amount__c = 1000;
        acc.RC_Limit_Used_Amount__c = 100;
        update acc;
        AUSFPSDButtonsController.handlePSDValidation(loanInstance.Id);
        acc.RC_Limit_Count__c = 0;
        acc.RC_Limit_Used_Count__c = 0;
        acc.Ad_Hoc_Date__c = System.today().addDays(-1);
        update acc;
        AUSFPSDButtonsController.handlePSDValidation(loanInstance.Id);
        acc.RC_Limit_Count__c = 2;
        acc.RC_Limit_Used_Count__c = 0;
        update acc;
        loanInstance.Total_Loan_Amount__c = 1000;
        update loanInstance;
        AUSFPSDButtonsController.handlePSDValidation(loanInstance.Id);
        Loan_Application__c loanRecord = new Loan_Application__c(Id = loanInstance.Id);
        loanRecord.DO_Status__c = 'Issued';
        loanRecord.Sanction_Status__c = 'Issued';
        update loanRecord;
        AUSFPSDButtonsController.handlePSDValidation(loanInstance.Id);
        
        
        Test.stopTest();
        
    }

    /**
    * @description R1 remaining test conditions
    * @author Ajitesh | 12-13-2023 
    **/
   @isTest
    public static void handlePSDR1ValidationRemainingCheck(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c, Product__c
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        loanInstance.Repayment_Mode__c = 'E mandate without PDC';
        update loanInstance;
        Test.startTest();
        
        String error = AUSFPSDButtonsController.handlePSDValidation(loanInstance.Id);
        
        loanInstance.E_Mandate_Status__c = 'Accepted';
        update loanInstance;

        error = AUSFPSDButtonsController.handlePSDValidation(loanInstance.Id);
        
        Test.stopTest();
    }

    /**
    * @description R1 remaining test conditions check 2 to avoid limits
    * @author Ajitesh | 12-13-2023 
    **/
    @isTest
    public static void handlePSDR1ValidationRemaingCheck2(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c, Product__c
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];

        Test.startTest();
        loanInstance.Dpd_Checked_Date__c = System.today();
        loanInstance.isExposureChanged__c = false;
        update loanInstance;
        String error = AUSFPSDButtonsController.handlePSDValidation(loanInstance.Id);
        
        loanInstance.isExposureChanged__c = true;
        update loanInstance;
        error = AUSFPSDButtonsController.handlePSDValidation(loanInstance.Id);
        
        Test.stopTest();
    }


    /**
    * @description Test PSD Validation for TAR functionality
    * @author Ajitesh | 12-13-2023 
    **/
    @isTest
    public static void handlePSDTarValidationCheck(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c, Product__c
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        
        loanInstance.Stage__c = 'PSD';
        loanInstance.Total_Loan_Amount__c = 10;
        loanInstance.Product__c = '10501';
        update loanInstance;
        Test.startTest();
        String error = AUSFPSDButtonsController.handlePSDValidation(loanInstance.Id);
        System.assert(!error.containsAny('TAR'), 'TAR validation fired!');
        Test.stopTest();

    }

      @isTest
    public static void handleSendBackToROTest(){
        Test.startTest();
        Loan_Application__c loanObj = [SELECT Id,Stage__c FROM Loan_Application__c LIMIT 1];
        AUSFPSDButtonsController.handleSendBackToRO(loanObj.Id,'DDE');
        Test.stopTest();
        
    }
       @isTest
    public static void handleSendBackToROCatchTest(){
        Test.startTest();
        Loan_Application__c loanObj = [SELECT Id,Stage__c FROM Loan_Application__c LIMIT 1];
        try{
            AUSFPSDButtonsController.handleSendBackToRO(NULL,'DDE');
        }
        Catch(Exception ex){
            
        }
        Test.stopTest();
        
    }
           @isTest
    public static void checkIfPricingApprovalRequiredTest(){
        Test.startTest();
        Loan_Application__c loanObj = [SELECT Id,Stage__c FROM Loan_Application__c LIMIT 1];
        loanObj.Is_Charge_Changed__c = true;
        update loanObj;
        try{
            AUSFPSDButtonsController.checkIfPricingApprovalRequired(loanObj.Id);
        }
        Catch(Exception ex){
            
        }
        Test.stopTest();
        
    }

    
}