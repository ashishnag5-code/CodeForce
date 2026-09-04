/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 02-01-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public with sharing class AccountTeamMemberTriggerHandler extends TriggerHandler{
    public override void afterInsert(){
        AccountTeamMemberTriggerService serviceInstance = new AccountTeamMemberTriggerService();
        serviceInstance.afterInsert(Trigger.new,Trigger.NewMap);
    }
    public override void beforeInsert(){
    }
    public override void afterUpdate(){
        AccountTeamMemberTriggerService serviceInstance = new AccountTeamMemberTriggerService();
        serviceInstance.afterUpdate(Trigger.new,Trigger.OldMap,Trigger.NewMap);
    }

    public override void beforeDelete(){
        AccountTeamMemberTriggerService serviceInstance = new AccountTeamMemberTriggerService();
        serviceInstance.beforeDelete(Trigger.OldMap);
    }

    public override void afterDelete(){
        AccountTeamMemberTriggerService serviceInstance = new AccountTeamMemberTriggerService();
        serviceInstance.afterDelete(Trigger.OldMap);
    }
    
}