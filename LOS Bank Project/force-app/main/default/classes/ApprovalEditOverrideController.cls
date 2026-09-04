public with sharing class ApprovalEditOverrideController {
    @AuraEnabled
    public static Id getApplicationFromApproval(Id approvalId){
        if(approvalId == null) throw new ApprovalEditOverrideException('Approval details are missing!');

        return [ SELECT
            Loan_Application__c
            FROM Loan_Application_Approval__c
            WHERE Id =: approvalId WITH USER_MODE
        ].Loan_Application__c;
    }
    
    public class ApprovalEditOverrideException extends Exception{}
}