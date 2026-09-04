public class LOSNsdlHandler {

    public List<String> generateRequest(Object reqParam){
        
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        /*String requestId =  String.valueOf(paramsMap.get('requestId'));
        String originatingChannel =  String.valueOf(paramsMap.get('originatingChannel'));*/
        String panNumber =  String.valueOf(paramsMap.get('panNumber'));
        //Blob key = Blob.valueOf(paramsMap.get('key'));
        //Blob iv = Blob.valueOf(paramsMap.get('iv'));
        generateNSDLWrapper generateWrap = new generateNSDLWrapper(panNumber);
        //Blob body = IntegrationUtility.encryptData('AES256',key,iv,Blob.valueOf(JSON.serialize(generateWrap)));
        return new List<String>{JSON.serialize(generateWrap)};
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }    
    
    
    
    public class generateNSDLWrapper{
        public String RequestId;
        public String OriginatingChannel;
        public String PanNumber;
        
        public generateNSDLWrapper(String panNumber){
            this.RequestId = IntegrationUtility.getReferenceId();
            this.OriginatingChannel = 'SFDC';
            this.PanNumber = panNumber;
        }
        
    }
    public class Response {
        public String Title;
        public String FirstName;
        public String LastName;
        public Object MiddleName;
        public String Status;
        public String Seeding;
    }
    
    public Headers headers;
    public List<Response> response;
    
    public class Headers {
        public String responseCode;
        public String responseMsg;
    }
    
}