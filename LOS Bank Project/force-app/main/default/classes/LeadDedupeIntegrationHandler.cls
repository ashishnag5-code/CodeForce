/*****
 * Class Name: LeadDedupeIntegrationHandler
 * Description:
 * Test Class Name: LeadDedupeIntegrationHandlerTest
 * 
 * LastModified Date    -   Last Modified By    -   Description

 * Sep-25-2023          -   Mayur               -   SFAU-5202 - At PSD, Customer dedupe API is calling without passing KYC in request payload
 * Dec-05-2023          -   Mohit M.            -   SFAU-5701 - NoOfEMIPaid for LOAN OD Details
 */
public class LeadDedupeIntegrationHandler implements IntegrationHandlerInterface{
    
    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        if(reqParam instanceof Applicant__c){
            Applicant__c paramsMap=(Applicant__c)reqParam;
            system.debug('%% '+paramsMap);
            DedupeSearchRequestWrapper objDedupeSearchRequestWrapper = new DedupeSearchRequestWrapper();
            objDedupeSearchRequestWrapper.RequestId = IntegrationUtility.getReferenceId();
            objDedupeSearchRequestWrapper.Channel = Label.AUSF_Dedupe_Search_Channel;
            objDedupeSearchRequestWrapper.ReferenceNumber = IntegrationUtility.getReferenceId();
            objDedupeSearchRequestWrapper.TransactionBranch = paramsMap.Loan__r.Branch_Master__r.Account_Code__c; //Label.AUSF_Dedupe_Search_Branch;
            if(paramsMap.CIF_No__c != null && paramsMap.CIF_No__c != ''){
                objDedupeSearchRequestWrapper.CustomerId = paramsMap.CIF_No__c;
            }
            else{
                //objDedupeSearchRequestWrapper.MobileNumber = '1021207666';
                objDedupeSearchRequestWrapper.MobileNumber = paramsMap.Mobile_Number__c != null ? paramsMap.Mobile_Number__c.replaceAll('\\D','') : '';
                objDedupeSearchRequestWrapper.PanNumber = paramsMap.PAN__c;
                if(paramsMap.Customer_Type__c != 'Non Individual'){
                    objDedupeSearchRequestWrapper.DrivingLicense = paramsMap.Driving_License_Id__c;
                    objDedupeSearchRequestWrapper.VoterID = paramsMap.Voter_Id__c;
                    objDedupeSearchRequestWrapper.PassportNumber = paramsMap.Passport_Number__c;
                    objDedupeSearchRequestWrapper.AadhaarNumber = paramsMap.Aadhaar_Number__c; //SFAU-5202
                    objDedupeSearchRequestWrapper.CustomerId = '';
                }
            }
            lstString.add(JSON.serialize(objDedupeSearchRequestWrapper));   
        }
        
        if(reqParam instanceof Map<String,String>){
            Map<String,String> reqParamMap = (Map<String,String>)reqParam;
            List<String> lstKeys = new List<String>(reqParamMap.keySet()); 
            if(!lstKeys.isEmpty() && lstKeys[0] == 'Bank Account'){
                DedupeDetailRequestWrapper objDedupeDetailRequestWrapper = new DedupeDetailRequestWrapper();
                objDedupeDetailRequestWrapper.RequestId = IntegrationUtility.getReferenceId();
                objDedupeDetailRequestWrapper.Channel = Label.AUSF_Dedupe_Search_Channel;
                objDedupeDetailRequestWrapper.ReferenceNumber = IntegrationUtility.getReferenceId();
                objDedupeDetailRequestWrapper.TransactionBranch = reqParamMap.get('TransactionBranch');  //Label.AUSF_Dedupe_Search_Branch;
                objDedupeDetailRequestWrapper.CustomerId = String.valueOf(reqParamMap.get(lstKeys[0]));
                //objDedupeDetailRequestWrapper.CustomerId = '21643363';
                lstString.add(JSON.serialize(objDedupeDetailRequestWrapper));  
            }
            if(!lstKeys.isEmpty() && lstKeys[0] == 'Credit Card'){
                DedupeDetailRequestWrapper objDedupeDetailRequestWrapper = new DedupeDetailRequestWrapper();
                objDedupeDetailRequestWrapper.RequestId = IntegrationUtility.getReferenceId();
                objDedupeDetailRequestWrapper.OriginatingChannel = Label.AUSF_Dedupe_Search_Channel;
                objDedupeDetailRequestWrapper.CustId = String.valueOf(reqParamMap.get(lstKeys[0]));
                //objDedupeDetailRequestWrapper.CustId = '25139814';
                lstString.add(JSON.serialize(objDedupeDetailRequestWrapper));  
            }
        }
        return lstString;
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    public class DedupeSearchRequestWrapper{
        public String DrivingLicense;
        public String VoterID;
        public String PassportNumber;
        public String MobileNumber;
        public String AadhaarNumber;
        public String RequestId;
        public String Channel;
        public String ReferenceNumber;
        public String PanNumber;
        public String TransactionBranch;
        public String CustomerId;
    }
    
