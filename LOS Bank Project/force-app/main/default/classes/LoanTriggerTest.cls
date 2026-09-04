@isTest
public class LoanTriggerTest {
    @testSetup static void setup() {
        
        Document_Master__c  docMaster1 = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(Name ='AUWheels0053', Document_Id__c = 'AUWheels0053', Document_Name__c  ='FI Photos', Active__c = true),true);
        
        List<Rule_Definition__c> lstRuleDef = new List<Rule_Definition__c>();
        Rule_Definition__c objRuleDef = (Rule_Definition__c )TestFactory.createSObject(new Rule_Definition__c ( Attribute_Fixed_Value__c = 'Auto Loan (New) ;Two Wheeler (New) ;Car Taxi (New) ;Construction Equipment (New) ;CV Loading (New) ;CV Passenger (New) ;Tractor (New)',
        Rule_Condition__c = 'Contains',
        Subject_Object__c = 'Loan_Application__c',
        Subject_Field__c = 'toLabel(Product__c)', Target_Object__c = 'Document_Checklist__c',
        Value_Field__c = 'Value', 
        Sequence__c = 1, Rule_Name__c = 'For all new Applications'),false);
        lstRuleDef.add(objRuleDef);
        
        insert lstRuleDef;
        
        Rule_Driver__c objRuleDriver = (Rule_Driver__c )TestFactory.createSObject(new Rule_Driver__c ( Configuring_For__c = 'Document Checklist', 
        Effective_To__c = System.Today().addDays(365), Effective_From__c = System.Today().addDays(-10), Logical_Expression__c = '1', Target_Value__c = 'AUWheels0053', Match_Criteria__c = 'All Match'),false);
        insert objRuleDriver; 
        
        List<Rule_Definition_Driver_Mapping__c> lstDriverMapping = new List<Rule_Definition_Driver_Mapping__c>();
        for (Rule_Definition__c objRuleD : [Select Id from Rule_Definition__c]) {
            Rule_Definition_Driver_Mapping__c objMap = (Rule_Definition_Driver_Mapping__c )TestFactory.createSObject(new Rule_Definition_Driver_Mapping__c ( 
                Rule_Driver_ID__c = objRuleDriver.Id ,
                Rule_ID__c = objRuleD.Id 
            ),false);
            lstDriverMapping.add(objMap);
        }
        insert lstDriverMapping;
        
