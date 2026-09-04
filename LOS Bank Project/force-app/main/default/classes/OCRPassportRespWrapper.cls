public class OCRPassportRespWrapper {

	public class Details {
		public CountryCode countryCode;
		public CountryCode dob;
		public CountryCode doe;
		public CountryCode doi;
		public CountryCode gender;
		public CountryCode givenName;
		public CountryCode surname;
		public CountryCode nationality;
		public CountryCode passportNum;
		public CountryCode placeOfBirth;
		public CountryCode placeOfIssue;
		public CountryCode type;
		public Mrz mrz;
	}

	public String requestId;
	public List<Result> result;
	public Integer statusCode;

	public class Mrz {
		public String line1;
		public String line2;
		public Double conf;
	}

	public class CountryCode {
		public String value;
		public Double conf;
	}

	public class Result {
		public Details details;
		public String type;
	}

	
	public static OCRPassportRespWrapper parse(String json) {
		return (OCRPassportRespWrapper) System.JSON.deserialize(json, OCRPassportRespWrapper.class);
	}

}