public class MarkSchemeInActiveDailyBatch implements Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC){

        /*String query = 'Select Id, START_DATE__c, EXPIRY_DATE__c, Is_InActive__c From 
        Scheme_Master__c where START_DATE__c!=null and EXPIRY_DATE__c!=null order by createddate desc limit 1';
        for test purpose*/
        String query = 'Select Id, START_DATE__c, EXPIRY_DATE__c, Is_InActive__c From Scheme_Master__c';
        return Database.getQueryLocator(query);
     }

     public void execute(Database.BatchableContext BC, List<Scheme_Master__c> schemes){
        system.debug('Schemes '+schemes);
        for(Scheme_Master__c scheme : schemes){
            if((scheme.START_DATE__c<Date.today() && scheme.EXPIRY_DATE__c<Date.today()) || (scheme.START_DATE__c>Date.today())){
                scheme.Is_InActive__c = true;
                system.debug(scheme.Id);
            }
        }
        update schemes;
    }

    public void finish(Database.BatchableContext info){     
    }


}