public with sharing class PaymentIMPSAPIHandler {

    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Loan_Application__c loan;
        Payment__c paymentFavouring;
        Map<String,String> paramsMap=(Map<String,String>)reqParam;
        Map<String, String> accountTypes = new Map<String, String>{GlobalConstants.PAYMENT_ACCOUNT_TYPE_SAVING => '10', 
                                                                        GlobalConstants.PAYMENT_ACCOUNT_TYPE_SAVING => '11'};
        List<Loan_Application__c> loanApps = [SELECT Id,Pool_Txn_Reference_Number__c, Narration__c, General_Ledger__c, LAN__c, Schedule_Code__c,
                                                    Disbursement_Date__c, Total_Loan_Amount__c, Branch_Master__r.Account_Code__c,Dealer_Master__c,Dealer_Master__r.Dealer_Name__c,
                                                    (SELECT Id, CIF_No__c, Customer_Name__c FROM Applicants__r WHERE RecordType.DeveloperName=:GlobalConstants.APPLICANT_RECORD_TYPE)
                                                    FROM Loan_Application__c WHERE Id=:paramsMap.get('LoanId')];

        if(loanApps!=null && loanApps.size()>0){
            loan = loanApps[0];
        }
        List<Payment__c> paymentFavourings;
        paymentFavourings = [SELECT Id,Payment_Recipient__c, Beneficiary_Name__c, Net_Amount__c, Account_Number__c, IFSC_Code__c, Account_Type__c, Txn_Reference_Number__c, Payment_Favouring_Status__c
                                                    FROM Payment__c WHERE Id=:paramsMap.get('PaymentId')];
        if(paymentFavourings!=null && paymentFavourings.size()>0){
            paymentFavouring = paymentFavourings[0];
        }
        PaymentIMPSAPIRequestWrappper requestWrapper = new PaymentIMPSAPIRequestWrappper();
        requestWrapper.RemitterAccountNo = loan.General_Ledger__c;//'2201210944288380';
        requestWrapper.RemitterMMID = '';
        requestWrapper.RequestId  = IntegrationUtility.getApplicationRelatedReferenceId(loan.Id);
        if(paymentFavouring.Payment_Favouring_Status__c=='Failed' && paymentFavouring.Txn_Reference_Number__c!=null){
            requestWrapper.ReferenceNumber = paymentFavouring.Txn_Reference_Number__c;//'2837127312';
        }else{
            requestWrapper.ReferenceNumber = requestWrapper.RequestId;//'SFDC1069315ada7525f20632068da0f7fc95';
        }
        requestWrapper.OriginatingChannel = paramsMap.get('Channel');//GlobalConstants.IMPS_ORIGINATING_CHANNEL;//'CIB';
        requestWrapper.BeneficiaryAccountNo= String.valueOf(paymentFavouring.Account_Number__c);//'123456';
       // requestWrapper.BeneficiaryName = paymentFavouring.Beneficiary_Name__c;//'';
        
        //Change added by Samridhi - 16 Aug
		if(paymentFavouring.Payment_Recipient__c == 'Dealer'){
            requestWrapper.BeneficiaryName = loan.Dealer_Master__c!=null?loan.Dealer_Master__r.Dealer_Name__c:'';
        }
        else if(paymentFavouring.Payment_Recipient__c == 'Customer'){
            requestWrapper.BeneficiaryName = loan.Applicants__r!=null && loan.Applicants__r.size()>0?loan.Applicants__r[0].Customer_Name__c:'';
        }
        
        requestWrapper.CodMsgType = '';
        requestWrapper.CustomerId = loan.Applicants__r[0].CIF_No__c;//'24075326';
        requestWrapper.CodTxnType = '';
        requestWrapper.TransactionCurrency = GlobalConstants.IMPS_TRANSACTION_CURRENCY;//'1';
        requestWrapper.TransactionAmount= String.valueOf(paymentFavouring.Net_Amount__c);//'2.00';
        requestWrapper.RemitterAcctType= accountTypes.get(paymentFavouring.Account_Type__c);//'10';
        requestWrapper.RemitterMobileNo= '';
        requestWrapper.Remarks = GlobalConstants.IMPS_TRANSACTION_REMARKS;//'Money Transfer';
        requestWrapper.TransactionBranch= String.valueOf(loan.Branch_Master__r.Account_Code__c);//'2011';
        requestWrapper.BeneficiaryIFSCCode = paymentFavouring.IFSC_Code__c;//'UTIB0000010';
       // requestWrapper.RemitterName= paymentFavouring.Beneficiary_Name__c;//'SANKAR ARUMUGAM';
        
        //requestWrapper.RemitterName= 'AUSFB WHEELS LOAN DISBURSEMENT';
        //requestWrapper.RemitterName= 'AUSFB WHEELS LOAN DISBURSEMENT';
        requestWrapper.RemitterName = System.Label.IMPS_REMMITER_NAME;
        lstString.add(JSON.serializePretty(requestWrapper, false));  
        return lstString;
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }

    
    public class PaymentIMPSAPIRequestWrappper {
        public String RemitterAccountNo;    //2201210944288380
        public String RemitterMMID; //
        public String RequestId;    //SFDC1069315ada7525f20632068da0f7fc95
        public String OriginatingChannel;   //CIB
        public String ReferenceNumber;  //SFDC1069315ada7525f20632068da0f7fc95
        public String BeneficiaryAccountNo; //123456
        public String BeneficiaryName;  //
        public String CodMsgType;   //
        public String CustomerId;   //24075326
        public String CodTxnType;   //
        public String TransactionCurrency;  //1
        public String TransactionAmount;    //2.00
        public String RemitterAcctType; //10
        public String RemitterMobileNo; //9234567081
        public String Remarks;  //Money Transfer
        public String TransactionBranch;    //2011
        public String BeneficiaryIFSCCode;  //UTIB0000010
        public String RemitterName; //SANKAR ARUMUGAM
    }
    
    public class PaymentIMPSAPIResponseWrappper{
        @AuraEnabled public cls_TransactionStatusType TransactionStatusType{get;set;} 
        @AuraEnabled public String RetrievalReferenceNumber{get;set;}  //306117639834
    }
    
    public class cls_TransactionStatusType {
        @AuraEnabled public String ResponseCode{get;set;}  //0
        @AuraEnabled public String ResponseMessage{get;set;}   //Success
        @AuraEnabled public cls_ExtendedErrorDetails ExtendedErrorDetails{get;set;} 
    }
    
    public class cls_ExtendedErrorDetails {
        @AuraEnabled public cls_messages[] messages{get;set;} 
    }
    
    public class cls_messages {
        @AuraEnabled public String code{get;set;}  //0
        @AuraEnabled public String message{get;set;}  

    }
}