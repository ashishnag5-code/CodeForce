/*****
 * Class Name: AUSFPreApprovedCheckController
 * Description: 
 * Test Class Name: 
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Sep-20-2023          -   Mohit M.            -   SFAU-5226 AND SFAU-5350 - Run BRE for Credit Approval when Loan Amount > Offer Amount
 * Dec-27-2023          -   Mohit M.            -   SFAU-5800 - UAT || Tenure reduction || Pre-Approval
 */
public without sharing class AUSFPreApprovedCheckController {
    
    @AuraEnabled
    public static PreApprovedWrapper getLoanApplicationStage(String loanAppId){
        PreApprovedWrapper preWrap = new PreApprovedWrapper();
        Id existingColRecordTypeId = Schema.SObjectType.Collateral__c.getRecordTypeInfosByName().get('Existing Collateral').getRecordTypeId();
        Id paymentFavouringRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByName().get('Payment Favouring').getRecordTypeId();
        Boolean isGoToPricingStage = false;
        Boolean isdetailInComplete = true;
        Boolean isGoToCreditStage = false;
        List<Collateral__c> listOfColl = [SELECT Id FROM Collateral__c WHERE Loan__c=:loanAppId AND recordTypeId!=:existingColRecordTypeId];
        List<Insurance_Details__c> listOfInsurance = [SELECT Id FROM Insurance_Details__c WHERE Loan_Application__c =:loanAppId];
        List<Payment__c> listOfPayments = [SELECT Id FROM Payment__c WHERE Loan_Application__c=:loanAppId AND recordTypeId=:paymentFavouringRecordTypeId];
        List<Pre_Approved_Offer__c> listOfPreApprovedOffer = [SELECT id,Loan_Application__r.Tenure__c,Loan_Application__r.Loan_Amount__c,Loan_Application__r.Total_Loan_Amount__c,Loan_Application__r.ROI__c ,
                                        FirstOfferAmount__c,RateofInterest__c,MaxLoanTenureinMonths__c,MinLoanTenureinMonths__c FROM Pre_Approved_Offer__c 
                                        WHERE Is_Selected__c =true AND Loan_Application__c=:loanAppId];
        
        if(listOfColl.size()>0 && listOfPayments.size()>0){
            isdetailInComplete = false;
        }
        if(listOfPreApprovedOffer.size()>0){
            Loan_Application__c loanApp = listOfPreApprovedOffer[0].Loan_Application__r;
            /* SFAU-5800 - START */
            if(listOfColl.size()>0){
                if (listOfPreApprovedOffer[0].FirstOfferAmount__c < loanApp.Total_Loan_Amount__c) {
                    isGoToCreditStage = true;
                }
                if(listOfPreApprovedOffer[0].MaxLoanTenureinMonths__c >= loanApp.Tenure__c && 
                        listOfPreApprovedOffer[0].FirstOfferAmount__c >= loanApp.Total_Loan_Amount__c){
                    isGoToPricingStage = true;
                }
            }
            /* SFAU-5800 - END */
            /*
            if(listOfColl.size()>0){//listOfInsurance.size()>0 && && listOfPayments.size()>0
                if(listOfPreApprovedOffer[0].RateofInterest__c<loanApp.ROI__c){
                    isGoToPricingStage = true;
                }
                if(listOfPreApprovedOffer[0].RateofInterest__c == loanApp.ROI__c && 
                    listOfPreApprovedOffer[0].MaxLoanTenureinMonths__c == loanApp.Tenure__c && 
                        listOfPreApprovedOffer[0].FirstOfferAmount__c == loanApp.Total_Loan_Amount__c){
                    isGoToPricingStage = true;
                }
                //SFAU-5226 - Run BRE for Credit Approval when Loan Amount > Offer Amount
                if (listOfPreApprovedOffer[0].FirstOfferAmount__c < loanApp.Total_Loan_Amount__c) {
                    isGoToCreditStage = true;
                }
            }
            */
        }
        
        preWrap.isdetailInComplete = isdetailInComplete;
        preWrap.isPriceStage = isGoToPricingStage;
        preWrap.isCreditStage = isGoToCreditStage;
        return preWrap;
    }
    public class PreApprovedWrapper{
        @AuraEnabled public Boolean isdetailInComplete;
        @AuraEnabled public Boolean isPriceStage;
        @AuraEnabled public Boolean isCreditStage;
    }
}