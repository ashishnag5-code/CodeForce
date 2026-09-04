public without sharing class GenericCustomLookupController {
    private Static Boolean isTabAvailable = false;
    @AuraEnabled(cacheable=true)
    public static SObjectWrapperList search(String searchTerm, string searchQuery, string myObject, string fieldApi, string myrecordTypeName, string dependencyQuery, string dependencyWhereClause) {
        
        String filter = '';
        String recordTypeId = '';
        SObjectType myObjectToken = Schema.getGlobalDescribe().get(myObject);
        system.debug('searchTerm'+searchTerm);
        system.debug('searchQuery'+searchQuery);
        system.debug('myObject'+myObject);
        system.debug('fieldApi'+fieldApi);
        system.debug('myrecordTypeName'+myrecordTypeName);
        system.debug('dependencyQuery'+dependencyQuery);
        system.debug('dependencyWhereClause'+dependencyWhereClause);
        
        
        if(String.isNotBlank(myrecordTypeName)){
            recordTypeId = getRecordTypeId(myObjectToken, myrecordTypeName);
        }
        system.debug('recordTypeId'+recordTypeId);
        System.debug('Searchable fields = '+filter);
        String myQuery = null;
        SObjectWrapperList sobjWrapper = new SObjectWrapperList();
        sobjWrapper.iconName = getIconName(myObject);
        sobjWrapper.sObjectList = new List<sObject>();
        
        if(String.isBlank(searchTerm)){
            if(isTabAvailable){
                if(String.isBlank(recordTypeId)){
                    if(String.isBlank(dependencyQuery) && String.isBlank(dependencyWhereClause)){
                        myQuery = 'Select Id, Name  from '+myObject+' Where Id != NULL ORDER BY LastViewedDate DESC LIMIT  10'; 
                    }
                    else{
                        myQuery = 'Select Id, Name, '+dependencyQuery+' from '+myObject+' Where Id != NULL '+dependencyWhereClause+' ORDER BY LastViewedDate DESC LIMIT  10';   
                    }
                }
                else{
                    if(String.isBlank(dependencyQuery) && String.isBlank(dependencyWhereClause)){
                        myQuery = 'Select Id, Name  from '+myObject+' Where Id != NULL AND RecordTypeId =: recordTypeId ORDER BY LastViewedDate DESC LIMIT  10'; 
                    }
                    else if(searchQuery.contains('Purchase_City__c')){
                        myQuery = 'Select Id, Name, '+dependencyQuery+' from '+myObject+' Where Id != NULL AND RecordTypeId =: recordTypeId '+dependencyWhereClause+' ORDER BY LastViewedDate DESC LIMIT  200';    
                    }else{
                        myQuery = 'Select Id, Name, '+dependencyQuery+' from '+myObject+' Where Id != NULL AND RecordTypeId =: recordTypeId '+dependencyWhereClause+' ORDER BY LastViewedDate DESC LIMIT  10';    
                    }
                }
            }else{
                if(String.isBlank(recordTypeId)){
                    if(String.isBlank(dependencyQuery) && String.isBlank(dependencyWhereClause)){
                        if(myObject == 'Group'){
                            myQuery = 'Select Id, Name  from '+myObject+' Where Id != NULL AND TYPE=\'Queue\' ORDER BY Id DESC LIMIT  10';
                        }
                        else{
                            myQuery = 'Select Id, Name  from '+myObject+' Where Id != NULL ORDER BY Id DESC LIMIT  10';
                        }
                        
                    }
                    else{
                        myQuery = 'Select Id, Name, '+dependencyQuery+' from '+myObject+' Where Id != NULL '+dependencyWhereClause+' ORDER BY Id DESC LIMIT  10';
                    }
                }
                else{
                   if(String.isBlank(dependencyQuery) && String.isBlank(dependencyWhereClause)){
                        myQuery = 'Select Id, Name  from '+myObject+' Where Id != NULL AND RecordTypeId =: recordTypeId ORDER BY Id DESC LIMIT  10';
                    }
                    else{
                        myQuery = 'Select Id, Name, '+dependencyQuery+' from '+myObject+' Where Id != NULL AND RecordTypeId =: recordTypeId '+dependencyWhereClause+' ORDER BY Id DESC LIMIT  10';   
                    }
                }
            }
        }else{
            if(String.isNotBlank(filter)){
                if(filter.contains(',')){
                    
                }else{
                    if(String.isBlank(recordTypeId)){
                        if(String.isBlank(dependencyQuery) && String.isBlank(dependencyWhereClause)){
                            myQuery = 'Select Id, Name, '+filter+'  from '+myObject+' Where '+searchQuery+' OR '+filter+' Like  \'%'+searchTerm+'%\' LIMIT  10';
                        }
                        else{
                            myQuery = 'Select Id, Name, '+filter+', '+dependencyQuery+' from '+myObject+' Where ('+searchQuery+' OR '+filter+' Like  \'%'+searchTerm+'%\') '+dependencyWhereClause+' LIMIT  10';   
                        }
                    }
                    else{
                        if(String.isBlank(dependencyQuery) && String.isBlank(dependencyWhereClause)){
                            myQuery = 'Select Id, Name, '+filter+'  from '+myObject+' Where ('+searchQuery+' OR '+filter+' Like  \'%'+searchTerm+'%\') AND RecordTypeId =: recordTypeId LIMIT  10';
                        }
                        else{
                            myQuery = 'Select Id, Name, '+filter+', '+dependencyQuery+' from '+myObject+' Where ('+searchQuery+' OR '+filter+' Like  \'%'+searchTerm+'%\') AND RecordTypeId =: recordTypeId '+dependencyWhereClause+' LIMIT  10';   
                        }
                    }
                }
            }else{
                if(String.isBlank(recordTypeId)){
                    if(String.isBlank(dependencyQuery) && String.isBlank(dependencyWhereClause)){
                         myQuery = 'Select Id, Name  from '+myObject+' Where '+searchQuery+' LIMIT  10';
                    }
                    else{
                        myQuery = 'Select Id, Name, '+dependencyQuery+' from '+myObject+' Where '+searchQuery+' '+dependencyWhereClause+ ' LIMIT  10';    
                    }
                }
                else{
                    if(String.isBlank(dependencyQuery) && String.isBlank(dependencyWhereClause)){
                       myQuery = 'Select Id, Name  from '+myObject+' Where '+searchQuery+' AND RecordTypeId =: recordTypeId LIMIT  10'; 
                    }
                    else if(searchQuery.contains('Purchase_City__c')){
                        myQuery = 'Select Id, Name, '+dependencyQuery+' from '+myObject+' Where '+searchQuery+' AND RecordTypeId =: recordTypeId '+dependencyWhereClause+' LIMIT  200';   
                    }else{
                        myQuery = 'Select Id, Name, '+dependencyQuery+' from '+myObject+' Where '+searchQuery+' AND RecordTypeId =: recordTypeId '+dependencyWhereClause+' LIMIT  100' ;   
                    }
                }
            }
        }
        
        
        /*if(filter != null && filter != ''){
myQuery = 'Select Id, Name  from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' AND '+filter+' LIMIT  5';
}
else {
if(searchTerm == null || searchTerm == ''){

}
else {

}
}*/
        System.debug('Search query is = '+myQuery);
        sobjWrapper.sObjectList.addAll(database.query(myQuery));
        System.debug('Size - '+sobjWrapper.sObjectList.size());
        return sobjWrapper;
    }
    @AuraEnabled(cacheable=true)
    public static SObjectWrapperList fetchLookupData(string searchKey , string sObjectApiName) {   
        System.debug('searchKey is - '+searchKey);
        System.debug('sObjectApiName is - '+sObjectApiName);
        List < sObject > returnList = new List < sObject > ();
        SObjectWrapperList sobjWrapper = new SObjectWrapperList();
        sobjWrapper.iconName = getIconName(sObjectApiName);
        sobjWrapper.sObjectList = new List<sObject>();
        string sWildCardText = '%' + searchKey + '%';
        string sQuery = 'Select Id,Name  From ' + sObjectApiName + ' Where Name Like : sWildCardText order by createdDate DESC LIMIT 5';
        System.debug('sQuery is - '+sQuery);
        for (sObject obj: database.query(sQuery)) {
            sobjWrapper.sObjectList.add(obj);
        }
        System.debug('Response is - '+sobjWrapper);
        return sobjWrapper;
    }
    
    public static String getIconName(String searchObject){
        System.debug('Sobject name - '+searchObject);
        String iconName;
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.DescribeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();
        
        for(Schema.DescribeTabSetResult tsr : tabSetDesc) { 
            tabDesc.addAll(tsr.getTabs()); 
        }
        isTabAvailable = false;
        for(Schema.DescribeTabResult tr : tabDesc) {
            if( searchObject == tr.getSobjectName() ) {
                isTabAvailable = true;
                if( tr.isCustom() ) {
                    iconDesc.addAll(tr.getIcons());
                } else {
                    iconName = 'standard:' + searchObject.toLowerCase();
                }
            }
        }
        for (Schema.DescribeIconResult ir : iconDesc) {
            if (ir.getContentType() == 'image/svg+xml'){
                iconName = 'custom:' + ir.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                break;
            }
        }
        return iconName != NULL? iconName: 'custom:custom33';
    } 
    
    
    // Method to fetch lookup default value 
    @AuraEnabled
    public static SObjectWrapperList fetchDefaultRecord(string recordId , string sObjectApiName) {
        System.debug('Sobject name - '+sObjectApiName);
        System.debug('recordId is - '+recordId);
        string sRecId = recordId;    
        SObjectWrapperList sobjList = new SObjectWrapperList();
        sobjList.iconName = GenericUIFrameworkUtility.getIconName(sObjectApiName);
        sobjList.sObjectList = new List<sObject>();
        string sQuery;
        if(sObjectApiName == 'Generic_Master__c'){
            sQuery = 'Select Id,Name,Company_Name__c, Name__c, Bank_Name__c  From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
        }else{
            sQuery = 'Select Id,Name  From ' + sObjectApiName + ' Where Id = : sRecId LIMIT 1';
        }
            
        
        
        for (sObject obj: database.query(sQuery)) {
            sobjList.sObjectList.add(obj);
        }
        System.debug('sobjList is - '+sobjList);
        return sobjList;
    }
    
    // Method to fetch lookup default value 
    @AuraEnabled
    public static SObjectWrapperList fetchDefaultColor(string fetchDefaultColor) {
        System.debug('recordId is - '+fetchDefaultColor);
        string sRecId = fetchDefaultColor;  
        Id recordTypeIdValue = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get('Vehicle Color').getRecordTypeId();
        SObjectWrapperList sobjList = new SObjectWrapperList();
        sobjList.iconName = GenericUIFrameworkUtility.getIconName('Generic_Master__c');
        sobjList.sObjectList = new List<sObject>();
        string sQuery;
       
            sQuery = 'Select Id,Color_Code__c  From Generic_Master__c Where Color_Code__c = : sRecId AND recordTypeId=:recordTypeIdValue LIMIT 1';
        
         
        for (sObject obj: database.query(sQuery)) {
            sobjList.sObjectList.add(obj);
        }
        System.debug('sobjList is - '+sobjList);
        return sobjList;
    }

    @AuraEnabled
    public static SObjectWrapperList fetchDefaultIssuerCompany(String defaultIssuerCompany){
        SObjectWrapperList sobjList = new SObjectWrapperList();
        sobjList.iconName = GenericUIFrameworkUtility.getIconName('Generic_Master__c');
        sobjList.sObjectList = [SELECT Id, Name__c FROM Generic_Master__c WHERE Name__c != NULL AND Name__c =: defaultIssuerCompany AND RecordType.Name = 'Previous Insurer' LIMIT 1 ];
        System.debug('sobjList is - '+ JSON.serializePretty(sobjList));
        return sobjList;
    }
    
    public class SObjectWrapperList{
        @auraenabled
        public String iconName											{get;set;}
        @auraenabled
        public List<sObject> sObjectList								{get;set;}
    }
    
    public static Id getRecordTypeId(SObjectType entity, String recordTypeName) {
        try {
            return entity
                .getDescribe()
                .getRecordTypeInfosByName()
                .get(recordTypeName)
                .getRecordTypeId();
        } catch(Exception e) {
            return null;
        }
    }
}