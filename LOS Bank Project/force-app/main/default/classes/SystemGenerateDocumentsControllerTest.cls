/*******************************************************************************************
* @Name         SystemGenerateDocumentsControllerTest
* @Author       Yash Shukla
* @Description   Test Controller class for Generating the PDF for CHecklist documents and sending the Notification
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer           Date               Description
*-------------------------------------------------------------------------------------------
*  1.0             Yash Shukla        31/10/2023         Initial Creation 
*******************************************************************************************/
@isTest
public class SystemGenerateDocumentsControllerTest {
    
    @testsetup static void setup(){
        
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        
        Account accInstance = (Account)TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            Branch_Queue__c=grp.Id
        ),true);
        
        AccountTeamMember atm = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
            AccountId =accInstance.Id,
            UserId=UserInfo.getUserId(),
            TeamMemberRole = 'COM',
            RBM_Approval_Level__c  = 'DO 1'
        ),true);   
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10', 
            Tenure__c = 10,
            Branch_Master__c = accInstance.Id,
            RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId()
        ),true);
        
        Document_Master__c  docMaster = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name          = 'AUWheels0010',
            Document_Name__c = 'Delivery Order'
        ),true);
        
        Document_Checklist__c   docChecklst = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMaster.Id,
            Loan_Application__c= loanAppl.Id,
            Document_Name__c = 'Delivery Order'
        ),true);
        
        Integration_Master__c intmassearch1 = (Integration_Master__c)TestFactory.createSObject(new Integration_Master__c(
            Name = 'DocumentCompressService ',
            Active__c = true,
            Timeout__c = '120000',
            End_Point_URL__c = 'https://api.aubankuat.in/sfdc/DocumentCompressService/Compress',
            HTTP_Method__c = 'POST',
            API_Key__c = '12345',
            Apiuser__c = 'SFDC'
            
        ),true);
        
        Collateral__c testCollateralRec = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId(),
            Loan__c = loanAppl.Id,
            Collateral_Type__c = 'Existing ',
            Registration_Number__c = '123456Test',
            Ex_Showroom_Price__c = 100,
            Discount__c = 10,
            Net_of_Discount_Price__c = 10,
            Final_Cost__c = 10,
            LTV_offered_On_final_cost__c = 10,
            Apportioned_Loan_Amount__c = 10,
            RTO_Taxes__c = 100.00,
            Insurance__c = 1000.00
        ),true);
        
    }
    
    @IsTest
    static void testSystemGenerateDocumentLWCMethod(){
        String loanId = [SELECT Id from Loan_Application__c LIMIT 1].Id;
        Test.startTest();
        SystemGenerateDocumentsController.systemGenerateDocumentLWCMethod('Delivery Order',loanId);
        Test.stopTest();
    }
    
    @IsTest
    static void testRejectApplication(){
        String loanId = [SELECT Id from Loan_Application__c LIMIT 1].Id;
        Document_Master__c  docMasterReject = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name          = 'AUWheels0011',
            Document_Name__c = 'Delivery Order'
        ),true);
        
        Document_Checklist__c   docListReject = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMasterReject.Id,
            Loan_Application__c= loanId,
            Document_Name__c = 'Reject letter'
        ),true);
        Test.startTest();
        SystemGenerateDocumentsController.rejectApplication('FI Related','Negative FI','Other Reason',loanId,false);
        try{
            SystemGenerateDocumentsController.rejectApplication('FI Related','Negative FI','Other Reason',loanId,true);
        }
        Catch(Exception e){
            system.assert(e.getMessage() != null);
        }
        
        Test.stopTest();
    }
    
    @IsTest
    static void testGenerateCancelApprovalRecords(){
        String loanId = [SELECT Id from Loan_Application__c LIMIT 1].Id;
        Document_Master__c  docMasterSancReject = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name          = 'AUWheels0011',
            Document_Name__c = 'Sanction Cancelled letter'
        ),true);
        
        Document_Checklist__c   docListSancReject = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMasterSancReject.Id,
            Loan_Application__c= loanId,
            Document_Name__c = 'Sanction Cancelled letter'
        ),true);
        
        Document_Master__c  docMasterDOReject = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name          = 'AUWheels0011',
            Document_Name__c = 'DO Cancelled letter'
        ),true);
        
        Document_Checklist__c   docListDOReject = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMasterSancReject.Id,
            Loan_Application__c= loanId,
            Document_Name__c = 'DO Cancelled letter'
        ),true);
        Test.startTest();
        SystemGenerateDocumentsController.generateCancelApprovalRecords(loanId, 'Sanction Cancelled letter');
        SystemGenerateDocumentsController.generateCancelApprovalRecords(loanId, 'DO Cancelled letter');
        SystemGenerateDocumentsController.generateCancelApprovalRecords('', 'DO Cancelled letter');
        Test.stopTest();
        
        
    }
    
    @IsTest
    static void testGenerateDOSanctionApprovalRecords(){
        Test.startTest();
        String loanId = [SELECT Id from Loan_Application__c LIMIT 1].Id;
        Document_Master__c  docMasterSancReject = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name          = 'AUWheels0011',
            Document_Name__c = 'Sanction Cancelled letter'
        ),true);
        
        Document_Checklist__c   docListSancReject = (Document_Checklist__c) TestFactory.createSObject(new Document_Checklist__c  (
            Document_Master__c = docMasterSancReject.Id,
            Loan_Application__c= loanId,
            Document_Name__c = 'Sanction Cancelled letter'
        ),true);
        
        Document_Master__c  docMasterDOReject = (Document_Master__c ) TestFactory.createSObject(new Document_Master__c (
            Name          = 'AUWheels0011',
            Document_Name__c = 'DO Cancelled letter'
        ),true);
        SystemGenerateDocumentsController.generateDOSanctionApprovalRecords(loanId, 'Sanction Cancelled letter','Test Remarkds',true);
        SystemGenerateDocumentsController.generateDOSanctionApprovalRecords(loanId, 'DO Cancelled letter','Test Remarkds',true);
        SystemGenerateDocumentsController.generateDOSanctionApprovalRecords('', 'DO Cancelled letter','Test Remarkds',true);
        Test.stopTest();
    }
    
    @IsTest
    static void testGetDocumentApprovalRecords(){
        Test.startTest();
        String loanId = [SELECT Id from Loan_Application__c LIMIT 1].Id;
        Loan_Application_Approval__c loanAppApproval1 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanId,  Approval_Type__c = 'Cancellation' , Approver__c = UserInfo.getUserId(), Type__c = 'Base',
            Archived__c = false, Document_Name__c = 'Sanction letter'
        ),true);
        List<SystemGenerateDocumentsController.UserAssociatedApprovalWrapper> rec = SystemGenerateDocumentsController.getDocumentApprovalRecords(loanId);
        List<SystemGenerateDocumentsController.UserApprovalRecordWrapper> rec2 = SystemGenerateDocumentsController.getUserAssociatedApprovals(loanId);
        Test.stopTest();
        
    }
    
    @IsTest
    static void testApproveCancellationRecordsAssigned(){
        Test.startTest();
        String loanId = [SELECT Id from Loan_Application__c LIMIT 1].Id;
        Loan_Application_Approval__c loanAppApproval1 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanId,  Approval_Type__c = 'Cancellation' , Approver__c = UserInfo.getUserId(), Type__c = 'Base',
            Archived__c = false, Document_Name__c = 'Sanction letter'
        ),true);
        SystemGenerateDocumentsController.ApprovalWrapper rec = SystemGenerateDocumentsController.approveCancellationRecordsAssigned(loanId, 'Sanction letter','Test remarks');
        SystemGenerateDocumentsController.ApprovalWrapper rec1 = SystemGenerateDocumentsController.approveCancellationRecordsAssigned('', 'Sanction letter','Test remarks');
        Test.stopTest();
        
    }
    
    @IsTest
    static void testApproveSystemGeneratedDocuments(){
        Test.startTest();
        String loanId = [SELECT Id from Loan_Application__c LIMIT 1].Id;
        Loan_Application_Approval__c loanAppApproval1 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanId,  Approval_Type__c = 'RBMTatkal' , Approver__c = UserInfo.getUserId(), Type__c = 'Base',
            Archived__c = false, Document_Name__c = 'Sanction letter'
        ),true);
        SystemGenerateDocumentsController.ApprovalWrapper rec = SystemGenerateDocumentsController.approveSystemGeneratedDocuments(loanId, 'Sanction letter','Test remarks','LSChargeApproval');
        SystemGenerateDocumentsController.ApprovalWrapper rec2 = SystemGenerateDocumentsController.approveSystemGeneratedDocuments(loanId, 'Sanction letter','Test remarks','SystemGeneratedDocs');
        SystemGenerateDocumentsController.ApprovalWrapper rec3 = SystemGenerateDocumentsController.approveSystemGeneratedDocuments('', 'Sanction letter','Test remarks','SystemGeneratedDocs');
        Test.stopTest();
        
    }
    
    @IsTest
    static void testRejectApprovalRecords(){
        Test.startTest();
        String loanId = [SELECT Id from Loan_Application__c LIMIT 1].Id;
        Loan_Application_Approval__c loanAppApproval1 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanId,  Approval_Type__c = 'RBMTatkal' , Approver__c = UserInfo.getUserId(), Type__c = 'Base',
            Archived__c = false, Document_Name__c = 'Sanction letter'
        ),true);
        SystemGenerateDocumentsController.rejectApprovalRecords(loanId, new List<String>{'Sanction letter'},'Test remarks');
        Test.stopTest();
        
    }
    
    @IsTest
    static void testWrapper(){
        Test.startTest();
        SystemGenerateDocumentsController.ApprovalWrapper rec= new SystemGenerateDocumentsController.ApprovalWrapper();
        Test.stopTest();
    }

}