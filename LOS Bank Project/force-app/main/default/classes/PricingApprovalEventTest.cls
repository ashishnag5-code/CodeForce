@isTest
public class PricingApprovalEventTest {
    @testSetup static void setup() {
        Account dealerMaster = (Account)TestFactory.createSObject(new Account(
            Name ='TestAccount',
            Account_Code__c='2103',
            Purchase_City__c='Jaipur',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId()
        ),true);
        Account branchMaster = (Account)TestFactory.createSObject(new Account(
            Name ='Branch M',
            Account_Code__c='21034',
            Purchase_City__c='Jaipur',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Branch').getRecordTypeId()
        ),true);
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Non Individual',
            Stage__c ='QDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Dealer_Master__c = dealerMaster.Id,
            Branch_Master__c = branchMaster.Id,
            recordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId()
        ),false);
        //Loan Application Insertion
        Loan_Application__c loanAppl2 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Non Individual',
            Stage__c ='QDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Dealer_Master__c = dealerMaster.Id,
            Branch_Master__c = branchMaster.Id
        ),false);

        Loan_Application__c loanApplTR = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'TR-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Non Individual',
            Stage__c ='QDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Send_Back_To_RO_Stage__c='Pricing',
            Dealer_Master__c = dealerMaster.Id,
            Branch_Master__c = branchMaster.Id,
            recordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Tractor').getRecordTypeId()
        ),false);

        List<Loan_Application__c> loans = new List<Loan_Application__c>{loanAppl, loanAppl2, loanApplTR};
        insert loans;

        Collateral__c collateral = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Loan__c  = loanApplTR.Id,
            recordTypeId=Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId()
        ),true);

        Loan_Application_Approval__c loanApplAppr1 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanApplTR.Id,
            Approver__c = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1].Id,
            Approval_Type__c='Pricing',
            Approval_Status__c='Pending'
        ),true);

        Loan_Application_Approval__c loanApplAppr2 = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanApplTR.Id,
            Approver__c = [SELECT Id FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1].Id,
            Approval_Type__c='Pricing',
            Approval_Status__c='Approved'
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
            Dob__c = System.today().addYears(-30),
            Education_qualification__c='GRADUATE',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
    }
    testmethod static void testPricingApprovalEvent(){
        List<Pricing_Approval_Event__e> paEvents = new List<Pricing_Approval_Event__e>();
        Loan_Application__c loanApp = [Select Id from Loan_Application__c WHERE recordType.Name ='Two Wheeler'  limit 1];
        loanApp.Bre_Decision__c = GlobalConstants.BRE_DECISION_STP;
        loanApp.No_Pricing_Deviation__c = false;
        loanApp.Stage__c = GlobalConstants.STAGE_PRICING;
        update loanApp;
        Test.startTest();
        paEvents.add(new Pricing_Approval_Event__e(sObjectId__c=loanApp.Id));
        Eventbus.publish(paEvents);
        Test.stopTest();
    }
    testmethod static void testPricingApprovalEvent2(){
        List<Pricing_Approval_Event__e> paEvents = new List<Pricing_Approval_Event__e>();
        Loan_Application__c loanApp = [Select Id from Loan_Application__c WHERE RecordType.Name='Tractor' limit 1];
        loanApp.Bre_Decision__c = GlobalConstants.BRE_DECISION_NSTP;
        loanApp.No_Pricing_Deviation__c = false;
        loanApp.Stage__c = 'Pricing';
        loanApp.Send_Back_To_RO_Stage__c=null;
        update loanApp;
        Test.startTest();
        paEvents.add(new Pricing_Approval_Event__e(sObjectId__c=loanApp.Id));
        Eventbus.publish(paEvents);
        Test.stopTest();
    }
    testmethod static void testPricingApprovalEvent3(){
        List<Pricing_Approval_Event__e> paEvents = new List<Pricing_Approval_Event__e>();
        Loan_Application__c loanApp = [Select Id from Loan_Application__c WHERE recordType.Name NOT IN ('Two Wheeler','Tractor') limit 1];
        loanApp.Bre_Decision__c = GlobalConstants.BRE_DECISION_NSTP;
        loanApp.No_Pricing_Deviation__c = true;
        loanApp.Stage__c = GlobalConstants.STAGE_PRICING;
        update loanApp;
        Test.startTest();
        paEvents.add(new Pricing_Approval_Event__e(sObjectId__c=loanApp.Id));
        Eventbus.publish(paEvents);
        Test.stopTest();
    }
    testmethod static void testPricingApprovalEvent4(){
        List<Pricing_Approval_Event__e> paEvents = new List<Pricing_Approval_Event__e>();
        Loan_Application__c loanApp = [Select Id from Loan_Application__c WHERE recordType.Name NOT IN ('Two Wheeler','Tractor') limit 1];
        loanApp.Bre_Decision__c = GlobalConstants.BRE_DECISION_STP;
        loanApp.No_Pricing_Deviation__c = false;
        loanApp.Stage__c = GlobalConstants.STAGE_PRICING;
        update loanApp;
        Test.startTest();
        paEvents.add(new Pricing_Approval_Event__e(sObjectId__c=loanApp.Id));
        Eventbus.publish(paEvents);
        Test.stopTest();
    }
    testmethod static void testPricingApprovalEvent5(){
        List<Pricing_Approval_Event__e> paEvents = new List<Pricing_Approval_Event__e>();
        Loan_Application__c loanApp = [Select Id from Loan_Application__c WHERE recordType.Name NOT IN ('Two Wheeler','Tractor') limit 1];
        loanApp.Bre_Decision__c = GlobalConstants.BRE_DECISION_NSTP;
        loanApp.No_Pricing_Deviation__c = false;
        loanApp.Stage__c = 'Credit';
        update loanApp;
        Test.startTest();
        paEvents.add(new Pricing_Approval_Event__e(sObjectId__c=loanApp.Id));
        Eventbus.publish(paEvents);
        Test.stopTest();
    }
    testmethod static void testPricingApprovalEvent6(){
        List<Pricing_Approval_Event__e> paEvents = new List<Pricing_Approval_Event__e>();
        Loan_Application__c loanApp = [Select Id from Loan_Application__c WHERE recordType.Name NOT IN ('Two Wheeler','Tractor') limit 1];
        loanApp.Bre_Decision__c = GlobalConstants.BRE_DECISION_NSTP;
        loanApp.No_Pricing_Deviation__c = false;
        loanApp.Stage__c = 'Pricing';
        update loanApp;
        Test.startTest();
        paEvents.add(new Pricing_Approval_Event__e(sObjectId__c=loanApp.Id));
        Eventbus.publish(paEvents);
        Test.stopTest();
    }
}