public with sharing class CibilReportPopOverController {
    @AuraEnabled
    public static ContentDocumentWrapper getApplicantCibil(String applcntId) {
        String recordId = '';
        List<Applicant__c> applicantLst = [SELECT Id,AML_Status__c, First_Name__c, Middle_Name__c, Last_Name__c,
                                           (SELECT id, API_Error__c, Integration_Master__r.Name, Is_Response_In_Attachment__c
                                            FROM Integration_Checklists__r
                                            WHERE (Integration_Master__r.Name = 'Cibil Individual')
                                            ORDER BY createddate DESC LIMIT 1),
                                           (SELECT id, Bureau_Score__c
                                            FROM Bureau_Results__r
                                            WHERE (Bureau__c = 'CIBIL')
                                            ORDER BY createddate DESC LIMIT 1)
                                           FROM Applicant__c WHERE Id =:applcntId AND IsInactive__c != true WITH SECURITY_ENFORCED];
        if(applicantLst[0].Bureau_Results__r.size()>0){
            recordId = applicantLst[0].Bureau_Results__r[0].Id;
            // Get record file IDs
            List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId WITH SECURITY_ENFORCED];
            List<ContentVersion> docs = new List<ContentVersion>();
            Set<Id> cdls = new Set<Id>();
            for(ContentDocumentLink cdl : files ){
                cdls.add(cdl.ContentDocumentId);
            }
            if(files.size() > 0) {
                docs = [SELECT Id, ContentDocumentId, FileExtension, Title
                        FROM ContentVersion WHERE ContentDocumentId IN: cdls and title='Cibil' WITH SECURITY_ENFORCED];
            }
            ContentDocumentWrapper obj = new ContentDocumentWrapper();
            obj.contentDocumentId = docs.size() > 0 ? String.valueOf(docs[0].ContentDocumentId) : '';
            obj.contentVersionId = docs.size() > 0 ? String.valueOf(docs[0].Id) : '';
            system.debug('obj--> '+obj);
            return obj;
        }
        return null;
    } 
    
    public class ContentDocumentWrapper {
        @AuraEnabled public String contentDocumentId;
        @AuraEnabled public String contentVersionId;
        public ContentDocumentWrapper(){
            contentDocumentId = '';
            contentVersionId = '';
        }
    }
        
}