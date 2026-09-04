/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 02-13-2023
 * @last modified by  : Harshit Goyal | Salesforce
 * Logs:
 * Last Modified Date       -   Last Modified By        -   Bug/User Story#
 * 31-07-2023               -   Mohit M.                -   SFAU-3985
 * Oct-18-2023              -   Mohit M.                -   SFAU-5419 - Maruti Lead | In case of Physical Journey case is not moving to next page.
 * Dec-20-2023              -   Mohit M.                -   SFAU-5622 - Add User.IsActive check in ATM
 * 25-10-2023               -   Sachin                  -   R2-9
**/
public with sharing class LeadAssignmentController {
    public static String stageStr = 'Lead';
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 02-10-2023 
    * @param recordId 
    * @return String 
    **/
    @AuraEnabled
    public static map<String, Object> getLeadNumber(String recordId){
        Group[] tcuQueues = [ SELECT Id FROM GROUP WHERE Name =: Label.PANIndiaTCUQueueName AND Type = 'Queue' WITH SYSTEM_MODE ];
        Id tcuQueueId = !tcuQueues.isEmpty() ? tcuQueues[0].Id : null;

        return new map<String, Object>{
            'lead' => [SELECT Loan_Number__c,Application_Id__c, Product__c FROM Loan_Application__c WHERE Id =:recordId],
            'tcuQueueId' => tcuQueueId //R2-9

        };
    }
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 02-02-2023 
    * @param loanNumber 
    * @param branchNameNumber 
    **/
    @AuraEnabled
    public static String searchLeadRecord(List<String> leadNumbers, String branchRecordId){
        system.debug('leadNumber'+leadNumbers);
        String accBranchId=branchRecordId;
        Map<String,AccountTeamMember> userIdVsAccTeamMember = new Map<String,AccountTeamMember>();
        Map<String,Integer> userIdVsLoadCount = new Map<String,Integer>();
        List<LoadWrapper> loadWrapList = new  List<LoadWrapper>();
            
        Set<String> titleSet = Utility.splitCustomLabel(System.Label.UserTitleList);
        Set<String> leadIds = new Set<String>();
        for(Loan_Application__c leadRec : [SELECT Id FROM Loan_Application__c WHERE (Application_Id__c IN: leadNumbers OR Id IN:leadNumbers) WITH SECURITY_ENFORCED]){
            leadIds.add(leadRec.Id);
        }
        if(leadIds.isEmpty()){
            ResultWrapper wrap = new ResultWrapper();
            wrap.isSuccess= false;
            wrap.message ='Lead record not found!!';
            return(JSON.serialize(wrap));
        }else{
            ResultWrapper wrap = new ResultWrapper();
            wrap.isSuccess= true;
            List<String> idsList = new List<String>();
            idsList.addAll(leadIds);
            wrap.leadRecordIds =idsList;
            wrap.accBranchId =branchRecordId;
                        //system.debug('titleSet'+titleSet+' '+accBranchId );
            //system.debug('titleSet'+[SELECT Id,UserId,User.Name,Employee_Code__c,AccountId,TeamMemberRole from AccountTeamMember] );
            for(AccountTeamMember accTeamMember : [SELECT Id,UserId,User.Name,Employee_Code__c, TeamMemberRole from AccountTeamMember WHERE AccountId=:accBranchId AND TeamMemberRole IN:titleSet AND User.isActive = true WITH SECURITY_ENFORCED]){
                userIdVsAccTeamMember.put(accTeamMember.UserId,accTeamMember);
            }
            system.debug('test '+userIdVsAccTeamMember);
            AggregateResult[]  recordsList=  [SELECT Count(Id) loadCount,OwnerId FROM Loan_Application__c WHERE Stage__c =: stageStr AND Branch_Master__c =:accBranchId WITH SECURITY_ENFORCED Group By OwnerId];
            for (AggregateResult ar : recordsList) {
                System.debug('Count of record ' + ar.get('OwnerId') + ' is ' + ar.get('loadCount'));
                userIdVsLoadCount.put(String.valueOf(ar.get('OwnerId')),Integer.valueOf(String.valueOf(ar.get('loadCount'))));
            }
            for(String userId : userIdVsAccTeamMember.keySet()){
                LoadWrapper loadWrap = new LoadWrapper();
                AccountTeamMember accTeamMember = userIdVsAccTeamMember.get(userId);
                loadWrap.roName = accTeamMember.User.Name;
                loadWrap.designation = accTeamMember.TeamMemberRole;
                loadWrap.employeeCode = accTeamMember.Employee_Code__c;
                loadWrap.userId = userId;
                if(userIdVsLoadCount.containsKey(userId)){
                    loadWrap.workLoad = userIdVsLoadCount.get(userId);
                }else{
                    loadWrap.workLoad = 0;
                }
                loadWrapList.add(loadWrap);
            }
            wrap.loadWrapper =loadWrapList;
            return(JSON.serialize(wrap));

        }
    }
    Public class ResultWrapper{
        @AuraEnabled
        public Boolean isSuccess{get;set;}
        @AuraEnabled
        public String message{get;set;}
        @AuraEnabled
        public List<String> leadRecordIds{get;set;}
        @AuraEnabled
        public String accBranchId{get;set;}
        @AuraEnabled
        public List<LoadWrapper> loadWrapper{get;set;}
        @AuraEnabled
        public List<Loan_Application__c> leadRecordList{get;set;}
    }
    Public class LoadWrapper{
        @AuraEnabled
        public String roName{get;set;}
        @AuraEnabled
        public String employeeCode{get;set;}
        @AuraEnabled
        public Integer workLoad{get;set;}
        @AuraEnabled
        public String userId{get;set;}
        @AuraEnabled
        public String designation{get;set;}
    }
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 02-02-2023 
    * @param leadRecordId 
    * @param newOwnerId 
    * @return string 
    **/
    @AuraEnabled
    public static string changeLeadOwner(List<String> leadRecordIds, String newOwnerId, String branchRecId){
        List<Loan_Application__c> ownerChangeList = new List<Loan_Application__c>();
        String strResponse = '';
        ResultWrapper result = new ResultWrapper();
        result.isSuccess = false;
        Map<Id,Id> mapRecordWithOwnerId = new Map<Id,Id>();
        try {
            for(String leadId : leadRecordIds){
                Loan_Application__c leadRecord = new Loan_Application__c();
                leadRecord.Id = leadId;
                leadRecord.OwnerId = newOwnerId;
                leadRecord.Branch_Master__c = branchRecId;
                List<Account> lstAccount =  new List<Account>();
                lstAccount = [Select Id, Name from Account where Id =: branchRecId];
                if (lstAccount == NULL || lstAccount.size() == 0)
                    throw new CustomException ('Selected branch not exist in system');
                leadRecord.Branch__c = lstAccount[0].Name;
                ownerChangeList.add(leadRecord);
                mapRecordWithOwnerId.put(Id.valueOf(leadId),Id.valueOf(newOwnerId));
            }
            if(!ownerChangeList.isEmpty() && Schema.sObjectType.Loan_Application__c.isUpdateable()){
                update ownerChangeList;
                /* START - SFAU-5419 */
                Utility.UtilityWrapper objUtilityWrap = Utility.changeDocumentChecklistOwner('Loan_Application__c',mapRecordWithOwnerId); 
                /* END - SFAU-5419 */
            }
            else {
                throw new CustomException ('You do not have permission to assign lead.');
            }
            result.isSuccess = true;
            strResponse = JSON.serialize(result);
        }catch(Exception objException){
            system.debug(LoggingLevel.Error,'Error -- ' + objException);
            Log.error('Error in Lead Assignment LeadAssignmentController at Line Number ' + objException.getLineNumber() + ' ' + objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),'');
            result.message = objException.getMessage();
            strResponse = JSON.serialize(result);
        }
        /* SFAU-3985 - START */
        try {
            if (result.isSuccess && ownerChangeList.size()>0) {
                for (Loan_Application__c objLead : ownerChangeList) {
                    NotificationHandler.sendNotification('Lead assigned to RO',objLead.Id,'');
                }
            }
        }
        catch(Exception ex) {
            System.debug(LoggingLevel.Error,'Error on Lead Assignment Notification ' + ex + ' Line Number ' + ex.getLineNumber());
            Log.error('Error in Lead Assignment Notification LeadAssignmentController at Line Number ' + ex.getLineNumber() + ' ' + ex,Log.SeverityType.valueOf(GlobalConstants.HIGH),'');
        }
        /* SFAU-3985 - END */
        return JSON.serialize(result);
    }
    /**
    * @description 
    * @author Harshit Goyal | Salesforce | 02-13-2023 
    * @param leadRecordIds 
    * @return string 
    **/
    @AuraEnabled
    public static String getLeadDetails(List<String> leadRecordIds){
        try {
            List<Loan_Application__c> loanAppList = [SELECT Id,Sourcing_channel__c,Stage__c,Application_Id__c FROM Loan_Application__c WHERE Id IN:leadRecordIds];
            ResultWrapper result = new ResultWrapper();
            result.isSuccess = true;
            result.leadRecordList = loanAppList;
            return JSON.serialize(result);
        }catch(Exception objException){
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),'');
            ResultWrapper result = new ResultWrapper();
            result.isSuccess = false;
            result.message = objException.getMessage();
            return JSON.serialize(result);
        }
    }

    @AuraEnabled
    public static map<String, Object> assignLeadsToTcu( Loan_Application__c[] leads ){
        Database.SaveResult[] saveResults = Database.update( leads, false );

        Object[] errors = new Object[0];
        for( Database.SaveResult sr: saveResults ){
            if( !sr.isSuccess() ){
                for( Database.Error error: sr.getErrors() ){
                    errors.add(
                        new map<String, Object>{
                            'Id' => sr.getId(),
                            'error' => error.getMessage()
                        }
                    );
                }
            }
        }

        if( !errors.isEmpty() ){
            Log.error( JSON.serialize(errors), Log.SeverityType.valueOf( GlobalConstants.SEVERITYTYPE_HIGH ), null );
        }
        return new map<String, Object>{
            'isSuccess' => errors.isEmpty(),
            'errors' => errors
        };
    }
    public class CustomException extends Exception {}

}