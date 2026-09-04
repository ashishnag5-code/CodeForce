/*******************************************************************************************
* @Name         SystemGenerateDocumentsController
* @Author       Yash Shukla
* @Description   Controller class for Generating the PDF for CHecklist documents and sending the Notification
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer           Date               Description
*-------------------------------------------------------------------------------------------
*  1.0             Yash Shukla        04/02/2023         Initial Creation 
*  2.0             Yash Shukla        04/12/2023         SFAU-5264 

*******************************************************************************************/
public without sharing class SystemGenerateDocumentsController {
    
    public static final String[] TWO_STEP_REJECTION_CASTES = new String[]{ 'SC', 'ST' };
    @AuraEnabled
    public static void systemGenerateDocumentLWCMethod(String letterType, String applicationId) {
        try{
            List<Document_Checklist__c> checkListRecords = getAssociatedCheckList(letterType, applicationId);
            if(!checkListRecords.isEmpty()){
                GenerateDocumentCheckList.systemGeneratedDocumentFiles(checkListRecords[0], applicationId);
            }
        }catch(Exception ex) {
           
        }
    }
    
    @AuraEnabled
    public static void rejectApplication(String reason, String subReason, String otherReason, String applicationId, Boolean isApprovalScreen) {
        
        try{
            system.debug('reject letter '+isApprovalScreen);
            systemGenerateDocumentLWCMethod('Rejection letter', applicationId);
            Loan_Application__c applicationRec = new Loan_Application__c(Id = applicationId);
            applicationRec.Rejection_Reason__c = reason;
            applicationRec.Rejection_Sub_Reason__c = subReason;
            applicationRec.Other_Rejection_Reason__c = otherReason;
            if(Schema.sObjectType.Loan_Application__c.isUpdateable()){
                if(isApprovalScreen){
                    AUSFApproverController.rejectLoanApplication(applicationId, new Loan_Application_Approval__c( Remarks__c = otherReason ));
                    update applicationRec;
                } else {
                    applicationRec.Sub_Stage__c = 'Rejected';
                    applicationRec.Stage__c = 'Credit'; // Sachin - SFAU-3549 - when RO rejects an additional rejection from Credit user will be required
                    
                    map<String,String> mapOfLoanIdVsApplicantCaste = LoanApplicationApprovalTriggerHelper.getMapLoanIdVsApplicantCaste(new Set<String>{ applicationId });
                    if( !mapOfLoanIdVsApplicantCaste.containsKey( applicationId ) || (mapOfLoanIdVsApplicantCaste.containsKey( applicationId ) && !TWO_STEP_REJECTION_CASTES.contains( mapOfLoanIdVsApplicantCaste.get( applicationId ) )) ){
                        applicationRec.Stage__c = 'Rejected';
                        applicationRec.Sub_Stage__c = null;
                    }
                    update applicationRec;
                    
                    // Sachin - SFAU-3974 - Will allow application to be relooked by RO / Credit user if it was not rejected from Credit Stage
                    insert new Loan_Application_Approval__c(
                        Approval_Status__c = GlobalConstants.REJECTED,
                        Loan_Application__c = applicationId,
                        Approver__c = UserInfo.getUserId(),
                        Remarks__c = otherReason,
                        Approval_Type__c = GlobalConstants.APPROVAL_TYPE_CREDIT
                    );
                }
            }
        }catch(Exception ex){
            system.debug('exception '+ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
        
    }
    
    private static List<Document_Checklist__c> getAssociatedCheckList(String letterType, String loanApplicationId) {
        List<Document_Checklist__c> checkLists = new List<Document_Checklist__c>();
        checkLists = [SELECT Id, Loan_Application__c, Document_Master__c, Document_Master__r.Name, Document_Name__c,
                      Document_Master__r.Document_Name__c, Ops_Action__c
                      FROM Document_Checklist__c WHERE Loan_Application__c = :loanApplicationId 
                      AND Document_Master__r.Document_Name__c = :letterType WITH SECURITY_ENFORCED];
        return checkLists;
    }
    
    @AuraEnabled
    public static String generateCancelApprovalRecords(String loanId,String letterType){
        try{
            if(STring.isBlank(loanId)){
                return 'Invalid Loan Id';
            }
            List<Loan_Application__c> applicationrecord = [SELECT Id, DO_Status__c, Sanction_Status__c, Is_DO_Sanction_Regenerate_Required__c FROM Loan_Application__c WHERE ID=:loanId LIMIT 1];// SFAU-5264 
            List<Loan_Application_Approval__c> existingApprovalRecord = [SELECT Id,Approval_Type__c, Document_Name__c, Approval_Status__c FROM Loan_Application_Approval__c
                                                                         WHERE Document_Name__c = :letterType  AND Loan_Application__c =:loanId AND
                                                                         (Approval_Status__c = '' OR Approval_Status__c = 'Pending') AND (Approval_Type__c='Cancellation') AND Archived__c = false];
            if(!existingApprovalRecord.isEmpty()){
                return 'There already exists an Approval Request associated with the Letter';
            }
            Map<String,String> loanId_LetterTypeMap = new Map<String,String>();
            loanId_LetterTypeMap.put(loanId,letterType);
            AUSFCancellationApprovalAssignment.getListOfCancellationApprovals( new String[]{ loanId },loanId_LetterTypeMap );
            Loan_Application__c record = applicationrecord[0];//new Loan_Application__c(Id=loanId);
            if(letterType.containsIgnoreCase('Sanction')){
                record.Sanction_Status__c = 'Cancellation In Progress';
            }
            else {
                record.DO_Status__c = 'Cancellation In Progress';
            }
            record.Is_DO_Sanction_Regenerate_Required__c = (record.DO_Status__c!='Issued' && record.Sanction_Status__c!='Issued')?false:record.Is_DO_Sanction_Regenerate_Required__c;// SGAU-5264
            update record;
            return 'Success in generating Cancellation Approval Request';
        }catch(Exception ex){

            Log.error(ex,Log.SeverityType.valueOf(GlobalConstants.HIGH),loanId);
            throw new AuraHandledException(ex.getMessage());
            //return ex.getMessage();
        }
    }
    
    @AuraEnabled
    public static String generateDOSanctionApprovalRecords(String loanId,String letterType, String remarks, Boolean isRBMTatkal){
        try{
            if(STring.isBlank(loanId)){
                return 'Invalid Loan Id';
            }

            String approvalType = (isRBMTatkal)?'RBMTatkal':'Sanction Tatkal';
            
            List<Loan_Application_Approval__c> existingApprovalRecord = [SELECT Id,Approval_Type__c, Document_Name__c, Approval_Status__c FROM Loan_Application_Approval__c
                                                                         WHERE Document_Name__c = :letterType  AND Loan_Application__c =:loanId AND
                                                                         (Approval_Status__c = '' OR Approval_Status__c = 'Pending') AND (Approval_Type__c=:approvalType) AND Archived__c = false];
            if(!existingApprovalRecord.isEmpty()){
                return 'There already exists an Approval Request associated with the Letter';
            }
            Map<String,String> loanId_LetterTypeMap = new Map<String,String>();
            loanId_LetterTypeMap.put(loanId,letterType);
            AUSFRBMApprovalAssignment.getListOfRBMApprovals( new String[]{ loanId },loanId_LetterTypeMap, remarks, isRBMTatkal);
            Loan_Application__c record = new Loan_Application__c(Id=loanId);
            if(letterType.containsIgnoreCase('Sanction')){
                record.Sanction_Status__c = 'Approval In Progress';
            }
            else {
                record.DO_Status__c = 'Approval In Progress';
            }
            update record;
            return 'Success in generating Approval Request';
        }catch(Exception ex){
            Log.error(ex,Log.SeverityType.valueOf(GlobalConstants.HIGH),loanId);
            system.debug('exception stack '+ex.getStackTraceString());
            return ex.getMessage();
            
        }
    }
    
    @AuraEnabled
    public static List<UserApprovalRecordWrapper> getUserAssociatedApprovals(String loanApplicationId){
        List<UserApprovalRecordWrapper> userApprovalRecords = new List<UserApprovalRecordWrapper>();
        try{
            Set<String> documentNameSet = new Set<String>();
            List<Loan_Application_Approval__c> userApprovalRecord = [SELECT Id,Name, Loan_Application__c, Document_Name__c, Approval_Type__c, Approval_Status__c, Approver__c FROM 
                                                                     Loan_Application_Approval__c where Loan_Application__c=:loanApplicationId
                                                                     AND (Approval_Type__c = 'Cancellation' OR Approval_Type__c='') AND (Approval_Status__c = '' OR Approval_Status__c = 'Pending') AND Document_Name__c!=''
                                                                     AND Approver__c=:Userinfo.getUserId()];
            for(Loan_Application_Approval__c approvalRecord : userApprovalRecord){
                if(!documentNameSet.contains(approvalRecord.Document_Name__c)){
                    UserApprovalRecordWrapper newWrapperRecord = new UserApprovalRecordWrapper();
                    newWrapperRecord.documentName = approvalRecord.Document_Name__c;
                    newWrapperRecord.documentId = approvalRecord.Name;
                    documentNameSet.add(approvalRecord.Document_Name__c);
                    userApprovalRecords.add(newWrapperRecord);
                }
            }
            
        }catch(Exception ex){
            Log.error(ex,Log.SeverityType.valueOf(GlobalConstants.HIGH),'');
        }
        return userApprovalRecords;
    }

    @AuraEnabled
    public static List<UserAssociatedApprovalWrapper> getDocumentApprovalRecords(String loanId){
        Map<String, String> DOCUMENTNAME_TO_PDFAPGE = Utility.getPageNameByDocName();
        List<UserAssociatedApprovalWrapper> userApprovalRecords = new List<UserAssociatedApprovalWrapper>();
        try {
            List<Loan_Application_Approval__c> userApprovalRecord = [SELECT Id,Name, Loan_Application__c, Document_Name__c, Approval_Type__c, Approval_Status__c, Approver__c, Remarks__c FROM 
                                                                     Loan_Application_Approval__c where Loan_Application__c=:loanId
                                                                     AND (Approval_Type__c = 'Cancellation' OR Approval_Type__c='Sanction Tatkal' OR Approval_Type__c='RBMTatkal') AND (Approval_Status__c = '' OR Approval_Status__c = 'Pending') /*AND (Document_Name__c!='' OR Loan_Application__c = 'a2b71000000CrLVAA0')*/
                                                                     AND Approver__c=:Userinfo.getUserId() AND Archived__c = FALSE ];//
            if(!userApprovalRecord.isEmpty()){
                for(Loan_Application_Approval__c approval : userApprovalRecord){
                    UserAssociatedApprovalWrapper approvalRec = new UserAssociatedApprovalWrapper();
                    approvalRec.recId = approval.Id;
                    approvalRec.loanId = approval.Loan_Application__c;
                    approvalRec.documentName = approval.Document_Name__c;
                    approvalRec.recordApprovalType = approval.Approval_Type__c;
                    approvalRec.pdfPageName = DOCUMENTNAME_TO_PDFAPGE.get(approval.Document_Name__c?.toUppercase());//(approval.Document_Name__c=='Sanction Letter')?'SanctionPDFPage':(approval.Document_Name__c=='Sanction Cancelled letter')?'SanctionCancelledPDFPage':'DOCancelledPDFPage';
                    approvalRec.isTatkalSanction = (approval.Approval_Type__c == 'Sanction Tatkal' || approval.Approval_Type__c == 'RBMTatkal');
                    approvalRec.remarks = (String.isNotBlank(approval.Remarks__c))?approval.Remarks__c:'';
                    userApprovalRecords.add(approvalRec);

                }
            }
                                                                     
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return userApprovalRecords;
    }

    public class UserAssociatedApprovalWrapper{
        @AuraENabled public String recId{get;set;}
        @AuraENabled public String loanId{get;set;}
        @AuraENabled public String documentName{get;set;}
        @AuraENabled public String recordApprovalType{get;set;}
        @AuraENabled public String pdfPageName{get;set;}
        @AuraENabled public String remarks{get;set;}
        @AuraEnabled public Boolean isTatkalSanction{get;set;}
    }
    
    @AuraEnabled
    public static ApprovalWrapper approveCancellationRecordsAssigned(String loanApplicationId, String letterType, String remarks){
        ApprovalWrapper returnWrapper;
        try{
            if(String.isBlank(loanApplicationId)){
                returnWrapper = new ApprovalWrapper(true,'Please provide a valid loan application Id');
                return returnWrapper;
            }
            String currentUserId = UserInfo.getUserId();
            List<Loan_Application_Approval__c> userApprovalRecord = [SELECT Id,Name, Loan_Application__c, Document_Name__c, Approval_Type__c, Approval_Status__c, Approver__c, Remarks__c FROM 
                                                                     Loan_Application_Approval__c where Loan_Application__c=:loanApplicationId
                                                                     AND Approval_Type__c = 'Cancellation' AND (Approval_Status__c = '' OR Approval_Status__c='Pending')
                                                                     AND Approver__c=:currentUserId AND Document_Name__c=:letterType LIMIT 1];// Document Name check
            if(!userApprovalRecord.isEmpty()){
                userApprovalRecord[0].Approval_Status__c = 'Approved';
                userApprovalRecord[0].Remarks__c = remarks;
                //
                List<Loan_Application_Approval__c> getAllRelatedApprovalRecords = [SELECT Id, Name, Approval_Type__c, Approval_Status__c FROM Loan_Application_Approval__c 
                                                                                   WHERE Loan_Application__c=:loanApplicationId AND Approval_Type__c = 'Cancellation' 
                                                                                   AND (Approval_Status__c = '' OR Approval_Status__c = 'Pending') AND Document_Name__c=:letterType AND ID!=:userApprovalRecord[0].Id AND Archived__c = false];
                system.debug('related approval records'+getAllRelatedApprovalRecords);
                if(getAllRelatedApprovalRecords.isEmpty()){
                    systemGenerateDocumentLWCMethod(letterType,loanApplicationId);
                    returnWrapper = new ApprovalWrapper(false,'Cancel letter document generated successfully ');
                }
                else{
                    returnWrapper = new ApprovalWrapper(false,'Request approved Successfully');
                }
                update userApprovalRecord;
                
                
            }
            else{
                returnWrapper = new ApprovalWrapper(false,'No Pending Approval Record associated with the User');
            }
            
        }catch(Exception ex){
            system.debug('yash '+ex.getStackTraceString());
            Log.error(ex,Log.SeverityType.valueOf(GlobalConstants.HIGH),loanApplicationId);
            returnWrapper = new ApprovalWrapper(true,ex.getMessage());
        }
        return returnWrapper;
    }
    
    
    @AuraEnabled
    public static ApprovalWrapper approveSystemGeneratedDocuments(String loanApplicationId, String letterType, String remarks, String approvalType){
        ApprovalWrapper returnWrapper;
        try{
            if(String.isBlank(loanApplicationId)){
                returnWrapper = new ApprovalWrapper(true,'Please provide a valid loan application Id');
                return returnWrapper;
            }
            String currentUserId = UserInfo.getUserId();
            Loan_Application_Approval__c[] userApprovalRecord;

            // SFAU-4471 - RBM Approval needed is LS is not taken
            if( approvalType != null && UserApprovalLWCController.RBM_APPROVAL_TYPES.LSChargeApproval == UserApprovalLWCController.RBM_APPROVAL_TYPES.valueOf( approvalType ) ){
                userApprovalRecord = [
                    SELECT Id,Name, Loan_Application__c, Document_Name__c, Approval_Type__c, Approval_Status__c, Approver__c, Remarks__c
                    FROM  Loan_Application_Approval__c WHERE Loan_Application__c =: loanApplicationId
                    AND Approval_Type__c = 'RBMTatkal' AND (Approval_Status__c = '' OR Approval_Status__c = 'Pending')
                    AND Approver__c =: currentUserId AND Archived__c = FALSE LIMIT 1
                ];

                Set<Id> apporvalRecordIds = new map<Id, Loan_Application_Approval__c>( userApprovalRecord ).keySet();
                List<ProcessInstanceWorkitem> workItems = [
                    SELECT Id, ProcessInstanceId 
                    FROM ProcessInstanceWorkitem 
                    WHERE ProcessInstance.TargetObjectId =: apporvalRecordIds
                ];

                // Approve records which are in approval process
                if( !workItems.isEmpty() ){
                    AUSFApproverController.approve( new List<Id>( apporvalRecordIds ), 'Approve', new Loan_Application_Approval__c( Remarks__c = remarks ) );
                } else {
                    AUSFApproverController.approveAction( userApprovalRecord, new Loan_Application_Approval__c( Remarks__c = remarks ), new List<Id>( apporvalRecordIds ) );
                }
                return new ApprovalWrapper( false, Label.LSChargeRBMApprovalSuccess );
            } else {
                userApprovalRecord = [SELECT Id,Name, Loan_Application__c, Document_Name__c, Approval_Type__c, Approval_Status__c, Approver__c, Remarks__c FROM 
                                                                         Loan_Application_Approval__c where Loan_Application__c=:loanApplicationId
                                                                         AND (Approval_Type__c = 'Sanction Tatkal' OR Approval_Type__c = 'RBMTatkal') AND (Approval_Status__c = '' OR Approval_Status__c = 'Pending')
                                                                         AND Approver__c=:currentUserId AND Document_Name__c=:letterType LIMIT 1];// Document Name check

            }
            if(!userApprovalRecord.isEmpty()){
                userApprovalRecord[0].Approval_Status__c = 'Approved';
                userApprovalRecord[0].Remarks__c = remarks;
                //futureCallGenerateDocumentLWCMethod(letterType,loanApplicationId);
                systemGenerateDocumentLWCMethod(letterType,loanApplicationId);
                returnWrapper = new ApprovalWrapper(false,letterType+' generated successfully');
                update userApprovalRecord;
            }
            else{
                returnWrapper = new ApprovalWrapper(false,'No Pending Approval Record associated with the User');
            }
            
        }catch(Exception ex){
            Log.error(ex,Log.SeverityType.valueOf(GlobalConstants.HIGH),loanApplicationId);
            system.debug('exception stack trace '+ex.getStackTraceString());
            returnWrapper = new ApprovalWrapper(true,ex.getMessage());
        }
        return returnWrapper;
    }
    
    /*@future(callout=true)
    public static void futureCallGenerateDocumentLWCMethod(String letterType, String applicationId)
    {   
         systemGenerateDocumentLWCMethod(letterType,applicationId);
    }*/
    
    @AuraEnabled
    public static void rejectApprovalRecords(String loanId, List<String> letterTypes, String remarks){
        try {
            
            system.debug('letters'+letterTypes);
            List<Loan_Application_Approval__c> approvalRecords = [SELECT Id,Name, Loan_Application__c, Document_Name__c, Approval_Type__c, Approval_Status__c, Approver__c, Remarks__c FROM 
                                                                  Loan_Application_Approval__c where Loan_Application__c=:loanId
                                                                  AND (Approval_Type__c = 'Sanction Tatkal' OR Approval_Type__c = 'Cancellation' OR Approval_Type__c = 'RBMTatkal') AND Approval_Status__c!='Rejected'
                                                                  AND Document_Name__c IN:letterTypes];
            for(Loan_Application_Approval__c approval : approvalRecords){
                if(approval.Approval_Status__c != 'Approved'){
                    approval.Approval_Status__c = 'Rejected';
                    approval.Remarks__c = remarks;
                }
            }
            
            update approvalRecords;
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updatePaymentFavouringApprovals(String loanId, String status, String remarks){
        try {
            system.debug('%%% '+remarks);
            List<Loan_Application_Approval__c> lstApprovalRecords = new List<Loan_Application_Approval__c>();
            List<Loan_Application_Approval__c> approvalRecords = [SELECT Id,Name, Loan_Application__c, Document_Name__c, Approval_Type__c, Approval_Status__c, Approver__c, Remarks__c FROM 
                                                                  Loan_Application_Approval__c where Loan_Application__c=:loanId
                                                                  AND Approval_Type__c = 'OEMApproval' AND Approval_Status__c='Pending'
                                                                  AND Archived__c = false];
            for(Loan_Application_Approval__c approval : approvalRecords){
                approval.Approval_Status__c = status;
                approval.Remarks__c = remarks;
                lstApprovalRecords.add(approval);
            }
            system.debug('%%% '+lstApprovalRecords);
            update lstApprovalRecords;
            createCustomFeedRecords(loanId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void createCustomFeedRecords(String loanId){
        List<Loan_Application__c> application = [SELECT Id,OwnerId, Name from Loan_Application__c WHERE Id=:loanId LIMIT 1];
        FeedItem feedRecord = new FeedItem();
        feedRecord.ParentId = application[0].OwnerId;
        feedRecord.Body = 'Payment Favouring Approval is rejected for Loan Application ' + application[0].Name;
        insert feedRecord;

    }
    
    public class ApprovalWrapper{
        @AuraEnabled
        public Boolean isError{get;set;}
        @AuraEnabled
        public String message{get;set;}
        public ApprovalWrapper(){
            this.isError = false;
            this.message = '';
        }
        public ApprovalWrapper(Boolean isError, String message){
            this.isError = isError;
            this.message = message;
        }
    }
    
    
    public class UserApprovalRecordWrapper{
        @AuraEnabled public String documentName{get;set;}
        @AuraEnabled public String documentId{get;set;}
        public UserApprovalRecordWrapper(){
            this.documentName = documentName;
            this.documentId = documentId;
        }
    }

    
    
}