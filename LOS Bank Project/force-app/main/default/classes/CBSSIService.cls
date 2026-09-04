public with sharing class CBSSIService implements IntegrationHandlerInterface{

    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Loan_Application__c> paramsMap=(Map<String,Loan_Application__c>)reqParam;
        CBSSIServiceRequestWrapper wrapper = new CBSSIServiceRequestWrapper();

        Loan_Application__c loan = paramsMap.get('LoanApplication');
        wrapper.RequestId = IntegrationUtility.getReferenceId();
        wrapper.ReferenceNumber = wrapper.RequestId;
        wrapper.OriginatingChannel = Label.CBS_SI;
        if(loan.Branch_Master__c!=null){
            wrapper.TransactionBranch = Integer.valueOf(loan.Branch_Master__r.Account_Code__c);
        }
        wrapper.OperationMode = 'A';
        wrapper.LoanAccountNumber = loan.LAN__c;
        wrapper.RemitterAccountNumber = loan.Repayment_Account_Number__c;
        wrapper.ArrearTypeDetails = 'cpmin';
        lstString.add(JSON.serialize(wrapper));   
        return lstString;
    }

    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    public class CBSSIServiceRequestWrapper{
        public String RequestId;
        public String ReferenceNumber;
        public String OriginatingChannel;
        public Integer TransactionBranch;
        public String OperationMode;
        public String LoanAccountNumber;
        public String RemitterAccountNumber;
        public String ArrearTypeDetails;
    }

    public class CBSSIServiceResponseWrapper{
        @AuraEnabled public TransactionStatusWrapper TransactionStatus{get;set;}
    }

    public class TransactionStatusWrapper{
        @AuraEnabled public String ResponseCode{get;set;}
        @AuraEnabled public String ResponseMessage{get;set;}
        @AuraEnabled public ExtendedErrorDetailsWrapper ExtendedErrorDetails{get;set;}
        @AuraEnabled public List<ValidationErrorWrapper> ValidationErrors{get;set;}
    }

    public class ExtendedErrorDetailsWrapper{
        @AuraEnabled public List<MessagesWrapper> messages{get;set;}
    }

    public class ValidationErrorWrapper{
        @AuraEnabled public String ErrorMessage{get;set;}
    }

    public class MessagesWrapper{
        @AuraEnabled public String code{get;set;}
        @AuraEnabled public String message{get;set;}

    }
    
}