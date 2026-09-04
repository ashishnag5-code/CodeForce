/*****
 * Class Name: AUSFRBMApprovalAssignmentTest
 * Description: AUSFRBMApprovalAssignment
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Dec-04-2023          -   Mohit M.            -   
 */
@isTest
public class AUSFRBMApprovalAssignmentTest {

    @testSetup static void setup() 
    {
        Profile adminProfile = [select Id,Name from profile where name = 'System Administrator'];
        User usrAdmin = (User)TestFactory.createSObject(new User(firstName = 'admin1',
                                                            lastName = 'admin2',
                                                            profileId = adminProfile.id,
                                                            username = 'admin1'+UserInfo.getOrganizationId()+'@test.com',
                                                            email = 'admin1@test.com',
                                                            Branch_Code__c  = '2103'
                                                           ),true);

        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        // Create test data
        Trigger_Deactivation_Settings__c trigSetup = new Trigger_Deactivation_Settings__c ();
        trigSetup.AccountTeamMember_Trigger__c = true;
        trigSetup.SetupOwnerId = UserInfo.getUserId();
        insert trigSetup;
        
        Account accInstance = (Account)TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            Branch_Queue__c=grp.Id
        ),true);
        
        Account regionAccount = new Account();
        regionAccount.Name = 'Region Account';
        regionAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Region').getRecordTypeId();
        insert regionAccount;

        System.runAs(usrAdmin) {
            Profile prof = [select Id,Name from profile where name like '%Credit%'];
            User usr = (User)TestFactory.createSObject(new User(firstName = 'credapp1',
                                                                lastName = 'test2',
                                                                profileId = prof.id,
                                                                username = 'test'+UserInfo.getOrganizationId()+'@test.com',
                                                                email = 'test@test.com',
                                                                Branch_Code__c  = '2103',
                                                                Authority_Level__c = 'L2'
                                                               ),true);
            User higherAuthUser = (User)TestFactory.createSObject(new User(firstName = 'credapp2',
                lastName = 'testL7',
                profileId = prof.id,
                username = 'testl7'+UserInfo.getOrganizationId()+'@test.com',
                email = 'testl7@test.com',
                Branch_Code__c  = '2103',
                Authority_Level__c = 'L5'
            ),true);
            
            PermissionSetAssignment[] psa = new PermissionSetAssignment[0];
            PermissionSet psgCredit = [Select Id from PermissionSet where Name = 'Credit_User'];
            PermissionSetAssignment cm1 = new PermissionSetAssignment(
            PermissionSetId = psgCredit.Id,
            AssigneeId = usr.Id);

            PermissionSetAssignment cm2 = new PermissionSetAssignment(
            PermissionSetId = psgCredit.Id,
            AssigneeId = higherAuthUser.Id);

            psa.add(cm1);
            psa.add(cm2);

            insert psa;

            Profile profPricing = [select Id,Name from profile where name like 'Sales Manager'];
            User usr2 = (User)TestFactory.createSObject(new User(firstName = 'priceapp1',
                                                                lastName = 'test2',
                                                                profileId = profPricing.id,
                                                                username = 'testprice'+UserInfo.getOrganizationId()+'@test.com',
                                                                email = 'test@test.com',
                                                                Branch_Code__c  = '2103'
                                                               ),true);
            
             
            PermissionSet psPricing = [Select Id from PermissionSet where Name = 'Sales_Manager_User'];
            PermissionSetAssignment assignment1 = new PermissionSetAssignment(
                PermissionSetId = psPricing.Id,
                AssigneeId = usr2.Id
            );
            insert assignment1;
            
        }
        
        User usr = [Select Id from User where Profile.Name like '%Credit%' and FirstName = 'credapp1' and LastName = 'test2'  limit 1];
        User higherAuthUser = [Select Id from User where Profile.Name like '%Credit%' and Authority_Level__c = 'L5' AND LastName = 'testL7' limit 1];
        User usr2 = [Select Id from User where Profile.Name like 'Sales Manager' and FirstName = 'priceapp1' and LastName = 'test2'  limit 1];

        List<AccountTeamMember> accountTeams = new List<AccountTeamMember>();
        AccountTeamMember aTM_1 = new AccountTeamMember();
        aTM_1.accountId = accInstance.Id;
        aTM_1.Active__c = true;
        aTM_1.Type_of_Employment__c = 'Farmer';
        aTM_1.Customer_Grade__c = 'IB';
        aTM_1.TeamMemberRole = 'Branch Manager';
        aTM_1.Approver_Level__c = 'P2';
        aTM_1.Product__c = '10201';
        aTM_1.Collateral__c = '10102';
        aTM_1.UserId = UserInfo.getUserId();
        //aTM_1.RBM_Approval_Level__c = 'DO 1';
        accountTeams.add(aTM_1);
        
        AccountTeamMember aTM_2 = new AccountTeamMember();
        aTM_2.accountId = accInstance.Id;
        aTM_2.Active__c = true;
        aTM_2.Type_of_Employment__c = 'Farmer';
        aTM_2.Customer_Grade__c = 'IB';
        aTM_2.TeamMemberRole = 'Region Head (RBM)';
        aTM_2.Approver_Level__c = 'P3';
        aTM_2.Product__c = '10201';
        aTM_2.Collateral__c = '10102';
        aTM_2.UserId = usr2.Id;
        aTM_2.RBM_Approval_Level__c = 'DO 1';
        accountTeams.add(aTM_2);
        insert accountTeams;
       
        List<Loan_Application__c> loanList = new List<Loan_Application__c>();
        RecordType rd=[select id from RecordType where name='Two Wheeler' and  sobjectType='Loan_Application__c'];
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true,
            Stage__c='QDE',
            Final_Exposure__c =10,
            RecordTypeId=rd.Id ,
            Branch_Master__c = accInstance.Id
        ),false);
        loanList.add(loanAppl);
        RecordType rd1=[select id from RecordType where name='Four Wheeler' and  sobjectType='Loan_Application__c'];
        Loan_Application__c loanAppl1 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true,
            Stage__c='QDE',
            Final_Exposure__c =10,
            RecordTypeId=rd1.Id            
        ),false);
        loanList.add(loanAppl1);
        Loan_Application__c loanAppl2 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true,
            Stage__c='DDE',
            Final_Exposure__c =10,
            RecordTypeId=rd1.Id
        ),false);
        loanList.add(loanAppl2);
         Loan_Application__c loanAppl3 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true,
            Stage__c='Credit',
            Final_Exposure__c =10,
            RecordTypeId=rd1.Id,
            Sanction_Status__c = 'Issued'
        ),false);
        loanList.add(loanAppl3);
        insert loanList;
    }
    
    @isTest
    static void assignmentTest()
    {
        List<String> loanList = new List<String>();
        Map<String,String> loanId_LetterTypeMap = new Map<String,String>();
        List<Loan_Application__c> loanAppList = [SELECT Id FROM Loan_Application__c];
        
        for(Loan_Application__c loanApp : [SELECT Id FROM Loan_Application__c])
        {
            loanList.add(loanApp.Id);
            loanId_LetterTypeMap.put(loanApp.Id,'Customer Signatures');
        }
        
        Loan_Application_Approval__c loanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppList[0].Id,  Approval_Type__c = 'Pricing' , Approver__c = UserInfo.getUserId(), Type__c = 'Base',
            Archived__c = false
        ),true); 
        Loan_Application_Approval__c loanAppApproval1 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppList[1].Id,  Approval_Type__c = 'Credit' , Approver__c = UserInfo.getUserId(), Type__c = 'Base',
            Archived__c = false
        ),true);
        Id applicantRecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
                First_Name__c = 'Vikash',
                Middle_Name__c = 'Kumar',
                Last_Name__c = 'Mandal',
                Loan__c =loanAppList[0].Id,
                Customer_Name__c='Vikas',
                Customer_Type__c='Individual',
                Type_Of_Employment__c = 'Farmer',
                Customer_Grade__c = 'IB',
                RecordTypeId = applicantRecordTypeId
            ),true);
        Id collateralUsedRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('Used/Cash on Wheels').getRecordTypeId();
        Collateral__c coll1 = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Owner_Serial_number__c='1111', vehicle_color__c = 'Blue', Kilometer__c = '10', 
            Loan__c = loanAppList[0].id, Chasis_Number__c ='12445', Engine_Number__c ='43232',
            Vehicle_Number__c  ='124234' , Vehicle_Usage__c  = 'Personal' , Collateral_Name__c = '10102',
            Vehicle_Category__c  = 'TestCat', RecordTypeId = collateralUsedRecordTypeId,Manufacture_year_month__c='202304'
        ),true);
        AUSFRBMApprovalAssignment.getListOfRBMApprovals(loanList,loanId_LetterTypeMap,'Test Remarks',false);
 
    }

    @isTest
    static void assignmentBranchTest()
    {
        List<String> loanList = new List<String>();
        Map<String,String> loanId_LetterTypeMap = new Map<String,String>();
        List<Loan_Application__c> loanAppList = [SELECT Id FROM Loan_Application__c];
        
        for(Loan_Application__c loanApp : [SELECT Id FROM Loan_Application__c])
        {
            loanList.add(loanApp.Id);
            loanId_LetterTypeMap.put(loanApp.Id,'Customer Signatures');
        }
        
        Id applicantRecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
                First_Name__c = 'Vikash',
                Middle_Name__c = 'Kumar',
                Last_Name__c = 'Mandal',
                Loan__c =loanAppList[0].Id,
                Customer_Name__c='Vikas',
                Customer_Type__c='Individual',
                Type_Of_Employment__c = 'Farmer',
                Customer_Grade__c = 'IB',
                RecordTypeId = applicantRecordTypeId
            ),true);
        Id collateralUsedRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('Used/Cash on Wheels').getRecordTypeId();
        Collateral__c coll1 = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Owner_Serial_number__c='1111', vehicle_color__c = 'Blue', Kilometer__c = '10', 
            Loan__c = loanAppList[0].id, Chasis_Number__c ='12445', Engine_Number__c ='43232',
            Vehicle_Number__c  ='124234' , Vehicle_Usage__c  = 'Personal' , Collateral_Name__c = '10102',
            Vehicle_Category__c  = 'TestCat', RecordTypeId = collateralUsedRecordTypeId,Manufacture_year_month__c='202304'
        ),true);
        AUSFRBMApprovalAssignment.RBM_DO_APPROVAL_TYPE = 'Branch Manager';
        AUSFRBMApprovalAssignment.requiredApprovalType = 'Branch Manager';
        AUSFRBMApprovalAssignment.getListOfRBMApprovals(loanList,loanId_LetterTypeMap,'Test Remarks',false);
 
    }
	
    @isTest static void verifyListOfApprovals(){
        AccountTeamMember atm = new AccountTeamMember( Approver_Level__c = 'L7', Deviation_Level__c = 'S6', UserId = UserInfo.getUserId() );
        Test.startTest();
        Id loanId = [ SELECT Id FROM Loan_Application__c LIMIT 1 ].Id;

        Loan_Application_Approval__c[] approvals = AUSFRBMApprovalAssignment.getListOfApprovals( atm, new String[]{ loanId }, new map<String, AccountTeamMember>(), null, new map<String, String>(), null, true );
        Test.stopTest();
        
        Assert.areEqual(
            1,
            approvals.size(),
            'An Approval should be raised to the NBM / RBM'
        );
    }
}