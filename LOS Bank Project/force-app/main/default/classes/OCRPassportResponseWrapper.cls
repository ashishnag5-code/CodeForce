/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 01-12-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public class OCRPassportResponseWrapper {

	public class AdditionalDetails {
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
		public AddressSplit addressSplit;
	}
	public class QualityChecks {
		public Double score;
		public Boolean flag;
		public String type;
	}

	public class OcrData {
		public CountryCode countryCode;
		public CountryCode dob;
		public CountryCode doe;
		public CountryCode doi;
		public CountryCode gender;
		public CountryCode givenName;
		public CountryCode nationality;
		public CountryCode passportNumber;
		public CountryCode placeOfBirth;
		public CountryCode placeOfIssue;
		public CountryCode surname;
		public CountryCode type;
		public CountryCode mrzLine1;
		public CountryCode mrzLine2;
		public CountryCode father;
		public CountryCode fileNumber;
		public CountryCode mother;
		public CountryCode oldDoi;
		public CountryCode oldPassportNumber;
		public CountryCode oldPlaceOfIssue;
		public CountryCode pin;
		public CountryCode spouse;
		public CountryCode address;
	}

	public class CountryCode {
		public String value;
		public Double confidence;
	}
	public String requestId;
	public Result result;
	public Integer statusCode;

	public class Result {
		public List<Documents> documents;
	}

	
	public static OCRPassportResponseWrapper parse(String json) {
		return (OCRPassportResponseWrapper) System.JSON.deserialize(json, OCRPassportResponseWrapper.class);
	}
}