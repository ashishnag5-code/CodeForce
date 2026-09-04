@isTest
public class LeadDedupeIntegrationHandlerTest {
    @testSetup static void setup() {
        Account dealerMaster = (Account)TestFactory.createSObject(new Account(
            Name ='TestAccount',
            Account_Code__c='2103',
            Purchase_City__c='Jaipur',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Dealer').getRecordTypeId()
        ),true);
        Account branchMaster = (Account)TestFactory.createSObject(new Account(
            Name ='Branch M',
            Account_Code__c='21034',
            Purchase_City__c='Jaipur',
            RecordTypeId=Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Branch').getRecordTypeId()
        ),true);
        //Loan Application Insertion
        Loan_Application__c loanAppl = (Loan_Application__c)TestFactory.createSObject(new Loan_Application__c(
            Application_Number__c  = 'AP-12345',
            Adhar_Card__c   = 123456,
            Loan_Amount__c  = 1000,
            Product__c='10201',
            Customer_Type__c='Non Individual',
            Stage__c ='QDE',
            EMI_Date__c = '10/3/2022',
            Tenure__c = 10,
            Dealer_Master__c = dealerMaster.Id,
            Branch_Master__c = branchMaster.Id,
            recordTypeId=Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByName().get('Two Wheeler').getRecordTypeId()
        ),true);
        
        //Applicant Insertion
        Applicant__c appl = (Applicant__c)TestFactory.createSObject(new Applicant__c(
            First_Name__c = 'Vikash',
            Middle_Name__c = 'Kumar',
            Last_Name__c = 'Mandal',
            CIF_No__c = '576321', 
            Driving_License_Id__c = 'HGTFR5467J',
            Loan__c =loanAppl.Id,
            Customer_Grade__c ='Premium',
            Customer_Type__c ='Individual',
            KYC_Type__c='Driving License',
            AU_Employee__c = 'Yes',
            AU_Employment_status__c='Active',
            Date_of_Joining__c = System.today().addDays(-60),
            Dob__c = System.today().addYears(-30),
            Education_qualification__c='GRADUATE',
            RecordTypeId=Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary_Applicant').getRecordTypeId()
        ),true);
    }
    testmethod static void generateRequest(){
        Applicant__c objAppli = [SELECT Id,Loan__r.Branch_Master__r.Account_Code__c,Mobile_Number__c,PAN__c, KYC_Status__c,Voter_Id__c, Driving_License_Id__c, Passport_Number__c, Gender__c, Dob__c, KYC_Type__c, Aadhaar_Number__c, First_Name__c, Last_Name__c, Middle_Name__c, Father_Name__c,CIF_No__c FROM Applicant__c limit 1];
        LeadDedupeIntegrationHandler.generateRequest(objAppli);
    }
    testmethod static void generateRequestElse(){
        Applicant__c objAppli = [SELECT Id,Customer_Type__c,Loan__r.Branch_Master__r.Account_Code__c,Mobile_Number__c,PAN__c, KYC_Status__c,Voter_Id__c, Driving_License_Id__c, Passport_Number__c, Gender__c, Dob__c, KYC_Type__c, Aadhaar_Number__c, First_Name__c, Last_Name__c, Middle_Name__c, Father_Name__c,CIF_No__c FROM Applicant__c limit 1];
        objAppli.CIF_No__c = null;
        LeadDedupeIntegrationHandler.generateRequest(objAppli);
    }
    testmethod static void generateRequestMapBank(){
        Map<String,String> objMap = new Map<String,String>();
        objMap.put('Bank Account','21643363');
        objMap.put('TransactionBranch','Jaipur');
        LeadDedupeIntegrationHandler.generateRequest(objMap);
    }
    testmethod static void generateRequestMapCredit(){
        Map<String,String> objMap = new Map<String,String>();
        objMap.put('Credit Card','21643363');
        objMap.put('TransactionBranch','Jaipur');
        LeadDedupeIntegrationHandler.generateRequest(objMap);
    }
    testmethod static void parse(){
        new LeadDedupeIntegrationHandler().generateJSONResponse(null);
    }
    
