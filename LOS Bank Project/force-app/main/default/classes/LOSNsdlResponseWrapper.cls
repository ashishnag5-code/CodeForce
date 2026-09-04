public class LOSNsdlResponseWrapper {
    
    public class UIResponse{
        public Response Response;
        public Object[] metadata;
		public Headers headers;
        public String error;
    }

	public class Response {
		public String Title;
		public String FirstName;
		public String LastName;
		//public Object MiddleName;
		public String MiddleName;
		public String Status;
		public String Seeding;
	}

	public Headers headers;
	public List<Response> response;

	public class Headers {
		public String responseCode;
		public String responseMsg;
	}
	
	public static LOSNsdlResponseWrapper parse(String json) {
		return (LOSNsdlResponseWrapper) System.JSON.deserialize(json, LOSNsdlResponseWrapper.class);
	}


}