public with sharing class casaDetailsHandler {
  
    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        CASADetailsRequestWrapper casaRequestWrapper = new CASADetailsRequestWrapper();
        casaRequestWrapper.StartDate = String.valueOf(paramsMap.get('StartDate'));
        casaRequestWrapper.RequestId = IntegrationUtility.getReferenceId();
       //casaRequestWrapper.RequestId =  '81273761231';
        casaRequestWrapper.OriginatingChannel = String.valueOf(paramsMap.get('OriginatingChannel'));
        casaRequestWrapper.ReferenceNumber ='1927398172381823';
        casaRequestWrapper.TransactionBranch = String.valueOf(paramsMap.get('TransactionBranch'));
        casaRequestWrapper.EndDate = String.valueOf(paramsMap.get('EndDate'));
        casaRequestWrapper.AccountNumber = String.valueOf(paramsMap.get('AccountNumber'));
        lstString.add(JSON.serialize(casaRequestWrapper));   
        return lstString;
    }

    public static List<String> generateLoanRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        LoanDetailsRequestWrapper loanRequestWrapper = new LoanDetailsRequestWrapper();
        loanRequestWrapper.ValueFromDate = String.valueOf(paramsMap.get('ValueFromDate'));
        loanRequestWrapper.RequestId = IntegrationUtility.getReferenceId();
        loanRequestWrapper.OriginatingChannel = String.valueOf(paramsMap.get('OriginatingChannel'));
        loanRequestWrapper.ReferenceNumber ='8713273617263';
        loanRequestWrapper.TransactionBranch = String.valueOf(paramsMap.get('TransactionBranch'));
        loanRequestWrapper.ValueToDate = String.valueOf(paramsMap.get('ValueToDate'));
        loanRequestWrapper.AccountNumber = String.valueOf(paramsMap.get('AccountNumber'));
        lstString.add(JSON.serialize(loanRequestWrapper));   
        return lstString;
    }

    public static  List<String> generateLoanInquiryRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        LoanInquiryRequestWrapper loanRequestWrapper = new LoanInquiryRequestWrapper();
        loanRequestWrapper.RequestId = IntegrationUtility.getReferenceId();
        loanRequestWrapper.OriginatingChannel = String.valueOf(paramsMap.get('OriginatingChannel'));
        loanRequestWrapper.ReferenceNumber =IntegrationUtility.getReferenceId();//'SFDCd35b180d1a58a804cc0a548a4f673f10';
        loanRequestWrapper.TransactionBranch = String.valueOf(paramsMap.get('TransactionBranch'));
        loanRequestWrapper.AccountNumber = String.valueOf(paramsMap.get('AccountNumber'));
        lstString.add(JSON.serialize(loanRequestWrapper));   
        return lstString;
    }

    public static List<String> generateODLimitEquiryRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        ODLimitInquiryRequestWrapper odRequestWrapper = new ODLimitInquiryRequestWrapper();
        odRequestWrapper.Channel = String.valueOf(paramsMap.get('Channel'));
        odRequestWrapper.ReferenceNo =IntegrationUtility.getReferenceId();//'SFDCd35b180d1a58a804cc0a548a4f673f10';
        odRequestWrapper.TransactionBranch = String.valueOf(paramsMap.get('TransactionBranch'));
        odRequestWrapper.accountNo = String.valueOf(paramsMap.get('accountNo'));
        lstString.add(JSON.serialize(odRequestWrapper));   
        return lstString;
    }


    public class CASADetailsRequestWrapper{
       
        public String StartDate;
        public String RequestId;
        public String OriginatingChannel;
        public String ReferenceNumber;
        public String TransactionBranch;
        public String EndDate;
        public String AccountNumber;
    }

    public class CASADetailsResponseWrapper{
        public String TransactionAmount;
        public String TransactionType;
        public String TxnId;
        public String Description;
        public String RunningTotal;
        public String ChequeNumber;
        public String ValueDate;
        public String TransactionBranch;
        public String TransactionDate;
    }

    public class LoanDetailsRequestWrapper{
       
        public String ValueToDate;
        public String RequestId;
        public String OriginatingChannel;
        public String ReferenceNumber;
        public String TransactionBranch;
        public String ValueFromDate;
        public String AccountNumber;
    }
    
    public class LoanInquiryRequestWrapper{
        public String RequestId;
        public String OriginatingChannel;
        public String ReferenceNumber;
        public String TransactionBranch;
        public String AccountNumber;
    }
    

    public class LoanDetailsResponseWrapper{
        public String AccountID;
        public String DebitedAmount;
        public String CreditedAmount;
        public String RunningBalance;
        public String TxnDate;
        public String ValueDate;
        
    }

    public class ODLimitInquiryRequestWrapper{
        public String Channel;
        public String ReferenceNo;
        public String TransactionBranch;
        public String accountNo;
    }
    
}