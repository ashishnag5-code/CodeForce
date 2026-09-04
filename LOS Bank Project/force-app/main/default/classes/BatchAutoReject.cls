global class BatchAutoReject implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
		Integer days = Integer.valueOf(System.label.AutoRejectDays);
        DateTime thirtyDaysAgo = (!Test.isRunningTest())?DateTime.now().addDays(-days):DateTime.now();
        String query = 'SELECT Id, Stage__c  FROM Loan_Application__c WHERE CreatedDate <= :thirtyDaysAgo AND Stage__c != \'Rejected\'';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Loan_Application__c> loanApplicationsToUpdate = new List<Loan_Application__c>();
        List<Loan_TAT__c> loanTatList = new List<Loan_TAT__c>();
        
        for (sObject s : scope) {
            Loan_Application__c loanApp = (Loan_Application__c)s;
            loanApp.Stage__c = 'Rejected';
            loanApp.isAutoRejected__c = true;
            loanApplicationsToUpdate.add(loanApp);
            
            //Create Loan TAT for that 
             Loan_TAT__c loanTat = new Loan_TAT__c();
             loanTat.Stage_Activity__c = 'Rejected';
             loanTat.Loan_Application__c = loanApp.Id; 
             loanTat.Start_Date_Time__c = System.now();
             loanTat.End_Date_Time__c = System.now();
             loanTat.Action_Type__c='Rejected'; 
             loanTat.Decision_Remarks__c = 'Auto Rejected';
             loanTatList.add(loanTat);
        }
        
        if (!loanApplicationsToUpdate.isEmpty() && loanApplicationsToUpdate.size()>0) {
            System.debug('loanRecords--:>' +loanApplicationsToUpdate.size());
           // update loanApplicationsToUpdate;
           Database.SaveResult[] srList = Database.update(loanApplicationsToUpdate, true);

        }

        if(loanTatList!=null &&  loanTatList.size()>0 && !loanTatList.isEmpty()){
            Database.SaveResult[] tatLst = Database.insert(loanTatList, true);
    }
    
       
        
    }

    global void finish(Database.BatchableContext BC) {

    }
}