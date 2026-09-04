public inherited sharing class AUSFLeadToCRMIntHandler implements IntegrationHandlerInterface {
    public static String[] generateRequest( Object params ){
        map<String,Object> paramsMap = (map<String,Object>)params;
        paramsMap.putAll(
            new map<String, Object>{
                'RequestId' => IntegrationUtility.getReferenceId()
        });

        return new String[]{ JSON.serialize( paramsMap ) };
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }

    public class LeadToCRMSuccessResopnse {
        public Cls_TransactionStatus TransactionStatus; //NOPMD - As per api spec
        public String IsSuccess; //NOPMD - As per api spec
        public String Message; //NOPMD - As per api spec
        public String LeadID; //NOPMD - As per api spec
    }
    public class Cls_TransactionStatus {
        public String ResponseCode; //NOPMD - As per api spec
        public String ResponseMessage; //NOPMD - As per api spec
        public Cls_ExtendedErrorDetails ExtendedErrorDetails; //NOPMD - As per api spec
    }
    public class Cls_ExtendedErrorDetails {
        public Cls_Messages[] messages;
    }
    public class Cls_Messages {
        public String code;
        public String message;
    }


    public class LeadToCRMFailureResopnse{
        public String ServiceExecutionStatus; //NOPMD - As per API specs
        public cls_Errors Errors; //NOPMD - As per API specs
    }

    public class cls_Errors {
        public cls_Error Error; //NOPMD - As per API specs
    }

    public class cls_Error {
        public String Code; //NOPMD - As per API specs
        public String Message; //NOPMD - As per API specs
    }
    
}