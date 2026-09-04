public class LOSPreApprovedOfferUpdateIntHandler implements IntegrationHandlerInterface{
    
    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        PreApprovedUpdateRequestWrapper objPreApprovedRequestWrapper = new PreApprovedUpdateRequestWrapper();
        objPreApprovedRequestWrapper.RequestId = IntegrationUtility.getReferenceId();
        objPreApprovedRequestWrapper.OriginatingChannel = 'SFDC';
        //objPreApprovedRequestWrapper.CustomerId = '24083775';
        objPreApprovedRequestWrapper.ItemType = String.valueOf(paramsMap.get('strItemType'));
        objPreApprovedRequestWrapper.OfferActive = String.valueOf(paramsMap.get('strOfferActive'));
        objPreApprovedRequestWrapper.ItemId = String.valueOf(paramsMap.get('strItemId'));
        lstString.add(JSON.serialize(objPreApprovedRequestWrapper));   
        return lstString;
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    public class PreApprovedUpdateRequestWrapper{
        public String RequestId;
        public String OriginatingChannel;
        public String ItemType;
        public String OfferActive;
        public String ItemId;
    }
    
    public class PreApprovedResponseWrapper{
        public cls_TransactionStatus TransactionStatus;
        public String OfferId;  //726254
    }
    
    public class cls_TransactionStatus {
        public String ResponseCode; //0
        public String ResponseMessage;  //Success
        public cls_ExtendedErrorDetails ExtendedErrorDetails;
    }
    
    public class cls_ExtendedErrorDetails {
        public cls_messages[] messages;
    }
    
    public class cls_messages {
        public Integer code;    //0
        public String message;  //Item has been updated successfully.
    }
}