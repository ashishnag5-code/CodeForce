/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 02-08-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public with sharing class AccountTriggerController {
    public static Id branchRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Branch').getRecordTypeId();
    public static void createAccountQueue(List<Account> newRecordList, Map<Id,Account> newRecordMap){
        Map<String,String> accIdVsBranchMap = new Map<String,String>();
        Map<String,String> branchVsAccountId = new Map<String,String>();
        Map<String,String> accountIdVsQueueId = new Map<String,String>();
        List<Group> groupToInsert = new List<Group>();
        List<QueuesObject> queueToInsert = new List<QueuesObject>();
        List<Account> accListToUpdate = new List<Account>();
        Set<String> groupIds = new Set<String>();
        Database.SaveResult[] results;
        for(Account accRecord : newRecordList){
            if(String.isNotBlank(accRecord.Account_Code__c) && accRecord.RecordTypeId == branchRecordTypeId){
                accIdVsBranchMap.put(accRecord.Id,accRecord.Account_Code__c+'-'+accRecord.Name);
                branchVsAccountId.put(accRecord.Account_Code__c+'-'+accRecord.Name,accRecord.Id);
            }
        }
        if(!accIdVsBranchMap.isEmpty()){
            for(String accId : accIdVsBranchMap.keySet()){
                Group testGroup = new Group(Name= accIdVsBranchMap.get(accid), Type='Queue');
                groupToInsert.add(testGroup);
            }

        }
        if(!groupToInsert.isEmpty()){
            results = Database.insert(groupToInsert, false);
            for(Integer index = 0, size = results.size(); index < size; index++) {
                if(results[index].isSuccess()) {
                    accountIdVsQueueId.put(branchVsAccountId.get(groupToInsert[index].Name),results[index].getId());
                    groupIds.add(results[index].getId());
                }else{
                    for(Database.Error err : results[index].getErrors()){
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
        }
        system.debug('accountIdVsQueueId'+accountIdVsQueueId);
        if(!groupIds.isEmpty()){
            insertObjectRelation(groupIds);
        }
        if(!accountIdVsQueueId.isEmpty()){
            for(String accid :accountIdVsQueueId.keySet()){
                Account accRecord =  new Account();
                accRecord.Id = accid;
                accRecord.Branch_Queue__c = accountIdVsQueueId.get(accid);
                accListToUpdate.add(accRecord);
            }
        }
        if(!accListToUpdate.isEmpty()){
            if(Schema.sObjectType.Account.isUpdateable()){
                Database.update(accListToUpdate, false);
            }
            
        }
        /* if(!queueToInsert.isEmpty()){
            
            System.debug('queueToInsert'+queueToInsert);
            Database.SaveResult[] srList1 =Database.insert(queueToInsert, false);
            for (Database.SaveResult sr : srList1) {
                if (sr.isSuccess()) {
                    System.debug('Successfully inserted account. Group ID: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors 
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
        } */
    }
    /**
    * @description Future method to handle mixed DML.
    * @author Harshit Goyal | Salesforce | 01-27-2023 
    * @param groupIdSet 
    **/
    @future
    public static void insertObjectRelation(Set<String> groupIdSet){
        List<QueuesObject> queueToInsert = new List<QueuesObject>();
        for(String groupId : groupIdSet){
            QueuesObject queueRec= new QueuesObject (QueueId=groupId,SObjectType ='Loan_Application__c');
            queueToInsert.add(queueRec);
        }
        if(!queueToInsert.isEmpty()){
            if(Schema.sObjectType.QueuesObject.isCreateable()){
                Database.insert(queueToInsert, false);
            }
            
        }
    }

}