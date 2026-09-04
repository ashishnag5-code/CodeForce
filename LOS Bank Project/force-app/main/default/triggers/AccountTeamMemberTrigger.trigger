/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 02-01-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
trigger AccountTeamMemberTrigger on AccountTeamMember (before insert, after insert, after update, before update, before delete,after delete,after undelete) {
    system.debug('Inside Account Team member Trigger');
    new AccountTeamMemberTriggerHandler().run('AccountTeamMember', 'AccountTeamMember_Trigger__c');
}