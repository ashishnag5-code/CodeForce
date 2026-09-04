@isTest
public class LOSPDDApprovalTest {
    @testSetup static void setup() {
        //Loan Application Insertion
        
        
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        
        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
           	Account_Code__c='2103',
           	Branch_Queue__c=grp.Id
        ),true);
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='DDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Branch_Master__c = accInstance.Id
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
            Loan_Application__c  = loanAppl.Id, Approver__c = usr.id , Approval_Status__c ='Pending' , Is_Assigned_Approver__c = true
        ),false);
        Loan_Application_Approval__c loanAppApproval1 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id, Approver__c = usr.id , Approval_Status__c ='Pending' , Is_Assigned_Approver__c = true
        ),false);
        lstLoanAppApproval.add(loanAppApproval);
        insert lstLoanAppApproval;
         
        Document_Checklist__c docChkRecord = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id
        ),false);
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
         Document_Checklist__c docChkRecord1 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Applicant__c    = appl.Id
        ),true);
         
         AccountTeamMember accTeamMember = (AccountTeamMember)TestFactory.createSObject(new AccountTeamMember(
            TeamMemberRole='Branch Manager', accountId = accInstance.id, Active__c = true, UserId =usr.id
        ),true);
        
        Collateral__c objCollateral=(Collateral__c)TestFactory.createSObject(new Collateral__c(
                			loan__c=loanAppl.Id,Vehicle_Usage__c='Personal'),true); 
        
        Deferral_Register__c deff = (Deferral_Register__c)TestFactory.createSObject(new Deferral_Register__c(
            Confirmation_Recieved__c='No', Collateral__c=objCollateral.Id
        ),true);
        
    } 
 
    @isTest
    public static void getLADetailsTest(){
        LOSPDDApprovalCtrl objLoanApp = new LOSPDDApprovalCtrl();
        Loan_Application__c loan = [SELECT id FROM Loan_Application__c limit 1];
        AccountTeamMember accTeamMember = [SELECT ID FROM AccountTeamMember LIMIT 1];
        Deferral_Register__c deff = [SELECT ID,Collateral__c,Confirmation_Recieved__c FROM Deferral_Register__c LIMIT 1];
         //deff.Confirmation_Recieved__c = 'Yes';
        //update deff;
        
        //LOSPDDApprovalCtrl.requestId = deff.Id;
        
        
        PageReference pageRef = Page.losRTOApproval ;
        pageRef.getParameters().put('reqId',String.valueOf(deff.Id));
        Test.setCurrentPage(pageRef);
        LOSPDDApprovalCtrl.getApplicants(loan.id);
        objLoanApp.doInit();
        objLoanApp.acceptDocuments();
        LOSPDDApprovalCtrl.getLoanApplicationDetails(loan.Id);
    }
}