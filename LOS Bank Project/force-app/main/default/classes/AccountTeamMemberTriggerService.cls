/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 02-01-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public with sharing class AccountTeamMemberTriggerService implements ServiceInterface{
    public void beforeInsert(List<sObject> newRecordList){
    }
    
    public void afterInsert(List<sObject> newRecordList,Map<Id,sObject> newRecordMap){
        AccountTeamMemberTriggerController.createQueueMember((List<AccountTeamMember>)newRecordList,(Map<Id,AccountTeamMember>) newRecordMap);
        ShareRecordsWithUsers.updateRecordAccessOnChangeOfRole(new Map<Id,sObject>(), newRecordMap, 'Insert');
    }
    
    public void beforeUpdate(List<sObject> newRecordList, Map<Id, sObject> oldRecordMap, Map<Id, sObject> newRecordMap) {
    }
    
    public void afterUpdate(List<sObject> newRecordList, Map<Id,sObject> oldRecordMap, Map<Id,sObject> newRecordMap){
        ShareRecordsWithUsers.updateRecordAccessOnChangeOfRole(oldRecordMap, newRecordMap, 'Update');
    }
    
    public void beforeDelete(Map<Id,sObject> oldRecordMap){
        system.debug('Inside before Delete');
        ShareRecordsWithUsers.updateRecordAccessOnChangeOfRole(oldRecordMap, new Map<Id,sObject>(), 'Delete');
    }
    
    public void afterDelete(Map<Id,sObject> oldRecordMap){
        AccountTeamMemberTriggerController.deleteQueueMember((Map<Id,AccountTeamMember>) oldRecordMap);
    }
    
    public void afterUndelete(Map<Id,sObject> newRecordList){
    }   
}