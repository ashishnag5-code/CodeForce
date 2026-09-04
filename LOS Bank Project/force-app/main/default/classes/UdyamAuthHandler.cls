public class UdyamAuthHandler implements IntegrationHandlerInterface{

    public class UdyamRequestWrapper{
        public String guid;
        public String channel;
        public String consent;
        public String udyamRegistrationNo;
        public String isPDFRequired;
    }

    public class UdyamResponseWrapper{
        @AuraEnabled public UdyamResponseWrapperResult result;
    }
    
    public class UdyamResponseWrapperResult{
        @AuraEnabled public String udyamRegistrationNo;
        @AuraEnabled public String dateOfRegistration;
        @AuraEnabled public profile profile;
        @AuraEnabled public OfficialAddress officialAddress;
        @AuraEnabled public BankDetails bankDetails;
        @AuraEnabled public List<Industry> industry;
    }
    
    public class Profile {
        @AuraEnabled public String name;
        @AuraEnabled public String ownerName;
        @AuraEnabled public String pan;
        @AuraEnabled public String gstnStatus;
        @AuraEnabled public String enterpriseType;
        @AuraEnabled public String organizationType;
        @AuraEnabled public String dateOfIncorporation;
    }
    
    public class OfficialAddress {
        @AuraEnabled public String flat{get;set;}
        @AuraEnabled public String premises{get;set;}
        @AuraEnabled public String village{get;set;}
        @AuraEnabled public String block{get;set;}
        @AuraEnabled public String road{get;set;}
        @AuraEnabled public String city{get;set;}
        @AuraEnabled public String state{get;set;}
        @AuraEnabled public String pincode{get;set;}
        @AuraEnabled public String district{get;set;}
        @AuraEnabled public String mobile{get;set;}
        @AuraEnabled public String email{get;set;}
    }
    
    public class Industry {
        @AuraEnabled public String subSector;
        @AuraEnabled public String activity;
        @AuraEnabled public String nicCode;
        @AuraEnabled public String industry;
    }
    
    public class BankDetails {
        @AuraEnabled public String bank;
        @AuraEnabled public String ifsc;
        @AuraEnabled public String acNo;
    }

    public class UIResponse{
        public UdyamResponseWrapperResult Response;
        public Object[] metadata;
        public Integer statusCode;
    }
    
    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        UdyamRequestWrapper requestWrapper = new UdyamRequestWrapper();
        requestWrapper.guid = IntegrationUtility.getReferenceId();
        requestWrapper.Channel = Label.UdyamAuthChannel;
        requestWrapper.udyamRegistrationNo = String.valueOf(paramsMap.get('udyamNo'));
        requestWrapper.Consent = 'Y';
        requestWrapper.isPDFRequired = 'N';
        lstString.add(JSON.serialize(requestWrapper));   
        return lstString;
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }

    public static UdyamResponseWrapper parse(String json) {
		return (UdyamResponseWrapper) System.JSON.deserialize(json, UdyamResponseWrapper.class);
	}
}