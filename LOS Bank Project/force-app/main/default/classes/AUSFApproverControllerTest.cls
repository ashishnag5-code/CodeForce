@isTest
public with sharing class AUSFApproverControllerTest {
    @testSetup static void setup() {
    
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
                                                           
        SObjectType accountSObjType = SObjectType.Account.getSObjectType();
        Account regionRecord = (Account)TestFactory.createSObject(
            new Account(
                name = 'Rajasthan_01',
                Account_Code__c  = '2104',
                Branch_Queue__c = testGroup.Id,
                RecordTypeId = Utility.getRecordTypeId( accountSObjType, 'Region' )
        ),true);

        Account branchRecord = (Account)TestFactory.createSObject(
            new Account(
                name = 'admin2',
                Account_Code__c  = '2103',
                Branch_Queue__c = testGroup.Id,
                Region__c = regionRecord.Id,
                RecordTypeId = Utility.getRecordTypeId( accountSObjType, 'Branch' )
            ),true);
    
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
            User pricingUser = (User)TestFactory.createSObject(new User(firstName = 'Pricing User #2',
                lastName = '12345',
                profileId = profPricing.id,
                username = 'testprice12345'+UserInfo.getOrganizationId()+'@test.com',
                email = 'test@test.com',
                Branch_Code__c  = '2103'
            ),true);                                                               
            
             
            PermissionSet psPricing = [Select Id from PermissionSet where Name = 'Sales_Manager_User'];
            PermissionSetAssignment assignment1 = new PermissionSetAssignment(
                PermissionSetId = psPricing.Id,
                AssigneeId = usr2.Id
            );
            PermissionSetAssignment assignment2 = new PermissionSetAssignment(
                PermissionSetId = psPricing.Id,
                AssigneeId = pricingUser.Id
            );
            insert new PermissionSetAssignment[]{ assignment1, assignment2 };
            
        }
        
        User usr = [Select Id from User where Profile.Name like '%Credit%' and FirstName = 'credapp1' and LastName = 'test2'  limit 1];
        User higherAuthUser = [Select Id from User where Profile.Name like '%Credit%' and Authority_Level__c = 'L5' AND LastName = 'testL7' limit 1];
        User usr2 = [Select Id from User where Profile.Name like 'Sales Manager' and FirstName = 'priceapp1' and LastName = 'test2'  limit 1];
        User pricingUser = [Select Id from User where Profile.Name like 'Sales Manager' and FirstName = 'Pricing User #2'  limit 1];

        insert new AccountTeamMember[]{
            new AccountTeamMember(
                UserId = higherAuthUser.Id,
                AccountId = branchRecord.Id,
                TeamMemberRole = 'Credit',
                Approver_Level__c = 'L7',
                Deviation_Level__c = 'S5'
            ),
    
            new AccountTeamMember(
                UserId = higherAuthUser.Id,
                AccountId = branchRecord.Id,
                TeamMemberRole = 'Branch Manager',
                Approver_Level__c = 'P7'
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

        

        TestFactory.createSObject( new AccountTeamMember(UserId = usr.Id, AccountId = branchRecord.Id, TeamMemberRole = 'Credit', Approver_Level__c = 'L2' ) , true);
        TestFactory.createSObject( new AccountTeamMember(UserId = usr.Id, AccountId = branchRecord.Id, TeamMemberRole = 'Branch Manager', Approver_Level__c = 'P2' ) , true);
        TestFactory.createSObject( new AccountTeamMember(UserId = higherAuthUser.Id, AccountId = branchRecord.Id, TeamMemberRole = 'Credit', Approver_Level__c = 'L7', Deviation_Level__c = 'S5' ) , true);
        TestFactory.createSObject( new AccountTeamMember(UserId = higherAuthUser.Id, AccountId = regionRecord.Id, TeamMemberRole = 'Credit', Approver_Level__c = 'L8', Deviation_Level__c = 'S5' ) , true);
       
        SObjectType loanApprovalSObjType = SObjectType.Loan_Application_Approval__c.getSObjectType();
        Id creditApprovalRecordTypeId = Utility.getRecordTypeId(
                loanApprovalSObjType,
                'Credit Approver'
            ),
            pricingApprovalRecordTypeId = Utility.getRecordTypeId(
                loanApprovalSObjType,
                'Pricing Approver'
            );

        list<Loan_Application_Approval__c> lstLoanAppApproval = new List<Loan_Application_Approval__c>();
        Loan_Application_Approval__c loanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id,  Approval_Type__c = 'Credit' , Approver__c = usr.id,
            Archived__c = false, Approver_Level__c = 'L1', Type__c = 'Base', RecordTypeId = creditApprovalRecordTypeId
        ),false);
        Loan_Application_Approval__c loanAppApproval1 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id, Approver__c = usr.id , Approval_Type__c = 'Credit', Approver_Level__c = 'L2', Type__c = 'Middle', RecordTypeId = creditApprovalRecordTypeId
        ),false);
        Loan_Application_Approval__c loanAppApproval2 = (Loan_Application_Approval__c)TestFactory.createSObject(
            new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id,
            Assigned_to_Queue__c = true,
            Approver__c = usr.id,
            Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING,
            Approver_Level__c = 'L3', Approval_Type__c = 'Credit', Type__c = 'Highest', RecordTypeId = creditApprovalRecordTypeId
        ),false);
        Loan_Application_Approval__c loanAppApproval3 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanApp2.Id,  Approval_Type__c = 'Pricing' , Approver__c = usr2.id,
            Archived__c = false, Approver_Level__c = 'P1', Type__c = 'Base', RecordTypeId = pricingApprovalRecordTypeId
        ),false);
        Loan_Application_Approval__c middleloanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanApp2.Id, Approver__c = usr2.id , Approval_Type__c = 'Pricing', Approver_Level__c = 'P2', Type__c = 'Middle', RecordTypeId = pricingApprovalRecordTypeId
        ),false);
        Loan_Application_Approval__c loanAppApproval4 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanApp2.Id, Approver__c = pricingUser.id , Approval_Type__c = 'Pricing', Approver_Level__c = 'P3', Type__c = 'Middle', RecordTypeId = pricingApprovalRecordTypeId
        ),false);
        Loan_Application_Approval__c loanAppApproval5 = (Loan_Application_Approval__c)TestFactory.createSObject(
            new Loan_Application_Approval__c(
            Loan_Application__c  = loanApp2.Id,
            Approver__c = usr2.id,
            Assigned_to_Queue__c = true,
            Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING,
            Approver_Level__c = 'P3', Approval_Type__c = 'Pricing', Type__c = 'Highest', RecordTypeId = pricingApprovalRecordTypeId
        ),false);
        Loan_Application_Approval__c loanAppApproval6 = (Loan_Application_Approval__c)TestFactory.createSObject(
            new Loan_Application_Approval__c(
            Loan_Application__c  = loanApp2.Id,
            Approver__c = usr2.id,
            Approval_Status__c = 'Rejected',
            Approver_Level__c = 'P3', Approval_Type__c = 'Pricing', Type__c = 'Highest', RecordTypeId = pricingApprovalRecordTypeId
        ),false);

        lstLoanAppApproval.addAll(new Loan_Application_Approval__c[]{ loanAppApproval, loanAppApproval1, loanAppApproval2, loanAppApproval3, loanAppApproval4, middleloanAppApproval, loanAppApproval5, loanAppApproval6 });
        insert lstLoanAppApproval;
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            Caste__c = 'SC',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
        
        
        
    } 
 
    @isTest
    public static void getLADetailsTest(){
        test.startTest();
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c,Approver__c  FROM Loan_Application_Approval__c WHERE Approver__r.FirstName = 'credapp1' AND Approval_Type__c = 'Credit'
            AND Approver_Level__c = 'L1'];
        List<String> recordIds = new List<String>{loanapp[0].Id};
        User usr = [SELECT Id FROM User WHERE Id = :loanapp[0].Approver__c];
        system.runAs(usr) {
            String ApproverId = String.valueOf((loanapp[0]));
            try {
                AUSFLoanApprovalMobileHandler.getLoanAppRecord(ApproverId); 
            } catch (Exception ex) {}
            List<String> lstApproveIds = new List<String>();
            for (Loan_Application_Approval__c obj : loanapp) {
                lstApproveIds.add(obj.Id);
            }
            //AUSFApproverController.approve(recordIds , 'Insert', loanapp[0]);
            //AUSFApproverController.approveAction( loanapp, loanapp[0], lstApproveIds); 
            //AUSFApproverController.assignNextApprover(loanapp[0].id);
          
        }
    }

    @isTest
    public static void getLADetailsTestL2(){
        test.startTest();
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c,Approver__c  FROM Loan_Application_Approval__c WHERE Approver__r.FirstName = 'credapp1' AND Approval_Type__c = 'Credit'
            AND Approver_Level__c = 'L2'];
        List<String> recordIds = new List<String>{loanapp[0].Id};
        User usr = [SELECT Id FROM User WHERE Id = :loanapp[0].Approver__c];
        Loan_Application_Approval__c forwardedApproval = new Loan_Application_Approval__c(Remarks__c = 'Forwarded');
        system.runAs(usr) {
            try {
                AUSFApproverController.getApproverList(loanObj.id,loanapp[0]); 
            } catch (Exception ex) {}
            List<String> lstApproveIds = new List<String>();
            for (Loan_Application_Approval__c obj : loanapp) {
                lstApproveIds.add(obj.Id);
            }
            AUSFApproverController.approve(recordIds , 'Insert', loanapp[0]);
            AUSFApproverController.approveAction( loanapp, loanapp[0], lstApproveIds); 
            AUSFApproverController.assignNextApprover(loanapp[0].id, forwardedApproval);
            try {
                AUSFApproverController.assignForRelook(loanObj.id,usr.Id,'L3');
            } catch (Exception ex) {}
            //AUSFApproverController.selectNextApprover(loanObj.Id,loanapp[0].id ,loanapp[0]);
            test.stopTest();
        }
    }

    @isTest
    public static void getLADetailsTestL2Next(){
        test.startTest();
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c,Approver__c  FROM Loan_Application_Approval__c WHERE Approver__r.FirstName = 'credapp1' AND Approval_Type__c = 'Credit'
            AND Approver_Level__c = 'L2'];
        List<String> recordIds = new List<String>{loanapp[0].Id};
        User usr = [SELECT Id FROM User WHERE Id = :loanapp[0].Approver__c];
        system.runAs(usr) {
            AUSFApproverController.selectNextApprover(loanObj.Id,loanapp[0].id ,loanapp[0]);
            test.stopTest();
        }
    }

    @isTest
    public static void getLADetailsTestL3(){
        test.startTest();
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c,Approver__c  FROM Loan_Application_Approval__c WHERE Approver__r.FirstName = 'credapp1' AND Approval_Type__c = 'Credit'
            AND Approver_Level__c = 'L3'];
        List<String> recordIds = new List<String>{loanapp[0].Id};
        Loan_Application_Approval__c forwardedApproval = new Loan_Application_Approval__c(Remarks__c = 'Forwarded');

        User usr = [SELECT Id FROM User WHERE Id = :loanapp[0].Approver__c];
        system.runAs(usr) {
            try {
                AUSFApproverController.getApproverList(loanObj.id,loanapp[0]); 
            } catch (Exception ex) {}
            List<String> lstApproveIds = new List<String>();
            for (Loan_Application_Approval__c obj : loanapp) {
                lstApproveIds.add(obj.Id);
            }
            AUSFApproverController.approve(recordIds , 'Insert', loanapp[0]);
            AUSFApproverController.approveAction( loanapp, loanapp[0],lstApproveIds); 
            AUSFApproverController.assignNextApprover(loanapp[0].id, forwardedApproval);
            try {
                AUSFApproverController.assignForRelook(loanObj.id,usr.Id,'L3');
            } catch (Exception ex) {}
            //AUSFApproverController.selectNextApprover(loanObj.Id,loanapp[0].id ,loanapp[0]);
            test.stopTest();
        }
    }

    @isTest
    public static void getLADetailsTestPricing(){
        test.startTest();
        Loan_Application__c loanObj = [SELECT Id, BRE_Decision__c FROM Loan_Application__c WHERE Stage__c = 'Pricing' LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c,Approver__c  FROM Loan_Application_Approval__c WHERE Approver__r.FirstName = 'priceapp1' AND Approval_Type__c = 'Pricing'
            AND Approver_Level__c = 'P1'];
        List<String> recordIds = new List<String>{loanapp[0].Id};
        Loan_Application_Approval__c forwardedApproval = new Loan_Application_Approval__c(Remarks__c = 'Forwarded');

        User usr = [SELECT Id FROM User WHERE Id = :loanapp[0].Approver__c];
        system.runAs(usr) {
            try {
                AUSFApproverController.getApproverList(loanObj.id,loanapp[0]); 
            } catch (Exception ex) {}
            List<String> lstApproveIds = new List<String>();
            for (Loan_Application_Approval__c obj : loanapp) {
                lstApproveIds.add(obj.Id);
            }
            AUSFApproverController.approve(recordIds , 'Insert', loanapp[0]);
            AUSFApproverController.approveAction( loanapp, loanapp[0],lstApproveIds); 
            AUSFApproverController.assignNextApprover(loanapp[0].id, forwardedApproval);
            try {
                AUSFApproverController.assignForRelook(loanObj.id,usr.Id,'L3');
            } catch (Exception ex) {}
            AUSFApproverController.selectNextApprover(loanObj.Id,loanapp[0].id ,loanapp[0]);
            test.stopTest();
        }
    }

    @isTest static void assignForRelookTest(){
        Test.startTest();
        Loan_Application__c loanObj = [SELECT Id, BRE_Decision__c FROM Loan_Application__c WHERE Stage__c = 'Pricing' LIMIT 1 ];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c,Approver__c  FROM Loan_Application_Approval__c WHERE Approver__r.FirstName = 'priceapp1' AND Approval_Type__c = 'Pricing' AND Approver_Level__c = 'P1'];
        User usr = [SELECT Id FROM User WHERE Id = :loanapp[0].Approver__c];
        system.runAs(usr) {
            AUSFApproverController.assignForRelook( loanObj.id, usr.Id, 'L3' );
        }
        Test.stopTest();
    }
    @isTest
    public static void getLADetailsTestPricingP2(){
        test.startTest();
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c WHERE Stage__c = 'Pricing' LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c,Approver__c  FROM Loan_Application_Approval__c WHERE Approver__r.FirstName = 'priceapp1' AND Approval_Type__c = 'Pricing'
            AND Approver_Level__c = 'P2'];
        List<String> recordIds = new List<String>{loanapp[0].Id};
        Loan_Application_Approval__c forwardedApproval = new Loan_Application_Approval__c(Remarks__c = 'Forwarded');

        User usr = [SELECT Id FROM User WHERE Id = :loanapp[0].Approver__c];
        system.runAs(usr) {
            try {
                AUSFApproverController.getApproverList(loanObj.id,loanapp[0]); 
            } catch (Exception ex) {}
            List<String> lstApproveIds = new List<String>();
            for (Loan_Application_Approval__c obj : loanapp) {
                lstApproveIds.add(obj.Id);
            }
            AUSFApproverController.approve(recordIds , 'Insert', loanapp[0]);
            AUSFApproverController.approveAction( loanapp, loanapp[0],lstApproveIds); 
            AUSFApproverController.assignNextApprover(loanapp[0].id, forwardedApproval);
            try {
                AUSFApproverController.assignForRelook(loanObj.id,usr.Id,'L3');
            } catch (Exception ex) {}
            AUSFApproverController.selectNextApprover(loanObj.Id,loanapp[0].id ,loanapp[0]);
            test.stopTest();
        }
    }

    @isTest
    public static void getLADetailsTestPricingP3(){
        
        test.startTest();
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c WHERE Stage__c = 'Pricing' LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c,Approver__c  FROM Loan_Application_Approval__c WHERE Approver__r.FirstName = 'priceapp1' AND Approval_Type__c = 'Pricing'
            AND Approver_Level__c = 'P3'];
        List<String> recordIds = new List<String>{loanapp[0].Id};
        Loan_Application_Approval__c forwardedApproval = new Loan_Application_Approval__c(Remarks__c = 'Forwarded');

        User usr = [SELECT Id FROM User WHERE Id = :loanapp[0].Approver__c];
        system.runAs(usr) {
            try {
                AUSFApproverController.getApproverList(loanObj.id,loanapp[0]); 
            } catch (Exception ex) {}
            List<String> lstApproveIds = new List<String>();
            for (Loan_Application_Approval__c obj : loanapp) {
                lstApproveIds.add(obj.Id);
            }
            AUSFApproverController.approve(recordIds , 'Insert', loanapp[0]);
            AUSFApproverController.approveAction( loanapp, loanapp[0],lstApproveIds); 
            AUSFApproverController.assignNextApprover(loanapp[0].id, forwardedApproval);
            try {
                AUSFApproverController.assignForRelook(loanObj.id,usr.Id,'L3');
            } catch (Exception ex) {}
            AUSFApproverController.selectNextApprover(loanObj.Id,loanapp[0].id ,loanapp[0]);
            test.stopTest();
        }
    }

    @isTest
    public static void getLADetailsTest1(){
        test.startTest();
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c,Approver__c  FROM Loan_Application_Approval__c WHERE Approver__r.FirstName = 'credapp1'];
        List<String> recordIds = new List<String>{loanapp[0].Id};
        User usr = [SELECT Id FROM User WHERE Id = :loanapp[0].Approver__c];
        system.runAs(usr) {
            try {
                AUSFApproverController.rejectLoanApplication(loanObj.Id, loanapp[0]);
            } catch (Exception ex) {}
            test.stopTest();
        }
    }

    @isTest
    public static void getLADetailsTest2(){
        test.startTest();
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c,Approver__c  FROM Loan_Application_Approval__c WHERE Approver__r.FirstName = 'credapp1'];
        List<String> recordIds = new List<String>{loanapp[0].Id};
        User usr = [SELECT Id FROM User WHERE Id = :loanapp[0].Approver__c];
        system.runAs(usr) {
            AUSFApproverController.sendBackToRoLoanApplication(loanObj.Id, 'Test Remarks');
            try {
                AUSFApproverController.revokeDelegatedUserAccess(loanObj.Id);
            } catch (Exception ex) {}
            try {
                //AUSFApproverController.createRCMApproval(loanObj.Id);
            } catch (Exception ex) {}
            test.stopTest();
        }
    }

    /*@isTest
    public static void getLADetailsTest3(){
        test.startTest();
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c,Approver__c  FROM Loan_Application_Approval__c WHERE Approver__r.FirstName = 'credapp1'];
        List<String> recordIds = new List<String>{loanapp[0].Id};
        User usr = [SELECT Id FROM User WHERE Id = :loanapp[0].Approver__c];
        system.runAs(usr) {
            AUSFApproverController.getRelookApprovers(String.valueOf(loanObj.id)); 
            test.stopTest();
        }
    }*/

    @isTest
    public static void verifyIfCaseIsAccepted(){
        Id loanId = [ SELECT Id FROM Loan_Application__c WHERE Recordtype.Name = 'Two Wheeler' LIMIT 1 ].Id;
        Test.startTest();
        try {
            User twCreditUSer = [ SELECT Id FROM User WHERE Authority_Level__c != null LIMIT 1];
            System.runAs( twCreditUSer ){
                AUSFApproverController.acceptApprovalFromQueue(loanId);
            }
            AUSFApproverController.getLevelVsApprovers(loanId);
            // AUSFApproverController.reAssignTwoWheeler(loanId); // method no longer exist
            AUSFApproverController.getNextLowerApprovalType(new List<String>{'Highest'});
            AUSFApproverController.getNextLowerApprovalType(new List<String>{'Middle'});
            AUSFApproverController.getLoanApp(loanId);
        } catch (Exception ex) {}
        Test.stopTest();
        //Assert.areEqual(0,[ SELECT COUNT() FROM Loan_Application_Approval__c WHERE Assigned_to_Queue__c = TRUE AND Approver__c = NULL ], 'Approval should be assigned to the user & moved out of the queue');
    }

    @isTest static void getDeviationLevelTest(){
        AUSFApproverController.getDeviationLevel('L2S4');
    }

    @isTest
    public static void getLADetailsTestPricingP2Method2(){
        /*
        String strUsrName =  'testprice'+UserInfo.getOrganizationId()+'@test.com';                                                      
        user objUser = [Select id, Authority_Level__c from User where username =: strUsrName and Profile.Name like '%Credit%' Limit 1];
        system.assertEquals(true, objUser != NULL);
        objUser.Authority_Level__c = 'L2';
        update objUser;
        */
        test.startTest();
        Loan_Application__c loanObj = [SELECT Id, BRE_Decision__c FROM Loan_Application__c WHERE Stage__c = 'Pricing' LIMIT 1];
        loanObj.BRE_Decision__c = 'NSTP';
        update loanObj;
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c,Approver__c  FROM Loan_Application_Approval__c WHERE Approver__r.FirstName = 'priceapp1' AND Approval_Type__c = 'Pricing'
            AND Approver_Level__c = 'P2'];
        List<String> recordIds = new List<String>{loanapp[0].Id};
        User usr = [SELECT Id FROM User WHERE Id = :loanapp[0].Approver__c];
        system.runAs(usr) {
            try {
                AUSFApproverController.getApproverList(loanObj.id,loanapp[0]); 
            } catch (Exception ex) {}
            test.stopTest();
        }
    }
    @isTest static void selectNextApproverTest(){
        Test.startTest();
        Loan_Application__c loanObj = [SELECT Id, BRE_Decision__c FROM Loan_Application__c WHERE Stage__c = 'Credit' LIMIT 1];
        Loan_Application_Approval__c[] approval = [SELECT Id, Remarks__c,Approver__c  FROM Loan_Application_Approval__c WHERE Approver__r.FirstName = 'credapp1' AND Approval_Type__c = 'Credit' AND Approver_Level__c = 'L1'];
        AUSFApproverController.selectNextApprover(loanObj.Id, approval[0].id, new Loan_Application_Approval__c() );
        Test.stopTest();
    }

    @isTest static void approveTest(){
        Test.startTest();
        
        
        Id loanId = [ SELECT Id FROM Loan_Application__c WHERE RecordType.Name =: GlobalConstants.FOURWHEELER LIMIT 1 ].Id;
        Loan_Application_Approval__c[] approvals = [ SELECT Id FROM Loan_Application_Approval__c WHERE Loan_Application__c =: loanId AND Is_Assigned_Approver__c = FALSE ];

        Loan_Application_Approval__c approvalToUpdate = approvals[0];
        approvalToUpdate.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
        approvalToUpdate.Is_Assigned_Approver__c = true;
        approvalToUpdate.Type__c = 'Base';
        update approvalToUpdate;

        AUSFApproverController.approve( new List<Id>(new map<Id, Loan_Application_Approval__c>( approvals ).keySet()) , 'Approve', new Loan_Application_Approval__c() );
        Test.stopTest();
    }

    @isTest static void approveActionTest(){
        Test.startTest();
        Id loanId = [ SELECT Id FROM Loan_Application__c WHERE RecordType.Name =: GlobalConstants.FOURWHEELER LIMIT 1 ].Id;
        AUSFApproverController.approveAction( [ SELECT Id FROM Loan_Application_Approval__c WHERE Loan_Application__c =: loanId ], new Loan_Application_Approval__c(), new String[0]); 
        Test.stopTest();
    }
    @isTest static void verifyNextApprover(){
        Test.startTest();
        Id approvalId = [ SELECT Id FROM Loan_Application_Approval__c LIMIT 1 ].Id;
        Loan_Application_Approval__c forwardedApproval = new Loan_Application_Approval__c(Remarks__c = 'Forwarded');

        AUSFApproverController.assignNextApprover( approvalId , forwardedApproval);
        Test.stopTest();
    }
    @isTest static void verifyLoanDetails(){
        Id loanId = [ SELECT Id FROM Loan_Application__c WHERE Stage__c =: GlobalConstants.STAGE_CREDIT LIMIT 1 ].Id;

        Test.startTest();
        AUSFApproverController.loanAppWrap loanDetails = AUSFApproverController.getLoanApp( loanId );
        Test.stopTest();

        Assert.areEqual(
            GlobalConstants.STAGE_CREDIT,
            loanDetails.loanApp.Stage__c,
            'The Application from Credit Stage should have been picked'
        );

        Assert.isTrue(
            loanDetails.isCreditStage,
            'The isCreditStage flag should be true since the application is on Credit Stage'
        );
    }
    @isTest static void verifyApplicationForward2W(){
        Test.startTest();
        Id loanId = [ SELECT Id FROM Loan_Application__c WHERE Stage__c =: GlobalConstants.STAGE_CREDIT LIMIT 1 ].Id;
        Id cmUserId = [ SELECT Approver__c FROM Loan_Application_Approval__c WHERE Loan_Application__c =: loanId AND Approval_Type__c =: GlobalConstants.APPROVAL_TYPE_CREDIT LIMIT 1 ].Approver__c;
        System.runAs( new User( Id = cmUserId )){
            AUSFApproverController.shareLoanApp( loanId, UserInfo.getUserId(), 'L2S4', 'Reassign', new Loan_Application_Approval__c( Remarks__c = 'please verify financial details' ) );
        }
        Test.stopTest();
    }
    @isTest static void verifyApplicationForward(){
        Test.startTest();
        Id loanId = [ SELECT Id FROM Loan_Application__c WHERE RecordType.Name =: GlobalConstants.FOURWHEELER LIMIT 1 ].Id;
        Id cmUserId = [ SELECT Approver__c FROM Loan_Application_Approval__c WHERE Loan_Application__c =: loanId AND Approval_Type__c =: GlobalConstants.APPROVAL_TYPE_PRICING AND Approver__r.FirstName = 'Pricing User #2' LIMIT 1 ].Approver__c;
        System.runAs( new User( Id = cmUserId ) ){
            AUSFApproverController.shareLoanApp( loanId, cmUserId, 'P2', 'Forward', new Loan_Application_Approval__c( Remarks__c = 'please verify financial details' ) );
        }
        Test.stopTest();
    }
    @isTest static void getLevelVsApproversTest(){
        Test.startTest();
        Id loanId = [ SELECT Id FROM Loan_Application__c WHERE RecordType.Name =: GlobalConstants.FOURWHEELER LIMIT 1 ].Id;
        AUSFApproverController.getLevelVsApprovers( loanId );

        Test.stopTest();
    }
    @isTest static void getLevelVsApprovers2WTest(){
        Test.startTest();
        Id loanId = [ SELECT Id FROM Loan_Application__c WHERE RecordType.Name =: GlobalConstants.TWOWHEELER LIMIT 1 ].Id;
        AUSFApproverController.getLevelVsApprovers( loanId );

        Test.stopTest();
    }
    @isTest static void verifyApprovalsForTwoWheeler(){
        Test.startTest();
        Id loanId = [ SELECT Id FROM Loan_Application__c WHERE RecordType.Name =: GlobalConstants.TWOWHEELER LIMIT 1 ].Id;
        Id approverId = [ SELECT Approver__c FROM Loan_Application_Approval__c WHERE Loan_Application__c =: loanId AND Approval_Type__c =: GlobalConstants.APPROVAL_TYPE_CREDIT AND Approver__r.Authority_Level__c != null AND Type__c = 'Base' ].Approver__c;
        System.runAs( new User( Id = approverId ) ){
            AUSFApproverController.getApproverList( loanId, new Loan_Application_Approval__c() );
        }

        Test.stopTest();
    }
    @isTest static void isMovingToHigherAuthorityTest(){
        Test.startTest();
        Id atmId = [ SELECT Id, UserId FROM AccountTeamMember LIMIT 1].UserId;
        AUSFApproverController.isMovingToHigherAuthority( 'Pricing', atmId, atmId );
        AUSFApproverController.isMovingToHigherAuthority( 'Credit', 'L1S2', 'L2S4' );
        Test.stopTest();
    }
    @isTest static void getNextLowerApprovalTypeTest(){
        AUSFApproverController.getNextLowerApprovalType( new String[]{'Highest'} );
        AUSFApproverController.getNextLowerApprovalType( new String[]{'Base'} );
    }
    @isTest
    public static void rejectApprovalTest(){
        test.startTest();
        Id loanId = [ SELECT Id FROM Loan_Application__c WHERE RecordType.Name =: GlobalConstants.FOURWHEELER LIMIT 1 ].Id;
        Loan_Application_Approval__c[] approvals = [ SELECT Id, Approver__c FROM Loan_Application_Approval__c WHERE Loan_Application__c =: loanId AND Is_Assigned_Approver__c = FALSE ];

        Loan_Application_Approval__c approvalToUpdate = approvals[0];
        approvalToUpdate.Approval_Status__c = GlobalConstants.APPROVAL_STATUS_PENDING;
        approvalToUpdate.Is_Assigned_Approver__c = true;
        approvalToUpdate.Type__c = 'Base';
        update approvalToUpdate;
        System.runAs( new User( Id = approvals[0].Approver__c ) ){
            AUSFApproverController.rejectLoanApplication(loanId, new Loan_Application_Approval__c() );
        }

        test.stopTest();
    }

    @isTest static void verifyAllowAccept4WPricing(){
        Id loanId = [ SELECT Id FROM Loan_Application__c WHERE RecordType.Name =: GlobalConstants.FOURWHEELER LIMIT 1 ].Id;
        User higherAuthUser = [Select Id from User where Profile.Name like '%Credit%' and Authority_Level__c = 'L5' AND LastName = 'testL7' limit 1];
        Test.startTest();
        System.runAs( higherAuthUser ){
            AUSFApproverController.renderAcceptButton( loanId );
        }
        Test.stopTest();
    }

    @isTest static void verifyAllowAccept4WCredit(){
        Id loanId = [ SELECT Id FROM Loan_Application__c WHERE RecordType.Name =: GlobalConstants.FOURWHEELER LIMIT 1 ].Id;
        update new Loan_Application__c( Id = loanId, Stage__c = GlobalConstants.STAGE_CREDIT );

        User higherAuthUser = [Select Id from User where Profile.Name like '%Credit%' and Authority_Level__c = 'L5' AND LastName = 'testL7' limit 1];
        Test.startTest();
        System.runAs( higherAuthUser ){
            AUSFApproverController.renderAcceptButton( loanId );
        }
        Test.stopTest();
    }

    @isTest static void verifyAccept4W(){
        Id loanId = [ SELECT Id FROM Loan_Application__c WHERE RecordType.Name =: GlobalConstants.FOURWHEELER LIMIT 1 ].Id;
        // update new Loan_Application__c( Id = loanId, Stage__c = GlobalConstants.STAGE_CREDIT );

        User usr = [Select Id from User where Profile.Name like '%Credit%' and FirstName = 'credapp1' and LastName = 'test2'  limit 1];
        Test.startTest();
        System.runAs( usr ){
            AUSFApproverController.acceptApprovalHierarchyBased( loanId );
        }
        Test.stopTest();
    }
    @isTest static void verifyNextType(){
        AUSFApproverController.getNextType( new String[]{ 'Base' });
        AUSFApproverController.getCurrentUserType( new String[]{ 'Base' });

        AUSFApproverController.getNextType( new String[]{ 'Middle' });
        AUSFApproverController.getCurrentUserType( new String[]{ 'Middle' });

        AUSFApproverController.getNextType( new String[]{ 'Highest' });
        AUSFApproverController.getCurrentUserType( new String[]{ 'Highest' });
    }

    @isTest static void verifyRelook(){
        Id loanId = [ SELECT Id FROM Loan_Application__c WHERE RecordType.Name =: GlobalConstants.FOURWHEELER LIMIT 1 ].Id;

        User usr = [Select Id from User where Profile.Name like '%Credit%' and FirstName = 'credapp1' and LastName = 'test2'  limit 1];
        Test.startTest();
        System.runAs( usr ){
            AUSFApproverController.validateAndAssignForRelook( loanId );
        }
        Test.stopTest();
    }

    @isTest static void verifyRCMApproval(){

        Id loanId = [ SELECT Id FROM Loan_Application__c WHERE Branch_Master__c != NULL ].Id;

        Test.startTest();
        Loan_Application_Approval__c approval = AUSFApproverController.createRCMApproval( loanId );
        Test.stopTest();

        Assert.isNotNull( approval, 'An approval should have been sent to Regional Credit Manager' );
    }

    @isTest static void validateMemberWithLeastWork(){
        String creditUsername = 'testl7' + UserInfo.getOrganizationId() + '@test.com';
        User creditUser = [ SELECT Id FROM User WHERE Username =: creditUsername LIMIT 1 ];

        Test.startTest();
        AccountTeamMember atm = AUSFApproverController.getMemberWithLeastWork(
            new AccountTeamMember[]{ new AccountTeamMember(UserId = UserInfo.getUserId()), new AccountTeamMember(UserId = creditUser.Id ) },
            new map<Id, Integer>{ UserInfo.getUserId() => 40,  creditUser.Id => 20 }
        );
        Test.stopTest();

        Assert.areEqual( creditUser.Id, atm.UserId, 'Highest Authority credit user should be returned since the user had 20 approvals assigned' );
    }

    @isTest static void verifyApproverAuthority(){
        Id loanId = [ SELECT Id FROM Loan_Application__c WHERE Id IN ( SELECT Loan_Application__c FROM Loan_Application_Approval__c WHERE Approval_Type__c =: GlobalConstants.APPROVAL_TYPE_CREDIT  ) LIMIT 1 ].Id;

        Test.startTest();
        String approvalAuthority = AUSFApproverController.getApproverApprovalAuthority( new Set<Id>{ loanId }, GlobalConstants.APPROVAL_TYPE_CREDIT, 'L7S5' );
        Test.stopTest();

        Assert.areEqual( 'Highest', approvalAuthority, 'The current approver was highest in the hierarchy' );
    }
    
    @IsTest
    static void testCreateRCMApproval(){
        Id loanId = [ SELECT Id FROM Loan_Application__c WHERE RecordType.Name =: GlobalConstants.FOURWHEELER LIMIT 1 ].Id;
        Test.startTest();
        Loan_Application_Approval__c approval = AUSFApproverController.createRCMApproval(loanId);
        Test.stopTest();
        
    }

     @IsTest
    static void testGetMemberWithLeastWork(){
        List<AccountTeamMember> actmember = [SELECT Id, userId FROM AccountTeamMember];
        map<Id, Integer> assigneeVsAssignedCount = new map<Id, Integer>();
        Integer i= 0;
        for(AccountTeamMember act : actmember){
            assigneeVsAssignedCount.put(act.UserId,i);
            i++;
        }
        Test.startTest();
        AccountTeamMember actTest = AUSFApproverController.getMemberWithLeastWork(actmember, assigneeVsAssignedCount);
        Test.stopTest();
        
    }
    
    @IsTest
    static void testGetApproverApprovalAuthority(){
        Set<Id> loanIds = new Set<Id>();
        List<Loan_Application__c> applications = [SELECT Id FROM Loan_Application__c];
        for(Loan_Application__c application : applications){
            loanIds.add(application.Id);
        }
        Test.startTest();
        String val = AUSFApproverController.getApproverApprovalAuthority(loanIds, 'Credit', 'Base');
        Test.stopTest();
        
        
    }
    
    @IsTest
    static void testUpdateVehicleCostBasedOnValuationRecieved(){
        List<Id> loanIds = new List<Id>();
        List<Loan_Application__c> applications = [SELECT Id FROM Loan_Application__c];
        for(Loan_Application__c application : applications){
            loanIds.add(application.Id);
        }
        Collateral__c testCollateralRec = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId(),
            Loan__c = loanIds[0],
            Collateral_Type__c = 'Existing ',
            Registration_Number__c = '123456Test',
            Ex_Showroom_Price__c = 100,
            Discount__c = 10,
            Net_of_Discount_Price__c = 10,
            Final_Cost__c = 10,
            LTV_offered_On_final_cost__c = 10,
            Apportioned_Loan_Amount__c = 10,
            RTO_Taxes__c = 100.00,
            Insurance__c = 1000.00,
            Valuation_Amount__c = '1000',
            Vehicle_Cost__c = 1000,
            Other_Funding_Total__c = 0
        ),true);
        Test.startTest();
        AUSFApproverController.updateVehicleCostBasedOnValuationRecieved(loanIds[0]);
        Test.stopTest();
        
        
    }
    
    @IsTest
    static void testLevelApproverWrapper(){
        test.startTest();
        AUSFApproverController.LevelApproverWrapper testWrapper = new AUSFApproverController.LevelApproverWrapper();
        Test.stoptest();
    }

}