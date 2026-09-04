public class IBBResponseWrapper {
    public Integer status;
    public List<Integer> ForRetailPrice;
    public String message;

    /* SFAU-5581 - Updated Response */
    public String pricefor;	//retail
	public cls_prices prices;
	public cls_match_details match_details;
	public class cls_prices {
		public Integer fairprice;	//868831
		public Integer marketprice;	//893296
		public Integer bestprice;	//911108
	}
	public class cls_match_details {
		public String Overall_Match_type;	//Approximate
		public String MMV_Match_Type;	//Approximate
		public String IBB_make;	//MARUTI SUZUKI
		public String IBB_model;	//ERTIGA(2018-2022)
		public String IBB_variant;	//ZXI PLUS BS-VI
		public String Location_Match_type;	//Exact Match
		public String IBB_location;	//DELHI
		public String IBB_color;	//Wine Red
	}
    /* SFAU-5581 - Updated Response */
	public static IBBResponseWrapper parse(String json) {
        return (IBBResponseWrapper) System.JSON.deserialize(json, IBBResponseWrapper.class);
    }
}