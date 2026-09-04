public class ContentVersionHandler {
    public static void linkToDocumentCheckList(List<ContentVersion> conList){
        Set<String> externalIdSet = new Set<String>();
        Map<String,String> externalIdVsDocChk = new Map<String,String>();
        List<ContentDocumentLink> conLinkList = new List<ContentDocumentLink>();
        for(ContentVersion versionRecord :conList){
            externalIdSet.add(versionRecord.Checklist_ID__c );
        }
        if(!externalIdSet.isEmpty()){
            for(Document_Checklist__c  docCheckRecord :[SELECT Id,Checklist_ID__c from Document_Checklist__c  WHERE Checklist_ID__c IN:externalIdSet]){
                externalIdVsDocChk.put(docCheckRecord.Checklist_ID__c,docCheckRecord.Id);
            }
        }
        if(!externalIdVsDocChk.isEmpty()){
            for(ContentVersion versionRecord :conList){
                ContentDocumentLink conLinkRec = new ContentDocumentLink();
                conLinkRec.ContentDocumentId  = versionRecord.ContentDocumentId;
                conLinkRec.LinkedEntityId = externalIdVsDocChk.get(versionRecord.Checklist_ID__c);
                conLinkList.add(conLinkRec);
            }
        }
        if(!conLinkList.isEmpty()){
            insert conLinkList;
        }
    }
}