public without sharing class UserApprovalLWCController {
    public Enum RBM_APPROVAL_TYPES {
        SystemGeneratedDocs,
        LSChargeApproval
    }

    /**
     * @Modified - 4th Aug | SFAU-4471
     * - Added argument rbmApprovalType
     * RBM Tatkal approval extended for LS Charge
     * 
     */
    @AuraEnabled
    public static List<UserApprovalWrapper> getUserRelatedRecords( String loanApplicationId, String rbmApprovalType ){
        try{
            List<UserApprovalWrapper> retWrapperList = new List<UserApprovalWrapper>();
            Map<String, String> DOCUMENTNAME_TO_PDFAPGE = Utility.getPageNameByDocName();
            Loan_Application_Approval__c[] approvalRecords;
            if(rbmApprovalType != null && RBM_APPROVAL_TYPES.LSChargeApproval == RBM_APPROVAL_TYPES.valueOf(rbmApprovalType) ){
                approvalRecords = [
                    SELECT Id, Name, Loan_Application__c, Loan_Application__r.Name, Document_Name__c,
                    Approval_Type__c, Approval_Status__c, Approver__c, Approver_Level__c, Remarks__c
                    FROM Loan_Application_Approval__c
                    WHERE Loan_Application_Stage__c !=: GlobalConstants.REJECTED AND Approval_Type__c = 'RBMTatkal' AND
                    (Approval_Status__c = '' OR Approval_Status__c = 'Pending') AND
                    Approver__c =: Userinfo.getUserId() AND Document_Name__c = NULL AND Archived__c = FALSE
                ];
            } else {
                approvalRecords = [SELECT Id,Name, Loan_Application__c, Loan_Application__r.Name, Document_Name__c, Approval_Type__c, Approval_Status__c, Approver__c, Approver_Level__c, Remarks__c FROM 
                                                                      Loan_Application_Approval__c where (Approval_Type__c = 'Cancellation' OR Approval_Type__c='Sanction Tatkal' OR Approval_Type__c='RBMTatkal') AND (Approval_Status__c = '' OR Approval_Status__c = 'Pending') AND Document_Name__c!=''
                                                                      AND Approver__c=:Userinfo.getUserId()];
            }
            system.debug('reached here '+approvalRecords);
            if(!approvalRecords.isEmpty()){
                for(Loan_Application_Approval__c record : approvalRecords){
                    UserApprovalWrapper wrap  = new UserApprovalWrapper();
                    wrap.recId = record.Id;
                    wrap.loanName =  record.Loan_Application__r.Name;
                    wrap.loanId = record.Loan_Application__c;
                    wrap.loanRecLink = '/'+record.Loan_Application__c;
                    wrap.docName = record.Document_Name__c;
                    wrap.approvalLevel = (String.isNotBlank(record.Approver_Level__c))?record.Approver_Level__c:'';
                    wrap.approvalType = (String.isNotBlank(record.Approval_Type__c))?record.Approval_Type__c:'';
                    wrap.docPDFName = DOCUMENTNAME_TO_PDFAPGE.get(record.Document_Name__c?.toUppercase());//(record.Document_Name__c=='Sanction Letter')?'SanctionPDFPage':(record.Document_Name__c=='Sanction Cancelled letter')?'SanctionCancelledPDFPage':'DOCancelledPDFPage';
                    wrap.isTatkalSanction = (record.Approval_Type__c == 'Sanction Tatkal' || record.Approval_Type__c == 'RBMTatkal' );
                    wrap.remarks = (String.isNotBlank(record.Remarks__c))?record.Remarks__c:'';
                    retWrapperList.add(wrap);
                }
                
            }
            return retWrapperList;
            
        }catch(Exception ex){
            throw new AurahandledException(ex.getMessage());
        }
    }
    
    /**
     * SFAU-4471 - RBM Approval needed is LS is not taken
     */
    @AuraEnabled
    public static SystemGenerateDocumentsController.ApprovalWrapper approveDocumentLetters(String loanApplicationId, String letterType, String remarks, Boolean isTatkalSanction, String approvalType ){
        if(isTatkalSanction){
            // createCustomFeedRecords(loanApplicationId, 'Sanction Letter generated successfully for Loan Application:');
            return SystemGenerateDocumentsController.approveSystemGeneratedDocuments(loanApplicationId, letterType, remarks, approvalType);
        }
        else{
            return SystemGenerateDocumentsController.approveCancellationRecordsAssigned(loanApplicationId, letterType, remarks);
        }
        
    }
    
    @AuraEnabled
    public static void sendBackDocuments(String loanApplicationId, String letterType, String remarks, Boolean isTatkalSanction){
        SystemGenerateDocumentsController.rejectApprovalRecords(loanApplicationId, new List<String>{letterType}, remarks);
        createCustomFeedRecords(loanApplicationId, letterType, 'Sanction Letter rejected for Loan Application:');
        
    }

    @AuraEnabled
    public static void createCustomFeedRecords(String loanId, String letterType, String body){
        List<Loan_Application__c> application = [SELECT Id,OwnerId, Name from Loan_Application__c WHERE Id=:loanId LIMIT 1];
        FeedItem feedRecord = new FeedItem();
        feedRecord.ParentId = application[0].OwnerId;
        feedRecord.Body = (String.isBlank(letterType) ? 'Loan Suraksha Charges has been rejected.' : letterType ) + ' ' + application[0].Name;
        insert feedRecord;

    }
    
    
    
    public class UserApprovalWrapper{
        @AuraENabled public String recId{get;set;}
        @AuraENabled public String docName{get;set;}
        @AuraENabled public String loanId{get;set;}
        @AuraENabled public String loanName{get;set;}
        @AuraENabled public String loanRecLink{get;set;}
        @AuraENabled public String approvalLevel{get;set;}
        @AuraEnabled public String approvalType{get;set;}
        @AuraENabled public String docPDFName{get;set;}
        @AuraENabled public String remarks{get;set;}
        @AuraEnabled public Boolean isTatkalSanction{get;set;}
    }
    
}