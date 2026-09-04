public class AddressComponentIntHandler implements IntegrationHandlerInterface{
    
    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        PINDistanceRequestWrapper objPINDistanceRequestWrapper = new PINDistanceRequestWrapper();
        objPINDistanceRequestWrapper.requestId = IntegrationUtility.getReferenceId();
        objPINDistanceRequestWrapper.channel = Label.AddressDistanceChannel;
        objPINDistanceRequestWrapper.fromPincode = String.valueOf(paramsMap.get('fromPincode'));
        objPINDistanceRequestWrapper.toPincode = String.valueOf(paramsMap.get('toPincode'));
        objPINDistanceRequestWrapper.acceptableDistance = 6;
        objPINDistanceRequestWrapper.consent = 'Y';
        lstString.add(JSON.serialize(objPINDistanceRequestWrapper));   
        return lstString;
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    public class PINDistanceRequestWrapper{
        public String requestId;
        public String channel;
        public String fromPincode;
        public String toPincode;
        public Integer acceptableDistance;
        public String consent;
    }
}