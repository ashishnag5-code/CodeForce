public class AUSFDrivingLicenseResponseWrapper {

    public class UIResponse{
        public Result Response;
        public Object[] metadata;
        public Integer statusCode;
        public String errorMessage;
    }
    
	public class Validity {
		public String transport;
		public String nontransport;
	}

	public Result result;
	public String request_id;
	public Integer statusCode;

	public class Cov_details {
		public String issue_date;
		public String cov;
	}

	public class Result {
		public List<Cov_details> cov_details;
		public Validity validity;
		public String name;
		public String dob;
		public String dl_number;
		public String fatherhusband;
		public String issue_date;
		public String blood_group;
		public String img;
		public String address;
	}
	
	public static AUSFDrivingLicenseResponseWrapper parse(String json) {
		return (AUSFDrivingLicenseResponseWrapper) System.JSON.deserialize(json, AUSFDrivingLicenseResponseWrapper.class);
	}
}