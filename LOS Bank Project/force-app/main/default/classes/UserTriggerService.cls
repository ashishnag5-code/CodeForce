/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 02-01-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public with sharing class UserTriggerService implements ServiceInterface{
    public void beforeInsert(List<sObject> newRecordList){
        List<User> lstUser = (List<User>)newRecordList;
        // Assign Employee Id
        for (User objUser : lstUser) {
            objUser.Employee_Id__c = objUser.Employee_Code__c; 
        }
    }
    
    public void afterInsert(List<sObject> newRecordList,Map<Id,sObject> newRecordMap){
        UserTriggerController.addUserToQueueAndAccTeam((List<User>)newRecordList,(Map<Id,User>) newRecordMap);
        
    }
    
    public void beforeUpdate(List<sObject> newRecordList, Map<Id, sObject> oldRecordMap, Map<Id, sObject> newRecordMap) {
    }
    
    public void afterUpdate(List<sObject> newRecordList, Map<Id,sObject> oldRecordMap, Map<Id,sObject> newRecordMap){
        system.debug(LoggingLevel.Info, 'Run Trigger....');
        List<User> lstUser = (List<User>)newRecordList;
        Map<Id,User> mapOldUser = (Map<Id,User>) oldRecordMap;
        Map<Id,User> mapNewUser = (Map<Id,User>) newRecordMap;
        Map<Id,User> mapUserOld = new Map<Id,User>();
        Map<Id,User> mapUserNew = new Map<Id,User>();
        List<User> lstNewUser = new List<User>();
        for (User objUser : lstUser) {
            if (objUser.IsActive != mapOldUser.get(objUser.Id).IsActive || objUser.Title != mapOldUser.get(objUser.Id).Title || objUser.Branch_Code__c != mapOldUser.get(objUser.Id).Branch_Code__c) {
                lstNewUser.add(objUser);
                mapUserOld.put(objUser.Id,mapOldUser.get(objUser.Id));
                mapUserNew.put(objUser.Id,mapNewUser.get(objUser.Id));
            }
        }
        if (lstNewUser.size() > 0)
            UserTriggerController.addUserToQueueAndAccTeamUpdate(lstNewUser,mapUserOld,mapUserNew);
        ShareRecordsWithUsers.updateRecordAccessOnChangeOfUser(oldRecordMap, newRecordMap, 'Update');
    }
    
    public void beforeDelete(Map<Id,sObject> oldRecordMap){
    }
    
    public void afterDelete(Map<Id,sObject> oldRecordMap){
    }
    
    public void afterUndelete(Map<Id,sObject> newRecordList){
    }   
}