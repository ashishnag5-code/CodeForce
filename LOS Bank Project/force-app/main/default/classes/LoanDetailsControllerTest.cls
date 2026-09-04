/**
 * @description       : 
 * @author            : Ajitesh
 * @group             : 
 * @last modified on  : 12-06-2023
 * @last modified by  : Ajitesh
**/
@isTest
public with sharing class LoanDetailsControllerTest {
    
    @TestSetup
    static void makeData(){
        // Create user without access to functionality
        Profile prof = [select Id,Name from profile where name = 'Standard User'];
        
        User usr = (User)TestFactory.createSObject(new User(firstName = 'Standard User',
        	lastName = 'test2',
        	profileId = prof.id,
        	username = 'standardUsertar'+UserInfo.getOrganizationId()+'@test.com',
        	email = 'test@test.com',
        	Branch_Code__c  = '2103'
    	),true);

        Id recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'Tractor'].Id;
        // Create user without access to functionality
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            RecordTypeId = recordTypeId,
            Loan_Amount__c  = 1200000,
            Product__c='10501',
            Tenure__c=12,
            EMI__c=100,
            ROI__c=0,
            Stage__c='DDE',
            Repayment_By__c ='Caroline Forbes',
            Repayment_Mode__c ='NACH with PDC',
            Vehicle_use__c = 'Personal'
        ),true);  
        
        Applicant__c applicant = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            loan__c  = loanAppl.Id,
            First_Name__c   = 'Caroline',
            Last_Name__c  = 'Forbes',
            RecordtypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId(),
            Total_Exposure__c  = 12000,
            Customer_Grade__c='IB',
            Type_Of_Employment__c = 'Farmer'
        ),true);
        /*
        Applicant__c applicant = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            loan__c  = loanAppl.Id,
            First_Name__c   = 'Caroline1',
            Last_Name__c  = 'Forbes1',
            RecordtypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Applicant').getRecordTypeId(),
            Total_Exposure__c  = 12000
        ),false);
        */    
        Address__c address = (Address__c)TestFactory.createSObject(new Address__c(
            State__c='Gujarat',
            District__c='Ahmedabad',
            Address_Type__c='Current',
            Applicant__c=applicant.Id
        ),true);

        // For fetching schemes for tractor QDE

        Date start = Date.newInstance(1999, 12, 31);
        Date endDate = Date.newInstance(2090, 12, 31);
        Scheme_Master__c scheme1 = (Scheme_Master__c)TestFactory.createSObject(new Scheme_Master__c(
            START_DATE__c  = start,
            EXPIRY_DATE__c   = endDate,
            Is_InActive__c  = false,
            Scheme_Name__c = 'Normal',
            Collateral__c = '10109;',
            Vehicle_Category__c = 'A;B;C;D;E',
            Type_of_Customer__c = 'NTB;ETB;ETV',
            Type_of_employment__c = 'Farmer;',
            Customer_Type__c ='I;NI;',
            Type_of_loan__c = 'New;Used;Cow;',
            Profile__c = 'IB;NIB',
            CIBIL_Max__c=900,
            CIBIL_Min__c=100,
            Include__c = -1,
            Vehicle_Usage__c = 'Personal',
            Is_Location_General_Scheme__c= 'False',
            Is_Make_model_Scheme__c = 'False',
            Is_Dealer_Scheme__c = 'False'
        ),true);

        Collateral__c coll = (Collateral__c)TestFactory.createSObject(new Collateral__c(
            Owner_Serial_number__c='1111', vehicle_color__c = 'Blue', Kilometer__c = '10', 
            Loan__c = loanAppl.id, Chasis_Number__c ='12445', Engine_Number__c ='43232',
            Vehicle_Number__c  ='124234' , Vehicle_Usage__c  = 'Personal' ,  
            Vehicle_Category__c  = 'A', Collateral_Name__c = '10109'
        ),true);

        Bureau_Results__c BureauRes = (Bureau_Results__c)TestFactory.createSObject(new Bureau_Results__c(
            Applicant__c = applicant.id, Bureau__c = 'CIBIL',
            Bureau_Score__c = 0,
            Account_High_Credit_Amount__c = 100
        ),true);
        
        // For fetching schemes for tractor QDE

        Bank_Account_Records__c bankAcc1 = (Bank_Account_Records__c)TestFactory.createSObject(new Bank_Account_Records__c(
            Bank_Name__c  = 'Canara',
            Account_Number__c  = '378459375',
            Applicant__c=applicant.Id,
            RecordtypeId=Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByDeveloperName().get('Cart').getRecordTypeId()
        ),true);  

        Bank_Account_Records__c bankAcc2 = (Bank_Account_Records__c)TestFactory.createSObject(new Bank_Account_Records__c(
            Bank_Name__c  = 'HDFC',
            Account_Number__c  = '378459375',
            Applicant__c=applicant.Id,
            RecordtypeId=Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByDeveloperName().get('CBS').getRecordTypeId()
        ),true);
        
        List<Generic_Master__c> bankRecords = new List<Generic_Master__c>();
        bankRecords.add(createBankRecords('HDFC'));
        bankRecords.add(createBankRecords('CANARA'));
        bankRecords.add(createEMIBankRecords('ICICI'));
        bankRecords.add(createRateChartBankRecords('ICICI1'));
        insert bankRecords;
        
        Payment__c paymnt = (Payment__c)TestFactory.createSObject(new Payment__c(
            Partial_Payment_Condition__c = 'Testgs',
            loan_application__c = loanAppl.id, 
            Inactive__c = false, 
            RecordTypeId=Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Tranche').getRecordTypeId()
        ),true);

        IFSC_Master__c ifscm = (IFSC_Master__c)TestFactory.createSObject(new IFSC_Master__c(
            Bank_Name__c = 'HDFC',
            IFSC__c = '009B',
            MICR_Code__c = 'MICR Code'
        ),true);
    }

    public static Generic_Master__c createBankRecords(String name){
        Generic_Master__c bank = new Generic_Master__c();
        bank.Bank_Name__c=name;
        bank.Bank_Code__c='898';
        bank.Net_Banking__c='Live';
        bank.Debit_Card__c='Live';
        bank.RecordTypeId=Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByDeveloperName().get('Bank_Master').getRecordTypeId();
        return bank;
    }
    public static Generic_Master__c createEMIBankRecords(String name){
        Generic_Master__c bank = new Generic_Master__c();
        bank.Bank_Name__c=name;
        bank.Bank_Code__c='898';
        bank.Net_Banking__c='Live';
        bank.Debit_Card__c='Live';
        bank.Product__c = '10201';
        bank.RecordTypeId=Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByDeveloperName().get('EMI_Schedule').getRecordTypeId();
        return bank;
    }
     public static Generic_Master__c createRateChartBankRecords(String name){
        Generic_Master__c bank = new Generic_Master__c();
        bank.Bank_Name__c=name;
        bank.Bank_Code__c='898';
        bank.Net_Banking__c='Live';
        bank.Debit_Card__c='Live';
        bank.Product__c = '10201';
        bank.RecordTypeId=Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByDeveloperName().get('Rate_Chart_Code').getRecordTypeId();
        return bank;
    }

    public static Emi_schedule__c createEMIScheduleRecords(Id loanId){
        Emi_schedule__c emi = new Emi_schedule__c();
        emi.stage_number__c=1;
        emi.installment_number__c=2;
        emi.installment_amount__c=1000;
        emi.loan_application__c=loanId;
        emi.isInactive__c=false;
        return emi;
    }

    @isTest
    public static void testgetVisibleFieldsForLoanDetails(){
        Test.startTest();
        Loan_Application__c loan = [SELECT Id, Disbursement_Category__c, Schedule_Type__c from Loan_Application__c LIMIT 1];
        Applicant__c app = [SELECT Id FROM Applicant__c LIMIT 1 ];
        LoanDetailsController.getVisibleFieldsForLoanDetails('Loan Details','QDE','');
        LoanDetailsController.getVisibleFields('Loan Details','QDE','','');
        LoanDetailsController.getFieldsToBeDisabled();
        LoanDetailsController.updateLoanApp(JSON.serialize(loan));
        LoanDetailsController.getBankName('009B');
        LoanDetailsController.getApplicants(loan.Id);
        LoanDetailsController.getApplicantBankAccountRecords(app.Id);
        LoanDetailsController.getBankMasterRecords();
        LoanDetailsController.getBankRecords(loan.Id);
        LoanDetailsController.getDetails(loan.Id);
        loan.Repayment_By_User__c = app.Id;
        loan.Disbursement_Category__c='Full';
        loan.Schedule_Type__c='IOI';
        update loan;
        loan = [SELECT Id, Disbursement_Category__c, Schedule_Type__c from Loan_Application__c LIMIT 1];
        LoanDetailsController.markDataInactive(loan);
        List<EMI_Schedule__c> newListEMI = new List<EMI_Schedule__c>();
        newListEMI.add(createEMIScheduleRecords(loan.Id));
        newListEMI.add(createEMIScheduleRecords(loan.Id));
        newListEMI.add(createEMIScheduleRecords(loan.Id));
        LoanDetailsController.upsertData(newListEMI,loan.Id,35);
        List<EMI_Schedule__c> emiList = [select id, isInactive__c from emi_schedule__c where loan_application__c=:loan.Id and isInactive__c=false];
        List<id> idList = new List<id>();
        idList.add(emiList[0].Id);
        LoanDetailsController.deleteEmiDetails(idList,loan.Id);
        LoanDetailsController.markDataInactive(loan);
        LoanDetailsController.updateStageNumber(loan.Id);
        loan.Stage__c = 'QDE';
        update loan;
        LoanDetailsController.getDetails(loan.Id);
        //loan.Stage__c='DDE';        
        loan.Repayment_By__c = '';
        update loan;
        LoanDetailsController.getDetails(loan.Id); 
        Test.stopTest();
    }
    
    @isTest
    public static void testLoanDetails(){
        
        Loan_Application__c loan = [SELECT Id, Disbursement_Category__c, Schedule_Type__c, Repayment_By_User__c, Repayment_Mode__c, Primary_Applicant__c, Primary_Applicant__r.Loan__c, Primary_Applicant__r.RecordtypeId from Loan_Application__c LIMIT 1];

        Applicant__c applicant = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            loan__c  = loan.Id,
            First_Name__c   = 'Caroline1',
            Last_Name__c  = 'Forbes1',
            RecordtypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Co_Applicant').getRecordTypeId(),
            Total_Exposure__c  = 12000
        ),true);
        
        Document_Master__c docMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Document_Name__c = 'Test Document', 
            Document_Id__c = 'AUWheels0051', 
            Document_Sub_Category__c = 'Loan', 
            Document_Category__c = 'Loan Document'
        ),true);
        
         Document_Master__c docMaster45 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Document_Name__c = 'Test Document', 
            Document_Id__c = 'AUWheels0045', 
            Document_Sub_Category__c = 'Loan', 
            Document_Category__c = 'Loan Document'
        ),true);
        
        Document_Master__c docMaster136 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Document_Name__c = 'Test Document', 
            Document_Id__c = 'AUWheels0136', 
            Document_Sub_Category__c = 'Loan', 
            Document_Category__c = 'Loan Document'
        ),true);
        
        Document_Checklist__c docChecklist = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Applicant__c = applicant.Id, 
            Document_Master__c = docMaster.Id//, 
            //Loan_Application__c = loan.Id
        ),true);
        
        test.startTest();
        Applicant__c app = [SELECT Id, RecordtypeId, Loan__c FROM Applicant__c WHERE loan__c=:loan.Id and Id =: applicant.Id LIMIT 1 ];
        loan.Repayment_By_User__c = app.Id;
        //update loan;
        LoanDetailsController.updateLoanApp(JSON.serialize(loan)); 
        LoanDetailsController.updateLoanApp('');
        Document_Checklist__c checklist = [Select Id, Loan_Application__c from Document_Checklist__c LIMIT 1];
        checklist.Loan_Application__c = loan.Id;
        update checklist;
        LoanDetailsController.updateLoanApp(JSON.serialize(loan));
        //Document_Master__c docMstr = [SELECT Id,Document_Id__c FROM Document_Master__c LIMIT 1];
        //docMstr.Document_Id__c = 'AUWheels0045';
        //update docMstr;
        LoanDetailsController.updateLoanApp(JSON.serialize(loan));
        loan.Repayment_Mode__c ='E mandate with PDC';
        update loan;
        LoanDetailsController.updateLoanApp(JSON.serialize(loan));
        test.stopTest();
        
    }

    // Tractor Validation feture test

    
    /**
    * @description Testing of validation config exist
    * @author Ajitesh | 11-07-2023 
    **/
    @isTest
    public static void getTractorValidationsTest() {
        Test.startTest();
        List<Loan_Details_Validation_Trac_Comm__mdt> metadataConfig = LoanDetailsController.getTractorValidations();
        System.assert(metadataConfig.size() > 0, 'Config exists');
        Test.stopTest();
    }

    

    /**
    * @description Testing exception handling
    * @author Ajitesh | 11-07-2023 
    **/
   @isTest static void exceptionHandlingTest() {
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        Loan_Application__c loanApp = [SELECT Id FROM Loan_Application__c LIMIT 1];

        System.runAs(usr){
            Test.startTest();
            try{
                List<Loan_Details_Validation_Trac_Comm__mdt> metadataConfig = LoanDetailsController.getTractorValidations();
            }
            catch(Exception e) {
                System.assert(true, 'Error occured ');
            }
           

            try{
                String micrCode = LoanDetailsController.getMICRCode('009B');
            }
            catch(Exception e) {
                System.assert(true, 'Error occured ');
            }
            Test.stopTest();
        }
    }

    // Tractor Validation feture test

    // Scheme field addtion on QDE Tractor


    /**
    * @description Fetch schemes applicable for tractor QDE
    * @author Ajitesh | 11-09-2023 
    **/
    @isTest static void getSchemePickListValuesTest(){
        Loan_Application__c loanApp = [SELECT Id,Branch_Master__c, Product__c, Customer_Type__c, Net_Land_Holding_in_Acre__c,Vehicle_use__c, Customer_Grade__c  FROM Loan_Application__c LIMIT 1];
        Applicant__c app = [SELECT Id,Type_of_Employment__c,Customer_Grade__c,Existing_Customer__c FROM Applicant__c LIMIT 1];
        Collateral__c col = [SELECT Collateral_Name__c, Vehicle_Category__c FROM Collateral__c LIMIT 1];
        Scheme_Master__c scheme = [SELECT Is_Location_General_Scheme__c, Is_Make_model_Scheme__c, Is_Dealer_Scheme__c FROM Scheme_Master__c LIMIT 1];
        Test.startTest();
        AUSFVehicleController.SchemeWrapper schemeWrap = LoanDetailsController.getSchemePickListValues(
            loanApp,
            app,
            col.Vehicle_Category__c,
            col.Collateral_Name__c
        );
        System.assert(schemeWrap !=null ,'Scheme fetched ');
        
        scheme.Is_Location_General_Scheme__c='True';
        scheme.Is_Make_model_Scheme__c='True';
        scheme.Is_Dealer_Scheme__c='True';
        update scheme;
        schemeWrap = LoanDetailsController.getSchemePickListValues(
            loanApp,
            app,
            col.Vehicle_Category__c,
            col.Collateral_Name__c
        );
        System.assert(schemeWrap !=null ,'Scheme fetched ');

        Test.stopTest();
    }
    // Scheme field addtion on QDE Tractor

    
    // Testing revist screen update
    @isTest static void testUpdateRevisitScreen(){
        Applicant__c applicant = [SELECT Re_Visit_Screens__c, Loan__c FROM Applicant__c ORDER BY CreatedDate DESC LIMIT 1 ];
        Map<String,Boolean> revisitScreenMap = new Map<String,Boolean>();
        revisitScreenMap.put('LoanDetails', true);
        applicant.Re_Visit_Screens__c = JSON.serialize(revisitScreenMap);
        update  applicant;
        
        Test.startTest();
        LoanDetailsController.updateRevisitScreen(applicant.loan__c);
        applicant = [SELECT Re_Visit_Screens__c, Loan__c FROM Applicant__c ORDER BY CreatedDate DESC LIMIT 1 ];
        revisitScreenMap = new Map<String,Boolean>();
        revisitScreenMap = (Map<String,Boolean>)JSON.deserialize(applicant.Re_Visit_Screens__c, Map<String,Boolean>.class);
        System.assert(revisitScreenMap.get('LoanDetails')!=true,'loanDetails key is false');

        Test.stopTest();
    }
    // Testing revist screen update

    @isTest static void getMICRCodeTest(){
        
        Test.startTest();
        String micrCode = LoanDetailsController.getMICRCode('009B');
        System.assert(micrCode !=null ,'MICR Code fetched ');
        Test.stopTest();
    }

    @isTest static void calculateEMIAmountTest(){
        Loan_Application__c loanApp = [SELECT ROI__c, Tenure__c, Total_Loan_Amount__c, EMI__c  FROM Loan_Application__c LIMIT 1];
        loanApp.ROI__c = 20;
        loanApp.Tenure__c = 10;
        loanApp.Total_Loan_Amount__c = 20000000;
        Test.startTest();
        double emiAmount = LoanDetailsController.calculateEMIAmount(loanApp);
        System.assert(emiAmount !=null ,'EMI calculated ');
        Test.stopTest();
    }


    @isTest static void panVerificationTest(){
        Test.startTest();
        Loan_Application__c loanApp = [SELECT ROI__c, Tenure__c, Loan_Amount__c, EMI__c, tolabel(Product__c), RecordType.DeveloperName FROM Loan_Application__c WHERE RecordType.Developername='Tractor' LIMIT 1];
        LoanDetailsController.panVerification(loanApp);
        Applicant__c appl = [SELECT Id, Customer_Type__c FROM Applicant__c WHERE Loan__c=:loanApp.Id];
        appl.Customer_Type__c='Non Individual';
        update appl;
        List<Applicant__c> applicants = LoanDetailsController.panVerification(loanApp);
        System.assert(applicants.size()==0 ,'Pan Needs to be verified');
        Test.stopTest();
    }
    
}