/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 02-22-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public class OCRVoterIdResponseWrapper {

	public class AdditionalDetails {
	}

	public String requestId;
	public Result result;
	public Integer statusCode;

	public class Dob {
		public String value;
		public Double confidence;
	}

	public class VoterId {
		public String value;
		public Double confidence;
	}

	public class Documents {
		public String documentType;
		public String subType;
		public Integer pageNo;
		public OcrData ocrData;
		public AdditionalDetails additionalDetails;
		public List<QualityChecks> qualityChecks;
		public Object documentLink;
	}

	public class QualityChecks {
		public Double score;
		public Boolean flag;
		public String type;
	}

	public class OcrData {
		public VoterId voterId;
		public VoterId name;
		public Dob dob;
		public VoterId gender;
		public VoterId ageAsPerDate;
		public VoterId relationName;
		public VoterId age;
	}

	public class Result {
		public List<Documents> documents;
	}

	
	public static OCRVoterIdResponseWrapper parse(String json) {
		return (OCRVoterIdResponseWrapper) System.JSON.deserialize(json, OCRVoterIdResponseWrapper.class);
	}
}