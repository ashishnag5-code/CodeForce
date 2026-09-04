public class CollateralDedupeResponseWrapper {

	public class Messages {
		public Integer code;
		public String message;
        public Messages(){
            code = 0000;
            message = '';
        }
	}

	public class CollateralDetails {
		public String AccountNumber;
		public String ChassisNumber;
		public String CollateralId;
		public String CollateralName;
		public String CollateralType;
		public String CollateralUnusedValue;
		public String CostPrice;
        public String EngineNumber;
		public String RegistrationNumber;
		public String TotalCollateralValue;
        public String ManufactureYear;
        public String Model;
        public String Make;
        public String ModelName;
        public String CollateralCode;
        public String PropertyOwnerName;
        public CollateralDetails(){
            AccountNumber = '';
            ChassisNumber = '';
            CollateralId = '';
            CollateralName = '';
            CollateralType = '';
            CollateralUnusedValue = '';
            CostPrice = '';
            EngineNumber = '';
            RegistrationNumber = '';
            TotalCollateralValue = '';
            ManufactureYear = '';
            Model = '';
            Make = '';
            ModelName = '';
            CollateralCode = '';
            PropertyOwnerName = '';
        }
	}

	public TransactionStatus TransactionStatus;
	public List<CollateralDetails> CollateralDetails;

	public class TransactionStatus {
		public String ResponseCode;
		public String ResponseMessage;
		public ExtendedErrorDetails ExtendedErrorDetails;
		public List<String> ValidationErrors;
        public TransactionStatus(){
            ResponseCode = '';
            ResponseMessage = '';
            ExtendedErrorDetails = new ExtendedErrorDetails();
            ValidationErrors = new List<String>();
        }
	}

	public class ExtendedErrorDetails {
		public List<Messages> messages;
        public ExtendedErrorDetails(){
            messages = new List<Messages>();
        }
	}

	
	/*public static CollateralDedupeResponseWrapper parse(String json) {
		return (CollateralDedupeResponseWrapper) System.JSON.deserialize(json, CollateralDedupeResponseWrapper.class);
	}*/
}