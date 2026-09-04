trigger IntegrationChecklistTrigger on Integration_Checklist__c (before insert, after insert, after update, before update, before delete) {
    new IntegrationChecklistTriggerHandler().run('Integration_Checklist__c', 'Applicant_Trigger__c');
}