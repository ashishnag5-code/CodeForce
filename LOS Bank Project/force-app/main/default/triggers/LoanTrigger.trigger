trigger LoanTrigger on Loan_Application__c (before insert, after insert, after update, before update, before delete) {

        new LoanTriggerHandler().run('Loan_Application__c','Loan_Application_Trigger__c');

}