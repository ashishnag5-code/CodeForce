/*****
 * Class Name: CollateralLinkageAPIHandler
 * Description: 
 * Test Class Name: CollateralLinkageAPIControllerTest
 * 
 * LastModified Date    -   Last Modified By    -   Description / Bug
 * Dec-06-2023          -   Mohit M.            -   SFAU-5665 - “FlgMode”: ”M” and FlagDeduction" to be passed as blank instead of “Y.
 * Dec-07-2023          -   Mohit M.            -   SFAU-5708 - change attribute PrimarOrSecondaryCollateral to PrimaryOrSecondaryCollateral
 * Dec-08-2023          -   Mohit M.            -   SFAU-5665 POS from Bank Account
 */
public with sharing class CollateralLinkageAPIHandler {
    public CollateralLinkageAPIHandler() {

    }

    public static List<String> generateRequest(Object reqParam){
        List<String> lstString = new List<String>();
        try {
        Map<String,String> paramsMap=(Map<String,String>)reqParam;
        Id loanId = paramsMap.get('LoanApplication');
        List<Loan_Application__c> loanApps = [SELECT Id, Branch_Master__r.Account_Code__c, 
                    (SELECT Id, Collateral_ID__c, Final_Cost__c, Collateral_Id_in_CBS__c, Collateral_Code_in_CBS__c, SVSH_SVOH__c, POS__c, Linked_Account_Number__c,BT_Loan_Status__c, Collateral_Name__c FROM Collaterals__r WHERE RecordType.DeveloperName in ('New','Used_Cash_on_Wheels') AND Is_Deleted__c=false Order By CreatedDate Desc) FROM Loan_Application__c WHERE Id=:loanId];
        Collateral__c collateral = new Collateral__c();
        if(loanApps!=null && loanApps.size()>0){
            Loan_Application__c loan = loanApps[0];
                Id objLoanId = loan.Id;
            if(loan.collaterals__r!=null && loan.collaterals__r.size()>0){
                collateral = loan.collaterals__r[0];
                    /*
                    String strAccId = String.isNotEmpty(collateral.Linked_Account_Number__c) ? collateral.Linked_Account_Number__c : '';
                    List<Bank_Account_Records__c> lstBAR = [Select Id, Account_Number__c, POS__c from Bank_Account_Records__c where RecordType.DeveloperName = 'CBS' and Account_Number__c =: strAccId AND Account_Type__c = 'Loan' AND Applicant__r.Loan__c =: objLoanId AND Applicant__r.RecordType.DeveloperName = 'Primary_Applicant' AND Applicant__r.IsInactive__c = false];
                    String strColPos =  lstBAR != NULL && lstBAR.size()>0 && lstBAR[0].POS__c != NULL ? String.valueOf(lstBAR[0].POS__c) : String.valueOf(collateral.POS__c);
                    */
                CollateralLinkageRequestWrapper wrapper = new CollateralLinkageRequestWrapper();
                wrapper.CollateralPriority=GlobalConstants.LINKAGE_COLLATERAL_PRIORITY;
                wrapper.PrimaryOrSecondaryCollateral=GlobalConstants.LINKAGE_PRIMARY_OR_SECONDARY_COLLATERAL;
                wrapper.AccountID=collateral.Linked_Account_Number__c;
                wrapper.RequestId=IntegrationUtility.getReferenceId();
                wrapper.OriginatingChannel=paramsMap.get('Channel');
                wrapper.FlagDeduction=GlobalConstants.LINKAGE_FLAG_DEDUCTION;
                    // SFAU-5343 - Always send new collateral id in SVOH cases. - Kunal 6th Nov
                    //wrapper.CollateralId=(collateral.SVSH_SVOH__c == 'SVOH' || collateral.BT_Loan_Status__c == 'Top Up' ) ? collateral.Collateral_ID__c : collateral.Collateral_Id_in_CBS__c;//collateral.Collateral_ID__c;
                    // SFAU-5705 - CBS Collateral to be passed in Collateral linkage API for SVSH + TOPUP
                    wrapper.CollateralId = collateral.Collateral_Id_in_CBS__c;//collateral.Collateral_ID__c;
                wrapper.ReferenceNumber=wrapper.RequestId;
                wrapper.ImpactOfRateChange='';
                wrapper.CollateralValue=String.valueOf(collateral.POS__c);
                //wrapper.CollateralCode=collateral.Collateral_Name__c;
                wrapper.CollateralCode=collateral.Collateral_Code_in_CBS__c;//As per Shashank's email - Collateral Code sent in Collateral Modification should be sent here as well
                wrapper.DepositNumber='';
                wrapper.LinkTDForInterest='';
                wrapper.LinkTDForInterest='';
                wrapper.TransactionBranch=loanApps[0].Branch_Master__r.Account_Code__c;
                wrapper.TdAccountNumber='';
                    wrapper.FlgMode = GlobalConstants.LINKAGE_FLAG_MODE;
                lstString.add(JSON.serialize(wrapper));
            }   
        }
        }
        catch (Exception ex) {
            throw ex;
        }
        return lstString;
    }

    public String generateJSONResponse(List<Object> recordList){
        return null;
    }

    public class CollateralLinkageRequestWrapper{
        public String CollateralPriority;
        public String PrimaryOrSecondaryCollateral;
        public String AccountID;
        public String RequestId;
        public String OriginatingChannel;
        public String FlagDeduction;
        public String CollateralId;
        public String ReferenceNumber;
        public String ImpactOfRateChange;
        public String CollateralValue;
        public String CollateralCode;
        public String DepositNumber;
        public String LinkTDForInterest;
        public String TransactionBranch;
        public String TdAccountNumber;
        //SFAU-5665
        public String FlgMode;
    }

    public class CollateralLinkageResponseWrapper{
        @AuraEnabled public TransactionStatusWrapper TransactionStatus{get;set;}
    }

    public class TransactionStatusWrapper{
        @AuraEnabled public String ResponseCode{get;set;}
        @AuraEnabled public String ResponseMessage{get;set;}
        @AuraEnabled public ExtendedErrorDetailsWrapper ExtendedErrorDetails{get;set;}
    }

    public class ExtendedErrorDetailsWrapper{
        @AuraEnabled public List<MessagesWrapper> messages{get;set;}
    }

    public class MessagesWrapper{
        @AuraEnabled public String code{get;set;}
        @AuraEnabled public String message{get;set;}
    }

}