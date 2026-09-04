global class BatchRejectionLetterGeneration implements Database.Batchable <sObject>, Database.Stateful ,Database.AllowsCallouts{
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
		Integer days = Integer.valueOf(System.label.AutoRejectDays);
        DateTime thirtyDaysAgo = (!Test.isRunningTest())?DateTime.now().addDays(-days):DateTime.now();
        String query = 'SELECT Id, Stage__c  FROM Loan_Application__c WHERE CreatedDate < :thirtyDaysAgo AND Stage__c != \'Rejected\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Loan_Application__c> loanApplicationsToUpdate = new List<Loan_Application__c>();
        Set<Id> loanIds = new Set<id>();
      //  List<GenerateDocumentQueueable> queueableJobs = new List<GenerateDocumentQueueable>();
        for (sObject s : scope) {
            Loan_Application__c loanApp = (Loan_Application__c)s;
            // Calling Queueable class
            //System.enqueueJob(new GenerateDocumentQueueable('Rejection letter', loanApp.Id));
            // Create Queueable jobs for each loan ID
            //queueableJobs.add(new GenerateDocumentQueueable('Rejection letter', loanApp.Id));
            SystemGenerateDocumentsController.systemGenerateDocumentLWCMethod('Rejection letter', loanApp.Id);
        }
       
       //System.enqueueJob(queueableJobs);
    }
    
    global void finish(Database.BatchableContext BC) {
        BatchAutoReject batchReject = new BatchAutoReject();
        Database.executeBatch(batchReject,5);
    } 
    
}