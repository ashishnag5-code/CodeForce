public with sharing class LOSApplicantWizardController {
    @AuraEnabled(cacheable=true)
    public static ApplicantWizardResponse getApplicantDocumentChecklist(String applicantId){
        ApplicantWizardResponse objWrapper = new ApplicantWizardResponse();
        objWrapper.isSuccess = false;
        objWrapper.docCheckList = new List<Document_Checklist__c>();
        try{
            objWrapper.docCheckList = [Select Id, Name, Document_Master__r.Document_Name__c  from Document_CheckList__c where Applicant__c =: applicantId];
            objWrapper.isSuccess = true;
        }
        catch(Exception ex){}
        return objWrapper;
    }
    
    public class ApplicantWizardResponse{
        @AuraEnabled
        public List<Document_Checklist__c> docCheckList{get;set;}
        @AuraEnabled
        public Boolean isSuccess {get;set;}
    }
    
    /*
    @AuraEnabled
    public static void doOCRCheck (String contentDocumentId, String documentName, String applicantId) {
        ApplicantWizardResponse objWrapper = new ApplicantWizardResponse();
        try{
            if (documentName == 'Aadhaar Card Copy') {
                ContentVersion objContentVersion = [Select id, VersionData from ContentVersion where ContentDocumentId =: contentDocumentId];
                system.debug(LoggingLevel.Info,'objContentVersion :: ' + objContentVersion);
                String strVersionBase64 = EncodingUtil.base64Encode(objContentVersion.VersionData);
                OCRAdharRespWrapper objAadharResponse = LOSOcrIntegrationController.initiateAdharOCR(applicantId,strVersionBase64,'2');
                system.debug(LoggingLevel.debug,'Response :: ' + objAadharResponse);
            }
            objWrapper.isSuccess = true;
        }
        catch(Exception ex){
            objWrapper.isSuccess = false;
        }
    }
	*/
}