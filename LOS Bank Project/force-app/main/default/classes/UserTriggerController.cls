/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 02-01-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public with sharing class UserTriggerController implements Queueable{
    public static Id currentUserProfileId = UserInfo.getProfileId();
    public static Set<String> titleSet = new Set<String>{'Regional Officer','Branch Manager','Team Lead'};
    public static String salesProfile =GlobalConstants.SALES_PROFILE;
    public static String typeQueue = GlobalConstants.TYPE_QUEUE;
    public static String editAccess = GlobalConstants.EDIT_ACCESS;
    public String teamMemberRecords; 
    public Boolean isInsert; 
    public Boolean isDelete; 
    public Boolean isUpdate;
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 02-01-2023 
    * @param teamMemberRecords 
    * @param isInsert 
    * @param isDelete 
    * @param isUpdate 
    **/
    public UserTriggerController(String teamMemberRecords,Boolean isInsert, Boolean isDelete,Boolean isUpdate){
        this.teamMemberRecords = teamMemberRecords;
        this.isInsert = isInsert;
        this.isDelete = isDelete;
        this.isUpdate = isUpdate;
    }
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 02-01-2023 
    * @param context 
    **/
    public void execute(QueueableContext context) {
        List<AccountTeamMember> teamMemberList = (List<AccountTeamMember>)Json.deserialize(teamMemberRecords,List<AccountTeamMember>.class);
        if(Schema.sObjectType.AccountTeamMember.isCreateable() && isInsert){
            insert teamMemberList;
        }
        if(Schema.sObjectType.AccountTeamMember.isDeletable() && isDelete){
            delete teamMemberList;
        }
        if(Schema.sObjectType.AccountTeamMember.isUpdateable() && isUpdate){
            update teamMemberList;
        }
    }
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 01-27-2023 
    * @param newRecordList 
    * @param newRecordMap 
    **/
    public static void addUserToQueueAndAccTeam(List<User> newRecordList, Map<Id,User> newRecordMap){
        titleSet = Utility.splitCustomLabel(System.Label.UserTitleList);
        system.debug('titleSet'+titleSet);
        String profileId = [SELECT Name FROM Profile WHERE Name =: salesProfile]?.Id;
        List<AccountTeamMember> accMemberToInsert = new List<AccountTeamMember>();
        List<GroupMember> groupMemberToInsert = new List<GroupMember>();
        Map<String,Set<String>> branchVsUserId = new Map<String,Set<String>>();
        Map<String,String> accountCodevsId = new Map<String,String>();
        Map<String,String> accountCodevsQueueId = new Map<String,String>();
        for(User userRecord : newRecordList){
            if( userRecord.isActive && userRecord.ProfileId == profileId && String.isNotBlank(userRecord.Title) && titleSet.contains(userRecord.Title) && String.isNotBlank(userRecord.Branch_Code__c)){
                if(userRecord.Branch_Code__c.contains(',')){
                    String[] branches = userRecord.Branch_Code__c.split(',');
                    for(String branchCode :branches){
                        if(branchVsUserId.containsKey(branchCode)){
                            branchVsUserId.get(branchCode).add(userRecord.Id);
                        }else{
                            branchVsUserId.put(branchCode,new Set<String>{userRecord.Id});
                        }
                    }
                }else{
                    branchVsUserId.put(userRecord.Branch_Code__c,new Set<String>{userRecord.Id});
                }  
            }
        }

        if(!branchVsUserId.isEmpty()){
            for(Account accRecord : [SELECT Id,Account_Code__c,Branch_Queue__c FROM Account WHERE Account_Code__c IN: branchVsUserId.keySet() WITH SECURITY_ENFORCED]){
                accountCodevsId.put(accRecord.Account_Code__c,accRecord.Id);
                accountCodevsQueueId.put(accRecord.Account_Code__c,accRecord.Branch_Queue__c);
            }
        }
        for(User userRecord : newRecordList){
            if( userRecord.ProfileId == profileId && String.isNotBlank(userRecord.Title) && titleSet.contains(userRecord.Title)){
                if(userRecord.Branch_Code__c.contains(',')){
                    String[] branches = userRecord.Branch_Code__c.split(',');
                    Set<String> checkDup = new Set<String>();
                    for(String branchCode :branches){
                        if(!checkDup.contains(branchCode)){
                            AccountTeamMember accMember = new AccountTeamMember();
                            accMember.UserId = userRecord.id;
                            accMember.AccountId = accountCodevsId.get(branchCode);
                            accMember.TeamMemberRole=userRecord.Title;
                            accMember.AccountAccessLevel = editAccess;
                            accMemberToInsert.add(accMember);
                            checkDup.add(branchCode);
                        }
                    }
                }else{
                    AccountTeamMember accMember = new AccountTeamMember();
                    accMember.UserId = userRecord.id;
                    accMember.AccountId = accountCodevsId.get(userRecord.Branch_Code__c);
                    accMember.TeamMemberRole=userRecord.Title;
                    accMember.AccountAccessLevel = editAccess;
                    accMemberToInsert.add(accMember);
                }

            }
        }
        if(!accMemberToInsert.isEmpty()){
            if(Schema.sObjectType.AccountTeamMember.isCreateable()){
                System.enqueueJob(new UserTriggerController(JSON.serialize(accMemberToInsert),true,false,false));
            }

        }
    }
    
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 01-31-2023 
    * @param newRecordList 
    * @param oldRecordMap 
    * @param newRecordMap 
    **/
    public static void addUserToQueueAndAccTeamUpdate(List<User> newRecordList,Map<Id,User> oldRecordMap, Map<Id,User> newRecordMap){
        titleSet = Utility.splitCustomLabel(System.Label.UserTitleList);
        system.debug('titleSet'+titleSet);
        String profileId = [SELECT Name FROM Profile WHERE Name =: salesProfile]?.Id;
        Map<String,Set<String>> branchVsUserIdToCreate = new Map<String,Set<String>>();
        Map<String,Set<String>> branchVsUserIdToDelete = new Map<String,Set<String>>();
        Set<String> branchIdsSet = new Set<String>();
        Set<String> branchesSetNew=new Set<String>();
        Set<String> branchesSetNewFinal=new Set<String>();
        Set<String> branchesSetOld=new Set<String>();
        Set<String> branchesSetOldFinal=new Set<String>();
        Map<String,String> accountCodevsId = new Map<String,String>();
        Map<String,String> accountCodevsQueueId = new Map<String,String>();
        Map<String,String> userIdVsnewRole = new Map<String,String>();
        Map<String,String> userIdVsRoles = new Map<String,String>();
        List<AccountTeamMember> accMemberToUpdate = new List<AccountTeamMember>();
        List<AccountTeamMember> accMemberToInsert = new List<AccountTeamMember>();
        List<AccountTeamMember> accMemberToDelete = new List<AccountTeamMember>();
        for(User userRecord : newRecordList){
            userIdVsRoles.put(userRecord.Id,userRecord.Title);
            if(userRecord.isActive && userRecord.ProfileId == profileId && String.isNotBlank(userRecord.Title) && titleSet.contains(userRecord.Title)
            && String.isNotBlank(userRecord.Branch_Code__c) && userRecord.Branch_Code__c != oldRecordMap.get(userRecord.Id).Branch_Code__c){
                if(userRecord.Branch_Code__c.contains(',')){
                    String[] branches = userRecord.Branch_Code__c.split(',');
                    branchesSetNew.addAll(branches);
                    branchesSetNewFinal.addAll(branches);
                    if(String.isNotBlank(oldRecordMap.get(userRecord.Id).Branch_Code__c) 
                    && oldRecordMap.get(userRecord.Id).Branch_Code__c.contains(',')){
                        String[] branchesOld = oldRecordMap.get(userRecord.Id).Branch_Code__c.split(',');
                        branchesSetOld.addAll(branchesOld);
                        branchesSetOldFinal.addAll(branchesOld);
                        branchesSetOldFinal.removeAll(branchesSetNew);
                        branchesSetNewFinal.removeAll(branchesSetOld);
                    }else if(String.isNotBlank(oldRecordMap.get(userRecord.Id).Branch_Code__c)){
                        branchesSetOld.add(oldRecordMap.get(userRecord.Id).Branch_Code__c);
                        branchesSetOldFinal.add(oldRecordMap.get(userRecord.Id).Branch_Code__c);
                        branchesSetOldFinal.removeAll(branchesSetNew);
                        branchesSetNewFinal.remove(oldRecordMap.get(userRecord.Id).Branch_Code__c);
                    }
                    for(String branchCode :branchesSetNewFinal){
                        if(branchVsUserIdToCreate.containsKey(branchCode)){
                            branchVsUserIdToCreate.get(branchCode).add(userRecord.Id);
                            branchIdsSet.add(branchCode);
                        }else{
                            branchVsUserIdToCreate.put(branchCode,new Set<String>{userRecord.Id});
                            branchIdsSet.add(branchCode);
                        }
                    }
                    for(String branchCode :branchesSetOldFinal){
                        if(branchVsUserIdToDelete.containsKey(branchCode)){
                            branchVsUserIdToDelete.get(branchCode).add(userRecord.Id);
                            branchIdsSet.add(branchCode);
                        }else{
                            branchVsUserIdToDelete.put(branchCode,new Set<String>{userRecord.Id});
                            branchIdsSet.add(branchCode);
                        }
                    }
                }else if(String.isNotBlank(userRecord.Branch_Code__c) &&  String.isNotBlank(oldRecordMap.get(userRecord.Id).Branch_Code__c)){
                    if(oldRecordMap.get(userRecord.Id).Branch_Code__c.contains(',')){
                        String[] branchesOld = oldRecordMap.get(userRecord.Id).Branch_Code__c.split(',');
                        branchesSetOld.addAll(branchesOld);
                        if(branchesSetOld.contains(userRecord.Branch_Code__c)){
                            branchesSetOld.remove(userRecord.Branch_Code__c);
                            for(String branchCode : branchesSetOld){
                                if(branchVsUserIdToDelete.containsKey(branchCode)){
                                    branchVsUserIdToDelete.get(branchCode).add(userRecord.Id);
                                    branchIdsSet.add(branchCode);
                                }else{
                                    branchVsUserIdToDelete.put(branchCode,new Set<String>{userRecord.Id});
                                    branchIdsSet.add(branchCode);
                                }
                            }
                        }else{
                            branchVsUserIdToCreate.put(userRecord.Branch_Code__c,new Set<String>{userRecord.Id}); 
                            branchIdsSet.add(userRecord.Branch_Code__c);
                        }
                    }
                }else if(String.isNotBlank(userRecord.Branch_Code__c) &&  String.isBlank(oldRecordMap.get(userRecord.Id).Branch_Code__c)){
                    branchVsUserIdToCreate.put(userRecord.Branch_Code__c,new Set<String>{userRecord.Id});
                    branchIdsSet.add(userRecord.Branch_Code__c);
                }
            }else if(userRecord.isActive && userRecord.ProfileId == profileId && String.isNotBlank(userRecord.Title) && titleSet.contains(userRecord.Title)
            && String.isNotBlank(userRecord.Branch_Code__c) && userRecord.IsActive != oldRecordMap.get(userRecord.Id).IsActive){
                if(userRecord.Branch_Code__c.contains(',')){
                    String[] branchesOld = userRecord.Branch_Code__c.split(',');
                    Set<String> branchCodeSetLocal = new Set<String>();
                    branchCodeSetLocal.addAll(branchesOld);
                    for(String branchCode : branchCodeSetLocal){
                        if(branchVsUserIdToCreate.containsKey(branchCode)){
                            branchVsUserIdToCreate.get(branchCode).add(userRecord.Id);
                            branchIdsSet.add(branchCode);
                        }else{
                            branchVsUserIdToCreate.put(branchCode,new Set<String>{userRecord.Id});
                            branchIdsSet.add(branchCode);
                        }
                    }
                }else{
                    branchVsUserIdToCreate.put(userRecord.Branch_Code__c,new Set<String>{userRecord.Id}); 
                    branchIdsSet.add(userRecord.Branch_Code__c);
                }
            }else if(userRecord.isActive && userRecord.ProfileId == profileId && String.isNotBlank(userRecord.Title) && titleSet.contains(userRecord.Title)
            && String.isBlank(userRecord.Branch_Code__c) &&  String.isNotBlank(oldRecordMap.get(userRecord.Id).Branch_Code__c)){
                if(oldRecordMap.get(userRecord.Id).Branch_Code__c.contains(',')){
                    String[] branchesOld = oldRecordMap.get(userRecord.Id).Branch_Code__c.split(',');
                    Set<String> branchCodeSetLocal = new Set<String>();
                    branchCodeSetLocal.addAll(branchesOld);
                    for(String branchCode : branchCodeSetLocal){
                        if(branchVsUserIdToDelete.containsKey(branchCode)){
                            branchVsUserIdToDelete.get(branchCode).add(userRecord.Id);
                            branchIdsSet.add(branchCode);
                        }else{
                            branchVsUserIdToDelete.put(branchCode,new Set<String>{userRecord.Id});
                            branchIdsSet.add(branchCode);
                        }
                    }
                }else{
                    branchVsUserIdToDelete.put(oldRecordMap.get(userRecord.Id).Branch_Code__c,new Set<String>{userRecord.Id}); 
                    branchIdsSet.add(oldRecordMap.get(userRecord.Id).Branch_Code__c);
                }
            }else if(!userRecord.isActive && userRecord.isActive != oldRecordMap.get(userRecord.Id).isActive && userRecord.ProfileId == profileId && String.isNotBlank(userRecord.Title) && titleSet.contains(userRecord.Title)
            && String.isNotBlank(userRecord.Branch_Code__c)){
                if(userRecord.Branch_Code__c.contains(',')){
                    String[] branchesOld = userRecord.Branch_Code__c.split(',');
                    Set<String> branchCodeSetLocal = new Set<String>();
                    branchCodeSetLocal.addAll(branchesOld);
                    for(String branchCode : branchCodeSetLocal){
                        if(branchVsUserIdToDelete.containsKey(branchCode)){
                            branchVsUserIdToDelete.get(branchCode).add(userRecord.Id);
                            branchIdsSet.add(branchCode);
                        }else{
                            branchVsUserIdToDelete.put(branchCode,new Set<String>{userRecord.Id});
                            branchIdsSet.add(branchCode);
                        }
                    }
                }else{
                    branchVsUserIdToDelete.put(userRecord.Branch_Code__c,new Set<String>{userRecord.Id}); 
                    branchIdsSet.add(userRecord.Branch_Code__c);
                }
            }
            if(userRecord.isActive && userRecord.ProfileId == profileId && String.isNotBlank(userRecord.Title) && titleSet.contains(userRecord.Title)
            && userRecord.Title != oldRecordMap.get(userRecord.Id).Title){
                userIdVsnewRole.put(userRecord.Id,userRecord.Title);
            }
        }
        if(!userIdVsnewRole.isEmpty()){
            for(AccountTeamMember accTeamRecord : [SELECT Id,TeamMemberRole,UserId from AccountTeamMember WHERE UserId IN:userIdVsnewRole.keySet()]){
                accTeamRecord.TeamMemberRole = userIdVsnewRole.get(accTeamRecord.UserId);
                accMemberToUpdate.add(accTeamRecord);
            }
        }
        if(!accMemberToUpdate.isEmpty()){
            System.enqueueJob(new UserTriggerController(JSON.serialize(accMemberToUpdate),false,false,true));
        }
        if(!branchIdsSet.isEmpty()){
            for(Account accRecord : [SELECT Id,Account_Code__c,Branch_Queue__c FROM Account WHERE Account_Code__c IN:branchIdsSet WITH SECURITY_ENFORCED]){
                accountCodevsId.put(accRecord.Account_Code__c,accRecord.Id);
                accountCodevsQueueId.put(accRecord.Account_Code__c,accRecord.Branch_Queue__c);
            }
        }
        if(!branchVsUserIdToCreate.isEmpty()){
            for(String branchCode : branchVsUserIdToCreate.keySet()){
                for(String userId : branchVsUserIdToCreate.get(branchCode)){
                    AccountTeamMember accMember = new AccountTeamMember();
                    accMember.UserId = userId;
                    accMember.AccountId = accountCodevsId.get(branchCode);
                    accMember.TeamMemberRole=userIdVsRoles.get(userId);
                    accMember.AccountAccessLevel = editAccess;
                    accMemberToInsert.add(accMember);
                }
            }
        }
        if(!branchVsUserIdToDelete.isEmpty()){
            for(AccountTeamMember accTeamRecord : [SELECT Id,TeamMemberRole,UserId,Account.Account_Code__c from AccountTeamMember WHERE Account.Account_Code__c IN: branchVsUserIdToDelete.keySet()]){
                if(branchVsUserIdToDelete.get(accTeamRecord.Account.Account_Code__c).contains(accTeamRecord.UserId)){
                    accMemberToDelete.add(accTeamRecord);
                }
            }
        }
        if(!accMemberToInsert.isEmpty()){
            if(Schema.sObjectType.AccountTeamMember.isCreateable()){
                System.enqueueJob(new UserTriggerController(JSON.serialize(accMemberToInsert),true,false,false));
            }
        }
        if(!accMemberToDelete.isEmpty()){
            System.enqueueJob(new UserTriggerController(JSON.serialize(accMemberToDelete),false,true,false));
        }
    }
}