public class LosCibilResponseWrapper {
    //public cls_ContextData ContextData;
    
    public cls_TransactionStatus TransactionStatus;	
    public cls_DCResponse DCResponse;	
    public class cls_TransactionStatus {	
        public String ResponseCode;	//0	
        public String ResponseMessage;	//Success	
        public cls_ExtendedErrorDetails ExtendedErrorDetails;	
    }	
    public class cls_ExtendedErrorDetails {	
        public cls_messages[] messages;	
    }	
    public class cls_messages {	
        public String code;	//0	
        public String message;	//Success	
    }	
    public class cls_DCResponse {	
        public String Status;	//Success	
        public cls_Authentication Authentication;	
        public cls_ResponseInfo ResponseInfo;	
        public cls_ContextData ContextData;	
    }	
    public class cls_Authentication {	
        public String Status;	//Success	
        public String Token;	//b9c2618f-bb60-4a17-bf5e-5dca94d5c31e	
    }	
    public class cls_ResponseInfo {	
        public String ApplicationId;	//34471202	
        public String SolutionSetInstanceId;	//b33530ab-c1b5-4ecb-9b1b-27d579a014f8	
    }
    
    public class cls_ContextData {
        public cls_Field[] Field;
        public cls_Applicants Applicants;
    }
    public class cls_Field {
        public String key;	//Applicants
        public cls_Applicants Applicants;
    }
    public class cls_Applicants {
        public cls_Applicant Applicant;
    }
    public class cls_Applicant {
        public cls_Accounts[] Accounts;
        public cls_Addresses Addresses;
        public cls_Telephones Telephones;
        public cls_Identifiers Identifiers;
        public String CompanyName;	//
        public String EmailAddress;	//
        public String Gender;	//2
        public String DateOfBirth;	//17111989
        public String ApplicantLastName;	//PATIL
        public String ApplicantMiddleName;	//KUMAR
        public String ApplicantFirstName;	//KIRAN
        public String ApplicantType;	//Main
        public cls_DsCibilBureau DsCibilBureau;
    }
    public class cls_Accounts {
        public cls_Account Account;
    }
    public class cls_Account {
        public String Length;	//04
        public String SegmentTag;	//T001
        public cls_Account_Summary_Segment_Fields[] Account_Summary_Segment_Fields;
        public cls_Account_NonSummary_Segment_Fields[] Account_NonSummary_Segment_Fields;
    }
    public class cls_Addresses {
        public cls_Address[] Address;
    }
    public class cls_Address {
        public String AddressSegmentTag;	//PA
        public String Length;	//03
        public String SegmentTag;	//A01
        public String AddressLine1FieldLength;	//20
        public String AddressLine1;	//GEETHA RESIDENCY GEETHA RESIDENCY KALAMB
        public String AddressLine2;
        public String AddressLine3;
        public String StateCode;	//27
        public String PinCodeFieldLength;	//06
        public String PinCode;	//413510
        public String AddressCategory;	//02
        public String DateReported;	//30112019
        public String EnrichedThroughEnquiry ;	//Y
    }
    public class cls_Telephones {
        public cls_Telephone[] Telephone;
    }
    public class cls_Telephone {
        public String TelephoneNumber;	//9686316324
        public String TelephoneExtension;	//
        public String TelephoneType;	//01
    }
    public class cls_Identifiers {
        public cls_Identifier[] Identifier;
    }
    public class cls_Identifier {
        public String IdType;	//04
        public String IdNumber;	//MH2520190005972
    }
    public class cls_DsCibilBureau {
        public cls_DsCibilBureauData DsCibilBureauData;
        public cls_DsCibilBureauStatus DsCibilBureauStatus;
        public cls_Response Response;
    }
    public class cls_DsCibilBureauData {
        public cls_Request Request;
    }
    public class cls_Request {
        public cls_Request Request;
        public cls_ConsumerDetails ConsumerDetails;
    }
    public class cls_ConsumerDetails {
        public cls_CreditReportInquiry CreditReportInquiry;
    }
    public class cls_CreditReportInquiry {
        public cls_Header Header;
        public cls_Names Names;
        public cls_Identifications Identifications;
        public cls_Telephones Telephones;
        public cls_Addresses Addresses;
    }
    public class cls_Header {
        public String SegmentTag;	//TUEF
        public String Version;	//12
        public String ReferenceNumber;	//47958179
        public String MemberCode;	//NB66057777_CIRC2CNPECV
        public String SubjectReturnCode;	//1
        public String EnquiryControlNumber;	//003510718234
        public String DateProcessed;	//19092020
        public String TimeProcessed;	//061608
    }
    public class cls_Names {
        public cls_Name[] Name;
    }
    public class cls_Name {
        public String ConsumerName1;	//KIRAN
        public String ConsumerName2;	//KUMAR
        public String ConsumerName3;	//PATIL
        public String ConsumerName4;	//
        public String ConsumerName5;	//
        public String DateOfBirth;	//17111989
        public String Gender;	//2
    }
    public class cls_Identifications {
        public cls_Identification[] Identification;
    }
    public class cls_Identification {
        public String PanNo;	//ASBPG1647I
        public String PassportNumber;	//
        public String DLNo;	//MH2520190005972
        public String VoterId;	//KAN8027289
        public String UId;	//
        public String RationCardNo;	//
        public String AdditionalID1;	//
        public String AdditionalID2;	//
    }
    public class cls_DsCibilBureauStatus {
        public String Trail;	//
    }
    public class cls_Response {
        public cls_CibilBureauResponse CibilBureauResponse;
    }
    public class cls_CibilBureauResponse {
        public String BureauResponseRaw;	//TUEF1247958179 0000NB66057777_CIRC2CNPECV 100351071823419092020061608PN03N010122KIRAN KUMAR PATIL07081711198908012ID03I010102010210ASBPG1647IID03I020102030210KAN80272899001YPT03T0101109686316324030201EC03C010122KKPATIL@GMAIL.COMEM03E01010212020831072020030204PA03A010120GEETHA RESIDENCY GEETHA RESIDENCY KALAMB0602270706413510080202100830112019PA03A020140CUSTOMERADDRESS A/P GEETHA RESIDENCY,TQ-KALAMB,OSM0234,A/P GEETHA RESIDENCY,TQ-KALAMB,LATUR, ,0309LATUR06022707064135100802021008181020199001YPA03A030140S/O KUMAR PATIL GEETHA RESIDENCY N/R DATTA MANDI0216R GEETHA RESIDENCY GEETHA RESIDENCY0505MURUD0602270706413510080202100806102019TL04T0010213NOT DISCLOSED040206050110808170820201108170820201205179901305119902803000300801082020310801082020TL04T0020213NOT DISCLOSED04020605011080831012020090802072020110831072020120515990130463962818000000000000000000300801072020310801022020TL04T0030213NOT DISCLOSED04021205011080811112019090817072020110831072020120628000013062789562827000000000030000000000000000300801072020310801112019TL04T0040213NOT DISCLOSED04021205011080811112019090821052020110831072020120616500013061649062827000000000030000000000000000300801072020310801112019TL04T0050213NOT DISCLOSED04020605011080807102019090802052020110831072020120510990130102830000000000000000000000000000000300801072020310801102019IQ04I0010108160920200415SBM INVST FIN0502010606400000IQ04I0020108150620200413NOT DISCLOSED0502530606445728IQ04I0030108310120200413NOT DISCLOSED050206060528980IQ04I0040108071120190413NOT DISCLOSED0502530606465000IQ04I0050108181020190413NOT DISCLOSED0502530606255000IQ04I0060108061020190413NOT DISCLOSED050206060528980ES0700016310102**
        public cls_BureauResponseXml BureauResponseXml;
        public cls_SecondaryReportXml SecondaryReportXml;
        public String IsSucess;	//True
    }
    public class cls_BureauResponseXml {
        public cls_FailureResponse FailureResponse;
		public cls_SucessResponse SucessResponse;
	}
	public class cls_FailureResponse {
		public String Status;	//CR
		public String ErrorCode;	//100
		public String ErrorDescription;	//Your request has been rejected by the Credit Bureau server.Please make the appropriate change and resubmit the request or contact the system administrator.
		public String Segment;	//Invalid Enquiry Purpose.
	}
    public class cls_SucessResponse {
        public cls_Header[] Header;
        public cls_NameSegment[] NameSegment;
        public cls_IDSegment[] IDSegment;
        public cls_TelephoneSegment[] TelephoneSegment;
        public cls_EmailContactSegment[] EmailContactSegment;
        public cls_EmploymentSegment[] EmploymentSegment;
        public cls_ScoreSegment[] ScoreSegment;
        public cls_Address[] Address;
        public cls_Account[] Account;
        public cls_Enquiry[] Enquiry;
        public cls_End EndVar; //End
	}
    public class cls_SecondaryReportXml {
		public cls_CreditReport CreditReport;
	}
    public class cls_CreditReport {
        public cls_Header Header;
        public cls_NameSegment NameSegment;
        public cls_IDSegment[] IDSegment;
        public cls_TelephoneSegment[] TelephoneSegment;
        public cls_EmailContactSegment[] EmailContactSegment;
        public cls_Address[] Address;
        public cls_End EndVar; //End
    }
    public class cls_NameSegment {
        public String Length;	//03
        public String SegmentTag;	//N01
        public String ConsumerName1FieldLength;	//22
        public String ConsumerName1;	//KIRAN KUMAR PATIL
		public String ConsumerName2FieldLength;	//07
		public String ConsumerName2;	//SOLANKI
		public String ConsumerName3FieldLength;	//10
		public String ConsumerName3;	//VINOD BHAI
        public String DateOfBirthFieldLength;	//08
        public String DateOfBirth;	//17111989
        public String GenderFieldLength;	//01
        public String Gender;	//2
    }
    public class cls_IDSegment {
        public String Length;	//03
        public String SegmentTag;	//I01
        public String IDType;	//01
        public String IDNumberFieldLength;	//10
        public String IDNumber;	//ASBPG1647I
    }
    public class cls_TelephoneSegment {
        public String Length;	//03
        public String SegmentTag;	//T01
        public String TelephoneNumberFieldLength;	//10
        public String TelephoneNumber;	//9686316324
        public String TelephoneType;	//01
    }
    public class cls_EmailContactSegment {
        public String Length;	//03
        public String SegmentTag;	//C01
        public String EmailIDFieldLength;	//22
        public String EmailID;	//KKPATIL@GMAIL.COM
    }
    public class cls_EmploymentSegment {
        public String Length;	//03
        public String SegmentTag;	//E01
        public String AccountType;	//12
        public String DateReportedCertified;	//31072020
        public String OccupationCode;	//04
    }
    public class cls_ScoreSegment {
        public String Length;	//10
        public String ScoreName;	//CIBILTUSC3
        public String ScoreCardName;	//08
        public String ScoreCardVersion;	//10
        public String ScoreDate;	//25092019
        public String Score;	//00727
        public String ReasonCode1FieldLength;	//02
        public String ReasonCode1;	//35
        public String ReasonCode2FieldLength;	//02
        public String ReasonCode2;	//42
        public String ReasonCode3FieldLength;	//02
        public String ReasonCode3;	//41
        public String ReasonCode4FieldLength;	//02
        public String ReasonCode4;	//39
        public String ReasonCode5FieldLength;	//02
        public String ReasonCode5;	//26
    }
    public class cls_Account_Summary_Segment_Fields {
        public String ReportingMemberShortNameFieldLength;	//13
    }
    public class cls_Account_NonSummary_Segment_Fields {
        public String ReportingMemberShortNameFieldLength;	//13
		public String ReportingMemberShortName;	//NOT DISCLOSED
		public String AccountType;	//7
		public String OwenershipIndicator;	//1
		public String DateOpenedOrDisbursed;	//5112020
		public String DateOfLastPayment;	//21122021
		public String DateClosed;	//21122021
		public String DateReportedAndCertified;	//31122021
		public String HighCreditOrSanctionedAmountFieldLength;	//5
		public String HighCreditOrSanctionedAmount;	//75300
		public String CurrentBalanceFieldLength;	//1
		public String CurrentBalance;	//0
		public String PaymentHistory1FieldLength;	//6
		public String PaymentHistory1;	//0
        public String PaymentHistory2;
        public String PaymentHistoryStartDate;	//1122021
		public String PaymentHistoryEndDate;	//1112021
		public String ValueOfCollateralFieldLength;	//5
		public String ValueOfCollateral;	//75300
		public String TypeOfCollateralFieldLength;	//2
		public String TypeOfCollateral;	//2
		public String RateOfInterestFieldLength;	//5
		public String RateOfInterest;	//26
		public String RepaymentTenureFieldLength;	//2
		public String RepaymentTenure;	//12
		public String ActualPaymentAmountFieldLength;	//5
		public String ActualPaymentAmount;	//75300
        public String EmiAmount;
        public String AmountOverdue;
        public String SuitFiledOrWilfulDefault;
        public String WrittenOffAndSettled;
        public String PaymentFrequency ;
         
    }
    public class cls_Enquiry {
        public String Length;	//04
        public String SegmentTag;	//I001
        public String DateOfEnquiryFields;	//16092020
        public String EnquiringMemberShortNameFieldLength;	//15
        public String EnquiringMemberShortName;	//SBM INVST FIN
        public String EnquiryPurpose;	//01
        public String EnquiryAmountFieldLength;	//06
        public String EnquiryAmount;	//400000
    }
    public class cls_End {
        public String SegmentTag;	//ES07
        public String TotalLength;	//0001631
    }
    
    public static LosCibilResponseWrapper parse(String json){
        return (LosCibilResponseWrapper) System.JSON.deserialize(json, LosCibilResponseWrapper.class);
    }   
}