/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 01-13-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/

trigger ContentDocumentLinkTrigger on ContentDocumentLink (before insert, after insert, after update, before update, before delete,after undelete) {
    new ContentDocumentLinkHandler().run('ContentDocumentLink', 'ContentDocumentLink_Trigger__c');
}