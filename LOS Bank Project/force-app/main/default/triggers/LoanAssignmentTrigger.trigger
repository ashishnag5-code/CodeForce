trigger LoanAssignmentTrigger on Assignment__c (after insert, after update, before update) {
    new LoanAssignmentTriggerHandler().run('Assignment__c','Loan_Assignment_Trigger__c');
}