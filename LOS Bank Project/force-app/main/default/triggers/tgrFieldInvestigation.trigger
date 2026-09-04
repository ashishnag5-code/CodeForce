trigger tgrFieldInvestigation on Field_Investigation__c (before insert, after insert, after update, before update, before delete,after undelete) {
    new FieldInvestigationTriggerHandler().run('Field_Investigation__c', 'Field_Investigation_Trigger__c');
}