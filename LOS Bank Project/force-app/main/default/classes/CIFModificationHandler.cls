/*****
 * Class Name: CIFModificationHandler
 * Description: CIFCreationControllerTest
 * Test Class Name: 
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Nov-08-2023          -   Mohit Maheshwari    -   SFAU-5534 - NationalIdentificationCode
 * Nov-17-2023          -   Mohit M.            -   SFAU-5592 - CIF Modification API  - PAN not to be passed in API if received from CBS
 * Dec-01-2023          -   Mohit M.            -   SFAU-5485 - Title needs to be blank in CIFModification API
 * Dec-05-2023          -   Mohit M.            -   SFAU-5698 - (Name, MobileNumber, DrivingLicense, DateOfBirth, VoterId, PassportNumber) In case of CIF Modification only Address, KYC & Customer Profiling should be update but now updating other details also.
 */
public with sharing class CIFModificationHandler implements IntegrationHandlerInterface{
    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,String> paramsMap=(Map<String,String>)reqParam;
        String recordId = paramsMap.get('ApplicantId');

        List<Applicant__c> applicantList = [SELECT Id, Name, Mother_Name__c, Constitution_Type__c, Email__c, Pan_Form60__c, Aadhaar_Seeding__c, Education_Qualification__c, IsEmailVerified__c, loan__r.Branch_Master__r.Account_Code__c, Dob__c, Customer_Type__c,
        Gender__c, Marital_Status__c, Mobile_Number__c, Aadhaar_Number__c, AU_Employee__c, PAN__c, CBS_PAN__c, (SELECT Id, Name, Pincode__c, State__c,
        City__c, Address_Line_1__c, Address_Line_2__c, Address_Line_3__c, Address_Type__c FROM Addresses__r WHERE Address_Type__c in ('Permanent','Current','Office') AND
        Source_Type__c=null Order By CreatedDate Desc), 
        (SELECT Id, isActive__c, Sector__c, Industry__c, Sub_Industry__c, Occupation__c, Type_Of_Employment__c FROM Applicant_Financials__r WHERE RecordType.DeveloperName='Financial_Parent' AND isActive__c=true Order By CreatedDate Desc),
        First_Name__c, Middle_Name__c, Last_Name__c, Title__c, CIF_No__c,
        Passport_Number__c, Voter_Id__c, Driving_License_Id__c FROM
        Applicant__c WHERE id=:recordId AND IsInactive__c=false];

        Applicant__c applicant;
        if(applicantList!=null && applicantList.size()>0){
            applicant=applicantList[0];
        }
        
        CIFModificationApiRequestWrapper cifApiRequestWrapper = new CIFModificationApiRequestWrapper();
        List<Title_Master__mdt> titleMaster = Title_Master__mdt.getAll().values();
        Map<String, Title_Master__mdt> titleMasterMap = new Map<String, Title_Master__mdt>();
        for(Title_Master__mdt title : titleMaster){
            titleMasterMap.put(title.MasterLabel, title);
        }

        
        cifApiRequestWrapper.RequestId = IntegrationUtility.getReferenceId();
        cifApiRequestWrapper.Channel = paramsMap.get('Channel');//'SFDC';
        cifApiRequestWrapper.TransactionBranch = applicant.loan__r.Branch_Master__r.Account_Code__c;
        cifApiRequestWrapper.ReferenceNumber = cifApiRequestWrapper.RequestId;

        Applicant_Financials_Details__c applicantParentFinancial = applicant.Applicant_Financials__r!=null && applicant.Applicant_Financials__r.size()>0?applicant.Applicant_Financials__r:new Applicant_Financials_Details__c();
        List<Profiling_Master__c> profilingMasterRecords = new List<Profiling_Master__c>();   
        profilingMasterRecords = [SELECT Name,Code__c,Sector__c, Sector__r.Code__c, Industry__c, Industry__r.Code__c,
        Sub_Industry__c, Sub_Industry__r.Code__c, Occupation__c, Occupation__r.Code__c, Employment_Type__c, 
        Employment_Type__r.Code__c 
        FROM Profiling_Master__c WHERE 
        Sector__r.Name =:applicantParentFinancial.Sector__c AND Industry__r.Name=:applicantParentFinancial.Industry__c 
        AND Sub_Industry__r.Name =:applicantParentFinancial.Sub_Industry__c AND 
        Occupation__r.Name =:applicantParentFinancial.Occupation__c AND Name=:applicantParentFinancial.Type_Of_Employment__c];

        CustomerProfilingDetailsWrapper customerProfilingDetails= new CustomerProfilingDetailsWrapper();
        Profiling_Master__c profilingMasterRecord = new Profiling_Master__c();   
        if(profilingMasterRecords!=null && profilingMasterRecords.size()>0){
            profilingMasterRecord=profilingMasterRecords[0];
            customerProfilingDetails.Activity = profilingMasterRecord.Occupation__c!=null?String.valueOf(profilingMasterRecord.Occupation__r.Code__c):'';
            customerProfilingDetails.BusinessProfiler = 'Y';
            customerProfilingDetails.CustCategory = profilingMasterRecord.Code__c!=null?String.valueOf(profilingMasterRecord.Code__c):'';
            customerProfilingDetails.IncomeProfiler = 'N';
            customerProfilingDetails.Industry = profilingMasterRecord.Industry__c!=null?String.valueOf(profilingMasterRecord.Industry__r.Code__c):'';
            customerProfilingDetails.Sector = profilingMasterRecord.Sector__r!=null?String.valueOf(profilingMasterRecord.Sector__r.Code__c):'';
            customerProfilingDetails.SubIndustry = profilingMasterRecord.Sub_Industry__c!=null?String.valueOf(profilingMasterRecord.Sub_Industry__r.Code__c):'';
        }
        else{
            customerProfilingDetails.BusinessProfiler = 'Y';
            customerProfilingDetails.IncomeProfiler = 'N';
        }

        cifApiRequestWrapper.CustomerProfilingDetails = customerProfilingDetails;
        /*ReportingParamWrapper reportingWrapper = new ReportingParamWrapper();
        reportingWrapper.MISClass = 'DIVISION';
        reportingWrapper.MISCode = '0';

        cifApiRequestWrapper.ReportingParam = reportingWrapper;*/

        if(applicant.Customer_Type__c == 'Individual'){
            IndividualCustomerWrapper newIndCustWrapper = new IndividualCustomerWrapper();
            if(applicant.Addresses__r!=null && applicant.Addresses__r.size()>0){
                for(Address__c address : applicant.Addresses__r){
                    AddressWrapper newAddressWrapper = new AddressWrapper();
                    newAddressWrapper.Zip = address.Pincode__c!=null?address.Pincode__c:'';
                    newAddressWrapper.State = address.State__c!=null?address.State__c.toUpperCase():'';
                    newAddressWrapper.Country = 'IN';
                    newAddressWrapper.City = address.City__c!=null?address.City__c.toUpperCase():'';
                    address.Address_Line_1__c = address.Address_Line_1__c!=null?address.Address_Line_1__c:'';
                    address.Address_Line_2__c = address.Address_Line_2__c!=null?address.Address_Line_2__c:'';
                    address.Address_Line_3__c = address.Address_Line_3__c!=null?address.Address_Line_3__c:'';
                    String addressSplit = address.Address_Line_1__c+address.Address_Line_2__c+address.Address_Line_3__c;
                    if(addressSplit.length()>30){
                        newAddressWrapper.Line1 = addressSplit.subString(0,29);
                        if(addressSplit.subString(29,addressSplit.length()).length()>30){
                            newAddressWrapper.Line2 = addressSplit.subString(29,59);
                            if(addressSplit.subString(59,addressSplit.length()).length()>30){
                                newAddressWrapper.Line3 = addressSplit.subString(59,89);
                            }else{
                                newAddressWrapper.Line3 = addressSplit.subString(59,addressSplit.length());
                            }
                        }else{
                            newAddressWrapper.Line2 = addressSplit.subString(29,addressSplit.length());
                            newAddressWrapper.Line3='';
                        }
                    }else{
                        newAddressWrapper.Line1 = addressSplit.subString(0,addressSplit.length());
                        newAddressWrapper.Line2='';
                        newAddressWrapper.Line3='';
                    }
                    /*newAddressWrapper.Line1 = address.Address_Line_1__c;
                    newAddressWrapper.Line2 = address.Address_Line_2__c;
                    newAddressWrapper.Line3 = address.Address_Line_3__c;*/
                    if(address.Address_Type__c == 'Permanent'){
                        newIndCustWrapper.Address = newAddressWrapper;
                    }
                    if(address.Address_Type__c == 'Current'){
                        newIndCustWrapper.MailingAddress = newAddressWrapper;
                    }
                }
            }
                // SFAU-5698 - Commented newIndCustWrapper.MobileNumber = applicant.Mobile_Number__c;
                /* SFAU-5698
                NameWrapper newNameWrapper = new NameWrapper();
                newNameWrapper.FirstName = applicant.First_Name__c!=null?applicant.First_Name__c:'';
                newNameWrapper.FormattedFullName = (applicant.First_Name__c!=null?applicant.First_Name__c+' ':'')+(applicant.Middle_Name__c!=null?applicant.Middle_Name__c+' ':'')+(applicant.Last_Name__c!=null?applicant.Last_Name__c:'');
                SFAU-5698 */

                /*if(applicant.Middle_Name__c!=null && applicant.Middle_Name__c!=''){
                    newNameWrapper.FormattedFullName = applicant.First_Name__c+' '+applicant.Middle_Name__c+' '+applicant.Last_Name__c;
                }else{
                    newNameWrapper.FormattedFullName = applicant.First_Name__c+' '+applicant.Last_Name__c;
                }*/
                //newNameWrapper.ShortName = applicant.First_Name__c;
                /* SFAU-5698
                if(applicant.First_Name__c==null){
                    newNameWrapper.ShortName = '';
                }else if(applicant.First_Name__c.length()>20){
                    newNameWrapper.ShortName = applicant.First_Name__c.left(20);
                }else{
                    newNameWrapper.ShortName = applicant.First_Name__c;
                }
                SFAU-5698 */
                // SFAU-5485 Start - Kunal 
                // SFAU-5485 Start - Mohit M. Dec-01-2023
                //newNameWrapper.Prefix = ''; // should be blank as per discussed with Shashank titleMasterMap.get(applicant.Title__c)!=null?titleMasterMap.get(applicant.Title__c).CBS_Title__c:'';//applicant.Title__c+'.';
                // SFAU-5485 End - Kunal 
                /* SFAU-5698
                newNameWrapper.LastName = applicant.Last_Name__c!=null?applicant.Last_Name__c:'';
                newNameWrapper.MiddleName = applicant.Middle_Name__c!=null?applicant.Middle_Name__c:'';
                // SFAU-5698 - Commented - newIndCustWrapper.Name = newNameWrapper;
                SFAU-5698 */
                //newIndCustWrapper.CountryOfResidence = 'IN';
                newIndCustWrapper.CustomerId = String.valueOf(applicant.CIF_No__c);
                newIndCustWrapper.EmailId = applicant.IsEmailVerified__c?applicant.Email__c:'';
                /* Start - SFAU-5534 - Remove
                if(applicant.Aadhaar_Number__c!=null){
                    newIndCustWrapper.NationalIdentificationCode = String.valueOf(applicant.Aadhaar_Number__c);
                }else if(applicant.PAN__c!=null){
                    newIndCustWrapper.NationalIdentificationCode = applicant.PAN__c;
                }else{
                    newIndCustWrapper.NationalIdentificationCode = CIFCreationApiHandler.generateIdentificationCode(applicant.Id);
                }
                */
                newIndCustWrapper.InoperativePan='';
                if(applicant.Pan_Form60__c == 'Pan Card'){
                    if(applicant.Aadhaar_Seeding__c=='Y'){
                        newIndCustWrapper.InoperativePan = 'N';
                    }else if(applicant.Aadhaar_Seeding__c=='R'){
                        newIndCustWrapper.InoperativePan = 'Y';
                    }
                }
              
                // SFAU-5485 Start - Kunal AND SFAU-5592 - Mohit M.
                newIndCustWrapper.PAN = String.isNotBlank(applicant.CBS_PAN__c) ? '' : String.isNotBlank(applicant.PAN__c) ? applicant.PAN__c : '';
                // SFAU-5485 End - Kunal 
                // SFAU-5698 - Commented - newIndCustWrapper.DateOfBirth = String.valueOf(applicant.Dob__c);
                // SFAU-5698 - Commented - newIndCustWrapper.VoterId = applicant.Voter_Id__c;
                // SFAU-5698 - Commented - newIndCustWrapper.PassportNumber = applicant.Passport_Number__c;
                // SFAU-5698 - Commented - newIndCustWrapper.DrivingLicense = applicant.Driving_License_Id__c;
                //newIndCustWrapper.DateRegistered = '2017-01-31';
                cifApiRequestWrapper.IndividualCustomer = newIndCustWrapper;
        }

        if(applicant.Customer_Type__c == 'Non Individual'){
            CorporateCustomerWrapper newCorporateCustWrapper = new CorporateCustomerWrapper();
            if(applicant.Addresses__r!=null && applicant.Addresses__r.size()>0){
                for(Address__c address : applicant.Addresses__r){
                    Address__c currentAddress = address;
                    AddressWrapper newAddressWrapper = new AddressWrapper();
                    newAddressWrapper.Zip = currentAddress.Pincode__c!=null?currentAddress.Pincode__c:'';
                    newAddressWrapper.State = currentAddress.State__c!=null?currentAddress.State__c.toUpperCase():''; //currentAddress.State__c;
                    newAddressWrapper.Country = 'IN';
                    newAddressWrapper.City = currentAddress.City__c!=null?currentAddress.City__c.toUpperCase():'';
                    currentAddress.Address_Line_1__c = currentAddress.Address_Line_1__c!=null?currentAddress.Address_Line_1__c:'';
                    currentAddress.Address_Line_2__c = currentAddress.Address_Line_2__c!=null?currentAddress.Address_Line_2__c:'';
                    currentAddress.Address_Line_3__c = currentAddress.Address_Line_3__c!=null?currentAddress.Address_Line_3__c:'';
                    String addressSplit = currentAddress.Address_Line_1__c+currentAddress.Address_Line_2__c+currentAddress.Address_Line_3__c;
                    if(addressSplit.length()>30){
                        newAddressWrapper.Line1 = addressSplit.subString(0,29);
                        if(addressSplit.subString(29,addressSplit.length()).length()>30){
                            newAddressWrapper.Line2 = addressSplit.subString(29,59);
                            if(addressSplit.subString(59,addressSplit.length()).length()>30){
                                newAddressWrapper.Line3 = addressSplit.subString(59,89);
                            }else{
                                newAddressWrapper.Line3 = addressSplit.subString(59,addressSplit.length());
                            }
                        }else{
                            newAddressWrapper.Line2 = addressSplit.subString(29,addressSplit.length());
                            newAddressWrapper.Line3='';
                        }
                    }else{
                        newAddressWrapper.Line1 = addressSplit.subString(0,30);
                        newAddressWrapper.Line2='';
                        newAddressWrapper.Line3='';
                    }                   
                    if(currentAddress.Address_Type__c == 'Office'){
                        newCorporateCustWrapper.Address = newAddressWrapper;
                    }
                    if(currentAddress.Address_Type__c == 'Current'){
                        newCorporateCustWrapper.MailingAddress = newAddressWrapper;
                    }
                }
                /* Start - SFAU-5534 - Remove from Modification
                if(applicant.Aadhaar_Number__c!=null){
                    newCorporateCustWrapper.NationalIdentificationCode = String.valueOf(applicant.Aadhaar_Number__c);
                }else if(applicant.PAN__c!=null){
                    newCorporateCustWrapper.NationalIdentificationCode = applicant.PAN__c;
                }else{
                    newCorporateCustWrapper.NationalIdentificationCode = CIFCreationApiHandler.generateIdentificationCode(applicant.Id);
                }
                */
                newCorporateCustWrapper.InoperativePan='';
                newCorporateCustWrapper.EmailId = applicant.IsEmailVerified__c?applicant.Email__c:'';
                if(applicant.Constitution_Type__c == 'Sole Proprietary'){
                    if(applicant.Aadhaar_Seeding__c=='Y'){
                        newCorporateCustWrapper.InoperativePan = 'N';
                    }else if(applicant.Aadhaar_Seeding__c=='R'){
                        newCorporateCustWrapper.InoperativePan = 'Y';
                    }
                }
                newCorporateCustWrapper.MobileNumber = applicant.Mobile_Number__c;
                cifApiRequestWrapper.CorporateCustomer = newCorporateCustWrapper;
            }
        }
        lstString.add(JSON.serialize(cifApiRequestWrapper));   
        return lstString;
    }

    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    public class CIFModificationApiRequestWrapper{
        public String RequestId;
        public String Channel;
        public String TransactionBranch;
        public String ReferenceNumber;
        //public ReportingParamWrapper ReportingParam;
        public IndividualCustomerWrapper IndividualCustomer;
        public CorporateCustomerWrapper CorporateCustomer;
        public CustomerProfilingDetailsWrapper CustomerProfilingDetails;
        //public List<KYCDocumentDetailsWrapper> KYCDocumentDetails;
    }

    public class ReportingParamWrapper{
        public String MISClass;
        public String MISCode;
    }

    public class IndividualCustomerWrapper{
        public AddressWrapper Address;
        public AddressWrapper MailingAddress;
        //SFAU-5698 - Commented - public String MobileNumber;
        public String InoperativePan;
        //public String CountryOfResidence;
        public String CustomerId;
        //SFAU-5698 - Commented - public NameWrapper Name;
        public String EmailId;
        //public String Nationality;
        //Start - SFAU-5534 Remove NationalIdentificationCode
        //public String NationalIdentificationCode;
        //public String icType;
        //public String SignatureType;
        //public String Category;
        public String PAN;
        //SFAU-5698 - Commented - public String DateOfBirth;
        //SFAU-5698 - Commented - public String PassportNumber;
        //SFAU-5698 - Commented - public String VoterId;
        //SFAU-5698 - Commented - public String DrivingLicense;
        //public String DateRegistered;
    }

    public class CorporateCustomerWrapper{
        public AddressWrapper Address;
        public AddressWrapper MailingAddress;
        public String InoperativePan;
        public String MobileNumber;
        public String EmailId;
        // Start - SFAU-5534 - Remove NationalIdentificationCode
        // public String NationalIdentificationCode;
    }

    public class CustomerProfilingDetailsWrapper{
        public String Activity;
        public String BusinessProfiler;
        public String CustCategory;
        public String IncomeProfiler;
        public String Industry;
        public String Sector;
        public String SubIndustry;
    }

    /* SFAU-5698
    public class NameWrapper{
        public String FirstName;
        public String FormattedFullName;
        public String ShortName;
        // public String Prefix; // SFAU-5485
        public String LastName;
        public String MiddleName;
    }
    */

    public class KYCDocumentDetailsWrapper{
        public String DateProvided;
        public String DocumentCheck;
        public String DocumentIssueDate;
        public String DocumentName;
        public String DocumentStatusMode;
        public String DocumentType;
        public String DocumentValue;
        public String ExpiryDate;
        public String IssuingAuthority;
        public String PlaceOfIssue;
        public String PlanCode;
        public String ProvidedFlag;
        public String Source;
        public String VerifiedFlag;
    }

    public class AddressWrapper{
        public String Zip;
        public String State;
        public String Country;
        public String City;
        public String Line1;
        public String Line2;
        public String Line3;
        public String Line4;
    }

    public class CIFModificationApiResponseWrapper{
        @AuraEnabled public TransactionStatusWrapper TransactionStatus{get;set;}
        @AuraEnabled public String CustomerId{get;set;}
    }

    public class TransactionStatusWrapper{
        @AuraEnabled public String ResponseCode{get;set;}
        @AuraEnabled public String ResponseMessage{get;set;}
        @AuraEnabled public ExtendedErrorDetailsWrapper ExtendedErrorDetails{get;set;}
        @AuraEnabled public ValidationErrorsWrapper ValidationErrors{get;set;}
    }

    public class ExtendedErrorDetailsWrapper{
        @AuraEnabled public MessagesWrapper messages{get;set;}
    }
    

    public class MessagesWrapper{
        @AuraEnabled public String code{get;set;}
        @AuraEnabled public String message{get;set;}
    }

    public class ValidationErrorsWrapper{
        @AuraEnabled public String AttributeName{get;set;}
        @AuraEnabled public String AttributeValue{get;set;}
        @AuraEnabled public String ErrorCode{get;set;}
        @AuraEnabled public String ErrorMessage{get;set;}
    }
}