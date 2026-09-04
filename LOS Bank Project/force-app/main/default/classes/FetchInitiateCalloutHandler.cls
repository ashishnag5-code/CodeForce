public with sharing class FetchInitiateCalloutHandler {
    public class FetchInitiateRequestWrapper{
        public String userId{get;set;}
        public String profileId{get;set;}
        public String txnId{get;set;}
        public List<AccountInnerWrapper> accounts{get;set;}
    }
    
    public class AccountInnerWrapper{
        public String fipId{get;set;}
        public String linkRefNumber{get;set;}
        public String fiType{get;set;}
        public AccountInnerWrapper(String fipId, STring linkRefNumber, String fiType) {
            this.fipId = fipId;
            this.linkRefNumber = linkRefNumber;
            this.fiType = fiType;
        }
    }
    
    public class FetchInitiateResponseWrapper{
        @AuraEnabled public String consentHandle{get;set;}
        @AuraEnabled public String redirectURL{get;set;}
        @AuraEnabled public String status{get;set;}
        @AuraEnabled public String txnId{get;set;}
        @AuraEnabled public String errorMessage{get;set;}
        @AuraEnabled public String errorCode{get;set;}
        @AuraEnabled public String timestamp{get;set;}
        
    }

}