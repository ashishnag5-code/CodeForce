/*****
 * Class Name: BatchsObjectRecordDelete
 * Description: Delete sObjectRecords
 * Test Class Name: BatchsObjectRecordDeleteTest
 * 
 * LastModified Date    -   Last Modified By    -   Description
 * Nov-07-2023          -   Mohit M.            -   
 */
public class BatchsObjectRecordDelete implements Database.Batchable<sObject> {
    public String strQuery = '';
    public Set<Id> setCreatedById = new Set<Id>();
    public Set<Id> setOwnerId = new Set<Id>();
    public Set<String> setStage = new Set<String>();
    
    public BatchsObjectRecordDelete (String strQuery) {
        this.strQuery = strQuery;
    }

    public BatchsObjectRecordDelete (String strQuery, Set<Id> setCreatedById, Set<Id> setOwnerId, Set<String> setStage) {
        this.setCreatedById = setCreatedById;
        this.setOwnerId = setOwnerId;
        this.setStage = setStage;
        this.strQuery = strQuery;
    }

    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(strQuery);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        // Delete Records
        delete scope;
        // Empty Recycle Bin
        Database.emptyRecycleBin(scope); 
    }
    
    public void finish(Database.BatchableContext BC) {
        
    }
}