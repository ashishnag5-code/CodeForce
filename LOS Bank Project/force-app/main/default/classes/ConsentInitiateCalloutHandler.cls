public with sharing class ConsentInitiateCalloutHandler {
    
    public class ConsentInitiateResposeWrapper {
        @AuraEnabled public String consentHandle{get;set;}
        @AuraEnabled public String redirectURL{get;set;}
        @AuraEnabled public String status{get;set;}
        @AuraEnabled public String txnId{get;set;}
        @AuraEnabled public String errorMessage{get;set;}
        @AuraEnabled public String errorCode{get;set;}
    }
    
    public class ConsentInitiateRequestWrapper {
        public String profileId{get;set;}
        public String userId{get;set;}
        public String txnId{get;set;}
        public String returnUrl{get;set;}
        public List<String> fiTypes{get;set;}
        public String startDate{get;set;}
        public String endDate{get;set;}
        public List<PassThroughParamsWrapper> passThroughParams{get;set;}
        public OptionalParamsWrapper optionalParams{get;set;}
        public AdditionalParamsWrapper additionalParams{get;set;}
        
    }
    
    public class PassThroughParamsWrapper{
        public DataInnerWrapper data{get;set;}
        public String target{get;set;}
    }
    
    public class DataInnerWrapper{
        public String facility{get;set;}
        public String loanType{get;set;}
        public String loanAmount{get;set;}
        public String todAllowed{get;set;}
        public String yearMonthTo{get;set;}
        public String employerName{get;set;}
        public String loanDuration{get;set;}
        public String yearMonthFrom{get;set;}
        public String processingType{get;set;}
        public String acceptancePolicy{get;set;}
        public String uploadingScannedStatements{get;set;}
    }
    
    public class OptionalParamsWrapper{
        public String consentNotification{get;set;}
        public String dataNotification{get;set;}
        public String reportNotification{get;set;}
    }
    
    public class AdditionalParamsWrapper{
        public String routingUrl{get;set;}
        public String sourceSystem{get;set;}
    }
    

}