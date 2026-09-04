public with sharing class DocumentChecklistTriggerService implements ServiceInterface {
    public void beforeInsert(List < sObject > newRecordList) {}

    public void afterInsert(List < sObject > newRecordList, Map < Id, sObject > newRecordMap) {}

    public void beforeUpdate(List < sObject > newRecordList, Map < Id, sObject > oldRecordMap, Map < Id, sObject > newRecordMap) {
    


    }

    public void afterUpdate(List < sObject > newRecordList, Map < Id, sObject > oldRecordMap, Map < Id, sObject > newRecordMap) {
        List < Document_Checklist__c > newList =  (List < Document_Checklist__c >) newRecordList;
        Map < Id, Document_Checklist__c > documentChecklistOldMap = (Map < Id, Document_Checklist__c > ) oldRecordMap;
        compressDocuments(newList, documentChecklistOldMap);
        updateDocVerfication(newList, documentChecklistOldMap);

    }

    public void beforeDelete(Map < Id, sObject > oldRecordMap) {}

    public void afterDelete(Map < Id, sObject > oldRecordMap) {}

    public void afterUndelete(Map < Id, sObject > newRecordList) {}

    //Compress Documents if Needs_Compression__c = true from Bridge App
    public static void compressDocuments(List < Document_Checklist__c > newList, Map < Id, Document_Checklist__c > oldMap) {
        Map < Id, Document_Checklist__c > idVsDocCheckMap = new Map < Id, Document_Checklist__c > ();
        for (Document_Checklist__c rec: newList) {
            if (oldMap.get(rec.Id).Needs_Compression__c != rec.Needs_Compression__c && rec.Needs_Compression__c) {
                idVsDocCheckMap.put(rec.Id, rec);
            }
        }
        if (!idVsDocCheckMap.keySet().isEmpty()) {
            compressDocumentAsync(JSON.serialize(idVsDocCheckMap));

        }
    }
    
   public static void updateDocVerfication(List < Document_Checklist__c > newList, Map < Id, Document_Checklist__c > oldMap){
        
        list<Document_Checklist__c> UpdatedDoclist = new list<Document_Checklist__c>();
        map<id,string> docIdToMasterNameMap = new map<id,String>();       
        list<Document_Checklist__c> docMasterList = [ select id,Document_Master__r.Document_Name__c 
                                                     from Document_Checklist__c where id IN :newList];
        
        for(Document_Checklist__c rec: docMasterList){
            if(!docIdToMasterNameMap.containskey(rec.id)){
                docIdToMasterNameMap.put(rec.id,rec.Document_Master__r.Document_Name__c);
            }    
        }

        for (Document_Checklist__c rec: newList) {
            Document_Checklist__c doc = new Document_Checklist__c(id=rec.id);
            if ((oldMap.get(doc.Id).Document_Number__c   != rec.Document_Number__c && (docIdToMasterNameMap.get(rec.id)!=NULL) && docIdToMasterNameMap.get(rec.id)=='Driving Licence')) {
                doc.Document_Verification_Status__c = 'Not Verified';
                UpdatedDoclist.add(doc);
            }
        }
        if(UpdatedDoclist!=null && !UpdatedDoclist.isEmpty()){
            update UpdatedDoclist;
        }
        
    }

    @future(callout = true)
    public static void compressDocumentAsync(String jsonStr) {
       // Declaration starts
        Map < Id, Document_Checklist__c > idVsDocCheckMap = (Map < Id, Document_Checklist__c > ) JSON.deserialize(jsonStr, Map < Id, Document_Checklist__c > .class);
        Map < Id, Id > docIdToChecklistId = new Map < Id, Id > ();
        Map < Id,ContentVersion > cvToInsert = new Map < Id,ContentVersion > ();
        List<ContentDocument> cdToDelete = new List<ContentDocument>();
        Map<Id,ContentVersion> idToCVMap = new Map<Id,ContentVersion>();
        List<ContentDocumentLink> cdlToInsert = new List<ContentDocumentLink>();
        // Declaration ends
       
        // Initializing Map of ContentDocumentId Vs LinkedEntityId
        List < DocumentCompressReqResWrapper.LOSDocCompressResWrapper > wrapperList = new List < DocumentCompressReqResWrapper.LOSDocCompressResWrapper > ();
        for (ContentDocumentLink each: [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN: idVsDocCheckMap.KeySet() AND ContentDocument.LatestPublishedVersion.isActive__c = TRUE WITH SECURITY_ENFORCED]) {
            docIdToChecklistId.put(each.ContentDocumentId, each.LinkedEntityId);
        }

        // Fetch ContentVersion Records based on ContentDocumentId
        List < ContentVersion > contVerList = [SELECT Id,ContentDocumentId, Title, VersionData FROM ContentVersion
            WHERE ContentDocumentId IN: docIdToChecklistId.keySet() WITH SECURITY_ENFORCED
            ORDER BY CreatedDate DESC
        ];


        // Compress Version data and prepare List<ContentVersion> to insert.
        for (ContentVersion cv: contVerList) {
            cdToDelete.add(new ContentDocument(Id = cv.ContentDocumentId)); 
            String loanId = idVsDocCheckMap.get(docIdToChecklistId.get(cv.ContentDocumentId)).Loan_Application__c;
            String appId = idVsDocCheckMap.get(docIdToChecklistId.get(cv.ContentDocumentId)).Applicant__c;
            DocumentCompressReqResWrapper.LOSDocCompressResWrapper wrapData = DocumentCompressAPI.getCompresssedDocument(EncodingUtil.base64Encode(cv.VersionData), cv.Title, appId,loanId );
            ContentVersion cvNew = new ContentVersion();
            if (wrapData.OutputStatus == System.Label.LOS_DocCompress_Success) {
                cvNew.VersionData = EncodingUtil.base64Decode(wrapData.OutputFileBase64string);
            } else {
                cvNew.VersionData = EncodingUtil.base64Decode(EncodingUtil.base64Encode(cv.VersionData));
            }
            cvNew.Title = cv.Title;
            cvNew.PathOnClient = cv.Title;
            cvToInsert.put(cv.ContentDocumentId,cvNew);
        }
        insert cvToInsert.values();  // insert new Content Versions

        // Prepare Map<ContentVersionId,ContentVersion>
        for(ContentVersion cv : [SELECT Id,ContentDocumentId FroM ContentVersion WHere ID IN: cvToInsert.values()]){
            idToCVMap.put(cv.Id,cv);
        }

        // ContentDocumentLinks to Create
        for(Id docId : cvToInsert.keySet()){
            ContentVersion cv = cvToInsert.get(docId);
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = idToCVMap.get(cv.Id).ContentDocumentId;
            cdl.LinkedEntityId = docIdToChecklistId.get(docId);
            cdlToInsert.add(cdl);
        } 

        insert cdlToInsert;
        delete cdToDelete;
    }


}