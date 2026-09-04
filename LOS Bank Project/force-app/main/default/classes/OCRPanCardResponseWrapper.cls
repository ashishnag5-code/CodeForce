/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 02-22-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public class OCRPanCardResponseWrapper {

	public class AdditionalDetails {
	}

	public String requestId;
	public Result result;
	public Integer statusCode;

	public class Dob {
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
		public Dob dob;
		public Doi doi;
		public Dob father;
		public Dob name;
		public Dob pan;
	}

	public class Doi {
		public String value;
		public Double confidence;
	}

	public class Result {
		public List<Documents> documents;
	}

	
	public static OCRPanCardResponseWrapper parse(String json) {
		return (OCRPanCardResponseWrapper) System.JSON.deserialize(json, OCRPanCardResponseWrapper.class);
	}
}