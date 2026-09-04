public class LeadDedupeWrapper{

    public class LeadtoLeadWrapper{
        @AuraEnabled public String strApplicationstatus {get;set;}
        @AuraEnabled public String strBranchName {get;set;}
        @AuraEnabled public String strLeadId{get;set;}
        @AuraEnabled public String strApplicationNumber{get;set;}
        @AuraEnabled public String strCustomerName{get;set;}
        @AuraEnabled public String strCustomerMobileNumber{get;set;}
        @AuraEnabled public String strLeadCreationDate{get;set;}
        @AuraEnabled public String strProductName{get;set;}
        @AuraEnabled public String strBranchCode{get;set;}
        @AuraEnabled public String strLoanAmount{get;set;}
        @AuraEnabled public String strCustomerType{get;set;}
        @AuraEnabled public String strKYCMatchParameter{get;set;}
        @AuraEnabled public String strRONameCode{get;set;}
        @AuraEnabled public String strROMobileNumber{get;set;}
    }
    
    public class leadCBSDedupeWrapper{
        @AuraEnabled public list<CustomerListWrapper> applicantList_fullMatch{get;set;}
        @AuraEnabled public list<CustomerListWrapper> applicantList_partialMatch{get;set;}
        public leadCBSDedupeWrapper(){
            applicantList_fullMatch = new list<CustomerListWrapper>();
            applicantList_partialMatch = new list<CustomerListWrapper>();
        }
    }
    
    public class leadCBSCreditCardWrapper{
        @AuraEnabled public List<cls_CreditCardResponse> CreditCardResponse{get;set;}
        public leadCBSCreditCardWrapper(){
            CreditCardResponse = new list<cls_CreditCardResponse>();
        }
    }
    
    public class CustomerListWrapper{
        @AuraEnabled public String strCustomerName {get;set;}
        @AuraEnabled public String strCustomerID {get;set;}
        @AuraEnabled public String strGender{get;set;}
        @AuraEnabled public String strAadhaar{get;set;}
        @AuraEnabled public String strPAN{get;set;}
        @AuraEnabled public String strMobile{get;set;}
        @AuraEnabled public String strBlockStatus{get;set;}
        @AuraEnabled public String strNPAStatus{get;set;}
        @AuraEnabled public String strCustomerType{get;set;}
        @AuraEnabled public String strInputCustomerType{get;set;}
        @AuraEnabled public Boolean boolIsCopyDisabled{get;set;}
        @AuraEnabled public Boolean boolIsInputApplicantIndividual{get;set;}
    }
    
    public class CustomerDetailWrapper{
        @AuraEnabled public String strCustomerName {get;set;}
        @AuraEnabled public String strCustomerID {get;set;}
        @AuraEnabled public String strAadhaar{get;set;}
        @AuraEnabled public String strPAN{get;set;}
        @AuraEnabled public String strPrefix{get;set;}
        @AuraEnabled public String strFirstName{get;set;}
        @AuraEnabled public String strMiddleName{get;set;}
        @AuraEnabled public String strLastName{get;set;}
        @AuraEnabled public String strShortName{get;set;}
        @AuraEnabled public String strCustomerType{get;set;}
        @AuraEnabled public String strConstitutionType{get;set;}
        @AuraEnabled public String strSex{get;set;}
        @AuraEnabled public String strMobileNumber{get;set;}
        @AuraEnabled public String strAddressLine1{get;set;}
        @AuraEnabled public String strAddressLine2{get;set;}
        @AuraEnabled public String strAddressLine3{get;set;}
        @AuraEnabled public String strCity{get;set;}
        @AuraEnabled public String strState{get;set;}
        @AuraEnabled public String strCountry{get;set;}
        @AuraEnabled public String strPincode{get;set;}
        @AuraEnabled public String strDOB{get;set;}
        @AuraEnabled public String strEmailID{get;set;}
        @AuraEnabled public String strBankShortName{get;set;}
        @AuraEnabled public String strInputCustomerType{get;set;}
        @AuraEnabled public String strInputCustomerTypeDesc{get;set;}//R2-41
        @AuraEnabled public Boolean boolIsSignatureAvailable{get;set;}
        @AuraEnabled public Boolean boolIsImageAvailable{get;set;}
        @AuraEnabled public Boolean boolIsKYCDone{get;set;}
        @AuraEnabled public Boolean boolIsFullMatch{get;set;}
        @AuraEnabled public Boolean boolIsInputApplicantIndividual{get;set;}
        @AuraEnabled public Boolean boolIsCopyDisabled{get;set;}
        @AuraEnabled public List<AccountWrapper> lstAccountWrapper{get;set;}
        /*@AuraEnabled public List<AccountWrapper> lstODCCAccountWrapper{get;set;}
        @AuraEnabled public List<AccountWrapper> lstLoanAccountWrapper{get;set;}
        @AuraEnabled public List<AccountWrapper> lstCASAAccountWrapper{get;set;}
        @AuraEnabled public List<AccountWrapper> lstFDRDAAccountWrapper{get;set;}
        @AuraEnabled public List<AccountWrapper> lstCCAccountWrapper{get;set;}*/
    }
    
    public class AccountWrapper {
        @AuraEnabled public String strLoanTitle{get;set;}
        @AuraEnabled public String strLoanNumber{get;set;}
        @AuraEnabled public String strProduuct{get;set;}
        @AuraEnabled public String strBranchName{get;set;}
        @AuraEnabled public String strCustomerRelationship{get;set;}
        @AuraEnabled public String strCurrentStatus{get;set;}
        @AuraEnabled public String strLoanAmount{get;set;}
        @AuraEnabled public String strTenureMonth{get;set;}
        @AuraEnabled public String strAccountOpeningDate{get;set;}
        @AuraEnabled public String strMaturityDate{get;set;}
        @AuraEnabled public String strNoofEmiPaid{get;set;}
        @AuraEnabled public String strTotalOutstanding{get;set;}
        @AuraEnabled public String strEMIAmount{get;set;}
        @AuraEnabled public String strROI{get;set;}
        @AuraEnabled public String strPOS{get;set;}
        @AuraEnabled public String strODLimitSactioned{get;set;}
        @AuraEnabled public String strODLimitUtilized{get;set;}
        @AuraEnabled public String strProductCode{get;set;}  //102
        @AuraEnabled public String strLoanAccountName{get;set;}  //102
        @AuraEnabled public String strTotalNoOfInstallmentsReceived{get;set;}
        @AuraEnabled public String strEmiTenure{get;set;}
        @AuraEnabled public String strInstallmentsOverDue{get;set;}
        @AuraEnabled public String strCASAAccountName{get;set;}
        @AuraEnabled public String strAvailableBalance{get;set;}
        @AuraEnabled public String strCASARelationShipDetails{get;set;}
        @AuraEnabled public Boolean boolIsODCCAccount{get;set;}
        @AuraEnabled public Boolean boolIsLoanAccount{get;set;}
        @AuraEnabled public Boolean boolIsCASAAccount{get;set;}
        @AuraEnabled public Boolean boolIsFDRDAccount{get;set;}
        @AuraEnabled public Boolean boolIsCCAccount{get;set;}
    
    }
    
    
    public class cls_CreditCardResponse {
        @AuraEnabled public String CustomerID{get;set;}   //25479697
        @AuraEnabled public String CustomerAccountRelation{get;set;}  //Sole Owner
        @AuraEnabled public String AccountNumber{get;set;}    //0001691023625986272
        @AuraEnabled public String LoanStatus{get;set;}   //Standard
        @AuraEnabled public String CustomerFullName{get;set;}
        @AuraEnabled public String ProductCode{get;set;}  //102
        @AuraEnabled public String Decode{get;set;}   //ALTURA PLUS
        @AuraEnabled public String AccountOpenDate{get;set;}  //2021-07-23 00:00:00
        @AuraEnabled public String AccountStatus{get;set;}    //ACCOUNT OPEN REGULAR
        @AuraEnabled public String SanctionedAmount{get;set;} //90000
        @AuraEnabled public String DPDValue{get;set;} //0
        @AuraEnabled public String LastStatementBalance{get;set;} //12,656.00
    }
    /*
    @AuraEnabled
    public static leadCBSDedupeWrapper getData(){
        leadCBSDedupeWrapper objleadCBSDedupeWrapper = new leadCBSDedupeWrapper();
        objleadCBSDedupeWrapper.applicantList_fullMatch = new list<CustomerWrapper>();
        objleadCBSDedupeWrapper.applicantList_fullMatch = getCustomerWrapper(3,'full');
        
        objleadCBSDedupeWrapper.applicantList_partialMatch = new list<CustomerWrapper>();
        objleadCBSDedupeWrapper.applicantList_partialMatch = getCustomerWrapper(3,'partial');
        
        return objleadCBSDedupeWrapper;
    }
    
    public static List<CustomerWrapper> getCustomerWrapper(Integer count, String type){
        List<CustomerWrapper> lstCustomerWrapper = new List<CustomerWrapper>();
        for(Integer i=0 ; i< count ; i++){
            CustomerWrapper objCustomerWrapper = new CustomerWrapper();
            objCustomerWrapper.strCustomerName = 'Test'+i;
            objCustomerWrapper.strCustomerID = type+'-146253'+i;
            objCustomerWrapper.strGender = 'M';
            objCustomerWrapper.strAadhar = '1462533726768'+i;
            objCustomerWrapper.strPAN = '14625323'+i;
            objCustomerWrapper.strMobile = '946253654'+i;
            objCustomerWrapper.strPerfix = 'Mr';
            objCustomerWrapper.strFirstName = 'Test'+i;
            objCustomerWrapper.strMiddleName = 'T';
            objCustomerWrapper.strLastName = 'Test'+i;
            objCustomerWrapper.strShortName = 'TT';
            objCustomerWrapper.strConstitutionType = 'Test'+i;
            objCustomerWrapper.strSex = 'M';
            objCustomerWrapper.strMobileNumber = '975625267'+i;
            objCustomerWrapper.strAddressLine1 = 'Test'+i;
            objCustomerWrapper.strAddressLine2 = 'Test'+i;
            objCustomerWrapper.strAddressLine3 = 'Test'+i;
            objCustomerWrapper.strCity = 'Test'+i;
            objCustomerWrapper.strState = 'Test'+i;
            objCustomerWrapper.strCountry = 'Test'+i;
            objCustomerWrapper.strPincode = '16560'+i;
            objCustomerWrapper.strDOB = '13/2/2000';
            objCustomerWrapper.strEmailID = 'Test'+i+'@gmail.com';
            objCustomerWrapper.lstAccountWrapper = new List<AccountWrapper>();
            objCustomerWrapper.lstAccountWrapper = getAccountWrapper(10);
            lstCustomerWrapper.add(objCustomerWrapper);
        }
        return lstCustomerWrapper;
    }
    
    public static List<AccountWrapper> getAccountWrapper(Integer count) {
        List<AccountWrapper> lstAccountWrapper = new List<AccountWrapper>();
        for(Integer i=0 ; i< count ; i++){
            AccountWrapper objAccountWrapper = new AccountWrapper();
            objAccountWrapper.strLoanNumber = '12345'+i;
            objAccountWrapper.strLoanTitle = 'Loan Number : '+objAccountWrapper.strLoanNumber;
            objAccountWrapper.strProduuct = 'Product'+i;
            objAccountWrapper.strBranchName = 'Branch'+i;
            objAccountWrapper.strCustomerRelationship = 'Applicant';
            objAccountWrapper.strCurrentStatus = 'Active';
            objAccountWrapper.strLoanAmount = '300000';
            objAccountWrapper.strTenureMonth = '240';
            objAccountWrapper.strAccountOpeningDate = '23/10/2021';
            objAccountWrapper.strMaturityDate = '23/10/2025';
            objAccountWrapper.strNoofEmiPaid = '4';
            objAccountWrapper.strTotalOutstanding = '200000';
            objAccountWrapper.strEMIAmount = '500';
            objAccountWrapper.strROI = 'Test';
            objAccountWrapper.strPOS = 'Test';
            //objAccountWrapper.boolIsODCCAccount = true;
            if(i<2)
                objAccountWrapper.boolIsODCCAccount = true;
            if(i >= 2 && i < 4)
                objAccountWrapper.boolIsLoanAccount = true;
            if(i >= 4 && i < 6)
                objAccountWrapper.boolIsCASAAccount = true;
            if(i >= 6 && i < 8)
                objAccountWrapper.boolIsFDRDAccount = true;
            if(i >= 8 && i < 10)
                objAccountWrapper.boolIsCCAccount = true;
            lstAccountWrapper.add(objAccountWrapper);
        }
        return lstAccountWrapper;
    }
    */
}