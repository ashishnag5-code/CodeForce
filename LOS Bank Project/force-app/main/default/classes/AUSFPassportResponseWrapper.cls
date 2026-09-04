public class AUSFPassportResponseWrapper {

    public class UIResponse{
        public PassPortResponse Response;
        public Object[] metadata;
        public Integer statusCode;
		public String errorMessage;
    }
    
    Public Class PassPortResponse {
         Public String nameFromPassport;
         Public String surnameFromPassport;
         Public String passportNumberFromSource;
         Public String dispatchedOnFromSource;
         Public String applicationDate;
    }
    
	public Result result;
	public String requestId;
	public Integer statusCode;

	public class DateOfIssue {
		public Boolean dateOfIssueMatch;
		public String dispatchedOnFromSource;
	}

	public class PassportNumber {
		public String passportNumberFromSource;
		public Boolean passportNumberMatch;
	}

	public class Name {
		public String surnameFromPassport;
		public Double nameScore;
		public String nameFromPassport;
		public Boolean nameMatch;
	}

	public class Result {
		public PassportNumber passportNumber;
		public String typeOfApplication;
		public Name name;
		public DateOfIssue dateOfIssue;
		public String applicationDate;
	}

	
	public static AUSFPassportResponseWrapper parse(String json) {
		return (AUSFPassportResponseWrapper) System.JSON.deserialize(json, AUSFPassportResponseWrapper.class);
	}
}