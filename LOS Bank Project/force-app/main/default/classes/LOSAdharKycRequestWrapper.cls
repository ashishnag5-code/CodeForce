public class LOSAdharKycRequestWrapper {

	public Headers headers;
	public Request request;

	public class Headers {
		public String sub_client_code;
		public String actor_type;
		public String channel;
		public String operation_mode;
		public String channel_code;
		public String channel_version;
		public String function_sub_code;
		public String function_code;
		public String run_mode;
		public String requestId;
		public String stan;
		public String user_handle_value;
		public String client_ip;
		public String location;
		public String user_handle_type;
		public String client_code;
		public String transmission_datetime;
	}

	public class Request {
		public String notification_channel;
		public String client_ref_number;
		public String uid;
		public String environment;
		public String purpose;
		public String remark;
		public String consent;
		public String transaction_ref_number;
	}

	
	/*public static LOSAdharKycRequestWrapper parse(String json) {
		return (LOSAdharKycRequestWrapper) System.JSON.deserialize(json, LOSAdharKycRequestWrapper.class);
	}*/

}