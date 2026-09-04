/**
 * Created by Mayur Sawant on 21/11/22.
 */
public without sharing class DatabaseUtility{

    public static void createRecords(List<sObject> sobjList, String sobjName){
        List<Object> errorsList = new List<Object> ();
        Database.SaveResult[] dbResult = Database.insert(sobjList, false);
        for(Integer i=0; i<dbResult.size(); i++){
            if (!dbResult[i].isSuccess()) {
                for(Database.Error err : dbResult[i].getErrors()){
                    String errLog = 'Message = \'Error: \'' +err.getStatusCode() + ';  Field: '+err.getFields() + ';  Error Messages: ' +err.getMessage() + ';  Failed Record: '+ sobjList[i];
                    errorsList.add(errLog);
                }
            }
        }
        if(!errorsList.isEmpty()){
            Log.error('',errorsList,Log.SeverityType.valueOf('High'),'');
        }
    }
    
    public static void updateRecords(List<sObject> sobjList, String sobjName){
        List<Object> errorsList = new List<Object> ();
        Database.SaveResult[] dbResult = Database.update(sobjList, false);
        for(Integer i=0; i<dbResult.size(); i++){
            if (!dbResult[i].isSuccess()) {
                for(Database.Error err : dbResult[i].getErrors()){
                    String errLog = 'Message = \'Error: \'' +err.getStatusCode() + ';  Field: '+err.getFields() + ';  Error Messages: ' +err.getMessage() + ';  Failed Record: '+ sobjList[i];
                    errorsList.add(errLog);
                }
            }
        }
        if(!errorsList.isEmpty()){
            Log.error('',errorsList,Log.SeverityType.valueOf('High'),'');
        }
    }
    
    public static void upsertRecords(List<sObject> sobjList, String sobjName){
        List<Object> errorsList = new List<Object> ();
        Database.UpsertResult[] dbResult = Database.upsert(sobjList, false);
        for(Integer i=0; i<dbResult.size(); i++){
            if (!dbResult[i].isSuccess()) {
                for(Database.Error err : dbResult[i].getErrors()){
                    String errLog = 'Message = \'Error: \'' +err.getStatusCode() + ';  Field: '+err.getFields() + ';  Error Messages: ' +err.getMessage() + ';  Failed Record: '+ sobjList[i];
                    errorsList.add(errLog);
                }
            }
        }
        if(!errorsList.isEmpty()){
            Log.error('',errorsList,Log.SeverityType.valueOf('High'),'');
        }
    }
    
    public static void deleteRecords(List<sObject> sobjList, String sobjName){
        List<Object> errorsList = new List<Object> ();
        Database.DeleteResult[] dbResult = Database.delete(sobjList, false);
        for(Integer i=0; i<dbResult.size(); i++){
            if (!dbResult[i].isSuccess()) {
                for(Database.Error err : dbResult[i].getErrors()){
                    String errLog = 'Message = \'Error: \'' +err.getStatusCode() + ';  Field: '+err.getFields() + ';  Error Messages: ' +err.getMessage() + ';  Failed Record: '+ sobjList[i];
                    errorsList.add(errLog);
                }
            }
        }
        if(!errorsList.isEmpty()){
            Log.error('',errorsList,Log.SeverityType.valueOf('High'),'');
        }
    }
    
    public static Database.SaveResult[] updateRecordsWithSaveResult(List<sObject> sobjList, String sobjName){
        List<Object> errorsList = new List<Object> ();
        Database.SaveResult[] dbResult = Database.update(sobjList, false);
        for(Integer i=0; i<dbResult.size(); i++){
            if (!dbResult[i].isSuccess()) {
                for(Database.Error err : dbResult[i].getErrors()){
                    String errLog = 'Message = \'Error: \'' +err.getStatusCode() + ';  Field: '+err.getFields() + ';  Error Messages: ' +err.getMessage() + ';  Failed Record: '+ sobjList[i];
                    errorsList.add(errLog);
                }
            }
        }
        if(!errorsList.isEmpty()){
            Log.error('',errorsList,Log.SeverityType.valueOf('High'),'');
        }
        return dbResult; //return SaveResult array back to calling method
    }
    
    public static Database.SaveResult[] createRecordsWithSaveResult(List<sObject> sobjList, String sobjName){
        List<Object> errorsList = new List<Object> ();
        Database.SaveResult[] dbResult = Database.insert(sobjList, false);
        for(Integer i=0; i<dbResult.size(); i++){
            if (!dbResult[i].isSuccess()) {
                for(Database.Error err : dbResult[i].getErrors()){
                    String errLog = 'Message = \'Error: \'' +err.getStatusCode() + ';  Field: '+err.getFields() + ';  Error Messages: ' +err.getMessage() + ';  Failed Record: '+ sobjList[i];
                    errorsList.add(errLog);
                }
            }
        }
        if(!errorsList.isEmpty()){
            Log.error('',errorsList,Log.SeverityType.valueOf('High'),'');
        }
        return dbResult; //return SaveResult array back to calling method
    }
}