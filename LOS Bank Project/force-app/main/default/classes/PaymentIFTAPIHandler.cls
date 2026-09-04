public with sharing class PaymentIFTAPIHandler {

    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Loan_Application__c loan;
        Payment__c paymentFavouring;
        Map<String,String> paramsMap=(Map<String,String>)reqParam;
        Boolean isCheque = Boolean.valueOf(paramsMap.get('isCheque')) ; // SFAU-5479 - Kunal 
        List<Loan_Application__c> loanApps = [SELECT Id, Narration__c, Pool_Txn_Reference_Number__c, General_Ledger__c, LAN__c, Schedule_Code__c, Branch_Master__r.Account_Code__c,
                                                    Disbursement_Date__c, Total_Loan_Amount__c, Branch_Master__c, is_Pool_Disbursement_Successful__c
                                                    FROM Loan_Application__c WHERE Id=:paramsMap.get('LoanId')];
        List<Payment__c> paymentFavourings;
        if(paramsMap.get('IsPoolDisbursement')!='Yes'){
            paymentFavourings = [SELECT Id,Payment_Mode__c, Beneficiary_Name__c, Net_Amount__c, Txn_Reference_Number__c, Account_Number__c, IFSC_Code__c, Payment_Favouring_Status__c
                                                    FROM Payment__c WHERE Id=:paramsMap.get('PaymentId')];
        }else{ // SFAU-5479 - Kunal 
            List<String> paymentModes = isCheque ? Label.ChequePaymentModes.split(';') : Label.NonChequePaymentModes.split(';');
            paymentFavourings = [SELECT Id,Is_Cheque_Pool_Disburse_Successful__c,Is_Pool_Disbursement_Successful__c,Pool_Txn_Cheque_Reference_Number__c,Pool_Txn_Reference_Number__c, Payment_Mode__c, Beneficiary_Name__c, Net_Amount__c, Txn_Reference_Number__c, Account_Number__c, IFSC_Code__c, Payment_Favouring_Status__c
            FROM Payment__c WHERE Payment_Mode__c IN: paymentModes AND Margin_Money_Action__c != 'Yes' AND Loan_Application__c =: paramsMap.get('LoanId')  ];
        }
        if(loanApps!=null && loanApps.size()>0){
            loan = loanApps[0];
        }
        if(paymentFavourings!=null && paymentFavourings.size()>0){
            paymentFavouring = paymentFavourings[0];
        }
        PaymentIFTAPIRequestWrappper requestWrapper = new PaymentIFTAPIRequestWrappper();
        //requestWrapper.UserReferenceNumber = IntegrationUtility.getApplicationRelatedReferenceId(loan.Id);//'2837127312';
        requestWrapper.ToAccountCurrency = GlobalConstants.IFT_TO_ACCOUNT_CURRENCY;//'1';
        requestWrapper.Channel = paramsMap.get('Channel');//GlobalConstants.IFT_CHANNEL;//'APES';
        requestWrapper.FromAccountBranch = String.valueOf(loan.Branch_Master__r.Account_Code__c);
        requestWrapper.ToAccountBranch = '';//'2258';
        requestWrapper.TransactionCurrency = GlobalConstants.IFT_TRANSACTION_CURRENCY;//'1';
        requestWrapper.FromAccountCurrency = GlobalConstants.IFT_FROM_ACCOUNT_CURRENCY;//'1';
        if(paramsMap.get('IsPoolDisbursement')=='Yes'){
            requestWrapper.TransactionAmount = paramsMap.get('DisbursementAmount');
            requestWrapper.TransactionType = System.Label.IFT_TxnType_Pool;//'3';
            // SFAU-5479 - Kunal Start
            Boolean isPoolDisburseSuccess = isCheque ? paymentFavouring.Is_Cheque_Pool_Disburse_Successful__c : paymentFavouring.Is_Pool_Disbursement_Successful__c;
            String txnRefNumber = isCheque ? paymentFavouring.Pool_Txn_Cheque_Reference_Number__c : paymentFavouring.Pool_Txn_Reference_Number__c;
            if(!isPoolDisburseSuccess && String.isNotBlank(txnRefNumber)){
                requestWrapper.UserReferenceNumber = txnRefNumber;
                requestWrapper.ReferenceNumber =  txnRefNumber;
            // SFAU-5479 - Kunal End
            }else{
                requestWrapper.UserReferenceNumber = IntegrationUtility.getApplicationRelatedReferenceId(loan.Id);//'2837127312';
                requestWrapper.ReferenceNumber = requestWrapper.UserReferenceNumber;//'SFDC80a1a1c7b220b61e65225ef762151722';
            }
            
        }else{
            requestWrapper.TransactionAmount = String.valueOf(paymentFavouring.Net_Amount__c);//'100';
            requestWrapper.TransactionType = System.Label.IFT_TxnType_StandAlone;//'3';
            if(paymentFavouring.Payment_Favouring_Status__c=='Failed' && paymentFavouring.Txn_Reference_Number__c!=null){
                requestWrapper.UserReferenceNumber = paymentFavouring.Txn_Reference_Number__c;//'2837127312';
                requestWrapper.ReferenceNumber = paymentFavouring.Txn_Reference_Number__c;
            }else{
                requestWrapper.UserReferenceNumber = IntegrationUtility.getApplicationRelatedReferenceId(loan.Id);//'2837127312';
                requestWrapper.ReferenceNumber = requestWrapper.UserReferenceNumber;//'SFDC80a1a1c7b220b61e65225ef762151722';
            }
        }
        if(paramsMap.get('IsPoolDisbursement')=='Yes'){
            //SFAU-5331
                Payment_API_Mapping__mdt paymentMappings = isCheque ? Payment_API_Mapping__mdt.getInstance('Cheque') : Payment_API_Mapping__mdt.getInstance('NEFT');
                requestWrapper.ToAccount = paymentMappings.Sender_Account_Number__c;//'2121201133429837';
        }else{
            requestWrapper.ToAccount = paymentFavouring.Account_Number__c;//'2121201133429837';
        }
        requestWrapper.GLRefrenceNo = loan.General_Ledger__c;//'';
        //Narrative length <= 30 characters start
        if(loan.Narration__c==null ){
            requestWrapper.Narrative = '';
        }else if(loan.Narration__c.length()>30){
            requestWrapper.Narrative = loan.Narration__c.left(30);
        }else{
            requestWrapper.Narrative = loan.Narration__c;
        }
        //Narrative length <= 30 characters end
        //requestWrapper.Narrative = loan.Narration__c;//'CASA to CASA TEST FOR CIB';
        requestWrapper.PostingDate = String.valueOf(Date.today()).replace('-','');//'';
        if(paramsMap.get('IsPoolDisbursement')=='Yes'){
            requestWrapper.FromAccount = loan.General_Ledger__c;//'1711224313509350';
        }
        else{
            //SFAU-5331
            Payment_API_Mapping__mdt paymentMappings = paymentFavouring.Payment_Mode__c== 'Cheque' ? Payment_API_Mapping__mdt.getInstance('Cheque') : Payment_API_Mapping__mdt.getInstance('NEFT');
            requestWrapper.FromAccount = paymentMappings.Sender_Account_Number__c;//'2121201133429837';
        }
        requestWrapper.ChequeNumber = '';
        requestWrapper.ValueDate = String.valueOf(Date.today()).replace('-','');//'';
        if(paramsMap.get('IsPoolDisbursement')=='Yes'){
            List<User> currentUsers = [SELECT Id, Employee_Id__c, Branch_Code__c FROM User WHERE Id=:UserInfo.getUserId()];
            User currentUser = currentUsers!=null && currentUsers.size()>0?currentUsers[0]:null;  
            requestWrapper.TransactionBranch = currentUser!=null && currentUser.Branch_Code__c!=null?currentUser.Branch_Code__c:null;
        }else{
            requestWrapper.TransactionBranch = System.Label.IFT_Branch_Code;//String.valueOf(loan.Branch_Master__r.Account_Code__c);//String.valueOf(loan.Branch_Master__r.Account_Code__c);//'2001';
        }
        
        lstString.add(JSON.serializePretty(requestWrapper, false));  
        return lstString;
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    public class PaymentIFTAPIRequestWrappper{
        public String UserReferenceNumber;  //2837127312
        public String TransactionType;  //3
        public String ToAccountCurrency;    //1
        public String ReferenceNumber;  //SFDC80a1a1c7b220b61e65225ef762151722
        public String Channel;  //APES
        public String FromAccountBranch;    //2001
        public String ToAccountBranch;  //2258
        public String TransactionCurrency;  //1
        public String FromAccountCurrency;  //1
        public String TransactionAmount;    //100
        public String ToAccount;    //2121201133429837
        public String GLRefrenceNo; //
        public String Narrative;    //CASA to CASA TEST FOR CIB
        public String PostingDate;  //
        public String FromAccount;  //1711224313509350
        public String ChequeNumber; //
        public String ValueDate;    //
        public String TransactionBranch;    //2001
    }
    
    public class PaymentIFTAPIResponseWrappper{
        @AuraEnabled public cls_TransactionStatus TransactionStatus{get;set;}
        @AuraEnabled public String ErrorCode{get;set;}   //0
        @AuraEnabled public String TransactionReferenceNo{get;set;}   //SFDC80a1a1c7b220b61e65225ef762151722
    }
    
    public class cls_TransactionStatus {
        @AuraEnabled public ValidationErrorsWrapper ValidationErrors{get;set;}
        @AuraEnabled public String ResponseCode{get;set;} //0
        @AuraEnabled public String ResponseMessage{get;set;}  //Success
    }

    public class ValidationErrorsWrapper{
        @AuraEnabled public String AttributeName{get;set;} //0
        @AuraEnabled public String AttributeValue{get;set;} //0
        @AuraEnabled public String ErrorCode{get;set;} //0
        @AuraEnabled public String ErrorMessage{get;set;} //0
    }
}