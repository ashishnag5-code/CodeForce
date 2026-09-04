public with sharing class CancelledPDFController {
    
    public static List<Generic_Master__c> objGenericMaster{get;set;}
    
    public CancelledPDFController() {
        objGenericMaster = [Select Id,Letter_Name__c,Letter_Content__c from Generic_Master__c where 
                            Letter_Name__c = 'Cancelled Letter'];
    } 

}