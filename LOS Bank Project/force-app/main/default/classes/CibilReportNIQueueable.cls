public with sharing class CibilReportNIQueueable implements Queueable, Database.AllowsCallouts {
    public String applcntId;
    public String applicationId;
    public String bureauResultId;
    
    public CibilReportNIQueueable(String applcntRecId, String applicationId, String bureauResultId) {
        this.applcntId = applcntRecId; 
        this.applicationId = applicationId;  
        this.bureauResultId = bureauResultId;
    }

    public String generateCibilReportRequest(String applicantRecId, String applicationId){
        String requestBody;
        System.debug('applicantRecId'+applicantRecId);
        System.debug('applicationId'+applicationId);
        String RequestId = IntegrationUtility.getReferenceId();
        LosCibilRequestWrapper.cls_Cibil_report reqObj = new LosCibilRequestWrapper.cls_Cibil_report();
        reqObj.RequestId = RequestId.left(2) + RequestId.right(RequestId.length()-4);
        reqObj.OriginatingChannel = Label.CIBILHandler_Channel ;
        reqObj.ApplicationId= applicationId;
        requestBody = Json.serialize(reqObj);
        system.debug('requestBody'+requestBody);
        return requestBody;
    }
    public String createCibilRequest(String requestBody, String applcntId, String integrationMasterName) {
        system.debug('requestBody'+requestBody);
        Integration_Master__c objIntMapper =IntegrationUtility.getIntegrationMasterRecord(integrationMasterName);
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = applcntId);
        String respBody;
        IntegrationUtility.RequestWrapper calloutRequestWrapper = new IntegrationUtility.RequestWrapper();
        calloutRequestWrapper.request = requestBody;
        calloutRequestWrapper.contentType = 'application/json';
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
        calloutRequestWrapper.masterRecord = objIntMapper;
        calloutRequestWrapper.checklistRecord = checklistRecord;
        IntegrationUtility.ResponseWrapper calloutResponseWrapper = IntegrationUtility.doRestCallout(calloutRequestWrapper);
        respBody = calloutResponseWrapper.response;
        system.debug('respBody-- ' +respBody);
        return respBody;
    }
    
    public void execute(QueueableContext qc){
        Savepoint sp;
        try{
            String reqbody = generateCibilReportRequest(applcntId, applicationId);
            String resBody = createCibilRequest(reqbody, applcntId, 'Cibil Non Individual Report'); 
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
        //Database.RollBack(sp);
        Integration_Checklist__c checklistRecord = [Select Id FROM Integration_Checklist__c WHERE Applicant__c=: applcntId ORDER BY CreatedDate DESC LIMIT 1];
        checklistRecord.Id = checklistRecord.Id;
        checklistRecord.API_Error__c = e.getMessage();
        update checklistRecord;
    }
        
    }
    
}