/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 01-13-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public with sharing class ContentDocumentLinkService implements ServiceInterface{
    public void beforeInsert(List<sObject> newRecordList){
          ContentDocumentLinkController.restrictShare((List<ContentDocumentLink>)newRecordList);
    }
    
    public void afterInsert(List<sObject> newRecordList,Map<Id,sObject> newRecordMap){
        ContentDocumentLinkController.checkActiveVersions((List<ContentDocumentLink>)newRecordList,(Map<Id,ContentDocumentLink>) newRecordMap);
    }
    
    public void beforeUpdate(List<sObject> newRecordList, Map<Id, sObject> oldRecordMap, Map<Id, sObject> newRecordMap) {
    }
    
    public void afterUpdate(List<sObject> newRecordList, Map<Id,sObject> oldRecordMap, Map<Id,sObject> newRecordMap){
    }
    
    public void beforeDelete(Map<Id,sObject> oldRecordMap){
    }
    
    public void afterDelete(Map<Id,sObject> oldRecordMap){
    }
    
    public void afterUndelete(Map<Id,sObject> newRecordList){
    }   
}