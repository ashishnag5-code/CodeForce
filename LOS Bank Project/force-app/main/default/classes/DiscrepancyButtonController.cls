public without sharing class DiscrepancyButtonController {
    
    public static List<Assignment__c> getAssignment(String loanApplAssignId) {
        List<Assignment__c> loanAppList = [SELECT id, Loan_Application__c FROM Assignment__c where id =:loanApplAssignId];
        return loanAppList;
    }

    public static List<Assignment__c> getAssignment2(String loanApplId) {
        List<Assignment__c> loanAppList = [SELECT id, ownerId FROM Assignment__c where Loan_Application__c  =:loanApplId AND recordType.Name = 'Ops - Disbursement'];
        return loanAppList;
    }

    public class NotificatioWrapper{
        public String ownerId{get;set;}
        public String remarks{get;set;}
    }

    @AuraEnabled
    public static DiscrepancyButtonControllerWrapper updateLoanApplicationRec(String recordId, String remarks, String opsStatus) {

        DiscrepancyButtonControllerWrapper obj = new DiscrepancyButtonControllerWrapper();
        Loan_Application__c loanAppRec = new Loan_Application__c();
        String loanApplId = '';
        NotificatioWrapper wrapData = new NotificatioWrapper();

        Id recId = Id.valueOf(recordId);
        String objectName = recId.getSObjectType().getDescribe().getName();
        User u = [SELECT Id,Profile.Name FROM User Where Id =: UserInfo.getUserId()];
        Assignment__c assignmentRec;
        if(objectName == 'Assignment__c') {
            loanApplId = getAssignment(recordId).size() > 0 ? getAssignment(recordId)[0].Loan_Application__c : '';
            wrapData.ownerId ='';
            wrapData.remarks = remarks;
            NotificationHandler.sendNotification('Marks Discrepancy', loanApplId, JSON.serialize(wrapData));
            //NotificationHandler.sendNotification('Marks Discrepancy', loanApplId, '', remarks);   // sending notification to RO
        }
        else if(objectName == 'Loan_Application__c') {
            loanApplId = recordId;
            if(u.Profile.Name == 'Credit Manager'){
                Loan_Application__c loanApp = [SELECT Id,OwnerId FROM Loan_Application__c Where Id =: loanApplId];
                wrapData.ownerId = loanApp.ownerId;
            }else{
                 assignmentRec = getAssignment2(loanApplId)[0];
                 wrapData.ownerId = assignmentRec.ownerId;
            }
            wrapData.remarks = remarks;
            NotificationHandler.sendNotification('Resolve Discrepancy', loanApplId, JSON.serialize(wrapData));  // sending notification to Ops Maker
        }
        if(u.Profile.Name == 'Credit Manager' && String.isNotBlank(opsStatus)){
            loanAppRec.Ops_Status__c = 'Credit ' + opsStatus;
        }else{
            loanAppRec.Ops_Status__c = opsStatus;
        }
        loanAppRec.Id = loanApplId;
        // SFAU-4293 - RO remarks not showing for OPS | 07/09/23
        if(u.Profile.Name == 'Operations'){
            loanAppRec.Remarks__c = remarks;
        } else if(u.Profile.Name == 'Sales'){
            loanAppRec.RO_Discrepancy_Remarks__c = remarks;
        }

        if(loanAppRec != null) {
            update loanAppRec;
            obj.message = 'success';
            return obj;
        }
        obj.message = 'Not Success';
        return obj;
    }

    @AuraEnabled    
    public static List<Loan_TAT__c> getAllLoanTatRecords() {
        List<Loan_TAT__c> loanTatRecList = [SELECT id, Remarks__c, Start_Date_Time__c, End_Date_Time__c FROM Loan_TAT__c];
        return loanTatRecList;
    }

    public class DiscrepancyButtonControllerWrapper {
        @AuraEnabled public String message;
    }
}