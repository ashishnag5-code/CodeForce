/*******************************************************************************************
* @Name         AddressTriggerHandler
* @Author       Gaurav Gaur
* @Description  Handler class for Address Trigger
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer           Date               Description
*-------------------------------------------------------------------------------------------
*  1.0             Gaurav Gaur        06/02/2023         Initial Creation 
*******************************************************************************************/
public with sharing class AddressTriggerHandler extends TriggerHandler{
    public override void afterInsert(){
        AddressTriggerService serviceInstance = new AddressTriggerService();
        serviceInstance.afterInsert(Trigger.new, Trigger.newMap);
    }
    public override void beforeInsert(){
        AddressTriggerService serviceInstance = new AddressTriggerService();
        serviceInstance.beforeInsert(Trigger.new);
    }
    public override void beforeUpdate(){
        AddressTriggerService serviceInstance = new AddressTriggerService();
        serviceInstance.beforeUpdate(Trigger.new, Trigger.OldMap, Trigger.NewMap);
    }
    
    public override void afterUpdate(){
        AddressTriggerService serviceInstance = new AddressTriggerService();
        serviceInstance.afterUpdate(Trigger.new, Trigger.OldMap, Trigger.NewMap);
    }
}