public class TransactionStatusCalloutHandler {
    
    public class TransactionStatusRequestWrapper{
        public String txnId{get;set;}
    }
    
    public class TransactionStatusResponseWrapper{
        @AuraEnabled public Boolean success{get;set;}
        @AuraEnabled public String status{get;set;}
        @AuraEnabled public String txnId{get;set;}
        @AuraEnabled public String errorMessage{get;set;}
        @AuraEnabled public String errorCode{get;set;}
        @AuraEnabled public String timestamp{get;set;}
    }

}