public with sharing class LoanDisbursementDetailsApiHandler {
    
    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Loan_Application__c loan=(Loan_Application__c)reqParam;
        LoanDisbursementRequestWrapper requestWrapper = new LoanDisbursementRequestWrapper();
        system.debug('paramsMap '+loan);
        if(loan.Branch_Master__c!=null){
            requestWrapper.TransactionBranch = Integer.valueOf(loan.Branch_Master__r.Account_Code__c);
        }
        requestWrapper.RequestId = IntegrationUtility.getReferenceId();
        requestWrapper.ReferenceNumber = requestWrapper.RequestId;
        requestWrapper.OriginatingChannel = System.Label.Integration_Channel;//'LOS';
        requestWrapper.AccountId = loan.LAN__c;
    
        lstString.add(JSON.serializePretty(requestWrapper, false));   
        return lstString;
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
       
        

    public class LoanDisbursementRequestWrapper{
        public String AccountId;
        public String RequestId;
        public String OriginatingChannel;
        public String ReferenceNumber;
        public Integer TransactionBranch;
	}

    public class LoanDisbursementResponseWrapper{
        @AuraEnabled public TransactionStatusWrapper TransactionStatus{get;set;}
        @AuraEnabled public Integer AccountBranchCode{get;set;}
        @AuraEnabled public Integer AccountProduct{get;set;}
        @AuraEnabled public Integer AccountCurrency{get;set;}
        @AuraEnabled public Integer AccountScheduleCode{get;set;}
        @AuraEnabled public Integer AccountTerm{get;set;}       
        @AuraEnabled public Decimal SanctionedAmount{get;set;}
        @AuraEnabled public Decimal DisbursementAmount{get;set;}
        @AuraEnabled public Integer ScheduleDrawnOn{get;set;}
        @AuraEnabled public String ProducedId{get;set;}
	}

    public class TransactionStatusWrapper{
        @AuraEnabled public String ResponseMessage{get;set;}
        @AuraEnabled public String ResponseCode{get;set;}
        @AuraEnabled public ExtendedErrorDetailsWrapper ExtendedErrorDetails{get;set;}
    }

    public class ExtendedErrorDetailsWrapper{
        @AuraEnabled public List<MessagesWrapper> messages{get;set;}
    }

    public class MessagesWrapper{
        @AuraEnabled public Integer code{get;set;}
        @AuraEnabled public String message{get;set;}
    }
    
}