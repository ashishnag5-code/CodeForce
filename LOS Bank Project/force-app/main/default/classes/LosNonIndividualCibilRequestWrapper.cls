public class LosNonIndividualCibilRequestWrapper {

	public String RequestId;	//19283091820931
	public String OriginatingChannel;	//SFDC
	public RequestInfo RequestInfo;
	public String UserData;	//
	public Fields Fields;
	public String Key;	//
	public class RequestInfo {
		public Integer SolutionSetId;	//440
		public Integer SolutionSetVersion;	//1
		public String ExecutionMode;	//NewWithContext
		public Integer EnvironmentId;	//1
	}
	public class Fields {
		public Field Field;
	}
	public class Field {
		public Applicants Applicants;
		public ApplicationData ApplicationData;
	}
	public class Applicants {
		public Applicant Applicant;
	}
	public class Applicant {
		public String ApplicantType;	//CO-OPERATIVE SOCIETY
		public String PAN;	//AACAS5144C
		public String CIN;	//
		public String CompanyName;	//SARVODAY SIKSAN SANSTHAN
		public String ClassOfActivity;	//HIGHER EDUCATION
		public String TypeOfEntity;	//CO-OPERATIVE SOCIETY
		public String DateOfRegistration;	//25-Sep-2001
		public RegisteredAddress RegisteredAddress;
		public String MemberReferenceNumber;	//BusinessBanking
		public String FacilityCategory;	//Overdraft
		public String FacilityType;	//NEW LOAN
	}

	/*public class Telephone {
		public String TelephoneType;	
		public String TelephoneNum;	
	}*/
	
	public class RegisteredAddress {
		public String AddressType;	//REGISTERED OFFICE
		public String AddressLine1;	//DIDWANA ROAD, CHENAR, NAGAUR
		public String AddressLine2;	//
		public String AddressLine3;	//
		public String AddressCity;	//NAGAUR
		public String AddressStateCode;	//08
		public Integer AddressPincode;	//341001
		//public Telephone Telephone;
	}
    
	public class ApplicationData {
		public String LitigationReport;	//False
		public boolean CommercialCIR;
		public boolean ConsumerCIR;
		public Integer NoOfDirector;	//4
		public boolean FormattedReport;
		public String GSTStateCode;	//08
		public Integer Amount;	//1000000
		public String MemberReferenceNumber;	//Wheels
	}
	public static LosNonIndividualCibilRequestWrapper parse(String json){
		return (LosNonIndividualCibilRequestWrapper) System.JSON.deserialize(json, LosNonIndividualCibilRequestWrapper.class);
	}

	
}