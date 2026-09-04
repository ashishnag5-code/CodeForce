/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 01-17-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public with sharing class ContentDownloadHandlerFactoryImpl implements Sfc.ContentDownloadHandlerFactory {
    public Sfc.ContentDownloadHandler getContentDownloadHandler( List<ID> listIds, Sfc.ContentDownloadContext context ) {
        Sfc.ContentDownloadHandler contentDownloadHandler = new Sfc.ContentDownloadHandler();
        if(context != Sfc.ContentDownloadContext.REST_API && context != Sfc.ContentDownloadContext.SOQL && context != Sfc.ContentDownloadContext.RETRIEVE){
            Set<String> linkedIdSet = new Set<String>();
            Set<String> docIdSet = new Set<String>();
            Map<String,String> versionVslink = new Map<String,String>();

            Profile objProfile = [ SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId() WITH SECURITY_ENFORCED LIMIT 1];

            // R2-2856 - START
            if (System.Label.FullDownloadBlockedProfiles.contains(objProfile.Name)) {
                contentDownloadHandler.isDownloadAllowed = false;
                contentDownloadHandler.downloadErrorMessage = 'You do not have permission to download this file.';
                return contentDownloadHandler;
            }
            // R2-2856 - END

            // Get the list of the content versions.
            List<ContentVersion> cvList= [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Id IN :listIds WITH SECURITY_ENFORCED];
            for(ContentVersion versionRecord : cvList){
                docIdSet.add(versionRecord.ContentDocumentId);
            }
            for(ContentDocumentLink cdLink : [SELECT Id,LinkedEntityId,ContentDocument.LatestPublishedVersionId FROM ContentDocumentLink WHERE ContentDocumentId IN:docIdSet WITH SECURITY_ENFORCED]){
                if(cdLink.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Document_Checklist__c'){
                    linkedIdSet.add(cdLink.LinkedEntityId);
                    versionVslink.put(cdLink.ContentDocument.LatestPublishedVersionId,cdLink.LinkedEntityId);
                }
                /*if(cdLink.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Valuation__c'){
                    linkedIdSet.add(cdLink.LinkedEntityId);
                    versionVslink.put(cdLink.ContentDocument.LatestPublishedVersionId,cdLink.LinkedEntityId);
                }*/
            }
            for(Document_Checklist__c checkListRecord : [SELECT Id,Document_Master__r.Is_Download_Allowed__c,Document_Master__r.Download_Profiles__c FROM  Document_Checklist__c WHERE Id IN:linkedIdSet WITH SECURITY_ENFORCED]){
                if(checkListRecord.Document_Master__r.Is_Download_Allowed__c || 
                ( String.isNotBlank(checkListRecord.Document_Master__r.Download_Profiles__c) && checkListRecord.Document_Master__r.Download_Profiles__c.contains(objProfile.Name))){
                    linkedIdSet.remove(checkListRecord.Id); 
                }
            }
            for (ContentVersion cv : cvList) {
                if(!versionVslink.isEmpty() && versionVslink.containsKey(cv.Id)){
                    String docChkId = versionVslink.get(cv.Id);
                    if(linkedIdSet.contains(docChkId)){
                        contentDownloadHandler.isDownloadAllowed = false;
                        contentDownloadHandler.downloadErrorMessage = 'You do not have permission to download this file.';
                        return contentDownloadHandler;
                    }
                }
            }
        }
        contentDownloadHandler.isDownloadAllowed = true;
        return contentDownloadHandler; 
    }
}