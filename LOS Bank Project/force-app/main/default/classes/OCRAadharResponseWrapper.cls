/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 01-12-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/


public class OCRAadharResponseWrapper {
    
    public String ServiceExecutionStatus;	//ERROR
	public ClassErrors Errors;
	class ClassErrors {
		public ClassError Error;
	}
	class ClassError {
		public String Code;	//AUF-ESB-Err-03
		public String Message;	//Bad Gateway
	}

	public class AdditionalDetails {
		public InputMaskStatus inputMaskStatus;
		public Boolean outputMaskStatus;
		public Boolean verhoeffCheck;
		public String qr;
		public Object barcode;
		public AddressSplit addressSplit;
		public CareOfDetails careOfDetails;
	}

	public class Aadhaar {
		public String value;
		public Double confidence;
	}

	public String requestId;
	public Result result;
	public Integer statusCode;

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

	public class AdditionalDetails_Z {
		public InputMaskStatus inputMaskStatus;
		public Boolean outputMaskStatus;
		public Boolean verhoeffCheck;
		public String qr;
		public Object barcode;
	}

	public class CareOfDetails {
		public String relation;
		public String name;
	}

	public class OcrData {
		public Aadhaar aadhaar;
		public Aadhaar address;
		public Aadhaar name;
		public Aadhaar phone;
		public Pin pin;
		public Aadhaar vid;
		public Pin dob;
		public Pin father;
		public Aadhaar gender;
		public Pin husband;
		public Pin mother;
		public Aadhaar yob;
	}
	public class Result {
		public List<Documents> documents;
	}

	public class Pin {
		public String value;
		public Double confidence;
	}

	public class InputMaskStatus {
		public Boolean isMasked;
		public Object maskedBy;
		public Object confidence;
	}

	public class Documents {
		public String documentType;
		public String subType;
		public Integer pageNo;
		public OcrData ocrData;
		public AdditionalDetails additionalDetails;
		public List<QualityChecks> qualityChecks;
		public String documentLink;
		public String documentBase64;
	}

	public class QualityChecks {
		public Double score;
		public Boolean flag;
		public String type;
	}

	
	public static OCRAadharResponseWrapper parse(String json) {
		return (OCRAadharResponseWrapper) System.JSON.deserialize(json, OCRAadharResponseWrapper.class);
	}
}