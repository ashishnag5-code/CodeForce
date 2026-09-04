public with sharing class CartStatementIntegrationHandler {
    

    public static  List<String> generateCartStatementRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        CartStatementWrapper cartRequestWrapper = new CartStatementWrapper();
        cartRequestWrapper.RequestId = String.valueOf(paramsMap.get('RequestId'));
        cartRequestWrapper.Channel = String.valueOf(paramsMap.get('Channel'));
        cartRequestWrapper.AccountNumber =  String.valueOf(paramsMap.get('AccountNumber'));
        cartRequestWrapper.CustomerName = String.valueOf(paramsMap.get('CustomerName'));
        cartRequestWrapper.EntityName = String.valueOf(paramsMap.get('EntityName'));
        cartRequestWrapper.BankName = String.valueOf(paramsMap.get('BankName'));
        cartRequestWrapper.AccountType = String.valueOf(paramsMap.get('AccountType'));
        cartRequestWrapper.FromDate = String.valueOf(paramsMap.get('FromDate'));
        cartRequestWrapper.EndDate = String.valueOf(paramsMap.get('EndDate'));
       // cartRequestWrapper.TransactionInquiryDetailsType = String.valueOf(paramsMap.get('TransactionInquiryDetailsType'));

        lstString.add(JSON.serialize(cartRequestWrapper));   
        return lstString;
    }




    public class CartStatementWrapper{
       
        public String RequestId;
        public String Channel;
        public String AccountNumber;
        public String CustomerName;
        public String EntityName;
        public String BankName;
        public String AccountType;
        public String FromDate;
        public String EndDate;
      //  public String TransactionInquiryDetailsType;

    }


    public class CartStatementResponseWrapper{
        public String docId;
        public String status;
        public String message;
        public String periodStart;
        public String periodEnd;
        public String documents;
        public String fileName;
        public String uploadTime;
        public String ocrFile;
        public String fileCount;
        public String totalPages;
        public String error;


    }
}