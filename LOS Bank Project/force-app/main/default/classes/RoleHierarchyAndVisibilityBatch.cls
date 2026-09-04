public with sharing class RoleHierarchyAndVisibilityBatch implements Database.Batchable<sObject> {

    public List<Id> loanApplicationIds{get;set;}
    public List<Loan_Application__c> loanApplications{get;set;}

    public RoleHierarchyAndVisibilityBatch(List<Id> applicationIds){
        loanApplicationIds = applicationIds;
        system.debug('loanApplicationIds '+loanApplicationIds);
    }

    public Database.QueryLocator start(Database.BatchableContext context){
        String query;
        query = 'Select Id, Product__c, Collateral_Type__c From Loan_Application__c WHERE Id IN: loanApplicationIds WITH SECURITY_ENFORCED';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext context, List<Loan_Application__c> loanApps){
        try{
            loanApplications = loanApps;
            Map<Id, String> loanIdVsAccessibleProducts = RoleHierarchyAndVisibility.getAccessibleProducts(loanApps);
            for(Loan_Application__c loan: loanApps){
                if(loanIdVsAccessibleProducts.containsKey(loan.Id)){
                    loan.Product_Applicable_For__c = loanIdVsAccessibleProducts.get(loan.Id);
                }
            }
            if(Schema.sObjectType.Account.isUpdateable()){
                update loanApps;
            }
        }catch(Exception objException){
            Log.error(objException, Log.SeverityType.valueOf('High'),null);
        }
        
    }

    public void finish(Database.BatchableContext info){    
        system.debug(LoggingLevel.DEBUG, 'Inside FINISH');
    }
}