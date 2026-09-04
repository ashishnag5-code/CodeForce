public class NotepadResponseWrapper {
    @AuraEnabled public List<CustMemoDetails> CustMemoDetails;
    @AuraEnabled public List<MemoDetails> MemoDetails;
	@AuraEnabled public String MemoNumber;
    @AuraEnabled public TransactionStatusType TransactionStatusType;
    
    public class CustMemoDetails{
        @AuraEnabled public String MemoNumber;
        @AuraEnabled public String EndDate;
        @AuraEnabled public String MemoText;
        @AuraEnabled public String ReasonForMemo;
        @AuraEnabled public String Severity;
        @AuraEnabled public String StartDate;
    }
    
    public class MemoDetails{
        @AuraEnabled public String MemoNumber;
        @AuraEnabled public String EndDate;
        @AuraEnabled public String MemoText;
        @AuraEnabled public String ReasonForMemo;
        @AuraEnabled public String Severity;
        @AuraEnabled public String StartDate;
    }
    
    public class TransactionStatusType {
		@AuraEnabled public String ResponseCode;
		@AuraEnabled public String ResponseMessage;
		@AuraEnabled public ExtendedErrorDetails ExtendedErrorDetails;
	}
    
    public class ExtendedErrorDetails{
        @AuraEnabled public Messages messages;
    }
    
    public class Messages {
		@AuraEnabled public String code;
        @AuraEnabled public String message;
	}
}