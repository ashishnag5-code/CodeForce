/*******************************************************************************************
 * @Name         DOPDFControllerTest
 * @Author       Yash Shukla
 * @Description   Test class for DO PDF COntroller
 *******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer           Date               Description
 *-------------------------------------------------------------------------------------------
 *  1.0             Yash Shukla        18/04/2023         Initial Creation 
 *******************************************************************************************/
@IsTest
public class DOPDFControllerTest {
    @testsetup
    static void testDataSetup() {
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Total_Loan_Amount__c = 1000,
            Product__c = '10201',
            ROI__c = 17.0,
            EMI__c = 13
        ),true);
        
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Mobile_Number__c = '9999999999',
            Aadhaar_Number__c = '9999999999',
            PAN__c = '9999999999',
            Loan__c =loanAppl.Id,
            RecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Applicant').getRecordTypeId()
        ),true);
        
        Collateral__c testCollateralRec = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('New').getRecordTypeId(),
            Loan__c = loanAppl.Id,
            Collateral_Type__c = 'Existing ',
            Registration_Number__c = '123456Test',
            Ex_Showroom_Price__c = 100,
            Discount__c = 10,
            Net_of_Discount_Price__c = 10,
            Final_Cost__c = 10,
            LTV_offered_On_final_cost__c = 10,
            Apportioned_Loan_Amount__c = 10,
            RTO_Taxes__c = 100.00,
            Insurance__c = 1000.00
        ),true);
        
        Address__c testAddressRec = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c = 'test address1',
            Address_Line_2__c = 'test address2',
            Address_Line_3__c = 'Existing ',
            State__c = '123456Test',
            City__c = 'testcity',
            Pincode__c = 'testPincode',
            Applicant__c = appl.Id,
            Address_Type__c = 'Current'
            
        ),true);
        
        Id PaymentRecordTypeId2 = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Dealer Payout').getRecordTypeId();
        Payment__c payment = new Payment__c(
            RecordTypeId = PaymentRecordTypeId2,
            Name__c = 'Test Payment',
            Inactive__c = false,
            Loan_Application__c = loanAppl.Id);
        insert payment;
        
        Charge__c  charge = new Charge__c (Loan_Application__c  = loanAppl.Id,Total_Amount__c = 100.00);
        insert charge;
    }
    
    @IsTest
    public static void testPDFWrapper() {
        String applicationId = [SELECT Id FROM Loan_Application__c LIMIT 1][0].Id;
        Test.StartTest(); 
        PageReference pageRef = Page.SanctionPDFPage; // Add your VF page Name here
        pageRef.getParameters().put('applicationId', String.valueOf(applicationId));
        Test.setCurrentPage(pageRef);
        DOPDFController.DOReturnWrapper returnWRapper = DOPDFController.getPDFWrapperData();
        Test.StopTest();
        System.assertEquals(returnWrapper!=null, true);
    }

}