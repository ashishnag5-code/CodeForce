@isTest
public with sharing class AUSFLeadDedupeCRMControllerTest {
    @TestSetup
    static void makeData(){
        Account branch = (Account)TestFactory.createSObject(new Account(
            Name = 'ParentAccount',
            Grading__c = 'Platinum-Certified',
            Certified_Value__c = 'Yes'
        ),true);

        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Mobile__c = '9898989898',
            Product__c = '10201',
            Wheels_Exposure__c = 500,
            Final_Exposure__c = 1000,
            Branch_Master__c = branch.Id,
            RecordTypeId = Utility.getRecordTypeId( Schema.Loan_Application__c.getSObjectType() , 'Lead' )
        ),true);

        // Duplicate loan
        TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-34567',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c = '10201',
            Mobile__c = '9898989898',
            Stage__c = 'QDE',
            Wheels_Exposure__c = 500,
            Final_Exposure__c = 1000,
            Branch_Master__c = branch.Id,
            RecordTypeId = Utility.getRecordTypeId( Schema.Loan_Application__c.getSObjectType() , 'Four Wheeler' )
        ),true);

        Loan_Application__c loanApp1 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c = '10201',
            Mobile__c = '9898989898',
            Stage__c = 'QDE',
            Wheels_Exposure__c = 500,
            Final_Exposure__c = 1000,
            Branch_Master__c = branch.Id,
            RecordTypeId = Utility.getRecordTypeId( Schema.Loan_Application__c.getSObjectType() , 'Four Wheeler' )
        ),true);

        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Loan__c = loanApp1.Id,
            Mobile_Number__c ='9898989898',
            PAN__c ='EXFPK4321K',
            CIF_No__c ='12345678',
            Voter_Id__c='1241214',
            Passport_Number__c='12411414',
            Driving_License_Id__c='3555535xfr',
            Aadhaar_Number__c = '60123214141',
            Customer_Type__c = 'Individual',
            RecordTypeId = Utility.getRecordTypeId( Schema.Applicant__c.getSObjectType() , 'Applicant' ),
            SF_Exposure_JSON__c ='[{"SanctionDate":null,"Product":null,"LoanAmount":"10000.00","includeInExposure":"Yes","customerName":null,"creditOverrideAuthority":false,"applicationNumber":""}]'
            
        ),true);
    }

    @isTest static void verifyDuplicateLoans(){
        Id leadId = [ SELECT Id FROM Loan_Application__c WHERE RecordType.Name = 'Lead' LIMIT 1 ].Id;

        Test.startTest();
        LeadDedupeController.LeadCRMDedupeWrapper[] matchingLoans = AUSFLeadDedupeCRMController.getDuplicateLoans( leadId );
        Test.stopTest();

        Assert.areEqual( 2, matchingLoans.size(), 'Matching loans based on phone number should be returned' );

    }
}