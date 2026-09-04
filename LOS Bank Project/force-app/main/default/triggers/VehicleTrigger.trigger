trigger VehicleTrigger on Collateral__c (before insert, after insert, after update, before update, before delete) {
    new VehicleTriggerHandler().run('Collateral__c', 'Collateral_Trigger__c');
}