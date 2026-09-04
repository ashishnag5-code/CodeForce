public class AUSFCollateralSearchErrorWrapper {
    
	public class Messages {
		public Integer code;
		public String message;
	}

	public TransactionStatus TransactionStatus;
	//public List<String> CollateralDetails;

	public class TransactionStatus {
		public String ResponseCode;
		public String ResponseMessage;
		public ExtendedErrorDetails ExtendedErrorDetails;
		//public List<String> ValidationErrors;
	}

	public class ExtendedErrorDetails {
		public List<Messages> messages;
	}

	
	public static AUSFCollateralSearchErrorWrapper parse(String json) {
		return (AUSFCollateralSearchErrorWrapper) System.JSON.deserialize(json, AUSFCollateralSearchErrorWrapper.class);
	}
}