    testmethod static void mapSearchIntWraptoUIWrap(){
        Applicant__c objAppli = [SELECT Id,Customer_Type__c,Loan__r.Branch_Master__r.Account_Code__c,Mobile_Number__c,Loan__r.Stage__c,PAN__c, KYC_Status__c,Voter_Id__c, Driving_License_Id__c, Passport_Number__c, Gender__c, Dob__c, KYC_Type__c, Aadhaar_Number__c, First_Name__c, Last_Name__c, Middle_Name__c, Father_Name__c,CIF_No__c, Bureau_Score__c FROM Applicant__c limit 1];
        LeadDedupeIntegrationHandler.DedupeSearchResultWrapper objDedupeSearchWrapper = new LeadDedupeIntegrationHandler.DedupeSearchResultWrapper();
        
        LeadDedupeIntegrationHandler.cls_TransactionStatus transactionStatus = new LeadDedupeIntegrationHandler.cls_TransactionStatus();
        LeadDedupeIntegrationHandler.cls_ExtendedErrorDetails eeD= new LeadDedupeIntegrationHandler.cls_ExtendedErrorDetails();
        transactionStatus.ResponseCode = '0';
        transactionStatus.ResponseMessage='Success';
        transactionStatus.ExtendedErrorDetails = eeD;
        
        LeadDedupeIntegrationHandler.cls_MatchFound matchFound = new LeadDedupeIntegrationHandler.cls_MatchFound();
        LeadDedupeIntegrationHandler.cls_Customer objCustomer = new LeadDedupeIntegrationHandler.cls_Customer();
        LeadDedupeIntegrationHandler.cls_Address address = new LeadDedupeIntegrationHandler.cls_Address();
        address.City='Jaipur';
        address.Country='IN';
        address.Line1 = 'L1 LL';
        address.Line2 = 'Mansarovar';
        address.State = 'Rajasthan';
        address.Zip = '400074';
        objCustomer.AadhaarNumber='123412341234';
        objCustomer.Address = address;
        objCustomer.BlockStatus = 'N';
        objCustomer.CustomerFullName='Test Man';
        objCustomer.CustomerID = '5763211';
        objCustomer.CustomerType = '100';
        objCustomer.DateOfBirth='1991-02-01';
        objCustomer.DateOfIncorporation='1991-02-01';
        objCustomer.DrivingLicense='HGTFR5467J';
        objCustomer.LandlineResidenceNumber='8690999399';
        objCustomer.MobileNumber='8104655801';
        objCustomer.NPAStatus='N';
        objCustomer.PAN='HGTFR5467J';
        objCustomer.PassportNumber='HGTFR5467J';
        objCustomer.VoterID='HGTFR5467J';
        
        matchFound.Customer = new List<LeadDedupeIntegrationHandler.cls_Customer>{objCustomer};
        objDedupeSearchWrapper.ErrorCode = '0';
        objDedupeSearchWrapper.TransactionStatus = transactionStatus;
        objDedupeSearchWrapper.MatchFound = matchFound;
        LeadDedupeIntegrationHandler.mapSearchIntWraptoUIWrap(objDedupeSearchWrapper,objAppli);
        
        objAppli.Mobile_Number__c = '8104655801';
        objAppli.Driving_License_Id__c = '8104655801';
        update objAppli;
        LeadDedupeIntegrationHandler.mapSearchIntWraptoUIWrap(objDedupeSearchWrapper,objAppli);
        
        objAppli.Customer_Type__c = 'Non Individual';
        objAppli.PAN__c = 'HGTFR5467J';
        update objAppli;
        LeadDedupeIntegrationHandler.mapSearchIntWraptoUIWrap(objDedupeSearchWrapper,objAppli);
    }
    
