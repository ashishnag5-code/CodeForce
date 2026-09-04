@isTest
public with sharing class CAMReportControllerTest {
    
    @TestSetup
    static void makeData(){

        Loan_Application__c loanApplParent = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12344',
            Loan_Amount__c  = 120000,
            LC_Code__c = '10101',
            Mobile__c = '9837476',
            Customer_Name__c = 'Kakashi'
            
        ),true); 

        Account state = new Account(Account_Name__c= 'Maharashtra',Name='State_Maharashtra');
        insert state;

        Account dealerMaster = new Account(Account_Name__c= 'Pune-Dealer', Account_Code__c  = '097', Name = 'Pune-Dealer', State__c=state.Id,recordTypeId=Schema.SObjectType.account.getRecordTypeInfosByName().get('Dealer').getRecordTypeId());
        insert dealerMaster;

        Loan_Application__c loanApplChild = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Loan_Amount__c  = 120000,
            Product__c = '10203',
            Parent_Loan__c = loanApplParent.Id,
            Dealer_Master__c = dealerMaster.Id
        ),true); 

        Applicant__c primaryAppl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            Loan__c  = loanApplChild.Id,
            First_Name__c  = 'Primary',
            Middle_Name__c = '',
            Last_Name__c = 'Applicant',
            Existing_Customer__c = 'Yes',
            CIF_No__c = '098',
            Bureau_Score__c = '150',
            RecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true); 

        Address__c address1 = (Address__c)TestFactory.createSObject(new Address__c(
            State__c='Gujarat',
            District__c='Ahmedabad',
            Address_Type__c='Permanent',
            Applicant__c=primaryAppl.Id
        ),true);

        Address__c address2 = (Address__c)TestFactory.createSObject(new Address__c(
            State__c='Gujarat',
            District__c='Ahmedabad',
            Address_Type__c='Current',
            Applicant__c=primaryAppl.Id
        ),true);

        Address__c address3 = (Address__c)TestFactory.createSObject(new Address__c(
            State__c='Gujarat',
            District__c='Ahmedabad',
            Address_Type__c='Touch Point',
            Applicant__c=primaryAppl.Id
        ),true);

        Address__c address4 = (Address__c)TestFactory.createSObject(new Address__c(
            State__c='Gujarat',
            District__c='Ahmedabad',
            Address_Type__c='Office',
            Applicant__c=primaryAppl.Id
        ),true);

        Applicant__c coAppl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            Loan__c  = loanApplChild.Id,
            First_Name__c  = 'Co',
            Middle_Name__c = '',
            Last_Name__c = 'Applicant',
            Bureau_Score__c = '150',
            RecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Co_Applicant').getRecordTypeId()
        ),true); 

        Applicant__c additionalMatch = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            Loan__c  = loanApplChild.Id,
            First_Name__c  = 'Additional',
            Middle_Name__c = '',
            Last_Name__c = 'Match',
            Applicant__c = primaryAppl.Id,
            RecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Additional_Match').getRecordTypeId()
        ),true); 

        Collateral__c collateral = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Loan__c  = loanApplChild.Id,
            Manufacture_Year__c = '2023',
            Fuel_Type__c = 'PETROL',
            RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId()
        ),true); 

        Deviation__c deviation = (Deviation__c)TestFactory.createSObject(new Deviation__c(
            Loan_Application__c  = loanApplChild.Id,
            Deviation_Type__c = 'ROI RBP',
            Source__c='SF'
        ),true); 

        BSR_PSL_Details__c bsrPsl = (BSR_PSL_Details__c)TestFactory.createSObject(new BSR_PSL_Details__c(
            Loan_Application__c  = loanApplChild.Id,
            RecordTypeId = Schema.SObjectType.BSR_PSL_Details__c.getRecordTypeInfosByDeveloperName().get('PSL').getRecordTypeId()
        ),true); 

        Applicant_Financials_Details__c afdParent = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
            Type_Of_Employment__c  = 'Salaried - Private',
            applicant__c  = primaryAppl.Id,
            RecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Financial_Parent').getRecordTypeId()
        ),true);
        
        Applicant_Financials_Details__c afdChild1 = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
            Type_Of_Employment__c  = 'Salaried - Private',
            applicant__c  = primaryAppl.Id,
            Average_Monthly_Salary__c = 12000,
            Applicant_Financials__c = afdParent.Id,
            RecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Salaried_Document').getRecordTypeId()
        ),true);

        Applicant_Financials_Details__c afdChild2 = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
            Type_Of_Employment__c  = 'Salaried - Private',
            applicant__c  = primaryAppl.Id,
            Monthly_Net_Profit__c = 12000,
            Applicant_Financials__c = afdParent.Id,
            RecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Assessed_No_Document').getRecordTypeId()
        ),true);

        Bank_Account_Records__c bank1 = (Bank_Account_Records__c)TestFactory.createSObject(new Bank_Account_Records__c(
            applicant__c  = primaryAppl.Id,
            No_of_Emi_Paid__c  = 8,
            Amount_Overdue__c  = 8000,
            RecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByDeveloperName().get('CBS').getRecordTypeId()
        ),true);

        Bank_Account_Records__c bank2 = (Bank_Account_Records__c)TestFactory.createSObject(new Bank_Account_Records__c(
            applicant__c  = primaryAppl.Id,
            No_of_Emi_Paid__c  = 8,
            Amount_Overdue__c  = 6000,
            RecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByDeveloperName().get('Cart').getRecordTypeId()
        ),true);

        Bank_Account_Records__c bank3 = (Bank_Account_Records__c)TestFactory.createSObject(new Bank_Account_Records__c(
            applicant__c  = primaryAppl.Id,
            No_of_Emi_Paid__c  = 8,
            Amount_Overdue__c  = 8000,
            EMI_Considered_for_Obligation__c='Yes',
            is_Enquiry_Type__c=false,
            RecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByDeveloperName().get('CIBIL').getRecordTypeId()
        ),true);

        Fleet__c fleet = (Fleet__c)TestFactory.createSObject(new Fleet__c(
            Relationship_with_borrower__c  = 'Father',
            Vehicle_Number__c  = '7847',
            Loan_Application__c = loanApplChild.Id
        ),true);

        TVR__c tvr = (TVR__c)TestFactory.createSObject(new TVR__c(
            Name_Of_Employee__c  = 'Name',
            Employee_ID__c  = '7847',
            Loan_Application__c = loanApplChild.Id
        ),true);

        Integration_Master__c intMaster = new Integration_Master__c(Name  = 'Collateral Dedupe API');
        insert intMaster;

        Integration_Checklist__c intChild = new Integration_Checklist__c();
        intChild.Response__c  = '{ "TransactionStatus" : {"ResponseCode" : "0","ResponseMessage" : "Success","ExtendedErrorDetails" : {"messages" : [{ "code" : 0}]},    "ValidationErrors" : [ null ]},  "CollateralDetails" : [ {"AccountCustomerRelation" : "GUA", "CostPrice" : "10000", "TotalCollateralValue": "100000","AccountNumber" : "9001020229453101","AmountBlockRecovery" : null,"AmountCollShareValueCollCcy" : 220000,"AmountCollValueAcCcy" : 220000,"AmountCollValueCollCcy" : 220000,"AmountShareValueAcCcy" : 220000,"AreaUnit" : null,"AssetClass" : "Used","AssuredValue" : null,"automobileTxtNotes1" : "Description 1","automobileTxtNotes2" : "Description 2","ChassisNumber" : "522075","CollateralCode" : "10102-SUV-INR","CollateralCoverValue" : 0,"CollateralCurrency" : 1,"CollateralDocument" : null,"CollateralHomebranch" : 2465,"RepoDate" : "2022-10-21","Narration" : "REPO WITHOUT RO"}]}';
        intChild.Loan_Application__c  = loanApplChild.Id; 
        intChild.Integration_Master__c  = intMaster.Id; 
        insert intChild;

        Document_Master__c docMaster1 = new Document_Master__c(Name='AUWheels0005');
        Document_Master__c docMaster2 = new Document_Master__c(Name='AUWheels0002');
        Document_Master__c docMaster3 = new Document_Master__c(Name='AUWheels0004');
        Document_Master__c docMaster4 = new Document_Master__c(Name='AUWheels0093');
        Document_Master__c docMaster5 = new Document_Master__c(Name='AUWheels0091');
        List<Document_Master__c> documentMasters = new List<Document_Master__c>{docMaster1, docMaster2, docMaster3, docMaster4, docMaster5};
        insert documentMasters;
        Document_Checklist__c docCheck1 = new Document_Checklist__c(Document_Master__c=docMaster1.Id, Applicant__c=primaryAppl.Id);
        Document_Checklist__c docCheck2 = new Document_Checklist__c(Document_Master__c=docMaster2.Id, Applicant__c=primaryAppl.Id);
        Document_Checklist__c docCheck3 = new Document_Checklist__c(Document_Master__c=docMaster3.Id, Applicant__c=primaryAppl.Id);
        Document_Checklist__c docCheck4 = new Document_Checklist__c(Document_Master__c=docMaster4.Id, Applicant__c=primaryAppl.Id);
        Document_Checklist__c docCheck5 = new Document_Checklist__c(Document_Master__c=docMaster5.Id, Applicant__c=primaryAppl.Id);
        List<Document_Checklist__c> documentChecklists = new List<Document_Checklist__c>{docCheck1, docCheck2, docCheck3, docCheck4, docCheck5};
        insert documentChecklists;

    }

    @isTest
    public static void testControllerMethods1(){
        Test.startTest();
        Id loanId = [SELECT Id FROM Loan_Application__c WHERE Application_Number__c  = 'AP-12345'][0].Id;
        CAMReportLWCController.runCAMReport(loanId);
        CAMReportLWCController.getLatestCAMReport(loanId);
        CAMReportLWCController.getCollaterals(loanId);
        CAMReportLWCController.runCAMReportFromFutureMethod(loanId);

        Test.stopTest();
    }

    @isTest
    public static void testControllerMethods2(){
        Test.startTest();
        Loan_Application__c loan = [SELECT Id FROM Loan_Application__c WHERE Application_Number__c  = 'AP-12345'];
        PageReference pageRef = Page.CreditSummary4W;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', String.valueOf(loan.Id));
        CAMReportVFPageController camController = new CAMReportVFPageController();
        CAMReportVFPageController.getLoan();
        CAMReportVFPageController.getApplicant();
        CAMReportVFPageController.getApplicants();
        //CAMReportVFPageController.getCollateral();
        CAMReportVFPageController.getFinancial();
        CAMReportVFPageController.setBankRecords();
        //CAMReportVFPageController.getFleetRecords();
        //CAMReportVFPageController.getTvrRecords();

        CAMReportChildComponentsController childController = new CAMReportChildComponentsController();
        CAMReportChildComponentsController.getCbs();
        CAMReportChildComponentsController.getLead();
        CAMReportChildComponentsController.getProd();

        CAMReportChildComponentsController.loan = [SELECT Dealer_Master__r.State__r.Account_Name__c, RecordType.Name, RecordType.DeveloperName From Loan_Application__c WHERE Application_Number__c  = 'AP-12345'];
        CAMReportChildComponentsController.getState();

        List<Applicant__c> applist = new List<Applicant__c>();
        applist = [SELECT Id, (SELECT Id, Bureau_Score__c FROM Applicants__r WHERE RecordType.DeveloperName='Additional_Match') From Applicant__c Where RecordType.DeveloperName in ('Primary_Applicant','Co_Applicant')];
        CAMReportChildComponentsController.applicants = applist;
        //CAMReportChildComponentsController.getAdditionalMatchScore();

        CAMReportChildComponentsController.applicantIds = new List<Id>();
        for(Applicant__c app: applist){
            CAMReportChildComponentsController.applicantIds.add(app.Id);
        }
        CAMReportChildComponentsController.addressList = new List<Address__c>();
        CAMReportChildComponentsController.getAddressTypeValues();

        CAMReportChildComponentsController.exposureDetailsForAppBanks = [SELECT Id, Name, Applicant__c, applicant__r.First_Name__c,applicant__r.Middle_Name__c, applicant__r.Last_Name__c, RecordType.DeveloperName FROM Bank_Account_Records__c];
        CAMReportChildComponentsController.getKeys();
        
        Applicant__c appl = [SELECT RecordTypeId, Customer_Type__c, RecordType.Name, Id, PAN__c, Aadhaar_Number__c, Voter_Id__c, Passport_Number__c, Driving_License_Id__c, First_Name__c, FOIR__c, Middle_Name__c, Last_Name__c, Constitution_Type__c, Gender__c, Marital_Status__c, Existing_Customer__c, Mobile_Number__c, Relationship_with_applicant__c, Dob__c, CIF_No__c, AML_Status__c, CFR_Status__c, Negative_Check_Status__c,PAN_verification_status__c, Bureau_Score__c, IsEmailVerified__c, Customer_Grade__c, Applicant__c, Applicant__r.Bureau_Score__c FROM Applicant__c WHERE RecordType.DeveloperName  = 'Primary_Applicant'];
        CAMReportChildComponentsController.applicant = appl;
        //CAMReportChildComponentsController.getApplicantExposure();

        CAMReportChildComponentsController.fleetRecords = [Select Id From Fleet__c];
        CAMReportChildComponentsController.tvrRecords = [Select Id From TVR__c];
        CAMReportChildComponentsController.lcDetails = 'ABC';
        CAMReportChildComponentsController.applicantName = 'APPL';
        CAMReportChildComponentsController.dealerNameAndCode = 'DEALER';
        CAMReportChildComponentsController.factor = 'SMALL';

        Test.stopTest();
    }

    @isTest
    public static void getAPIResponseTest(){
        List<Document_Checklist__c> documentChecklists = [SELECT Id FROM Document_Checklist__c];
        Test.startTest();
        for(Document_Checklist__c doc: documentChecklists){
            CAMReportLWCController.getAPIResponse(doc.Id);
        }
        System.assertEquals(documentChecklists.size()>0, true, 'Success');
        Test.stopTest();
    }

    @isTest
    public static void getActivePrimaryApplicantsTest(){
        List<Loan_Application__c> loan = [SELECT Id FROM Loan_Application__c WHERE Application_Number__c='AP-12345' LIMIT 1];
        Test.startTest();
        List<Applicant__c> app = CAMReportLWCController.getActivePrimaryApplicants(loan[0].Id);
        System.assertEquals(app.size()>0, true, 'Success');
        Test.stopTest();
    }

    @isTest
    public static void getFinancialsR2Test(){
        Test.startTest();
        List<Applicant__c> applicants = [SELECT Id FROM Applicant__c];
        List<String> applicantIds = new List<String>();
        for(Applicant__c app: applicants){
            applicantIds.add(app.Id);
        }
        CAMReportVFPageController.applicantIds = applicantIds;
        CAMReportVFPageController.getFinancialsR2();
        CAMReportVFPageController.handleCreditVerify();
        CAMReportVFPageController.getCbsCibilLoanRecords();
        Test.stopTest();
    }

    
    
}