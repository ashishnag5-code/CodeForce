@isTest
public class AUSFCancellationApprovalAssignmentTest {
    @testSetup static void setup() {
        Account branchMaster = (Account)TestFactory.createSObject(new Account(
            Name ='Branch M',
            Account_Code__c='21034',
            Purchase_City__c='Jaipur',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Branch').getRecordTypeId()
        ),true);

        Profile prof = [select Id,Name from profile where name = 'Field Investigator'];
        User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
                                                            lastName = 'test2',
                                                            profileId = prof.id,
                                                            username = 'test'+UserInfo.getOrganizationId()+'@test.com',
                                                            email = 'test@test.com',
                                                            Branch_Code__c  = '21034'
                                                           ),true);
        Branch_Field_Investigation_Master__c branchFIMaster = (Branch_Field_Investigation_Master__c)TestFactory.createSObject(new Branch_Field_Investigation_Master__c(
            Branch_Name__c =branchMaster.Id,
            FI_Agent__c=usr.Id,
            Is_Active__c=true,
            Pin_Code__c='302026',
            Unique_Id__c='302026-0',
            RecordTypeId=Schema.SObjectType.Branch_Field_Investigation_Master__c.getRecordTypeInfosByDeveloperName().get('Two_Wheeler').getRecordTypeId()
        ),true);

        Branch_Field_Investigation_Master__c branchFIMaster2 = (Branch_Field_Investigation_Master__c)TestFactory.createSObject(new Branch_Field_Investigation_Master__c(
            Branch_Name__c =branchMaster.Id,
            FI_Agent__c=usr.Id,
            Is_Active__c=true,
            Pin_Code__c='302026',
            Unique_Id__c='302026-1',
            RecordTypeId=Schema.SObjectType.Branch_Field_Investigation_Master__c.getRecordTypeInfosByDeveloperName().get('Two_Wheeler').getRecordTypeId()
        ),true);

        AccountTeamMember accTeamMember = (AccountTeamMember)TestFactory.createSObject(new AccountTeamMember(
            TeamMemberRole='Branch Manager', 
            accountId = branchMaster.id, 
            Active__c = true, 
            UserId =usr.id,
            Zip_Code__c='302026',
            Cancellation_Level__c='Cancellation 1',
            Product__c='10301',
            Customer_Grade__c='Premium',
            Collateral__c='10110',
            Type_Of_Employment__c='Business'
        ),true);
        
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10301',
            Customer_Type__c='Non Individual',
            Stage__c ='QDE',
            EMI_Date__c = '10/3/2022',
            Customer_Grade__c ='Premium',
            Tenure__c = 10,
            Branch_Master__c = branchMaster.Id
        ),true);

        // Collateral Insertion
        Collateral__c  collateralNew = (Collateral__c )TestFactory.createSObject(new Collateral__c (
            Loan__c =loanAppl.Id,
            Vehicle_Number__c='TN12345567',
            Certified_Value__c='1234',
            Collateral_Name__c ='10110',
            Pincode__c = '302026',
            City__c = 'Jaipur',
            Registration_City__c = 'Jaipur',
            Engine_Category__c ='BS6',
            RecordTypeId=Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId()
        ),true);

        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            Customer_Grade__c ='Premium',
            Customer_Type__c ='Non Individual',
            KYC_Type__c='Driving License',
            AU_Employee__c = 'Yes',
            AU_Employment_status__c='Active',
            Date_of_Joining__c = System.today().addDays(-60),
            Education_qualification__c='GRADUATE',
            Type_Of_Employment__c='Business',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId()
        ),true);
    }

    static testmethod void testRoundRobingAssigFieldInvestigation(){
        String loanAppId = [Select Id from Loan_Application__c].Id;
        Map<String,String> mapofloanidtodoc = new Map<String,String>();
        mapofloanidtodoc.put(loanAppId,'Bank Statement');
        AUSFCancellationApprovalAssignment.getListOfCancellationApprovals(new List<String>{loanAppId},mapofloanidtodoc);
    }
    
    static testmethod void testRoundRobingAssigFieldInvestigation2(){
        String loanAppId = [Select Id from Loan_Application__c].Id;
        Account branchMaster = [Select Id from Account];
        User usr = [Select Id from User where email = 'test@test.com'and Branch_Code__c  = '21034'];
        AccountTeamMember accTeamMember2 = (AccountTeamMember)TestFactory.createSObject(new AccountTeamMember(
            TeamMemberRole='Branch Manager', 
            accountId = branchMaster.id, 
            Active__c = true, 
            UserId =usr.id,
            Zip_Code__c='302026',
            Cancellation_Level__c='Cancellation 2',
            Product__c='10301',
            Customer_Grade__c='Premium',
            Collateral__c='10110',
            Type_Of_Employment__c='Business'
        ),true);
        Map<String,String> mapofloanidtodoc = new Map<String,String>();
        mapofloanidtodoc.put(loanAppId,'Bank Statement');
        AUSFCancellationApprovalAssignment.getListOfCancellationApprovals(new List<String>{loanAppId},mapofloanidtodoc);
    }
    
    static testmethod void testRoundRobingAssigFieldInvestigation3(){
        String loanAppId = [Select Id from Loan_Application__c].Id;
        Account branchMaster = [Select Id from Account];
        User usr = [Select Id from User where email = 'test@test.com'and Branch_Code__c  = '21034'];
        AccountTeamMember accTeamMember3 = (AccountTeamMember)TestFactory.createSObject(new AccountTeamMember(
            TeamMemberRole='Branch Manager', 
            accountId = branchMaster.id, 
            Active__c = true, 
            UserId =usr.id,
            Zip_Code__c='302026',
            Cancellation_Level__c='Cancellation 3',
            Product__c='10301',
            Customer_Grade__c='Premium',
            Collateral__c='10110',
            Type_Of_Employment__c='Business'
        ),true);
        Map<String,String> mapofloanidtodoc = new Map<String,String>();
        mapofloanidtodoc.put(loanAppId,'Bank Statement');
        AUSFCancellationApprovalAssignment.getListOfCancellationApprovals(new List<String>{loanAppId},mapofloanidtodoc);
    }
}