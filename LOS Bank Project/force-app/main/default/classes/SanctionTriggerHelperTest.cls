@isTest
public class SanctionTriggerHelperTest {

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
                                                                IsActive = true,
                                                                username = 'test'+UserInfo.getOrganizationId()+'@test.com',
                                                                email = 'test@test.com',
                                                                Branch_Code__c  = '2103'
                                                               ),true);
            list<Loan_Application_Approval__c> lstLoanAppApproval = new List<Loan_Application_Approval__c>();
            Loan_Application_Approval__c loanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
                Loan_Application__c  = loanAppl.Id, Approver__c = usr.id, Archived__c = FALSE, Approval_Status__c = 'Pending'
            ),false);
            Loan_Application_Approval__c loanAppApproval1 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
                Loan_Application__c  = loanAppl.Id, Approver__c = usr.id, Archived__c = FALSE, Approval_Status__c = 'Pending'
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
            
            /*
            Sanction_Condition__c sanctionRecord = (Sanction_Condition__c)TestFactory.createSObject(new Sanction_Condition__c(
                Loan_Application__c  = loanAppl.Id,
                Status__c = 'Not Compliant'
            ),true);

*/
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

  /*  @istest static void handleupdatetest(){
        
        Profile prof = [select Id,Name from profile where name like '%Credit%'];
        Loan_Application__c loanRecord = [SELECT Id FROm Loan_Application__c LIMIT 1];
        loanRecord.Stage__c = 'Credit';
        update loanRecord;
        
        

        User usrRec = new User();
        usrRec = [SELECT Id FROM User Where ProfileId = :prof.Id and IsActive = true LIMIT 1];
        System.runAs(usrRec){
             Loan_Application_Approval__c loanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanRecord.Id,  Approval_Type__c = 'Credit' , Approver__c = usrRec.id,
            Archived__c = false, Approver_Level__c = 'L1', Type__c = 'Base'
        ),false);
            
            Sanction_Condition__c sanctionRecord = (Sanction_Condition__c)TestFactory.createSObject(new Sanction_Condition__c(
                Loan_Application__c  = loanRecord.Id,
                Status__c = 'Not Compliant',
                Remark__c = 'Test Remarks',
                Remarks__c = 'test remarks'
            ),true);
            Test.startTest();
            sanctionRecord.Status__c = 'Compliant';
            update sanctionRecord;
            Test.stopTest();
            
        }

        /*Test.startTest();
        Sanction_Condition__c sanc = [SELECT Id FROM Sanction_Condition__c LIMIT 1];
        sanc.Status__c = 'Compliant';
        Test.stopTest();
        
    }*/
    
    //5 JAN
   	 @isTest static void verifyApplicationForward2W(){
        Test.startTest();
        Profile prof = [select Id,Name from profile where name like '%Credit%'];
        User usr = (User)TestFactory.createSObject(new User(firstName = 'credapp1',
                                                            lastName = 'test2',
                                                            profileId = prof.id,
                                                            username = 'test'+UserInfo.getOrganizationId()+'@sstest.com',
                                                            email = 'test@test.com',
                                                            Branch_Code__c  = '2103',
                                                            Authority_Level__c = 'L2'
                                                           ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='Credit',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            BRE_Decision__c = 'STP',
            BRE_Approval_Level__c = 'L1',
            Valuation_Completion_Date__c = Date.today().addDays(-40),
            FI_Completion_Date__c = Date.today().addDays(-40),
            RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId()
        ),true);
        list<Loan_Application_Approval__c> lstLoanAppApproval = new List<Loan_Application_Approval__c>();
        Loan_Application_Approval__c loanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id,  Approval_Type__c = 'Credit' , Approver__c = usr.id,
            Archived__c = false, Approver_Level__c = 'L1', Type__c = 'Base'
        ),false);
        Loan_Application_Approval__c loanAppApproval1 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id, Approver__c = usr.id , Approval_Type__c = 'Credit', Approver_Level__c = 'L2', Type__c = 'Middle'
        ),false);
        Loan_Application_Approval__c loanAppApproval2 = (Loan_Application_Approval__c)TestFactory.createSObject(
            new Loan_Application_Approval__c(
                Loan_Application__c  = loanAppl.Id,
                Assigned_to_Queue__c = true,
                Approver__c = usr.id,
                Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING,
                Approver_Level__c = 'L3', Approval_Type__c = 'Credit', Type__c = 'Highest'
            ),false);
        
        
        lstLoanAppApproval.addAll(new Loan_Application_Approval__c[]{ loanAppApproval, loanAppApproval1, loanAppApproval2 });
        insert lstLoanAppApproval;
      	Id loanId = loanAppl.Id;
       	Id cmUserId = [ SELECT Approver__c FROM Loan_Application_Approval__c WHERE Loan_Application__c =: loanId AND Approval_Type__c =: GlobalConstants.APPROVAL_TYPE_CREDIT LIMIT 1 ].Approver__c;
        System.runAs( new User( Id = cmUserId )){
            Sanction_Condition__c sanctionRecord = (Sanction_Condition__c)TestFactory.createSObject(new Sanction_Condition__c(
                Loan_Application__c  = loanAppl.Id,
                Status__c = 'Not Compliant',
                Remark__c = 'Test Remarks',
                Remarks__c = 'test remarks'
            ),true);
           
            sanctionRecord.Status__c = 'Compliant';
            update sanctionRecord;
            Test.stopTest();
            //Utility.assignApprovalsForRework(lstLoanAppApproval);
        }

    }
  
    
   /* @istest static void handleupdatetest1(){
        
        Profile prof = [select Id,Name from profile where name like '%Credit%'];
        Loan_Application__c loanRecord = [SELECT Id FROm Loan_Application__c LIMIT 1];
        loanRecord.Stage__c = 'Credit';
        update loanRecord;

        User usrRec = new User();
        usrRec = [SELECT Id FROM User Where ProfileId = :prof.Id and IsActive = true LIMIT 1];
        System.runAs(usrRec){
            Sanction_Condition__c sanctionRecord = (Sanction_Condition__c)TestFactory.createSObject(new Sanction_Condition__c(
                Loan_Application__c  = loanRecord.Id,
                Status__c = 'Compliant',
                Remark__c = 'Test Remarks',
                Remarks__c = 'test remarks'
            ),true);
            Test.startTest();
            sanctionRecord.Status__c = 'Not Compliant';
            //update sanctionRecord;
            Test.stopTest();
            
        }

        /*Test.startTest();
        Sanction_Condition__c sanc = [SELECT Id FROM Sanction_Condition__c LIMIT 1];
        sanc.Status__c = 'Compliant';
        Test.stopTest();
        
    }*/

    /*
    @istest static void handleupdatetest1(){

        Test.startTest();
        Sanction_Condition__c sanc = [SELECT Id FROM Sanction_Condition__c LIMIT 1];
        sanc.Status__c ='Not Compliant';
        Test.stopTest();
        
    }*/

}