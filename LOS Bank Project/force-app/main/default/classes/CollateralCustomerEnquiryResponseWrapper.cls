public class CollateralCustomerEnquiryResponseWrapper {
    
	public cls_CollateralDetails[] CollateralDetails;
	public cls_TransactionStatus TransactionStatus;
	public class cls_CollateralDetails {
		public String InsurancePlanCode;
		public String ValuationSourceDesc;//FCR COLLATERAL
		public String FlagPropogateCollValue;//NO
		public Integer CollateralHomebranch;//2170
		public String RegisteringAuthority;
		public String FinSecCode;
        public String ProductNameCode;
		public String PropertyType;//FreeHold
		public Integer CollateralCoverValue;//0
		public String ManufactureYear;
		public String InsurancePolicyNumber;
		public Integer MarketValue;//2000000
		public String PropertyDesc1;//Housing Board
		public String GoldValuatorCode;
		public String NextPremiumDate;
		public String NonStandardCollateralId;
		public String PropertyDesc2;
		public Integer CollateralCurrency;//1
		public String GoldNetWeight;
		public String LastValuationDate;//20221201
		public String CollateralName;//Property
		public String OriginalValuationDate;//20221201
		public String DeedReturnDate;//20240405
		public Integer AmountCollValueAcCcy;//200000
		public String DeedDetails;	//AUF
		public Integer LeaseExpireDate;
		public String NonStandardMachineNo;
		// Updated by Kunal - to Double Start - SFAU-5773
		public Double RatSharePercent;	//10 
		// End SFAU-5773
		public String TypeOfCharge;	//FirstCharge
		public String TehsilTaluka;	//Jaipur
		public String NonStandardInvoiceNo;
		public String NonStandardFlagMachine;
		public String HouseFlatShopNo;
		public String ModelName;
		public String Village;
		public String CollateralId;	//1060121192002749
		public String DeedSentDate;	//20221201
		public String GoldValuationAmt;
		public Integer OriginalValue;	//2000000
		public String Make;
		public String CustomerId;	//27965904
		public Integer AmountCollValueCollCcy;	//200000
		public String CollateralType;	//Primary
		public String FloatingCollateralFlag;	//N
		public String KhasaraPlotNo;
		public String ChassisNumber;
		public String GuardianCustomerId;
		public Integer LastValue;	//2000000
		public Integer CollateralUnusedValue;	//1800000
		public String GoldNoOfUnits;
		public Integer totalCollateralValue;	//2000000
		public String AssetClass;	//New
		public String CollateralDocument;
		public String District;	//Jaipur
		public String CustodianName;
		public Integer ForceSaleValue;	//0
		public Integer AmountBlockRecovery;
		public String PropertyOwnerName;	//Nani
		public String TownCity;	//JAIPUR
		public Integer AmountShareValueAcCcy;	//200000
		public Integer QuitRentValue;	//0
		public Integer AmountCollShareValueCollCcy;	//200000
		public String AssuredValue;
		public Integer TotalArea;	//1000
		public String EngineNumber;
		public String StatusOfDeeds;	//WithUs
		public String ValuationEdition;
		public String AreaUnit;	//SQYD
		public String RegistrationNumber;
		public Integer CostPrice;	//2000000
		public String GoldOrnamentType;
		public String GoldKarat;
		public String GoldOtherDtls;
		public String NonStandardDesc2;
		public String NonStandardManufactureName;
		public String ValuationSource;	//0
		public String NonStandardDesc1;
		public String AccountCustomerRelation;	//SOW
		public String GoldMarketValue;
		public String ValuationSuppliment;
		public String NameOfLender;
		public String FinSecDtls;
		public String FinSecSrl1;
		public String FinSecSrl2;
		public String MaturityDate;
		public String GoldOrnamentDesc;
		public String AccountNumber;	//9001060130308777
		public String CollateralCode;	//10201-Property-INR
		public String FinSecNoOfUnit;
		public String GoldGrossWeight;
		public String Model;
		public String FinSecTotalValue;
		public String GoldValuatorName;
		public String Location;	//near
	}
	public class cls_TransactionStatus {
		public String ResponseCode;	//99
		//public cls_ValidationErrors[] ValidationErrors;
		public String ResponseMessage;	//Failure
		public cls_ExtendedErrorDetails ExtendedErrorDetails;
	}
	/*class cls_ValidationErrors {
	}*/
	class cls_ExtendedErrorDetails {
		public cls_messages[] messages;
	} 
	class cls_messages {
		public Integer code;	//99
		public String message;	//No collateral attached to linked accounts for customer.
	}
	public static CollateralCustomerEnquiryResponseWrapper parse(String json){
		return (CollateralCustomerEnquiryResponseWrapper) System.JSON.deserialize(json, CollateralCustomerEnquiryResponseWrapper.class);
	}
}