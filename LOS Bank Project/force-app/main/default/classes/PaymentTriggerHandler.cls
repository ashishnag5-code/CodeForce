/*******************************************************************************************
 * @Name         PaymentTriggerHandler
 * @Author       Samridhi
 * @Description  Handler class for Payment Trigger
*******************************************************************************************/
/* MODIFICATION LOG
 * Version          Developer           Date               Description
 *-------------------------------------------------------------------------------------------
 *  1.0             Samridhi        19/10/2023         Initial Creation
 *                  Mohit M.        Nov-03-2023        SFAU-5483 - Invalid Account Number - Add before Insert and Before Update

*******************************************************************************************/
public with sharing class PaymentTriggerHandler extends TriggerHandler {

    public override void afterUpdate(){
        PaymentTriggerService serviceInstance = new PaymentTriggerService();
        serviceInstance.afterUpdate(Trigger.new, Trigger.OldMap, Trigger.NewMap);
    }
    
    public override void afterInsert(){
        PaymentTriggerService serviceInstance = new PaymentTriggerService();
        serviceInstance.afterInsert(Trigger.new, Trigger.NewMap);
    }
    
    public override void beforeInsert(){
        PaymentTriggerService serviceInstance = new PaymentTriggerService();
        serviceInstance.beforeInsert(Trigger.new);
    }

    public override void beforeUpdate(){
        PaymentTriggerService serviceInstance = new PaymentTriggerService();
        serviceInstance.beforeUpdate(Trigger.new, Trigger.OldMap, Trigger.NewMap);
    }
    
}