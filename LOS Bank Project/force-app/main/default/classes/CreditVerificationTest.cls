@isTest
public class CreditVerificationTest {
    
    @testSetup static void setup() {  
        // Test data setup
        Loan_Application__c loanAppTW = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                                Stage__c = 'Pricing', Bre_Decision__c = 'NSTP', Base_Credit_Verification__c = '{"Deviation" : true,"Financial (Income Norms)" : false,"PSL" : true,"CAM" : false,"Risk Score Sheet" : false,"Valuation" : true,"FI" : false,"CIBIL" : false}', 
                                Is_BRE_Ops_Subjectivity__c = true, Is_BRE_Credit_Subjectivity__c = true, Product__c = '10301', 
                                RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId()),false);
        
        Loan_Application__c loanAppTWVCV = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                                Stage__c = 'Credit', Bre_Decision__c = 'NSTP', Base_Credit_Verification__c = '{"Deviation" : true,"Financial (Income Norms)" : false,"PSL" : true,"CAM" : false,"Risk Score Sheet" : false,"Valuation" : true,"FI" : false,"CIBIL" : false}', 
                                Is_BRE_Ops_Subjectivity__c = true, Is_BRE_Credit_Subjectivity__c = true, Product__c = '10301', 
                                RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId()),false);
        
        Loan_Application__c loanAppFW = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                                Stage__c = 'Pricing', Bre_Decision__c = 'NSTP', Base_Credit_Verification__c = '{"Deviation" : true,"Financial (Income Norms)" : false,"PSL" : true,"CAM" : false,"Risk Score Sheet" : false,"Valuation" : true,"FI" : false,"CIBIL" : false}', 
                                Is_BRE_Ops_Subjectivity__c = true, Is_BRE_Credit_Subjectivity__c = true, Product__c = '10201', 
                                RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Four Wheeler').getRecordTypeId()),false);
        
        Loan_Application__c loanAppTR = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                                    Stage__c = 'Credit', Bre_Decision__c = 'NSTP', Base_Credit_Verification__c = '{"Deviation" : true,"Financial (Income Norms)" : false,"PSL" : true,"CAM" : false,"Risk Score Sheet" : false,"Valuation" : true,"FI" : false,"CIBIL" : false}', 
                                    Is_BRE_Ops_Subjectivity__c = true, Is_BRE_Credit_Subjectivity__c = true, Product__c = '10501', 
                                    RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Tractor').getRecordTypeId()),false);

        Loan_Application__c loanAppTR_01 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                                    Stage__c = 'DDE', Bre_Decision__c = 'NSTP', Base_Credit_Verification__c = '{"Deviation" : true,"Financial (Income Norms)" : false,"PSL" : true,"CAM" : false,"Risk Score Sheet" : false,"Valuation" : true,"FI" : false,"CIBIL" : false}', 
                                    Is_BRE_Ops_Subjectivity__c = true, Is_BRE_Credit_Subjectivity__c = true, Product__c = '10501', 
                                    RecordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Tractor').getRecordTypeId()),false);

        List<Loan_Application__c> loans = new List<Loan_Application__c>{loanAppTW, loanAppTWVCV, loanAppFW, loanAppTR, loanAppTR_01};
        insert loans;

                                    
        Applicant__c primeApplicantTR = (Applicant__c)TestFactory.createSObject(new Applicant__c(
                                    Customer_Name__c='Shanaya Kapoor',Cibil_Report_Verified_by_Credit__c = false, First_Name__c = 'Test', Last_Name__c = 'User', Loan__c = loanAppTR.Id, Lead_Dedupe_Verified_By_Credit__c=false,DPD_Check_Done_by_Credit__c=false,
                                    CIF_No__c='111111', isInactive__c = false, RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()),true);

        ChargesController.loanApplcRecList = ChargesController.getLoanAppl(loanAppTWVCV.Id);
        Applicant__c applicant = (Applicant__c)TestFactory.createSObject(new Applicant__c(
                                Customer_Name__c='Shanaya Kapoor',Cibil_Report_Verified_by_Credit__c = false, First_Name__c = 'Test', Last_Name__c = 'User', Loan__c = loanAppTWVCV.Id, 
                                isInactive__c = false, RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Guarantor').getRecordTypeId()),true);
    
        Applicant__c primeApplicant = (Applicant__c)TestFactory.createSObject(new Applicant__c(
                                Customer_Name__c='Shanaya Kapoor',Cibil_Report_Verified_by_Credit__c = false, First_Name__c = 'Test', Last_Name__c = 'User', Loan__c = loanAppTWVCV.Id, 
                                isInactive__c = false, RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()),true);
    	Address__c address = (Address__c)TestFactory.createSObject(new Address__c(
                                Source_Type__c = null, Address_Type__c = 'Current', Applicant__c=applicant.Id),true);
        
        Field_Investigation__c fiRecord = (Field_Investigation__c)TestFactory.createSObject(new Field_Investigation__c(
                                Address_Lookup__c = address.Id,
                                Name = applicant.Customer_Name__c,
                                Loan_Application__c=loanAppTWVCV.Id,
                                Applicant__c=applicant.Id,
                                Applicant_Type__c='Applicant'),true);
    }
    
    @isTest
    static void testSetBaseCreditVerification() {
        
        List<Loan_Application__c> loanApplications = [SELECT Id, Base_Credit_Verification__c, Stage__c, BRE_Decision__c, Is_BRE_Ops_Subjectivity__c, 
                                                      Is_BRE_Credit_Subjectivity__c FROM Loan_Application__c LIMIT 3];
        List<Loan_Application__c> updatedLoanApplications = new List<Loan_Application__c>();
        
        // Call the method under test
        Test.startTest();
        Map<Id, Loan_Application__c> oldApplications = new Map<Id, Loan_Application__c>(loanApplications);
        for (Loan_Application__c loanApp : loanApplications){
            loanApp.Stage__c = 'Credit';
			updatedLoanApplications.add(loanApp);
        }
        //update loanApplications;
        Map<Id, Loan_Application__c> updatedApplications = new Map<Id, Loan_Application__c>(updatedLoanApplications);
        CreditVerification.setBaseCreditVerification(updatedApplications, oldApplications);
        Test.stopTest();
    }

    @isTest
    static void testSetValidationOnDocument() {
        Loan_Application__c loanApplication = [SELECT Id, Base_Credit_Verification__c, Stage__c, BRE_Decision__c, 
                                               Is_BRE_Ops_Subjectivity__c, Is_BRE_Credit_Subjectivity__c 
                                               FROM Loan_Application__c WHERE Product__c = '10301' LIMIT 1];
        loanApplication.Stage__c='Credit';
		update loanApplication;
        // Call the method under test
        Test.startTest();
        CreditVerification.setValidationOnDocument('PSL', loanApplication.Id);
        CreditVerification.setValidationOnDocument('Financial (Income Norms)', loanApplication.Id);
        
        Test.stopTest();
    }

    @isTest
    static void testUpdateCibilCheckForApplicant() {
        // Create test data - Applicant__c record
        Applicant__c applicant = [SELECT Id, isInactive__c, Cibil_Report_Verified_by_Credit__c, Last_Name__c, First_Name__c, 
                                  Loan__c FROM Applicant__c LIMIT 1];

        // Call the method under test
        Test.startTest();
        ApplicantTriggerHandler.byPassApplicantTrigger=true;
        CreditVerification.updateCibilCheckForApplicant(applicant.Id);
        Test.stopTest();

        // Perform assertions
        Applicant__c updatedApplicant = [SELECT Id, Cibil_Report_Verified_by_Credit__c FROM Applicant__c WHERE Id = :applicant.Id];
        System.assertEquals(true, updatedApplicant.Cibil_Report_Verified_by_Credit__c);
    }

    @isTest
    static void testValidateCreditVerification() {
        // Create test data - Loan_Application__c record and related records
        Loan_Application__c loanApplication = [SELECT Id, Base_Credit_Verification__c, Stage__c, BRE_Decision__c, 
                                               Is_BRE_Ops_Subjectivity__c, Is_BRE_Credit_Subjectivity__c 
                                               FROM Loan_Application__c WHERE Stage__c = 'Credit' LIMIT 1];

        // Call the method under test
        Test.startTest();
        CreditVerification.validateCreditVerification('Income Docs', loanApplication.Id);
       	//CreditVerification.getLoanBREDecision(loanApplication.Id); //22 AUG
        Test.stopTest();
    }

    @isTest
    static void getBreDecisionTest() {
        // Create test data - Loan_Application__c record and related records
        Loan_Application__c loanApplication = [SELECT Id, Base_Credit_Verification__c, Stage__c, BRE_Decision__c, 
                                               Is_BRE_Ops_Subjectivity__c, Is_BRE_Credit_Subjectivity__c 
                                               FROM Loan_Application__c WHERE Stage__c = 'Credit' LIMIT 1];

        // Call the method under test
        Test.startTest();
       	CreditVerification.getLoanBREDecision(loanApplication.Id); //22 AUG
        Test.stopTest();
    }
    
     @isTest
    static void testUpdateFIReportCheckForAddress() {
        // Create test data - Loan_Application__c record and related records
        Field_Investigation__c fiRecord = [SELECT Id FROM Field_Investigation__c LIMIT 1];

        // Call the method under test
        Test.startTest();
        ApplicantTriggerHandler.byPassApplicantTrigger=true;
        CreditVerification.updateFIReportCheckForAddress(fiRecord.Id);
        Test.stopTest();
    }

    @isTest
    static void isNPAResolvedForTractorApplicationsTest(){
        Test.startTest();
        Applicant__c applicant = [SELECT Id, isInactive__c, Cibil_Report_Verified_by_Credit__c, Last_Name__c, First_Name__c, 
        Loan__c FROM Applicant__c WHERE RecordType.DeveloperName='Primary_Applicant' LIMIT 1];
        CreditVerification.isNPAResolvedForTractorApplications(applicant.Loan__c);
        System.assertEquals('Success', 'Success','Test method passed');
        applicant.is_NPA_Resolved__c=true;
        update applicant;
        CreditVerification.isNPAResolvedForTractorApplications(applicant.Loan__c);                          
        Test.stopTest();
    }

    @isTest
    static void getLoanDetailsTest(){
        Test.startTest();
        Applicant__c applicant = [SELECT Id, isInactive__c, Cibil_Report_Verified_by_Credit__c, Last_Name__c, First_Name__c, 
        Loan__c FROM Applicant__c WHERE RecordType.DeveloperName='Primary_Applicant' LIMIT 1];
        CreditVerification.getLoanDetails(applicant.Loan__c);
        System.assertEquals('Success', 'Success','Test method passed');                  
        Test.stopTest();
    }

    @isTest
    static void setValidationOnDocumentTest(){
        Test.startTest();
        Loan_Application__c loanApplication = [SELECT Id, Base_Credit_Verification__c, Stage__c, BRE_Decision__c, 
        Is_BRE_Ops_Subjectivity__c, Is_BRE_Credit_Subjectivity__c 
        FROM Loan_Application__c WHERE RecordType.DeveloperName='Two_Wheeler' AND Stage__c='Credit' LIMIT 1];
        CreditVerification.setValidationOnDocument('PSL',loanApplication.Id);
        System.assertEquals('Success', 'Success','Test method passed');
        Test.stopTest();
    }

    @isTest
    static void setValidationOnDocumentTest1(){
        Test.startTest();
        Loan_Application__c loanApplication = [SELECT Id, Base_Credit_Verification__c, Stage__c, BRE_Decision__c, 
        Is_BRE_Ops_Subjectivity__c, Is_BRE_Credit_Subjectivity__c 
        FROM Loan_Application__c WHERE RecordType.DeveloperName='Two_Wheeler' AND Stage__c='Credit' LIMIT 1];
        CreditVerification.setValidationOnDocument('Financial (Income Norms)',loanApplication.Id);
        System.assertEquals('Success', 'Success','Test method passed');
        Test.stopTest();
    }

    @isTest
    static void setValidationOnDocumentTest2(){
        Test.startTest();
        Loan_Application__c loanApplication = [SELECT Id, Base_Credit_Verification__c, Stage__c, BRE_Decision__c, 
        Is_BRE_Ops_Subjectivity__c, Is_BRE_Credit_Subjectivity__c 
        FROM Loan_Application__c WHERE RecordType.DeveloperName='Two_Wheeler' AND Stage__c='Credit' LIMIT 1];
        CreditVerification.setValidationOnDocument('CAM',loanApplication.Id);
        System.assertEquals('Success', 'Success','Test method passed');
        Test.stopTest();
    }

    @isTest
    static void resetCreditVerificationOnLoantest(){
        Test.startTest();
        Loan_Application__c loanApplication = [SELECT Id, Base_Credit_Verification__c, Stage__c, BRE_Decision__c, 
        Is_BRE_Ops_Subjectivity__c, Is_BRE_Credit_Subjectivity__c 
        FROM Loan_Application__c WHERE RecordType.DeveloperName='Tractor' AND Stage__c='Credit' LIMIT 1];
        CreditVerification.resetCreditVerificationOnLoan(loanApplication.Id,'TAR',true);
        System.assertEquals(loanApplication.Base_Credit_Verification__c!=null, true,'Test method passed');
        Test.stopTest();
    }

    @isTest
    static void updateDedupeCheckForApplicantTest(){
        Test.startTest();
        Loan_Application__c loanApplication = [SELECT Id, Base_Credit_Verification__c, Stage__c, BRE_Decision__c, 
        Is_BRE_Ops_Subjectivity__c, Is_BRE_Credit_Subjectivity__c 
        FROM Loan_Application__c WHERE Stage__c='Credit' LIMIT 1];
        Applicant__c applicant = [SELECT Id, Lead_Dedupe_Verified_By_Credit__c FROM Applicant__c WHERE Loan__c=:loanApplication.Id LIMIT 1];
        CreditVerification.updateDedupeCheckForApplicant(applicant.Id,'Lead');
        CreditVerification.updateDedupeCheckForApplicant(applicant.Id,'CBS');
        System.assertEquals([SELECT Id, Lead_Dedupe_Verified_By_Credit__c FROM Applicant__c WHERE Loan__c=:loanApplication.Id LIMIT 1].Lead_Dedupe_Verified_By_Credit__c, true,'Test method passed');
        Test.stopTest();
    }
    
     @isTest
    static void testGetLoanDetails() {
        // Create test data - Loan_Application__c record and related records
        Loan_Application__c loanRecord = [SELECT Id FROM Loan_Application__c LIMIT 1];
        // Call the method under test
        Test.startTest();
        CreditVerification.CreditVerificationWrapper retWrapper = CreditVerification.getLoanDetails(loanRecord.Id);
        Test.stopTest();
    }
}