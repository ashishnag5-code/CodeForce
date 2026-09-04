/*******************************************************************************************
* @Name         SanctionTriggerHelper
* @Author       Yash Shukla
* @Description   Helper class for Sanction Trigger.
*******************************************************************************************/
/* MODIFICATION LOG
* Version           Developer           Date                Description
*-------------------------------------------------------------------------------------------
*  1.0              Yash Shukla         08/07/2023          Initial Creation
*  2.0              Mohit M.            Dec-19-2023         SFAU-5663 - For STP cases credit ST condition should be mandatary before credit approval.              
*******************************************************************************************/
public class SanctionTriggerHelper {

    public static void handleInsertBefore(List<Sanction_Condition__c> newSanctionsList){
        //shareRecordsWithROUser(newSanctionsList);
        if(isAccessRestricted(newSanctionsList[0])){
            newSanctionsList[0].addError('Access Restricted: You do have access to create/modify Sanction Conditions');
        }//4733
        handleCompletedByUserName(newSanctionsList);
        handleRemarkTextAreaAddition(newSanctionsList);
    }

    public static void handleInsertAfter(Map<Id,Sanction_Condition__c> oldSanctionRecords, Map<Id, Sanction_Condition__c> newSanctionRecords){
        shareRecordsWithROUser(newSanctionRecords.keySet());
    }

    public static void handleUpdate(Map<Id,Sanction_Condition__c> oldRecMap , Map<Id,Sanction_Condition__c> newRecMap){
        List<Sanction_Condition__c> compliantUpdatedSanctionList = new List<Sanction_Condition__c>();
        List<Sanction_Condition__c> nonCompliantUpdatedSanctionList = new List<Sanction_Condition__c>();
        List<Sanction_Condition__c> remarkSanctionList = new List<Sanction_Condition__c>();
        if(isAccessRestricted(newRecMap.values()[0])){
            newRecMap.values()[0].addError('Access Restricted: You do have access to create/modify Sanction Conditions');
        }//4733
        for(Id recId : newRecMap.keySet()){
            if(oldRecMap.get(recId).Status__c!='Compliant' && newRecMap.get(recId).Status__c=='Compliant'){
                compliantUpdatedSanctionList.add(newRecMap.get(recId));
            }
            if(oldRecMap.get(recId).Status__c=='Compliant' && newRecMap.get(recId).Status__c!='Compliant'){
                nonCompliantUpdatedSanctionList.add(newRecMap.get(recId));
            }
            if(oldRecMap.get(recId).Remark__c != newRecMap.get(recId).Remark__c){
                remarkSanctionList.add(newRecMap.get(recId));
            }
        }
        if(!compliantUpdatedSanctionList.isEmpty()){
            handleCompletedByUserName(compliantUpdatedSanctionList);
        }
        if(!nonCompliantUpdatedSanctionList.isEmpty()){
            handleNonCompliantCompletedByUserName(nonCompliantUpdatedSanctionList);
        }
        if(!remarkSanctionList.isEmpty()){
            handleRemarkTextAreaAddition(remarkSanctionList);
        }
        updateApproverOnSanctions(oldRecMap, newRecMap);
    }

    public static void handleUpdateAfter(Map<Id,Sanction_Condition__c> oldRecMap , Map<Id,Sanction_Condition__c> newRecMap){
        Set<Id> loanIds = new Set<Id>();
        for(Id recId : oldRecMap.keySet()){
            loanIds.add(newRecMap.get(recId).Loan_Application__c);
        }
    }

    public static void updateApproverOnSanctions(Map<Id,Sanction_Condition__c> oldRecMap , Map<Id,Sanction_Condition__c> newRecMap){

        for(Id recId : oldRecMap.keySet()){
            if(oldRecMap.get(recId).Status__c == 'Not Compliant' && newRecMap.get(recId).Status__c == 'Compliant'){
                newRecMap.get(recId).Approver__c = null;
            }
        }
    }

    private static void handleCompletedByUserName(List<Sanction_Condition__c> sanctions){
        for(Sanction_Condition__c sanction : sanctions){
            if(sanction.Status__c == 'Compliant'){
                sanction.Completed_By__c = UserInfo.getUserId();
            }
        }
    }

