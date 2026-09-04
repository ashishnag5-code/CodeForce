public with sharing class GenericDataDisplayController {
    public GenericDataDisplayController() {

    }

    @AuraEnabled
    public static List<Display_Data__mdt> getMetadataRecords(String type){
        
        Map<String, Display_Data__mdt> recordMap = new Map<String, Display_Data__mdt>();
        List<Display_Data__mdt> records = [Select API_Name__c, Display_on_UI__c, JSON_Key__c, Order__c, Type__c, DeveloperName, MasterLabel 
        from Display_Data__mdt where Type__c=:type and Display_on_UI__c=true order by Order__c];
        for(Display_Data__mdt record: records){
            recordMap.put(record.JSON_Key__c, record);
        }
        
        return records;
    }
}