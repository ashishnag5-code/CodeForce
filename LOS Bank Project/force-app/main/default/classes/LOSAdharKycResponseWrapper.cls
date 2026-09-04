public class LOSAdharKycResponseWrapper {

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

	
	public static LOSAdharKycResponseWrapper parse(String json) {
        system.debug('json--'+json);
		return (LOSAdharKycResponseWrapper) System.JSON.deserialize(json, LOSAdharKycResponseWrapper.class);
	}
}