public class AUSFVehicleBikeDekhoIntHandler implements IntegrationHandlerInterface{
    
    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        BikeDekhoRequestWrapper objAddressMatchRequestWrapper = new BikeDekhoRequestWrapper();
        objAddressMatchRequestWrapper.RequestId = IntegrationUtility.getReferenceId();
        objAddressMatchRequestWrapper.Channel = Label.VehicleDekhoChannel;
        objAddressMatchRequestWrapper.VariantId = String.valueof(paramsMap.get('variantId'));
        objAddressMatchRequestWrapper.CityId = String.valueof(paramsMap.get('cityId'));
        lstString.add(JSON.serialize(objAddressMatchRequestWrapper));   
        return lstString;
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    public class BikeDekhoRequestWrapper{
        public String RequestId;
        public String Channel;
        public String VariantId;
        public String CityId;
    }

    public class BikeDekhoResponseWrapper{
        @AuraEnabled public BikeDekhoResponseData data;
        public String message;  //Variant price
        public Integer status;  //200
    }
    
    public class BikeDekhoFailureResponse{
        public map<String, String> errors;
    }

    public class BikeDekhoResponseData {
        @AuraEnabled public Integer insurance;   //43591
        @AuraEnabled public Integer antitheftcharges;    //0
        @AuraEnabled public Integer autocardcharges; //0
        @AuraEnabled public Integer othermcdcharges; //0
        @AuraEnabled public Integer warehousingcharges;  //0
        @AuraEnabled public Integer is_near_by_city_price;   //1
        @AuraEnabled public Integer non_mandatory_misc_charges;  //0
        @AuraEnabled public Integer numberplate; //0
        @AuraEnabled public Integer secure;  //0
        @AuraEnabled public Integer non_mandatory_total; //0
        @AuraEnabled public Integer standardaccessoriescharges;  //0
        @AuraEnabled public String city_name;    //Adilabad
        @AuraEnabled public Integer essentialkit;    //0
        @AuraEnabled public Integer variant_id;  //84
        @AuraEnabled public Integer smartcardcharges;    //0
        @AuraEnabled public Integer mandatory_total; //16
        @AuraEnabled public String date_time;    //2022-07-06T12:30:43.000Z
        @AuraEnabled public Integer price;   //1641000
        @AuraEnabled public String variant_slug; //hayabusa-1300
        @AuraEnabled public Integer displacement;    //1340
        @AuraEnabled public Integer id;  //11384
        @AuraEnabled public Integer helment_charges; //0
        @AuraEnabled public Integer logesticcharges; //0
        @AuraEnabled public Integer driveassure; //0
        @AuraEnabled public Integer stockyardcharges;    //0
        @AuraEnabled public Integer mandatory_other_charges; //0
        @AuraEnabled public Integer extendedwarranty;    //0
        @AuraEnabled public String variant_name; //STD
        @AuraEnabled public Integer on_road_price;   //1832281
        @AuraEnabled public Integer rto; //131280
        @AuraEnabled public Integer polish_charges;  //0
        @AuraEnabled public Integer tefloncoating;   //0
        @AuraEnabled public Integer mandatory_handling_charges;  //5
        @AuraEnabled public String price_type;   //orp
        @AuraEnabled public Integer handlingcharges; //0
        @AuraEnabled public Integer city_id; //2
    }
    
}