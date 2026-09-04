public without sharing class RecordAccessExceptionHandler {
    public RecordAccessExceptionHandler() {

    }

    @AuraEnabled
    public static Id updatePaymentFavouringAtOpsAuth(String paymentStr){
        if(String.isBlank(paymentStr)){
            return '';
        }
        Payment__c payment = (Payment__c) JSON.deserialize(paymentStr, Payment__c.Class);
        try {
            update payment;
            return payment.Id;
        } catch (Exception e) {
            Log.error('Error in RecordAccessExceptionHandler method updatePaymentFavouringAtOpsAuth :: ' + e.getMessage(),Log.SeverityType.valueOf(GlobalConstants.SEVERITYTYPE_HIGH),payment.Id);
            return null;
        }
    }

    @AuraEnabled
    public static void deleteBankStatement(String recordId, String conDocId){
        try {
            Id cartRedTypeId = Schema.SObjectType.Bank_Account_Records__c.getRecordTypeInfosByName().get('Cart').getRecordTypeId();
            // List<Document_Checklist__c> docCheckList = [SELECT Id FROM Document_Checklist__c WHERE Applicant__c=:recordId AND
            // Document_Master__r.Name=:docName];
            // List<ContentDocumentLink> cdl = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=:docCheckList[0].Id];
            // List<String> links = new List<String>();
            // for(ContentDocumentLink link: cdl){
            //     links.add(link.ContentDocumentId);
            // }
            database.Delete([SELECT Id FROM ContentDocument WHERE ID=:conDocId]);
            database.Delete([SELECT Id FROM Bank_Account_Records__c WHERE Applicant__c =:recordId AND RecordTypeId =:cartRedTypeId AND Manual_Check__c = false]);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}