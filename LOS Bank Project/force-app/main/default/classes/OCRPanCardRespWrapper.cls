public class OCRPanCardRespWrapper {
	public String requestId;	//edc11e0e-2ee1-4177-bc95-b04f87c3c268
	public cls_result[] result;
	public Integer statusCode;	//101
	class cls_result {
		public cls_details details;
		public String type;	//Pan
	}
	class cls_details {
		public cls_date_x date_x;
		public cls_dateOfIssue dateOfIssue;
		public cls_father father;
		public cls_name name;
		public cls_panNo panNo;
	}
	class cls_date_x {
		public Double conf;	//1
		public String value;	//05/06/1992
	}
	class cls_dateOfIssue {
		public Double conf;	//0
		public String value;	//
	}
	class cls_father {
		public Double conf;	//0.8
		public String value;	//KHANDEKAR
	}
	class cls_name {
		public Double conf;	//0.81
		public String value;	//KHANDEKAR MANGESH SHIVAJIRAO SHIVAJIRAO VITTHALRAO
	}
	class cls_panNo {
		public Double conf;	//1
		public String value;	//DKXPK5809K
	}
	public static OCRPanCardRespWrapper parse(String json){
		return (OCRPanCardRespWrapper) System.JSON.deserialize(json, OCRPanCardRespWrapper.class);
	}
}