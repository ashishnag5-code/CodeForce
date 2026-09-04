trigger QueryTrigger on Query__c (before insert,after insert, before update) {
    
    //new QueryTriggerHandler().run('Query__c','Query_Trigger__c');
    if(Trigger.isBefore && Trigger.isInsert){
        QueryTriggerService.beforeInsert(Trigger.new);
    }
    if(Trigger.isAfter && Trigger.isInsert){
        QueryTriggerService.afterInsert(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        QueryTriggerService.beforeUpdate(Trigger.oldMap, Trigger.newMap);
    }

}