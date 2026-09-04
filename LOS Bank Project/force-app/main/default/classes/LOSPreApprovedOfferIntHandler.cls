public class LOSPreApprovedOfferIntHandler implements IntegrationHandlerInterface{
    
    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Map<String,Object> paramsMap=(Map<String,Object>)reqParam;
        PreApprovedRequestWrapper objPreApprovedRequestWrapper = new PreApprovedRequestWrapper();
        objPreApprovedRequestWrapper.RequestId = IntegrationUtility.getReferenceId();
        objPreApprovedRequestWrapper.OriginatingChannel = Label.PreApproved_Channel;
        //objPreApprovedRequestWrapper.CustomerId = '24083775';
        objPreApprovedRequestWrapper.CustomerId = String.valueOf(paramsMap.get('strCustomerId'));
        lstString.add(JSON.serialize(objPreApprovedRequestWrapper));   
        return lstString;
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    public class PreApprovedRequestWrapper{
        public String RequestId;
        public String OriginatingChannel;
        public String CustomerId;
    }
    
    public class PreApprovedResponseWrapper{
        public cls_TransactionStatus TransactionStatus;
        public cls_CRMQueryResults[] CRMQueryResults;
    }
    
    public class cls_TransactionStatus {
        public String ResponseCode; //0
        public String ResponseMessage;  //Success
        public cls_ExtendedErrorDetails ExtendedErrorDetails;
    }
    
    public class cls_ExtendedErrorDetails {
        public cls_messages[] messages;
    }
    
    public class cls_messages {
        public Integer code;    //0
        public cls_message message;
    }
    
    public class cls_message {
    }
    
    public class cls_CRMQueryResults {
        public Integer RowNumber;   //1
        public String CustomerId;   //24083775
        public String OfferId;  //726254
        public String OfferName;    //Instant New Car Loan Rs 3500000 @7.99% p.a.
        public Integer ProductId;   //10204
        public Double FirstOfferAmount;    //40000
        public String ValidFrom;    //2022-03-03T18:30:00+05:30
        public String ValidTill;    //2029-12-16T18:30:00+05:30
        public Integer RatingID;    //2
        public String OfferDescription;
        public String Image_Offers;
        public String Avail;
        public String CurrencyID;   //INR
        public String TermsAndCondition;
        public String OfferIsActive;    //true
        public String MaxLoanTenureinMonths;    //36
        public String MinLoanTenureinMonths;    //12
        public String RateofInterest;   //21.000000
        public String Scheme;   //Scheme TT
        public String Royale;
        public String Employee;
        public String OfferType;
        public String Occupation;
        public String Location;
        public String RepaymentMode;
        public String CustomerNameinBankAccount;
        public String IFSCcode;
        public String BankBranch;
        public String BankName;
        public String off_ex1_8;    //ACC ACC ACC
        public String Mobile;   //6775677575
    }
}