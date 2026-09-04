@isTest
public class AUSF_AssignmentRelatedRecordsCntlrTest {


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
                Total_Loan_Amount__c = 100
            ),true);
            Profile prof = [select Id,Name from profile where name like '%Credit%'];
            User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
                                                                lastName = 'test2',
                                                                profileId = prof.id,
                                                                username = 'test'+UserInfo.getOrganizationId()+'@test.com',
                                                                email = 'test@test.com',
                                                                Branch_Code__c  = '2103'
                                                               ),true);
            Profile standardProfile = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
            User testUser = (User)TestFactory.createSObject(new User(firstName = 'testUser1',
                                                                lastName = 'testUser2',
                                                                profileId = standardProfile.id,
                                                                username = 'testUser'+UserInfo.getOrganizationId()+'@test.com',
                                                                email = 'testUser1@test.com',
                                                                Branch_Code__c  = '2103'
                                                               ),true);
            
            list<Loan_Application_Approval__c> lstLoanAppApproval = new List<Loan_Application_Approval__c>();
            Loan_Application_Approval__c loanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
                Loan_Application__c  = loanAppl.Id, Approver__c = usr.id 
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
                Inactive__c = false,
                isVerified__c = true
            ),true);
            
            Sanction_Condition__c sanctionRecord = (Sanction_Condition__c)TestFactory.createSObject(new Sanction_Condition__c(
                Loan_Application__c  = loanAppl.Id,
                Status__c = 'Not Compliant'
            ),true);
            Query__c query= new Query__c( 
                                     Assigned_To__c=usr.Id, Remarks__c ='Test',Status__c ='New',Loan_Application__c  = loanAppl.Id);
        insert query;
            Deviation__c  dev = (Deviation__c)TestFactory.createSObject(new Deviation__c(
            Loan_Application__c  = loanAppl.id , Active__c  = true,Archived__c=false,Deviation_Type__c  ='Motor Insurance'
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



    @istest static void getAssignmentRelatedRecordsTest(){

        Sanction_Condition__c sanc = [SELECT Id FROM Sanction_Condition__c LIMIT 1];
        Loan_Application__c Loan = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Test.startTest();
        AUSF_AssignmentRelatedRecordsCntlr.getAssignmentRelatedRecords(Loan.id,'Sanction_Condition__c');
        AUSF_AssignmentRelatedRecordsCntlr.getAssignmentRelatedRecords(Loan.id,'Query__c');
        AUSF_AssignmentRelatedRecordsCntlr.getAssignmentRelatedRecords(Loan.id,'Deviation__c');
        AUSF_AssignmentRelatedRecordsCntlr.getAssignmentRelatedRecords(null,'Deviation__c');
        Test.stopTest();
        
    }

    @istest static void sendBackSanctionDataTest(){

        List<String> sancIds = new  List<String>();
        Sanction_Condition__c sanc = [SELECT Id FROM Sanction_Condition__c LIMIT 1];
        Loan_Application__c Loan = [SELECT Id FROM Loan_Application__c LIMIT 1];
        sancIds.add(sanc.id);


        Test.startTest();
        try{
        AUSF_AssignmentRelatedRecordsCntlr.sendBackSanctionData(sancIds,Loan.id,true,'Test123');
        }
        Catch(exception e){
            
        }
        Test.stopTest();
        
    }
    @isTest
    static void testSendBackSanctionData() {
        User testUser1 = [SELECT Id FROM User WHERE FirstName = 'Test1' AND LastName = 'Test2' LIMIT 1];
        User testUser2 = [SELECT Id FROM User WHERE FirstName = 'testUser1' AND LastName = 'testUser2' LIMIT 1];
        
        Id loanId = [SELECT Id FROM Loan_Application__c LIMIT 1].Id;
        Id raisedById = testUser2.Id;
        
        Sanction_Condition__c sanctionConditionNoShare = new Sanction_Condition__c(
            Loan_Application__c = loanId,
            Raised_By__c = raisedById
        );
        insert sanctionConditionNoShare;
        
        Sanction_Condition__c sanctionConditionWithShare = new Sanction_Condition__c(
            Loan_Application__c = loanId,
            Raised_By__c = raisedById
        );
        insert sanctionConditionWithShare;
        
        Sanction_Condition__Share existingShare = new Sanction_Condition__Share(
            ParentId = sanctionConditionWithShare.Id,
            UserOrGroupId = testUser1.Id,
            AccessLevel = 'Edit',
            RowCause = 'Manual'
        );
        insert existingShare;
        
        List<String> sanctionIds = new List<String>{ sanctionConditionNoShare.Id, sanctionConditionWithShare.Id };
            
            Test.startTest();
        AUSF_AssignmentRelatedRecordsCntlr.sendBackSanctionData(sanctionIds, loanId, false, 'Test Remarks');
        Test.stopTest();
    }





}