public with sharing class KarzaPNGBillHandler {
    public KarzaPNGBillHandler() {

    }

    public class KarzaPNGBillResponseWrapper{
        @AuraEnabled public String status_code {get;set;}
        @AuraEnabled public String request_id {get;set;}
        @AuraEnabled public KarzaPNGBillResult result {get;set;}
    }

    public class KarzaPNGBillResult{
        @AuraEnabled public String Bill_No {get;set;}
        @AuraEnabled public String Due_Date {get;set;}
        @AuraEnabled public String Bill_Amount {get;set;}
        @AuraEnabled public String mobile {get;set;}
        @AuraEnabled public String Customer_Address {get;set;}
        @AuraEnabled public String Bill_Date {get;set;}
        @AuraEnabled public String Email {get;set;}
        @AuraEnabled public String Customer_Name {get;set;}
    }
}