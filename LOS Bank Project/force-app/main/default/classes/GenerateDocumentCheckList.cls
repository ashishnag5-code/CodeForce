/*******************************************************************************************
* @Name         NotificationHandler
* @Author       Yash Shukla
* @Description   Controller class for Generating the PDF for CHecklist documents and sending the Notification
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer           Date               Description
*-------------------------------------------------------------------------------------------
*  1.0             Yash Shukla        04/02/2023         Initial Creation
*  2.0             Yash Shukla        16/10/2023         Code Refactor and Platform event approach added for Loan Application Update

*******************************************************************************************/
public without sharing class GenerateDocumentCheckList {

    private static final Map<String, String> DOCUMENTNAME_TO_FIELDNAME = new Map<String, String>{
        'SANCTION LETTER' => 'Sanction_Status__c',
        'DELIVERY ORDER' => 'DO_Status__c',
        'SANCTION CANCELLED LETTER' => 'Sanction_Status__c',
        'DO CANCELLED LETTER' => 'DO_Status__c',
        'DO LETTER' => 'DO_Status__c'
   };

   private static final Map<String, String> LETTERHEAD_NOTIFICATIONMASTERMAP = new Map<String, String>{
       'SANCTION LETTER' => 'ON loan sanction',
       'DELIVERY ORDER' => 'DO generation',
    //'SANCTION CANCELLED LETTER' => 'Sanction_Status__c',
       'DO CANCELLED LETTER' => 'DO Cancellation',
       'REJECTION LETTER' => 'Case Rejection',
       'DO LETTER' => 'DO generation'
   };


    public static void systemGeneratedDocumentFiles(Document_Checklist__c checkList, String loanApplicationId) {
        try{
            Map<String, String> DOCUMENTNAME_TO_PDFAPGE = Utility.getPageNameByDocName();
            if(checkList != null) {
                Document_Checklist__c checkListRecord = checkList;
                if(checkListRecord!=null) {
                    system.debug(checkListRecord.Document_Master__r.Document_Name__c.toUppercase());
                    String pageType = DOCUMENTNAME_TO_PDFAPGE.get(checkListRecord.Document_Master__r.Document_Name__c.toUppercase());
                    PageReference savepage ;
                    savepage = new PageReference('/apex/'+pageType);

                    if(pageType=='LoanChargesDeductionLetterPDFPage' || pageType == 'ApplicationFormPDFPage'|| pageType == 'DisbursementVoucherPDFPage'){
                        savepage.getParameters().put('id',loanApplicationId);
                    }else{
                        savepage.getParameters().put('applicationId',loanApplicationId);
                    }
                    String base64Content = '';
                    if(Test.isRunningTest()){
                        base64Content = EncodingUtil.Base64Encode(blob.valueOf('Unit.Test'));
                    }
                    else{
                        base64Content = EncodingUtil.Base64Encode(
                            savepage.getContentAsPDF());

                    }
                    
                    uploadFile(base64Content, checkListRecord.Document_Master__r.Document_Name__c, checkListRecord.Id, '', loanApplicationId);
                    updateCheckListRecord(checkListRecord);
                    if(true) {//res.isSuccess
                        /*
                        updateLoanApplication(loanApplicationId, checkListRecord.Document_Master__r.Document_Name__c.toUppercase());
                        if(String.isBlank(checkListRecord.Ops_Action__c) || checkListRecord.Ops_Action__c != 'Ok'){
                            checkListRecord.Ops_Action__c = 'Ok';
                            update checkListRecord;
                        }
                        */
                    }
                }
            }
        }catch (Exception ex) {
            Log.error(ex,Log.SeverityType.valueOf(GlobalConstants.HIGH),loanApplicationId);
        }
    }


    private static void sendNotifcation(String loanApplicationId, String letterType) {
        if(LETTERHEAD_NOTIFICATIONMASTERMAP.containsKey(letterType) && letterType!='REJECTION LETTER') {
            NotificationHandler.sendNotification(LETTERHEAD_NOTIFICATIONMASTERMAP.get(letterType),loanApplicationId,'');
        }

    }

    private static void uploadFile(String base64, String filename, String recordId,String applicantId,String loanId) {
        PdfSaveWrapper returnWrapper= new PdfSaveWrapper();
        try {
            DocumentCompressReqResWrapper.LOSDocCompressResWrapper wrapData= new DocumentCompressReqResWrapper.LOSDocCompressResWrapper();
            wrapData = (!Test.isRunningTest())?DocumentCompressAPI.getCompresssedDocument(base64,filename,applicantId,loanId): setMockResponse();
            ContentVersion cv = new ContentVersion();
            if(wrapData.OutputStatus == System.Label.LOS_DocCompress_Success){
                cv.VersionData = EncodingUtil.base64Decode(wrapData.OutputFileBase64string);
            }else{
                cv.VersionData = EncodingUtil.base64Decode(base64);
            }
            cv.Title = filename;
            cv.PathOnClient = filename+'.pdf';
            if(Schema.sObjectType.ContentVersion.isCreateable()){
                insert cv;
            }
            if (cv.Id == null || recordId == null) { //return null;
            }
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id WITH SECURITY_ENFORCED].ContentDocumentId;
            cdl.LinkedEntityId = recordId;
            //cdl.ShareType = 'V';
            if(Schema.sObjectType.ContentDocumentLink.isCreateable()){
                insert cdl;
            }
            createAndPublishSystemDocEvent(filename.toUppercase(), loanId);// Method created for Aynchronouslyupdating the Loan Records.
            sendNotifcation(loanId, filename.toUppercase());
            returnWrapper.versionId = cv.Id;

            
        }catch(DMLException objException) {
            returnWrapper.isSuccess = false;
            if(String.isNotBlank(loanId)){
                Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),loanId);
            }else{
                Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),applicantId);
            }

            //return returnWrapper;
        }
    }

    public class PdfSaveWrapper {
        public String versionId{get;set;}
        public Boolean isSuccess{get;set;}
        public PdfSaveWrapper() {
            versionId = '';
            isSuccess = true;
        }
    }

    public static void createAndPublishSystemDocEvent(String letterName, String loanId){
        try{
            if(String.isNotBlank(letterName) && String.isNotBlank(loanId)){
                if(letterName.startsWith('DO') || letterName.startsWith('SANCTION') || letterName.startsWith('DELIVERY')){
                    System_Generated_Document_Event__e eventRecord = new System_Generated_Document_Event__e();
                    eventRecord.Letter_Type__c = letterName;
                    eventRecord.Loan_Application_Id__c = loanId;
                    EventBus.publish(eventRecord);

                }
            }
        }catch(Exception ex){
            Log.error(ex,Log.SeverityType.valueOf(GlobalConstants.HIGH),loanId);
        }
    }
    
    private static void updateCheckListRecord(Document_Checklist__c checkListRecord){
        if(checkListRecord!=null){
            system.debug('checkListRecord::'+checkListRecord.Ops_Action__c);
            if(String.isBlank(checkListRecord.Ops_Action__c) || checkListRecord.Ops_Action__c != 'Ok'){
                checkListRecord.Ops_Action__c = 'Ok';
                update checkListRecord;
            }
        }
    }
    
    private static DocumentCompressReqResWrapper.LOSDocCompressResWrapper setMockResponse(){
        DocumentCompressReqResWrapper.LOSDocCompressResWrapper resp = new DocumentCompressReqResWrapper.LOSDocCompressResWrapper();
        resp.OutputFileBase64string = 'Test Response';
        resp.OutputStatus = 'File Successfully Compressed';
        resp.checklistRecord = new Integration_Checklist__c();
        resp.statusCode = 00;
        return resp;

    }
}