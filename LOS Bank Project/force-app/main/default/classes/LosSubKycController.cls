public with sharing class LosSubKycController {

    @AuraEnabled
    public static String getDocumentChecklistId(String applicantId){
        return [SELECT id FROM Document_Checklist__c WHERE Applicant__c =: applicantId AND Document_Master__r.Document_Name__c ='Aadhaar Card'][0].id;
    }
}