    public class DedupeSearchResultWrapper{
        public LeadDedupeIntegrationHandler.cls_TransactionStatus TransactionStatus;
        public String ErrorCode;    //0
        public LeadDedupeIntegrationHandler.cls_MatchFound MatchFound;
        
    }
    
    public class DedupeDetailRequestWrapper{
        public String RequestId;
        public String Channel;
        public String ReferenceNumber;
        public String TransactionBranch;
        public String CustomerId;
        public String CustId;
        public String OriginatingChannel;
    }
    
    public class DedupeDetailResultWrapper{
        public LeadDedupeIntegrationHandler.cls_TransactionStatus TransactionStatus;
        public LeadDedupeIntegrationHandler.cls_CustomerMemo CustomerMemo;
        public LeadDedupeIntegrationHandler.cls_CustomerResponse CustomerResponse;
        public LeadDedupeIntegrationHandler.cls_AccountDetails AccountDetails;
        //public List<CreditCardResponse> CreditCardResponse;
    }
    
    public class cls_TransactionStatus {
        public String ResponseCode; //0
        public String ResponseMessage;  //Success
        public LeadDedupeIntegrationHandler.cls_ExtendedErrorDetails ExtendedErrorDetails;
    }
    public class cls_ExtendedErrorDetails {
        //public LeadDedupeIntegrationHandler.cls_messages messages;
    }
    public class cls_messages {
        public String code; //0
    }
    public class cls_MatchFound {
        public List<LeadDedupeIntegrationHandler.cls_Customer> Customer;
    }
    public class cls_CustomerMemo {
        public List<LeadDedupeIntegrationHandler.cls_CustomerMemoDetail> CustomerMemoDetail;
    }
    public class cls_CustomerMemoDetail {
        public String CustomerId;   //26440006
        public String SerialNumber;   //26440006
        public String MemoText;   //26440006
        public String Severity;   //26440006
        public String MemoDate;   //26440006
    }
    public class cls_Customer {
        public String CustomerID;   //26440006
        public String PAN;  //HGTFR5467J
        public String AadhaarNumber;  //HGTFR5467J
        public String MobileNumber; //8104655801
        public String DrivingLicense;
        public String VoterID;
        public String PassportNumber;
        public String LandlineResidenceNumber;  //8690999399
        public String CustomerFullName; //Harnoor Kaur
        public String DateOfBirth;  //1991-02-01
        public String DateOfIncorporation;  //1991-02-01
        public LeadDedupeIntegrationHandler.cls_Address Address;
        public String CustomerType; //100
        public String BlockStatus;  //N
        public String NPAStatus;  //N
    }
    public class cls_Address {
        public String Line1;    //2286 PLOT 12 EASTERN PART DHANMANDI
        public String Line2;    //NEAR HDFC BANK, HANUMAN GARH ROAD
        public String City; //JAIPUR
        public String State;    //RAJASTHAN
        public String Country;  //INDIA
        public String Zip;  //302019
    }
    
