public with sharing class LoanDetailsHandler {

    public static List<String> generateLoanODDetails(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        LoanDetailsRequestWrapper loanRequestWrapper = new LoanDetailsRequestWrapper();
        
        loanRequestWrapper.RequestId = IntegrationUtility.getReferenceId();
        loanRequestWrapper.Channel = String.valueOf(paramsMap.get('Channel'));
        loanRequestWrapper.ReferenceNumber =IntegrationUtility.getReferenceId();
        loanRequestWrapper.TransactionBranch = String.valueOf(paramsMap.get('TransactionBranch'));
        loanRequestWrapper.CustomerId = String.valueOf(paramsMap.get('CustomerId'));
        lstString.add(JSON.serialize(loanRequestWrapper));   
        return lstString;
    }





    public class LoanDetailsRequestWrapper{
       
        public String CustomerId;
        public String RequestId;
        public String ReferenceNumber;
        public String TransactionBranch;
        public String Channel;
     
    }
}