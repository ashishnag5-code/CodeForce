public class LOSAdhaKycValidateOtpReqWrapper {

	public class Modalities {
		public String pi;
		public String pa;
		public String pfa;
		public String bio;
		public String bt;
		public String otp;
	}

	public Headers headers;
	public Request request;

	public class Headers {
		public String channel;
		public String requestId;
		public String client_code;
		public String sub_client_code;
		public String channel_code;
		public String channel_version;
		public String stan;
		public String client_ip;
		public String transmission_datetime;
		public String operation_mode;
		public String run_mode;
		public String actor_type;
		public String user_handle_type;
		public String user_handle_value;
		public String location;
		public String function_code;
		public String function_sub_code;
	}

	public class Request {
		public String client_ref_number;
		public String transaction_ref_number;
		public String remark;
		public String environment;
		public String notification_channel;
		public String hmac;
		public String uid;
		public String consent;
		public String pdf;
		public String lr;
		public String purpose;
		public Skey skey;
		public Pid pid;
		public Modalities modalities;
	}

	public class Pid {
		public String type;
		public String value;
	}

	public class Skey {
		public String ci;
		public String value;
	}

}