public class OCRAdharRespWrapper {

	public class Aadhaar {
		public String value;
		public Double conf;
		public String isMasked;
	}

	public class Details {
		public Aadhaar aadhaar;
		public Dob dob;
		public Father father;
		public Dob gender;
		public Father mother;
		public Dob name;
		public Father yob;
		public ImageUrl imageUrl;
		public ImageUrl qr;
	}

	public String requestId;
	public List<Result> result;
	public Integer statusCode;

	public class Dob {
		public String value;
		public Double conf;
	}

	public class AddressSplit {
		public String careOf;
		public String houseNumber;
		public String city;
		public String line1;
		public String line2;
		public String street;
		public String locality;
		public String landmark;
		public String district;
		public String state;
		public String pin;
	}

	public class ImageUrl {
		public String value;
	}

	public class Details_Z {
		public Aadhaar aadhaar;
		public Dob address;
		public Dob pin;
		public ImageUrl imageUrl;
		public ImageUrl qr;
		public Father father;
		public Father husband;
		public AddressSplit addressSplit;
	}

	public class Details_Y {
		public Aadhaar aadhaar;
		public Dob address;
		public Dob name;
		public Dob phone;
		public Father pin;
		public ImageUrl imageUrl;
		public Father father;
		public Father husband;
		public AddressSplit addressSplit;
	}

	public class Father {
		public String value;
		public Integer conf;
	}

	public class Result {
		public Details details;
		public String type;
	}

	
	public static OCRAdharRespWrapper parse(String json) {
		return (OCRAdharRespWrapper) System.JSON.deserialize(json, OCRAdharRespWrapper.class);
	}

}