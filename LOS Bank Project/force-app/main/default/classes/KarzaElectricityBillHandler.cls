public with sharing class KarzaElectricityBillHandler{
    
    @TestVisible
    public class KarzaElectricityBillRequestWrapper{
        public String consent;
        public String service_provider;
        public String consumer_id;
        public String ReqId;
        public String Channel;
    }

    @TestVisible
    public class KarzaElectricityBillResponseWrapper{
        @AuraEnabled public String status_code {get;set;}
        @AuraEnabled public String request_id {get;set;}
        @AuraEnabled public KarzaElectricityBillResult result {get;set;}
    }

    @TestVisible
    public class KarzaElectricityBillResult{
        @AuraEnabled public String address {get;set;}
        @AuraEnabled public String amount_payable {get;set;}
        @AuraEnabled public String bill_amount {get;set;}
        @AuraEnabled public String bill_date {get;set;}
        @AuraEnabled public String bill_due_date {get;set;}
        @AuraEnabled public String bill_issue_date {get;set;}
        @AuraEnabled public String bill_no {get;set;}
        @AuraEnabled public String consumer_name {get;set;}
        @AuraEnabled public String consumer_number {get;set;}
        @AuraEnabled public String email_address {get;set;}
        @AuraEnabled public String mobile_number {get;set;}
        @AuraEnabled public String total_amount {get;set;}
    }
}