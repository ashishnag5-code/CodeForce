/**
 * @description       : 
 * @author            : Mohit M. | Salesforce
 * @group             : 
 * @last modified on  : 01-31-2023
 * @last modified by  : Mohit M. | Salesforce
**/
public with sharing class FieldInvestigationTriggerHandler extends TriggerHandler{
    public override void afterInsert(){
        FieldInvestigationService serviceInstance = new FieldInvestigationService();
        serviceInstance.afterInsert(Trigger.new,Trigger.NewMap);
    }
    
    public override void beforeInsert(){
        FieldInvestigationService serviceInstance = new FieldInvestigationService();
        serviceInstance.beforeInsert(Trigger.new);
    }
    
    public override void afterUpdate(){
        FieldInvestigationService serviceInstance = new FieldInvestigationService();
        serviceInstance.afterupdate(Trigger.new,Trigger.OldMap, Trigger.NewMap);
    }
}