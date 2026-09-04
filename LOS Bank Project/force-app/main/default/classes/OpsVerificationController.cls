public without sharing class OpsVerificationController {
    
    public class OpsBaseVerificationWrapper{
        @AuraEnabled public Boolean isCaseSummaryVerified{get;set;}
        @AuraEnabled public Boolean isAssetDetailsVerified{get;set;}
        @AuraEnabled public Boolean isSourcingVerified{get;set;}
        public OpsBaseVerificationWrapper(){
            this.isCaseSummaryVerified = false;
            this.isAssetDetailsVerified = false;
            this.isSourcingVerified = false;
        }
    }
    
    public static void setBaseOpsVerification(Map<Id, SObject> oldRecords, Map<Id, SObject> newRecords){
        Map<Id, Loan_Application__c> newApplicationMap = (Map<Id, Loan_Application__c>) newRecords;
        Map<Id, Loan_Application__c> oldApplicationMap = (Map<Id, Loan_Application__c>) oldRecords;
        for(Id loanId : newApplicationMap.keySet()){
            if((oldApplicationMap.get(loanId).Stage__c != newApplicationMap.get(loanId).Stage__c) && newApplicationMap.get(loanId).Stage__c=='Ops Maker'){
                newApplicationMap.get(loanId).Ops_Verification__c = JSON.serializePretty(new OpsBaseVerificationWrapper(), false);
            }
        }
        
    }

}