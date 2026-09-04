public with sharing class IntegrationChecklistTriggerHandler extends TriggerHandler {
	
    public override void afterUpdate(){
        IntegrationChecklistTriggerService serviceInstance = new IntegrationChecklistTriggerService();
        serviceInstance.afterUpdate(Trigger.new, Trigger.OldMap, Trigger.NewMap);
    }
    public override void afterInsert(){
        IntegrationChecklistTriggerService serviceInstance = new IntegrationChecklistTriggerService();
        serviceInstance.afterInsert(Trigger.new,Trigger.NewMap);
    }
     
}