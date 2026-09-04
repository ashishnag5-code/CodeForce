public with sharing class CibilQueueable implements Queueable, Database.AllowsCallouts {
    @testVisible
    private static Boolean doChainJob = true;
    public String applcntId;
    
    public CibilQueueable(String applcntRecId) {
        this.applcntId = applcntRecId;      
    }
    
    public void execute(QueueableContext qc){
        
        CIBILHandler cibObj = new CIBILHandler(); 
        String reqbody = cibObj.generateCibilRequest(applcntId);
        system.debug('reqbody -->  ' + reqbody);
        String resBody = cibObj.createCibilRequest(reqbody, applcntId, 'Cibil Individual'); 
        system.debug('resBody -->  ' + resBody);
        Savepoint sp = Database.setSavepoint();
        try{
            String bureauResultId = cibObj.updateCibilScore(applcntId, resBody); 
            LosCibilResponseWrapper cibilResWrpObj = LosCibilResponseWrapper.parse(resBody);
            if(String.isNotBlank(cibilResWrpObj.DCResponse.ResponseInfo.ApplicationId)){
                if(doChainJob) { 
                    System.enqueueJob(new CibilReportQueueable(applcntId, cibilResWrpObj.DCResponse.ResponseInfo.ApplicationId, bureauResultId));
                }
            }
       }
        catch(Exception ex){
            Database.RollBack(sp);
            Integration_Checklist__c checklistRecord = [Select Id FROM Integration_Checklist__c WHERE Applicant__c=: applcntId ORDER BY CreatedDate DESC LIMIT 1];
            checklistRecord.Id = checklistRecord.Id;
            checklistRecord.API_Error__c = 'Getting error in parsing CIBIL Response JSON';
            update checklistRecord;
        }

    }
    
}