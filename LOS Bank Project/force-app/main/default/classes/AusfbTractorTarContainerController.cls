/**
 * @description       : Tractor TAR Form Data service
 * @author            : Ajitesh
 * @group             : 
 * @last modified on  : 12-04-2023
 * @last modified by  : Ajitesh
**/
public with sharing class AusfbTractorTarContainerController {
    /**
    * @description Getting current collateral of the loan
    * @author Ajitesh | 10-31-2023 
    * @param loanId 
    * @return Id 
    **/
    @AuraEnabled
    public static Collateral__c getCollateralRecord(Id loanId){
        try {
            List<Collateral__c> collateralData = [SELECT Id, Loan__r.Stage__c, Loan__r.Product__c, Loan__r.Collateral_Type__c, Vehicle_Delivery__c, MMV_Master__r.Name, Engine_Number__c, Chasis_Number__c, TAR_Tractors_Running_Usage_Hour_Meter_Re__c, TAR_Place_of_Visit__c, TAR_if_Other_please_specify__c, TAR_Delivery_Date__c, TAR_Customer_Equity_Amount_MMR_paid__c, TAR_Sr_No__c, RecordTypeId FROM Collateral__c WHERE Loan__c = :loanId WITH SECURITY_ENFORCED];
            if(collateralData.size() > 0){
                return collateralData[0];
            }
            return null;
        } catch (Exception e) {
            System.debug('Something went wrong fetching collateral record ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Getting document check of collateral to show images upload option and validate
    * @author Ajitesh | 11-02-2023 
    * @param documentIds 
    * @param collateralId 
    * @return List<Document_Checklist__c> 
    **/
    @AuraEnabled
    public static List<Document_Checklist__c> getDocumentCheckListRelatedToTar(
        String[] documentIds,
        Id collateralId
    ){
        try {
            return [SELECT Document_Master__r.Document_Name__c, Document_Master__r.Document_ID__c, Id FROM Document_Checklist__c WHERE Collateral__c = :collateralId AND Document_Master__r.Document_ID__c IN :documentIds WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            System.debug('Something went wrong fetching document checklist record ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Fetching metadata configuration for information about component display
    * @author Ajitesh | 11-02-2023 
    * @return List<Tractor_TAR_Form_Config__mdt> 
    **/
    @AuraEnabled(cacheable=true)
    public static List<Tractor_TAR_Form_Config__mdt> getMetadataConfig(){
        try {
            return [SELECT DeveloperName, MetaData_Value__c, Collateral_Type__c, Form_Field_To_Display__c, Image_Field_To_Display__c FROM Tractor_TAR_Form_Config__mdt WITH SECURITY_ENFORCED];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
    * @description Check if all fields are uploaded or not
    * @author Ajitesh | 11-02-2023 
    * @param documentCheckListData 
    * @return String 
    **/
    @AuraEnabled
    public static String validateDocumentUpload(List<Document_Checklist__c> documentCheckListData ){
        try {
            Set<Id> parentIds = new Set<Id>();
            Set<Id> documentAttachedToTheseCheckList = new Set<Id>();
            String errorMessage = '';

            for(Document_Checklist__c documentCheckListTemp : documentCheckListData) {
                parentIds.add(documentCheckListTemp.Id);
            }

            if (!parentIds.isEmpty()) {
                for(ContentDocumentLink contentDocumentLinkTemp : [
                    SELECT LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :parentIds WITH SECURITY_ENFORCED
                ]){
                    documentAttachedToTheseCheckList.add(contentDocumentLinkTemp.LinkedEntityId);
                }
            }

            for(Id documentAttachedCheckListId : documentAttachedToTheseCheckList){
                if(parentIds.contains(documentAttachedCheckListId)){
                    parentIds.remove(documentAttachedCheckListId);
                }
            }

            for(Document_Checklist__c documentCheckListTemp : documentCheckListData){
                if(parentIds.contains(documentCheckListTemp.Id)){
                    errorMessage += documentCheckListTemp.Document_Master__r.Document_Name__c  + ',';
                }
            }

            return errorMessage;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string createApproval(String recId, String remarks){
        try {
            Loan_Application_Approval__c apprv = New Loan_Application_Approval__c();
            apprv.Loan_Application__c = recId;
            apprv.Remarks__c = remarks;
            apprv.Approval_Status__c = 'Pending';
            apprv.RecordTypeId = Schema.SObjectType.Loan_Application_Approval__c.getRecordTypeInfosByName().get('TAR').getRecordTypeId();
            insert apprv;
            return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<retApprovWrapper> getApprovals(String recId) {
        return getapp(recId);
    }

    @AuraEnabled
    public static List<retApprovWrapper> getApprovalRecs(String recId) {
        return getapp(recId);
    }

    private static List<retApprovWrapper> getapp(String recId){
        id loanAppId;
        boolean recExist = false;
        retApprovWrapper ret = New retApprovWrapper();
        Id subLoanApprovalId;
        Id recTypeId = Schema.SObjectType.Loan_Application_Approval__c.getRecordTypeInfosByName().get('TAR').getRecordTypeId();
        for(Loan_Application_Approval__c app: [SELECT Id, Remarks__c,Approval_Status__c from Loan_Application_Approval__c 
            where Loan_Application__c =: recId and 
            RecordTypeId =: recTypeId order by createddate desc limit 1]){
            recExist = true;
            ret.remarks = app.Remarks__c;
            ret.approvalStatus = app.Approval_Status__c;
            subLoanApprovalId = app.Id;
            if(app.Approval_Status__c == 'Approved'){
                loanAppId = app.Id;
            }
        }
        if(loanAppId<> null){
            for(ProcessInstance pi: [select id,LastActor.Name from ProcessInstance where TargetObjectId =: loanAppId]){
                ret.approvedBY = pi.LastActor.Name;
            }
        }
        
        if(subLoanApprovalId<> null){
            List<String> approverNames = new List<String>();
            for(ProcessInstanceWorkitem piw:[SELECT Id, ProcessInstanceId, OriginalActor.Name, Actor.Name, 
                    ElapsedTimeInDays, ElapsedTimeInHours, ElapsedTimeInMinutes, 
                    IsDeleted, CreatedDate, CreatedById, ActorId
                FROM ProcessInstanceWorkitem 
                WHERE ProcessInstance.targetObjectId =: subLoanApprovalId ]){
                if(piw.ActorId == UserInfo.getUserId() && !ret.isCurrentuserApprover){
                    ret.isCurrentuserApprover = true;
                    ret.loanAppRecId = piw.Id;
                }
                approverNames.add(piw.Actor.Name);
            }
            ret.approverNames = String.join(approverNames, '/');
        }

        List<retApprovWrapper> retList = New List<retApprovWrapper>();
        if(recExist){
            retList.add(ret);
        }
        
        return retList;
    }

    @AuraEnabled
    public static string validateTARSubmitOrApproval(String recId){
        try {

            List<Collateral__c> colList = [Select Loan__c, Id from Collateral__c where Loan__c =:recId and 
                TAR_Status__c <> 'Submitted' ];

            List<Loan_Application_Approval__c> appList = [Select Loan_Application__c, Id from Loan_Application_Approval__c 
                where Loan_Application__c =:recId and Approval_Status__c = 'Approved' and RecordType.Name = 'TAR'];

            Loan_Application__c la = [Select id,Stage__c from Loan_Application__c where id =: recId];

            if(colList.size()==0){
                return 'submitted';
            }
            if(appList.size()> 0){
                return 'approved';
            }
            if(colList.size()>0 && appList.size()==0 && la.Stage__c == 'PSD'){
                return 'throwerror';
            }
        
        return 'error';
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string submitforApprovalOrReject(String comments, String approveOrReject, String subLoanApprovalId){
        try {
            Approval.ProcessWorkitemRequest req2 = 
            new Approval.ProcessWorkitemRequest();
            req2.setComments(comments);
            if(approveOrReject == 'approve'){
                req2.setAction('Approve');
            }else{
                req2.setAction('Reject');
            }
            
            // Use the ID from the newly created item to specify the item to be worked
            req2.setWorkitemId(subLoanApprovalId);
            
            // Submit the request for approval
            Approval.ProcessResult result2 =  Approval.process(req2);

            return 'success';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class retApprovWrapper{
        @AuraEnabled 
        public string remarks;
        @AuraEnabled 
        public string approvalStatus;
        @AuraEnabled 
        public string approvedBY;
        @AuraEnabled 
        public Boolean isCurrentuserApprover = false;
        @AuraEnabled 
        public String loanAppRecId = '';
        @AuraEnabled
        public String approverNames;
    }
}