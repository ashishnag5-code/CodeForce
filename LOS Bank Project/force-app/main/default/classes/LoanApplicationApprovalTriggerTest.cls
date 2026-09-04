/*****
 * Class Name: LoanApplicationApprovalTriggerTest
 * Description: 
 * Test Class Name: LoanApplicationApprovalTriggerHandler AND LoanApplicationApprovalTriggerHelper
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Dec-19-2023          -   Mohit M.            -   SFAU-5663 - For STP cases credit ST condition should be mandatary before credit approval.
 */
@isTest
public class LoanApplicationApprovalTriggerTest {
    @testSetup static void setup() {
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='Credit',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10
        ),true);
        Profile prof = [select Id,Name from profile where name like '%Credit%'];
        User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
                                                            lastName = 'test2',
                                                            profileId = prof.id,
                                                            username = 'test'+UserInfo.getOrganizationId()+'@test.com',
                                                            email = 'test@test.com',
                                                            Branch_Code__c  = '2103'
                                                           ),true);
        User usr1 = (User)TestFactory.createSObject(new User(firstName = 'test',
                                                            lastName = 'name',
                                                            profileId = prof.id,
                                                            username = 'testname'+UserInfo.getOrganizationId()+'@test.com',
                                                            email = 'testname@test.com',
                                                            Branch_Code__c  = '2103',
                                                             DelegatedApproverId = usr.Id
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
         Assignment__c  assignmentRec = (Assignment__c)TestFactory.createSObject(new Assignment__c(
            Loan_Application__c  = loanAppl.Id,
            Name = 'Test Assignment',
            RecordTypeId=Schema.SObjectType.Assignment__c.getRecordTypeInfosByName().get('Credit - BSR/ PSL').getRecordTypeId()
        ),true);
    } 
 
    @isTest
    public static void createLAADetailsT(){
            Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c limit 1];
             User usr = [SELECT Id from User limit 1];
            //list<Loan_Application_Approval__c> lstLoanAppApproval = new List<Loan_Application_Approval__c>();
            Loan_Application_Approval__c loanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
                Loan_Application__c  = loanAppl.Id,  Approval_Type__c = 'Credit' , Approver__c = UserInfo.getUserId(),
                Archived__c = false, BSR_PSL__c=true
            ),false);
            Loan_Application_Approval__c loanAppApproval1 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
                Loan_Application__c  = loanAppl.Id, Approver__c = usr.id 
            ),false);
            insert loanAppApproval;
            Test.startTest();
            loanAppApproval.Approval_Status__c = 'Approved';
            loanAppApproval.Is_Assigned_Approver__c = false;
            loanAppApproval.Is_Rework__c = false;
            update loanAppApproval;
            loanAppl.RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId() ;
            update loanAppl;
            Test.stopTest();
            /*Test.startTest();
            loanAppApproval.Approval_Status__c = 'Pending';
            loanAppApproval.Is_Assigned_Approver__c = true;
            loanAppApproval.Is_Rework__c = true;
            update loanAppApproval;
            loanAppl.RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Four Wheeler').getRecordTypeId() ;
            update loanAppl;
            update loanAppApproval;
            loanAppApproval.Approval_Status__c = 'Rejected';
             update loanAppApproval;
            loanAppApproval.Is_Assigned_Approver__c = true;
            update loanAppApproval;
            //Test.stopTest();*/
        
    }
    /*
     @isTest
    public static void createLAADetailsT1(){
            Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c limit 1];
            User usr = [SELECT Id from User limit 1];
            //list<Loan_Application_Approval__c> lstLoanAppApproval = new List<Loan_Application_Approval__c>();
            Loan_Application_Approval__c loanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
                Loan_Application__c  = loanAppl.Id,  Approval_Type__c = 'Credit' , Approver__c = UserInfo.getUserId(),
                Archived__c = false, BSR_PSL__c=true
            ),false);
            Loan_Application_Approval__c loanAppApproval1 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
                Loan_Application__c  = loanAppl.Id, Approver__c = usr.id 
            ),false);
            insert loanAppApproval;
            /*Test.startTest();
            loanAppApproval.Approval_Status__c = 'Approved';
            loanAppApproval.Is_Assigned_Approver__c = false;
            loanAppApproval.Is_Rework__c = false;
            update loanAppApproval;
            loanAppl.RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId() ;
            update loanAppl;
            Test.stopTest();*
            Test.startTest();
            loanAppApproval.Approval_Status__c = 'Pending';
            loanAppApproval.Is_Assigned_Approver__c = true;
            loanAppApproval.Is_Rework__c = true;
            update loanAppApproval;
            loanAppl.RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Four Wheeler').getRecordTypeId() ;
            update loanAppl;
            update loanAppApproval;
            loanAppApproval.Approval_Status__c = 'Rejected';
             update loanAppApproval;
            loanAppApproval.Is_Assigned_Approver__c = true;
            update loanAppApproval;
            Test.stopTest();
        
    }
    */

     @isTest
    public static void updateLAADetailsT(){
            Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c limit 1];
            Profile prof = [select Id,Name from profile where name like '%Credit%'];
            User usr = [SELECT Id from User where DelegatedApproverId != null LIMIT 1];
        
            Test.startTest();
            List<Loan_Application_Approval__c> lstLAApproval = new List<Loan_Application_Approval__c>();
            Loan_Application_Approval__c loanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
                Loan_Application__c  = loanAppl.Id,  Approval_Type__c = 'Credit' , Approver__c = usr.Id,
                Archived__c = false, BSR_PSL__c=true, Approval_Status__c = 'Pending'
            ),false);
            lstLAApproval.add(loanAppApproval);
        
            Loan_Application_Approval__c loanAppApproval1 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
                Loan_Application__c  = loanAppl.Id,  Approval_Type__c = 'Credit' , Approver__c = usr.Id,
                Archived__c = false, BSR_PSL__c=true, Approval_Status__c = 'Pending'
            ),false);
            lstLAApproval.add(loanAppApproval1);
            insert lstLAApproval;
        
            loanAppl.RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId() ;
            update loanAppl;
            loanAppApproval.Approval_Status__c = 'Approved';
            loanAppApproval.Approval_Type__c = 'Pricing';
            update loanAppApproval;
        Test.stopTest();
    }
    
    @isTest
    public static void updateLA2DetailsT(){
        Test.startTest();
            Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c limit 1];
            User usr = [SELECT Id from User limit 1];
            Loan_Application_Approval__c loanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
                Loan_Application__c  = loanAppl.Id,  Approval_Type__c = 'Credit' , Approver__c = UserInfo.getUserId(),Type__c= 'Base',
                Archived__c = false, BSR_PSL__c=true
            ),false);
            insert loanAppApproval;
            loanAppl.RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Four Wheeler').getRecordTypeId() ;
            update loanAppl;
            loanAppApproval.Approval_Status__c = 'Approved';
            loanAppApproval.Approval_Type__c = 'Pricing';
            update loanAppApproval;
            LoanApplicationApprovalTriggerHandler.updateLoanApprovals(new List<Id>{loanAppApproval.id});
           // LoanApplicationApprovalTriggerHelper.submitForApproval(new Set<String>{loanAppApproval.id});
            //LoanApplicationApprovalTriggerHelper.markLoanApplicationForReWork(new Set<id>{loanAppl.id});
        Test.stopTest();
        
    }
    
    @isTest
    public static void updateNewTest(){
        Test.startTest();
        Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c limit 1];
        User usr = [SELECT Id from User limit 1];
        Loan_Application_Approval__c loanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id,  Approval_Type__c = 'Credit' , Approver__c = UserInfo.getUserId(),Type__c= 'Base',
            Archived__c = false, BSR_PSL__c=true, Approval_Status__c ='Pending'
        ),false);
        insert loanAppApproval;
        
        loanAppl.RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Four Wheeler').getRecordTypeId() ;
        update loanAppl;
        
        LoanApplicationApprovalTriggerHelper.updateLoanApplications(new Set<String>{loanAppl.Id}, 'Credit Approved', 'Credit', 'Credit');
        // LoanApplicationApprovalTriggerHelper.submitForApproval(new Set<String>{loanAppApproval.id});
        //LoanApplicationApprovalTriggerHelper.markLoanApplicationForReWork(new Set<id>{loanAppl.id});
        Test.stopTest();
        
    }
    @IsTest
    public static void updateNewTest2(){
        Loan_Application__c loanAppl = [SELECT Id from Loan_Application__c limit 1];
        test.startTest();
        LoanApplicationApprovalTriggerHelper.rejectLoanApplications(new Set<String>{loanAppl.Id});
        Test.stoptest();
    }
    
    
    
    
    


}