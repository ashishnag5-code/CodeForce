public with sharing class DocumentChecklistHandler extends TriggerHandler{
    public override void afterUpdate() {
        ServiceInterface objServ = new DocumentChecklistTriggerService();
        objServ.afterUpdate(Trigger.new, Trigger.oldMap, Trigger.newMap);
       
    }
}