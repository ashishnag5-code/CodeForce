public class GSTAuthHandler implements IntegrationHandlerInterface{

    public class GSTRequestWrapper{
        public String requestId;
        public String channel;
        public String consent;
        public String gstin;
    }

    public class GSTResponseWrapper{
        public Result result;
        public String requestId;
        public Integer statusCode;
    }
    
    public class Result{
        @AuraEnabled public String gstin;
        @AuraEnabled public String lgnm;
        @AuraEnabled public String tradeNam;
        @AuraEnabled public String ctb;
        @AuraEnabled public permanentAddr pradr;
        @AuraEnabled public cEmail contacted;
        @AuraEnabled public String sts;
        @AuraEnabled public String rgdt;
        @AuraEnabled public String lstupdt;
    }
    
    public class UIResponse{
        public Result Response;
        public Object[] metadata;
        public Integer statusCode;
    }
    
    public class permanentAddr{
        @AuraEnabled public String adr;
    }
    
    public class cEmail{
        @AuraEnabled public String email;
    }
    
    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        GSTRequestWrapper requestWrapper = new GSTRequestWrapper();
        requestWrapper.RequestId = IntegrationUtility.getReferenceId();
        requestWrapper.Channel = Label.GST_Channel;
        requestWrapper.gstin = String.valueOf(paramsMap.get('gstin'));
        requestWrapper.Consent = 'Y';
        lstString.add(JSON.serialize(requestWrapper));   
        return lstString;
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    public static GSTResponseWrapper parse(String json) {
		return (GSTResponseWrapper) System.JSON.deserialize(json, GSTResponseWrapper.class);
	}
}