    public class cls_CustomerResponse {
        public cls_CustomerBasicInquiry CustomerBasicInquiry;
    }
    public class cls_CustomerBasicInquiry {
        public String CustomerFullName; //ASHISH KUMAR SHRIVASTAV
        public String IsSignatureAvailable; //false
        public String Sex;  //M
        public String IsImageAvailable; //false
        public cls_AadhaarDetail AadhaarDetail;
        public String CustomerId;   //21486134
        public String CategoryType; //INDIVIDUAL - FULL KYC
        public String CustomerType; //100
        public String EmailAddress; //21486134@axc.com
        public String IcTypeDesc;   //Aadhar Card
        public String MobileNumber; //21486134
        public String NationalIdentificationCode;   //21486134
        public String BankShortName;    //Bank_Center_Indore
        public String IcType;   //A
        public cls_CustomerName CustomerName;
        public String HomeBranch;   //9001
        public String PAN;  //21486134
        public String CombWithdrawBal;  //0.0
        public cls_CustomerDetailAddress CustomerAddress;
        public String BirthDateText;    //1988-01-15
    }
    public class cls_AadhaarDetail {
        public String AadhaarNumber;    //21486134
    }
    public class cls_CustomerName {
        public String MidName;  //KUMAR
        public String FirstName;    //ASHISH
        public String FullName; //ASHISH KUMAR SHRIVASTAV
        public String FormattedFullName;    //ASHISH#KUMAR#SHRIVASTAV
        public String ShortName;    //ASHISH KUMAR SHRIVAS
        public String Prefix;   //MR.
        public String LastName; //SHRIVASTAV
    }
    public class cls_CustomerDetailAddress {
        public String Zip;  //452011
        public String State;    //MADHYA PRADESH
        public String Country;  //India
        public String City; //INDORE
        public String Line1;    //21486134
        public String Line2;    //21486134
        public String Line3;    //21486134
    }
    public class cls_AccountDetails {
        public String IsCustomerSchemeAvailable;    //false
        public List<cls_CustomerAccount> CustomerAccount;
    }
    public class cls_CustomerAccount {
        public String SafeDepositBoxId; //0
        public String AccountId;    //9001010400837322
        public String BalanceBook;  //288188.00
        public String ProductName;  //12004-Securitization and Assignment
        public String TotalBalBook; //288188.00
        public String UnclearFunds; //0.00
        public String AcyAmount;    //288188.00
        public String Reason;   // 
        public String OtherArrear;  //14160
        public String CurrencyCode; //1
        public String OriginalBalance;  //270000.00
        public String Tenure;   //48 Months 0 Days 0 Years 
        public String AvailableBalance; //288188.00
        public String BalUncollectedInt;    //0.00
        public String IsTDLinkage;  //N 
        public String CurrentStatusDescription; //ACCOUNT OPEN REGULAR
        public String TotalAcyAmount;   //288188.00
        public String Classification;   //SUSPENDED
        public String TotalLcyAmount;   //288188.00
        public String LoanApplicationNumber;    //9001010400837322 
        public String BranchName;   //Bank_Center_Indore
        public String FutureDatedAmount;    //0.00
        public String MonthsSinceActive;    //0
        public String BalUncollectedPrinc;  //0.00
        public String TotalBalUncollecPrinc;    //0.00
        public String BillAmount;   //0.00
        public String BalPrincipal; //0
        public String CurrencyShortName;    //INR
        public String AmtGoal;  //0
        public String DisbursedAmount;  //270000
        public String ProductCode;  //12004
        public String CurrentStatus;    //8
        public String DateAccountOpen;  //2017-03-09
        public String LoanAccountName;  //ASHISH KUMAR SHRIVAS
        public String InstallmentAmount;    //0
        public String IntRate;  //14.5
        public String MaturityDate; //2021-03-10
        public String LcyAmount;    //288188.00
        public String ModuleCode;   //L
        public String EmiTenure;    //48
        public String CustomerRelationship; //SOW
        public String LienAmount;   //0
        public String TotalBalUncollecInt;  //0.00
        public String TotalNoOfInstallmentsReceived;  //0.00
        public String BranchCode;   //9001
        public String ODLimitSactioned;   //9001
        public String ODLimitUtilized;   //9001
        public String InstallmentsOverDue;   //9001
        public String CASAAccountName;   //9001
        public List<CASARelationshipDetails> CASARelationshipDetails;   //9001
    }
    
