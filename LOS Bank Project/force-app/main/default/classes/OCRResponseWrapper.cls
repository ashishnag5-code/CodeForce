public class OCRResponseWrapper {

	public class Details {
		public Gender gender;
		public Dob dob;
		public Gender voterid;
		public Gender name;
		public Gender doc;
		public Dob age;
		public Gender relation;
	}

	public List<Result> result;
	public String requestId;
	public Integer statusCode;

	public class Dob {
		public Integer conf;
		public String value;
	}

	public class Gender {
		public Double conf;
		public String value;
	}

	public class Result {
		public Details details;
		public String type;
	}

	
	public static OCRResponseWrapper parse(String json) {
		return (OCRResponseWrapper) System.JSON.deserialize(json, OCRResponseWrapper.class);
	}
}