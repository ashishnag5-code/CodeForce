@isTest
public class ApplicationTrackerControllerTest {
    @testSetup static void setup() {
        
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true
            
        ),true);
        Collateral__c coll= new Collateral__c(Loan__c=loanAppl.Id);
        insert coll;
        Loan_TAT__c loanTat= new Loan_TAT__c( 
                  Start_Date_Time__c=DateTime.newInstance(1996, 04, 04),
                  End_Date_Time__c=DateTime.newInstance(1996, 08, 04),
                  Assigned_To__c='User',Loan_Application__c=loanAppl.Id); 
        insert loanTat;
        Valuation__c val= new Valuation__c(Name='TestVal',Collateral__c=coll.Id);
        insert val;
        Assignment__c assignment = new Assignment__c();
        assignment.RecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByName().get('Ops - KYC').getRecordTypeId();
        assignment.Loan_Application__c = loanAppl.Id;
        insert assignment;
       
        Loan_TAT__c loanTatLoanAssignment= new Loan_TAT__c( Loan_Application_Assignment__c =assignment.Id,
                  Start_Date_Time__c=DateTime.newInstance(1996, 04, 04),
                  Assigned_To__c='User',Loan_Application__c=loanAppl.Id);
        insert loanTatLoanAssignment;
            
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Customer_Type__c ='Individual',
            Residential_Status__c ='Resident',
            Loan__c =loanAppl.Id
            
        ),true);
        
    }


    @isTest static void getAddress1() {
       Loan_application__c loan = [select id from Loan_application__c where Application_Number__c='AP-12345'];
       Test.startTest();
       ApplicationTrackerController.fetchLineItems(loan.Id);
       Test.stopTest();
    }

}