/**
 * @description       : 
 * @author            : Yash Shukla | Salesforce
 * @group             : 
 * @last modified on  : 31-03-2023
 * @last modified by  : Yash Shukla | Salesforce
**/
global class InactiveUserBatchController implements Database.batchable<sObject>, Database.Stateful{
    public Set<String> userIds = new Set<String>();
    private static final Set<String> APPLICATION_STAGES = new Set<String>{'Cancelled','Rejected','Disbursed','Approved'};
    private static final Set<String> TEAM_ROLE = new Set<String>{'Branch Manager','Team Lead'};
       // public Set<String> idString = new Set<String>{'a016s000003eR3MAAU','a016s000003bcPLAAY'};


    public InactiveUserBatchController(Set<String> userIds){
        this.userIds = userIds;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String queryString = 'Select Id, Name From USER Where IsActive = false AND Inactive_Completion__c = false';
        if(!userIds.isEmpty())
        {
            queryString+=' AND Id IN :userIds';
        }
        queryString+=' LIMIT 5';
        return Database.getQueryLocator(queryString);//
    }
    
    
    global void execute(Database.BatchableContext BC, List<sObject> userRecords) {
        try{
            Map<Id, User> scopeUserMap = new Map<Id, User>((List<User>)userRecords);
            Map<Id, Id> account_TeamMap = new Map<Id,Id>();
            List<Loan_Application__c> updateApplicationRecords = new List<Loan_Application__c>();
            if(!scopeUserMap.isEmpty()) {
                Map<Id, List<Loan_Application__c>> branchIdLoanApplicationsMap = new Map<Id, List<Loan_Application__c>>();
                Map<Id, List<String>> ownerIdLoanApplicationsIdMap = new Map<Id, List<String>>();
                for(Loan_Application__c application : [SELECT Id, Branch_Master__c, Stage__c, OwnerId FROM Loan_Application__c WHERE OwnerId IN : scopeUserMap.keySet()
                                                       AND Stage__c NOT IN :APPLICATION_STAGES
                                                      ])// AND ID IN:idString
                {
                    if(String.isNotBlank(application.Branch_Master__c)) {
                        if(!branchIdLoanApplicationsMap.containsKey(application.Branch_Master__c)) {
                            branchIdLoanApplicationsMap.put(application.Branch_Master__c, new List<Loan_Application__c>());
                        }
                        branchIdLoanApplicationsMap.get(application.Branch_Master__c).add(application);
                    }
                    
                    if(!ownerIdLoanApplicationsIdMap.containsKey(application.OwnerId)){
                        ownerIdLoanApplicationsIdMap.put(application.OwnerId, new List<String>());
                    }
                    ownerIdLoanApplicationsIdMap.get(application.OwnerId).add(application.Id);
                }                
                if(!branchIdLoanApplicationsMap.isEmpty()) {
                    for(AccountTeamMember atm : [SELECT Id, UserId, AccountId FROM AccountTeamMember WHERE AccountId IN : branchIdLoanApplicationsMap.keySet()
                                                 AND TeamMemberRole IN : TEAM_ROLE
                                                ])
                    {
                        if(!account_TeamMap.containsKey(atm.AccountId)) {
                            account_TeamMap.put(atm.AccountId, atm.UserId);
                        }
                    }
                    
                    Set<String> toBeUpdatedOwnerIds = new Set<String>();
                    for(Id accId : branchIdLoanApplicationsMap.keySet()) {
                        if(account_TeamMap.containsKey(accId) && !account_TeamMap.isEmpty()) {
                            for(Loan_Application__c application : branchIdLoanApplicationsMap.get(accId)) {
                                Loan_Application__c rec = application;
                                toBeUpdatedOwnerIds.add(rec.OwnerId);// to add the original owner to check if they are being edited
                                rec.OwnerId = account_TeamMap.get(accId);
                                updateApplicationRecords.add(rec);
                            }
                        }
                        
                    }
                    system.debug('toBeUpdatedOwnerIds-> '+toBeUpdatedOwnerIds);
                    List<String> failedRecordsId = new List<String>();
                    
                    if(!updateApplicationRecords.isEmpty()) {
                        List<Database.SaveResult> results = Database.update(updateApplicationRecords,false);
                        for(Database.SaveResult result : results){
                            if(!result.isSuccess()){
                                failedRecordsId.add(result.getId());
                                for(Database.Error err : result.getErrors()) {
                                    Log.error(err.getMessage(),Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),result.getId());
                                }
                            }
                        }
                    }
                    
                    for(Id usrId : scopeUserMap.keySet()) {
                        User usr = new User();
                        usr.Id = usrId;
                        Boolean isActiveComplete = true;
                        if(!toBeUpdatedOwnerIds.contains(usrId)){
                            Log.error('No Active Team Lead or Branch Manager associated with the Branch',Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),'');
                            isActiveComplete = false;
                        }
                        else {
                            for(String applicationId : ownerIdLoanApplicationsIdMap.get(usrId)){
                                if(failedRecordsId.contains(applicationId)){
                                    isActiveComplete = false;
                                    break;
                                }
                            }
                        }
						usr.Inactive_Completion__c = isActiveComplete;
                        scopeUserMap.put(usrId, usr);
                    }
                    
                    List<Database.SaveResult> resultsUser = Database.update(scopeUserMap.values(),false);
                    for(Database.SaveResult result : resultsUser){
                        if(!result.isSuccess()){
                            for(Database.Error err : result.getErrors()) {
                                Log.error(err.getMessage(),Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),result.getId());
                            }
                        }
                    }
                    
                }
            }
            
        }catch(Exception ex) {
            Log.error(ex,Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),'');
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        system.debug('batch completed');
    }

}