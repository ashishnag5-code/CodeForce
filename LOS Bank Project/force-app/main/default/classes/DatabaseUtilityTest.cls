@IsTest
private class DatabaseUtilityTest {
    @IsTest
    static void testCreateRecords() {
        // Create test data
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2'),
            new Account(Name = 'Test Account 3')
        };
        
        Test.startTest();
        DatabaseUtility.createRecords(accounts, 'Account');
        
        
        List<Account> createdAccounts = [SELECT Id, Name FROM Account WHERE Name LIKE 'Test Account%'];
        System.assertEquals(accounts.size(), createdAccounts.size(), 'Incorrect number of accounts created');
        for (Account acc : createdAccounts) {
            System.assertNotEquals(null, acc.Id, 'Account not assigned an ID');
        }
        
        //Check failure during sobject record creation (not providing last name for 2nd Contact)
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(LastName = 'Contact1'));
        contacts.add(new Contact(LastName = ''));
        
        DatabaseUtility.createRecords(contacts, 'Contact');
        List<Contact> createdContacts = [SELECT Id, Name FROM Contact WHERE LastName LIKE 'Contact1%'];
        System.assertNotEquals(contacts.size(), createdContacts.size(), 'Fail: Only ' + createdContacts.size() + ' contact(s) has to be created');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testUpdateRecords() {
        
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2'),
            new Account(Name = 'Test Account 3')
        };
        insert accounts;
        
        for (Account acc : accounts) {
            acc.Name = 'Updated ' + acc.Name;
        }
        
        Test.startTest();
        DatabaseUtility.updateRecords(accounts, 'Account');
        
        List<Account> updatedAccounts = [SELECT Id, Name FROM Account WHERE Name LIKE 'Updated Test Account%'];
        System.assertEquals(accounts.size(), updatedAccounts.size(), 'Incorrect number of accounts updated');
        for (Account acc : updatedAccounts) {
            System.assertEquals(true, acc.Name.startsWith('Updated '), 'Account name not updated correctly');
        }
        
        //Check failure during sobject record updation by setting 
        //account name as blank and updating one more attribute, assert will make sure other attribute (Website) not updated
        for (Account acc : accounts) {
            acc.Name = '';
            acc.website = 'https://www.google.com';
        }
        
        DatabaseUtility.updateRecords(accounts, 'Account');
        
        updatedAccounts = [SELECT Id, Name FROM Account WHERE Website = 'https://www.google.com'];
        System.assertEquals(0, updatedAccounts.size(), 'Incorrect number of accounts updated');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testUpsertRecords() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2'),
            new Account(Name = 'Test Account 3')
        };
        
        Test.startTest();
        DatabaseUtility.upsertRecords(accounts, 'Account');
        
        List<Account> upsertedAccounts = [SELECT Id, Name FROM Account WHERE Name LIKE 'Test Account%'];
        System.assertEquals(accounts.size(), upsertedAccounts.size(), 'Incorrect number of accounts upserted');
        for (Account acc : upsertedAccounts) {
            System.assertNotEquals(null, acc.Id, 'Account not assigned an ID');
        }
        
        //Check failure during sobject record updation by setting 
        //account name as blank and updating one more attribute, assert will make sure other attribute (Website) not updated
        for (Account acc : accounts) {
            acc.Name = '';
            acc.website = 'https://www.google.com';
        }
        
        DatabaseUtility.upsertRecords(accounts, 'Account');
        
        upsertedAccounts = [SELECT Id, Name FROM Account WHERE Website = 'https://www.google.com'];
        System.assertEquals(0, upsertedAccounts.size(), 'Incorrect number of accounts updated');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testDeleteRecords() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2'),
            new Account(Name = 'Test Account 3')
        };
        insert accounts;
       
        Test.startTest();
        DatabaseUtility.deleteRecords(accounts, 'Account');
        
        List<Account> deletedAccounts = [SELECT Id, Name FROM Account WHERE Name LIKE 'Test Account%'];
        System.assertEquals(0, deletedAccounts.size(), 'Accounts were not deleted');
        
        //Creating an Account and associating it with a case record
        Account acc = new Account(Name = 'Demo Account');
        insert acc;
        Case cse = new Case(AccountId = acc.Id, Status = 'New', Origin = 'Email');
        insert cse;
        
        //Calling the delete method of the utility class which will fail as Account can be delete if any open cases are present
        DatabaseUtility.deleteRecords(new List<Sobject>{acc}, 'Account');
        deletedAccounts = [SELECT Id, Name FROM Account WHERE Name LIKE 'Demo Account%'];
        System.assertEquals(1, deletedAccounts.size(), 'Accounts were deleted');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testUpdateRecordsWithSaveResult() {
        // Create test data
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2'),
            new Account(Name = 'Test Account 3')
        };
        insert accounts;
        
        for (Account acc : accounts) {
            acc.Name = 'Updated ' + acc.Name;
        }
        Test.startTest();
        Database.SaveResult[] results = DatabaseUtility.updateRecordsWithSaveResult(accounts, 'Account');
        
        System.assertEquals(accounts.size(), results.size(), 'Incorrect number of save results');
        for (Database.SaveResult result : results) {
            System.assertEquals(true, result.isSuccess(), 'Save result should be successful');
        }
        
        List<Account> updatedAccounts = [SELECT Id, Name FROM Account WHERE Name LIKE 'Updated Test Account%'];
        System.assertEquals(accounts.size(), updatedAccounts.size(), 'Incorrect number of accounts updated');
        for (Account acc : updatedAccounts) {
            System.assertEquals(true, acc.Name.startsWith('Updated '), 'Account name not updated correctly');
        }
        
        //Check failure during sobject record updation by setting 
        //account name as blank and updating one more attribute, assert will make sure other attribute (Website) not updated
        for (Account acc : accounts) {
            acc.Name = '';
            acc.website = 'https://www.google.com';
        }
        
        results = DatabaseUtility.updateRecordsWithSaveResult(accounts, 'Account');
        System.assertEquals(accounts.size(), results.size(), 'Incorrect number of save results');
        
        updatedAccounts = [SELECT Id, Name FROM Account WHERE Website = 'https://www.google.com'];
        System.assertEquals(0, updatedAccounts.size(), 'Incorrect number of accounts updated');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testCreateRecordsWithSaveResult() {
        // Create test data
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Test Account 1'),
            new Account(Name = 'Test Account 2'),
            new Account(Name = 'Test Account 3')
        };
        
        Test.startTest();
        Database.SaveResult[] results = DatabaseUtility.createRecordsWithSaveResult(accounts, 'Account');
        
        System.assertEquals(accounts.size(), results.size(), 'Incorrect number of save results');
        for (Database.SaveResult result : results) {
            System.assertEquals(true, result.isSuccess(), 'Save result should be successful');
        }
        
        List<Account> createdAccounts = [SELECT Id, Name FROM Account WHERE Name LIKE 'Test Account%'];
        System.assertEquals(accounts.size(), createdAccounts.size(), 'Incorrect number of accounts created');
        for (Account acc : createdAccounts) {
            System.assertNotEquals(null, acc.Id, 'Account not assigned an ID');
        }
        
        //Check failure during sobject record creation (not providing last name for 2nd Contact)
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(LastName = 'Contact1'));
        contacts.add(new Contact(LastName = ''));
        
        results = DatabaseUtility.createRecordsWithSaveResult(contacts, 'Contact');
        System.assertEquals(contacts.size(), results.size(), 'Incorrect number of save results');
        
        List<Contact> createdContacts = [SELECT Id, Name FROM Contact WHERE LastName LIKE 'Contact1%'];
        System.assertNotEquals(contacts.size(), createdContacts.size(), 'Fail: Only ' + createdContacts.size() + ' contact(s) has to be created');
        
        Test.stopTest();
    }
}