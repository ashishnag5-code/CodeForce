public with sharing class CibilReportQueueable implements Queueable, Database.AllowsCallouts {
    
    public String applcntId;
    public String applicationId;
    public String bureauResultId;
    
    public CibilReportQueueable(String applcntRecId, String applicationId, String bureauResultId) {
        this.applcntId = applcntRecId; 
        this.applicationId = applicationId;  
        this.bureauResultId = bureauResultId;
    }
    
    public void execute(QueueableContext qc){
        Savepoint sp;
        try{
        CIBILHandler cibObj = new CIBILHandler();
        String reqbody = cibObj.generateCibilReportRequest(applcntId, applicationId);
        system.debug('reqbody -->  ' + reqbody);
        String resBody = cibObj.createCibilRequest(reqbody, applcntId, 'Cibil Individual Report'); 
        system.debug('resBody -->  ' + resBody);
        sp = Database.setSavepoint();

        LosCibilReportResponseWrapper cibilRepResWrpObj = LosCibilReportResponseWrapper.parse(resBody);
        
        
        if(cibilRepResWrpObj.ResponseMessage != null && cibilRepResWrpObj.ResponseMessage == 'Success'){
            
            ContentVersion cv = new ContentVersion();
            system.debug('HTML'+EncodingUtil.base64Decode(cibilRepResWrpObj.FileContent).toString());
            cv.VersionData = EncodingUtil.base64Decode(cibilRepResWrpObj.FileContent);
            cv.Title = 'Cibil';
            cv.PathOnClient = 'Cibil.html';
            insert cv;
            system.debug('cv'+cv.Id);
            
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [
                SELECT ContentDocumentId 
                FROM ContentVersion 
                WHERE Id =: cv.Id
            ].ContentDocumentId;
            cdl.LinkedEntityId = bureauResultId;
            // ShareType is either 'V', 'C', or 'I'
            // V = Viewer, C = Collaborator, I = Inferred
            cdl.ShareType = 'V';
            insert cdl;
            
        }
    }Catch(Exception e){
        Database.RollBack(sp);
        Integration_Checklist__c checklistRecord = [Select Id FROM Integration_Checklist__c WHERE Applicant__c=: applcntId ORDER BY CreatedDate DESC LIMIT 1];
        checklistRecord.Id = checklistRecord.Id;
        checklistRecord.API_Error__c = e.getMessage();
        update checklistRecord;
    }
        
    }
    
}