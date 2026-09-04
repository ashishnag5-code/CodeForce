public with sharing class VehicleTriggerHandler extends TriggerHandler{
    public override void afterInsert(){
        VehicleTriggerService serviceInstance = new VehicleTriggerService();
        serviceInstance.afterInsert(Trigger.new,Trigger.newMap);
    }

    public override void afterUpdate() {
        VehicleTriggerService serviceInstance = new VehicleTriggerService();
        serviceInstance.afterUpdate(Trigger.new, Trigger.oldMap, Trigger.newMap);
    }
}