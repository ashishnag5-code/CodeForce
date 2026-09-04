public class DownloadReportCalloutHandler {
    
    public class DownloadReportRequestWrapper{
        public String txnId{get;set;}
        public String type{get;set;}
        public String format{get;set;}
    }
    
    public class DownloadReportResponseWrapper{
        @AuraEnabled public Boolean success{get;set;}
        @AuraEnabled public String status{get;set;}
        @AuraEnabled public String txnId{get;set;}
        @AuraEnabled public String errorMessage{get;set;}
        @AuraEnabled public String errorCode{get;set;}
        @AuraEnabled public String timestamp{get;set;}
        @AuraEnabled public Object report{get;set;}
        
    }

}