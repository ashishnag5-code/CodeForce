public with sharing class DocumentManagerHandler {

    @AuraEnabled
    public static String getDocumentChecklist(String applicantId){

        List<Document_Checklist__c> records = new List<Document_Checklist__c>();
        records = [Select id, Document__c from Document_Checklist__c
        where Applicant__c =: applicantId];
        return JSON.serialize(records);
    }

    @AuraEnabled
    public static List<ResponseListWrapper> getVersionFiles(String recordId){
        try {
            List<ResponseListWrapper> respWrapList = new List<ResponseListWrapper>();
            Set<Id> docChecklistIdsSet = new Set<Id>();
            Map<Id,String> docToMasterNameMap = new Map<Id,String>();
            //List<Applicant__c> applicantIds = [Select id from Applicant__c where id=: recordId];
            //if(!applicantIds.isEmpty()){
            List<Document_Checklist__c> docList = [Select id, Document_Master__r.Document_Name__c from Document_Checklist__c where Applicant__c =:recordId];

            if(!docList.isEmpty()){
                for(Document_Checklist__c doc : docList){
                    docChecklistIdsSet.add(doc.Id);
                    docToMasterNameMap.put(doc.Id, doc.Document_Master__r.Document_Name__c);
                }
            }
            Set<Id> contentDocumentIds = new Set<Id>();
            Map<Id, Id> docIdToChecklistId = new Map<Id, Id>();
            for(ContentDocumentLink each : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :docChecklistIdsSet]) {
                contentDocumentIds.add(each.ContentDocumentId);
                docIdToChecklistId.put(each.ContentDocumentId, each.LinkedEntityId);
            }

            List<ContentVersion> contVerList = [SELECT Id, Title,ContentDocumentId,FileType,FileExtension,FirstPublishLocationId FROM ContentVersion
            WHERE ContentDocumentId IN :contentDocumentIds
            ORDER BY CreatedDate DESC];
            for(ContentVersion cv : contVerList){
                ResponseListWrapper resp = new ResponseListWrapper();
                resp.docName = docToMasterNameMap.get(docIdToChecklistId.get(cv.ContentDocumentId));
                resp.url = '/sfc/servlet.shepherd/document/download/' +cv.ContentDocumentId;
                resp.fileType = cv.FileExtension;
                resp.recordId = docIdToChecklistId.get(cv.ContentDocumentId);//cv.Id;
                respWrapList.add(resp);
            }
            //}
            return respWrapList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ResponseListWrapper{
        @AuraEnabled
        public String docName{get;set;}
        @AuraEnabled
        public String url{get;set;}
        @AuraEnabled
        public String fileType{get;set;}
        @AuraEnabled
        public String recordId{get;set;}
    }
}