/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 01-27-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public with sharing class AccountTriggerHandler extends TriggerHandler{
    public override void afterInsert(){
        AccountTriggerService serviceInstance = new AccountTriggerService();
        serviceInstance.afterInsert(Trigger.new,Trigger.NewMap);
    }
    public override void beforeInsert(){
    }
    public override void afterUpdate(){
        AccountTriggerService serviceInstance = new AccountTriggerService();
        serviceInstance.afterUpdate(Trigger.new,Trigger.OldMap,Trigger.NewMap);
    }
}