    public class CASARelationshipDetails {
        public String CustomerID;
        public String JointHolderName;
        public String MobileNo;
        public String Relationship;
    }
    
    public class CustomerODResponse {
        public CustomerODTransactionStatus TransactionStatus;
        public CustomerODAccountDetail[] AccountDetail;
    }
    public class CustomerODTransactionStatus {
        public String ResponseCode; //0
        public String ResponseMessage;  //Success
        public CustomerODResponseErrorDetails ExtendedErrorDetails;
    }
    public class CustomerODResponseErrorDetails {
        public CustomerODmessages[] messages;
    }
    public class CustomerODmessages {
        public Integer code;    //0
    }
    public class CustomerODAccountDetail {
        public String AccountId;  
        public CustomerODLoanAccountDetails[] LoanAccountDetails;    
    }
    public class CustomerODLoanAccountDetails {
        public String AccountNo;  
        public Integer InstallmentsOverDue;
        public Decimal PrincipalBalance;
        // SFAU-5701
        public Integer TotalNoOfInstallmentsReceived;
    }
    /*
    public class CreditCardResponse {
        public String CustomerID;
        public String CustomerAccountRelation;
        public String AccountNumber;
        public String LoanStatus;
        public Object CustomerFullName;
        public String ProductCode;
        public String Decode;
        public String AccountOpenDate;
        public String AccountStatus;
        public String SanctionedAmount;
        public String DPDValue;
        public String LastStatementBalance;
    }
    */
    public static LeadDedupeWrapper.leadCBSDedupeWrapper mapSearchIntWraptoUIWrap(DedupeSearchResultWrapper objDedupeSearchWrapper, Applicant__c objApplicant){
        LeadDedupeWrapper.leadCBSDedupeWrapper objleadCBSDedupeWrapper = new LeadDedupeWrapper.leadCBSDedupeWrapper();
        objleadCBSDedupeWrapper.applicantList_fullMatch = new list<LeadDedupeWrapper.CustomerListWrapper>();
        objleadCBSDedupeWrapper.applicantList_partialMatch = new list<LeadDedupeWrapper.CustomerListWrapper>();
        String stageLabel = Label.runDedupeStages ;
        List<String> dedupeStages = stageLabel.split(',');
        system.debug('%%% '+objApplicant);
        //List<LeadDedupeWrapper.CustomerWrapper> lstCustomerWrapper = new List<LeadDedupeWrapper.CustomerWrapper>();
        LeadDedupeWrapper.CustomerListWrapper objCustomerWrapper;
        if(objDedupeSearchWrapper != null && objDedupeSearchWrapper.MatchFound != null 
            && objDedupeSearchWrapper.MatchFound.Customer != null){
            for(LeadDedupeIntegrationHandler.cls_Customer objCustomer : objDedupeSearchWrapper.MatchFound.Customer){
                objCustomerWrapper = new LeadDedupeWrapper.CustomerListWrapper();
                objCustomerWrapper.strCustomerName = objCustomer.CustomerFullName;
                objCustomerWrapper.strCustomerID = objCustomer.CustomerID;
                objCustomerWrapper.strGender = '';
                objCustomerWrapper.strAadhaar = objCustomer.AadhaarNumber;
                objCustomerWrapper.strPAN = objCustomer.PAN;
                objCustomerWrapper.strMobile = objCustomer.MobileNumber;
                objCustomerWrapper.strBlockStatus = objCustomer.BlockStatus;
                objCustomerWrapper.boolIsInputApplicantIndividual = (objApplicant.Customer_Type__c != null && objApplicant.Customer_Type__c != 'Non Individual' ? true : false);
                objCustomerWrapper.strInputCustomerType = (objApplicant.Customer_Type__c != null && objApplicant.Customer_Type__c != 'Non Individual' ? 'Individual' : 'Non Individual');
                objCustomerWrapper.strNPAStatus = (objCustomer.NPAStatus != null ? objCustomer.NPAStatus : '');
                if(CBS_Customer_Type_Mapping__mdt.getInstance('CUST_TYP_'+objCustomer.CustomerType) != null){
                    objCustomerWrapper.strCustomerType = CBS_Customer_Type_Mapping__mdt.getInstance('CUST_TYP_'+objCustomer.CustomerType).FLG_TYP_CLASS__c == 'I'? 'Individual' : 'Non Individual'; 
                }
                if(objApplicant.Customer_Type__c != 'Non Individual' && ((objApplicant.CIF_No__c != null && objCustomer.CustomerID == objApplicant.CIF_No__c) || 
                    /*objApplicant.Mobile_Number__c != null && objCustomer.MobileNumber == objApplicant.Mobile_Number__c.replaceAll('\\D','') && */
                        (objApplicant.PAN__c != null && objCustomer.PAN == String.valueOf(objApplicant.PAN__c)) 
                            || (objApplicant.Aadhaar_Number__c != null && objCustomer.AadhaarNumber == String.valueOf(objApplicant.Aadhaar_Number__c))
                            || (objApplicant.Voter_Id__c != null && objCustomer.VoterID == String.valueOf(objApplicant.Voter_Id__c))
                            || (objApplicant.Passport_Number__c != null && objCustomer.PassportNumber == String.valueOf(objApplicant.Passport_Number__c))
                            || (objApplicant.Driving_License_Id__c != null && objCustomer.DrivingLicense == String.valueOf(objApplicant.Driving_License_Id__c)))){
                    //objCustomerWrapper.boolIsCopyDisabled = objApplicant.Bureau_Score__c != null ? true : false;
                    objCustomerWrapper.boolIsCopyDisabled = dedupeStages.contains(objApplicant.Loan__r.Stage__c) ? false : true; // Updated by Samridhi to enable till PSD Stage - SFAU-5341
                    objleadCBSDedupeWrapper.applicantList_fullMatch.add(objCustomerWrapper);
                }
                else if(objApplicant.Customer_Type__c == 'Non Individual' && ((objApplicant.CIF_No__c != null && objCustomer.CustomerID == objApplicant.CIF_No__c) || 
                        (objApplicant.PAN__c != null && objCustomer.PAN == String.valueOf(objApplicant.PAN__c)))){
                    objCustomerWrapper.boolIsCopyDisabled = false;
                    objleadCBSDedupeWrapper.applicantList_fullMatch.add(objCustomerWrapper);                        
                }
                else if(objApplicant.Mobile_Number__c != null && objCustomer.MobileNumber == objApplicant.Mobile_Number__c.replaceAll('\\D','')){
                    objCustomerWrapper.boolIsCopyDisabled = true;
                    objleadCBSDedupeWrapper.applicantList_partialMatch.add(objCustomerWrapper);
                }
            }
        }
        return objleadCBSDedupeWrapper;
    }
    
