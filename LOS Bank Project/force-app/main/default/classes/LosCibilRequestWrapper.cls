public class LosCibilRequestWrapper {
    
    public class Account {
        public Object AccountNumber;
    }
    
    public class Identifier {
        public String IdNumber;
        public String IdType;
    }
    
    public String RequestId;
    public String OriginatingChannel;
    public RequestInfo RequestInfo;
    public ApplicationData ApplicationData;
    public Applicant Applicant;
    
    public class Telephone {
        public Object TelephoneNumber;
        public String TelephoneType;
    }
    
    public class Address {
        public String AddressLine1;
        public String AddressLine2;
        public String AddressLine3;
        public Object AddressLine4;
        public Object AddressLine5;
        public String AddressType;
        public String City;
        public String PinCode;
        public Object ResidenceType;
        public String StateCode;
    }
    
    public class Telephones {
        public List<Telephone> Telephone;
    }
    
    public class ApplicationData {
        public String Purpose;
        public String Amount;
        public String ScoreType;
        public String GSTStateCode;
        public String CibilBureauFlag;
        public String DSTuNtcFlag;
        public String IDVerificationFlag;
        public String MFIBureauFlag;
        public String NTCProductType;
        public String ConsumerConsentForUIDAIAuthentication;
        public Object MFIEnquiryAmount;
        public Object MFILoanPurpose;
        public Object MFICenterReferenceNo;
        public Object MFIBranchReferenceNo;
        public String FormattedReport;
    }
    
    public class RequestInfo {
        public String ExecutionMode;
        public String SolutionSetId;
        public String SolutionSetVersion;
    }
    
    public class Identifiers {
        public List<Identifier> Identifier;
    }
    
    public class Applicant {
        public String ApplicantType;
        public String ApplicantFirstName;
        public Object ApplicantMiddleName;
        public String ApplicantLastName;
        public String DateOfBirth;
        public String Gender;
        public Object EmailAddress;
        public Object CompanyName;
        public Identifiers Identifiers;
        public Telephones Telephones;
        public List<Address> Address;
        public Object PersonRelation;
        public Object PersonName;
        public Object MemberRelationType4;
        public Object MemberRelationName4;
        public Object MemberRelationType3;
        public Object MemberRelationName3;
        public Object MemberRelationType2;
        public Object MemberRelationName2;
        public Object MemberRelationType1;
        public Object MemberRelationName1;
        public Object NomineeRelation;
        public Object NomineeName;
        public Object KeyPersonRelation;
        public Object KeyPersonName;
        public Object MemberOtherId4;
        public Object MemberOtherId4Type;
        public Object MemberOtherId3;
        public Object MemberOtherId3Type;
        public Object MemberOtherId2;
        public Object MemberOtherId2Type;
        public Object MemberOtherId1;
        public Object MemberOtherId1Type;
        public Accounts Accounts;
        public String FinalTraceLevel;
    }
    
    public class Accounts {
        public Account Account;
    }
    
    public class cls_Cibil_report{
        public string RequestId;
        public string OriginatingChannel;
        public string ApplicationId;
    }
    
    public static LosCibilRequestWrapper parse(String json) {
        return (LosCibilRequestWrapper) System.JSON.deserialize(json, LosCibilRequestWrapper.class);
    }
    
    
}