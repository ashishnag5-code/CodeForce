public class AUSFVoterResponseWrapper {

    public class UIResponse{
        public Result Response;
        public Object[] metadata;
        public Integer statusCode;
        public String errorMessage;
    }
    
	public String requestId;
	public Result result;
	public Integer statusCode;

	public class Result {
		public String name;
		public String rln_name;
		public String rlnType;
		public String gender;
		@AuraEnabled public String district{get;set;}
		public String acName;
		public String pcName;
        @AuraEnabled public String state{get;set;}
		public String epic_no;
		public String dob;
		public Integer age;
		public String partNo;
		public String slNoInPart;
		public String psName;
		public String partName;
		public String lastUpdate;
		public String psLatLong;
		public String rlnNameV1;
		public String rlnNameV2;
		public String rlnNameV3;
		public String sectionNo;
		public String id;
		public String nameV1;
		public String nameV2;
		public String nameV3;
		public String acNo;
		public String stCode;
		//public String houseNo;
		@AuraEnabled public String house_no{get;set;}
		@AuraEnabled public String pin{get;set;}
	}

	
	public static AUSFVoterResponseWrapper parse(String json) {
		return (AUSFVoterResponseWrapper) System.JSON.deserialize(json, AUSFVoterResponseWrapper.class);
	}
}