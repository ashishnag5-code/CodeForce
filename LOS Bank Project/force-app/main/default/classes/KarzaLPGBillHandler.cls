public with sharing class KarzaLPGBillHandler {
    public KarzaLPGBillHandler() {

    }

    public class KarzaLPGBillResponseWrapper{
        @AuraEnabled public String status_code {get;set;}
        @AuraEnabled public String request_id {get;set;}
        @AuraEnabled public KarzaLPGBillResult result {get;set;}
    }

    public class KarzaLPGBillResult{
        @AuraEnabled public String status;
        @AuraEnabled public String ApproximateSubsidyAvailed {get;set;}
        @AuraEnabled public String SubsidizedRefillConsumed {get;set;}
        @AuraEnabled public String pin {get;set;}
        @AuraEnabled public String ConsumerEmail {get;set;}
        @AuraEnabled public String DistributorCode {get;set;}
        @AuraEnabled public String BankName {get;set;}
        @AuraEnabled public String IFSCCode {get;set;}
        @AuraEnabled public String AadhaarNo {get;set;}
        @AuraEnabled public String ConsumerContact {get;set;}
        @AuraEnabled public String DistributorAddress {get;set;}
        @AuraEnabled public String ConsumerName {get;set;}
        @AuraEnabled public String ConsumerNo {get;set;}
        @AuraEnabled public String DistributorName {get;set;}
        @AuraEnabled public String BankAccountNo {get;set;}
        @AuraEnabled public String GivenUpSubsidy {get;set;}
        @AuraEnabled public String ConsumerAddress {get;set;}
        @AuraEnabled public String LastBookingDate {get;set;}
        @AuraEnabled public String TotalRefillConsumed {get;set;}
    }
}