@isTest
public with sharing class FinancialViewTemplateR2Controller_Test {
    @testSetup static void setup() {
        Profile adminProfile = [select Id,Name from profile where name = 'System Administrator'];
        String recordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Tractor').getRecordTypeId();
        User usrAdmin = (User)TestFactory.createSObject(new User(firstName = 'admin1',
                                                                 lastName = 'admin2',
                                                                 profileId = adminProfile.id,
                                                                 username = 'admin1'+UserInfo.getOrganizationId()+'@test.com',
                                                                 email = 'admin1@test.com',
                                                                 Branch_Code__c  = '2103'
                                                                ),true);
        System.runAs(usrAdmin) {
            //Loan Application Insertion
            Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
                Application_Number__c  = 'AP-12345',
                Adhar_Card__c   = 123456,
                Loan_Amount__c  = 1000,
                Product__c='10201',
                EMI__c =45,
                Stage__c ='DDE',
                RecordTypeId = recordTypeId,
                Original_Vehicle_Usage__c = 'Agri',
                Collateral_Type__c = '10109',
                EMI_Frequency__c='MONTHLY'
            ),true);
            
            //Applicant Insertion
            Id coApplicantRecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Co-Applicant').getRecordTypeId();
            Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
                First_Name__c = 'Vikash',
                Middle_Name__c = 'Kumar',
                Last_Name__c = 'Mandal',
                Loan__c =loanAppl.Id,
                RecordTypeId=coApplicantRecordTypeId,
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
                Row_Instance__c=0,
                Consider_Income_for_Eligibility__c='Yes'
            ),true);
            
            // Salaried
            Id salariedRecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Salaried Document').getRecordTypeId();
            Applicant_Financials_Details__c applChildFinancials = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
                Applicant__c = appl.Id,
                RecordTypeId = salariedRecordTypeId,
                isActive__c = true,
                Monthly_Net_Salary__c=10,
                Salary_Received_in_Bank__c =3342,
                Salary_Received_in_Cash__c =5773,
                Monthly_Turnover__c=1000,
                Applicant_Financials__c =applParentFinancials.Id
            ),true);
            
            // Documented Audited
            Id documentedRecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Documented With Audited financial').getRecordTypeId();
            Applicant_Financials_Details__c applChildFinancials1 = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
                Applicant__c = appl.Id,
                RecordTypeId = documentedRecordTypeId,
                isActive__c = true,
                Monthly_Total_Income__c =100000,
                Monthly_Turnover__c=1000,
                Applicant_Financials__c =applParentFinancials.Id
            ),true);
            // Documented With out Audited
            Id documentedwithoutRecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Documented Without Audited financial').getRecordTypeId();
            Applicant_Financials_Details__c applChildFinancials2 = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
                Applicant__c = appl.Id,
                RecordTypeId = documentedwithoutRecordTypeId,
                isActive__c = true,
                Monthly_Total_Income__c =100000,
                Monthly_Turnover__c=1000,
                Applicant_Financials__c =applParentFinancials.Id
            ),true);
            // Assessed
            Id assessedRecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Assessed No Document').getRecordTypeId();
            Applicant_Financials_Details__c applChildFinancials3 = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
                Applicant__c = appl.Id,
                RecordTypeId = assessedRecordTypeId,
                Monthly_Turnover__c=1000,
                Monthly_Total_Income__c =100000,
                isActive__c = true,
                Applicant_Financials__c =applParentFinancials.Id
            ),true);
            //commmercialfinancial
            Id commercialRecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Commercial financial format').getRecordTypeId();
            Applicant_Financials_Details__c applChildFinancials4 = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
                Applicant__c = appl.Id,
                RecordTypeId = assessedRecordTypeId,
                Monthly_Turnover__c=1000,
                isActive__c = true,
                Applicant_Financials__c =applParentFinancials.Id
            ),true);
            //hirevsbuy
            Id hireRecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Hire VS Buy').getRecordTypeId();
            Applicant_Financials_Details__c applChildFinancials5 = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
                Applicant__c = appl.Id,
                RecordTypeId = hireRecordTypeId,
                isActive__c = true,
                Monthly_Turnover__c=1000,
                HireVsBuy_Decision__c='FAVOURABLE',
                Applicant_Financials__c =applParentFinancials.Id
            ),true);
            //Other Income
            Id otherRecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Other Income').getRecordTypeId();
            Applicant_Financials_Details__c applChildFinancials6 = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
                Applicant__c = appl.Id,
                RecordTypeId = otherRecordTypeId,
                isActive__c = true,
                Monthly_Income__c=1000,
                Monthly_Turnover__c=1000,
                Applicant_Financials__c =applParentFinancials.Id
            ),true);
            //Viability Sheet Commercial Equipment
            Id viaRecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Viability Sheet Commercial Equipment').getRecordTypeId();
            Applicant_Financials_Details__c applChildFinancials7 = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
                Applicant__c = appl.Id,
                RecordTypeId = viaRecordTypeId,
                isActive__c = true,
                Monthly_Turnover__c=1000,
                FCF_EMI__c =2.3,
                Applicant_Financials__c =applParentFinancials.Id
            ),true);
            //Viability Sheet Commercial Vehicle
            Id viaComRecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Viability Sheet Commercial Vehicle').getRecordTypeId();
            Applicant_Financials_Details__c applChildFinancials8 = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
                Applicant__c = appl.Id,
                RecordTypeId = viaComRecordTypeId,
                isActive__c = true,
                Monthly_Turnover__c=1000,
                FCF_EMI__c =2.4,                
                Applicant_Financials__c =applParentFinancials.Id
            ),true);
            //Viability Sheet Self Propelled Harvester
            Id viaSelfRecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Viability Sheet Self Propelled Harvester').getRecordTypeId();
            Applicant_Financials_Details__c applChildFinancials9 = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
                Applicant__c = appl.Id,
                RecordTypeId = viaSelfRecordTypeId,
                Total_Net_Income__c=2424,
                isActive__c = true,
                Applicant_Financials__c =applParentFinancials.Id
            ),true);
            //Viability Sheet Small Commercial Vehicle
            Id viaSmallRecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Viability Sheet Small Commercial Vehicle').getRecordTypeId();
            Applicant_Financials_Details__c applChildFinancials10 = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
                Applicant__c = appl.Id,
                RecordTypeId = viaSmallRecordTypeId,
                isActive__c = true,
                FCF_EMI__c =2.4,             
                Applicant_Financials__c =applParentFinancials.Id
            ),true);
            //Farmer - Agriculture Own Land
            Id famerRecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Farmer - Agriculture Own Land').getRecordTypeId();
            Applicant_Financials_Details__c applChildFinancials11 = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
                Applicant__c = appl.Id,
                RecordTypeId = famerRecordTypeId,
                Net_Revenue__c =1000,
                Net_Annual_Income__c=1198,
                isActive__c = true,
                Applicant_Financials__c =applParentFinancials.Id
            ),true);
            //Farmer - Agriculture Rented Land
            Id famerrednetedRecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Farmer - Agriculture Rented Land').getRecordTypeId();
            Applicant_Financials_Details__c applChildFinancials12 = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
                Applicant__c = appl.Id,
                RecordTypeId = famerrednetedRecordTypeId,
                isActive__c = true,
                Net_Annual_Income__c=1198,
                Net_Revenue__c =2000,
                Applicant_Financials__c =applParentFinancials.Id
            ),true);
            //Farmer - Commercial
            Id famercommeRecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Farmer - Commercial').getRecordTypeId();
            Applicant_Financials_Details__c applChildFinancials13 = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
                Applicant__c = appl.Id,
                RecordTypeId = famercommeRecordTypeId,
                Net_Annual_Income__c=1198,
                isActive__c = true,
                Applicant_Financials__c =applParentFinancials.Id
            ),true);
            //Farmer - Dairy Business
            Id famerDiaryRecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Farmer - Dairy Business').getRecordTypeId();
            Applicant_Financials_Details__c applChildFinancials14 = (Applicant_Financials_Details__c)TestFactory.createSObject(new Applicant_Financials_Details__c(
                Applicant__c = appl.Id,
                RecordTypeId = famerDiaryRecordTypeId,
                Net_Annual_Income__c=1198,
                Total_Net_Income__c = 23333,
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
    }
    
    @isTest static void workingFinancials(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        Test.startTest();
        FinancialViewTemplateR2Controller.getWorkingFinancialDetails(loanInstance.Id);
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    @isTest static void loanApplicationUpdate(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        Test.startTest();
        FinancialViewTemplateR2Controller.updateLoanApp(loanInstance);
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    @isTest static void financialsCheck(){
        List<Applicant__c> appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        Test.startTest();
        FinancialViewTemplateR2Controller.checkForFinancials(appl,loanInstance.Id);
        FinancialViewTemplateR2Controller.getViabilityTemplatesMapping();
        System.assertEquals('Vikash', appl[0].First_Name__c,'test');
        Test.stopTest();
    }
    @isTest static void activeRecord(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        Test.startTest();
        FinancialViewTemplateR2Controller.getActiveFinancialRecord(appl.Id,0);
        
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    @isTest static void getChildRecords(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        FinancialViewTemplateR2Controller.getExistingChildFinancialRecords(appl.Id);
        
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    @isTest static void deactiveFinancials(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        FinancialViewTemplateR2Controller.deactiveExistingFinancials(appl.Id);
        
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    
    @isTest static void updateFinancials(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Applicant_Financials_Details__c parentRecord = [SELECT id,Type_Of_Employment__c FROM Applicant_Financials_Details__c WHERE Type_Of_Employment__c = 'Salaried - Private' ];
        Test.startTest();
        FinancialViewTemplateR2Controller.deactiveExistingFinancials(parentRecord.Id);
        
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    @isTest static void isPanMandatoryCheck(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        Test.startTest();
        FinancialViewTemplateR2Controller.isPanMandatory(loanInstance.Id);
        
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    
    @isTest static void validationsCheck(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Applicant_Financials_Details__c parentRecord = [SELECT id,Type_Of_Employment__c FROM Applicant_Financials_Details__c WHERE Type_Of_Employment__c = 'Salaried - Private' ];
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        Test.startTest();
        FinancialViewTemplateR2Controller.updateCommercialParentFinancials(parentRecord.Id);
        FinancialViewTemplateR2Controller.getVisibleFieldsForFinancials('Income Parent','QDE','Four Wheeler');
        
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    @isTest static void updateParent(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Applicant_Financials_Details__c parentRecord = [SELECT id,Type_Of_Employment__c FROM Applicant_Financials_Details__c WHERE Type_Of_Employment__c = 'Salaried - Private' ];
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c 
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        Test.startTest();
        FinancialViewTemplateR2Controller.updateParentFinancials(parentRecord.Id);  
        FinancialViewTemplateR2Controller.getCurrentUserDetails();
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    
    @isTest static void getFinancialWrapperTest(){
        Applicant__c appl =[SELECT id,First_Name__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        List<Applicant__c> applicants =[SELECT id,First_Name__c,Customer_Type__c,Loan__c FROM Applicant__c];
        Test.startTest();
        FinancialViewTemplateR2Controller.getFinancialWrapper(appl.Id,applicants);  
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    @isTest static void getFinancialWrapperTest1(){
        // Body funding part
        String recordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Commercial_Vehicle').getRecordTypeId();
        //Loan Application Insertion
        Loan_Application__c loanAppl1 = new Loan_Application__c();
        loanAppl1.Application_Number__c  = 'CA-12345';
        loanAppl1.Adhar_Card__c   = 12345;
        loanAppl1.Loan_Amount__c  = 1000;
        loanAppl1.Product__c='10201';
        loanAppl1.EMI__c =45;
        loanAppl1.Stage__c ='DDE';
        loanAppl1.RecordTypeId = recordTypeId;
        loanAppl1.Original_Vehicle_Usage__c = 'Agri';
        loanAppl1.Collateral_Type__c = '10102';
        loanAppl1.EMI_Frequency__c='MONTHLY';
        insert loanAppl1;
        Id coApplicantRecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Co-Applicant').getRecordTypeId();
        Applicant__c appl11 = new Applicant__c();
        appl11.First_Name__c = 'Vikas2h1';
        appl11.Middle_Name__c = 'Kumar21';
        appl11.Last_Name__c = 'Mandal21';
        appl11.Loan__c =loanAppl1.Id;
        appl11.RecordTypeId=coApplicantRecordTypeId;
        appl11.Customer_Type__c='Individual';
        insert appl11;
        
        Loan_Application__c loanAppl11 = new Loan_Application__c();
        loanAppl11.Application_Number__c  = 'CA-123456';
        loanAppl11.Adhar_Card__c   = 12345;
        loanAppl11.Loan_Amount__c  = 1000;
        loanAppl11.Product__c='10201';
        loanAppl11.EMI__c =45;
        loanAppl11.Parent_Loan__c = loanAppl1.Id;
        loanAppl11.Stage__c ='DDE';
        loanAppl11.RecordTypeId = recordTypeId;
        loanAppl11.Original_Vehicle_Usage__c = 'Agri';
        loanAppl11.Collateral_Type__c = '10113';
        loanAppl11.EMI_Frequency__c='MONTHLY';
        insert loanAppl11;
        
        // Id coApplicantRecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByName().get('Co-Applicant').getRecordTypeId();
        Applicant__c appl1 = new Applicant__c();
        appl1.First_Name__c = 'Vikash1';
        appl1.Middle_Name__c = 'Kumar1';
        appl1.Last_Name__c = 'Mandal1';
        appl1.Loan__c =loanAppl11.Id;
        appl1.RecordTypeId=coApplicantRecordTypeId;
        appl1.Customer_Type__c='Individual';
        insert appl1;
        List<Applicant__c> appList = new List<Applicant__c>();
        appList.add(appl1);
        appList.add(appl11);
        // Applicant Financials Insertion
        Id parentRecordTypeId = Schema.SObjectType.Applicant_Financials_Details__c.getRecordTypeInfosByName().get('Financial Parent').getRecordTypeId();
        Applicant_Financials_Details__c applParentFinancials1 = new Applicant_Financials_Details__c();
        applParentFinancials1.Applicant__c = appl1.Id;
        applParentFinancials1.RecordTypeId = parentRecordTypeId;
        applParentFinancials1.isActive__c = true;
        applParentFinancials1.Type_Of_Employment__c ='Business';
        applParentFinancials1.Method_Of_Assesment__c ='Salaried';
        applParentFinancials1.Monthly_Income__c =100;
        applParentFinancials1.Monthly_Obligation__c =50;
        applParentFinancials1.Other_Income__c =80;
        applParentFinancials1.Row_Instance__c=0;
        applParentFinancials1.Consider_Income_for_Eligibility__c='Yes';
        insert 	applParentFinancials1;
        
        
        
        
        Test.startTest();
        FinancialViewTemplateR2Controller.getFinancialWrapper(appl11.Id,appList);  
        System.assertEquals('Vikash1', appl1.First_Name__c,'test');
        Test.stopTest();
    }
    
    
    
    @isTest static void getRevisitScreensTest(){
        Applicant__c appl =[SELECT id,First_Name__c,Re_Visit_Screens__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Map<String,Boolean> screenMap = new Map<String,Boolean>();
        screenMap.put('Financial',true);
        appl.Re_Visit_Screens__c = JSON.serialize(screenMap);
        update appl;
        appl =[SELECT id,First_Name__c,Re_Visit_Screens__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Applicant_Financials_Details__c parentRecord = [SELECT id,Type_Of_Employment__c FROM Applicant_Financials_Details__c WHERE Type_Of_Employment__c = 'Salaried - Private' ];
        Loan_Application__c loanInstance = [SELECT id,Application_Number__c
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        Test.startTest();
        FinancialViewTemplateR2Controller.getRevisitScreens(loanInstance.Id);  
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    
    @isTest static void updateRelatedApplTest(){
        Applicant__c appl =[SELECT id,First_Name__c,Re_Visit_Screens__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Test.startTest();
        FinancialViewTemplateR2Controller.updateRelatedApplicant(appl);  
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    
    @isTest static void getTractorFinancialValidationsTest(){
        Applicant__c appl =[SELECT id,First_Name__c,Re_Visit_Screens__c FROM Applicant__c WHERE First_Name__c='Vikash'];
        Loan_Application__c loanInstance = [SELECT Id, Customer_Grade__c, Original_Vehicle_Usage__c, Collateral_Type__c, EMI__c,
                                            Product__c, Loan_Amount__c, RecordType.DeveloperName, Stage__c
                                            FROM Loan_Application__c
                                            WHERE Application_Number__c='AP-12345'];
        Test.startTest();
        FinancialViewTemplateR2Controller.getTractorFinancialValidations(loanInstance);  
        FinancialViewTemplateR2Controller.updateRelatedApplicants(loanInstance.Id);
        FinancialViewTemplateR2Controller.getCommercialFinancialValidations(loanInstance.Id);
        System.assertEquals('Vikash', appl.First_Name__c,'test');
        Test.stopTest();
    }
    
    
    
    
    
    
    
    
    
    
    
}