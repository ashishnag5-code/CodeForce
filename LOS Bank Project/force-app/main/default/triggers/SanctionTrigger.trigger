trigger SanctionTrigger on Sanction_Condition__c (before insert, after insert, after update, before update) {
    
    
    if(Trigger.isBefore && Trigger.isInsert){
        SanctionTriggerHelper.handleInsertBefore(Trigger.new);
    }
    if(Trigger.isAFter && Trigger.isUpdate){
        SanctionTriggerHelper.handleUpdateAfter(Trigger.oldMap, Trigger.newMap);
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        SanctionTriggerHelper.handleUpdate(Trigger.oldMap, Trigger.newMap);
    }
    if(Trigger.isAfter && Trigger.isInsert){
        SanctionTriggerHelper.handleInsertAfter(Trigger.oldMap, Trigger.newMap);
    }


}