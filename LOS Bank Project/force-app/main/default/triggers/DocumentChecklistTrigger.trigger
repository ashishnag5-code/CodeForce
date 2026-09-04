trigger DocumentChecklistTrigger on Document_Checklist__c (after update) {
    new DocumentChecklistHandler().run('Document_Checklist','Document_Checklist_Trigger__c');
}