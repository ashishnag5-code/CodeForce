public class AUSFVahaanResponseWrapper {

    @AuraEnabled public Result result {get;set;} 
	@AuraEnabled public String statusCode {get;set;} // in json: status-code
	@AuraEnabled public String request_id {get;set;}
	@AuraEnabled public Double totalOverdueAmount {get;set;}
	@AuraEnabled public String errorMessage {get;set;}

    public class Result {
		@AuraEnabled public Metadata metadata {get;set;} 
		@AuraEnabled public String pdf {get;set;} 
		@AuraEnabled public map<String, String> nocCcDetails {get;set;} 
		@AuraEnabled public map<String, String> ownerDetails {get;set;} 
		@AuraEnabled public VehicleDetails vehicleDetails {get;set;} 
		@AuraEnabled public map<String, String> financersDetails {get;set;} 
		@AuraEnabled public map<String, String> insuranceDetails {get;set;} 
		@AuraEnabled public ChallanDetail[] challanDetails {get;set;}

		public Result(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'metadata') {
							metadata = new Metadata(parser);
						} else if (text == 'pdf') {
							pdf = parser.getText();
						} else if (text == 'nocCcDetails') {
							nocCcDetails = (map<String, String>)parser.readValueAs(map<String, String>.class);
							// nocCcDetails = new NocCcDetails(parser);
						} else if (text == 'ownerDetails') {
							ownerDetails = (map<String, String>)parser.readValueAs(map<String, String>.class);
						} else if (text == 'vehicleDetails') {
							vehicleDetails = new VehicleDetails(parser);
						} else if (text == 'financersDetails') {
							financersDetails = (map<String, String>)parser.readValueAs(map<String, String>.class);
						} else if (text == 'insuranceDetails') {
							insuranceDetails = (map<String, String>)parser.readValueAs(map<String, String>.class);
						} else if(text == 'challanDetails'){
							challanDetails = (ChallanDetail[])JSON.deserialize(parser.getText(), ChallanDetail[].class);
							// if(challanDetails != null){
							// 	this.totalOverdueAmount = getChallanOverdueAmount( challanDetails );
							// }
						} else {
							System.debug(LoggingLevel.WARN, 'Result consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
    public class Metadata {
		@AuraEnabled public Integer amountBeforePayment {get;set;} 
		@AuraEnabled public String crawlerLogs {get;set;} 
		@AuraEnabled public String searchBy {get;set;} 
		@AuraEnabled public Integer amountAfterPayment {get;set;} 
		@AuraEnabled public String user {get;set;} 

		public Metadata(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'amountBeforePayment') {
							amountBeforePayment = parser.getIntegerValue();
						} else if (text == 'crawlerLogs') {
							crawlerLogs = parser.getText();
						} else if (text == 'searchBy') {
							searchBy = parser.getText();
						} else if (text == 'amountAfterPayment') {
							amountAfterPayment = parser.getIntegerValue();
						} else if (text == 'user') {
							user = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'Metadata consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

    public class VehicleDetails {
		@AuraEnabled public String bodyType {get;set;} 
		@AuraEnabled public String horsePower {get;set;} 
		@AuraEnabled public String color {get;set;} 
		@AuraEnabled public String registrationDt {get;set;} 
		@AuraEnabled public String fuel {get;set;} 
		@AuraEnabled public String purchaseDt {get;set;} 
		@AuraEnabled public String noOfCylinders {get;set;} 
		@AuraEnabled public String fitnessUpto {get;set;} 
		@AuraEnabled public String manufacturer {get;set;} 
		@AuraEnabled public String cubicCap {get;set;} 
		@AuraEnabled public String seatingCap {get;set;} 
		@AuraEnabled public String vehicleClass {get;set;} 
		@AuraEnabled public String makerModel {get;set;} 
		@AuraEnabled public String panGirNo {get;set;} 
		@AuraEnabled public String ownerSrNo {get;set;} 
		@AuraEnabled public String saleAmount {get;set;} 
		@AuraEnabled public String engineNo {get;set;} 
		@AuraEnabled public String gvw {get;set;} 
		@AuraEnabled public String standingCap {get;set;} 
		@AuraEnabled public String wheelbase {get;set;} 
		@AuraEnabled public String registrationNo {get;set;} 
		@AuraEnabled public String chassisNo {get;set;} 
		@AuraEnabled public String dealer {get;set;} 
		@AuraEnabled public String wtUnladen {get;set;} 
		@AuraEnabled public String blackListDetails {get;set;} 

		public VehicleDetails(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'bodyType') {
							bodyType = parser.getText();
						} else if (text == 'horsePower') {
							horsePower = parser.getText();
						} else if (text == 'color') {
							color = parser.getText();
						} else if (text == 'registrationDt') {
							registrationDt = parser.getText();
						} else if (text == 'fuel') {
							fuel = parser.getText();
						} else if (text == 'purchaseDt') {
							purchaseDt = parser.getText();
						} else if (text == 'noOfCylinders') {
							noOfCylinders = parser.getText();
						} else if (text == 'fitnessUpto') {
							fitnessUpto = parser.getText();
						} else if (text == 'manufacturer') {
							manufacturer = parser.getText();
						} else if (text == 'cubicCap') {
							cubicCap = parser.getText();
						} else if (text == 'seatingCap') {
							seatingCap = parser.getText();
						} else if (text == 'vehicleClass') {
							vehicleClass = parser.getText();
						} else if (text == 'makerModel') {
							makerModel = parser.getText();
						} else if (text == 'panGirNo') {
							panGirNo = parser.getText();
						} else if (text == 'ownerSrNo') {
							ownerSrNo = parser.getText();
						} else if (text == 'saleAmount') {
							saleAmount = parser.getText();
						} else if (text == 'engineNo') {
							engineNo = parser.getText();
						} else if (text == 'gvw') {
							gvw = parser.getText();
						} else if (text == 'standingCap') {
							standingCap = parser.getText();
						} else if (text == 'wheelbase') {
							wheelbase = parser.getText();
						} else if (text == 'registrationNo') {
							registrationNo = parser.getText();
						} else if (text == 'chassisNo') {
							chassisNo = parser.getText();
						} else if (text == 'dealer') {
							dealer = parser.getText();
						} else if (text == 'wtUnladen') {
							wtUnladen = parser.getText();
						} else if (text == 'blackListDetails') {
							blackListDetails = parser.getText();
						} else {
							System.debug(LoggingLevel.WARN, 'VehicleDetails consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public Class ChallanDetail{
		@AuraEnabled public Double totalAmount;
		@AuraEnabled public String status;
	}

    public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}

    ////====================================================================================////
    ////===========================///    Vahan Free Version ///===========================////
    ////====================================================================================////
    // @AuraEnabled
    // public String requestId;
    // @AuraEnabled
    // public Result result;
    // @AuraEnabled
    // public Integer statusCode;
    
    // public class Result {
    //     /*@AuraEnabled
    //     public String seatingCapacity;
    //     @AuraEnabled
    //     public String taxPaidUpto;
    //     @AuraEnabled
    //     public String vehicleClassDescription;
    //     @AuraEnabled
    //     public String grossVehicleWeight;
    //     @AuraEnabled
    //     public String unladenWeight;
    //     @AuraEnabled
    //     public String permanentAddress;*/
    //     @AuraEnabled
    //     public String ownerSerialNumber;
    //     /*@AuraEnabled
    //     public Object statusAsOn;
    //     @AuraEnabled
    //     public String wheelbase;
    //     @AuraEnabled
    //     public String registrationDate;
    //     @AuraEnabled
    //     public String fatherName;*/
    //     @AuraEnabled
    //     public String financier;
    //     @AuraEnabled
    //     public String registrationNumber;
    //     @AuraEnabled
    //     public String chassisNumber;
    //     /*@AuraEnabled
    //     public String numberOfCylinders;
    //     @AuraEnabled
    //     public String bodyTypeDescription;
    //     @AuraEnabled
    //     public String makerDescription;
    //     @AuraEnabled
    //     public String sleeperCapacity;
    //     @AuraEnabled
    //     public String fuelDescription;
    //     @AuraEnabled
    //     public String makerModel;
    //     @AuraEnabled
    //     public String cubicCapacity;*/
    //     @AuraEnabled
    //     public String color;
    //     @AuraEnabled
    //     public String ownerName;
    //     @AuraEnabled
    //     public String registeredAt;
    //     @AuraEnabled
    //     public String manufacturedMonthYear;
    //     /*@AuraEnabled
    //     public String normsDescription;
    //     @AuraEnabled
    //     public String standingCapacity;
    //     @AuraEnabled
    //     public String insuranceUpto;*/
    //     @AuraEnabled
    //     public String engineNumber;
    //     /*@AuraEnabled
    //     public String presentAddress;
    //     @AuraEnabled
    //     public String insurancePolicyNumber;
    //     @AuraEnabled
    //     public String fitnessUpto;
    //     @AuraEnabled
    //     public String insuranceCompany;*/
    // }
    
    
    public static AUSFVahaanResponseWrapper parse(String json) {
        return (AUSFVahaanResponseWrapper) System.JSON.deserialize(json, AUSFVahaanResponseWrapper.class);
    }
	public static Double getChallanOverdueAmount(ChallanDetail[] challanDetails){
		Double overdueAmount = 0;
		for(ChallanDetail challan: challanDetails){
			if( challan.status == 'PENDING' && challan.totalAmount != null ){
				overdueAmount += challan.totalAmount;
			}
		}
		return overdueAmount;
	}
    
}