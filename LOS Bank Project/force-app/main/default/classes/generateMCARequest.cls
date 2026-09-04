public with sharing class generateMCARequest implements IntegrationHandlerInterface {

    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        MCARequestWrapper MCADRequestWrapper = new MCARequestWrapper();
        MCADRequestWrapper.requestId = IntegrationUtility.getReferenceId();
        MCADRequestWrapper.channel = Label.AddressDistanceChannel;
        MCADRequestWrapper.consent = String.valueOf(paramsMap.get('consent'));
        MCADRequestWrapper.cin = String.valueOf(paramsMap.get('cin'));
        lstString.add(JSON.serialize(MCADRequestWrapper));   
        return lstString;
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    public class MCARequestWrapper{
        public String requestId;
        public String channel;
        public String consent;
        public String cin;
    }
}