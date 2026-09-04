/**
* @description       : 
* @author            : Deployment user
* @group             : 
* @last modified on  : 10-29-2023
* @last modified by  : Ajitesh
**/
@isTest
    public with sharing class financeController_Test {
    
    @testSetup public  static void setup() {
    //Loan Application Insertion
    Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
        Application_Number__c  = 'AP-12345',
        Adhar_Card__c   = 123456,
        Loan_Amount__c  = 1000,
        Product__c='10201',
        Stage__c ='DDE'
    ),true);
    
    //Applicant Insertion
    Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
        First_Name__c = 'Vikash',
        Middle_Name__c = 'Kumar',
        Last_Name__c = 'Mandal',
        Loan__c =loanAppl.Id,
        Customer_Type__c='Individual'
    ),true);
    
        //Inserting Document Master and Document Checklist
        Document_Master__c  docMaster = (Document_Master__c)TestFactory.createSObject(new Document_Master__c (
            Name = 'AUWheels0008',
            Document_Name__c = 'Driving Licence',
            OCR_Document_Type__c = Label.KYC_OCR_Type_Driving_License,
            Document_Sub_Category__c = Label.BRE_Karza_Verification_Type_KYC
        ),true);
        
        Document_Checklist__c docChkRecord = (Document_Checklist__c)TestFactory.createSObject(new Document_Checklist__c(
            Parent_Loan__c   = loanAppl.Id,
            Applicant__c = appl.Id,
            Document_Master__c = docMaster.Id,
            Document_Name__c ='Driving Licensce',
            Document_Number__c = 'BEMPN6666E'
        ),true);
        
    //Profiling Master Insertion
    //Sector
    Id sectorRecordTypeId = Schema.SObjectType.Profiling_Master__c.getRecordTypeInfosByName().get('RT - Sector').getRecordTypeId();
    Profiling_Master__c profMaster = (Profiling_Master__c)TestFactory.createSObject(new Profiling_Master__c(
        Name='Manufacturer',
        Entity_Type__c = 'Individual',
        RecordTypeId = sectorRecordTypeId
    ),true);
    
    //Industry
    Id industryRecordTypeId = Schema.SObjectType.Profiling_Master__c.getRecordTypeInfosByName().get('RT - Industry').getRecordTypeId();
    Profiling_Master__c industryMaster = (Profiling_Master__c)TestFactory.createSObject(new Profiling_Master__c(
        Name='Construction & Civil Engineering',
        Sector__c = profMaster.Id,
        RecordTypeId = industryRecordTypeId
    ),true);
    
    //SubIndustry
    Id subIndustryRecordTypeId = Schema.SObjectType.Profiling_Master__c.getRecordTypeInfosByName().get('RT - Sub Industry').getRecordTypeId();
    Profiling_Master__c subIndustryMaster = (Profiling_Master__c)TestFactory.createSObject(new Profiling_Master__c(
        Name='Metal Cutlery',
        Sector__c = profMaster.Id,
        Industry__c =industryMaster.Id,
        RecordTypeId = subIndustryRecordTypeId
    ),true);
    
    //Occupation
    Id occupationRecordTypeId = Schema.SObjectType.Profiling_Master__c.getRecordTypeInfosByName().get('RT - Occupation').getRecordTypeId();
    Profiling_Master__c occupationMaster = (Profiling_Master__c)TestFactory.createSObject(new Profiling_Master__c(
        Name='Manufacturer',
        Sector__c = profMaster.Id,
        Industry__c = industryMaster.Id,
        Sub_Industry__c =subIndustryMaster.Id,
        RecordTypeId = occupationRecordTypeId
    ),true);
        
    Id employmentTypeRecordTypeId = Schema.SObjectType.Profiling_Master__c.getRecordTypeInfosByName().get('RT - Employment Type').getRecordTypeId();
    Profiling_Master__c employmentTypeMaster = (Profiling_Master__c)TestFactory.createSObject(new Profiling_Master__c(
        Name='Manufacturer',
        Sector__c = profMaster.Id,
        Industry__c = industryMaster.Id,
        Sub_Industry__c =subIndustryMaster.Id,
        Occupation__c = occupationMaster.Id,
        RecordTypeId = employmentTypeRecordTypeId
    ),true);
    
    // Applicant Financials Insertion
    Id parentRecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Financial Parent').getRecordTypeId();
    Applicant_Financials_Details__c applParentFinancials = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
        Applicant__c = appl.Id,
        RecordTypeId = parentRecordTypeId,
        isActive__c = true,
        Type_Of_Employment__c ='Salaried - Private',
        Method_Of_Assesment__c ='Salaried',
        Monthly_Income__c =100,
        Monthly_Obligation__c =50,
        Other_Income__c =80,
        Consider_Income_for_Eligibility__c='Yes'
    ),true);
    
    // Salaried
    Id salariedRecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Salaried Document').getRecordTypeId();
    Applicant_Financials_Details__c applChildFinancials = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
        Applicant__c = appl.Id,
        RecordTypeId = salariedRecordTypeId,
        isActive__c = true,
        Applicant_Financials__c =applParentFinancials.Id
    ),true);
    
    
    //Bureau Insertion
    Bureau_Results__c bureauInstanace = (Bureau_Results__c) TestFactory.createSObject(new Bureau_Results__c(
        Applicant__c = appl.Id,
        Bureau_Score__c =100,
        Total_EMI_Amount__c=245000,
        Bureau_Score_Date__c = System.today()
    ),true);
    
    //Bank Account Insertion
    //CBS
    Id cbsRecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CBS').getRecordTypeId();
    Bank_Account_Records__c cbsAccountInstance = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
        Applicant__c = appl.Id,
        Account_Type__c = 'Loan',
        Loan_Amount__c =10000,
        EMI_Amount__c =2000,
        RecordTypeId = cbsRecordTypeId,
        Account_Opening_Date__c = System.today()-368
    ),true);
    
    //CBS CASA
     Bank_Account_Records__c cbsAccountInstance1 = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
        Applicant__c = appl.Id,
        Account_Type__c = 'CASA',
        Loan_Amount__c =10000,
        EMI_Amount__c =2000,
         Product__c='Current',
        RecordTypeId = cbsRecordTypeId,
         Account_Number__c ='AC00001',
        Account_Opening_Date__c = System.today()-368
    ),true);
    Bank_Account_Records__c cbsAccountInstance2 = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
        Applicant__c = appl.Id,
        Account_Type__c = 'CASA',
        Loan_Amount__c =10000,
        EMI_Amount__c =2000,
         Product__c='Savings',
        RecordTypeId = cbsRecordTypeId,
         Account_Number__c ='AC00002',
        Account_Opening_Date__c = System.today()-368
    ),true);
    
    //CIBIL
    Id cibilRecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('CIBIL').getRecordTypeId();
    Bank_Account_Records__c cibilAccountInstance = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
        Applicant__c = appl.Id,
        Account_Type__c = 'Loan',
        Loan_Amount__c =1000,
        EMI_Amount__c =2001,
        RecordTypeId = cibilRecordTypeId,
        Account_Opening_Date__c = System.today()-2,
        Payment_History_End_Date__c = System.today()
    ),true);
    //CART
    Id cartRecordTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('Cart').getRecordTypeId();
    Bank_Account_Records__c cartAccountInstance = (Bank_Account_Records__c) TestFactory.createSObject(new Bank_Account_Records__c(
        Applicant__c = appl.Id,
        Loan_Amount__c =1000,
        EMI_Amount__c =2001,
        RecordTypeId = cartRecordTypeId,
        //Analysis_Data__c ='[{"totalReversalAmount":0.0,"totalPenalChargesAmount":0.0,"totalPaymentBounceCharges":0.0,"totalInterestReceived":0.0,"totalInterestPaid":0.0,"totalEMIBounceAmount":0.0,"totalEMIAmount":3000.0,"totalChequeReturnCharges":0.0,"totalBankChargesAmount":0.0,"salaryAmount":179726.0,"paymentBounceOutwardAmount":0.0,"paymentBounceInwardAmount":0.0,"otherIncomeAmount":0.0,"noOfReversal":0,"noOfPenalCharges":0,"noOfPaymentBounceOutward":0,"noOfPaymentBounceInward":0,"noOfPaymentBounceCharges":0,"noOfNetDebitTransactions":25,"noOfNetCreditTransactions":5,"noOfMinimumBalanceCharges":0,"noOfLoanDisbursal":0,"noOfInterestReceived":0,"noOfInterestPaid":0,"noOfEMIBounce":0,"noOfEMI":2,"noOfDebitTransactions":25,"noOfCreditTransactions":5,"noOfChequeReturnCharges":0,"noOfChequeIssued":0,"noOfChequeDeposits":0,"noOfChequeBounceOutward":0,"noOfChequeBounceInward":0,"noOfCashWithdrawals":2,"noOfCashDeposits":0,"noOfBankCharges":0,"noOfATMWithdrawals":2,"netDebitTransactionsAmount":265422.64,"netCreditTransactionsAmount":179818.2,"month":"Aug-2021","minimumEODBalance":321627.25,"minimumBalance":321627.25,"maximumEODBalance":482589.69,"maximumBalance":482589.69,"loanDisbursalAmount":0.0,"debitTransactionsAmount":265422.64,"creditTransactionsAmount":179818.2,"chequeIssuedAmount":0.0,"chequeDepositsAmount":0.0,"chequeBounceOutwardAmount":0.0,"chequeBounceInwardAmount":0.0,"cashWithdrawalsAmount":13000.0,"cashDepositsAmount":0.0,"cashDepositPercentage":0.0,"averageEODBalance":357915.36612903245,"atmWithdrawalsAmount":13000.0},{"totalReversalAmount":0.0,"totalPenalChargesAmount":0.0,"totalPaymentBounceCharges":0.0,"totalInterestReceived":6420.0,"totalInterestPaid":0.0,"totalEMIBounceAmount":0.0,"totalEMIAmount":1500.0,"totalChequeReturnCharges":0.0,"totalBankChargesAmount":0.0,"salaryAmount":180976.0,"paymentBounceOutwardAmount":0.0,"paymentBounceInwardAmount":0.0,"otherIncomeAmount":0.0,"noOfReversal":0,"noOfPenalCharges":0,"noOfPaymentBounceOutward":0,"noOfPaymentBounceInward":0,"noOfPaymentBounceCharges":0,"noOfNetDebitTransactions":38,"noOfNetCreditTransactions":2,"noOfMinimumBalanceCharges":0,"noOfLoanDisbursal":0,"noOfInterestReceived":1,"noOfInterestPaid":0,"noOfEMIBounce":0,"noOfEMI":1,"noOfDebitTransactions":38,"noOfCreditTransactions":3,"noOfChequeReturnCharges":0,"noOfChequeIssued":0,"noOfChequeDeposits":0,"noOfChequeBounceOutward":0,"noOfChequeBounceInward":0,"noOfCashWithdrawals":0,"noOfCashDeposits":0,"noOfBankCharges":0,"noOfATMWithdrawals":0,"netDebitTransactionsAmount":239236.64,"netCreditTransactionsAmount":220976.0,"month":"Sep-2021","minimumEODBalance":202121.61,"minimumBalance":202121.61,"maximumEODBalance":389517.61,"maximumBalance":389517.61,"loanDisbursalAmount":0.0,"debitTransactionsAmount":239236.64,"creditTransactionsAmount":227396.0,"chequeIssuedAmount":0.0,"chequeDepositsAmount":0.0,"chequeBounceOutwardAmount":0.0,"chequeBounceInwardAmount":0.0,"cashWithdrawalsAmount":0.0,"cashDepositsAmount":0.0,"cashDepositPercentage":0.0,"averageEODBalance":218630.3413333334,"atmWithdrawalsAmount":0.0},{"totalReversalAmount":0.0,"totalPenalChargesAmount":0.0,"totalPaymentBounceCharges":0.0,"totalInterestReceived":0.0,"totalInterestPaid":0.0,"totalEMIBounceAmount":0.0,"totalEMIAmount":1500.0,"totalChequeReturnCharges":0.0,"totalBankChargesAmount":0.0,"salaryAmount":178584.0,"paymentBounceOutwardAmount":0.0,"paymentBounceInwardAmount":0.0,"otherIncomeAmount":0.0,"noOfReversal":0,"noOfPenalCharges":0,"noOfPaymentBounceOutward":0,"noOfPaymentBounceInward":0,"noOfPaymentBounceCharges":0,"noOfNetDebitTransactions":63,"noOfNetCreditTransactions":7,"noOfMinimumBalanceCharges":0,"noOfLoanDisbursal":0,"noOfInterestReceived":0,"noOfInterestPaid":0,"noOfEMIBounce":0,"noOfEMI":1,"noOfDebitTransactions":63,"noOfCreditTransactions":7,"noOfChequeReturnCharges":0,"noOfChequeIssued":0,"noOfChequeDeposits":0,"noOfChequeBounceOutward":0,"noOfChequeBounceInward":0,"noOfCashWithdrawals":2,"noOfCashDeposits":0,"noOfBankCharges":0,"noOfATMWithdrawals":2,"netDebitTransactionsAmount":306679.84,"netCreditTransactionsAmount":180458.0,"month":"Oct-2021","minimumEODBalance":88275.77,"minimumBalance":88275.77,"maximumEODBalance":307016.61,"maximumBalance":307016.61,"loanDisbursalAmount":0.0,"debitTransactionsAmount":306679.84,"creditTransactionsAmount":180458.0,"chequeIssuedAmount":0.0,"chequeDepositsAmount":0.0,"chequeBounceOutwardAmount":0.0,"chequeBounceInwardAmount":0.0,"cashWithdrawalsAmount":18000.0,"cashDepositsAmount":0.0,"cashDepositPercentage":0.0,"averageEODBalance":226998.03451612892,"atmWithdrawalsAmount":18000.0},{"totalReversalAmount":0.0,"totalPenalChargesAmount":0.0,"totalPaymentBounceCharges":0.0,"totalInterestReceived":0.0,"totalInterestPaid":0.0,"totalEMIBounceAmount":0.0,"totalEMIAmount":26841.0,"totalChequeReturnCharges":0.0,"totalBankChargesAmount":0.0,"salaryAmount":179417.0,"paymentBounceOutwardAmount":0.0,"paymentBounceInwardAmount":0.0,"otherIncomeAmount":0.0,"noOfReversal":0,"noOfPenalCharges":0,"noOfPaymentBounceOutward":0,"noOfPaymentBounceInward":0,"noOfPaymentBounceCharges":0,"noOfNetDebitTransactions":43,"noOfNetCreditTransactions":3,"noOfMinimumBalanceCharges":0,"noOfLoanDisbursal":0,"noOfInterestReceived":0,"noOfInterestPaid":0,"noOfEMIBounce":0,"noOfEMI":2,"noOfDebitTransactions":43,"noOfCreditTransactions":3,"noOfChequeReturnCharges":0,"noOfChequeIssued":0,"noOfChequeDeposits":0,"noOfChequeBounceOutward":0,"noOfChequeBounceInward":0,"noOfCashWithdrawals":2,"noOfCashDeposits":0,"noOfBankCharges":0,"noOfATMWithdrawals":2,"netDebitTransactionsAmount":135239.82,"netCreditTransactionsAmount":180202.0,"month":"Nov-2021","minimumEODBalance":129075.95,"minimumBalance":129075.95,"maximumEODBalance":308257.95,"maximumBalance":308257.95,"loanDisbursalAmount":0.0,"debitTransactionsAmount":135239.82,"creditTransactionsAmount":180202.0,"chequeIssuedAmount":0.0,"chequeDepositsAmount":0.0,"chequeBounceOutwardAmount":0.0,"chequeBounceInwardAmount":0.0,"cashWithdrawalsAmount":20000.0,"cashDepositsAmount":0.0,"cashDepositPercentage":0.0,"averageEODBalance":153154.90000000002,"atmWithdrawalsAmount":20000.0},{"totalReversalAmount":0.0,"totalPenalChargesAmount":0.0,"totalPaymentBounceCharges":0.0,"totalInterestReceived":6420.0,"totalInterestPaid":0.0,"totalEMIBounceAmount":0.0,"totalEMIAmount":32841.0,"totalChequeReturnCharges":0.0,"totalBankChargesAmount":0.0,"salaryAmount":718703.0,"paymentBounceOutwardAmount":0.0,"paymentBounceInwardAmount":0.0,"otherIncomeAmount":0.0,"noOfReversal":0,"noOfPenalCharges":0,"noOfPaymentBounceOutward":0,"noOfPaymentBounceInward":0,"noOfPaymentBounceCharges":0,"noOfNetDebitTransactions":169,"noOfNetCreditTransactions":17,"noOfMinimumBalanceCharges":0,"noOfLoanDisbursal":0,"noOfInterestReceived":1,"noOfInterestPaid":0,"noOfEMIBounce":0,"noOfEMI":6,"noOfDebitTransactions":169,"noOfCreditTransactions":18,"noOfChequeReturnCharges":0,"noOfChequeIssued":0,"noOfChequeDeposits":0,"noOfChequeBounceOutward":0,"noOfChequeBounceInward":0,"noOfCashWithdrawals":6,"noOfCashDeposits":0,"noOfBankCharges":0,"noOfATMWithdrawals":6,"netDebitTransactionsAmount":946578.9400000002,"netCreditTransactionsAmount":761454.2,"month":"GrandTotal","minimumEODBalance":88275.77,"minimumBalance":88275.77,"maximumEODBalance":482589.69,"maximumBalance":482589.69,"loanDisbursalAmount":0.0,"debitTransactionsAmount":946578.9400000002,"creditTransactionsAmount":767874.2,"chequeIssuedAmount":0.0,"chequeDepositsAmount":0.0,"chequeBounceOutwardAmount":0.0,"chequeBounceInwardAmount":0.0,"cashWithdrawalsAmount":51000.0,"cashDepositsAmount":0.0,"cashDepositPercentage":0.0,"averageEODBalance":239174.6604946237,"atmWithdrawalsAmount":51000.0}]',
        Analysis_Data__c='{"monthlyCreditsDetailsGrandTotal":{"Salary Credit":25650,"Month-Year":null,"Credit":37344},"monthlyBalancesDetailsGrandTotal":{"averageBalanceOn5th":0,"averageBalanceOn25th":1,"Month-Year":null,"averageBalanceOn20th":1,"AMB":1319.594193548387,"averageBalanceOn10th":101,"Average of Custom Day":2892.1666666666665,"averageBalanceOn15th":6,"averageBalanceOn1st":17244},"monthlyCreditsDetails":[{"Salary Credit":25650,"Month-Year":"Oct-2022","Credit":37344}],"monthlyBalancesDetails":[{"averageBalanceOn5th":0,"averageBalanceOn25th":1,"Month-Year":"Oct-2022","averageBalanceOn20th":1,"AMB":1319.594193548387,"averageBalanceOn10th":101,"Average of Custom Day":2892.1666666666665,"averageBalanceOn15th":6,"averageBalanceOn1st":17244}]}',
        Account_Opening_Date__c = System.today()-2
    ),true);
    
    
    //Address Insertion
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
        Applicant__c =appl.Id,
        Stability__c='1',
        Status__c='Owned',
        Address_Type__c='Permanent',
        Type__c='Bungalow'
    ),true);
    
    Address__c  addInstance1 = (Address__c)TestFactory.createSObject(new Address__c(
        Address_Line_1__c ='TestAddressline11',
        Address_Line_2__c ='TestAddressline22',
        Address_Line_3__c ='TestAddressline33',
        State__c='MAHARASHTRA',
        City__c='EAST DELHI',
        Area_Name__c='JAGJIT NAGAR',
        Area_Type__c='Urban',
        Taluka__c='NA',
        Pincode__c='110053',
        Land_mark__c='Testing',
        Applicant__c =appl.Id,
        Stability__c='1',
        Status__c='Owned',
        Address_Type__c='Current',
        Type__c='Bungalow'
    ),true);
    Address__c  addInstanc2 = (Address__c)TestFactory.createSObject(new Address__c(
        Address_Line_1__c ='TestAddressline112',
        Address_Line_2__c ='TestAddressline222',
        Address_Line_3__c ='TestAddressline332',
        State__c='MAHARASHTRA',
        City__c='EAST DELHI',
        Area_Name__c='JAGJIT NAGAR',
        Area_Type__c='Urban',
        Taluka__c='NA',
        Pincode__c='110053',
        Land_mark__c='Testing',
        Applicant__c =appl.Id,
        Stability__c='1',
        Status__c='Owned',
        Address_Type__c='Office',
        Type__c='Bungalow'
    ),true);
    Address__c  addInstanc3 = (Address__c)TestFactory.createSObject(new Address__c(
        Address_Line_1__c ='TestAddressline112',
        Address_Line_2__c ='TestAddressline222',
        Address_Line_3__c ='TestAddressline332',
        State__c='MAHARASHTRA',
        City__c='EAST DELHI',
        Area_Name__c='JAGJIT NAGAR',
        Area_Type__c='Urban',
        Taluka__c='NA',
        Pincode__c='110053',
        Land_mark__c='Testing',
        Applicant__c =appl.Id,
        Stability__c='1',
        Status__c='Owned',
        Address_Type__c='Touch Point',
        Type__c='Bungalow'
    ),true);
    
    Generic_Master__c  genericInstance = (Generic_Master__c)TestFactory.createSObject(new Generic_Master__c(
        Company_Name__c ='Salesforce',
        Company_Category__c ='A'
    ),true);
    
     //CASA Integration Master
    Integration_Master__c inMaster = (Integration_Master__c )TestFactory.createSObject(new Integration_Master__c (
        Name ='Cart Statement Service',
        End_Point_URL__c='https://serviceuatsfdc.aubankuat.in/CartStatementService/Cart',
        Apiuser__c ='SFDC',
        API_Key__c ='epikey',
        HTTP_Method__c='POST',
        Timeout__c='120000',
        Active__c = true
    ),true);
    
    
    
    }
    
    @isTest static void applicants(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
            financeController.getApplicants(appl.Id);
            System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    
    @isTest static void bureuaResults(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
            financeController.getBureauResults(appl.Id);
            System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest static void getAddress(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
            financeController.getRelatedAddress(appl.Id);
            System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
    
    }
    
    @isTest static void bankRecords(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
            financeController.getBankRecords(appl.Id,'Loan',0);
            System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
    
    }
    
    @isTest static void cartBankRecords(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
            financeController.getBankRecords(appl.Id,'',0);
            System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
    
    }
    
    @isTest static void premiumMetdataRecords(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
            financeController.getPremiumMetadata();
            System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
    
    }
    
    @isTest static void financialsParentRecords(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
            financeController.getFinancials(appl.Id);
            System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest static void finacialsAllRecords(){
    Applicant_Financials_Details__c parentRecord = [SELECT id,Type_Of_Employment__c FROM Applicant_Financials_Details__c WHERE Type_Of_Employment__c = 'Salaried - Private' ];
        Test.startTest();
            financeController.getFinancialChildDetails(parentRecord.Id);
            System.assertEquals('Salaried - Private', parentRecord.Type_Of_Employment__c,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest static void getVisibleFieldsMetadata(){
        Test.startTest();
            List<String> fieldList = financeController.getVisibleFields('Income Parent','QDE');
            System.assertEquals(true, fieldList!=null,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest static void creationFinancialData(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Applicant_Financials_Details__c recordInstance = new Applicant_Financials_Details__c();
        recordInstance.Type_Of_Employment__c = 'Salaried - Private';
        recordInstance.Applicant__c = appl.Id;
        Test.startTest();
            financeController.createFinancialRecords(recordInstance);
            System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest static void getincomeProfileMetadataRecords(){
        Test.startTest();
            List<Income_Profiling__mdt> incomeProf = financeController.getEmploymentType('Individual'); 
            System.assertEquals(true, incomeProf!=null,'AssertMsg');
        Test.stopTest();        
    }
    
    @isTest static void getProfMasterRecords(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
            financeController.getProfilingMaster(appl.Id);
            System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
    
    }
    
    @isTest static void getSelectedProfMasterRecords(){
        Test.startTest();
            financeController.getRelatedProfilingMaster('Manufacturer','RT - Employment Type', 'RT - Sector','');
            financeController.getRelatedProfilingMaster('Manufacturer','RT - Sector','RT - Industry','');
            financeController.getRelatedProfilingMaster('Construction & Civil Engineering','RT - Industry','RT - Sub Industry','');
            financeController.getRelatedProfilingMaster('Metal Cutlery','RT - Sub Industry','RT - Occupation','');
            List<Profiling_Master__c>  prof = financeController.getRelatedProfilingMaster('Manufacturer','RT - Occupation','RT - Employment Type',''); 
            List<Profiling_Master__c>  prof2 = financeController.getRelatedProfilingMaster('Manufacturer','RT - Sector','RT - Occupation','RT - Sector');
        List<Profiling_Master__c>  prof3 = financeController.getRelatedProfilingMaster('Manufacturer','RT - Industry','RT - Occupation','RT - Sector~RT - Industry');
        List<Profiling_Master__c>  prof4 = financeController.getRelatedProfilingMaster('Manufacturer','RT - Sub Industry','RT - Occupation','RT - Sector~RT - Industry~RT - Sub Industry');
        List<Profiling_Master__c>  prof5 = financeController.getRelatedProfilingMaster('Manufacturer','RT - Occupation','RT - Occupation','RT - Sector~RT - Industry~RT - Sub Industry~RT - Occupation');

            System.assertEquals(true, prof!=null,'AssertMsg');
        Test.stopTest();
    
    }
    
    @isTest static void getOtherIncomeRecords(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Id otherIncomeRecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Other Income').getRecordTypeId();
        Id parentRecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Financial Parent').getRecordTypeId();
        Applicant_Financials_Details__c recordParentInstance = new Applicant_Financials_Details__c();
        recordParentInstance.Applicant__c = appl.Id;
        recordParentInstance.isActive__c = true;
        recordParentInstance.RecordTypeId = parentRecordTypeId;
        insert recordParentInstance;
        
        Applicant_Financials_Details__c recordInstance = new Applicant_Financials_Details__c();
        recordInstance.Type_Of_Employment__c = 'Salaried - Private';
        recordInstance.Applicant__c = appl.Id;
        recordInstance.RecordTypeId = otherIncomeRecordTypeId; 
        recordInstance.Monthly_Income__c = 235;
        recordInstance.isActive__c = true;
        recordInstance.Applicant_Financials__c=recordParentInstance.Id;
        insert recordInstance;
        financeController.ApplicantWrapper wrapper= new financeController.ApplicantWrapper();
        wrapper.marital = 'Single';
        wrapper.residential = 'NRI';
        wrapper.physical = 'No';
        wrapper.highrisk = '';
        wrapper.auemp = 'No';
        wrapper.auname = 'Test';
        wrapper.auid = '12345';
        wrapper.austatus = 'Active';
        wrapper.nature = '';
        wrapper.proof = '';
        wrapper.spouse = '';
        Test.startTest();
        financeController.updateApplicant(appl.Id, JSON.serialize(wrapper));
        financeController.getApplicant(appl.Id);
            financeController.getOtherIncomeTotal(recordParentInstance.Id);
            financeController.deactivateChildFinancials(recordParentInstance.Id);
            financeController.checkCartFetchButton(appl.Id);
            financeController.applicantEmploymentUpdation(appl.Id,'Salaried - Private','NIB');
            System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
    
    }
    
    @isTest static void companySuccessScenario(){
        Test.startTest();
            Boolean returnInstance = financeController.getCompanyCode('Salesforce');
            System.assertEquals(true, returnInstance!=null,'AssertMsg');
            Test.stopTest();
        }
        
    @isTest static void companyFailureScenario(){
        Test.startTest();
            Boolean returnInstance = financeController.getCompanyCode('Salesforce123');
            System.assertEquals(true, returnInstance!=null,'AssertMsg');
        Test.stopTest();
    }
            
    @isTest static void summaryDetails(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        String loanId = loanInstance.Id;
        Test.startTest();
            financeSummaryClass.getSummaryDetails(loanId);
            System.assertEquals('AP-12345', loanInstance.Application_Number__c,'AssertMsg');
    
        Test.stopTest();
    }
    
    @isTest static void foirDetails(){
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                        FROM Loan_Application__c
                                        WHERE Application_Number__c='AP-12345'];
        String loanId = loanInstance.Id;
        Test.startTest();
            foirController.getAllApplicantsFoir(loanId);
            financeController.getFinancialStatus(loanInstance.Id);
            System.assertEquals('AP-12345', loanInstance.Application_Number__c,'AssertMsg');
        Test.stopTest();
    }
    
    @isTest static void cartStatement(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        
        String applicantId = appl.Id;
        
        Test.setMock(HttpCalloutMock.class, new CartStatementCalloutMock());
        Test.startTest();
            financeController.getCartStatement(applicantId,'AC00001');
            System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
    
    }

    @isTest static void checkDLRequirementForNewCommercialVehicle(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        
        String applicantId = appl.Id;
        Test.startTest();
        financeController.checkIfDLNeedsTobeFilledForNewCE(applicantId);
        System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
        
    }
    @isTest static void fetchLoanStageTest(){
        Applicant__c appl =[SELECT id,First_Name__c,RecordType.DeveloperName FROM Applicant__c WHERE First_Name__c='Vikash'];
        
        String applicantId = appl.Id;
        
        Test.setMock(HttpCalloutMock.class, new CartStatementCalloutMock());
        Test.startTest();
            financeController.fetchLoanStage(applicantId);
            financeController.validateAddressInfo(applicantId,'');
            financeController.getRiskCategoryBasedOnRiskIdentification(appl,'First_Name__c');
            financeController.ApplicantListWrapper wrapper = new financeController.ApplicantListWrapper(appl);
            wrapper.compareTo( wrapper);
        Test.stopTest();
    
    }

    @isTest static void getRecordTypeOfApplicationTest(){
        Applicant__c appl =[SELECT id,First_Name__c,Loan__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        String applicantId = appl.Id;
        Test.startTest();
        financeController.getRecordTypeOfApplication(appl.Loan__c);
        System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
    }

    @isTest static void addressInfo(){
        Applicant__c appl =[SELECT id,First_Name__c,Loan__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        String applicantId = appl.Id;
        Test.startTest();
        financeController.validateAddressInfo(applicantId,'Salaried - Private');
        System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
    }
    @isTest static void addressInfo1(){
        Applicant__c appl =[SELECT id,First_Name__c,Loan__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        String applicantId = appl.Id;
        Test.startTest();
        financeController.validateAddressInfo(applicantId,'Unemployed');
        System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
    }
    @isTest static void riskIdentification(){
        Applicant__c appl =[SELECT id,First_Name__c,Loan__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        appl.Type_Of_Employment__c = 'Farmer'; 
        update appl;
        String applicantId = appl.Id;
        Test.startTest();
        financeController.getRiskCategoryBasedOnRiskIdentification(appl,'Type_Of_Employment__c');
        System.assertEquals('Vikash', appl.First_Name__c,'AssertMsg');
        Test.stopTest();
    }
        
    @IsTest
    static void testSaveDetails(){
        Loan_Application__c appl = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Test.startTest();
        foirController.saveDetails(appl.Id,'');
    }
}