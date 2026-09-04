public with sharing class COMShareApplicationRecordHandler {
    
    private static final List<String> READ_WRITE_STAGE  = new List<String>{'QDE','DDE','PSD','PDD'};
    private static final List<String> READ_STAGE  = new List<String>{'Credit','Pricing','Ops'};
    public static void publishCOMPlatformEventRecords(Set<Id> loanIds) {
        List<COM_Share_Record_Event__e > eventsToPublish = new List<COM_Share_Record_Event__e >();
        for(Id loanId : loanIds) {
            COM_Share_Record_Event__e eventRecord = new COM_Share_Record_Event__e();
            eventRecord.SObjectId__c = loanId;
            eventsToPublish.add(eventRecord);
        }
        List<Database.SaveResult> results = EventBus.publish(eventsToPublish);
        for(Database.SaveResult result : results) {
        }
    }
    
    public static void handleCOMPlatformRecordInsert(Map<Id, COM_Share_Record_Event__e> publishedEventRecord) {
        try {
            Set<Id> loanIds = new Set<Id>();
            for(Id eventId : publishedEventRecord.keySet()) {
                loanIds.add(publishedEventRecord.get(eventId).SObjectId__c);
            }
            if(!loanIds.isEmpty()) {
                Map<String, String> loanId_BranchIdMap = new Map<String,String>();
                Map<String, String> loanId_StageMap = new Map<String, String>();
                List<Loan_Application__c> applicationRecords = [SELECT Id, Branch_Master__c, Stage__c FROM Loan_Application__c
                                                                WHERE Id IN :loanIds
                                                               ];
                for(Loan_Application__c application : applicationRecords) {
                    if(String.isNotBlank(String.valueOf(application.Branch_Master__c))) {
                        loanId_BranchIdMap.put(application.Id, application.Branch_Master__c);
                        loanId_StageMap.put(application.Id, application.Stage__c);
                    }
                }
                Map<Id, Account> accountWithTeamMap = new Map<Id,Account>([SELECT Id, (Select Id, UserId, TeamMemberRole FROM AccountTeamMembers 
                                                                                       WHERE TeamMemberRole = 'Com')
                                                                           FROM Account WHERE Id IN:loanId_BranchIdMap.values()
                                                                          ]);
                List<Loan_Application__Share> sharedApplicationRecords = new List<Loan_Application__Share>();
                for(String loanId : loanId_BranchIdMap.keySet()) {
                    if(accountWithTeamMap.get(loanId_BranchIdMap.get(loanId)).AccountTeamMembers.size()>0){
                        for(AccountTeamMember act : accountWithTeamMap.get(loanId_BranchIdMap.get(loanId)).AccountTeamMembers) {
                            if(READ_WRITE_STAGE.contains(loanId_StageMap.get(loanId)) || READ_STAGE.contains(loanId_StageMap.get(loanId))) {
                                Loan_Application__Share sharedRecord = new Loan_Application__Share();
                                sharedRecord.AccessLevel = (READ_WRITE_STAGE.contains(loanId_StageMap.get(loanId))) ? 'Edit' : 'Read';
                                sharedRecord.ParentId = loanId;
                                sharedRecord.UserOrGroupId = act.UserId;
                                sharedApplicationRecords.add(sharedRecord);
                            }
                            
                        }
                    }
                }
                if(!sharedApplicationRecords.isEmpty()) {
                    Database.insert(sharedApplicationRecords,false);
                }
            }
            
        }catch (Exception ex) {
            Log.error(ex,Log.SeverityType.valueOf(GlobalConstants.HIGH),'');
        }
    }
}