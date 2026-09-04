public class Queueable_EKYC implements Queueable, Database.AllowsCallouts {
	
    public List<Applicant__c> newRecordList;
    public Map<Id,Applicant__c> oldRecordMap;
    public Map<Id,Applicant__c> newRecordMap;
    public List<Applicant__c> newFiltrRecordList;
    
    public Queueable_EKYC(List<Applicant__c> newRecordList, Map<Id,Applicant__c> oldRecordMap, Map<Id,Applicant__c> newRecordMap, List<Applicant__c> newFiltrRecordList) {
        this.newRecordList = newRecordList;
        this.oldRecordMap = oldRecordMap;
        this.newRecordMap = newRecordMap;
        this.newFiltrRecordList = newFiltrRecordList;
    }
        
    public void execute(QueueableContext context) {
        ApplicantTriggerService applcntTriggerSrvcObj = new ApplicantTriggerService();
        applcntTriggerSrvcObj.saveEKYCPdf(newRecordList, oldRecordMap, newRecordMap, newFiltrRecordList);
    }
    
}