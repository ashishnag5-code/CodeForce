/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 01-19-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public class LOSKarzaFaceMatchIntHandler implements IntegrationHandlerInterface{
    
    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        FaceMatchRequestWrapper objNameMatchRequestWrapper = new FaceMatchRequestWrapper();
        objNameMatchRequestWrapper.requestId = IntegrationUtility.getReferenceId();
        objNameMatchRequestWrapper.channel = Label.Karza_Face_Match_Channel;
        objNameMatchRequestWrapper.Image1B64 = String.valueOf(paramsMap.get('name1'));
        objNameMatchRequestWrapper.Image2B64 = String.valueOf(paramsMap.get('name2'));
        objNameMatchRequestWrapper.type = 'individual';
        objNameMatchRequestWrapper.preset = 'L';
        lstString.add(JSON.serialize(objNameMatchRequestWrapper));   
        return lstString;
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    public class FaceMatchRequestWrapper{
        public String requestId;
        public String channel;
        public String Image1B64;
        public String Image2B64;
        public String type;
        public String preset;
    }
    
    public class FaceMatchResponseWrapper{
        public String requestId;    //18012218-e46c-4aed-9b7e-55fe2d2f39b4
        public cls_result result;
        public Integer statusCode;  //101
    }
    
    public class cls_result {
        public Double score;    //0.961111111111111
        public boolean result;
    }
    
}