public without sharing class QueryTriggerService {
    
    public static final List<String> RESTRICTED_STAGES = new List<String>{'Ops Maker','Ops Author','PDD'};
    public static void beforeInsert(List < sObject > newRecordList) {
        handleAutoClose(newRecordList);
        
    }
    public static void afterInsert(List < sObject > newRecordList) {
        List<Query__Share> shareRecords = new List<Query__Share>();
        List<Query__c> queryRecords = (List < Query__c > ) newRecordList;
        for(Query__c rec : queryRecords){
            if(rec.Assigned_To__c != UserInfo.getUserId()){
                Query__Share shareRec = new Query__Share();
                shareRec.ParentId = rec.Id;
                shareRec.UserOrGroupId = rec.Assigned_To__c;
                shareRec.AccessLevel = 'Edit';
                shareRec.RowCause = 'Manual';
                shareRecords.add(shareRec);

            }
            
        }
        if (!shareRecords.isEmpty())
        	insert shareRecords;
        
        //handleAutoClose(newRecordList);
        
    }
    
    public static void beforeUpdate(Map<Id,Sobject> oldRecordsMap, Map<Id,SObject> newRecordsMap){
        handleEditCheck((Map<Id,Query__c>)oldRecordsMap, (Map<Id,Query__c>)newRecordsMap);
        handleAutoClose(newRecordsMap.values());
    }
   /* 
    public static void afterUpdate(Map<Id,Sobject> oldRecordsMap, Map<Id,SObject> newRecordsMap){
        handleAutoClose(newRecordsMap.values());
    }*/
    
    private static void handleAutoClose(List<Query__c> records){
        for(Query__c query : records){
            if((UserInfo.getUserId() == query.Assigned_To__c) && String.isNotBlank(query.Remarks__c) && (query.Status__c =='New'||query.Status__c=='In Progress')){
                query.Status__c = 'Auto-Close';
            }
        }
    }

    /*Method added to check the edit access*/
    private static void handleEditCheck(Map<Id,Query__c> oldRecordsMap, Map<Id,Query__c> newRecordsMap) {
        Set<Id> loanIds = new Set<Id>();
        for(Id recId : newRecordsMap.keySet()){
            loanIds.add(newRecordsMap.get(recId).Loan_Application__c );
        }
        if(!loanIds.isEmpty()){
            Map<Id, String> loanIdStageMap = new Map<Id, String>();
            List<Loan_Application__c> applications = [SELECT Id, Stage__c FROM Loan_Application__c Where ID IN:loanIds];
            for(Loan_Application__c application : applications){
                loanIdStageMap.put(application.Id, application.Stage__c);
            }
            for(Id recId : newRecordsMap.keySet()){
                if((oldRecordsMap.get(recId).Status__c != newRecordsMap.get(recId).Status__c) && newRecordsMap.get(recId).Status__c!='Cancelled' && RESTRICTED_STAGES.contains(loanIdStageMap.get(newRecordsMap.get(recId).Loan_Application__c))){
                    newRecordsMap.get(recId).addError('You cannot edit the record. Please cancel the record and create new one for any queries');
                }
            }
        }
        
    }

}