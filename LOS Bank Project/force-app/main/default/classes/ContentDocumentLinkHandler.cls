/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 01-13-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public with sharing class ContentDocumentLinkHandler extends TriggerHandler{
    public override void afterInsert(){
        ContentDocumentLinkService serviceInstance = new ContentDocumentLinkService();
        serviceInstance.afterInsert(Trigger.new,Trigger.NewMap);
    }
    
    public override void beforeInsert(){
        ContentDocumentLinkService serviceInstance = new ContentDocumentLinkService();
        serviceInstance.beforeInsert(Trigger.new);
    }
    public override void afterUpdate(){
        ContentDocumentLinkService serviceInstance = new ContentDocumentLinkService();
        serviceInstance.afterUpdate(Trigger.new,Trigger.OldMap,Trigger.NewMap);
    }
}