trigger AccountTrigger on Account (before insert, after insert, after update, before update, before delete,after undelete) {
    new AccountTriggerHandler().run('Account', 'Account_Trigger__c');
}