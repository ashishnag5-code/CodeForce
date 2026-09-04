public without sharing class AUSF_AssignmentRelatedRecordsCntlr {
    
    @AuraEnabled
    public static List<SObject> getAssignmentRelatedRecords(String loanId, String objectName){
        try{
            system.debug(loanId+' '+objectName);
            if(String.isBlank(loanId)){
                return null;
            }
            system.debug('yash '+objectName);
            String query = 'SELECT Id,Name,';
            if(objectName == 'Sanction_Condition__c'){
                query+='Sanction_Condition__c,Is_Waived__c,Raised_By__r.Name,Remarks__c ,Sanction_Type__c, Status__c FROM Sanction_Condition__c WHERE Loan_Application__c ='+'\'' + loanId + '\'';
            }
            else if(objectName == 'Query__c'){
                query+='Resolution_Comments__c ,Remarks__c ,Sub_Type__c ,Type__c FROM Query__c WHERE Loan_Application__c='+'\'' + loanId + '\'';
            }
            else if(objectName == 'Deviation__c'){
                query+='Deviation_Type__c,Level__c FROM Deviation__c WHERE Loan_Application__c='+'\'' + loanId + '\'';
            }
            List<Sobject> relatedRecords = Database.query(query);
            return relatedRecords;
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage()+' '+ex.getStackTraceString());
        }
    }

    @AuraEnabled
    public static void sendBackSanctionData(List<String> sanctionIds, String loanId, Boolean isComplianceSentBack, String remarks){
        try {
            List<Sanction_Condition__c> conditionsRelatedList = [SELECT Id, Name, Status__c, Raised_By__c , Approver__c, Remark__c, Remarks__c, Sanction_Type__c, Loan_Application__c, Loan_Application__r.OwnerId FROM Sanction_Condition__c
                                                                 WHERE ID IN:sanctionIds AND Loan_Application__c=:loanId
                                                                ];
            for(Sanction_Condition__c condition : conditionsRelatedList){
                condition.Status__c = 'Not Compliant';
                condition.Remark__c = remarks;
                condition.Approver__c = (!isComplianceSentBack)?condition.Raised_By__c:null;//'00571000001sR98AAE';//UserInfo.getUserId();// this needs to be changed	
            }
            //String shareRecordUserId = (isComplianceSentBack)?conditionsRelatedList[0].Loan_Application__r.OwnerId : 
            createShareRecordWithApprover(conditionsRelatedList, isComplianceSentBack, sanctionIds);
            if(isComplianceSentBack){
                Loan_Application__c loanApplication = new Loan_Application__c(Id=loanId,Stage__c='PSD',IsSTCompliance__c=true);
                update loanApplication;
            }
            update conditionsRelatedList;
            
        } catch (Exception e) {
            throw new AuraHandledException('Yash'+e.getMessage()+' '+e.getStackTraceString());
        }
    }
    
    private static void createShareRecordWithApprover(List<Sanction_Condition__c> conditions, Boolean isSendBackToRo, List<String> conditionIds){
        Map<Id, Set<Id>> sanctionExistingApproverIdsMap = new Map<Id, Set<Id>>();
        for(Sanction_Condition__Share condition : [SELECT Id,UserOrGroupId, ParentId FROM Sanction_Condition__Share  WHERE ParentId IN:conditionIds]){
            if(!sanctionExistingApproverIdsMap.containsKey(condition.ParentId)){
                sanctionExistingApproverIdsMap.put(condition.ParentId, new Set<Id>());
            }
            sanctionExistingApproverIdsMap.get(condition.ParentId).add(condition.UserOrGroupId);
        }
        List<Sanction_Condition__Share> shareRecords = new List<Sanction_Condition__share>();
        
        for(Sanction_Condition__c condition : conditions){
            if(sanctionExistingApproverIdsMap.containsKey(condition.Id)){
                Id tobeSharedUserId = (!isSendBackToRo)?condition.Raised_By__c:condition.Loan_Application__r.OwnerId;
                if(!sanctionExistingApproverIdsMap.get(condition.Id).contains(tobeSharedUserId)){
                    Sanction_Condition__Share shareRec = new Sanction_Condition__Share();
                    shareRec.ParentId = condition.Id;
                    shareRec.UserOrGroupId = (!isSendBackToRo)?condition.Raised_By__c:condition.Loan_Application__r.OwnerId;
                    shareRec.AccessLevel = 'Edit';
                    shareRec.RowCause = 'Manual';
                    shareRecords.add(shareRec);

                }

            }
            else{
                Sanction_Condition__Share shareRec = new Sanction_Condition__Share();
                shareRec.ParentId = condition.Id;
                shareRec.UserOrGroupId = (!isSendBackToRo)?condition.Raised_By__c:condition.Loan_Application__r.OwnerId;
                shareRec.AccessLevel = 'Edit';
                shareRec.RowCause = 'Manual';
                shareRecords.add(shareRec);

            }
            
        }
        insert shareRecords;
    }

}