        RecordType rd=[select id from RecordType where name='Two Wheeler' and  sobjectType='Loan_Application__c'];
        List<Loan_Application__c> applicationList = new List<Loan_Application__c>();

        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true,
            Stage__c='QDE',
            Final_Exposure__c =10,
            RecordTypeId=rd.Id,
            Emi_Frequency__c = 'HALF YEARLY',
            EMI_Date__c = '10',
            First_EMI_Date__c = Date.newInstance(2022, 06, 01)
        ),false);
        applicationList.add(loanAppl);
        
        Loan_Application__c loanAppl2 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12346',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true,
            Stage__c='QDE',
            Final_Exposure__c =10,
            RecordTypeId=rd.Id,
            Emi_Frequency__c = 'QUARTERLY',
            EMI_Date__c = '18',
            First_EMI_Date__c = Date.newInstance(2022, 06, 05)
        ),false);
        applicationList.add(loanAppl2);
        
        Loan_Application__c loanAppl3 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12347',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true,
            Stage__c='QDE',
            Final_Exposure__c =10,
            RecordTypeId=rd.Id, 
            Emi_Frequency__c = 'MONTHLY', 
            EMI_Date__c = '10',
            First_EMI_Date__c = Date.newInstance(2022, 06, 10)
        ),false);
        applicationList.add(loanAppl3);

                
        Id leadRecordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Lead').getRecordTypeId();
        Loan_Application__c loanAppl4 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12348',
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true,
            Stage__c='Lead',
            Final_Exposure__c =10,
            RecordTypeId=leadRecordTypeId, 
            Emi_Frequency__c = 'MONTHLY', 
            EMI_Date__c = '10',
            First_EMI_Date__c = Date.newInstance(2022, 06, 10)
        ),false);
        applicationList.add(loanAppl4);

        Loan_Application__c loanAppl5 = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12349',
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=false,
            Stage__c='PSD',
            Final_Exposure__c =10,
            RecordTypeId=rd.Id, 
            Emi_Frequency__c = 'MONTHLY', 
            EMI_Date__c = '10',
            First_EMI_Date__c = Date.newInstance(2022, 06, 10),
            Credit_Approval_Date__c = Date.TODAY(),
            Repayment_Mode__c = 'Standing Instructions',
            Esign_Type__c = 'Digital',
            Dpd_Found__c = false
        ),false);

        applicationList.add(loanAppl5);

        insert applicationList;

        
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Customer_Type__c ='Non Individual',
            Residential_Status__c ='Resident',
            Loan__c =loanAppl.Id
        ),true);

        
        Applicant__c appl5 = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikashi',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            Customer_Type__c ='Non Individual',
            Residential_Status__c ='Resident',
            KYC_Status__c = 'Complete',
            KYC_Type__c = 'Aadhaar - OTP',
            Loan__c =loanAppl5.Id
        ),true);
        
        Address__c  addInstance = (Address__c)TestFactory.createSObject(new Address__c(
            Address_Line_1__c ='TestAddressline1',
            Address_Line_2__c ='TestAddressline2',
            Address_Line_3__c ='TestAddressline3',
            State__c='MAHARASHTRA',
            City__c='EAST DELHI',
            Area_Name__c='JAGJIT NAGAR',
            Area_Type__c='Urban',
            Taluka__c='NA',
            Pincode__c='110053',
            Land_mark__c='Testing',
            Applicant__c =appl5.Id,
            Status__c='Owned',
            Address_Type__c='Current',
            Type__c='Bungalow'
        ),true);

        List<Applicant_Financials_Details__c> appFinList = new List<Applicant_Financials_Details__c>();
        Applicant_Financials_Details__c af1 = new Applicant_Financials_Details__c();
        af1.RecordTypeId=Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Financial_Parent').getRecordTypeId();
        af1.Applicant__c = appl.Id;
        af1.Monthly_Income__c = 2000;
        af1.Monthly_Obligation__c = 1000;
        af1.Consider_Income_for_Eligibility__c = 'Yes';
        Applicant_Financials_Details__c af2 = new Applicant_Financials_Details__c();
        af2.RecordTypeId=Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByDeveloperName().get('Financial_Parent').getRecordTypeId();
        af2.Applicant__c = appl5.Id;
        af2.Monthly_Income__c = 2000;
        af2.Monthly_Obligation__c = 5000;
        af2.Consider_Income_for_Eligibility__c = 'Yes';
        appFinList.add(af1);
        appFinList.add(af2);
        insert appFinList;
         
        
        Document_Master__c  docMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c(
            Name ='Test',
            Document_Name__c  ='Customers Signature'
        ),true);
        
        Document_Checklist__c docChkRecord = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            //Parent_Loan__c   = loanAppl.Id,
            Applicant__c = appl.Id,
            Document_Master__c = docMaster.Id,
            Document_Name__c ='Customers Signature'
            //Credit_FTR_FTNR__c = 'FTNR'
        ),true);
      Collateral__c coll= new Collateral__c(Loan__c=loanAppl.Id);
      coll.RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId();
        
      insert coll;

      coll= new Collateral__c(Loan__c=loanAppl3.Id);
      coll.RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId();
        
      insert coll;
        
     Charge__c rec = new Charge__c(Loan_Application__c = loanAppl.Id, Value_Type__c = 'Percent', Actual_rate__c = 2, Charges_Name__c = 'Stamp duty');
     insert rec;   
        
    }


    @isTest static void getAddress1() {
       Test.startTest();
           Loan_application__c loan = [select id from Loan_application__c where Application_Number__c='AP-12345'];
           loan.Adhar_Card__c=123454;
           //loan.Loan_Amount__c=2340;
           loan.Stage__c='DDE';
           loan.EMI_Date__c = '18' ;
           update loan;
       
       Test.stopTest();
    }
    
    @isTest static void updateFirstEMIDate() {
       Test.startTest();
           Loan_application__c loan = [select id from Loan_application__c where Application_Number__c='AP-12345'];
           loan.Adhar_Card__c=123454;
           //loan.Loan_Amount__c=2340;
           loan.Stage__c='DDE';
           loan.EMI_Date__c = '18' ;
           loan.First_EMI_Date__c = Date.newInstance(2023, 11, 18);
           update loan;
       
       Test.stopTest();
    }
    
    @isTest static void getAddress2() {
       Test.startTest();
           Loan_application__c loan = [select id from Loan_application__c where Application_Number__c='AP-12346'];
           loan.Adhar_Card__c=123454;
           loan.Loan_Amount__c=2340;
           loan.Stage__c='DDE';
           update loan;
       
       Test.stopTest();
    }
    
    @isTest static void getAddress3() {
       Test.startTest();
           Loan_application__c loan = [select id, Product__c from Loan_application__c where Application_Number__c='AP-12347'];
           loan.Product__c = '10202';
           loan.Adhar_Card__c=123454;
           loan.Loan_Amount__c=2340;
           loan.Stage__c='DDE';
           update loan;
           
       Test.stopTest();
    }
    
    @isTest 
    static void testLoanTrigger() {
        Test.startTest();
            LoanTriggerService lts = new LoanTriggerService();        
            //lts.beforeInsert(new List<sObject>() );
            //lts.afterUpdate(new List<sObject>() , new Map<Id,sObject>() ,new Map<Id,sObject>() );
            lts.beforeDelete(new Map<Id,sObject>() );
            lts.afterDelete(new Map<Id,sObject>() );
            lts.afterUndelete(new Map<Id,sObject>() );        
        Test.stopTest();
    }
     @isTest 
    static void testLoanTriggerInsert() {
        Test.startTest();
                 RecordType rd=[select id from RecordType where name='Two Wheeler' and  sobjectType='Loan_Application__c'];
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-123488',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true,
            Stage__c='CREDIT',
            Final_Exposure__c =10,
            RecordTypeId=rd.Id,
            Emi_Frequency__c = 'HALF YEARLY',
            EMI_Date__c = '10',
            First_EMI_Date__c = Date.newInstance(2022, 06, 01)
        ),true);
        
        Document_Master__c docMaster = [Select Id from Document_Master__c limit 1];
        Document_Checklist__c docChkRecord1 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Loan_Application__c = loanAppl.Id,
            Document_Master__c = docMaster.Id,
            Document_Name__c ='Customers Signature',
            Credit_FTR_FTNR__c = 'FTNR',
            Mandatory__c = true
        ),true);

        
        Loan_Application__c obj = new Loan_Application__c();
        obj.Id = loanAppl.Id;
        obj.Stage__c = 'Ops Maker';
        obj.Ops_FTR_FTNR__c = 'FTNR';
        update obj;
        
        delete docChkRecord1;
        
        docChkRecord1 = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Loan_Application__c = loanAppl.Id,
            Document_Master__c = docMaster.Id,
            Document_Name__c ='Customers Signature',
            Ops_FTR_FTNR__c = 'FTNR',
            Mandatory__c = true
        ),true);
        
        obj = new Loan_Application__c();
        obj.Id = loanAppl.Id;
        obj.Stage__c = 'Credit';
        obj.Credit_FTR_FTNR__c = 'FTNR';
        obj.E_Mandate_Status__c = 'Accepted';
        obj.BRE_Decision__c = 'STP';
        update obj;
        
        Set<Id> appId = new Set<Id>();
        appId.add(obj.Id);
        
     //   LoanTriggerService.createApprovalRecords(appId);


        Test.stopTest();
    }
        @isTest
    public static void handleCredit1(){
         Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        String creditRecord='{\"CreditCardResponse\":[{\"AccountNumber\":\"234242424242424224242\",\"AccountOpenDate\":\"2022-02-28\",\"AccountStatus\":\"ACCOUNTOPENREGULAR\",\"CustomerAccountRelation\":\"SoleOwner\",\"CustomerFullName\":\"SULOCHANADAHARIYA\",\"CustomerID\":\"25139814\",\"Decode\":\"ALTURA\",\"DPDValue\":\"58\",\"LastStatementBalance\":\"49,520.69\",\"LoanStatus\":\"Standard\",\"ProductCode\":\"101\",\"SanctionedAmount\":\"45000\"}]}';
        Test.startTest();
        CustomerSummaryController.handleCCExposure('27972650',appl.Id,creditRecord);
        Test.stopTest();
    }
    
    @isTest 
    static void testLoanTriggerInsert1() {
        Test.startTest();
                 RecordType rd=[select id from RecordType where name='Two Wheeler' and  sobjectType='Loan_Application__c'];
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-123488',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true,
            Stage__c='CREDIT',
            Final_Exposure__c =10,
            RecordTypeId=rd.Id,
            Emi_Frequency__c = 'HALF YEARLY',
            EMI_Date__c = '10',
            First_EMI_Date__c = Date.newInstance(2022, 06, 01)
        ),true);
        
       
        
        Loan_Application__c obj = new Loan_Application__c();
        obj.Id = loanAppl.Id;
        obj.OPS_PDD_Action__c = 'Rework';
        obj.Ops_FTR_FTNR__c = 'FTNR';
        obj.Stage__c='PDD';
        
        update obj;
        
     

        Test.stopTest();
    }
    
    @isTest 
    static void testLoanTriggerInsert2() {
        Test.startTest();
                 RecordType rd=[select id from RecordType where name='Four Wheeler' and  sobjectType='Loan_Application__c'];
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-123488',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true,
            Stage__c='Pricing',
            Final_Exposure__c =10,
            RecordTypeId=rd.Id,
            Emi_Frequency__c = 'HALF YEARLY',
            EMI_Date__c = '10',
            First_EMI_Date__c = Date.newInstance(2022, 06, 01)
        ),true);
        
       
        
        Loan_Application__c obj = new Loan_Application__c();
        obj.Id = loanAppl.Id;
        obj.OPS_PDD_Action__c = 'Rework';
        obj.Ops_FTR_FTNR__c = 'FTNR';
        obj.Stage__c='PSD';
        obj.No_Pricing_Deviation__c = false;
        update obj;
        
     

        Test.stopTest();
    }
    
    @isTest 
    static void testLoanTriggerInsert3() {
        Test.startTest();
                 RecordType rd=[select id from RecordType where name='Two Wheeler' and  sobjectType='Loan_Application__c'];
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-123489',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10301',
            RC_Limit_On_Hold__c=true,
            Stage__c='Pricing',
            Final_Exposure__c =10,
            RecordTypeId=rd.Id,
            Emi_Frequency__c = 'HALF YEARLY',
            EMI_Date__c = '10',
            First_EMI_Date__c = Date.newInstance(2022, 06, 01)
        ),true);
        
       
        
        Loan_Application__c obj = new Loan_Application__c();
        obj.Id = loanAppl.Id;
        obj.OPS_PDD_Action__c = 'Rework';
        obj.Ops_FTR_FTNR__c = 'FTNR';
        obj.Stage__c='DDE';
        obj.No_Pricing_Deviation__c = false;
        obj.Loan_Amount__c = 10000000;
        update obj;
        
     

        Test.stopTest();
    }
    
    @isTest 
    static void testevaluateApprovedLTV1() {
        Test.startTest();
            RecordType rd=[select id from RecordType where name='Tractor' and sobjectType='Loan_Application__c'];
            Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-123489',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10501',
            RC_Limit_On_Hold__c=true,
            Stage__c='Pricing',
            Final_Exposure__c =10,
            Customer_Grade__c ='FTU',
            Original_Vehicle_Usage__c='Agri',
            Net_Land_Holding_in_Acre__c=3.0,
            RecordTypeId=rd.Id,
            Emi_Frequency__c = 'HALF YEARLY',
            EMI_Date__c = '10',
            First_EMI_Date__c = Date.newInstance(2022, 06, 01)
        ),true);
        
        Collateral__c coll= new Collateral__c(Loan__c=loanAppl.Id);
        coll.RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('New').getRecordTypeId();     
        insert coll;
        
        Loan_Application__c obj = new Loan_Application__c();
        obj.Id = loanAppl.Id;
        obj.Net_Land_Holding_in_Acre__c = 4.0;
        obj.Loan_Amount__c = 100;
        update obj;
        Test.stopTest();
    }

    @isTest 
    static void testevaluateApprovedLTV2() {
        Test.startTest();
            RecordType rd=[select id from RecordType where name='Tractor' and sobjectType='Loan_Application__c'];
            Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-123489',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10502',
            RC_Limit_On_Hold__c=true,
            Stage__c='Pricing',
            Final_Exposure__c =10,
            Customer_Grade__c ='FTU',
            Original_Vehicle_Usage__c='Agri',
            Net_Land_Holding_in_Acre__c=3.0,
            RecordTypeId=rd.Id,
            Emi_Frequency__c = 'HALF YEARLY',
            EMI_Date__c = '10',
            First_EMI_Date__c = Date.newInstance(2022, 06, 01)
        ),true);
        
        Collateral__c coll= new Collateral__c(Loan__c=loanAppl.Id);
        coll.RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId();     
        insert coll;
        
        Loan_Application__c obj = new Loan_Application__c();
        obj.Id = loanAppl.Id;
        obj.Net_Land_Holding_in_Acre__c = 4.0;
        update obj;
        Test.stopTest();
    }
    
    @isTest 
    static void testevaluateApprovedLTV3() {
        Test.startTest();
            RecordType rd=[select id from RecordType where name='Commercial Vehicle' and sobjectType='Loan_Application__c'];
            Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-123489',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10104',
            RC_Limit_On_Hold__c=true,
            Stage__c='Pricing',
            Final_Exposure__c =10,
            Customer_Grade__c ='FTU',
            Original_Vehicle_Usage__c='Agri',
            Net_Land_Holding_in_Acre__c=3.0,
            RecordTypeId=rd.Id,
            Emi_Frequency__c = 'HALF YEARLY',
            EMI_Date__c = '10',
            First_EMI_Date__c = Date.newInstance(2022, 06, 01)
        ),true);
        
        Collateral__c coll= new Collateral__c(Loan__c=loanAppl.Id,Assessment_Method__c='LTV',Vehicle_Category__c='A',Net_of_Discount_Price__c = 10.0);
        coll.RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('New').getRecordTypeId();     
        insert coll;
        
        Scheme_Master__c objScheme = new Scheme_Master__c(Scheme_Name__c = 'Normal');
        insert objScheme;
        
        Depreciated_Grid__c dep= new Depreciated_Grid__c(Scheme__c=objScheme.Id);
        dep.RecordTypeId = Schema.SObjectType.Depreciated_Grid__c.getRecordTypeInfosByDeveloperName().get('LTV').getRecordTypeId();     
        insert dep;
        
        Loan_Application__c obj = new Loan_Application__c();
        obj.Id = loanAppl.Id;
        obj.Net_Land_Holding_in_Acre__c = 4.0;
        update obj;
        Test.stopTest();
    }
    
    @isTest 
    static void testevaluateApprovedLTV4() {
        Test.startTest();
            RecordType rd=[select id from RecordType where name='Commercial Vehicle' and sobjectType='Loan_Application__c'];
            Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-123489',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10105',
            RC_Limit_On_Hold__c=true,
            Stage__c='Pricing',
            Final_Exposure__c =10,
            Customer_Grade__c ='FTU',
            Original_Vehicle_Usage__c='Agri',
            Net_Land_Holding_in_Acre__c=3.0,
            RecordTypeId=rd.Id,
            Emi_Frequency__c = 'HALF YEARLY',
            EMI_Date__c = '10',
            First_EMI_Date__c = Date.newInstance(2022, 06, 01)
        ),true);
        
        Collateral__c coll= new Collateral__c(Loan__c=loanAppl.Id,Assessment_Method__c='LTV',Vehicle_Category__c='A',Net_of_Discount_Price__c = 10.0,Apportioned_Loan_Amount__c = 10.0);
        coll.RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId();     
        insert coll;
        
        Scheme_Master__c objScheme = new Scheme_Master__c(Scheme_Name__c = 'Normal');
        insert objScheme;
        
        Depreciated_Grid__c dep= new Depreciated_Grid__c(Scheme__c=objScheme.Id);
        dep.RecordTypeId = Schema.SObjectType.Depreciated_Grid__c.getRecordTypeInfosByDeveloperName().get('LTV').getRecordTypeId();     
        insert dep;
        
        Loan_Application__c obj = new Loan_Application__c();
        obj.Id = loanAppl.Id;
        obj.Net_Land_Holding_in_Acre__c = 4.0;
        update obj;
        Test.stopTest();
    }
    
    @isTest 
    static void testevaluateApprovedLTV5() {
        Test.startTest();
            RecordType rd=[select id from RecordType where name='Construction Equipment' and sobjectType='Loan_Application__c'];
            Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-123489',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10401',
            RC_Limit_On_Hold__c=true,
            Stage__c='Pricing',
            Final_Exposure__c =10,
            Customer_Grade__c ='FTU',
            Original_Vehicle_Usage__c='Agri',
            Net_Land_Holding_in_Acre__c=3.0,
            RecordTypeId=rd.Id,
            Emi_Frequency__c = 'HALF YEARLY',
            EMI_Date__c = '10',
            First_EMI_Date__c = Date.newInstance(2022, 06, 01)
        ),true);
        
        Collateral__c coll= new Collateral__c(Loan__c=loanAppl.Id,Assessment_Method__c='Absolute',Vehicle_Category__c='A',Net_of_Discount_Price__c = 10.0);
        coll.RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('New').getRecordTypeId();     
        insert coll;
        
        Scheme_Master__c objScheme = new Scheme_Master__c(Scheme_Name__c = 'Normal');
        insert objScheme;
        
        Depreciated_Grid__c dep= new Depreciated_Grid__c(Scheme__c=objScheme.Id);
        dep.RecordTypeId = Schema.SObjectType.Depreciated_Grid__c.getRecordTypeInfosByDeveloperName().get('LTV').getRecordTypeId();     
        insert dep;
        
        Loan_Application__c obj = new Loan_Application__c();
        obj.Id = loanAppl.Id;
        obj.Net_Land_Holding_in_Acre__c = 4.0;
        update obj;
        Test.stopTest();
    }
    
    @isTest 
    static void testevaluateApprovedLTV6() {
        Test.startTest();
            RecordType rd=[select id from RecordType where name='Construction Equipment' and sobjectType='Loan_Application__c'];
            Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-123489',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10402',
            RC_Limit_On_Hold__c=true,
            Stage__c='Pricing',
            Final_Exposure__c =10,
            Customer_Grade__c ='FTU',
            Original_Vehicle_Usage__c='Agri',
            Net_Land_Holding_in_Acre__c=3.0,
            RecordTypeId=rd.Id,
            Emi_Frequency__c = 'HALF YEARLY',
            EMI_Date__c = '10',
            First_EMI_Date__c = Date.newInstance(2022, 06, 01)
        ),true);
        
        Collateral__c coll= new Collateral__c(Loan__c=loanAppl.Id,Assessment_Method__c='Absolute',Vehicle_Category__c='A',Net_of_Discount_Price__c = 10.0);
        coll.RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('Used_Cash_on_Wheels').getRecordTypeId();     
        insert coll;
        
        Scheme_Master__c objScheme = new Scheme_Master__c(Scheme_Name__c = 'Normal');
        insert objScheme;
        
        Depreciated_Grid__c dep= new Depreciated_Grid__c(Scheme__c=objScheme.Id);
        dep.RecordTypeId = Schema.SObjectType.Depreciated_Grid__c.getRecordTypeInfosByDeveloperName().get('LTV').getRecordTypeId();     
        insert dep;
        
        Loan_Application__c obj = new Loan_Application__c();
        obj.Id = loanAppl.Id;
        obj.Net_Land_Holding_in_Acre__c = 4.0;
        update obj;
        Test.stopTest();
    }
    


    @isTest 
    static void testLoanTriggerInsert4() {
        Loan_Application__c loan = [Select id from Loan_Application__c where stage__c = 'Lead'];
        loan.stage__c = 'QDE';
        Test.startTest();
        update loan;
        Test.stopTest();
        
    }
    
    @isTest 
    static void skipOpsMakerTest() {
        Loan_Application__c loan = [Select id from Loan_Application__c where stage__c = 'PSD' and Credit_Approval_Date__c!=null];
        loan.stage__c = 'Pricing';
        Test.startTest();
        update loan;
        Test.stopTest();
        
    }

    @isTest 
    static void testarchivePricingApprovalsRework() {
        Test.startTest();
                 RecordType rd=[select id from RecordType where name='Four Wheeler' and  sobjectType='Loan_Application__c'];
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-123488',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true,
            Stage__c='Pricing',
            Final_Exposure__c =10,
            RecordTypeId=rd.Id,
            Emi_Frequency__c = 'HALF YEARLY',
            EMI_Date__c = '10',
            First_EMI_Date__c = Date.newInstance(2022, 06, 01)
        ),true);
        
        Loan_Application__c obj = new Loan_Application__c();
        obj.Id = loanAppl.Id;
        obj.OPS_PDD_Action__c = 'Rework';
        obj.Ops_FTR_FTNR__c = 'FTNR';
        obj.Stage__c='Credit';
        obj.Is_Rework__c = true;
        obj.No_Pricing_Deviation__c = false;
        update obj;
        
        Test.stopTest();
    }

    @isTest 
    static void testarchivePricingApprovalsReLookup() {
        Test.startTest();
                 RecordType rd=[select id from RecordType where name='Four Wheeler' and  sobjectType='Loan_Application__c'];
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-123488',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true,
            Stage__c='Pricing',
            Final_Exposure__c =10,
            RecordTypeId=rd.Id,
            Emi_Frequency__c = 'HALF YEARLY',
            EMI_Date__c = '10',
            First_EMI_Date__c = Date.newInstance(2022, 06, 01)
        ),true);
        
        Loan_Application__c obj = new Loan_Application__c();
        obj.Id = loanAppl.Id;
        obj.OPS_PDD_Action__c = 'Rework';
        obj.Ops_FTR_FTNR__c = 'FTNR';
        obj.Stage__c='Credit';
        obj.Is_Being_Relooked__c = true;
        obj.No_Pricing_Deviation__c = false;
        update obj;
        
        Test.stopTest();
    }

    @isTest 
    static void testarchivePricingApprovalsCustomerGrade() {
        Test.startTest();
            List<Applicant_Financials_Details__c> lstApp = [Select Id, Applicant__c, Applicant__r.Loan__c, Monthly_Income__c, Customer_Grade__c from Applicant_Financials_Details__c LIMIT 1];
            lstApp[0].Monthly_Income__c = 90000;
            lstApp[0].Customer_Grade__c = 'Premium';
            update lstApp;
        Test.stopTest();
    }
    
    @isTest 
    static void testhandleExposureChange() {
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-123488',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true,
            Stage__c='Pricing',
            Final_Exposure__c =10,
            RecordTypeId=Utility.getRecordTypeId( SObjectType.Loan_Application__c.getSObjectType(), GlobalConstants.TWOWHEELER ),
            Emi_Frequency__c = 'HALF YEARLY',
            EMI_Date__c = '10',
            First_EMI_Date__c = Date.newInstance(2022, 06, 01),
            Discrepancy_Count__c = 10,
            Total_Loan_Amount__c = 100
        ),true);
        Test.startTest();
        loanAppl.Total_Loan_Amount__c = 200;
        update loanAppl;
        Test.stopTest();
       
    }
    
    @isTest 
    static void testevaluateApportionedLoanonCollateral() {
        Test.startTest();
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-123488',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10501',
            RC_Limit_On_Hold__c=true,
            Stage__c='Pricing',
            Final_Exposure__c =10,
            RecordTypeId=Utility.getRecordTypeId( SObjectType.Loan_Application__c.getSObjectType(), 'Tractor' ),
            Emi_Frequency__c = 'HALF YEARLY',
            EMI_Date__c = '10',
            First_EMI_Date__c = Date.newInstance(2022, 06, 01),
            Discrepancy_Count__c = 10,
            Total_Loan_Amount__c = 100
        ),true);
        
        Collateral__c coll= new Collateral__c(Loan__c=loanAppl.Id,Assessment_Method__c='Absolute',Vehicle_Category__c='A',Net_of_Discount_Price__c = 10.0);
        coll.RecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByDeveloperName().get('New').getRecordTypeId();     
        insert coll;
        
        
        loanAppl.Total_Loan_Amount__c = 200;
        update loanAppl;
        Test.stopTest();
       
    }
    
    @isTest 
    static void testRecalculateCharges() {
        
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-123488',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            RC_Limit_On_Hold__c=true,
            Stage__c='Pricing',
            Final_Exposure__c =10,
            RecordTypeId=Utility.getRecordTypeId( SObjectType.Loan_Application__c.getSObjectType(), GlobalConstants.TWOWHEELER ),
            Emi_Frequency__c = 'HALF YEARLY',
            EMI_Date__c = '10',
            First_EMI_Date__c = Date.newInstance(2022, 06, 01),
            Discrepancy_Count__c = 10,
            Total_Loan_Amount__c = 100
        ),true);
        Charge__c chg = (Charge__c)TestFactory.createSObject(new Charge__c(
            Loan_Application__c = loanAppl.Id,
            Value_Type__c = 'Percent',
            Actual_rate__c = 1000,
            Tax_Percentage__c = 10,
            Charges_Name__c = 'RC Charges'),true
        );
        Test.startTest();
        Set<Id> loanId = new Set<Id>{loanAppl.Id};
        LoanTriggerService.recalculateCharges(loanId);
                                                            
        Test.stopTest();
       
    }
    


}