trigger LoanDedupeEventTrigger on Loan_Dedupe__e (after insert) {
    if( Trigger.isAfter && Trigger.isInsert ){
        LoanDedupeEventTriggerHandler.validateLeadDedupe( (Loan_Dedupe__e[])Trigger.new );
    }
}