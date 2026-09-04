public class DelegatedAuthServiceHandler implements IntegrationHandlerInterface{
    
    public static List<String> generateRequest(Object reqParam){
        Map<String,String> reqParamMap = (Map<String,String>)reqParam;
        List<String> lstString = new List<String>();
        DelegatedAuthServiceRequest objDelegatedAuthServiceRequest = new DelegatedAuthServiceRequest();
        objDelegatedAuthServiceRequest.Channel = reqParamMap.get('Channel');
        objDelegatedAuthServiceRequest.UserId = reqParamMap.get('UserId');
        objDelegatedAuthServiceRequest.Password = reqParamMap.get('Password');
        lstString.add(JSON.serialize(objDelegatedAuthServiceRequest));   
        return lstString;
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    public class DelegatedAuthServiceRequest{
        public String Channel;  //SFDC
        public String UserId;   //983602
        public String Password; //strPasswordEncrypted
    }
    /*
    public class DelegatedAuthServiceResponse{
        public String return;   //true
    }*/
}