    public static LeadDedupeWrapper.CustomerDetailWrapper mapDetailIntWraptoUIWrap(DedupeDetailResultWrapper objDedupeDetailWrapper, String cardName, Applicant__c objApplicant, Integer countFull){
        LeadDedupeWrapper.CustomerDetailWrapper objCustomerDetailWrapper = new LeadDedupeWrapper.CustomerDetailWrapper();
        String stageLabel = Label.runDedupeStages ;
        List<String> dedupeStages = stageLabel.split(',');
        try{
            if(objDedupeDetailWrapper != null && objDedupeDetailWrapper.CustomerResponse != null 
                && objDedupeDetailWrapper.CustomerResponse.CustomerBasicInquiry != null){
                
                LeadDedupeIntegrationHandler.cls_CustomerBasicInquiry objCustomerBasicInquiry = objDedupeDetailWrapper.CustomerResponse.CustomerBasicInquiry;
                objCustomerDetailWrapper.strCustomerName = objCustomerBasicInquiry.CustomerFullName;
                objCustomerDetailWrapper.strCustomerID = objCustomerBasicInquiry.CustomerId;
                objCustomerDetailWrapper.strAadhaar = objCustomerBasicInquiry.AadhaarDetail != null? objCustomerBasicInquiry.AadhaarDetail.AadhaarNumber : '';
                objCustomerDetailWrapper.strPAN = objCustomerBasicInquiry.PAN;
                objCustomerDetailWrapper.strPrefix = objCustomerBasicInquiry.CustomerName.Prefix;
                objCustomerDetailWrapper.strFirstName = objCustomerBasicInquiry.CustomerName.FirstName;
                objCustomerDetailWrapper.strMiddleName = objCustomerBasicInquiry.CustomerName.MidName;
                objCustomerDetailWrapper.strLastName = objCustomerBasicInquiry.CustomerName.LastName;
                objCustomerDetailWrapper.strShortName = objCustomerBasicInquiry.CustomerName.ShortName;
                objCustomerDetailWrapper.strConstitutionType = objCustomerBasicInquiry.CategoryType;
                objCustomerDetailWrapper.strSex = (objCustomerBasicInquiry.Sex == Label.AUSF_Gender_Code_Male ? Label.AUSF_Gender_Male :
                                                    (objCustomerBasicInquiry.Sex == Label.AUSF_Gender_Code_Female ? Label.AUSF_Gender_Female : ''));
                objCustomerDetailWrapper.strMobileNumber = objCustomerBasicInquiry.MobileNumber;
                objCustomerDetailWrapper.strAddressLine1 = objCustomerBasicInquiry.CustomerAddress.Line1;
                objCustomerDetailWrapper.strAddressLine2 = objCustomerBasicInquiry.CustomerAddress.Line2;
                objCustomerDetailWrapper.strAddressLine3 = objCustomerBasicInquiry.CustomerAddress.Line3;
                objCustomerDetailWrapper.strCity = objCustomerBasicInquiry.CustomerAddress.City;
                objCustomerDetailWrapper.strState = objCustomerBasicInquiry.CustomerAddress.State;
                objCustomerDetailWrapper.strCountry = objCustomerBasicInquiry.CustomerAddress.Country;
                objCustomerDetailWrapper.strPincode = objCustomerBasicInquiry.CustomerAddress.Zip;
                objCustomerDetailWrapper.strDOB = objCustomerBasicInquiry.BirthDateText;
                objCustomerDetailWrapper.strEmailID = objCustomerBasicInquiry.EmailAddress;
                objCustomerDetailWrapper.strBankShortName = objCustomerBasicInquiry.BankShortName;
                objCustomerDetailWrapper.boolIsSignatureAvailable = objCustomerBasicInquiry.IsSignatureAvailable == 'true' ? true : false;
                objCustomerDetailWrapper.boolIsImageAvailable = objCustomerBasicInquiry.IsImageAvailable == 'true' ? true : false;
                if(countFull > 0 && cardName != Label.AUSF_Dedupe_Card_Full){
                    objCustomerDetailWrapper.boolIsCopyDisabled = true;
                }
                else{
                    //objCustomerDetailWrapper.boolIsCopyDisabled = objApplicant.Bureau_Score__c != null ? true : false; // Added by Neha to disable Copy to Applicant button if CIBIL is already fetched.
                    //objCustomerDetailWrapper.boolIsCopyDisabled = false;
                    objCustomerDetailWrapper.boolIsCopyDisabled = dedupeStages.contains(objApplicant.Loan__r.Stage__c) ? false : true; // Updated by Samridhi to enable till PSD Stage - SFAU-5341
                    
                }
                objCustomerDetailWrapper.strInputCustomerType = (objApplicant.Customer_Type__c != null && objApplicant.Customer_Type__c != 'Non Individual' ? 'Individual' : 'Non Individual');
                if(CBS_Customer_Type_Mapping__mdt.getInstance('CUST_TYP_'+objCustomerBasicInquiry.CustomerType) != null){
                    objCustomerDetailWrapper.strCustomerType = CBS_Customer_Type_Mapping__mdt.getInstance('CUST_TYP_'+objCustomerBasicInquiry.CustomerType).FLG_TYP_CLASS__c == 'I'? 'Individual' : 'Non Individual'; 
                    objCustomerDetailWrapper.strInputCustomerTypeDesc = CBS_Customer_Type_Mapping__mdt.getInstance('CUST_TYP_'+objCustomerBasicInquiry.CustomerType).TXT_CUST_TYPE__c;//R2-41 store to check later if complaint or non complaint
                }
                objCustomerDetailWrapper.boolIsInputApplicantIndividual = (objApplicant.Customer_Type__c != null && objApplicant.Customer_Type__c != 'Non Individual' ? true : false);   
                objCustomerDetailWrapper.boolIsKYCDone = objApplicant.Mobile_Number__c.replaceAll('\\D','') == objCustomerDetailWrapper.strMobileNumber && objCustomerBasicInquiry.CategoryType != null 
                                    && (objCustomerBasicInquiry.CategoryType =='INDIVIDUAL - FULL KYC' || objCustomerBasicInquiry.CategoryType =='INDIVIDUAL SENIOR CITIZEN - FULL KYC') 
                                    && cardName == Label.AUSF_Dedupe_Card_Full ? true : false;
                objCustomerDetailWrapper.boolIsFullMatch = (cardName == Label.AUSF_Dedupe_Card_Full ? true : false);
            }
            objCustomerDetailWrapper.lstAccountWrapper = new List<LeadDedupeWrapper.AccountWrapper>();
            objCustomerDetailWrapper.lstAccountWrapper = mapDetailIntWraptoUIWrapAcc(objDedupeDetailWrapper);
        }
        catch(Exception objException) {
            Log.error('Error in LeadDedupeIntegrationHandler mapDetailIntWraptoUIWrap :: ' + objException.getLineNumber() + ' ' + objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),objApplicant!= NULL ? objApplicant.Id : '');
            throw objException;
        }
        return objCustomerDetailWrapper;
    }
    
    
    public static List<LeadDedupeWrapper.AccountWrapper> mapDetailIntWraptoUIWrapAcc(DedupeDetailResultWrapper objDedupeDetailWrapper){
        List<LeadDedupeWrapper.AccountWrapper> lstAccountWrapper = new List<LeadDedupeWrapper.AccountWrapper>();
        try{
            String completeAccountName = ''; 
            if(objDedupeDetailWrapper != null && objDedupeDetailWrapper.AccountDetails != null){
                completeAccountName = objDedupeDetailWrapper.CustomerResponse.CustomerBasicInquiry.CustomerFullName;
                for(LeadDedupeIntegrationHandler.cls_CustomerAccount objCustomerAccount : objDedupeDetailWrapper.AccountDetails.CustomerAccount){
                    LeadDedupeWrapper.AccountWrapper objAccountWrapper = new LeadDedupeWrapper.AccountWrapper();
                    objAccountWrapper.strLoanNumber = objCustomerAccount.LoanApplicationNumber != null ? objCustomerAccount.LoanApplicationNumber.trim() : '';
                    objAccountWrapper.strProduuct = objCustomerAccount.ProductName;
                    objAccountWrapper.strBranchName = objCustomerAccount.BranchName;
                    objAccountWrapper.strCustomerRelationship = objCustomerAccount.CustomerRelationship;
                    objAccountWrapper.strCurrentStatus = objCustomerAccount.CurrentStatusDescription;
                    objAccountWrapper.strLoanAmount = objCustomerAccount.DisbursedAmount;
                    objAccountWrapper.strTenureMonth = objCustomerAccount.Tenure;
                    objAccountWrapper.strAccountOpeningDate = objCustomerAccount.DateAccountOpen;
                    objAccountWrapper.strMaturityDate = objCustomerAccount.MaturityDate;
                    objAccountWrapper.strTotalOutstanding = objCustomerAccount.TotalBalBook;
                    objAccountWrapper.strEMIAmount = objCustomerAccount.InstallmentAmount;
                    objAccountWrapper.strROI = objCustomerAccount.IntRate;
                    objAccountWrapper.strPOS = objCustomerAccount.BalPrincipal; 
                    if(objCustomerAccount.ModuleCode == 'C'){
                        objAccountWrapper.strLoanTitle =  objCustomerAccount.AccountId;
                        objAccountWrapper.strCASAAccountName =  completeAccountName; // objCustomerAccount.CASAAccountName; //SFAU-4640 - Kunal
                        objAccountWrapper.strAvailableBalance =  objCustomerAccount.AvailableBalance;
                        objAccountWrapper.strODLimitSactioned = objCustomerAccount.ODLimitSactioned;
                        objAccountWrapper.strODLimitUtilized = objCustomerAccount.ODLimitUtilized;
                        if(objCustomerAccount.CASARelationShipDetails != null){
                            objAccountWrapper.strCASARelationShipDetails = JSON.serialize(objCustomerAccount.CASARelationShipDetails);
                        }
                        if(String.isNotBlank(objAccountWrapper.strODLimitSactioned) && Integer.valueOf(objAccountWrapper.strODLimitSactioned) > 0){
                            objAccountWrapper.boolIsODCCAccount = true;
                        }
                        else{
                            objAccountWrapper.boolIsCASAAccount = true;
                        }
                    }
                    else if(objCustomerAccount.ModuleCode == 'T'){
                        objAccountWrapper.strAvailableBalance =  objCustomerAccount.AvailableBalance;
                        objAccountWrapper.strLoanTitle =  objCustomerAccount.AccountId;
                        objAccountWrapper.boolIsFDRDAccount = true;
                    }
                    else if(objCustomerAccount.ModuleCode == 'L'){
                        //objAccountWrapper.strLoanTitle =  objCustomerAccount.LoanApplicationNumber;
                        objAccountWrapper.strLoanTitle =  objCustomerAccount.AccountId;
                        objAccountWrapper.strProductCode = objCustomerAccount.ProductCode;
                        objAccountWrapper.strLoanAccountName = objCustomerAccount.LoanAccountName;
                        objAccountWrapper.strEmiTenure = objCustomerAccount.EmiTenure;
                        objAccountWrapper.strInstallmentsOverDue = objCustomerAccount.InstallmentsOverDue;
                        objAccountWrapper.strTotalNoOfInstallmentsReceived = objCustomerAccount.TotalNoOfInstallmentsReceived;
                        objAccountWrapper.strNoofEmiPaid = objCustomerAccount.TotalNoOfInstallmentsReceived;
                        objAccountWrapper.boolIsLoanAccount = true;
                    }
                    else if(objCustomerAccount.ModuleCode == 'R'){
                        objAccountWrapper.boolIsFDRDAccount = true;
                    }
                    lstAccountWrapper.add(objAccountWrapper);
                }
            }
        }
        catch(Exception objException) {
            Log.error('Error in LeadDedupeIntegrationHandler mapDetailIntWraptoUIWrapAcc :: ' + objException.getLineNumber() + ' ' + objException,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),'');
            throw objException;
        }
        return lstAccountWrapper;
    }
    
}