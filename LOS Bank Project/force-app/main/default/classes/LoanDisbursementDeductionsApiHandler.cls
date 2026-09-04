public with sharing class LoanDisbursementDeductionsApiHandler {
    public static List<String> generateRequest(Object reqParam, Decimal netDisbursementAmount){
        List<String> lstString = new List<String>();
        Loan_Application__c loan=(Loan_Application__c)reqParam;
        DisbursementDeductionsWrapper requestWrapper = new DisbursementDeductionsWrapper();
        system.debug('paramsMap '+loan);
        requestWrapper.AccountId = Long.valueOf(loan.LAN__c);
        requestWrapper.RequestId = IntegrationUtility.getReferenceId();
        requestWrapper.OriginatingChannel = System.Label.Integration_Channel;//'LOS';
        requestWrapper.DisbursementDate = String.valueOf(loan.Disbursement_Date__c);
        requestWrapper.ReferenceNumber = requestWrapper.RequestId;
        if(loan.Branch_Master__c!=null){
            requestWrapper.TransactionBranch = Integer.valueOf(loan.Branch_Master__r.Account_Code__c);
        }
        Disbursement_Mode__mdt dbMode = Disbursement_Mode__mdt.getInstance(loan.Mode_of_Disbursement__c);
        requestWrapper.DisbursementMode=Integer.valueOf(dbMode.Code__c);
        requestWrapper.DisbursementAmount=loan.Total_Loan_Amount__c;//netDisbursementAmount;//loan.Total_Loan_Amount__c;
    
        lstString.add(JSON.serializePretty(requestWrapper, false));   
        return lstString;
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
       
        

    public class DisbursementDeductionsWrapper{
        public Long AccountId;
        public String RequestId;
        public String OriginatingChannel;
        public String DisbursementDate;
        public String ReferenceNumber;
        public Integer TransactionBranch;
        public Integer DisbursementMode;
        public Decimal DisbursementAmount;

	}

    public class DisbursementDeductionResponseWrapper{
        public List<DeductionDetailsWrapper> DeductionDetails;
        @AuraEnabled public TransactionStatusWrapper TransactionStatus{get;set;}
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
        @AuraEnabled public String message{get;set;}
    }

    public class DeductionDetailsWrapper{
        public String SrlNumber;
        public String DeductionAmountInLocalCurrency;
        public String IsWaived;
        public String CtrSrlDednNo;
        public String FlgDueOn;
        public String IsSCDeductionAmortised;
        public String ServiceChargeName;
        public String DeductionMode;
        public Integer ConversionRateTransactionCurrency;
        public Integer ConversionRateAccountCurrency;
        public String DeductionCode;
        public String AccountCurrencyCode;
        public String TransactionCurrencyCode;
        public String LocalCurrencyCode;
        public String DeductionCurrencyCode;
        public String DeductionType;
        public Double DeductionAmountInTransactionCurrency;
        public Double DeductionAmountInAccountCurrency;
    }
}