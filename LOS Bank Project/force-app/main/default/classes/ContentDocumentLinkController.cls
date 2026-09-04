/**
 * @description       : 
 * @author            : Harshit Goyal | Salesforce
 * @group             : 
 * @last modified on  : 01-13-2023
 * @last modified by  : Harshit Goyal | Salesforce
**/
public without sharing class ContentDocumentLinkController {

    public static void checkActiveVersions(List<ContentDocumentLink> newList, Map<Id,ContentDocumentLink> newMap){
        Set<String> linkedIdSet = new Set<String>();
        Set<String> conLinkIdSet = new Set<String>();
        Set<Id> setMultipleUpload = new Set<Id>();
        List<Document_Checklist__c> lstUpdateDocCheckRecords = new List<Document_Checklist__c>();
        
        List<ContentVersion> conVersionListToUpdate = new List<ContentVersion>();
        for(ContentDocumentLink conLink : newList){
            if(conLink.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Document_Checklist__c'){
                linkedIdSet.add(conLink.LinkedEntityId);
                conLinkIdSet.add(conLink.Id);
            }

        }
        /*
        for(Document_Checklist__c checkListRecord : [SELECT Id FROM  Document_Checklist__c WHERE Id IN:linkedIdSet AND Multiple_Upload__c=TRUE WITH SECURITY_ENFORCED]){
            linkedIdSet.remove(checkListRecord.Id);
        }
        */
        
        List<Document_Checklist__c> lstDocCheck = [SELECT Id, Multiple_Upload__c, Document_Received_Date__c FROM  Document_Checklist__c WHERE Id IN:linkedIdSet WITH SECURITY_ENFORCED];
        for(Document_Checklist__c checkListRecord : lstDocCheck){
            // Add Condition Document Checklist Record Id for Multiple Upload
            if (checkListRecord.Multiple_Upload__c)
                setMultipleUpload.add(checkListRecord.Id);
        }
        if(!linkedIdSet.isEmpty()){
            for(ContentDocumentLink conLink :[SELECT Id,ContentDocument.LatestPublishedVersionId, LinkedEntityId from ContentDocumentLink WHERE LinkedEntityId IN:linkedIdSet AND Id NOT IN:conLinkIdSet AND ContentDocument.LatestPublishedVersion.isActive__c = TRUE WITH SECURITY_ENFORCED]){
                // Logic - Update IsActive = true for content Version
                if (!setMultipleUpload.contains(conLink.LinkedEntityId)) {
                    ContentVersion conRecord = new ContentVersion();
                    conRecord.Id = conLink.ContentDocument.LatestPublishedVersionId; 
                    conRecord.isActive__c = false;
                    conVersionListToUpdate.add(conRecord);
                }
            }
        }
        
        if(!conVersionListToUpdate.isEmpty()){
            if(Schema.sObjectType.ContentVersion.isUpdateable()){
                update conVersionListToUpdate;
            }
        }
        
        // Logic - Update Document Received Date on Document checklist record
        if (lstDocCheck.size()>0){
            for (Document_Checklist__c objCheck : lstDocCheck){
                objCheck.Document_Received_Date__c = System.today();
                lstUpdateDocCheckRecords.add(objCheck);
            }
            update lstUpdateDocCheckRecords;
        }

    }
    
    
    public static void restrictShare(List<ContentDocumentLink> newDocList){
        /* Bypass Share validation for given profile */
        List<String> lstByPassProfileForShare = new List<String>();
        lstByPassProfileForShare = Label.Bypass_Content_Sharing_For_Profile.split(',');
        String strUserId = UserInfo.getUserId();
        User objuser = [Select Id, Profile.Name from User where Id =: strUserId];
        for(ContentDocumentLink cdl: newDocList){
            if (!isSharingAllowed(cdl) && !lstByPassProfileForShare.contains(objuser.Profile.Name))  {
            	cdl.addError('Sorry, you cannot share this file.');
        	}
        }
    }
    
    public static boolean isSharingAllowed(ContentDocumentLink cdl) {
        System.debug('***checking sharing');
        System.debug('***cdl: '+cdl);
        String docId = cdl.ContentDocumentId;
       
        List<contentDocumentLink> cdlList = [Select Id,ContentDocumentId,ContentDocument.Title, LinkedentityId FROM contentDocumentLink where ContentDocumentId =:docId];      
        String sharedDocs = System.Label.Sharing_Doc_List;
        List<String> sharedDocList = sharedDocs.split(',');
        System.debug('***version: '+cdlList);
        if (cdlList.size() <= 1 || sharedDocList.contains(cdlList[0].ContentDocument.Title)) {
            return true;
        }
        return false;
    }
}