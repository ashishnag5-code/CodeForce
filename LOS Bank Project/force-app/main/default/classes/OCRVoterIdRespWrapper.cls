public class OCRVoterIdRespWrapper {

	public class Details {
		public Voterid voterid;
		public Voterid name;
		public Voterid gender;
		public Voterid relation;
		public Voterid dob;
		public Doc doc;
		public Doc age;
	}

	public String requestId;
	public List<Result> result;
	public Integer statusCode;

	public class Voterid {
		public String value;
		public Double conf;
	}

	public class Doc {
		public String value;
		public Integer conf;
	}

	public class Result {
		public Details details;
		public String type;
	}

	
	public static OCRVoterIdRespWrapper parse(String json) {
		return (OCRVoterIdRespWrapper) System.JSON.deserialize(json, OCRVoterIdRespWrapper.class);
	}
}