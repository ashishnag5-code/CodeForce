public with sharing class MobileCompatibleDataTableController {
    @AuraEnabled
    public static List<Object_Data_Table__mdt> getCustomMetadataColumns(String metadataName){
      	String name='Applicant_Data';
        List<Object_Data_Table__mdt> objDataTableList = new List<Object_Data_Table__mdt>();
        String strQuery = 'SELECT  HeaderField__c,Icon__c,CheckboxColumn__c, (SELECT FieldApi_Name__c, Sortable__c, Field_Label__c, Order__c, DataType__c   FROM Fields_Data_Tables__r where Active__c =true and Order__c!=null ORDER BY Order__c ASC) FROM Object_Data_Table__mdt WHERE DeveloperName=:name LIMIT 1';
        try{
            objDataTableList = database.query(strQuery);
        }catch(Exception e){
            throw new AuraHandledException('Please give correct MetaDataType Name which has HeaderField__c, Columns_MetaData__c and Icon__c' );   
        }
        return objDataTableList;
    }
    
    
    
    /*public static List < Map < String, String >> getPickListValues(String objApiName, String fieldName) {
        List < Map < String, String >> options = new List < Map < String, String >> ();
        Map < String, Schema.SObjectType > objGlobalMap = Schema.getGlobalDescribe();
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objApiName);
        if (objType == null) {
            return options;
        }
        Schema.DescribeSObjectResult sobjectDescribe = objType.getDescribe();
        Map < String, Schema.SObjectField > fieldMap = sobjectDescribe.fields.getMap();
        if (fieldMap.get(fieldName) == null) {
            return options;
        }
        List < Schema.PicklistEntry > pickListValues = fieldMap.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry f: pickListValues) {
            Map < String, String > values = new Map < String, String > {
                'label' => f.getLabel(),
                'value' => f.getValue()
            };
            options.add(values);
        }
        return options;
    }*/
}