public with sharing class NomineeController {
    
    @AuraEnabled
    public static Applicant__c upsertData(Applicant__c nominee, Id recordId){
        
        if(nominee.RecordTypeId==null)
            nominee.RecordTypeId = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Nominee').getRecordTypeId();
        List<Applicant__c> newList =[select id, name, Customer_Name__c, Profile__c, Dob__c, Relationship_with_applicant__c, Percentage_Share_for_Nomination__c,Nominee_Address__c, Mobile_Number__c from Applicant__c where Loan__c=:recordId and id!=:nominee.Id and IsInactive__c=false and Recordtype.DeveloperName='Nominee' WITH SECURITY_ENFORCED];
        Integer totalNetPercent=0;
        for(Applicant__c app:newList){
            totalNetPercent=(Integer)(app.Percentage_Share_for_Nomination__c+totalNetPercent);
        }
        totalNetPercent=(Integer)(totalNetPercent+nominee.Percentage_Share_for_Nomination__c);
        if(totalNetPercent<=100){
            upsert nominee;
        }else{
            throw new AuraHandledException('Total Share for Nomination for all Nominees should add upto 100%');
        }
        
        
        Applicant__c nomineeRecord = [select id, name, Customer_Name__c, Dob__c, Profile__c, Relationship_with_applicant__c, Percentage_Share_for_Nomination__c,Nominee_Address__c, Mobile_Number__c,Appointee_Name__c,Appointee_DoB__c,Appointee_Relationship__c from Applicant__c where Id=:nominee.Id WITH SECURITY_ENFORCED]; //R2 Added these fields Appointee_Name__c,Appointee_DoB__c,Appointee_Relationship__c
        return nomineeRecord;
    }

    @AuraEnabled
    public static List<Applicant__c> getNomineeDetails(Id recordId){
        List<Applicant__c> nomineeList = [select id, name, Customer_Name__c, Profile__c, Dob__c, Relationship_with_applicant__c, Percentage_Share_for_Nomination__c,Nominee_Address__c, Mobile_Number__c,Appointee_Name__c,Appointee_DoB__c,Appointee_Relationship__c from Applicant__c where Loan__c=:recordId and IsInactive__c=false and Recordtype.DeveloperName='Nominee' WITH SECURITY_ENFORCED]; //R2 Added these fields Appointee_Name__c,Appointee_DoB__c,Appointee_Relationship__c
        return nomineeList;
    }

    @AuraEnabled
    public static List<Picklist_Value_Mapping__mdt> getRelationOptions(){
        List<Picklist_Value_Mapping__mdt> picklistValues = [select id, picklist_values__c, masterlabel from Picklist_Value_Mapping__mdt where masterlabel='Relation Master' WITH SECURITY_ENFORCED];
        return picklistValues;
    }

    @AuraEnabled
    public static Applicant__c deleteNominee(Id recordId){
        Applicant__c nominee = [Select id,IsInactive__c from Applicant__c where id=:recordId WITH SECURITY_ENFORCED];
        nominee.IsInactive__c=true;
        update nominee;
        Applicant__c nomineeRecord = [select id, name, Customer_Name__c, Profile__c, Dob__c, Relationship_with_applicant__c, Percentage_Share_for_Nomination__c,Nominee_Address__c, Mobile_Number__c from Applicant__c where Id=:nominee.Id WITH SECURITY_ENFORCED];
        return nomineeRecord;
    }
}