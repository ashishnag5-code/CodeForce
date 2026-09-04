@isTest
public class LeadDedupeWrapperTest {
    @isTest static void leadDedupeWrapperTest1(){
        LeadDedupeWrapper.LeadtoLeadWrapper leadWrapper = new LeadDedupeWrapper.LeadtoLeadWrapper();
        leadWrapper.strApplicationstatus ='';
        leadWrapper.strBranchName ='';
        leadWrapper.strLeadId ='';
        leadWrapper.strApplicationNumber ='';
        leadWrapper.strCustomerName ='';
        leadWrapper.strCustomerMobileNumber ='';
        leadWrapper.strLeadCreationDate ='';
        leadWrapper.strProductName ='';
        leadWrapper.strBranchCode ='';
        leadWrapper.strLoanAmount ='';
        leadWrapper.strCustomerType ='';
        leadWrapper.strKYCMatchParameter ='';
        leadWrapper.strRONameCode ='';
        leadWrapper.strROMobileNumber ='';
        
        LeadDedupeWrapper.cls_CreditCardResponse creditWrapper = new LeadDedupeWrapper.cls_CreditCardResponse();
        creditWrapper.CustomerID='';
        creditWrapper.CustomerAccountRelation='';
        creditWrapper.AccountNumber='';
        creditWrapper.LoanStatus='';
        creditWrapper.CustomerFullName='';
        creditWrapper.ProductCode='';
        creditWrapper.Decode='';
        creditWrapper.AccountOpenDate='';
        creditWrapper.AccountStatus='';
        creditWrapper.SanctionedAmount='';
        creditWrapper.DPDValue='';
        creditWrapper.LastStatementBalance='';
        
        LeadDedupeWrapper.CustomerListWrapper customerList = new LeadDedupeWrapper.CustomerListWrapper();
        customerList.strCustomerName='';
        customerList.strCustomerID='';
        customerList.strGender='';
        customerList.strAadhaar='';
        customerList.strPAN='';
        customerList.strMobile='';
        customerList.strBlockStatus='';
        customerList.strNPAStatus='';
        customerList.strCustomerType='';
        customerList.strInputCustomerType='';
        customerList.boolIsCopyDisabled=false;
        customerList.boolIsInputApplicantIndividual=false;
        
        LeadDedupeWrapper.CustomerDetailWrapper customerDetailWrapper = new LeadDedupeWrapper.CustomerDetailWrapper();
        customerDetailWrapper.strCustomerName='';
        customerDetailWrapper.strCustomerID='';
        customerDetailWrapper.strAadhaar='';
        customerDetailWrapper.strPAN='';
        customerDetailWrapper.strPrefix='';
        customerDetailWrapper.strFirstName='';
        customerDetailWrapper.strMiddleName='';
        customerDetailWrapper.strLastName='';
        customerDetailWrapper.strShortName='';
        customerDetailWrapper.strCustomerType='';
        customerDetailWrapper.strConstitutionType='';
        customerDetailWrapper.strSex='';
        customerDetailWrapper.strMobileNumber='';
        customerDetailWrapper.strAddressLine1='';
        customerDetailWrapper.strAddressLine2='';
        customerDetailWrapper.strAddressLine3='';
        customerDetailWrapper.strCity='';
        customerDetailWrapper.strState='';
        customerDetailWrapper.strCountry='';
        customerDetailWrapper.strPincode='';
        customerDetailWrapper.strDOB='';
        customerDetailWrapper.strEmailID='';
        customerDetailWrapper.strBankShortName='';
        customerDetailWrapper.strInputCustomerType='';
        customerDetailWrapper.boolIsSignatureAvailable=false;
        customerDetailWrapper.boolIsImageAvailable=false;
        customerDetailWrapper.boolIsKYCDone=false;
        customerDetailWrapper.boolIsFullMatch=false;
        customerDetailWrapper.boolIsInputApplicantIndividual=false;
        customerDetailWrapper.boolIsCopyDisabled=false;
        customerDetailWrapper.lstAccountWrapper=null;
        
        LeadDedupeWrapper.AccountWrapper accountWrapper = new LeadDedupeWrapper.AccountWrapper();
        accountWrapper.strLoanTitle='';
        accountWrapper.strLoanNumber='';
        accountWrapper.strProduuct='';
        accountWrapper.strBranchName='';
        accountWrapper.strCustomerRelationship='';
        accountWrapper.strCurrentStatus='';
        accountWrapper.strLoanAmount='';
        accountWrapper.strTenureMonth='';
        accountWrapper.strAccountOpeningDate='';
        accountWrapper.strMaturityDate='';
        accountWrapper.strNoofEmiPaid='';
        accountWrapper.strTotalOutstanding='';
        accountWrapper.strEMIAmount='';
        accountWrapper.strROI='';
        accountWrapper.strPOS='';
        accountWrapper.strODLimitSactioned='';
        accountWrapper.strODLimitUtilized='';
        accountWrapper.strProductCode='';
        accountWrapper.strLoanAccountName='';
        accountWrapper.strTotalNoOfInstallmentsReceived='';
        accountWrapper.strEmiTenure='';
        accountWrapper.strInstallmentsOverDue='';
        accountWrapper.strCASAAccountName='';
        accountWrapper.strAvailableBalance='';
        accountWrapper.strCASARelationShipDetails='';
        accountWrapper.boolIsODCCAccount=false;
        accountWrapper.boolIsLoanAccount=false;
        accountWrapper.boolIsCASAAccount=false;
        accountWrapper.boolIsFDRDAccount=false;
        accountWrapper.boolIsCCAccount=false;
        
        
        
    }
    @IsTest
    static void testCustomerDetailWrapperProperties() {
        // Create test data
        LeadDedupeWrapper.CustomerDetailWrapper wrapper = new LeadDedupeWrapper.CustomerDetailWrapper();
        
        // Set property values
        wrapper.strCustomerName = 'John Doe';
        wrapper.strCustomerID = '123456';
        wrapper.strAadhaar = '1234-5678-9012';
        wrapper.strPAN = 'ABCDE1234F';
        wrapper.strPrefix = 'Mr.';
        wrapper.strFirstName = 'John';
        wrapper.strMiddleName = 'William';
        wrapper.strLastName = 'Doe';
        wrapper.strShortName = 'J. Doe';
        wrapper.strCustomerType = 'Individual';
        wrapper.strConstitutionType = 'Sole Proprietorship';
        wrapper.strSex = 'Male';
        wrapper.strMobileNumber = '1234567890';
        wrapper.strAddressLine1 = '123 Main Street';
        wrapper.strAddressLine2 = 'Apt 4B';
        wrapper.strAddressLine3 = 'Building C';
        wrapper.strCity = 'New York';
        wrapper.strState = 'NY';
        wrapper.strCountry = 'United States';
        wrapper.strPincode = '12345';
        wrapper.strDOB = '1990-01-01';
        wrapper.strEmailID = 'john.doe@example.com';
        wrapper.strBankShortName = 'ABC Bank';
        wrapper.strInputCustomerType = 'Retail';
        wrapper.boolIsSignatureAvailable = true;
        wrapper.boolIsImageAvailable = true;
        wrapper.boolIsKYCDone = true;
        wrapper.boolIsFullMatch = true;
        wrapper.boolIsInputApplicantIndividual = true;
        wrapper.boolIsCopyDisabled = false;

        // Verify property values
        System.assertEquals('John Doe', wrapper.strCustomerName, 'strCustomerName should be set correctly');
        System.assertEquals('123456', wrapper.strCustomerID, 'strCustomerID should be set correctly');
        System.assertEquals('1234-5678-9012', wrapper.strAadhaar, 'strAadhaar should be set correctly');
        System.assertEquals('ABCDE1234F', wrapper.strPAN, 'strPAN should be set correctly');
        System.assertEquals('Mr.', wrapper.strPrefix, 'strPrefix should be set correctly');
        System.assertEquals('John', wrapper.strFirstName, 'strFirstName should be set correctly');
        System.assertEquals('William', wrapper.strMiddleName, 'strMiddleName should be set correctly');
        System.assertEquals('Doe', wrapper.strLastName, 'strLastName should be set correctly');
        System.assertEquals('J. Doe', wrapper.strShortName, 'strShortName should be set correctly');
        System.assertEquals('Individual', wrapper.strCustomerType, 'strCustomerType should be set correctly');
        System.assertEquals('Sole Proprietorship', wrapper.strConstitutionType, 'strConstitutionType should be set correctly');
        System.assertEquals('Male', wrapper.strSex, 'strSex should be set correctly');
        System.assertEquals('1234567890', wrapper.strMobileNumber, 'strMobileNumber should be set correctly');
        System.assertEquals('123 Main Street', wrapper.strAddressLine1, 'strAddressLine1 should be set correctly');
        System.assertEquals('Apt 4B', wrapper.strAddressLine2, 'strAddressLine2 should be set correctly');
        System.assertEquals('Building C', wrapper.strAddressLine3, 'strAddressLine3 should be set correctly');
        System.assertEquals('New York', wrapper.strCity, 'strCity should be set correctly');
        System.assertEquals('NY', wrapper.strState, 'strState should be set correctly');
        System.assertEquals('United States', wrapper.strCountry, 'strCountry should be set correctly');
        System.assertEquals('12345', wrapper.strPincode, 'strPincode should be set correctly');
        System.assertEquals('1990-01-01', wrapper.strDOB, 'strDOB should be set correctly');
        System.assertEquals('john.doe@example.com', wrapper.strEmailID, 'strEmailID should be set correctly');
        System.assertEquals('ABC Bank', wrapper.strBankShortName, 'strBankShortName should be set correctly');
        System.assertEquals('Retail', wrapper.strInputCustomerType, 'strInputCustomerType should be set correctly');
        System.assertEquals(true, wrapper.boolIsSignatureAvailable, 'boolIsSignatureAvailable should be set correctly');
        System.assertEquals(true, wrapper.boolIsImageAvailable, 'boolIsImageAvailable should be set correctly');
        System.assertEquals(true, wrapper.boolIsKYCDone, 'boolIsKYCDone should be set correctly');
        System.assertEquals(true, wrapper.boolIsFullMatch, 'boolIsFullMatch should be set correctly');
        System.assertEquals(true, wrapper.boolIsInputApplicantIndividual, 'boolIsInputApplicantIndividual should be set correctly');
        System.assertEquals(false, wrapper.boolIsCopyDisabled, 'boolIsCopyDisabled should be set correctly');
    }
}