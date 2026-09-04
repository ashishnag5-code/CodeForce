public with sharing virtual class EmailVerificationWrapper {
    
    public class GenerateOtpWrapper {
        @AuraEnabled public String requestId {get;set;}
		@AuraEnabled public String channel   {get;set;}
		@AuraEnabled public String email     {get;set;}
    }

    public class VerifyOtpWrapper {
        @AuraEnabled public String requestId {get;set;}
		@AuraEnabled public String channel   {get;set;}
		@AuraEnabled public String otp       {get;set;}
    }

    public class ResponseWrapper {
        @AuraEnabled public Result result     {get;set;}
		@AuraEnabled public String requestId  {get;set;}
		@AuraEnabled public String statusCode {get;set;}
    }

    public class Result {
		@AuraEnabled public String message  {get;set;}
    }    
}