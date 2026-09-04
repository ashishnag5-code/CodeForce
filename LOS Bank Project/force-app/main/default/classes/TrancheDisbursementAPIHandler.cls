public with sharing class TrancheDisbursementAPIHandler {
    
    public static List<String> generateRequest(Object reqParam, Decimal netDisbursementAmount){
        List<String> lstString = new List<String>();
        Loan_Application__c loan=(Loan_Application__c)reqParam;
        TrancheDisbursementRequestWrapper requestWrapper = new TrancheDisbursementRequestWrapper();
        system.debug('paramsMap '+loan);
        requestWrapper.ReferenceNumber = IntegrationUtility.getReferenceId();
        if(loan.Branch_Master__c!=null){
            requestWrapper.TransactionBranch = Integer.valueOf(loan.Branch_Master__r.Account_Code__c);
        }
        requestWrapper.RequestId = requestWrapper.ReferenceNumber;
        requestWrapper.OriginatingChannel = System.Label.Integration_Channel;//'SFDC';

        BranchDisbursementDetailWrapper branchWrapper = new BranchDisbursementDetailWrapper();
        if(loan.OwnerId.getSObjectType() == Schema.User.getSObjectType()){
            List<User> owners = [SELECT Id, Employee_Code__c FROM User WHERE Id=:loan.OwnerId];
            if(owners!=null && owners.size()>0){
                branchWrapper.UserId = 23786;//Integer.valueOf(owners[0].Employee_Code__c);//RO User Id
            }
        }
        branchWrapper.AccountId = Long.valueOf(loan.LAN__c);
        Disbursement_Mode__mdt dbMode = Disbursement_Mode__mdt.getInstance(loan.Mode_of_Disbursement__c);
        branchWrapper.DisbursementMode=Integer.valueOf(dbMode.Code__c);
        branchWrapper.FromAccountNo = 250408455;
        branchWrapper.Narrative = loan.Narration__c;
        branchWrapper.UserReferenceNumber = requestWrapper.ReferenceNumber;
        requestWrapper.BranchDisbursementDetail = branchWrapper;

        SubSequentDisbursementDetailWrapper sequentWrapper = new SubSequentDisbursementDetailWrapper();
        sequentWrapper.AccountId = loan.LAN__c;
        sequentWrapper.SessionId = Integer.valueOf(loan.Disbursement_Session_Id__c);
        sequentWrapper.Comments = loan.Narration__c;
        sequentWrapper.DefinitionDate = (String.valueOf(loan.Disbursement_Date__c)).replace('-','');
        sequentWrapper.DisbursementAmount = netDisbursementAmount;//loan.Total_Loan_Amount__c;
        sequentWrapper.ReasonCode = 100;
        sequentWrapper.DisbursementMode=Integer.valueOf(dbMode.Code__c);

        requestWrapper.SubSequentDisbursementDetail = sequentWrapper;

        lstString.add(JSON.serializePretty(requestWrapper, false));   
        return lstString;
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }

    public class TrancheDisbursementRequestWrapper{
        public String ReferenceNumber;
        public Integer TransactionBranch;
        public String RequestId;
        public String OriginatingChannel;
        public BranchDisbursementDetailWrapper BranchDisbursementDetail;
        public SubSequentDisbursementDetailWrapper SubSequentDisbursementDetail;
    }

    public class BranchDisbursementDetailWrapper{
        public Integer UserId;
        public Long AccountId;
        public Integer DisbursementMode;
        public Long FromAccountNo;
        public String Narrative;
        public String UserReferenceNumber;
    }

    public class SubSequentDisbursementDetailWrapper{
        public String AccountId;
        public Integer SessionId;
        public String Comments;
        public String DefinitionDate;
        public Decimal DisbursementAmount;
        public Integer ReasonCode;
        public Integer DisbursementMode;
    }

    public class TrancheDisbursementResponseWrapper{
        @AuraEnabled public Integer HostDisbursementSessionId{get;set;}
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
}