@isTest
public class AsynchronousEventTriggerTest {
    @testSetup static void setup() {
        Account dealerMaster = (Account)TestFactory.createSObject(new Account(
            Name ='TestAccount',
            Account_Code__c='2103',
            RC_Limit_Increased__c=true,
            Purchase_City__c='Jaipur',
         recordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId()),true);
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
            RC_Limit_On_Hold__c= true,
            Total_Loan_Amount__c=10,
            Dealer_Master__c = dealerMaster.Id
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
            AU_Employee__c = 'Yes',
            AU_Employment_status__c='Active',
            Date_of_Joining__c = System.today().addDays(-60),
            Education_qualification__c='GRADUATE'
        ),true);
        Field_Investigation__c fieldInvestigationObj= (Field_Investigation__c)TestFactory.createSObject(new Field_Investigation__c( 
            Name = appl.First_Name__c,
            Loan_Application__c =loanAppl.Id,
            Applicant__c=appl.Id,
            FI_Status__c ='POSITIVE',
            Proposed_vehicle__c=GlobalConstants.AUTOLOANNEW,
            Applicant_Type__c='Applicant',
            Re_Trigger__c = false,
            Type_of_Address__c='Current'
        ),true);
        
        Loan_Application_Approval__c loanAppApproval = (Loan_Application_Approval__c)TestFactory.createSObject(new Loan_Application_Approval__c(
            Loan_Application__c  = loanAppl.Id,  Approval_Type__c = 'Credit' , Approver__c = UserInfo.getUserId(),
            Archived__c = false
        ),true);
        Assignment__c assignment = new Assignment__c();
        assignment.RecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByName().get('Ops - KYC').getRecordTypeId();
        assignment.Loan_Application__c = loanAppl.Id;
        insert assignment;
        
        Loan_TAT__c loanTatFI= new Loan_TAT__c( Field_Investigation__c =fieldInvestigationObj.Id,
                  Start_Date_Time__c=DateTime.newInstance(1996, 04, 04),
                  Assigned_To__c='Queue',Loan_Application__c=loanAppl.Id);
        insert loanTatFI;
        Loan_TAT__c loanTatLoanApproval= new Loan_TAT__c( Loan_Application_Approval__c =loanAppApproval.Id,
                  Start_Date_Time__c=DateTime.newInstance(1996, 04, 04),
                  Assigned_To__c='Queue',Loan_Application__c=loanAppl.Id);
        insert loanTatLoanApproval;
        Loan_TAT__c loanTatLoanAssignment= new Loan_TAT__c( Loan_Application_Assignment__c =assignment.Id,
                  Start_Date_Time__c=DateTime.newInstance(1996, 04, 04),
                  Assigned_To__c='Queue',Loan_Application__c=loanAppl.Id);
        insert loanTatLoanAssignment;
        Loan_TAT__c loanTatLoanApp= new Loan_TAT__c(
                  Start_Date_Time__c=DateTime.newInstance(1996, 04, 04),
                  Assigned_To__c='Queue',Loan_Application__c=loanAppl.Id);
        insert loanTatLoanApp;
    }
    testmethod static void testAsynchronousEventForLA(){
        List<Asynchronous_Event__e> tatEvents = new List<Asynchronous_Event__e>();
        Test.startTest();
        Loan_Application__c oldLoanApp = [Select Id,Application_Number__c,Adhar_Card__c,Total_Loan_Amount__c from Loan_Application__c limit 1];
        Loan_Application__c loanApp = [Select Id,Application_Number__c,Adhar_Card__c,Total_Loan_Amount__c from Loan_Application__c limit 1];
        loanApp.Stage__c = 'Credit';
        loanApp.Application_FI_Status__c ='Positive';
        Field_Investigation__c fieldInvestigation = [Select Id,Name,Loan_Application__c,Applicant__c,FI_Status__c from Field_Investigation__c limit 1];
        Loan_Application_Approval__c loanAppliApproval = [Select Id from Loan_Application_Approval__c limit 1];
        Assignment__c assignment = [Select Id from Assignment__c limit 1];
        tatEvents.add(new Asynchronous_Event__e(Event_Type__c = 'TAT', New_Records_Payload__c = JSON.serialize(loanApp), Event_Date_Time__c = Datetime.now()));
        tatEvents.add(new Asynchronous_Event__e(Event_Type__c = 'TAT', New_Records_Payload__c = JSON.serialize(loanApp), Object_API_Name__c = 'Loan_Application__c',Event_Date_Time__c = Datetime.now()));
        tatEvents.add(new Asynchronous_Event__e(Event_Type__c = 'TAT',Old_Records_Payload__c=JSON.serialize(oldLoanApp), New_Records_Payload__c = JSON.serialize(loanApp), Object_API_Name__c = 'Loan_Application__c',Event_Date_Time__c = Datetime.now()));
        tatEvents.add(new Asynchronous_Event__e(Event_Type__c = 'TAT',Old_Records_Payload__c=JSON.serialize(fieldInvestigation), New_Records_Payload__c = JSON.serialize(fieldInvestigation), Object_API_Name__c = 'Field_Investigation__c',Event_Date_Time__c = Datetime.now()));
        tatEvents.add(new Asynchronous_Event__e(Event_Type__c = 'TAT',Old_Records_Payload__c=JSON.serialize(loanAppliApproval), New_Records_Payload__c = JSON.serialize(loanAppliApproval), Object_API_Name__c = 'Loan_Application_Approval__c',Event_Date_Time__c = Datetime.now()));
        tatEvents.add(new Asynchronous_Event__e(Event_Type__c = 'TAT',Old_Records_Payload__c=JSON.serialize(assignment), New_Records_Payload__c = JSON.serialize(assignment), Object_API_Name__c = 'Assignment__c',Event_Date_Time__c = Datetime.now()));
        Eventbus.publish(tatEvents);
        Test.stopTest();
    }
    testmethod static void testAsynchronousEventForLAWithOldPayload(){
        List<Asynchronous_Event__e> tatEvents = new List<Asynchronous_Event__e>();
        Test.startTest();
        Loan_Application__c loanApp = [Select Id,Application_Number__c,Adhar_Card__c,Total_Loan_Amount__c from Loan_Application__c limit 1];
        tatEvents.add(new Asynchronous_Event__e(Event_Type__c = 'TAT',Old_Records_Payload__c=JSON.serialize(loanApp), New_Records_Payload__c = JSON.serialize(loanApp), Object_API_Name__c = 'Loan_Application__c',Event_Date_Time__c = Datetime.now()));
        Eventbus.publish(tatEvents);
        Test.stopTest();
    }
    testmethod static void testAsynchronousEventForFI(){
        List<Asynchronous_Event__e> tatEvents = new List<Asynchronous_Event__e>();
        Test.startTest();
        Field_Investigation__c fieldInvestigation = [Select Id,Name,Loan_Application__c,Applicant__c,FI_Status__c from Field_Investigation__c limit 1];
        tatEvents.add(new Asynchronous_Event__e(Event_Type__c = 'TAT',Old_Records_Payload__c=JSON.serialize(fieldInvestigation), New_Records_Payload__c = JSON.serialize(fieldInvestigation), Object_API_Name__c = 'Field_Investigation__c',Event_Date_Time__c = Datetime.now()));
        Eventbus.publish(tatEvents);
        Test.stopTest();
    }
    testmethod static void testAsynchronousEventForLAA(){
        List<Asynchronous_Event__e> tatEvents = new List<Asynchronous_Event__e>();
        Test.startTest();
        Loan_Application_Approval__c loanAppliApproval = [Select Id,Loan_Application__c, Approval_Type__c, Approver__c, Archived__c from Loan_Application_Approval__c limit 1];
        tatEvents.add(new Asynchronous_Event__e(Event_Type__c = 'TAT',Old_Records_Payload__c=JSON.serialize(loanAppliApproval), New_Records_Payload__c = JSON.serialize(loanAppliApproval), Object_API_Name__c = 'Loan_Application_Approval__c',Event_Date_Time__c = Datetime.now()));
        Eventbus.publish(tatEvents);
        Test.stopTest();
    }
    testmethod static void testAsynchronousEventForAssignment(){
        List<Asynchronous_Event__e> tatEvents = new List<Asynchronous_Event__e>();
        Test.startTest();
        Assignment__c assignment = [Select Id,Loan_Application__c from Assignment__c limit 1];
        tatEvents.add(new Asynchronous_Event__e(Event_Type__c = 'TAT',Old_Records_Payload__c=JSON.serialize(assignment), New_Records_Payload__c = JSON.serialize(assignment), Object_API_Name__c = 'Assignment__c',Event_Date_Time__c = Datetime.now()));
        Eventbus.publish(tatEvents);
        Test.stopTest();
    }
    
    @istest
    static void testRejectionRemarks(){
        
        
        Loan_Application__c appl = [SELECT Id, Rejection_Reason__c, Rejection_Sub_Reason__c, Other_Rejection_Reason__c 
                                    FROM Loan_Application__c LIMIT 1
                                   ];
        appl.Rejection_Reason__c = 'Repayment/CIBIL issue';
        appl.Rejection_Sub_Reason__c = 'Irregular track in other loans of same CIF';
        appl.Other_Rejection_Reason__c = 'Repayment/CIBIL issue';
        Test.startTest();
        String remarks = AsynchronousEventTriggerHelper.setRejectionDecisionRemarks(appl);
        Test.stopTest();
        
    }
    
    @IsTest
    static void testpauseOpsTAT(){
        List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
        AsynchronousEventTriggerHelper.defaultBusinessHoursId = bhs[0].Id;
        Loan_Application__c appl = [SELECT Id, Rejection_Reason__c, Rejection_Sub_Reason__c, Branch_Master__r.State__r.Business_Hours__c,
                                    Other_Rejection_Reason__c,Ops_Status__c,Stage__c, Total_Loan_Amount__c, RO_Discrepancy_Remarks__c, Remarks__c,
                                    Tenure__c, ROI__c,(SELECT Id, OwnerId, Loan_Application__c, Remarks__c From Assignments__r) FROM 
                                    Loan_Application__c LIMIT 1
                                   ];
        appl.Ops_Status__c = 'Discrepancy';
        
        Test.startTest();
        AsynchronousEventTriggerHelper.pauseOpsTAT(appl, System.Now(), userInfo.getUserId());
        Test.stopTest();
    }
    
    @IsTest
    static void testCreditTAT(){
        List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
        AsynchronousEventTriggerHelper.defaultBusinessHoursId = bhs[0].Id;
        Loan_Application__c appl = [SELECT Id, Rejection_Reason__c, Rejection_Sub_Reason__c, Branch_Master__r.State__r.Business_Hours__c,
                                    Other_Rejection_Reason__c,Ops_Status__c,Stage__c, Total_Loan_Amount__c, RO_Discrepancy_Remarks__c, Remarks__c,
                                    Tenure__c, ROI__c,(SELECT Id, Loan_Application__c, Remarks__c, Approver__c, Assigned_to_Queue__c From Loan_Application_Approvers__r) FROM 
                                    Loan_Application__c LIMIT 1
                                   ];
        appl.Ops_Status__c = 'Discrepancy';
        
        Test.startTest();
        AsynchronousEventTriggerHelper.pauseCreditTAT(appl, System.Now(), userInfo.getUserId(),true);
        AsynchronousEventTriggerHelper.pauseCreditTAT(appl, System.Now(), userInfo.getUserId(),false);
        Test.stopTest();
        
    }
}