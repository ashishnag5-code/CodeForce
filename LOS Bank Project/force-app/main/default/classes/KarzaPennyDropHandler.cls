public with sharing class KarzaPennyDropHandler {

    public class KarzaPennyDropResponseWrapper {
        public String statuscode;
        public String request_id;
        public BankTransactionResult result;


    }
    public class BankTransactionResult {
        public Boolean bankTxnStatus;
        public String accountNumber;
        public String ifsc;
        public String accountName;
        public String bankResponse;
    }

}