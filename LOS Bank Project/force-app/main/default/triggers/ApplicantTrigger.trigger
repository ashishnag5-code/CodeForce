trigger ApplicantTrigger on Applicant__c (before insert, after insert, after update, before update, before delete) {
    new ApplicantTriggerHandler().run('Applicant__c', 'Applicant_Trigger__c');
}