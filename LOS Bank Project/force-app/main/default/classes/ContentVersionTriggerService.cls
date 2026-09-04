/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 01-13-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public with sharing class ContentVersionTriggerService implements ServiceInterface{
    public static Boolean boolRunCallback = true;

    public void beforeInsert(List<sObject> newRecordList){
        ContentVersionTriggerController.restrictSharingFile((List < ContentVersion > ) newRecordList);
    }
    
    public void afterInsert(List < sObject > newRecordList, Map < Id, sObject > newRecordMap) {
        ContentVersionTriggerController.hanlderFileSize((List < ContentVersion > ) newRecordList, (Map < Id, ContentVersion > ) newRecordMap);
        ContentVersionTriggerController.afterInsertHandler((List < ContentVersion > ) newRecordList, (Map < Id, ContentVersion > ) newRecordMap);
        if(boolRunCallback){
            MultipleFileUploadController.handleCartCallBackResponse((Map < Id, ContentVersion > ) newRecordMap);
            AUSFValuationController.handleValuationCallBackResponse((Map < Id, ContentVersion > ) newRecordMap);
            if(!Test.isRunningTest()){
                SignDeskEsignApiController.handleEsignSignDeskAPICallback((Map < Id, ContentVersion > ) newRecordMap);
            }
        }
    }
    
    public void beforeUpdate(List<sObject> newRecordList, Map<Id, sObject> oldRecordMap, Map<Id, sObject> newRecordMap) {
    }
    
    public void afterUpdate(List<sObject> newRecordList, Map<Id,sObject> oldRecordMap, Map<Id,sObject> newRecordMap){
       // MultipleFileUploadController.handleCartCallBackResponse((Map<Id,ContentVersion>) newRecordMap);
    }
    
    public void beforeDelete(Map<Id,sObject> oldRecordMap){
    }
    
    public void afterDelete(Map<Id,sObject> oldRecordMap){
    }
    
    public void afterUndelete(Map<Id,sObject> newRecordList){
    }   
}