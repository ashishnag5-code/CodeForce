public with sharing class ChargeTriggerHandler extends TriggerHandler{
    public override void afterInsert(){
        ChargeTriggerService serviceInstance = new ChargeTriggerService();
        serviceInstance.afterInsert(Trigger.new, Trigger.NewMap);
    }
    
    public override void beforeInsert(){
    }
    
    public override void afterUpdate(){
        ChargeTriggerService serviceInstance = new ChargeTriggerService();
        serviceInstance.afterUpdate(Trigger.new, Trigger.OldMap, Trigger.NewMap);
    }
}