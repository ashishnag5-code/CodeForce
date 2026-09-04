public class LOSKarzaAddressMatchIntHandler implements IntegrationHandlerInterface{
    
    public static List<String> generateRequest(Object reqParam){
        return new List<String>();
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    public class AddressMatchRequestWrapper{
        public String requestId;
        public String channel;
        public String consent;
        public AddressMatchSourceRequestWrapper source;
        public AddressMatchTargetRequestWrapper target;
        public ClientDataWrapper clientData;
    }

    public class AddressMatchSourceRequestWrapper{
        public NameRequestWrapper name;
        public List<RelationNameRequestWrapper> relationNames;
        public List<AddressRequestWrapper> addresses;
        public String dob;
    }

    public class AddressMatchTargetRequestWrapper{
        public String referenceId;
        public NameRequestWrapper name;
        public List<RelationNameRequestWrapper> relationNames;
        public List<AddressRequestWrapper> addresses;
        public String dob;
    }

    public class NameRequestWrapper{
        public String first = '';
        public String middle = '';
        public String last = '';

    }

    public class RelationNameRequestWrapper{
        public String relationReference;
        public NameRequestWrapper name;
    }

    public class AddressRequestWrapper{
        public String addressLine1 = '';
        public String addressLine2 = '';
        public String city ='';
        public String locality = '';
        public String state = '';
        public String district = '';
        public String pincode = '';
        public String country = '';
    }

    @TestVisible
    public class AddressMatchResponseWrapper{
        @AuraEnabled public Integer statusCode {get;set;}
        @AuraEnabled public String requestId {get;set;}
        @AuraEnabled public AddressMatchResponseWrapperResult result{get;set;}
    }

    @TestVisible
    public class AddressMatchResponseWrapperResult{
        @AuraEnabled public List<AddressMatchResponseWrapperFlag> flags {get;set;}
    }

    @TestVisible
    public class AddressMatchResponseWrapperFlag{
        @AuraEnabled public AddressMatchResponseWrapperAddress address {get;set;}
    }

    @TestVisible
    public class AddressMatchResponseWrapperAddress{
        @AuraEnabled public String matchType {get;set;}
        @AuraEnabled public List<AddressMatchResponseWrapperScore> scores {get;set;}
    }

    @TestVisible
    public class AddressMatchResponseWrapperScore{
        @AuraEnabled public Decimal score {get;set;}
        @AuraEnabled public String refernce1 {get;set;}
        @AuraEnabled public Boolean match {get;set;}
        @AuraEnabled public String refernce2 {get;set;}
    }
    

    @TestVisible
    public class ClientDataWrapper{
        public String caseId {get;set;}
    }
}