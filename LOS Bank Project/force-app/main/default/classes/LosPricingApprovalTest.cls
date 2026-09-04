/*****
 * Class Name: LosPricingApprovalTest
 * Description: 
 * Main Class Name: LosPricingApproval
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Nov-22-2023          -   Mohit M.            -   SFAU-5606
 */
@IsTest
private class LosPricingApprovalTest {
    @isTest
    static void testgetMapOfAcTeamMembers(){
        Profile prof = [select Id,Name from profile where name like '%Credit%'];

		Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='Group1',
            Type='Queue'
        ),true); 
        Account accInstance = (Account )TestFactory.createSObject(new Account (
            Name ='TestAccount',
           	Account_Code__c='2103',
           	Branch_Queue__c=grp.Id
        ),true); 

        User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
        	lastName = 'test2',
        	profileId = prof.id,
        	username = 'test'+UserInfo.getOrganizationId()+'@test.com',
        	email = 'test@test.com',
        	Branch_Code__c  = '2103'
    	),true);
        List<AccountTeamMember> atmList = new List<AccountTeamMember>();
        AccountTeamMember atm = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
        	AccountId =accInstance.Id,
        	UserId=usr.Id,
        	TeamMemberRole = 'Account Manager'
       	),true);  
        atmList.add(atm);
        AccountTeamMember atm1 = (AccountTeamMember )TestFactory.createSObject(new AccountTeamMember (
        	AccountId =accInstance.Id,
        	UserId=usr.Id,
        	TeamMemberRole = 'Account Manager'
       	),true);  
        atmList.add(atm1);
        Test.startTest();
        LosPricingApproval.getMapOfAcTeamMembers(atmList,'Account Manager');
        Test.stopTest();
    }
    
    @IsTest
    static void testGetPricingApprovalAuthorities() {
        
        Id branchMasterAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='T10001 Test Account1',
            Type='Queue'
        ),true); 

        // Create test data
        Trigger_Deactivation_Settings__c trigSetup = new Trigger_Deactivation_Settings__c ();
        trigSetup.AccountTeamMember_Trigger__c = true;
        trigSetup.SetupOwnerId = UserInfo.getUserId();
        insert trigSetup;

        
        List<AccountTeamMember> accountTeams = new List<AccountTeamMember>();

        Account regionAccount = new Account();
        regionAccount.Name = 'Region Account';
        regionAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Region').getRecordTypeId();
        insert regionAccount;
        
        Account branchMasterAccount = new Account();
        branchMasterAccount.Name = 'Test Account1';
        branchMasterAccount.Region__c = regionAccount.Id;
        branchMasterAccount.RecordTypeId = branchMasterAccountRTId;
        branchMasterAccount.Account_Code__c = 'T10001';
        branchMasterAccount.Branch_Queue__c = grp.Id;
        insert branchMasterAccount;
                
        AccountTeamMember aTM_1 = new AccountTeamMember();
        aTM_1.accountId = branchMasterAccount.Id;
        aTM_1.Active__c = true;
        aTM_1.Type_of_Employment__c = 'Business';
        aTM_1.Customer_Grade__c = 'IB';
        aTM_1.TeamMemberRole = 'Branch Manager';
        aTM_1.Approver_Level__c = 'P2';
        aTM_1.Product__c = '10201';
        aTM_1.Collateral__c = '10101';
        aTM_1.UserId = UserInfo.getUserId();
        accountTeams.add(aTM_1);
        
        AccountTeamMember aTM_2 = new AccountTeamMember();
        aTM_2.accountId = regionAccount.Id;
        aTM_2.Active__c = true;
        aTM_2.Type_of_Employment__c = 'Business';
        aTM_2.Customer_Grade__c = 'IB';
        aTM_2.TeamMemberRole = 'Region Head (RBM)';
        aTM_2.Approver_Level__c = 'P2';
        aTM_2.Product__c = '10201';
        aTM_2.Collateral__c = '10101';
        aTM_2.UserId = UserInfo.getUserId();
        
        accountTeams.add(aTM_2);
        insert accountTeams;
        
        List<Loan_Application__c> loanAppsParam = new List<Loan_Application__c>();

        Loan_Application__c loanApp1 = new Loan_Application__c();
        loanApp1.Name = 'Loan App 1';
        loanApp1.ROI__c = 31;
        loanApp1.RBP__c = 30;
        loanApp1.Product__c = '10201';
        loanApp1.Branch_Master__c = branchMasterAccount.Id;
        loanAppsParam.add(loanApp1);

        Loan_Application__c loanApp2 = new Loan_Application__c();
        loanApp2.Name = 'Loan App 2';
       	loanApp2.ROI__c = 30;
        loanApp2.RBP__c = 29;
        loanAppsParam.add(loanApp2);
        
        Loan_Application__c loanApp3 = new Loan_Application__c();
        loanApp3.Name = 'Loan App 3';
        loanApp3.ROI__c = 31;
        loanApp3.RBP__c = 30;
        loanApp3.Product__c = '10201';
        loanAppsParam.add(loanApp3);
        
        insert loanAppsParam;
         Deviation__c  dev = (Deviation__c)TestFactory.createSObject(new Deviation__c(
            Loan_Application__c  = loanApp1.id , Active__c  = true,Archived__c=false,Deviation_Type__c  ='Motor Insurance'
        ),true);
        Deviation__c  dev1 = (Deviation__c)TestFactory.createSObject(new Deviation__c(
            Loan_Application__c  = loanApp2.id , Active__c  = true,Archived__c=false,Deviation_Type__c  ='Motor Insurance'
        ),true);
        Deviation__c  dev3 = (Deviation__c)TestFactory.createSObject(new Deviation__c(
            Loan_Application__c  = loanApp3.id , Active__c  = true,Archived__c=false,Deviation_Type__c  ='Motor Insurance'
        ),true);

        Map<Id,Loan_Application__c> newMap = new Map<Id,Loan_Application__c>([Select Id,Name,ROI__c,RBP__c,Product__c,RecordTypeId,RecordType.Name,RecordType.DeveloperName from Loan_Application__c]);
        
        Charge__c charge1 = new Charge__c();
        charge1.Charges_Name__c = 'Processing Fees';
        charge1.Actual_rate__c = 200;
        charge1.Charge_Amount__c = 100;
        charge1.Loan_Application__c = loanAppsParam[0].Id;
        charge1.Rate_value_As_per_Policy__c = 200.0;
        insert charge1;
        
        Charge__c charge2 = new Charge__c();
        charge2.Charges_Name__c = 'Documentation Charges';
        charge2.Actual_rate__c = 200;
        charge2.Charge_Amount__c = 100;
        charge2.Loan_Application__c = loanAppsParam[1].Id;
        charge2.Rate_value_As_per_Policy__c = 200.0;
        insert charge2;
        
        Charge__c charge3 = new Charge__c();
        charge3.Charges_Name__c = 'LS Charges';
        charge3.Actual_rate__c = 200;
        charge3.Charge_Amount__c = 100;
        charge3.Loan_Application__c = loanAppsParam[2].Id;
        charge3.Rate_value_As_per_Policy__c = 200.0;
        insert charge3;
        
        List<Loan_Application_Approval__c> loanAppApprovals = new List<Loan_Application_Approval__c>();
        Loan_Application_Approval__c loanAppApproval = new Loan_Application_Approval__c();
        loanAppApproval.Loan_Application__c = loanAppsParam[0].Id;
        loanAppApproval.Approval_Type__c = 'Pricing';
        loanAppApproval.Archived__c = false;
        loanAppApproval.Type__c = 'Highest';
        loanAppApproval.Assigned_to_Queue__c = true;
        loanAppApproval.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
        loanAppApproval.Approver_Level__c  = 'P3'; 
        loanAppApprovals.add(loanAppApproval);

        try{
            
            Loan_Application_Approval__c loanAppApprovalMiddle = new Loan_Application_Approval__c();
            loanAppApprovalMiddle.Loan_Application__c = loanAppsParam[0].Id;
            loanAppApprovalMiddle.Approval_Type__c = 'Pricing';
            loanAppApprovalMiddle.Archived__c = false;
            loanAppApprovalMiddle.Type__c = 'Middle';
            loanAppApprovalMiddle.Assigned_to_Queue__c = true;
            loanAppApprovalMiddle.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
            loanAppApprovalMiddle.Approver_Level__c  = 'P1'; 
            loanAppApprovals.add(loanAppApprovalMiddle);
            insert loanAppApprovals;
            
            Id applicantRecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
            Applicant__c applicant = new Applicant__c();
            applicant.Loan__c = loanAppsParam[0].Id;
            applicant.RecordTypeId = applicantRecordTypeId;
            applicant.Type_Of_Employment__c = 'Business';
            applicant.Customer_Grade__c = 'IB';
            insert applicant;
            
            Map<String,String> returnMap = LosPricingApproval.getPricingApprovalAuthorities(newMap);
            Set<Id> newSetLoanAppId = newMap.keySet();
            
            System.Test.startTest();
            LosPricingApproval.callLoanApplicationAssignmentHelperMethod(newSetLoanAppId);
            
            List<Loan_Application_Approval__c> newLoanAppApprovals = [SELECT Id FROM Loan_Application_Approval__c WHERE Type__c = 'Base'];
            //Assert.isTrue(newLoanAppApprovals.size() > 0, 'No new Loan Application Approvals found');

            List<Loan_Application__c> lstLoanApp = [Select Id, BRE_Decision__c, Stage__c, No_Pricing_Deviation__c from Loan_Application__c limit 1];
            lstLoanApp[0].Stage__c = 'Pricing';
            lstLoanApp[0].BRE_Decision__c = 'STP';
            lstLoanApp[0].No_Pricing_Deviation__c = false;
            update lstLoanApp[0];

            System.Test.stopTest();
        }
        catch(Exception e){

        }
    }
    


    @IsTest
    static void testGetPricingApprovalAuthoritiesSecond() {
        
        Id branchMasterAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='T10001 Test Account1',
            Type='Queue'
        ),true); 

        // Create test data
        Trigger_Deactivation_Settings__c trigSetup = new Trigger_Deactivation_Settings__c ();
        trigSetup.AccountTeamMember_Trigger__c = true;
        trigSetup.SetupOwnerId = UserInfo.getUserId();
        insert trigSetup;
        
        List<AccountTeamMember> accountTeams = new List<AccountTeamMember>();

        Account regionAccount = new Account();
        regionAccount.Name = 'Region Account';
        regionAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Region').getRecordTypeId();
        insert regionAccount;
        
        Account branchMasterAccount = new Account();
        branchMasterAccount.Name = 'Test Account1';
        branchMasterAccount.Region__c = regionAccount.Id;
        branchMasterAccount.RecordTypeId = branchMasterAccountRTId;
        branchMasterAccount.Account_Code__c = 'T10001';
        branchMasterAccount.Branch_Queue__c = grp.Id;
        insert branchMasterAccount;
        
        Id loginUserId = UserInfo.getUserId();
        
        AccountTeamMember aTM_1 = new AccountTeamMember();
        aTM_1.accountId = branchMasterAccount.Id;
        aTM_1.Active__c = true;
        aTM_1.Type_of_Employment__c = 'Business';
        aTM_1.Customer_Grade__c = 'NIB';
        aTM_1.TeamMemberRole = 'Branch Manager';
        aTM_1.Approver_Level__c = 'P2';
        aTM_1.Product__c = '10201';
        aTM_1.Collateral__c = '10101';
        aTM_1.UserId = [Select Id from User where Id !=: loginUserId AND IsActive = true and Profile.Name = 'System Administrator' LIMIT 1].Id;
        accountTeams.add(aTM_1);
        
        AccountTeamMember aTM_2 = new AccountTeamMember();
        aTM_2.accountId = regionAccount.Id;
        aTM_2.Active__c = true;
        aTM_2.Type_of_Employment__c = 'Business';
        aTM_2.Customer_Grade__c = 'NIB';
        aTM_2.TeamMemberRole = 'Region Head (RBM)';
        aTM_2.Approver_Level__c = 'P3';
        aTM_2.Product__c = '10201';
        aTM_2.Collateral__c = '10101';
        aTM_2.UserId = UserInfo.getUserId();
        
        accountTeams.add(aTM_2);
        insert accountTeams;

        for (AccountTeamMember objATM : [Select Id, UserId, Product__c ,AccountId, TeamMemberRole, Account.RecordType.DeveloperName, Approver_Level__c, Deviation_Level__c,Customer_Grade__c,Collateral__c, Type_Of_Employment__c, User.IsActive, Active__c From AccountTeamMember]) {
            system.debug('Data ::: ' + objATM);
        }
        
        List<Loan_Application__c> loanAppsParam = new List<Loan_Application__c>();

        Loan_Application__c loanApp1 = new Loan_Application__c();
        loanApp1.Name = 'Loan App 1';
        loanApp1.ROI__c = 29;
        loanApp1.RBP__c = 30;
        loanApp1.Product__c = '10201';
        loanApp1.Branch_Master__c = branchMasterAccount.Id;
        loanApp1.Customer_Grade__c = 'NIB';
        loanApp1.recordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Four_Wheeler').getRecordTypeId();
        loanAppsParam.add(loanApp1);

        Loan_Application__c loanApp2 = new Loan_Application__c();
        loanApp2.Name = 'Loan App 2';
       	loanApp2.ROI__c = 30;
        loanApp2.RBP__c = 29;
        loanApp2.Product__c = '10202';
        loanApp2.Branch_Master__c = branchMasterAccount.Id;
        //loanAppsParam.add(loanApp2);
        
        Loan_Application__c loanApp3 = new Loan_Application__c();
        loanApp3.Name = 'Loan App 3';
        loanApp3.ROI__c = 29;
        loanApp2.RBP__c = 30;
        loanApp2.Product__c = '10203';
        loanApp2.Branch_Master__c = branchMasterAccount.Id;
        //loanAppsParam.add(loanApp3);
        
        insert loanAppsParam;

        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppsParam[0].Id,
            Customer_Grade__c ='NIB',
            Customer_Type__c ='Individual',
            KYC_Type__c='Driving License',
            AU_Employee__c = 'Yes',
            AU_Employment_status__c='Active',
            Date_of_Joining__c = System.today().addDays(-60),
            Education_qualification__c='GRADUATE',
            Type_Of_Employment__c = 'Business',
            RecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);

        // Collateral Insertion
        Collateral__c  collateralNew = (Collateral__c)TestFactory.createSObject(new Collateral__c (
            Loan__c =loanAppsParam[0].Id,
            //MMV_Master__c =mmvMaster.Id,
            Vehicle_Number__c='TN12345567',
            Certified_Value__c='1234',
            Collateral_Name__c ='10101',
            Pincode__c = '302026',
            City__c = 'Jaipur',
            Registration_City__c = 'Jaipur',
            Engine_Category__c ='BS6',
            Insurance_Expiry_Date__c = Date.Today().addDays(180),
            RecordTypeId=Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId()
        ), true);

        collateralNew = (Collateral__c)TestFactory.createSObject(new Collateral__c (
            Loan__c =loanAppsParam[0].Id,
            //MMV_Master__c =mmvMaster.Id,
            Vehicle_Number__c='TN12345568',
            Certified_Value__c='12345',
            Collateral_Name__c ='10101',
            Pincode__c = '302026',
            City__c = 'Jaipur',
            Registration_City__c = 'Jaipur',
            Engine_Category__c ='BS6',
            Insurance_Expiry_Date__c = Date.Today().addDays(180),
            RecordTypeId=Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('New').getRecordTypeId()
        ), true);

        Map<Id,Loan_Application__c> newMap = new Map<Id,Loan_Application__c>([Select Id,Name,ROI__c,RBP__c,Product__c,RecordTypeId,RecordType.Name,RecordType.DeveloperName from Loan_Application__c]);
        
        Charge__c charge1 = new Charge__c();
        charge1.Charges_Name__c = 'Processing Fees';
        charge1.Actual_rate__c = 200;
        charge1.Charge_Amount__c = 100;
        charge1.Loan_Application__c = loanAppsParam[0].Id;
        charge1.Rate_value_As_per_Policy__c = 200.0;
        insert charge1;
        
        Charge__c charge2 = new Charge__c();
        charge2.Charges_Name__c = 'Documentation Charges';
        charge2.Actual_rate__c = 200;
        charge2.Charge_Amount__c = 100;
        charge2.Loan_Application__c = loanAppsParam[0].Id;
        charge2.Rate_value_As_per_Policy__c = 200.0;
        insert charge2;
        
        Charge__c charge3 = new Charge__c();
        charge3.Charges_Name__c = 'LS Charges';
        charge3.Actual_rate__c = 200;
        charge3.Charge_Amount__c = 100;
        charge3.Loan_Application__c = loanAppsParam[0].Id;
        charge3.Rate_value_As_per_Policy__c = 200.0;
        charge3.SC_Code__c = '1265';
        insert charge3;

        Charge__c charge4 = new Charge__c();
        charge4.Charges_Name__c = 'Insurance Premium';
        charge4.Actual_rate__c = 200;
        charge4.Charge_Amount__c = 100;
        charge4.Loan_Application__c = loanAppsParam[0].Id;
        charge4.Rate_value_As_per_Policy__c = 200.0;
        charge4.SC_Code__c = '1099';
        insert charge4;
        
        List<Loan_Application_Approval__c> loanAppApprovals = new List<Loan_Application_Approval__c>();
        Loan_Application_Approval__c loanAppApproval = new Loan_Application_Approval__c();
        loanAppApproval.Loan_Application__c = loanAppsParam[0].Id;
        loanAppApproval.Approval_Type__c = 'Pricing';
        loanAppApproval.Archived__c = false;
        loanAppApproval.Type__c = 'Highest';
        loanAppApproval.Assigned_to_Queue__c = true;
        loanAppApproval.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
        loanAppApproval.Approver_Level__c  = 'P4'; 
        loanAppApprovals.add(loanAppApproval);

        try{
            
            Loan_Application_Approval__c loanAppApprovalMiddle = new Loan_Application_Approval__c();
            loanAppApprovalMiddle.Loan_Application__c = loanAppsParam[0].Id;
            loanAppApprovalMiddle.Approval_Type__c = 'Pricing';
            loanAppApprovalMiddle.Archived__c = false;
            loanAppApprovalMiddle.Type__c = 'Middle';
            loanAppApprovalMiddle.Assigned_to_Queue__c = true;
            loanAppApprovalMiddle.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
            loanAppApprovalMiddle.Approver_Level__c  = 'P2'; 
            loanAppApprovals.add(loanAppApprovalMiddle);
            insert loanAppApprovals;
            
            Id applicantRecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
            Applicant__c applicant = new Applicant__c();
            applicant.Loan__c = loanAppsParam[0].Id;
            applicant.RecordTypeId = applicantRecordTypeId;
            applicant.Type_Of_Employment__c = 'Business';
            applicant.Customer_Grade__c = 'IB';
            //insert applicant;
            
            System.Test.startTest();
            //Map<String,String> returnMap = LosPricingApproval.getPricingApprovalAuthorities(newMap);
            
            Set<Id> newSetLoanAppId = newMap.keySet();
            Loan_Application__c la = [Select Id, Customer_Grade__c, Branch_Master__r.Region__c from Loan_Application__c];
            Applicant__c apct = [Select Id, Customer_Grade__c, Type_Of_Employment__c from Applicant__c];
            system.assertEquals('NIB',la.Customer_Grade__c);
            system.assertEquals(regionAccount.Id,la.Branch_Master__r.Region__c);
            system.assertEquals('NIB',apct.Customer_Grade__c);
            system.assertEquals('Business',apct.Type_Of_Employment__c);
            LosPricingApproval.callLoanApplicationAssignmentHelperMethod(newSetLoanAppId);
            
            List<Loan_Application_Approval__c> newLoanAppApprovals = [SELECT Id FROM Loan_Application_Approval__c WHERE Type__c = 'Base'];
            //Assert.isTrue(newLoanAppApprovals.size() > 0, 'No new Loan Application Approvals found');

            List<Loan_Application__c> lstLoanApp = [Select Id, BRE_Decision__c, Stage__c, No_Pricing_Deviation__c from Loan_Application__c limit 1];
            lstLoanApp[0].Stage__c = 'Pricing';
            lstLoanApp[0].BRE_Decision__c = 'NSTP';
            lstLoanApp[0].No_Pricing_Deviation__c = false;
            //update lstLoanApp[0];

            System.Test.stopTest();
        }
        catch(Exception e){
            system.assertEquals('e',e.getMessage());
        }
    }
    
    @IsTest
    static void testGetPricingApprovalAuthoritiesWOMiddle() {
        
        Id branchMasterAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='T10001 Test Account1',
            Type='Queue'
        ),true); 

        // Create test data
        Trigger_Deactivation_Settings__c trigSetup = new Trigger_Deactivation_Settings__c ();
        trigSetup.AccountTeamMember_Trigger__c = true;
        trigSetup.SetupOwnerId = UserInfo.getUserId();
        insert trigSetup;
        
        List<AccountTeamMember> accountTeams = new List<AccountTeamMember>();

        Account regionAccount = new Account();
        regionAccount.Name = 'Region Account';
        regionAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Region').getRecordTypeId();
        insert regionAccount;
        
        Account branchMasterAccount = new Account();
        branchMasterAccount.Name = 'Test Account1';
        branchMasterAccount.Region__c = regionAccount.Id;
        branchMasterAccount.RecordTypeId = branchMasterAccountRTId;
        branchMasterAccount.Account_Code__c = 'T10001';
        branchMasterAccount.Branch_Queue__c = grp.Id;
        insert branchMasterAccount;
        
        Id loginUserId = UserInfo.getUserId();
        /*
        AccountTeamMember aTM_1 = new AccountTeamMember();
        aTM_1.accountId = branchMasterAccount.Id;
        aTM_1.Active__c = true;
        aTM_1.Type_of_Employment__c = 'Business';
        aTM_1.Customer_Grade__c = 'NIB';
        aTM_1.TeamMemberRole = 'Branch Manager';
        aTM_1.Approver_Level__c = 'P3';
        aTM_1.Product__c = '10201';
        aTM_1.Collateral__c = '10101';
        aTM_1.UserId = [Select Id from User where Id !=: loginUserId AND IsActive = true and Profile.Name = 'System Administrator' LIMIT 1].Id;
        accountTeams.add(aTM_1);
        */
        AccountTeamMember aTM_2 = new AccountTeamMember();
        aTM_2.accountId = regionAccount.Id;
        aTM_2.Active__c = true;
        aTM_2.Type_of_Employment__c = 'Business';
        aTM_2.Customer_Grade__c = 'NIB';
        aTM_2.TeamMemberRole = 'Region Head (RBM)';
        aTM_2.Approver_Level__c = 'P2;P3';
        aTM_2.Product__c = '10201';
        aTM_2.Collateral__c = '10101';
        aTM_2.UserId = UserInfo.getUserId();
        
        accountTeams.add(aTM_2);
        insert accountTeams;

        for (AccountTeamMember objATM : [Select Id, UserId, Product__c ,AccountId, TeamMemberRole, Account.RecordType.DeveloperName, Approver_Level__c, Deviation_Level__c,Customer_Grade__c,Collateral__c, Type_Of_Employment__c, User.IsActive, Active__c From AccountTeamMember]) {
            system.debug('Data ::: ' + objATM);
        }
        
        List<Loan_Application__c> loanAppsParam = new List<Loan_Application__c>();

        Loan_Application__c loanApp1 = new Loan_Application__c();
        loanApp1.Name = 'Loan App 1';
        loanApp1.ROI__c = 29;
        loanApp1.RBP__c = 30;
        loanApp1.Product__c = '10201';
        loanApp1.Branch_Master__c = branchMasterAccount.Id;
        loanApp1.Customer_Grade__c = 'NIB';
        loanApp1.recordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Four_Wheeler').getRecordTypeId();
        loanAppsParam.add(loanApp1);

        Loan_Application__c loanApp2 = new Loan_Application__c();
        loanApp2.Name = 'Loan App 2';
       	loanApp2.ROI__c = 30;
        loanApp2.RBP__c = 29;
        loanApp2.Product__c = '10202';
        loanApp2.Branch_Master__c = branchMasterAccount.Id;
        //loanAppsParam.add(loanApp2);
        
        Loan_Application__c loanApp3 = new Loan_Application__c();
        loanApp3.Name = 'Loan App 3';
        loanApp3.ROI__c = 29;
        loanApp2.RBP__c = 30;
        loanApp2.Product__c = '10203';
        loanApp2.Branch_Master__c = branchMasterAccount.Id;
        //loanAppsParam.add(loanApp3);
        
        insert loanAppsParam;

        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppsParam[0].Id,
            Customer_Grade__c ='NIB',
            Customer_Type__c ='Individual',
            KYC_Type__c='Driving License',
            AU_Employee__c = 'Yes',
            AU_Employment_status__c='Active',
            Date_of_Joining__c = System.today().addDays(-60),
            Education_qualification__c='GRADUATE',
            Type_Of_Employment__c = 'Business',
            RecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);

        // Collateral Insertion
        Collateral__c  collateralNew = (Collateral__c)TestFactory.createSObject(new Collateral__c (
            Loan__c =loanAppsParam[0].Id,
            //MMV_Master__c =mmvMaster.Id,
            Vehicle_Number__c='TN12345567',
            Certified_Value__c='1234',
            Collateral_Name__c ='10101',
            Pincode__c = '302026',
            City__c = 'Jaipur',
            Registration_City__c = 'Jaipur',
            Engine_Category__c ='BS6',
            Insurance_Expiry_Date__c = Date.Today().addDays(180),
            RecordTypeId=Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId()
        ), true);

        collateralNew = (Collateral__c)TestFactory.createSObject(new Collateral__c (
            Loan__c =loanAppsParam[0].Id,
            //MMV_Master__c =mmvMaster.Id,
            Vehicle_Number__c='TN12345568',
            Certified_Value__c='12345',
            Collateral_Name__c ='10101',
            Pincode__c = '302026',
            City__c = 'Jaipur',
            Registration_City__c = 'Jaipur',
            Engine_Category__c ='BS6',
            Insurance_Expiry_Date__c = Date.Today().addDays(180),
            RecordTypeId=Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('New').getRecordTypeId()
        ), true);

        Map<Id,Loan_Application__c> newMap = new Map<Id,Loan_Application__c>([Select Id,Name,ROI__c,RBP__c,Product__c,RecordTypeId,RecordType.Name,RecordType.DeveloperName from Loan_Application__c]);
        
        Charge__c charge1 = new Charge__c();
        charge1.Charges_Name__c = 'Processing Fees';
        charge1.Actual_rate__c = 200;
        charge1.Charge_Amount__c = 100;
        charge1.Loan_Application__c = loanAppsParam[0].Id;
        charge1.Rate_value_As_per_Policy__c = 200.0;
        insert charge1;
        
        Charge__c charge2 = new Charge__c();
        charge2.Charges_Name__c = 'Documentation Charges';
        charge2.Actual_rate__c = 200;
        charge2.Charge_Amount__c = 100;
        charge2.Loan_Application__c = loanAppsParam[0].Id;
        charge2.Rate_value_As_per_Policy__c = 200.0;
        insert charge2;
        
        Charge__c charge3 = new Charge__c();
        charge3.Charges_Name__c = 'LS Charges';
        charge3.Actual_rate__c = 200;
        charge3.Charge_Amount__c = 100;
        charge3.Loan_Application__c = loanAppsParam[0].Id;
        charge3.Rate_value_As_per_Policy__c = 200.0;
        charge3.SC_Code__c = '1265';
        insert charge3;

        Charge__c charge4 = new Charge__c();
        charge4.Charges_Name__c = 'Insurance Premium';
        charge4.Actual_rate__c = 200;
        charge4.Charge_Amount__c = 100;
        charge4.Loan_Application__c = loanAppsParam[0].Id;
        charge4.Rate_value_As_per_Policy__c = 200.0;
        charge4.SC_Code__c = '1099';
        insert charge4;
        
        List<Loan_Application_Approval__c> loanAppApprovals = new List<Loan_Application_Approval__c>();
        Loan_Application_Approval__c loanAppApproval = new Loan_Application_Approval__c();
        loanAppApproval.Loan_Application__c = loanAppsParam[0].Id;
        loanAppApproval.Approval_Type__c = 'Pricing';
        loanAppApproval.Archived__c = false;
        loanAppApproval.Type__c = 'Highest';
        loanAppApproval.Assigned_to_Queue__c = true;
        loanAppApproval.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
        loanAppApproval.Approver_Level__c  = 'P3'; 
        loanAppApprovals.add(loanAppApproval);

        try{
            /*
            Loan_Application_Approval__c loanAppApprovalMiddle = new Loan_Application_Approval__c();
            loanAppApprovalMiddle.Loan_Application__c = loanAppsParam[0].Id;
            loanAppApprovalMiddle.Approval_Type__c = 'Pricing';
            loanAppApprovalMiddle.Archived__c = false;
            loanAppApprovalMiddle.Type__c = 'Middle';
            loanAppApprovalMiddle.Assigned_to_Queue__c = true;
            loanAppApprovalMiddle.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
            loanAppApprovalMiddle.Approver_Level__c  = 'P2'; 
            loanAppApprovals.add(loanAppApprovalMiddle);
            insert loanAppApprovals;
            */
            Id applicantRecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
            Applicant__c applicant = new Applicant__c();
            applicant.Loan__c = loanAppsParam[0].Id;
            applicant.RecordTypeId = applicantRecordTypeId;
            applicant.Type_Of_Employment__c = 'Business';
            applicant.Customer_Grade__c = 'IB';
            //insert applicant;
            
            System.Test.startTest();
            //Map<String,String> returnMap = LosPricingApproval.getPricingApprovalAuthorities(newMap);
            
            Set<Id> newSetLoanAppId = newMap.keySet();
            Loan_Application__c la = [Select Id, Customer_Grade__c, Branch_Master__r.Region__c from Loan_Application__c];
            Applicant__c apct = [Select Id, Customer_Grade__c, Type_Of_Employment__c from Applicant__c];
            system.assertEquals('NIB',la.Customer_Grade__c);
            system.assertEquals(regionAccount.Id,la.Branch_Master__r.Region__c);
            system.assertEquals('NIB',apct.Customer_Grade__c);
            system.assertEquals('Business',apct.Type_Of_Employment__c);
            LosPricingApproval.callLoanApplicationAssignmentHelperMethod(newSetLoanAppId);
            
            List<Loan_Application_Approval__c> newLoanAppApprovals = [SELECT Id FROM Loan_Application_Approval__c WHERE Type__c = 'Base'];
            //Assert.isTrue(newLoanAppApprovals.size() > 0, 'No new Loan Application Approvals found');

            List<Loan_Application__c> lstLoanApp = [Select Id, BRE_Decision__c, Stage__c, No_Pricing_Deviation__c from Loan_Application__c limit 1];
            lstLoanApp[0].Stage__c = 'Pricing';
            lstLoanApp[0].BRE_Decision__c = 'NSTP';
            lstLoanApp[0].No_Pricing_Deviation__c = false;
            //update lstLoanApp[0];

            System.Test.stopTest();
        }
        catch(Exception e){
            system.assertEquals('e',e.getMessage() + ' Line  ' + e.getLineNumber());
        }
    }
    

    @IsTest
    static void testGetPricingApprovalAuthoritiesWOMiddle2() {
        
        Id branchMasterAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='T10001 Test Account1',
            Type='Queue'
        ),true); 

        // Create test data
        Trigger_Deactivation_Settings__c trigSetup = new Trigger_Deactivation_Settings__c ();
        trigSetup.AccountTeamMember_Trigger__c = true;
        trigSetup.SetupOwnerId = UserInfo.getUserId();
        insert trigSetup;
        
        List<AccountTeamMember> accountTeams = new List<AccountTeamMember>();

        Account regionAccount = new Account();
        regionAccount.Name = 'Region Account';
        regionAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Region').getRecordTypeId();
        insert regionAccount;
        
        Account branchMasterAccount = new Account();
        branchMasterAccount.Name = 'Test Account1';
        branchMasterAccount.Region__c = regionAccount.Id;
        branchMasterAccount.RecordTypeId = branchMasterAccountRTId;
        branchMasterAccount.Account_Code__c = 'T10001';
        branchMasterAccount.Branch_Queue__c = grp.Id;
        insert branchMasterAccount;
        
        Id loginUserId = UserInfo.getUserId();
        /*
        AccountTeamMember aTM_1 = new AccountTeamMember();
        aTM_1.accountId = branchMasterAccount.Id;
        aTM_1.Active__c = true;
        aTM_1.Type_of_Employment__c = 'Business';
        aTM_1.Customer_Grade__c = 'NIB';
        aTM_1.TeamMemberRole = 'Branch Manager';
        aTM_1.Approver_Level__c = 'P5';
        aTM_1.Product__c = '10201';
        aTM_1.Collateral__c = '10101';
        aTM_1.UserId = [Select Id from User where Id !=: loginUserId AND IsActive = true and Profile.Name = 'System Administrator' LIMIT 1].Id;
        accountTeams.add(aTM_1);
        */
        AccountTeamMember aTM_2 = new AccountTeamMember();
        aTM_2.accountId = regionAccount.Id;
        aTM_2.Active__c = true;
        aTM_2.Type_of_Employment__c = 'Business';
        aTM_2.Customer_Grade__c = 'NIB';
        aTM_2.TeamMemberRole = 'Region Head (RBM)';
        aTM_2.Approver_Level__c = 'P6;P7';
        aTM_2.Product__c = '10201';
        aTM_2.Collateral__c = '10101';
        aTM_2.UserId = UserInfo.getUserId();
        accountTeams.add(aTM_2);
        insert accountTeams;

        for (AccountTeamMember objATM : [Select Id, UserId, Product__c ,AccountId, TeamMemberRole, Account.RecordType.DeveloperName, Approver_Level__c, Deviation_Level__c,Customer_Grade__c,Collateral__c, Type_Of_Employment__c, User.IsActive, Active__c From AccountTeamMember]) {
            system.debug('Data ::: ' + objATM);
        }
        
        List<Loan_Application__c> loanAppsParam = new List<Loan_Application__c>();

        Loan_Application__c loanApp1 = new Loan_Application__c();
        loanApp1.Name = 'Loan App 1';
        loanApp1.ROI__c = 29;
        loanApp1.RBP__c = 30;
        loanApp1.Product__c = '10201';
        loanApp1.Branch_Master__c = branchMasterAccount.Id;
        loanApp1.Customer_Grade__c = 'NIB';
        loanApp1.recordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Four_Wheeler').getRecordTypeId();
        loanAppsParam.add(loanApp1);

        Loan_Application__c loanApp2 = new Loan_Application__c();
        loanApp2.Name = 'Loan App 2';
       	loanApp2.ROI__c = 30;
        loanApp2.RBP__c = 29;
        loanApp2.Product__c = '10202';
        loanApp2.Branch_Master__c = branchMasterAccount.Id;
        //loanAppsParam.add(loanApp2);
        
        Loan_Application__c loanApp3 = new Loan_Application__c();
        loanApp3.Name = 'Loan App 3';
        loanApp3.ROI__c = 29;
        loanApp2.RBP__c = 30;
        loanApp2.Product__c = '10203';
        loanApp2.Branch_Master__c = branchMasterAccount.Id;
        //loanAppsParam.add(loanApp3);
        
        insert loanAppsParam;

        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppsParam[0].Id,
            Customer_Grade__c ='NIB',
            Customer_Type__c ='Individual',
            KYC_Type__c='Driving License',
            AU_Employee__c = 'Yes',
            AU_Employment_status__c='Active',
            Date_of_Joining__c = System.today().addDays(-60),
            Education_qualification__c='GRADUATE',
            Type_Of_Employment__c = 'Business',
            RecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);

        // Collateral Insertion
        Collateral__c  collateralNew = (Collateral__c)TestFactory.createSObject(new Collateral__c (
            Loan__c =loanAppsParam[0].Id,
            //MMV_Master__c =mmvMaster.Id,
            Vehicle_Number__c='TN12345567',
            Certified_Value__c='1234',
            Collateral_Name__c ='10101',
            Pincode__c = '302026',
            City__c = 'Jaipur',
            Registration_City__c = 'Jaipur',
            Engine_Category__c ='BS6',
            Insurance_Expiry_Date__c = Date.Today().addDays(180),
            RecordTypeId=Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId()
        ), true);

        collateralNew = (Collateral__c)TestFactory.createSObject(new Collateral__c (
            Loan__c =loanAppsParam[0].Id,
            //MMV_Master__c =mmvMaster.Id,
            Vehicle_Number__c='TN12345568',
            Certified_Value__c='12345',
            Collateral_Name__c ='10101',
            Pincode__c = '302026',
            City__c = 'Jaipur',
            Registration_City__c = 'Jaipur',
            Engine_Category__c ='BS6',
            Insurance_Expiry_Date__c = Date.Today().addDays(180),
            RecordTypeId=Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('New').getRecordTypeId()
        ), true);

        Map<Id,Loan_Application__c> newMap = new Map<Id,Loan_Application__c>([Select Id,Name,ROI__c,RBP__c,Product__c,RecordTypeId,RecordType.Name,RecordType.DeveloperName from Loan_Application__c]);
        
        Charge__c charge1 = new Charge__c();
        charge1.Charges_Name__c = 'Processing Fees';
        charge1.Actual_rate__c = 200;
        charge1.Charge_Amount__c = 100;
        charge1.Loan_Application__c = loanAppsParam[0].Id;
        charge1.Rate_value_As_per_Policy__c = 200.0;
        insert charge1;
        
        Charge__c charge2 = new Charge__c();
        charge2.Charges_Name__c = 'Documentation Charges';
        charge2.Actual_rate__c = 200;
        charge2.Charge_Amount__c = 100;
        charge2.Loan_Application__c = loanAppsParam[0].Id;
        charge2.Rate_value_As_per_Policy__c = 200.0;
        insert charge2;
        
        Charge__c charge3 = new Charge__c();
        charge3.Charges_Name__c = 'LS Charges';
        charge3.Actual_rate__c = 200;
        charge3.Charge_Amount__c = 100;
        charge3.Loan_Application__c = loanAppsParam[0].Id;
        charge3.Rate_value_As_per_Policy__c = 200.0;
        charge3.SC_Code__c = '1265';
        insert charge3;

        Charge__c charge4 = new Charge__c();
        charge4.Charges_Name__c = 'Insurance Premium';
        charge4.Actual_rate__c = 200;
        charge4.Charge_Amount__c = 100;
        charge4.Loan_Application__c = loanAppsParam[0].Id;
        charge4.Rate_value_As_per_Policy__c = 200.0;
        charge4.SC_Code__c = '1099';
        insert charge4;
        
        List<Loan_Application_Approval__c> loanAppApprovals = new List<Loan_Application_Approval__c>();
        Loan_Application_Approval__c loanAppApproval = new Loan_Application_Approval__c();
        loanAppApproval.Loan_Application__c = loanAppsParam[0].Id;
        loanAppApproval.Approval_Type__c = 'Pricing';
        loanAppApproval.Archived__c = false;
        loanAppApproval.Type__c = 'Highest';
        loanAppApproval.Assigned_to_Queue__c = true;
        loanAppApproval.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
        loanAppApproval.Approver_Level__c  = 'P4'; 
        loanAppApprovals.add(loanAppApproval);

        try{
            /*
            Loan_Application_Approval__c loanAppApprovalMiddle = new Loan_Application_Approval__c();
            loanAppApprovalMiddle.Loan_Application__c = loanAppsParam[0].Id;
            loanAppApprovalMiddle.Approval_Type__c = 'Pricing';
            loanAppApprovalMiddle.Archived__c = false;
            loanAppApprovalMiddle.Type__c = 'Middle';
            loanAppApprovalMiddle.Assigned_to_Queue__c = true;
            loanAppApprovalMiddle.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
            loanAppApprovalMiddle.Approver_Level__c  = 'P2'; 
            loanAppApprovals.add(loanAppApprovalMiddle);
            insert loanAppApprovals;
            */
            Id applicantRecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
            Applicant__c applicant = new Applicant__c();
            applicant.Loan__c = loanAppsParam[0].Id;
            applicant.RecordTypeId = applicantRecordTypeId;
            applicant.Type_Of_Employment__c = 'Business';
            applicant.Customer_Grade__c = 'IB';
            //insert applicant;
            
            System.Test.startTest();
            //Map<String,String> returnMap = LosPricingApproval.getPricingApprovalAuthorities(newMap);
            
            Set<Id> newSetLoanAppId = newMap.keySet();
            Loan_Application__c la = [Select Id, Customer_Grade__c, Branch_Master__r.Region__c from Loan_Application__c];
            Applicant__c apct = [Select Id, Customer_Grade__c, Type_Of_Employment__c from Applicant__c];
            system.assertEquals('NIB',la.Customer_Grade__c);
            system.assertEquals(regionAccount.Id,la.Branch_Master__r.Region__c);
            system.assertEquals('NIB',apct.Customer_Grade__c);
            system.assertEquals('Business',apct.Type_Of_Employment__c);
            LosPricingApproval.callLoanApplicationAssignmentHelperMethod(newSetLoanAppId);
            
            List<Loan_Application_Approval__c> newLoanAppApprovals = [SELECT Id FROM Loan_Application_Approval__c WHERE Type__c = 'Base'];
            //Assert.isTrue(newLoanAppApprovals.size() > 0, 'No new Loan Application Approvals found');

            List<Loan_Application__c> lstLoanApp = [Select Id, BRE_Decision__c, Stage__c, No_Pricing_Deviation__c from Loan_Application__c limit 1];
            lstLoanApp[0].Stage__c = 'Pricing';
            lstLoanApp[0].BRE_Decision__c = 'NSTP';
            lstLoanApp[0].No_Pricing_Deviation__c = false;
            //update lstLoanApp[0];

            System.Test.stopTest();
        }
        catch(Exception e){
            system.assertEquals('e',e.getMessage() + ' Line  ' + e.getLineNumber());
        }
    }
    
    
    @IsTest
    static void testGetPricingApprovalAuthoritiesUsed() {
        
        Id branchMasterAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='T10001 Test Account1',
            Type='Queue'
        ),true); 

        // Create test data
        Trigger_Deactivation_Settings__c trigSetup = new Trigger_Deactivation_Settings__c ();
        trigSetup.AccountTeamMember_Trigger__c = true;
        trigSetup.SetupOwnerId = UserInfo.getUserId();
        insert trigSetup;
        
        List<AccountTeamMember> accountTeams = new List<AccountTeamMember>();

        Account regionAccount = new Account();
        regionAccount.Name = 'Region Account';
        regionAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Region').getRecordTypeId();
        insert regionAccount;
        
        Account branchMasterAccount = new Account();
        branchMasterAccount.Name = 'Test Account1';
        branchMasterAccount.Region__c = regionAccount.Id;
        branchMasterAccount.RecordTypeId = branchMasterAccountRTId;
        branchMasterAccount.Account_Code__c = 'T10001';
        branchMasterAccount.Branch_Queue__c = grp.Id;
        insert branchMasterAccount;
                
        AccountTeamMember aTM_1 = new AccountTeamMember();
        aTM_1.accountId = branchMasterAccount.Id;
        aTM_1.Active__c = true;
        aTM_1.Type_of_Employment__c = 'Business';
        aTM_1.Customer_Grade__c = 'IB';
        aTM_1.TeamMemberRole = 'Branch Manager';
        aTM_1.Approver_Level__c = 'P6';
        aTM_1.Product__c = '10201';
        aTM_1.Collateral__c = '10101';
        aTM_1.UserId = UserInfo.getUserId();
        accountTeams.add(aTM_1);
        
        AccountTeamMember aTM_2 = new AccountTeamMember();
        aTM_2.accountId = regionAccount.Id;
        aTM_2.Active__c = true;
        aTM_2.Type_of_Employment__c = 'Business';
        aTM_2.Customer_Grade__c = 'IB';
        aTM_2.TeamMemberRole = 'Region Head (RBM)';
        aTM_2.Approver_Level__c = 'P7';
        aTM_2.Product__c = '10201';
        aTM_2.Collateral__c = '10101';
        aTM_2.UserId = UserInfo.getUserId();
        
        accountTeams.add(aTM_2);
        insert accountTeams;
        
        List<Loan_Application__c> loanAppsParam = new List<Loan_Application__c>();

        Loan_Application__c loanApp1 = new Loan_Application__c();
        loanApp1.Name = 'Loan App 1';
        loanApp1.ROI__c = 29;
        loanApp1.RBP__c = 30;
        loanApp1.Product__c = '10203';
        loanApp1.Branch_Master__c = branchMasterAccount.Id;
        loanApp1.Customer_Grade__c = 'IB';
        loanAppsParam.add(loanApp1);

        Loan_Application__c loanApp2 = new Loan_Application__c();
        loanApp2.Name = 'Loan App 2';
       	loanApp2.ROI__c = 30;
        loanApp2.RBP__c = 29;
        loanApp2.Product__c = '10203';
        //loanAppsParam.add(loanApp2);
        
        Loan_Application__c loanApp3 = new Loan_Application__c();
        loanApp3.Name = 'Loan App 3';
        loanApp3.ROI__c = 29;
        loanApp3.RBP__c = 30;
        loanApp3.Product__c = '10203';
        //loanAppsParam.add(loanApp3);
        
        insert loanAppsParam;
        Deviation__c  dev = (Deviation__c)TestFactory.createSObject(new Deviation__c(
            Loan_Application__c  = loanApp1.id , Active__c  = true,Archived__c=false,Deviation_Type__c  ='Motor Insurance'
        ),true);
        

        // Collateral Insertion
        Collateral__c  collateralNew = (Collateral__c)TestFactory.createSObject(new Collateral__c (
            Loan__c =loanAppsParam[0].Id,
            //MMV_Master__c =mmvMaster.Id,
            Vehicle_Number__c='TN12345567',
            Certified_Value__c='1234',
            Collateral_Name__c ='10108',
            Pincode__c = '302026',
            City__c = 'Jaipur',
            Registration_City__c = 'Jaipur',
            Engine_Category__c ='BS6',
            Insurance_Expiry_Date__c = Date.Today().addDays(180),
            RecordTypeId=Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId()
        ), true);

        Map<Id,Loan_Application__c> newMap = new Map<Id,Loan_Application__c>([Select Id,Name,ROI__c,RBP__c,Product__c,RecordTypeId,RecordType.Name,RecordType.DeveloperName from Loan_Application__c]);
        
        Charge__c charge1 = new Charge__c();
        charge1.Charges_Name__c = 'Processing Fees';
        charge1.Actual_rate__c = 200;
        charge1.Charge_Amount__c = 0;
        charge1.Loan_Application__c = loanAppsParam[0].Id;
        charge1.Rate_value_As_per_Policy__c = 200.0;
        charge1.SC_Code__c = '1042';
        insert charge1;
        
        Charge__c charge2 = new Charge__c();
        charge2.Charges_Name__c = 'Documentation Charges';
        charge2.Actual_rate__c = 200;
        charge2.Charge_Amount__c = 100;
        charge2.Loan_Application__c = loanAppsParam[0].Id;
        charge2.Rate_value_As_per_Policy__c = 200.0;
        charge2.SC_Code__c = '1002';
        insert charge2;

        Charge__c charge4 = new Charge__c();
        charge4.Charges_Name__c = 'Insurance Premium';
        charge4.Actual_rate__c = 200;
        charge4.Charge_Amount__c = 100;
        charge4.Loan_Application__c = loanAppsParam[0].Id;
        charge4.Rate_value_As_per_Policy__c = 200.0;
        charge4.SC_Code__c = '1099';
        insert charge4;        
        
        Charge__c charge3 = new Charge__c();
        charge3.Charges_Name__c = 'LS Charges';
        charge3.Actual_rate__c = 200;
        charge3.Charge_Amount__c = 0;
        charge3.Loan_Application__c = loanAppsParam[0].Id;
        charge3.Rate_value_As_per_Policy__c = 200.0;
        charge3.SC_Code__c = '1265';
        insert charge3;
        
        List<Loan_Application_Approval__c> loanAppApprovals = new List<Loan_Application_Approval__c>();
        Loan_Application_Approval__c loanAppApproval = new Loan_Application_Approval__c();
        loanAppApproval.Loan_Application__c = loanAppsParam[0].Id;
        loanAppApproval.Approval_Type__c = 'Pricing';
        loanAppApproval.Archived__c = false;
        loanAppApproval.Type__c = 'Highest';
        loanAppApproval.Assigned_to_Queue__c = true;
        loanAppApproval.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
        loanAppApproval.Approver_Level__c  = 'P3'; 
        loanAppApprovals.add(loanAppApproval);

        try{
            
            Loan_Application_Approval__c loanAppApprovalMiddle = new Loan_Application_Approval__c();
            loanAppApprovalMiddle.Loan_Application__c = loanAppsParam[0].Id;
            loanAppApprovalMiddle.Approval_Type__c = 'Pricing';
            loanAppApprovalMiddle.Archived__c = false;
            loanAppApprovalMiddle.Type__c = 'Middle';
            loanAppApprovalMiddle.Assigned_to_Queue__c = true;
            loanAppApprovalMiddle.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
            loanAppApprovalMiddle.Approver_Level__c  = 'P3'; 
            loanAppApprovals.add(loanAppApprovalMiddle);
            insert loanAppApprovals;
            
            Id applicantRecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
            Applicant__c applicant = new Applicant__c();
            applicant.Loan__c = loanAppsParam[0].Id;
            applicant.RecordTypeId = applicantRecordTypeId;
            applicant.Type_Of_Employment__c = 'Business';
            applicant.Customer_Grade__c = 'IB';
            insert applicant;
            
            Map<String,String> returnMap = LosPricingApproval.getPricingApprovalAuthorities(newMap);
            Set<Id> newSetLoanAppId = newMap.keySet();
            
            System.Test.startTest();
            LosPricingApproval.callLoanApplicationAssignmentHelperMethod(newSetLoanAppId);
            
            List<Loan_Application_Approval__c> newLoanAppApprovals = [SELECT Id FROM Loan_Application_Approval__c WHERE Type__c = 'Base'];
            //Assert.isTrue(newLoanAppApprovals.size() > 0, 'No new Loan Application Approvals found');

            List<Loan_Application__c> lstLoanApp = [Select Id, BRE_Decision__c, Stage__c, No_Pricing_Deviation__c from Loan_Application__c limit 1];
            lstLoanApp[0].Stage__c = 'Pricing';
            lstLoanApp[0].BRE_Decision__c = 'NSTP';
            lstLoanApp[0].No_Pricing_Deviation__c = false;
            update lstLoanApp[0];

            System.Test.stopTest();
        }
        catch(Exception e){
            system.assertEquals('e',e.getMessage());
        }
    }

    @IsTest
    static void testGetPricingApprovalAuthoritiesUsedMotor() {
        
        Id branchMasterAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
        
        Group grp = (Group )TestFactory.createSObject(new Group (
            Name ='T10001 Test Account1',
            Type='Queue'
        ),true); 

        // Create test data
        Trigger_Deactivation_Settings__c trigSetup = new Trigger_Deactivation_Settings__c ();
        trigSetup.AccountTeamMember_Trigger__c = true;
        trigSetup.SetupOwnerId = UserInfo.getUserId();
        insert trigSetup;
        
        List<AccountTeamMember> accountTeams = new List<AccountTeamMember>();

        Account regionAccount = new Account();
        regionAccount.Name = 'Region Account';
        regionAccount.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Region').getRecordTypeId();
        insert regionAccount;
        
        Account branchMasterAccount = new Account();
        branchMasterAccount.Name = 'Test Account1';
        branchMasterAccount.Region__c = regionAccount.Id;
        branchMasterAccount.RecordTypeId = branchMasterAccountRTId;
        branchMasterAccount.Account_Code__c = 'T10001';
        branchMasterAccount.Branch_Queue__c = grp.Id;
        insert branchMasterAccount;
                
        AccountTeamMember aTM_1 = new AccountTeamMember();
        aTM_1.accountId = branchMasterAccount.Id;
        aTM_1.Active__c = true;
        aTM_1.Type_of_Employment__c = 'Business';
        aTM_1.Customer_Grade__c = 'IB';
        aTM_1.TeamMemberRole = 'Branch Manager';
        aTM_1.Approver_Level__c = 'P6';
        aTM_1.Product__c = '10201';
        aTM_1.Collateral__c = '10101';
        aTM_1.UserId = UserInfo.getUserId();
        accountTeams.add(aTM_1);
        
        AccountTeamMember aTM_2 = new AccountTeamMember();
        aTM_2.accountId = regionAccount.Id;
        aTM_2.Active__c = true;
        aTM_2.Type_of_Employment__c = 'Business';
        aTM_2.Customer_Grade__c = 'IB';
        aTM_2.TeamMemberRole = 'Region Head (RBM)';
        aTM_2.Approver_Level__c = 'P7';
        aTM_2.Product__c = '10201';
        aTM_2.Collateral__c = '10101';
        aTM_2.UserId = UserInfo.getUserId();
        
        accountTeams.add(aTM_2);
        insert accountTeams;
        
        List<Loan_Application__c> loanAppsParam = new List<Loan_Application__c>();

        Loan_Application__c loanApp1 = new Loan_Application__c();
        loanApp1.Name = 'Loan App 1';
        loanApp1.ROI__c = 29;
        loanApp1.RBP__c = 30;
        loanApp1.Product__c = '10203';
        loanApp1.Branch_Master__c = branchMasterAccount.Id;
        loanApp1.Customer_Grade__c = 'IB';
        loanApp1.recordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Four_Wheeler').getRecordTypeId();
        loanAppsParam.add(loanApp1);

        Loan_Application__c loanApp2 = new Loan_Application__c();
        loanApp2.Name = 'Loan App 2';
       	loanApp2.ROI__c = 30;
        loanApp2.RBP__c = 29;
        loanApp2.Product__c = '10203';
        //loanAppsParam.add(loanApp2);
        
        Loan_Application__c loanApp3 = new Loan_Application__c();
        loanApp3.Name = 'Loan App 3';
        loanApp3.ROI__c = 29;
        loanApp3.RBP__c = 30;
        loanApp3.Product__c = '10203';
        //loanAppsParam.add(loanApp3);
        
        insert loanAppsParam;

        // Collateral Insertion
        Collateral__c  collateralNew = (Collateral__c)TestFactory.createSObject(new Collateral__c (
            Loan__c =loanAppsParam[0].Id,
            //MMV_Master__c =mmvMaster.Id,
            Vehicle_Number__c='TN12345567',
            Certified_Value__c='1234',
            Collateral_Name__c ='10108',
            Pincode__c = '302026',
            City__c = 'Jaipur',
            Registration_City__c = 'Jaipur',
            Engine_Category__c ='BS6',
            Insurance_Expiry_Date__c = Date.Today().addDays(10),
            RecordTypeId=Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId()
        ), true);

        Map<Id,Loan_Application__c> newMap = new Map<Id,Loan_Application__c>([Select Id,Name,ROI__c,RBP__c,Product__c,RecordTypeId,RecordType.Name,RecordType.DeveloperName from Loan_Application__c]);
        
        Charge__c charge1 = new Charge__c();
        charge1.Charges_Name__c = 'Processing Fees';
        charge1.Actual_rate__c = 200;
        charge1.Charge_Amount__c = 0;
        charge1.Loan_Application__c = loanAppsParam[0].Id;
        charge1.Rate_value_As_per_Policy__c = 200.0;
        charge1.SC_Code__c = '1042';
        insert charge1;
        
        Charge__c charge2 = new Charge__c();
        charge2.Charges_Name__c = 'Documentation Charges';
        charge2.Actual_rate__c = 200;
        charge2.Charge_Amount__c = 100;
        charge2.Loan_Application__c = loanAppsParam[0].Id;
        charge2.Rate_value_As_per_Policy__c = 200.0;
        charge2.SC_Code__c = '1002';
        insert charge2;

        Charge__c charge4 = new Charge__c();
        charge4.Charges_Name__c = 'Insurance Premium';
        charge4.Actual_rate__c = 200;
        charge4.Charge_Amount__c = 0;
        charge4.Loan_Application__c = loanAppsParam[0].Id;
        charge4.Rate_value_As_per_Policy__c = 200.0;
        charge4.SC_Code__c = '1099';
        insert charge4;

        
        
        Charge__c charge3 = new Charge__c();
        charge3.Charges_Name__c = 'LS Charges';
        charge3.Actual_rate__c = 200;
        charge3.Charge_Amount__c = 0;
        charge3.Loan_Application__c = loanAppsParam[0].Id;
        charge3.Rate_value_As_per_Policy__c = 200.0;
        charge3.SC_Code__c = '1265';
        insert charge3;
        
        List<Loan_Application_Approval__c> loanAppApprovals = new List<Loan_Application_Approval__c>();
        Loan_Application_Approval__c loanAppApproval = new Loan_Application_Approval__c();
        loanAppApproval.Loan_Application__c = loanAppsParam[0].Id;
        loanAppApproval.Approval_Type__c = 'Pricing';
        loanAppApproval.Archived__c = false;
        loanAppApproval.Type__c = 'Highest';
        loanAppApproval.Assigned_to_Queue__c = true;
        loanAppApproval.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
        loanAppApproval.Approver_Level__c  = 'P3'; 
        loanAppApprovals.add(loanAppApproval);

        try{
            
            Loan_Application_Approval__c loanAppApprovalMiddle = new Loan_Application_Approval__c();
            loanAppApprovalMiddle.Loan_Application__c = loanAppsParam[0].Id;
            loanAppApprovalMiddle.Approval_Type__c = 'Pricing';
            loanAppApprovalMiddle.Archived__c = false;
            loanAppApprovalMiddle.Type__c = 'Middle';
            loanAppApprovalMiddle.Assigned_to_Queue__c = true;
            loanAppApprovalMiddle.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
            loanAppApprovalMiddle.Approver_Level__c  = 'P3'; 
            loanAppApprovals.add(loanAppApprovalMiddle);
            insert loanAppApprovals;
            
            Id applicantRecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId();
            Applicant__c applicant = new Applicant__c();
            applicant.Loan__c = loanAppsParam[0].Id;
            applicant.RecordTypeId = applicantRecordTypeId;
            applicant.Type_Of_Employment__c = 'Business';
            applicant.Customer_Grade__c = 'IB';
            insert applicant;
            
            //Map<String,String> returnMap = LosPricingApproval.getPricingApprovalAuthorities(newMap);
            
            
            System.Test.startTest();
            Set<Id> newSetLoanAppId = newMap.keySet();
            LosPricingApproval.callLoanApplicationAssignmentHelperMethod(newSetLoanAppId);
            
            List<Loan_Application_Approval__c> newLoanAppApprovals = [SELECT Id FROM Loan_Application_Approval__c WHERE Type__c = 'Base'];
            //Assert.isTrue(newLoanAppApprovals.size() > 0, 'No new Loan Application Approvals found');

            List<Loan_Application__c> lstLoanApp = [Select Id, BRE_Decision__c, Stage__c, No_Pricing_Deviation__c from Loan_Application__c limit 1];
            lstLoanApp[0].Stage__c = 'Pricing';
            lstLoanApp[0].BRE_Decision__c = 'NSTP';
            lstLoanApp[0].No_Pricing_Deviation__c = false;
            update lstLoanApp[0];

            System.Test.stopTest();
        }
        catch(Exception e){
            system.assertEquals('e',e.getMessage());
        }
    }
    
}