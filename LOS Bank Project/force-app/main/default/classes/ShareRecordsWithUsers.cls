public with sharing class ShareRecordsWithUsers {
    public static Boolean isFirstPass = false;
    public static void shareLoanBasedOnProductAccess(Map<Id, sObject> oldApplicationsMap, Map<Id, sObject> newApplicationsMap, String currentOperation){
        //Added by naga for 101 SOQL issue.
         if(!isFirstPass){
         Map<Id, Loan_Application__c> newApplications = (Map<Id, Loan_Application__c>) newApplicationsMap;
         Map<Id, Loan_Application__c> oldApplications = new Map<Id, Loan_Application__c>();
         List<Id> applicationIds = new List<Id>();
         Map<Id, List<Id>> hubVsLoans = new Map<Id, List<Id>>();
         Map<Id, List<Id>> regionVsLoans = new Map<Id, List<Id>>();
         Map<Id, List<Id>> zoneVsLoans = new Map<Id, List<Id>>();
         Map<Id, List<Id>> nationalVsLoans = new Map<Id, List<Id>>();
         if(currentOperation == 'Update'){
             oldApplications = (Map<Id, Loan_Application__c>) oldApplicationsMap;
             for(Loan_Application__c loan: newApplications.values()){
                 if(loan.Product__c != oldApplications.get(loan.Id).Product__c){
                     applicationIds.add(loan.Id);
                 }
             }
         }else{
             applicationIds.addAll(newApplications.keySet());
         }
         Map<Id, Loan_Application__c> loanApps = new Map<Id, Loan_Application__c>([SELECT Id, Branch_Master__c, Branch_Master__r.Business_HUB__c, Branch_Master__r.Region__c, 
             Branch_Master__r.Zone__c, Branch_Master__r.National__c, Product__c FROM Loan_Application__c 
             WHERE Id in: applicationIds WITH SECURITY_ENFORCED]);
 
         List<Accessible_Products__mdt> accessibleProducts = Accessible_Products__mdt.getAll().values();
         Map<String, Accessible_Products__mdt> accessibleProductLabelVsValue = new Map<String, Accessible_Products__mdt>();
 
         for(Accessible_Products__mdt product: accessibleProducts){
             accessibleProductLabelVsValue.put(product.MasterLabel, product);
         }
 
         for(Loan_Application__c loan: loanApps.values()){
             if(loan.Branch_Master__r.Business_HUB__c!=null){
                 hubVsLoans = getLocationVsLoanMap(hubVsLoans, loan.Branch_Master__r.Business_HUB__c, loan.Id);
             }
             if(loan.Branch_Master__r.Region__c!=null){
                 regionVsLoans = getLocationVsLoanMap(regionVsLoans, loan.Branch_Master__r.Region__c, loan.Id);
             }
             if(loan.Branch_Master__r.Zone__c!=null){
                 zoneVsLoans = getLocationVsLoanMap(zoneVsLoans, loan.Branch_Master__r.Zone__c, loan.Id);
             }
             if(loan.Branch_Master__r.National__c!=null){
                 nationalVsLoans = getLocationVsLoanMap(nationalVsLoans, loan.Branch_Master__r.National__c, loan.Id);
             }   
         }
 
         List<Loan_Application__Share> shareRecords = new List<Loan_Application__Share>();
 
         List<AccountTeamMember> accountTeamMembers = [SELECT Id, AccountId, UserId, User.Product_Accessible__c FROM AccountTeamMember WHERE
                ((AccountId in :hubVsLoans.keySet() AND TeamMemberRole=:GlobalConstants.HUB_HEAD) OR 
                 (AccountId in :regionVsLoans.keySet() AND TeamMemberRole=:GlobalConstants.REGION_HEAD) OR
                 (AccountId in :zoneVsLoans.keySet() AND TeamMemberRole=:GlobalConstants.ZONE_HEAD) OR 
                 (AccountId in :nationalVsLoans.keySet() AND TeamMemberRole=:GlobalConstants.NATIONAL_HEAD)) AND UserId!= :UserInfo.getUserId() WITH SECURITY_ENFORCED];
                
         for(AccountTeamMember teamMember: accountTeamMembers){
             List<Id> loandIdList = new List<Id>();
             if(hubVsLoans.keySet().contains(teamMember.AccountId)){
                 loandIdList = hubVsLoans.get(teamMember.AccountId);
             }
             if(regionVsLoans.keySet().contains(teamMember.AccountId)){
                 loandIdList = regionVsLoans.get(teamMember.AccountId);
             }
             if(zoneVsLoans.keySet().contains(teamMember.AccountId)){
                 loandIdList = zoneVsLoans.get(teamMember.AccountId);
             }
             if(nationalVsLoans.keySet().contains(teamMember.AccountId)){
                 loandIdList = nationalVsLoans.get(teamMember.AccountId);
             }            
             shareRecords = assignShareRecords(loandIdList, shareRecords, teamMember, loanApps, accessibleProductLabelVsValue);            
         }
 
         if(shareRecords!=null && shareRecords.size()>0){
             insert shareRecords;
         }
             isFirstPass=true;
         }
         
     }

    public static Map<Id,List<Id>> getLocationVsLoanMap(Map<Id,List<Id>> locationVsSObject, Id locationId, Id sObjectId){
        if(locationVsSObject.keySet().contains(locationId)){
            locationVsSObject.get(locationId).add(sObjectId);
        }else{
            List<Id> tempIdList = new List<Id>();
            tempIdList.add(sObjectId);
            locationVsSObject.put(locationId, tempIdList);
        }
        return locationVsSObject;
    }

    public static List<Loan_Application__Share> assignShareRecords(List<Id> loanIds, List<Loan_Application__Share> shareRecords, AccountTeamMember teamMember, Map<Id, Loan_Application__c> loanApps, Map<String, Accessible_Products__mdt> accessibleProductRecords){
        for(Id loanId: loanIds){
            if(accessibleProductRecords.keySet().contains(teamMember.User.Product_Accessible__c) && accessibleProductRecords.get(teamMember.User.Product_Accessible__c).Product_Codes__c.contains(loanApps.get(loanId).Product__c)){
                Loan_Application__Share loanShare = new Loan_Application__Share();
                loanShare.ParentId = loanId;
                loanShare.UserOrGroupId = teamMember.UserId;
                loanShare.AccessLevel = 'Edit';
                shareRecords.add(loanShare);
            }
        }
        return shareRecords;
    }

    public static void updateRecordAccessOnChangeOfRole(Map<Id, sObject> oldAcTeamMembersMap, Map<Id, sObject> newAcTeamMembersMap, String currentOperation){

        Map<Id, AccountTeamMember> newAcTeamMembers =  new Map<Id, AccountTeamMember>();
        Map<Id, AccountTeamMember> oldAcTeamMembers = new Map<Id, AccountTeamMember>();
        List<String> roles = new List<String> {System.Label.Hub_Head_CBM, System.Label.Region_Head_RBM, 
                                        System.Label.Zonal_Head_ZBM, System.Label.National_Head_NBM_NPM};
        Map<String, Map<Id, List<Id>>> roleVsAccountVsUsers = new Map<String, Map<Id, List<Id>>>();
        Map<String, Map<Id, List<Id>>> roleVsAccountVsUsersToDelete = new Map<String, Map<Id, List<Id>>>();
        List<Account> brancheMasters = new List<Account>();
        Map<Id,List<Id>> branchVsUsers = new Map<Id,List<Id>>();
        Map<Id,List<Id>> branchVsUsersToDelete = new Map<Id,List<Id>>();
        Map<Id, Account> allAccounts;
        List<Id> currentAccountIds = new List<Id>();
        if(currentOperation == 'Update'){
            newAcTeamMembers = (Map<Id, AccountTeamMember>) newAcTeamMembersMap;
            oldAcTeamMembers = (Map<Id, AccountTeamMember>) oldAcTeamMembersMap;
            for(AccountTeamMember member: newAcTeamMembers.values()){
                currentAccountIds.add(member.AccountId);
            }
            for(AccountTeamMember member: oldAcTeamMembers.values()){
                currentAccountIds.add(member.AccountId);
            }
            allAccounts = new Map<Id,Account>([SELECT Id, RecordType.DeveloperName FROM Account WHERE Id in:currentAccountIds]);
            for(AccountTeamMember member: newAcTeamMembers.values()){
                String oldRole = oldAcTeamMembers.get(member.Id).TeamMemberRole;
                String newRole = member.TeamMemberRole;
                if(newRole != oldRole){
                    if(!roles.contains(oldRole) && roles.contains(newRole)){
                        if(!checkErrorValidation(member, newRole, allAccounts)){
                            roleVsAccountVsUsers = getRolesVsAccVsUsersMap(roleVsAccountVsUsers, newRole, member);
                            roleVsAccountVsUsersToDelete = getRolesVsAccVsUsersMap(roleVsAccountVsUsersToDelete, oldRole, member);
                        }
                    }
                    if(roles.contains(oldRole) && !roles.contains(newRole)){
                        roleVsAccountVsUsersToDelete = getRolesVsAccVsUsersMap(roleVsAccountVsUsersToDelete, newRole, member);
                    }
                    if(roles.contains(oldRole) && roles.contains(newRole)){
                        checkErrorValidation(member, newRole, allAccounts);
                    }
                }
            }
        }

        if(currentOperation == 'Delete'){
            oldAcTeamMembers = (Map<Id, AccountTeamMember>) oldAcTeamMembersMap;
            system.debug('oldAcTeamMembers '+oldAcTeamMembers);
            for(AccountTeamMember member: oldAcTeamMembers.values()){
                roleVsAccountVsUsersToDelete = getRolesVsAccVsUsersMap(roleVsAccountVsUsersToDelete, member.TeamMemberRole, member);
            }
        }

        if(currentOperation == 'Insert'){
            newAcTeamMembers = (Map<Id, AccountTeamMember>) newAcTeamMembersMap;
            for(AccountTeamMember member: newAcTeamMembers.values()){
                currentAccountIds.add(member.AccountId);
            }
            allAccounts = new Map<Id,Account>([SELECT Id, RecordType.DeveloperName FROM Account WHERE Id in:currentAccountIds]);
            for(AccountTeamMember member: newAcTeamMembers.values()){
                if(!checkErrorValidation(member, member.TeamMemberRole, allAccounts)){
                    roleVsAccountVsUsers = getRolesVsAccVsUsersMap(roleVsAccountVsUsers, member.TeamMemberRole, member);
                }            
            }
        }
        system.debug('roleVsAccountVsUsers '+roleVsAccountVsUsers);
        system.debug('roleVsAccountVsUsersToDelete '+roleVsAccountVsUsersToDelete);

        brancheMasters = [SELECT Id, Business_HUB__c, Region__c, Zone__c, National__c
                                 FROM Account WHERE RecordType.DeveloperName='Branch' WITH SECURITY_ENFORCED];
        for(Account branch: brancheMasters){
            branchVsUsers = getBranchVsUsersForRoles(roleVsAccountVsUsers, branchVsUsers, branch);
            branchVsUsersToDelete = getBranchVsUsersForRoles(roleVsAccountVsUsersToDelete, branchVsUsersToDelete, branch);                                         
        }

        ShareRecordsAccessUpateBatch batch = new ShareRecordsAccessUpateBatch(branchVsUsers, branchVsUsersToDelete);
        ID batchprocessid = Database.executeBatch(batch);
    }

    public static Map<String, Map<Id, List<Id>>> getRolesVsAccVsUsersMap(Map<String, Map<Id, List<Id>>> roleVsAccountVsUsers, String newRole,
                        AccountTeamMember member){
        if(roleVsAccountVsUsers.keySet().contains(newRole) && roleVsAccountVsUsers.get(newRole).keySet().contains(member.AccountId)){
            roleVsAccountVsUsers.get(newRole).get(member.AccountId).add(member.UserId);
        }else{
            Map<Id, List<Id>> acVsUserMap = new Map<Id, List<Id>>();
            acVsUserMap = getLocationVsLoanMap(acVsUserMap, member.AccountId, member.UserId);
            roleVsAccountVsUsers.put(newRole, acVsUserMap);
        }
        return roleVsAccountVsUsers;
    }

    public static Map<Id, List<Id>> getBranchVsUsersForRoles(Map<String, Map<Id, List<Id>>> roleVsAccountVsUsers, Map<Id, List<Id>> branchVsUsers, Account branch){
        for(String role: roleVsAccountVsUsers.keySet()){
            branchVsUsers = getBranchVsUsers(roleVsAccountVsUsers, branchVsUsers, role, branch.Business_HUB__c, branch.Id);
            branchVsUsers = getBranchVsUsers(roleVsAccountVsUsers, branchVsUsers, role, branch.Region__c, branch.Id);
            branchVsUsers = getBranchVsUsers(roleVsAccountVsUsers, branchVsUsers, role, branch.Zone__c, branch.Id);
            branchVsUsers = getBranchVsUsers(roleVsAccountVsUsers, branchVsUsers, role, branch.National__c, branch.Id);
        }
        return branchVsUsers;
    }

    public static Map<Id, List<Id>> getBranchVsUsers(Map<String, Map<Id, List<Id>>> roleVsAccountVsUsers, 
                                Map<Id, List<Id>> branchVsUsers, String role, Id locationId, Id branchId){
        if(roleVsAccountVsUsers.keySet().contains(role) && roleVsAccountVsUsers.get(role).keySet().contains(locationId)){
            if(branchVsUsers.keySet().contains(branchId)){
                branchVsUsers.get(branchId).addAll(roleVsAccountVsUsers.get(role).get(locationId));
            }else{
                branchVsUsers.put(branchId, roleVsAccountVsUsers.get(role).get(locationId));
            }    
        }      
        return branchVsUsers;
    }

    public static void updateRecordAccessOnChangeOfUser(Map<Id, sObject> oldUsersMap, Map<Id, sObject> newUsersMap, String currentOperation){

        String batchOperation;
        Map<Id, User> newUsers = (Map<Id, User>) newUsersMap;
        Map<Id, User> oldUsers = new Map<Id, User>();
        List<Account> brancheMasters = new List<Account>();
        Map<Id,List<Id>> branchVsUsers = new Map<Id,List<Id>>();
        Map<Id,List<Id>> branchVsUsersToDelete = new Map<Id,List<Id>>();
        Map<String, Map<Id, List<Id>>> roleVsAccountVsUsers = new Map<String, Map<Id, List<Id>>>();
        Map<String, Map<Id, List<Id>>> roleVsAccountVsUsersToDelete = new Map<String, Map<Id, List<Id>>>();
        
        List<AccountTeamMember> acTeamMembers = [SELECT Id, AccountId, UserId, User.Product_Accessible__c, TeamMemberRole FROM AccountTeamMember WHERE UserId IN: newUsers.keySet()];
        
        if(currentOperation == 'Update'){
            oldUsers = (Map<Id, User>) oldUsersMap;
            for(AccountTeamMember member: acTeamMembers){
                String newAccessibleProducts = member.User.Product_Accessible__c;
                String oldAccessibleProducts =oldUsers.get(member.UserId).Product_Accessible__c;
                if(newAccessibleProducts != oldAccessibleProducts){
                    if(oldAccessibleProducts==null && newAccessibleProducts!=null){
                        roleVsAccountVsUsers = getRolesVsAccVsUsersMap(roleVsAccountVsUsers, member.TeamMemberRole, member);
                    }
                    if(oldAccessibleProducts!=null && newAccessibleProducts==null){
                        roleVsAccountVsUsersToDelete = getRolesVsAccVsUsersMap(roleVsAccountVsUsersToDelete, member.TeamMemberRole, member);
                    }
                    if(oldAccessibleProducts!=null && newAccessibleProducts!=null){
                        roleVsAccountVsUsers = getRolesVsAccVsUsersMap(roleVsAccountVsUsers, member.TeamMemberRole, member);
                        roleVsAccountVsUsersToDelete = getRolesVsAccVsUsersMap(roleVsAccountVsUsersToDelete, member.TeamMemberRole, member);
                    }
                }
            }
        }
        brancheMasters = [SELECT Id, Business_HUB__c, Region__c, Zone__c, National__c
                                 FROM Account WHERE RecordType.DeveloperName='Branch' WITH SECURITY_ENFORCED];
        for(Account branch: brancheMasters){
            branchVsUsers = getBranchVsUsersForRoles(roleVsAccountVsUsers, branchVsUsers, branch);
            branchVsUsersToDelete = getBranchVsUsersForRoles(roleVsAccountVsUsersToDelete, branchVsUsersToDelete, branch);                                         
        }
        ShareRecordsAccessUpateBatch batch = new ShareRecordsAccessUpateBatch(branchVsUsers, branchVsUsersToDelete);
        ID batchprocessid = Database.executeBatch(batch);
    }

    public static Boolean checkErrorValidation(AccountTeamMember member, String newRole, Map<Id, Account> allAccounts){
        Boolean isError=false;
        if(newRole == System.Label.Hub_Head_CBM && allAccounts.keySet().contains(member.AccountId) && allAccounts.get(member.AccountId).RecordType.DeveloperName != 'Hub'){
            member.addError(System.Label.Hub_Head_CBM+' was not found at Hub Level');
            isError=true;
        }else if(newRole == System.Label.Region_Head_RBM && allAccounts.keySet().contains(member.AccountId) && allAccounts.get(member.AccountId).RecordType.DeveloperName != 'Region'){
            member.addError(System.Label.Region_Head_RBM+' was not found at Region Level');
            isError=true;
        }else if(newRole == System.Label.Zonal_Head_ZBM && allAccounts.keySet().contains(member.AccountId) && allAccounts.get(member.AccountId).RecordType.DeveloperName != 'Zone'){
            member.addError(System.Label.Zonal_Head_ZBM+' was not found at Zone Level');
            isError=true;
        }else if(newRole == System.Label.National_Head_NBM_NPM && allAccounts.keySet().contains(member.AccountId) && allAccounts.get(member.AccountId).RecordType.DeveloperName != 'National'){
            member.addError(System.Label.National_Head_NBM_NPM+' was not found at National Level');
            isError=true;
        }
        return isError;
    } 
}