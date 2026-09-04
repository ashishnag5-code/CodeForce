public with sharing class ShareRecordsAccessUpateBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    public final Map<Id, List<Id>> branchVsUserIdMap;
    public final Map<Id, List<Id>> branchVsUserIdMapToDelete;
    public final String dmlOperation;
    List<Loan_Application__c> loanApplications{get;set;}

    public ShareRecordsAccessUpateBatch(Map<Id, List<Id>> branchVsUsers, Map<Id, List<Id>> branchVsUsersToDelete){
        branchVsUserIdMap = branchVsUsers;
        branchVsUserIdMapToDelete = branchVsUsersToDelete;
        if(branchVsUserIdMapToDelete!=null && branchVsUserIdMapToDelete.keySet().size()>0){
            dmlOperation = 'Delete';
        }else{
            dmlOperation = 'Insert';
        }
        system.debug('dmlOperation '+dmlOperation);
        system.debug('branchVsUserIdMap '+branchVsUserIdMap);
        system.debug('branchVsUserIdMapToDelete '+branchVsUserIdMapToDelete);
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query;
        Set<Id> ids;
        system.debug('branchVsUserIdMap.keySet() '+branchVsUserIdMap.keySet());
        system.debug('branchVsUserIdMapToDelete.keySet() '+branchVsUserIdMapToDelete.keySet());

        if(dmlOperation == 'Insert'){
            ids = branchVsUserIdMap.keySet();
            query = 'Select Id, Branch_master__c, Product__c From Loan_Application__c WHERE Branch_Master__c IN: ids';
        }
        else if(dmlOperation == 'Delete'){
            ids = branchVsUserIdMapToDelete.keySet();
            query = 'Select Id, Branch_master__c, Product__c From Loan_Application__c WHERE Branch_Master__c IN: ids';
        }
        return Database.getQueryLocator(query);
     }

     public void execute(Database.BatchableContext BC, List<Loan_Application__c> loanApps){
        system.debug('loanApps '+loanApps);
        loanApplications = loanApps;
        
        if(dmlOperation == 'Delete'){
            system.debug('branchVsUserIdMapToDelete in execute '+branchVsUserIdMapToDelete);
            performOperationOnShareRecords(branchVsUserIdMapToDelete, dmlOperation, loanApplications);
        }
        if(dmlOperation == 'Insert'){
            system.debug('branchVsUserIdMap in execute '+branchVsUserIdMap);
            performOperationOnShareRecords(branchVsUserIdMap, dmlOperation, loanApplications);
        }
        
    }

    public static void performOperationOnShareRecords(Map<Id, List<Id>> branchVsUserIdTempMap, String currentOperation, List<Loan_Application__c> loanApps){
        Map<Id, List<Id>> currentBranchVsUserMap = new Map<Id, List<Id>>();
        Map<Id, Loan_Application__c> loanMap = new Map<Id, Loan_Application__c>();
        Map<String, Accessible_Products__mdt> accessibleProductLabelVsValue = new Map<String, Accessible_Products__mdt>();
        List<Loan_Application__Share> shareRecords = new List<Loan_Application__Share>();
        List<Id> userIds = new List<Id>();
        List<Accessible_Products__mdt> accessibleProducts = Accessible_Products__mdt.getAll().values();

        currentBranchVsUserMap = branchVsUserIdTempMap;
        system.debug('branchVsUserIdTempMap '+branchVsUserIdTempMap);
        for(List<Id> uId: currentBranchVsUserMap.values()){
            userIds.addAll(uId);
        }
        for(Loan_Application__c loan: loanApps){
            loanMap.put(loan.Id, loan);
        }
        
        for(Accessible_Products__mdt product: accessibleProducts){
            accessibleProductLabelVsValue.put(product.MasterLabel, product);
        }

        Map<Id, User> users = new Map<Id, User>([SELECT Id, Product_Accessible__c FROM User WHERE Id IN :userIds AND Id!= :UserInfo.getUserId()]);   
        if(currentOperation == 'Insert'){
            system.debug('Inside Insert');
            for(Loan_Application__c loan : loanApps){
                system.debug('loan '+loan);
                if(currentBranchVsUserMap.keySet().contains(loan.Branch_master__c)){
                    system.debug('currentBranchVsUserMap contains  '+loan.Branch_master__c);
                    for(Id userId: currentBranchVsUserMap.get(loan.Branch_master__c)){
                        system.debug('userId  '+userId);
                        if(users.keySet().contains(userId)){
                            system.debug('users contain  '+userId);
                            User currentUser = users.get(userId);
                            if(accessibleProductLabelVsValue.keySet().contains(currentUser.Product_Accessible__c) && accessibleProductLabelVsValue.get(currentUser.Product_Accessible__c).Product_Codes__c.contains(loan.Product__c)){
                                system.debug('loan share create  '+userId);
                                Loan_Application__Share loanShare = new Loan_Application__Share();
                                loanShare.ParentId = loan.Id;
                                loanShare.UserOrGroupId = userId;
                                loanShare.AccessLevel = 'Edit';
                                shareRecords.add(loanShare);
                            }
                        } 
                    }
                }
            }
            system.debug('shareRecords '+shareRecords);
            if(shareRecords!=null && shareRecords.size()>0){
                DatabaseUtility.createRecords(shareRecords, 'Loan_Application__Share');
                //Database.insert(shareRecords,false);
            }
        }       
        if(currentOperation == 'Delete'){
            List<Loan_Application__Share> shareRecordsRelatedToUser = [SELECT Id, ParentId, Parent.Branch_Master__c, Parent.OwnerId, UserOrGroupId FROM Loan_Application__Share
            WHERE Parent.Branch_Master__c IN: currentBranchVsUserMap.keySet()];
            for(Loan_Application__Share loanShare: shareRecordsRelatedToUser){
                if(currentBranchVsUserMap.keySet().contains(loanShare.Parent.Branch_Master__c) && currentBranchVsUserMap.get(loanShare.Parent.Branch_Master__c).contains(loanShare.UserOrGroupId)){
                    if(loanShare.UserOrGroupId != loanShare.Parent.OwnerId){
                        shareRecords.add(loanShare);
                    }
                    
                }
            }
            if(shareRecords!=null && shareRecords.size()>0){
                DatabaseUtility.deleteRecords(shareRecords, 'Loan_Application__Share');
                //delete shareRecords;
            }
        }
        
    }

    public void finish(Database.BatchableContext info){    
        system.debug('in finish dmlOperation '+dmlOperation);
        if(dmlOperation == 'Delete'){
            Database.executeBatch(new ShareRecordsAccessUpateBatch(branchVsUserIdMap, new Map<Id, List<Id>>()),1000);
        }
    }
}