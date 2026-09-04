/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on || last modified by
 * 01-27-2023			Harshit Goyal (Salesforce)
 * 05-15-2023		 || Mohit M (Salesforce)
 * 
**/
public with sharing class UserTriggerHandler extends TriggerHandler{
    public override void afterInsert(){
        UserTriggerService serviceInstance = new UserTriggerService();
        serviceInstance.afterInsert(Trigger.new,Trigger.NewMap);
    }
    public override void beforeInsert(){
        UserTriggerService serviceInstance = new UserTriggerService();
        serviceInstance.beforeInsert(Trigger.new);
    }
    public override void afterUpdate(){
        UserTriggerService serviceInstance = new UserTriggerService();
        serviceInstance.afterUpdate(Trigger.new,Trigger.OldMap,Trigger.NewMap);
    }
}