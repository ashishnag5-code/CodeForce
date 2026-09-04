trigger AddressTrigger on Address__c (before insert, after insert, after update, before update, before delete) {
    new AddressTriggerHandler().run('Address__c', 'Address_Trigger__c');
}