    private static void handleNonCompliantCompletedByUserName(List<Sanction_Condition__c> sanctions){
        for(Sanction_Condition__c sanction : sanctions){
            if(sanction.Status__c != 'Compliant'){
                sanction.Completed_By__c = null;
            }
        }
    }

    private static void handleRemarkTextAreaAddition(List<Sanction_Condition__c> sanctions){
        List<User> userRecords = new List<User>();
        userRecords = [SELECT Id, Name FROM USER where ID=:UserInfo.getUserId() LIMIT 1];
        DateTime currentDateTime = System.now();

        String prefixString =  userRecords[0].Name+' '+String.valueOf(currentDateTime.date())+'--> ';
        for(Sanction_Condition__c sanction : sanctions){
            if(String.isNotBlank(sanction.Remark__c)){
                if(String.isNotBlank(sanction.Remarks__c)){
                    sanction.Remarks__c+='\n'+prefixString+sanction.Remark__c+'\n';
                }
                else{
                    sanction.Remarks__c = prefixString+sanction.Remark__c+'\n';
                }

                sanction.Remark__c = '';
            }
        }
    }

    private static void shareRecordsWithROUser(Set<Id> sanctionIds){
        Map<Id, Set<Id>> sanctionExistingApproverIdsMap = new Map<Id, Set<Id>>();
        List<Sanction_Condition__c> sanctions = [SELECT Id, Loan_Application__c, Loan_Application__r.OwnerId, Raised_By__c, Sanction_Type__c  FROM Sanction_Condition__c WHERE ID IN:sanctionIds];
        List<Sanction_Condition__Share> shareRecords = new List<Sanction_Condition__Share>();
        Map<Id, List<Id>> mapSanctioned = new Map<Id,List<Id>>();
        Id userId = UserInfo.getUserId();
        userId = Id.valueOf(userId+'');
        for(Sanction_Condition__c condition : sanctions){
            if (condition.Raised_By__c != condition.Loan_Application__r.OwnerId) {
                Sanction_Condition__Share shareRec = shareSanctionRecords (condition.Id, condition.Loan_Application__r.OwnerId);
                shareRecords.add(shareRec);
            }
            // SFAU-5663
            if (condition.Sanction_Type__c == 'Credit') {
                if (!mapSanctioned.containsKey(condition.Loan_Application__c)) {
                    mapSanctioned.put(condition.Loan_Application__c,new List<Id>());
                }
                List<Id> lstIds = mapSanctioned.get(condition.Loan_Application__c);
                lstIds.add(condition.Id);
                mapSanctioned.put(condition.Loan_Application__c,lstIds);
            }
        }
        if (mapSanctioned != NULL && mapSanctioned.size()>0) {
            for (Loan_Application_Approval__c objApproval : [Select Id, Approval_Type__c, Approval_Status__c, Approver__c, Loan_Application__c from Loan_Application_Approval__c where Loan_Application__c in: mapSanctioned.keySet() AND Approval_Status__c NOT IN ('Approved','Rejected', 'Forwarded') AND Archived__c = false AND Approver__c != NULL]) {
                for (Id objId : mapSanctioned.get(objApproval.Loan_Application__c)) {
                    Sanction_Condition__Share shareRec = shareSanctionRecords (objId, objApproval.Approver__c);
                    shareRecords.add(shareRec);
                }
            }
        }
        if(!shareRecords.isEmpty()){
            database.insert(shareRecords,false);
        }
    }

    //4733
    public static Boolean isAccessRestricted(Sanction_Condition__c sanctionCondition){
        return ComponentProfileRestrictionController.restricAccess('sanctionCondition',sanctionCondition.Loan_Application__c);
    }
    
    // Added as part of SFAU-5663
    public static Sanction_Condition__Share shareSanctionRecords (Id parentId, Id idShareWith) {
        Sanction_Condition__Share shareRec = new Sanction_Condition__Share();
        shareRec.ParentId = parentId;
        shareRec.UserOrGroupId = idShareWith;
        shareRec.AccessLevel = 'Edit';
        shareRec.RowCause = 'Manual';
        return shareRec;
    }



}