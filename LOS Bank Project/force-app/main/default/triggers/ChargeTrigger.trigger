trigger ChargeTrigger on Charge__c (before insert, after insert, after update, before update, before delete) {
    new ChargeTriggerHandler().run('Charge__c', 'Charge_Trigger__c');
}