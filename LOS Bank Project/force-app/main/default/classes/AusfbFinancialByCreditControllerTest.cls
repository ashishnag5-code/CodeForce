/**
 * @description       : Financial template by credit operation
 * @author            : Ajitesh
 * @group             : 
 * @last modified on  : 12-14-2023
 * @last modified by  : Ajitesh
**/
@isTest
public with sharing class AusfbFinancialByCreditControllerTest {
    // Setup coping code from financeController to control single test data
    @testSetup
    public  static void setup() {
        Profile prof = [select Id,Name from profile where name like '%Credit%'];
        
        User usr = (User)TestFactory.createSObject(new User(firstName = 'test1',
        	lastName = 'test2',
        	profileId = prof.id,
        	username = 'test'+UserInfo.getOrganizationId()+'@test.com',
        	email = 'test@test.com',
        	Branch_Code__c  = '2103'
    	),true);
        System.runAs([select Id from User where Id = :UserInfo.getUserId()][0]) {
            financeController_Test.setup();
        }
        
    }

    /**
    * @description Check view and edit funcationality of the Financial template
    * @author Ajitesh | 10-29-2023 
    **/
    @isTest
    static void viewAndEditRightTest(){
        Applicant__c applicant = [SELECT Id FROM Applicant__c LIMIT 1];
        Loan_Application__c loanRec = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Map<String,Boolean> resp = new Map<String,Boolean>();

        
        Test.startTest();

        // Non applicable data
        resp = AusfbFinancialByCreditController.viewAndEditRight(applicant.Id);
        System.assertEquals(resp.get('visible'), false,'Financial Template not visible');

        // Applicable stage
        loanRec.Stage__c = 'Credit';
        update loanRec;
        resp = AusfbFinancialByCreditController.viewAndEditRight(applicant.Id);
        System.assertEquals(resp.get('visible'), false,'Financial Template not visible');

        // Applicable product
        loanRec.Product__c = '10104';
        update loanRec;
        resp = AusfbFinancialByCreditController.viewAndEditRight(applicant.Id);
        System.assertEquals(resp.get('visible'), true,'Financial Template visible');
        
        Test.stopTest();
    }

    /**
    * @description Checking if inserting Financial detail
    * @author Ajitesh | 10-29-2023 
    **/
    @isTest
    static void insertFinancialDetailsAndGetIntialDataTest(){

        // Setting up database
        Id applicantId = [SELECT Applicant__c FROM Applicant_Financials_Details__c WHERE RecordType.DeveloperName = 'Financial_Parent' LIMIT 1].Applicant__c;
        List<Applicant_Financials_Details__c> applicantDetails = new List<Applicant_Financials_Details__c>();
        applicantDetails.add(new Applicant_Financials_Details__c(
            Credit_Financial_Date__c = Date.newInstance(System.today().year(), System.today().month(), System.today().day()),
            Applicant__c = applicantId
        ));
        applicantDetails.add(new Applicant_Financials_Details__c(
            Credit_Financial_Date__c = Date.newInstance(System.today().year() - 1, System.today().month(), System.today().day()),
            Applicant__c = applicantId
        ));
        applicantDetails.add(new Applicant_Financials_Details__c(
            Credit_Financial_Date__c = Date.newInstance(System.today().year() - 2, System.today().month(), System.today().day()),
            Applicant__c = applicantId
        ));

        Test.startTest();

        // Check if applicant financial is inserted
        AusfbFinancialByCreditController.insertFinancialDetails(
            applicantDetails,
            '[]',
            20,
            20,
            20,
            20,
            [SELECT Id FROM Applicant_Financials_Details__c WHERE RecordType.DeveloperName = 'Financial_Parent' LIMIT 1].Id
        );

        applicantDetails = AusfbFinancialByCreditController.getInitialData(applicantId);

        System.assertEquals(applicantDetails.size(), 4, 'Data got created');
        
        Test.stopTest();
    }

    /**
    * @description Financial Template validation check
    * @author Ajitesh | 10-29-2023 
    **/
    @isTest
    static void isFinancialTemplateConditionMatchNDataNotFilledTest(){
        Loan_Application__c loanRec = [SELECT Id FROM Loan_Application__c LIMIT 1];
        String isFilled = '';

        Test.startTest();

        // Non Applicable Loan
        isFilled = AusfbFinancialByCreditController.isFinancialTemplateConditionMatchNDataNotFilled(loanRec.Id);
        System.assert(isFilled == 'no-error', 'Not applicable loan ');

        // Applicable product
        loanRec.Product__c = '10104';
        update loanRec;
        isFilled = AusfbFinancialByCreditController.isFinancialTemplateConditionMatchNDataNotFilled(loanRec.Id);
        System.assert(isFilled == 'no-error', 'Not applicable loan ');

        // Applicable Collateral Grade
        loanRec.Collateral_Type__c = '10104';
        update loanRec;
        isFilled = AusfbFinancialByCreditController.isFinancialTemplateConditionMatchNDataNotFilled(loanRec.Id);
        System.assert(isFilled == 'no-error', 'Not applicable loan ');

        // Applicable Customer Type
        Applicant__c applicant= [SELECT Customer_Type__c, Date_of_Establishment__c FROM Applicant__c WHERE Loan__c = :loanRec.Id AND RecordType.DeveloperName = 'Primary_Applicant'];
        applicant.Customer_Type__c = 'Non Individual';
        update applicant;
        isFilled = AusfbFinancialByCreditController.isFinancialTemplateConditionMatchNDataNotFilled(loanRec.Id);
        System.assert(isFilled != 'no-error', 'Not applicable loan ');

        // Applicable Month of establishment
        
        // Setting up applicant financial template data by credit
        Id applicantId = [SELECT Applicant__c FROM Applicant_Financials_Details__c WHERE RecordType.DeveloperName = 'Financial_Parent' LIMIT 1].Applicant__c;
        List<Applicant_Financials_Details__c> applicantDetails = new List<Applicant_Financials_Details__c>();
        applicantDetails.add(new Applicant_Financials_Details__c(
            Credit_Financial_Date__c = Date.newInstance(System.today().year(), System.today().month(), System.today().day()),
            Applicant__c = applicantId
        ));
        applicantDetails.add(new Applicant_Financials_Details__c(
            Credit_Financial_Date__c = Date.newInstance(System.today().year() - 1, System.today().month(), System.today().day()),
            Applicant__c = applicantId
        ));
        applicantDetails.add(new Applicant_Financials_Details__c(
            Credit_Financial_Date__c = Date.newInstance(System.today().year() - 2, System.today().month(), System.today().day()),
            Applicant__c = applicantId
        ));

        AusfbFinancialByCreditController.insertFinancialDetails(
            applicantDetails,
            '[]',
            20,
            20,
            20,
            20,
            [SELECT Id FROM Applicant_Financials_Details__c WHERE RecordType.DeveloperName = 'Financial_Parent' LIMIT 1].Id
        );
        // Setting up applicant financial template data by credit

        applicant.Date_of_Establishment__c = Date.newInstance(System.today().year() - 3, System.today().month(), System.today().day());
        update applicant;
        isFilled = AusfbFinancialByCreditController.isFinancialTemplateConditionMatchNDataNotFilled(loanRec.Id);
        System.assert(isFilled != 'no-error', 'not Applicable loan ');

        // Applicable Customer grade
        Id commercialVehicle = [SELECT Id FROM RecordType WHERE DeveloperName = 'Commercial_Vehicle'].Id;
        loanRec.Customer_Grade__c = 'Captive';
        loanRec.RecordTypeId = commercialVehicle;
        update loanRec;
        isFilled = AusfbFinancialByCreditController.isFinancialTemplateConditionMatchNDataNotFilled(loanRec.Id);
        System.assert(isFilled != 'no-error', 'not applicable loan ');

        // Applicable Sub-Grade
        loanRec.Sub_Grade__c = 'With financials';
        update loanRec;
        isFilled = AusfbFinancialByCreditController.isFinancialTemplateConditionMatchNDataNotFilled(loanRec.Id);
        System.assert(isFilled != 'no-error', 'Not applicable loan ');

        Test.stopTest();
    }

    /**
    * @description Check if Deviation is created archived on base of logic
    * @author Ajitesh | 10-29-2023 
    **/
    @isTest
    static void createOrArchiveDeviationFinancialTemplateTest(){
        // Setting up database
        Loan_Application__c loanRec = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Applicant__c applicant= [SELECT Customer_Type__c, Date_of_Establishment__c FROM Applicant__c WHERE Loan__c = :loanRec.Id AND RecordType.DeveloperName = 'Primary_Applicant'];
        
        loanRec.Product__c = '10104';
        loanRec.Collateral_Type__c = '10104';
        applicant.Customer_Type__c = 'Non Individual';
        applicant.Date_of_Establishment__c = Date.newInstance(System.today().year() - 3, System.today().month(), System.today().day());

        update loanRec;
        update applicant;
        
        Id applicantId = [SELECT Applicant__c FROM Applicant_Financials_Details__c WHERE RecordType.DeveloperName = 'Financial_Parent' LIMIT 1].Applicant__c;
        List<Applicant_Financials_Details__c> applicantDetails = new List<Applicant_Financials_Details__c>();
        applicantDetails.add(new Applicant_Financials_Details__c(
            Credit_Financial_Date__c = Date.newInstance(System.today().year(), System.today().month(), System.today().day()),
            Applicant__c = applicantId,
            Strategic_Cash_Profit_of_current_year_to__c = -1,
            Strategic_YOY_Turnover_to_be_ve__c = -1,
            DSCR_should_be_1_1__c = -1,
            Strategic_Debt_Equity_Ratio_including_p__c = -1,
            Strategic_Drs_Turnover_should_be_90__c = -1
        ));
        applicantDetails.add(new Applicant_Financials_Details__c(
            Credit_Financial_Date__c = Date.newInstance(System.today().year() - 1, System.today().month(), System.today().day()),
            Applicant__c = applicantId
        ));
        applicantDetails.add(new Applicant_Financials_Details__c(
            Credit_Financial_Date__c = Date.newInstance(System.today().year() - 2, System.today().month(), System.today().day()),
            Applicant__c = applicantId
        ));

        AusfbFinancialByCreditController.insertFinancialDetails(
            applicantDetails,
            '[]',
            20,
            20,
            20,
            20,
            [SELECT Id FROM Applicant_Financials_Details__c WHERE RecordType.DeveloperName = 'Financial_Parent' LIMIT 1].Id
        );
        // Setting up database

        Test.startTest();
        
        //Data to create deviation
        AusfbFinancialByCreditController.createOrArchiveDeviationFinancialTemplate(loanRec.Id);
        List<Deviation__c> deviations = [SELECT Id FROM Deviation__c WHERE Loan_Application__c = :loanRec.Id AND Active__c = true LIMIT 1];
        System.assert(deviations.size() == 1, 'one deviation created');

        // Data to check if deviation is already created
        AusfbFinancialByCreditController.createOrArchiveDeviationFinancialTemplate(loanRec.Id);
        deviations = [SELECT Id FROM Deviation__c WHERE Loan_Application__c = :loanRec.Id AND Active__c = true LIMIT 1];
        System.assert(deviations.size() == 1, 'one deviation already created');

        // Updating data to remove the created deviation
        Applicant_Financials_Details__c applicantFinanceDetail = [
            SELECT Strategic_Cash_Profit_of_current_year_to__c,  Strategic_YOY_Turnover_to_be_ve__c, DSCR_should_be_1_1__c, Strategic_Debt_Equity_Ratio_including_p__c,
             Strategic_Drs_Turnover_should_be_90__c FROM Applicant_Financials_Details__c WHERE Strategic_Cash_Profit_of_current_year_to__c = -1
        ];
        applicantFinanceDetail.Strategic_Cash_Profit_of_current_year_to__c = 0;
        applicantFinanceDetail.Strategic_YOY_Turnover_to_be_ve__c = 0;
        applicantFinanceDetail.DSCR_should_be_1_1__c = 0;
        applicantFinanceDetail.Strategic_Debt_Equity_Ratio_including_p__c = 0;
        applicantFinanceDetail.Strategic_Drs_Turnover_should_be_90__c = 0;
        update applicantFinanceDetail;

        // Deleting the existing deviation
        AusfbFinancialByCreditController.createOrArchiveDeviationFinancialTemplate(loanRec.Id);
        deviations = [SELECT Id FROM Deviation__c WHERE Loan_Application__c = :loanRec.Id AND Active__c = true LIMIT 1];
        System.assert(deviations.size() == 0, 'deviation deleted');
        Test.stopTest();
    }
}