trigger LoanApplicationApprovalTrigger on Loan_Application_Approval__c (before insert,after insert, before update, after update) {
    if(Trigger.isBefore && Trigger.isInsert){
        LoanApplicationApprovalTriggerHandler.populateAdditionalFields(Trigger.new);
        LoanApplicationApprovalTriggerHandler.getBaseApprover(Trigger.New);
    } else if(Trigger.isBefore && Trigger.isUpdate){
        //LoanApplicationApprovalTriggerHelper.updateComments(trigger.new);
        LoanApplicationApprovalTriggerHandler.populateApproverforTAR(Trigger.New, Trigger.oldMap);
    }
    
    if(Trigger.isAfter){
        if (Trigger.isInsert){
            LoanApplicationApprovalTriggerHelper.shareLoanApplicationWithApprover(Trigger.New);
            LoanApplicationApprovalTriggerHelper.callShareRecordsWithCreditApprovers(Trigger.new);//3838
            LoanApplicationApprovalTriggerHelper.sendLoanApplicationForReWork(Trigger.new);
            LoanApplicationApprovalTriggerHandler.delegateApproval(Trigger.new, null);
            LoanApplicationApprovalTriggerHandler.createBSRAssignmentRecord(Trigger.new);
            LoanApplicationApprovalTriggerHandler.handleTAT(Trigger.new, null);
            // START - SFAU-5663 - For STP cases credit ST condition should be mandatary before credit approval.
            LoanApplicationApprovalTriggerHandler.afterInsert(trigger.new);
            // END - SFAU-5663 - For STP cases credit ST condition should be mandatary before credit approval.
            LoanApplicationApprovalTriggerHandler.sendNotificationtoCreditBase(Trigger.new); // calling notification
            LoanApplicationApprovalTriggerHelper.submitToApprovalProcess( Trigger.new,  Trigger.newMap ); // SFAU-5179
            LoanApplicationApprovalTriggerHelper.updateTarstatusonCollateral( Trigger.new,  null );
        }
        if(Trigger.isUpdate){
            LoanApplicationApprovalTriggerHandler.allowApproverEditAccess(Trigger.new, Trigger.oldMap);
            LoanApplicationApprovalTriggerHandler.delegateApproval(Trigger.new, Trigger.oldMap);
            LoanApplicationApprovalTriggerHandler.updateLoanApplicationApproved(Trigger.New,Trigger.OldMap);
            // START - SFAU-5663 - For STP cases credit ST condition should be mandatary before credit approval.
            LoanApplicationApprovalTriggerHandler.afterUpdate(trigger.new,Trigger.oldMap);
            // END - SFAU-5663 - For STP cases credit ST condition should be mandatary before credit approval.
            LoanApplicationApprovalTriggerHandler.handleTAT(Trigger.new, Trigger.OldMap);
            LoanApplicationApprovalTriggerHandler.validateSubmitForApproval (Trigger.OldMap, Trigger.new); // SFAU-5179
            LoanApplicationApprovalTriggerHelper.updateTarstatusonCollateral( Trigger.new,  Trigger.OldMap );
        }
    }
}