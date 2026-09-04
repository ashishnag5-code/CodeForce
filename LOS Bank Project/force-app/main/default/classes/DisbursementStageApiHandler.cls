public with sharing class DisbursementStageApiHandler {

    public static List<String> generateRequest(Object reqParam, Decimal netDisbursementAmount){
        List<String> lstString = new List<String>();
        Map<String,String> paramsMap =(Map<String,String>)reqParam;
        String recordId = paramsMap.get('LoanId');
        List<Loan_Application__c> loanApps = [SELECT Id, Branch_Master__c, Branch_Master__r.Account_Code__c, LAN__c, Schedule_Code__c,
                                                    Disbursement_Date__c, Total_Loan_Amount__c
                                                    FROM Loan_Application__c WHERE Id=:recordId];
        Loan_Application__c loan=loanApps[0];
        DisbursementStageRequestWrappper requestWrapper = new DisbursementStageRequestWrappper();
        system.debug('paramsMap '+loan);
        requestWrapper.AccountId = Long.valueOf(loan.LAN__c);
        requestWrapper.RequestId = IntegrationUtility.getReferenceId();
        requestWrapper.OriginatingChannel = paramsMap.get('Channel');//'LOS';
        requestWrapper.ReferenceNumber = requestWrapper.RequestId;
        requestWrapper.ScheduleTypeCode = Integer.valueOf(loan.Schedule_Code__c);
        if(loan.Branch_Master__c!=null){
            requestWrapper.TransactionBranch = Integer.valueOf(loan.Branch_Master__r.Account_Code__c);
        }
        requestWrapper.DefinitionDate = String.valueOf(loan.Disbursement_Date__c);
        requestWrapper.DisbursementAmount = loan.Total_Loan_Amount__c; //netDisbursementAmount;//loan.Total_Loan_Amount__c;
        requestWrapper.DebitTypeDeductionAmount = 0;

        lstString.add(JSON.serializePretty(requestWrapper, false));   
        return lstString;
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }

    public class DisbursementStageRequestWrappper{
        public Long AccountId;
        public String RequestId;
        public String OriginatingChannel;
        public String ReferenceNumber;
        public Integer ScheduleTypeCode;
        public Integer TransactionBranch;
        public String DefinitionDate;
        public Decimal DisbursementAmount;
        public Decimal DebitTypeDeductionAmount;
    }

    public class DisbursementStageResponseWrappper{
        @AuraEnabled public TransactionStatusWrapper TransactionStatus{get;set;}
        @AuraEnabled public String SessionId{get;set;}
    }

    public class TransactionStatusWrapper{
        @AuraEnabled public String ResponseCode{get;set;}
        @AuraEnabled public String ResponseMessage{get;set;}
        @AuraEnabled public ExtendedErrorDetailsWrapper ExtendedErrorDetails{get;set;}
    }

    public class ExtendedErrorDetailsWrapper{
        @AuraEnabled public List<MessageWrapper> messages{get;set;}
    }

    public class MessageWrapper{
        @AuraEnabled public Integer code{get;set;}
        @AuraEnabled public Integer message{get;set;}
    }
}