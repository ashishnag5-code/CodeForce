public with sharing class DoDisbursementAPIHandler {
    
    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        DoDisbursementRequestWrapper requestWrapper = new DoDisbursementRequestWrapper();
        Loan_Application__c loan;
        Payment__c paymentFavouring;
        Map<String,String> paramsMap=(Map<String,String>)reqParam;
        User currentUser;
        List<Loan_Application__c> loanApps = [SELECT Id, Mode_of_Disbursement__c, Branch_Master__c, Application_Id__c, Total_Charges_Disbursement__c,
                                                    Branch_Master__r.Account_Code__c, LAN__c, Schedule_Code__c, General_Ledger__c,
                                                    Disbursement_Date__c, Total_Loan_Amount__c, Narration__c, Disbursement_Session_Id__c,
                                                    Total_Charges__c, OwnerId
                                                    FROM Loan_Application__c WHERE Id=:paramsMap.get('LoanId')
                                                    WITH SECURITY_ENFORCED];
        List<User> currentUsers = [SELECT Id, Employee_Id__c, Branch_Code__c FROM User WHERE Id=:UserInfo.getUserId()];
        if(loanApps!=null && loanApps.size()>0){
            loan = loanApps[0];
        }  
        if(currentUsers!=null && currentUsers.size()>0){
            currentUser = currentUsers[0];
        }                                                                                                
        requestWrapper.ReferenceNumber = IntegrationUtility.getApplicationRelatedReferenceId(loan.Application_Id__c);
        /*if(loan.Branch_Master__c!=null){
            requestWrapper.TransactionBranch = Integer.valueOf(loan.Branch_Master__r.Account_Code__c);
        }*/
        requestWrapper.TransactionBranch = currentUser!=null && currentUser.Branch_Code__c!=null?Integer.valueOf(currentUser.Branch_Code__c):null;
        requestWrapper.RequestId = requestWrapper.ReferenceNumber;
        requestWrapper.OriginatingChannel = paramsMap.get('Channel');//'LOS';

        BranchDisbursementDetailWrapper branchWrapper = new BranchDisbursementDetailWrapper();
        branchWrapper.UserId = currentUser!=null && currentUser.Employee_Id__c!=null?Integer.valueOf(currentUser.Employee_Id__c):null;
        /*if(loan.OwnerId.getSObjectType() == Schema.User.getSObjectType()){
            List<User> owners = [SELECT Id, Employee_Code__c FROM User WHERE Id=:loan.OwnerId];
            if(owners!=null && owners.size()>0){
                branchWrapper.UserId = 111154;//Integer.valueOf(owners[0].Employee_Code__c);//RO User Id
            }
        }*/
        branchWrapper.AccountId = Long.valueOf(loan.LAN__c);
        Disbursement_Mode__mdt dbMode = Disbursement_Mode__mdt.getInstance(loan.Mode_of_Disbursement__c);
        branchWrapper.DisbursementMode=Integer.valueOf(dbMode.Code__c);
        branchWrapper.FromAccountNo = Long.valueOf(loan.General_Ledger__c);//250408455;
        if(loan.Narration__c.length() > 40){
            branchWrapper.Narrative = loan.Narration__c.subString(0,40);
        }
        else{
            branchWrapper.Narrative = loan.Narration__c;
        }
        branchWrapper.UserReferenceNumber = requestWrapper.ReferenceNumber.subString(0,19);
        requestWrapper.BranchDisbursementDetail = branchWrapper;

        HostDisbursementDetailWrapper hostWrapper = new HostDisbursementDetailWrapper();
        hostWrapper.AccountId = Long.valueOf(loan.LAN__c);
        hostWrapper.SessionId = Integer.valueOf(loan.Disbursement_Session_Id__c);
        /* start - Updated the date for testing R2 */
        // Date genDate = Date.newInstance(2024, 01, 08);
         hostWrapper.DisbursementDate = String.valueof(loan.Disbursement_Date__c);
        //hostWrapper.DisbursementDate = String.valueof(genDate);
            /* End - Updated the date for testing R2 */
        hostWrapper.DisbursementTransactionAmount = loan.Total_Loan_Amount__c;//Decimal.valueOf(paramsMap.get('NetDisbursementAmount'));//netDisbursementAmount;//Integer.valueof(loan.Total_Loan_Amount__c);
        hostWrapper.ScheduleCode = Integer.valueOf(loan.Schedule_Code__c);
        hostWrapper.DeductTypeDeductionAmount = loan.Total_Charges_Disbursement__c;
        hostWrapper.DisbursementMode = Integer.valueOf(dbMode.Code__c);

        List<Charge__c> chargesList = [SELECT Id, Charges_Name__c, Sequence_NO__c, SC_Code__c, Total_Amount__c FROM Charge__c
        WHERE Loan_Application__c=:loan.Id Order by Sequence_NO__c];

        List<DeductionDetailsWrapper> deductionsWrapperList = new List<DeductionDetailsWrapper>();
        if(chargesList!=null && chargesList.size()>0){
            for(Charge__c charge: chargesList){
                deductionsWrapperList.add(new DeductionDetailsWrapper(charge));
            }
        }
        hostWrapper.DeductionDetails = deductionsWrapperList;
        requestWrapper.HostDisbursementDetail = hostWrapper;

        lstString.add(JSON.serializePretty(requestWrapper, false));   
        return lstString;
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }

    public class DoDisbursementRequestWrapper{
        public String ReferenceNumber;
        public Integer TransactionBranch;
        public String RequestId;
        public String OriginatingChannel;
        public BranchDisbursementDetailWrapper BranchDisbursementDetail;
        public HostDisbursementDetailWrapper HostDisbursementDetail;
    }

    public class BranchDisbursementDetailWrapper{
        public Integer UserId;
        public Long AccountId;
        public Integer DisbursementMode;
        public Long FromAccountNo;
        public String Narrative;
        public String UserReferenceNumber;
    }

    public class HostDisbursementDetailWrapper{
        public Long AccountId;
        public Integer SessionId;
        public String DisbursementDate;
        public Decimal DisbursementTransactionAmount;
        public Integer ScheduleCode;
        public Decimal DeductTypeDeductionAmount;
        public Integer DisbursementMode;
        public List<DeductionDetailsWrapper> DeductionDetails;
    }

    public class DeductionDetailsWrapper{
        public Boolean IsWaived;
        public String DeductionCurrencyCode;
        public String SrlNumber; //SequenceNO
        public String DeductionCode; //SCCode
        public String ServiceChargeName; //Charge name
        public Integer ConversionRateTransactionCurrency;
        public Decimal DeductionAmountInAccountCurrency; //Total amount
        public String DeductionType;
        public String CtrSrlDednNo; //SequenceNO
        public String TransactionCurrencyCode;
        public String DeductionAmountInLocalCurrency; //Total Amount
        public String LocalCurrencyCode;
        public String AccountCurrencyCode;
        public String FlgDueOn;
        public Boolean IsSCDeductionAmortised;
        public Integer ConversionRateAccountCurrency;
        public String DeductionMode;
        public Decimal DeductionAmountInTransactionCurrency; //Total Amount
        public DeductionDetailsWrapper(Charge__c charge){
            IsWaived = false;
            DeductionCurrencyCode = '1';
            SrlNumber = String.valueOf(charge.Sequence_NO__c);
            DeductionCode = charge.SC_Code__c;
            ServiceChargeName = charge.Charges_Name__c;
            ConversionRateTransactionCurrency = 1;
            DeductionAmountInAccountCurrency = charge.Total_Amount__c;
            DeductionType = '0';
            CtrSrlDednNo = String.valueOf(charge.Sequence_NO__c);
            TransactionCurrencyCode = '1';
            DeductionAmountInLocalCurrency = String.valueOf(charge.Total_Amount__c);
            LocalCurrencyCode = '1';
            AccountCurrencyCode = '1';
            FlgDueOn = '1';
            IsSCDeductionAmortised = false;
            ConversionRateAccountCurrency = 1;
            DeductionMode = '1';
            DeductionAmountInTransactionCurrency = charge.Total_Amount__c;
        }
    }

    public class DoDisbursementResponseWrapper{
        @AuraEnabled public LoanBalanceResponseWrapper LoanBalanceResponse{get;set;}
        @AuraEnabled public TransactionStatusWrapper TransactionStatus{get;set;}
    }

    public class LoanBalanceResponseWrapper{
        @AuraEnabled public Decimal NextInstallmentDueAmount{get;set;}
        @AuraEnabled public Decimal MinAmountDue{get;set;}
        @AuraEnabled public Decimal UnclearedFunds{get;set;}
        @AuraEnabled public Decimal AmountDisbursedToday{get;set;}
        @AuraEnabled public Decimal PenaltyArrears{get;set;}
        @AuraEnabled public String MaturityDate{get;set;}
        @AuraEnabled public Decimal OtherArrears{get;set;}
        @AuraEnabled public String NextDueDate{get;set;}
        @AuraEnabled public Decimal InstallmentArrears{get;set;}
        @AuraEnabled public Decimal UnbilledServiceCharge{get;set;}
        @AuraEnabled public Decimal PrincipalBalance{get;set;}
        @AuraEnabled public Decimal RpaBalance{get;set;}
        @AuraEnabled public Decimal AccountStatus{get;set;}
        @AuraEnabled public Decimal AmountPaidToday{get;set;}
        @AuraEnabled public Decimal UncollectedInterest{get;set;}
        @AuraEnabled public Decimal AvailableBalance{get;set;}
        @AuraEnabled public String AccountCurrency{get;set;}
        @AuraEnabled public String CustomerShortName{get;set;}
        @AuraEnabled public Decimal UnbilledPenaltyInterest{get;set;}
        @AuraEnabled public Decimal TotalOutstandings{get;set;}
        @AuraEnabled public Decimal UnbilledInterest{get;set;}
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