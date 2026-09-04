/*
@ Class Name: AUSFLoanApplicationAssignmentHelperTest
@ Description: Test class for AUSFLoanApplicationAssignmentHelper
@ Code Coverage: 
@ Description: Loan Assignment
@ Logs:
@   Last Modified Date  -   Last Modified By    -   Bug
@   Dec-15-2023         -   Yash S              -   SFAU-5747 - 
@   Dec-18-2023         -   Mohit M.            -   SFAU-5664 - STP Case Credit

*/
@isTest
public class AUSFLoanApplicationAssignmentHelperTest {
    
    @testsetup static void createData(){
        /*       
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        
        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
            Account_Code__c='2103',
            Branch_Queue__c=grp.Id,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId()
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
            Branch_Master__c = accInstance.Id,
            RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Four Wheeler').getRecordTypeId()
        ),true);
         

        
        AccountTeamMember atm = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
            AccountId =accInstance.Id,
            UserId=UserInfo.getUserId(),
            TeamMemberRole = 'Credit',
            Deviation_Level__c = 'S3',
            Approver_Level__c = 'L4;L5', Customer_Grade__c = 'IB', 
            Type_of_Employment__c = 'Salaried - Private', Collateral__c  = '10101',  Product__c = '10201'   
        ),true);                    
        */
        Profile adminProfile = [select Id,Name from profile where name = 'System Administrator'];
        User usrAdmin = (User)TestFactory.createSObject(new User(firstName = 'admin1',
                                                            lastName = 'admin2',
                                                            profileId = adminProfile.id,
                                                            username = 'admin1'+UserInfo.getOrganizationId()+'@test.com',
                                                            email = 'admin1@test.com',
                                                            Branch_Code__c  = '2103'
                                                           ),true);

        Group testGroup = new Group(Name='test group', Type='Queue');
        insert testGroup;
              
        Account regionRecord = (Account)TestFactory.createSObject(
            new Account(
                name = 'adminRegion',
                Account_Code__c  = '2104',
                Branch_Queue__c = testGroup.Id
            ),true);
        Account hubRecord = (Account)TestFactory.createSObject(
            new Account(
                name = 'adminRegion',
                Account_Code__c  = '2105',
                Branch_Queue__c = testGroup.Id,
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Hub').getRecordTypeId()
            ),true);
        Account branchRecord = (Account)TestFactory.createSObject(
            new Account(
                name = 'admin2',
                Account_Code__c  = '2103',
                Branch_Queue__c = testGroup.Id,
                Region__c = regionRecord.Id,
                Business_HUB__c = hubRecord.Id
            ),true);
        // Create test data
        Trigger_Deactivation_Settings__c trigSetup = new Trigger_Deactivation_Settings__c ();
        trigSetup.AccountTeamMember_Trigger__c = true;
        trigSetup.SetupOwnerId = usrAdmin.Id;
        insert trigSetup;

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

        insert new AccountTeamMember[]{
            new AccountTeamMember(
                UserId = higherAuthUser.Id,
                AccountId = branchRecord.Id,
                TeamMemberRole = 'Credit',
                Approver_Level__c = 'L7',
                Deviation_Level__c = 'S5',
                Type_Of_Employment__c = 'Farmer',
                Product__c = '10201',
                Collateral__c = '10101',
                Customer_Grade__c = 'IB'
            ),
                new AccountTeamMember(
                UserId = higherAuthUser.Id,
                AccountId = hubRecord.Id,
                TeamMemberRole = 'Credit',
                Approver_Level__c = 'L7',
                Deviation_Level__c = 'S5',
                Type_Of_Employment__c = 'Farmer',
                Product__c = '10201',
                Collateral__c = '10101',
                Customer_Grade__c = 'IB'
            ),
    
            new AccountTeamMember(
                UserId = higherAuthUser.Id,
                AccountId = branchRecord.Id,
                TeamMemberRole = 'Branch Manager',
                Approver_Level__c = 'P7',
                Type_Of_Employment__c = 'Farmer',
                Product__c = '10201',
                Collateral__c = '10101',
                Customer_Grade__c = 'IB'
            ),
            new AccountTeamMember(
                UserId = UserInfo.getUserId(),
                AccountId = branchRecord.Id,
                TeamMemberRole = 'Branch Manager',
                Approver_Level__c = 'P3',
                Type_Of_Employment__c = 'Farmer',
                Product__c = '10201',
                Collateral__c = '10101',
                Customer_Grade__c = 'IB'
            )
        };
        
        
        //Loan Application Insertion
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
        ),false);
        Loan_Application__c loanApp2 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Individual',
            Stage__c ='Pricing',
            EMI_Date__c = '10/3/2022',
            BRE_Decision__c = 'STP',
            BRE_Approval_Level__c = 'L1S1',
            Tenure__c = 10,
            Branch_Master__c = branchRecord.Id,
            RecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Four Wheeler').getRecordTypeId()
        ),false);
        insert new List<Loan_Application__c> {loanAppl, loanApp2};

        TestFactory.createSObject( new AccountTeamMember(UserId = usr.Id, AccountId = branchRecord.Id, TeamMemberRole = 'Credit', Approver_Level__c = 'L2',Type_Of_Employment__c = 'Farmer', Product__c = '10201', Collateral__c = '10101', Customer_Grade__c = 'IB' ) , true);
        TestFactory.createSObject( new AccountTeamMember(UserId = higherAuthUser.Id, AccountId = branchRecord.Id, TeamMemberRole = 'Credit', Approver_Level__c = 'L7', Deviation_Level__c = 'S5',Type_Of_Employment__c = 'Farmer', Product__c = '10201', Collateral__c = '10101', Customer_Grade__c = 'IB' ) , true);
       
        list<Loan_Application_Approval__c> lstLoanAppApproval = new List<Loan_Application_Approval__c>();
        Loan_Application_Approval__c loanAppApproval0 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanApp2.Id,  Approval_Type__c = 'Credit' , Approver__c = usr.id,Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING,
            Archived__c = false, Approver_Level__c = 'L1', Type__c = 'Base'
        ),false);
        
        Loan_Application_Approval__c loanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id,  Approval_Type__c = 'Credit' , Approver__c = usr.id,Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING,
            Archived__c = false, Approver_Level__c = 'L1', Type__c = 'Base'
        ),false);
        Loan_Application_Approval__c loanAppApproval1 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id, Approver__c = usr.id , Approval_Type__c = 'Credit', Approver_Level__c = 'L2', Type__c = 'Middle', Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING
        ),false);
        Loan_Application_Approval__c loanAppApproval2 = (Loan_Application_Approval__c)TestFactory.createSObject(
            new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id,
            Assigned_to_Queue__c = true,
            Approver__c = usr.id,
            Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING,
            Approver_Level__c = 'L3', Approval_Type__c = 'Credit', Type__c = 'Highest'
        ),false);
        Loan_Application_Approval__c loanAppApproval3 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanApp2.Id,  Approval_Type__c = 'Pricing' , Approver__c = usr2.id,
            Archived__c = false, Approver_Level__c = 'P1', Type__c = 'Base'
        ),false);
        Loan_Application_Approval__c loanAppApproval4 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanApp2.Id, Approver__c = usr2.id , Approval_Type__c = 'Pricing', Approver_Level__c = 'P2', Type__c = 'Middle'
        ),false);
        Loan_Application_Approval__c loanAppApproval5 = (Loan_Application_Approval__c)TestFactory.createSObject(
            new Loan_Application_Approval__c(
            Loan_Application__c  = loanApp2.Id,
            Approver__c = usr2.id,
            Assigned_to_Queue__c = true,
            Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING,
            Approver_Level__c = 'P3', Approval_Type__c = 'Pricing', Type__c = 'Highest'
        ),false);
        Loan_Application_Approval__c loanAppApproval6 = (Loan_Application_Approval__c)TestFactory.createSObject(
            new Loan_Application_Approval__c(
            Loan_Application__c  = loanApp2.Id,
            Approver__c = usr2.id,
            Approval_Status__c = 'Rejected',
            Approver_Level__c = 'P3', Approval_Type__c = 'Pricing', Type__c = 'Highest'
        ),false);

        lstLoanAppApproval.addAll(new Loan_Application_Approval__c[]{ loanAppApproval0, loanAppApproval, loanAppApproval1, loanAppApproval2, loanAppApproval3, loanAppApproval4, loanAppApproval5, loanAppApproval6 });
        insert lstLoanAppApproval;
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanApp2.Id,
            Caste__c = 'SC',
            Type_Of_Employment__c = 'Farmer',
            Customer_Grade__c = 'IB',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
    }
    
    @isTest static void AUSFLoanApplicationAssignmentHelper1(){
        
        List<Loan_Application__c> applicats = [Select Id, RecordTypeId, Application_Number__c, Branch_Master__c, Branch_Master__r.Business_HUB__c, Adhar_Card__c, Loan_Amount__c, Product__c, 
                                               Customer_Type__c, Stage__c, EMI_Date__c, Tenure__c,  Branch_Master__r.Region__c, 
                                               Branch_Master__r.State__c, Branch_Master__r.Zone__c,  Branch_Master__r.National__c, BRE_Approval_Level__c, RecordType.Name, RecordType.DeveloperName from Loan_Application__c];
        List<AccountTeamMember> teamMembers = [Select Id, UserId, AccountId, Approver_Level__c, TeamMemberRole, Deviation_Level__c, Customer_Grade__c, 
                                               Type_Of_Employment__c, Collateral__c, Product__c from AccountTeamMember]; 

        Test.startTest();
            AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsCustGrade = new Map<String, String>{applicats[0].Id=> 'IB'};
            AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsTypeOfEmpl = new Map<String, String>{applicats[0].Id=> 'Salaried - Private'};
            AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsCollateralName = new Map<String, String>{applicats[0].Id=> '10101'};
            AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsProduct = new Map<String, String>{applicats[0].Id=> '10201'};        
            AUSFLoanApplicationAssignmentHelper helper = new AUSFLoanApplicationAssignmentHelper();
            AUSFLoanApplicationAssignmentHelper cs1 = new AUSFLoanApplicationAssignmentHelper(GlobalConstants.APPROVAL_TYPE_PRICING, null);
            //AUSFLoanApplicationAssignmentHelper.mainMethod(teamMembers, applicats);
        Test.stopTest();
        
        //AUSFLoanApplicationAssignmentHelper.insertListOfApprovers(teamMembers,teamMembers,teamMembers, applicats[0].Id, '', '', '', applicats[0]);

        
    }
    
    @isTest static void AUSFLoanApplicationAssignmentHelper2W(){
        
        List<Loan_Application__c> applicats = [Select Id, RecordTypeId, Application_Number__c, Branch_Master__c, Branch_Master__r.Business_HUB__c, Adhar_Card__c, Loan_Amount__c, Product__c, 
                                               Customer_Type__c, Stage__c, EMI_Date__c, Tenure__c,  Branch_Master__r.Region__c, 
                                               Branch_Master__r.State__c, Branch_Master__r.Zone__c,  Branch_Master__r.National__c, BRE_Approval_Level__c, RecordType.Name, RecordType.DeveloperName from Loan_Application__c where Recordtype.Name = 'Two Wheeler'];
        
        List<AccountTeamMember> teamMembers = [Select Id, UserId, AccountId, Approver_Level__c, TeamMemberRole, Deviation_Level__c, Customer_Grade__c, 
                                               Type_Of_Employment__c, Collateral__c, Product__c from AccountTeamMember]; 

        Test.startTest();
        map<String, map<String, AccountTeamMember[]>> mapOfAcc = new map<String, map<String, AccountTeamMember[]>>();
        Map<String, AccountTeamMember[]> accTeam = new Map<String, AccountTeamMember[]>{teamMembers[0].AccountId => teamMembers};
        mapOfAcc.put(teamMembers[0].Id, accTeam);
        AUSFLoanApplicationAssignmentHelper.mainMethod(teamMembers, applicats);
        Test.stopTest();
        //AUSFLoanApplicationAssignmentHelper.insertListOfApprovers(teamMembers,teamMembers,teamMembers, applicats[0].Id, '', '', '', applicats[0]);
        
        
    }
    
    @isTest static void AUSFLoanApplicationAssignmentHelper2(){
        
        List<Loan_Application__c> applicats = [Select Id, RecordTypeId, Application_Number__c, Branch_Master__c, Branch_Master__r.Business_HUB__c, Adhar_Card__c, Loan_Amount__c, Product__c, 
                                               Customer_Type__c, Stage__c, EMI_Date__c, Tenure__c,  Branch_Master__r.Region__c, 
                                               Branch_Master__r.State__c, Branch_Master__r.Zone__c,  Branch_Master__r.National__c, BRE_Approval_Level__c, RecordType.Name, RecordType.DeveloperName from Loan_Application__c where RecordType.Name = 'Four Wheeler'];
        
        List<AccountTeamMember> teamMembers = [Select Id, UserId, AccountId, Approver_Level__c, TeamMemberRole, Deviation_Level__c, Customer_Grade__c, 
                                               Type_Of_Employment__c, Collateral__c, Product__c from AccountTeamMember]; 

        Test.startTest();
        map<String, map<String, AccountTeamMember[]>> mapOfAcc = new map<String, map<String, AccountTeamMember[]>>();
        Map<String, AccountTeamMember[]> accTeam = new Map<String, AccountTeamMember[]>{teamMembers[0].AccountId => teamMembers};
        mapOfAcc.put(teamMembers[0].Id, accTeam);
        AUSFLoanApplicationAssignmentHelper.mainMethod(teamMembers, applicats);
        Test.stopTest();
        //AUSFLoanApplicationAssignmentHelper.insertListOfApprovers(teamMembers,teamMembers,teamMembers, applicats[0].Id, '', '', '', applicats[0]);
        
        
    }
    
    @isTest static void AUSFLoanApplicationAssignmentHelper4WCredit(){
        
        List<Loan_Application__c> applicats = [Select Id, RecordTypeId, Application_Number__c, Branch_Master__c, Branch_Master__r.Business_HUB__c, Adhar_Card__c, Loan_Amount__c, Product__c, 
                                               Customer_Type__c, Stage__c, EMI_Date__c, Tenure__c,  Branch_Master__r.Region__c, 
                                               Branch_Master__r.State__c, Branch_Master__r.Zone__c,  Branch_Master__r.National__c, BRE_Approval_Level__c, RecordType.Name, RecordType.DeveloperName from Loan_Application__c where RecordType.Name = 'Four Wheeler'];
        
        applicats[0].Stage__c = 'Credit';
        List<AccountTeamMember> teamMembers = [Select Id, UserId, AccountId, Approver_Level__c, TeamMemberRole, Deviation_Level__c, Customer_Grade__c, 
                                               Type_Of_Employment__c, Collateral__c, Product__c from AccountTeamMember]; 

        Test.startTest();
        map<String, map<String, AccountTeamMember[]>> mapOfAcc = new map<String, map<String, AccountTeamMember[]>>();
        Map<String, AccountTeamMember[]> accTeam = new Map<String, AccountTeamMember[]>{teamMembers[0].AccountId => teamMembers};
        mapOfAcc.put(teamMembers[0].Id, accTeam);
            AUSFLoanApplicationAssignmentHelper obj = new AUSFLoanApplicationAssignmentHelper('Credit',null);
            AUSFLoanApplicationAssignmentHelper.mainMethod(teamMembers, applicats);
        Test.stopTest();
        //AUSFLoanApplicationAssignmentHelper.insertListOfApprovers(teamMembers,teamMembers,teamMembers, applicats[0].Id, '', '', '', applicats[0]);
        
        
    }
    
    @isTest static void AUSFLoanApplicationAssignmentHelper4WPricing(){
        
        List<Loan_Application__c> applicats = [Select Id, RecordTypeId, Application_Number__c, Branch_Master__c, Branch_Master__r.Business_HUB__c, Adhar_Card__c, Loan_Amount__c, Product__c, 
                                               Customer_Type__c, Stage__c, EMI_Date__c, Tenure__c,  Branch_Master__r.Region__c, 
                                               Branch_Master__r.State__c, Branch_Master__r.Zone__c,  Branch_Master__r.National__c, BRE_Approval_Level__c, RecordType.Name, RecordType.DeveloperName from Loan_Application__c where RecordType.Name = 'Four Wheeler'];
        
        applicats[0].Stage__c = 'Pricing';
        List<AccountTeamMember> teamMembers = [Select Id, UserId, AccountId, Approver_Level__c, TeamMemberRole, Deviation_Level__c, Customer_Grade__c, 
                                               Type_Of_Employment__c, Collateral__c, Product__c from AccountTeamMember]; 

        Test.startTest();
        map<String, map<String, AccountTeamMember[]>> mapOfAcc = new map<String, map<String, AccountTeamMember[]>>();
        Map<String, AccountTeamMember[]> accTeam = new Map<String, AccountTeamMember[]>{teamMembers[0].AccountId => teamMembers};
        mapOfAcc.put(teamMembers[0].Id, accTeam);
            AUSFLoanApplicationAssignmentHelper obj = new AUSFLoanApplicationAssignmentHelper('Pricing',null);
        Test.stopTest();
        //AUSFLoanApplicationAssignmentHelper.insertListOfApprovers(teamMembers,teamMembers,teamMembers, applicats[0].Id, '', '', '', applicats[0]);
        
        
    }
    
    @isTest static void testGetTwoWheelerKeys(){
        
        List<Loan_Application__c> applicats = [Select Id, RecordTypeId, Application_Number__c, Branch_Master__c, Branch_Master__r.Business_HUB__c, Adhar_Card__c, Loan_Amount__c, Product__c, 
                                               Customer_Type__c, Stage__c, EMI_Date__c, Tenure__c,  Branch_Master__r.Region__c, 
                                               Branch_Master__r.State__c, Branch_Master__r.Zone__c,  Branch_Master__r.National__c, BRE_Approval_Level__c, RecordType.Name, RecordType.DeveloperName from Loan_Application__c where RecordType.Name = 'Four Wheeler'];
        
        Test.startTest();   
            AUSFLoanApplicationAssignmentHelper.getTwoWheelerKeys();
            AUSFLoanApplicationAssignmentHelper.getAccountId ('Branch',applicats[0]);
            AUSFLoanApplicationAssignmentHelper.getAccountId ('Hub',applicats[0]);
            AUSFLoanApplicationAssignmentHelper.getAccountId ('State',applicats[0]);
            AUSFLoanApplicationAssignmentHelper.getAccountId ('Region',applicats[0]);
            AUSFLoanApplicationAssignmentHelper.getAccountId ('Zone',applicats[0]);
            AUSFLoanApplicationAssignmentHelper.getAccountId ('National',applicats[0]);
        Test.stopTest();
        //AUSFLoanApplicationAssignmentHelper.insertListOfApprovers(teamMembers,teamMembers,teamMembers, applicats[0].Id, '', '', '', applicats[0]);
        
        
    }
    
    @isTest static void AUSFLoanApplicationAssignmentHelper3(){
        /*
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        */
        Account accInstance = [Select Id from Account where Account_Code__c = '2104' limit 1];
        
        AccountTeamMember atm = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
            AccountId =accInstance.Id,
            UserId=UserInfo.getUserId(),
            TeamMemberRole = 'Credit',
            Deviation_Level__c = 'S3',
            Approver_Level__c = 'L4;L5', Customer_Grade__c = 'IB', 
            Type_of_Employment__c = 'Salaried - Private', Collateral__c  = '10101',  Product__c = '10201'   
        ),true);
        
        List<Loan_Application__c> applicats = [Select Id, RecordTypeId, Application_Number__c, Branch_Master__c, Branch_Master__r.Business_HUB__c, Adhar_Card__c, Loan_Amount__c, Product__c, 
                                               Customer_Type__c, Stage__c, EMI_Date__c, Tenure__c,  Branch_Master__r.Region__c, 
                                               Branch_Master__r.State__c, Branch_Master__r.Zone__c,  Branch_Master__r.National__c, BRE_Approval_Level__c, RecordType.Name, RecordType.DeveloperName from Loan_Application__c];
        List<AccountTeamMember> teamMembers = [Select Id, UserId, AccountId, Approver_Level__c, TeamMemberRole, Deviation_Level__c, Customer_Grade__c, 
                                               Type_Of_Employment__c, Collateral__c, Product__c from AccountTeamMember]; 

        Test.startTest();
        List<Id> lstLoanId = new List<Id>();
        for (Loan_Application__c obj : applicats) {
            lstLoanId.add(obj.Id);
        }
        CreditApprovalHandler.wrapper wrap = CreditApprovalHandler.getListOfFilterValues(lstLoanId);
        AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsCollateralName = wrap.mapOfLoanIddVsCollateralName;
        AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsCustGrade = wrap.mapOfLoanIdVsCustGrade;
        AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsTypeOfEmpl = wrap.mapOfLoanIdVsTypeOfEmpl;
        AUSFLoanApplicationAssignmentHelper.mapOfFieldVsListOfValues = wrap.mapOfFieldVsValues; 
        AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsProduct = wrap.mapOfLoanIdVsProduct;
        AUSFLoanApplicationAssignmentHelper obj = new AUSFLoanApplicationAssignmentHelper('Credit',null);
        AUSFLoanApplicationAssignmentHelper.mainMethod(teamMembers, applicats);
        AUSFLoanApplicationAssignmentHelper.mainMethod(new List<AccountTeamMember>{atm}, applicats);
        Test.stopTest();
    }
    
    @isTest static void AUSFLoanApplicationAssignmentHelper4(){
        
        AUSFLoanApplicationAssignmentHelper.isCalledFromFI = true;
        /*Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        */
        Account accInstance = [Select Id from Account where Account_Code__c = '2104' limit 1];
        
        AccountTeamMember atm = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
            AccountId =accInstance.Id,
            UserId=UserInfo.getUserId(),
            TeamMemberRole = 'Credit',
            Deviation_Level__c = 'S3',
            Approver_Level__c = 'L4;L5', Customer_Grade__c = 'IB', 
            Type_of_Employment__c = 'Salaried - Private', Collateral__c  = '10101',  Product__c = '10201'   
        ),true);
        
        List<Loan_Application__c> applicats = [Select Id, RecordTypeId, Application_Number__c, Branch_Master__c, Branch_Master__r.Business_HUB__c, Adhar_Card__c, Loan_Amount__c, Product__c, 
                                               Customer_Type__c, Stage__c, EMI_Date__c, Tenure__c,  Branch_Master__r.Region__c, 
                                               Branch_Master__r.State__c, Branch_Master__r.Zone__c,  Branch_Master__r.National__c, BRE_Approval_Level__c, RecordType.Name, RecordType.DeveloperName from Loan_Application__c];
        List<AccountTeamMember> teamMembers = [Select Id, UserId, AccountId, Approver_Level__c, TeamMemberRole, Deviation_Level__c, Customer_Grade__c, 
                                               Type_Of_Employment__c, Collateral__c, Product__c from AccountTeamMember]; 

        Test.startTest();
        List<Id> lstLoanId = new List<Id>();
        for (Loan_Application__c obj : applicats) {
            lstLoanId.add(obj.Id);
        }
        CreditApprovalHandler.wrapper wrap = CreditApprovalHandler.getListOfFilterValues(lstLoanId);
        AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsCollateralName = wrap.mapOfLoanIddVsCollateralName;
        AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsCustGrade = wrap.mapOfLoanIdVsCustGrade;
        AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsTypeOfEmpl = wrap.mapOfLoanIdVsTypeOfEmpl;
        AUSFLoanApplicationAssignmentHelper.mapOfFieldVsListOfValues = wrap.mapOfFieldVsValues; 
        AUSFLoanApplicationAssignmentHelper.mapOfLoanIdVsProduct = wrap.mapOfLoanIdVsProduct;
        AUSFLoanApplicationAssignmentHelper obj = new AUSFLoanApplicationAssignmentHelper('Credit',null);
        AUSFLoanApplicationAssignmentHelper.mainMethod(teamMembers, applicats);
        AUSFLoanApplicationAssignmentHelper.mainMethod(new List<AccountTeamMember>{atm}, applicats);
        Test.stopTest();
    }
}