public with sharing class KarzaITRController {
    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        ITRDetailsRequestWrapper itrRequestWrapper = new ITRDetailsRequestWrapper();
        itrRequestWrapper.requestId = IntegrationUtility.getReferenceId();
        //cartRequestWrapper.Source = 'SFDC';
        // cartRequestWrapper.filename = String.valueOf(paramsMap.get('filename'));
        itrRequestWrapper.channel = Label.KarzaITRController_Channel; //CBS //June13
        itrRequestWrapper.file_b64 = String.valueOf(paramsMap.get('base64'));
        itrRequestWrapper.password = String.valueOf(paramsMap.get('password'));
        lstString.add(JSON.serialize(itrRequestWrapper));   
        return lstString;
    }


    public class ITRDetailsRequestWrapper{
        public String requestId;
        public String channel;
        public String file_b64;
        public String password;
        
    }


}