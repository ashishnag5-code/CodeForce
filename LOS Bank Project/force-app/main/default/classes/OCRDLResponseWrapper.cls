/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 12-20-2022
 * @last modified by  : Harshit Goyal | Salesforce
**/

public class OCRDLResponseWrapper {

	public class AdditionalDetails {
		public Boolean faceDetected;
		public AddressSplit addressSplit;
	}

	public class AddressSplit {
		public String building;
		public String city;
		public String district;
		public String pin;
		public String floor;
		public String house;
		public String locality;
		public String state;
		public String street;
		public String complex;
		public String landmark;
		public String untagged;
	}

	public class Documents {
		public String documentType;
		public String subType;
		public Object pageNo;
		public OcrData ocrData;
		public AdditionalDetails additionalDetails;
	}

	public String requestId;
	public Result result;
	public Integer statusCode;

	public class DlNo {
		public String value;
		public Double confidence;
	}

	public class OcrData {
		public DlNo dlNo;
		public DlNo name;
		public DlNo dob;
		public DlNo doi;
		public DlNo doe;
		public DlNo relationName;
		public DlNo address;
		public DlNo pin;
	}

	public class Result {
		public List<Documents> documents;
	}

	
	public static OCRDLResponseWrapper parse(String json) {
		return (OCRDLResponseWrapper) System.JSON.deserialize(json, OCRDLResponseWrapper.class);
	}
}