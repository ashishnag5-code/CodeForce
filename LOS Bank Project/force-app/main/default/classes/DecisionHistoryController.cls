/**
 * @author        Joshna
 * @date          1-Jul-2023
 * @description   Controller for Decision History display component
 * @reference     Decision History
 * Modification Log:
 * --------------------------------------------------------------------------------------------
 * Developer               Date            Description
 * --------------------------------------------------------------------------------------------
 * Joshna                  01-Jul-2023     Initial creation - added fetchHistory
 */
public with sharing class DecisionHistoryController {
    @AuraEnabled
    public static List<DecisionHistoryWrapper> fetchHistory(String loanId) {
        updateAutoRejectedLoans(loanId);// SFAU-5313 
        List<DecisionHistoryWrapper> returnWrapper = new List<DecisionHistoryWrapper>();
        Boolean addedAML = false;
        Boolean addedValuation = false;
        DecisionHistoryWrapper valuationTAT;

        String sObjName = Id.valueOf(loanId).getSObjectType().getDescribe().getName();
        if(sObjName == 'Assignment__c'){
            loanId = [SELECT Id, Loan_Application__c FROM Assignment__c WHERE Id=:loanId][0].Loan_Application__c;
        }

        for (Valuation__c each : [SELECT Id, Owner.Name, CreatedDate, Completion_Date_Time__c FROM Valuation__c WHERE Collateral__r.Loan__c = :loanId]) {
            valuationTAT = new DecisionHistoryWrapper(new Loan_TAT__c(Action_Type__c = each.Completion_Date_Time__c == null ? 'Valuation Initiated' : 'Valuation Completed',
                Start_Date_Time__c = each.CreatedDate, End_Date_Time__c = each.Completion_Date_Time__c), each.Owner.Name, null);
        }

        for (Loan_TAT__c each : [SELECT Id, Assigned_To__c, Difference_in_Ms_Business_Hours__c, TAT_in_Business_Hours__c , Start_Date_Time__c, End_Date_Time__c,
            Field_Investigation__c, Loan_Application_Approval__c, Loan_Application_Assignment__c, Override_TAT__c, Owner__r.Name, Owner__r.Employee_Id__c, Type__c,
            Stage_Activity__c, Decision_Remarks__c, Action_Type__c, Loan_Application__r.Primary_Applicant__r.AML_Status__c, Loan_Amount__c, ROI__c, Tenure__c, LTV__c,
            Loan_Application__r.Primary_Applicant__r.AML_Verification_Start_Date__c, Loan_Application__r.Primary_Applicant__r.AML_Verification_End_Date__c,
            Actor__c, Actor__r.Name, Actor__r.Employee_Id__c,Loan_Application__r.isAutoRejected__c // SFAU-5313  Added Loan_Application__r.isAutoRejected__c field
            FROM Loan_TAT__c WHERE Loan_Application__c = :loanId ORDER BY Start_Date_Time__c]) {
            if (!addedValuation && valuationTAT != null && each.Start_Date_Time__c > valuationTAT.loanTATRecord.Start_Date_Time__c) {
                addedValuation = true;
                returnWrapper.add(valuationTAT);
            }
            if (!addedAML && each.Loan_Application__r.Primary_Applicant__r.AML_Verification_Start_Date__c != null &&
                each.Start_Date_Time__c > each.Loan_Application__r.Primary_Applicant__r.AML_Verification_Start_Date__c) {
                addedAML = true;
                returnWrapper.add(new DecisionHistoryWrapper(new Loan_TAT__c(Action_Type__c = each.Loan_Application__r.Primary_Applicant__r.AML_Status__c == null ?
                    'AML Initiated' : 'AML ' + each.Loan_Application__r.Primary_Applicant__r.AML_Status__c,
                    Start_Date_Time__c = each.Loan_Application__r.Primary_Applicant__r.AML_Verification_Start_Date__c,
                    End_Date_Time__c = each.Loan_Application__r.Primary_Applicant__r.AML_Verification_End_Date__c), null, null));
            }
            returnWrapper.add(new DecisionHistoryWrapper(each));
        }
        return returnWrapper;
    }
    // START || SFAU-5313 
    public static void updateAutoRejectedLoans(String loanId){
        List<Loan_TAT__c> loanTATRecords =[SELECT Id, Decision_Remarks__c,Loan_Application__c,Loan_Application__r.isAutoRejected__c,Stage_Activity__c,
                                           Actor__c, Actor__r.Name, Actor__r.Employee_Id__c
                                           FROM Loan_TAT__c 
                                           WHERE Loan_Application__c = :loanId 
                                           AND Stage_Activity__c ='Rejected'
                                           AND Loan_Application__r.isAutoRejected__c = true
                                           ORDER BY Start_Date_Time__c];
        List<Loan_TAT__c> updateRecords = new List<Loan_TAT__c>();
        for(Loan_TAT__c tatInstance : loanTATRecords){
            Loan_TAT__c tatUpdateInstance =tatInstance;
            tatUpdateInstance.Decision_Remarks__c ='Auto Rejected';
            updateRecords.add(tatUpdateInstance);
        }
        if(updateRecords!=null && updateRecords.size()>0 && !updateRecords.isEmpty()){
            update updateRecords;
        }                                            
    }
    //END
    public class DecisionHistoryWrapper {
        @AuraEnabled public Boolean isLoanTAT;
        @AuraEnabled public Loan_TAT__c loanTATRecord;
        @AuraEnabled public String ownerName;
        @AuraEnabled public String ownerEmployeeId;

        public DecisionHistoryWrapper(Loan_TAT__c loanTATRecord) {
            this.loanTATRecord = loanTATRecord;
            if (loanTATRecord.Action_Type__c == 'Loan Submitted') {
                if(String.isNotBlank(loanTATRecord.Owner__c)){
                    this.ownerEmployeeId = loanTATRecord.Owner__r.Name;
                    this.ownerName = loanTATRecord.Owner__r.Employee_Id__c;
                    this.isLoanTAT = false;
                }
                else{
                    this.ownerEmployeeId = loanTATRecord.Actor__r.Name;
                    this.ownerName = loanTATRecord.Actor__r.Employee_Id__c;
                    this.isLoanTAT = false;

                }
                
            }else if (loanTATRecord.Loan_Application__r.isAutoRejected__c && loanTATRecord.Stage_Activity__c =='Rejected'){ // START || SFAU-5313 
                this.ownerEmployeeId = '';
                this.ownerName = '';
                this.isLoanTAT = false;
            } else { //END || SFAU-5313 
                this.isLoanTAT = true;
            }
        }

        public DecisionHistoryWrapper(Loan_TAT__c loanTATRecord, String ownerName, String ownerEmployeeId) {
            this.loanTATRecord = loanTATRecord;
            this.ownerEmployeeId = ownerEmployeeId;
            this.ownerName = ownerName;
            this.isLoanTAT = false;
        }
    }
}