@isTest
public with sharing class CreditApprovalAssignmentHandlerTest {

    static AccountTeamMember[] atmCreditMaster = new AccountTeamMember[]{
        new AccountTeamMember(
            UserId = UserInfo.getUserId(),
            Approver_Level__c = 'L0',
            Deviation_Level__c = 'S0',
            TeamMemberRole = 'Credit',
            Active__c = true
        ),
        new AccountTeamMember(
            UserId = UserInfo.getUserId(),
            Approver_Level__c = 'L4',
            Deviation_Level__c = 'S5',
            TeamMemberRole = 'Credit',
            Active__c = true
        ),
        new AccountTeamMember(
            UserId = UserInfo.getUserId(),
            Approver_Level__c = 'L4',
            Deviation_Level__c = 'S5',
            TeamMemberRole = 'Credit',
            Active__c = true
        ),
        new AccountTeamMember(
            UserId = UserInfo.getUserId(),
            Approver_Level__c = 'L2',
            Deviation_Level__c = 'S2',
            TeamMemberRole = 'Credit',
            Active__c = true
        )
    };

    static AccountTeamMember[] atmCreditMasterNoBase = new AccountTeamMember[]{
        new AccountTeamMember(
            UserId = UserInfo.getUserId(),
            Approver_Level__c = 'L4',
            Deviation_Level__c = 'S5',
            TeamMemberRole = 'Credit',
            Active__c = true
        ),
        new AccountTeamMember(
            UserId = UserInfo.getUserId(),
            Approver_Level__c = 'L7',
            Deviation_Level__c = 'S5',
            TeamMemberRole = 'Credit',
            Active__c = true
        )
    };

    static AccountTeamMember[] atmPricingMaster = new AccountTeamMember[]{
        new AccountTeamMember(
            UserId = UserInfo.getUserId(),
            Approver_Level__c = 'P2',
            TeamMemberRole = 'Pricing',
            Active__c = true
        )
    };

    @TestSetup
    static void makeData(){
        // Profile prof = [select Id,Name from profile where name like '%Credit%'];
        // User usr = (User)TestFactory.createSObject(new User(
        //     firstName = 'test1',
        //     lastName = 'test2',
        //     profileId = prof.id,
        //     username = 'user'+ Datetime.now().getTime() + UserInfo.getOrganizationId() +'@au.in',
        //     email = 'user' + Datetime.now().getTime() + '@au.in',
        //     Branch_Code__c  = '2103'
        //     ), true
        // );

        Loan_Application__c[] applications = new Loan_Application__c[]{

            (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                Application_Number__c  = 'AP-12345',
                Adhar_Card__c   = 123456,
                Loan_Amount__c  = 1000,
                Product__c='10201',
                RC_Limit_On_Hold__c=true,
                Stage__c = 'DDE',
                Final_Exposure__c = 10,
                RecordTypeId = Utility.getRecordTypeId( SObjectType.Loan_Application__c.getSobjectType(), GlobalConstants.FOURWHEELER ),
                Sanction_Status__c = 'Issued'
            ), false ),
    
            (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                Application_Number__c  = 'AP-12345',
                Adhar_Card__c   = 123456,
                Loan_Amount__c  = 1000,
                Product__c='10201',
                RC_Limit_On_Hold__c=true,
                Stage__c = 'DDE',
                Final_Exposure__c = 10,
                RecordTypeId = Utility.getRecordTypeId( SObjectType.Loan_Application__c.getSobjectType(), GlobalConstants.TWOWHEELER ),
                Sanction_Status__c = 'Issued'
            ), false )

        };
        
        insert applications;
    }

    @isTest static void validateCreditAssignment4WInt(){
        Test.startTest();

        final String BRE_APPROVAL_LEVEL = 'L3S2';
        Loan_Application__c loanApp = [ SELECT Id, BRE_Approval_Level__c, RecordType.Name FROM Loan_Application__c WHERE RecordType.Name =: GlobalConstants.FOURWHEELER LIMIT 1 ];
        loanApp.Stage__c = GlobalConstants.STAGE_CREDIT;
        loanApp.BRE_Approval_Level__c = BRE_APPROVAL_LEVEL;

        CreditApprovalAssignmentHandler.mainMethod( GlobalConstants.APPROVAL_TYPE_CREDIT, atmCreditMaster, loanApp, BRE_APPROVAL_LEVEL );
        Test.stopTest();

        Assert.areEqual(
            3,
            [ SELECT COUNT() FROM Loan_Application_Approval__c WHERE Loan_Application__c =: loanApp.Id ]
        );

    }

    @isTest static void validateCreditAssignment4WIntWithBaseHigherAuthThanBRE(){
        Test.startTest();

        final String BRE_APPROVAL_LEVEL = 'L3S2';
        Loan_Application__c loanApp = [ SELECT Id, BRE_Approval_Level__c, RecordType.Name FROM Loan_Application__c WHERE RecordType.Name =: GlobalConstants.FOURWHEELER LIMIT 1 ];
        loanApp.Stage__c = GlobalConstants.STAGE_CREDIT;
        loanApp.BRE_Approval_Level__c = BRE_APPROVAL_LEVEL;

        CreditApprovalAssignmentHandler.mainMethod( GlobalConstants.APPROVAL_TYPE_CREDIT, atmCreditMasterNoBase, loanApp, BRE_APPROVAL_LEVEL );
        Test.stopTest();

        Assert.areEqual(
            1,
            [ SELECT COUNT() FROM Loan_Application_Approval__c WHERE Loan_Application__c =: loanApp.Id ]
        );

    }

    @isTest static void validateCreditAssignment2WInt(){
        Test.startTest();

        final String BRE_APPROVAL_LEVEL = 'L4';
        Loan_Application__c loanApp = [ SELECT Id, BRE_Approval_Level__c, RecordType.Name FROM Loan_Application__c WHERE RecordType.Name =: GlobalConstants.TWOWHEELER LIMIT 1 ];
        loanApp.Stage__c = GlobalConstants.STAGE_CREDIT;
        loanApp.BRE_Approval_Level__c = BRE_APPROVAL_LEVEL;

        CreditApprovalAssignmentHandler.mainMethod( GlobalConstants.APPROVAL_TYPE_CREDIT, atmCreditMaster, loanApp, BRE_APPROVAL_LEVEL );
        Test.stopTest();
        Assert.areEqual(
            1,
            [ SELECT COUNT() FROM Loan_Application_Approval__c WHERE Loan_Application__c =: loanApp.Id ]
        );

    }

    @isTest static void validatePricingAssignment2WInt(){
        Test.startTest();

        final String BRE_APPROVAL_LEVEL = 'L4';
        Loan_Application__c loanApp = [ SELECT Id, BRE_Approval_Level__c, RecordType.Name FROM Loan_Application__c WHERE RecordType.Name =: GlobalConstants.TWOWHEELER LIMIT 1 ];
        loanApp.Stage__c = GlobalConstants.STAGE_CREDIT;
        loanApp.BRE_Approval_Level__c = BRE_APPROVAL_LEVEL;

        CreditApprovalAssignmentHandler.mainMethod( GlobalConstants.APPROVAL_TYPE_PRICING, atmPricingMaster, loanApp, 'P2' );
        Test.stopTest();

        Assert.areEqual(
            1,
            [ SELECT COUNT() FROM Loan_Application_Approval__c WHERE Loan_Application__c =: loanApp.Id ]
        );
    }
}