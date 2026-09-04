/**
 * Created by ngundurao on 03/11/22.
 */

 public with sharing class EmailVerificationResponseWrapper {
    @AuraEnabled public Result result;
    @AuraEnabled public String error;

    public class Data {
        @AuraEnabled public Boolean disposable;
        @AuraEnabled public Boolean webmail;
        @AuraEnabled public Boolean result;
        @AuraEnabled public Boolean accept_all;
        @AuraEnabled public Boolean smtp_check;
        @AuraEnabled public Boolean regexp;
        @AuraEnabled public Boolean mx_records;
        @AuraEnabled public String email;
        public Data(){
            disposable = false;
            webmail = false;
            result = false;
            accept_all = false;
            smtp_check = false;
            regexp = false;
            mx_records = false;
            email = '';
        }
    }

    public class Result {
        @AuraEnabled public Data data;
        public Result(){
            data = new Data();
        }
    }
}