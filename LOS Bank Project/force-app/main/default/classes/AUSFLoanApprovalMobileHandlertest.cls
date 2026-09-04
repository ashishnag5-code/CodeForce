@isTest
public with sharing class AUSFLoanApprovalMobileHandlertest {
    @testSetup static void setup() {
        
        Profile adminProfile = [select Id,Name from profile where name = 'System Administrator'];
        User usrAdmin = (User)TestFactory.createSObject(new User(firstName = 'admin1',
                                                                 lastName = 'admin2',
                                                                 profileId = adminProfile.id,
                                                                 username = 'admin1'+UserInfo.getOrganizationId()+'@test.com',
                                                                 email = 'admin1@test.com',
                                                                 Branch_Code__c  = '2103'
                                                                ),true);
        System.runAs(usrAdmin) {
            Profile prof = [select Id,Name from profile where name like '%Credit%'];
            User usr = (User)TestFactory.createSObject(new User(firstName = 'credapp1',
                                                                lastName = 'test2',
                                                                profileId = prof.id,
                                                                username = 'test'+UserInfo.getOrganizationId()+'@test.com',
                                                                email = 'test@test.com',
                                                                Branch_Code__c  = '2103'
                                                               ),true);
            
            PermissionSet psgCredit = [Select Id from PermissionSet where Name = 'Credit_User'];
            PermissionSetAssignment assignment = new PermissionSetAssignment(
                PermissionSetId = psgCredit.Id,
                AssigneeId = usr.Id);
            insert assignment;
            
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
        User usr2 = [Select Id from User where Profile.Name like 'Sales Manager' and FirstName = 'priceapp1' and LastName = 'test2'  limit 1];
        
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
            Tenure__c = 10
        ),false);
        insert new List<Loan_Application__c> {loanAppl, loanApp2};
            
            
            
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
        
        lstLoanAppApproval.addAll(new Loan_Application_Approval__c[]{ loanAppApproval, loanAppApproval1, loanAppApproval2, loanAppApproval3, loanAppApproval4, loanAppApproval5 });
        insert lstLoanAppApproval;
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Loan__c =loanAppl.Id,
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        
    }
    
    @isTest
    public static void getLoanAppRecordTest(){
        test.startTest();
        Loan_Application__c loanObj = [SELECT Id FROM Loan_Application__c LIMIT 1];
        List<Loan_Application_Approval__c> loanapp = [SELECT Id, Remarks__c,Approver__c  FROM Loan_Application_Approval__c WHERE Approver__r.FirstName = 'credapp1' AND Approval_Type__c = 'Credit'
                                                      AND Approver_Level__c = 'L1'];
        List<String> recordIds = new List<String>{loanapp[0].Id};
            User usr = [SELECT Id FROM User WHERE Id = :loanapp[0].Approver__c];
        system.runAs(usr) {
            String recordId = AUSFLoanApprovalMobileHandler.getLoanAppRecord(loanapp[0].Id);
            System.assertEquals(String.isNotBlank(recordId), true);
        }
        
    }
        @isTest
    public static void getLoanAppRecordNegetiveTest(){
        test.startTest();
        User usr = [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        system.runAs(usr) {
            String recordId = AUSFLoanApprovalMobileHandler.getLoanAppRecord(null);
        }
        test.stopTest();
        
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
            try {
                AUSFApproverController.getApproverList(loanObj.id,loanapp[0]); 
            } catch (Exception ex) {}
            List<String> lstApproveIds = new List<String>();
            for (Loan_Application_Approval__c obj : loanapp) {
                lstApproveIds.add(obj.Id);
            }
            AUSFApproverController.approve(recordIds , 'Insert', loanapp[0]);
            AUSFApproverController.approveAction( loanapp, loanapp[0], lstApproveIds); 
            AUSFApproverController.assignNextApprover(loanapp[0].id, new Loan_Application_Approval__c());
            try {
                AUSFApproverController.assignForRelook(loanObj.id,usr.Id,'L3');
            } catch (Exception ex) {}
            //AUSFApproverController.selectNextApprover(loanObj.Id,loanapp[0].id ,loanapp[0]);
            test.stopTest();
        }
    }
    
}