public class LOSKarzaNameMatchIntHandler implements IntegrationHandlerInterface{
    
    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        NameMatchRequestWrapper objNameMatchRequestWrapper = new NameMatchRequestWrapper();
        objNameMatchRequestWrapper.requestId = IntegrationUtility.getReferenceId();
        objNameMatchRequestWrapper.channel = Label.NameMatchChannel;
        objNameMatchRequestWrapper.name1 = String.valueOf(paramsMap.get('name1'));
        objNameMatchRequestWrapper.name2 = String.valueOf(paramsMap.get('name2'));
        objNameMatchRequestWrapper.type = 'individual';
        objNameMatchRequestWrapper.preset = 'L';
        lstString.add(JSON.serialize(objNameMatchRequestWrapper));   
        return lstString;
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    public class NameMatchRequestWrapper{
        public String requestId;
        public String channel;
        public String name1;
        public String name2;
        public String type;
        public String preset;
    }
    
    public class NameMatchResponseWrapper{
        public String requestId;    //18012218-e46c-4aed-9b7e-55fe2d2f39b4
        public cls_result result;
        public Integer statusCode;  //101
    }
    
    public class cls_result {
        public Double score;    //0.961111111111111
        public boolean result;
    }
    
}