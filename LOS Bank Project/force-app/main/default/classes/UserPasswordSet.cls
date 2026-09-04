global class UserPasswordSet implements Database.Batchable<sObject>
{
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        string str = '%field%';
        string name = '%krishan%';
        String query = 'SELECT id, name, profileId, profile.name, createdDate, email from user where profile.name like: str And createdby.name like: name AND CreatedDate >= 2023-06-19T14:11:53.000+0000';            
        system.debug('query PRINTED ' + query);
        list<sobject>lstobj = database.query(query);
        system.debug('result ' +lstobj.size());
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<User> scope)
    {
        List<user> lstUser = new List<User>();
        for(User u : scope)
        {
            if(u.Id != null){
                System.setPassword(u.id, 'sfdc@12345'); 
            }
            lstUser.add(u);
        }
        Database.SaveResult[] srList = Database.update(lstUser, false);
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully updated Record with ID: ' + sr.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('User fields that affected this error: ' + err.getFields());
                }
            }
        }
    }
    global void finish(Database.BatchableContext BC) {
    }
}