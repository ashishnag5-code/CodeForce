@isTest
public class DiscrepancyButtonControllerTest {
     @testSetup static void setup() {
        Profile profileId = [SELECT Id FROM Profile WHERE Name Like '%Admin%' LIMIT 1];
        
        User user = new User(
            LastName = 'Test Code',
            Email = 'test@test.com',
            Alias = 'Tcode',
            Username = 'test1234444@testzsdfsdtfsdf.com',
            CommunityNickname = 'test12',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'GMT',
            ProfileID = profileId.Id,
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            Employee_Id__c='E0123456'
        );
        insert user;
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true
            
        ),true);
        
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321',
            Loan__c =loanAppl.Id,
            AML_Verification_Start_Date__c=DateTime.newInstance(1996, 08, 04),
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
        Loan_TAT__c loanTat= new Loan_TAT__c( 
            Start_Date_Time__c=Datetime.now(),
            End_Date_Time__c=DateTime.newInstance(1996, 08, 04),
            Assigned_To__c='Queue',
            Loan_Application__c=loanAppl.Id,
            Action_Type__c='Loan Submitted',
            Actor__c=user.Id
        ); 
        insert loanTat;
         
        Assignment__c assignment = new Assignment__c();
        assignment.RecordTypeId = Schema.SObjectType.Assignment__c.getRecordTypeInfosByName().get('Ops - Disbursement').getRecordTypeId();
        assignment.Loan_Application__c = loanAppl.Id;
        insert assignment; 
        
    }
    
    @isTest
    public static void updateLoanApplicationRecTest(){
        
        Test.startTest();
        Loan_Application__c loanAppl=[Select Id from Loan_Application__c LIMIT 1];
        Assignment__c assignment=[Select Id from Assignment__c LIMIT 1];
        DiscrepancyButtonController.updateLoanApplicationRec(loanAppl.Id, 'Discrepancy', 'Discrepancy');
        DiscrepancyButtonController.updateLoanApplicationRec(assignment.Id, 'Discrepancy', 'Discrepancy');
        DiscrepancyButtonController.getAllLoanTatRecords();
        Test.stopTest();
          
    }
    
    @isTest
    public static void updateLoanApplicationRecTest_CreditManager(){
        Loan_Application__c loanAppl=[Select Id from Loan_Application__c LIMIT 1];
        Assignment__c assignment=[Select Id from Assignment__c LIMIT 1];
        Profile profileId = [SELECT Id FROM Profile WHERE Name Like '%Credit Manager%' LIMIT 1];
        
        User user = new User(
            LastName = 'Test dCode',
            Email = 'test@test1.com',
            Alias = 'Tcdode',
            Username = 'test123411444@testsdtfsdf.com',
            CommunityNickname = 'tesdt12',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey = 'GMT',
            ProfileID = profileId.Id,
            LanguageLocaleKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            Employee_Id__c='E0113456'
        );
        insert user;
        Loan_Application__share share = new Loan_Application__share(ParentId = loanAppl.Id, UserOrGroupId = user.Id, AccessLevel = 'Edit', RowCause = 'Manual');
		insert share;
        Test.startTest();
        System.runas(user){
        DiscrepancyButtonController.updateLoanApplicationRec(loanAppl.Id, 'Discrepancy', 'Discrepancy');
        DiscrepancyButtonController.updateLoanApplicationRec(assignment.Id, 'Discrepancy', 'Discrepancy');
        DiscrepancyButtonController.getAllLoanTatRecords();     
        }
        
        Test.stopTest();
          
    }

}