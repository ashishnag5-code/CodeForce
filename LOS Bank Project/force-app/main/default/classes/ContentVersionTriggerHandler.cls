/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 01-13-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public with sharing class ContentVersionTriggerHandler extends TriggerHandler{
    public static Boolean boolTriggerRun = true;
    public override void afterInsert(){
        if(boolTriggerRun){
            ContentVersionTriggerService serviceInstance = new ContentVersionTriggerService();
            serviceInstance.afterInsert(Trigger.new,Trigger.NewMap);
        }
    }
    public override void beforeInsert(){
        if(boolTriggerRun){
            ContentVersionTriggerService serviceInstance = new ContentVersionTriggerService();
            serviceInstance.beforeInsert(Trigger.new);
        }
    }
    public override void afterUpdate(){
        if(boolTriggerRun){
            ContentVersionTriggerService serviceInstance = new ContentVersionTriggerService();
            serviceInstance.afterUpdate(Trigger.new,Trigger.OldMap,Trigger.NewMap);
        }
    }
}