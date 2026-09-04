public with sharing class TrancheController {

    @AuraEnabled
    public static List<String> getVisibleFieldsForLoanDetails(String strScreen, String strStage, String strProfile){

        List<String> visibleFields = new List<String>();
        visibleFields = Utility.getVisibleFields(strScreen, strStage, strProfile);
        return visibleFields;

    }

    @AuraEnabled
    public static List<Payment__c> upsertData(List<Payment__c> tranche, Id loanId){
        
        for(Payment__c pay: tranche){
            if(pay.RecordTypeId==null)
                pay.RecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Tranche').getRecordTypeId();
            if(pay.Loan_Application__c==null)
                pay.Loan_Application__c = loanId;
        }
         
        upsert tranche;
        
        List<Payment__c> trancheRecords = getTrancheDetails(loanId);
        return trancheRecords;
    }

    @AuraEnabled
    public static List<Payment__c> getTrancheDetails(Id recordId){
        List<Payment__c> trancheList = [select id, name, RecordTypeId, Tranche_Status__c, Disbursement_Amount__c, Partial_Payment_Condition__c, Tranche_Number__c from Payment__c where loan_application__c=:recordId and RecordType.Developername='Tranche' and Inactive__c=false WITH SECURITY_ENFORCED order by Tranche_Number__c];
        return trancheList;
    }

    @AuraEnabled
    public static List<Payment__c> deleteTranche(List<Id> recordIds, Id loanId){
        integer num=1;
        List<Payment__c> tranche = [select id, name, Inactive__c, Tranche_Status__c,Disbursement_Amount__c, Partial_Payment_Condition__c, Tranche_Number__c from Payment__c where  RecordType.Developername='Tranche' and Inactive__c=false and loan_application__c=:loanId WITH SECURITY_ENFORCED order by Tranche_Number__c];
        system.debug('tranche '+tranche);
        for(Payment__c record:tranche){
            if(recordIds.contains(record.Id)){
                record.Inactive__c=true;
            }else{
                record.Tranche_Number__c=num;
                num++;
            }
        }
              
        update tranche;
        List<Payment__c> trancheRecords = getTrancheDetails(loanId);
        return trancheRecords;
    }
}