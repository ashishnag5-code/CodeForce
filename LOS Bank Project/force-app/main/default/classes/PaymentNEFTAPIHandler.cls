/*
@ Class Name: PaymentNEFTAPIHandler
@ Test Class: 
@ Code Coverage: 
@ Description: NEFT Payment Favoring
@ Logs:
@ Last Modified Date  -   Last Modified By    -   Bug
@ Mohit M.            -   Oct-20-2023         -   SFAU-5334 - Receiver Name is blank in RTGS and NEFT
@ Mohit M.            -   Nov-02-2023         -   SFAU-5483 - CUG|| SFDC|| 4W || Invalid Account Number
*/
public with sharing class PaymentNEFTAPIHandler {

    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        Loan_Application__c loan;
        Payment__c paymentFavouring;
        Map<String,String> paramsMap=(Map<String,String>)reqParam;
        Map<String, String> accountTypes = new Map<String, String>{GlobalConstants.PAYMENT_ACCOUNT_TYPE_SAVING => '10', 
                                                                        GlobalConstants.PAYMENT_ACCOUNT_TYPE_CURRENT => '11'};                                                                    
        List<Loan_Application__c> loanApps = [SELECT Id, Pool_Txn_Reference_Number__c,Narration__c, General_Ledger__c, LAN__c, Schedule_Code__c,
                                                    Disbursement_Date__c, Total_Loan_Amount__c, OwnerId,Dealer_Master__c,Dealer_Master__r.Account_Name__c, Dealer_Master__r.Dealer_Name__c,
                                                    (SELECT Id, Customer_Name__c FROM Applicants__r WHERE RecordType.DeveloperName=:GlobalConstants.APPLICANT_RECORD_TYPE)
                                                    FROM Loan_Application__c WHERE Id=:paramsMap.get('LoanId')];

        if(loanApps!=null && loanApps.size()>0){
            loan = loanApps[0];
        }
        List<Payment__c> paymentFavourings;
        paymentFavourings = [SELECT Id, Beneficiary_Name__c,Name__c, Net_Amount__c, Account_Number__c, IFSC_Code__c, Account_Type__c, Payment_Recipient__c, Txn_Reference_Number__c, Payment_Favouring_Status__c
                                                    FROM Payment__c WHERE Id=:paramsMap.get('PaymentId')];
        if(paymentFavourings!=null && paymentFavourings.size()>0){
            paymentFavouring = paymentFavourings[0];
        }
        PaymentNEFTAPIRequestWrappper requestWrapper = new PaymentNEFTAPIRequestWrappper();
        cls_SettlementRequest objSettlementRequest = new cls_SettlementRequest();
        Payment_API_Mapping__mdt paymentMappings = Payment_API_Mapping__mdt.getInstance('NEFT');
        objSettlementRequest.SenderIFSC = paymentMappings.Sender_IFSC__c;//'AUBL0002011';
        //SFAU-5257
        objSettlementRequest.ReceivingCustomerName = paymentFavouring.Name__c;//'SHUBHAM';
        
        //Change added by Samridhi - 16 Aug
		if(paymentFavouring.Payment_Recipient__c == 'Dealer'){
            // SFAU-5334 - Receiver Name is blank in RTGS and NEFT
            //objSettlementRequest.ReceivingCustomerName = loan.Dealer_Master__c!=null?loan.Dealer_Master__r.Dealer_Name__c:'';
            objSettlementRequest.ReceivingCustomerName = loan.Dealer_Master__c!=null?loan.Dealer_Master__r.Dealer_Name__c:paymentFavouring.Name__c;
        }
        else if(paymentFavouring.Payment_Recipient__c == 'Customer'){
            objSettlementRequest.ReceivingCustomerName = loan.Applicants__r!=null && loan.Applicants__r.size()>0?loan.Applicants__r[0].Customer_Name__c:'';
        }
                
        objSettlementRequest.Narration = loan.Narration__c;//'Money Transfer';
        objSettlementRequest.Amount = String.valueOf(paymentFavouring.Net_Amount__c);//'200000.00';
        // START - SFAU-5483
        // objSettlementRequest.ReceiverAccountNumber = paymentFavouring.Account_Number__c;//'123456789012';
        objSettlementRequest.ReceiverAccountNumber = String.isNotBlank(paymentFavouring.Account_Number__c) ? paymentFavouring.Account_Number__c.replaceAll('\'','') : paymentFavouring.Account_Number__c;
        // END - SFAU-5483
        objSettlementRequest.Source = paramsMap.get('Channel');//GlobalConstants.NEFT_SOURCE;//'TGT';
        if(loan.OwnerId.getSObjectType() == Schema.User.getSObjectType()){
            List<User> owners = [SELECT Id, MobilePhone FROM User WHERE Id=:loan.OwnerId];
            if(owners!=null && owners.size()>0){
                objSettlementRequest.SenderContactInfo = owners[0].MobilePhone;//paymentMappings.Sender_Contact_Info__c;//'8306587700';
            }
        }
        objSettlementRequest.SenderAccountType = paymentMappings.Sender_Account_Type__c;//'10';
        objSettlementRequest.SenderAccountNumber = paymentMappings.Sender_Account_Number__c;//loan.General_Ledger__c;//'2201210944284751';
        objSettlementRequest.ReceiverAccountType = accountTypes.get(paymentFavouring.Account_Type__c);
        objSettlementRequest.ReceiverIFSC = paymentFavouring.IFSC_Code__c;//'SBIN0002927';
        objSettlementRequest.ValueDate = (String.valueOf(Date.today())).replace('-','');//'20230302';
        
        //Change added by Samridhi - 16 Aug
        objSettlementRequest.SendingCustomerName = 'AUSFB WHEELS LOAN DISBURSEMENT';
        /*if(paymentFavouring.Payment_Recipient__c == 'Dealer'){
            objSettlementRequest.SendingCustomerName = loan.Dealer_Master__c!=null?loan.Dealer_Master__r.Dealer_Name__c:'';
        }
        else if(paymentFavouring.Payment_Recipient__c == 'Customer'){
            objSettlementRequest.SendingCustomerName = loan.Applicants__r!=null && loan.Applicants__r.size()>0?loan.Applicants__r[0].Customer_Name__c:'';
        }*/
        
        
        if(paymentFavouring.Payment_Favouring_Status__c=='Failed' && paymentFavouring.Txn_Reference_Number__c!=null){
            objSettlementRequest.TransactionReferenceNumber = paymentFavouring.Txn_Reference_Number__c;//'2837127312';
        }else{
            objSettlementRequest.TransactionReferenceNumber = IntegrationUtility.getApplicationRelatedReferenceId(loan.Id);//'2837127312';
        }
      
        requestWrapper.SettlementRequest = objSettlementRequest;
        lstString.add(JSON.serializePretty(requestWrapper, false));  
        return lstString;
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    public class PaymentNEFTAPIRequestWrappper{
        public cls_SettlementRequest SettlementRequest;
    }
    
    public class cls_SettlementRequest {
        public String SenderIFSC;   //AUBL0002011
        public String ReceivingCustomerName;    //rujb
        public String Narration;    //Money Transfer
        public String Amount;   //25001.00
        public String ReceiverAccountNumber;    //123456
        public String Source;   //TGT
        public String SenderContactInfo;    //8306586667
        public String SenderAccountType;    //10
        public String SenderAccountNumber;  //2301210944335832
        public String ReceiverAccountType;  //10
        public String ReceiverIFSC; //ICIC0000238
        public String ValueDate;    //20230301
        public String SendingCustomerName;  //Vishal G
        public String TransactionReferenceNumber;   //GT167765504227
    }
    
    public class PaymentNEFTAPIResponseWrappper{
        @AuraEnabled public cls_SettlementResponse SettlementResponse{get;set;}
    }
    
    public class cls_SettlementResponse {
        @AuraEnabled public String Status{get;set;}   //Success
        @AuraEnabled public String ResponseCodeDescription{get;set;}  //Request Successfully Processed
        @AuraEnabled public String ResponseCode{get;set;} //RBAPI00G001
        @AuraEnabled public String Remarks{get;set;}  //Payment Generated Successfully with ID: TGT176563332835506
        @AuraEnabled public String IPHREF{get;set;}   //AUBLR12023030201677873
        @AuraEnabled public String Code{get;set;} //201
        @AuraEnabled public String TransactionReferenceNumber{get;set;}   //TGT176563332835506
    }
}