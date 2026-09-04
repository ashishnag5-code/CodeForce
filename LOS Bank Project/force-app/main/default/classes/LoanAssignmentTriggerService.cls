/**
 * @author        Joshna
 * @date          11-Jun-2023
 * @description   Service class for Loan Assignment Trigger
 * @reference     TAT creation
 * Modification Log:
 * --------------------------------------------------------------------------------------------
 * Developer               Date            Description
 * --------------------------------------------------------------------------------------------
 * Joshna                  11-Jun-2023     Initial creation - added afterInsert & afterUpdate
 * Mohit M.                05-Oct-2023     SFAU-5335  
 * Yash S                   25-oct-2023    SFAU-5432
 */
public without sharing class LoanAssignmentTriggerService implements ServiceInterface{
    public void beforeInsert(List <sObject> newRecordList) {}
    //public void beforeUpdate(List <sObject> newRecordList, Map <Id, sObject> oldRecordMap, Map <Id, sObject> newRecordMap) {}
    public void beforeDelete(Map <Id, sObject> oldRecordMap) {}
    public void afterDelete(Map <Id, sObject> oldRecordMap) {}
    public void afterUndelete(Map <Id, sObject> newRecordList) {}

    public void afterInsert(List <sObject> newRecordList, Map <Id, sObject> newRecordMap) {
        List<Asynchronous_Event__e> tatEvents = new List<Asynchronous_Event__e>();
        for (Assignment__c each : (List<Assignment__c>) newRecordList) {
            Assignment__c loanAssignment = new Assignment__c(Id = each.Id, RecordTypeId = each.RecordTypeId, Status__c = each.Status__c,
                OwnerId = each.OwnerId, Loan_Application__c = each.Loan_Application__c, Remarks__c = each.Remarks__c);
            tatEvents.add(new Asynchronous_Event__e(Event_Type__c = 'TAT', New_Records_Payload__c = JSON.serialize(loanAssignment), Object_API_Name__c = 'Assignment__c',
                Event_Date_Time__c = Datetime.now(), Logged_In_User__c = UserInfo.getUserId()));
        }
        Eventbus.publish(tatEvents);
    }

    public void afterUpdate(List <sObject> newRecordList, Map <Id, sObject> oldRecordMap, Map <Id, sObject> newRecordMap) {
        List<Asynchronous_Event__e> tatEvents = new List<Asynchronous_Event__e>();
        List<Assignment__c> lstAssignment = new List<Assignment__c>();
        List<loan_application__share> sharedApplicationRecords = new List<loan_application__share>();
        Map<Id,Id> loanAppIdVsOwner = new Map<Id,Id>();
        for (Assignment__c each : (List<Assignment__c>) newRecordList) {
            Assignment__c oldRecord = (Assignment__c) oldRecordMap.get(each.Id);
            if (oldRecord.Status__c != each.Status__c || each.OwnerId != oldRecord.OwnerId) {
                Assignment__c newLoanAssignment = new Assignment__c(Id = each.Id, RecordTypeId = each.RecordTypeId, Status__c = each.Status__c,
                    OwnerId = each.OwnerId, Loan_Application__c = each.Loan_Application__c, Remarks__c = each.Remarks__c);
                Assignment__c oldLoanAssignment = new Assignment__c(Id = oldRecord.Id, RecordTypeId = each.RecordTypeId, Status__c = oldRecord.Status__c,
                    OwnerId = oldRecord.OwnerId, Loan_Application__c = oldRecord.Loan_Application__c, Remarks__c = oldRecord.Remarks__c);
                tatEvents.add(new Asynchronous_Event__e(Event_Type__c = 'TAT', New_Records_Payload__c = JSON.serialize(newLoanAssignment), Object_API_Name__c = 'Assignment__c',
                    Event_Date_Time__c = Datetime.now(), Old_Records_Payload__c = JSON.serialize(oldLoanAssignment), Logged_In_User__c = UserInfo.getUserId()));
            }
            if(!String.isBlank(oldRecord.OwnerId) && !String.isBlank(each.OwnerId) && each.OwnerId != oldRecord.OwnerId && String.valueOf(each.OwnerId).startsWith('005') /*&& String.valueOf(oldRecord.OwnerId).startsWith('005')*/) {
                lstAssignment.add(each);
                /*loan_application__share sharedRecord = new loan_application__share();
                sharedRecord.AccessLevel = 'edit';
                sharedRecord.ParentId = Id.valueOf(each.Loan_Application__c);//[Select Id,RecordType.Name from Assignment__c where Loan_Application__c=:objLoanApp.Id AND RecordType.Name = 'Ops - KYC' limit 1].Id;
                sharedRecord.UserOrGroupId = each.OwnerId;
                //sharedRecord.RowCause = Schema.Assignment__Share.RowCause.Share_to_RO__c;
                sharedApplicationRecords.add(sharedRecord);
                loanAppIdVsOwner.put(Id.valueOf(each.Loan_Application__c),each.OwnerId);*/
            }
        }
        if(!lstAssignment.isEmpty()) {
            shareApplicationToOwner(lstAssignment);
            //SFAU-5335
            //Database.insert(sharedApplicationRecords,false);
        }
        /*
        List<Document_Tracker__Share> docShareList = new List<Document_Tracker__Share>();
        if(!loanAppIdVsOwner.keySet().isEmpty()){
            // SFAU-5340 - Share Document Tracker Records
            List<Document_Tracker__c> docTrackerRecords = [SELECT Id FROM Document_Tracker__c Where Loan_Application__c IN: loanAppIdVsOwner.keySet()];
            for(Document_Tracker__c record : docTrackerRecords){
                Document_Tracker__Share shareObj = new Document_Tracker__Share();
                shareObj.ParentId = record.Id;
                shareObj.UserOrGroupId = UserInfo.getUserId();
                shareObj.AccessLevel = 'Read';
                System.debug('shareObj '+shareObj);
                docShareList.add(shareObj);
            }
        }
        insert docShareList;*/
        if (!tatEvents.isEmpty()) {
            Eventbus.publish(tatEvents);
        }
    }
    
    public void shareApplicationToOwner(List<Assignment__c> lstAssign){
        Map<Id,Id> loanAppIdVsOwner = new Map<Id,Id>();
        List<loan_application__share> sharedApplicationRecords = new List<loan_application__share>();
        for (Assignment__c each : lstAssign) {
            loan_application__share sharedRecord = new loan_application__share();
            sharedRecord.AccessLevel = 'edit';
            sharedRecord.ParentId = Id.valueOf(each.Loan_Application__c);//[Select Id,RecordType.Name from Assignment__c where Loan_Application__c=:objLoanApp.Id AND RecordType.Name = 'Ops - KYC' limit 1].Id;
            sharedRecord.UserOrGroupId = each.OwnerId;
            //sharedRecord.RowCause = Schema.Assignment__Share.RowCause.Share_to_RO__c;
            sharedApplicationRecords.add(sharedRecord);
            loanAppIdVsOwner.put(Id.valueOf(each.Loan_Application__c),each.OwnerId);
        } 
        if(!sharedApplicationRecords.isEmpty()) {
            //SFAU-5335
            Database.insert(sharedApplicationRecords,false);
        }   
        List<Document_Tracker__Share> docShareList = new List<Document_Tracker__Share>();
        if(!loanAppIdVsOwner.keySet().isEmpty()){
            // SFAU-5340 - Share Document Tracker Records
            List<Document_Tracker__c> docTrackerRecords = [SELECT Id FROM Document_Tracker__c Where Loan_Application__c IN: loanAppIdVsOwner.keySet()];
            for(Document_Tracker__c record : docTrackerRecords){
                Document_Tracker__Share shareObj = new Document_Tracker__Share();
                shareObj.ParentId = record.Id;
                shareObj.UserOrGroupId = UserInfo.getUserId();
                shareObj.AccessLevel = 'Read';
                System.debug('shareObj '+shareObj);
                docShareList.add(shareObj);
            }
        }
        if(!sharedApplicationRecords.isEmpty()) {
            //SFAU-5335
            Database.insert(docShareList,false);
        }  
        //insert docShareList;
    }

    public void beforeUpdate(List <sObject> newRecordList, Map <Id, sObject> oldRecordMap, Map <Id, sObject> newRecordMap) {
        handleOwnerChangeCheck((Map<Id,Assignment__c>)oldRecordMap , (Map<Id,Assignment__c>)newRecordMap);
    }
    
    public void handleOwnerChangeCheck(Map<Id,Assignment__c> oldAssignmentRecords, Map<Id,Assignment__c> newAssignmentRecords){
        Map<Id,User> userMap = new Map<Id,User>();
        Set<Id> assignmentOwnerIdSet = new Set<Id>();
        for(Id recId : newAssignmentRecords.keySet()){
            if(oldAssignmentRecords.get(recId).OwnerId != newAssignmentRecords.get(recId).OwnerId && newAssignmentRecords.get(recId).OwnerId.getSObjectType() == Schema.User.getSObjectType()){
                assignmentOwnerIdSet.add(newAssignmentRecords.get(recId).OwnerId);
            }
        }
        userMap = new Map<Id, User>([SELECT Id, Name, Profile.Name FROM USER WHERE ID IN:assignmentOwnerIdSet]);
        for(Id recId : newAssignmentRecords.keySet()){
            if(userMap.containsKey(newAssignmentRecords.get(recId).OwnerId)){
                if(userMap.get(newAssignmentRecords.get(recId).OwnerId).Profile.Name!='Operations'){
                    newAssignmentRecords.get(recId).addError('You cannot assign the Assignment Record to a Non-Operations User');
                }
            }
        }
    }
}