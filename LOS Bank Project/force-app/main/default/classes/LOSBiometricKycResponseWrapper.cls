public class LOSBiometricKycResponseWrapper {

    public class Response_data {
		public String data;
		public String format;
	}

	public Response_data response_data;
	public Response_status response_status;

	public class Response_status {
		public String code;
		public String message;
		public String status;
	}

	
	public static LOSBiometricKycResponseWrapper parse(String json) {
		return (LOSBiometricKycResponseWrapper) System.JSON.deserialize(json, LOSBiometricKycResponseWrapper.class);
	}
}