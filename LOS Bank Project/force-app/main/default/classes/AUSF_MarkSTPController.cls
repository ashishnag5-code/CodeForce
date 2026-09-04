public without sharing class AUSF_MarkSTPController {
    @AuraEnabled
    public static Boolean checkIfValidLoggedInUser(String applicationId){
        List<String> VALID_ROLES = System.Label.AUSF_STPValidRoles.split(',');//new List<String>{'Branch Manager','Credit Manager'};
        
            Boolean resp = false;
        try{
            if(String.isBlank(applicationId)){
                resp = false;
                return resp;
            }
            List<Loan_Application__c> applicationRecord = [SELECT Id, Branch_Master__c, RecordType.Name, BRE_Decision__c  FROM Loan_Application__c WHERE Id=:applicationId LIMIT 1];
            if(String.isBlank(applicationRecord[0].Branch_Master__c) || applicationRecord[0].BRE_Decision__c !='STP'){
                resp = false;
                
            }
            else{
                List<AccountTeamMember> loggedInUserValidMember = [SELECT Id,TeamMemberRole, UserId, User.Authority_Level__c, User.Profile.Name  FROM AccountTeamMember WHERE 
                                                                   AccountId=:applicationRecord[0].Branch_Master__c AND UserId=:UserInfo.getUserId()
                                                       			   AND TeamMemberRole IN:VALID_ROLES];
                List<User> currentUserRecord = [SELECT Id, Authority_Level__c, Profile.Name FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
                
                if(!loggedInUserValidMember.isEMpty()){
                    for(AccountTeamMember act : loggedInUserValidMember){
                        if(String.isNotBlank(act.User.Authority_Level__c) && act.User.Profile.Name == 'Credit Manager' && applicationRecord[0].RecordType.Name=='Two Wheeler'){
                            resp = true;
                            break;
                        }
                        else if(act.User.Profile.Name == 'Credit Manager' && applicationRecord[0].RecordType.Name=='Four Wheeler'){
                            resp = true;
                            break;
                        }
                        else if(act.User.Profile.Name != 'Credit Manager'){
                            resp = true;
                            break;
                        }
                    }
                    
                }
                else if(String.isNotBlank(currentUserRecord[0].Authority_Level__c) && currentUserRecord[0].Profile.Name == 'Credit Manager' && applicationRecord[0].RecordType.Name=='Two Wheeler'){
                    resp = true;
                }
                
                /*if(applicationRecord[0].RecordType.Name=='Four Wheeler'){
                    List<AccountTeamMember> actList = [SELECT Id,TeamMemberRole, UserId  FROM AccountTeamMember WHERE AccountId=:applicationRecord[0].Branch_Master__c
                                                       AND TeamMemberRole IN:VALID_ROLES];
                    if(!actList.isEmpty()){
                        for(AccountTeamMember act : actList){
                            if(act.UserId == UserInfo.getUserId()){
                                resp = true;
                                break;
                            }
                        }
                    }
                } else if(applicationRecord[0].RecordType.Name=='Two Wheeler'){
                    List<User> loggedInUserRecord = [SELECT Id,Authority_Level__c FROM User WHERE Id=:UserInfo.getUserId() AND Authority_Level__c!='' LIMIT 1];
                    resp = loggedInUserRecord.size()>0;
                }*/
                
                
            }
            
            
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        return resp;
    }
    
    @AuraEnabled
    public static String markSTPOk_NotOk(String applicationId, String response, STring remarks){
        String resp = 'Success';
        try{
            if(String.isBlank(applicationId)){
                resp = 'Please provide a valid Loan Application Id';
            }
            List<Loan_Application__c> applicationRecord = [SELECT Id, Branch_Master__c, BM_STP_Action__c, BCM_STP_Action__c, RecordType.Name, BM_Remarks__c, BCM_Remarks__c
                                                           FROM Loan_Application__c WHERE Id=:applicationId LIMIT 1];
            List<AccountTeamMember> act = [SELECT Id, UserId, User.FirstName, TeamMemberRole, AccountId FROM AccountTeamMember WHERE UserId = :UserInfo.getUserId() AND 
                                           AccountId=:applicationRecord[0].Branch_Master__c LIMIT 1];
            //system.debug('Act list '+act[0].User.FirstName+' '+act[0].TeamMemberRole);
            if(!act.isEmpty()){
                if(act[0].TeamMemberRole == 'Branch Manager'){
                    applicationRecord[0].BM_STP_Action__c = response;
                    applicationRecord[0].BM_Remarks__c = remarks;
                }
                else if(act[0].TeamMemberRole == 'Credit Manager'){
                    applicationRecord[0].BCM_STP_Action__c = response;
                    applicationRecord[0].BCM_Remarks__c = remarks;
                }
                
            }
            else if(applicationRecord[0].RecordType.Name=='Two Wheeler'){
                applicationRecord[0].BCM_STP_Action__c = response;
                applicationRecord[0].BCM_Remarks__c = remarks;
            }
            update applicationRecord;
            resp = 'Success';
            /*else if(applicationRecord[0].RecordType.Name == 'Two Wheeler'){
                applicationRecord[0].BCM_STP_Action__c = response;
		        applicationRecord[0].BCM_Remarks__c = remarks;
                update applicationRecord;
                resp = 'Success';
            }*/
            
        }catch(Exception ex){
            
            resp = 'Not Success';
            throw new AurahandledException(ex.getMessage());
        }
        return resp;
    }
    
}