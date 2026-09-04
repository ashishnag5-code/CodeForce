public inherited sharing class AUSFVehicleCarDekhoIntHandler implements IntegrationHandlerInterface{
    
    public static String[] generateRequest(Object reqParam){
        map<String,Object> paramsMap = (map<String,Object>)reqParam;
        CarDekhoRequestWrapper request = new CarDekhoRequestWrapper();
        request.RequestId = IntegrationUtility.getReferenceId();
        request.Channel = Label.VehicleDekhoChannel;
        request.variantId = (String)paramsMap.get('variantId');
        request.cityId = (String)paramsMap.get('cityId');
        return new String[]{ JSON.serialize( request ) };
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    public class CarDekhoRequestWrapper{
        public String RequestId;
        public String Channel;
        public String variantId;
        public String cityId;
    }

    public class CarDekhoFailureResponseWrapper{
        public map<String, String> errors;
    }

    public class CarDekhoResponseWrapper {
        @AuraEnabled public CarDekhoResponseWrapper data {get;set;} 
        @AuraEnabled public Integer id {get;set;} 
        @AuraEnabled public Integer insurance {get;set;} 
        @AuraEnabled public Integer ex_showroom_price {get;set;} 
        @AuraEnabled public Integer on_road_price {get;set;} 
        @AuraEnabled public String updated_date {get;set;} 
        @AuraEnabled public Integer rto {get;set;} 
        /*@AuraEnabled public String city_name {get;set;} 
        @AuraEnabled public String city_id {get;set;}*/
    }
}