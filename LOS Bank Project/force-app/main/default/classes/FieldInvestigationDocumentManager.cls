public with sharing class FieldInvestigationDocumentManager {
    
    @AuraEnabled
    public static List<ResponseListWrapper> getVersionFiles(String recordId,String objectApiName){
        try {
            List<ResponseListWrapper> respWrapList = new List<ResponseListWrapper>();
            Set<Id> docChecklistIdsSet = new Set<Id>();
            Map<Id,String> docToMasterNameMap = new Map<Id,String>();
            List<Document_Checklist__c> docList;
            if(objectApiName == 'Field_investigation__c'){
                docList = [Select id, Document_Master__r.Document_Name__c from Document_Checklist__c where Field_investigation__c =:recordId WITH SECURITY_ENFORCED];
            }
            
            
            if(!docList.isEmpty()){
                for(Document_Checklist__c doc : docList){
                    docChecklistIdsSet.add(doc.Id);
                    docToMasterNameMap.put(doc.Id, doc.Document_Master__r.Document_Name__c);
                }
            }
            
            
            
            
            if(!docChecklistIdsSet.isEmpty()) {
                Set<Id> contentDocumentIds = new Set<Id>();
                Map<Id, Id> docIdToChecklistId = new Map<Id, Id>();
                for(ContentDocumentLink each : [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :docChecklistIdsSet WITH SECURITY_ENFORCED]) {
                    system.debug('ContentDocumentLink>>>'+each);
                    contentDocumentIds.add(each.ContentDocumentId);
                    docIdToChecklistId.put(each.ContentDocumentId, each.LinkedEntityId);
                }
                
                
                List<ContentVersion> contVerList = [SELECT Id,isActive__c ,Title,ContentDocumentId,ContentDocument.Title,FileType,FileExtension,FirstPublishLocationId FROM ContentVersion
                                                    WHERE ContentDocumentId IN :contentDocumentIds WITH SECURITY_ENFORCED
                                                    ORDER BY CreatedDate DESC ];
                
                for(ContentVersion cv : contVerList){
                    system.debug('ContentVersion>>>'+cv);
                    ResponseListWrapper resp = new ResponseListWrapper();
                    resp.fileName = cv.Title;
                    resp.docName = docToMasterNameMap.get(docIdToChecklistId.get(cv.ContentDocumentId));
                    //resp.url = '/sfc/servlet.shepherd/document/download/' +cv.ContentDocumentId;
                    resp.downloadurl= '/sfc/servlet.shepherd/document/download/' +cv.ContentDocumentId;
                    resp.url = '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId='+cv.Id;
                    resp.fileType = cv.FileExtension;
                    resp.recordId = docIdToChecklistId.get(cv.ContentDocumentId);//cv.Id;
                    resp.contentDocId = cv.ContentDocumentId;
                    resp.contentVerId = cv.Id;
                    resp.contentDocTitle=cv.ContentDocument.Title;
                    respWrapList.add(resp);
                    
                }
                
            }
            
            
            //}
            return respWrapList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    @AuraEnabled
    public static String deactivateDocument(Id recordId){
        try{
            contentdocument cdRecord= new contentdocument();
            cdRecord.Id=recordId;
            if(Schema.sObjectType.contentdocument.isDeletable()){
                delete cdRecord ;
            }
            ResultWrapper result = new ResultWrapper();
            result.isSuccess = true;
            result.message = '';
            return JSON.serialize(result);
        }catch(Exception objException){
            Log.error(objException,Log.SeverityType.valueOf(GlobalConstants.HIGH),'');
            ResultWrapper result = new ResultWrapper();
            result.isSuccess = false;
            result.message = objException.getMessage();
            return JSON.serialize(result);
        }
    }
    Public class ResultWrapper{
        @AuraEnabled
        public Boolean isSuccess{get;set;}
        @AuraEnabled
        public String message{get;set;}
    }
    public class ResponseListWrapper{
        @AuraEnabled
        public String fileName{get;set;}
        @AuraEnabled
        public String docName{get;set;}
        @AuraEnabled
        public String url{get;set;}
        @AuraEnabled
        public String downloadurl{get;set;}
        @AuraEnabled
        public String fileType{get;set;}
        @AuraEnabled
        public String recordId{get;set;}
        @AuraEnabled
        public String contentDocId{get;set;}
        @AuraEnabled
        public String contentVerId{get;set;}
        @AuraEnabled
        public String contentDocTitle{get;set;}
    }
}