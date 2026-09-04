/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 02-01-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public with sharing class AccountTeamMemberTriggerController implements Queueable{
    public String groupMemberRecords; 
    public Boolean isInsert; 
    public Boolean isDelete; 
    public AccountTeamMemberTriggerController(String groupMemberRecords,Boolean isInsert, Boolean isDelete){
        this.groupMemberRecords = groupMemberRecords;
        this.isInsert = isInsert;
        this.isDelete = isDelete;
    }
    public void execute(QueueableContext context) {
        List<GroupMember> groupMemberList = (List<GroupMember>)Json.deserialize(groupMemberRecords,List<GroupMember>.class);
        if(Schema.sObjectType.GroupMember.isCreateable() && isInsert){
            insert groupMemberList;
        }
        if(Schema.sObjectType.GroupMember.isDeletable() && isDelete){
            delete groupMemberList;
        }
    }
    public static void createQueueMember(List<AccountTeamMember> newRecordList , Map<Id,AccountTeamMember> newRecordMap){
        Map<String,String> accountVsUserId = new Map<String,String>();
        Map<String,String> accountIdvsQueueId = new Map<String,String>();
        List<GroupMember> groupMemberToInsert = new List<GroupMember>();
        for(AccountTeamMember accTeamMember : newRecordList){
            accountVsUserId.put(accTeamMember.AccountId,accTeamMember.userId);
        }
        for(Account accRecord : [SELECT Id,Account_Code__c,Branch_Queue__c FROM Account WHERE Id IN: accountVsUserId.keySet() WITH SECURITY_ENFORCED]){
            accountIdvsQueueId.put(accRecord.Id,accRecord.Branch_Queue__c);
        }
        for(AccountTeamMember accTeamMember : newRecordList){
            GroupMember groupMem = new GroupMember();
            groupMem.GroupId = accountIdvsQueueId.get(accTeamMember.AccountId);
            groupMem.UserOrGroupId = accTeamMember.userId;
            groupMemberToInsert.add(groupMem);
        }
        if(!groupMemberToInsert.isEmpty()){
            system.debug('groupMemberToInsert'+groupMemberToInsert);
            System.enqueueJob(new AccountTeamMemberTriggerController(JSON.serialize(groupMemberToInsert),true,false));
        }
    }
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 02-01-2023 
    * @param oldRecordMap 
    **/
    public static void deleteQueueMember(Map<Id,AccountTeamMember> oldRecordMap){
        Set<String> userIdDeleted = new Set<String>();
        Map<String,String> accountVsUserId = new Map<String,String>();
        Map<String,Set<String>> userIdVsAccount = new Map<String,Set<String>>();
        Map<String,String> queueIdVsAccountId = new Map<String,String>();
        Map<String,String> accountIdvsQueueId = new Map<String,String>();
        List<GroupMember> groupMemberToDelete = new List<GroupMember>();
        for(String deletedRecordId : oldRecordMap.keySet()){
            AccountTeamMember accTeamMember = oldRecordMap.get(deletedRecordId);
            userIdDeleted.add(accTeamMember.userId);
            accountVsUserId.put(accTeamMember.AccountId, accTeamMember.UserId);
            if(userIdVsAccount.containsKey(accTeamMember.UserId)){
                userIdVsAccount.get(accTeamMember.UserId).add(accTeamMember.AccountId);
            }else{
                userIdVsAccount.put(accTeamMember.UserId,new Set<String> {accTeamMember.AccountId});
            }
            
        }
        for(Account accRecord : [SELECT Id,Account_Code__c,Branch_Queue__c FROM Account WHERE Id IN: accountVsUserId.keySet() WITH SECURITY_ENFORCED]){
            queueIdVsAccountId.put(accRecord.Branch_Queue__c,accRecord.Id);
            accountIdvsQueueId.put(accRecord.Id,accRecord.Branch_Queue__c);
        }
        for(GroupMember groupRecord : [SELECT Id,UserOrGroupId,GroupId FROM GroupMember WHERE GroupId IN:queueIdVsAccountId.keySet() WITH SECURITY_ENFORCED]){
            if(userIdVsAccount.containsKey(groupRecord.UserOrGroupId)){
                for(String accountId : userIdVsAccount.get(groupRecord.UserOrGroupId)){
                    if(accountIdvsQueueId.containsKey(accountId) && groupRecord.GroupId == accountIdvsQueueId.get(accountId)){
                        groupMemberToDelete.add(groupRecord);
                    }
                }
                
            }
        }
        if(!groupMemberToDelete.isEmpty()){
            system.debug('groupMemberToDelete'+groupMemberToDelete);
            System.enqueueJob(new AccountTeamMemberTriggerController(JSON.serialize(groupMemberToDelete),false,true));
        }
    }
}