    testmethod static void mapDetailIntWraptoUIWrap(){
        Applicant__c objAppli = [SELECT Id,Customer_Type__c,Loan__r.Branch_Master__r.Account_Code__c,Mobile_Number__c,PAN__c, KYC_Status__c,Voter_Id__c, Driving_License_Id__c, Passport_Number__c, Gender__c, Dob__c, KYC_Type__c, Aadhaar_Number__c, First_Name__c, Last_Name__c, Middle_Name__c, Father_Name__c,CIF_No__c, Loan__r.Stage__c FROM Applicant__c limit 1];
        LeadDedupeIntegrationHandler.DedupeDetailResultWrapper objDedupeDetailWrapper = new LeadDedupeIntegrationHandler.DedupeDetailResultWrapper();
        
        LeadDedupeIntegrationHandler.cls_TransactionStatus transactionStatus = new LeadDedupeIntegrationHandler.cls_TransactionStatus();
        LeadDedupeIntegrationHandler.cls_ExtendedErrorDetails eeD= new LeadDedupeIntegrationHandler.cls_ExtendedErrorDetails();
        transactionStatus.ResponseCode = '0';
        transactionStatus.ResponseMessage='Success';
        transactionStatus.ExtendedErrorDetails = eeD;
        objDedupeDetailWrapper.TransactionStatus = transactionStatus;
        
        LeadDedupeIntegrationHandler.cls_CustomerMemo CustomerMemo = new LeadDedupeIntegrationHandler.cls_CustomerMemo();
        LeadDedupeIntegrationHandler.cls_CustomerMemoDetail cmD = new LeadDedupeIntegrationHandler.cls_CustomerMemoDetail();
        cmD.CustomerId = '26440006';
        cmd.MemoDate = '26440006';
        cmD.MemoText = '26440006';
        cmD.SerialNumber = '26440006';
        cmD.Severity = '26440006';
        CustomerMemo.CustomerMemoDetail = new List<LeadDedupeIntegrationHandler.cls_CustomerMemoDetail>{cmD};
        objDedupeDetailWrapper.CustomerMemo = CustomerMemo;
        
        LeadDedupeIntegrationHandler.cls_CustomerResponse objCustomerRes = new LeadDedupeIntegrationHandler.cls_CustomerResponse ();
        LeadDedupeIntegrationHandler.cls_CustomerBasicInquiry basicInquiry = new LeadDedupeIntegrationHandler.cls_CustomerBasicInquiry();
        LeadDedupeIntegrationHandler.cls_AadhaarDetail aadhar = new LeadDedupeIntegrationHandler.cls_AadhaarDetail();
        aadhar.AadhaarNumber = '123412341234';
        LeadDedupeIntegrationHandler.cls_CustomerName customerName = new LeadDedupeIntegrationHandler.cls_CustomerName();
        customerName.FirstName = 'ASHISH';
        customerName.FormattedFullName='ASHISH#KUMAR#SHRIVASTAV';
        customerName.FullName='ASHISH KUMAR SHRIVASTAV';
        customerName.LastName='SHRIVASTAV';
        customerName.MidName='KUMAR';
        customerName.Prefix='MR.';
        customerName.ShortName='ASHISH KUMAR SHRIVAS';
        LeadDedupeIntegrationHandler.cls_CustomerDetailAddress address = new LeadDedupeIntegrationHandler.cls_CustomerDetailAddress();
        address.City='Jaipur';
        address.Country='IN';
        address.Line1 = 'L1 LL';
        address.Line2 = 'Rajat Path';
        address.Line3 = 'Mansarovar';
        address.State = 'Rajasthan';
        address.Zip = '400074';
        basicInquiry.AadhaarDetail = aadhar;
        basicInquiry.BankShortName = 'Bank_Center_Indore';
        basicInquiry.BirthDateText='1988-01-15';
        basicInquiry.CategoryType='INDIVIDUAL - FULL KYC';
        basicInquiry.CombWithdrawBal='0.0';
        basicInquiry.CustomerAddress = address;
        basicInquiry.CustomerFullName = 'ASHISH KUMAR SHRIVASTAV';
        basicInquiry.CustomerId ='21486134';
        basicInquiry.CustomerName=customerName;
        basicInquiry.CustomerType='100';
        basicInquiry.EmailAddress='21486134@axc.com';
        basicInquiry.HomeBranch='9001';
        basicInquiry.IcType='A';
        basicInquiry.IcTypeDesc='Aadhar Card';
        basicInquiry.IsImageAvailable='false';
        basicInquiry.IsSignatureAvailable='false';
        basicInquiry.MobileNumber='21486134';
        basicInquiry.NationalIdentificationCode='21486134';
        basicInquiry.PAN='21486134';
        basicInquiry.Sex='F';
        objCustomerRes.CustomerBasicInquiry = basicInquiry;
        objDedupeDetailWrapper.CustomerResponse = objCustomerRes;
        
        LeadDedupeIntegrationHandler.cls_AccountDetails accountDetails = new LeadDedupeIntegrationHandler.cls_AccountDetails();
        LeadDedupeIntegrationHandler.cls_CustomerAccount cusAcc = new LeadDedupeIntegrationHandler.cls_CustomerAccount();
        cusAcc.AccountId='9001010400837322';
        cusAcc.AcyAmount='288188.00';
        cusAcc.AmtGoal='0';
        cusAcc.AvailableBalance='288188.00';
        cusAcc.BalanceBook='288188.00';
        cusAcc.BalPrincipal='0';
        cusAcc.BalUncollectedInt='';
        cusAcc.BalUncollectedPrinc='0.00';
        cusAcc.BillAmount='0.00';
        cusAcc.BranchCode='';
        cusAcc.BranchName='Bank_Center_Indore';
        cusAcc.CASAAccountName='9001';
        cusAcc.Classification='';
        cusAcc.CurrencyCode='1';
        cusAcc.CurrencyShortName='INR';
        cusAcc.CurrentStatus='8';
        cusAcc.CurrentStatusDescription='';
        cusAcc.CustomerRelationship='SOW';
        cusAcc.DateAccountOpen='2017-03-09';
        cusAcc.DisbursedAmount='270000';
        cusAcc.EmiTenure='48';
        cusAcc.FutureDatedAmount='0.00';
        cusAcc.InstallmentAmount='0';
        cusAcc.InstallmentsOverDue='';
        cusAcc.IntRate='14.5';
        cusAcc.IsTDLinkage='';
        cusAcc.LcyAmount='288188.00';
        cusAcc.LienAmount='';
        cusAcc.LoanAccountName='ASHISH KUMAR SHRIVAS';
        cusAcc.LoanApplicationNumber='';
        cusAcc.MaturityDate='2021-03-10';
        cusAcc.ModuleCode='L';
        cusAcc.MonthsSinceActive='0';
        cusAcc.ODLimitSactioned='';
        cusAcc.ODLimitUtilized='';
        cusAcc.OriginalBalance='270000.00';
        cusAcc.OtherArrear='14160';
        cusAcc.ProductCode='12004';
        cusAcc.ProductName='12004-Securitization and Assignment';
        cusAcc.Reason='';
        cusAcc.SafeDepositBoxId='0';
        cusAcc.Tenure='48 Months 0 Days 0 Years';
        cusAcc.TotalAcyAmount='';
        cusAcc.TotalBalBook='288188.00';
        cusAcc.TotalBalUncollecInt='';
        cusAcc.TotalBalUncollecPrinc='0.00';
        cusAcc.TotalLcyAmount='';
        cusAcc.TotalNoOfInstallmentsReceived='';
        cusAcc.UnclearFunds='0.00';
        accountDetails.CustomerAccount = new List<LeadDedupeIntegrationHandler.cls_CustomerAccount>{cusAcc};
        accountDetails.IsCustomerSchemeAvailable = 'false';
        objDedupeDetailWrapper.AccountDetails = accountDetails;
        
        objAppli.Mobile_Number__c = '21486134';
        LeadDedupeIntegrationHandler.mapDetailIntWraptoUIWrap(objDedupeDetailWrapper,Label.AUSF_Dedupe_Card_Full,objAppli,1);
        
    }
    
}